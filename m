From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 2/8] cxgb4: Print adapter VPD Part Number instead of Engineering Change field
Date: Tue, 18 Feb 2014 17:56:09 +0530
Message-ID: <1392726375-32001-3-git-send-email-hariprasad@chelsio.com>
References: <1392726375-32001-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, dm@chelsio.com, leedom@chelsio.com,
	nirranjan@chelsio.com, kumaras@chelsio.com, santosh@chelsio.com,
	hariprasad@chelsio.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:31324 "EHLO
	stargate.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755128AbaBRNgJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Feb 2014 08:36:09 -0500
In-Reply-To: <1392726375-32001-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kumar Sanghvi <kumaras@chelsio.com>

When we attach to adapter, print VPD Part Number instead of Engineering Change field.
Based on original work by Casey Leedom <leedom@chelsio.com>

Signed-off-by: Kumar Sanghvi <kumaras@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h      | 2 ++
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 4 ++--
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c      | 5 ++++-
 3 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index 0c4edd1..028b5e5 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -66,6 +66,7 @@ enum {
 	SERNUM_LEN = 24,    /* Serial # length */
 	EC_LEN     = 16,    /* E/C length */
 	ID_LEN     = 16,    /* ID length */
+	PN_LEN     = 16,    /* Part Number length */
 };
 
 enum {
@@ -254,6 +255,7 @@ struct vpd_params {
 	u8 ec[EC_LEN + 1];
 	u8 sn[SERNUM_LEN + 1];
 	u8 id[ID_LEN + 1];
+	u8 pn[PN_LEN + 1];
 };
 
 struct pci_params {
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index ee2f123..5e345bc 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -5841,8 +5841,8 @@ static void print_port_info(const struct net_device *dev)
 		    is_offload(adap) ? "R" : "", adap->params.pci.width, spd,
 		    (adap->flags & USING_MSIX) ? " MSI-X" :
 		    (adap->flags & USING_MSI) ? " MSI" : "");
-	netdev_info(dev, "S/N: %s, E/C: %s\n",
-		    adap->params.vpd.sn, adap->params.vpd.ec);
+	netdev_info(dev, "S/N: %s, P/N: %s\n",
+		    adap->params.vpd.sn, adap->params.vpd.pn);
 }
 
 static void enable_pcie_relaxed_ordering(struct pci_dev *dev)
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index 514c525..7ae756d 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -573,7 +573,7 @@ int get_vpd_params(struct adapter *adapter, struct vpd_params *p)
 {
 	u32 cclk_param, cclk_val;
 	int i, ret, addr;
-	int ec, sn;
+	int ec, sn, pn;
 	u8 *vpd, csum;
 	unsigned int vpdr_len, kw_offset, id_len;
 
@@ -638,6 +638,7 @@ int get_vpd_params(struct adapter *adapter, struct vpd_params *p)
 
 	FIND_VPD_KW(ec, "EC");
 	FIND_VPD_KW(sn, "SN");
+	FIND_VPD_KW(pn, "PN");
 #undef FIND_VPD_KW
 
 	memcpy(p->id, vpd + PCI_VPD_LRDT_TAG_SIZE, id_len);
@@ -647,6 +648,8 @@ int get_vpd_params(struct adapter *adapter, struct vpd_params *p)
 	i = pci_vpd_info_field_size(vpd + sn - PCI_VPD_INFO_FLD_HDR_SIZE);
 	memcpy(p->sn, vpd + sn, min(i, SERNUM_LEN));
 	strim(p->sn);
+	memcpy(p->pn, vpd + pn, min(i, PN_LEN));
+	strim(p->pn);
 
 	/*
 	 * Ask firmware for the Core Clock since it knows how to translate the
-- 
1.8.0
