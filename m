From: Harini Katakam <harini.katakam@xilinx.com>
Subject: [RFC PATCH 1/3] net: macb: Add support for extended BD with a config option
Date: Fri, 11 Sep 2015 13:27:36 +0530
Message-ID: <1441958258-35441-2-git-send-email-harinik@xilinx.com>
References: <1441958258-35441-1-git-send-email-harinik@xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<devicetree@vger.kernel.org>, <harinik@xilinx.com>,
	<punnaia@xilinx.com>, <michals@xilinx.com>, <anirudh@xilinx.com>
To: <nicolas.ferre@atmel.com>, <davem@davemloft.net>,
	<robh+dt@kernel.org>, <pawel.moll@arm.com>, <mark.rutland@arm.com>,
	<ijc+devicetree@hellion.org.uk>, <galak@codeaurora.org>,
	<boris.brezillon@free-electrons.com>,
	<alexandre.belloni@free-electrons.com>,
	<harinikatakamlinux@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1441958258-35441-1-git-send-email-harinik@xilinx.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Cadence GEM supports extended buffer descriptors.
This patch adds a config option to enable use of extended BD.
This adds two extra words to the TX BD and RX BD by configuring the
necessary registers. Corresponding variables are added to the
macb_dma_desc structure.

Signed-off-by: Harini Katakam <harinik@xilinx.com>
---
 drivers/net/ethernet/cadence/Kconfig |    8 ++++++++
 drivers/net/ethernet/cadence/macb.c  |    4 ++++
 drivers/net/ethernet/cadence/macb.h  |    8 ++++++++
 3 files changed, 20 insertions(+)

diff --git a/drivers/net/ethernet/cadence/Kconfig b/drivers/net/ethernet/cadence/Kconfig
index f0bcb15..33e4198 100644
--- a/drivers/net/ethernet/cadence/Kconfig
+++ b/drivers/net/ethernet/cadence/Kconfig
@@ -31,4 +31,12 @@ config MACB
 	  To compile this driver as a module, choose M here: the module
 	  will be called macb.
 
+config MACB_EXT_BD
+	tristate "Cadence MACB/GEM extended buffer descriptor"
+	depends on HAS_DMA && MACB
+	---help---
+	  The Cadence MACB host supports use of extended buffer descriptor.
+	  This option enables additon of two extra words to TX BD and RX BD.
+	  These two extra words are currently used to obtain PTP timestamp.
+
 endif # NET_CADENCE
diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 88c1e1a..bb2932c 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -1665,6 +1665,10 @@ static void macb_configure_dma(struct macb *bp)
 			dmacfg |= GEM_BIT(TXCOEN);
 		else
 			dmacfg &= ~GEM_BIT(TXCOEN);
+#ifdef CONFIG_MACB_EXT_BD
+		dmacfg |= GEM_BIT(RXBDEXT);
+		dmacfg |= GEM_BIT(TXBDEXT);
+#endif
 		netdev_dbg(bp->dev, "Cadence configure DMA with 0x%08x\n",
 			   dmacfg);
 		gem_writel(bp, DMACFG, dmacfg);
diff --git a/drivers/net/ethernet/cadence/macb.h b/drivers/net/ethernet/cadence/macb.h
index 6e1faea..58c9870 100644
--- a/drivers/net/ethernet/cadence/macb.h
+++ b/drivers/net/ethernet/cadence/macb.h
@@ -244,6 +244,10 @@
 #define GEM_RXBS_SIZE		8
 #define GEM_DDRP_OFFSET		24 /* disc_when_no_ahb */
 #define GEM_DDRP_SIZE		1
+#define GEM_RXBDEXT_OFFSET	28 /* Extended RX BD */
+#define GEM_RXBDEXT_SIZE	1
+#define GEM_TXBDEXT_OFFSET	29 /* Extended TX BD */
+#define GEM_TXBDEXT_SIZE	1
 
 
 /* Bitfields in NSR */
@@ -466,6 +470,10 @@
 struct macb_dma_desc {
 	u32	addr;
 	u32	ctrl;
+#ifdef CONFIG_MACB_EXT_BD
+	u32	tsl;
+	u32	tsh;
+#endif
 };
 
 /* DMA descriptor bitfields */
-- 
1.7.9.5
