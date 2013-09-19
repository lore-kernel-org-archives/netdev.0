From: Russell King <rmk+kernel@arm.linux.org.uk>
Subject: [PATCH 41/51] DMA-API: crypto: remove last references
 to 'static struct device *dev'
Date: Fri, 20 Sep 2013 00:13:38 +0100
Message-ID: <E1VMnPm-0007sP-Px@rmk-PC.arm.linux.org.uk>
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

Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
---
 drivers/crypto/ixp4xx_crypto.c |   13 ++++++++-----
 1 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/drivers/crypto/ixp4xx_crypto.c b/drivers/crypto/ixp4xx_crypto.c
index 8306185..214357e 100644
--- a/drivers/crypto/ixp4xx_crypto.c
+++ b/drivers/crypto/ixp4xx_crypto.c
@@ -221,7 +221,6 @@ static int support_aes = 1;
 #define DRIVER_NAME "ixp4xx_crypto"
 
 static struct platform_device *pdev;
-static struct device *dev;
 
 static inline dma_addr_t crypt_virt2phys(struct crypt_ctl *virt)
 {
@@ -250,6 +249,7 @@ static inline const struct ix_hash_algo *ix_hash(struct crypto_tfm *tfm)
 
 static int setup_crypt_desc(void)
 {
+	struct device *dev = &pdev->dev;
 	BUILD_BUG_ON(sizeof(struct crypt_ctl) != 64);
 	crypt_virt = dma_alloc_coherent(dev,
 			NPE_QLEN * sizeof(struct crypt_ctl),
@@ -350,6 +350,7 @@ static void finish_scattered_hmac(struct crypt_ctl *crypt)
 
 static void one_packet(dma_addr_t phys)
 {
+	struct device *dev = &pdev->dev;
 	struct crypt_ctl *crypt;
 	struct ixp_ctx *ctx;
 	int failed;
@@ -419,7 +420,7 @@ static void crypto_done_action(unsigned long arg)
 	tasklet_schedule(&crypto_done_tasklet);
 }
 
-static int init_ixp_crypto(void)
+static int init_ixp_crypto(struct device *dev)
 {
 	int ret = -ENODEV;
 	u32 msg[2] = { 0, 0 };
@@ -506,7 +507,7 @@ static int init_ixp_crypto(void)
 	return ret;
 }
 
-static void release_ixp_crypto(void)
+static void release_ixp_crypto(struct device *dev)
 {
 	qmgr_disable_irq(RECV_QID);
 	tasklet_kill(&crypto_done_tasklet);
@@ -873,6 +874,7 @@ static int ablk_perform(struct ablkcipher_request *req, int encrypt)
 	enum dma_data_direction src_direction = DMA_BIDIRECTIONAL;
 	struct ablk_ctx *req_ctx = ablkcipher_request_ctx(req);
 	struct buffer_desc src_hook;
+	struct device *dev = &pdev->dev;
 	gfp_t flags = req->base.flags & CRYPTO_TFM_REQ_MAY_SLEEP ?
 				GFP_KERNEL : GFP_ATOMIC;
 
@@ -997,6 +999,7 @@ static int aead_perform(struct aead_request *req, int encrypt,
 	unsigned int cryptlen;
 	struct buffer_desc *buf, src_hook;
 	struct aead_ctx *req_ctx = aead_request_ctx(req);
+	struct device *dev = &pdev->dev;
 	gfp_t flags = req->base.flags & CRYPTO_TFM_REQ_MAY_SLEEP ?
 				GFP_KERNEL : GFP_ATOMIC;
 
@@ -1426,7 +1429,7 @@ static int __init ixp_module_init(void)
 	spin_lock_init(&desc_lock);
 	spin_lock_init(&emerg_lock);
 
-	err = init_ixp_crypto();
+	err = init_ixp_crypto(&pdev->dev);
 	if (err) {
 		platform_device_unregister(pdev);
 		return err;
@@ -1492,7 +1495,7 @@ static void __exit ixp_module_exit(void)
 		if (ixp4xx_algos[i].registered)
 			crypto_unregister_alg(&ixp4xx_algos[i].crypto);
 	}
-	release_ixp_crypto();
+	release_ixp_crypto(&pdev->dev);
 	platform_device_unregister(pdev);
 }
 
-- 
1.7.4.4
