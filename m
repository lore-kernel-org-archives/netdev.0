From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [net-next.git 1/8] stmmac: reorganize chain/ring modes removing Koptions
Date: Tue, 26 Mar 2013 15:43:05 +0100
Message-ID: <1364308992-27929-2-git-send-email-peppe.cavallaro@st.com>
References: <1364308992-27929-1-git-send-email-peppe.cavallaro@st.com>
Cc: rayagond@vayavyalabs.com, richardcochran@gmail.com,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog124.obsmtp.com ([207.126.144.157]:42514 "EHLO
	eu1sys200aog124.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933525Ab3CZOoe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Mar 2013 10:44:34 -0400
In-Reply-To: <1364308992-27929-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Previously we had two Koptions to decide if the stmmac
had to use either a ring or a chain to manage its descriptors.
This patch removes the Kernel configuration options and it allow us
to use the chain mode by passing a module option.
Ring mode continues to be the default.

Also with this patch, it will be easier to validate the driver built and
guarantee that all the two modes always compile fine.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/Kconfig       |   18 ----
 drivers/net/ethernet/stmicro/stmmac/Makefile      |    6 +-
 drivers/net/ethernet/stmicro/stmmac/chain_mode.c  |   36 ++-------
 drivers/net/ethernet/stmicro/stmmac/common.h      |   25 ++++--
 drivers/net/ethernet/stmicro/stmmac/descs_com.h   |   44 +++++-----
 drivers/net/ethernet/stmicro/stmmac/enh_desc.c    |   29 +++++--
 drivers/net/ethernet/stmicro/stmmac/norm_desc.c   |   29 +++++--
 drivers/net/ethernet/stmicro/stmmac/ring_mode.c   |   24 ++----
 drivers/net/ethernet/stmicro/stmmac/stmmac.h      |    1 +
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |   94 ++++++++++++++------
 10 files changed, 169 insertions(+), 137 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/Kconfig b/drivers/net/ethernet/stmicro/stmmac/Kconfig
index c0ea838..f0720d0 100644
--- a/drivers/net/ethernet/stmicro/stmmac/Kconfig
+++ b/drivers/net/ethernet/stmicro/stmmac/Kconfig
@@ -54,22 +54,4 @@ config STMMAC_DA
 	  By default, the DMA arbitration scheme is based on Round-robin
 	  (rx:tx priority is 1:1).
 
-choice
-	prompt "Select the DMA TX/RX descriptor operating modes"
-	depends on STMMAC_ETH
-	---help---
-	  This driver supports DMA descriptor to operate both in dual buffer
-	  (RING) and linked-list(CHAINED) mode. In RING mode each descriptor
-	  points to two data buffer pointers whereas in CHAINED mode they
-	  points to only one data buffer pointer.
-
-config STMMAC_RING
-	bool "Enable Descriptor Ring Mode"
-
-config STMMAC_CHAINED
-	bool "Enable Descriptor Chained Mode"
-
-endchoice
-
-
 endif
diff --git a/drivers/net/ethernet/stmicro/stmmac/Makefile b/drivers/net/ethernet/stmicro/stmmac/Makefile
index c8e8ea6..ae995a3 100644
--- a/drivers/net/ethernet/stmicro/stmmac/Makefile
+++ b/drivers/net/ethernet/stmicro/stmmac/Makefile
@@ -1,9 +1,7 @@
 obj-$(CONFIG_STMMAC_ETH) += stmmac.o
-stmmac-$(CONFIG_STMMAC_RING) += ring_mode.o
-stmmac-$(CONFIG_STMMAC_CHAINED) += chain_mode.o
 stmmac-$(CONFIG_STMMAC_PLATFORM) += stmmac_platform.o
 stmmac-$(CONFIG_STMMAC_PCI) += stmmac_pci.o
-stmmac-objs:= stmmac_main.o stmmac_ethtool.o stmmac_mdio.o	\
-	      dwmac_lib.o dwmac1000_core.o  dwmac1000_dma.o	\
+stmmac-objs:= stmmac_main.o stmmac_ethtool.o stmmac_mdio.o ring_mode.o	\
+	      chain_mode.o dwmac_lib.o dwmac1000_core.o  dwmac1000_dma.o \
 	      dwmac100_core.o dwmac100_dma.o enh_desc.o  norm_desc.o \
 	      mmc_core.o $(stmmac-y)
diff --git a/drivers/net/ethernet/stmicro/stmmac/chain_mode.c b/drivers/net/ethernet/stmicro/stmmac/chain_mode.c
index 0668659..08ff51e 100644
--- a/drivers/net/ethernet/stmicro/stmmac/chain_mode.c
+++ b/drivers/net/ethernet/stmicro/stmmac/chain_mode.c
@@ -28,7 +28,7 @@
 
 #include "stmmac.h"
 
-unsigned int stmmac_jumbo_frm(void *p, struct sk_buff *skb, int csum)
+static unsigned int stmmac_jumbo_frm(void *p, struct sk_buff *skb, int csum)
 {
 	struct stmmac_priv *priv = (struct stmmac_priv *) p;
 	unsigned int txsize = priv->dma_tx_size;
@@ -47,7 +47,7 @@ unsigned int stmmac_jumbo_frm(void *p, struct sk_buff *skb, int csum)
 
 	desc->des2 = dma_map_single(priv->device, skb->data,
 				    bmax, DMA_TO_DEVICE);
-	priv->hw->desc->prepare_tx_desc(desc, 1, bmax, csum);
+	priv->hw->desc->prepare_tx_desc(desc, 1, bmax, csum, STMMAC_CHAIN_MODE);
 
 	while (len != 0) {
 		entry = (++priv->cur_tx) % txsize;
@@ -57,8 +57,8 @@ unsigned int stmmac_jumbo_frm(void *p, struct sk_buff *skb, int csum)
 			desc->des2 = dma_map_single(priv->device,
 						    (skb->data + bmax * i),
 						    bmax, DMA_TO_DEVICE);
-			priv->hw->desc->prepare_tx_desc(desc, 0, bmax,
-							csum);
+			priv->hw->desc->prepare_tx_desc(desc, 0, bmax, csum,
+							STMMAC_CHAIN_MODE);
 			priv->hw->desc->set_tx_owner(desc);
 			priv->tx_skbuff[entry] = NULL;
 			len -= bmax;
@@ -67,8 +67,8 @@ unsigned int stmmac_jumbo_frm(void *p, struct sk_buff *skb, int csum)
 			desc->des2 = dma_map_single(priv->device,
 						    (skb->data + bmax * i), len,
 						    DMA_TO_DEVICE);
-			priv->hw->desc->prepare_tx_desc(desc, 0, len,
-							csum);
+			priv->hw->desc->prepare_tx_desc(desc, 0, len, csum,
+							STMMAC_CHAIN_MODE);
 			priv->hw->desc->set_tx_owner(desc);
 			priv->tx_skbuff[entry] = NULL;
 			len = 0;
@@ -89,18 +89,6 @@ static unsigned int stmmac_is_jumbo_frm(int len, int enh_desc)
 	return ret;
 }
 
-static void stmmac_refill_desc3(int bfsize, struct dma_desc *p)
-{
-}
-
-static void stmmac_init_desc3(int des3_as_data_buf, struct dma_desc *p)
-{
-}
-
-static void stmmac_clean_desc3(struct dma_desc *p)
-{
-}
-
 static void stmmac_init_dma_chain(struct dma_desc *des, dma_addr_t phy_addr,
 				  unsigned int size)
 {
@@ -120,18 +108,8 @@ static void stmmac_init_dma_chain(struct dma_desc *des, dma_addr_t phy_addr,
 	p->des3 = (unsigned int)phy_addr;
 }
 
-static int stmmac_set_16kib_bfsize(int mtu)
-{
-	/* Not supported */
-	return 0;
-}
-
-const struct stmmac_ring_mode_ops ring_mode_ops = {
+const struct stmmac_chain_mode_ops chain_mode_ops = {
 	.is_jumbo_frm = stmmac_is_jumbo_frm,
 	.jumbo_frm = stmmac_jumbo_frm,
-	.refill_desc3 = stmmac_refill_desc3,
-	.init_desc3 = stmmac_init_desc3,
 	.init_dma_chain = stmmac_init_dma_chain,
-	.clean_desc3 = stmmac_clean_desc3,
-	.set_16kib_bfsize = stmmac_set_16kib_bfsize,
 };
diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
index 186d148..a295532 100644
--- a/drivers/net/ethernet/stmicro/stmmac/common.h
+++ b/drivers/net/ethernet/stmicro/stmmac/common.h
@@ -255,23 +255,27 @@ struct dma_features {
 #define STMMAC_DEFAULT_LIT_LS_TIMER	0x3E8
 #define STMMAC_DEFAULT_TWT_LS_TIMER	0x0
 
+#define STMMAC_CHAIN_MODE	0x1
+#define STMMAC_RING_MODE	0x2
+
 struct stmmac_desc_ops {
 	/* DMA RX descriptor ring initialization */
 	void (*init_rx_desc) (struct dma_desc *p, unsigned int ring_size,
-			      int disable_rx_ic);
+			      int disable_rx_ic, int mode);
 	/* DMA TX descriptor ring initialization */
-	void (*init_tx_desc) (struct dma_desc *p, unsigned int ring_size);
+	void (*init_tx_desc) (struct dma_desc *p, unsigned int ring_size,
+			      int mode);
 
 	/* Invoked by the xmit function to prepare the tx descriptor */
 	void (*prepare_tx_desc) (struct dma_desc *p, int is_fs, int len,
-				 int csum_flag);
+				 int csum_flag, int mode);
 	/* Set/get the owner of the descriptor */
 	void (*set_tx_owner) (struct dma_desc *p);
 	int (*get_tx_owner) (struct dma_desc *p);
 	/* Invoked by the xmit function to close the tx descriptor */
 	void (*close_tx_desc) (struct dma_desc *p);
 	/* Clean the tx descriptor as soon as the tx irq is received */
-	void (*release_tx_desc) (struct dma_desc *p);
+	void (*release_tx_desc) (struct dma_desc *p, int mode);
 	/* Clear interrupt on tx frame completion. When this bit is
 	 * set an interrupt happens as soon as the frame is transmitted */
 	void (*clear_tx_ic) (struct dma_desc *p);
@@ -361,18 +365,24 @@ struct stmmac_ring_mode_ops {
 	unsigned int (*is_jumbo_frm) (int len, int ehn_desc);
 	unsigned int (*jumbo_frm) (void *priv, struct sk_buff *skb, int csum);
 	void (*refill_desc3) (int bfsize, struct dma_desc *p);
-	void (*init_desc3) (int des3_as_data_buf, struct dma_desc *p);
-	void (*init_dma_chain) (struct dma_desc *des, dma_addr_t phy_addr,
-				unsigned int size);
+	void (*init_desc3) (struct dma_desc *p);
 	void (*clean_desc3) (struct dma_desc *p);
 	int (*set_16kib_bfsize) (int mtu);
 };
 
+struct stmmac_chain_mode_ops {
+	unsigned int (*is_jumbo_frm) (int len, int ehn_desc);
+	unsigned int (*jumbo_frm) (void *priv, struct sk_buff *skb, int csum);
+	void (*init_dma_chain) (struct dma_desc *des, dma_addr_t phy_addr,
+				unsigned int size);
+};
+
 struct mac_device_info {
 	const struct stmmac_ops		*mac;
 	const struct stmmac_desc_ops	*desc;
 	const struct stmmac_dma_ops	*dma;
 	const struct stmmac_ring_mode_ops	*ring;
+	const struct stmmac_chain_mode_ops	*chain;
 	struct mii_regs mii;	/* MII register Addresses */
 	struct mac_link link;
 	unsigned int synopsys_uid;
@@ -390,5 +400,6 @@ extern void stmmac_set_mac(void __iomem *ioaddr, bool enable);
 
 extern void dwmac_dma_flush_tx_fifo(void __iomem *ioaddr);
 extern const struct stmmac_ring_mode_ops ring_mode_ops;
+extern const struct stmmac_chain_mode_ops chain_mode_ops;
 
 #endif /* __COMMON_H__ */
diff --git a/drivers/net/ethernet/stmicro/stmmac/descs_com.h b/drivers/net/ethernet/stmicro/stmmac/descs_com.h
index 7ee9499..20f83fc 100644
--- a/drivers/net/ethernet/stmicro/stmmac/descs_com.h
+++ b/drivers/net/ethernet/stmicro/stmmac/descs_com.h
@@ -30,26 +30,28 @@
 #ifndef __DESC_COM_H__
 #define __DESC_COM_H__
 
-#if defined(CONFIG_STMMAC_RING)
-static inline void ehn_desc_rx_set_on_ring_chain(struct dma_desc *p, int end)
+/* Specific functions used for Ring mode */
+
+/* Enhanced descriptors */
+static inline void ehn_desc_rx_set_on_ring(struct dma_desc *p, int end)
 {
 	p->des01.erx.buffer2_size = BUF_SIZE_8KiB - 1;
 	if (end)
 		p->des01.erx.end_ring = 1;
 }
 
-static inline void ehn_desc_tx_set_on_ring_chain(struct dma_desc *p, int end)
+static inline void ehn_desc_tx_set_on_ring(struct dma_desc *p, int end)
 {
 	if (end)
 		p->des01.etx.end_ring = 1;
 }
 
-static inline void enh_desc_end_tx_desc(struct dma_desc *p, int ter)
+static inline void enh_desc_end_tx_desc_on_ring(struct dma_desc *p, int ter)
 {
 	p->des01.etx.end_ring = ter;
 }
 
-static inline void enh_set_tx_desc_len(struct dma_desc *p, int len)
+static inline void enh_set_tx_desc_len_on_ring(struct dma_desc *p, int len)
 {
 	if (unlikely(len > BUF_SIZE_4KiB)) {
 		p->des01.etx.buffer1_size = BUF_SIZE_4KiB;
@@ -58,25 +60,26 @@ static inline void enh_set_tx_desc_len(struct dma_desc *p, int len)
 		p->des01.etx.buffer1_size = len;
 }
 
-static inline void ndesc_rx_set_on_ring_chain(struct dma_desc *p, int end)
+/* Normal descriptors */
+static inline void ndesc_rx_set_on_ring(struct dma_desc *p, int end)
 {
 	p->des01.rx.buffer2_size = BUF_SIZE_2KiB - 1;
 	if (end)
 		p->des01.rx.end_ring = 1;
 }
 
-static inline void ndesc_tx_set_on_ring_chain(struct dma_desc *p, int end)
+static inline void ndesc_tx_set_on_ring(struct dma_desc *p, int end)
 {
 	if (end)
 		p->des01.tx.end_ring = 1;
 }
 
-static inline void ndesc_end_tx_desc(struct dma_desc *p, int ter)
+static inline void ndesc_end_tx_desc_on_ring(struct dma_desc *p, int ter)
 {
 	p->des01.tx.end_ring = ter;
 }
 
-static inline void norm_set_tx_desc_len(struct dma_desc *p, int len)
+static inline void norm_set_tx_desc_len_on_ring(struct dma_desc *p, int len)
 {
 	if (unlikely(len > BUF_SIZE_2KiB)) {
 		p->des01.etx.buffer1_size = BUF_SIZE_2KiB - 1;
@@ -85,47 +88,48 @@ static inline void norm_set_tx_desc_len(struct dma_desc *p, int len)
 		p->des01.tx.buffer1_size = len;
 }
 
-#else
+/* Specific functions used for Chain mode */
 
-static inline void ehn_desc_rx_set_on_ring_chain(struct dma_desc *p, int end)
+/* Enhanced descriptors */
+static inline void ehn_desc_rx_set_on_chain(struct dma_desc *p, int end)
 {
 	p->des01.erx.second_address_chained = 1;
 }
 
-static inline void ehn_desc_tx_set_on_ring_chain(struct dma_desc *p, int end)
+static inline void ehn_desc_tx_set_on_chain(struct dma_desc *p, int end)
 {
 	p->des01.etx.second_address_chained = 1;
 }
 
-static inline void enh_desc_end_tx_desc(struct dma_desc *p, int ter)
+static inline void enh_desc_end_tx_desc_on_chain(struct dma_desc *p, int ter)
 {
 	p->des01.etx.second_address_chained = 1;
 }
 
-static inline void enh_set_tx_desc_len(struct dma_desc *p, int len)
+static inline void enh_set_tx_desc_len_on_chain(struct dma_desc *p, int len)
 {
 	p->des01.etx.buffer1_size = len;
 }
 
-static inline void ndesc_rx_set_on_ring_chain(struct dma_desc *p, int end)
+/* Normal descriptors */
+static inline void ndesc_rx_set_on_chain(struct dma_desc *p, int end)
 {
 	p->des01.rx.second_address_chained = 1;
 }
 
-static inline void ndesc_tx_set_on_ring_chain(struct dma_desc *p, int ring_size)
+static inline void ndesc_tx_set_on_chain(struct dma_desc *p, int
+						 ring_size)
 {
 	p->des01.tx.second_address_chained = 1;
 }
 
-static inline void ndesc_end_tx_desc(struct dma_desc *p, int ter)
+static inline void ndesc_end_tx_desc_on_chain(struct dma_desc *p, int ter)
 {
 	p->des01.tx.second_address_chained = 1;
 }
 
-static inline void norm_set_tx_desc_len(struct dma_desc *p, int len)
+static inline void norm_set_tx_desc_len_on_chain(struct dma_desc *p, int len)
 {
 	p->des01.tx.buffer1_size = len;
 }
-#endif
-
 #endif /* __DESC_COM_H__ */
diff --git a/drivers/net/ethernet/stmicro/stmmac/enh_desc.c b/drivers/net/ethernet/stmicro/stmmac/enh_desc.c
index 2fc8ef9..62f9f4e 100644
--- a/drivers/net/ethernet/stmicro/stmmac/enh_desc.c
+++ b/drivers/net/ethernet/stmicro/stmmac/enh_desc.c
@@ -229,14 +229,17 @@ static int enh_desc_get_rx_status(void *data, struct stmmac_extra_stats *x,
 }
 
 static void enh_desc_init_rx_desc(struct dma_desc *p, unsigned int ring_size,
-				  int disable_rx_ic)
+				  int disable_rx_ic, int mode)
 {
 	int i;
 	for (i = 0; i < ring_size; i++) {
 		p->des01.erx.own = 1;
 		p->des01.erx.buffer1_size = BUF_SIZE_8KiB - 1;
 
-		ehn_desc_rx_set_on_ring_chain(p, (i == ring_size - 1));
+		if (mode == STMMAC_CHAIN_MODE)
+			ehn_desc_rx_set_on_chain(p, (i == ring_size - 1));
+		else
+			ehn_desc_rx_set_on_ring(p, (i == ring_size - 1));
 
 		if (disable_rx_ic)
 			p->des01.erx.disable_ic = 1;
@@ -244,13 +247,17 @@ static void enh_desc_init_rx_desc(struct dma_desc *p, unsigned int ring_size,
 	}
 }
 
-static void enh_desc_init_tx_desc(struct dma_desc *p, unsigned int ring_size)
+static void enh_desc_init_tx_desc(struct dma_desc *p, unsigned int ring_size,
+				  int mode)
 {
 	int i;
 
 	for (i = 0; i < ring_size; i++) {
 		p->des01.etx.own = 0;
-		ehn_desc_tx_set_on_ring_chain(p, (i == ring_size - 1));
+		if (mode == STMMAC_CHAIN_MODE)
+			ehn_desc_tx_set_on_chain(p, (i == ring_size - 1));
+		else
+			ehn_desc_tx_set_on_ring(p, (i == ring_size - 1));
 		p++;
 	}
 }
@@ -280,20 +287,26 @@ static int enh_desc_get_tx_ls(struct dma_desc *p)
 	return p->des01.etx.last_segment;
 }
 
-static void enh_desc_release_tx_desc(struct dma_desc *p)
+static void enh_desc_release_tx_desc(struct dma_desc *p, int mode)
 {
 	int ter = p->des01.etx.end_ring;
 
 	memset(p, 0, offsetof(struct dma_desc, des2));
-	enh_desc_end_tx_desc(p, ter);
+	if (mode == STMMAC_CHAIN_MODE)
+		enh_desc_end_tx_desc_on_chain(p, ter);
+	else
+		enh_desc_end_tx_desc_on_ring(p, ter);
 }
 
 static void enh_desc_prepare_tx_desc(struct dma_desc *p, int is_fs, int len,
-				     int csum_flag)
+				     int csum_flag, int mode)
 {
 	p->des01.etx.first_segment = is_fs;
 
-	enh_set_tx_desc_len(p, len);
+	if (mode == STMMAC_CHAIN_MODE)
+		enh_set_tx_desc_len_on_chain(p, len);
+	else
+		enh_set_tx_desc_len_on_ring(p, len);
 
 	if (likely(csum_flag))
 		p->des01.etx.checksum_insertion = cic_full;
diff --git a/drivers/net/ethernet/stmicro/stmmac/norm_desc.c b/drivers/net/ethernet/stmicro/stmmac/norm_desc.c
index 68962c5..88df0b4 100644
--- a/drivers/net/ethernet/stmicro/stmmac/norm_desc.c
+++ b/drivers/net/ethernet/stmicro/stmmac/norm_desc.c
@@ -123,14 +123,17 @@ static int ndesc_get_rx_status(void *data, struct stmmac_extra_stats *x,
 }
 
 static void ndesc_init_rx_desc(struct dma_desc *p, unsigned int ring_size,
-			       int disable_rx_ic)
+			       int disable_rx_ic, int mode)
 {
 	int i;
 	for (i = 0; i < ring_size; i++) {
 		p->des01.rx.own = 1;
 		p->des01.rx.buffer1_size = BUF_SIZE_2KiB - 1;
 
-		ndesc_rx_set_on_ring_chain(p, (i == ring_size - 1));
+		if (mode == STMMAC_CHAIN_MODE)
+			ndesc_rx_set_on_chain(p, (i == ring_size - 1));
+		else
+			ndesc_rx_set_on_ring(p, (i == ring_size - 1));
 
 		if (disable_rx_ic)
 			p->des01.rx.disable_ic = 1;
@@ -138,12 +141,16 @@ static void ndesc_init_rx_desc(struct dma_desc *p, unsigned int ring_size,
 	}
 }
 
-static void ndesc_init_tx_desc(struct dma_desc *p, unsigned int ring_size)
+static void ndesc_init_tx_desc(struct dma_desc *p, unsigned int ring_size,
+			       int mode)
 {
 	int i;
 	for (i = 0; i < ring_size; i++) {
 		p->des01.tx.own = 0;
-		ndesc_tx_set_on_ring_chain(p, (i == (ring_size - 1)));
+		if (mode == STMMAC_CHAIN_MODE)
+			ndesc_tx_set_on_chain(p, (i == (ring_size - 1)));
+		else
+			ndesc_tx_set_on_ring(p, (i == (ring_size - 1)));
 		p++;
 	}
 }
@@ -173,19 +180,25 @@ static int ndesc_get_tx_ls(struct dma_desc *p)
 	return p->des01.tx.last_segment;
 }
 
-static void ndesc_release_tx_desc(struct dma_desc *p)
+static void ndesc_release_tx_desc(struct dma_desc *p, int mode)
 {
 	int ter = p->des01.tx.end_ring;
 
 	memset(p, 0, offsetof(struct dma_desc, des2));
-	ndesc_end_tx_desc(p, ter);
+	if (mode == STMMAC_CHAIN_MODE)
+		ndesc_end_tx_desc_on_chain(p, ter);
+	else
+		ndesc_end_tx_desc_on_ring(p, ter);
 }
 
 static void ndesc_prepare_tx_desc(struct dma_desc *p, int is_fs, int len,
-				  int csum_flag)
+				  int csum_flag, int mode)
 {
 	p->des01.tx.first_segment = is_fs;
-	norm_set_tx_desc_len(p, len);
+	if (mode == STMMAC_CHAIN_MODE)
+		norm_set_tx_desc_len_on_chain(p, len);
+	else
+		norm_set_tx_desc_len_on_ring(p, len);
 
 	if (likely(csum_flag))
 		p->des01.tx.checksum_insertion = cic_full;
diff --git a/drivers/net/ethernet/stmicro/stmmac/ring_mode.c b/drivers/net/ethernet/stmicro/stmmac/ring_mode.c
index 4b785e1..8a5e661 100644
--- a/drivers/net/ethernet/stmicro/stmmac/ring_mode.c
+++ b/drivers/net/ethernet/stmicro/stmmac/ring_mode.c
@@ -49,8 +49,8 @@ static unsigned int stmmac_jumbo_frm(void *p, struct sk_buff *skb, int csum)
 		desc->des2 = dma_map_single(priv->device, skb->data,
 					    bmax, DMA_TO_DEVICE);
 		desc->des3 = desc->des2 + BUF_SIZE_4KiB;
-		priv->hw->desc->prepare_tx_desc(desc, 1, bmax,
-						csum);
+		priv->hw->desc->prepare_tx_desc(desc, 1, bmax, csum,
+						STMMAC_RING_MODE);
 		wmb();
 		entry = (++priv->cur_tx) % txsize;
 		desc = priv->dma_tx + entry;
@@ -58,7 +58,8 @@ static unsigned int stmmac_jumbo_frm(void *p, struct sk_buff *skb, int csum)
 		desc->des2 = dma_map_single(priv->device, skb->data + bmax,
 					    len, DMA_TO_DEVICE);
 		desc->des3 = desc->des2 + BUF_SIZE_4KiB;
-		priv->hw->desc->prepare_tx_desc(desc, 0, len, csum);
+		priv->hw->desc->prepare_tx_desc(desc, 0, len, csum,
+						STMMAC_RING_MODE);
 		wmb();
 		priv->hw->desc->set_tx_owner(desc);
 		priv->tx_skbuff[entry] = NULL;
@@ -66,7 +67,8 @@ static unsigned int stmmac_jumbo_frm(void *p, struct sk_buff *skb, int csum)
 		desc->des2 = dma_map_single(priv->device, skb->data,
 					    nopaged_len, DMA_TO_DEVICE);
 		desc->des3 = desc->des2 + BUF_SIZE_4KiB;
-		priv->hw->desc->prepare_tx_desc(desc, 1, nopaged_len, csum);
+		priv->hw->desc->prepare_tx_desc(desc, 1, nopaged_len, csum,
+						STMMAC_RING_MODE);
 	}
 
 	return entry;
@@ -89,17 +91,10 @@ static void stmmac_refill_desc3(int bfsize, struct dma_desc *p)
 		p->des3 = p->des2 + BUF_SIZE_8KiB;
 }
 
-/* In ring mode we need to fill the desc3 because it is used
- * as buffer */
-static void stmmac_init_desc3(int des3_as_data_buf, struct dma_desc *p)
-{
-	if (unlikely(des3_as_data_buf))
-		p->des3 = p->des2 + BUF_SIZE_8KiB;
-}
-
-static void stmmac_init_dma_chain(struct dma_desc *des, dma_addr_t phy_addr,
-				  unsigned int size)
+/* In ring mode we need to fill the desc3 because it is used as buffer */
+static void stmmac_init_desc3(struct dma_desc *p)
 {
+	p->des3 = p->des2 + BUF_SIZE_8KiB;
 }
 
 static void stmmac_clean_desc3(struct dma_desc *p)
@@ -121,7 +116,6 @@ const struct stmmac_ring_mode_ops ring_mode_ops = {
 	.jumbo_frm = stmmac_jumbo_frm,
 	.refill_desc3 = stmmac_refill_desc3,
 	.init_desc3 = stmmac_init_desc3,
-	.init_dma_chain = stmmac_init_dma_chain,
 	.clean_desc3 = stmmac_clean_desc3,
 	.set_16kib_bfsize = stmmac_set_16kib_bfsize,
 };
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac.h b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
index b05df89..e5f2f33 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac.h
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
@@ -93,6 +93,7 @@ struct stmmac_priv {
 	u32 tx_coal_timer;
 	int use_riwt;
 	u32 rx_riwt;
+	unsigned int mode;
 };
 
 extern int phyaddr;
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index d02b446..bbee6b3 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -130,6 +130,13 @@ module_param(eee_timer, int, S_IRUGO | S_IWUSR);
 MODULE_PARM_DESC(eee_timer, "LPI tx expiration time in msec");
 #define STMMAC_LPI_TIMER(x) (jiffies + msecs_to_jiffies(x))
 
+/* By default the driver will use the ring mode to manage tx and rx descriptors
+ * but passing this value so user can force to use the chain instead of the ring
+ */
+static unsigned int chain_mode;
+module_param(chain_mode, int, S_IRUGO);
+MODULE_PARM_DESC(chain_mode, "To use chain instead of ring mode");
+
 static irqreturn_t stmmac_interrupt(int irq, void *dev_id);
 
 #ifdef CONFIG_STMMAC_DEBUG_FS
@@ -514,17 +521,15 @@ static void init_dma_desc_rings(struct net_device *dev)
 	struct sk_buff *skb;
 	unsigned int txsize = priv->dma_tx_size;
 	unsigned int rxsize = priv->dma_rx_size;
-	unsigned int bfsize;
+	unsigned int bfsize = 0;
 	int dis_ic = 0;
-	int des3_as_data_buf = 0;
 
 	/* Set the max buffer size according to the DESC mode
 	 * and the MTU. Note that RING mode allows 16KiB bsize. */
-	bfsize = priv->hw->ring->set_16kib_bfsize(dev->mtu);
+	if (priv->mode == STMMAC_RING_MODE)
+		bfsize = priv->hw->ring->set_16kib_bfsize(dev->mtu);
 
-	if (bfsize == BUF_SIZE_16KiB)
-		des3_as_data_buf = 1;
-	else
+	if (bfsize < BUF_SIZE_16KiB)
 		bfsize = stmmac_set_bfsize(dev->mtu, priv->dma_buf_sz);
 
 	DBG(probe, INFO, "stmmac: txsize %d, rxsize %d, bfsize %d\n",
@@ -571,7 +576,9 @@ static void init_dma_desc_rings(struct net_device *dev)
 
 		p->des2 = priv->rx_skbuff_dma[i];
 
-		priv->hw->ring->init_desc3(des3_as_data_buf, p);
+		if ((priv->mode == STMMAC_RING_MODE) &&
+		    (bfsize == BUF_SIZE_16KiB))
+			priv->hw->ring->init_desc3(p);
 
 		DBG(probe, INFO, "[%p]\t[%p]\t[%x]\n", priv->rx_skbuff[i],
 			priv->rx_skbuff[i]->data, priv->rx_skbuff_dma[i]);
@@ -589,17 +596,20 @@ static void init_dma_desc_rings(struct net_device *dev)
 
 	/* In case of Chained mode this sets the des3 to the next
 	 * element in the chain */
-	priv->hw->ring->init_dma_chain(priv->dma_rx, priv->dma_rx_phy, rxsize);
-	priv->hw->ring->init_dma_chain(priv->dma_tx, priv->dma_tx_phy, txsize);
-
+	if (priv->mode == STMMAC_CHAIN_MODE) {
+		priv->hw->chain->init_dma_chain(priv->dma_rx, priv->dma_rx_phy,
+						rxsize);
+		priv->hw->chain->init_dma_chain(priv->dma_tx, priv->dma_tx_phy,
+						txsize);
+	}
 	priv->dirty_tx = 0;
 	priv->cur_tx = 0;
 
 	if (priv->use_riwt)
 		dis_ic = 1;
 	/* Clear the Rx/Tx descriptors */
-	priv->hw->desc->init_rx_desc(priv->dma_rx, rxsize, dis_ic);
-	priv->hw->desc->init_tx_desc(priv->dma_tx, txsize);
+	priv->hw->desc->init_rx_desc(priv->dma_rx, rxsize, dis_ic, priv->mode);
+	priv->hw->desc->init_tx_desc(priv->dma_tx, txsize, priv->mode);
 
 	if (netif_msg_hw(priv)) {
 		pr_info("RX descriptor ring:\n");
@@ -726,14 +736,15 @@ static void stmmac_tx_clean(struct stmmac_priv *priv)
 			dma_unmap_single(priv->device, p->des2,
 					 priv->hw->desc->get_tx_len(p),
 					 DMA_TO_DEVICE);
-		priv->hw->ring->clean_desc3(p);
+		if (priv->mode == STMMAC_RING_MODE)
+			priv->hw->ring->clean_desc3(p);
 
 		if (likely(skb != NULL)) {
 			dev_kfree_skb(skb);
 			priv->tx_skbuff[entry] = NULL;
 		}
 
-		priv->hw->desc->release_tx_desc(p);
+		priv->hw->desc->release_tx_desc(p, priv->mode);
 
 		priv->dirty_tx++;
 	}
@@ -778,7 +789,8 @@ static void stmmac_tx_err(struct stmmac_priv *priv)
 
 	priv->hw->dma->stop_tx(priv->ioaddr);
 	dma_free_tx_skbufs(priv);
-	priv->hw->desc->init_tx_desc(priv->dma_tx, priv->dma_tx_size);
+	priv->hw->desc->init_tx_desc(priv->dma_tx, priv->dma_tx_size,
+				     priv->mode);
 	priv->dirty_tx = 0;
 	priv->cur_tx = 0;
 	priv->hw->dma->start_tx(priv->ioaddr);
@@ -1190,7 +1202,7 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct stmmac_priv *priv = netdev_priv(dev);
 	unsigned int txsize = priv->dma_tx_size;
 	unsigned int entry;
-	int i, csum_insertion = 0;
+	int i, csum_insertion = 0, is_jumbo = 0;
 	int nfrags = skb_shinfo(skb)->nr_frags;
 	struct dma_desc *desc, *first;
 	unsigned int nopaged_len = skb_headlen(skb);
@@ -1236,15 +1248,27 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 #endif
 	priv->tx_skbuff[entry] = skb;
 
-	if (priv->hw->ring->is_jumbo_frm(skb->len, priv->plat->enh_desc)) {
-		entry = priv->hw->ring->jumbo_frm(priv, skb, csum_insertion);
-		desc = priv->dma_tx + entry;
+	/* To program the descriptors according to the size of the frame */
+	if (priv->mode == STMMAC_RING_MODE) {
+		is_jumbo = priv->hw->ring->is_jumbo_frm(skb->len,
+							priv->plat->enh_desc);
+		if (unlikely(is_jumbo))
+			entry = priv->hw->ring->jumbo_frm(priv, skb,
+							  csum_insertion);
 	} else {
+		is_jumbo = priv->hw->chain->is_jumbo_frm(skb->len,
+							priv->plat->enh_desc);
+		if (unlikely(is_jumbo))
+			entry = priv->hw->chain->jumbo_frm(priv, skb,
+							   csum_insertion);
+	}
+	if (likely(!is_jumbo)) {
 		desc->des2 = dma_map_single(priv->device, skb->data,
 					nopaged_len, DMA_TO_DEVICE);
 		priv->hw->desc->prepare_tx_desc(desc, 1, nopaged_len,
-						csum_insertion);
-	}
+						csum_insertion, priv->mode);
+	} else
+		desc = priv->dma_tx + entry;
 
 	for (i = 0; i < nfrags; i++) {
 		const skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
@@ -1257,7 +1281,8 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 		desc->des2 = skb_frag_dma_map(priv->device, frag, 0, len,
 					      DMA_TO_DEVICE);
 		priv->tx_skbuff[entry] = NULL;
-		priv->hw->desc->prepare_tx_desc(desc, 0, len, csum_insertion);
+		priv->hw->desc->prepare_tx_desc(desc, 0, len, csum_insertion,
+						priv->mode);
 		wmb();
 		priv->hw->desc->set_tx_owner(desc);
 		wmb();
@@ -1338,7 +1363,8 @@ static inline void stmmac_rx_refill(struct stmmac_priv *priv)
 
 			(p + entry)->des2 = priv->rx_skbuff_dma[entry];
 
-			if (unlikely(priv->plat->has_gmac))
+			if (unlikely((priv->mode == STMMAC_RING_MODE) &&
+				     (priv->plat->has_gmac)))
 				priv->hw->ring->refill_desc3(bfsize, p + entry);
 
 			RX_DBG(KERN_INFO "\trefill entry #%d\n", entry);
@@ -1884,12 +1910,20 @@ static int stmmac_hw_init(struct stmmac_priv *priv)
 
 	priv->hw = mac;
 
-	/* To use the chained or ring mode */
-	priv->hw->ring = &ring_mode_ops;
-
 	/* Get and dump the chip ID */
 	priv->synopsys_id = stmmac_get_synopsys_id(priv);
 
+	/* To use the chained or ring mode */
+	if (chain_mode)	{
+		priv->hw->chain = &chain_mode_ops;
+		pr_info(" Chain mode enabled\n");
+		priv->mode = STMMAC_CHAIN_MODE;
+	} else {
+		priv->hw->ring = &ring_mode_ops;
+		pr_info(" Ring mode enabled\n");
+		priv->mode = STMMAC_RING_MODE;
+	}
+
 	/* Get the HW capability (new GMAC newer than 3.50a) */
 	priv->hw_cap_support = stmmac_get_hw_features(priv);
 	if (priv->hw_cap_support) {
@@ -2109,8 +2143,9 @@ int stmmac_suspend(struct net_device *ndev)
 	priv->hw->dma->stop_rx(priv->ioaddr);
 	/* Clear the Rx/Tx descriptors */
 	priv->hw->desc->init_rx_desc(priv->dma_rx, priv->dma_rx_size,
-				     dis_ic);
-	priv->hw->desc->init_tx_desc(priv->dma_tx, priv->dma_tx_size);
+				     dis_ic, priv->mode);
+	priv->hw->desc->init_tx_desc(priv->dma_tx, priv->dma_tx_size,
+				     priv->mode);
 
 	/* Enable Power down mode by programming the PMT regs */
 	if (device_may_wakeup(priv->device))
@@ -2249,6 +2284,9 @@ static int __init stmmac_cmdline_opt(char *str)
 		} else if (!strncmp(opt, "eee_timer:", 10)) {
 			if (kstrtoint(opt + 10, 0, &eee_timer))
 				goto err;
+		} else if (!strncmp(opt, "chain_mode:", 11)) {
+			if (kstrtoint(opt + 11, 0, &chain_mode))
+				goto err;
 		}
 	}
 	return 0;
-- 
1.7.4.4
