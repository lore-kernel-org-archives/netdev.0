From: akpm@osdl.org
Subject: [patch 4/7] Fix for 802.3ad shutdown issue
Date: Wed, 10 Nov 2004 16:02:28 -0800
Message-ID: <200411102358.iAANwH904212@mail.osdl.org>
Cc: jgarzik@pobox.com, netdev@oss.sgi.com, akpm@osdl.org,
        mitch.a.williams@intel.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


From: "Williams, Mitch A" <mitch.a.williams@intel.com>

The patch below fixes a problem with shutting down 802.3ad bonds on the 2.6
kernel.  Taking the interface down or removing the module causes a stack
dump if spinlock debugging is enabled.  This patch was generated from the
2.6.9 kernel.

This patch has been peer reviewed by our Linux software engineering team,
and the fix has been verified by our test labs.

Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 25-akpm/drivers/net/bonding/bond_main.c |   15 +++++++++++----
 25-akpm/drivers/net/bonding/bonding.h   |    4 ++--
 2 files changed, 13 insertions(+), 6 deletions(-)

diff -puN drivers/net/bonding/bonding.h~fix-for-8023ad-shutdown-issue drivers/net/bonding/bonding.h
--- 25/drivers/net/bonding/bonding.h~fix-for-8023ad-shutdown-issue	Wed Nov 10 16:00:36 2004
+++ 25-akpm/drivers/net/bonding/bonding.h	Wed Nov 10 16:00:36 2004
@@ -36,8 +36,8 @@
 #include "bond_3ad.h"
 #include "bond_alb.h"
 
-#define DRV_VERSION	"2.6.0"
-#define DRV_RELDATE	"January 14, 2004"
+#define DRV_VERSION	"2.6.1"
+#define DRV_RELDATE	"October 29, 2004"
 #define DRV_NAME	"bonding"
 #define DRV_DESCRIPTION	"Ethernet Channel Bonding Driver"
 
diff -puN drivers/net/bonding/bond_main.c~fix-for-8023ad-shutdown-issue drivers/net/bonding/bond_main.c
--- 25/drivers/net/bonding/bond_main.c~fix-for-8023ad-shutdown-issue	Wed Nov 10 16:00:36 2004
+++ 25-akpm/drivers/net/bonding/bond_main.c	Wed Nov 10 16:00:36 2004
@@ -469,6 +469,13 @@
  *	  * Add support for VLAN hardware acceleration capable slaves.
  *	  * Add capability to tag self generated packets in ALB/TLB modes.
  *	  Set version to 2.6.0.
+ * 2004/10/29 - Mitch Williams <mitch.a.williams at intel dot com>
+ *      - Fixed bug when unloading module while using 802.3ad.  If
+ *        spinlock debugging is turned on, this causes a stack dump.
+ *        Solution is to move call to dev_remove_pack outside of the
+ *        spinlock.
+ *        Set version to 2.6.1.
+ *
  */
 
 //#define BONDING_DEBUG 1
@@ -3566,15 +3573,15 @@ static int bond_close(struct net_device 
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
 
_
