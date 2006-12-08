From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 21/22] e1000: Version increment 7.3.20-k2 and minor cleanups
Date: Fri, 08 Dec 2006 15:03:32 -0800
Message-ID: <20061208230331.30109.23517.stgit@gitlost.site>
References: <20061208230209.30109.49157.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:4397 "EHLO gitlost.site"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1947469AbWLHWyB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Dec 2006 17:54:01 -0500
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20061208230209.30109.49157.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000.h       |    6 +----
 drivers/net/e1000/e1000_hw.c    |   52 +++++++++++++++++++--------------------
 drivers/net/e1000/e1000_hw.h    |    1 +
 drivers/net/e1000/e1000_main.c  |    9 +++----
 drivers/net/e1000/e1000_osdep.h |    9 +------
 5 files changed, 32 insertions(+), 45 deletions(-)

diff --git a/drivers/net/e1000/e1000.h b/drivers/net/e1000/e1000.h
index 8e7acb0..7c48680 100644
--- a/drivers/net/e1000/e1000.h
+++ b/drivers/net/e1000/e1000.h
@@ -61,6 +61,7 @@
 #include <linux/ip.h>
 #ifdef NETIF_F_TSO6
 #include <linux/ipv6.h>
+#include <net/ip6_checksum.h>
 #endif
 #include <linux/tcp.h>
 #include <linux/udp.h>
@@ -85,11 +86,7 @@ struct e1000_adapter;
 
 #include "e1000_hw.h"
 
-#ifdef DBG
-#define E1000_DBG(args...) printk(KERN_DEBUG "e1000: " args)
-#else
 #define E1000_DBG(args...)
-#endif
 
 #define E1000_ERR(args...) printk(KERN_ERR "e1000: " args)
 
@@ -361,5 +358,4 @@ enum e1000_state_t {
 	__E1000_RESETTING,
 	__E1000_DOWN
 };
-
 #endif /* _E1000_H_ */
diff --git a/drivers/net/e1000/e1000_hw.c b/drivers/net/e1000/e1000_hw.c
index 4ad6a11..9a295e0 100644
--- a/drivers/net/e1000/e1000_hw.c
+++ b/drivers/net/e1000/e1000_hw.c
@@ -718,8 +718,6 @@ e1000_reset_hw(struct e1000_hw *hw)
  *
  * hw: Struct containing variables accessed by shared code
  *
- * This function contains hardware limitation workarounds for PCI-E adapters
- *
  *****************************************************************************/
 static void
 e1000_initialize_hardware_bits(struct e1000_hw *hw)
@@ -731,14 +729,15 @@ e1000_initialize_hardware_bits(struct e1
         uint32_t reg_tctl;
         uint32_t reg_txdctl, reg_txdctl1;
 
-        /* link autonegotiation/sync workarounds */
         reg_tarc0 = E1000_READ_REG(hw, TARC0);
+        /* link autonegotiation/sync workarounds */
         reg_tarc0 &= ~((1 << 30)|(1 << 29)|(1 << 28)|(1 << 27));
 
-        /* Enable not-done TX descriptor counting */
         reg_txdctl = E1000_READ_REG(hw, TXDCTL);
+        /* Enable not-done TX descriptor counting */
         reg_txdctl |= E1000_TXDCTL_COUNT_DESC;
         E1000_WRITE_REG(hw, TXDCTL, reg_txdctl);
+
         reg_txdctl1 = E1000_READ_REG(hw, TXDCTL1);
         reg_txdctl1 |= E1000_TXDCTL_COUNT_DESC;
         E1000_WRITE_REG(hw, TXDCTL1, reg_txdctl1);
@@ -746,18 +745,18 @@ e1000_initialize_hardware_bits(struct e1
         switch (hw->mac_type) {
             case e1000_82571:
             case e1000_82572:
-                /* Clear PHY TX compatible mode bits */
                 reg_tarc1 = E1000_READ_REG(hw, TARC1);
+                reg_tctl = E1000_READ_REG(hw, TCTL);
+
+                /* Clear PHY TX compatible mode bits */
                 reg_tarc1 &= ~((1 << 30)|(1 << 29));
 
                 /* link autonegotiation/sync workarounds */
                 reg_tarc0 |= ((1 << 26)|(1 << 25)|(1 << 24)|(1 << 23));
-
                 /* TX ring control fixes */
                 reg_tarc1 |= ((1 << 26)|(1 << 25)|(1 << 24));
 
                 /* Multiple read bit is reversed polarity */
-                reg_tctl = E1000_READ_REG(hw, TCTL);
                 if (reg_tctl & E1000_TCTL_MULR)
                     reg_tarc1 &= ~(1 << 28);
                 else
@@ -767,18 +766,18 @@ e1000_initialize_hardware_bits(struct e1
                 break;
             case e1000_82573:
                 reg_ctrl_ext = E1000_READ_REG(hw, CTRL_EXT);
+                reg_ctrl = E1000_READ_REG(hw, CTRL);
+
                 reg_ctrl_ext &= ~(1 << 23);
                 reg_ctrl_ext |= (1 << 22);
-
                 /* TX byte count fix */
-                reg_ctrl = E1000_READ_REG(hw, CTRL);
                 reg_ctrl &= ~(1 << 29);
 
                 E1000_WRITE_REG(hw, CTRL_EXT, reg_ctrl_ext);
                 E1000_WRITE_REG(hw, CTRL, reg_ctrl);
                 break;
             case e1000_80003es2lan:
-                /* improve small packet performace for fiber/serdes */
+                /* improve small packet performance for fiber/serdes */
                 if ((hw->media_type == e1000_media_type_fiber) ||
                     (hw->media_type == e1000_media_type_internal_serdes)) {
                     reg_tarc0 &= ~(1 << 20);
@@ -800,7 +799,6 @@ e1000_initialize_hardware_bits(struct e1
                     ((hw->device_id != E1000_DEV_ID_ICH8_IGP_M_AMT) &&
                      (hw->device_id != E1000_DEV_ID_ICH8_IGP_M)))
                     reg_tarc0 |= ((1 << 29)|(1 << 28));
-
                 reg_ctrl_ext = E1000_READ_REG(hw, CTRL_EXT);
                 reg_ctrl_ext |= (1 << 22);
                 E1000_WRITE_REG(hw, CTRL_EXT, reg_ctrl_ext);
@@ -808,15 +806,16 @@ e1000_initialize_hardware_bits(struct e1
                 /* workaround TX hang with TSO=on */
                 reg_tarc0 |= ((1 << 27)|(1 << 26)|(1 << 24)|(1 << 23));
 
-                /* Multiple read bit is reversed polarity */
-                reg_tctl = E1000_READ_REG(hw, TCTL);
                 reg_tarc1 = E1000_READ_REG(hw, TARC1);
+                reg_tctl = E1000_READ_REG(hw, TCTL);
+
+                /* Multiple read bit is reversed polarity */
                 if (reg_tctl & E1000_TCTL_MULR)
                     reg_tarc1 &= ~(1 << 28);
                 else
                     reg_tarc1 |= (1 << 28);
 
-                /* workaround TX hang with TSO=on */
+                /* workaround TX hang and TSO=on */
                 reg_tarc1 |= ((1 << 30)|(1 << 26)|(1 << 24));
 
                 E1000_WRITE_REG(hw, TARC1, reg_tarc1);
@@ -4580,7 +4579,6 @@ e1000_init_eeprom_params(struct e1000_hw
         hw->flash_bank_size *= ICH_FLASH_SECTOR_SIZE;
 
         hw->flash_bank_size /= 2 * sizeof(uint16_t);
-
         break;
         }
     default:
@@ -6342,12 +6340,12 @@ e1000_clear_hw_cntrs(struct e1000_hw *hw
     temp = E1000_READ_REG(hw, FCRUC);
 
     if (hw->mac_type != e1000_ich8lan) {
-    temp = E1000_READ_REG(hw, PRC64);
-    temp = E1000_READ_REG(hw, PRC127);
-    temp = E1000_READ_REG(hw, PRC255);
-    temp = E1000_READ_REG(hw, PRC511);
-    temp = E1000_READ_REG(hw, PRC1023);
-    temp = E1000_READ_REG(hw, PRC1522);
+        temp = E1000_READ_REG(hw, PRC64);
+        temp = E1000_READ_REG(hw, PRC127);
+        temp = E1000_READ_REG(hw, PRC255);
+        temp = E1000_READ_REG(hw, PRC511);
+        temp = E1000_READ_REG(hw, PRC1023);
+        temp = E1000_READ_REG(hw, PRC1522);
     }
 
     temp = E1000_READ_REG(hw, GPRC);
@@ -6371,12 +6369,12 @@ e1000_clear_hw_cntrs(struct e1000_hw *hw
     temp = E1000_READ_REG(hw, TPT);
 
     if (hw->mac_type != e1000_ich8lan) {
-    temp = E1000_READ_REG(hw, PTC64);
-    temp = E1000_READ_REG(hw, PTC127);
-    temp = E1000_READ_REG(hw, PTC255);
-    temp = E1000_READ_REG(hw, PTC511);
-    temp = E1000_READ_REG(hw, PTC1023);
-    temp = E1000_READ_REG(hw, PTC1522);
+        temp = E1000_READ_REG(hw, PTC64);
+        temp = E1000_READ_REG(hw, PTC127);
+        temp = E1000_READ_REG(hw, PTC255);
+        temp = E1000_READ_REG(hw, PTC511);
+        temp = E1000_READ_REG(hw, PTC1023);
+        temp = E1000_READ_REG(hw, PTC1522);
     }
 
     temp = E1000_READ_REG(hw, MPTC);
diff --git a/drivers/net/e1000/e1000_hw.h b/drivers/net/e1000/e1000_hw.h
index fd15f62..520e52d 100644
--- a/drivers/net/e1000/e1000_hw.h
+++ b/drivers/net/e1000/e1000_hw.h
@@ -1042,6 +1042,7 @@ struct e1000_ffvt_entry {
 #define E1000_ICRXDMTC 0x04120  /* Interrupt Cause Rx Descriptor Minimum Threshold Count */
 #define E1000_ICRXOC   0x04124  /* Interrupt Cause Receiver Overrun Count */
 #define E1000_RXCSUM   0x05000  /* RX Checksum Control - RW */
+#define E1000_RLPML    0x05004  /* RX Long Packet Max Length */
 #define E1000_RFCTL    0x05008  /* Receive Filter Control*/
 #define E1000_MTA      0x05200  /* Multicast Table Array - RW Array */
 #define E1000_RA       0x05400  /* Receive Address - RW Array */
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 458aa38..092476a 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -27,7 +27,6 @@
 *******************************************************************************/
 
 #include "e1000.h"
-#include <net/ip6_checksum.h>
 
 char e1000_driver_name[] = "e1000";
 static char e1000_driver_string[] = "Intel(R) PRO/1000 Network Driver";
@@ -36,7 +35,7 @@ static char e1000_driver_string[] = "Int
 #else
 #define DRIVERNAPI "-NAPI"
 #endif
-#define DRV_VERSION "7.3.15-k2"DRIVERNAPI
+#define DRV_VERSION "7.3.20-k2"DRIVERNAPI
 char e1000_driver_version[] = DRV_VERSION;
 static char e1000_copyright[] = "Copyright (c) 1999-2006 Intel Corporation.";
 
@@ -1353,7 +1352,6 @@ e1000_sw_init(struct e1000_adapter *adap
 	spin_lock_init(&adapter->stats_lock);
 
 	set_bit(__E1000_DOWN, &adapter->flags);
-
 	return 0;
 }
 
@@ -1713,7 +1711,8 @@ e1000_configure_tx(struct e1000_adapter 
 		tarc = E1000_READ_REG(hw, TARC0);
 		/* set the speed mode bit, we'll clear it if we're not at
 		 * gigabit link later */
-		tarc |= (1 << 21);
+#define SPEED_MODE_BIT (1 << 21)
+		tarc |= SPEED_MODE_BIT;
 		E1000_WRITE_REG(hw, TARC0, tarc);
 	} else if (hw->mac_type == e1000_80003es2lan) {
 		tarc = E1000_READ_REG(hw, TARC0);
@@ -2631,7 +2630,7 @@ e1000_watchdog(unsigned long data)
 			    txb2b == 0) {
 				uint32_t tarc0;
 				tarc0 = E1000_READ_REG(&adapter->hw, TARC0);
-				tarc0 &= ~(1 << 21);
+				tarc0 &= ~SPEED_MODE_BIT;
 				E1000_WRITE_REG(&adapter->hw, TARC0, tarc0);
 			}
 
diff --git a/drivers/net/e1000/e1000_osdep.h b/drivers/net/e1000/e1000_osdep.h
index 18afc0c..da8c641 100644
--- a/drivers/net/e1000/e1000_osdep.h
+++ b/drivers/net/e1000/e1000_osdep.h
@@ -48,17 +48,10 @@ typedef enum {
     TRUE = 1
 } boolean_t;
 
-#define MSGOUT(S, A, B)	printk(KERN_DEBUG S "\n", A, B)
-
-#ifdef DBG
-#define DEBUGOUT(S)		printk(KERN_DEBUG S "\n")
-#define DEBUGOUT1(S, A...)	printk(KERN_DEBUG S "\n", A)
-#else
 #define DEBUGOUT(S)
 #define DEBUGOUT1(S, A...)
-#endif
 
-#define DEBUGFUNC(F) DEBUGOUT(F)
+#define DEBUGFUNC(F) DEBUGOUT(F "\n")
 #define DEBUGOUT2 DEBUGOUT1
 #define DEBUGOUT3 DEBUGOUT2
 #define DEBUGOUT7 DEBUGOUT3



---
Auke Kok <auke-jan.h.kok@intel.com>
