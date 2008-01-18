From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [patch for 2.6.24? 1/1] bonding: locking fix
Date: Thu, 17 Jan 2008 17:45:33 -0800
Message-ID: <27063.1200620733@death>
References: <200801140904.m0E94vJd020425@imap1.linux-foundation.org> <Pine.LNX.4.64.0801142313350.26034@bizon.gios.gov.pl> <20080114144754.29a448ad.akpm@linux-foundation.org> <16796.1200351673@death> <20080117154243.9ee4265c.akpm@linux-foundation.org> <24607.1200616005@death> <Pine.LNX.4.64.0801180154570.4570@bizon.gios.gov.pl>
Cc: Andrew Morton <akpm@linux-foundation.org>, davem@davemloft.net,
	jeff@garzik.org, shemminger@linux-foundation.org,
	netdev@vger.kernel.org, Andy Gospodarek <andy@greyhouse.net>
To: Krzysztof Oledzki <olel@ans.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:43364 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752843AbYARBpm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Jan 2008 20:45:42 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m0I1lRpT013819
	for <netdev@vger.kernel.org>; Thu, 17 Jan 2008 20:47:27 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m0I1ja82238100
	for <netdev@vger.kernel.org>; Thu, 17 Jan 2008 20:45:36 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m0I1jZmw006261
	for <netdev@vger.kernel.org>; Thu, 17 Jan 2008 20:45:36 -0500
In-reply-to: <Pine.LNX.4.64.0801180154570.4570@bizon.gios.gov.pl> 
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Krzysztof Oledzki <olel@ans.pl> wrote:

>> Andrew Morton <akpm@linux-foundation.org> wrote:
>> [...]
>>> Can we get this bug fixed please?  Today?  It has been known about for more
>>> than two months.
>>
>> 	I just reposted the complete fix; it's #1 of the series of 7.
>
>Bad news. :( 2.6.24-rc7 + patch #1 (bonding: fix locking in sysfs
>primary/active selection):
[...]
>=========================================================
>[ INFO: possible irq lock inversion dependency detected ]
>2.6.24-rc7 #1
>---------------------------------------------------------
>events/0/9 just changed the state of lock:
> (&mc->mca_lock){-+..}, at: [<c041255a>] mld_ifc_timer_expire+0x130/0x1fb
>but this lock took another, soft-read-irq-unsafe lock in the past:
> (&bond->lock){-.--}

	None of the seven patches I posted just a bit ago will fix this
lockdep warning (which is a different thing that the bug Andrew inquired
about); I'm still working on that one.

	For that one, I had posted this work in progress patch:

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 77d004d..6906dbc 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3937,8 +3937,6 @@ static void bond_set_multicast_list(struct net_device *bond_dev)
 	struct bonding *bond = bond_dev->priv;
 	struct dev_mc_list *dmi;
 
-	write_lock_bh(&bond->lock);
-
 	/*
 	 * Do promisc before checking multicast_mode
 	 */
@@ -3959,6 +3957,8 @@ static void bond_set_multicast_list(struct net_device *bond_dev)
 		bond_set_allmulti(bond, -1);
 	}
 
+	read_lock(&bond->lock);
+
 	bond->flags = bond_dev->flags;
 
 	/* looking for addresses to add to slaves' mc list */
@@ -3979,7 +3979,7 @@ static void bond_set_multicast_list(struct net_device *bond_dev)
 	bond_mc_list_destroy(bond);
 	bond_mc_list_copy(bond_dev->mc_list, bond, GFP_ATOMIC);
 
-	write_unlock_bh(&bond->lock);
+	read_unlock(&bond->lock);
 }
 
 /*

	which makes the warning go away, but Herbert Xu pointed out that
there is a potential problem with bond_enslave accessing the mc_lists
without sufficient locking.  It's not the only offender, either, and the
bond->mc_list references really need to be protected by the bond_lock,
and the whole thing probably ought to use dev_mc_sync/unsync instead of
what it does now.

	Since the bond_enslave, et al, business isn't a new problem, and
I've never heard of it being hit, I'm thinking now to just leave the
bond_enslave part for 2.6.25, and fix the lockdep warning for 2.6.24.

	But I wanted to make sure dropping the write lock to a read lock
wasn't going to make something worse.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
