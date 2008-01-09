From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH 0/3] bonding: 3 fixes for 2.6.24
Date: Wed, 09 Jan 2008 09:54:56 -0800
Message-ID: <32361.1199901296@death>
References: <11997574203125-git-send-email-fubar@us.ibm.com> <Pine.LNX.4.64.0801081949290.1135@bizon.gios.gov.pl> <29560.1199820632@death> <Pine.LNX.4.64.0801090732490.1135@bizon.gios.gov.pl> <17850.1199865514@death> <20080109152740.GE8728@gospo.usersys.redhat.com>
Cc: Krzysztof Oledzki <olel@ans.pl>, netdev@vger.kernel.org,
	Jeff Garzik <jgarzik@pobox.com>,
	David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:52392 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754245AbYAIRzU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jan 2008 12:55:20 -0500
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e33.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m09Ht5tV011524
	for <netdev@vger.kernel.org>; Wed, 9 Jan 2008 12:55:05 -0500
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m09HsxnN131860
	for <netdev@vger.kernel.org>; Wed, 9 Jan 2008 10:55:04 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m09HsU6P004578
	for <netdev@vger.kernel.org>; Wed, 9 Jan 2008 10:54:31 -0700
In-reply-to: <20080109152740.GE8728@gospo.usersys.redhat.com> 
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andy Gospodarek <andy@greyhouse.net> wrote:
[...]
>My initial concern was that a slave device could disappear out from
>under us, but it seems like this certainly isn't the case since all
>calls to bond_release are protected by rtnl-locks, so I think you are
>correct that we are safe.  I'll test this on my setup here and let you
>know if I see any problems.

	Yep, all entries into enslave or remove come in with RTNL, so if
we have RTNL there then slaves can't vanish.

	On further inspection, I don't think it's safe to simply drop
the locks in bond_set_multicast_list, I'm seeing a couple of cases that
could be troublesome:

	bond_set_promiscuity and bond_set_allmulti both reference
curr_active_slave, which isn't protected from change by RTNL, so that
could conflict with a change_active_slave calling bond_mc_swap (which is
also holding the wrong locks for dev_set_promisc/allmulti).

	It also looks like there are paths (igmp6 for one) into
dev_mc_add that just hold a bunch of regular locks, and not RTNL, so
those wouldn't be safe from having slaves vanish due to concurrent
deslavement.

	Looks like read_lock_bh for bond-lock and curr_slave_lock is
needed in bond_set_multicast_list, and some dropping of locks is needed
inside bond_set_promisc/allmulti.  Methinks that without any locks,
bond_mc_add/delete could race with either a change of active slave or a
de-enslavement of the active slave.

	I'm wondering if this is worth trying to make perfect for 2.6.24
(and maybe making things worse), and, instead, just do this:

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 77d004d..8b9e33a 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3937,7 +3937,7 @@ static void bond_set_multicast_list(struct net_device *bond_dev)
 	struct bonding *bond = bond_dev->priv;
 	struct dev_mc_list *dmi;
 
-	write_lock_bh(&bond->lock);
+	read_lock_bh(&bond->lock);
 
 	/*
 	 * Do promisc before checking multicast_mode
@@ -3979,7 +3979,7 @@ static void bond_set_multicast_list(struct net_device *bond_dev)
 	bond_mc_list_destroy(bond);
 	bond_mc_list_copy(bond_dev->mc_list, bond, GFP_ATOMIC);
 
-	write_unlock_bh(&bond->lock);
+	read_unlock_bh(&bond->lock);
 }
 
 /*


	This should silence the lockdep (if I'm understanding what
everybody's saying), and keep the change set to a minimum.  This might
not even be worth pushing for 2.6.24; I'm not exactly sure how difficult
the lockdep problem would be to trigger.

	The other stuff I mention above can be dealt with later; they're
very low-probability races that would be pretty difficult to hit even on
purpose.

	Thoughts?

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
