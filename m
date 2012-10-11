From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: unresponsive vlan on top of bond with fail_over_mac=active
Date: Wed, 10 Oct 2012 20:34:31 -0700
Message-ID: <8588.1349926471@death.nxdomain>
References: <20121010231122.GB28935@unicorn.suse.cz>
Cc: netdev@vger.kernel.org, Andy Gospodarek <andy@greyhouse.net>
To: Michal Kubecek <mkubecek@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:54681 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932783Ab2JKDet (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2012 23:34:49 -0400
Received: from /spool/local
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Wed, 10 Oct 2012 21:34:48 -0600
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 126F219D803F
	for <netdev@vger.kernel.org>; Wed, 10 Oct 2012 21:34:34 -0600 (MDT)
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q9B3YX0n242364
	for <netdev@vger.kernel.org>; Wed, 10 Oct 2012 21:34:33 -0600
Received: from d03av05.boulder.ibm.com (loopback [127.0.0.1])
	by d03av05.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q9B3YXJl026224
	for <netdev@vger.kernel.org>; Wed, 10 Oct 2012 21:34:33 -0600
In-reply-to: <20121010231122.GB28935@unicorn.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Michal Kubecek <mkubecek@suse.cz> wrote:

>Hello,
>
>a customer of ours has the following problem:
>
>A bond is set up in active-backup mode with fail_over_mac=1 (active). On
>top of it, a VLAN is created so that it inherits MAC address of the bond
>which is the same as address of its active slave.
>
>When failover occurs, the bond switches its MAC address to address of
>the new active slave but VLAN interface keeps the old address and it
>stops receiving packets from outside.

	What network device are they using that requires fail_over_mac
to be set to active?  The intended user of this facility is IPoIB, which
does not support VLANs (and therefore does not have this problem).  For
regular Ethernet, the active setting is not generally a good choice, as
network peers must be updated via gratutious ARP when a failover occurs,
so there is really no advantage to using it.

>The customer suggested that upon failover, not only bond should switch
>its MAC address to the new active slave but also all VLAN interfaces on
>top of it. I don't like this approach too much as there is already a
>different mechanism for the problem: network device's uc list. Since
>commits
>
>  7d26bb10  bonding: emit event when bonding changes MAC
>  2af73d4b  net/bonding: emit address change event also in bond_release
>
>VLAN device's MAC address is copied into bond's uc list. Unfortunately
>there is no code taking care of syncing the bond's uc list to its
>slaves (so that the slave drops the packets for the VLAN). My idea is to
>do this either via ndo_set_rx_mode method or in response to an event.
>
>But before proposing a patch, I would like to ask: which approach is
>preferrable: copying active slave's hw address to all VLAN devices
>defined on top of the bond or syncing bond's uc list to its slaves?

	I tested some of this out earlier this year, and I don't recall
having problems (although I'm not sure I did this exact test).  The
dev_uc_add() logic (in __dev_set_rx_mode) would put the underlying
device into promiscuous mode if the hardware didn't support multiple
unicast MAC addresses. dev_uc_add() was invoked by vlan_sync_address(),
which is called by the vlan NETDEV_CHANGEADDR notifier callback.

	Bonding does propagate promisc to its slaves, but (as you point
out) not the uc lists; is the hardware in question something that
supports multiple unicast addresses (IFF_UNICAST_FLT)?  The device I
tested with does not support IFF_UNICAST_FLT, and (as I recall) would
end up in promisc mode.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
