From: Suravee Suthikulpanit <Suravee.Suthikulpanit@amd.com>
Subject: [V3 PATCH 5/5] amd-xgbe: Unify coherency checking logic with device_dma_is_coherent()
Date: Thu, 7 May 2015 19:37:16 -0500
Message-ID: <1431045436-8690-6-git-send-email-Suravee.Suthikulpanit@amd.com>
References: <1431045436-8690-1-git-send-email-Suravee.Suthikulpanit@amd.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <msalter@redhat.com>, <hanjun.guo@linaro.org>,
	<al.stone@linaro.org>, <grant.likely@linaro.org>,
	<leo.duran@amd.com>, <linux-arm-kernel@lists.infradead.org>,
	<linux-acpi@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<linaro-acpi@lists.linaro.org>, <netdev@vger.kernel.org>,
	<linux-crypto@vger.kernel.org>,
	"Suravee Suthikulpanit" <Suravee.Suthikulpanit@amd.com>
To: <rjw@rjwysocki.net>, <lenb@kernel.org>, <catalin.marinas@arm.com>,
	<will.deacon@arm.com>, <thomas.lendacky@amd.com>,
	<herbert@gondor.apana.org.au>, <davem@davemloft.net>,
	<arnd@arndb.de>
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <1431045436-8690-1-git-send-email-Suravee.Suthikulpanit@amd.com>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Currently, amd-xgbe driver has separate logic to determine device
coherency for DT vs. ACPI. This patch simplifies the code with
a call to device_dma_is_coherent().

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
Signed-off-by: Suravee Suthikulpanit <Suravee.Suthikulpanit@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-main.c | 27 +--------------------------
 1 file changed, 1 insertion(+), 26 deletions(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-main.c b/drivers/net/ethernet/amd/xgbe/xgbe-main.c
index 7149053..6d2c702 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-main.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-main.c
@@ -168,13 +168,8 @@ static void xgbe_init_all_fptrs(struct xgbe_prv_data *pdata)
 #ifdef CONFIG_ACPI
 static int xgbe_acpi_support(struct xgbe_prv_data *pdata)
 {
-	struct acpi_device *adev = pdata->adev;
 	struct device *dev = pdata->dev;
 	u32 property;
-	acpi_handle handle;
-	acpi_status status;
-	unsigned long long data;
-	int cca;
 	int ret;
 
 	/* Obtain the system clock setting */
@@ -195,24 +190,6 @@ static int xgbe_acpi_support(struct xgbe_prv_data *pdata)
 	}
 	pdata->ptpclk_rate = property;
 
-	/* Retrieve the device cache coherency value */
-	handle = adev->handle;
-	do {
-		status = acpi_evaluate_integer(handle, "_CCA", NULL, &data);
-		if (!ACPI_FAILURE(status)) {
-			cca = data;
-			break;
-		}
-
-		status = acpi_get_parent(handle, &handle);
-	} while (!ACPI_FAILURE(status));
-
-	if (ACPI_FAILURE(status)) {
-		dev_err(dev, "error obtaining acpi coherency value\n");
-		return -EINVAL;
-	}
-	pdata->coherent = !!cca;
-
 	return 0;
 }
 #else   /* CONFIG_ACPI */
@@ -243,9 +220,6 @@ static int xgbe_of_support(struct xgbe_prv_data *pdata)
 	}
 	pdata->ptpclk_rate = clk_get_rate(pdata->ptpclk);
 
-	/* Retrieve the device cache coherency value */
-	pdata->coherent = of_dma_is_coherent(dev->of_node);
-
 	return 0;
 }
 #else   /* CONFIG_OF */
@@ -364,6 +338,7 @@ static int xgbe_probe(struct platform_device *pdev)
 		goto err_io;
 
 	/* Set the DMA coherency values */
+	pdata->coherent = device_dma_is_coherent(pdata->dev);
 	if (pdata->coherent) {
 		pdata->axdomain = XGBE_DMA_OS_AXDOMAIN;
 		pdata->arcache = XGBE_DMA_OS_ARCACHE;
-- 
2.1.0

