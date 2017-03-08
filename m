From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 2/9] nfp: add support for reporting CRC32 hash function
Date: Wed,  8 Mar 2017 08:57:01 -0800
Message-ID: <20170308165708.96087-3-jakub.kicinski@netronome.com>
References: <20170308165708.96087-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f50.google.com ([74.125.83.50]:36029 "EHLO
        mail-pg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753073AbdCHQ7E (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Mar 2017 11:59:04 -0500
Received: by mail-pg0-f50.google.com with SMTP id 187so15170546pgb.3
        for <netdev@vger.kernel.org>; Wed, 08 Mar 2017 08:58:10 -0800 (PST)
In-Reply-To: <20170308165708.96087-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some firmware images may reuse CRC32 hardware to compute RXHASH.
Make sure we report the correct hash function.  Note that we don't
support changing functions at runtime.  That would also require
a few more additions to the way the key is set because different
functions have different key sizes.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net.h       |  3 ++
 .../net/ethernet/netronome/nfp/nfp_net_common.c    | 46 ++++++++++++++++++++--
 drivers/net/ethernet/netronome/nfp/nfp_net_ctrl.h  | 14 ++++++-
 .../net/ethernet/netronome/nfp/nfp_net_ethtool.c   | 23 +++++++----
 4 files changed, 75 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net.h b/drivers/net/ethernet/netronome/nfp/nfp_net.h
index e614a376b595..9843e953bbed 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net.h
@@ -446,6 +446,7 @@ struct nfp_stat_pair {
  * @fw_ver:             Firmware version
  * @cap:                Capabilities advertised by the Firmware
  * @max_mtu:            Maximum support MTU advertised by the Firmware
+ * @rss_hfunc:		RSS selected hash function
  * @rss_cfg:            RSS configuration
  * @rss_key:            RSS secret key
  * @rss_itbl:           RSS indirection table
@@ -518,6 +519,7 @@ struct nfp_net {
 	u32 cap;
 	u32 max_mtu;
 
+	u8 rss_hfunc;
 	u32 rss_cfg;
 	u8 rss_key[NFP_NET_CFG_RSS_KEY_SZ];
 	u8 rss_itbl[NFP_NET_CFG_RSS_ITBL_SZ];
@@ -776,6 +778,7 @@ void nfp_net_netdev_clean(struct net_device *netdev);
 void nfp_net_set_ethtool_ops(struct net_device *netdev);
 void nfp_net_info(struct nfp_net *nn);
 int nfp_net_reconfig(struct nfp_net *nn, u32 update);
+unsigned int nfp_net_rss_key_sz(struct nfp_net *nn);
 void nfp_net_rss_write_itbl(struct nfp_net *nn);
 void nfp_net_rss_write_key(struct nfp_net *nn);
 void nfp_net_coalesce_write_cfg(struct nfp_net *nn);
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index 9179a99563af..e72468d65c28 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -41,6 +41,7 @@
  *          Chris Telfer <chris.telfer@netronome.com>
  */
 
+#include <linux/bitfield.h>
 #include <linux/bpf.h>
 #include <linux/bpf_trace.h>
 #include <linux/module.h>
@@ -2045,7 +2046,7 @@ void nfp_net_rss_write_key(struct nfp_net *nn)
 {
 	int i;
 
-	for (i = 0; i < NFP_NET_CFG_RSS_KEY_SZ; i += 4)
+	for (i = 0; i < nfp_net_rss_key_sz(nn); i += 4)
 		nn_writel(nn, NFP_NET_CFG_RSS_KEY + i,
 			  get_unaligned_le32(nn->rss_key + i));
 }
@@ -3112,19 +3113,58 @@ void nfp_net_netdev_free(struct nfp_net *nn)
 }
 
 /**
+ * nfp_net_rss_key_sz() - Get current size of the RSS key
+ * @nn:		NFP Net device instance
+ *
+ * Return: size of the RSS key for currently selected hash function.
+ */
+unsigned int nfp_net_rss_key_sz(struct nfp_net *nn)
+{
+	switch (nn->rss_hfunc) {
+	case ETH_RSS_HASH_TOP:
+		return NFP_NET_CFG_RSS_KEY_SZ;
+	case ETH_RSS_HASH_XOR:
+		return 0;
+	case ETH_RSS_HASH_CRC32:
+		return 4;
+	}
+
+	nn_warn(nn, "Unknown hash function: %u\n", nn->rss_hfunc);
+	return 0;
+}
+
+/**
  * nfp_net_rss_init() - Set the initial RSS parameters
  * @nn:	     NFP Net device to reconfigure
  */
 static void nfp_net_rss_init(struct nfp_net *nn)
 {
-	netdev_rss_key_fill(nn->rss_key, NFP_NET_CFG_RSS_KEY_SZ);
+	unsigned long func_bit, rss_cap_hfunc;
+	u32 reg;
+
+	/* Read the RSS function capability and select first supported func */
+	reg = nn_readl(nn, NFP_NET_CFG_RSS_CAP);
+	rss_cap_hfunc =	FIELD_GET(NFP_NET_CFG_RSS_CAP_HFUNC, reg);
+	if (!rss_cap_hfunc)
+		rss_cap_hfunc =	FIELD_GET(NFP_NET_CFG_RSS_CAP_HFUNC,
+					  NFP_NET_CFG_RSS_TOEPLITZ);
+
+	func_bit = find_first_bit(&rss_cap_hfunc, NFP_NET_CFG_RSS_HFUNCS);
+	if (func_bit == NFP_NET_CFG_RSS_HFUNCS) {
+		dev_warn(&nn->pdev->dev,
+			 "Bad RSS config, defaulting to Toeplitz hash\n");
+		func_bit = ETH_RSS_HASH_TOP_BIT;
+	}
+	nn->rss_hfunc = 1 << func_bit;
+
+	netdev_rss_key_fill(nn->rss_key, nfp_net_rss_key_sz(nn));
 
 	nfp_net_rss_init_itbl(nn);
 
 	/* Enable IPv4/IPv6 TCP by default */
 	nn->rss_cfg = NFP_NET_CFG_RSS_IPV4_TCP |
 		      NFP_NET_CFG_RSS_IPV6_TCP |
-		      NFP_NET_CFG_RSS_TOEPLITZ |
+		      FIELD_PREP(NFP_NET_CFG_RSS_HFUNC, nn->rss_hfunc) |
 		      NFP_NET_CFG_RSS_MASK;
 }
 
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_ctrl.h b/drivers/net/ethernet/netronome/nfp/nfp_net_ctrl.h
index 385ba355c965..71d86171b4ee 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_ctrl.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_ctrl.h
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2015 Netronome Systems, Inc.
+ * Copyright (C) 2015-2017 Netronome Systems, Inc.
  *
  * This software is dual licensed under the GNU General License Version 2,
  * June 1991 as shown in the file COPYING in the top-level directory of this
@@ -192,6 +192,14 @@
 #define NFP_NET_CFG_RX_OFFSET_DYNAMIC		0	/* Prepend mode */
 
 /**
+ * RSS capabilities
+ * @NFP_NET_CFG_RSS_CAP_HFUNC:	supported hash functions (same bits as
+ *				@NFP_NET_CFG_RSS_HFUNC)
+ */
+#define NFP_NET_CFG_RSS_CAP		0x0054
+#define   NFP_NET_CFG_RSS_CAP_HFUNC	  0xff000000
+
+/**
  * VXLAN/UDP encap configuration
  * @NFP_NET_CFG_VXLAN_PORT:	Base address of table of tunnels' UDP dst ports
  * @NFP_NET_CFG_VXLAN_SZ:	Size of the UDP port table in bytes
@@ -249,7 +257,11 @@
 #define   NFP_NET_CFG_RSS_IPV4_UDP        (1 << 11) /* RSS for IPv4/UDP */
 #define   NFP_NET_CFG_RSS_IPV6_TCP        (1 << 12) /* RSS for IPv6/TCP */
 #define   NFP_NET_CFG_RSS_IPV6_UDP        (1 << 13) /* RSS for IPv6/UDP */
+#define   NFP_NET_CFG_RSS_HFUNC		  0xff000000
 #define   NFP_NET_CFG_RSS_TOEPLITZ        (1 << 24) /* Use Toeplitz hash */
+#define   NFP_NET_CFG_RSS_XOR		  (1 << 25) /* Use XOR as hash */
+#define   NFP_NET_CFG_RSS_CRC32		  (1 << 26) /* Use CRC32 as hash */
+#define   NFP_NET_CFG_RSS_HFUNCS	  3
 #define NFP_NET_CFG_RSS_KEY             (NFP_NET_CFG_RSS_BASE + 0x4)
 #define NFP_NET_CFG_RSS_KEY_SZ          0x28
 #define NFP_NET_CFG_RSS_ITBL            (NFP_NET_CFG_RSS_BASE + 0x4 + \
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c b/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
index 2649f7523c81..a1bca2dca0a5 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
@@ -40,6 +40,7 @@
  *          Brad Petrus <brad.petrus@netronome.com>
  */
 
+#include <linux/bitfield.h>
 #include <linux/kernel.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
@@ -454,7 +455,7 @@ static int nfp_net_set_rss_hash_opt(struct nfp_net *nn,
 		return -EINVAL;
 	}
 
-	new_rss_cfg |= NFP_NET_CFG_RSS_TOEPLITZ;
+	new_rss_cfg |= FIELD_PREP(NFP_NET_CFG_RSS_HFUNC, nn->rss_hfunc);
 	new_rss_cfg |= NFP_NET_CFG_RSS_MASK;
 
 	if (new_rss_cfg == nn->rss_cfg)
@@ -496,7 +497,12 @@ static u32 nfp_net_get_rxfh_indir_size(struct net_device *netdev)
 
 static u32 nfp_net_get_rxfh_key_size(struct net_device *netdev)
 {
-	return NFP_NET_CFG_RSS_KEY_SZ;
+	struct nfp_net *nn = netdev_priv(netdev);
+
+	if (!(nn->cap & NFP_NET_CFG_CTRL_RSS))
+		return -EOPNOTSUPP;
+
+	return nfp_net_rss_key_sz(nn);
 }
 
 static int nfp_net_get_rxfh(struct net_device *netdev, u32 *indir, u8 *key,
@@ -512,9 +518,12 @@ static int nfp_net_get_rxfh(struct net_device *netdev, u32 *indir, u8 *key,
 		for (i = 0; i < ARRAY_SIZE(nn->rss_itbl); i++)
 			indir[i] = nn->rss_itbl[i];
 	if (key)
-		memcpy(key, nn->rss_key, NFP_NET_CFG_RSS_KEY_SZ);
-	if (hfunc)
-		*hfunc = ETH_RSS_HASH_TOP;
+		memcpy(key, nn->rss_key, nfp_net_rss_key_sz(nn));
+	if (hfunc) {
+		*hfunc = nn->rss_hfunc;
+		if (*hfunc >= 1 << ETH_RSS_HASH_FUNCS_COUNT)
+			*hfunc = ETH_RSS_HASH_UNKNOWN;
+	}
 
 	return 0;
 }
@@ -527,14 +536,14 @@ static int nfp_net_set_rxfh(struct net_device *netdev,
 	int i;
 
 	if (!(nn->cap & NFP_NET_CFG_CTRL_RSS) ||
-	    !(hfunc == ETH_RSS_HASH_NO_CHANGE || hfunc == ETH_RSS_HASH_TOP))
+	    !(hfunc == ETH_RSS_HASH_NO_CHANGE || hfunc == nn->rss_hfunc))
 		return -EOPNOTSUPP;
 
 	if (!key && !indir)
 		return 0;
 
 	if (key) {
-		memcpy(nn->rss_key, key, NFP_NET_CFG_RSS_KEY_SZ);
+		memcpy(nn->rss_key, key, nfp_net_rss_key_sz(nn));
 		nfp_net_rss_write_key(nn);
 	}
 	if (indir) {
-- 
2.11.0
