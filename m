From: Suravee Suthikulpanit <Suravee.Suthikulpanit@amd.com>
Subject: [V2 PATCH 4/5] crypto: ccp - Unify coherency checking logic with
 device_dma_is_coherent()
Date: Tue, 5 May 2015 10:12:08 -0500
Message-ID: <1430838729-21572-5-git-send-email-Suravee.Suthikulpanit@amd.com>
References: <1430838729-21572-1-git-send-email-Suravee.Suthikulpanit@amd.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: al.stone@linaro.org, arnd@arndb.de, linaro-acpi@lists.linaro.org,
 netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
 linux-acpi@vger.kernel.org, leo.duran@amd.com, hanjun.guo@linaro.org, Suravee
 Suthikulpanit <Suravee.Suthikulpanit@amd.com>, msalter@redhat.com,
 grant.likely@linaro.org, linux-arm-kernel@lists.infradead.org,
 linux-crypto@vger.kernel.org
To: <rjw@rjwysocki.net>, <lenb@kernel.org>, <catalin.marinas@arm.com>,
 <will.deacon@arm.com>, <thomas.lendacky@amd.com>,
 <herbert@gondor.apana.org.au>, <davem@davemloft.net>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1430838729-21572-1-git-send-email-Suravee.Suthikulpanit@amd.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Currently, the driver has separate logic to determine device coherency
for DT vs ACPI.  This patch simplifies the code with a call to
device_dma_is_coherent().

CC: Herbert Xu <herbert@gondor.apana.org.au>
CC: David S. Miller <davem@davemloft.net>
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
