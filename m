From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH 2.6.8.1] bonding: bonding might sleep with lock held
Date: Tue, 17 Aug 2004 15:08:34 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200408172208.i7HM8Yo7009451@death.nxdomain.ibm.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


	I posted a patch for this a while back, Andi Kleen suggested an
alternate patch, which never made it into the mainline; here it is.

	To summarize the problem: In 802.3ad mode, the bond_close()
function will eventually call dev_remove_pack() with a lock held.  In
turn, dev_remove_pack() calls synchronize_net() which eventually might
sleep in wait_for_completion().

	Patch generated against 2.6.7, but applied ok to 2.6.8.1.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

diff -urN linux-2.6.7-virgin/drivers/net/bonding/bond_main.c linux-2.6.7/drivers/net/bonding/bond_main.c
--- linux-2.6.7-virgin/drivers/net/bonding/bond_main.c	2004-08-17 14:56:04.411984128 -0700
+++ linux-2.6.7/drivers/net/bonding/bond_main.c	2004-08-17 14:57:08.441968256 -0700
@@ -3566,15 +3566,15 @@
 {
 	struct bonding *bond = bond_dev->priv;
 
-	write_lock_bh(&bond->lock);
-
-	bond_mc_list_destroy(bond);
-
 	if (bond->params.mode == BOND_MODE_8023AD) {
 		/* Unregister the receive of LACPDUs */
 		bond_unregister_lacpdu(bond);
 	}
 
+	write_lock_bh(&bond->lock);
+
+	bond_mc_list_destroy(bond);
+
 	/* signal timers not to re-arm */
 	bond->kill_timers = 1;
 
