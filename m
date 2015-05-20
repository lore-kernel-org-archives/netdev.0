From: "Izumi, Taku" <izumi.taku@jp.fujitsu.com>
Subject: [PATCH 7/7] fjes: Add ethtool support
Date: Wed, 20 May 2015 08:23:22 +0000
Message-ID: <E86EADE93E2D054CBCD4E708C38D364A5422D89B@G01JPEXMBYT01>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Cc: "Hart, Darren" <darren.hart@intel.com>,
	"rkhan@redhat.com" <rkhan@redhat.com>,
	"alexander.h.duyck@redhat.com" <alexander.h.duyck@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>
To: "platform-driver-x86@vger.kernel.org"
	<platform-driver-x86@vger.kernel.org>
Return-path: <linux-acpi-owner@vger.kernel.org>
Content-Language: ja-JP
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This patch adds implementation for ethtool support.

Signed-off-by: Taku Izumi <izumi.taku@jp.fujitsu.com>
---
 drivers/platform/x86/fjes/Makefile       |   2 +-
 drivers/platform/x86/fjes/fjes.h         |   2 +
 drivers/platform/x86/fjes/fjes_ethtool.c | 135 +++++++++++++++++++++++++++++++
 drivers/platform/x86/fjes/fjes_main.c    |   1 +
 4 files changed, 139 insertions(+), 1 deletion(-)
 create mode 100644 drivers/platform/x86/fjes/fjes_ethtool.c

diff --git a/drivers/platform/x86/fjes/Makefile b/drivers/platform/x86/fjes/Makefile
index a67f65d8..8ca4de0 100644
--- a/drivers/platform/x86/fjes/Makefile
+++ b/drivers/platform/x86/fjes/Makefile
@@ -27,5 +27,5 @@
 
 obj-$(CONFIG_FUJITSU_ES) += fjes.o
 
-fjes-objs := fjes_main.o fjes_hw.o
+fjes-objs := fjes_main.o fjes_hw.o fjes_ethtool.o
 
diff --git a/drivers/platform/x86/fjes/fjes.h b/drivers/platform/x86/fjes/fjes.h
index c056fc4..240c2ec 100644
--- a/drivers/platform/x86/fjes/fjes.h
+++ b/drivers/platform/x86/fjes/fjes.h
@@ -80,4 +80,6 @@ extern char fjes_driver_name[];
 extern char fjes_driver_version[];
 extern u32 fjes_support_mtu[];
 
+void fjes_set_ethtool_ops(struct net_device *);
+
 #endif /* FJES_H_ */
diff --git a/drivers/platform/x86/fjes/fjes_ethtool.c b/drivers/platform/x86/fjes/fjes_ethtool.c
new file mode 100644
index 0000000..49974d2
--- /dev/null
+++ b/drivers/platform/x86/fjes/fjes_ethtool.c
@@ -0,0 +1,135 @@
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
+
+#include "fjes.h"
+
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
+		struct ethtool_stats *stats, u64 *data)
+{
+	struct fjes_adapter *adapter = netdev_priv(netdev);
+	int i;
+	char *p = NULL;
+
+	for (i = 0; i < ARRAY_SIZE(fjes_gstrings_stats); i++) {
+		p = (char *)adapter + fjes_gstrings_stats[i].stat_offset;
+		data[i] = (fjes_gstrings_stats[i].sizeof_stat == sizeof(u64))
+			? *(u64 *)p : *(u32 *)p;
+	}
+}
+
+static void fjes_get_strings(struct net_device *netdev,
+		u32 stringset, u8 *data)
+{
+	u8 *p = data;
+	int i;
+
+	switch (stringset) {
+	case ETH_SS_STATS:
+		for (i = 0; i < ARRAY_SIZE(fjes_gstrings_stats); i++) {
+			memcpy(p, fjes_gstrings_stats[i].stat_string,
+				ETH_GSTRING_LEN);
+			p += ETH_GSTRING_LEN;
+		}
+		break;
+	}
+}
+
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
+		struct ethtool_drvinfo *drvinfo)
+{
+	strlcpy(drvinfo->driver, fjes_driver_name, sizeof(drvinfo->driver));
+	strlcpy(drvinfo->version, fjes_driver_version,
+			sizeof(drvinfo->version));
+
+	strlcpy(drvinfo->fw_version, "none", sizeof(drvinfo->fw_version));
+	strlcpy(drvinfo->bus_info, "none", sizeof(drvinfo->bus_info));
+	drvinfo->regdump_len = 0;
+	drvinfo->eedump_len = 0;
+
+}
+
+
+static int fjes_get_settings(struct net_device *netdev,
+		struct ethtool_cmd *ecmd)
+{
+	ecmd->supported = 0;
+	ecmd->advertising = 0;
+	ecmd->duplex = DUPLEX_FULL;
+	ecmd->autoneg = AUTONEG_DISABLE;
+	ecmd->transceiver = XCVR_DUMMY1;
+	ecmd->port = PORT_NONE;
+	ethtool_cmd_speed_set(ecmd, 20000);	/* 20Gb/s */
+	return 0;
+}
+
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
diff --git a/drivers/platform/x86/fjes/fjes_main.c b/drivers/platform/x86/fjes/fjes_main.c
index 0bf8efc..1df1715 100644
--- a/drivers/platform/x86/fjes/fjes_main.c
+++ b/drivers/platform/x86/fjes/fjes_main.c
@@ -1215,6 +1215,7 @@ static void fjes_netdev_setup(struct net_device *netdev)
 
 	netdev->watchdog_timeo = FJES_TX_RETRY_INTERVAL;
 	netdev->netdev_ops = &fjes_netdev_ops;
+	fjes_set_ethtool_ops(netdev);
 	netdev->mtu = fjes_support_mtu[0];
 	netdev->flags |= IFF_BROADCAST;
 	netdev->features |= NETIF_F_HW_CSUM | NETIF_F_HW_VLAN_CTAG_FILTER;
-- 
1.8.3.1
