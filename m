From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 2/3] cxgb4: Add support in cxgb4 to get expansion rom version via ethtool
Date: Wed,  4 Feb 2015 18:19:35 +0530
Message-ID: <1423054176-26420-3-git-send-email-hariprasad@chelsio.com>
References: <1423054176-26420-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, ben@decadent.org.uk, leedom@chelsio.com,
	anish@chelsio.com, nirranjan@chelsio.com, kumaras@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:4797 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S933842AbbBDMoO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2015 07:44:14 -0500
In-Reply-To: <1423054176-26420-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support to get option/expansion rom version flashed in the adapter via
ethtool getdrvinfo function.

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h      |    1 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |    9 +++++
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c      |   37 +++++++++++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h   |    8 +++++
 4 files changed, 55 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index 55019c9..63231bf 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -1120,6 +1120,7 @@ int t4_fw_upgrade(struct adapter *adap, unsigned int mbox,
 unsigned int t4_flash_cfg_addr(struct adapter *adapter);
 int t4_get_fw_version(struct adapter *adapter, u32 *vers);
 int t4_get_tp_version(struct adapter *adapter, u32 *vers);
+int t4_get_exprom_version(struct adapter *adapter, u32 *vers);
 int t4_prep_fw(struct adapter *adap, struct fw_info *fw_info,
 	       const u8 *fw_data, unsigned int fw_size,
 	       struct fw_hdr *card_fw, enum dev_state state, int *reset);
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 041742b..16639c7 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -1419,6 +1419,7 @@ static int get_eeprom_len(struct net_device *dev)
 static void get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
 {
 	struct adapter *adapter = netdev2adap(dev);
+	u32 exprom_vers;
 
 	strlcpy(info->driver, KBUILD_MODNAME, sizeof(info->driver));
 	strlcpy(info->version, DRV_VERSION, sizeof(info->version));
@@ -1436,6 +1437,14 @@ static void get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
 			FW_HDR_FW_VER_MINOR_G(adapter->params.tp_vers),
 			FW_HDR_FW_VER_MICRO_G(adapter->params.tp_vers),
 			FW_HDR_FW_VER_BUILD_G(adapter->params.tp_vers));
+
+	if (!t4_get_exprom_version(adapter, &exprom_vers))
+		snprintf(info->erom_version, sizeof(info->erom_version),
+			 "%u.%u.%u.%u",
+			 FW_HDR_FW_VER_MAJOR_G(exprom_vers),
+			 FW_HDR_FW_VER_MINOR_G(exprom_vers),
+			 FW_HDR_FW_VER_MICRO_G(exprom_vers),
+			 FW_HDR_FW_VER_BUILD_G(exprom_vers));
 }
 
 static void get_strings(struct net_device *dev, u32 stringset, u8 *data)
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index ea16c62..ae69796 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -948,6 +948,43 @@ int t4_get_tp_version(struct adapter *adapter, u32 *vers)
 			     1, vers, 0);
 }
 
+/**
+ *	t4_get_exprom_version - return the Expansion ROM version (if any)
+ *	@adapter: the adapter
+ *	@vers: where to place the version
+ *
+ *	Reads the Expansion ROM header from FLASH and returns the version
+ *	number (if present) through the @vers return value pointer.  We return
+ *	this in the Firmware Version Format since it's convenient.  Return
+ *	0 on success, -ENOENT if no Expansion ROM is present.
+ */
+int t4_get_exprom_version(struct adapter *adap, u32 *vers)
+{
+	struct exprom_header {
+		unsigned char hdr_arr[16];	/* must start with 0x55aa */
+		unsigned char hdr_ver[4];	/* Expansion ROM version */
+	} *hdr;
+	u32 exprom_header_buf[DIV_ROUND_UP(sizeof(struct exprom_header),
+					   sizeof(u32))];
+	int ret;
+
+	ret = t4_read_flash(adap, FLASH_EXP_ROM_START,
+			    ARRAY_SIZE(exprom_header_buf), exprom_header_buf,
+			    0);
+	if (ret)
+		return ret;
+
+	hdr = (struct exprom_header *)exprom_header_buf;
+	if (hdr->hdr_arr[0] != 0x55 || hdr->hdr_arr[1] != 0xaa)
+		return -ENOENT;
+
+	*vers = (FW_HDR_FW_VER_MAJOR_V(hdr->hdr_ver[0]) |
+		 FW_HDR_FW_VER_MINOR_V(hdr->hdr_ver[1]) |
+		 FW_HDR_FW_VER_MICRO_V(hdr->hdr_ver[2]) |
+		 FW_HDR_FW_VER_BUILD_V(hdr->hdr_ver[3]));
+	return 0;
+}
+
 /* Is the given firmware API compatible with the one the driver was compiled
  * with?
  */
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h b/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
index 1e72cda..c009627 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
@@ -3012,21 +3012,29 @@ enum fw_hdr_chip {
 
 #define FW_HDR_FW_VER_MAJOR_S	24
 #define FW_HDR_FW_VER_MAJOR_M	0xff
+#define FW_HDR_FW_VER_MAJOR_V(x) \
+	((x) << FW_HDR_FW_VER_MAJOR_S)
 #define FW_HDR_FW_VER_MAJOR_G(x) \
 	(((x) >> FW_HDR_FW_VER_MAJOR_S) & FW_HDR_FW_VER_MAJOR_M)
 
 #define FW_HDR_FW_VER_MINOR_S	16
 #define FW_HDR_FW_VER_MINOR_M	0xff
+#define FW_HDR_FW_VER_MINOR_V(x) \
+	((x) << FW_HDR_FW_VER_MINOR_S)
 #define FW_HDR_FW_VER_MINOR_G(x) \
 	(((x) >> FW_HDR_FW_VER_MINOR_S) & FW_HDR_FW_VER_MINOR_M)
 
 #define FW_HDR_FW_VER_MICRO_S	8
 #define FW_HDR_FW_VER_MICRO_M	0xff
+#define FW_HDR_FW_VER_MICRO_V(x) \
+	((x) << FW_HDR_FW_VER_MICRO_S)
 #define FW_HDR_FW_VER_MICRO_G(x) \
 	(((x) >> FW_HDR_FW_VER_MICRO_S) & FW_HDR_FW_VER_MICRO_M)
 
 #define FW_HDR_FW_VER_BUILD_S	0
 #define FW_HDR_FW_VER_BUILD_M	0xff
+#define FW_HDR_FW_VER_BUILD_V(x) \
+	((x) << FW_HDR_FW_VER_BUILD_S)
 #define FW_HDR_FW_VER_BUILD_G(x) \
 	(((x) >> FW_HDR_FW_VER_BUILD_S) & FW_HDR_FW_VER_BUILD_M)
 
-- 
1.7.1
