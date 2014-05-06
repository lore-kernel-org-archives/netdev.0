From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: [PATCH net] bonding: fix vlan_features computing
Date: Tue, 6 May 2014 10:44:46 +0200
Message-ID: <20140506084446.GA18366@unicorn.suse.cz>
References: <20140502165448.D8078E635B@unicorn.suse.cz>
 <20140505.234500.89241173582893591.davem@davemloft.net>
 <17712.1399362807@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	vfalico@gmail.com, andy@greyhouse.net, mirq-linux@rere.qmqm.pl
To: Jay Vosburgh <jay.vosburgh@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:58831 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934374AbaEFIot (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 May 2014 04:44:49 -0400
Content-Disposition: inline
In-Reply-To: <17712.1399362807@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 06, 2014 at 12:53:27AM -0700, Jay Vosburgh wrote:
> 
> 	The VLAN device doesn't get _HW_CSUM (aka _GEN_CSUM)?  In
> ethtool, this is tx-checksum-ip-generic, I believe.
> 
> 	I have only one machine with a _IP_CSUM only device (a tg3) set
> up at the moment, it's running a Fedora 20 3.13 kernel, and a vlan ->
> bond0 -> eth0 stack shows "generic" offload for the vlan and bond0, and
> "ipv4" offload for the eth0 itself.
> 
> 	Is that not what you're seeing?  Did this used to work correctly
> for you?  Does ethtool -K permit you to enable checksum offload on the
> VLAN device?

In my case the problem is that while bond has HW_CSUM in vlan_features,
it has (only) IP_CSUM and IPV6_CSUM in features. As vlan starts with
features of its real_dev and masks them with real_dev's vlan_features,
the result is no checksum offloading.

However, I realized now that while I checked that vlan_features
computing hasn't changed since 3.0, I didn't do the same with features
so I better retest with mainline kernel.

But even if bond's features are set to HW_CSUM, I still don't think the
logic of bond_compute_features() is correct:

> >I thought the whole idea with bond_compute_features() is that you
> >could start with "everything" enabled, and as you add devices the
> >feature bits get chopped off based upon what each slave can do.
> 
> 	For VLANs, it was originally the other way around; the features
> started with nothing, and the various slaves' offloads were added to the
> vlan_features.

My understanding is that there are two types of features: additive
(NETIF_F_ONE_FOR_ALL, support in one slave is sufficient) and
subtractive (NETIF_F_ALL_FOR_ALL, all slaves must support). That is how
netdev_increment_features works (except the additional checksumming
cleanup). For this to work, we should start with 0 for additive features
and 1 for subtractive ones.

The problem IMHO is that bond_compute_features() initializes the value
with BOND_VLAN_FEATURES which is a subset of NETIF_F_ONE_FOR_ALL.
Therefore these flags always stay on in vlan_features no matter what
slaves have (except cleaned up checksumming). But if this was intended,
we wouldn't need to cycle through slaves at all and could always set
vlan_features to BOND_VLAN_FEATURES (minus non-generic checksumming).

> 	So this patch may work for the case that the slaves are
> homogenous, but if one is _HW_CSUM (aka _GEN_CSUM) and one is only _IP
> or _IPV6, there may still be a problem because the _HW_CSUM slave will
> get its feature bit at the VLAN level, but the other one will not, and I
> thought that the mixed offload slaves case previously worked correctly.

I tried to go through this and I believe it is safe to advertise HW_CSUM
even if some slaves support only IP_CSUM (and possibly IPV6_CSUM). Even
if the vlan assumes the packet can be checksummed but it is sent away by
a slave not supporting that, the can_checksum_protocol() test in
dev_hard_start_xmit() would detect that and checksum would be calculated
in software. For IP(v6) packets, can_checksum_protocol() should return
true for all three devices and packet would be checksummed by the slave
it is sent by.

                                                          Michal Kubecek
