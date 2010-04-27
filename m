From: Dimitris Michailidis <dm@chelsio.com>
Subject: [PATCH net-next 1/2] cxgb4: parse the VPD instead of relying on a static VPD layout
Date: Tue, 27 Apr 2010 15:24:15 -0700
Message-ID: <1272407056-11699-1-git-send-email-dm@chelsio.com>
Cc: Dimitris Michailidis <dm@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:13760 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757352Ab0D0W3t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Apr 2010 18:29:49 -0400
Received: from maui.asicdesigners.com (maui.asicdesigners.com [10.192.180.15])
	by stargate.chelsio.com (8.13.1/8.13.1) with SMTP id o3RMToWG003264
	for <netdev@vger.kernel.org>; Tue, 27 Apr 2010 15:29:50 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some boards' VPDs contain additional keywords or have longer serial numbers,
meaning the keyword locations are variable.  Ditch the static layout and
use the pci_vpd_* family of functions to parse the VPD instead.

Signed-off-by: Dimitris Michailidis <dm@chelsio.com>
---
 drivers/net/cxgb4/t4_hw.c |   64 +++++++++++++++++++++++++++-----------------
 1 files changed, 39 insertions(+), 25 deletions(-)

diff --git a/drivers/net/cxgb4/t4_hw.c b/drivers/net/cxgb4/t4_hw.c
index cadead5..2923dd4 100644
--- a/drivers/net/cxgb4/t4_hw.c
+++ b/drivers/net/cxgb4/t4_hw.c
@@ -347,33 +347,21 @@ int t4_edc_read(struct adapter *adap, int idx, u32 addr, __be32 *data, u64 *ecc)
 	return 0;
 }
 
-#define VPD_ENTRY(name, len) \
-	u8 name##_kword[2]; u8 name##_len; u8 name##_data[len]
-
 /*
  * Partial EEPROM Vital Product Data structure.  Includes only the ID and
- * VPD-R sections.
+ * VPD-R header.
  */
-struct t4_vpd {
+struct t4_vpd_hdr {
 	u8  id_tag;
 	u8  id_len[2];
 	u8  id_data[ID_LEN];
 	u8  vpdr_tag;
 	u8  vpdr_len[2];
-	VPD_ENTRY(pn, 16);                     /* part number */
-	VPD_ENTRY(ec, EC_LEN);                 /* EC level */
-	VPD_ENTRY(sn, SERNUM_LEN);             /* serial number */
-	VPD_ENTRY(na, 12);                     /* MAC address base */
-	VPD_ENTRY(port_type, 8);               /* port types */
-	VPD_ENTRY(gpio, 14);                   /* GPIO usage */
-	VPD_ENTRY(cclk, 6);                    /* core clock */
-	VPD_ENTRY(port_addr, 8);               /* port MDIO addresses */
-	VPD_ENTRY(rv, 1);                      /* csum */
-	u32 pad;                  /* for multiple-of-4 sizing and alignment */
 };
 
 #define EEPROM_STAT_ADDR   0x7bfc
 #define VPD_BASE           0
+#define VPD_LEN            512
 
 /**
  *	t4_seeprom_wp - enable/disable EEPROM write protection
@@ -398,16 +386,36 @@ int t4_seeprom_wp(struct adapter *adapter, bool enable)
  */
 static int get_vpd_params(struct adapter *adapter, struct vpd_params *p)
 {
-	int ret;
-	struct t4_vpd vpd;
-	u8 *q = (u8 *)&vpd, csum;
+	int i, ret;
+	int ec, sn, v2;
+	u8 vpd[VPD_LEN], csum;
+	unsigned int vpdr_len;
+	const struct t4_vpd_hdr *v;
 
-	ret = pci_read_vpd(adapter->pdev, VPD_BASE, sizeof(vpd), &vpd);
+	ret = pci_read_vpd(adapter->pdev, VPD_BASE, sizeof(vpd), vpd);
 	if (ret < 0)
 		return ret;
 
-	for (csum = 0; q <= vpd.rv_data; q++)
-		csum += *q;
+	v = (const struct t4_vpd_hdr *)vpd;
+	vpdr_len = pci_vpd_lrdt_size(&v->vpdr_tag);
+	if (vpdr_len + sizeof(struct t4_vpd_hdr) > VPD_LEN) {
+		dev_err(adapter->pdev_dev, "bad VPD-R length %u\n", vpdr_len);
+		return -EINVAL;
+	}
+
+#define FIND_VPD_KW(var, name) do { \
+	var = pci_vpd_find_info_keyword(&v->id_tag, sizeof(struct t4_vpd_hdr), \
+					vpdr_len, name); \
+	if (var < 0) { \
+		dev_err(adapter->pdev_dev, "missing VPD keyword " name "\n"); \
+		return -EINVAL; \
+	} \
+	var += PCI_VPD_INFO_FLD_HDR_SIZE; \
+} while (0)
+
+	FIND_VPD_KW(i, "RV");
+	for (csum = 0; i >= 0; i--)
+		csum += vpd[i];
 
 	if (csum) {
 		dev_err(adapter->pdev_dev,
@@ -415,12 +423,18 @@ static int get_vpd_params(struct adapter *adapter, struct vpd_params *p)
 		return -EINVAL;
 	}
 
-	p->cclk = simple_strtoul(vpd.cclk_data, NULL, 10);
-	memcpy(p->id, vpd.id_data, sizeof(vpd.id_data));
+	FIND_VPD_KW(ec, "EC");
+	FIND_VPD_KW(sn, "SN");
+	FIND_VPD_KW(v2, "V2");
+#undef FIND_VPD_KW
+
+	p->cclk = simple_strtoul(vpd + v2, NULL, 10);
+	memcpy(p->id, v->id_data, ID_LEN);
 	strim(p->id);
-	memcpy(p->ec, vpd.ec_data, sizeof(vpd.ec_data));
+	memcpy(p->ec, vpd + ec, EC_LEN);
 	strim(p->ec);
-	memcpy(p->sn, vpd.sn_data, sizeof(vpd.sn_data));
+	i = pci_vpd_info_field_size(vpd + sn - PCI_VPD_INFO_FLD_HDR_SIZE);
+	memcpy(p->sn, vpd + sn, min(i, SERNUM_LEN));
 	strim(p->sn);
 	return 0;
 }
-- 
1.5.4

