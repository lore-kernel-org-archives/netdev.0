From: Kenzo Iwami <k-iwami@cj.jp.nec.com>
Subject: Re: watchdog timeout panic in e1000 driver
Date: Tue, 19 Dec 2006 09:13:32 +0900
Message-ID: <45872EAC.7050501@cj.jp.nec.com>
References: <36D9DB17C6DE9E40B059440DB8D95F52013ABFE9@orsmsx418.amr.corp.intel.com> <4562D207.60301@cj.jp.nec.com> <4573E6FD.3030905@cj.jp.nec.com> <4574C14E.2060108@intel.com> <457E610D.4060908@cj.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: Auke Kok <auke-jan.h.kok@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Shaw Vrana <shaw@vranix.com>, netdev@vger.kernel.org,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from TYO200.gate.nec.co.jp ([210.143.35.50]:35758 "EHLO
	tyo200.gate.nec.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932645AbWLSCIc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Dec 2006 21:08:32 -0500
Received: from tyo201.gate.nec.co.jp ([10.7.69.201])
	by tyo200.gate.nec.co.jp (8.13.8/8.13.4) with ESMTP id kBJ0n74u003880
	for <netdev@vger.kernel.org>; Tue, 19 Dec 2006 09:54:44 +0900 (JST)
To: Kenzo Iwami <k-iwami@cj.jp.nec.com>
In-Reply-To: <457E610D.4060908@cj.jp.nec.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Previously, I posted a patch that fixed this problem without using spinlocks
nor disabling interrupts.
I have rebased this patch for 2.6.20-rc1.

Does this patch have problems?

I welcome any comments.

--
  Kenzo Iwami (k-iwami@cj.jp.nec.com)

Signed-off-by: Kenzo Iwami <k-iwami@cj.jp.nec.com>

diff -urpN linux-2.6.20-rc1-org/drivers/net/e1000/e1000_hw.c
linux-2.6.20-rc1-fix/drivers/net/e1000/e1000_hw.c
--- linux-2.6.20-rc1-org/drivers/net/e1000/e1000_hw.c	2006-12-14
10:14:23.000000000 +0900
+++ linux-2.6.20-rc1-fix/drivers/net/e1000/e1000_hw.c	2006-12-18
13:10:21.000000000 +0900
@@ -3394,8 +3394,19 @@ e1000_swfw_sync_acquire(struct e1000_hw
         return e1000_get_hw_eeprom_semaphore(hw);

     while (timeout) {
-            if (e1000_get_hw_eeprom_semaphore(hw))
+            atomic_inc(&hw->swfw_sem_count);
+            if (e1000_get_hw_eeprom_semaphore(hw)) {
+                if (atomic_xchg(&hw->watchdog_deferred, 0)) {
+retry1:
+                    e1000_do_watchdog(hw);
+                }
+                atomic_dec(&hw->swfw_sem_count);
+                if (atomic_read(&hw->watchdog_deferred)) {
+                    atomic_inc(&hw->swfw_sem_count);
+                    goto retry1;
+                }
                 return -E1000_ERR_SWFW_SYNC;
+            }

             swfw_sync = E1000_READ_REG(hw, SW_FW_SYNC);
             if (!(swfw_sync & (fwmask | swmask))) {
@@ -3405,6 +3416,15 @@ e1000_swfw_sync_acquire(struct e1000_hw
             /* firmware currently using resource (fwmask) */
             /* or other software thread currently using resource (swmask) */
             e1000_put_hw_eeprom_semaphore(hw);
+            if (atomic_xchg(&hw->watchdog_deferred, 0)) {
+retry2:
+                e1000_do_watchdog(hw);
+            }
+            atomic_dec(&hw->swfw_sem_count);
+            if (atomic_read(&hw->watchdog_deferred)) {
+                atomic_inc(&hw->swfw_sem_count);
+                goto retry2;
+            }
             mdelay(5);
             timeout--;
     }
@@ -3418,6 +3438,15 @@ e1000_swfw_sync_acquire(struct e1000_hw
     E1000_WRITE_REG(hw, SW_FW_SYNC, swfw_sync);

     e1000_put_hw_eeprom_semaphore(hw);
+    if (atomic_xchg(&hw->watchdog_deferred, 0)) {
+retry3:
+        e1000_do_watchdog(hw);
+    }
+    atomic_dec(&hw->swfw_sem_count);
+    if (atomic_read(&hw->watchdog_deferred)) {
+        atomic_inc(&hw->swfw_sem_count);
+        goto retry3;
+    }
     return E1000_SUCCESS;
 }

@@ -3439,6 +3468,7 @@ e1000_swfw_sync_release(struct e1000_hw
         return;
     }

+    atomic_inc(&hw->swfw_sem_count);
     /* if (e1000_get_hw_eeprom_semaphore(hw))
      *    return -E1000_ERR_SWFW_SYNC; */
     while (e1000_get_hw_eeprom_semaphore(hw) != E1000_SUCCESS);
@@ -3449,6 +3479,15 @@ e1000_swfw_sync_release(struct e1000_hw
     E1000_WRITE_REG(hw, SW_FW_SYNC, swfw_sync);

     e1000_put_hw_eeprom_semaphore(hw);
+    if (atomic_xchg(&hw->watchdog_deferred, 0)) {
+retry:
+        e1000_do_watchdog(hw);
+    }
+    atomic_dec(&hw->swfw_sem_count);
+    if (atomic_read(&hw->watchdog_deferred)) {
+        atomic_inc(&hw->swfw_sem_count);
+        goto retry;
+    }
 }

 /*****************************************************************************
diff -urpN linux-2.6.20-rc1-org/drivers/net/e1000/e1000_hw.h
linux-2.6.20-rc1-fix/drivers/net/e1000/e1000_hw.h
--- linux-2.6.20-rc1-org/drivers/net/e1000/e1000_hw.h	2006-12-14
10:14:23.000000000 +0900
+++ linux-2.6.20-rc1-fix/drivers/net/e1000/e1000_hw.h	2006-12-18
13:09:15.000000000 +0900
@@ -306,6 +306,7 @@ typedef enum {
 #define E1000_BYTE_SWAP_WORD(_value) ((((_value) & 0x00ff) << 8) | \
                                      (((_value) & 0xff00) >> 8))

+extern void e1000_do_watchdog(struct e1000_hw *hw);
 /* Function prototypes */
 /* Initialization */
 int32_t e1000_reset_hw(struct e1000_hw *hw);
@@ -1460,6 +1461,8 @@ struct e1000_hw {
     boolean_t mng_reg_access_disabled;
     boolean_t leave_av_bit_off;
     boolean_t kmrn_lock_loss_workaround_disabled;
+    atomic_t swfw_sem_count;
+    atomic_t watchdog_deferred;
 };


diff -urpN linux-2.6.20-rc1-org/drivers/net/e1000/e1000_main.c
linux-2.6.20-rc1-fix/drivers/net/e1000/e1000_main.c
--- linux-2.6.20-rc1-org/drivers/net/e1000/e1000_main.c	2006-12-14
10:14:23.000000000 +0900
+++ linux-2.6.20-rc1-fix/drivers/net/e1000/e1000_main.c	2006-12-18
10:03:05.000000000 +0900
@@ -152,6 +152,7 @@ static void e1000_clean_rx_ring(struct e
 static void e1000_set_multi(struct net_device *netdev);
 static void e1000_update_phy_info(unsigned long data);
 static void e1000_watchdog(unsigned long data);
+void e1000_do_watchdog(struct e1000_hw *hw);
 static void e1000_82547_tx_fifo_stall(unsigned long data);
 static int e1000_xmit_frame(struct sk_buff *skb, struct net_device *netdev);
 static struct net_device_stats * e1000_get_stats(struct net_device *netdev);
@@ -1184,6 +1185,9 @@ e1000_sw_init(struct e1000_adapter *adap
 	hw->tbi_compatibility_en = TRUE;
 	hw->adaptive_ifs = TRUE;

+	atomic_set(&hw->swfw_sem_count, 0);
+	atomic_set(&hw->watchdog_deferred, 0);
+
 	/* Copper options */

 	if (hw->media_type == e1000_media_type_copper) {
@@ -2426,6 +2430,25 @@ static void
 e1000_watchdog(unsigned long data)
 {
 	struct e1000_adapter *adapter = (struct e1000_adapter *) data;
+	struct e1000_hw *hw = &adapter->hw;
+
+	if (hw->swfw_sync_present) {
+		if (atomic_read(&hw->swfw_sem_count))
+			atomic_set(&hw->watchdog_deferred, 1);
+		else
+			e1000_do_watchdog(hw);
+	} else {
+		e1000_do_watchdog(hw);
+	}
+
+	/* Reset the timer */
+	mod_timer(&adapter->watchdog_timer, jiffies + 2 * HZ);
+}
+
+void
+e1000_do_watchdog(struct e1000_hw *hw)
+{
+	struct e1000_adapter *adapter = hw->back;
 	struct net_device *netdev = adapter->netdev;
 	struct e1000_tx_ring *txdr = adapter->tx_ring;
 	uint32_t link, tctl;
@@ -2586,9 +2609,6 @@ e1000_watchdog(unsigned long data)
 	 * reset from the other port. Set the appropriate LAA in RAR[0] */
 	if (adapter->hw.mac_type == e1000_82571 && adapter->hw.laa_is_present)
 		e1000_rar_set(&adapter->hw, adapter->hw.mac_addr, 0);
-
-	/* Reset the timer */
-	mod_timer(&adapter->watchdog_timer, jiffies + 2 * HZ);
 }

 enum latency_range {

