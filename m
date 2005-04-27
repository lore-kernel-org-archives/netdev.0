From: Jeff Garzik <jgarzik@pobox.com>
Subject: [BK PATCHES] 2.4.x net driver updates
Date: Wed, 27 Apr 2005 17:17:50 -0400
Message-ID: <20050427211750.GA27516@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S262026AbVD0VST@vger.kernel.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Ditto for net drivers... this is my last 'bk pull' request for you,
before we both (presumably) switch to git.

Please do a

	bk pull bk://gkernel.bkbits.net/net-drivers-2.4

This will update the following files:

 drivers/net/bonding/bond_main.c |   15 +++++++++++----
 drivers/net/pcnet32.c           |    3 ++-
 2 files changed, 13 insertions(+), 5 deletions(-)

through these ChangeSets:

<willy@w.ods.org> (05/03/30 1.1448.129.2)
   [PATCH] bonding fix
   
   It fixes a stack dump when unloading the bonding module in 802.3ad mode
   if spinlock debugging is turned on, and it was already merged in 2.6.
   
   Signed-off-by: Jeff Garzik <jgarzik@pobox.com>

<brazilnut@us.ibm.com> (05/03/30 1.1448.129.1)
   [PATCH] pcnet32: 79C975 fiber fix
   
   From: "HARDY, Steven" <steven.hardy@astrium.eads.net>
   
   I have found a bug in the pcnet32 driver (drivers/net/pcnet32.c)
   affecting all ethernet cards based on the AMD79C975 chip, using the
   fiber interface.
   
   It's a one line fix, where some config registers get corrupted during
   initialisation (which stops the Fiber interface working with this chip)
   
   This bug was introduced somewhere betweeen 2.4.17 and 2.6.x (noticed
   whilst upgrading to 2.6), and it may affect other chips too.  I have
   checked all versions up to 2.6.11-bk6 and they are all broken.
   
   Signed-off-by: Andrew Morton <akpm@osdl.org>
   Signed-off-by: Don Fry <brazilnut@us.ibm.com>
   Signed-off-by: Jeff Garzik <jgarzik@pobox.com>

diff -Nru a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
--- a/drivers/net/bonding/bond_main.c	2005-04-27 17:16:28 -04:00
+++ b/drivers/net/bonding/bond_main.c	2005-04-27 17:16:28 -04:00
@@ -469,6 +469,13 @@
  *	  * Add support for VLAN hardware acceleration capable slaves.
  *	  * Add capability to tag self generated packets in ALB/TLB modes.
  *	  Set version to 2.6.0.
+ * 2004/10/29 - Mitch Williams <mitch.a.williams at intel dot com>
+ *	- Fixed bug when unloading module while using 802.3ad.  If
+ *	  spinlock debugging is turned on, this causes a stack dump.
+ *	  Solution is to move call to dev_remove_pack outside of the
+ *	  spinlock.
+ *	  Set version to 2.6.1.
+ *
  */
 
 //#define BONDING_DEBUG 1
@@ -3565,14 +3572,14 @@
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
+
+	write_lock_bh(&bond->lock);
+
+	bond_mc_list_destroy(bond);
 
 	/* signal timers not to re-arm */
 	bond->kill_timers = 1;
diff -Nru a/drivers/net/pcnet32.c b/drivers/net/pcnet32.c
--- a/drivers/net/pcnet32.c	2005-04-27 17:16:28 -04:00
+++ b/drivers/net/pcnet32.c	2005-04-27 17:16:28 -04:00
@@ -1348,7 +1348,8 @@
 	printk(KERN_INFO "%s: registered as %s\n", dev->name, lp->name);
     cards_found++;
 
-    a->write_bcr(ioaddr, 2, 0x1002);	/* enable LED writes */
+    /* enable LED writes */
+    a->write_bcr(ioaddr, 2, a->read_bcr(ioaddr, 2) | 0x1000);
 
     return 0;
 
