From: Taku Izumi <izumi.taku@jp.fujitsu.com>
Subject: [PATCH v2.1 17/22] fjes: force_close_task
Date: Thu, 23 Jul 2015 09:10:31 +0900
Message-ID: <1437610236-12490-17-git-send-email-izumi.taku@jp.fujitsu.com>
References: <1437610142-12439-1-git-send-email-izumi.taku@jp.fujitsu.com>
 <1437610236-12490-1-git-send-email-izumi.taku@jp.fujitsu.com>
Cc: platform-driver-x86@vger.kernel.org, dvhart@infradead.org,
	rkhan@redhat.com, alexander.h.duyck@redhat.com,
	linux-acpi@vger.kernel.org, joe@perches.com,
	sergei.shtylyov@cogentembedded.com, stephen@networkplumber.org,
	yasu.isimatu@gmail.com, Taku Izumi <izumi.taku@jp.fujitsu.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <1437610236-12490-1-git-send-email-izumi.taku@jp.fujitsu.com>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds force_close_task.
This task is used to close network device forcibly.

Signed-off-by: Taku Izumi <izumi.taku@jp.fujitsu.com>
---
 drivers/net/fjes/fjes.h      |  1 +
 drivers/net/fjes/fjes_main.c | 13 +++++++++++++
 2 files changed, 14 insertions(+)

diff --git a/drivers/net/fjes/fjes.h b/drivers/net/fjes/fjes.h
index 1743dbb..d31d4c3 100644
--- a/drivers/net/fjes/fjes.h
+++ b/drivers/net/fjes/fjes.h
@@ -47,6 +47,7 @@ struct fjes_adapter {
 	unsigned long rx_last_jiffies;
 	bool unset_rx_last;
 
+	struct work_struct force_close_task;
 	bool force_reset;
 	bool open_guard;
 
diff --git a/drivers/net/fjes/fjes_main.c b/drivers/net/fjes/fjes_main.c
index 2bf9f71..3a8cc5b 100644
--- a/drivers/net/fjes/fjes_main.c
+++ b/drivers/net/fjes/fjes_main.c
@@ -54,6 +54,7 @@ static void fjes_free_resources(struct fjes_adapter *);
 static netdev_tx_t fjes_xmit_frame(struct sk_buff *, struct net_device *);
 static void fjes_raise_intr_rxdata_task(struct work_struct *);
 static void fjes_tx_stall_task(struct work_struct *);
+static void fjes_force_close_task(struct work_struct *);
 static irqreturn_t fjes_intr(int, void*);
 static struct rtnl_link_stats64 *
 fjes_get_stats64(struct net_device *, struct rtnl_link_stats64 *);
@@ -494,6 +495,17 @@ static void fjes_tx_stall_task(struct work_struct *work)
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
@@ -1006,6 +1018,7 @@ static int fjes_probe(struct platform_device *plat_dev)
 	if (err)
 		goto err_sw_init;
 
+	INIT_WORK(&adapter->force_close_task, fjes_force_close_task);
 	adapter->force_reset = false;
 	adapter->open_guard = false;
 
-- 
1.8.3.1

