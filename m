From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH] ethtool: Support passing the PHY info through get_drvinfo
Date: Tue, 17 Nov 2009 08:17:48 -0800
Message-ID: <20091117161748.11411.74316.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org, davem@davemloft.net, shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta08.westchester.pa.mail.comcast.net ([76.96.62.80]:49884
	"EHLO QMTA08.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751986AbZKQQSH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2009 11:18:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>

This allows drivers to provide a PHY type to dump_drvinfo when
ethtool -i ethX is executed.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 ethtool-copy.h |   25 ++++++++++++++++++++++++-
 ethtool.c      |   30 ++++++++++++++++++++++++++++--
 2 files changed, 52 insertions(+), 3 deletions(-)

diff --git a/ethtool-copy.h b/ethtool-copy.h
index 3ca4e2c..db29c5a 100644
--- a/ethtool-copy.h
+++ b/ethtool-copy.h
@@ -53,7 +53,8 @@ struct ethtool_drvinfo {
 	char	bus_info[ETHTOOL_BUSINFO_LEN];	/* Bus info for this IF. */
 				/* For PCI devices, use pci_name(pci_dev). */
 	char	reserved1[32];
-	char	reserved2[12];
+	char	reserved2[11];
+	__u8	phy_type;	/* PHY type present on the NIC */
 	__u32	n_priv_flags;	/* number of flags valid in ETHTOOL_GPFLAGS */
 	__u32	n_stats;	/* number of u64's from ETHTOOL_GSTATS */
 	__u32	testinfo_len;
@@ -285,6 +286,28 @@ enum ethtool_flags {
 	ETH_FLAG_LRO		= (1 << 15),	/* LRO is enabled */
 };
 
+/*
+ * PHY types supported
+ *
+ * 0   - No PHY specified
+ * 1   - SFP/SFP+ Fiber (SR and LR)
+ * 2   - XFP Fiber (SR and LR)
+ * 3   - SFP+ Direct Attach (TwinAX)
+ * 4   - BASE-T (RJ-45)
+ * MAX - PHY not present
+ */
+enum ethtool_phy_type {
+	ETH_PHY_UNSPECIFIED = 0,
+	ETH_PHY_SFP_FIBER,
+	ETH_PHY_XFP_FIBER,
+	ETH_PHY_DA_TWINAX,
+	ETH_PHY_BASE_T,
+
+	/* This must be the last entry */
+	ETH_PHY_NOT_PRESENT,
+};
+#define ETH_MAX_PHY_STR_LEN 32
+
 struct ethtool_rxnfc {
 	__u32		cmd;
 	__u32		flow_type;
diff --git a/ethtool.c b/ethtool.c
index 0110682..8baa429 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -969,15 +969,41 @@ static int dump_ecmd(struct ethtool_cmd *ep)
 
 static int dump_drvinfo(struct ethtool_drvinfo *info)
 {
+	char phy_type[ETH_MAX_PHY_STR_LEN];
+
+	switch (info->phy_type) {
+	case ETH_PHY_NOT_PRESENT:
+		sprintf(phy_type, "PHY not present");
+		break;
+	case ETH_PHY_SFP_FIBER:
+		sprintf(phy_type, "SFP/SFP+ Fiber (SR/LR)");
+		break;
+	case ETH_PHY_XFP_FIBER:
+		sprintf(phy_type, "XFP Fiber (SR/LR)");
+		break;
+	case ETH_PHY_DA_TWINAX:
+		sprintf(phy_type, "SFP+ DA TwinAX");
+		break;
+	case ETH_PHY_BASE_T:
+		sprintf(phy_type, "BASE-T Copper");
+		break;
+	case ETH_PHY_UNSPECIFIED:
+	default:
+		sprintf(phy_type, "PHY unspecified");
+		break;
+	};
+
 	fprintf(stdout,
 		"driver: %s\n"
 		"version: %s\n"
 		"firmware-version: %s\n"
-		"bus-info: %s\n",
+		"bus-info: %s\n"
+		"phy-type: %s\n",
 		info->driver,
 		info->version,
 		info->fw_version,
-		info->bus_info);
+		info->bus_info,
+		phy_type);
 
 	return 0;
 }

