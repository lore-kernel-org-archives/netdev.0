From: Alexander Loktionov <Alexander.Loktionov@aquantia.com>
Subject: [PATCH v5 11/13] net: ethernet: aquantia: Ethtool support
Date: Thu, 12 Jan 2017 21:02:27 -0800
Message-ID: <b2236a13fcf9ac65f15cfc084de670948517e003.1484283610.git.vomlehn@texas.net>
References: <cover.1484283610.git.vomlehn@texas.net>
Cc: "David S . Miller" <davem@davemloft.net>,
        Simon Edelhaus <Simon.Edelhaus@aquantia.com>,
        Alexander Loktionov <Alexander.Loktionov@aquantia.com>,
        Dmitrii Tarakanov <Dmitrii.Tarakanov@aquantia.com>,
        Pavel Belous <Pavel.Belous@aquantia.com>,
        Dmitry Bezrukov <Dmitry.Bezrukov@aquantia.com>
To: netdev@vger.kernel.org, David VomLehn <vomlehn@texas.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda1.aus1.datafoundry.com ([209.99.124.132]:53715 "EHLO
        milter.aus.datafoundry.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1750749AbdAMFD3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2017 00:03:29 -0500
In-Reply-To: <cover.1484283610.git.vomlehn@texas.net>
In-Reply-To: <bd4244af243c5800bd08cfe6c3859f1b406089be.1484283610.git.vomlehn@texas.net>
References: <cover.1484283610.git.vomlehn@texas.net> <fe1664e502d28bcb6a5689787b8000e6c9288307.1484283610.git.vomlehn@texas.net> <2c056fd544958594f6356a17892c251ea26ea8c8.1484283610.git.vomlehn@texas.net> <98a7a3c6800c246753ef6cfaa5982a348da757c8.1484283610.git.vomlehn@texas.net> <29b795c8c4fc8de7925e82e071e5feaa266cd801.1484283610.git.vomlehn@texas.net> <5e87af3b0effb96698d0c085366b1ba9320a6305.1484283610.git.vomlehn@texas.net> <e17f53f9485f69edafa966d2bcbaa4b9fd7c145f.1484283610.git.vomlehn@texas.net> <e3f7eda0cc3bfa3426932c39465971ba4c6226ef.1484283610.git.vomlehn@texas.net> <2889e8e87b8b89945f34e57a7f8ca253f204de47.1484283610.git.vomlehn@texas.net> <fef6ab77998a2914f94549367b88ab31e1f734e7.1484283610.git.vomlehn@texas.net> <bd4244af243c5800bd08cfe6c3859f1b406089be.1484283610.git.vomleh
 n@texas.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David VomLehn <vomlehn@texas.net>

Add the driver interfaces required for support by the ethtool utility.

Signed-off-by: Alexander Loktionov <Alexander.Loktionov@aquantia.com>
Signed-off-by: Dmitrii Tarakanov <Dmitrii.Tarakanov@aquantia.com>
Signed-off-by: Pavel Belous <Pavel.Belous@aquantia.com>
Signed-off-by: Dmitry Bezrukov <Dmitry.Bezrukov@aquantia.com>
Signed-off-by: David M. VomLehn <vomlehn@texas.net>
---
 drivers/net/ethernet/aquantia/aq_ethtool.c | 250 +++++++++++++++++++++++++++++
 drivers/net/ethernet/aquantia/aq_ethtool.h |  19 +++
 2 files changed, 269 insertions(+)
 create mode 100644 drivers/net/ethernet/aquantia/aq_ethtool.c
 create mode 100644 drivers/net/ethernet/aquantia/aq_ethtool.h

diff --git a/drivers/net/ethernet/aquantia/aq_ethtool.c b/drivers/net/ethernet/aquantia/aq_ethtool.c
new file mode 100644
index 0000000..f11bdb1
--- /dev/null
+++ b/drivers/net/ethernet/aquantia/aq_ethtool.c
@@ -0,0 +1,250 @@
+/*
+ * aQuantia Corporation Network Driver
+ * Copyright (C) 2014-2017 aQuantia Corporation. All rights reserved
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ */
+
+/* File aq_ethtool.c: Definition of ethertool related functions. */
+
+#include "aq_ethtool.h"
+#include "aq_nic.h"
+
+static void aq_ethtool_get_regs(struct net_device *ndev,
+				struct ethtool_regs *regs, void *p)
+{
+	struct aq_nic_s *aq_nic = (struct aq_nic_s *)netdev_priv(ndev);
+	u32 regs_count = aq_nic_get_regs_count(aq_nic);
+
+	memset(p, 0, regs_count * sizeof(u32));
+	aq_nic_get_regs(aq_nic, regs, p);
+}
+
+static int aq_ethtool_get_regs_len(struct net_device *ndev)
+{
+	struct aq_nic_s *aq_nic = (struct aq_nic_s *)netdev_priv(ndev);
+	u32 regs_count = aq_nic_get_regs_count(aq_nic);
+
+	return regs_count * sizeof(u32);
+}
+
+static u32 aq_ethtool_get_link(struct net_device *ndev)
+{
+	struct aq_nic_s *aq_nic = (struct aq_nic_s *)netdev_priv(ndev);
+
+	return aq_nic_get_link_speed(aq_nic) ? 1U : 0U;
+}
+
+static int aq_ethtool_get_settings(struct net_device *ndev,
+				   struct ethtool_cmd *cmd)
+{
+	struct aq_nic_s *aq_nic = (struct aq_nic_s *)netdev_priv(ndev);
+
+	cmd->port = PORT_TP;
+	cmd->transceiver = XCVR_EXTERNAL;
+
+	ethtool_cmd_speed_set(cmd, netif_carrier_ok(ndev) ?
+				aq_nic_get_link_speed(aq_nic) : 0U);
+
+	cmd->duplex = DUPLEX_FULL;
+	aq_nic_get_link_settings(aq_nic, cmd);
+	return 0;
+}
+
+static int aq_ethtool_set_settings(struct net_device *ndev,
+				   struct ethtool_cmd *cmd)
+{
+	struct aq_nic_s *aq_nic = (struct aq_nic_s *)netdev_priv(ndev);
+
+	return aq_nic_set_link_settings(aq_nic, cmd);
+}
+
+static const char aq_ethtool_stat_names[][ETH_GSTRING_LEN] = {
+	"InPackets",
+	"InUCast",
+	"InMCast",
+	"InBCast",
+	"InErrors",
+	"OutPackets",
+	"OutUCast",
+	"OutMCast",
+	"OutBCast",
+	"InUCastOctects",
+	"OutUCastOctects",
+	"InMCastOctects",
+	"OutMCastOctects",
+	"InBCastOctects",
+	"OutBCastOctects",
+	"InOctects",
+	"OutOctects",
+	"InPacketsDma",
+	"OutPacketsDma",
+	"InOctetsDma",
+	"OutOctetsDma",
+	"InDroppedDma",
+	"Queue[0] InPackets",
+	"Queue[0] OutPackets",
+	"Queue[0] InJumboPackets",
+	"Queue[0] InLroPackets",
+	"Queue[0] InErrors",
+#if 1 < AQ_CFG_VECS_DEF
+	"Queue[1] InPackets",
+	"Queue[1] OutPackets",
+	"Queue[1] InJumboPackets",
+	"Queue[1] InLroPackets",
+	"Queue[1] InErrors",
+#endif
+#if 2 < AQ_CFG_VECS_DEF
+	"Queue[2] InPackets",
+	"Queue[2] OutPackets",
+	"Queue[2] InJumboPackets",
+	"Queue[2] InLroPackets",
+	"Queue[2] InErrors",
+#endif
+#if 3 < AQ_CFG_VECS_DEF
+	"Queue[3] InPackets",
+	"Queue[3] OutPackets",
+	"Queue[3] InJumboPackets",
+	"Queue[3] InLroPackets",
+	"Queue[3] InErrors",
+#endif
+#if 4 < AQ_CFG_VECS_DEF
+	"Queue[4] InPackets",
+	"Queue[4] OutPackets",
+	"Queue[4] InJumboPackets",
+	"Queue[4] InLroPackets",
+	"Queue[4] InErrors",
+#endif
+#if 5 < AQ_CFG_VECS_DEF
+	"Queue[5] InPackets",
+	"Queue[5] OutPackets",
+	"Queue[5] InJumboPackets",
+	"Queue[5] InLroPackets",
+	"Queue[5] InErrors",
+#endif
+#if 6 < AQ_CFG_VECS_DEF
+	"Queue[6] InPackets",
+	"Queue[6] OutPackets",
+	"Queue[6] InJumboPackets",
+	"Queue[6] InLroPackets",
+	"Queue[6] InErrors",
+#endif
+#if 7 < AQ_CFG_VECS_DEF
+	"Queue[7] InPackets",
+	"Queue[7] OutPackets",
+	"Queue[7] InJumboPackets",
+	"Queue[7] InLroPackets",
+	"Queue[7] InErrors",
+#endif
+};
+
+static void aq_ethtool_stats(struct net_device *ndev,
+			     struct ethtool_stats *stats, u64 *data)
+{
+	struct aq_nic_s *aq_nic = (struct aq_nic_s *)netdev_priv(ndev);
+
+	memset(data, 0, ARRAY_SIZE(aq_ethtool_stat_names) * sizeof(u64));
+	aq_nic_get_stats(aq_nic, data);
+}
+
+static void aq_ethtool_get_drvinfo(struct net_device *ndev,
+				   struct ethtool_drvinfo *drvinfo)
+{
+	struct aq_nic_s *aq_nic = (struct aq_nic_s *)netdev_priv(ndev);
+	u32 firmware_version = aq_nic_get_fw_version(aq_nic);
+	u32 regs_count = aq_nic_get_regs_count(aq_nic);
+
+	strlcat(drvinfo->driver, AQ_CFG_DRV_NAME, sizeof(drvinfo->driver));
+	strlcat(drvinfo->version, AQ_CFG_DRV_VERSION, sizeof(drvinfo->version));
+
+	snprintf(drvinfo->fw_version, sizeof(drvinfo->fw_version),
+		 "%u.%u.%u", firmware_version >> 24,
+		 (firmware_version >> 16) & 0xFFU, firmware_version & 0xFFFFU);
+
+	drvinfo->n_stats = ARRAY_SIZE(aq_ethtool_stat_names);
+	drvinfo->testinfo_len = 0;
+	drvinfo->regdump_len = regs_count;
+	drvinfo->eedump_len = 0;
+}
+
+static void aq_ethtool_get_strings(struct net_device *ndev,
+				   u32 stringset, u8 *data)
+{
+	memcpy(data, *aq_ethtool_stat_names, sizeof(aq_ethtool_stat_names));
+}
+
+static int aq_ethtool_get_sset_count(struct net_device *ndev, int stringset)
+{
+	return ARRAY_SIZE(aq_ethtool_stat_names);
+}
+
+static u32 aq_ethtool_get_rss_indir_size(struct net_device *ndev)
+{
+	return AQ_CFG_RSS_INDIRECTION_TABLE_MAX;
+}
+
+static u32 aq_ethtool_get_rss_key_size(struct net_device *ndev)
+{
+	struct aq_nic_s *aq_nic = (struct aq_nic_s *)netdev_priv(ndev);
+	struct aq_nic_cfg_s *cfg = aq_nic_get_cfg(aq_nic);
+
+	return sizeof(cfg->aq_rss.hash_secret_key);
+}
+
+static int aq_ethtool_get_rss(struct net_device *ndev, u32 *indir, u8 *key,
+			      u8 *hfunc)
+{
+	struct aq_nic_s *aq_nic = (struct aq_nic_s *)netdev_priv(ndev);
+	struct aq_nic_cfg_s *cfg = aq_nic_get_cfg(aq_nic);
+	unsigned int i = 0U;
+
+	if (hfunc)
+		*hfunc = ETH_RSS_HASH_TOP; /* Toeplitz */
+	if (indir) {
+		for (i = 0; i < AQ_CFG_RSS_INDIRECTION_TABLE_MAX; i++)
+			indir[i] = cfg->aq_rss.indirection_table[i];
+	}
+	if (key)
+		memcpy(key, cfg->aq_rss.hash_secret_key,
+		       sizeof(cfg->aq_rss.hash_secret_key));
+	return 0;
+}
+
+static int aq_ethtool_get_rxnfc(struct net_device *ndev,
+				struct ethtool_rxnfc *cmd, u32 *rule_locs)
+
+{
+	struct aq_nic_s *aq_nic = (struct aq_nic_s *)netdev_priv(ndev);
+	struct aq_nic_cfg_s *cfg = aq_nic_get_cfg(aq_nic);
+	int err = -EOPNOTSUPP;
+
+	switch (cmd->cmd) {
+	case ETHTOOL_GRXRINGS:
+		cmd->data = cfg->vecs;
+		err = 0;
+		break;
+
+	default:
+		break;
+	}
+
+	return err;
+}
+
+const struct ethtool_ops aq_ethtool_ops = {
+	.get_link            = aq_ethtool_get_link,
+	.get_regs_len        = aq_ethtool_get_regs_len,
+	.get_regs            = aq_ethtool_get_regs,
+	.get_settings        = aq_ethtool_get_settings,
+	.set_settings        = aq_ethtool_set_settings,
+	.get_drvinfo         = aq_ethtool_get_drvinfo,
+	.get_strings         = aq_ethtool_get_strings,
+	.get_rxfh_indir_size = aq_ethtool_get_rss_indir_size,
+	.get_rxfh_key_size   = aq_ethtool_get_rss_key_size,
+	.get_rxfh            = aq_ethtool_get_rss,
+	.get_rxnfc           = aq_ethtool_get_rxnfc,
+	.get_sset_count      = aq_ethtool_get_sset_count,
+	.get_ethtool_stats   = aq_ethtool_stats
+};
diff --git a/drivers/net/ethernet/aquantia/aq_ethtool.h b/drivers/net/ethernet/aquantia/aq_ethtool.h
new file mode 100644
index 0000000..21c126e
--- /dev/null
+++ b/drivers/net/ethernet/aquantia/aq_ethtool.h
@@ -0,0 +1,19 @@
+/*
+ * aQuantia Corporation Network Driver
+ * Copyright (C) 2014-2017 aQuantia Corporation. All rights reserved
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ */
+
+/* File aq_ethtool.h: Declaration of ethertool related functions. */
+
+#ifndef AQ_ETHTOOL_H
+#define AQ_ETHTOOL_H
+
+#include "aq_common.h"
+
+extern const struct ethtool_ops aq_ethtool_ops;
+
+#endif /* AQ_ETHTOOL_H */
-- 
2.7.4
