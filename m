From: Vadim Lomovtsev <Vadim.Lomovtsev@caviumnetworks.com>
Subject: [PATCH] net: thunderx: acpi: fix LMAC initialization
Date: Thu, 12 Jan 2017 07:28:06 -0800
Message-ID: <1484234886-22172-1-git-send-email-Vadim.Lomovtsev@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Vadim Lomovtsev <Vadim.Lomovtsev@caviumnetworks.com>
To: <linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <sgoutham@cavium.com>,
        <rric@kernel.org>, <Radha.Chintakuntla@cavium.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

While probing BGX we requesting appropriate QLM for it's configuration
and get LMAC count by that request. Then, while reading configured
MAC values from SSDT table we need to save them in proper mapping:
  BGX[i]->lmac[j].mac = <MAC value>
to later provide for initialization stuff. In order to fill
such mapping properly we need to add lmac index to be used while
acpi initialization since at this moment bgx->lmac_count already contains
actual value.

Signed-off-by: Vadim Lomovtsev <Vadim.Lomovtsev@caviumnetworks.com>
---
 drivers/net/ethernet/cavium/thunder/thunder_bgx.c | 11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/cavium/thunder/thunder_bgx.c b/drivers/net/ethernet/cavium/thunder/thunder_bgx.c
index be30ad0..a3f4f83 100644
--- a/drivers/net/ethernet/cavium/thunder/thunder_bgx.c
+++ b/drivers/net/ethernet/cavium/thunder/thunder_bgx.c
@@ -47,8 +47,9 @@ struct lmac {
 struct bgx {
 	u8			bgx_id;
 	struct	lmac		lmac[MAX_LMAC_PER_BGX];
-	int			lmac_count;
+	u8			lmac_count;
 	u8			max_lmac;
+	u8                      acpi_lmac_idx;
 	void __iomem		*reg_base;
 	struct pci_dev		*pdev;
 	bool                    is_dlm;
@@ -1073,13 +1074,13 @@ static acpi_status bgx_acpi_register_phy(acpi_handle handle,
 	if (acpi_bus_get_device(handle, &adev))
 		goto out;
 
-	acpi_get_mac_address(dev, adev, bgx->lmac[bgx->lmac_count].mac);
+	acpi_get_mac_address(dev, adev, bgx->lmac[bgx->acpi_lmac_idx].mac);
 
-	SET_NETDEV_DEV(&bgx->lmac[bgx->lmac_count].netdev, dev);
+	SET_NETDEV_DEV(&bgx->lmac[bgx->acpi_lmac_idx].netdev, dev);
 
-	bgx->lmac[bgx->lmac_count].lmacid = bgx->lmac_count;
+	bgx->lmac[bgx->acpi_lmac_idx].lmacid = bgx->acpi_lmac_idx;
+	bgx->acpi_lmac_idx++; /* move to next LMAC */
 out:
-	bgx->lmac_count++;
 	return AE_OK;
 }
 
-- 
1.8.3.1
