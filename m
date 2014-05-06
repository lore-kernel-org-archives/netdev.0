From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bonding: fix vlan_features computing
Date: Mon, 05 May 2014 23:45:00 -0400 (EDT)
Message-ID: <20140505.234500.89241173582893591.davem@davemloft.net>
References: <20140502165448.D8078E635B@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, j.vosburgh@gmail.com, vfalico@gmail.com,
	andy@greyhouse.net, mirq-linux@rere.qmqm.pl
To: mkubecek@suse.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36132 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933739AbaEFDpC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 May 2014 23:45:02 -0400
In-Reply-To: <20140502165448.D8078E635B@unicorn.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michal Kubecek <mkubecek@suse.cz>
Date: Fri,  2 May 2014 18:54:48 +0200 (CEST)

> bond_compute_features() uses netdev_increment_features() to
> combine vlan_features of slaves into vlan_features of the bond.
> As netdev_increment_features() only adds most features and we
> start with BOND_VLAN_FEATURES, we may end up with features none
> of the slaves provided.
> 
> In particular, BOND_VLAN_FEATURES contains NETIF_F_HW_CSUM so
> that netdev_increment_features() clears NETIF_F_IP{,V6}_CSUM and
> if we only have slaves with NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM
> (e.g. ixgbe based cards), the same will be in features of the
> bond and a vlan device on top of the bond would support no
> checksumming, resulting in significant performance degradation.
> 
> If there is at least one slave, initialize vlan_features only
> with the flags in NETIF_F_ALL_FOR_ALL. Right now there is none
> in BOND_VLAN_FEATURES but stating it explicitely will make the
> code more future proof.
> 
> Signed-off-by: Michal Kubecek <mkubecek@suse.cz>

Jay and others can you take a look at this one?

I find that handling of NETIF_F_GEN_CSUM (which is basically just
a synonym for NETIF_F_HW_CSUM) strange.

I thought the whole idea with bond_compute_features() is that you
could start with "everything" enabled, and as you add devices the
feature bits get chopped off based upon what each slave can do.

But the special NETIF_F_GEN_CSUM in bond_compute_features() seems to
defeat that.
