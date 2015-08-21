From: Taku Izumi <izumi.taku@jp.fujitsu.com>
Subject: [PATCH v3 22/22] fjes: ethtool support
Date: Fri, 21 Aug 2015 17:29:38 +0900
Message-ID: <1440145778-15941-22-git-send-email-izumi.taku@jp.fujitsu.com>
References: <1440145680-15851-1-git-send-email-izumi.taku@jp.fujitsu.com>
 <1440145778-15941-1-git-send-email-izumi.taku@jp.fujitsu.com>
Cc: platform-driver-x86@vger.kernel.org, dvhart@infradead.org,
	rkhan@redhat.com, alexander.h.duyck@redhat.com,
	linux-acpi@vger.kernel.org, joe@perches.com,
	sergei.shtylyov@cogentembedded.com, stephen@networkplumber.org,
	yasu.isimatu@gmail.com, Taku Izumi <izumi.taku@jp.fujitsu.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <1440145778-15941-1-git-send-email-izumi.taku@jp.fujitsu.com>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds implementation for ethtool support.

Signed-off-by: Taku Izumi <izumi.taku@jp.fujitsu.com>
---
 drivers/net/fjes/Makefile       |   2 +-
 drivers/net/fjes/fjes.h         |   2 +
 drivers/net/fjes/fjes_ethtool.c | 137 ++++++++++++++++++++++++++++++++++++++++
 drivers/net/fjes/fjes_main.c    |   1 +
 4 files changed, 141 insertions(+), 1 deletion(-)
 create mode 100644 drivers/net/fjes/fjes_ethtool.c

diff --git a/drivers/net/fjes/Makefile b/drivers/net/fjes/Makefile
index 753d52f..523e3d7 100644
--- a/drivers/net/fjes/Makefile
+++ b/drivers/net/fjes/Makefile
@@ -27,4 +27,4 @@
 
 obj-$(CONFIG_FUJITSU_ES) += fjes.o
 
-fjes-objs := fjes_main.o fjes_hw.o
+fjes-objs := fjes_main.o fjes_hw.o fjes_ethtool.o
diff --git a/drivers/net/fjes/fjes.h b/drivers/net/fjes/fjes.h
index 57feee8..a592fe2 100644
--- a/drivers/net/fjes/fjes.h
+++ b/drivers/net/fjes/fjes.h
@@ -72,4 +72,6 @@ extern char fjes_driver_name[];
 extern char fjes_driver_version[];
 extern const u32 fjes_support_mtu[];
 
+void fjes_set_ethtool_ops(struct net_device *);
+
 #endif /* FJES_H_ */
diff --git a/drivers/net/fjes/fjes_ethtool.c b/drivers/net/fjes/fjes_ethtool.c
new file mode 100644
index 0000000..0119dd1
--- /dev/null
+++ b/drivers/net/fjes/fjes_ethtool.c
@@ -0,0 +1,137 @@
+/*
+ *  FUJITSU Extended Socket Network Device driver
+ *  Copyright (c) 2015 FUJITSU LIMITED
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License along with
+ * this program; if not, see <http://www.gnu.org/licenses/>.
+ *
+ * The full GNU General Public License is included in this distribution in
+ * the file called "COPYING".
+ *
+ */
+
+/* ethtool support for fjes */
+
+#include <linux/vmalloc.h>
+#include <linux/netdevice.h>
+#include <linux/ethtool.h>
+#include <linux/platform_device.h>
+
+#include "fjes.h"
+
+struct fjes_stats {
+	char stat_string[ETH_GSTRING_LEN];
+	int sizeof_stat;
+	int stat_offset;
+};
+
+#define FJES_STAT(name, stat) { \
+	.stat_string = name, \
+	.sizeof_stat = FIELD_SIZEOF(struct fjes_adapter, stat), \
+	.stat_offset = offsetof(struct fjes_adapter, stat) \
+}
+
+static const struct fjes_stats fjes_gstrings_stats[] = {
+	FJES_STAT("rx_packets", stats64.rx_packets),
+	FJES_STAT("tx_packets", stats64.tx_packets),
+	FJES_STAT("rx_bytes", stats64.rx_bytes),
+	FJES_STAT("tx_bytes", stats64.rx_bytes),
+	FJES_STAT("rx_dropped", stats64.rx_dropped),
+	FJES_STAT("tx_dropped", stats64.tx_dropped),
+};
+
+static void fjes_get_ethtool_stats(struct net_device *netdev,
+				   struct ethtool_stats *stats, u64 *data)
+{
+	struct fjes_adapter *adapter = netdev_priv(netdev);
+	char *p;
+	int i;
+
+	for (i = 0; i < ARRAY_SIZE(fjes_gstrings_stats); i++) {
+		p = (char *)adapter + fjes_gstrings_stats[i].stat_offset;
+		data[i] = (fjes_gstrings_stats[i].sizeof_stat == sizeof(u64))
+			? *(u64 *)p : *(u32 *)p;
+	}
+}
+
+static void fjes_get_strings(struct net_device *netdev,
+			     u32 stringset, u8 *data)
+{
+	u8 *p = data;
+	int i;
+
+	switch (stringset) {
+	case ETH_SS_STATS:
+		for (i = 0; i < ARRAY_SIZE(fjes_gstrings_stats); i++) {
+			memcpy(p, fjes_gstrings_stats[i].stat_string,
+			       ETH_GSTRING_LEN);
+			p += ETH_GSTRING_LEN;
+		}
+		break;
+	}
+}
+
+static int fjes_get_sset_count(struct net_device *netdev, int sset)
+{
+	switch (sset) {
+	case ETH_SS_STATS:
+		return ARRAY_SIZE(fjes_gstrings_stats);
+	default:
+		return -EOPNOTSUPP;
+	}
+}
+
+static void fjes_get_drvinfo(struct net_device *netdev,
+			     struct ethtool_drvinfo *drvinfo)
+{
+	struct fjes_adapter *adapter = netdev_priv(netdev);
+	struct platform_device *plat_dev;
+
+	plat_dev = adapter->plat_dev;
+
+	strlcpy(drvinfo->driver, fjes_driver_name, sizeof(drvinfo->driver));
+	strlcpy(drvinfo->version, fjes_driver_version,
+		sizeof(drvinfo->version));
+
+	strlcpy(drvinfo->fw_version, "none", sizeof(drvinfo->fw_version));
+	snprintf(drvinfo->bus_info, sizeof(drvinfo->bus_info),
+		 "platform:%s", plat_dev->name);
+	drvinfo->regdump_len = 0;
+	drvinfo->eedump_len = 0;
+}
+
+static int fjes_get_settings(struct net_device *netdev,
+			     struct ethtool_cmd *ecmd)
+{
+	ecmd->supported = 0;
+	ecmd->advertising = 0;
+	ecmd->duplex = DUPLEX_FULL;
+	ecmd->autoneg = AUTONEG_DISABLE;
+	ecmd->transceiver = XCVR_DUMMY1;
+	ecmd->port = PORT_NONE;
+	ethtool_cmd_speed_set(ecmd, 20000);	/* 20Gb/s */
+
+	return 0;
+}
+
+static const struct ethtool_ops fjes_ethtool_ops = {
+		.get_settings		= fjes_get_settings,
+		.get_drvinfo		= fjes_get_drvinfo,
+		.get_ethtool_stats = fjes_get_ethtool_stats,
+		.get_strings      = fjes_get_strings,
+		.get_sset_count   = fjes_get_sset_count,
+};
+
+void fjes_set_ethtool_ops(struct net_device *netdev)
+{
+	netdev->ethtool_ops = &fjes_ethtool_ops;
+}
diff --git a/drivers/net/fjes/fjes_main.c b/drivers/net/fjes/fjes_main.c
index 5f93e42..0ddb54f 100644
--- a/drivers/net/fjes/fjes_main.c
+++ b/drivers/net/fjes/fjes_main.c
@@ -1202,6 +1202,7 @@ static void fjes_netdev_setup(struct net_device *netdev)
 
 	netdev->watchdog_timeo = FJES_TX_RETRY_INTERVAL;
 	netdev->netdev_ops = &fjes_netdev_ops;
+	fjes_set_ethtool_ops(netdev);
 	netdev->mtu = fjes_support_mtu[0];
 	netdev->flags |= IFF_BROADCAST;
 	netdev->features |= NETIF_F_HW_CSUM | NETIF_F_HW_VLAN_CTAG_FILTER;
-- 
1.8.3.1

