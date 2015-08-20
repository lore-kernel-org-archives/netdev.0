From: Taku Izumi <izumi.taku@jp.fujitsu.com>
Subject: [PATCH v2.2 13/22] fjes: net_device_ops.ndo_change_mtu
Date: Thu, 20 Aug 2015 17:46:17 +0900
Message-ID: <1440060386-13189-13-git-send-email-izumi.taku@jp.fujitsu.com>
References: <1440060306-13040-1-git-send-email-izumi.taku@jp.fujitsu.com>
 <1440060386-13189-1-git-send-email-izumi.taku@jp.fujitsu.com>
Cc: platform-driver-x86@vger.kernel.org, dvhart@infradead.org,
	rkhan@redhat.com, alexander.h.duyck@redhat.com,
	linux-acpi@vger.kernel.org, joe@perches.com,
	sergei.shtylyov@cogentembedded.com, stephen@networkplumber.org,
	yasu.isimatu@gmail.com, Taku Izumi <izumi.taku@jp.fujitsu.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <platform-driver-x86-owner@vger.kernel.org>
In-Reply-To: <1440060386-13189-1-git-send-email-izumi.taku@jp.fujitsu.com>
Sender: platform-driver-x86-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds net_device_ops.ndo_change_mtu.

Signed-off-by: Taku Izumi <izumi.taku@jp.fujitsu.com>
---
 drivers/net/fjes/fjes_main.c | 29 +++++++++++++++++++++++++++++
 1 file changed, 29 insertions(+)

diff --git a/drivers/net/fjes/fjes_main.c b/drivers/net/fjes/fjes_main.c
index 842edbb..bb94890 100644
--- a/drivers/net/fjes/fjes_main.c
+++ b/drivers/net/fjes/fjes_main.c
@@ -57,6 +57,7 @@ static void fjes_tx_stall_task(struct work_struct *);
 static irqreturn_t fjes_intr(int, void*);
 static struct rtnl_link_stats64 *
 fjes_get_stats64(struct net_device *, struct rtnl_link_stats64 *);
+static int fjes_change_mtu(struct net_device *, int);
 
 static int fjes_acpi_add(struct acpi_device *);
 static int fjes_acpi_remove(struct acpi_device *);
@@ -222,6 +223,7 @@ static const struct net_device_ops fjes_netdev_ops = {
 	.ndo_stop		= fjes_close,
 	.ndo_start_xmit		= fjes_xmit_frame,
 	.ndo_get_stats64	= fjes_get_stats64,
+	.ndo_change_mtu		= fjes_change_mtu,
 };
 
 /* fjes_open - Called when a network interface is made active */
@@ -715,6 +717,33 @@ fjes_get_stats64(struct net_device *netdev, struct rtnl_link_stats64 *stats)
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
