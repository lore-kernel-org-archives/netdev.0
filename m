From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH 0/3] bonding: 3 fixes for 2.6.24
Date: Tue, 08 Jan 2008 12:28:04 -0800
Message-ID: <25243.1199824084@death>
References: <11997574203125-git-send-email-fubar@us.ibm.com> <Pine.LNX.4.64.0801081949290.1135@bizon.gios.gov.pl> <20080108191706.GD8728@gospo.usersys.redhat.com>
Cc: Krzysztof Oledzki <olel@ans.pl>, netdev@vger.kernel.org,
	Jeff Garzik <jgarzik@pobox.com>,
	David Miller <davem@davemloft.net>
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:48012 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750818AbYAHU2U (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Jan 2008 15:28:20 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m08KS7qg028085
	for <netdev@vger.kernel.org>; Tue, 8 Jan 2008 15:28:07 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m08KS7t2137902
	for <netdev@vger.kernel.org>; Tue, 8 Jan 2008 15:28:07 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m08KS6Vq024093
	for <netdev@vger.kernel.org>; Tue, 8 Jan 2008 15:28:07 -0500
In-reply-to: <20080108191706.GD8728@gospo.usersys.redhat.com> 
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andy Gospodarek <andy@greyhouse.net> wrote:
[...]
>Jay's patches will not fix this issue.  I think something like this did
>it for me, but as I mentioned to Jay in the last thread, I'm not
>convinced it doesn't violate some of the locking expectations we have.
>
>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>index 423298c..3c6619a 100644
>--- a/drivers/net/bonding/bond_main.c
>+++ b/drivers/net/bonding/bond_main.c
>@@ -3915,7 +3915,7 @@ static void bond_set_multicast_list(struct net_device *bond_dev)
> 	struct bonding *bond = bond_dev->priv;
> 	struct dev_mc_list *dmi;
>
>-	write_lock_bh(&bond->lock);
>+	read_lock(&bond->lock);
>
> 	/*
> 	 * Do promisc before checking multicast_mode
>@@ -3957,7 +3957,7 @@ static void bond_set_multicast_list(struct net_device *bond_dev)
> 	bond_mc_list_destroy(bond);
> 	bond_mc_list_copy(bond_dev->mc_list, bond, GFP_ATOMIC);
>
>-	write_unlock_bh(&bond->lock);
>+	read_unlock(&bond->lock);
> }
>
> /*

	Actually, I think we might be good here with no locks at all, as
it appears that all of the accesses to and manipulations of the
bond->mc_list are protected under RTNL.  I haven't checked this 100%,
but it looks that way to me after 20 minutes of poking around.  I'm
pretty sure that bonding doesn't internally mess with the mc_lists
without RTNL, it's the outside callers that I'm not entirely sure of.

	I delve into "no locks" because bond_set_multicast_list should
do a bunch of things with no extra locks beyond RTNL (all of the calls
to bond_set_promisc, and _allmulti), so simply removing the acquisition
of bond->lock would help there, too.  I don't think we'll go down the
promisc or allmulti paths when called from ipv6 (which holds extra locks
in addition to RTNL) because those (apparently) won't alter the
IFF_PROMISC or IFF_ALLMULTI flags.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
