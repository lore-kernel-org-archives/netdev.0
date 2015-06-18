From: Taku Izumi <izumi.taku@jp.fujitsu.com>
Subject: [PATCH 13/22] fjes: net_device_ops.ndo_change_mtu
Date: Thu, 18 Jun 2015 09:49:38 +0900
Message-ID: <1434588587-25655-13-git-send-email-izumi.taku@jp.fujitsu.com>
References: <1434588359-25589-1-git-send-email-izumi.taku@jp.fujitsu.com>
 <1434588587-25655-1-git-send-email-izumi.taku@jp.fujitsu.com>
Cc: rkhan@redhat.com, alexander.h.duyck@redhat.com,
	netdev@vger.kernel.org, linux-acpi@vger.kernel.org,
	Taku Izumi <izumi.taku@jp.fujitsu.com>
To: platform-driver-x86@vger.kernel.org, dvhart@infradead.org
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <1434588587-25655-1-git-send-email-izumi.taku@jp.fujitsu.com>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds net_device_ops.ndo_change_mtu.

Signed-off-by: Taku Izumi <izumi.taku@jp.fujitsu.com>
---
 drivers/platform/x86/fjes/fjes_main.c | 30 ++++++++++++++++++++++++++++++
 1 file changed, 30 insertions(+)

diff --git a/drivers/platform/x86/fjes/fjes_main.c b/drivers/platform/x86/fjes/fjes_main.c
index eeda824..72541a7 100644
--- a/drivers/platform/x86/fjes/fjes_main.c
+++ b/drivers/platform/x86/fjes/fjes_main.c
@@ -59,6 +59,7 @@ static void fjes_tx_stall_task(struct work_struct *);
 static irqreturn_t fjes_intr(int, void*);
 static struct rtnl_link_stats64
 *fjes_get_stats64(struct net_device *, struct rtnl_link_stats64 *);
+static int fjes_change_mtu(struct net_device *, int);
 
 static int fjes_acpi_add(struct acpi_device *);
 static int fjes_acpi_remove(struct acpi_device *);
@@ -226,6 +227,7 @@ static const struct net_device_ops fjes_netdev_ops = {
 	.ndo_stop		= fjes_close,
 	.ndo_start_xmit		= fjes_xmit_frame,
 	.ndo_get_stats64	= fjes_get_stats64,
+	.ndo_change_mtu		= fjes_change_mtu,
 };
 
 /*
@@ -748,6 +750,34 @@ static struct rtnl_link_stats64
 	return stats;
 }
 
+static int fjes_change_mtu(struct net_device *netdev, int new_mtu)
+{
+	int idx;
+	bool running = netif_running(netdev);
+	int ret = 0;
+
+	for (idx = 0; fjes_support_mtu[idx] != 0; idx++) {
+		if (new_mtu <= fjes_support_mtu[idx]) {
+
+			new_mtu = fjes_support_mtu[idx];
+			if (new_mtu == netdev->mtu)
+				return 0;
+
+			if (running)
+				fjes_close(netdev);
+
+			netdev->mtu = new_mtu;
+
+			if (running)
+				ret = fjes_open(netdev);
+
+			return ret;
+		}
+	}
+
+	return -EINVAL;
+}
+
 static irqreturn_t fjes_intr(int irq, void *data)
 {
 	struct fjes_adapter *adapter = data;
-- 
1.8.3.1

