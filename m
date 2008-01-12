From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH 0/3] bonding: 3 fixes for 2.6.24
Date: Sat, 12 Jan 2008 09:56:38 -0800
Message-ID: <18609.1200160598@death>
References: <11997574203125-git-send-email-fubar@us.ibm.com> <Pine.LNX.4.64.0801081949290.1135@bizon.gios.gov.pl> <29560.1199820632@death> <Pine.LNX.4.64.0801090732490.1135@bizon.gios.gov.pl> <17850.1199865514@death> <20080109152740.GE8728@gospo.usersys.redhat.com> <32361.1199901296@death> <20080109201709.GF8728@gospo.usersys.redhat.com> <Pine.LNX.4.64.0801121150001.16465@bizon.gios.gov.pl>
Cc: Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org,
	Jeff Garzik <jgarzik@pobox.com>,
	David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Krzysztof Oledzki <olel@ans.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:44463 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754493AbYALR4n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Jan 2008 12:56:43 -0500
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m0CHufRA004177
	for <netdev@vger.kernel.org>; Sat, 12 Jan 2008 12:56:41 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m0CHufLN057206
	for <netdev@vger.kernel.org>; Sat, 12 Jan 2008 12:56:41 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m0CHufTX002625
	for <netdev@vger.kernel.org>; Sat, 12 Jan 2008 12:56:41 -0500
In-reply-to: <Pine.LNX.4.64.0801121150001.16465@bizon.gios.gov.pl> 
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Krzysztof Oledzki <olel@ans.pl> wrote:
[...]
>Exactly. All I need to do is to reboot my server, I have 100% probability
>to get the warning.

	I wish it were that easy for me; I'm not sure what magic thing
you've got on your server or network that I don't, but I haven't been
able to make this lockdep warning happen at all.

>Right. So, what is the final patch? I would like to test it if that's
>possible. ;)

	Can you test the following and let me know if it triggers the
warning?  I believe this is the minimum locking needed, and based on
input from Herbert, we shouldn't need to hold the lock at _bh.  If this
one works, and nobody sees any other issues with it, then it's the final
patch for this lockdep problem.  I'll add some deep, meaningful comments
to explain the locking a bit (i.e., we're called with rtnl for the
allmulti and promisc cases, so we're ok there without additional locks,
but the later code could be called from anywhere, so it needs locks to
prevent the slave list from changing, but the mc_lists themselves are
covered by the netif_tx_lock that all callers will hold), but this would
be the actual code change.

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


	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
