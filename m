From: Russell King <rmk+kernel@arm.linux.org.uk>
Subject: [PATCH 40/51] DMA-API: crypto: fix ixp4xx crypto
 platform device support
Date: Fri, 20 Sep 2013 00:12:38 +0100
Message-ID: <E1VMnOo-0007sC-Li@rmk-PC.arm.linux.org.uk>
References: <20130919212235.GD12758@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
 "David S. Miller" <davem@davemloft.net>
To: alsa-devel@alsa-project.org, b43-dev@lists.infradead.org,
 devel@driverdev.osuosl.org, devicetree@vger.kernel.org,
 dri-devel@lists.freedesktop.org, e1000-devel@lists.sourceforge.net,
 linux-arm-kernel@lists.infradead.org, linux-crypto@vger.kernel.org,
 linux-doc@vger.kernel.org, linux-fbdev@vger.kernel.org,
 linux-ide@vger.kernel.org, linux-media@vger.kernel.org,
 linux-mmc@vger.kernel.org, linux-nvme@lists.infradead.org,
 linux-omap@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
 linux-samsung-soc@vger.kernel.org, linux-scsi@vger.kernel.org,
 linux-tegra@vger.kernel.org, linux-usb@vger.kernel.org,
 linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
 Solarflare linux maintainers <linux-net-drivers@solarflare.com>,
 uclinux-dist-devel@blackfin.uclinux.org
Return-path: <alsa-devel-bounces@alsa-project.org>
In-Reply-To: <20130919212235.GD12758@n2100.arm.linux.org.uk>
List-Unsubscribe: <http://mailman.alsa-project.org/mailman/options/alsa-devel>,
 <mailto:alsa-devel-request@alsa-project.org?subject=unsubscribe>
List-Archive: <http://mailman.alsa-project.org/pipermail/alsa-devel/>
List-Post: <mailto:alsa-devel@alsa-project.org>
List-Help: <mailto:alsa-devel-request@alsa-project.org?subject=help>
List-Subscribe: <http://mailman.alsa-project.org/mailman/listinfo/alsa-devel>,
 <mailto:alsa-devel-request@alsa-project.org?subject=subscribe>
Errors-To: alsa-devel-bounces@alsa-project.org
Sender: alsa-devel-bounces@alsa-project.org
List-Id: netdev.vger.kernel.org

Don't statically allocate struct device's in modules, and shut the
warning up with an empty release() function.  There's a reason that
warning is there and that's not for people to hide in this way.  It's
there to persuade people to use the correct APIs to allocate platform
devices.

Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
---
 drivers/crypto/ixp4xx_crypto.c |   37 +++++++++++++++++--------------------
 1 files changed, 17 insertions(+), 20 deletions(-)

diff --git a/drivers/crypto/ixp4xx_crypto.c b/drivers/crypto/ixp4xx_crypto.c
index 21180d6..8306185 100644
--- a/drivers/crypto/ixp4xx_crypto.c
+++ b/drivers/crypto/ixp4xx_crypto.c
@@ -218,23 +218,10 @@ static dma_addr_t crypt_phys;
 
 static int support_aes = 1;
 
-static void dev_release(struct device *dev)
-{
-	return;
-}
-
 #define DRIVER_NAME "ixp4xx_crypto"
-static struct platform_device pseudo_dev = {
-	.name = DRIVER_NAME,
-	.id   = 0,
-	.num_resources = 0,
-	.dev  = {
-		.coherent_dma_mask = DMA_BIT_MASK(32),
-		.release = dev_release,
-	}
-};
 
-static struct device *dev = &pseudo_dev.dev;
+static struct platform_device *pdev;
+static struct device *dev;
 
 static inline dma_addr_t crypt_virt2phys(struct crypt_ctl *virt)
 {
@@ -1418,20 +1405,30 @@ static struct ixp_alg ixp4xx_algos[] = {
 } };
 
 #define IXP_POSTFIX "-ixp4xx"
+
+static const struct platform_device_info ixp_dev_info __initdata = {
+	.name		= DRIVER_NAME,
+	.id		= 0,
+	.dma_mask	= DMA_BIT_MASK(32),
+};
+
 static int __init ixp_module_init(void)
 {
 	int num = ARRAY_SIZE(ixp4xx_algos);
-	int i,err ;
+	int i, err ;
 
-	if (platform_device_register(&pseudo_dev))
-		return -ENODEV;
+	pdev = platform_device_register_full(&ixp_dev_info);
+	if (IS_ERR(pdev))
+		return PTR_ERR(pdev);
+
+	dev = &pdev->dev;
 
 	spin_lock_init(&desc_lock);
 	spin_lock_init(&emerg_lock);
 
 	err = init_ixp_crypto();
 	if (err) {
-		platform_device_unregister(&pseudo_dev);
+		platform_device_unregister(pdev);
 		return err;
 	}
 	for (i=0; i< num; i++) {
@@ -1496,7 +1493,7 @@ static void __exit ixp_module_exit(void)
 			crypto_unregister_alg(&ixp4xx_algos[i].crypto);
 	}
 	release_ixp_crypto();
-	platform_device_unregister(&pseudo_dev);
+	platform_device_unregister(pdev);
 }
 
 module_init(ixp_module_init);
-- 
1.7.4.4
