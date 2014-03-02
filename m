From: Vince Bridgers <vbridgers2013@gmail.com>
Subject: =?UTF-8?q?=5BPATCH=20RFC=203/3=5D=20Altera=20TSE=3A=20Add=20Altera=20Triple=20Speed=20Ethernet=20=28TSE=29=20Driver?=
Date: Sun,  2 Mar 2014 14:42:02 -0600
Message-ID: <1393792922-2381-4-git-send-email-vbridgers2013@gmail.com>
References: <1393792922-2381-1-git-send-email-vbridgers2013@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: robh+dt@kernel.org, pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, galak@codeaurora.org,
	rob@landley.net, vbridgers2013@gmail.com
To: devicetree@vger.kernel.org, netdev@vger.kernel.org,
	linux-doc@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f175.google.com ([209.85.214.175]:35124 "EHLO
	mail-ob0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752952AbaCBUrA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Mar 2014 15:47:00 -0500
In-Reply-To: <1393792922-2381-1-git-send-email-vbridgers2013@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the Altera Triple Speed Ethernet (TSE) Driver for Alter=
a's
soft 10/100/1000 Ethernet controller that can be configured and synthes=
ized
for Altera's FPGAs using the Quartus toolchain. The driver supports SGD=
MA and
MSGDMA soft IP configurable through Quartus where the mode of operation=
 and
configuration options are described in the platform bus device tree.

This driver was tested with Quartus 13.1 and 14.0 on Altera's Cyclone 4=
,
Cyclone 5, and Cyclone 5 SOC FPGAs on the ARM A9 and NIOS processors.

Signed-off-by: Vince Bridgers <vbridgers2013@gmail.com>
---
 drivers/net/ethernet/Kconfig                     |    1 +
 drivers/net/ethernet/Makefile                    |    1 +
 drivers/net/ethernet/altera/Kconfig              |    8 +
 drivers/net/ethernet/altera/Makefile             |    7 +
 drivers/net/ethernet/altera/altera_msgdma.c      |  205 +++
 drivers/net/ethernet/altera/altera_msgdma.h      |   35 +
 drivers/net/ethernet/altera/altera_msgdmahw.h    |  168 +++
 drivers/net/ethernet/altera/altera_sgdma.c       |  558 ++++++++
 drivers/net/ethernet/altera/altera_sgdma.h       |   36 +
 drivers/net/ethernet/altera/altera_sgdmahw.h     |  125 ++
 drivers/net/ethernet/altera/altera_tse.c         | 1578 ++++++++++++++=
++++++++
 drivers/net/ethernet/altera/altera_tse.h         |  477 +++++++
 drivers/net/ethernet/altera/altera_tse_ethtool.c |  226 ++++
 drivers/net/ethernet/altera/altera_utils.c       |   46 +
 drivers/net/ethernet/altera/altera_utils.h       |   28 +
 15 files changed, 3499 insertions(+)
 create mode 100644 drivers/net/ethernet/altera/Kconfig
 create mode 100644 drivers/net/ethernet/altera/Makefile
 create mode 100644 drivers/net/ethernet/altera/altera_msgdma.c
 create mode 100644 drivers/net/ethernet/altera/altera_msgdma.h
 create mode 100644 drivers/net/ethernet/altera/altera_msgdmahw.h
 create mode 100644 drivers/net/ethernet/altera/altera_sgdma.c
 create mode 100644 drivers/net/ethernet/altera/altera_sgdma.h
 create mode 100644 drivers/net/ethernet/altera/altera_sgdmahw.h
 create mode 100644 drivers/net/ethernet/altera/altera_tse.c
 create mode 100644 drivers/net/ethernet/altera/altera_tse.h
 create mode 100644 drivers/net/ethernet/altera/altera_tse_ethtool.c
 create mode 100644 drivers/net/ethernet/altera/altera_utils.c
 create mode 100644 drivers/net/ethernet/altera/altera_utils.h

diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfi=
g
index 506b024..39484b5 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -22,6 +22,7 @@ source "drivers/net/ethernet/adaptec/Kconfig"
 source "drivers/net/ethernet/aeroflex/Kconfig"
 source "drivers/net/ethernet/allwinner/Kconfig"
 source "drivers/net/ethernet/alteon/Kconfig"
+source "drivers/net/ethernet/altera/Kconfig"
 source "drivers/net/ethernet/amd/Kconfig"
 source "drivers/net/ethernet/apple/Kconfig"
 source "drivers/net/ethernet/arc/Kconfig"
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makef=
ile
index c0b8789..adf61af 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -8,6 +8,7 @@ obj-$(CONFIG_NET_VENDOR_ADAPTEC) +=3D adaptec/
 obj-$(CONFIG_GRETH) +=3D aeroflex/
 obj-$(CONFIG_NET_VENDOR_ALLWINNER) +=3D allwinner/
 obj-$(CONFIG_NET_VENDOR_ALTEON) +=3D alteon/
+obj-$(CONFIG_ALTERA_TSE) +=3D altera/
 obj-$(CONFIG_NET_VENDOR_AMD) +=3D amd/
 obj-$(CONFIG_NET_VENDOR_APPLE) +=3D apple/
 obj-$(CONFIG_NET_VENDOR_ARC) +=3D arc/
diff --git a/drivers/net/ethernet/altera/Kconfig b/drivers/net/ethernet=
/altera/Kconfig
new file mode 100644
index 0000000..1766e63
--- /dev/null
+++ b/drivers/net/ethernet/altera/Kconfig
@@ -0,0 +1,8 @@
+config ALTERA_TSE
+	tristate "Altera Triple-Speed Ethernet MAC support"
+	select PHYLIB
+	---help---
+	  This driver supports the Altera Triple-Speed (TSE) Ethernet MAC.
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called altera_tse_driver.
diff --git a/drivers/net/ethernet/altera/Makefile b/drivers/net/etherne=
t/altera/Makefile
new file mode 100644
index 0000000..3aa7039
--- /dev/null
+++ b/drivers/net/ethernet/altera/Makefile
@@ -0,0 +1,7 @@
+#
+# Makefile for the Altera device drivers.
+#
+
+obj-$(CONFIG_ALTERA_TSE) +=3D altera_tse_driver.o
+altera_tse_driver-objs :=3D altera_tse.o altera_tse_ethtool.o \
+altera_msgdma.o altera_sgdma.o altera_utils.o
diff --git a/drivers/net/ethernet/altera/altera_msgdma.c b/drivers/net/=
ethernet/altera/altera_msgdma.c
new file mode 100644
index 0000000..cd15647
--- /dev/null
+++ b/drivers/net/ethernet/altera/altera_msgdma.c
@@ -0,0 +1,205 @@
+/* Altera TSE SGDMA and MSGDMA Linux driver
+ * Copyright (C) 2014 Altera Corporation. All rights reserved
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITH=
OUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY =
or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public Licen=
se for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License a=
long with
+ * this program.  If not, see <http://www.gnu.org/licenses/>.
+ */
+
+#include "altera_utils.h"
+#include "altera_tse.h"
+#include "altera_msgdmahw.h"
+
+/* No initialization work to do for MSGDMA */
+int msgdma_initialize(struct altera_tse_private *priv)
+{
+	return 0;
+}
+
+void msgdma_uninitialize(struct altera_tse_private *priv)
+{
+}
+
+void msgdma_reset(struct altera_tse_private *priv)
+{
+	int counter;
+	struct msgdma_csr *txcsr =3D
+		(struct msgdma_csr *)priv->tx_dma_csr;
+	struct msgdma_csr *rxcsr =3D
+		(struct msgdma_csr *)priv->rx_dma_csr;
+
+	/* Reset Rx mSGDMA */
+	iowrite32(MSGDMA_CSR_STAT_MASK, &rxcsr->status);
+	iowrite32(MSGDMA_CSR_CTL_RESET, &rxcsr->control);
+
+	counter =3D 0;
+	while (counter++ < ALTERA_TSE_SW_RESET_WATCHDOG_CNTR) {
+		if (tse_bit_is_clear(&rxcsr->status,
+				     MSGDMA_CSR_STAT_RESETTING))
+			break;
+		udelay(1);
+	}
+
+	if ((counter >=3D ALTERA_TSE_SW_RESET_WATCHDOG_CNTR) &&
+	    (netif_msg_drv(priv)))
+		dev_warn(priv->device,
+			 "TSE Rx mSGDMA resetting bit never cleared!\n");
+
+	/* clear all status bits */
+	iowrite32(MSGDMA_CSR_STAT_MASK, &rxcsr->status);
+
+	/* Reset Tx mSGDMA */
+	iowrite32(MSGDMA_CSR_STAT_MASK, &txcsr->status);
+	iowrite32(MSGDMA_CSR_CTL_RESET, &txcsr->control);
+
+	counter =3D 0;
+	while (counter++ < ALTERA_TSE_SW_RESET_WATCHDOG_CNTR) {
+		if (tse_bit_is_clear(&txcsr->status,
+				     MSGDMA_CSR_STAT_RESETTING))
+			break;
+		udelay(1);
+	}
+
+	if ((counter >=3D ALTERA_TSE_SW_RESET_WATCHDOG_CNTR) &&
+	    (netif_msg_drv(priv)))
+		dev_warn(priv->device,
+			 "TSE Tx mSGDMA resetting bit never cleared!\n");
+
+	/* clear all status bits */
+	iowrite32(MSGDMA_CSR_STAT_MASK, &txcsr->status);
+}
+
+void msgdma_disable_rxirq(struct altera_tse_private *priv)
+{
+	struct msgdma_csr *csr =3D priv->rx_dma_csr;
+	tse_clear_bit(&csr->control, MSGDMA_CSR_CTL_GLOBAL_INTR);
+}
+
+void msgdma_enable_rxirq(struct altera_tse_private *priv)
+{
+	struct msgdma_csr *csr =3D priv->rx_dma_csr;
+	tse_set_bit(&csr->control, MSGDMA_CSR_CTL_GLOBAL_INTR);
+}
+
+void msgdma_disable_txirq(struct altera_tse_private *priv)
+{
+	struct msgdma_csr *csr =3D priv->tx_dma_csr;
+	tse_clear_bit(&csr->control, MSGDMA_CSR_CTL_GLOBAL_INTR);
+}
+
+void msgdma_enable_txirq(struct altera_tse_private *priv)
+{
+	struct msgdma_csr *csr =3D priv->tx_dma_csr;
+	tse_set_bit(&csr->control, MSGDMA_CSR_CTL_GLOBAL_INTR);
+}
+
+void msgdma_clear_rxirq(struct altera_tse_private *priv)
+{
+	struct msgdma_csr *csr =3D priv->rx_dma_csr;
+	iowrite32(MSGDMA_CSR_STAT_IRQ, &csr->status);
+}
+
+void msgdma_clear_txirq(struct altera_tse_private *priv)
+{
+	struct msgdma_csr *csr =3D priv->tx_dma_csr;
+	iowrite32(MSGDMA_CSR_STAT_IRQ, &csr->status);
+}
+
+/* return 0 to indicate transmit is pending */
+int msgdma_tx_buffer(struct altera_tse_private *priv, struct tse_buffe=
r *buffer)
+{
+	struct msgdma_extended_desc *desc =3D priv->tx_dma_desc;
+
+	iowrite32(buffer->dma_addr, &desc->read_addr_lo);
+	iowrite32(0, &desc->read_addr_hi);
+	iowrite32(0, &desc->write_addr_lo);
+	iowrite32(0, &desc->write_addr_hi);
+	iowrite32(buffer->len, &desc->len);
+	iowrite32(0, &desc->burst_seq_num);
+	iowrite32(MSGDMA_DESC_TX_STRIDE, &desc->stride);
+	iowrite32(MSGDMA_DESC_CTL_TX_SINGLE, &desc->control);
+	return 0;
+}
+
+u32 msgdma_tx_completions(struct altera_tse_private *priv)
+{
+	u32 ready =3D 0;
+	u32 inuse;
+	u32 status;
+	struct msgdma_csr *txcsr =3D
+		(struct msgdma_csr *)priv->tx_dma_csr;
+
+	/* Get number of sent descriptors */
+	inuse =3D ioread32(&txcsr->rw_fill_level) & 0xffff;
+
+	if (inuse) { /* Tx FIFO is not empty */
+		ready =3D priv->tx_prod - priv->tx_cons - inuse - 1;
+	} else {
+		/* Check for buffered last packet */
+		status =3D ioread32(&txcsr->status);
+		if (status & MSGDMA_CSR_STAT_BUSY)
+			ready =3D priv->tx_prod - priv->tx_cons - 1;
+		else
+			ready =3D priv->tx_prod - priv->tx_cons;
+	}
+	return ready;
+}
+
+/* Put buffer to the mSGDMA RX FIFO
+ */
+int msgdma_add_rx_desc(struct altera_tse_private *priv,
+			struct tse_buffer *rxbuffer)
+{
+	struct msgdma_extended_desc *desc =3D priv->rx_dma_desc;
+	u32 len =3D priv->rx_dma_buf_sz;
+	dma_addr_t dma_addr =3D rxbuffer->dma_addr;
+	u32 control =3D (MSGDMA_DESC_CTL_END_ON_EOP
+			| MSGDMA_DESC_CTL_END_ON_LEN
+			| MSGDMA_DESC_CTL_TR_COMP_IRQ
+			| MSGDMA_DESC_CTL_EARLY_IRQ
+			| MSGDMA_DESC_CTL_TR_ERR_IRQ
+			| MSGDMA_DESC_CTL_GO);
+
+	iowrite32(0, &desc->read_addr_lo);
+	iowrite32(0, &desc->read_addr_hi);
+	iowrite32(dma_addr, &desc->write_addr_lo);
+	iowrite32(0, &desc->write_addr_hi);
+	iowrite32(len, &desc->len);
+	iowrite32(0, &desc->burst_seq_num);
+	iowrite32(0x00010001, &desc->stride);
+	iowrite32(control, &desc->control);
+	return 1;
+}
+
+/* status is returned on upper 16 bits,
+ * length is returned in lower 16 bits
+ */
+u32 msgdma_rx_status(struct altera_tse_private *priv)
+{
+	u32 rxstatus =3D 0;
+	u32 pktlength;
+	u32 pktstatus;
+	struct msgdma_csr *rxcsr =3D
+		(struct msgdma_csr *)priv->rx_dma_csr;
+	struct msgdma_response *rxresp =3D
+		(struct msgdma_response *)priv->rx_dma_resp;
+
+	if (ioread32(&rxcsr->resp_fill_level) & 0xffff) {
+		pktlength =3D ioread32(&rxresp->bytes_transferred);
+		pktstatus =3D ioread32(&rxresp->status);
+		rxstatus =3D pktstatus;
+		rxstatus =3D rxstatus << 16;
+		rxstatus |=3D (pktlength & 0xffff);
+	}
+	return rxstatus;
+}
+
+
diff --git a/drivers/net/ethernet/altera/altera_msgdma.h b/drivers/net/=
ethernet/altera/altera_msgdma.h
new file mode 100644
index 0000000..707bf6a
--- /dev/null
+++ b/drivers/net/ethernet/altera/altera_msgdma.h
@@ -0,0 +1,35 @@
+/* Altera TSE SGDMA and MSGDMA Linux driver
+ * Copyright (C) 2014 Altera Corporation. All rights reserved
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITH=
OUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY =
or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public Licen=
se for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License a=
long with
+ * this program.  If not, see <http://www.gnu.org/licenses/>.
+ */
+
+#ifndef __ALTERA_MSGDMA_H__
+#define __ALTERA_MSGDMA_H__
+
+void msgdma_reset(struct altera_tse_private *);
+void msgdma_enable_txirq(struct altera_tse_private *);
+void msgdma_enable_rxirq(struct altera_tse_private *);
+void msgdma_disable_rxirq(struct altera_tse_private *);
+void msgdma_disable_txirq(struct altera_tse_private *);
+void msgdma_clear_rxirq(struct altera_tse_private *);
+void msgdma_clear_txirq(struct altera_tse_private *);
+u32 msgdma_tx_completions(struct altera_tse_private *);
+int msgdma_add_rx_desc(struct altera_tse_private *, struct tse_buffer =
*);
+int msgdma_tx_buffer(struct altera_tse_private *, struct tse_buffer *)=
;
+u32 msgdma_rx_status(struct altera_tse_private *);
+int msgdma_initialize(struct altera_tse_private *);
+void msgdma_uninitialize(struct altera_tse_private *);
+
+#endif /*  __ALTERA_MSGDMA_H__ */
+
diff --git a/drivers/net/ethernet/altera/altera_msgdmahw.h b/drivers/ne=
t/ethernet/altera/altera_msgdmahw.h
new file mode 100644
index 0000000..623d2f2
--- /dev/null
+++ b/drivers/net/ethernet/altera/altera_msgdmahw.h
@@ -0,0 +1,168 @@
+/* Altera TSE SGDMA and MSGDMA Linux driver
+ * Copyright (C) 2014 Altera Corporation. All rights reserved
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITH=
OUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY =
or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public Licen=
se for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License a=
long with
+ * this program.  If not, see <http://www.gnu.org/licenses/>.
+ */
+
+#ifndef __ALTERA_MSGDMA_H__
+#define __ALTERA_MSGDMA_H__
+
+/* mSGDMA standard descriptor format
+ */
+struct msgdma_desc {
+	u32 read_addr;	/* data buffer source address */
+	u32 write_addr;	/* data buffer destination address */
+	u32 len;	/* the number of bytes to transfer per descriptor */
+	u32 control;	/* characteristics of the transfer */
+};
+
+/* mSGDMA extended descriptor format
+ */
+struct msgdma_extended_desc {
+	u32 read_addr_lo;	/* data buffer source address low bits */
+	u32 write_addr_lo;	/* data buffer destination address low bits */
+	u32 len;		/* the number of bytes to transfer
+				 * per descriptor
+				 */
+	u32 burst_seq_num;	/* bit 31:24 write burst
+				 * bit 23:16 read burst
+				 * bit 15:0  sequence number
+				 */
+	u32 stride;		/* bit 31:16 write stride
+				 * bit 15:0  read stride
+				 */
+	u32 read_addr_hi;	/* data buffer source address high bits */
+	u32 write_addr_hi;	/* data buffer destination address high bits */
+	u32 control;		/* characteristics of the transfer */
+};
+
+/* mSGDMA descriptor control field bit definitions
+ */
+#define MSGDMA_DESC_CTL_SET_CH(x)	((x) & 0xff)
+#define MSGDMA_DESC_CTL_GEN_SOP		BIT(8)
+#define MSGDMA_DESC_CTL_GEN_EOP		BIT(9)
+#define MSGDMA_DESC_CTL_PARK_READS	BIT(10)
+#define MSGDMA_DESC_CTL_PARK_WRITES	BIT(11)
+#define MSGDMA_DESC_CTL_END_ON_EOP	BIT(12)
+#define MSGDMA_DESC_CTL_END_ON_LEN	BIT(13)
+#define MSGDMA_DESC_CTL_TR_COMP_IRQ	BIT(14)
+#define MSGDMA_DESC_CTL_EARLY_IRQ	BIT(15)
+#define MSGDMA_DESC_CTL_TR_ERR_IRQ	(0xff << 16)
+#define MSGDMA_DESC_CTL_EARLY_DONE	BIT(24)
+/* Writing =E2=80=981=E2=80=99 to the =E2=80=98go=E2=80=99 bit commits=
 the entire descriptor into the
+ * descriptor FIFO(s)
+ */
+#define MSGDMA_DESC_CTL_GO		BIT(31)
+
+/* Tx buffer control flags
+ */
+#define MSGDMA_DESC_CTL_TX_FIRST	(MSGDMA_DESC_CTL_GEN_SOP |	\
+					 MSGDMA_DESC_CTL_TR_ERR_IRQ |	\
+					 MSGDMA_DESC_CTL_GO)
+
+#define MSGDMA_DESC_CTL_TX_MIDDLE	(MSGDMA_DESC_CTL_TR_ERR_IRQ |	\
+					 MSGDMA_DESC_CTL_GO)
+
+#define MSGDMA_DESC_CTL_TX_LAST		(MSGDMA_DESC_CTL_GEN_EOP |	\
+					 MSGDMA_DESC_CTL_TR_COMP_IRQ |	\
+					 MSGDMA_DESC_CTL_TR_ERR_IRQ |	\
+					 MSGDMA_DESC_CTL_GO)
+
+#define MSGDMA_DESC_CTL_TX_SINGLE	(MSGDMA_DESC_CTL_GEN_SOP |	\
+					 MSGDMA_DESC_CTL_GEN_EOP |	\
+					 MSGDMA_DESC_CTL_TR_COMP_IRQ |	\
+					 MSGDMA_DESC_CTL_TR_ERR_IRQ |	\
+					 MSGDMA_DESC_CTL_GO)
+
+#define MSGDMA_DESC_CTL_RX_SINGLE	(MSGDMA_DESC_CTL_END_ON_EOP |	\
+					 MSGDMA_DESC_CTL_END_ON_LEN |	\
+					 MSGDMA_DESC_CTL_TR_COMP_IRQ |	\
+					 MSGDMA_DESC_CTL_EARLY_IRQ |	\
+					 MSGDMA_DESC_CTL_TR_ERR_IRQ |	\
+					 MSGDMA_DESC_CTL_GO)
+
+/* mSGDMA extended descriptor stride definitions
+ */
+#define MSGDMA_DESC_TX_STRIDE		(0x00010001)
+#define MSGDMA_DESC_RX_STRIDE		(0x00010001)
+
+/* mSGDMA dispatcher control and status register map
+ */
+struct msgdma_csr {
+	u32 status;		/* Read/Clear */
+	u32 control;		/* Read/Write */
+	u32 rw_fill_level;	/* bit 31:16 - write fill level
+				 * bit 15:0  - read fill level
+				 */
+	u32 resp_fill_level;	/* bit 15:0 */
+	u32 rw_seq_num;		/* bit 31:16 - write sequence number
+				 * bit 15:0  - read sequence number
+				 */
+	u32 pad[3];		/* reserved */
+};
+
+/* mSGDMA CSR status register bit definitions
+ */
+#define MSGDMA_CSR_STAT_BUSY			BIT(0)
+#define MSGDMA_CSR_STAT_DESC_BUF_EMPTY		BIT(1)
+#define MSGDMA_CSR_STAT_DESC_BUF_FULL		BIT(2)
+#define MSGDMA_CSR_STAT_RESP_BUF_EMPTY		BIT(3)
+#define MSGDMA_CSR_STAT_RESP_BUF_FULL		BIT(4)
+#define MSGDMA_CSR_STAT_STOPPED			BIT(5)
+#define MSGDMA_CSR_STAT_RESETTING		BIT(6)
+#define MSGDMA_CSR_STAT_STOPPED_ON_ERR		BIT(7)
+#define MSGDMA_CSR_STAT_STOPPED_ON_EARLY	BIT(8)
+#define MSGDMA_CSR_STAT_IRQ			BIT(9)
+#define MSGDMA_CSR_STAT_MASK			0x3FF
+#define MSGDMA_CSR_STAT_MASK_WITHOUT_IRQ	0x1FF
+
+#define MSGDMA_CSR_STAT_BUSY_GET(v)			GET_BIT_VALUE(v, 0)
+#define MSGDMA_CSR_STAT_DESC_BUF_EMPTY_GET(v)		GET_BIT_VALUE(v, 1)
+#define MSGDMA_CSR_STAT_DESC_BUF_FULL_GET(v)		GET_BIT_VALUE(v, 2)
+#define MSGDMA_CSR_STAT_RESP_BUF_EMPTY_GET(v)		GET_BIT_VALUE(v, 3)
+#define MSGDMA_CSR_STAT_RESP_BUF_FULL_GET(v)		GET_BIT_VALUE(v, 4)
+#define MSGDMA_CSR_STAT_STOPPED_GET(v)			GET_BIT_VALUE(v, 5)
+#define MSGDMA_CSR_STAT_RESETTING_GET(v)		GET_BIT_VALUE(v, 6)
+#define MSGDMA_CSR_STAT_STOPPED_ON_ERR_GET(v)		GET_BIT_VALUE(v, 7)
+#define MSGDMA_CSR_STAT_STOPPED_ON_EARLY_GET(v)		GET_BIT_VALUE(v, 8)
+#define MSGDMA_CSR_STAT_IRQ_GET(v)			GET_BIT_VALUE(v, 9)
+
+/* mSGDMA CSR control register bit definitions
+ */
+#define MSGDMA_CSR_CTL_STOP			BIT(0)
+#define MSGDMA_CSR_CTL_RESET			BIT(1)
+#define MSGDMA_CSR_CTL_STOP_ON_ERR		BIT(2)
+#define MSGDMA_CSR_CTL_STOP_ON_EARLY		BIT(3)
+#define MSGDMA_CSR_CTL_GLOBAL_INTR		BIT(4)
+#define MSGDMA_CSR_CTL_STOP_DESCS		BIT(5)
+
+/* mSGDMA CSR fill level bits
+ */
+#define MSGDMA_CSR_WR_FILL_LEVEL_GET(v)		(((v) & 0xffff0000) >> 16)
+#define MSGDMA_CSR_RD_FILL_LEVEL_GET(v)		((v) & 0x0000ffff)
+#define MSGDMA_CSR_RESP_FILL_LEVEL_GET(v)	((v) & 0x0000ffff)
+
+/* mSGDMA response register map
+ */
+struct msgdma_response {
+	u32 bytes_transferred;
+	u32 status;
+};
+
+/* mSGDMA response register bit definitions
+ */
+#define MSGDMA_RESP_EARLY_TERM	BIT(8)
+#define MSGDMA_RESP_ERR_MASK	0xFF
+
+#endif /* __ALTERA_MSGDMA_H__*/
+
diff --git a/drivers/net/ethernet/altera/altera_sgdma.c b/drivers/net/e=
thernet/altera/altera_sgdma.c
new file mode 100644
index 0000000..422dc20
--- /dev/null
+++ b/drivers/net/ethernet/altera/altera_sgdma.c
@@ -0,0 +1,558 @@
+/* Altera TSE SGDMA and MSGDMA Linux driver
+ * Copyright (C) 2014 Altera Corporation. All rights reserved
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITH=
OUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY =
or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public Licen=
se for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License a=
long with
+ * this program.  If not, see <http://www.gnu.org/licenses/>.
+ */
+
+#include <linux/list.h>
+#include "altera_utils.h"
+#include "altera_tse.h"
+#include "altera_sgdmahw.h"
+#include "altera_sgdma.h"
+
+static void sgdma_descrip(struct sgdma_descrip *desc,
+			  struct sgdma_descrip *ndesc,
+			  unsigned int ndesc_phys,
+			  dma_addr_t raddr,
+			  dma_addr_t waddr,
+			  u16 length,
+			  int generate_eop,
+			  int rfixed,
+			  int wfixed);
+
+static int sgdma_async_write(struct altera_tse_private *priv,
+			      struct sgdma_descrip *desc);
+
+static int sgdma_async_read(struct altera_tse_private *priv);
+
+static unsigned int
+sgdma_txphysaddr(struct altera_tse_private *priv,
+		 struct sgdma_descrip *desc);
+
+static unsigned int
+sgdma_rxphysaddr(struct altera_tse_private *priv,
+		 struct sgdma_descrip *desc);
+
+static int sgdma_txbusy(struct altera_tse_private *priv);
+
+static int sgdma_rxbusy(struct altera_tse_private *priv);
+
+static void
+queue_tx(struct altera_tse_private *priv, struct tse_buffer *buffer);
+
+static void
+queue_rx(struct altera_tse_private *priv, struct tse_buffer *buffer);
+
+static struct tse_buffer *
+dequeue_tx(struct altera_tse_private *priv);
+
+static struct tse_buffer *
+dequeue_rx(struct altera_tse_private *priv);
+
+static struct tse_buffer *
+queue_rx_peekhead(struct altera_tse_private *priv);
+
+int sgdma_initialize(struct altera_tse_private *priv)
+{
+	priv->descripsz =3D sizeof(struct sgdma_descrip);
+	priv->txdescrips =3D priv->txdescmem/priv->descripsz;
+	priv->rxdescrips =3D priv->rxdescmem/priv->descripsz;
+
+	priv->txctrlreg =3D SGDMA_CTRLREG_ILASTD;
+
+	priv->rxctrlreg =3D SGDMA_CTRLREG_IDESCRIP |
+		      SGDMA_CTRLREG_ILASTD;
+
+	INIT_LIST_HEAD(&priv->txlisthd);
+	INIT_LIST_HEAD(&priv->rxlisthd);
+
+	priv->rxdescphys =3D (dma_addr_t) 0;
+	priv->txdescphys =3D (dma_addr_t) 0;
+
+	priv->rxdescphys =3D dma_map_single(priv->device, priv->rx_dma_desc,
+					  priv->rxdescmem, DMA_BIDIRECTIONAL);
+
+	if (dma_mapping_error(priv->device, priv->rxdescphys)) {
+		sgdma_uninitialize(priv);
+		dev_dbg(priv->device, "error mapping rx descriptor memory\n");
+		return -EINVAL;
+	}
+
+	priv->txdescphys =3D dma_map_single(priv->device, priv->rx_dma_desc,
+					  priv->rxdescmem, DMA_TO_DEVICE);
+
+	if (dma_mapping_error(priv->device, priv->txdescphys)) {
+		sgdma_uninitialize(priv);
+		dev_dbg(priv->device, "error mapping tx descriptor memory\n");
+		return -EINVAL;
+	}
+	dev_dbg(priv->device, "TSE rxdma %x, phys %x, size %d, bus %x\n",
+		(unsigned int)priv->rx_dma_desc,
+		(unsigned int)priv->rxdescphys,
+		(unsigned int)priv->rxdescmem,
+		(unsigned int)priv->rxdescmem_busaddr);
+
+	dev_dbg(priv->device, "TSE txdma %x, phys %x, size %d, bus %x\n",
+		(unsigned int)priv->tx_dma_desc,
+		(unsigned int)priv->txdescphys,
+		(unsigned int)priv->txdescmem,
+		(unsigned int)priv->txdescmem_busaddr);
+
+	return 0;
+}
+
+void sgdma_uninitialize(struct altera_tse_private *priv)
+{
+	if (priv->rxdescphys)
+		dma_unmap_single(priv->device, priv->rxdescphys,
+				 priv->rxdescmem, DMA_BIDIRECTIONAL);
+
+	if (priv->txdescphys)
+		dma_unmap_single(priv->device, priv->txdescphys,
+				 priv->txdescmem, DMA_BIDIRECTIONAL);
+}
+
+/* This function resets the SGDMA controller and clears the
+ * descriptor memory used for transmits and receives.
+ */
+void sgdma_reset(struct altera_tse_private *priv)
+{
+	u32 *ptxdescripmem =3D (u32 *)priv->tx_dma_desc;
+	u32 txdescriplen   =3D priv->txdescmem;
+	u32 *prxdescripmem =3D (u32 *)priv->rx_dma_desc;
+	u32 rxdescriplen   =3D priv->rxdescmem;
+	struct sgdma_csr *ptxsgdma =3D (struct sgdma_csr *)priv->tx_dma_csr;
+	struct sgdma_csr *prxsgdma =3D (struct sgdma_csr *)priv->rx_dma_csr;
+
+	/* Initialize descriptor memory to 0 */
+	memset(ptxdescripmem, 0, txdescriplen);
+	memset(prxdescripmem, 0, rxdescriplen);
+
+	iowrite32(SGDMA_CTRLREG_RESET, &ptxsgdma->control);
+	iowrite32(0, &ptxsgdma->control);
+
+	iowrite32(SGDMA_CTRLREG_RESET, &prxsgdma->control);
+	iowrite32(0, &prxsgdma->control);
+}
+
+void sgdma_enable_rxirq(struct altera_tse_private *priv)
+{
+	struct sgdma_csr *csr =3D (struct sgdma_csr *)priv->rx_dma_csr;
+	priv->rxctrlreg |=3D SGDMA_CTRLREG_INTEN;
+	tse_set_bit(&csr->control, SGDMA_CTRLREG_INTEN);
+}
+
+void sgdma_enable_txirq(struct altera_tse_private *priv)
+{
+	struct sgdma_csr *csr =3D (struct sgdma_csr *)priv->tx_dma_csr;
+	priv->txctrlreg |=3D SGDMA_CTRLREG_INTEN;
+	tse_set_bit(&csr->control, SGDMA_CTRLREG_INTEN);
+}
+
+/* for SGDMA, RX interrupts remain enabled after enabling */
+void sgdma_disable_rxirq(struct altera_tse_private *priv)
+{
+}
+
+/* for SGDMA, TX interrupts remain enabled after enabling */
+void sgdma_disable_txirq(struct altera_tse_private *priv)
+{
+}
+
+void sgdma_clear_rxirq(struct altera_tse_private *priv)
+{
+	struct sgdma_csr *csr =3D (struct sgdma_csr *)priv->rx_dma_csr;
+	tse_set_bit(&csr->control, SGDMA_CTRLREG_CLRINT);
+}
+
+void sgdma_clear_txirq(struct altera_tse_private *priv)
+{
+	struct sgdma_csr *csr =3D (struct sgdma_csr *)priv->tx_dma_csr;
+	tse_set_bit(&csr->control, SGDMA_CTRLREG_CLRINT);
+}
+
+/* transmits buffer through SGDMA. Returns number of buffers
+ * transmitted, 0 if not possible.
+ *
+ * tx_lock is held by the caller
+ */
+int sgdma_tx_buffer(struct altera_tse_private *priv, struct tse_buffer=
 *buffer)
+{
+	int pktstx =3D 0;
+	struct sgdma_descrip *descbase =3D
+		(struct sgdma_descrip *)priv->tx_dma_desc;
+
+	struct sgdma_descrip *cdesc =3D &descbase[0];
+	struct sgdma_descrip *ndesc =3D &descbase[1];
+
+	/* wait 'til the tx sgdma is ready for the next transmit request */
+	if (sgdma_txbusy(priv))
+		return 0;
+
+	sgdma_descrip(cdesc,			/* current descriptor */
+		      ndesc,			/* next descriptor */
+		      sgdma_txphysaddr(priv, ndesc),
+		      buffer->dma_addr,		/* address of packet to xmit */
+		      0,			/* write addr 0 for tx dma */
+		      buffer->len,		/* length of packet */
+		      SGDMA_CONTROL_EOP,	/* Generate EOP */
+		      0,			/* read fixed */
+		      SGDMA_CONTROL_WR_FIXED);	/* Generate SOP */
+
+	pktstx =3D sgdma_async_write(priv, cdesc);
+
+	/* enqueue the request to the pending transmit queue */
+	queue_tx(priv, buffer);
+
+	return 1;
+}
+
+
+/* tx_lock held to protect access to queued tx list
+ */
+u32 sgdma_tx_completions(struct altera_tse_private *priv)
+{
+	u32 ready =3D 0;
+	struct sgdma_descrip *desc =3D (struct sgdma_descrip *)priv->tx_dma_d=
esc;
+
+	if (!sgdma_txbusy(priv) &&
+	    ((desc->control & SGDMA_CONTROL_HW_OWNED) =3D=3D 0) &&
+	    (dequeue_tx(priv))) {
+		ready =3D 1;
+	}
+
+	return ready;
+}
+
+int sgdma_add_rx_desc(struct altera_tse_private *priv,
+		      struct tse_buffer *rxbuffer)
+{
+	queue_rx(priv, rxbuffer);
+	return sgdma_async_read(priv);
+}
+
+/* status is returned on upper 16 bits,
+ * length is returned in lower 16 bits
+ */
+u32 sgdma_rx_status(struct altera_tse_private *priv)
+{
+	struct sgdma_csr *csr =3D (struct sgdma_csr *)priv->rx_dma_csr;
+	struct sgdma_descrip *base =3D (struct sgdma_descrip *)priv->rx_dma_d=
esc;
+	struct sgdma_descrip *desc =3D NULL;
+	int pktsrx;
+	unsigned int rxstatus =3D 0;
+	unsigned int pktlength =3D 0;
+	unsigned int pktstatus =3D 0;
+	struct tse_buffer *rxbuffer =3D NULL;
+
+	dma_sync_single_for_cpu(priv->device,
+				priv->rxdescphys,
+				priv->rxdescmem,
+				DMA_BIDIRECTIONAL);
+	/* Issue read memory barrier before accessing rx descriptor */
+	rmb();
+	desc =3D &base[0];
+	if ((ioread32(&csr->status) & SGDMA_STSREG_EOP) ||
+	    (desc->status & SGDMA_STATUS_EOP)) {
+
+		pktlength =3D desc->bytes_xferred;
+		pktstatus =3D desc->status & 0x3f;
+		rxstatus =3D pktstatus;
+		rxstatus =3D rxstatus << 16;
+		rxstatus |=3D (pktlength & 0xffff);
+
+		desc->status =3D 0;
+
+		rxbuffer =3D dequeue_rx(priv);
+		if (rxbuffer =3D=3D NULL) {
+			dev_info(priv->device,
+				 "sgdma rx and rx queue empty!\n");
+		}
+		/* kick the rx sgdma after reaping this descriptor */
+		pktsrx =3D sgdma_async_read(priv);
+	}
+
+	return rxstatus;
+}
+
+
+/* Private functions */
+static void sgdma_descrip(struct sgdma_descrip *desc,
+			  struct sgdma_descrip *ndesc,
+			  unsigned int ndesc_phys,
+			  dma_addr_t raddr,
+			  dma_addr_t waddr,
+			  u16 length,
+			  int generate_eop,
+			  int rfixed,
+			  int wfixed)
+{
+	/* Clear the next descriptor as not owned by hardware */
+	u32 ctrl =3D ndesc->control;
+	ctrl &=3D ~SGDMA_CONTROL_HW_OWNED;
+	ndesc->control =3D ctrl;
+
+	ctrl =3D 0;
+	ctrl =3D SGDMA_CONTROL_HW_OWNED;
+	ctrl |=3D generate_eop;
+	ctrl |=3D rfixed;
+	ctrl |=3D wfixed;
+
+	/* Channel is implicitly zero, initialized to 0 by default */
+
+	desc->raddr =3D raddr;
+	desc->waddr =3D waddr;
+	desc->next =3D (unsigned int)ndesc_phys;
+	desc->control =3D ctrl;
+	desc->status =3D 0;
+	desc->rburst =3D 0;
+	desc->wburst =3D 0;
+	desc->bytes =3D length;
+	desc->bytes_xferred =3D 0;
+}
+
+/* If hardware is busy, don't restart async read.
+ * if status register is 0 - meaning initial state, restart async read=
,
+ * probably for the first time when populating a receive buffer.
+ * If read status indicate not busy and a status, restart the async
+ * DMA read.
+ */
+static int sgdma_async_read(struct altera_tse_private *priv)
+{
+	struct sgdma_csr *csr =3D (struct sgdma_csr *)priv->rx_dma_csr;
+	struct sgdma_descrip *descbase =3D
+		(struct sgdma_descrip *)priv->rx_dma_desc;
+
+	struct sgdma_descrip *cdesc =3D &descbase[0];
+	struct sgdma_descrip *ndesc =3D &descbase[1];
+
+	unsigned int sts =3D ioread32(&csr->status);
+	struct tse_buffer *rxbuffer =3D NULL;
+
+	if (!sgdma_rxbusy(priv)) {
+		rxbuffer =3D queue_rx_peekhead(priv);
+		if (rxbuffer =3D=3D NULL)
+			return 0;
+
+		sgdma_descrip(cdesc,		/* current descriptor */
+			      ndesc,		/* next descriptor */
+			      sgdma_rxphysaddr(priv, ndesc),
+			      0,		/* read addr 0 for rx dma */
+			      rxbuffer->dma_addr, /* write addr for rx dma */
+			      0,		/* read 'til EOP */
+			      0,		/* EOP: NA for rx dma */
+			      0,		/* read fixed: NA for rx dma */
+			      0);		/* SOP: NA for rx DMA */
+
+		/* clear control and status */
+		iowrite32(0, &csr->control);
+
+		/* If statuc available, clear those bits */
+		if (sts & 0xf)
+			iowrite32(0xf, &csr->status);
+
+		dma_sync_single_for_device(priv->device,
+					   priv->rxdescphys,
+					   priv->rxdescmem,
+					   DMA_BIDIRECTIONAL);
+
+		/* Ensure all writes to descriptor memory are complete
+		 * before submitting descriptor, and all DMA read/writes
+		 * are consistent with respect to the processor
+		 */
+		mb();
+		iowrite32(sgdma_rxphysaddr(priv, cdesc),
+			  &csr->next_descrip);
+
+		iowrite32((priv->rxctrlreg | SGDMA_CTRLREG_START),
+			  &csr->control);
+
+		return 1;
+	}
+
+	return 0;
+}
+
+static int sgdma_async_write(struct altera_tse_private *priv,
+			      struct sgdma_descrip *desc)
+{
+	struct sgdma_csr *csr =3D (struct sgdma_csr *)priv->tx_dma_csr;
+
+	if (sgdma_txbusy(priv))
+		return 0;
+
+	/* clear control and status */
+	iowrite32(0, &csr->control);
+	iowrite32(0x1f, &csr->status);
+
+	dma_sync_single_for_device(priv->device, priv->txdescphys,
+				   priv->txdescmem, DMA_TO_DEVICE);
+	/* Make sure all writes to descriptor memory are complete
+	 * before submitting descriptor
+	 */
+	wmb();
+	iowrite32(sgdma_txphysaddr(priv, desc), &csr->next_descrip);
+
+	iowrite32((priv->txctrlreg | SGDMA_CTRLREG_START),
+		  &csr->control);
+
+	return 1;
+}
+
+static unsigned int
+sgdma_txphysaddr(struct altera_tse_private *priv,
+		 struct sgdma_descrip *desc)
+{
+	unsigned int paddr =3D priv->txdescmem_busaddr;
+	unsigned int offs =3D (unsigned int)((unsigned int)desc -
+				(unsigned int)priv->tx_dma_desc);
+	paddr =3D paddr + offs;
+	return paddr;
+}
+
+static unsigned int
+sgdma_rxphysaddr(struct altera_tse_private *priv,
+		 struct sgdma_descrip *desc)
+{
+	unsigned int paddr =3D priv->rxdescmem_busaddr;
+	unsigned int offs =3D (unsigned int)((unsigned int)desc -
+				(unsigned int)priv->rx_dma_desc);
+	paddr =3D paddr + offs;
+	return paddr;
+}
+
+/* Function not used, here for debug purposes */
+void
+dumpdesc(struct altera_tse_private *priv,
+	 struct sgdma_descrip *desc, int index)
+{
+	dev_info(priv->device, "desc %x, index %d\n",
+		 (unsigned int)desc, index);
+	dev_info(priv->device, "    raddr  %x\n", desc->raddr);
+	dev_info(priv->device, "    pad1   %x\n", desc->pad1);
+	dev_info(priv->device, "    waddr  %x\n", desc->waddr);
+	dev_info(priv->device, "    pad2   %x\n", desc->pad2);
+	dev_info(priv->device, "    next   %x\n", desc->next);
+	dev_info(priv->device, "    pad3   %x\n", desc->pad3);
+	dev_info(priv->device, "    bytes  %x\n", desc->bytes);
+	dev_info(priv->device, "    rburst %x\n", desc->rburst);
+	dev_info(priv->device, "    wburst %x\n", desc->wburst);
+	dev_info(priv->device, "    xfer   %x\n", desc->bytes_xferred);
+	dev_info(priv->device, "    sts    %x\n", desc->status);
+	dev_info(priv->device, "    ctrl   %x\n", desc->control);
+}
+
+#define list_remove_head(list, entry, type, member)			\
+	do {								\
+		entry =3D NULL;						\
+		if (!list_empty(list)) {				\
+			entry =3D list_entry((list)->next, type, member);	\
+			list_del_init(&entry->member);			\
+		}							\
+	} while (0)
+
+#define list_peek_head(list, entry, type, member)			\
+	do {								\
+		entry =3D NULL;						\
+		if (!list_empty(list)) {				\
+			entry =3D list_entry((list)->next, type, member);	\
+		}							\
+	} while (0)
+
+/* adds a tse_buffer to the tail of a tx buffer list.
+ * assumes the caller is managing and holding a mutual exclusion
+ * primitive to avoid simultaneous pushes/pops to the list.
+ */
+static void
+queue_tx(struct altera_tse_private *priv, struct tse_buffer *buffer)
+{
+	list_add_tail(&buffer->lh, &priv->txlisthd);
+}
+
+
+/* adds a tse_buffer to the tail of a rx buffer list
+ * assumes the caller is managing and holding a mutual exclusion
+ * primitive to avoid simultaneous pushes/pops to the list.
+ */
+static void
+queue_rx(struct altera_tse_private *priv, struct tse_buffer *buffer)
+{
+	list_add_tail(&buffer->lh, &priv->rxlisthd);
+}
+
+/* dequeues a tse_buffer from the transmit buffer list, otherwise
+ * returns NULL if empty.
+ * assumes the caller is managing and holding a mutual exclusion
+ * primitive to avoid simultaneous pushes/pops to the list.
+ */
+static struct tse_buffer *
+dequeue_tx(struct altera_tse_private *priv)
+{
+	struct tse_buffer *buffer =3D NULL;
+	list_remove_head(&priv->txlisthd, buffer, struct tse_buffer, lh);
+	return buffer;
+}
+
+/* dequeues a tse_buffer from the receive buffer list, otherwise
+ * returns NULL if empty
+ * assumes the caller is managing and holding a mutual exclusion
+ * primitive to avoid simultaneous pushes/pops to the list.
+ */
+static struct tse_buffer *
+dequeue_rx(struct altera_tse_private *priv)
+{
+	struct tse_buffer *buffer =3D NULL;
+	list_remove_head(&priv->rxlisthd, buffer, struct tse_buffer, lh);
+	return buffer;
+}
+
+/* dequeues a tse_buffer from the receive buffer list, otherwise
+ * returns NULL if empty
+ * assumes the caller is managing and holding a mutual exclusion
+ * primitive to avoid simultaneous pushes/pops to the list while the
+ * head is being examined.
+ */
+static struct tse_buffer *
+queue_rx_peekhead(struct altera_tse_private *priv)
+{
+	struct tse_buffer *buffer =3D NULL;
+	list_peek_head(&priv->rxlisthd, buffer, struct tse_buffer, lh);
+	return buffer;
+}
+
+/* check and return rx sgdma status without polling
+ */
+static int sgdma_rxbusy(struct altera_tse_private *priv)
+{
+	struct sgdma_csr *csr =3D (struct sgdma_csr *)priv->rx_dma_csr;
+	return ioread32(&csr->status) & SGDMA_STSREG_BUSY;
+}
+
+/* waits for the tx sgdma to finish it's current operation, returns 0
+ * when it transitions to nonbusy, returns 1 if the operation times ou=
t
+ */
+static int sgdma_txbusy(struct altera_tse_private *priv)
+{
+	int delay =3D 0;
+	struct sgdma_csr *csr =3D (struct sgdma_csr *)priv->tx_dma_csr;
+
+	/* if DMA is busy, wait for current transactino to finish */
+	while ((ioread32(&csr->status) & SGDMA_STSREG_BUSY) && (delay++ < 100=
))
+		udelay(1);
+
+	if (ioread32(&csr->status) & SGDMA_STSREG_BUSY) {
+		dev_dbg(priv->device, "timeout waiting for tx dma\n");
+		return 1;
+	}
+	return 0;
+}
diff --git a/drivers/net/ethernet/altera/altera_sgdma.h b/drivers/net/e=
thernet/altera/altera_sgdma.h
new file mode 100644
index 0000000..153a76c
--- /dev/null
+++ b/drivers/net/ethernet/altera/altera_sgdma.h
@@ -0,0 +1,36 @@
+/* Altera TSE SGDMA and MSGDMA Linux driver
+ * Copyright (C) 2014 Altera Corporation. All rights reserved
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITH=
OUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY =
or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public Licen=
se for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License a=
long with
+ * this program.  If not, see <http://www.gnu.org/licenses/>.
+ */
+
+#ifndef __ALTERA_SGDMA_H__
+#define __ALTERA_SGDMA_H__
+
+void sgdma_reset(struct altera_tse_private *);
+void sgdma_enable_txirq(struct altera_tse_private *);
+void sgdma_enable_rxirq(struct altera_tse_private *);
+void sgdma_disable_rxirq(struct altera_tse_private *);
+void sgdma_disable_txirq(struct altera_tse_private *);
+void sgdma_clear_rxirq(struct altera_tse_private *);
+void sgdma_clear_txirq(struct altera_tse_private *);
+int sgdma_tx_buffer(struct altera_tse_private *priv, struct tse_buffer=
 *);
+u32 sgdma_tx_completions(struct altera_tse_private *);
+int sgdma_add_rx_desc(struct altera_tse_private *priv, struct tse_buff=
er *);
+void sgdma_status(struct altera_tse_private *);
+u32 sgdma_rx_status(struct altera_tse_private *);
+int sgdma_initialize(struct altera_tse_private *);
+void sgdma_uninitialize(struct altera_tse_private *);
+
+#endif /*  __ALTERA_SGDMA_H__ */
+
diff --git a/drivers/net/ethernet/altera/altera_sgdmahw.h b/drivers/net=
/ethernet/altera/altera_sgdmahw.h
new file mode 100644
index 0000000..99e3609
--- /dev/null
+++ b/drivers/net/ethernet/altera/altera_sgdmahw.h
@@ -0,0 +1,125 @@
+/* Altera TSE SGDMA and MSGDMA Linux driver
+ * Copyright (C) 2014 Altera Corporation. All rights reserved
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITH=
OUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY =
or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public Licen=
se for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License a=
long with
+ * this program.  If not, see <http://www.gnu.org/licenses/>.
+ */
+
+#ifndef __ALTERA_SGDMAHW_H__
+#define __ALTERA_SGDMAHW_H__
+
+/* SGDMA descriptor structure */
+struct sgdma_descrip {
+	unsigned int	raddr; /* address of data to be read */
+	unsigned int	pad1;
+	unsigned int	waddr;
+	unsigned int    pad2;
+	unsigned int	next;
+	unsigned int	pad3;
+	unsigned short  bytes;
+	unsigned char   rburst;
+	unsigned char	wburst;
+	unsigned short	bytes_xferred;	/* 16 bits, bytes xferred */
+
+	/* bit 0: error
+	 * bit 1: length error
+	 * bit 2: crc error
+	 * bit 3: truncated error
+	 * bit 4: phy error
+	 * bit 5: collision error
+	 * bit 6: reserved
+	 * bit 7: status eop for recv case
+	 */
+	unsigned char	status;
+
+	/* bit 0: eop
+	 * bit 1: read_fixed
+	 * bit 2: write fixed
+	 * bits 3,4,5,6: Channel (always 0)
+	 * bit 7: hardware owned
+	 */
+	unsigned char	control;
+} __packed;
+
+
+#define SGDMA_STATUS_ERR		(1<<0)
+#define SGDMA_STATUS_LENGTH_ERR		(1<<1)
+#define SGDMA_STATUS_CRC_ERR		(1<<2)
+#define SGDMA_STATUS_TRUNC_ERR		(1<<3)
+#define SGDMA_STATUS_PHY_ERR		(1<<4)
+#define SGDMA_STATUS_COLL_ERR		(1<<5)
+#define SGDMA_STATUS_EOP		(1<<7)
+
+#define SGDMA_CONTROL_EOP		(1<<0)
+#define SGDMA_CONTROL_RD_FIXED		(1<<1)
+#define SGDMA_CONTROL_WR_FIXED		(1<<2)
+
+/* Channel is always 0, so just zero initialize it */
+
+#define SGDMA_CONTROL_HW_OWNED		(1<<7)
+
+/* SGDMA register space */
+struct sgdma_csr {
+	/* bit 0: error
+	 * bit 1: eop
+	 * bit 2: descriptor completed
+	 * bit 3: chain completed
+	 * bit 4: busy
+	 * remainder reserved
+	 */
+	u32	status;
+	u32	pad1[3];
+
+	/* bit 0: interrupt on error
+	 * bit 1: interrupt on eop
+	 * bit 2: interrupt after every descriptor
+	 * bit 3: interrupt after last descrip in a chain
+	 * bit 4: global interrupt enable
+	 * bit 5: starts descriptor processing
+	 * bit 6: stop core on dma error
+	 * bit 7: interrupt on max descriptors
+	 * bits 8-15: max descriptors to generate interrupt
+	 * bit 16: Software reset
+	 * bit 17: clears owned by hardware if 0, does not clear otherwise
+	 * bit 18: enables descriptor polling mode
+	 * bit 19-26: clocks before polling again
+	 * bit 27-30: reserved
+	 * bit 31: clear interrupt
+	 */
+	u32	control;
+	u32	pad2[3];
+	u32	next_descrip;
+	u32	pad3[3];
+};
+
+
+#define SGDMA_STSREG_ERR	(1<<0) /* Error */
+#define SGDMA_STSREG_EOP	(1<<1) /* EOP */
+#define SGDMA_STSREG_DESCRIP	(1<<2) /* Descriptor completed */
+#define SGDMA_STSREG_CHAIN	(1<<3) /* Chain completed */
+#define SGDMA_STSREG_BUSY	(1<<4) /* Controller busy */
+
+#define SGDMA_CTRLREG_IOE	(1<<0) /* Interrupt on error */
+#define SGDMA_CTRLREG_IOEOP	(1<<1) /* Interrupt on EOP */
+#define SGDMA_CTRLREG_IDESCRIP	(1<<2) /* Interrupt after every descrip=
tor */
+#define SGDMA_CTRLREG_ILASTD	(1<<3) /* Interrupt after last descriptor=
 */
+#define SGDMA_CTRLREG_INTEN	(1<<4) /* Global Interrupt enable */
+#define SGDMA_CTRLREG_START	(1<<5) /* starts descriptor processing */
+#define SGDMA_CTRLREG_STOPERR	(1<<6) /* stop on dma error */
+#define SGDMA_CTRLREG_INTMAX	(1<<7) /* Interrupt on max descriptors */
+#define SGDMA_CTRLREG_RESET	(1<<16) /* Software reset */
+#define SGDMA_CTRLREG_COBHW	(1<<17) /* Clears owned by hardware */
+#define SGDMA_CTRLREG_POLL	(1<<18) /* enables descriptor polling mode =
*/
+#define SGDMA_CTRLREG_CLRINT	(1<<31) /* Clears interrupt */
+
+#endif /* __ALTERA_SGDMAHW_H__ */
+
diff --git a/drivers/net/ethernet/altera/altera_tse.c b/drivers/net/eth=
ernet/altera/altera_tse.c
new file mode 100644
index 0000000..0db5651
--- /dev/null
+++ b/drivers/net/ethernet/altera/altera_tse.c
@@ -0,0 +1,1578 @@
+/* Altera Triple-Speed Ethernet MAC driver
+ * Copyright (C) 2014 Altera Corporation. All rights reserved
+ *
+ * Contributors:
+ *   Dalon Westergreen
+ *   Thomas Chou
+ *   Ian Abbott
+ *   Yuriy Kozlov
+ *   Tobias Klauser
+ *   Andriy Smolskyy
+ *   Roman Bulgakov
+ *   Dmytro Mytarchuk
+ *
+ * Original driver contributed by SLS.
+ * Major updates contributed by GlobalLogic
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITH=
OUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY =
or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public Licen=
se for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License a=
long with
+ * this program.  If not, see <http://www.gnu.org/licenses/>.
+ */
+
+#include <asm/cacheflush.h>
+#include <linux/atomic.h>
+#include <linux/delay.h>
+#include <linux/etherdevice.h>
+#include <linux/if_vlan.h>
+#include <linux/init.h>
+#include <linux/interrupt.h>
+#include <linux/io.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/netdevice.h>
+#include <linux/of_device.h>
+#include <linux/of_mdio.h>
+#include <linux/of_platform.h>
+#include <linux/phy.h>
+#include <linux/platform_device.h>
+#include <linux/skbuff.h>
+
+#include "altera_utils.h"
+#include "altera_tse.h"
+#include "altera_sgdma.h"
+#include "altera_msgdma.h"
+
+static atomic_t instance_count =3D ATOMIC_INIT(~0);
+/* Module parameters */
+static int debug =3D -1;
+module_param(debug, int, S_IRUGO | S_IWUSR);
+MODULE_PARM_DESC(debug, "Message Level (-1: default, 0: no output, 16:=
 all)");
+
+static const u32 default_msg_level =3D (NETIF_MSG_DRV | NETIF_MSG_PROB=
E |
+					NETIF_MSG_LINK | NETIF_MSG_IFUP |
+					NETIF_MSG_IFDOWN);
+
+#define RX_DESCRIPTORS 64
+static int dma_rx_num =3D RX_DESCRIPTORS;
+module_param(dma_rx_num, int, S_IRUGO | S_IWUSR);
+MODULE_PARM_DESC(dma_rx_num, "Number of descriptors in the RX list");
+
+#define TX_DESCRIPTORS 64
+static int dma_tx_num =3D TX_DESCRIPTORS;
+module_param(dma_tx_num, int, S_IRUGO | S_IWUSR);
+MODULE_PARM_DESC(dma_tx_num, "Number of descriptors in the TX list");
+
+
+#define POLL_PHY (-1)
+
+/* Make sure DMA buffer size is larger than the max frame size
+ * plus some alignment offset and a VLAN header. If the max frame size=
 is
+ * 1518, a VLAN header would be additional 4 bytes and additional
+ * headroom for alignment is 2 bytes, 2048 is just fine.
+ */
+#define ALTERA_RXDMABUFFER_SIZE	2048
+
+/* Allow network stack to resume queueing packets after we've
+ * finished transmitting at least 1/4 of the packets in the queue.
+ */
+#define TSE_TX_THRESH(x)	(x->tx_ring_size / 4)
+
+static inline u32 tse_tx_avail(struct altera_tse_private *priv)
+{
+	return priv->tx_cons + priv->tx_ring_size - priv->tx_prod - 1;
+}
+
+/* MDIO specific functions
+ */
+static int altera_tse_mdio_read(struct mii_bus *bus, int mii_id, int r=
egnum)
+{
+	struct altera_tse_mac *mac =3D (struct altera_tse_mac *)bus->priv;
+	unsigned int *mdio_regs =3D (unsigned int *)&mac->mdio_phy0;
+	u32 data;
+
+	/* set MDIO address */
+	iowrite32((mii_id & 0x1f), &mac->mdio_phy0_addr);
+
+	/* get the data */
+	data =3D ioread32(&mdio_regs[regnum]) & 0xffff;
+	return data;
+}
+
+static int altera_tse_mdio_write(struct mii_bus *bus, int mii_id, int =
regnum,
+				 u16 value)
+{
+	struct altera_tse_mac *mac =3D (struct altera_tse_mac *)bus->priv;
+	unsigned int *mdio_regs =3D (unsigned int *)&mac->mdio_phy0;
+
+	/* set MDIO address */
+	iowrite32((mii_id & 0x1f), &mac->mdio_phy0_addr);
+
+	/* write the data */
+	iowrite32((u32) value, &mdio_regs[regnum]);
+	return 0;
+}
+
+static int altera_tse_mdio_create(struct net_device *dev, unsigned int=
 id)
+{
+	struct altera_tse_private *priv =3D netdev_priv(dev);
+	int ret;
+	int i;
+	struct device_node *mdio_node;
+	struct mii_bus *mdio;
+
+	mdio_node =3D of_find_compatible_node(priv->device->of_node, NULL,
+		"altr,tse-mdio");
+
+	if (mdio_node) {
+		dev_warn(priv->device, "FOUND MDIO subnode\n");
+	} else {
+		dev_warn(priv->device, "NO MDIO subnode\n");
+		return 0;
+	}
+
+	mdio =3D mdiobus_alloc();
+	if (mdio =3D=3D NULL) {
+		dev_err(priv->device, "Error allocating MDIO bus\n");
+		return -ENOMEM;
+	}
+
+	mdio->name =3D ALTERA_TSE_RESOURCE_NAME;
+	mdio->read =3D &altera_tse_mdio_read;
+	mdio->write =3D &altera_tse_mdio_write;
+	snprintf(mdio->id, MII_BUS_ID_SIZE, "%s-%u", mdio->name, id);
+
+	mdio->irq =3D kcalloc(PHY_MAX_ADDR, sizeof(int), GFP_KERNEL);
+	if (mdio->irq =3D=3D NULL) {
+		dev_err(priv->device, "%s: Cannot allocate memory\n", __func__);
+		ret =3D -ENOMEM;
+		goto out_free_mdio;
+	}
+	for (i =3D 0; i < PHY_MAX_ADDR; i++)
+		mdio->irq[i] =3D PHY_POLL;
+
+	mdio->priv =3D (void *)priv->mac_dev;
+	mdio->parent =3D priv->device;
+
+	ret =3D of_mdiobus_register(mdio, mdio_node);
+	if (ret !=3D 0) {
+		dev_err(priv->device, "Cannot register MDIO bus %s\n",
+			mdio->id);
+		goto out_free_mdio_irq;
+	}
+
+	if (netif_msg_drv(priv))
+		dev_info(priv->device, "MDIO bus %s: created\n", mdio->id);
+
+	priv->mdio =3D mdio;
+	return 0;
+out_free_mdio_irq:
+	kfree(mdio->irq);
+out_free_mdio:
+	mdiobus_free(mdio);
+	mdio =3D NULL;
+	return ret;
+}
+
+static void altera_tse_mdio_destroy(struct net_device *dev)
+{
+	struct altera_tse_private *priv =3D netdev_priv(dev);
+
+	if (priv->mdio =3D=3D NULL)
+		return;
+
+	if (netif_msg_drv(priv))
+		dev_info(priv->device, "MDIO bus %s: removed\n",
+			 priv->mdio->id);
+
+	mdiobus_unregister(priv->mdio);
+	kfree(priv->mdio->irq);
+	mdiobus_free(priv->mdio);
+	priv->mdio =3D NULL;
+}
+
+static int tse_init_rx_buffer(struct altera_tse_private *priv,
+			      struct tse_buffer *rxbuffer, int len)
+{
+	rxbuffer->skb =3D netdev_alloc_skb_ip_align(priv->dev, len);
+	if (!rxbuffer->skb) {
+		dev_err(priv->device, "%s: Rx init fails; skb is NULL\n",
+			__func__);
+		return -ENOMEM;
+	}
+
+	rxbuffer->dma_addr =3D dma_map_single(priv->device, rxbuffer->skb->da=
ta,
+						len,
+						DMA_FROM_DEVICE);
+
+	if (dma_mapping_error(priv->device, rxbuffer->dma_addr)) {
+		dev_err(priv->device, "%s: DMA mapping error\n", __func__);
+		dev_kfree_skb_any(rxbuffer->skb);
+		return -EINVAL;
+	}
+	rxbuffer->len =3D len;
+	return 0;
+}
+
+static void tse_free_rx_buffer(struct altera_tse_private *priv,
+			       struct tse_buffer *rxbuffer)
+{
+	struct sk_buff *skb =3D rxbuffer->skb;
+	dma_addr_t dma_addr =3D rxbuffer->dma_addr;
+
+	if (skb !=3D NULL) {
+		if (dma_addr)
+			dma_unmap_single(priv->device, dma_addr,
+					 rxbuffer->len,
+					 DMA_FROM_DEVICE);
+		dev_kfree_skb_any(skb);
+		rxbuffer->skb =3D NULL;
+		rxbuffer->dma_addr =3D 0;
+	}
+}
+
+/* Unmap and free Tx buffer resources
+ */
+static void tse_free_tx_buffer(struct altera_tse_private *priv,
+			       struct tse_buffer *buffer)
+{
+	if (buffer->dma_addr) {
+		if (buffer->mapped_as_page)
+			dma_unmap_page(priv->device, buffer->dma_addr,
+				       buffer->len, DMA_TO_DEVICE);
+		else
+			dma_unmap_single(priv->device, buffer->dma_addr,
+					 buffer->len, DMA_TO_DEVICE);
+		buffer->dma_addr =3D 0;
+	}
+	if (buffer->skb) {
+		dev_kfree_skb_any(buffer->skb);
+		buffer->skb =3D NULL;
+	}
+}
+
+static int alloc_init_skbufs(struct altera_tse_private *priv)
+{
+	unsigned int rx_descs =3D priv->rx_ring_size;
+	unsigned int tx_descs =3D priv->tx_ring_size;
+	int ret =3D -ENOMEM;
+	int i;
+
+	/* Create Rx ring buffer */
+	priv->rx_ring =3D kcalloc(rx_descs, sizeof(struct tse_buffer),
+				GFP_KERNEL);
+	if (!priv->rx_ring)
+		goto err_rx_ring;
+
+	/* Create Tx ring buffer */
+	priv->tx_ring =3D kcalloc(tx_descs, sizeof(struct tse_buffer),
+				GFP_KERNEL);
+	if (!priv->tx_ring)
+		goto err_tx_ring;
+
+	priv->tx_cons =3D 0;
+	priv->tx_prod =3D 0;
+
+	/* Init Rx ring */
+	for (i =3D 0; i < rx_descs; i++) {
+		ret =3D tse_init_rx_buffer(priv, &priv->rx_ring[i],
+					 priv->rx_dma_buf_sz);
+		if (ret)
+			goto err_init_rx_buffers;
+	}
+
+	priv->rx_cons =3D 0;
+	priv->rx_prod =3D 0;
+
+	return 0;
+err_init_rx_buffers:
+	while (--i >=3D 0)
+		tse_free_rx_buffer(priv, &priv->rx_ring[i]);
+	kfree(priv->tx_ring);
+err_tx_ring:
+	kfree(priv->rx_ring);
+err_rx_ring:
+	return ret;
+}
+
+static void free_skbufs(struct net_device *dev)
+{
+	struct altera_tse_private *priv =3D netdev_priv(dev);
+	unsigned int rx_descs =3D priv->rx_ring_size;
+	unsigned int tx_descs =3D priv->tx_ring_size;
+	int i;
+
+	/* Release the DMA TX/RX socket buffers */
+	for (i =3D 0; i < rx_descs; i++)
+		tse_free_rx_buffer(priv, &priv->rx_ring[i]);
+	for (i =3D 0; i < tx_descs; i++)
+		tse_free_tx_buffer(priv, &priv->tx_ring[i]);
+
+
+	kfree(priv->tx_ring);
+}
+
+/* Reallocate the skb for the reception process
+ */
+static inline void tse_rx_refill(struct altera_tse_private *priv)
+{
+	unsigned int rxsize =3D priv->rx_ring_size;
+	unsigned int entry;
+	int ret;
+
+	for (; priv->rx_cons - priv->rx_prod > 0;
+			priv->rx_prod++) {
+		entry =3D priv->rx_prod % rxsize;
+		if (likely(priv->rx_ring[entry].skb =3D=3D NULL)) {
+			ret =3D tse_init_rx_buffer(priv, &priv->rx_ring[entry],
+				priv->rx_dma_buf_sz);
+			if (unlikely(ret !=3D 0)) {
+				dev_err(priv->device,
+					"%s: Cannot allocate skb\n", __func__);
+				break;
+			}
+			priv->add_rx_desc(priv, &priv->rx_ring[entry]);
+			if (netif_msg_rx_status(priv))
+				dev_dbg(priv->device, "\trefill entry #%d\n",
+					entry);
+		}
+	}
+}
+
+/* Pull out the VLAN tag and fix up the packet
+ */
+static inline void tse_rx_vlan(struct net_device *dev, struct sk_buff =
*skb)
+{
+	struct ethhdr *eth_hdr;
+	u16 vid;
+	if ((dev->features & NETIF_F_HW_VLAN_CTAG_RX) &&
+	    !__vlan_get_tag(skb, &vid)) {
+		eth_hdr =3D (struct ethhdr *)skb->data;
+		memmove(skb->data + VLAN_HLEN, eth_hdr, ETH_ALEN * 2);
+		skb_pull(skb, VLAN_HLEN);
+		__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), vid);
+	}
+}
+
+/* Receive a packet: retrieve and pass over to upper levels
+ */
+static int tse_rx(struct altera_tse_private *priv, int limit)
+{
+	unsigned int count =3D 0;
+	unsigned int next_entry;
+	struct sk_buff *skb;
+	unsigned int entry =3D priv->rx_cons % priv->rx_ring_size;
+	u32 rxstatus;
+	u16 pktlength;
+	u16 pktstatus;
+
+	while ((rxstatus =3D priv->get_rx_status(priv)) !=3D 0) {
+		pktstatus =3D rxstatus >> 16;
+		pktlength =3D rxstatus & 0xffff;
+
+		if ((pktstatus & 0xFF) || (pktlength =3D=3D 0))
+			netdev_err(priv->dev,
+				   "RCV pktstatus %08X pktlength %08X\n",
+				   pktstatus, pktlength);
+
+		count++;
+		next_entry =3D (++priv->rx_cons) % priv->rx_ring_size;
+
+		skb =3D priv->rx_ring[entry].skb;
+		if (unlikely(!skb)) {
+			dev_err(priv->device,
+				"%s: Inconsistent Rx descriptor chain\n",
+				__func__);
+			priv->dev->stats.rx_dropped++;
+			break;
+		}
+		priv->rx_ring[entry].skb =3D NULL;
+
+		skb_put(skb, pktlength);
+
+		/* make cache consistent with receive packet buffer */
+		dma_sync_single_for_cpu(priv->device,
+					priv->rx_ring[entry].dma_addr,
+					priv->rx_ring[entry].len,
+					DMA_FROM_DEVICE);
+
+		dma_unmap_single(priv->device, priv->rx_ring[entry].dma_addr,
+				 priv->rx_ring[entry].len, DMA_FROM_DEVICE);
+
+		/* make sure all pending memory updates are complete */
+		rmb();
+
+		if (netif_msg_pktdata(priv)) {
+			dev_info(priv->device, "frame received %d bytes\n",
+				 pktlength);
+			print_hex_dump(KERN_ERR, "data: ", DUMP_PREFIX_OFFSET,
+				       16, 1, skb->data, pktlength, true);
+		}
+
+		tse_rx_vlan(priv->dev, skb);
+
+		skb->protocol =3D eth_type_trans(skb, priv->dev);
+		skb_checksum_none_assert(skb);
+
+		napi_gro_receive(&priv->napi, skb);
+
+		priv->dev->stats.rx_packets++;
+		priv->dev->stats.rx_bytes +=3D pktlength;
+
+		entry =3D next_entry;
+	}
+
+	tse_rx_refill(priv);
+	return count;
+}
+
+/* Reclaim resources after transmission completes
+ */
+static int tse_tx_complete(struct altera_tse_private *priv)
+{
+	unsigned int txsize =3D priv->tx_ring_size;
+	u32 ready;
+	unsigned int entry;
+	struct tse_buffer *tx_buff;
+	int txcomplete =3D 0;
+
+	spin_lock(&priv->tx_lock);
+
+	ready =3D priv->tx_completions(priv);
+
+	/* Free sent buffers */
+	while (ready && (priv->tx_cons !=3D priv->tx_prod)) {
+		entry =3D priv->tx_cons % txsize;
+		tx_buff =3D &priv->tx_ring[entry];
+
+		if (netif_msg_tx_done(priv))
+			dev_dbg(priv->device, "%s: curr %d, dirty %d\n",
+				__func__, priv->tx_prod, priv->tx_cons);
+
+		if (likely(tx_buff->skb))
+			priv->dev->stats.tx_packets++;
+
+		tse_free_tx_buffer(priv, tx_buff);
+		priv->tx_cons++;
+
+		txcomplete++;
+		ready--;
+	}
+
+	if (unlikely(netif_queue_stopped(priv->dev) &&
+		     tse_tx_avail(priv) > TSE_TX_THRESH(priv))) {
+		netif_tx_lock(priv->dev);
+		if (netif_queue_stopped(priv->dev) &&
+		    tse_tx_avail(priv) > TSE_TX_THRESH(priv)) {
+			if (netif_msg_tx_done(priv))
+				dev_dbg(priv->device, "%s: restart transmit\n",
+					__func__);
+			netif_wake_queue(priv->dev);
+		}
+		netif_tx_unlock(priv->dev);
+	}
+
+	spin_unlock(&priv->tx_lock);
+	return txcomplete;
+}
+
+/* NAPI polling function
+ */
+static int tse_poll(struct napi_struct *napi, int budget)
+{
+	struct altera_tse_private *priv =3D
+			container_of(napi, struct altera_tse_private, napi);
+	int rxcomplete =3D 0;
+	int txcomplete =3D 0;
+	unsigned long int flags;
+
+	txcomplete =3D tse_tx_complete(priv);
+
+	rxcomplete =3D tse_rx(priv, budget);
+
+	if (txcomplete+rxcomplete !=3D budget) {
+		napi_gro_flush(napi, false);
+		__napi_complete(napi);
+
+		dev_dbg(priv->device,
+			"NAPI Complete, did %d packets with budget %d\n",
+			txcomplete+rxcomplete, budget);
+	}
+	spin_lock_irqsave(&priv->rxdma_irq_lock, flags);
+	priv->enable_rxirq(priv);
+	priv->enable_txirq(priv);
+	spin_unlock_irqrestore(&priv->rxdma_irq_lock, flags);
+	return rxcomplete + txcomplete;
+}
+
+/* DMA TX & RX FIFO interrupt routing
+ */
+static irqreturn_t altera_isr(int irq, void *dev_id)
+{
+	struct net_device *dev =3D dev_id;
+	struct altera_tse_private *priv;
+	unsigned long int flags;
+
+
+	if (unlikely(!dev)) {
+		pr_err("%s: invalid dev pointer\n", __func__);
+		return IRQ_NONE;
+	}
+	priv =3D netdev_priv(dev);
+
+	/* turn off desc irqs and enable napi rx */
+	spin_lock_irqsave(&priv->rxdma_irq_lock, flags);
+
+	if (likely(napi_schedule_prep(&priv->napi))) {
+		priv->disable_rxirq(priv);
+		priv->disable_txirq(priv);
+		__napi_schedule(&priv->napi);
+	}
+
+	/* reset IRQs */
+	priv->clear_rxirq(priv);
+	priv->clear_txirq(priv);
+
+	spin_unlock_irqrestore(&priv->rxdma_irq_lock, flags);
+
+	return IRQ_HANDLED;
+}
+
+/* Transmit a packet (called by the kernel). Dispatches
+ * either the SGDMA method for transmitting or the
+ * MSGDMA method, assumes no scatter/gather support,
+ * implying an assumption that there's only one
+ * physically contiguous fragment starting at
+ * skb->data, for length of skb_headlen(skb).
+ */
+static int tse_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct altera_tse_private *priv =3D netdev_priv(dev);
+	unsigned int txsize =3D priv->tx_ring_size;
+	unsigned int entry;
+	struct tse_buffer *buffer =3D NULL;
+	int nfrags =3D skb_shinfo(skb)->nr_frags;
+	unsigned int nopaged_len =3D skb_headlen(skb);
+	enum netdev_tx ret =3D NETDEV_TX_OK;
+	dma_addr_t dma_addr;
+	int txcomplete =3D 0;
+
+	spin_lock_bh(&priv->tx_lock);
+
+	if (unlikely(nfrags)) {
+		dev_err(priv->device,
+			"%s: nfrags must be 0, SG not supported\n", __func__);
+		ret =3D NETDEV_TX_BUSY;
+		goto out;
+	}
+
+	if (unlikely(tse_tx_avail(priv) < nfrags + 1)) {
+		if (!netif_queue_stopped(dev)) {
+			netif_stop_queue(dev);
+			/* This is a hard error, log it. */
+			dev_err(priv->device,
+				"%s: Tx list full when queue awake\n",
+				__func__);
+		}
+		ret =3D NETDEV_TX_BUSY;
+		goto out;
+	}
+
+	/* Map the first skb fragment */
+	entry =3D priv->tx_prod % txsize;
+	buffer =3D &priv->tx_ring[entry];
+
+	dma_addr =3D dma_map_single(priv->device, skb->data, nopaged_len,
+				  DMA_TO_DEVICE);
+	if (dma_mapping_error(priv->device, dma_addr)) {
+		dev_err(priv->device, "%s: DMA mapping error\n", __func__);
+		ret =3D NETDEV_TX_BUSY;
+		goto out;
+	}
+
+	buffer->skb =3D skb;
+	buffer->dma_addr =3D dma_addr;
+	buffer->len =3D nopaged_len;
+
+	/* Push data out of the cache hierarchy into main memory */
+	dma_sync_single_for_device(priv->device, buffer->dma_addr,
+				   buffer->len, DMA_TO_DEVICE);
+
+	/* Make sure the write buffers are bled ahead of initiated the I/O */
+	wmb();
+
+	txcomplete =3D priv->tx_buffer(priv, buffer);
+
+	priv->tx_prod++;
+	dev->stats.tx_bytes +=3D skb->len;
+
+	if (unlikely(tse_tx_avail(priv) <=3D 2)) {
+		if (netif_msg_hw(priv))
+			dev_dbg(priv->device, "%s: stop transmitted packets\n",
+				__func__);
+		netif_stop_queue(dev);
+	}
+
+out:
+	spin_unlock_bh(&priv->tx_lock);
+
+	return ret;
+}
+
+/* Called every time the controller might need to be made
+ * aware of new link state.  The PHY code conveys this
+ * information through variables in the phydev structure, and this
+ * function converts those variables into the appropriate
+ * register values, and can bring down the device if needed.
+ */
+static void altera_tse_adjust_link(struct net_device *dev)
+{
+	struct altera_tse_private *priv =3D netdev_priv(dev);
+	struct phy_device *phydev =3D priv->phydev;
+	int new_state =3D 0;
+
+	/* only change config if there is a link */
+	spin_lock(&priv->mac_cfg_lock);
+	if (phydev->link) {
+		/* Read old config */
+		u32 cfg_reg =3D ioread32(&priv->mac_dev->command_config);
+
+		/* Check duplex */
+		if (phydev->duplex !=3D priv->oldduplex) {
+			new_state =3D 1;
+			if (!(phydev->duplex))
+				cfg_reg |=3D MAC_CMDCFG_HD_ENA;
+			else
+				cfg_reg &=3D ~MAC_CMDCFG_HD_ENA;
+
+			dev_dbg(priv->device, "%s: Link duplex =3D 0x%x\n",
+				dev->name, phydev->duplex);
+
+			priv->oldduplex =3D phydev->duplex;
+		}
+
+		/* Check speed */
+		if (phydev->speed !=3D priv->oldspeed) {
+			new_state =3D 1;
+			switch (phydev->speed) {
+			case 1000:
+				cfg_reg |=3D MAC_CMDCFG_ETH_SPEED;
+				cfg_reg &=3D ~MAC_CMDCFG_ENA_10;
+				break;
+			case 100:
+				cfg_reg &=3D ~MAC_CMDCFG_ETH_SPEED;
+				cfg_reg &=3D ~MAC_CMDCFG_ENA_10;
+				break;
+			case 10:
+				cfg_reg &=3D ~MAC_CMDCFG_ETH_SPEED;
+				cfg_reg |=3D MAC_CMDCFG_ENA_10;
+				break;
+			default:
+				if (netif_msg_link(priv))
+					netdev_warn(dev, "Speed (%d) is not 10/100/1000!\n",
+						    phydev->speed);
+				break;
+			}
+			priv->oldspeed =3D phydev->speed;
+		}
+		iowrite32(cfg_reg, &priv->mac_dev->command_config);
+
+		if (!priv->oldlink) {
+			new_state =3D 1;
+			priv->oldlink =3D 1;
+		}
+	} else if (priv->oldlink) {
+		new_state =3D 1;
+		priv->oldlink =3D 0;
+		priv->oldspeed =3D 0;
+		priv->oldduplex =3D -1;
+	}
+
+	if (new_state && netif_msg_link(priv))
+		phy_print_status(phydev);
+
+	spin_unlock(&priv->mac_cfg_lock);
+}
+static struct phy_device *connect_local_phy(struct net_device *dev)
+{
+	struct altera_tse_private *priv =3D netdev_priv(dev);
+	struct phy_device *phydev =3D NULL;
+	char phy_id_fmt[MII_BUS_ID_SIZE + 3];
+	int ret;
+
+	if (priv->phy_addr !=3D POLL_PHY) {
+		snprintf(phy_id_fmt, MII_BUS_ID_SIZE + 3, PHY_ID_FMT,
+			 priv->mdio->id, priv->phy_addr);
+
+		dev_dbg(priv->device, "trying to attach to %s\n", phy_id_fmt);
+
+		phydev =3D phy_connect(dev, phy_id_fmt, &altera_tse_adjust_link,
+				     priv->phy_iface);
+		if (IS_ERR(phydev))
+			netdev_err(dev, "Could not attach to PHY\n");
+
+	} else {
+		phydev =3D phy_find_first(priv->mdio);
+		if (phydev =3D=3D NULL) {
+			netdev_err(dev, "No PHY found\n");
+			return phydev;
+		}
+
+		ret =3D phy_connect_direct(dev, phydev, &altera_tse_adjust_link,
+				priv->phy_iface);
+		if (ret !=3D 0) {
+			netdev_err(dev, "Could not attach to PHY\n");
+			phydev =3D NULL;
+		}
+	}
+	return phydev;
+}
+
+/* Initialize driver's PHY state, and attach to the PHY
+ */
+static int init_phy(struct net_device *dev)
+{
+	struct altera_tse_private *priv =3D netdev_priv(dev);
+	struct phy_device *phydev;
+	struct device_node *phynode;
+
+	priv->oldlink =3D 0;
+	priv->oldspeed =3D 0;
+	priv->oldduplex =3D -1;
+
+	phynode =3D of_parse_phandle(priv->device->of_node, "phy-handle", 0);
+
+	if (!phynode) {
+		netdev_warn(dev, "no phy-handle found\n");
+		if (!priv->mdio) {
+			netdev_err(dev,
+				   "No phy-handle nor local mdio specified\n");
+			return -ENODEV;
+		}
+		phydev =3D connect_local_phy(dev);
+	} else {
+		netdev_warn(dev, "phy-handle found\n");
+		phydev =3D of_phy_connect(dev, phynode,
+			&altera_tse_adjust_link, 0, priv->phy_iface);
+	}
+
+	/* Stop Advertising 1000BASE Capability if interface is not GMII
+	 * Note: Checkpatch throws CHECKs for the camel case defines below,
+	 * it's ok to ignore.
+	 */
+	if ((priv->phy_iface =3D=3D PHY_INTERFACE_MODE_MII) ||
+	    (priv->phy_iface =3D=3D PHY_INTERFACE_MODE_RMII))
+		phydev->advertising &=3D ~(SUPPORTED_1000baseT_Half |
+					 SUPPORTED_1000baseT_Full);
+
+	/* Broken HW is sometimes missing the pull-up resistor on the
+	 * MDIO line, which results in reads to non-existent devices returnin=
g
+	 * 0 rather than 0xffff. Catch this here and treat 0 as a non-existen=
t
+	 * device as well.
+	 * Note: phydev->phy_id is the result of reading the UID PHY register=
s.
+	 */
+	if (phydev->phy_id =3D=3D 0) {
+		netdev_err(dev, "Bad PHY UID 0x%08x\n", phydev->phy_id);
+		phy_disconnect(phydev);
+		return -ENODEV;
+	}
+
+	dev_dbg(priv->device, "attached to PHY %d UID 0x%08x Link =3D %d\n",
+		phydev->addr, phydev->phy_id, phydev->link);
+
+	priv->phydev =3D phydev;
+	return 0;
+}
+
+static void tse_update_mac_addr(struct altera_tse_private *priv, u8 *a=
ddr)
+{
+	struct altera_tse_mac *mac =3D priv->mac_dev;
+	u32 msb;
+	u32 lsb;
+
+	msb =3D (addr[3] << 24) | (addr[2] << 16) | (addr[1] << 8) | addr[0];
+	lsb =3D ((addr[5] << 8) | addr[4]) & 0xffff;
+
+	/* Set primary MAC address */
+	iowrite32(msb, &mac->mac_addr_0);
+	iowrite32(lsb, &mac->mac_addr_1);
+}
+
+/* MAC software reset.
+ * When reset is triggered, the MAC function completes the current
+ * transmission or reception, and subsequently disables the transmit a=
nd
+ * receive logic, flushes the receive FIFO buffer, and resets the stat=
istics
+ * counters.
+ */
+static int reset_mac(struct altera_tse_private *priv)
+{
+	void __iomem *cmd_cfg_reg =3D &priv->mac_dev->command_config;
+	int counter;
+	u32 dat;
+
+	dat =3D ioread32(cmd_cfg_reg);
+	dat &=3D ~(MAC_CMDCFG_TX_ENA | MAC_CMDCFG_RX_ENA);
+	dat |=3D MAC_CMDCFG_SW_RESET | MAC_CMDCFG_CNT_RESET;
+	iowrite32(dat, cmd_cfg_reg);
+
+	counter =3D 0;
+	while (counter++ < ALTERA_TSE_SW_RESET_WATCHDOG_CNTR) {
+		if (tse_bit_is_clear(cmd_cfg_reg, MAC_CMDCFG_SW_RESET))
+			break;
+		udelay(1);
+	}
+
+	if (counter >=3D ALTERA_TSE_SW_RESET_WATCHDOG_CNTR) {
+		if (netif_msg_drv(priv))
+			dev_warn(priv->device,
+				 "TSE MAC resetting bit never cleared!\n");
+		dat =3D ioread32(cmd_cfg_reg);
+		dat &=3D ~MAC_CMDCFG_SW_RESET;
+		iowrite32(dat, cmd_cfg_reg);
+		return -1;
+	}
+	return 0;
+}
+
+/* Initialize MAC core registers
+*/
+static int init_mac(struct altera_tse_private *priv)
+{
+	struct altera_tse_mac *mac =3D priv->mac_dev;
+	unsigned int cmd =3D 0;
+	u32 frm_length;
+
+	/* Setup Rx FIFO */
+	iowrite32(priv->rx_fifo_depth - ALTERA_TSE_RX_SECTION_EMPTY,
+		  &mac->rx_section_empty);
+	iowrite32(ALTERA_TSE_RX_SECTION_FULL, &mac->rx_section_full);
+	iowrite32(ALTERA_TSE_RX_ALMOST_EMPTY, &mac->rx_almost_empty);
+	iowrite32(ALTERA_TSE_RX_ALMOST_FULL, &mac->rx_almost_full);
+
+	/* Setup Tx FIFO */
+	iowrite32(priv->tx_fifo_depth - ALTERA_TSE_TX_SECTION_EMPTY,
+		  &mac->tx_section_empty);
+	iowrite32(ALTERA_TSE_TX_SECTION_FULL, &mac->tx_section_full);
+	iowrite32(ALTERA_TSE_TX_ALMOST_EMPTY, &mac->tx_almost_empty);
+	iowrite32(ALTERA_TSE_TX_ALMOST_FULL, &mac->tx_almost_full);
+
+	/* MAC Address Configuration */
+	tse_update_mac_addr(priv, priv->dev->dev_addr);
+
+	/* MAC Function Configuration */
+	frm_length =3D ETH_HLEN + priv->dev->mtu + ETH_FCS_LEN;
+	iowrite32(frm_length, &mac->frm_length);
+	iowrite32(ALTERA_TSE_TX_IPG_LENGTH, &mac->tx_ipg_length);
+
+	/* Disable RX/TX shift 16 for alignment of all received frames on 16-=
bit
+	 * start address
+	 */
+	tse_clear_bit(&mac->rx_cmd_stat, ALTERA_TSE_RX_CMD_STAT_RX_SHIFT16);
+	tse_clear_bit(&mac->tx_cmd_stat, ALTERA_TSE_TX_CMD_STAT_TX_SHIFT16 |
+					 ALTERA_TSE_TX_CMD_STAT_OMIT_CRC);
+
+	/* Set the MAC options */
+	cmd =3D ioread32(&mac->command_config);
+	cmd |=3D MAC_CMDCFG_PAD_EN;	/* Padding Removal on Receive */
+	cmd &=3D ~MAC_CMDCFG_CRC_FWD;	/* CRC Removal */
+	cmd |=3D MAC_CMDCFG_RX_ERR_DISC;	/* Automatically discard frames
+					 * with CRC errors
+					 */
+	cmd |=3D MAC_CMDCFG_CNTL_FRM_ENA;
+	cmd &=3D ~MAC_CMDCFG_TX_ENA;
+	cmd &=3D ~MAC_CMDCFG_RX_ENA;
+	iowrite32(cmd, &mac->command_config);
+
+	if (netif_msg_hw(priv))
+		dev_dbg(priv->device,
+			"MAC post-initialization: CMD_CONFIG =3D 0x%08x\n", cmd);
+
+	return 0;
+}
+
+/* Start/stop MAC transmission logic
+ */
+static void tse_set_mac(struct altera_tse_private *priv, bool enable)
+{
+	struct altera_tse_mac *mac =3D priv->mac_dev;
+	u32 value =3D ioread32(&mac->command_config);
+
+	if (enable)
+		value |=3D MAC_CMDCFG_TX_ENA | MAC_CMDCFG_RX_ENA;
+	else
+		value &=3D ~(MAC_CMDCFG_TX_ENA | MAC_CMDCFG_RX_ENA);
+
+	iowrite32(value, &mac->command_config);
+}
+
+/* Change the MTU
+ */
+static int tse_change_mtu(struct net_device *dev, int new_mtu)
+{
+	struct altera_tse_private *priv =3D netdev_priv(dev);
+	unsigned int max_mtu =3D priv->max_mtu;
+	unsigned int min_mtu =3D ETH_ZLEN + ETH_FCS_LEN;
+
+	if (netif_running(dev)) {
+		dev_err(priv->device, "must be stopped to change its MTU\n");
+		return -EBUSY;
+	}
+
+	if ((new_mtu < min_mtu) || (new_mtu > max_mtu)) {
+		netdev_err(dev, "invalid MTU, max MTU is: %u\n", max_mtu);
+		return -EINVAL;
+	}
+
+	dev->mtu =3D new_mtu;
+	netdev_update_features(dev);
+
+	return 0;
+}
+
+static void altera_tse_set_mcfilter(struct net_device *dev)
+{
+	struct altera_tse_private *priv =3D netdev_priv(dev);
+	struct altera_tse_mac *mac =3D (struct altera_tse_mac *)priv->mac_dev=
;
+	int i;
+	struct netdev_hw_addr *ha;
+
+	/* clear the hash filter */
+	for (i =3D 0; i < 64; i++)
+		iowrite32(0, &(mac->hash_table[i]));
+
+	netdev_for_each_mc_addr(ha, dev) {
+		unsigned int hash =3D 0;
+		int mac_octet;
+
+		for (mac_octet =3D 5; mac_octet >=3D 0; mac_octet--) {
+			unsigned char xor_bit =3D 0;
+			unsigned char octet =3D ha->addr[mac_octet];
+			unsigned int bitshift;
+
+			for (bitshift =3D 0; bitshift < 8; bitshift++)
+				xor_bit ^=3D ((octet >> bitshift) & 0x01);
+
+			hash =3D (hash << 1) | xor_bit;
+		}
+		iowrite32(1, &(mac->hash_table[hash]));
+	}
+}
+
+
+static void altera_tse_set_mcfilterall(struct net_device *dev)
+{
+	struct altera_tse_private *priv =3D netdev_priv(dev);
+	struct altera_tse_mac *mac =3D (struct altera_tse_mac *)priv->mac_dev=
;
+	int i;
+
+	/* set the hash filter */
+	for (i =3D 0; i < 64; i++)
+		iowrite32(1, &(mac->hash_table[i]));
+}
+
+/* Set or clear the multicast filter for this adaptor
+ */
+static void tse_set_rx_mode_hashfilter(struct net_device *dev)
+{
+	struct altera_tse_private *priv =3D netdev_priv(dev);
+	struct altera_tse_mac *mac =3D priv->mac_dev;
+
+	spin_lock(&priv->mac_cfg_lock);
+
+	if (dev->flags & IFF_PROMISC)
+		tse_set_bit(&mac->command_config, MAC_CMDCFG_PROMIS_EN);
+
+	if (dev->flags & IFF_ALLMULTI)
+		altera_tse_set_mcfilterall(dev);
+	else
+		altera_tse_set_mcfilter(dev);
+
+	spin_unlock(&priv->mac_cfg_lock);
+}
+
+/* Set or clear the multicast filter for this adaptor
+ */
+static void tse_set_rx_mode(struct net_device *dev)
+{
+	struct altera_tse_private *priv =3D netdev_priv(dev);
+	struct altera_tse_mac *mac =3D priv->mac_dev;
+
+	spin_lock(&priv->mac_cfg_lock);
+
+	if ((dev->flags & IFF_PROMISC) || (dev->flags & IFF_ALLMULTI) ||
+	    !netdev_mc_empty(dev) || !netdev_uc_empty(dev))
+		tse_set_bit(&mac->command_config, MAC_CMDCFG_PROMIS_EN);
+	else
+		tse_clear_bit(&mac->command_config, MAC_CMDCFG_PROMIS_EN);
+
+	spin_unlock(&priv->mac_cfg_lock);
+}
+
+/* Open and initialize the interface
+ */
+static int tse_open(struct net_device *dev)
+{
+	struct altera_tse_private *priv =3D netdev_priv(dev);
+	int ret =3D 0;
+	int i;
+	unsigned long int flags;
+
+	/* Reset and configure TSE MAC and probe associated PHY */
+	ret =3D priv->init_dma(priv);
+	if (ret !=3D 0) {
+		netdev_err(dev, "Cannot initialize DMA\n");
+		goto phy_error;
+	}
+
+	ret =3D init_phy(dev);
+	if (ret !=3D 0) {
+		netdev_err(dev, "Cannot attach to PHY (error: %d)\n", ret);
+		goto phy_error;
+	}
+
+	if (netif_msg_ifup(priv))
+		dev_warn(priv->device, "device MAC address %pM\n",
+			 dev->dev_addr);
+
+	if ((priv->revision < 0xd00) || (priv->revision > 0xe00))
+		dev_warn(priv->device, "TSE revision %x\n", priv->revision);
+
+	spin_lock(&priv->mac_cfg_lock);
+	ret =3D reset_mac(priv);
+	if (ret)
+		netdev_err(dev, "Cannot reset MAC core (error: %d)\n", ret);
+
+	ret =3D init_mac(priv);
+	spin_unlock(&priv->mac_cfg_lock);
+	if (ret) {
+		netdev_err(dev, "Cannot init MAC core (error: %d)\n", ret);
+		goto alloc_skbuf_error;
+	}
+
+	priv->reset_dma(priv);
+
+	/* Create and initialize the TX/RX descriptors chains. */
+	priv->rx_ring_size =3D dma_rx_num;
+	priv->tx_ring_size =3D dma_tx_num;
+	ret =3D alloc_init_skbufs(priv);
+	if (ret) {
+		netdev_err(dev, "DMA descriptors initialization failed\n");
+		goto alloc_skbuf_error;
+	}
+
+
+	/* Register RX interrupt */
+	ret =3D request_irq(priv->rx_irq, altera_isr, IRQF_SHARED,
+			  dev->name, dev);
+	if (ret) {
+		netdev_err(dev, "Unable to register RX interrupt %d\n",
+			   priv->rx_irq);
+		goto init_error;
+	}
+
+	/* Register TX interrupt */
+	ret =3D request_irq(priv->tx_irq, altera_isr, IRQF_SHARED,
+			  dev->name, dev);
+	if (ret) {
+		netdev_err(dev, "Unable to register TX interrupt %d\n",
+			   priv->tx_irq);
+		goto tx_request_irq_error;
+	}
+
+	/* Enable DMA interrupts */
+	spin_lock_irqsave(&priv->rxdma_irq_lock, flags);
+	priv->enable_rxirq(priv);
+	priv->enable_txirq(priv);
+
+	/* Setup RX descriptor chain */
+	for (i =3D 0; i < priv->rx_ring_size; i++)
+		priv->add_rx_desc(priv, &priv->rx_ring[i]);
+
+	spin_unlock_irqrestore(&priv->rxdma_irq_lock, flags);
+
+	/* Start MAC Rx/Tx */
+	spin_lock(&priv->mac_cfg_lock);
+	tse_set_mac(priv, true);
+	spin_unlock(&priv->mac_cfg_lock);
+
+	if (priv->phydev)
+		phy_start(priv->phydev);
+
+	napi_enable(&priv->napi);
+	netif_start_queue(dev);
+
+	return 0;
+
+tx_request_irq_error:
+	free_irq(priv->rx_irq, dev);
+init_error:
+	free_skbufs(dev);
+alloc_skbuf_error:
+	if (priv->phydev) {
+		phy_disconnect(priv->phydev);
+		priv->phydev =3D NULL;
+	}
+phy_error:
+	return ret;
+}
+
+/* Stop TSE MAC interface and put the device in an inactive state
+ */
+static int tse_shutdown(struct net_device *dev)
+{
+	struct altera_tse_private *priv =3D netdev_priv(dev);
+	int ret;
+	unsigned long int flags;
+
+	/* Stop and disconnect the PHY */
+	if (priv->phydev) {
+		phy_stop(priv->phydev);
+		phy_disconnect(priv->phydev);
+		priv->phydev =3D NULL;
+	}
+
+	netif_stop_queue(dev);
+	napi_disable(&priv->napi);
+
+	/* Disable DMA interrupts */
+	spin_lock_irqsave(&priv->rxdma_irq_lock, flags);
+	priv->disable_rxirq(priv);
+	priv->disable_txirq(priv);
+	spin_unlock_irqrestore(&priv->rxdma_irq_lock, flags);
+
+	/* Free the IRQ lines */
+	free_irq(priv->rx_irq, dev);
+	free_irq(priv->tx_irq, dev);
+
+	/* disable and reset the MAC, empties fifo */
+	spin_lock(&priv->mac_cfg_lock);
+	spin_lock(&priv->tx_lock);
+
+	ret =3D reset_mac(priv);
+	if (ret)
+		netdev_err(dev, "Cannot reset MAC core (error: %d)\n", ret);
+	priv->reset_dma(priv);
+	free_skbufs(dev);
+
+	spin_unlock(&priv->tx_lock);
+	spin_unlock(&priv->mac_cfg_lock);
+
+	priv->uninit_dma(priv);
+
+	netif_carrier_off(dev);
+
+	return 0;
+}
+
+static struct net_device_ops altera_tse_netdev_ops =3D {
+	.ndo_open		=3D tse_open,
+	.ndo_stop		=3D tse_shutdown,
+	.ndo_start_xmit		=3D tse_start_xmit,
+	.ndo_set_mac_address	=3D eth_mac_addr,
+	.ndo_set_rx_mode	=3D tse_set_rx_mode,
+	.ndo_change_mtu		=3D tse_change_mtu,
+	.ndo_validate_addr	=3D eth_validate_addr,
+};
+
+static int altera_tse_get_of_prop(struct platform_device *pdev,
+				  const char *name, unsigned int *val)
+{
+	const __be32 *tmp;
+	int len;
+	char buf[strlen(name)+1];
+
+	tmp =3D of_get_property(pdev->dev.of_node, name, &len);
+	if (!tmp && !strncmp(name, "altr,", 5)) {
+		strcpy(buf, name);
+		strncpy(buf, "ALTR,", 5);
+		tmp =3D of_get_property(pdev->dev.of_node, buf, &len);
+	}
+	if (!tmp || (len < sizeof(__be32)))
+		return -ENODEV;
+
+	*val =3D be32_to_cpup(tmp);
+	return 0;
+}
+
+static int altera_tse_get_phy_iface_prop(struct platform_device *pdev,
+					 phy_interface_t *iface)
+{
+	const void *prop;
+	int len;
+
+	prop =3D of_get_property(pdev->dev.of_node, "phy-mode", &len);
+	if (!prop)
+		return -ENOENT;
+	if (len < 4)
+		return -EINVAL;
+
+	if (!strncmp((char *)prop, "mii", 3)) {
+		*iface =3D PHY_INTERFACE_MODE_MII;
+		return 0;
+	} else if (!strncmp((char *)prop, "gmii", 4)) {
+		*iface =3D PHY_INTERFACE_MODE_GMII;
+		return 0;
+	} else if (!strncmp((char *)prop, "rgmii-id", 8)) {
+		*iface =3D PHY_INTERFACE_MODE_RGMII_ID;
+		return 0;
+	} else if (!strncmp((char *)prop, "rgmii", 5)) {
+		*iface =3D PHY_INTERFACE_MODE_RGMII;
+		return 0;
+	} else if (!strncmp((char *)prop, "sgmii", 5)) {
+		*iface =3D PHY_INTERFACE_MODE_SGMII;
+		return 0;
+	}
+
+	return -EINVAL;
+}
+
+static int request_and_map(struct platform_device *pdev, const char *n=
ame,
+			   struct resource **res, void __iomem **ptr)
+{
+	struct resource *region;
+	struct device *device =3D &pdev->dev;
+
+	*res =3D platform_get_resource_byname(pdev, IORESOURCE_MEM, name);
+	if (*res =3D=3D NULL) {
+		dev_err(device, "resource %s not defined\n", name);
+		return -ENODEV;
+	}
+
+	region =3D devm_request_mem_region(device, (*res)->start,
+					 resource_size(*res), dev_name(device));
+	if (region =3D=3D NULL) {
+		dev_err(device, "unable to request %s\n", name);
+		return -EBUSY;
+	}
+
+	*ptr =3D devm_ioremap_nocache(device, region->start,
+				    resource_size(region));
+	if (*ptr =3D=3D NULL) {
+		dev_err(device, "ioremap_nocache of %s failed!", name);
+		return -ENOMEM;
+	}
+
+	return 0;
+}
+
+/* Probe Altera TSE MAC device
+ */
+static int altera_tse_probe(struct platform_device *pdev)
+{
+	struct net_device *ndev;
+	int ret =3D -ENODEV;
+	struct resource *control_port;
+	struct resource *dma_res;
+	struct altera_tse_private *priv;
+	int len;
+	const unsigned char *macaddr;
+	struct device_node *np =3D pdev->dev.of_node;
+	unsigned int descmap;
+
+	ndev =3D alloc_etherdev(sizeof(struct altera_tse_private));
+	if (!ndev) {
+		dev_err(&pdev->dev, "Could not allocate network device\n");
+		return -ENODEV;
+	}
+
+	SET_NETDEV_DEV(ndev, &pdev->dev);
+
+	priv =3D netdev_priv(ndev);
+	priv->device =3D &pdev->dev;
+	priv->dev =3D ndev;
+	priv->msg_enable =3D netif_msg_init(debug, default_msg_level);
+
+	if (of_device_is_compatible(np, "altr,tse-1.0") ||
+	    of_device_is_compatible(np, "ALTR,tse-1.0")) {
+		priv->reset_dma =3D sgdma_reset;
+		priv->enable_rxirq =3D sgdma_enable_rxirq;
+		priv->enable_txirq =3D sgdma_enable_txirq;
+		priv->disable_rxirq =3D sgdma_disable_rxirq;
+		priv->disable_txirq =3D sgdma_disable_txirq;
+		priv->clear_rxirq =3D sgdma_clear_rxirq;
+		priv->clear_txirq =3D sgdma_clear_txirq;
+		priv->tx_buffer =3D sgdma_tx_buffer;
+		priv->tx_completions =3D sgdma_tx_completions;
+		priv->add_rx_desc =3D sgdma_add_rx_desc;
+		priv->get_rx_status =3D sgdma_rx_status;
+		priv->init_dma =3D sgdma_initialize;
+		priv->uninit_dma =3D sgdma_uninitialize;
+
+		ret =3D request_and_map(pdev, "s1", &dma_res,
+			      (void *)&descmap);
+		if (ret)
+			goto out_free;
+
+		priv->tx_dma_desc =3D (void *)descmap;
+		priv->txdescmem =3D resource_size(dma_res)/2;
+		priv->txdescmem_busaddr =3D dma_res->start;
+
+		priv->rx_dma_desc =3D (void *)(descmap+priv->txdescmem);
+		priv->rxdescmem =3D resource_size(dma_res)/2;
+		priv->rxdescmem_busaddr =3D dma_res->start + priv->txdescmem;
+	}
+
+	if (of_device_is_compatible(np, "altr,tse-msgdma-1.0")) {
+		priv->reset_dma =3D msgdma_reset;
+		priv->enable_rxirq =3D msgdma_enable_rxirq;
+		priv->enable_txirq =3D msgdma_enable_txirq;
+		priv->disable_rxirq =3D msgdma_disable_rxirq;
+		priv->disable_txirq =3D msgdma_disable_txirq;
+		priv->clear_rxirq =3D msgdma_clear_rxirq;
+		priv->clear_txirq =3D msgdma_clear_txirq;
+		priv->tx_buffer =3D msgdma_tx_buffer;
+		priv->tx_completions =3D msgdma_tx_completions;
+		priv->add_rx_desc =3D msgdma_add_rx_desc;
+		priv->get_rx_status =3D msgdma_rx_status;
+		priv->init_dma =3D msgdma_initialize;
+		priv->uninit_dma =3D msgdma_uninitialize;
+
+		ret =3D request_and_map(pdev, "rx_resp", &dma_res,
+				      (void *)&priv->rx_dma_resp);
+		if (ret)
+			goto out_free;
+
+		ret =3D request_and_map(pdev, "tx_desc", &dma_res,
+			      (void *)&priv->tx_dma_desc);
+		if (ret)
+			goto out_free;
+
+		priv->txdescmem =3D resource_size(dma_res);
+		priv->txdescmem_busaddr =3D dma_res->start;
+
+		dev_dbg(priv->device, "TSE tx_desc phys %x, map %x\n",
+			(unsigned int)dma_res->start,
+			(unsigned int)priv->tx_dma_desc);
+
+		ret =3D request_and_map(pdev, "rx_desc", &dma_res,
+			      (void *)&priv->rx_dma_desc);
+		if (ret)
+			goto out_free;
+
+		priv->rxdescmem =3D resource_size(dma_res);
+		priv->rxdescmem_busaddr =3D dma_res->start;
+
+		dev_dbg(priv->device, "TSE rx_desc phys %x, map %x\n",
+			(unsigned int)dma_res->start,
+			(unsigned int)priv->rx_dma_desc);
+	}
+
+	/* MAC address space */
+	ret =3D request_and_map(pdev, "control_port", &control_port,
+			      (void *)&priv->mac_dev);
+	if (ret)
+		goto out_free;
+
+	/* xSGDMA Rx Dispatcher address space */
+	ret =3D request_and_map(pdev, "rx_csr", &dma_res,
+			      (void *)&priv->rx_dma_csr);
+	if (ret)
+		goto out_free;
+
+
+	/* xSGDMA Tx Dispatcher address space */
+	ret =3D request_and_map(pdev, "tx_csr", &dma_res,
+			      (void *)&priv->tx_dma_csr);
+	if (ret)
+		goto out_free;
+
+
+	/* Rx IRQ */
+	priv->rx_irq =3D platform_get_irq_byname(pdev, "rx_irq");
+	if (priv->rx_irq =3D=3D -ENXIO) {
+		dev_err(&pdev->dev, "cannot obtain Rx IRQ\n");
+		ret =3D -ENXIO;
+		goto out_free;
+	}
+
+	/* Tx IRQ */
+	priv->tx_irq =3D platform_get_irq_byname(pdev, "tx_irq");
+	if (priv->tx_irq =3D=3D -ENXIO) {
+		dev_err(&pdev->dev, "cannot obtain Tx IRQ\n");
+		ret =3D -ENXIO;
+		goto out_free;
+	}
+
+	/* get Rx FIFO depth from device tree (assuming FIFO width =3D 4) */
+	ret =3D altera_tse_get_of_prop(pdev, "altr,rx-fifo-depth",
+				     &priv->rx_fifo_depth);
+	if (ret) {
+		dev_err(&pdev->dev, "cannot obtain altr,rx-fifo-depth\n");
+		goto out_free;
+	}
+
+	/* get Tx FIFO depth from device tree (assuming FIFO width =3D 4) */
+	ret =3D altera_tse_get_of_prop(pdev, "altr,tx-fifo-depth",
+				     &priv->tx_fifo_depth);
+	if (ret) {
+		dev_err(&pdev->dev, "cannot obtain altr,tx-fifo-depth\n");
+		goto out_free;
+	}
+
+	/* get hash filter settings for this instance */
+	ret =3D altera_tse_get_of_prop(pdev, "altr,enable-hash",
+				     &priv->hash_filter);
+	if (ret)
+		priv->hash_filter =3D 0;
+
+	/* get supplemental address settings for this instance */
+	ret =3D altera_tse_get_of_prop(pdev, "altr,enable-sup-addr",
+				     &priv->added_unicast);
+	if (ret)
+		priv->added_unicast =3D 0;
+
+	/* Max MTU is 1500, ETH_DATA_LEN */
+	priv->max_mtu =3D ETH_DATA_LEN;
+
+	/* The DMA buffer size already accounts for an alignment bias
+	 * to avoid unaligned access exceptions for the NIOS processor,
+	 */
+	priv->rx_dma_buf_sz =3D ALTERA_RXDMABUFFER_SIZE;
+
+	/* get default MAC address from device tree */
+	macaddr =3D of_get_property(pdev->dev.of_node, "local-mac-address", &=
len);
+	if (macaddr && len =3D=3D ETH_ALEN)
+		memcpy(ndev->dev_addr, macaddr, ETH_ALEN);
+
+	/* If we didn't get a valid address, generate a random one */
+	if (!is_valid_ether_addr(ndev->dev_addr))
+		eth_hw_addr_random(ndev);
+
+	ret =3D altera_tse_get_phy_iface_prop(pdev, &priv->phy_iface);
+	if (ret =3D=3D -ENOENT) {
+		/* backward compatability, assume RGMII */
+		dev_warn(&pdev->dev,
+			 "cannot obtain PHY interface mode, assuming RGMII\n");
+		priv->phy_iface =3D PHY_INTERFACE_MODE_RGMII;
+	} else if (ret) {
+		dev_err(&pdev->dev, "unknown PHY interface mode\n");
+		goto out_free;
+	}
+
+	/* try to get PHY address from device tree, use PHY autodetection if
+	 * no valid address is given
+	 */
+	ret =3D altera_tse_get_of_prop(pdev, "altr,phy-addr", &priv->phy_addr=
);
+	if (ret)
+		priv->phy_addr =3D POLL_PHY;
+
+	if (!((priv->phy_addr =3D=3D POLL_PHY) ||
+	      ((priv->phy_addr >=3D 0) && (priv->phy_addr < PHY_MAX_ADDR)))) =
{
+		dev_err(&pdev->dev, "invalid altr,phy-addr specified %d\n",
+			priv->phy_addr);
+		goto out_free;
+	}
+
+	/* Create/attach to MDIO bus */
+	ret =3D altera_tse_mdio_create(ndev,
+				     atomic_add_return(1, &instance_count));
+
+	if (ret)
+		goto out_free;
+
+	/* initialize netdev */
+	ether_setup(ndev);
+	ndev->mem_start =3D control_port->start;
+	ndev->mem_end =3D control_port->end;
+	ndev->netdev_ops =3D &altera_tse_netdev_ops;
+	altera_tse_set_ethtool_ops(ndev);
+
+	altera_tse_netdev_ops.ndo_set_rx_mode =3D tse_set_rx_mode;
+
+	if (priv->hash_filter)
+		altera_tse_netdev_ops.ndo_set_rx_mode =3D
+			tse_set_rx_mode_hashfilter;
+
+	/* Scatter/gather IO is not supported,
+	 * so it is turned off
+	 */
+	ndev->hw_features &=3D ~NETIF_F_SG;
+	ndev->features |=3D ndev->hw_features | NETIF_F_HIGHDMA;
+
+	/* VLAN offloading of tagging, stripping and filtering is not
+	 * supported by hardware, but driver will accommodate the
+	 * extra 4-byte VLAN tag for processing by upper layers
+	 */
+	ndev->features |=3D NETIF_F_HW_VLAN_CTAG_RX;
+
+	/* setup NAPI interface */
+	netif_napi_add(ndev, &priv->napi, tse_poll, NAPI_POLL_WEIGHT);
+
+	spin_lock_init(&priv->mac_cfg_lock);
+	spin_lock_init(&priv->tx_lock);
+	spin_lock_init(&priv->rxdma_irq_lock);
+
+	ret =3D register_netdev(ndev);
+	if (ret) {
+		dev_err(&pdev->dev, "failed to register TSE net device\n");
+		goto out_free_mdio;
+	}
+
+	platform_set_drvdata(pdev, ndev);
+
+	priv->revision =3D ioread32(&priv->mac_dev->megacore_revision);
+
+	if (netif_msg_probe(priv))
+		dev_info(&pdev->dev, "Altera TSE MAC version %d.%d at 0x%08lx irq %d=
/%d\n",
+			 (priv->revision >> 8) & 0xff,
+			 priv->revision & 0xff,
+			 (unsigned long) control_port->start, priv->rx_irq,
+			 priv->tx_irq);
+	return 0;
+
+out_free_mdio:
+	altera_tse_mdio_destroy(ndev);
+out_free:
+	free_netdev(ndev);
+	return ret;
+}
+
+/* Remove Altera TSE MAC device
+ */
+static int altera_tse_remove(struct platform_device *pdev)
+{
+	struct net_device *ndev =3D platform_get_drvdata(pdev);
+
+	platform_set_drvdata(pdev, NULL);
+	if (ndev) {
+		altera_tse_mdio_destroy(ndev);
+		netif_carrier_off(ndev);
+		unregister_netdev(ndev);
+		free_netdev(ndev);
+	}
+
+	return 0;
+}
+
+static struct of_device_id altera_tse_of_match[] =3D {
+	{ .compatible =3D "altr,tse-1.0", },
+	{ .compatible =3D "ALTR,tse-1.0", },
+	{ .compatible =3D "altr,tse-msgdma-1.0", },
+	{},
+};
+MODULE_DEVICE_TABLE(of, altera_tse_of_match);
+
+static struct platform_driver altera_tse_driver =3D {
+	.probe		=3D altera_tse_probe,
+	.remove		=3D altera_tse_remove,
+	.suspend	=3D NULL,
+	.resume		=3D NULL,
+	.driver		=3D {
+		.name	=3D ALTERA_TSE_RESOURCE_NAME,
+		.owner	=3D THIS_MODULE,
+		.of_match_table =3D altera_tse_of_match,
+	},
+};
+
+module_platform_driver(altera_tse_driver);
+
+MODULE_AUTHOR("Altera Corporation");
+MODULE_DESCRIPTION("Altera Triple Speed Ethernet MAC driver");
+MODULE_LICENSE("GPL v2");
diff --git a/drivers/net/ethernet/altera/altera_tse.h b/drivers/net/eth=
ernet/altera/altera_tse.h
new file mode 100644
index 0000000..c273c43
--- /dev/null
+++ b/drivers/net/ethernet/altera/altera_tse.h
@@ -0,0 +1,477 @@
+/* Altera Triple-Speed Ethernet MAC driver
+ * Copyright (C) 2014 Altera Corporation. All rights reserved
+ *
+ * Contributors:
+ *   Dalon Westergreen
+ *   Thomas Chou
+ *   Ian Abbott
+ *   Yuriy Kozlov
+ *   Tobias Klauser
+ *   Andriy Smolskyy
+ *   Roman Bulgakov
+ *   Dmytro Mytarchuk
+ *
+ * Original driver contributed by SLS.
+ * Major updates contributed by GlobalLogic
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITH=
OUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY =
or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public Licen=
se for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License a=
long with
+ * this program.  If not, see <http://www.gnu.org/licenses/>.
+ */
+
+#ifndef __ALTERA_TSE_H__
+#define __ALTERA_TSE_H__
+
+#define ALTERA_TSE_RESOURCE_NAME	"altera_tse"
+
+#include <linux/bitops.h>
+#include <linux/if_vlan.h>
+#include <linux/list.h>
+#include <linux/netdevice.h>
+#include <linux/phy.h>
+
+#define ALTERA_TSE_SW_RESET_WATCHDOG_CNTR	10000
+#define ALTERA_TSE_MAC_FIFO_WIDTH		4	/* TX/RX FIFO width in
+							 * bytes
+							 */
+/* Rx FIFO default settings */
+#define ALTERA_TSE_RX_SECTION_EMPTY	16
+#define ALTERA_TSE_RX_SECTION_FULL	0
+#define ALTERA_TSE_RX_ALMOST_EMPTY	8
+#define ALTERA_TSE_RX_ALMOST_FULL	8
+
+/* Tx FIFO default settings */
+#define ALTERA_TSE_TX_SECTION_EMPTY	16
+#define ALTERA_TSE_TX_SECTION_FULL	0
+#define ALTERA_TSE_TX_ALMOST_EMPTY	8
+#define ALTERA_TSE_TX_ALMOST_FULL	3
+
+/* MAC function configuration default settings */
+#define ALTERA_TSE_TX_IPG_LENGTH	12
+
+#define GET_BIT_VALUE(v, bit)		(((v) >> (bit)) & 0x1)
+
+/* MAC Command_Config Register Bit Definitions
+ */
+#define MAC_CMDCFG_TX_ENA			BIT(0)
+#define MAC_CMDCFG_RX_ENA			BIT(1)
+#define MAC_CMDCFG_XON_GEN			BIT(2)
+#define MAC_CMDCFG_ETH_SPEED			BIT(3)
+#define MAC_CMDCFG_PROMIS_EN			BIT(4)
+#define MAC_CMDCFG_PAD_EN			BIT(5)
+#define MAC_CMDCFG_CRC_FWD			BIT(6)
+#define MAC_CMDCFG_PAUSE_FWD			BIT(7)
+#define MAC_CMDCFG_PAUSE_IGNORE			BIT(8)
+#define MAC_CMDCFG_TX_ADDR_INS			BIT(9)
+#define MAC_CMDCFG_HD_ENA			BIT(10)
+#define MAC_CMDCFG_EXCESS_COL			BIT(11)
+#define MAC_CMDCFG_LATE_COL			BIT(12)
+#define MAC_CMDCFG_SW_RESET			BIT(13)
+#define MAC_CMDCFG_MHASH_SEL			BIT(14)
+#define MAC_CMDCFG_LOOP_ENA			BIT(15)
+#define MAC_CMDCFG_TX_ADDR_SEL(v)		(((v) & 0x7) << 16)
+#define MAC_CMDCFG_MAGIC_ENA			BIT(19)
+#define MAC_CMDCFG_SLEEP			BIT(20)
+#define MAC_CMDCFG_WAKEUP			BIT(21)
+#define MAC_CMDCFG_XOFF_GEN			BIT(22)
+#define MAC_CMDCFG_CNTL_FRM_ENA			BIT(23)
+#define MAC_CMDCFG_NO_LGTH_CHECK		BIT(24)
+#define MAC_CMDCFG_ENA_10			BIT(25)
+#define MAC_CMDCFG_RX_ERR_DISC			BIT(26)
+#define MAC_CMDCFG_DISABLE_READ_TIMEOUT		BIT(27)
+#define MAC_CMDCFG_CNT_RESET			BIT(31)
+
+#define MAC_CMDCFG_TX_ENA_GET(v)		GET_BIT_VALUE(v, 0)
+#define MAC_CMDCFG_RX_ENA_GET(v)		GET_BIT_VALUE(v, 1)
+#define MAC_CMDCFG_XON_GEN_GET(v)		GET_BIT_VALUE(v, 2)
+#define MAC_CMDCFG_ETH_SPEED_GET(v)		GET_BIT_VALUE(v, 3)
+#define MAC_CMDCFG_PROMIS_EN_GET(v)		GET_BIT_VALUE(v, 4)
+#define MAC_CMDCFG_PAD_EN_GET(v)		GET_BIT_VALUE(v, 5)
+#define MAC_CMDCFG_CRC_FWD_GET(v)		GET_BIT_VALUE(v, 6)
+#define MAC_CMDCFG_PAUSE_FWD_GET(v)		GET_BIT_VALUE(v, 7)
+#define MAC_CMDCFG_PAUSE_IGNORE_GET(v)		GET_BIT_VALUE(v, 8)
+#define MAC_CMDCFG_TX_ADDR_INS_GET(v)		GET_BIT_VALUE(v, 9)
+#define MAC_CMDCFG_HD_ENA_GET(v)		GET_BIT_VALUE(v, 10)
+#define MAC_CMDCFG_EXCESS_COL_GET(v)		GET_BIT_VALUE(v, 11)
+#define MAC_CMDCFG_LATE_COL_GET(v)		GET_BIT_VALUE(v, 12)
+#define MAC_CMDCFG_SW_RESET_GET(v)		GET_BIT_VALUE(v, 13)
+#define MAC_CMDCFG_MHASH_SEL_GET(v)		GET_BIT_VALUE(v, 14)
+#define MAC_CMDCFG_LOOP_ENA_GET(v)		GET_BIT_VALUE(v, 15)
+#define MAC_CMDCFG_TX_ADDR_SEL_GET(v)		(((v) >> 16) & 0x7)
+#define MAC_CMDCFG_MAGIC_ENA_GET(v)		GET_BIT_VALUE(v, 19)
+#define MAC_CMDCFG_SLEEP_GET(v)			GET_BIT_VALUE(v, 20)
+#define MAC_CMDCFG_WAKEUP_GET(v)		GET_BIT_VALUE(v, 21)
+#define MAC_CMDCFG_XOFF_GEN_GET(v)		GET_BIT_VALUE(v, 22)
+#define MAC_CMDCFG_CNTL_FRM_ENA_GET(v)		GET_BIT_VALUE(v, 23)
+#define MAC_CMDCFG_NO_LGTH_CHECK_GET(v)		GET_BIT_VALUE(v, 24)
+#define MAC_CMDCFG_ENA_10_GET(v)		GET_BIT_VALUE(v, 25)
+#define MAC_CMDCFG_RX_ERR_DISC_GET(v)		GET_BIT_VALUE(v, 26)
+#define MAC_CMDCFG_DISABLE_READ_TIMEOUT_GET(v)	GET_BIT_VALUE(v, 27)
+#define MAC_CMDCFG_CNT_RESET_GET(v)		GET_BIT_VALUE(v, 31)
+
+/* MDIO registers within MAC register Space
+ */
+struct altera_tse_mdio {
+	unsigned int control;	/* PHY device operation control register */
+	unsigned int status;	/* PHY device operation status register */
+	unsigned int phy_id1;	/* Bits 31:16 of PHY identifier */
+	unsigned int phy_id2;	/* Bits 15:0 of PHY identifier */
+	unsigned int auto_negotiation_advertisement;	/* Auto-negotiation
+							 * advertisement
+							 * register
+							 */
+	unsigned int remote_partner_base_page_ability;
+
+	unsigned int reg6;
+	unsigned int reg7;
+	unsigned int reg8;
+	unsigned int reg9;
+	unsigned int rega;
+	unsigned int regb;
+	unsigned int regc;
+	unsigned int regd;
+	unsigned int rege;
+	unsigned int regf;
+	unsigned int reg10;
+	unsigned int reg11;
+	unsigned int reg12;
+	unsigned int reg13;
+	unsigned int reg14;
+	unsigned int reg15;
+	unsigned int reg16;
+	unsigned int reg17;
+	unsigned int reg18;
+	unsigned int reg19;
+	unsigned int reg1a;
+	unsigned int reg1b;
+	unsigned int reg1c;
+	unsigned int reg1d;
+	unsigned int reg1e;
+	unsigned int reg1f;
+};
+
+/* MAC register Space. Note that some of these registers may or may no=
t be
+ * present depending upon options chosen by the user when the core was
+ * configured and built. Please consult the Altera Triple Speed Ethern=
et User
+ * Guide for details.
+ */
+struct altera_tse_mac {
+	/* Bits 15:0: MegaCore function revision (0x0800). Bit 31:16: Custome=
r
+	 * specific revision
+	 */
+	unsigned int megacore_revision;
+	/* Provides a memory location for user applications to test the devic=
e
+	 * memory operation.
+	 */
+	unsigned int scratch_pad;
+	/* The host processor uses this register to control and configure the
+	 * MAC block
+	 */
+	unsigned int command_config;
+	/* 32-bit primary MAC address word 0 bits 0 to 31 of the primary
+	 * MAC address
+	 */
+	unsigned int mac_addr_0;
+	/* 32-bit primary MAC address word 1 bits 32 to 47 of the primary
+	 * MAC address
+	 */
+	unsigned int mac_addr_1;
+	/* 14-bit maximum frame length. The MAC receive logic */
+	unsigned int frm_length;
+	/* The pause quanta is used in each pause frame sent to a remote
+	 * Ethernet device, in increments of 512 Ethernet bit times
+	 */
+	unsigned int pause_quanta;
+	/* 12-bit receive FIFO section-empty threshold */
+	unsigned int rx_section_empty;
+	/* 12-bit receive FIFO section-full threshold */
+	unsigned int rx_section_full;
+	/* 12-bit transmit FIFO section-empty threshold */
+	unsigned int tx_section_empty;
+	/* 12-bit transmit FIFO section-full threshold */
+	unsigned int tx_section_full;
+	/* 12-bit receive FIFO almost-empty threshold */
+	unsigned int rx_almost_empty;
+	/* 12-bit receive FIFO almost-full threshold */
+	unsigned int rx_almost_full;
+	/* 12-bit transmit FIFO almost-empty threshold */
+	unsigned int tx_almost_empty;
+	/* 12-bit transmit FIFO almost-full threshold */
+	unsigned int tx_almost_full;
+	/* MDIO address of PHY Device 0. Bits 0 to 4 hold a 5-bit PHY address=
 */
+	unsigned int mdio_phy0_addr;
+	/* MDIO address of PHY Device 1. Bits 0 to 4 hold a 5-bit PHY address=
 */
+	unsigned int mdio_phy1_addr;
+
+	/* Bit[15:0]=E2=80=9416-bit holdoff quanta */
+	unsigned int holdoff_quant;
+
+	/* only if 100/1000 BaseX PCS, reserved otherwise */
+	unsigned int reserved1[5];
+
+	/* Minimum IPG between consecutive transmit frame in terms of bytes *=
/
+	unsigned int tx_ipg_length;
+
+	/* IEEE 802.3 oEntity Managed Object Support */
+
+	/* The MAC addresses */
+	unsigned int mac_id_1;
+	unsigned int mac_id_2;
+
+	/* Number of frames transmitted without error including pause frames =
*/
+	unsigned int frames_transmitted_ok;
+	/* Number of frames received without error including pause frames */
+	unsigned int frames_received_ok;
+	/* Number of frames received with a CRC error */
+	unsigned int frames_check_sequence_errors;
+	/* Frame received with an alignment error */
+	unsigned int alignment_errors;
+	/* Sum of payload and padding octets of frames transmitted without
+	 * error
+	 */
+	unsigned int octets_transmitted_ok;
+	/* Sum of payload and padding octets of frames received without error=
 */
+	unsigned int octets_received_ok;
+
+	/* IEEE 802.3 oPausedEntity Managed Object Support */
+
+	/* Number of transmitted pause frames */
+	unsigned int tx_pause_mac_ctrl_frames;
+	/* Number of Received pause frames */
+	unsigned int rx_pause_mac_ctrl_frames;
+
+	/* IETF MIB (MIB-II) Object Support */
+
+	/* Number of frames received with error */
+	unsigned int if_in_errors;
+	/* Number of frames transmitted with error */
+	unsigned int if_out_errors;
+	/* Number of valid received unicast frames */
+	unsigned int if_in_ucast_pkts;
+	/* Number of valid received multicasts frames (without pause) */
+	unsigned int if_in_multicast_pkts;
+	/* Number of valid received broadcast frames */
+	unsigned int if_in_broadcast_pkts;
+	unsigned int if_out_discards;
+	/* The number of valid unicast frames transmitted */
+	unsigned int if_out_ucast_pkts;
+	/* The number of valid multicast frames transmitted,
+	 * excluding pause frames
+	 */
+	unsigned int if_out_multicast_pkts;
+	unsigned int if_out_broadcast_pkts;
+
+	/* IETF RMON MIB Object Support */
+
+	/* Counts the number of dropped packets due to internal errors
+	 * of the MAC client.
+	 */
+	unsigned int ether_stats_drop_events;
+	/* Total number of bytes received. Good and bad frames. */
+	unsigned int ether_stats_octets;
+	/* Total number of packets received. Counts good and bad packets. */
+	unsigned int ether_stats_pkts;
+	/* Number of packets received with less than 64 bytes. */
+	unsigned int ether_stats_undersize_pkts;
+	/* The number of frames received that are longer than the
+	 * value configured in the frm_length register
+	 */
+	unsigned int ether_stats_oversize_pkts;
+	/* Number of received packet with 64 bytes */
+	unsigned int ether_stats_pkts_64_octets;
+	/* Frames (good and bad) with 65 to 127 bytes */
+	unsigned int ether_stats_pkts_65to127_octets;
+	/* Frames (good and bad) with 128 to 255 bytes */
+	unsigned int ether_stats_pkts_128to255_octets;
+	/* Frames (good and bad) with 256 to 511 bytes */
+	unsigned int ether_stats_pkts_256to511_octets;
+	/* Frames (good and bad) with 512 to 1023 bytes */
+	unsigned int ether_stats_pkts_512to1023_octets;
+	/* Frames (good and bad) with 1024 to 1518 bytes */
+	unsigned int ether_stats_pkts_1024to1518_octets;
+
+	/* Any frame length from 1519 to the maximum length configured in the
+	 * frm_length register, if it is greater than 1518
+	 */
+	unsigned int ether_stats_pkts_1519tox_octets;
+	/* Too long frames with CRC error */
+	unsigned int ether_stats_jabbers;
+	/* Too short frames with CRC error */
+	unsigned int ether_stats_fragments;
+
+	unsigned int reserved2;
+
+	/* FIFO control register */
+	unsigned int tx_cmd_stat;
+	unsigned int rx_cmd_stat;
+
+	/* Extended Statistics Counters */
+	unsigned int msb_octets_transmitted_ok;
+	unsigned int msb_octets_received_ok;
+	unsigned int msb_ether_stats_octets;
+
+	unsigned int reserved3;
+
+	/* Multicast address resolution table, mapped in the controller addre=
ss
+	 * space
+	 */
+	unsigned int hash_table[64];
+
+	/* Registers 0 to 31 within PHY device 0/1 connected to the MDIO PHY
+	 * management interface
+	 */
+	struct altera_tse_mdio mdio_phy0;
+	struct altera_tse_mdio mdio_phy1;
+
+	/* 4 Supplemental MAC Addresses */
+	unsigned int supp_mac_addr_0_0;
+	unsigned int supp_mac_addr_0_1;
+	unsigned int supp_mac_addr_1_0;
+	unsigned int supp_mac_addr_1_1;
+	unsigned int supp_mac_addr_2_0;
+	unsigned int supp_mac_addr_2_1;
+	unsigned int supp_mac_addr_3_0;
+	unsigned int supp_mac_addr_3_1;
+
+	unsigned int reserved4[8];
+
+	/* IEEE 1588v2 Feature */
+	unsigned int tx_period;
+	unsigned int tx_adjust_fns;
+	unsigned int tx_adjust_ns;
+	unsigned int rx_period;
+	unsigned int rx_adjust_fns;
+	unsigned int rx_adjust_ns;
+
+	unsigned int reserved5[42];
+};
+
+/* Transmit and Receive Command Registers Bit Definitions
+ */
+#define ALTERA_TSE_TX_CMD_STAT_OMIT_CRC		BIT(17)
+#define ALTERA_TSE_TX_CMD_STAT_TX_SHIFT16	BIT(18)
+#define ALTERA_TSE_RX_CMD_STAT_RX_SHIFT16	BIT(25)
+
+/* Wrapper around a pointer to a socket buffer,
+ * so a DMA handle can be stored along with the buffer
+ */
+struct tse_buffer {
+	struct list_head lh;
+	struct sk_buff *skb;
+	dma_addr_t dma_addr;
+	unsigned int len;
+	int mapped_as_page;
+};
+
+/* This structure is private to each device.
+ */
+struct altera_tse_private {
+	struct net_device *dev;
+	struct device *device;
+	struct napi_struct napi;
+
+	/* MAC address space */
+	struct altera_tse_mac *mac_dev;
+
+	/* TSE Revision */
+	u32	revision;
+
+	/* mSGDMA Rx Dispatcher address space */
+	void __iomem *rx_dma_csr;
+	void __iomem *rx_dma_desc;
+	void __iomem *rx_dma_resp;
+
+	/* mSGDMA Tx Dispatcher address space */
+	void __iomem *tx_dma_csr;
+	void __iomem *tx_dma_desc;
+
+	/* Rx buffers queue */
+	struct tse_buffer *rx_ring;
+	unsigned int rx_cons;
+	unsigned int rx_prod;
+	unsigned int rx_ring_size;
+	unsigned int rx_dma_buf_sz;
+
+	/* Tx ring buffer */
+	struct tse_buffer *tx_ring;
+	unsigned int tx_prod;
+	unsigned int tx_cons;
+	unsigned int tx_ring_size;
+
+	/* Interrupts */
+	unsigned int tx_irq;
+	unsigned int rx_irq;
+
+	/* RX/TX MAC FIFO configs */
+	unsigned int tx_fifo_depth;
+	unsigned int rx_fifo_depth;
+	unsigned int max_mtu;
+
+	/* Hash filter settings */
+	unsigned int hash_filter;
+	unsigned int added_unicast;
+
+	/* Descriptor memory info for managing SGDMA */
+	unsigned int txdescmem;
+	unsigned int rxdescmem;
+	unsigned int rxdescmem_busaddr;
+	unsigned int txdescmem_busaddr;
+	unsigned int descripsz;
+	unsigned int txdescrips;
+	unsigned int rxdescrips;
+	unsigned int txctrlreg;
+	unsigned int rxctrlreg;
+	dma_addr_t rxdescphys;
+	dma_addr_t txdescphys;
+
+	struct list_head txlisthd;
+	struct list_head rxlisthd;
+
+	/* MAC command_config register protection */
+	spinlock_t mac_cfg_lock;
+	/* Tx path protection */
+	spinlock_t tx_lock;
+	/* Rx DMA & interrupt control protection */
+	spinlock_t rxdma_irq_lock;
+
+	/* PHY */
+	int phy_addr;		/* PHY's MDIO address, -1 for autodetection */
+	phy_interface_t phy_iface;
+	struct mii_bus *mdio;
+	struct phy_device *phydev;
+	int oldspeed;
+	int oldduplex;
+	int oldlink;
+
+	/* ethtool msglvl option */
+	u32 msg_enable;
+
+	/* standard DMA interface for SGDMA and MSGDMA */
+	void (*reset_dma)(struct altera_tse_private *);
+	void (*enable_txirq)(struct altera_tse_private *);
+	void (*enable_rxirq)(struct altera_tse_private *);
+	void (*disable_txirq)(struct altera_tse_private *);
+	void (*disable_rxirq)(struct altera_tse_private *);
+	void (*clear_txirq)(struct altera_tse_private *);
+	void (*clear_rxirq)(struct altera_tse_private *);
+	int (*tx_buffer)(struct altera_tse_private *, struct tse_buffer *);
+	u32 (*tx_completions)(struct altera_tse_private *);
+	int (*add_rx_desc)(struct altera_tse_private *, struct tse_buffer *);
+	u32 (*get_rx_status)(struct altera_tse_private *);
+	int (*init_dma)(struct altera_tse_private *);
+	void (*uninit_dma)(struct altera_tse_private *);
+};
+
+/* Function prototypes
+ */
+void altera_tse_set_ethtool_ops(struct net_device *);
+
+#endif /* __ALTERA_TSE_H__ */
diff --git a/drivers/net/ethernet/altera/altera_tse_ethtool.c b/drivers=
/net/ethernet/altera/altera_tse_ethtool.c
new file mode 100644
index 0000000..58328c1
--- /dev/null
+++ b/drivers/net/ethernet/altera/altera_tse_ethtool.c
@@ -0,0 +1,226 @@
+/* Ethtool support for Altera Triple-Speed Ethernet MAC driver
+ * Copyright (C) 2014 Altera Corporation. All rights reserved
+ *
+ * Contributors:
+ *   Dalon Westergreen
+ *   Thomas Chou
+ *   Ian Abbott
+ *   Yuriy Kozlov
+ *   Tobias Klauser
+ *   Andriy Smolskyy
+ *   Roman Bulgakov
+ *   Dmytro Mytarchuk
+ *
+ * Original driver contributed by SLS.
+ * Major updates contributed by GlobalLogic
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITH=
OUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY =
or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public Licen=
se for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License a=
long with
+ * this program.  If not, see <http://www.gnu.org/licenses/>.
+ */
+
+#include <linux/ethtool.h>
+#include <linux/kernel.h>
+#include <linux/netdevice.h>
+#include <linux/phy.h>
+
+#include "altera_tse.h"
+
+#define TSE_STATS_LEN 31
+
+static char stat_gstrings[][ETH_GSTRING_LEN] =3D {
+	"aFramesTransmittedOK",
+	"aFramesReceivedOK",
+	"aFramesCheckSequenceErrors",
+	"aAlignmentErrors",
+	"aOctetsTransmittedOK",
+	"aOctetsReceivedOK",
+	"aTxPAUSEMACCtrlFrames",
+	"aRxPAUSEMACCtrlFrames",
+	"ifInErrors",
+	"ifOutErrors",
+	"ifInUcastPkts",
+	"ifInMulticastPkts",
+	"ifInBroadcastPkts",
+	"ifOutDiscards",
+	"ifOutUcastPkts",
+	"ifOutMulticastPkts",
+	"ifOutBroadcastPkts",
+	"etherStatsDropEvents",
+	"etherStatsOctets",
+	"etherStatsPkts",
+	"etherStatsUndersizePkts",
+	"etherStatsOversizePkts",
+	"etherStatsPkts64Octets",
+	"etherStatsPkts65to127Octets",
+	"etherStatsPkts128to255Octets",
+	"etherStatsPkts256to511Octets",
+	"etherStatsPkts512to1023Octets",
+	"etherStatsPkts1024to1518Octets",
+	"etherStatsPkts1519toXOctets",
+	"etherStatsJabbers",
+	"etherStatsFragments",
+};
+
+static void tse_get_drvinfo(struct net_device *dev,
+			    struct ethtool_drvinfo *info)
+{
+	struct altera_tse_private *priv =3D netdev_priv(dev);
+	u32 rev =3D ioread32(&priv->mac_dev->megacore_revision);
+
+	strcpy(info->driver, "Altera TSE MAC IP Driver");
+	strcpy(info->version, "v8.0");
+	snprintf(info->fw_version, ETHTOOL_FWVERS_LEN, "v%d.%d",
+		 rev & 0xFFFF, (rev & 0xFFFF0000) >> 16);
+	sprintf(info->bus_info, "AVALON");
+}
+
+/* Fill in a buffer with the strings which correspond to the
+ * stats
+ */
+static void tse_gstrings(struct net_device *dev, u32 stringset, u8 *bu=
f)
+{
+	memcpy(buf, stat_gstrings, TSE_STATS_LEN * ETH_GSTRING_LEN);
+}
+
+static void tse_fill_stats(struct net_device *dev, struct ethtool_stat=
s *dummy,
+			   u64 *buf)
+{
+	struct altera_tse_private *priv =3D netdev_priv(dev);
+	struct altera_tse_mac *mac =3D priv->mac_dev;
+	u64 ext;
+
+	buf[0] =3D (u64) ioread32(&mac->frames_transmitted_ok);
+	buf[1] =3D (u64) ioread32(&mac->frames_received_ok);
+	buf[2] =3D (u64) ioread32(&mac->frames_check_sequence_errors);
+	buf[3] =3D (u64) ioread32(&mac->alignment_errors);
+
+	/* Extended aOctetsTransmittedOK counter */
+	ext =3D (u64) ioread32(&mac->msb_octets_transmitted_ok) << 32;
+	ext |=3D (u64) ioread32(&mac->octets_transmitted_ok);
+	buf[4] =3D ext;
+
+	/* Extended aOctetsReceivedOK counter */
+	ext =3D (u64) ioread32(&mac->msb_octets_received_ok) << 32;
+	ext |=3D (u64) ioread32(&mac->octets_received_ok);
+	buf[5] =3D ext;
+
+	buf[6] =3D (u64) ioread32(&mac->tx_pause_mac_ctrl_frames);
+	buf[7] =3D (u64) ioread32(&mac->rx_pause_mac_ctrl_frames);
+	buf[8] =3D (u64) ioread32(&mac->if_in_errors);
+	buf[9] =3D (u64) ioread32(&mac->if_out_errors);
+	buf[10] =3D (u64) ioread32(&mac->if_in_ucast_pkts);
+	buf[11] =3D (u64) ioread32(&mac->if_in_multicast_pkts);
+	buf[12] =3D (u64) ioread32(&mac->if_in_broadcast_pkts);
+	buf[13] =3D (u64) ioread32(&mac->if_out_discards);
+	buf[14] =3D (u64) ioread32(&mac->if_out_ucast_pkts);
+	buf[15] =3D (u64) ioread32(&mac->if_out_multicast_pkts);
+	buf[16] =3D (u64) ioread32(&mac->if_out_broadcast_pkts);
+	buf[17] =3D (u64) ioread32(&mac->ether_stats_drop_events);
+
+	/* Extended etherStatsOctets counter */
+	ext =3D (u64) ioread32(&mac->msb_ether_stats_octets) << 32;
+	ext |=3D (u64) ioread32(&mac->ether_stats_octets);
+	buf[18] =3D ext;
+
+	buf[19] =3D (u64) ioread32(&mac->ether_stats_pkts);
+	buf[20] =3D (u64) ioread32(&mac->ether_stats_undersize_pkts);
+	buf[21] =3D (u64) ioread32(&mac->ether_stats_oversize_pkts);
+	buf[22] =3D (u64) ioread32(&mac->ether_stats_pkts_64_octets);
+	buf[23] =3D (u64) ioread32(&mac->ether_stats_pkts_65to127_octets);
+	buf[24] =3D (u64) ioread32(&mac->ether_stats_pkts_128to255_octets);
+	buf[25] =3D (u64) ioread32(&mac->ether_stats_pkts_256to511_octets);
+	buf[26] =3D (u64) ioread32(&mac->ether_stats_pkts_512to1023_octets);
+	buf[27] =3D (u64) ioread32(&mac->ether_stats_pkts_1024to1518_octets);
+	buf[28] =3D (u64) ioread32(&mac->ether_stats_pkts_1519tox_octets);
+	buf[29] =3D (u64) ioread32(&mac->ether_stats_jabbers);
+	buf[30] =3D (u64) ioread32(&mac->ether_stats_fragments);
+}
+
+static int tse_sset_count(struct net_device *dev, int sset)
+{
+	switch (sset) {
+	case ETH_SS_STATS:
+		return TSE_STATS_LEN;
+	default:
+		return -EOPNOTSUPP;
+	}
+}
+
+static u32 tse_get_msglevel(struct net_device *dev)
+{
+	struct altera_tse_private *priv =3D netdev_priv(dev);
+	return priv->msg_enable;
+}
+
+static void tse_set_msglevel(struct net_device *dev, uint32_t data)
+{
+	struct altera_tse_private *priv =3D netdev_priv(dev);
+	priv->msg_enable =3D data;
+}
+
+static int tse_reglen(struct net_device *dev)
+{
+	return sizeof(struct altera_tse_mac);
+}
+
+static void tse_get_regs(struct net_device *dev, struct ethtool_regs *=
regs,
+			 void *regbuf)
+{
+	int i;
+	struct altera_tse_private *priv =3D netdev_priv(dev);
+	u32 *tse_mac_regs =3D (u32 *)priv->mac_dev;
+	u32 *buf =3D (u32 *)regbuf;
+
+	for (i =3D 0; i < sizeof(struct altera_tse_mac) / sizeof(u32); i++)
+		buf[i] =3D ioread32(&tse_mac_regs[i]);
+}
+
+static int tse_get_settings(struct net_device *dev, struct ethtool_cmd=
 *cmd)
+{
+	struct altera_tse_private *priv =3D netdev_priv(dev);
+	struct phy_device *phydev =3D priv->phydev;
+
+	if (phydev =3D=3D NULL)
+		return -ENODEV;
+
+	return phy_ethtool_gset(phydev, cmd);
+}
+
+static int tse_set_settings(struct net_device *dev, struct ethtool_cmd=
 *cmd)
+{
+	struct altera_tse_private *priv =3D netdev_priv(dev);
+	struct phy_device *phydev =3D priv->phydev;
+
+	if (phydev =3D=3D NULL)
+		return -ENODEV;
+
+	return phy_ethtool_sset(phydev, cmd);
+}
+
+static const struct ethtool_ops tse_ethtool_ops =3D {
+	.get_drvinfo =3D tse_get_drvinfo,
+	.get_regs_len =3D tse_reglen,
+	.get_regs =3D tse_get_regs,
+	.get_link =3D ethtool_op_get_link,
+	.get_settings =3D tse_get_settings,
+	.set_settings =3D tse_set_settings,
+	.get_strings =3D tse_gstrings,
+	.get_sset_count =3D tse_sset_count,
+	.get_ethtool_stats =3D tse_fill_stats,
+	.get_msglevel =3D tse_get_msglevel,
+	.set_msglevel =3D tse_set_msglevel,
+};
+
+void altera_tse_set_ethtool_ops(struct net_device *netdev)
+{
+	SET_ETHTOOL_OPS(netdev, &tse_ethtool_ops);
+}
diff --git a/drivers/net/ethernet/altera/altera_utils.c b/drivers/net/e=
thernet/altera/altera_utils.c
new file mode 100644
index 0000000..4f112fb
--- /dev/null
+++ b/drivers/net/ethernet/altera/altera_utils.c
@@ -0,0 +1,46 @@
+/* Altera TSE SGDMA and MSGDMA Linux driver
+ * Copyright (C) 2014 Altera Corporation. All rights reserved
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITH=
OUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY =
or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public Licen=
se for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License a=
long with
+ * this program.  If not, see <http://www.gnu.org/licenses/>.
+ */
+
+#include "altera_tse.h"
+#include "altera_utils.h"
+
+void tse_set_bit(void __iomem *ioaddr, u32 bit_mask)
+{
+	u32 value =3D ioread32(ioaddr);
+	value |=3D bit_mask;
+	iowrite32(value, ioaddr);
+}
+
+void tse_clear_bit(void __iomem *ioaddr, u32 bit_mask)
+{
+	u32 value =3D ioread32(ioaddr);
+	value &=3D ~bit_mask;
+	iowrite32(value, ioaddr);
+}
+
+int tse_bit_is_set(void __iomem *ioaddr, u32 bit_mask)
+{
+	u32 value =3D ioread32(ioaddr);
+	return (value & bit_mask) ? 1 : 0;
+}
+
+int tse_bit_is_clear(void __iomem *ioaddr, u32 bit_mask)
+{
+	u32 value =3D ioread32(ioaddr);
+	return (value & bit_mask) ? 0 : 1;
+}
+
+
diff --git a/drivers/net/ethernet/altera/altera_utils.h b/drivers/net/e=
thernet/altera/altera_utils.h
new file mode 100644
index 0000000..ccff509
--- /dev/null
+++ b/drivers/net/ethernet/altera/altera_utils.h
@@ -0,0 +1,28 @@
+/* Altera TSE SGDMA and MSGDMA Linux driver
+ * Copyright (C) 2014 Altera Corporation. All rights reserved
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITH=
OUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY =
or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public Licen=
se for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License a=
long with
+ * this program.  If not, see <http://www.gnu.org/licenses/>.
+ */
+
+#include <linux/kernel.h>
+
+#ifndef __ALTERA_UTILS_H__
+#define __ALTERA_UTILS_H__
+
+void tse_set_bit(void __iomem *ioaddr, u32 bit_mask);
+void tse_clear_bit(void __iomem *ioaddr, u32 bit_mask);
+int tse_bit_is_set(void __iomem *ioaddr, u32 bit_mask);
+int tse_bit_is_clear(void __iomem *ioaddr, u32 bit_mask);
+
+#endif /* __ALTERA_UTILS_H__*/
+
--=20
1.7.9.5
