From: Noam Camus <noamc@ezchip.com>
Subject: [PATCH v4] NET: Add ezchip ethernet driver
Date: Sun, 14 Jun 2015 09:26:33 +0300
Message-ID: <1434263193-16877-1-git-send-email-noamc@ezchip.com>
References: <1434044505-13327-1-git-send-email-noamc@ezchip.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Alexey.Brodkin@synopsys.com>, <vgupta@synopsys.com>,
	<giladb@ezchip.com>, <cmetcalf@ezchip.com>,
	Noam Camus <noamc@ezchip.com>, Tal Zilcer <talz@ezchip.com>
To: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-am1on0059.outbound.protection.outlook.com ([157.56.112.59]:28506
	"EHLO emea01-am1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751307AbbFNG1s (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 14 Jun 2015 02:27:48 -0400
In-Reply-To: <1434044505-13327-1-git-send-email-noamc@ezchip.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Noam Camus <noamc@ezchip.com>

Simple LAN device for debug or management purposes.
Device supports interrupts for RX and TX(completion).
Device does not have DMA ability.

Signed-off-by: Noam Camus <noamc@ezchip.com>
Signed-off-by: Tal Zilcer <talz@ezchip.com>
Acked-by: Alexey Brodkin <abrodkin@synopsys.com>
---
Change log for v4:
1) replace macros with generic ones i.e. DIV_ROUND_UP and IS_ALIGNED
2) Use casting to insure GCC will handle unaligned access byte by byte
3) Add NAPI support
4) remove get_stats()
5) update Kconfig and commit log
---
 .../devicetree/bindings/net/ezchip_enet.txt        |   15 +
 drivers/net/ethernet/Kconfig                       |    1 +
 drivers/net/ethernet/Makefile                      |    1 +
 drivers/net/ethernet/ezchip/Kconfig                |   27 +
 drivers/net/ethernet/ezchip/Makefile               |    1 +
 drivers/net/ethernet/ezchip/nps_enet.c             |  668 ++++++++++++++++++++
 drivers/net/ethernet/ezchip/nps_enet.h             |  327 ++++++++++
 7 files changed, 1040 insertions(+), 0 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/ezchip_enet.txt
 create mode 100644 drivers/net/ethernet/ezchip/Kconfig
 create mode 100644 drivers/net/ethernet/ezchip/Makefile
 create mode 100644 drivers/net/ethernet/ezchip/nps_enet.c
 create mode 100644 drivers/net/ethernet/ezchip/nps_enet.h

diff --git a/Documentation/devicetree/bindings/net/ezchip_enet.txt b/Documentation/devicetree/bindings/net/ezchip_enet.txt
new file mode 100644
index 0000000..4e29b2b
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/ezchip_enet.txt
@@ -0,0 +1,15 @@
+* EZchip NPS Management Ethernet port driver
+
+Required properties:
+- compatible: Should be "ezchip,nps-mgt-enet"
+- reg: Address and length of the register set for the device
+- interrupts: Should contain the ENET interrupt
+
+Examples:
+
+	ethernet@f0003000 {
+		compatible = "ezchip,nps-mgt-enet";
+		reg = <0xf0003000 0x44>;
+		interrupts = <7>;
+		mac-address = [ 00 11 22 33 44 55 ];
+	};
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index eadcb05..1a6b1ba 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -66,6 +66,7 @@ config DNET
 source "drivers/net/ethernet/dec/Kconfig"
 source "drivers/net/ethernet/dlink/Kconfig"
 source "drivers/net/ethernet/emulex/Kconfig"
+source "drivers/net/ethernet/ezchip/Kconfig"
 source "drivers/net/ethernet/neterion/Kconfig"
 source "drivers/net/ethernet/faraday/Kconfig"
 source "drivers/net/ethernet/freescale/Kconfig"
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index 1367afc..489f9cc 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -29,6 +29,7 @@ obj-$(CONFIG_DNET) += dnet.o
 obj-$(CONFIG_NET_VENDOR_DEC) += dec/
 obj-$(CONFIG_NET_VENDOR_DLINK) += dlink/
 obj-$(CONFIG_NET_VENDOR_EMULEX) += emulex/
+obj-$(CONFIG_NET_VENDOR_EZCHIP) += ezchip/
 obj-$(CONFIG_NET_VENDOR_EXAR) += neterion/
 obj-$(CONFIG_NET_VENDOR_FARADAY) += faraday/
 obj-$(CONFIG_NET_VENDOR_FREESCALE) += freescale/
diff --git a/drivers/net/ethernet/ezchip/Kconfig b/drivers/net/ethernet/ezchip/Kconfig
new file mode 100644
index 0000000..d031177
--- /dev/null
+++ b/drivers/net/ethernet/ezchip/Kconfig
@@ -0,0 +1,27 @@
+#
+# EZchip network device configuration
+#
+
+config NET_VENDOR_EZCHIP
+	bool "EZchip devices"
+	default y
+	---help---
+	  If you have a network (Ethernet) device belonging to this class, say Y
+	  and read the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  Note that the answer to this question doesn't directly affect the
+	  kernel: saying N will just cause the configurator to skip all
+	  the questions about EZchip devices. If you say Y, you will be asked for
+	  your specific device in the following questions.
+
+if NET_VENDOR_EZCHIP
+
+config EZCHIP_NPS_MANAGEMENT_ENET
+	tristate "EZchip NPS management enet support"
+	---help---
+	  Simple LAN device for debug or management purposes.
+	  Device supports interrupts for RX and TX(completion).
+	  Device does not have DMA ability.
+
+endif
diff --git a/drivers/net/ethernet/ezchip/Makefile b/drivers/net/ethernet/ezchip/Makefile
new file mode 100644
index 0000000..e490176
--- /dev/null
+++ b/drivers/net/ethernet/ezchip/Makefile
@@ -0,0 +1 @@
+obj-$(CONFIG_EZCHIP_NPS_MANAGEMENT_ENET) += nps_enet.o
diff --git a/drivers/net/ethernet/ezchip/nps_enet.c b/drivers/net/ethernet/ezchip/nps_enet.c
new file mode 100644
index 0000000..619451c
--- /dev/null
+++ b/drivers/net/ethernet/ezchip/nps_enet.c
@@ -0,0 +1,668 @@
+/*
+ * Copyright(c) 2015 EZchip Technologies.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * The full GNU General Public License is included in this distribution in
+ * the file called "COPYING".
+ */
+
+#include <linux/module.h>
+#include <linux/etherdevice.h>
+#include <linux/of_address.h>
+#include <linux/of_irq.h>
+#include <linux/of_net.h>
+#include <linux/of_platform.h>
+#include "nps_enet.h"
+
+#define DRV_NAME			"nps_mgt_enet"
+
+static void nps_enet_clean_rx_fifo(struct net_device *ndev, u32 frame_len)
+{
+	struct nps_enet_priv *priv = netdev_priv(ndev);
+	u32 i, len = DIV_ROUND_UP(frame_len, sizeof(u32));
+
+	/* Empty Rx FIFO buffer by reading all words */
+	for (i = 0; i < len; i++)
+		nps_enet_reg_get(priv, NPS_ENET_REG_RX_BUF);
+}
+
+static void nps_enet_read_rx_fifo(struct net_device *ndev,
+				  unsigned char *dst, u32 length)
+{
+	struct nps_enet_priv *priv = netdev_priv(ndev);
+	s32 i, last = length & (sizeof(u32) - 1);
+	u32 *reg = (u32 *)dst, len = length / sizeof(u32);
+	bool dst_is_aligned = IS_ALIGNED((u32)dst, sizeof(u32));
+
+	/* In case dst is not aligned we need an intermediate buffer */
+	if (dst_is_aligned)
+		for (i = 0; i < len; i++, reg++)
+			*reg = nps_enet_reg_get(priv, NPS_ENET_REG_RX_BUF);
+	else { /* !dst_is_aligned */
+		for (i = 0; i < len; i++, reg++) {
+			u32 buf =
+				nps_enet_reg_get(priv, NPS_ENET_REG_RX_BUF);
+
+			/* to accommodate word-unaligned address of "reg"
+			 * we have to do memcpy() instead of simple "=".
+			 * we cast reg so compiler won't try optimize
+			 * to 32-bit load/store sequence.
+			 */
+			memcpy((void *)reg, &buf, sizeof(buf));
+		}
+	}
+
+	/* copy last bytes (if any) */
+	if (last) {
+		u32 buf = nps_enet_reg_get(priv, NPS_ENET_REG_RX_BUF);
+
+		memcpy(reg, &buf, last);
+	}
+}
+
+static void nps_enet_rx_handler(struct net_device *ndev)
+{
+	struct nps_enet_priv *priv = netdev_priv(ndev);
+	struct sk_buff *skb = priv->irq_data.skb;
+	struct nps_enet_rx_ctl rx_ctrl;
+	u32 frame_len;
+
+	rx_ctrl.value = priv->irq_data.rx_ctrl.value;
+	frame_len = rx_ctrl.nr;
+	/* Check if we got RX */
+	if (!rx_ctrl.cr)
+		return;
+
+	ndev->stats.rx_packets++;
+	ndev->stats.rx_bytes += frame_len;
+
+	netif_receive_skb(skb);
+}
+
+static s32 nps_enet_rx_prep(struct net_device *ndev)
+{
+	struct nps_enet_priv *priv = netdev_priv(ndev);
+	struct sk_buff *skb;
+	struct nps_enet_rx_ctl rx_ctrl;
+	u32 frame_len, err = 0;
+	s32 ret = 0;
+
+	rx_ctrl.value = nps_enet_reg_get(priv, NPS_ENET_REG_RX_CTL);
+	frame_len = rx_ctrl.nr;
+
+	/* Check if we got RX */
+	if (!rx_ctrl.cr) {
+		priv->irq_data.rx_ctrl.value = 0;
+		return ret;
+	}
+
+	/* Check Rx error */
+	if (rx_ctrl.er) {
+		ndev->stats.rx_errors++;
+		err = 1;
+	}
+
+	/* Check Rx CRC error */
+	if (rx_ctrl.crc) {
+		ndev->stats.rx_crc_errors++;
+		ndev->stats.rx_dropped++;
+		err = 1;
+	}
+
+	/* Check Frame length Min 64b */
+	if (unlikely(frame_len < ETH_ZLEN)) {
+		ndev->stats.rx_length_errors++;
+		ndev->stats.rx_dropped++;
+		err = 1;
+	}
+
+	if (err)
+		goto rx_irq_clean;
+
+	/* Skb allocation */
+	skb = netdev_alloc_skb_ip_align(ndev, frame_len);
+	if (unlikely(!skb)) {
+		ndev->stats.rx_errors++;
+		ndev->stats.rx_dropped++;
+		goto rx_irq_clean;
+	}
+
+	/* Copy frame from Rx fifo into the skb */
+	nps_enet_read_rx_fifo(ndev, skb->data, frame_len);
+
+	skb_put(skb, frame_len);
+	skb->dev = ndev;
+	skb->protocol = eth_type_trans(skb, ndev);
+	skb->ip_summed = CHECKSUM_UNNECESSARY;
+
+	priv->irq_data.skb = skb;
+	priv->irq_data.rx_ctrl.value = rx_ctrl.value;
+	ret = 1;
+	goto rx_irq_frame_done;
+
+rx_irq_clean:
+	/* Clean Rx fifo */
+	nps_enet_clean_rx_fifo(ndev, frame_len);
+	priv->irq_data.rx_ctrl.value = 0;
+
+rx_irq_frame_done:
+	/* Ack Rx ctrl register */
+	nps_enet_reg_set(priv, NPS_ENET_REG_RX_CTL, 0);
+
+	return ret;
+}
+
+static void nps_enet_tx_handler(struct net_device *ndev)
+{
+	struct nps_enet_priv *priv = netdev_priv(ndev);
+	struct nps_enet_tx_ctl tx_ctrl;
+
+	tx_ctrl.value = priv->irq_data.tx_ctrl.value;
+	/* Check if we got TX */
+	if (!priv->tx_packet_sent || tx_ctrl.ct)
+		return;
+
+	/* Check Tx transmit error */
+	if (unlikely(tx_ctrl.et)) {
+		ndev->stats.tx_errors++;
+	} else {
+		ndev->stats.tx_packets++;
+		ndev->stats.tx_bytes += tx_ctrl.nt;
+	}
+
+	/* In nps_enet_start_xmit we disabled sending frames*/
+	netif_wake_queue(ndev);
+
+	priv->tx_packet_sent = false;
+}
+
+static s32 nps_enet_tx_prep(struct net_device *ndev)
+{
+	struct nps_enet_priv *priv = netdev_priv(ndev);
+	struct nps_enet_tx_ctl tx_ctrl;
+	s32 ret = 0;
+
+	tx_ctrl.value = nps_enet_reg_get(priv, NPS_ENET_REG_TX_CTL);
+	if (!tx_ctrl.ct && priv->tx_packet_sent) {
+		/* Ack Tx ctrl register */
+		nps_enet_reg_set(priv, NPS_ENET_REG_TX_CTL, 0);
+		priv->irq_data.tx_ctrl.value = tx_ctrl.value;
+		ret = 1;
+	} else {
+		priv->irq_data.tx_ctrl.value = 0;
+	}
+
+	return ret;
+}
+
+static s32 nps_enet_prep(struct net_device *ndev)
+{
+	s32 ret = 0;
+
+	ret |= nps_enet_tx_prep(ndev);
+	ret |= nps_enet_rx_prep(ndev);
+
+	return ret;
+}
+
+/**
+ * nps_enet_poll - NAPI poll handler.
+ * @napi:       Pointer to napi_struct structure.
+ * @budget:     How many frames to process on 1 call.
+ *
+ * returns:     Number of processed frames
+ */
+static int nps_enet_poll(struct napi_struct *napi, int budget)
+{
+	struct net_device *ndev = napi->dev;
+	struct nps_enet_priv *priv = netdev_priv(ndev);
+	struct nps_enet_buf_int_enable buf_int_enable = {
+		.rx_rdy = NPS_ENET_ENABLE,
+		.tx_done = NPS_ENET_ENABLE,};
+
+	nps_enet_tx_handler(ndev);
+	nps_enet_rx_handler(ndev);
+	napi_complete(napi);
+	nps_enet_reg_set(priv, NPS_ENET_REG_BUF_INT_ENABLE,
+			 buf_int_enable.value);
+
+	return budget;
+}
+
+/**
+ * nps_enet_irq_handler - Global interrupt handler for ENET.
+ * @irq:                irq number.
+ * @dev_instance:       device instance.
+ *
+ * returns: IRQ_HANDLED for all cases.
+ *
+ * EZchip ENET has 2 interrupt causes, and depending on bits raised in
+ * CTRL registers we may tell what is a reason for interrupt to fire up.
+ * We got one for RX and the other for TX (completion).
+ */
+static irqreturn_t nps_enet_irq_handler(s32 irq, void *dev_instance)
+{
+	struct net_device *ndev = dev_instance;
+	struct nps_enet_priv *priv = netdev_priv(ndev);
+
+	if (nps_enet_prep(ndev)) {
+		if (likely(napi_schedule_prep(&priv->napi))) {
+			nps_enet_reg_set(priv, NPS_ENET_REG_BUF_INT_ENABLE, 0);
+			__napi_schedule(&priv->napi);
+		}
+	}
+
+	return IRQ_HANDLED;
+}
+
+static void nps_enet_set_hw_mac_address(struct net_device *ndev)
+{
+	struct nps_enet_priv *priv = netdev_priv(ndev);
+	struct nps_enet_ge_mac_cfg_1 ge_mac_cfg_1;
+	struct nps_enet_ge_mac_cfg_2 *ge_mac_cfg_2 = &priv->ge_mac_cfg_2;
+
+	/* set MAC address in HW */
+	ge_mac_cfg_1.octet_0 = ndev->dev_addr[0];
+	ge_mac_cfg_1.octet_1 = ndev->dev_addr[1];
+	ge_mac_cfg_1.octet_2 = ndev->dev_addr[2];
+	ge_mac_cfg_1.octet_3 = ndev->dev_addr[3];
+	ge_mac_cfg_2->octet_4 = ndev->dev_addr[4];
+	ge_mac_cfg_2->octet_5 = ndev->dev_addr[5];
+
+	nps_enet_reg_set(priv, NPS_ENET_REG_GE_MAC_CFG_1,
+			 ge_mac_cfg_1.value);
+
+	nps_enet_reg_set(priv, NPS_ENET_REG_GE_MAC_CFG_2,
+			 ge_mac_cfg_2->value);
+}
+
+/**
+ * nps_enet_hw_reset - Reset the network device.
+ * @ndev:       Pointer to the network device.
+ *
+ * This function reset the PCS and TX fifo.
+ * The programming model is to set the relevant reset bits
+ * wait for some time for this to propagate and then unset
+ * the reset bits. This way we ensure that reset procedure
+ * is done successfully by device.
+ */
+static void nps_enet_hw_reset(struct net_device *ndev)
+{
+	struct nps_enet_priv *priv = netdev_priv(ndev);
+	struct nps_enet_ge_rst ge_rst = {.value = 0};
+	struct nps_enet_phase_fifo_ctl phase_fifo_ctl = {.value = 0};
+
+	/* Pcs reset sequence*/
+	ge_rst.gmac_0 = NPS_ENET_ENABLE;
+	nps_enet_reg_set(priv, NPS_ENET_REG_GE_RST, ge_rst.value);
+	usleep_range(10, 20);
+	ge_rst.value = 0;
+	nps_enet_reg_set(priv, NPS_ENET_REG_GE_RST, ge_rst.value);
+
+	/* Tx fifo reset sequence */
+	phase_fifo_ctl.rst = NPS_ENET_ENABLE;
+	phase_fifo_ctl.init = NPS_ENET_ENABLE;
+	nps_enet_reg_set(priv, NPS_ENET_REG_PHASE_FIFO_CTL,
+			 phase_fifo_ctl.value);
+	usleep_range(10, 20);
+	phase_fifo_ctl.value = 0;
+	nps_enet_reg_set(priv, NPS_ENET_REG_PHASE_FIFO_CTL,
+			 phase_fifo_ctl.value);
+}
+
+static void nps_enet_hw_enable_control(struct net_device *ndev)
+{
+	struct nps_enet_priv *priv = netdev_priv(ndev);
+	struct nps_enet_ge_mac_cfg_0 ge_mac_cfg_0 = { .value = 0 };
+	struct nps_enet_buf_int_enable buf_int_enable = { .value = 0 };
+	struct nps_enet_ge_mac_cfg_2 *ge_mac_cfg_2 = &priv->ge_mac_cfg_2;
+	struct nps_enet_ge_mac_cfg_3 *ge_mac_cfg_3 = &priv->ge_mac_cfg_3;
+	s32 max_frame_length;
+
+	/* Enable Rx and Tx statistics */
+	ge_mac_cfg_2->stat_en = NPS_ENET_GE_MAC_CFG_2_STAT_EN;
+
+	/* Discard packets with different MAC address */
+	ge_mac_cfg_2->disc_da = NPS_ENET_ENABLE;
+
+	/* Discard multicast packets */
+	ge_mac_cfg_2->disc_mc = NPS_ENET_ENABLE;
+
+	nps_enet_reg_set(priv, NPS_ENET_REG_GE_MAC_CFG_2,
+			 ge_mac_cfg_2->value);
+
+	/* Discard Packets bigger than max frame length */
+	max_frame_length = ETH_HLEN + ndev->mtu + ETH_FCS_LEN;
+	if (max_frame_length <= NPS_ENET_MAX_FRAME_LENGTH) {
+		ge_mac_cfg_3->max_len = max_frame_length;
+		nps_enet_reg_set(priv, NPS_ENET_REG_GE_MAC_CFG_3,
+				 ge_mac_cfg_3->value);
+	}
+
+	/* Enable interrupts */
+	buf_int_enable.rx_rdy = NPS_ENET_ENABLE;
+	buf_int_enable.tx_done = NPS_ENET_ENABLE;
+	nps_enet_reg_set(priv, NPS_ENET_REG_BUF_INT_ENABLE,
+			 buf_int_enable.value);
+
+	/* Write device MAC address to HW */
+	nps_enet_set_hw_mac_address(ndev);
+
+	/* Rx and Tx HW features */
+	ge_mac_cfg_0.tx_pad_en = NPS_ENET_ENABLE;
+	ge_mac_cfg_0.tx_crc_en = NPS_ENET_ENABLE;
+	ge_mac_cfg_0.rx_crc_strip = NPS_ENET_ENABLE;
+
+	/* IFG configuration */
+	ge_mac_cfg_0.rx_ifg = NPS_ENET_GE_MAC_CFG_0_RX_IFG;
+	ge_mac_cfg_0.tx_ifg = NPS_ENET_GE_MAC_CFG_0_TX_IFG;
+
+	/* preamble configuration */
+	ge_mac_cfg_0.rx_pr_check_en = NPS_ENET_ENABLE;
+	ge_mac_cfg_0.tx_pr_len = NPS_ENET_GE_MAC_CFG_0_TX_PR_LEN;
+
+	/* enable flow control frames */
+	ge_mac_cfg_0.tx_fc_en = NPS_ENET_ENABLE;
+	ge_mac_cfg_0.rx_fc_en = NPS_ENET_ENABLE;
+	ge_mac_cfg_0.tx_fc_retr = NPS_ENET_GE_MAC_CFG_0_TX_FC_RETR;
+
+	/* Enable Rx and Tx */
+	ge_mac_cfg_0.rx_en = NPS_ENET_ENABLE;
+	ge_mac_cfg_0.tx_en = NPS_ENET_ENABLE;
+
+	nps_enet_reg_set(priv, NPS_ENET_REG_GE_MAC_CFG_0,
+			 ge_mac_cfg_0.value);
+}
+
+static void nps_enet_hw_disable_control(struct net_device *ndev)
+{
+	struct nps_enet_priv *priv = netdev_priv(ndev);
+
+	/* Disable interrupts */
+	nps_enet_reg_set(priv, NPS_ENET_REG_BUF_INT_ENABLE, 0);
+
+	/* Disable Rx and Tx */
+	nps_enet_reg_set(priv, NPS_ENET_REG_GE_MAC_CFG_0, 0);
+}
+
+static void nps_enet_send_frame(struct net_device *ndev,
+				struct sk_buff *skb)
+{
+	struct nps_enet_priv *priv = netdev_priv(ndev);
+	struct nps_enet_tx_ctl tx_ctrl = { .value = 0 };
+	short length = skb->len;
+	u32 i, len = DIV_ROUND_UP(length, sizeof(u32));
+	u32 *src = (u32 *)virt_to_phys(skb->data);
+	bool src_is_aligned = IS_ALIGNED((u32)src, sizeof(u32));
+
+	/* In case src is not aligned we need an intermediate buffer */
+	if (src_is_aligned)
+		for (i = 0; i < len; i++, src++)
+			nps_enet_reg_set(priv, NPS_ENET_REG_TX_BUF, *src);
+	else { /* !src_is_aligned */
+		for (i = 0; i < len; i++, src++) {
+			u32 buf;
+
+			/* to accommodate word-unaligned address of "src"
+			 * we have to do memcpy() instead of simple "="
+			 */
+			memcpy(&buf, src, sizeof(buf));
+			nps_enet_reg_set(priv, NPS_ENET_REG_TX_BUF, buf);
+		}
+	}
+	/* Write the length of the Frame */
+	tx_ctrl.nt = length;
+
+	/* Indicate SW is done */
+	priv->tx_packet_sent = true;
+	tx_ctrl.ct = NPS_ENET_ENABLE;
+
+	/* Send Frame */
+	nps_enet_reg_set(priv, NPS_ENET_REG_TX_CTL, tx_ctrl.value);
+}
+
+/**
+ * nps_enet_set_mac_address - Set the MAC address for this device.
+ * @ndev:       Pointer to net_device structure.
+ * @p:          6 byte Address to be written as MAC address.
+ *
+ * This function copies the HW address from the sockaddr structure to the
+ * net_device structure and updates the address in HW.
+ *
+ * returns:     -EBUSY if the net device is busy or 0 if the address is set
+ *              successfully.
+ */
+static s32 nps_enet_set_mac_address(struct net_device *ndev, void *p)
+{
+	struct sockaddr *addr = p;
+	s32 res;
+
+	if (netif_running(ndev))
+		return -EBUSY;
+
+	res = eth_mac_addr(ndev, p);
+	if (!res) {
+		ether_addr_copy(ndev->dev_addr, addr->sa_data);
+		nps_enet_set_hw_mac_address(ndev);
+	}
+
+	return res;
+}
+
+/**
+ * nps_enet_open - Open the network device.
+ * @ndev:       Pointer to the network device.
+ *
+ * returns: 0, on success or non-zero error value on failure.
+ *
+ * This function enables an IRQs for the ENET device and starts the Tx queue.
+ */
+static s32 nps_enet_open(struct net_device *ndev)
+{
+	s32 err;
+	struct nps_enet_priv *priv = netdev_priv(ndev);
+
+	/* Reset private variables */
+	priv->tx_packet_sent = false;
+	priv->ge_mac_cfg_2.value = 0;
+	priv->ge_mac_cfg_3.value = 0;
+
+	/* ge_mac_cfg_3 default values */
+	priv->ge_mac_cfg_3.rx_ifg_th = NPS_ENET_GE_MAC_CFG_3_RX_IFG_TH;
+	priv->ge_mac_cfg_3.max_len = NPS_ENET_GE_MAC_CFG_3_MAX_LEN;
+
+	/* Disable HW device */
+	nps_enet_hw_disable_control(ndev);
+
+	/* irq Rx allocation */
+	err = request_irq(priv->irq, nps_enet_irq_handler,
+			  0, "enet-rx-tx", ndev);
+	if (err)
+		return err;
+
+	napi_enable(&priv->napi);
+
+	/* Enable HW device */
+	nps_enet_hw_reset(ndev);
+	nps_enet_hw_enable_control(ndev);
+
+	netif_start_queue(ndev);
+
+	return 0;
+}
+
+/**
+ * nps_enet_stop - Close the network device.
+ * @ndev:       Pointer to the network device.
+ *
+ * This function stops the Tx queue, disables interrupts for the ENET device.
+ */
+static s32 nps_enet_stop(struct net_device *ndev)
+{
+	struct nps_enet_priv *priv = netdev_priv(ndev);
+
+	napi_disable(&priv->napi);
+	netif_stop_queue(ndev);
+	nps_enet_hw_disable_control(ndev);
+	free_irq(priv->irq, ndev);
+
+	return 0;
+}
+
+/**
+ * nps_enet_start_xmit - Starts the data transmission.
+ * @skb:        sk_buff pointer that contains data to be Transmitted.
+ * @ndev:       Pointer to net_device structure.
+ *
+ * returns: NETDEV_TX_OK, on success
+ *              NETDEV_TX_BUSY, if any of the descriptors are not free.
+ *
+ * This function is invoked from upper layers to initiate transmission.
+ */
+static netdev_tx_t nps_enet_start_xmit(struct sk_buff *skb,
+				       struct net_device *ndev)
+{
+	/* This driver handles one frame at a time  */
+	netif_stop_queue(ndev);
+
+	nps_enet_send_frame(ndev, skb);
+
+	dev_kfree_skb(skb);
+
+	return NETDEV_TX_OK;
+}
+
+#ifdef CONFIG_NET_POLL_CONTROLLER
+static void nps_enet_poll_controller(struct net_device *ndev)
+{
+	disable_irq(ndev->irq);
+	nps_enet_board_irq_handler(ndev->irq, ndev);
+	enable_irq(ndev->irq);
+}
+#endif
+
+static const struct net_device_ops nps_netdev_ops = {
+	.ndo_open		= nps_enet_open,
+	.ndo_stop		= nps_enet_stop,
+	.ndo_start_xmit		= nps_enet_start_xmit,
+	.ndo_set_mac_address	= nps_enet_set_mac_address,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller	= nps_enet_poll_controller,
+#endif
+};
+
+static s32 nps_enet_probe(struct platform_device *pdev)
+{
+	struct device *dev = &pdev->dev;
+	struct net_device *ndev;
+	struct nps_enet_priv *priv;
+	s32 err = 0;
+	const char *mac_addr;
+	struct resource res_regs;
+
+	if (!dev->of_node)
+		return -ENODEV;
+
+	ndev = alloc_etherdev(sizeof(struct nps_enet_priv));
+	if (!ndev)
+		return -ENOMEM;
+
+	platform_set_drvdata(pdev, ndev);
+	SET_NETDEV_DEV(ndev, dev);
+	priv = netdev_priv(ndev);
+
+	/* Get ENET registers base address from device tree */
+	err = of_address_to_resource(dev->of_node, 0, &res_regs);
+	if (err) {
+		dev_err(dev, "failed to retrieve registers base from device tree\n");
+		err = -ENODEV;
+		goto out_netdev;
+	}
+
+	/* The EZ NET specific entries in the device structure. */
+	ndev->netdev_ops = &nps_netdev_ops;
+	ndev->watchdog_timeo = (400 * HZ / 1000);
+	ndev->flags &= ~IFF_MULTICAST;
+
+	priv->regs_base = devm_ioremap_resource(dev, &res_regs);
+	if (IS_ERR(priv->regs_base)) {
+		err = PTR_ERR(priv->regs_base);
+		goto out_netdev;
+	}
+	dev_dbg(dev, "Registers base address is 0x%p\n", priv->regs_base);
+
+	/* set kernel MAC address to dev */
+	mac_addr = of_get_mac_address(dev->of_node);
+	if (mac_addr)
+		ether_addr_copy(ndev->dev_addr, mac_addr);
+	else
+		eth_hw_addr_random(ndev);
+
+	/* Get IRQ number from device tree */
+	priv->irq = irq_of_parse_and_map(dev->of_node, 0);
+	if (!priv->irq) {
+		dev_err(dev, "failed to retrieve <irq Rx-Tx> value from device tree\n");
+		err = -ENODEV;
+		goto out_netdev;
+	}
+
+	netif_napi_add(ndev, &priv->napi, nps_enet_poll, NAPI_POLL_WEIGHT);
+
+	/* Register the driver. Should be the last thing in probe */
+	err = register_netdev(ndev);
+	if (err) {
+		dev_err(dev, "Failed to register ndev for %s, err = 0x%08x\n",
+			ndev->name, (s32)err);
+		err = -ENODEV;
+		goto out_netif_api;
+	}
+
+	dev_info(dev, "(rx/tx=%d)\n", priv->irq);
+
+out_netif_api:
+	netif_napi_del(&priv->napi);
+out_netdev:
+	if (err)
+		free_netdev(ndev);
+
+	return 0;
+}
+
+static s32 nps_enet_remove(struct platform_device *pdev)
+{
+	struct net_device *ndev = platform_get_drvdata(pdev);
+	struct nps_enet_priv *priv = netdev_priv(ndev);
+
+	unregister_netdev(ndev);
+	free_netdev(ndev);
+	netif_napi_del(&priv->napi);
+
+	return 0;
+}
+
+static const struct of_device_id nps_enet_dt_ids[] = {
+	{ .compatible = "ezchip,nps-mgt-enet" },
+	{ /* Sentinel */ }
+};
+
+static struct platform_driver nps_enet_driver = {
+	.probe = nps_enet_probe,
+	.remove = nps_enet_remove,
+	.driver = {
+		.name = DRV_NAME,
+		.of_match_table  = nps_enet_dt_ids,
+	},
+};
+
+module_platform_driver(nps_enet_driver);
+
+MODULE_AUTHOR("EZchip Semiconductor");
+MODULE_LICENSE("GPL v2");
diff --git a/drivers/net/ethernet/ezchip/nps_enet.h b/drivers/net/ethernet/ezchip/nps_enet.h
new file mode 100644
index 0000000..062808b
--- /dev/null
+++ b/drivers/net/ethernet/ezchip/nps_enet.h
@@ -0,0 +1,327 @@
+/*
+ * Copyright(c) 2015 EZchip Technologies.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * The full GNU General Public License is included in this distribution in
+ * the file called "COPYING".
+ */
+
+#ifndef _NPS_ENET_H
+#define _NPS_ENET_H
+
+/* default values */
+#define NPS_ENET_MAX_FRAME_LENGTH		0x3FFF
+#define NPS_ENET_GE_MAC_CFG_0_TX_FC_RETR	0x7
+#define NPS_ENET_GE_MAC_CFG_0_RX_IFG		0x5
+#define NPS_ENET_GE_MAC_CFG_0_TX_IFG		0xC
+#define NPS_ENET_GE_MAC_CFG_0_TX_PR_LEN		0x7
+#define NPS_ENET_GE_MAC_CFG_2_STAT_EN		0x3
+#define NPS_ENET_GE_MAC_CFG_3_RX_IFG_TH		0x14
+#define NPS_ENET_GE_MAC_CFG_3_MAX_LEN		0x3FFC
+#define NPS_ENET_ENABLE				1
+#define NPS_ENET_DISABLE			0
+
+/* register definitions  */
+#define NPS_ENET_REG_TX_CTL		0x800
+#define NPS_ENET_REG_TX_BUF		0x808
+#define NPS_ENET_REG_RX_CTL		0x810
+#define NPS_ENET_REG_RX_BUF		0x818
+#define NPS_ENET_REG_BUF_INT_ENABLE	0x8C0
+#define NPS_ENET_REG_GE_MAC_CFG_0	0x1000
+#define NPS_ENET_REG_GE_MAC_CFG_1	0x1004
+#define NPS_ENET_REG_GE_MAC_CFG_2	0x1008
+#define NPS_ENET_REG_GE_MAC_CFG_3	0x100C
+#define NPS_ENET_REG_GE_RST		0x1400
+#define NPS_ENET_REG_PHASE_FIFO_CTL	0x1404
+
+/* Tx control register */
+struct nps_enet_tx_ctl {
+	union {
+		/* ct: SW sets to indicate frame ready in Tx buffer for
+		 *     transmission. HW resets to when transmission done
+		 * et: Transmit error
+		 * nt: Length in bytes of Tx frame loaded to Tx buffer
+		 */
+		struct {
+			u32
+			__reserved_1:16,
+			ct:1,
+			et:1,
+			__reserved_2:3,
+			nt:11;
+		};
+
+		u32 value;
+	};
+};
+
+/* Rx control register */
+struct nps_enet_rx_ctl {
+	union {
+		/* cr:  HW sets to indicate frame ready in Rx buffer.
+		 *      SW resets to indicate host read received frame
+		 *      and new frames can be written to Rx buffer
+		 * er:  Rx error indication
+		 * crc: Rx CRC error indication
+		 * nr:  Length in bytes of Rx frame loaded by MAC to Rx buffer
+		 */
+		struct {
+			u32
+			__reserved_1:16,
+			cr:1,
+			er:1,
+			crc:1,
+			__reserved_2:2,
+			nr:11;
+		};
+
+		u32 value;
+	};
+};
+
+/* Interrupt enable for data buffer events register */
+struct nps_enet_buf_int_enable {
+	union {
+		/* tx_done: Interrupt generation in the case when new frame
+		 *          is ready in Rx buffer
+		 * rx_rdy:  Interrupt generation in the case when current frame
+		 *          was read from TX buffer
+		 */
+		struct {
+			u32
+			__reserved:30,
+			tx_done:1,
+			rx_rdy:1;
+		};
+
+		u32 value;
+	};
+};
+
+/* Gbps Eth MAC Configuration 0 register */
+struct nps_enet_ge_mac_cfg_0 {
+	union {
+		/* tx_pr_len:          Transmit preamble length in bytes
+		 * tx_ifg_nib:         Tx idle pattern
+		 * nib_mode:           Nibble (4-bit) Mode
+		 * rx_pr_check_en:     Receive preamble Check Enable
+		 * tx_ifg:             Transmit inter-Frame Gap
+		 * rx_ifg:             Receive inter-Frame Gap
+		 * tx_fc_retr:         Transmit Flow Control Retransmit Mode
+		 * rx_length_check_en: Receive Length Check Enable
+		 * rx_crc_ignore:      Results of the CRC check are ignored
+		 * rx_crc_strip:       MAC strips the CRC from received frames
+		 * rx_fc_en:           Receive Flow Control Enable
+		 * tx_crc_en:          Transmit CRC Enabled
+		 * tx_pad_en:          Transmit Padding Enable
+		 * tx_cf_en:           Transmit Flow Control Enable
+		 * tx_en:              Transmit Enable
+		 * rx_en:              Receive Enable
+		 */
+		struct {
+			u32
+			tx_pr_len:4,
+			tx_ifg_nib:4,
+			nib_mode:1,
+			rx_pr_check_en:1,
+			tx_ifg:6,
+			rx_ifg:4,
+			tx_fc_retr:3,
+			rx_length_check_en:1,
+			rx_crc_ignore:1,
+			rx_crc_strip:1,
+			rx_fc_en:1,
+			tx_crc_en:1,
+			tx_pad_en:1,
+			tx_fc_en:1,
+			tx_en:1,
+			rx_en:1;
+		};
+
+		u32 value;
+	};
+};
+
+/* Gbps Eth MAC Configuration 1 register */
+struct nps_enet_ge_mac_cfg_1 {
+	union {
+		/* octet_3: MAC address octet 3
+		 * octet_2: MAC address octet 2
+		 * octet_1: MAC address octet 1
+		 * octet_0: MAC address octet 0
+		 */
+		struct {
+			u32
+			octet_3:8,
+			octet_2:8,
+			octet_1:8,
+			octet_0:8;
+		};
+
+		u32 value;
+	};
+};
+
+/* Gbps Eth MAC Configuration 2 register */
+struct nps_enet_ge_mac_cfg_2 {
+	union {
+		/* transmit_flush_en: MAC flush enable
+		 * stat_en:           RMON statistics interface enable
+		 * disc_da:           Discard frames with DA different
+		 *                    from MAC address
+		 * disc_bc:           Discard broadcast frames
+		 * disc_mc:           Discard multicast frames
+		 * octet_5:           MAC address octet 5
+		 * octet_4:           MAC address octet 4
+		 */
+		struct {
+			u32
+			transmit_flush_en:1,
+			__reserved_1:5,
+			stat_en:2,
+			__reserved_2:1,
+			disc_da:1,
+			disc_bc:1,
+			disc_mc:1,
+			__reserved_3:4,
+			octet_5:8,
+			octet_4:8;
+		};
+
+		u32 value;
+	};
+};
+
+/* Gbps Eth MAC Configuration 3 register */
+struct nps_enet_ge_mac_cfg_3 {
+	union {
+		/* ext_oob_cbfc_sel:  Selects one of the 4 profiles for
+		 *                    extended OOB in-flow-control indication
+		 * max_len:           Maximum receive frame length in bytes
+		 * tx_cbfc_en:        Enable transmission of class-based
+		 *                    flow control packets
+		 * rx_ifg_th:         Threshold for IFG status reporting via OOB
+		 * cf_timeout:        Configurable time to decrement FC counters
+		 * cf_drop:           Drop control frames
+		 * redirect_cbfc_sel: Selects one of CBFC redirect profiles
+		 * rx_cbfc_redir_en:  Enable Rx class-based flow
+		 *                    control redirect
+		 * rx_cbfc_en:        Enable Rx class-based flow control
+		 * tm_hd_mode:        TM header mode
+		 */
+		struct {
+			u32
+			ext_oob_cbfc_sel:2,
+			max_len:14,
+			tx_cbfc_en:1,
+			rx_ifg_th:5,
+			cf_timeout:4,
+			cf_drop:1,
+			redirect_cbfc_sel:2,
+			rx_cbfc_redir_en:1,
+			rx_cbfc_en:1,
+			tm_hd_mode:1;
+		};
+
+		u32 value;
+	};
+};
+
+/* GE MAC, PCS reset control register */
+struct nps_enet_ge_rst {
+	union {
+		/* gmac_0: GE MAC reset
+		 * spcs_0: SGMII PCS reset
+		 */
+		struct {
+			u32
+			__reserved_1:23,
+			gmac_0:1,
+			__reserved_2:7,
+			spcs_0:1;
+		};
+
+		u32 value;
+	};
+};
+
+/* Tx phase sync FIFO control register */
+struct nps_enet_phase_fifo_ctl {
+	union {
+		/* init: initialize serdes TX phase sync FIFO pointers
+		 * rst:  reset serdes TX phase sync FIFO
+		 */
+		struct {
+			u32
+			__reserved:30,
+			init:1,
+			rst:1;
+		};
+
+		u32 value;
+	};
+};
+
+/**
+ * struct nps_enet_irq_data - Storage of data to pass from HW to SW IRQ context.
+ * @skb:            skb of received frame that need to be passed to net stack
+ * @rx_ctrl:        RX control for frame pointed by skb
+ * @tx_ctrl:        TX control
+ */
+struct nps_enet_irq_data {
+	struct sk_buff *skb;
+	struct nps_enet_rx_ctl rx_ctrl;
+	struct nps_enet_tx_ctl tx_ctrl;
+};
+
+/**
+ * struct nps_enet_priv - Storage of ENET's private information.
+ * @regs_base:      Base address of ENET memory-mapped control registers.
+ * @irq:            For RX/TX IRQ number.
+ * @tx_packet_sent: SW indication if frame is being sent
+ * @irq_data:       Data for RX/TX softirq handling
+ * @napi:           Structure for NAPI.
+ */
+struct nps_enet_priv {
+	void __iomem *regs_base;
+	s32 irq;
+	bool tx_packet_sent;
+	struct nps_enet_irq_data irq_data;
+	struct napi_struct napi;
+	struct nps_enet_ge_mac_cfg_2 ge_mac_cfg_2;
+	struct nps_enet_ge_mac_cfg_3 ge_mac_cfg_3;
+};
+
+/**
+ * nps_reg_set - Sets ENET register with provided value.
+ * @priv:       Pointer to EZchip ENET private data structure.
+ * @reg:        Register offset from base address.
+ * @value:      Value to set in register.
+ */
+static inline void nps_enet_reg_set(struct nps_enet_priv *priv,
+				    s32 reg, s32 value)
+{
+	iowrite32be(value, priv->regs_base + reg);
+}
+
+/**
+ * nps_reg_get - Gets value of specified ENET register.
+ * @priv:       Pointer to EZchip ENET private data structure.
+ * @reg:        Register offset from base address.
+ *
+ * returns:     Value of requested register.
+ */
+static inline u32 nps_enet_reg_get(struct nps_enet_priv *priv, s32 reg)
+{
+	return ioread32be(priv->regs_base + reg);
+}
+
+#endif /* _NPS_ENET_H */
-- 
1.7.1
