From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [net-next 1/5] stmmac: add CHAINED descriptor mode support (V2)
Date: Wed, 12 Oct 2011 15:38:04 +0200
Message-ID: <1318426688-9419-2-git-send-email-peppe.cavallaro@st.com>
References: <1318426688-9419-1-git-send-email-peppe.cavallaro@st.com>
Cc: davem@davemloft.net, Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	Rayagond Kokatanur <rayagond@vayavyalabs.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog113.obsmtp.com ([207.126.144.135]:37976 "EHLO
	eu1sys200aog113.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752857Ab1JLNi0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Oct 2011 09:38:26 -0400
In-Reply-To: <1318426688-9419-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch enhances the STMMAC driver to support CHAINED mode of
descriptor (useful also on validation side).

STMMAC supports DMA descriptor to operate both in dual buffer(RING)
and linked-list(CHAINED) mode. In RING mode (default) each descriptor
points to two data buffer pointers whereas in CHAINED mode they point
to only one data buffer pointer.

In CHAINED mode each descriptor will have pointer to next descriptor in
the list, hence creating the explicit chaining in the descriptor itself,
whereas such explicit chaining is not possible in RING mode.

First version of this work has been done by Rayagond; I've reworked
the whole support and added a new header file to implement the
helper routines specialised for chained/ring modes (as D. Miller
suggested).

Signed-off-by: Rayagond Kokatanur <rayagond@vayavyalabs.com>
Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/Kconfig       |   18 +
 drivers/net/ethernet/stmicro/stmmac/common.h      |   19 +
 drivers/net/ethernet/stmicro/stmmac/enh_desc.c    |   51 ---
 drivers/net/ethernet/stmicro/stmmac/norm_desc.c   |   42 --
 drivers/net/ethernet/stmicro/stmmac/ring_mode.h   |  450 +++++++++++++++++++++
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |  121 ++----
 6 files changed, 531 insertions(+), 170 deletions(-)
 create mode 100644 drivers/net/ethernet/stmicro/stmmac/ring_mode.h

diff --git a/drivers/net/ethernet/stmicro/stmmac/Kconfig b/drivers/net/ethernet/stmicro/stmmac/Kconfig
index 8cd9dde..ac6f190 100644
--- a/drivers/net/ethernet/stmicro/stmmac/Kconfig
+++ b/drivers/net/ethernet/stmicro/stmmac/Kconfig
@@ -63,4 +63,22 @@ config STMMAC_RTC_TIMER
 
 endchoice
 
+choice
+	prompt "Select the DMA TX/RX descriptor operating modes"
+	depends on STMMAC_ETH
+	---help---
+	  This driver supports DMA descriptor to operate both in dual buffer
+	  (RING) and linked-list(CHAINED) mode. In RING mode each descriptor
+	  points to two data buffer pointers whereas in CHAINED mode they
+	  points to only one data buffer pointer.
+
+config STMMAC_RING
+	bool "Enable Descriptor Ring Mode"
+
+config STMMAC_CHAINED
+	bool "Enable Descriptor Chained Mode"
+
+endchoice
+
+
 endif
diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
index 22c61b2..90ba81a 100644
--- a/drivers/net/ethernet/stmicro/stmmac/common.h
+++ b/drivers/net/ethernet/stmicro/stmmac/common.h
@@ -152,6 +152,7 @@ struct dma_features {
 #define BUF_SIZE_8KiB 8192
 #define BUF_SIZE_4KiB 4096
 #define BUF_SIZE_2KiB 2048
+#define DMA_BUFFER_SIZE	BUF_SIZE_2KiB
 
 /* Power Down and WOL */
 #define PMT_NOT_SUPPORTED 0
@@ -261,6 +262,7 @@ struct mac_device_info {
 	const struct stmmac_ops		*mac;
 	const struct stmmac_desc_ops	*desc;
 	const struct stmmac_dma_ops	*dma;
+	const struct stmmac_ring_mode_ops	*ring;
 	struct mii_regs mii;	/* MII register Addresses */
 	struct mac_link link;
 	unsigned int synopsys_uid;
@@ -274,3 +276,20 @@ extern void stmmac_set_mac_addr(void __iomem *ioaddr, u8 addr[6],
 extern void stmmac_get_mac_addr(void __iomem *ioaddr, unsigned char *addr,
 				unsigned int high, unsigned int low);
 extern void dwmac_dma_flush_tx_fifo(void __iomem *ioaddr);
+
+extern void ndesc_init_rx_desc(struct dma_desc *p, unsigned int ring_size,
+			       int disable_rx_ic);
+extern void enh_desc_prepare_tx_desc(struct dma_desc *p, int is_fs, int len,
+				     int csum_flag);
+extern void enh_desc_release_tx_desc(struct dma_desc *p);
+extern void enh_desc_init_tx_desc(struct dma_desc *p, unsigned int ring_size);
+extern void enh_desc_init_rx_desc(struct dma_desc *p, unsigned int ring_size,
+				  int disable_rx_ic);
+extern void ndesc_prepare_tx_desc(struct dma_desc *p, int is_fs, int len,
+				  int csum_flag);
+extern void ndesc_release_tx_desc(struct dma_desc *p);
+extern void ndesc_init_tx_desc(struct dma_desc *p, unsigned int ring_size);
+extern void ndesc_init_rx_desc(struct dma_desc *p, unsigned int ring_size,
+			       int disable_rx_ic);
+
+
diff --git a/drivers/net/ethernet/stmicro/stmmac/enh_desc.c b/drivers/net/ethernet/stmicro/stmmac/enh_desc.c
index e5dfb6a..f378b3b 100644
--- a/drivers/net/ethernet/stmicro/stmmac/enh_desc.c
+++ b/drivers/net/ethernet/stmicro/stmmac/enh_desc.c
@@ -226,35 +226,6 @@ static int enh_desc_get_rx_status(void *data, struct stmmac_extra_stats *x,
 	return ret;
 }
 
-static void enh_desc_init_rx_desc(struct dma_desc *p, unsigned int ring_size,
-				  int disable_rx_ic)
-{
-	int i;
-	for (i = 0; i < ring_size; i++) {
-		p->des01.erx.own = 1;
-		p->des01.erx.buffer1_size = BUF_SIZE_8KiB - 1;
-		/* To support jumbo frames */
-		p->des01.erx.buffer2_size = BUF_SIZE_8KiB - 1;
-		if (i == ring_size - 1)
-			p->des01.erx.end_ring = 1;
-		if (disable_rx_ic)
-			p->des01.erx.disable_ic = 1;
-		p++;
-	}
-}
-
-static void enh_desc_init_tx_desc(struct dma_desc *p, unsigned int ring_size)
-{
-	int i;
-
-	for (i = 0; i < ring_size; i++) {
-		p->des01.etx.own = 0;
-		if (i == ring_size - 1)
-			p->des01.etx.end_ring = 1;
-		p++;
-	}
-}
-
 static int enh_desc_get_tx_owner(struct dma_desc *p)
 {
 	return p->des01.etx.own;
@@ -280,28 +251,6 @@ static int enh_desc_get_tx_ls(struct dma_desc *p)
 	return p->des01.etx.last_segment;
 }
 
-static void enh_desc_release_tx_desc(struct dma_desc *p)
-{
-	int ter = p->des01.etx.end_ring;
-
-	memset(p, 0, offsetof(struct dma_desc, des2));
-	p->des01.etx.end_ring = ter;
-}
-
-static void enh_desc_prepare_tx_desc(struct dma_desc *p, int is_fs, int len,
-				     int csum_flag)
-{
-	p->des01.etx.first_segment = is_fs;
-	if (unlikely(len > BUF_SIZE_4KiB)) {
-		p->des01.etx.buffer1_size = BUF_SIZE_4KiB;
-		p->des01.etx.buffer2_size = len - BUF_SIZE_4KiB;
-	} else {
-		p->des01.etx.buffer1_size = len;
-	}
-	if (likely(csum_flag))
-		p->des01.etx.checksum_insertion = cic_full;
-}
-
 static void enh_desc_clear_tx_ic(struct dma_desc *p)
 {
 	p->des01.etx.interrupt = 0;
diff --git a/drivers/net/ethernet/stmicro/stmmac/norm_desc.c b/drivers/net/ethernet/stmicro/stmmac/norm_desc.c
index 029c2a2..1cd985f 100644
--- a/drivers/net/ethernet/stmicro/stmmac/norm_desc.c
+++ b/drivers/net/ethernet/stmicro/stmmac/norm_desc.c
@@ -119,32 +119,6 @@ static int ndesc_get_rx_status(void *data, struct stmmac_extra_stats *x,
 	return ret;
 }
 
-static void ndesc_init_rx_desc(struct dma_desc *p, unsigned int ring_size,
-			       int disable_rx_ic)
-{
-	int i;
-	for (i = 0; i < ring_size; i++) {
-		p->des01.rx.own = 1;
-		p->des01.rx.buffer1_size = BUF_SIZE_2KiB - 1;
-		if (i == ring_size - 1)
-			p->des01.rx.end_ring = 1;
-		if (disable_rx_ic)
-			p->des01.rx.disable_ic = 1;
-		p++;
-	}
-}
-
-static void ndesc_init_tx_desc(struct dma_desc *p, unsigned int ring_size)
-{
-	int i;
-	for (i = 0; i < ring_size; i++) {
-		p->des01.tx.own = 0;
-		if (i == ring_size - 1)
-			p->des01.tx.end_ring = 1;
-		p++;
-	}
-}
-
 static int ndesc_get_tx_owner(struct dma_desc *p)
 {
 	return p->des01.tx.own;
@@ -170,22 +144,6 @@ static int ndesc_get_tx_ls(struct dma_desc *p)
 	return p->des01.tx.last_segment;
 }
 
-static void ndesc_release_tx_desc(struct dma_desc *p)
-{
-	int ter = p->des01.tx.end_ring;
-
-	memset(p, 0, offsetof(struct dma_desc, des2));
-	/* set termination field */
-	p->des01.tx.end_ring = ter;
-}
-
-static void ndesc_prepare_tx_desc(struct dma_desc *p, int is_fs, int len,
-				  int csum_flag)
-{
-	p->des01.tx.first_segment = is_fs;
-	p->des01.tx.buffer1_size = len;
-}
-
 static void ndesc_clear_tx_ic(struct dma_desc *p)
 {
 	p->des01.tx.interrupt = 0;
diff --git a/drivers/net/ethernet/stmicro/stmmac/ring_mode.h b/drivers/net/ethernet/stmicro/stmmac/ring_mode.h
new file mode 100644
index 0000000..32fe688
--- /dev/null
+++ b/drivers/net/ethernet/stmicro/stmmac/ring_mode.h
@@ -0,0 +1,450 @@
+/*******************************************************************************
+  Header File to describe the DMA descriptor ring/chain(s)
+
+  Copyright(C) 2011  STMicroelectronics Ltd
+
+  It defines all the functions used to handle the normal/enhanced
+  descriptors in case of the DMA is configured to work in chained or
+  in ring mode.
+
+  This program is free software; you can redistribute it and/or modify it
+  under the terms and conditions of the GNU General Public License,
+  version 2, as published by the Free Software Foundation.
+
+  This program is distributed in the hope it will be useful, but WITHOUT
+  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+  more details.
+
+  You should have received a copy of the GNU General Public License along with
+  this program; if not, write to the Free Software Foundation, Inc.,
+  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+
+  The full GNU General Public License is included in this distribution in
+  the file called "COPYING".
+
+  Author: Giuseppe Cavallaro <peppe.cavallaro@st.com>
+*******************************************************************************/
+
+#if defined(CONFIG_STMMAC_RING)
+
+static unsigned int stmmac_jumbo_frm(struct stmmac_priv *priv,
+				     struct sk_buff *skb, int csum_insertion)
+{
+	unsigned int txsize = priv->dma_tx_size;
+	unsigned int entry = priv->cur_tx % txsize;
+	struct dma_desc *desc = priv->dma_tx + entry;
+	unsigned int nopaged_len = skb_headlen(skb);
+	unsigned int buf_max_size, len;
+
+	if (priv->plat->enh_desc)
+		buf_max_size = BUF_SIZE_8KiB;
+	else
+		buf_max_size = BUF_SIZE_2KiB;
+
+	len = nopaged_len - buf_max_size;
+
+	if (nopaged_len > BUF_SIZE_8KiB) {
+
+		desc->des2 = dma_map_single(priv->device, skb->data,
+					    buf_max_size, DMA_TO_DEVICE);
+		desc->des3 = desc->des2 + BUF_SIZE_4KiB;
+		priv->hw->desc->prepare_tx_desc(desc, 1, buf_max_size,
+						csum_insertion);
+
+		entry = (++priv->cur_tx) % txsize;
+		desc = priv->dma_tx + entry;
+
+		desc->des2 = dma_map_single(priv->device,
+					    skb->data + buf_max_size,
+					    len, DMA_TO_DEVICE);
+		desc->des3 = desc->des2 + BUF_SIZE_4KiB;
+		priv->hw->desc->prepare_tx_desc(desc, 0, len, csum_insertion);
+		priv->hw->desc->set_tx_owner(desc);
+		priv->tx_skbuff[entry] = NULL;
+	} else {
+		desc->des2 = dma_map_single(priv->device, skb->data,
+					    nopaged_len, DMA_TO_DEVICE);
+		desc->des3 = desc->des2 + BUF_SIZE_4KiB;
+		priv->hw->desc->prepare_tx_desc(desc, 1, nopaged_len,
+						csum_insertion);
+	}
+
+	return entry;
+}
+
+static unsigned int stmmac_is_jumbo_frame(struct stmmac_priv *priv,
+					  struct sk_buff *skb,
+					  int csum, struct dma_desc *desc)
+{
+	unsigned int ret = 0;
+
+	if (unlikely(skb->len >= BUF_SIZE_4KiB)) {
+		unsigned int entry = stmmac_jumbo_frm(priv, skb, csum);
+		desc = priv->dma_tx + entry;
+		ret = 1;
+	}
+
+	return ret;
+}
+
+static void stmmac_refill_desc3(int bfsize, struct dma_desc *p)
+{
+	/* Fill DES3 in case of RING mode */
+	if (bfsize >= BUF_SIZE_8KiB)
+		p->des3 = p->des2 + BUF_SIZE_8KiB;
+}
+
+/* In ring mode we need to fill the desc3 because it is used
+ * as buffer */
+static void stmmac_init_desc3(int des3_as_data_buf, struct dma_desc *p)
+{
+	if (unlikely(des3_as_data_buf))
+		p->des3 = p->des2 + BUF_SIZE_8KiB;
+}
+
+static void stmmac_init_dma_chain(struct dma_desc *des, dma_addr_t phy_addr,
+				  unsigned int size)
+{
+}
+
+static void stmmac_clean_desc3(struct dma_desc *p)
+{
+	if (unlikely(p->des3))
+		p->des3 = 0;
+}
+
+static int stmmac_set_bfsize(int mtu, int bufsize)
+{
+	int ret = bufsize;
+
+	if (unlikely(mtu >= BUF_SIZE_8KiB))
+		ret = BUF_SIZE_16KiB;
+	else if (unlikely(mtu >= BUF_SIZE_4KiB))
+		ret = BUF_SIZE_8KiB;
+	else if (unlikely(mtu >= BUF_SIZE_2KiB))
+		ret = BUF_SIZE_4KiB;
+	else if (unlikely(mtu >= DMA_BUFFER_SIZE))
+		ret = BUF_SIZE_2KiB;
+	else
+		ret = DMA_BUFFER_SIZE;
+
+	return ret;
+}
+
+/* Normal/enhanced descriptor functions for RING mode */
+
+inline void enh_desc_init_rx_desc(struct dma_desc *p, unsigned int ring_size,
+				  int disable_rx_ic)
+{
+	int i;
+	for (i = 0; i < ring_size; i++) {
+		p->des01.erx.own = 1;
+		p->des01.erx.buffer1_size = BUF_SIZE_8KiB - 1;
+		/* To support jumbo frames */
+		p->des01.erx.buffer2_size = BUF_SIZE_8KiB - 1;
+		if (i == (ring_size - 1))
+			p->des01.erx.end_ring = 1;
+		if (disable_rx_ic)
+			p->des01.erx.disable_ic = 1;
+		p++;
+	}
+}
+
+inline void enh_desc_init_tx_desc(struct dma_desc *p, unsigned int ring_size)
+{
+	int i;
+
+	for (i = 0; i < ring_size; i++) {
+		p->des01.etx.own = 0;
+		if (i == (ring_size - 1))
+			p->des01.etx.end_ring = 1;
+		p++;
+	}
+}
+
+inline void enh_desc_release_tx_desc(struct dma_desc *p)
+{
+	int ter = p->des01.etx.end_ring;
+
+	memset(p, 0, offsetof(struct dma_desc, des2));
+	p->des01.etx.end_ring = ter;
+}
+
+inline void enh_desc_prepare_tx_desc(struct dma_desc *p, int is_fs, int len,
+				     int csum_flag)
+{
+	p->des01.etx.first_segment = is_fs;
+
+	if (unlikely(len > BUF_SIZE_4KiB)) {
+		p->des01.etx.buffer1_size = BUF_SIZE_4KiB;
+		p->des01.etx.buffer2_size = len - BUF_SIZE_4KiB;
+	} else
+		p->des01.etx.buffer1_size = len;
+
+	if (likely(csum_flag))
+		p->des01.etx.checksum_insertion = cic_full;
+}
+
+inline void ndesc_init_rx_desc(struct dma_desc *p, unsigned int ring_size,
+			       int disable_rx_ic)
+{
+	int i;
+	for (i = 0; i < ring_size; i++) {
+		p->des01.rx.own = 1;
+		p->des01.rx.buffer1_size = BUF_SIZE_2KiB - 1;
+		p->des01.rx.buffer2_size = BUF_SIZE_2KiB - 1;
+		if (i == (ring_size - 1))
+			p->des01.rx.end_ring = 1;
+		if (disable_rx_ic)
+			p->des01.rx.disable_ic = 1;
+		p++;
+	}
+}
+
+inline void ndesc_init_tx_desc(struct dma_desc *p, unsigned int ring_size)
+{
+	int i;
+	for (i = 0; i < ring_size; i++) {
+		p->des01.tx.own = 0;
+		if (i == (ring_size - 1))
+			p->des01.tx.end_ring = 1;
+		p++;
+	}
+}
+
+inline void ndesc_release_tx_desc(struct dma_desc *p)
+{
+	int ter = p->des01.tx.end_ring;
+
+	memset(p, 0, offsetof(struct dma_desc, des2));
+	/* set termination field */
+	p->des01.tx.end_ring = ter;
+}
+
+inline void ndesc_prepare_tx_desc(struct dma_desc *p, int is_fs, int len,
+				  int csum_flag)
+{
+	p->des01.tx.first_segment = is_fs;
+
+	if (unlikely(len > BUF_SIZE_2KiB)) {
+		p->des01.etx.buffer1_size = BUF_SIZE_2KiB - 1;
+		p->des01.etx.buffer2_size = len - p->des01.etx.buffer1_size;
+	} else
+		p->des01.tx.buffer1_size = len;
+}
+
+#else
+
+/* Chained mode functions */
+
+static unsigned int stmmac_jumbo_frm(struct stmmac_priv *priv,
+				     struct sk_buff *skb, int csum_insertion)
+{
+	unsigned int txsize = priv->dma_tx_size;
+	unsigned int entry = priv->cur_tx % txsize;
+	struct dma_desc *desc = priv->dma_tx + entry;
+	unsigned int nopaged_len = skb_headlen(skb);
+	unsigned int buf_max_size;
+	unsigned int i = 1, len;
+
+	if (priv->plat->enh_desc)
+		buf_max_size = BUF_SIZE_8KiB;
+	else
+		buf_max_size = BUF_SIZE_2KiB;
+
+	len = nopaged_len - buf_max_size;
+
+	desc->des2 = dma_map_single(priv->device, skb->data,
+				    buf_max_size, DMA_TO_DEVICE);
+	priv->hw->desc->prepare_tx_desc(desc, 1, buf_max_size, csum_insertion);
+
+	while (len != 0) {
+		entry = (++priv->cur_tx) % txsize;
+		desc = priv->dma_tx + entry;
+
+		if (len > buf_max_size) {
+			desc->des2 = dma_map_single(priv->device,
+						    (skb->data +
+						     buf_max_size * i),
+						    buf_max_size,
+						    DMA_TO_DEVICE);
+			priv->hw->desc->prepare_tx_desc(desc, 0, buf_max_size,
+							csum_insertion);
+			priv->hw->desc->set_tx_owner(desc);
+			priv->tx_skbuff[entry] = NULL;
+			len -= buf_max_size;
+			i++;
+		} else {
+			desc->des2 = dma_map_single(priv->device,
+						    (skb->data +
+						     buf_max_size * i), len,
+						    DMA_TO_DEVICE);
+			priv->hw->desc->prepare_tx_desc(desc, 0, len,
+							csum_insertion);
+			priv->hw->desc->set_tx_owner(desc);
+			priv->tx_skbuff[entry] = NULL;
+			len = 0;
+		}
+	}
+	return entry;
+}
+
+static unsigned int stmmac_is_jumbo_frame(struct stmmac_priv *priv,
+					  struct sk_buff *skb,
+					  int csum, struct dma_desc *desc)
+{
+	unsigned int ret = 0;
+
+	if ((priv->plat->enh_desc && unlikely(skb->len > BUF_SIZE_8KiB)) ||
+	    (!priv->plat->enh_desc && unlikely(skb->len > BUF_SIZE_2KiB))) {
+		unsigned int entry = stmmac_jumbo_frm(priv, skb, csum);
+		desc = priv->dma_tx + entry;
+		ret = 1;
+	}
+
+	return ret;
+}
+
+static void stmmac_refill_desc3(int bfsize, struct dma_desc *p)
+{
+}
+
+static void stmmac_init_desc3(int des3_as_data_buf, struct dma_desc *p)
+{
+}
+
+static void stmmac_clean_desc3(struct dma_desc *p)
+{
+}
+
+/* In chained mode des3 points to the next element in the ring.
+ * The latest element has to point to the head.
+ */
+static void stmmac_init_dma_chain(struct dma_desc *des, dma_addr_t phy_addr,
+				  unsigned int size)
+{
+	int i;
+	struct dma_desc *p = des;
+	dma_addr_t dma_phy = phy_addr;
+
+	for (i = 0; i < (size - 1); i++) {
+		dma_phy += sizeof(struct dma_desc);
+		p->des3 = (unsigned int)dma_phy;
+		p++;
+	}
+	p->des3 = (unsigned int)phy_addr;
+}
+
+static int stmmac_set_bfsize(int mtu, int bufsize)
+{
+	int ret = bufsize;
+
+	if (unlikely(mtu >= BUF_SIZE_4KiB))
+		ret = BUF_SIZE_8KiB;
+	else if (unlikely(mtu >= BUF_SIZE_2KiB))
+		ret = BUF_SIZE_4KiB;
+	else if (unlikely(mtu >= DMA_BUFFER_SIZE))
+		ret = BUF_SIZE_2KiB;
+	else
+		ret = DMA_BUFFER_SIZE;
+
+	return ret;
+}
+
+/* Normal/enhanced descriptor functions for RING mode */
+
+inline void enh_desc_init_rx_desc(struct dma_desc *p, unsigned int ring_size,
+				  int disable_rx_ic)
+{
+	int i;
+	for (i = 0; i < ring_size; i++) {
+		p->des01.erx.own = 1;
+		p->des01.erx.buffer1_size = BUF_SIZE_8KiB - 1;
+		/* To support jumbo frames */
+		p->des01.erx.second_address_chained = 1;
+		if (disable_rx_ic)
+			p->des01.erx.disable_ic = 1;
+		p++;
+	}
+}
+
+inline void enh_desc_init_tx_desc(struct dma_desc *p, unsigned int ring_size)
+{
+	int i;
+
+	for (i = 0; i < ring_size; i++) {
+		p->des01.etx.own = 0;
+		p->des01.etx.second_address_chained = 1;
+		p++;
+	}
+}
+
+inline void enh_desc_release_tx_desc(struct dma_desc *p)
+{
+	memset(p, 0, offsetof(struct dma_desc, des2));
+	p->des01.etx.second_address_chained = 1;
+}
+
+inline void enh_desc_prepare_tx_desc(struct dma_desc *p, int is_fs, int len,
+				     int csum_flag)
+{
+	p->des01.etx.first_segment = is_fs;
+	p->des01.etx.buffer1_size = len;
+
+	if (likely(csum_flag))
+		p->des01.etx.checksum_insertion = cic_full;
+}
+
+inline void ndesc_init_rx_desc(struct dma_desc *p, unsigned int ring_size,
+			       int disable_rx_ic)
+{
+	int i;
+	for (i = 0; i < ring_size; i++) {
+		p->des01.rx.own = 1;
+		p->des01.rx.buffer1_size = BUF_SIZE_2KiB - 1;
+		p->des01.rx.buffer2_size = BUF_SIZE_2KiB - 1;
+		if (i == (ring_size - 1))
+			p->des01.rx.end_ring = 1;
+		if (disable_rx_ic)
+			p->des01.rx.disable_ic = 1;
+		p++;
+	}
+}
+
+inline void ndesc_init_tx_desc(struct dma_desc *p, unsigned int ring_size)
+{
+	int i;
+	for (i = 0; i < ring_size; i++) {
+		p->des01.tx.own = 0;
+		if (i == (ring_size - 1))
+			p->des01.tx.end_ring = 1;
+		p++;
+	}
+}
+
+inline void ndesc_release_tx_desc(struct dma_desc *p)
+{
+	memset(p, 0, offsetof(struct dma_desc, des2));
+	p->des01.tx.second_address_chained = 1;
+}
+
+inline void ndesc_prepare_tx_desc(struct dma_desc *p, int is_fs, int len,
+				  int csum_flag)
+{
+	p->des01.tx.first_segment = is_fs;
+	p->des01.tx.buffer1_size = len;
+}
+#endif
+
+struct stmmac_ring_mode_ops {
+	unsigned int (*is_jumbo_frame) (struct stmmac_priv *priv,
+					struct sk_buff *skb,
+					int csum, struct dma_desc *desc);
+	void (*refill_desc3) (int bfsize, struct dma_desc *p);
+	void (*init_desc3) (int des3_as_data_buf, struct dma_desc *p);
+	void (*init_dma_chain) (struct dma_desc *des, dma_addr_t phy_addr,
+				unsigned int size);
+	void (*clean_desc3) (struct dma_desc *p);
+	int (*set_bfsize) (int mtu, int bufsize);
+};
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index c0ee6b6..ba7af2c 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -2,7 +2,7 @@
   This is the driver for the ST MAC 10/100/1000 on-chip Ethernet controllers.
   ST Ethernet IPs are built around a Synopsys IP Core.
 
-  Copyright (C) 2007-2009  STMicroelectronics Ltd
+	Copyright(C) 2007-2011 STMicroelectronics Ltd
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
@@ -47,11 +47,12 @@
 #include <linux/dma-mapping.h>
 #include <linux/slab.h>
 #include <linux/prefetch.h>
-#include "stmmac.h"
 #ifdef CONFIG_STMMAC_DEBUG_FS
 #include <linux/debugfs.h>
 #include <linux/seq_file.h>
 #endif
+#include "stmmac.h"
+#include "ring_mode.h"
 
 #define STMMAC_RESOURCE_NAME	"stmmaceth"
 
@@ -131,7 +132,6 @@ module_param(tmrate, int, S_IRUGO | S_IWUSR);
 MODULE_PARM_DESC(tmrate, "External timer freq. (default: 256Hz)");
 #endif
 
-#define DMA_BUFFER_SIZE	BUF_SIZE_2KiB
 static int buf_sz = DMA_BUFFER_SIZE;
 module_param(buf_sz, int, S_IRUGO | S_IWUSR);
 MODULE_PARM_DESC(buf_sz, "DMA buffer size");
@@ -142,6 +142,16 @@ static const u32 default_msg_level = (NETIF_MSG_DRV | NETIF_MSG_PROBE |
 
 static irqreturn_t stmmac_interrupt(int irq, void *dev_id);
 
+/* Functions used for chained/ring modes */
+static const struct stmmac_ring_mode_ops ring_mode_ops = {
+	.is_jumbo_frame = stmmac_is_jumbo_frame,
+	.refill_desc3 = stmmac_refill_desc3,
+	.init_desc3 = stmmac_init_desc3,
+	.init_dma_chain = stmmac_init_dma_chain,
+	.clean_desc3 = stmmac_clean_desc3,
+	.set_bfsize = stmmac_set_bfsize,
+};
+
 /**
  * stmmac_verify_args - verify the driver parameters.
  * Description: it verifies if some wrong parameter is passed to the driver.
@@ -385,7 +395,8 @@ static void display_ring(struct dma_desc *p, int size)
  * init_dma_desc_rings - init the RX/TX descriptor rings
  * @dev: net device structure
  * Description:  this function initializes the DMA RX/TX descriptors
- * and allocates the socket buffers.
+ * and allocates the socket buffers. It suppors the chained and ring
+ * modes.
  */
 static void init_dma_desc_rings(struct net_device *dev)
 {
@@ -394,31 +405,22 @@ static void init_dma_desc_rings(struct net_device *dev)
 	struct sk_buff *skb;
 	unsigned int txsize = priv->dma_tx_size;
 	unsigned int rxsize = priv->dma_rx_size;
-	unsigned int bfsize = priv->dma_buf_sz;
-	int buff2_needed = 0, dis_ic = 0;
+	unsigned int bfsize;
+	int dis_ic = 0;
+	int des3_as_data_buf = 0;
 
-	/* Set the Buffer size according to the MTU;
-	 * indeed, in case of jumbo we need to bump-up the buffer sizes.
-	 */
-	if (unlikely(dev->mtu >= BUF_SIZE_8KiB))
-		bfsize = BUF_SIZE_16KiB;
-	else if (unlikely(dev->mtu >= BUF_SIZE_4KiB))
-		bfsize = BUF_SIZE_8KiB;
-	else if (unlikely(dev->mtu >= BUF_SIZE_2KiB))
-		bfsize = BUF_SIZE_4KiB;
-	else if (unlikely(dev->mtu >= DMA_BUFFER_SIZE))
-		bfsize = BUF_SIZE_2KiB;
-	else
-		bfsize = DMA_BUFFER_SIZE;
+	/* Set the max buffer size according to the DESC mode used
+	 * and the MTU. */
+	bfsize = priv->hw->ring->set_bfsize(dev->mtu, priv->dma_buf_sz);
+
+	if (bfsize == BUF_SIZE_16KiB)
+		des3_as_data_buf = 1;
 
 #ifdef CONFIG_STMMAC_TIMER
 	/* Disable interrupts on completion for the reception if timer is on */
 	if (likely(priv->tm->enable))
 		dis_ic = 1;
 #endif
-	/* If the MTU exceeds 8k so use the second buffer in the chain */
-	if (bfsize >= BUF_SIZE_8KiB)
-		buff2_needed = 1;
 
 	DBG(probe, INFO, "stmmac: txsize %d, rxsize %d, bfsize %d\n",
 	    txsize, rxsize, bfsize);
@@ -446,7 +448,7 @@ static void init_dma_desc_rings(struct net_device *dev)
 		return;
 	}
 
-	DBG(probe, INFO, "stmmac (%s) DMA desc rings: virt addr (Rx %p, "
+	DBG(probe, INFO, "stmmac (%s) DMA desc: virt addr (Rx %p, "
 	    "Tx %p)\n\tDMA phy addr (Rx 0x%08x, Tx 0x%08x)\n",
 	    dev->name, priv->dma_rx, priv->dma_tx,
 	    (unsigned int)priv->dma_rx_phy, (unsigned int)priv->dma_tx_phy);
@@ -468,8 +470,9 @@ static void init_dma_desc_rings(struct net_device *dev)
 						bfsize, DMA_FROM_DEVICE);
 
 		p->des2 = priv->rx_skbuff_dma[i];
-		if (unlikely(buff2_needed))
-			p->des3 = p->des2 + BUF_SIZE_8KiB;
+
+		priv->hw->ring->init_desc3(des3_as_data_buf, p);
+
 		DBG(probe, INFO, "[%p]\t[%p]\t[%x]\n", priv->rx_skbuff[i],
 			priv->rx_skbuff[i]->data, priv->rx_skbuff_dma[i]);
 	}
@@ -483,6 +486,12 @@ static void init_dma_desc_rings(struct net_device *dev)
 		priv->tx_skbuff[i] = NULL;
 		priv->dma_tx[i].des2 = 0;
 	}
+
+	/* In case of Chained mode this sets the des3 to the next
+	 * element in the chain */
+	priv->hw->ring->init_dma_chain(priv->dma_rx, priv->dma_rx_phy, rxsize);
+	priv->hw->ring->init_dma_chain(priv->dma_tx, priv->dma_tx_phy, txsize);
+
 	priv->dirty_tx = 0;
 	priv->cur_tx = 0;
 
@@ -611,8 +620,7 @@ static void stmmac_tx(struct stmmac_priv *priv)
 			dma_unmap_single(priv->device, p->des2,
 					 priv->hw->desc->get_tx_len(p),
 					 DMA_TO_DEVICE);
-		if (unlikely(p->des3))
-			p->des3 = 0;
+		priv->hw->ring->clean_desc3(p);
 
 		if (likely(skb != NULL)) {
 			/*
@@ -1005,47 +1013,6 @@ static int stmmac_release(struct net_device *dev)
 	return 0;
 }
 
-static unsigned int stmmac_handle_jumbo_frames(struct sk_buff *skb,
-					       struct net_device *dev,
-					       int csum_insertion)
-{
-	struct stmmac_priv *priv = netdev_priv(dev);
-	unsigned int nopaged_len = skb_headlen(skb);
-	unsigned int txsize = priv->dma_tx_size;
-	unsigned int entry = priv->cur_tx % txsize;
-	struct dma_desc *desc = priv->dma_tx + entry;
-
-	if (nopaged_len > BUF_SIZE_8KiB) {
-
-		int buf2_size = nopaged_len - BUF_SIZE_8KiB;
-
-		desc->des2 = dma_map_single(priv->device, skb->data,
-					    BUF_SIZE_8KiB, DMA_TO_DEVICE);
-		desc->des3 = desc->des2 + BUF_SIZE_4KiB;
-		priv->hw->desc->prepare_tx_desc(desc, 1, BUF_SIZE_8KiB,
-						csum_insertion);
-
-		entry = (++priv->cur_tx) % txsize;
-		desc = priv->dma_tx + entry;
-
-		desc->des2 = dma_map_single(priv->device,
-					skb->data + BUF_SIZE_8KiB,
-					buf2_size, DMA_TO_DEVICE);
-		desc->des3 = desc->des2 + BUF_SIZE_4KiB;
-		priv->hw->desc->prepare_tx_desc(desc, 0, buf2_size,
-						csum_insertion);
-		priv->hw->desc->set_tx_owner(desc);
-		priv->tx_skbuff[entry] = NULL;
-	} else {
-		desc->des2 = dma_map_single(priv->device, skb->data,
-					nopaged_len, DMA_TO_DEVICE);
-		desc->des3 = desc->des2 + BUF_SIZE_4KiB;
-		priv->hw->desc->prepare_tx_desc(desc, 1, nopaged_len,
-						csum_insertion);
-	}
-	return entry;
-}
-
 /**
  *  stmmac_xmit:
  *  @skb : the socket buffer
@@ -1094,10 +1061,10 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 		       skb->len, skb_headlen(skb), nfrags, skb->ip_summed);
 #endif
 	priv->tx_skbuff[entry] = skb;
-	if (unlikely(skb->len >= BUF_SIZE_4KiB)) {
-		entry = stmmac_handle_jumbo_frames(skb, dev, csum_insertion);
-		desc = priv->dma_tx + entry;
-	} else {
+
+	/* Manage Jumbo frames depending on the descriptor mode
+	 * actually used (chained or ring). */
+	if (!priv->hw->ring->is_jumbo_frame(priv, skb, csum_insertion, desc)) {
 		unsigned int nopaged_len = skb_headlen(skb);
 		desc->des2 = dma_map_single(priv->device, skb->data,
 					nopaged_len, DMA_TO_DEVICE);
@@ -1187,11 +1154,10 @@ static inline void stmmac_rx_refill(struct stmmac_priv *priv)
 					   DMA_FROM_DEVICE);
 
 			(p + entry)->des2 = priv->rx_skbuff_dma[entry];
-			if (unlikely(priv->plat->has_gmac)) {
-				if (bfsize >= BUF_SIZE_8KiB)
-					(p + entry)->des3 =
-					    (p + entry)->des2 + BUF_SIZE_8KiB;
-			}
+
+			if (unlikely(priv->plat->has_gmac))
+				priv->hw->ring->refill_desc3(bfsize, p + entry);
+
 			RX_DBG(KERN_INFO "\trefill entry #%d\n", entry);
 		}
 		wmb();
@@ -1767,6 +1733,7 @@ static int stmmac_mac_device_setup(struct net_device *dev)
 		device->desc = &ndesc_ops;
 
 	priv->hw = device;
+	priv->hw->ring = &ring_mode_ops;
 
 	if (device_can_wakeup(priv->device)) {
 		priv->wolopts = WAKE_MAGIC; /* Magic Frame as default */
-- 
1.7.4.4
