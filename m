From: Russell King <rmk+kernel-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>
Subject: [PATCH 44/51] DMA-API: dcdbas: update DMA mask handing
Date: Fri, 20 Sep 2013 00:16:39 +0100
Message-ID: <E1VMnSh-0007sm-5t@rmk-PC.arm.linux.org.uk>
References: <20130919212235.GD12758@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Doug Warzecha <Douglas_Warzecha-8PEkshWhKlo@public.gmane.org>
To: alsa-devel-K7yf7f+aM1XWsZ/bQMPhNw@public.gmane.org, b43-dev-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
 devel-gWbeCf7V1WCQmaza687I9mD2FQJk+8+b@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 dri-devel-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org, e1000-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
 linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-crypto-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-fbdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 linux-ide-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-media-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 linux-mmc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-nvme-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
 linux-omap-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
 linux-samsung-soc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 linux-tegra-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 Solarflare linux maintainers <linux-net-drivers-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>,
 uclinux-dist-devel-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org
Return-path: <b43-dev-bounces+gldbd-bcm43xx-dev=gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
In-Reply-To: <20130919212235.GD12758-l+eeeJia6m9vn6HldHNs0ANdhmdF6hFW@public.gmane.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/b43-dev>,
 <mailto:b43-dev-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/b43-dev/>
List-Post: <mailto:b43-dev-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b43-dev-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/b43-dev>,
 <mailto:b43-dev-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: "b43-dev" <b43-dev-bounces-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Errors-To: b43-dev-bounces+gldbd-bcm43xx-dev=gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

dcdbas was explicitly initializing DMA masks thusly:
	dcdbas_pdev->dev.coherent_dma_mask = DMA_BIT_MASK(32);
	dcdbas_pdev->dev.dma_mask = &dcdbas_pdev->dev.coherent_dma_mask;
which bypasses the architecture check.  Moreover, it is creating the
dcdbas_pdev device itself, and using the platform_device_register_full()
avoids some of this explicit initialization.

Convert the driver to use platform_device_register_full(), and as it
makes use of coherent DMA, also call dma_set_coherent_mask() to ensure
that the architecture gets to check the mask.

Signed-off-by: Russell King <rmk+kernel-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>
---
 drivers/firmware/dcdbas.c |   23 ++++++++++++-----------
 1 files changed, 12 insertions(+), 11 deletions(-)

diff --git a/drivers/firmware/dcdbas.c b/drivers/firmware/dcdbas.c
index ff080ee..a85fda2 100644
--- a/drivers/firmware/dcdbas.c
+++ b/drivers/firmware/dcdbas.c
@@ -549,8 +549,9 @@ static int dcdbas_probe(struct platform_device *dev)
 	 * BIOS SMI calls require buffer addresses be in 32-bit address space.
 	 * This is done by setting the DMA mask below.
 	 */
-	dcdbas_pdev->dev.coherent_dma_mask = DMA_BIT_MASK(32);
-	dcdbas_pdev->dev.dma_mask = &dcdbas_pdev->dev.coherent_dma_mask;
+	error = dma_set_coherent_mask(&dcdbas_pdev->dev, DMA_BIT_MASK(32));
+	if (error)
+		return error;
 
 	error = sysfs_create_group(&dev->dev.kobj, &dcdbas_attr_group);
 	if (error)
@@ -581,6 +582,12 @@ static struct platform_driver dcdbas_driver = {
 	.remove		= dcdbas_remove,
 };
 
+static const struct platform_device_info dcdbas_dev_info __initdata = {
+	.name		= DRIVER_NAME,
+	.id		= -1,
+	.dma_mask	= DMA_BIT_MASK(32),
+};
+
 /**
  * dcdbas_init: initialize driver
  */
@@ -592,20 +599,14 @@ static int __init dcdbas_init(void)
 	if (error)
 		return error;
 
-	dcdbas_pdev = platform_device_alloc(DRIVER_NAME, -1);
-	if (!dcdbas_pdev) {
-		error = -ENOMEM;
+	dcdbas_pdev = platform_device_register_full(&dcdbas_dev_info);
+	if (IS_ERR(dcdbas_pdev)) {
+		error = PTR_ERR(dcdbas_pdev);
 		goto err_unregister_driver;
 	}
 
-	error = platform_device_add(dcdbas_pdev);
-	if (error)
-		goto err_free_device;
-
 	return 0;
 
- err_free_device:
-	platform_device_put(dcdbas_pdev);
  err_unregister_driver:
 	platform_driver_unregister(&dcdbas_driver);
 	return error;
-- 
1.7.4.4
