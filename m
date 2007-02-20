From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: watchdog timeout panic in e1000 driver
Date: Tue, 20 Feb 2007 08:10:35 -0800
Message-ID: <45DB1D7B.9020008@intel.com>
References: <45375135.5050206@cj.jp.nec.com> <45DABECF.5020202@cj.jp.nec.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060400010202080306040809"
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, "Ronciak, John" <john.ronciak@intel.com>
To: Kenzo Iwami <k-iwami@cj.jp.nec.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:46833 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965225AbXBTQK5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Feb 2007 11:10:57 -0500
In-Reply-To: <45DABECF.5020202@cj.jp.nec.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------060400010202080306040809
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Kenzo Iwami wrote:
> Hi,
> 
> I created a patch that uses watchdog_task but fixes the race condition
> that occurred in old the e1000 driver.
> 
> I've obtained information about the panic caused by the old e1000 driver
> using e1000_watchdog_task. According to the crash dump, the panic was
> caused by a timer_list whose contents were NULLs. Further trace
> information revealed that the function in the timer list was
> e1000_watchdog().
> 
> This function is registered in timer_list during e1000_watchdog_task.
> It seems that e1000_watchdog_task could be called after the adapter is
> removed, and freed memory is registered to timer_list.
> 
> By looking at the source code, e1000_watchdog_task will be scheduled if
> e1000_watchdog is invoked during e1000_remove, after flush_scheduled_work()
> is called, but before del_timer_sync() is called in e1000_down().
> 
> The attached patch adds back the e1000_watchdog_task(), but it will
> prevent the old race condition from happening by deleting e1000_watchdog
> from timer_list before flush_scheduled_work() is called.


Kenzo,

this looks a lot better than the previous patch!! However, we already have a 
state marker for _down_ that we should probably reuse. Can you try the attached 
patch and see if it works for you? It's basically your patch without the added 
remove flag and instead using the already available atomic state trackers.

If this works for you then that is great news and I'll push this patch to the 
upstream kernel maintainers after testing.

Cheers,

Auke




--------------060400010202080306040809
Content-Type: text/x-patch;
 name="e1000_git_kenzo_use_state_flags.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="e1000_git_kenzo_use_state_flags.patch"

diff --git a/drivers/net/e1000/e1000.h b/drivers/net/e1000/e1000.h
index 689f158..bd4026d 100644
--- a/drivers/net/e1000/e1000.h
+++ b/drivers/net/e1000/e1000.h
@@ -264,6 +264,7 @@ struct e1000_adapter {
 	uint16_t rx_itr;
 
 	struct work_struct reset_task;
+	struct work_struct watchdog_task;
 	uint8_t fc_autoneg;
 
 	struct timer_list blink_timer;
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 619c892..0548e65 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -152,6 +152,7 @@ static void e1000_clean_rx_ring(struct e1000_adapter *adapter,
 static void e1000_set_multi(struct net_device *netdev);
 static void e1000_update_phy_info(unsigned long data);
 static void e1000_watchdog(unsigned long data);
+static void e1000_watchdog_task(struct work_struct *work);
 static void e1000_82547_tx_fifo_stall(unsigned long data);
 static int e1000_xmit_frame(struct sk_buff *skb, struct net_device *netdev);
 static struct net_device_stats * e1000_get_stats(struct net_device *netdev);
@@ -1049,6 +1050,7 @@ e1000_probe(struct pci_dev *pdev,
 	adapter->phy_info_timer.data = (unsigned long) adapter;
 
 	INIT_WORK(&adapter->reset_task, e1000_reset_task);
+	INIT_WORK(&adapter->watchdog_task, e1000_watchdog_task);
 
 	e1000_check_options(adapter);
 
@@ -1216,6 +1218,11 @@ e1000_remove(struct pci_dev *pdev)
 	int i;
 #endif
 
+	/* flush_scheduled work may reschedule our watchdog task, so
+	 * explicitly disable watchdog tasks from being rescheduled  */
+	set_bit(__E1000_DOWN, &adapter->flags);
+	del_timer_sync(&adapter->watchdog_timer);
+
 	flush_scheduled_work();
 
 	e1000_release_manageability(adapter);
@@ -2551,6 +2558,17 @@ static void
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
+	struct e1000_adapter *adapter = container_of(work,
+	                                struct e1000_adapter, watchdog_task);
+
 	struct net_device *netdev = adapter->netdev;
 	struct e1000_tx_ring *txdr = adapter->tx_ring;
 	uint32_t link, tctl;
@@ -2721,7 +2739,8 @@ e1000_watchdog(unsigned long data)
 		e1000_rar_set(&adapter->hw, adapter->hw.mac_addr, 0);
 
 	/* Reset the timer */
-	mod_timer(&adapter->watchdog_timer, jiffies + 2 * HZ);
+	if (!test_bit(__E1000_DOWN, &adapter->flags))
+		mod_timer(&adapter->watchdog_timer, jiffies + 2 * HZ);
 }
 
 enum latency_range {

--------------060400010202080306040809--
