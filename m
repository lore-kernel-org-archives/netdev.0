From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 2/6] cxgb4: Fixed the code to use correct length for part number
Date: Tue, 12 Aug 2014 11:09:09 +0530
Message-ID: <1407821953-8711-3-git-send-email-hariprasad@chelsio.com>
References: <1407821953-8711-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	kumaras@chelsio.com, anish@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 99-65-72-227.uvs.sntcca.sbcglobal.net ([99.65.72.227]:43195
	"EHLO stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752354AbaHLFdh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Aug 2014 01:33:37 -0400
In-Reply-To: <1407821953-8711-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Previously it was using the length value of serial number.
Also added macro for VPD unique identifier (0x82).

Signed-off-by: Casey Leedom <leedom@chelsio.com>
Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c |   11 ++++++++++-
 1 files changed, 10 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index 6b92c4c..adf16a5 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -566,6 +566,7 @@ int t4_memory_rw(struct adapter *adap, int win, int mtype, u32 addr,
 #define VPD_BASE           0x400
 #define VPD_BASE_OLD       0
 #define VPD_LEN            1024
+#define CHELSIO_VPD_UNIQUE_ID 0x82
 
 /**
  *	t4_seeprom_wp - enable/disable EEPROM write protection
@@ -603,7 +604,14 @@ int get_vpd_params(struct adapter *adapter, struct vpd_params *p)
 	ret = pci_read_vpd(adapter->pdev, VPD_BASE, sizeof(u32), vpd);
 	if (ret < 0)
 		goto out;
-	addr = *vpd == 0x82 ? VPD_BASE : VPD_BASE_OLD;
+
+	/* The VPD shall have a unique identifier specified by the PCI SIG.
+	 * For chelsio adapters, the identifier is 0x82. The first byte of a VPD
+	 * shall be CHELSIO_VPD_UNIQUE_ID (0x82). The VPD programming software
+	 * is expected to automatically put this entry at the
+	 * beginning of the VPD.
+	 */
+	addr = *vpd == CHELSIO_VPD_UNIQUE_ID ? VPD_BASE : VPD_BASE_OLD;
 
 	ret = pci_read_vpd(adapter->pdev, addr, VPD_LEN, vpd);
 	if (ret < 0)
@@ -667,6 +675,7 @@ int get_vpd_params(struct adapter *adapter, struct vpd_params *p)
 	i = pci_vpd_info_field_size(vpd + sn - PCI_VPD_INFO_FLD_HDR_SIZE);
 	memcpy(p->sn, vpd + sn, min(i, SERNUM_LEN));
 	strim(p->sn);
+	i = pci_vpd_info_field_size(vpd + pn - PCI_VPD_INFO_FLD_HDR_SIZE);
 	memcpy(p->pn, vpd + pn, min(i, PN_LEN));
 	strim(p->pn);
 
-- 
1.7.1
