From: Kenzo Iwami <k-iwami@cj.jp.nec.com>
Subject: Re: watchdog timeout panic in e1000 driver
Date: Tue, 12 Dec 2006 16:58:05 +0900
Message-ID: <457E610D.4060908@cj.jp.nec.com>
References: <36D9DB17C6DE9E40B059440DB8D95F52013ABFE9@orsmsx418.amr.corp.intel.com> <4562D207.60301@cj.jp.nec.com> <4573E6FD.3030905@cj.jp.nec.com> <4574C14E.2060108@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Shaw Vrana <shaw@vranix.com>, netdev@vger.kernel.org,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from TYO201.gate.nec.co.jp ([202.32.8.193]:56707 "EHLO
	tyo201.gate.nec.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750956AbWLLH6b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Dec 2006 02:58:31 -0500
To: Auke Kok <auke-jan.h.kok@intel.com>
In-Reply-To: <4574C14E.2060108@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

> There are several issues that are conflicting and mixing that make it less than 
> intuitive to decide what the better fix is.
> 
> Most of all, we discussed that adding a spinlock is not going to fix the underlying 
> problem of contention, as the code that would need to be spinlocked can sleep. Not a 
> good thing.
> 
> Adding state tracking code in the form of atomics might solve the issue too, but then we 
> need to do this in quite a few locations. And it comes down to the fact that we really 
> want all users of the semaphore to halt in case it is in use.
> 
> Reducing the swfw semaphore time is a usefull exercise, but requires an amazing amount 
> of changes to all of the phy code to make sure we're not locking it too long, and even 
> then I doubt that we will reduce the maximum lock time to acceptable levels.
> 
> The watchdog then, appears to needlessly lock the semaphore every two seconds. this is 
> because even though the link is up and we're already setup, we go through the trouble of 
> doing all the PHY reads, which are protected by the semaphores.
> 
> I'm currently testing a watchdog version which completely bypasses these checks in case 
> the MAC didn't detect a link change, and we already are setup completely. In that case, 
> all we need to do is update stats and reschedule the timer.

I managed to devise a patch that will fix this problem without using
spinlocks nor disabling interrupts.

Basically, if any process is acquiring the semaphore, watchdog processing
will be deferred until when that process releases the semaphore.

Two new members are added to e1000_hw structure.

hw->swfw_sem_count represents the number of processes that is trying to hold
the semaphore.
hw->swfw_sem_count is incremented before acquiring the semaphore, and
decremented after releasing the semaphore. It will be zero if no processes
is trying to acquire the semaphore.
hw->watchdog_deferred is used to check whether there is any watchdogs
pending. It will be one if watchdog processing is deferred, and zero if
no watchdogs are pending.

Before hw->swfw_sem_count is decremented, hw->watchdog_deferred is checked
and exchanged to zero. If the old value is not zero, watchdog function
is called before decrementing hw->swfw_sem_count.

The interrupt handler will not try to acquire the semaphore, while the
interrupted code is holding the semaphore, and the deadlock is avoided.

I ran the reproduction TP I sent previously and confirmed that the system
doesn't panic.

How about this patch? Does this patch have problems?

I welcome any comments.
-- 
  Kenzo Iwami (k-iwami@cj.jp.nec.com)

Signed-off-by: Kenzo Iwami <k-iwami@cj.jp.nec.com>

diff -urpN linux-2.6.19.org/drivers/net/e1000/e1000_hw.c
linux-2.6.19_new/drivers/net/e1000/e1000_hw.c
--- linux-2.6.19.org/drivers/net/e1000/e1000_hw.c	2006-11-30 06:57:37.000000000
+0900
+++ linux-2.6.19_new/drivers/net/e1000/e1000_hw.c	2006-12-12 13:30:13.000000000
+0900
@@ -3389,8 +3389,19 @@ e1000_swfw_sync_acquire(struct e1000_hw
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
@@ -3400,6 +3411,15 @@ e1000_swfw_sync_acquire(struct e1000_hw
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
@@ -3413,6 +3433,15 @@ e1000_swfw_sync_acquire(struct e1000_hw
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

@@ -3434,6 +3463,7 @@ e1000_swfw_sync_release(struct e1000_hw
         return;
     }

+    atomic_inc(&hw->swfw_sem_count);
     /* if (e1000_get_hw_eeprom_semaphore(hw))
      *    return -E1000_ERR_SWFW_SYNC; */
     while (e1000_get_hw_eeprom_semaphore(hw) != E1000_SUCCESS);
@@ -3444,6 +3474,15 @@ e1000_swfw_sync_release(struct e1000_hw
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
diff -urpN linux-2.6.19.org/drivers/net/e1000/e1000_hw.h
linux-2.6.19_new/drivers/net/e1000/e1000_hw.h
--- linux-2.6.19.org/drivers/net/e1000/e1000_hw.h	2006-11-30 06:57:37.000000000
+0900
+++ linux-2.6.19_new/drivers/net/e1000/e1000_hw.h	2006-12-12 13:30:14.000000000
+0900
@@ -304,6 +304,7 @@ typedef enum {
 #define E1000_BYTE_SWAP_WORD(_value) ((((_value) & 0x00ff) << 8) | \
                                      (((_value) & 0xff00) >> 8))

+extern void e1000_do_watchdog(struct e1000_hw *hw);
 /* Function prototypes */
 /* Initialization */
 int32_t e1000_reset_hw(struct e1000_hw *hw);
@@ -1454,6 +1455,8 @@ struct e1000_hw {
     boolean_t mng_reg_access_disabled;
     boolean_t leave_av_bit_off;
     boolean_t kmrn_lock_loss_workaround_disabled;
+    atomic_t swfw_sem_count;
+    atomic_t watchdog_deferred;
 };


diff -urpN linux-2.6.19.org/drivers/net/e1000/e1000_main.c
linux-2.6.19_new/drivers/net/e1000/e1000_main.c
--- linux-2.6.19.org/drivers/net/e1000/e1000_main.c	2006-11-30
06:57:37.000000000 +0900
+++ linux-2.6.19_new/drivers/net/e1000/e1000_main.c	2006-12-12
15:00:16.000000000 +0900
@@ -148,6 +148,7 @@ static void e1000_clean_rx_ring(struct e
 static void e1000_set_multi(struct net_device *netdev);
 static void e1000_update_phy_info(unsigned long data);
 static void e1000_watchdog(unsigned long data);
+void e1000_do_watchdog(struct e1000_hw *hw);
 static void e1000_82547_tx_fifo_stall(unsigned long data);
 static int e1000_xmit_frame(struct sk_buff *skb, struct net_device *netdev);
 static struct net_device_stats * e1000_get_stats(struct net_device *netdev);
@@ -1178,6 +1179,8 @@ e1000_sw_init(struct e1000_adapter *adap
 	hw->tbi_compatibility_en = TRUE;
 	hw->adaptive_ifs = TRUE;

+	atomic_set(&hw->swfw_sem_count, 0);
+	atomic_set(&hw->watchdog_deferred, 0);
 	/* Copper options */

 	if (hw->media_type == e1000_media_type_copper) {
@@ -2401,10 +2404,27 @@ e1000_82547_tx_fifo_stall(unsigned long
  * e1000_watchdog - Timer Call-back
  * @data: pointer to adapter cast into an unsigned long
  **/
-static void
-e1000_watchdog(unsigned long data)
+static void e1000_watchdog(unsigned long data)
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
@@ -2572,9 +2592,6 @@ e1000_watchdog(unsigned long data)
 	 * reset from the other port. Set the appropriate LAA in RAR[0] */
 	if (adapter->hw.mac_type == e1000_82571 && adapter->hw.laa_is_present)
 		e1000_rar_set(&adapter->hw, adapter->hw.mac_addr, 0);
-
-	/* Reset the timer */
-	mod_timer(&adapter->watchdog_timer, jiffies + 2 * HZ);
 }

 #define E1000_TX_FLAGS_CSUM		0x00000001

