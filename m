From: Jay Vosburgh <fubar@us.ibm.com>
Subject: PATCH: bonding might sleep with lock held
Date: Wed, 12 May 2004 19:15:33 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200405130215.i4D2FX52016740@death.nxdomain.ibm.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


	In 802.3ad mode, the bond_close() function will eventually call
dev_remove_pack() with a lock held.  In turn, dev_remove_pack() calls
synchronize_net() which eventually might sleep in wait_for_completion().
Probably not good.

	This patch replaces dev_remove_pack() with __dev_remove_pack()
and adds a synchronize_net() call outside the lock.  The patch is
against 2.6.5, but applied to 2.6.6 for me.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com


diff -urN linux-2.6.5-virgin/drivers/net/bonding/bond_main.c linux-2.6.5/drivers/net/bonding/bond_main.c
--- linux-2.6.5-virgin/drivers/net/bonding/bond_main.c	2004-05-11 17:33:50.977235256 -0700
+++ linux-2.6.5/drivers/net/bonding/bond_main.c	2004-05-11 17:35:42.538275400 -0700
@@ -3495,7 +3495,7 @@
 /* unregister to receive lacpdus on a bond */
 static void bond_unregister_lacpdu(struct bonding *bond)
 {
-	dev_remove_pack(&(BOND_AD_INFO(bond).ad_pkt_type));
+	__dev_remove_pack(&(BOND_AD_INFO(bond).ad_pkt_type));
 }
 
 /*-------------------------- Device entry points ----------------------------*/
@@ -3580,6 +3580,12 @@
 
 	write_unlock_bh(&bond->lock);
 
+	/*
+	 * Sync outside the lock after __dev_remove_pack() in
+	 * bond_unregister_lacpdu()
+	 */
+	synchronize_net();
+
 	/* del_timer_sync must run without holding the bond->lock
 	 * because a running timer might be trying to hold it too
 	 */
