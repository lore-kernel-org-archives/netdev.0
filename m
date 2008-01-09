From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH 0/3] bonding: 3 fixes for 2.6.24
Date: Wed, 09 Jan 2008 15:19:10 -0800
Message-ID: <7603.1199920750@death>
References: <11997574203125-git-send-email-fubar@us.ibm.com> <Pine.LNX.4.64.0801081949290.1135@bizon.gios.gov.pl> <29560.1199820632@death> <Pine.LNX.4.64.0801090732490.1135@bizon.gios.gov.pl> <17850.1199865514@death> <20080109152740.GE8728@gospo.usersys.redhat.com> <32361.1199901296@death> <20080109201709.GF8728@gospo.usersys.redhat.com> <20080109220534.GA2692@gondor.apana.org.au>
Cc: Andy Gospodarek <andy@greyhouse.net>,
	Krzysztof Oledzki <olel@ans.pl>, netdev@vger.kernel.org,
	Jeff Garzik <jgarzik@pobox.com>,
	David Miller <davem@davemloft.net>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:46919 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752431AbYAIXTj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Jan 2008 18:19:39 -0500
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m09NJbKt003181
	for <netdev@vger.kernel.org>; Wed, 9 Jan 2008 18:19:37 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m09NJbM9455354
	for <netdev@vger.kernel.org>; Wed, 9 Jan 2008 18:19:37 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m09NJaxU009857
	for <netdev@vger.kernel.org>; Wed, 9 Jan 2008 18:19:37 -0500
In-reply-to: <20080109220534.GA2692@gondor.apana.org.au> 
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu <herbert@gondor.apana.org.au> wrote:

>On Wed, Jan 09, 2008 at 03:17:09PM -0500, Andy Gospodarek wrote:
>>
>> Agreed.  And despite Herbert's opinion that this isn't the correct fix,
>> I think this will work fine.  This is one of the cases where we can take
>> a write_lock(bond->lock) in softirq context, so we need to drop that (or
>> make sure all the read_lock's are read_lock_bh's).  The latter isn't
>> really an option since having a majority of the bonding code run in
>> softirq context was what we are trying to avoid with the workqueue
>> conversion.
>
>No that's not the point.  The point is to move the majority of the code
>into process context so that you can take the RTNL.  Once you have taken
>the RTNL you can disable BH all you want and I don't care one bit.

	I'm not sure how we could move more code into a process context;
much of the bonding driver is at the mercy of its callers, as in this
case.  The monitoring stuff and enslave / deslave is all in a process
context now (workqueue).  The transmit processing functions, for
example, can't be assumed to be in any particular context as they're
called by dev_queue_xmit.

	The function in question here is the dev->set_multicast_list
method function, which is sometimes called with RTNL, and sometimes with
other random locks, but seems to always be called with netif_tx_lock_bh.
Then, bonding's bond_set_multicast_list calls dev_set_promiscuity (on
slaves), which I believe is an "RTNL only" function (which is probably
another discussion).

>In any case, fixing a known dead-lock is important.

	Agreed.

	I'm now thinking for just the topic at hand (the previously
posted lockdep report), something like this will resolve it:

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 77d004d..b7ac10b 100644
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
 
+	read_lock_bh(&bond->lock);
+
 	bond->flags = bond_dev->flags;
 
 	/* looking for addresses to add to slaves' mc list */
@@ -3979,7 +3979,7 @@ static void bond_set_multicast_list(struct net_device *bond_dev)
 	bond_mc_list_destroy(bond);
 	bond_mc_list_copy(bond_dev->mc_list, bond, GFP_ATOMIC);
 
-	write_unlock_bh(&bond->lock);
+	read_unlock_bh(&bond->lock);
 }
 
 /*


	This (a) converts the write_lock_bh to a read_lock_bh, and moves
it down to not cover the promisc/allmulti code (which is protected by
RTNL).  I'm not sure that this is really a signficant alteration, but
it's a bit closer to "correct."

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
