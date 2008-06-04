From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: [PATCH] irda: driver for Freescale FIRI controller
Date: Wed, 4 Jun 2008 19:45:10 +0400
Message-ID: <20080604154510.GA31162@polina.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf8
Cc: Zhang Wei <Wei.Zhang@freescale.com>,
	Timur Tabi <timur@freescale.com>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: Samuel Ortiz <samuel@sortiz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtsoft3.corbina.net ([85.21.88.6]:20653 "EHLO
	buildserver.ru.mvista.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755323AbYFDPpQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jun 2008 11:45:16 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhang Wei <wei.zhang@freescale.com>

The driver supports SIR, MIR, FIR modes and maximum 4000000bps rate.

Signed-off-by: Zhang Wei <wei.zhang@freescale.com>
[AV: few small fixes, plus had made platform ops passing via node->data
     to avoid #ifdef stuff in the fsl_soc (think DIU). ]
Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
---

If anyone from the Freescale is already working on this patch for the
mainline, I'll readily step back.

 drivers/net/irda/Kconfig  |    5 +
 drivers/net/irda/Makefile |    1 +
 drivers/net/irda/fsl_ir.c |  792 +++++++++++++++++++++++++++++++++++++++++++++
 include/linux/fsl_ir.h    |  207 ++++++++++++
 4 files changed, 1005 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/irda/fsl_ir.c
 create mode 100644 include/linux/fsl_ir.h

diff --git a/drivers/net/irda/Kconfig b/drivers/net/irda/Kconfig
index ce816ba..da24f57 100644
--- a/drivers/net/irda/Kconfig
+++ b/drivers/net/irda/Kconfig
@@ -341,5 +341,10 @@ config MCS_FIR
 	  To compile it as a module, choose M here: the module will be called
 	  mcs7780.
 
+config FSL_FIR
+	tristate "Freescale Irda driver"
+	depends on IRDA && FSL_SOC
+	help
+
 endmenu
 
diff --git a/drivers/net/irda/Makefile b/drivers/net/irda/Makefile
index 5d20fde..724218c 100644
--- a/drivers/net/irda/Makefile
+++ b/drivers/net/irda/Makefile
@@ -19,6 +19,7 @@ obj-$(CONFIG_VIA_FIR)		+= via-ircc.o
 obj-$(CONFIG_PXA_FICP)	        += pxaficp_ir.o
 obj-$(CONFIG_MCS_FIR)	        += mcs7780.o
 obj-$(CONFIG_AU1000_FIR)	+= au1k_ir.o
+obj-$(CONFIG_FSL_FIR)	        += fsl_ir.o
 # SIR drivers
 obj-$(CONFIG_IRTTY_SIR)		+= irtty-sir.o	sir-dev.o
 # dongle drivers for SIR drivers
diff --git a/drivers/net/irda/fsl_ir.c b/drivers/net/irda/fsl_ir.c
new file mode 100644
index 0000000..d38d309
--- /dev/null
+++ b/drivers/net/irda/fsl_ir.c
@@ -0,0 +1,792 @@
+/*
+ * Copyright (C) 2007 Freescale Semiconductor, Inc. All rights reserved.
+ *
+ * Author: Zhang Wei, wei.zhang@freescale.com, Oct. 2007
+ *
+ * Description:
+ * The IrDA driver for Freescale PowerPC MPC8610 processor. The driver
+ * support SIR and FIR mode. The maximum speed is 4Mbps.
+ *
+ * Changelog:
+ * Oct 2007 Zhang Wei <wei.zhang@freescale.com>
+ * - Initial version.
+ *
+ * This file is part of the Linux kernel
+ *
+ * This is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ */
+
+#include <linux/kernel.h>
+#include <linux/interrupt.h>
+#include <linux/delay.h>
+#include <linux/of_platform.h>
+#include <linux/fsl_ir.h>
+
+#include <net/irda/irda.h>
+#include <net/irda/wrapper.h>
+#include <net/irda/irda_device.h>
+#include <net/irda/irlap_frame.h>
+#include <net/irda/irlap.h>
+
+#include <sysdev/fsl_soc.h>
+
+#define is_sir_speed(speed) ((speed <= 115200) ? 1 : 0)
+#define is_sir(ir) (is_sir_speed(ir->speed))
+
+static void init_iobuf(iobuff_t *io, void *buff, int size)
+{
+	io->head = buff;
+	io->truesize = size;
+	io->in_frame = FALSE;
+	io->state = OUTSIDE_FRAME;
+	io->data = io->head;
+	io->skb = NULL;
+}
+
+static void ir_switch_mode(struct fsl_ir *ir, u32 speed)
+{
+
+	if (ir->speed && (ir->speed < 115200))	/* Switch from SIR to FIR */
+		/* Disable SIRI */
+		clrbits32(&ir->reg_base->scr1, FSL_IR_SCR1_IREN |
+						FSL_IR_SCR1_SIRIEN);
+	else {					/* Switch from FIR to SIR */
+		/* Disable FIRI */
+		out_be32(&ir->reg_base->firitcr, 0);
+		out_be32(&ir->reg_base->firircr, 0);
+	}
+
+	/* Switch the IrDA mode on board */
+	if (ir->plat_op && ir->plat_op->set_ir_mode)
+		ir->plat_op->set_ir_mode(ir, speed);
+}
+
+static int ir_crc_len(struct fsl_ir *ir)
+{
+	int crc_len;
+
+	switch (ir->speed) {
+	case 576000:
+	case 1152000:
+		crc_len = 2;	/* CRC16, 16 bits */
+		break;
+	case 4000000:
+		crc_len = 4;	/* CRC32, 32 bits */
+		break;
+	default:
+		crc_len = 0;
+		break;
+	}
+	return crc_len;
+}
+
+static void fir_rx(struct fsl_ir *ir, int len)
+{
+	struct net_device *ndev = dev_get_drvdata(ir->dev);
+	struct sk_buff *skb;
+	int i;
+
+	if (len <= ir_crc_len(ir))
+		return;
+
+	do_gettimeofday(&ir->stamp);
+	/* Now, for new packet arriving */
+	skb = alloc_skb(len + 1, GFP_ATOMIC);
+	if (!skb) {
+		ir->stats.rx_dropped++;
+		return;
+	}
+	skb_reserve(skb, 1);
+
+	for (i = 0; i < len; i++)
+		skb->data[i] = in_8((u8 *)&ir->reg_base->rfifo);
+
+	len -= ir_crc_len(ir);
+	skb_put(skb, len);
+
+	ir->stats.rx_packets++;
+	ir->stats.rx_bytes += len;
+
+	skb->dev = ndev;
+	skb_reset_mac_header(skb);
+	skb->protocol = htons(ETH_P_IRDA);
+	netif_rx(skb);
+}
+
+static void fir_tx(struct fsl_ir *ir)
+{
+	int free_bytes;
+	struct sk_buff *skb = ir->tx_buff.skb;
+	size_t len;
+
+	if (!skb)
+		return;
+
+	spin_lock(&ir->tx_lock);
+	do {
+		free_bytes = 128 -
+			((in_be32(&ir->reg_base->firitsr) >> 8) & 0xff);
+		for (len = min(free_bytes, ir->tx_buff.len); len > 0;
+			len--, ir->tx_buff.len--)
+			out_8((u8 *)&ir->reg_base->tfifo,
+				skb->data[skb->len - ir->tx_buff.len]);
+	} while (ir->tx_buff.len > 0);
+	spin_unlock(&ir->tx_lock);
+
+	dev_kfree_skb_any(ir->tx_buff.skb);
+	ir->stats.tx_packets++;
+	ir->stats.tx_bytes += skb->len;
+}
+
+static void sir_set_data(struct fsl_ir *ir, u8 data_size)
+{
+	switch (data_size) {
+	case 7:
+		clrbits32(&ir->reg_base->scr2, FSL_IR_SCR2_WS);
+		break;
+	case 8:
+		setbits32(&ir->reg_base->scr2, FSL_IR_SCR2_WS);
+		break;
+	}
+}
+
+static void sir_set_parity(struct fsl_ir *ir, enum sir_parity parity)
+{
+	switch (parity) {
+	case SIR_PARITY_NONE:
+		clrbits32(&ir->reg_base->scr2, FSL_IR_SCR2_PREN);
+		break;
+	case SIR_PARITY_EVEN:
+		setbits32(&ir->reg_base->scr2, FSL_IR_SCR2_PREN);
+		clrbits32(&ir->reg_base->scr2, FSL_IR_SCR2_PROE);
+		break;
+	case SIR_PARITY_ODD:
+		setbits32(&ir->reg_base->scr2, FSL_IR_SCR2_PREN
+				| FSL_IR_SCR2_PROE);
+		break;
+	}
+}
+
+static void sir_set_stop(struct fsl_ir *ir, u8 stop_bit)
+{
+	switch (stop_bit) {
+	case 1:
+		clrbits32(&ir->reg_base->scr2, FSL_IR_SCR2_STPB);
+		break;
+	case 2:
+		setbits32(&ir->reg_base->scr2, FSL_IR_SCR2_STPB);
+		break;
+	}
+}
+
+static void sir_put(struct fsl_ir *ir, u8 ch)
+{
+	out_be32(&ir->reg_base->stxd, ch);
+}
+
+static u8 sir_get(struct fsl_ir *ir)
+{
+	u32 rxd = in_be32(&ir->reg_base->srxd);
+
+	if (rxd & FSL_IR_SRXD_ERR)
+		ir->stats.rx_errors++;
+
+	if (rxd & FSL_IR_SRXD_OVRRUN)
+		ir->stats.rx_fifo_errors++;
+
+	if (rxd & FSL_IR_SRXD_FRMERR)
+		ir->stats.rx_frame_errors++;
+
+	if (rxd & FSL_IR_SRXD_PRERR)
+		ir->stats.rx_crc_errors++;
+
+	return (u8)rxd;
+}
+
+static int fsl_ir_set_speed(struct net_device *ndev, u32 speed)
+{
+	u32 sbir;
+	u32 sbmr;
+	struct fsl_ir *ir = netdev_priv(ndev);
+	struct irlap_cb *self;
+
+	if (is_sir_speed(ir->speed) != is_sir_speed(speed))
+		ir_switch_mode(ir, speed);
+
+	ir->speed = speed;
+	if (is_sir_speed(speed)) {
+		/* SIR */
+		sbir = 89;
+		sbmr = ir->clock_in / ir->div / 16 * (sbir + 1) / speed - 1;
+		out_be32(&ir->reg_base->sbir, sbir);
+		out_be32(&ir->reg_base->sbmr, sbmr);
+
+		/* Prepare SIR buff */
+		init_iobuf(&ir->tx_buff, ir->txb, FSL_SIR_TXBUFF_SIZE);
+		init_iobuf(&ir->rx_buff, ir->rxb, FSL_SIR_RXBUFF_SIZE);
+
+		/* Enable SIR */
+		setbits32(&ir->reg_base->scr1, FSL_IR_SCR1_IREN |
+						FSL_IR_SCR1_SIRIEN);
+	} else {
+		/* MIR and FIR are the same mode in FSL IR controller */
+
+		/* Clean the TCR and RCR register */
+		out_be32(&ir->reg_base->firitcr, 0);
+		out_be32(&ir->reg_base->firircr, 0);
+
+		/* Prepare FIR buff */
+		ir->tx_buff.skb = NULL;
+		ir->rx_buff.skb = NULL;
+
+		/* Set FIRI Transmitter Control
+		 * Transmit complete interrupt: Enabled
+		 * Send packet abort sysmbol when FIFO underrun or transfer
+		 * abort: Enabled
+		 */
+		setbits32(&ir->reg_base->firitcr,
+			FSL_FIRITCR_TCIE | FSL_FIRITCR_PCF | FSL_FIRITCR_PC);
+		out_be32(&ir->reg_base->firicr, (32 << 5) | 5);
+
+		/* Set FIRI Receive control */
+		self = ndev->atalk_ptr;
+		setbits32(&ir->reg_base->firircr,
+			FSL_FIRIRCR_RAM | ((((u32)self->caddr |
+						((self->state == LAP_NRM_S) ?
+						 CMD_FRAME : 0)) << 16)
+						& 0x00ff0000)|
+			FSL_FIRIRCR_RDT_16 | FSL_FIRIRCR_RPA | FSL_FIRIRCR_RPP |
+			FSL_FIRIRCR_RPEIE);
+
+		switch (speed) {
+		case 576000:
+			setbits32(&ir->reg_base->firitcr,
+						FSL_FIRITCR_TM_MIR_576);
+			setbits32(&ir->reg_base->firircr,
+						FSL_FIRIRCR_RM_MIR_576);
+			break;
+		case 1152000:
+			setbits32(&ir->reg_base->firitcr,
+						FSL_FIRITCR_TM_MIR_1152);
+			setbits32(&ir->reg_base->firircr,
+						FSL_FIRIRCR_RM_MIR_1152);
+			break;
+		case 4000000:
+			setbits32(&ir->reg_base->firitcr, FSL_FIRITCR_TM_FIR);
+			setbits32(&ir->reg_base->firircr, FSL_FIRIRCR_RM_FIR);
+			break;
+		default:
+			dev_err(ir->dev, "speed %d is not supported!\n",
+					speed);
+			return -ENOTSUPP;
+		}
+
+		out_be32(&ir->reg_base->firitsr, 0xffff);
+		/* Enable FIR Rx */
+		setbits32(&ir->reg_base->firircr, FSL_FIRIRCR_RE);
+		out_be32(&ir->reg_base->firirsr, 0xffff);
+	}
+	return 0;
+}
+
+/* Start IR from 9600 speed */
+static void fsl_ir_start(struct net_device *ndev)
+{
+	struct fsl_ir *ir = netdev_priv(ndev);
+
+	/* Start IrDA speed from 9600 with SIRI mode */
+	ir->div = ir->clock_in / 0x10000 / 1000 + 1;
+
+	if (ir->div > 7) {
+		dev_err(ir->dev, "Unsupported SIR clock in frequency!\n");
+		return;
+	}
+
+	clrbits32(&ir->reg_base->sfcr, FSL_IR_SFCR_RFDIV_MASK);
+	setbits32(&ir->reg_base->sfcr, (ir->div < 7) ?
+				((6 - ir->div) << 7) : FSL_IR_SFCR_RFDIV_7);
+
+	/* Set Tx and Rx watermarks,
+	 * Tx watermarks = 2
+	 * Rx watermarks = 30
+	 */
+	setbits32(&ir->reg_base->sfcr, (2 << 10) | 30);
+
+	/* Set One Millisecond Register */
+	out_be32(&ir->reg_base->sonems, 0xffff & (ir->clock_in / ir->div
+								/ 1000));
+
+	/* Select interrupts */
+
+	/* SCR3:
+	 * Invert TX
+	 * If the Tx need invert, enable below:
+	 * out_be32(&ir->reg_base->scr3, 0x0700 | FSL_IR_SCR3_INVT);
+	 */
+
+
+	/* SCR1:
+	 * SIR initialization */
+	setbits32(&ir->reg_base->scr1, FSL_IR_SCR1_IREN | FSL_IR_SCR1_RRDYEN |
+				FSL_IR_SCR1_ATDMAEN | FSL_IR_SCR1_SIRIEN);
+
+	/* 9600 8-N-1 */
+	ir_switch_mode(ir, 9600);
+	fsl_ir_set_speed(ndev, 9600);
+	sir_set_data(ir, 8);
+	sir_set_parity(ir, SIR_PARITY_NONE);
+	sir_set_stop(ir, 1);
+
+	out_be32(&ir->reg_base->sts, 0x60);
+
+	/* SCR2:
+	 * Enable Tx/Rx */
+	setbits32(&ir->reg_base->scr2, 0x4000 | FSL_IR_SCR2_TXEN |
+				FSL_IR_SCR2_ATEN | FSL_IR_SCR2_RXEN);
+
+	/* SCR4:
+	 * If the Rx need invert, enable FSL_IR_SCR4_INVR bit.
+	 */
+	out_be32(&ir->reg_base->scr4, 0x8000 | FSL_IR_SCR4_IRSC);
+
+
+	dev_dbg(ir->dev, "scr1 %08x\n", in_be32(&ir->reg_base->scr1));
+	dev_dbg(ir->dev, "scr2 %08x\n", in_be32(&ir->reg_base->scr2));
+	dev_dbg(ir->dev, "scr3 %08x\n", in_be32(&ir->reg_base->scr3));
+	dev_dbg(ir->dev, "scr4 %08x\n", in_be32(&ir->reg_base->scr4));
+}
+
+static void fsl_ir_halt(struct fsl_ir *ir)
+{
+	ir_switch_mode(ir, 0);
+
+	/* Clean SIR registers */
+	out_be32(&ir->reg_base->scr1, 0);
+	out_be32(&ir->reg_base->scr2, 0);
+	out_be32(&ir->reg_base->scr3, 0);
+	out_be32(&ir->reg_base->scr4, 0);
+
+	/* Clean FIR TCR and RCR register */
+	out_be32(&ir->reg_base->firitcr, 0);
+	out_be32(&ir->reg_base->firircr, 0);
+}
+
+static irqreturn_t fsl_ir_sir_irq(struct net_device *ndev)
+{
+	struct fsl_ir *ir = netdev_priv(ndev);
+	u32 ssr1, ssr2;
+	ssr1 = in_be32(&ir->reg_base->ssr1);
+	ssr2 = in_be32(&ir->reg_base->ssr2);
+
+	/* Tx is ready */
+	if ((ssr1 & FSL_IR_SSR1_TRDY) && ir->tx_buff.len) {
+		clrbits32(&ir->reg_base->scr1, FSL_IR_SCR1_TRDYEN);
+		tasklet_schedule(&ir->tx_tasklet);
+	}
+
+	/* Last Tx transfer is finished */
+	if (ssr2 & FSL_IR_SSR2_TXDC && !ir->tx_buff.len) {
+		if (ir->new_speed) {
+			fsl_ir_set_speed(ndev, ir->new_speed);
+			ir->new_speed = 0;
+		}
+		clrbits32(&ir->reg_base->scr4, FSL_IR_SCR4_TCEN);
+
+		ir->stats.tx_packets++;
+		ir->stats.tx_bytes += ir->tx_buff.data
+						- ir->tx_buff.head;
+
+		netif_wake_queue(ndev);
+	}
+
+	/* Rx is ready */
+	if (ssr1 & FSL_IR_SSR1_RRDY) {
+		int i;
+		int rxchars = in_be32(&ir->reg_base->sfcr) & 0x3f;
+
+		for (i = 0; i < rxchars; i++)
+			async_unwrap_char(ndev, &ir->stats, &ir->rx_buff,
+								sir_get(ir));
+		ndev->last_rx = jiffies;
+	}
+
+	/* There are some Rx datas in FIFO less than watermark */
+	if (ssr1 & FSL_IR_SSR1_AGTIM) {
+		while (in_be32(&ir->reg_base->ssr2) & 0x1)
+			async_unwrap_char(ndev, &ir->stats, &ir->rx_buff,
+								sir_get(ir));
+		ndev->last_rx = jiffies;
+	}
+
+	out_be32(&ir->reg_base->ssr1, ssr1);
+	out_be32(&ir->reg_base->ssr2, ssr2);
+	return IRQ_HANDLED;
+}
+
+static irqreturn_t fsl_ir_fir_irq(struct net_device *ndev)
+{
+	struct fsl_ir *ir = netdev_priv(ndev);
+	u32 tsr, rsr;
+
+	tsr = in_be32(&ir->reg_base->firitsr);
+	rsr = in_be32(&ir->reg_base->firirsr);
+
+	out_be32(&ir->reg_base->firitsr, tsr);
+	out_be32(&ir->reg_base->firirsr, rsr);
+
+	/* Tx completed */
+	if ((tsr & FSL_FIRITSR_TC) && (!ir->tx_buff.len)) {
+		clrbits32(&ir->reg_base->firitcr, FSL_FIRITCR_TE);
+		if (ir->new_speed) {
+			fsl_ir_set_speed(ndev, ir->new_speed);
+			ir->new_speed = 0;
+		}
+		ir->tx_buff.skb = NULL;
+		/* Tx finish */
+		netif_wake_queue(ndev);
+		goto out;
+	}
+
+	/* Rx errors */
+	if (rsr & (FSL_FIRIRSR_CRCE | FSL_FIRIRSR_DDE | FSL_FIRIRSR_RFO)) {
+		ir->stats.rx_errors++;
+		if (rsr & FSL_FIRIRSR_CRCE)
+			ir->stats.rx_crc_errors++;
+		if (rsr & FSL_FIRIRSR_DDE)
+			ir->stats.rx_frame_errors++;
+		if (rsr & FSL_FIRIRSR_RFO) {
+			ir->stats.rx_over_errors++;
+			/* Clean FIFO, and restart Rx */
+			clrbits32(&ir->reg_base->firircr, FSL_FIRIRCR_RE);
+			setbits32(&ir->reg_base->firircr, FSL_FIRIRCR_RE);
+		}
+		goto out;
+	}
+
+	/* Rx */
+	if (rsr & FSL_FIRIRSR_RPE)
+		fir_rx(ir, (rsr >> 8) & 0xff);
+
+out:
+	return IRQ_HANDLED;
+}
+
+static irqreturn_t fsl_ir_do_interrupt(int irq, void *data)
+{
+	struct net_device *ndev = data;
+	struct fsl_ir *ir = netdev_priv(ndev);
+
+	return is_sir(ir) ? fsl_ir_sir_irq(ndev) : fsl_ir_fir_irq(ndev);
+}
+
+static void fsl_ir_tx_do_tasklet(unsigned long data)
+{
+	struct fsl_ir *ir = (struct fsl_ir *)data;
+
+	if (is_sir(ir)) {
+		int i;
+		i = FSL_SIR_TX_MAX
+			- ((in_be32(&ir->reg_base->sfcr) >> 10) & 0x3f);
+
+		spin_lock(&ir->tx_lock);
+		while (ir->tx_buff.len && i--) {
+			sir_put(ir, *ir->tx_buff.data++);
+			ir->tx_buff.len--;
+		}
+
+		if (ir->tx_buff.len)
+			setbits32(&ir->reg_base->scr1, FSL_IR_SCR1_TRDYEN);
+		else
+			setbits32(&ir->reg_base->scr4, FSL_IR_SCR4_TCEN);
+		spin_unlock(&ir->tx_lock);
+	}
+}
+
+static struct net_device_stats *fsl_ir_stats(struct net_device *ndev)
+{
+	struct fsl_ir *ir = netdev_priv(ndev);
+	return &ir->stats;
+}
+
+static int fsl_ir_ioctl(struct net_device *ndev, struct ifreq *ifreq, int cmd)
+{
+	struct if_irda_req *rq = (struct if_irda_req *)ifreq;
+	struct fsl_ir *ir = netdev_priv(ndev);
+	int err = 0;
+
+	switch (cmd) {
+	case SIOCSBANDWIDTH:
+		if (capable(CAP_NET_ADMIN)) {
+			if (ir->tx_buff.len)
+				ir->new_speed = rq->ifr_baudrate;
+			else
+				err = fsl_ir_set_speed(ndev, rq->ifr_baudrate);
+		}
+		break;
+	case SIOCSMEDIABUSY:
+		if (capable(CAP_NET_ADMIN))
+			irda_device_set_media_busy(ndev, TRUE);
+		else
+			err = -EPERM;
+		break;
+	case SIOCGRECEIVING:
+		rq->ifr_receiving = is_sir(ir) ?
+				ir->rx_buff.state != OUTSIDE_FRAME : 0;
+		break;
+	default:
+		err = -EOPNOTSUPP;
+		break;
+	}
+
+	return err;
+}
+
+static int fsl_ir_hard_xmit(struct sk_buff *skb, struct net_device *ndev)
+{
+	struct fsl_ir *ir = netdev_priv(ndev);
+	int speed = irda_get_next_speed(skb);
+
+	/*
+	 * Does this packet contain a request to change the interface
+	 * speed?  If so, remember it until we complete the transmission
+	 * of this frame.
+	 */
+	if (speed != ir->speed && speed != -1)
+		ir->new_speed = speed;
+
+	/*
+	 * If this is an empty frame, we can bypass a lot.
+	 */
+	if (skb->len == 0) {
+		if (ir->new_speed) {
+			ir->new_speed = 0;
+			fsl_ir_set_speed(ndev, speed);
+		}
+		dev_kfree_skb(skb);
+		return 0;
+	}
+
+	/* Tx buff is one */
+	netif_stop_queue(ndev);
+	if (is_sir(ir)) {
+		ir->tx_buff.data = ir->tx_buff.head;
+		ir->tx_buff.len = async_wrap_skb(skb, ir->tx_buff.data,
+						 ir->tx_buff.truesize);
+		dev_kfree_skb(skb);
+		setbits32(&ir->reg_base->scr1, FSL_IR_SCR1_TRDYEN);
+	} else {
+		unsigned int mtt = irda_get_mtt(skb);
+		struct timeval now;
+		int pending;
+
+		ir->tx_buff.skb = skb;
+		ir->tx_buff.len = skb->len;
+
+		/*
+		 * If we have a mean turn-around time, impose the specified
+		 * specified delay.  We could shorten this by timing from
+		 * the point we received the packet.
+		 */
+		if (mtt) {
+			do_gettimeofday(&now);
+			pending = now.tv_usec - ir->stamp.tv_usec;
+
+			if (pending < 0)
+				pending += 1000000;
+
+			if (mtt > pending)
+				mtt -= pending;
+			else if (pending < mtt * 2)
+				mtt = 0;
+			udelay(mtt);
+		}
+
+		/* Enable Tx */
+		out_be32(&ir->reg_base->firitctr, skb->len - 1);
+		setbits32(&ir->reg_base->firitcr, FSL_FIRITCR_TE);
+		fir_tx(ir);
+	}
+
+	ndev->trans_start = jiffies;
+	return 0;
+}
+
+static int fsl_ir_open(struct net_device *ndev)
+{
+	struct fsl_ir *ir = netdev_priv(ndev);
+	int err = 0;
+	unsigned int baudrate_mask;
+
+	dev_info(ir->dev, "%s open\n", ndev->name);
+
+	irda_init_max_qos_capabilies(&ir->qos);
+
+	/*
+	 * We support SIR, MIR and FIR rate.
+	 */
+	baudrate_mask = IR_9600 | IR_19200 | IR_38400 | IR_57600 | IR_115200
+			| IR_576000 | IR_1152000 	/* MIR rates */
+			| (IR_4000000 << 8);		/* FIR rates */
+	ir->qos.baud_rate.bits &= baudrate_mask;
+	ir->qos.min_turn_time.bits = 7;	/* Min turn around time is 1ms */
+
+	/* 64 bytes receive size, since FIFO buffer size is 128 bytes. */
+	ir->qos.data_size.bits = 0x01;
+
+	irda_qos_bits_to_value(&ir->qos);
+
+	ir->speed = 0;
+	fsl_ir_start(ndev);
+
+	/*http://www.kernel.org/pub/scm/linux/kernel/git/avi/kvm.git
+	 * Open a new IrLAP layer instance.
+	 */
+	ir->irlap = irlap_open(ndev, &ir->qos, "fsl-irda");
+	if (!ir->irlap) {
+		err = -ENOMEM;
+		goto err;
+	}
+
+	if (ir->irq != NO_IRQ) {
+		err = request_irq(ir->irq, &fsl_ir_do_interrupt, IRQF_SHARED,
+					"fsl-irda", ndev);
+		if (err)
+			dev_err(&ndev->dev, "fsl irda request_irq error "
+				"with return %d\n", err);
+	}
+
+	netif_start_queue(ndev);
+	return 0;
+
+err:
+	free_irq(ir->irq, ndev);
+	irlap_close(ir->irlap);
+	fsl_ir_halt(ir);
+	return err;
+}
+
+static int fsl_ir_stop(struct net_device *ndev)
+{
+	struct fsl_ir *ir = netdev_priv(ndev);
+
+	irlap_close(ir->irlap);
+	ir->irlap = NULL;
+
+	netif_stop_queue(ndev);
+	free_irq(ir->irq, ndev);
+	fsl_ir_halt(ir);
+	return 0;
+}
+
+static int of_fsl_ir_probe(struct of_device *ofdev,
+			const struct of_device_id *match)
+{
+	struct net_device *ndev;
+	struct fsl_ir *ir = NULL;
+	int err;
+	const void *of_val;
+	int len;
+	struct device_node *cpu_node;
+
+	ndev = alloc_irdadev(sizeof(struct fsl_ir));
+	if (!ndev) {
+		err = -ENOMEM;
+		goto err;
+	}
+
+	ir = ndev->priv;
+	ir->dev = &ofdev->dev;
+	ir->plat_op = ofdev->node->data;
+
+	spin_lock_init(&ir->tx_lock);
+	spin_lock_init(&ir->rx_lock);
+
+	/* get register base from of-node */
+	err = of_address_to_resource(ofdev->node, 0, &ir->res);
+	if (err) {
+		dev_err(&ofdev->dev, "Can't get %s property 'reg'\n",
+				ofdev->node->full_name);
+		goto err;
+	}
+
+	ir->reg_base = ioremap(ir->res.start, ir->res.end - ir->res.start + 1);
+	tasklet_init(&ir->tx_tasklet, fsl_ir_tx_do_tasklet, (unsigned long)ir);
+
+	cpu_node = of_find_node_by_type(NULL, "cpu");
+	if (!cpu_node) {
+		err = -ENODEV;
+		goto err;
+	}
+
+	of_val = of_get_property(cpu_node, "bus-frequency", &len);
+	if (of_val)
+		ir->clock_in = *(u32 *)of_val / 2;
+
+	/* Get irq from of-node */
+	ir->irq = irq_of_parse_and_map(ofdev->node, 0);
+
+	ndev->hard_start_xmit	= fsl_ir_hard_xmit;
+	ndev->open		= fsl_ir_open;
+	ndev->stop		= fsl_ir_stop;
+	ndev->do_ioctl		= fsl_ir_ioctl;
+	ndev->get_stats		= fsl_ir_stats;
+	ndev->irq		= ir->irq;
+
+	err = register_netdev(ndev);
+	if (err)
+		goto err;
+
+	dev_set_drvdata(&ofdev->dev, ndev);
+
+	dev_info(&ofdev->dev, "Found fsl-irda controller\n");
+	dev_info(&ofdev->dev, "Clock-in frequency %dHz, irq %d, %s\n",
+				ir->clock_in, ir->irq, ndev->name);
+
+err:
+	return err;
+}
+
+static int of_fsl_ir_remove(struct of_device *ofdev)
+{
+	struct net_device *ndev = dev_get_drvdata(&ofdev->dev);
+
+	if (ndev) {
+		unregister_netdev(ndev);
+		free_netdev(ndev);
+	}
+	return 0;
+}
+
+static struct of_device_id of_fsl_ir_ids[] = {
+	{ .compatible = "fsl,mpc8610-irda", },
+	{}
+};
+
+static struct of_platform_driver of_fsl_ir_drv = {
+	.owner		= THIS_MODULE,
+	.name		= "of-fsl-irda",
+	.match_table	= of_fsl_ir_ids,
+	.probe		= of_fsl_ir_probe,
+	.remove		= of_fsl_ir_remove,
+};
+
+static __init int of_fsl_ir_init(void)
+{
+	return of_register_platform_driver(&of_fsl_ir_drv);
+}
+
+static void __exit of_fsl_ir_exit(void)
+{
+	of_unregister_platform_driver(&of_fsl_ir_drv);
+}
+
+device_initcall(of_fsl_ir_init);
+module_exit(of_fsl_ir_exit);
+
+MODULE_AUTHOR("Zhang Wei <wei.zhang@freescale.com>");
+MODULE_DESCRIPTION("Freescale MPC8610 IrDA driver");
+MODULE_LICENSE("GPL");
diff --git a/include/linux/fsl_ir.h b/include/linux/fsl_ir.h
new file mode 100644
index 0000000..2ee623a
--- /dev/null
+++ b/include/linux/fsl_ir.h
@@ -0,0 +1,207 @@
+/*
+ * Copyright (C) 2007 Freescale Semiconductor, Inc. All rights reserved.
+ *
+ * Author: Zhang Wei, wei.zhang@freescale.com, Oct. 2007
+ *
+ * Description:
+ * This file is the header file for Freescale IrDA driver.
+ *
+ * Changelog:
+ * Oct 2007 Zhang Wei <wei.zhang@freescale.com>
+ * - Initial version.
+ *
+ * This file is part of the Linux kernel
+ *
+ * This is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ */
+#ifndef __LINUX_FSL_IR_H
+#define __LINUX_FSL_IR_H
+
+#include <linux/device.h>
+#include <net/irda/irda.h>
+#include <net/irda/wrapper.h>
+#include <net/irda/irda_device.h>
+
+enum fsl_ir_mode {
+	FSL_IR_CLOSE,
+	FSL_IR_SIR,
+	FSL_IR_MIR,
+	FSL_IR_FIR
+};
+
+#define FSL_IR_SRXD_CHARRDY	0x00008000 /* Character ready */
+#define FSL_IR_SRXD_ERR		0x00004000 /* Error detect */
+#define FSL_IR_SRXD_OVRRUN	0x00002000 /* Receiver overrun */
+#define FSL_IR_SRXD_FRMERR	0x00001000 /* Frame error */
+#define FSL_IR_SRXD_PRERR	0x00000400 /* Parity error */
+
+#define FSL_IR_SCR1_TRDYEN	0x00002000 /* Transmitter ready enable */
+#define FSL_IR_SCR1_RRDYEN	0x00000200 /* Receive ready interrupt enable */
+#define FSL_IR_SCR1_RXDMAEN	0x00000100 /* Receive ready DMA enable */
+#define FSL_IR_SCR1_IREN	0x00000080 /* Infrared interface enable */
+#define FSL_IR_SCR1_TXDMAEN	0x00000008 /* Transmitter ready DMA enable */
+#define FSL_IR_SCR1_ATDMAEN	0x00000004 /* Aging DMA timer enable */
+#define FSL_IR_SCR1_SIRIEN	0x00000001 /* SIRI Enable */
+
+#define FSL_IR_SCR2_PREN	0x00000100 /* Parity enable */
+#define FSL_IR_SCR2_PROE	0x00000080 /* Parity odd/even */
+#define FSL_IR_SCR2_STPB	0x00000040 /* Stop bit */
+#define FSL_IR_SCR2_WS		0x00000020 /* Word size */
+#define FSL_IR_SCR2_ATEN	0x00000008 /* Aging timer enable */
+#define FSL_IR_SCR2_TXEN	0x00000004 /* Transmitter enable */
+#define FSL_IR_SCR2_RXEN	0x00000002 /* Receiver enable */
+#define FSL_IR_SCR2_SRST	0x00000001 /* Software reset */
+
+#define FSL_IR_SCR3_RXDSEN	0x00000040 /* Receive status interrupt enable */
+#define FSL_IR_SCR3_AIRINTEN	0x00000020 /* Asynchronous IR Wake int enable */
+#define FSL_IR_SCR3_AWAKEN	0x00000010 /* Asynchronous WAKE int enable */
+#define FSL_IR_SCR3_INVT	0x00000002 /* Inverted infrared transmission */
+
+#define FSL_IR_SCR4_INVR	0x00000200 /* Inverted infrared reception */
+#define FSL_IR_SCR4_ENIRI	0x00000100 /* Serial irda interrupt enable*/
+#define FSL_IR_SCR4_IRSC	0x00000020 /* IR special case */
+#define FSL_IR_SCR4_LPBYP	0x00000010 /* Low power bypass */
+#define FSL_IR_SCR4_TCEN	0x00000008 /* Transmit complete int enable */
+#define FSL_IR_SCR4_DREN	0x00000001 /* Receive data ready int enable */
+
+#define FSL_IR_SFCR_RFDIV_MASK	0x00000380
+#define FSL_IR_SFCR_RFDIV_6	0x00000000
+#define FSL_IR_SFCR_RFDIV_5	0x00000080
+#define FSL_IR_SFCR_RFDIV_4	0x00000100
+#define FSL_IR_SFCR_RFDIV_3	0x00000180
+#define FSL_IR_SFCR_RFDIV_2	0x00000200
+#define FSL_IR_SFCR_RFDIV_1	0x00000210
+#define FSL_IR_SFCR_RFDIV_7	0x00000300
+
+#define FSL_IR_STS_LOOP		0x00001000	/* Loop TX and RX for test */
+#define FSL_IR_STS_LOOPIR	0x00000400	/* Loop TX and RX for test */
+#define FSL_IR_STS_TXFULL	0x00000010	/* TX FIFO full */
+
+#define FSL_IR_SSR1_TRDY	0x00002000	/* Transmitter ready */
+#define FSL_IR_SSR1_RRDY	0x00000200	/* Receiver ready */
+#define FSL_IR_SSR1_AGTIM	0x00000100	/* Aging timer interrupt flag */
+
+#define FSL_IR_SSR2_TXDC	0x00000008	/* Transmitter is complete */
+#define FSL_IR_SSR2_RDR		0x00000001	/* Receive data is ready */
+
+#define FSL_FIRITCR_TDT_32	0x00000800	/* TDT trigger leverl = 32 */
+#define FSL_FIRITCR_TDT_16	0x00000400	/* TDT trigger leverl = 16 */
+#define FSL_FIRITCR_TCIE	0x00000200	/* Transmit complete INT en */
+#define FSL_FIRITCR_PCF		0x00000040	/* Send abort if underrun */
+#define FSL_FIRITCR_PC		0x00000020	/* Send abort is sip == 1 */
+#define FSL_FIRITCR_TM_FIR	0x00000000
+#define FSL_FIRITCR_TM_MIR_576	0x00000002
+#define FSL_FIRITCR_TM_MIR_1152	0x00000004
+#define FSL_FIRITCR_TE		0x00000001
+
+#define FSL_FIRIRCR_RAM		0x03000000	/* Match RA and broadcast */
+#define FSL_FIRIRCR_RPEDE	0x00000800	/* Enable Rx DMA request */
+#define FSL_FIRIRCR_RDT_96	0x00000600	/* Rx DMA trigger level is 96 */
+#define FSL_FIRIRCR_RDT_32	0x00000200	/* Rx DMA trigger level is 32 */
+#define FSL_FIRIRCR_RDT_16	0x00000100	/* Rx DMA trigger level is 32 */
+#define FSL_FIRIRCR_RPA		0x00000080	/* Clear FIFO is illegal recv */
+#define FSL_FIRIRCR_RPEIE	0x00000040	/* Recv packet end INT enable */
+#define FSL_FIRIRCR_PAIE	0x00000020	/* Recv abort INT enable */
+#define FSL_FIRIRCR_RFOIE	0x00000010	/* Recv overrun INT enable */
+#define FSL_FIRIRCR_RPP		0x00000008	/* Recv signal is inverted*/
+#define FSL_FIRIRCR_RM_FIR	0x00000000
+#define FSL_FIRIRCR_RM_MIR_576	0x00000002
+#define FSL_FIRIRCR_RM_MIR_1152	0x00000004
+#define FSL_FIRIRCR_RE		0x00000001
+
+#define FSL_FIRITSR_TC		0x00000008	/* Transmit complete */
+#define FSL_FIRITSR_TPE		0x00000002	/* Transmit Packet complete */
+
+#define FSL_FIRIRSR_RFP_mask	0x0000ff00	/* Receiver FIFO point mask */
+#define FSL_FIRIRSR_PAS		0x00000020	/* Preamble search */
+#define FSL_FIRIRSR_RPE		0x00000010	/* Receiver packet end */
+#define FSL_FIRIRSR_RFO		0x00000008	/* Receiver FIFO overrun */
+#define FSL_FIRIRSR_BAM		0x00000006	/* Broadcast address match */
+#define FSL_FIRIRSR_CRCE	0x00000002	/* Receiver CRC error */
+#define FSL_FIRIRSR_DDE		0x00000001	/* Receiver DD error */
+
+struct fsl_ir_reg {
+	__be32	srxd;		/* 0x00: SIRI receiver register */
+	u8	res1[0x3c];
+	__be32	stxd;		/* 0x40: SIRI transmitter register */
+	u8	res2[0x3c];
+	__be32	scr1;		/* 0x80: SIRI control register 1 */
+	__be32	scr2;		/* 0x84: SIRI control register 2 */
+	__be32	scr3;		/* 0x88: SIRI control register 3 */
+	__be32	scr4;		/* 0x8c: SIRI control register 4 */
+	__be32	sfcr;		/* 0x90: SIRI FIFO control register */
+	__be32	ssr1;		/* 0x94: SIRI status register 1 */
+	__be32	ssr2;		/* 0x98: SIRI status register 2 */
+	__be32	sesc;		/* 0x9c: SIRI escape character register */
+	__be32	stim;		/* 0xa0: SIRI escape timer register */
+	__be32	sbir;		/* 0xa4: SIRI BRM incremental register */
+	__be32	sbmr;		/* 0xa8: SIRI BRM modulator register */
+	__be32	sbrc;		/* 0xac: SIRI baud rate count register */
+	__be32	sonems;		/* 0xb0: SIRI one millisecond register */
+	__be32	sts;		/* 0xb4: SIRI test register */
+	u8	res3[0x48];
+	__be32	firitcr;	/* 0x100: FIRI transmit control register */
+	__be32	firitctr;	/* 0x104: FIRI transmit count register */
+	__be32	firircr;	/* 0x108: FIRI receive control register */
+	__be32	firitsr;	/* 0x10c: FIRI transmit status register */
+	__be32	firirsr;	/* 0x110: FIRI receive status register */
+	__be32	tfifo;		/* 0x114: Transmiter FIFO */
+	__be32	rfifo;		/* 0x118: Receiver FIFO */
+	__be32	firicr;		/* 0x11c: FIRI control register */
+	u8	res4[0xee0];
+};
+
+#define FSL_SIR_TXBUFF_SIZE	14384
+#define FSL_SIR_RXBUFF_SIZE	4000
+
+enum sir_parity {
+	SIR_PARITY_NONE,
+	SIR_PARITY_EVEN,
+	SIR_PARITY_ODD
+};
+
+#define FSL_SIR_TX_LEVEL	2
+#define FSL_SIR_TX_MAX		32
+
+#define FIR_PKG_SIZE		2048
+
+struct fsl_ir;
+
+struct fsl_ir_op {
+	void (*set_ir_mode)(struct fsl_ir *, u32 speed);
+};
+
+struct fsl_ir {
+	struct fsl_ir_reg __iomem	*reg_base;
+	struct resource			res;
+	struct device			*dev;
+	int				irq;
+	struct fsl_ir_op		*plat_op;
+
+	struct irlap_cb			*irlap;
+	struct qos_info			qos;
+	struct net_device_stats		stats;
+
+	int				speed;
+	int				new_speed;
+	u32				clock_in;
+	int				div;
+
+	u8				txb[FSL_SIR_TXBUFF_SIZE];
+	u8				rxb[FSL_SIR_RXBUFF_SIZE];
+	iobuff_t			tx_buff;
+	iobuff_t			rx_buff;
+
+	spinlock_t			tx_lock;  /* Lock for Tx */
+	spinlock_t			rx_lock;  /* Lock for Rx */
+
+	struct tasklet_struct		tx_tasklet;
+	struct delayed_work		rx_work;
+	struct timeval			stamp;
+};
+
+#endif /* __LINUX_FSL_IR_H */
-- 
1.5.5.1
