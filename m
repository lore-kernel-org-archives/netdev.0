From: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
Subject: Re: [-MM GIT PULL] e1000: fixes, API rewrite, cleanups
Date: Sun, 01 Apr 2007 01:00:52 +0900
Message-ID: <87d52p8ksr.fsf@duaron.myhome.or.jp>
References: <20070329225815.C977F40951@ahkok-mobl.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	jesse.brandeburg@intel.com, john.ronciak@intel.com,
	arjan@linux.intel.com, netdev@vger.kernel.org, jgarzik@pobox.com
To: Auke Kok <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.parknet.jp ([210.171.160.80]:2906 "EHLO parknet.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753248AbXCaQJP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 31 Mar 2007 12:09:15 -0400
Received: from ibmpc.myhome.or.jp ([210.171.168.39]:2711)
	by parknet.jp with [XMail 1.21 ESMTP Server]
	id <S11ABC> for <netdev@vger.kernel.org> from <hirofumi@mail.parknet.co.jp>;
	Sun, 1 Apr 2007 01:01:38 +0900
In-Reply-To: <20070329225815.C977F40951@ahkok-mobl.jf.intel.com> (Auke Kok's message of "Thu Mar 29 15\:50\:55 PDT 2007")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Auke Kok <auke-jan.h.kok@intel.com> writes:

> All patches from 3) onwards are also available to view over here:
>     http://foo-projects.org/~sofar/patches-20070327/

Doesn't the patch have a rare race? What do you think about the
following situation?

           cpu0                                     cpu1
---------------------------------------------------------------------------
                                             e1000_watchdog_task()
e1000_remove()
                                                 test_bit(__E1000_DOWN)
    set_bit(__E1000_DOWN)
    del_timer_sync(watchdog_timer)
                                                 mod_timer(watchdog_timer)
    flush_scheduled_work()
/* module was removed */
                                             /* run watchdog_timer.function */
                                             e1000_watchdog()
                                             e1000_watchdog_task()

If I'm not missing something, workqueue may be simple solution.
-- 
OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>


e1000: introduce watchdog task

From: Auke Kok <auke-jan.h.kok@intel.com>

An SNMP program polling the interface using ethool multiple times per
second exposed a design issue in the e1000 software_firmware semaphore.
This semaphore can possibly be help for a relatively long time during which
tx/rx continues normally, but other register reads/writes such as mac/phy
settings or statistic reads are forced to wait.

If a process in non-interrupt context is holding the semaphore while
another one in interrupt context attempts to hold it, a deadlock occurs.
This can be reproduced easily with a tight loop calling ethtool, because
the watchdog code in e1000 currently runs entirely in interrupt context.

The solution has multiple parts, but mostly introduces the watchdog timer
task into the driver to assure that the semaphore is never held in
interrupt context. This can be verified by placing a BUG_ON(in_interrupt())
in that code.

Aside from that, we need to assure that we are not re-scheduling the
watchdog inadvertently while removing the device. Several state checks
prevent those.

Many thanks to Kenzo Iwami <k-iwami@cj.jp.nec.com> for persistently
working with us in getting this fixed.

Cc: Kenzo Iwami <k-iwami@cj.jp.nec.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000.h      |    1 +
 drivers/net/e1000/e1000_main.c |   41 ++++++++++++++++++++++++++++++++++------
 2 files changed, 36 insertions(+), 6 deletions(-)

diff --git a/drivers/net/e1000/e1000.h b/drivers/net/e1000/e1000.h
index cb130b9..18a6e4b 100644
--- a/drivers/net/e1000/e1000.h
+++ b/drivers/net/e1000/e1000.h
@@ -227,6 +227,7 @@ struct e1000_adapter {
 	u16 rx_itr;
 
 	struct work_struct reset_task;
+	struct work_struct watchdog_task;
 	u8 fc_autoneg;
 
 	struct timer_list blink_timer;
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index bfc0144..2641388 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -164,6 +164,7 @@ static void e1000_clean_rx_ring(struct e1000_adapter *adapter,
 static void e1000_set_multi(struct net_device *netdev);
 static void e1000_update_phy_info(unsigned long data);
 static void e1000_watchdog(unsigned long data);
+static void e1000_watchdog_task(struct work_struct *work);
 static void e1000_82547_tx_fifo_stall(unsigned long data);
 static int e1000_xmit_frame(struct sk_buff *skb, struct net_device *netdev);
 static struct net_device_stats * e1000_get_stats(struct net_device *netdev);
@@ -1094,6 +1095,7 @@ e1000_probe(struct pci_dev *pdev,
 	adapter->phy_info_timer.data = (unsigned long) adapter;
 
 	INIT_WORK(&adapter->reset_task, e1000_reset_task);
+	INIT_WORK(&adapter->watchdog_task, e1000_watchdog_task);
 
 	e1000_check_options(adapter);
 
@@ -1264,6 +1266,13 @@ e1000_remove(struct pci_dev *pdev)
 	int i;
 #endif
 
+	/* flush_scheduled work may reschedule our watchdog task, so
+	 * explicitly disable watchdog tasks from being rescheduled  */
+	set_bit(__E1000_DOWN, &adapter->flags);
+	del_timer_sync(&adapter->tx_fifo_stall_timer);
+	del_timer_sync(&adapter->watchdog_timer);
+	del_timer_sync(&adapter->phy_info_timer);
+
 	flush_scheduled_work();
 
 	e1000_release_manageability(adapter);
@@ -1281,6 +1290,8 @@ e1000_remove(struct pci_dev *pdev)
 	if (!e1000_check_reset_block(&adapter->hw))
 		e1000_phy_hw_reset(&adapter->hw);
 
+	e1000_remove_device(&adapter->hw);
+
 	kfree(adapter->tx_ring);
 	kfree(adapter->rx_ring);
 #ifdef CONFIG_E1000_NAPI
@@ -2555,9 +2566,8 @@ e1000_82547_tx_fifo_stall(unsigned long data)
 			adapter->tx_fifo_head = 0;
 			atomic_set(&adapter->tx_fifo_stall, 0);
 			netif_wake_queue(netdev);
-		} else {
+		} else if (!test_bit(__E1000_DOWN, &adapter->flags))
 			mod_timer(&adapter->tx_fifo_stall_timer, jiffies + 1);
-		}
 	}
 }
 
@@ -2569,6 +2579,17 @@ static void
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
 	struct e1000_mac_info *mac = &adapter->hw.mac;
@@ -2671,7 +2692,9 @@ e1000_watchdog(unsigned long data)
 
 			netif_carrier_on(netdev);
 			netif_wake_queue(netdev);
-			mod_timer(&adapter->phy_info_timer, round_jiffies(jiffies + 2 * HZ));
+			if (!test_bit(__E1000_DOWN, &adapter->flags))
+				mod_timer(&adapter->phy_info_timer,
+				          round_jiffies(jiffies + 2 * HZ));
 			adapter->smartspeed = 0;
 		} else {
 			/* make sure the receive unit is started */
@@ -2688,7 +2711,9 @@ e1000_watchdog(unsigned long data)
 			DPRINTK(LINK, INFO, "NIC Link is Down\n");
 			netif_carrier_off(netdev);
 			netif_stop_queue(netdev);
-			mod_timer(&adapter->phy_info_timer, round_jiffies(jiffies + 2 * HZ));
+			if (!test_bit(__E1000_DOWN, &adapter->flags))
+				mod_timer(&adapter->phy_info_timer,
+				          round_jiffies(jiffies + 2 * HZ));
 
 			/* 80003ES2LAN workaround--
 			 * For packet buffer work-around on link down event;
@@ -2740,7 +2765,9 @@ e1000_watchdog(unsigned long data)
 		e1000_rar_set(&adapter->hw, adapter->hw.mac.addr, 0);
 
 	/* Reset the timer */
-	mod_timer(&adapter->watchdog_timer, round_jiffies(jiffies + 2 * HZ));
+	if (!test_bit(__E1000_DOWN, &adapter->flags))
+		mod_timer(&adapter->watchdog_timer,
+		          round_jiffies(jiffies + 2 * HZ));
 }
 
 enum latency_range {
@@ -3395,7 +3422,9 @@ e1000_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	if (unlikely(adapter->hw.mac.type == e1000_82547)) {
 		if (unlikely(e1000_82547_fifo_workaround(adapter, skb))) {
 			netif_stop_queue(netdev);
-			mod_timer(&adapter->tx_fifo_stall_timer, jiffies + 1);
+			if (!test_bit(__E1000_DOWN, &adapter->flags))
+				mod_timer(&adapter->tx_fifo_stall_timer,
+				          jiffies + 1);
 			spin_unlock_irqrestore(&tx_ring->tx_lock, flags);
 			return NETDEV_TX_BUSY;
 		}
