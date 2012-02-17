From: John Crispin <blogic@openwrt.org>
Subject: [PATCH 4/6] NET: MIPS: lantiq: convert etop to managed gpio
Date: Fri, 17 Feb 2012 11:32:49 +0100
Message-ID: <1329474771-20874-5-git-send-email-blogic@openwrt.org>
References: <1329474771-20874-1-git-send-email-blogic@openwrt.org>
Cc: linux-mips@linux-mips.org, John Crispin <blogic@openwrt.org>,
	netdev@vger.kernel.org
To: Ralf Baechle <ralf@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbd.name ([46.4.11.11]:38879 "EHLO nbd.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752484Ab2BQKdV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Feb 2012 05:33:21 -0500
In-Reply-To: <1329474771-20874-1-git-send-email-blogic@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ltq_gpio_request() now uses devres to manage the gpios. We need to pass a
struct device pointer to make it work.

Signed-off-by: John Crispin <blogic@openwrt.org>
Cc: netdev@vger.kernel.org
---
This patch should go via MIPS with the rest of the series.

 drivers/net/ethernet/lantiq_etop.c |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/lantiq_etop.c b/drivers/net/ethernet/lantiq_etop.c
index 66ec54a..80ce6d9 100644
--- a/drivers/net/ethernet/lantiq_etop.c
+++ b/drivers/net/ethernet/lantiq_etop.c
@@ -292,9 +292,6 @@ ltq_etop_gbit_init(void)
 {
 	ltq_pmu_enable(PMU_SWITCH);
 
-	ltq_gpio_request(42, 2, 1, "MDIO");
-	ltq_gpio_request(43, 2, 1, "MDC");
-
 	ltq_gbit_w32_mask(0, GCTL0_SE, LTQ_GBIT_GCTL0);
 	/** Disable MDIO auto polling mode */
 	ltq_gbit_w32_mask(0, PX_CTL_DMDIO, LTQ_GBIT_P0_CTL);
@@ -873,6 +870,12 @@ ltq_etop_probe(struct platform_device *pdev)
 			err = -ENOMEM;
 			goto err_out;
 		}
+		if (ltq_gpio_request(&pdev->dev, 42, 2, 1, "MDIO") ||
+				ltq_gpio_request(&pdev->dev, 43, 2, 1, "MDC")) {
+			dev_err(&pdev->dev, "failed to request MDIO gpios\n");
+			err = -ENOMEM;
+			goto err_out;
+		}
 	}
 
 	dev = alloc_etherdev_mq(sizeof(struct ltq_etop_priv), 4);
-- 
1.7.7.1
