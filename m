From: Zhao Qiang <qiang.zhao@nxp.com>
Subject: [Patch v3 5/5] drivers/net: support hdlc function for QE-UCC
Date: Mon, 6 Jun 2016 14:30:02 +0800
Message-ID: <1465194602-43209-5-git-send-email-qiang.zhao@nxp.com>
References: <1465194602-43209-1-git-send-email-qiang.zhao@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linuxppc-dev@lists.ozlabs.org>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>, <xiaobo.xie@nxp.com>,
	Zhao Qiang <qiang.zhao@nxp.com>
To: <oss@buserror.net>, <davem@davemloft.net>,
	<Joakim.Tjernlund@infinera.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1465194602-43209-1-git-send-email-qiang.zhao@nxp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The driver add hdlc support for Freescale QUICC Engine.
It support NMSI and TSA mode.

Signed-off-by: Zhao Qiang <qiang.zhao@nxp.com>
---
Changes for v2:
	- remove useless code.
	- remove Unnecessary casts
	- return IRQ_NONE when there are no interrupt
	- remove Useless comments
Changes for v3:
	- add crc err and overrun err handling code in hdlc_rx_done.

 MAINTAINERS                    |    7 +
 drivers/net/wan/Kconfig        |   11 +
 drivers/net/wan/Makefile       |    1 +
 drivers/net/wan/fsl_ucc_hdlc.c | 1192 ++++++++++++++++++++++++++++++++++++++++
 drivers/net/wan/fsl_ucc_hdlc.h |  147 +++++
 include/soc/fsl/qe/qe.h        |    1 +
 include/soc/fsl/qe/ucc_fast.h  |   22 +-
 7 files changed, 1379 insertions(+), 2 deletions(-)
 create mode 100644 drivers/net/wan/fsl_ucc_hdlc.c
 create mode 100644 drivers/net/wan/fsl_ucc_hdlc.h

diff --git a/MAINTAINERS b/MAINTAINERS
index 74bbff3..bdada16 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -4572,6 +4572,13 @@ F:	drivers/net/ethernet/freescale/gianfar*
 X:	drivers/net/ethernet/freescale/gianfar_ptp.c
 F:	Documentation/devicetree/bindings/net/fsl-tsec-phy.txt
 
+FREESCALE QUICC ENGINE UCC HDLC DRIVER
+M:	Zhao Qiang <qiang.zhao@nxp.com>
+L:	netdev@vger.kernel.org
+L:	linuxppc-dev@lists.ozlabs.org
+S:	Maintained
+F:	drivers/net/wan/fsl_ucc_hdlc*
+
 FREESCALE QUICC ENGINE UCC UART DRIVER
 M:	Timur Tabi <timur@tabi.org>
 L:	linuxppc-dev@lists.ozlabs.org
diff --git a/drivers/net/wan/Kconfig b/drivers/net/wan/Kconfig
index a2fdd15..9e314b7 100644
--- a/drivers/net/wan/Kconfig
+++ b/drivers/net/wan/Kconfig
@@ -280,6 +280,17 @@ config DSCC4
 	  To compile this driver as a module, choose M here: the
 	  module will be called dscc4.
 
+config FSL_UCC_HDLC
+	tristate "Freescale QUICC Engine HDLC support"
+	depends on HDLC
+	depends on QUICC_ENGINE
+	help
+	  Driver for Freescale QUICC Engine HDLC controller. The driver
+	  supports HDLC in NMSI and TDM mode.
+
+	  To compile this driver as a module, choose M here: the
+	  module will be called fsl_ucc_hdlc.
+
 config DSCC4_PCISYNC
 	bool "Etinc PCISYNC features"
 	depends on DSCC4
diff --git a/drivers/net/wan/Makefile b/drivers/net/wan/Makefile
index c135ef4..25fec40 100644
--- a/drivers/net/wan/Makefile
+++ b/drivers/net/wan/Makefile
@@ -32,6 +32,7 @@ obj-$(CONFIG_WANXL)		+= wanxl.o
 obj-$(CONFIG_PCI200SYN)		+= pci200syn.o
 obj-$(CONFIG_PC300TOO)		+= pc300too.o
 obj-$(CONFIG_IXP4XX_HSS)	+= ixp4xx_hss.o
+obj-$(CONFIG_FSL_UCC_HDLC)	+= fsl_ucc_hdlc.o
 
 clean-files := wanxlfw.inc
 $(obj)/wanxl.o:	$(obj)/wanxlfw.inc
diff --git a/drivers/net/wan/fsl_ucc_hdlc.c b/drivers/net/wan/fsl_ucc_hdlc.c
new file mode 100644
index 0000000..19174ac
--- /dev/null
+++ b/drivers/net/wan/fsl_ucc_hdlc.c
@@ -0,0 +1,1192 @@
+/* Freescale QUICC Engine HDLC Device Driver
+ *
+ * Copyright 2016 Freescale Semiconductor Inc.
+ *
+ * This program is free software; you can redistribute  it and/or modify it
+ * under  the terms of  the GNU General  Public License as published by the
+ * Free Software Foundation;  either version 2 of the  License, or (at your
+ * option) any later version.
+ */
+
+#include <linux/delay.h>
+#include <linux/dma-mapping.h>
+#include <linux/hdlc.h>
+#include <linux/init.h>
+#include <linux/interrupt.h>
+#include <linux/io.h>
+#include <linux/irq.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/netdevice.h>
+#include <linux/of_address.h>
+#include <linux/of_irq.h>
+#include <linux/of_platform.h>
+#include <linux/platform_device.h>
+#include <linux/sched.h>
+#include <linux/skbuff.h>
+#include <linux/slab.h>
+#include <linux/spinlock.h>
+#include <linux/stddef.h>
+#include <soc/fsl/qe/qe_tdm.h>
+#include <uapi/linux/if_arp.h>
+
+#include "fsl_ucc_hdlc.h"
+
+#define DRV_DESC "Freescale QE UCC HDLC Driver"
+#define DRV_NAME "ucc_hdlc"
+
+#define TDM_PPPOHT_SLIC_MAXIN
+#define BROKEN_FRAME_INFO
+
+static struct ucc_tdm_info utdm_primary_info = {
+	.uf_info = {
+		.tsa = 0,
+		.cdp = 0,
+		.cds = 1,
+		.ctsp = 1,
+		.ctss = 1,
+		.revd = 0,
+		.urfs = 256,
+		.utfs = 256,
+		.urfet = 128,
+		.urfset = 192,
+		.utfet = 128,
+		.utftt = 0x40,
+		.ufpt = 256,
+		.mode = UCC_FAST_PROTOCOL_MODE_HDLC,
+		.ttx_trx = UCC_FAST_GUMR_TRANSPARENT_TTX_TRX_NORMAL,
+		.tenc = UCC_FAST_TX_ENCODING_NRZ,
+		.renc = UCC_FAST_RX_ENCODING_NRZ,
+		.tcrc = UCC_FAST_16_BIT_CRC,
+		.synl = UCC_FAST_SYNC_LEN_NOT_USED,
+	},
+
+	.si_info = {
+#ifdef TDM_PPPOHT_SLIC_MAXIN
+		.simr_rfsd = 1,
+		.simr_tfsd = 2,
+#else
+		.simr_rfsd = 0,
+		.simr_tfsd = 0,
+#endif
+		.simr_crt = 0,
+		.simr_sl = 0,
+		.simr_ce = 1,
+		.simr_fe = 1,
+		.simr_gm = 0,
+	},
+};
+
+static struct ucc_tdm_info utdm_info[MAX_HDLC_NUM];
+
+static int uhdlc_init(struct ucc_hdlc_private *priv)
+{
+	struct ucc_tdm_info *ut_info;
+	struct ucc_fast_info *uf_info;
+	u32 cecr_subblock;
+	u16 bd_status;
+	int ret, i;
+	void *bd_buffer;
+	dma_addr_t bd_dma_addr;
+	u32 riptr;
+	u32 tiptr;
+	u32 gumr;
+
+	ut_info = priv->ut_info;
+	uf_info = &ut_info->uf_info;
+
+	if (priv->tsa) {
+		uf_info->tsa = 1;
+		uf_info->ctsp = 1;
+	}
+	uf_info->uccm_mask = ((UCC_HDLC_UCCE_RXB | UCC_HDLC_UCCE_RXF |
+				UCC_HDLC_UCCE_TXB) << 16);
+
+	ret = ucc_fast_init(uf_info, &priv->uccf);
+	if (ret) {
+		dev_err(priv->dev, "Failed to init uccf.");
+		return ret;
+	}
+
+	priv->uf_regs = priv->uccf->uf_regs;
+	ucc_fast_disable(priv->uccf, COMM_DIR_RX | COMM_DIR_TX);
+
+	/* Loopback mode */
+	if (priv->loopback) {
+		dev_info(priv->dev, "Loopback Mode\n");
+		gumr = ioread32be(&priv->uf_regs->gumr);
+		gumr |= (UCC_FAST_GUMR_LOOPBACK | UCC_FAST_GUMR_CDS |
+			 UCC_FAST_GUMR_TCI);
+		gumr &= ~(UCC_FAST_GUMR_CTSP | UCC_FAST_GUMR_RSYN);
+		iowrite32be(gumr, &priv->uf_regs->gumr);
+	}
+
+	/* Initialize SI */
+	if (priv->tsa)
+		ucc_tdm_init(priv->utdm, priv->ut_info);
+
+	/* Write to QE CECR, UCCx channel to Stop Transmission */
+	cecr_subblock = ucc_fast_get_qe_cr_subblock(uf_info->ucc_num);
+	ret = qe_issue_cmd(QE_STOP_TX, cecr_subblock,
+			   QE_CR_PROTOCOL_UNSPECIFIED, 0);
+
+	/* Set UPSMR normal mode (need fixed)*/
+	iowrite32be(0, &priv->uf_regs->upsmr);
+
+	priv->rx_ring_size = RX_BD_RING_LEN;
+	priv->tx_ring_size = TX_BD_RING_LEN;
+	/* Alloc Rx BD */
+	priv->rx_bd_base = dma_alloc_coherent(priv->dev,
+			RX_BD_RING_LEN * sizeof(struct qe_bd *),
+			&priv->dma_rx_bd, GFP_KERNEL);
+
+	if (!priv->rx_bd_base) {
+		dev_err(priv->dev, "Cannot allocate MURAM memory for RxBDs\n");
+		ret = -ENOMEM;
+		goto rxbd_alloc_error;
+	}
+
+	/* Alloc Tx BD */
+	priv->tx_bd_base = dma_alloc_coherent(priv->dev,
+			TX_BD_RING_LEN * sizeof(struct qe_bd *),
+			&priv->dma_tx_bd, GFP_KERNEL);
+
+	if (!priv->tx_bd_base) {
+		dev_err(priv->dev, "Cannot allocate MURAM memory for TxBDs\n");
+		ret = -ENOMEM;
+		goto txbd_alloc_error;
+	}
+
+	/* Alloc parameter ram for ucc hdlc */
+	priv->ucc_pram_offset = qe_muram_alloc(sizeof(priv->ucc_pram),
+				ALIGNMENT_OF_UCC_HDLC_PRAM);
+
+	if (priv->ucc_pram_offset < 0) {
+		dev_err(priv->dev, "Can not allocate MURAM for hdlc prameter.\n");
+		ret = -ENOMEM;
+		goto pram_alloc_error;
+	}
+
+	priv->rx_skbuff = kzalloc(priv->rx_ring_size * sizeof(*priv->rx_skbuff),
+				  GFP_KERNEL);
+	if (!priv->rx_skbuff)
+		goto rx_skb_alloc_error;
+
+	priv->tx_skbuff = kzalloc(priv->tx_ring_size * sizeof(*priv->tx_skbuff),
+				  GFP_KERNEL);
+	if (!priv->tx_skbuff)
+		goto tx_skb_alloc_error;
+
+	priv->skb_curtx = 0;
+	priv->skb_dirtytx = 0;
+	priv->curtx_bd = priv->tx_bd_base;
+	priv->dirty_tx = priv->tx_bd_base;
+	priv->currx_bd = priv->rx_bd_base;
+	priv->currx_bdnum = 0;
+
+	/* init parameter base */
+	cecr_subblock = ucc_fast_get_qe_cr_subblock(uf_info->ucc_num);
+	ret = qe_issue_cmd(QE_ASSIGN_PAGE_TO_DEVICE, cecr_subblock,
+			   QE_CR_PROTOCOL_UNSPECIFIED, priv->ucc_pram_offset);
+
+	priv->ucc_pram = (struct ucc_hdlc_param __iomem *)
+					qe_muram_addr(priv->ucc_pram_offset);
+
+	/* Zero out parameter ram */
+	memset_io(priv->ucc_pram, 0, sizeof(struct ucc_hdlc_param));
+
+	/* Alloc riptr, tiptr */
+	riptr = qe_muram_alloc(32, 32);
+	if (riptr < 0) {
+		dev_err(priv->dev, "Cannot allocate MURAM mem for Receive internal temp data pointer\n");
+		ret = -ENOMEM;
+		goto riptr_alloc_error;
+	}
+
+	tiptr = qe_muram_alloc(32, 32);
+	if (tiptr < 0) {
+		dev_err(priv->dev, "Cannot allocate MURAM mem for Transmit internal temp data pointer\n");
+		ret = -ENOMEM;
+		goto tiptr_alloc_error;
+	}
+
+	/* Set RIPTR, TIPTR */
+	iowrite16be(riptr, &priv->ucc_pram->riptr);
+	iowrite16be(tiptr, &priv->ucc_pram->tiptr);
+
+	/* Set MRBLR */
+	iowrite16be(MAX_RX_BUF_LENGTH, &priv->ucc_pram->mrblr);
+
+	/* Set RBASE, TBASE */
+	iowrite32be(priv->dma_rx_bd, &priv->ucc_pram->rbase);
+	iowrite32be(priv->dma_tx_bd, &priv->ucc_pram->tbase);
+
+	/* Set RSTATE, TSTATE */
+	iowrite32be(BMR_GBL | BMR_BIG_ENDIAN, &priv->ucc_pram->rstate);
+	iowrite32be(BMR_GBL | BMR_BIG_ENDIAN, &priv->ucc_pram->tstate);
+
+	/* Set C_MASK, C_PRES for 16bit CRC */
+	iowrite32be(CRC_16BIT_MASK, &priv->ucc_pram->c_mask);
+	iowrite32be(CRC_16BIT_PRES, &priv->ucc_pram->c_pres);
+
+	iowrite16be(MAX_FRAME_LENGTH, &priv->ucc_pram->mflr);
+	iowrite16be(DEFAULT_RFTHR, &priv->ucc_pram->rfthr);
+	iowrite16be(DEFAULT_RFTHR, &priv->ucc_pram->rfcnt);
+	iowrite16be(DEFAULT_ADDR_MASK, &priv->ucc_pram->hmask);
+	iowrite16be(DEFAULT_HDLC_ADDR, &priv->ucc_pram->haddr1);
+	iowrite16be(DEFAULT_HDLC_ADDR, &priv->ucc_pram->haddr2);
+	iowrite16be(DEFAULT_HDLC_ADDR, &priv->ucc_pram->haddr3);
+	iowrite16be(DEFAULT_HDLC_ADDR, &priv->ucc_pram->haddr4);
+
+	/* Get BD buffer */
+	bd_buffer = dma_alloc_coherent(priv->dev,
+				       (RX_BD_RING_LEN + TX_BD_RING_LEN) *
+				       MAX_RX_BUF_LENGTH,
+				       &bd_dma_addr, GFP_KERNEL);
+
+	if (!bd_buffer) {
+		dev_err(priv->dev, "Could not allocate buffer descriptors\n");
+		ret = -ENOMEM;
+		goto bd_alloc_error;
+	}
+
+	memset(bd_buffer, 0, (RX_BD_RING_LEN + TX_BD_RING_LEN)
+			* MAX_RX_BUF_LENGTH);
+
+	priv->rx_buffer = bd_buffer;
+	priv->tx_buffer = bd_buffer + RX_BD_RING_LEN * MAX_RX_BUF_LENGTH;
+
+	priv->dma_rx_addr = bd_dma_addr;
+	priv->dma_tx_addr = bd_dma_addr + RX_BD_RING_LEN * MAX_RX_BUF_LENGTH;
+
+	for (i = 0; i < RX_BD_RING_LEN; i++) {
+		if (i < (RX_BD_RING_LEN - 1))
+			bd_status = R_E_S | R_I_S;
+		else
+			bd_status = R_E_S | R_I_S | R_W_S;
+
+		iowrite16be(bd_status, &priv->rx_bd_base[i].status);
+		iowrite32be(priv->dma_rx_addr + i * MAX_RX_BUF_LENGTH,
+			    &priv->rx_bd_base[i].buf);
+	}
+
+	for (i = 0; i < TX_BD_RING_LEN; i++) {
+		if (i < (TX_BD_RING_LEN - 1))
+			bd_status =  T_I_S | T_TC_S;
+		else
+			bd_status =  T_I_S | T_TC_S | T_W_S;
+
+		iowrite16be(bd_status, &priv->tx_bd_base[i].status);
+		iowrite32be(priv->dma_tx_addr + i * MAX_RX_BUF_LENGTH,
+			    &priv->tx_bd_base[i].buf);
+	}
+
+	return 0;
+
+bd_alloc_error:
+	qe_muram_free(tiptr);
+tiptr_alloc_error:
+	qe_muram_free(riptr);
+riptr_alloc_error:
+	kfree(priv->tx_skbuff);
+tx_skb_alloc_error:
+	kfree(priv->rx_skbuff);
+rx_skb_alloc_error:
+	qe_muram_free(priv->ucc_pram_offset);
+pram_alloc_error:
+	dma_free_coherent(priv->dev,
+			  TX_BD_RING_LEN * sizeof(struct qe_bd),
+			  priv->tx_bd_base, priv->dma_tx_bd);
+txbd_alloc_error:
+	dma_free_coherent(priv->dev,
+			  RX_BD_RING_LEN * sizeof(struct qe_bd),
+			  priv->rx_bd_base, priv->dma_rx_bd);
+rxbd_alloc_error:
+	ucc_fast_free(priv->uccf);
+
+	return ret;
+}
+
+static netdev_tx_t ucc_hdlc_tx(struct sk_buff *skb, struct net_device *dev)
+{
+	hdlc_device *hdlc = dev_to_hdlc(dev);
+	struct ucc_hdlc_private *priv = (struct ucc_hdlc_private *)hdlc->priv;
+	struct qe_bd __iomem *bd;
+	u16 bd_status;
+	unsigned long flags;
+	u8 *send_buf;
+	int i;
+	u16 *proto_head;
+
+	switch (dev->type) {
+	case ARPHRD_RAWHDLC:
+		if (skb_headroom(skb) < HDLC_HEAD_LEN) {
+			dev->stats.tx_dropped++;
+			dev_kfree_skb(skb);
+			netdev_err(dev, "No enough space for hdlc head\n");
+			return -ENOMEM;
+		}
+
+		skb_push(skb, HDLC_HEAD_LEN);
+
+		proto_head = (u16 *)skb->data;
+		*proto_head = htons(DEFAULT_HDLC_HEAD);
+
+		dev->stats.tx_bytes += skb->len;
+		break;
+
+	case ARPHRD_PPP:
+		proto_head = (u16 *)skb->data;
+		if (*proto_head != htons(DEFAULT_PPP_HEAD)) {
+			dev->stats.tx_dropped++;
+			dev_kfree_skb(skb);
+			netdev_err(dev, "Wrong ppp header\n");
+			return -ENOMEM;
+		}
+
+		dev->stats.tx_bytes += skb->len;
+		break;
+
+	default:
+		dev->stats.tx_dropped++;
+		dev_kfree_skb(skb);
+		return -ENOMEM;
+	}
+
+	pr_info("Tx data skb->len:%d ", skb->len);
+	send_buf = (u8 *)skb->data;
+	pr_info("\nTransmitted data:\n");
+	for (i = 0; i < 16; i++) {
+		if (i == skb->len)
+			pr_info("++++");
+		else
+		pr_info("%02x\n", send_buf[i]);
+	}
+	spin_lock_irqsave(&priv->lock, flags);
+
+	/* Start from the next BD that should be filled */
+	bd = priv->curtx_bd;
+	bd_status = ioread16be(&bd->status);
+	/* Save the skb pointer so we can free it later */
+	priv->tx_skbuff[priv->skb_curtx] = skb;
+
+	/* Update the current skb pointer (wrapping if this was the last) */
+	priv->skb_curtx =
+	    (priv->skb_curtx + 1) & TX_RING_MOD_MASK(TX_BD_RING_LEN);
+
+	/* copy skb data to tx buffer for sdma processing */
+	memcpy(priv->tx_buffer + (be32_to_cpu(bd->buf) - priv->dma_tx_addr),
+	       skb->data, skb->len);
+
+	/* set bd status and length */
+	bd_status = (bd_status & T_W_S) | T_R_S | T_I_S | T_L_S | T_TC_S;
+
+	iowrite16be(bd_status, &bd->status);
+	iowrite16be(skb->len, &bd->length);
+
+	/* Move to next BD in the ring */
+	if (!(bd_status & T_W_S))
+		bd += 1;
+	else
+		bd = priv->tx_bd_base;
+
+	if (bd == priv->dirty_tx) {
+		if (!netif_queue_stopped(dev))
+			netif_stop_queue(dev);
+	}
+
+	priv->curtx_bd = bd;
+
+	spin_unlock_irqrestore(&priv->lock, flags);
+
+	return NETDEV_TX_OK;
+}
+
+static int hdlc_tx_done(struct ucc_hdlc_private *priv)
+{
+	/* Start from the next BD that should be filled */
+	struct net_device *dev = priv->ndev;
+	struct qe_bd *bd;		/* BD pointer */
+	u16 bd_status;
+
+	bd = priv->dirty_tx;
+	bd_status = ioread16be(&bd->status);
+
+	/* Normal processing. */
+	while ((bd_status & T_R_S) == 0) {
+		struct sk_buff *skb;
+
+		/* BD contains already transmitted buffer.   */
+		/* Handle the transmitted buffer and release */
+		/* the BD to be used with the current frame  */
+
+		skb = priv->tx_skbuff[priv->skb_dirtytx];
+		if (!skb)
+			break;
+		pr_info("TxBD: %x\n", bd_status);
+		dev->stats.tx_packets++;
+		memset(priv->tx_buffer +
+		       (be32_to_cpu(bd->buf) - priv->dma_tx_addr),
+		       0, skb->len);
+		dev_kfree_skb_irq(skb);
+
+		priv->tx_skbuff[priv->skb_dirtytx] = NULL;
+		priv->skb_dirtytx =
+		    (priv->skb_dirtytx +
+		     1) & TX_RING_MOD_MASK(TX_BD_RING_LEN);
+
+		/* We freed a buffer, so now we can restart transmission */
+		if (netif_queue_stopped(dev))
+			netif_wake_queue(dev);
+
+		/* Advance the confirmation BD pointer */
+		if (!(bd_status & T_W_S))
+			bd += 1;
+		else
+			bd = priv->tx_bd_base;
+		bd_status = ioread16be(&bd->status);
+	}
+	priv->dirty_tx = bd;
+
+	return 0;
+}
+
+static int hdlc_rx_done(struct ucc_hdlc_private *priv, int rx_work_limit)
+{
+	struct net_device *dev = priv->ndev;
+	struct sk_buff *skb;
+	hdlc_device *hdlc = dev_to_hdlc(dev);
+	struct qe_bd *bd;
+	u32 bd_status;
+	u16 length, howmany = 0;
+	u8 *bdbuffer;
+	int i;
+	static int entry;
+
+	bd = priv->currx_bd;
+	bd_status = ioread16be(&bd->status);
+
+	/* while there are received buffers and BD is full (~R_E) */
+	while (!((bd_status & (R_E_S)) || (--rx_work_limit < 0))) {
+		if (bd_status & R_OV_S)
+			dev->stats.rx_over_errors++;
+		if (bd_status & R_CR_S) {
+#ifdef BROKEN_FRAME_INFO
+			pr_info("Broken Frame with RxBD: %x\n", bd_status);
+#endif
+			dev->stats.rx_crc_errors++;
+			dev->stats.rx_dropped++;
+			goto recycle;
+		}
+		bdbuffer = priv->rx_buffer +
+			(priv->currx_bdnum * MAX_RX_BUF_LENGTH);
+		length = ioread16be(&bd->length);
+
+		pr_info("Received data length:%d", length);
+		pr_info("while entry times:%d", entry++);
+
+		pr_info("\nReceived data:\n");
+		for (i = 0; (i < 16); i++) {
+			if (i == length)
+				pr_info("++++");
+			else
+			pr_info("%02x\n", bdbuffer[i]);
+		}
+
+		switch (dev->type) {
+		case ARPHRD_RAWHDLC:
+			bdbuffer += HDLC_HEAD_LEN;
+			length -= (HDLC_HEAD_LEN + HDLC_CRC_SIZE);
+
+			skb = dev_alloc_skb(length);
+			if (!skb) {
+				dev->stats.rx_dropped++;
+				return -ENOMEM;
+			}
+
+			skb_put(skb, length);
+			skb->len = length;
+			skb->dev = dev;
+			memcpy(skb->data, bdbuffer, length);
+			break;
+
+		case ARPHRD_PPP:
+			length -= HDLC_CRC_SIZE;
+
+			skb = dev_alloc_skb(length);
+			if (!skb) {
+				dev->stats.rx_dropped++;
+				return -ENOMEM;
+			}
+
+			skb_put(skb, length);
+			skb->len = length;
+			skb->dev = dev;
+			memcpy(skb->data, bdbuffer, length);
+			break;
+		}
+
+		dev->stats.rx_packets++;
+		dev->stats.rx_bytes += skb->len;
+		howmany++;
+		if (hdlc->proto)
+			skb->protocol = hdlc_type_trans(skb, dev);
+		pr_info("skb->protocol:%x\n", skb->protocol);
+		netif_receive_skb(skb);
+
+recycle:
+		iowrite16be(bd_status | R_E_S | R_I_S, &bd->status);
+
+		/* update to point at the next bd */
+		if (bd_status & R_W_S) {
+			priv->currx_bdnum = 0;
+			bd = priv->rx_bd_base;
+		} else {
+			if (priv->currx_bdnum < (RX_BD_RING_LEN - 1))
+				priv->currx_bdnum += 1;
+			else
+				priv->currx_bdnum = RX_BD_RING_LEN - 1;
+
+			bd += 1;
+		}
+
+		bd_status = ioread16be(&bd->status);
+	}
+
+	priv->currx_bd = bd;
+	return howmany;
+}
+
+static int ucc_hdlc_poll(struct napi_struct *napi, int budget)
+{
+	struct ucc_hdlc_private *priv = container_of(napi,
+						     struct ucc_hdlc_private,
+						     napi);
+	int howmany;
+
+	/* Tx event processing */
+	spin_lock(&priv->lock);
+		hdlc_tx_done(priv);
+	spin_unlock(&priv->lock);
+
+	howmany = 0;
+	howmany += hdlc_rx_done(priv, budget - howmany);
+
+	if (howmany < budget) {
+		napi_complete(napi);
+		qe_setbits32(priv->uccf->p_uccm,
+			     (UCCE_HDLC_RX_EVENTS | UCCE_HDLC_TX_EVENTS) << 16);
+	}
+
+	return howmany;
+}
+
+static irqreturn_t ucc_hdlc_irq_handler(int irq, void *dev_id)
+{
+	struct ucc_hdlc_private *priv = (struct ucc_hdlc_private *)dev_id;
+	struct net_device *dev = priv->ndev;
+	struct ucc_fast_private *uccf;
+	struct ucc_tdm_info *ut_info;
+	u32 ucce;
+	u32 uccm;
+
+	ut_info = priv->ut_info;
+	uccf = priv->uccf;
+
+	ucce = ioread32be(uccf->p_ucce);
+	uccm = ioread32be(uccf->p_uccm);
+	ucce &= uccm;
+	iowrite32be(ucce, uccf->p_ucce);
+	pr_info("irq ucce:%x\n", ucce);
+	if (!ucce)
+		return IRQ_NONE;
+
+	if ((ucce >> 16) & (UCCE_HDLC_RX_EVENTS | UCCE_HDLC_TX_EVENTS)) {
+		if (napi_schedule_prep(&priv->napi)) {
+			uccm &= ~((UCCE_HDLC_RX_EVENTS | UCCE_HDLC_TX_EVENTS)
+				  << 16);
+			iowrite32be(uccm, uccf->p_uccm);
+			__napi_schedule(&priv->napi);
+		}
+	}
+
+	/* Errors and other events */
+	if (ucce >> 16 & UCC_HDLC_UCCE_BSY)
+		dev->stats.rx_errors++;
+	if (ucce >> 16 & UCC_HDLC_UCCE_TXE)
+		dev->stats.tx_errors++;
+
+	return IRQ_HANDLED;
+}
+
+static int uhdlc_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
+{
+	const size_t size = sizeof(te1_settings);
+	te1_settings line;
+	struct ucc_hdlc_private *priv = netdev_priv(dev);
+
+	if (cmd != SIOCWANDEV)
+		return hdlc_ioctl(dev, ifr, cmd);
+
+	switch (ifr->ifr_settings.type) {
+	case IF_GET_IFACE:
+		ifr->ifr_settings.type = IF_IFACE_E1;
+		if (ifr->ifr_settings.size < size) {
+			ifr->ifr_settings.size = size; /* data size wanted */
+			return -ENOBUFS;
+		}
+		line.clock_type = priv->clocking;
+		line.clock_rate = 0;
+		line.loopback = 0;
+
+		if (copy_to_user(ifr->ifr_settings.ifs_ifsu.sync, &line, size))
+			return -EFAULT;
+		return 0;
+
+	default:
+		return hdlc_ioctl(dev, ifr, cmd);
+	}
+}
+
+static int uhdlc_open(struct net_device *dev)
+{
+	u32 cecr_subblock;
+	hdlc_device *hdlc = dev_to_hdlc(dev);
+	struct ucc_hdlc_private *priv = hdlc->priv;
+	struct ucc_tdm *utdm = priv->utdm;
+
+	if (priv->hdlc_busy != 1) {
+		if (request_irq(priv->ut_info->uf_info.irq,
+				ucc_hdlc_irq_handler, 0, "hdlc", priv))
+			return -ENODEV;
+
+		cecr_subblock = ucc_fast_get_qe_cr_subblock(
+					priv->ut_info->uf_info.ucc_num);
+
+		qe_issue_cmd(QE_INIT_TX_RX, cecr_subblock,
+			     QE_CR_PROTOCOL_UNSPECIFIED, 0);
+
+		ucc_fast_enable(priv->uccf, COMM_DIR_RX | COMM_DIR_TX);
+
+		/* Enable the TDM port */
+		if (priv->tsa)
+			utdm->si_regs->siglmr1_h |= (0x1 << utdm->tdm_port);
+
+		priv->hdlc_busy = 1;
+		netif_device_attach(priv->ndev);
+		napi_enable(&priv->napi);
+		netif_start_queue(dev);
+		hdlc_open(dev);
+	}
+
+	return 0;
+}
+
+static void uhdlc_memclean(struct ucc_hdlc_private *priv)
+{
+	qe_muram_free(priv->ucc_pram->riptr);
+	qe_muram_free(priv->ucc_pram->tiptr);
+
+	if (priv->rx_bd_base) {
+		dma_free_coherent(priv->dev,
+				  RX_BD_RING_LEN * sizeof(struct qe_bd),
+				  priv->rx_bd_base, priv->dma_rx_bd);
+
+		priv->rx_bd_base = NULL;
+		priv->dma_rx_bd = 0;
+	}
+
+	if (priv->tx_bd_base) {
+		dma_free_coherent(priv->dev,
+				  TX_BD_RING_LEN * sizeof(struct qe_bd),
+				  priv->tx_bd_base, priv->dma_tx_bd);
+
+		priv->tx_bd_base = NULL;
+		priv->dma_tx_bd = 0;
+	}
+
+	if (priv->ucc_pram) {
+		qe_muram_free(priv->ucc_pram_offset);
+		priv->ucc_pram = NULL;
+		priv->ucc_pram_offset = 0;
+	 }
+
+	kfree(priv->rx_skbuff);
+	priv->rx_skbuff = NULL;
+
+	kfree(priv->tx_skbuff);
+	priv->tx_skbuff = NULL;
+
+	if (priv->uf_regs) {
+		iounmap(priv->uf_regs);
+		priv->uf_regs = NULL;
+	}
+
+	if (priv->uccf) {
+		ucc_fast_free(priv->uccf);
+		priv->uccf = NULL;
+	}
+
+	if (priv->rx_buffer) {
+		dma_free_coherent(priv->dev,
+				  RX_BD_RING_LEN * MAX_RX_BUF_LENGTH,
+				  priv->rx_buffer, priv->dma_rx_addr);
+		priv->rx_buffer = NULL;
+		priv->dma_rx_addr = 0;
+	}
+
+	if (priv->tx_buffer) {
+		dma_free_coherent(priv->dev,
+				  TX_BD_RING_LEN * MAX_RX_BUF_LENGTH,
+				  priv->tx_buffer, priv->dma_tx_addr);
+		priv->tx_buffer = NULL;
+		priv->dma_tx_addr = 0;
+	}
+}
+
+static int uhdlc_close(struct net_device *dev)
+{
+	struct ucc_hdlc_private *priv = dev_to_hdlc(dev)->priv;
+	struct ucc_tdm *utdm = priv->utdm;
+	u32 cecr_subblock;
+
+	napi_disable(&priv->napi);
+	cecr_subblock = ucc_fast_get_qe_cr_subblock(
+				priv->ut_info->uf_info.ucc_num);
+
+	qe_issue_cmd(QE_GRACEFUL_STOP_TX, cecr_subblock,
+		     (u8)QE_CR_PROTOCOL_UNSPECIFIED, 0);
+	qe_issue_cmd(QE_CLOSE_RX_BD, cecr_subblock,
+		     (u8)QE_CR_PROTOCOL_UNSPECIFIED, 0);
+
+	if (priv->tsa)
+		utdm->si_regs->siglmr1_h &= ~(0x1 << utdm->tdm_port);
+
+	ucc_fast_disable(priv->uccf, COMM_DIR_RX | COMM_DIR_TX);
+
+	free_irq(priv->ut_info->uf_info.irq, priv);
+	netif_stop_queue(dev);
+	priv->hdlc_busy = 0;
+
+	return 0;
+}
+
+static int ucc_hdlc_attach(struct net_device *dev, unsigned short encoding,
+			   unsigned short parity)
+{
+	struct ucc_hdlc_private *priv = dev_to_hdlc(dev)->priv;
+
+	if (encoding != ENCODING_NRZ &&
+	    encoding != ENCODING_NRZI)
+		return -EINVAL;
+
+	if (parity != PARITY_NONE &&
+	    parity != PARITY_CRC32_PR1_CCITT &&
+	    parity != PARITY_CRC16_PR1_CCITT)
+		return -EINVAL;
+
+	priv->encoding = encoding;
+	priv->parity = parity;
+
+	return 0;
+}
+
+#ifdef CONFIG_PM
+static void store_clk_config(struct ucc_hdlc_private *priv)
+{
+	struct qe_mux *qe_mux_reg = &qe_immr->qmx;
+
+	/* store si clk */
+	priv->cmxsi1cr_h = ioread32be(&qe_mux_reg->cmxsi1cr_h);
+	priv->cmxsi1cr_l = ioread32be(&qe_mux_reg->cmxsi1cr_l);
+
+	/* store si sync */
+	priv->cmxsi1syr = ioread32be(&qe_mux_reg->cmxsi1syr);
+
+	/* store ucc clk */
+	memcpy_fromio(priv->cmxucr, qe_mux_reg->cmxucr, 4 * sizeof(u32));
+}
+
+static void resume_clk_config(struct ucc_hdlc_private *priv)
+{
+	struct qe_mux *qe_mux_reg = &qe_immr->qmx;
+
+	memcpy_toio(qe_mux_reg->cmxucr, priv->cmxucr, 4 * sizeof(u32));
+
+	iowrite32be(priv->cmxsi1cr_h, &qe_mux_reg->cmxsi1cr_h);
+	iowrite32be(priv->cmxsi1cr_l, &qe_mux_reg->cmxsi1cr_l);
+
+	iowrite32be(priv->cmxsi1syr, &qe_mux_reg->cmxsi1syr);
+}
+
+static int uhdlc_suspend(struct device *dev)
+{
+	struct ucc_hdlc_private *priv = dev_get_drvdata(dev);
+	struct ucc_tdm_info *ut_info;
+	struct ucc_fast __iomem *uf_regs;
+
+	if (!priv)
+		return -EINVAL;
+
+	if (!netif_running(priv->ndev))
+		return 0;
+
+	netif_device_detach(priv->ndev);
+	napi_disable(&priv->napi);
+
+	ut_info = priv->ut_info;
+	uf_regs = priv->uf_regs;
+
+	/* backup gumr guemr*/
+	priv->gumr = ioread32be(&uf_regs->gumr);
+	priv->guemr = ioread8(&uf_regs->guemr);
+
+	priv->ucc_pram_bak = kmalloc(sizeof(*priv->ucc_pram_bak),
+					GFP_KERNEL);
+	if (!priv->ucc_pram_bak)
+		return -ENOMEM;
+
+	/* backup HDLC parameter */
+	memcpy_fromio(priv->ucc_pram_bak, priv->ucc_pram,
+		      sizeof(struct ucc_hdlc_param));
+
+	/* store the clk configuration */
+	store_clk_config(priv);
+
+	/* save power */
+	ucc_fast_disable(priv->uccf, COMM_DIR_RX | COMM_DIR_TX);
+
+	dev_dbg(dev, "ucc hdlc suspend\n");
+	return 0;
+}
+
+static int uhdlc_resume(struct device *dev)
+{
+	struct ucc_hdlc_private *priv = dev_get_drvdata(dev);
+	struct ucc_tdm *utdm = priv->utdm;
+	struct ucc_tdm_info *ut_info;
+	struct ucc_fast __iomem *uf_regs;
+	struct ucc_fast_private *uccf;
+	struct ucc_fast_info *uf_info;
+	int ret, i;
+	u32 cecr_subblock;
+	u16 bd_status;
+
+	if (!priv)
+		return -EINVAL;
+
+	if (!netif_running(priv->ndev))
+		return 0;
+
+	ut_info = priv->ut_info;
+	uf_info = &ut_info->uf_info;
+	uf_regs = priv->uf_regs;
+	uccf = priv->uccf;
+
+	/* restore gumr guemr */
+	iowrite8(priv->guemr, &uf_regs->guemr);
+	iowrite32be(priv->gumr, &uf_regs->gumr);
+
+	/* Set Virtual Fifo registers */
+	iowrite16be(uf_info->urfs, &uf_regs->urfs);
+	iowrite16be(uf_info->urfet, &uf_regs->urfet);
+	iowrite16be(uf_info->urfset, &uf_regs->urfset);
+	iowrite16be(uf_info->utfs, &uf_regs->utfs);
+	iowrite16be(uf_info->utfet, &uf_regs->utfet);
+	iowrite16be(uf_info->utftt, &uf_regs->utftt);
+	/* utfb, urfb are offsets from MURAM base */
+	iowrite32be(uccf->ucc_fast_tx_virtual_fifo_base_offset, &uf_regs->utfb);
+	iowrite32be(uccf->ucc_fast_rx_virtual_fifo_base_offset, &uf_regs->urfb);
+
+	/* Rx Tx and sync clock routing */
+	resume_clk_config(priv);
+
+	iowrite32be(uf_info->uccm_mask, &uf_regs->uccm);
+	iowrite32be(0xffffffff, &uf_regs->ucce);
+
+	ucc_fast_disable(priv->uccf, COMM_DIR_RX | COMM_DIR_TX);
+
+	/* rebuild SIRAM */
+	if (priv->tsa)
+		ucc_tdm_init(priv->utdm, priv->ut_info);
+
+	/* Write to QE CECR, UCCx channel to Stop Transmission */
+	cecr_subblock = ucc_fast_get_qe_cr_subblock(uf_info->ucc_num);
+	ret = qe_issue_cmd(QE_STOP_TX, cecr_subblock,
+			   (u8)QE_CR_PROTOCOL_UNSPECIFIED, 0);
+
+	/* Set UPSMR normal mode */
+	iowrite32be(0, &uf_regs->upsmr);
+
+	/* init parameter base */
+	cecr_subblock = ucc_fast_get_qe_cr_subblock(uf_info->ucc_num);
+	ret = qe_issue_cmd(QE_ASSIGN_PAGE_TO_DEVICE, cecr_subblock,
+			   QE_CR_PROTOCOL_UNSPECIFIED, priv->ucc_pram_offset);
+
+	priv->ucc_pram = (struct ucc_hdlc_param __iomem *)
+				qe_muram_addr(priv->ucc_pram_offset);
+
+	/* restore ucc parameter */
+	memcpy_toio(priv->ucc_pram, priv->ucc_pram_bak,
+		    sizeof(struct ucc_hdlc_param));
+	kfree(priv->ucc_pram_bak);
+
+	/* rebuild BD entry */
+	for (i = 0; i < RX_BD_RING_LEN; i++) {
+		if (i < (RX_BD_RING_LEN - 1))
+			bd_status = R_E_S | R_I_S;
+		else
+			bd_status = R_E_S | R_I_S | R_W_S;
+
+		iowrite16be(bd_status, &priv->rx_bd_base[i].status);
+		iowrite32be(priv->dma_rx_addr + i * MAX_RX_BUF_LENGTH,
+			    &priv->rx_bd_base[i].buf);
+	}
+
+	for (i = 0; i < TX_BD_RING_LEN; i++) {
+		if (i < (TX_BD_RING_LEN - 1))
+			bd_status =  T_I_S | T_TC_S;
+		else
+			bd_status =  T_I_S | T_TC_S | T_W_S;
+
+		iowrite16be(bd_status, &priv->tx_bd_base[i].status);
+		iowrite32be(priv->dma_tx_addr + i * MAX_RX_BUF_LENGTH,
+			    &priv->tx_bd_base[i].buf);
+	}
+
+	/* if hdlc is busy enable TX and RX */
+	if (priv->hdlc_busy == 1) {
+		cecr_subblock = ucc_fast_get_qe_cr_subblock(
+					priv->ut_info->uf_info.ucc_num);
+
+		qe_issue_cmd(QE_INIT_TX_RX, cecr_subblock,
+			     (u8)QE_CR_PROTOCOL_UNSPECIFIED, 0);
+
+		ucc_fast_enable(priv->uccf, COMM_DIR_RX | COMM_DIR_TX);
+
+		/* Enable the TDM port */
+		if (priv->tsa)
+			utdm->si_regs->siglmr1_h |= (0x1 << utdm->tdm_port);
+	}
+
+	napi_enable(&priv->napi);
+	netif_device_attach(priv->ndev);
+
+	return 0;
+}
+
+static const struct dev_pm_ops uhdlc_pm_ops = {
+	.suspend = uhdlc_suspend,
+	.resume = uhdlc_resume,
+	.freeze = uhdlc_suspend,
+	.thaw = uhdlc_resume,
+};
+
+#define HDLC_PM_OPS (&uhdlc_pm_ops)
+
+#else
+
+#define HDLC_PM_OPS NULL
+
+#endif
+static const struct net_device_ops uhdlc_ops = {
+	.ndo_open       = uhdlc_open,
+	.ndo_stop       = uhdlc_close,
+	.ndo_change_mtu = hdlc_change_mtu,
+	.ndo_start_xmit = hdlc_start_xmit,
+	.ndo_do_ioctl   = uhdlc_ioctl,
+};
+
+static int ucc_hdlc_probe(struct platform_device *pdev)
+{
+	struct device_node *np = pdev->dev.of_node;
+	struct ucc_hdlc_private *uhdlc_priv = NULL;
+	struct ucc_tdm_info *ut_info;
+	struct ucc_tdm *utdm;
+	struct resource res;
+	struct net_device *dev;
+	hdlc_device *hdlc;
+	int ucc_num;
+	const char *sprop;
+	int ret;
+	u32 val;
+
+	ret = of_property_read_u32_index(np, "cell-index", 0, &val);
+	if (ret) {
+		dev_err(&pdev->dev, "Invalid ucc property\n");
+		return -ENODEV;
+	}
+
+	ucc_num = val - 1;
+	if ((ucc_num > 3) || (ucc_num < 0)) {
+		dev_err(&pdev->dev, ": Invalid UCC num\n");
+		return -EINVAL;
+	}
+
+	memcpy(&utdm_info[ucc_num], &utdm_primary_info,
+	       sizeof(utdm_primary_info));
+
+	ut_info = &utdm_info[ucc_num];
+	ut_info->uf_info.ucc_num = ucc_num;
+
+	sprop = of_get_property(np, "rx-clock-name", NULL);
+	if (sprop) {
+		ut_info->uf_info.rx_clock = qe_clock_source(sprop);
+		if ((ut_info->uf_info.rx_clock < QE_CLK_NONE) ||
+		    (ut_info->uf_info.rx_clock > QE_CLK24)) {
+			dev_err(&pdev->dev, "Invalid rx-clock-name property\n");
+			return -EINVAL;
+		}
+	} else {
+		dev_err(&pdev->dev, "Invalid rx-clock-name property\n");
+		return -EINVAL;
+	}
+
+	sprop = of_get_property(np, "tx-clock-name", NULL);
+	if (sprop) {
+		ut_info->uf_info.tx_clock = qe_clock_source(sprop);
+		if ((ut_info->uf_info.tx_clock < QE_CLK_NONE) ||
+		    (ut_info->uf_info.tx_clock > QE_CLK24)) {
+			dev_err(&pdev->dev, "Invalid tx-clock-name property\n");
+			return -EINVAL;
+		}
+	} else {
+		dev_err(&pdev->dev, "Invalid tx-clock-name property\n");
+		return -EINVAL;
+	}
+
+	/* use the same clock when work in loopback */
+	if (ut_info->uf_info.rx_clock == ut_info->uf_info.tx_clock)
+		qe_setbrg(ut_info->uf_info.rx_clock, 20000000, 1);
+
+	ret = of_address_to_resource(np, 0, &res);
+	if (ret)
+		return -EINVAL;
+
+	ut_info->uf_info.regs = res.start;
+	ut_info->uf_info.irq = irq_of_parse_and_map(np, 0);
+
+	uhdlc_priv = kzalloc(sizeof(*uhdlc_priv), GFP_KERNEL);
+	if (!uhdlc_priv) {
+		ret = -ENOMEM;
+		dev_err(&pdev->dev, "No mem to alloc hdlc private data\n");
+		goto err_alloc_priv;
+	}
+
+	dev_set_drvdata(&pdev->dev, uhdlc_priv);
+	uhdlc_priv->dev = &pdev->dev;
+	uhdlc_priv->ut_info = ut_info;
+
+	if (of_get_property(np, "fsl,tdm-interface", NULL))
+		uhdlc_priv->tsa = 1;
+
+	if (of_get_property(np, "fsl,ucc-internal-loopback", NULL))
+		uhdlc_priv->loopback = 1;
+
+	if (uhdlc_priv->tsa == 1) {
+		utdm = kzalloc(sizeof(*utdm), GFP_KERNEL);
+		if (!utdm) {
+			ret = -ENOMEM;
+			dev_err(&pdev->dev, "No mem to alloc ucc tdm data\n");
+			goto err_alloc_utdm;
+		}
+		uhdlc_priv->utdm = utdm;
+		ret = ucc_of_parse_tdm(np, utdm, ut_info);
+		if (ret)
+			goto err_miss_tsa_property;
+	}
+
+	ret = uhdlc_init(uhdlc_priv);
+	if (ret) {
+		dev_err(&pdev->dev, "Failed to init uhdlc\n");
+		goto err_hdlc_init;
+	}
+
+	dev = alloc_hdlcdev(uhdlc_priv);
+	if (!dev) {
+		ret = -ENOMEM;
+		pr_err("ucc_hdlc: unable to allocate memory\n");
+		goto err_hdlc_init;
+	}
+
+	uhdlc_priv->ndev = dev;
+	hdlc = dev_to_hdlc(dev);
+	dev->tx_queue_len = 16;
+	dev->netdev_ops = &uhdlc_ops;
+	hdlc->attach = ucc_hdlc_attach;
+	hdlc->xmit = ucc_hdlc_tx;
+	netif_napi_add(dev, &uhdlc_priv->napi, ucc_hdlc_poll, 32);
+	if (register_hdlc_device(dev)) {
+		ret = -ENOBUFS;
+		pr_err("ucc_hdlc: unable to register hdlc device\n");
+		free_netdev(dev);
+		goto err_hdlc_init;
+	}
+
+	return 0;
+
+err_hdlc_init:
+err_miss_tsa_property:
+	kfree(uhdlc_priv);
+	if (uhdlc_priv->tsa)
+		kfree(utdm);
+err_alloc_utdm:
+	kfree(uhdlc_priv);
+err_alloc_priv:
+	return ret;
+}
+
+static int ucc_hdlc_remove(struct platform_device *pdev)
+{
+	struct ucc_hdlc_private *priv = dev_get_drvdata(&pdev->dev);
+
+	uhdlc_memclean(priv);
+
+	if (priv->utdm->si_regs) {
+		iounmap(priv->utdm->si_regs);
+		priv->utdm->si_regs = NULL;
+	}
+
+	if (priv->utdm->siram) {
+		iounmap(priv->utdm->siram);
+		priv->utdm->siram = NULL;
+	}
+	kfree(priv);
+
+	dev_info(&pdev->dev, "UCC based hdlc module removed\n");
+
+	return 0;
+}
+
+static const struct of_device_id fsl_ucc_hdlc_of_match[] = {
+	{
+	.compatible = "fsl,ucc-hdlc",
+	},
+	{},
+};
+
+MODULE_DEVICE_TABLE(of, fsl_ucc_hdlc_of_match);
+
+static struct platform_driver ucc_hdlc_driver = {
+	.probe	= ucc_hdlc_probe,
+	.remove	= ucc_hdlc_remove,
+	.driver	= {
+		.owner		= THIS_MODULE,
+		.name		= DRV_NAME,
+		.pm		= HDLC_PM_OPS,
+		.of_match_table	= fsl_ucc_hdlc_of_match,
+	},
+};
+
+static int __init ucc_hdlc_init(void)
+{
+	return platform_driver_register(&ucc_hdlc_driver);
+}
+
+static void __exit ucc_hdlc_exit(void)
+{
+	platform_driver_unregister(&ucc_hdlc_driver);
+}
+
+module_init(ucc_hdlc_init);
+module_exit(ucc_hdlc_exit);
diff --git a/drivers/net/wan/fsl_ucc_hdlc.h b/drivers/net/wan/fsl_ucc_hdlc.h
new file mode 100644
index 0000000..525786a
--- /dev/null
+++ b/drivers/net/wan/fsl_ucc_hdlc.h
@@ -0,0 +1,147 @@
+/* Freescale QUICC Engine HDLC Device Driver
+ *
+ * Copyright 2014 Freescale Semiconductor Inc.
+ *
+ * This program is free software; you can redistribute  it and/or modify it
+ * under  the terms of  the GNU General  Public License as published by the
+ * Free Software Foundation;  either version 2 of the  License, or (at your
+ * option) any later version.
+ */
+
+#ifndef CONFIG_UCC_HDLC_H
+#define CONFIG_UCC_HDLC_H
+
+#include <linux/kernel.h>
+#include <linux/list.h>
+
+#include <soc/fsl/qe/immap_qe.h>
+#include <soc/fsl/qe/qe.h>
+
+#include <soc/fsl/qe/ucc.h>
+#include <soc/fsl/qe/ucc_fast.h>
+
+/* UCC HDLC event register */
+#define UCCE_HDLC_RX_EVENTS	\
+(UCC_HDLC_UCCE_RXF | UCC_HDLC_UCCE_RXB | UCC_HDLC_UCCE_BSY)
+#define UCCE_HDLC_TX_EVENTS	(UCC_HDLC_UCCE_TXB | UCC_HDLC_UCCE_TXE)
+
+struct ucc_hdlc_param {
+	__be16 riptr;
+	__be16 tiptr;
+	__be16 res0;
+	__be16 mrblr;
+	__be32 rstate;
+	__be32 rbase;
+	__be16 rbdstat;
+	__be16 rbdlen;
+	__be32 rdptr;
+	__be32 tstate;
+	__be32 tbase;
+	__be16 tbdstat;
+	__be16 tbdlen;
+	__be32 tdptr;
+	__be32 rbptr;
+	__be32 tbptr;
+	__be32 rcrc;
+	__be32 res1;
+	__be32 tcrc;
+	__be32 res2;
+	__be32 res3;
+	__be32 c_mask;
+	__be32 c_pres;
+	__be16 disfc;
+	__be16 crcec;
+	__be16 abtsc;
+	__be16 nmarc;
+	__be32 max_cnt;
+	__be16 mflr;
+	__be16 rfthr;
+	__be16 rfcnt;
+	__be16 hmask;
+	__be16 haddr1;
+	__be16 haddr2;
+	__be16 haddr3;
+	__be16 haddr4;
+	__be16 ts_tmp;
+	__be16 tmp_mb;
+};
+
+struct ucc_hdlc_private {
+	struct ucc_tdm	*utdm;
+	struct ucc_tdm_info *ut_info;
+	struct ucc_fast_private *uccf;
+	struct device *dev;
+	struct net_device *ndev;
+	struct napi_struct napi;
+	struct ucc_fast __iomem *uf_regs;	/* UCC Fast registers */
+	struct ucc_hdlc_param __iomem *ucc_pram;
+	u16 tsa;
+	bool hdlc_busy;
+	bool loopback;
+
+	u8 *tx_buffer;
+	u8 *rx_buffer;
+	dma_addr_t dma_tx_addr;
+	dma_addr_t dma_rx_addr;
+
+	struct qe_bd *tx_bd_base;
+	struct qe_bd *rx_bd_base;
+	dma_addr_t dma_tx_bd;
+	dma_addr_t dma_rx_bd;
+	struct qe_bd *curtx_bd;
+	struct qe_bd *currx_bd;
+	struct qe_bd *dirty_tx;
+	u16 currx_bdnum;
+
+	struct sk_buff **tx_skbuff;
+	struct sk_buff **rx_skbuff;
+	u16 skb_curtx;
+	u16 skb_currx;
+	unsigned short skb_dirtytx;
+
+	unsigned short tx_ring_size;
+	unsigned short rx_ring_size;
+	u32 ucc_pram_offset;
+
+	unsigned short encoding;
+	unsigned short parity;
+	u32 clocking;
+	spinlock_t lock;	/* lock for Tx BD and Tx buffer */
+#ifdef CONFIG_PM
+	struct ucc_hdlc_param *ucc_pram_bak;
+	u32 gumr;
+	u8 guemr;
+	u32 cmxsi1cr_l, cmxsi1cr_h;
+	u32 cmxsi1syr;
+	u32 cmxucr[4];
+#endif
+};
+
+#define TX_BD_RING_LEN	0x10
+#define RX_BD_RING_LEN	0x20
+#define RX_CLEAN_MAX	0x10
+#define NUM_OF_BUF	4
+#define MAX_RX_BUF_LENGTH	(48 * 0x20)
+#define MAX_FRAME_LENGTH	(MAX_RX_BUF_LENGTH + 8)
+#define ALIGNMENT_OF_UCC_HDLC_PRAM	64
+#define SI_BANK_SIZE	128
+#define MAX_HDLC_NUM	4
+#define HDLC_HEAD_LEN	2
+#define HDLC_CRC_SIZE	2
+#define TX_RING_MOD_MASK(size) (size - 1)
+#define RX_RING_MOD_MASK(size) (size - 1)
+
+#define HDLC_HEAD_MASK		0x0000
+#define DEFAULT_HDLC_HEAD	0xff44
+#define DEFAULT_ADDR_MASK	0x00ff
+#define DEFAULT_HDLC_ADDR	0x00ff
+
+#define BMR_GBL			0x20000000
+#define BMR_BIG_ENDIAN		0x10000000
+#define CRC_16BIT_MASK		0x0000F0B8
+#define CRC_16BIT_PRES		0x0000FFFF
+#define DEFAULT_RFTHR		1
+
+#define DEFAULT_PPP_HEAD    0xff03
+
+#endif
diff --git a/include/soc/fsl/qe/qe.h b/include/soc/fsl/qe/qe.h
index c3b1dc8..70339d7 100644
--- a/include/soc/fsl/qe/qe.h
+++ b/include/soc/fsl/qe/qe.h
@@ -657,6 +657,7 @@ struct ucc_slow_pram {
 #define UCC_SLOW_GUMR_L_MODE_QMC	0x00000002
 
 /* General UCC FAST Mode Register */
+#define UCC_FAST_GUMR_LOOPBACK	0x40000000
 #define UCC_FAST_GUMR_TCI	0x20000000
 #define UCC_FAST_GUMR_TRX	0x10000000
 #define UCC_FAST_GUMR_TTX	0x08000000
diff --git a/include/soc/fsl/qe/ucc_fast.h b/include/soc/fsl/qe/ucc_fast.h
index e898895..3ee9e7c 100644
--- a/include/soc/fsl/qe/ucc_fast.h
+++ b/include/soc/fsl/qe/ucc_fast.h
@@ -21,19 +21,37 @@
 
 #include <soc/fsl/qe/ucc.h>
 
-/* Receive BD's status */
+/* Receive BD's status and length*/
 #define R_E	0x80000000	/* buffer empty */
 #define R_W	0x20000000	/* wrap bit */
 #define R_I	0x10000000	/* interrupt on reception */
 #define R_L	0x08000000	/* last */
 #define R_F	0x04000000	/* first */
 
-/* transmit BD's status */
+/* transmit BD's status and length*/
 #define T_R	0x80000000	/* ready bit */
 #define T_W	0x20000000	/* wrap bit */
 #define T_I	0x10000000	/* interrupt on completion */
 #define T_L	0x08000000	/* last */
 
+/* Receive BD's status */
+#define R_E_S	0x8000	/* buffer empty */
+#define R_W_S	0x2000	/* wrap bit */
+#define R_I_S	0x1000	/* interrupt on reception */
+#define R_L_S	0x0800	/* last */
+#define R_F_S	0x0400	/* first */
+#define R_CM_S	0x0200	/* continuous mode */
+#define R_CR_S	0x0004	/* crc */
+#define R_OV_S	0x0002	/* crc */
+
+/* transmit BD's status */
+#define T_R_S	0x8000	/* ready bit */
+#define T_W_S	0x2000	/* wrap bit */
+#define T_I_S	0x1000	/* interrupt on completion */
+#define T_L_S	0x0800	/* last */
+#define T_TC_S	0x0400	/* crc */
+#define T_TM_S	0x0200	/* continuous mode */
+
 /* Rx Data buffer must be 4 bytes aligned in most cases */
 #define UCC_FAST_RX_ALIGN			4
 #define UCC_FAST_MRBLR_ALIGNMENT		4
-- 
2.1.0.27.g96db324
