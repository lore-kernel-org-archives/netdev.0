From: Dimitris Michailidis <dm@chelsio.com>
Subject: [PATCH 11/12] cxgb4: extend VPD parsing
Date: Tue, 14 Dec 2010 23:36:54 -0800
Message-ID: <1292398615-26527-12-git-send-email-dm@chelsio.com>
References: <1292398615-26527-1-git-send-email-dm@chelsio.com>
 <1292398615-26527-2-git-send-email-dm@chelsio.com>
 <1292398615-26527-3-git-send-email-dm@chelsio.com>
 <1292398615-26527-4-git-send-email-dm@chelsio.com>
 <1292398615-26527-5-git-send-email-dm@chelsio.com>
 <1292398615-26527-6-git-send-email-dm@chelsio.com>
 <1292398615-26527-7-git-send-email-dm@chelsio.com>
 <1292398615-26527-8-git-send-email-dm@chelsio.com>
 <1292398615-26527-9-git-send-email-dm@chelsio.com>
 <1292398615-26527-10-git-send-email-dm@chelsio.com>
 <1292398615-26527-11-git-send-email-dm@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:7449 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754258Ab0LOHpT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Dec 2010 02:45:19 -0500
Received: from maui.asicdesigners.com (maui.asicdesigners.com [10.192.180.15])
	by stargate.chelsio.com (8.13.1/8.13.1) with SMTP id oBF7jICa004129
	for <netdev@vger.kernel.org>; Tue, 14 Dec 2010 23:45:19 -0800
Received: from darkside.asicdesigners.com (localhost.localdomain [127.0.0.1])
	by darkside.asicdesigners.com (8.13.4/8.13.4) with ESMTP id oBF7avBD026617
	for <netdev@vger.kernel.org>; Tue, 14 Dec 2010 23:36:57 -0800
Received: (from dm@localhost)
	by darkside.asicdesigners.com (8.13.4/8.13.4/Submit) id oBF7avle026616
	for netdev@vger.kernel.org; Tue, 14 Dec 2010 23:36:57 -0800
In-Reply-To: <1292398615-26527-11-git-send-email-dm@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Current code parses the VPD RO section for keywords but makes static
assumptions about the location of the section.  Remove them and parse
the VPD to find it.

Signed-off-by: Dimitris Michailidis <dm@chelsio.com>
---
 drivers/net/cxgb4/t4_hw.c |   41 +++++++++++++++++++++--------------------
 1 files changed, 21 insertions(+), 20 deletions(-)

diff --git a/drivers/net/cxgb4/t4_hw.c b/drivers/net/cxgb4/t4_hw.c
index c7fb549..b9fd8a6 100644
--- a/drivers/net/cxgb4/t4_hw.c
+++ b/drivers/net/cxgb4/t4_hw.c
@@ -330,18 +330,6 @@ int t4_edc_read(struct adapter *adap, int idx, u32 addr, __be32 *data, u64 *ecc)
 	return 0;
 }
 
-/*
- * Partial EEPROM Vital Product Data structure.  Includes only the ID and
- * VPD-R header.
- */
-struct t4_vpd_hdr {
-	u8  id_tag;
-	u8  id_len[2];
-	u8  id_data[ID_LEN];
-	u8  vpdr_tag;
-	u8  vpdr_len[2];
-};
-
 #define EEPROM_STAT_ADDR   0x7bfc
 #define VPD_BASE           0
 #define VPD_LEN            512
@@ -372,23 +360,36 @@ static int get_vpd_params(struct adapter *adapter, struct vpd_params *p)
 	int i, ret;
 	int ec, sn;
 	u8 vpd[VPD_LEN], csum;
-	unsigned int vpdr_len;
-	const struct t4_vpd_hdr *v;
+	unsigned int vpdr_len, kw_offset, id_len;
 
 	ret = pci_read_vpd(adapter->pdev, VPD_BASE, sizeof(vpd), vpd);
 	if (ret < 0)
 		return ret;
 
-	v = (const struct t4_vpd_hdr *)vpd;
-	vpdr_len = pci_vpd_lrdt_size(&v->vpdr_tag);
-	if (vpdr_len + sizeof(struct t4_vpd_hdr) > VPD_LEN) {
+	if (vpd[0] != PCI_VPD_LRDT_ID_STRING) {
+		dev_err(adapter->pdev_dev, "missing VPD ID string\n");
+		return -EINVAL;
+	}
+
+	id_len = pci_vpd_lrdt_size(vpd);
+	if (id_len > ID_LEN)
+		id_len = ID_LEN;
+
+	i = pci_vpd_find_tag(vpd, 0, VPD_LEN, PCI_VPD_LRDT_RO_DATA);
+	if (i < 0) {
+		dev_err(adapter->pdev_dev, "missing VPD-R section\n");
+		return -EINVAL;
+	}
+
+	vpdr_len = pci_vpd_lrdt_size(&vpd[i]);
+	kw_offset = i + PCI_VPD_LRDT_TAG_SIZE;
+	if (vpdr_len + kw_offset > VPD_LEN) {
 		dev_err(adapter->pdev_dev, "bad VPD-R length %u\n", vpdr_len);
 		return -EINVAL;
 	}
 
 #define FIND_VPD_KW(var, name) do { \
-	var = pci_vpd_find_info_keyword(&v->id_tag, sizeof(struct t4_vpd_hdr), \
-					vpdr_len, name); \
+	var = pci_vpd_find_info_keyword(vpd, kw_offset, vpdr_len, name); \
 	if (var < 0) { \
 		dev_err(adapter->pdev_dev, "missing VPD keyword " name "\n"); \
 		return -EINVAL; \
@@ -410,7 +411,7 @@ static int get_vpd_params(struct adapter *adapter, struct vpd_params *p)
 	FIND_VPD_KW(sn, "SN");
 #undef FIND_VPD_KW
 
-	memcpy(p->id, v->id_data, ID_LEN);
+	memcpy(p->id, vpd + PCI_VPD_LRDT_TAG_SIZE, id_len);
 	strim(p->id);
 	memcpy(p->ec, vpd + ec, EC_LEN);
 	strim(p->ec);
-- 
1.5.4

