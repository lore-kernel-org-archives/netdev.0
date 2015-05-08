From: Suravee Suthikulpanit <Suravee.Suthikulpanit@amd.com>
Subject: [V3 PATCH 4/5] crypto: ccp - Unify coherency checking logic with device_dma_is_coherent()
Date: Thu, 7 May 2015 19:37:15 -0500
Message-ID: <1431045436-8690-5-git-send-email-Suravee.Suthikulpanit@amd.com>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1431045436-8690-1-git-send-email-Suravee.Suthikulpanit@amd.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Currently, the driver has separate logic to determine device coherency
for DT vs ACPI.  This patch simplifies the code with a call to
device_dma_is_coherent().

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
Signed-off-by: Suravee Suthikulpanit <Suravee.Suthikulpanit@amd.com>
---
 drivers/crypto/ccp/ccp-platform.c | 60 +--------------------------------------
 1 file changed, 1 insertion(+), 59 deletions(-)

diff --git a/drivers/crypto/ccp/ccp-platform.c b/drivers/crypto/ccp/ccp-platform.c
index b1c20b2..e446781 100644
--- a/drivers/crypto/ccp/ccp-platform.c
+++ b/drivers/crypto/ccp/ccp-platform.c
@@ -90,58 +90,6 @@ static struct resource *ccp_find_mmio_area(struct ccp_device *ccp)
 	return NULL;
 }
 
-#ifdef CONFIG_ACPI
-static int ccp_acpi_support(struct ccp_device *ccp)
-{
-	struct ccp_platform *ccp_platform = ccp->dev_specific;
-	struct acpi_device *adev = ACPI_COMPANION(ccp->dev);
-	acpi_handle handle;
-	acpi_status status;
-	unsigned long long data;
-	int cca;
-
-	/* Retrieve the device cache coherency value */
-	handle = adev->handle;
-	do {
-		status = acpi_evaluate_integer(handle, "_CCA", NULL, &data);
-		if (!ACPI_FAILURE(status)) {
-			cca = data;
-			break;
-		}
-	} while (!ACPI_FAILURE(status));
-
-	if (ACPI_FAILURE(status)) {
-		dev_err(ccp->dev, "error obtaining acpi coherency value\n");
-		return -EINVAL;
-	}
-
-	ccp_platform->coherent = !!cca;
-
-	return 0;
-}
-#else	/* CONFIG_ACPI */
-static int ccp_acpi_support(struct ccp_device *ccp)
-{
-	return -EINVAL;
-}
-#endif
-
-#ifdef CONFIG_OF
-static int ccp_of_support(struct ccp_device *ccp)
-{
-	struct ccp_platform *ccp_platform = ccp->dev_specific;
-
-	ccp_platform->coherent = of_dma_is_coherent(ccp->dev->of_node);
-
-	return 0;
-}
-#else
-static int ccp_of_support(struct ccp_device *ccp)
-{
-	return -EINVAL;
-}
-#endif
-
 static int ccp_platform_probe(struct platform_device *pdev)
 {
 	struct ccp_device *ccp;
@@ -182,13 +130,7 @@ static int ccp_platform_probe(struct platform_device *pdev)
 		goto e_err;
 	}
 
-	if (ccp_platform->use_acpi)
-		ret = ccp_acpi_support(ccp);
-	else
-		ret = ccp_of_support(ccp);
-	if (ret)
-		goto e_err;
-
+	ccp_platform->coherent = device_dma_is_coherent(ccp->dev);
 	if (ccp_platform->coherent)
 		ccp->axcache = CACHE_WB_NO_ALLOC;
 	else
-- 
2.1.0
