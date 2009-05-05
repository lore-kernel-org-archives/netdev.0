From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: 2.6.27.18: bonding: scheduling while atomic
Date: Tue, 05 May 2009 12:56:21 -0700
Message-ID: <19313.1241553381@death.nxdomain.ibm.com>
References: <1241550877.30571.17.camel@psmith-ubeta.netezza.com>
Cc: Netdev <netdev@vger.kernel.org>
To: paul@mad-scientist.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:45272 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752923AbZEET4Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 May 2009 15:56:16 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id n45JqFQQ007253
	for <netdev@vger.kernel.org>; Tue, 5 May 2009 15:52:15 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n45JuGIN145268
	for <netdev@vger.kernel.org>; Tue, 5 May 2009 15:56:16 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n45JsMs0031734
	for <netdev@vger.kernel.org>; Tue, 5 May 2009 15:54:23 -0400
In-reply-to: <1241550877.30571.17.camel@psmith-ubeta.netezza.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Paul Smith <paul@mad-scientist.net> wrote:

>Hi all;  I got a "scheduling while atomic" error while I was enslaving
>my second interface to my bond (balance-alb / mode 6).  I already have
>the previous fix for a locking error installed here.
[...]
><4> [<ffffffff8046f32c>] packet_notifier+0x8c/0x1f0
><4> [<ffffffffa00ad0a8>] bond_alb_init_slave+0x228/0x250 [bonding]
><4> [<ffffffffa00a766a>] bond_enslave+0x7ca/0x9d0 [bonding]
><4> [<ffffffff804a1981>] _spin_unlock_irq+0x11/0x40
><4> [<ffffffff8041896a>] __dev_get_by_name+0x9a/0xc0
><4> [<ffffffffa00a8af5>] bond_do_ioctl+0x3f5/0x530 [bonding]
><4> [<ffffffff802580f7>] notifier_call_chain+0x37/0x70

	I believe this is happening when the new slave's MAC address is
already in use by the bond somewhere.  You can get that if you set up
and tear down the bond after it's moved things around and you haven't
reset the slaves to their default (hardware) MAC address (by, e.g.,
reloading the drivers).  The alb mode doesn't do that, because that MAC
might still be in use by the bond; if memory serves, you'll see a
message at slave removal about that.

	Anyway, I'm pretty sure the following will make it go away.  I
believe this is safe, as RTNL is held throughout, but I haven't checked
exhaustively.

	This is against 2.6.27.18, and is just for testing.

	-J


diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index 4489e58..d199446 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -1520,15 +1520,8 @@ int bond_alb_init_slave(struct bonding *bond, struct slave *slave)
 		return res;
 	}
 
-	/* caller must hold the bond lock for write since the mac addresses
-	 * are compared and may be swapped.
-	 */
-	read_lock(&bond->lock);
-
 	res = alb_handle_addr_collision_on_attach(bond, slave);
 
-	read_unlock(&bond->lock);
-
 	if (res) {
 		return res;
 	}


---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
