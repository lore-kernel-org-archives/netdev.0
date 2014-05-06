From: Jay Vosburgh <jay.vosburgh@canonical.com>
Subject: Re: [PATCH net] bonding: fix vlan_features computing
Date: Tue, 06 May 2014 00:53:27 -0700
Message-ID: <17712.1399362807@localhost.localdomain>
References: <20140502165448.D8078E635B@unicorn.suse.cz> <20140505.234500.89241173582893591.davem@davemloft.net>
Cc: mkubecek@suse.cz, netdev@vger.kernel.org, vfalico@gmail.com,
	andy@greyhouse.net, mirq-linux@rere.qmqm.pl
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:37069 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934069AbaEFHxg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 May 2014 03:53:36 -0400
In-reply-to: <20140505.234500.89241173582893591.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:

>From: Michal Kubecek <mkubecek@suse.cz>
>Date: Fri,  2 May 2014 18:54:48 +0200 (CEST)
>
>> bond_compute_features() uses netdev_increment_features() to
>> combine vlan_features of slaves into vlan_features of the bond.
>> As netdev_increment_features() only adds most features and we
>> start with BOND_VLAN_FEATURES, we may end up with features none
>> of the slaves provided.
>> 
>> In particular, BOND_VLAN_FEATURES contains NETIF_F_HW_CSUM so
>> that netdev_increment_features() clears NETIF_F_IP{,V6}_CSUM and
>> if we only have slaves with NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM
>> (e.g. ixgbe based cards), the same will be in features of the
>> bond and a vlan device on top of the bond would support no
>> checksumming, resulting in significant performance degradation.

	The VLAN device doesn't get _HW_CSUM (aka _GEN_CSUM)?  In
ethtool, this is tx-checksum-ip-generic, I believe.

	I have only one machine with a _IP_CSUM only device (a tg3) set
up at the moment, it's running a Fedora 20 3.13 kernel, and a vlan ->
bond0 -> eth0 stack shows "generic" offload for the vlan and bond0, and
"ipv4" offload for the eth0 itself.

	Is that not what you're seeing?  Did this used to work correctly
for you?  Does ethtool -K permit you to enable checksum offload on the
VLAN device?

>> If there is at least one slave, initialize vlan_features only
>> with the flags in NETIF_F_ALL_FOR_ALL. Right now there is none
>> in BOND_VLAN_FEATURES but stating it explicitely will make the
>> code more future proof.
>> 
>> Signed-off-by: Michal Kubecek <mkubecek@suse.cz>
>
>Jay and others can you take a look at this one?
>
>I find that handling of NETIF_F_GEN_CSUM (which is basically just
>a synonym for NETIF_F_HW_CSUM) strange.
>
>I thought the whole idea with bond_compute_features() is that you
>could start with "everything" enabled, and as you add devices the
>feature bits get chopped off based upon what each slave can do.

	For VLANs, it was originally the other way around; the features
started with nothing, and the various slaves' offloads were added to the
vlan_features.

>But the special NETIF_F_GEN_CSUM in bond_compute_features() seems to
>defeat that.

	I've been looking through the feature code for the last hour,
and I see what's going on in netdev_increment_features, but not why the
vlan device ends up with no offloads at all.

	My recollection is that, currently, the bond advertises that it
is checksum offload capable (via _CSUM_ALL in BOND_VLAN_FEATURES), the
VLAN device believes it (picks up the feature bit), and when the skb is
sent down through the bond, when it reaches the actual bottom of the
stack, then the skb would have checksum offload applied according to the
features of the final transmit device.

	So this patch may work for the case that the slaves are
homogenous, but if one is _HW_CSUM (aka _GEN_CSUM) and one is only _IP
or _IPV6, there may still be a problem because the _HW_CSUM slave will
get its feature bit at the VLAN level, but the other one will not, and I
thought that the mixed offload slaves case previously worked correctly.

	I'll also point out that the team driver does the same thing as
bonding with regard to the handling of vlan_features, so whatever ends
up changing in bonding should probably be updated in team as well.

	-J

---
	-Jay Vosburgh, jay.vosburgh@canonical.com
