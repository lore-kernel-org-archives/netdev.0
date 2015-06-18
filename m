From: Taku Izumi <izumi.taku@jp.fujitsu.com>
Subject: [PATCH 17/22] fjes: force_close_task
Date: Thu, 18 Jun 2015 09:49:42 +0900
Message-ID: <1434588587-25655-17-git-send-email-izumi.taku@jp.fujitsu.com>
References: <1434588359-25589-1-git-send-email-izumi.taku@jp.fujitsu.com>
 <1434588587-25655-1-git-send-email-izumi.taku@jp.fujitsu.com>
Cc: rkhan@redhat.com, alexander.h.duyck@redhat.com,
	netdev@vger.kernel.org, linux-acpi@vger.kernel.org,
	Taku Izumi <izumi.taku@jp.fujitsu.com>
To: platform-driver-x86@vger.kernel.org, dvhart@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgwym04.jp.fujitsu.com ([211.128.242.43]:52903 "EHLO
	mgwym04.jp.fujitsu.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753227AbbFRAx3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2015 20:53:29 -0400
In-Reply-To: <1434588587-25655-1-git-send-email-izumi.taku@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds force_close_task.
This task is used to close network device forcibly.

Signed-off-by: Taku Izumi <izumi.taku@jp.fujitsu.com>
---
 drivers/platform/x86/fjes/fjes.h      |  1 +
 drivers/platform/x86/fjes/fjes_main.c | 13 +++++++++++++
 2 files changed, 14 insertions(+)

diff --git a/drivers/platform/x86/fjes/fjes.h b/drivers/platform/x86/fjes/fjes.h
index 1a880a0..e50fd01 100644
--- a/drivers/platform/x86/fjes/fjes.h
+++ b/drivers/platform/x86/fjes/fjes.h
@@ -49,6 +49,7 @@ struct fjes_adapter {
 	unsigned long rx_last_jiffies;
 	bool unset_rx_last;
 
+	struct work_struct force_close_task;
 	bool force_reset;
 	bool open_guard;
 
diff --git a/drivers/platform/x86/fjes/fjes_main.c b/drivers/platform/x86/fjes/fjes_main.c
index 8e78014..3931bcc 100644
--- a/drivers/platform/x86/fjes/fjes_main.c
+++ b/drivers/platform/x86/fjes/fjes_main.c
@@ -56,6 +56,7 @@ static netdev_tx_t fjes_xmit_frame(struct sk_buff *,
 		struct net_device *);
 static void fjes_raise_intr_rxdata_task(struct work_struct *);
 static void fjes_tx_stall_task(struct work_struct *);
+static void fjes_force_close_task(struct work_struct *);
 static irqreturn_t fjes_intr(int, void*);
 static struct rtnl_link_stats64
 *fjes_get_stats64(struct net_device *, struct rtnl_link_stats64 *);
@@ -509,6 +510,17 @@ static void fjes_tx_stall_task(struct work_struct *work)
 	queue_work(adapter->txrx_wq, &adapter->tx_stall_task);
 }
 
+static void fjes_force_close_task(struct work_struct *work)
+{
+	struct fjes_adapter *adapter = container_of(work,
+			struct fjes_adapter, force_close_task);
+	struct net_device *netdev = adapter->netdev;
+
+	rtnl_lock();
+	dev_close(netdev);
+	rtnl_unlock();
+}
+
 static void fjes_raise_intr_rxdata_task(struct work_struct *work)
 {
 	struct fjes_adapter *adapter = container_of(work,
@@ -1053,6 +1065,7 @@ static int fjes_probe(struct platform_device *plat_dev)
 	if (err)
 		goto err_sw_init;
 
+	INIT_WORK(&adapter->force_close_task, fjes_force_close_task);
 	adapter->force_reset = false;
 	adapter->open_guard = false;
 
-- 
1.8.3.1
