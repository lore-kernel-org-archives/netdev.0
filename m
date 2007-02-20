From: Kenzo Iwami <k-iwami@cj.jp.nec.com>
Subject: Re: watchdog timeout panic in e1000 driver
Date: Tue, 20 Feb 2007 18:26:39 +0900
Message-ID: <45DABECF.5020202@cj.jp.nec.com>
References: <45375135.5050206@cj.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Ronciak, John" <john.ronciak@intel.com>
To: Auke Kok <auke-jan.h.kok@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from TYO202.gate.nec.co.jp ([202.32.8.206]:60312 "EHLO
	tyo202.gate.nec.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932708AbXBTJ0y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Feb 2007 04:26:54 -0500
In-Reply-To: <45375135.5050206@cj.jp.nec.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I created a patch that uses watchdog_task but fixes the race condition
that occurred in old the e1000 driver.

I've obtained information about the panic caused by the old e1000 driver
using e1000_watchdog_task. According to the crash dump, the panic was
caused by a timer_list whose contents were NULLs. Further trace
information revealed that the function in the timer list was
e1000_watchdog().

This function is registered in timer_list during e1000_watchdog_task.
It seems that e1000_watchdog_task could be called after the adapter is
removed, and freed memory is registered to timer_list.

By looking at the source code, e1000_watchdog_task will be scheduled if
e1000_watchdog is invoked during e1000_remove, after flush_scheduled_work()
is called, but before del_timer_sync() is called in e1000_down().

The attached patch adds back the e1000_watchdog_task(), but it will
prevent the old race condition from happening by deleting e1000_watchdog
from timer_list before flush_scheduled_work() is called.

Please incorporate this patch to e1000 source code.
--
  Kenzo Iwami (k-iwami@cj.jp.nec.com)

Signed-off-by: Kenzo Iwami <k-iwami@cj.jp.nec.com>

diff -urpN linux-2.6.20_org/drivers/net/e1000/e1000.h linux-2.6.20_fix/drivers/net/e1000/e1000.h
--- linux-2.6.20_org/drivers/net/e1000/e1000.h	2007-02-05 03:44:54.000000000 +0900
+++ linux-2.6.20_fix/drivers/net/e1000/e1000.h	2007-02-19 09:52:22.000000000 +0900
@@ -268,6 +268,7 @@ struct e1000_adapter {
 	uint16_t tx_itr;
 	uint16_t rx_itr;

+	struct work_struct watchdog_task;
 	struct work_struct reset_task;
 	uint8_t fc_autoneg;

@@ -355,6 +356,8 @@ struct e1000_adapter {
 	boolean_t quad_port_a;
 	unsigned long flags;
 	uint32_t eeprom_wol;
+	/* Indicates that the adapter is being removed if remove_state==1.*/
+	int remove_state;
 };

 enum e1000_state_t {
diff -urpN linux-2.6.20_org/drivers/net/e1000/e1000_main.c linux-2.6.20_fix/drivers/net/e1000/e1000_main.c
--- linux-2.6.20_org/drivers/net/e1000/e1000_main.c	2007-02-05 03:44:54.000000000 +0900
+++ linux-2.6.20_fix/drivers/net/e1000/e1000_main.c	2007-02-20 15:14:40.000000000 +0900
@@ -152,6 +152,7 @@ static void e1000_clean_rx_ring(struct e
 static void e1000_set_multi(struct net_device *netdev);
 static void e1000_update_phy_info(unsigned long data);
 static void e1000_watchdog(unsigned long data);
+static void e1000_watchdog_task(struct work_struct *work);
 static void e1000_82547_tx_fifo_stall(unsigned long data);
 static int e1000_xmit_frame(struct sk_buff *skb, struct net_device *netdev);
 static struct net_device_stats * e1000_get_stats(struct net_device *netdev);
@@ -1044,10 +1045,14 @@ e1000_probe(struct pci_dev *pdev,
 	adapter->tx_fifo_stall_timer.function = &e1000_82547_tx_fifo_stall;
 	adapter->tx_fifo_stall_timer.data = (unsigned long) adapter;

+	adapter->remove_state = 0;
+
 	init_timer(&adapter->watchdog_timer);
 	adapter->watchdog_timer.function = &e1000_watchdog;
 	adapter->watchdog_timer.data = (unsigned long) adapter;

+	INIT_WORK(&adapter->watchdog_task, e1000_watchdog_task);
+
 	init_timer(&adapter->phy_info_timer);
 	adapter->phy_info_timer.function = &e1000_update_phy_info;
 	adapter->phy_info_timer.data = (unsigned long) adapter;
@@ -1219,7 +1224,15 @@ e1000_remove(struct pci_dev *pdev)
 #ifdef CONFIG_E1000_NAPI
 	int i;
 #endif
-
+	/* If e1000_watchdog runs between flush_scheduled_work and
+	 * del_timer_sync(in e1000_down), e1000_watchdog_task is
+	 * called after the adapter is removed. This will cause
+	 * freed memory to be registered to timer list and
+	 * result in system panic. Delete e1000_watchdog from
+	 * timer list to prevent this from happening.
+	 */
+	adapter->remove_state = 1;
+	del_timer_sync(&adapter->watchdog_timer);
 	flush_scheduled_work();

 	e1000_release_manageability(adapter);
@@ -2555,6 +2568,16 @@ static void
 e1000_watchdog(unsigned long data)
 {
 	struct e1000_adapter *adapter = (struct e1000_adapter *) data;
+
+	/* Do the rest outside of interrupt context */
+	schedule_work(&adapter->watchdog_task);
+}
+
+static void
+e1000_watchdog_task(struct work_struct *work)
+{
+	struct e1000_adapter *adapter =
+		container_of(work, struct e1000_adapter, watchdog_task);
 	struct net_device *netdev = adapter->netdev;
 	struct e1000_tx_ring *txdr = adapter->tx_ring;
 	uint32_t link, tctl;
@@ -2724,7 +2747,8 @@ e1000_watchdog(unsigned long data)
 		e1000_rar_set(&adapter->hw, adapter->hw.mac_addr, 0);

 	/* Reset the timer */
-	mod_timer(&adapter->watchdog_timer, jiffies + 2 * HZ);
+	if (!adapter->remove_state)
+		mod_timer(&adapter->watchdog_timer, jiffies + 2 * HZ);
 }

 enum latency_range {
