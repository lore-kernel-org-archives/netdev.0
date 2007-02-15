From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 1/4] r8169: RTNL and flush_scheduled_work deadlock
Date: Thu, 15 Feb 2007 23:37:21 +0100
Message-ID: <20070215223721.GA19840@electric-eye.fr.zoreil.com>
References: <20070214132729.479793ac@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	akpm@linux-foundation.org, Ben Greear <greearb@candelatech.com>,
	Kyle Lucke <klucke@us.ibm.com>,
	Raghavendra Koushik <raghavendra.koushik@neterion.com>,
	Al Viro <viro@ftp.linux.org.uk>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:39347 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161582AbXBOWlG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Feb 2007 17:41:06 -0500
Content-Disposition: inline
In-Reply-To: <20070214132729.479793ac@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

flush_scheduled_work() in net_device->close has a slight tendency
to deadlock with tasks on the workqueue that hold RTNL.

rtl8169_close/down simply need the recovery tasks to not meddle
with the hardware while the device is going down.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/r8169.c |   25 ++++++++++++++++++-------
 1 files changed, 18 insertions(+), 7 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 5598d86..13cf06e 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -1733,6 +1733,8 @@ rtl8169_remove_one(struct pci_dev *pdev)
 	assert(dev != NULL);
 	assert(tp != NULL);
 
+	flush_scheduled_work();
+
 	unregister_netdev(dev);
 	rtl8169_release_board(pdev, dev, tp->mmio_addr);
 	pci_set_drvdata(pdev, NULL);
@@ -2161,10 +2163,13 @@ static void rtl8169_reinit_task(struct work_struct *work)
 	struct net_device *dev = tp->dev;
 	int ret;
 
-	if (netif_running(dev)) {
-		rtl8169_wait_for_quiescence(dev);
-		rtl8169_close(dev);
-	}
+	rtnl_lock();
+
+	if (!netif_running(dev))
+		goto out_unlock;
+
+	rtl8169_wait_for_quiescence(dev);
+	rtl8169_close(dev);
 
 	ret = rtl8169_open(dev);
 	if (unlikely(ret < 0)) {
@@ -2179,6 +2184,9 @@ static void rtl8169_reinit_task(struct work_struct *work)
 		}
 		rtl8169_schedule_work(dev, rtl8169_reinit_task);
 	}
+
+out_unlock:
+	rtnl_unlock();
 }
 
 static void rtl8169_reset_task(struct work_struct *work)
@@ -2187,8 +2195,10 @@ static void rtl8169_reset_task(struct work_struct *work)
 		container_of(work, struct rtl8169_private, task.work);
 	struct net_device *dev = tp->dev;
 
+	rtnl_lock();
+
 	if (!netif_running(dev))
-		return;
+		goto out_unlock;
 
 	rtl8169_wait_for_quiescence(dev);
 
@@ -2210,6 +2220,9 @@ static void rtl8169_reset_task(struct work_struct *work)
 		}
 		rtl8169_schedule_work(dev, rtl8169_reset_task);
 	}
+
+out_unlock:
+	rtnl_unlock();
 }
 
 static void rtl8169_tx_timeout(struct net_device *dev)
@@ -2722,8 +2735,6 @@ static void rtl8169_down(struct net_device *dev)
 
 	netif_stop_queue(dev);
 
-	flush_scheduled_work();
-
 core_down:
 	spin_lock_irq(&tp->lock);
 
-- 
1.4.4.4

