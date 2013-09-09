From: Benedikt Spranger <b.spranger@linutronix.de>
Subject: [PATCH 01/16] c_can_platform: add FlexCard D-CAN support
Date: Mon,  9 Sep 2013 09:24:58 +0200
Message-ID: <1378711513-2548-2-git-send-email-b.spranger@linutronix.de>
References: <1378711513-2548-1-git-send-email-b.spranger@linutronix.de>
Cc: Alexander Frank <Alexander.Frank@eberspaecher.com>,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
	Holger Dengler <dengler@linutronix.de>,
	Benedikt Spranger <b.spranger@linutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.linutronix.de ([62.245.132.108]:37917 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751161Ab3IIHZb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Sep 2013 03:25:31 -0400
In-Reply-To: <1378711513-2548-1-git-send-email-b.spranger@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

FlexCard supports up to 8 D-CAN devices with a shared DMA-capable receive
function. Add support for FlexCard D-CAN.

Signed-off-by: Benedikt Spranger <b.spranger@linutronix.de>
---
 drivers/net/can/c_can/c_can.h          |   1 +
 drivers/net/can/c_can/c_can_platform.c | 149 ++++++++++++++++++++++++++++++++-
 2 files changed, 148 insertions(+), 2 deletions(-)

diff --git a/drivers/net/can/c_can/c_can.h b/drivers/net/can/c_can/c_can.h
index d2e1c21..d2e2d20 100644
--- a/drivers/net/can/c_can/c_can.h
+++ b/drivers/net/can/c_can/c_can.h
@@ -148,6 +148,7 @@ enum c_can_dev_id {
 	BOSCH_C_CAN_PLATFORM,
 	BOSCH_C_CAN,
 	BOSCH_D_CAN,
+	BOSCH_D_CAN_FLEXCARD,
 };
 
 /* c_can private data structure */
diff --git a/drivers/net/can/c_can/c_can_platform.c b/drivers/net/can/c_can/c_can_platform.c
index c6f838d..43a3e3f 100644
--- a/drivers/net/can/c_can/c_can_platform.c
+++ b/drivers/net/can/c_can/c_can_platform.c
@@ -32,6 +32,7 @@
 #include <linux/clk.h>
 #include <linux/of.h>
 #include <linux/of_device.h>
+#include <linux/flexcard.h>
 
 #include <linux/can/dev.h>
 
@@ -81,6 +82,112 @@ static void c_can_hw_raminit(const struct c_can_priv *priv, bool enable)
 	writel(val, priv->raminit_ctrlreg);
 }
 
+static int c_can_rx_pkt(void *p, void *data, size_t len)
+{
+	struct net_device *dev = p;
+	struct net_device_stats *stats = &dev->stats;
+	struct fc_packet_buf *pb = data;
+	union fc_packet_types *pt = &pb->packet;
+	struct can_frame *frame;
+	struct sk_buff *skb;
+	u32 flags, id, state, type;
+
+	switch (le32_to_cpu(pb->header.type)) {
+	case fc_packet_type_can:
+		skb = alloc_can_skb(dev, &frame);
+		if (!skb) {
+			stats->rx_dropped++;
+			return -ENOMEM;
+		}
+
+		id = le32_to_cpu(pt->can_packet.id);
+		flags = le32_to_cpu(pt->can_packet.flags);
+
+		if (id & BIT(29))
+			frame->can_id = (id & CAN_EFF_MASK) | CAN_EFF_FLAG;
+		else
+			frame->can_id = id & CAN_SFF_MASK;
+
+		if (flags & BIT(13))
+			frame->can_id |= CAN_RTR_FLAG;
+		frame->can_dlc = (flags >> 8) & 0xf;
+		memcpy(frame->data, pt->can_packet.data, frame->can_dlc);
+		netif_receive_skb(skb);
+
+		stats->rx_packets++;
+		stats->rx_bytes += frame->can_dlc;
+		break;
+
+	case fc_packet_type_can_error:
+		stats->rx_errors++;
+
+		skb = alloc_can_err_skb(dev, &frame);
+		if (!skb)
+			return -ENOMEM;
+
+		type = le32_to_cpu(pt->can_error_packet.type);
+		state = le32_to_cpu(pt->can_error_packet.state);
+
+		switch (state) {
+		case fc_can_state_warning:
+			frame->data[1] |= CAN_ERR_CRTL_RX_WARNING;
+			frame->data[1] |= CAN_ERR_CRTL_TX_WARNING;
+			frame->can_id |= CAN_ERR_CRTL;
+			break;
+		case fc_can_state_error_passive:
+			frame->data[1] |= CAN_ERR_CRTL_RX_PASSIVE;
+			frame->data[1] |= CAN_ERR_CRTL_TX_PASSIVE;
+			frame->can_id |= CAN_ERR_CRTL;
+			break;
+		case fc_can_state_bus_off:
+			frame->can_id |= CAN_ERR_BUSOFF;
+			break;
+		}
+
+		switch (type) {
+		case fc_can_error_stuff:
+			frame->data[2] |= CAN_ERR_PROT_STUFF;
+			frame->can_id |= CAN_ERR_PROT;
+			break;
+		case fc_can_error_form:
+			frame->data[2] |= CAN_ERR_PROT_FORM;
+			frame->can_id |= CAN_ERR_PROT;
+			break;
+		case fc_can_error_acknowledge:
+			frame->can_id |= CAN_ERR_ACK;
+			break;
+		case fc_can_error_bit1:
+			frame->data[2] |= CAN_ERR_PROT_BIT1;
+			frame->can_id |= CAN_ERR_PROT;
+			break;
+		case fc_can_error_bit0:
+			frame->data[2] |= CAN_ERR_PROT_BIT0;
+			frame->can_id |= CAN_ERR_PROT;
+			break;
+		case fc_can_error_crc:
+			frame->data[3] |= CAN_ERR_PROT_LOC_CRC_SEQ;
+			frame->can_id |= CAN_ERR_PROT;
+			break;
+		case fc_can_error_parity:
+			frame->data[1] |= CAN_ERR_PROT_UNSPEC;
+			frame->can_id |= CAN_ERR_CRTL;
+			break;
+		}
+		frame->data[5] = pt->can_error_packet.rx_error_counter;
+		frame->data[6] = pt->can_error_packet.tx_error_counter;
+
+		stats->rx_bytes += frame->can_dlc;
+		stats->rx_packets++;
+
+		netif_receive_skb(skb);
+		break;
+	default:
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
 static struct platform_device_id c_can_id_table[] = {
 	[BOSCH_C_CAN_PLATFORM] = {
 		.name = KBUILD_MODNAME,
@@ -93,6 +200,10 @@ static struct platform_device_id c_can_id_table[] = {
 	[BOSCH_D_CAN] = {
 		.name = "d_can",
 		.driver_data = BOSCH_D_CAN,
+	},
+	[BOSCH_D_CAN_FLEXCARD] = {
+		.name = "flexcard-d_can",
+		.driver_data = BOSCH_D_CAN_FLEXCARD,
 	}, {
 	}
 };
@@ -108,7 +219,7 @@ MODULE_DEVICE_TABLE(of, c_can_of_table);
 static int c_can_plat_probe(struct platform_device *pdev)
 {
 	int ret;
-	void __iomem *addr;
+	void __iomem *addr, *reset_reg;
 	struct net_device *dev;
 	struct c_can_priv *priv;
 	const struct of_device_id *match;
@@ -167,6 +278,8 @@ static int c_can_plat_probe(struct platform_device *pdev)
 	}
 
 	priv = netdev_priv(dev);
+	priv->can.clock.freq = clk_get_rate(clk);
+
 	switch (id->driver_data) {
 	case BOSCH_C_CAN:
 		priv->regs = reg_map_c_can;
@@ -199,7 +312,26 @@ static int c_can_plat_probe(struct platform_device *pdev)
 			dev_info(&pdev->dev, "control memory is not used for raminit\n");
 		else
 			priv->raminit = c_can_hw_raminit;
+
 		break;
+	case BOSCH_D_CAN_FLEXCARD:
+		priv->regs = reg_map_d_can;
+		priv->can.ctrlmode_supported |= CAN_CTRLMODE_3_SAMPLES;
+		priv->read_reg = c_can_plat_read_reg_aligned_to_16bit;
+		priv->write_reg = c_can_plat_write_reg_aligned_to_16bit;
+		priv->instance = pdev->id;
+
+		res = platform_get_resource(pdev, IORESOURCE_MEM, 1);
+		reset_reg = ioremap(res->start, resource_size(res));
+		if (!reset_reg || priv->instance < 0) {
+			dev_info(&pdev->dev, "Can't reset device.\n");
+		} else {
+			writel(1 << (4 + priv->instance), addr);
+			udelay(100);
+		}
+		iounmap(reset_reg);
+		priv->can.clock.freq = 16000000;
+
 	default:
 		ret = -EINVAL;
 		goto exit_free_device;
@@ -208,7 +340,6 @@ static int c_can_plat_probe(struct platform_device *pdev)
 	dev->irq = irq;
 	priv->base = addr;
 	priv->device = &pdev->dev;
-	priv->can.clock.freq = clk_get_rate(clk);
 	priv->priv = clk;
 	priv->type = id->driver_data;
 
@@ -222,10 +353,22 @@ static int c_can_plat_probe(struct platform_device *pdev)
 		goto exit_free_device;
 	}
 
+	if (id->driver_data == BOSCH_D_CAN_FLEXCARD) {
+		ret = fc_register_rx_pkt(FC_CANIF_OFFSET + pdev->id,
+				dev, c_can_rx_pkt);
+		if (ret) {
+			dev_err(&pdev->dev,
+					"registering RX-CB failed %d\n", ret);
+			goto exit_unregister_device;
+		}
+	}
+
 	dev_info(&pdev->dev, "%s device registered (regs=%p, irq=%d)\n",
 		 KBUILD_MODNAME, priv->base, dev->irq);
 	return 0;
 
+exit_unregister_device:
+	unregister_c_can_dev(dev);
 exit_free_device:
 	free_c_can_dev(dev);
 exit_iounmap:
@@ -246,6 +389,8 @@ static int c_can_plat_remove(struct platform_device *pdev)
 	struct c_can_priv *priv = netdev_priv(dev);
 	struct resource *mem;
 
+	if (priv->type == BOSCH_D_CAN_FLEXCARD)
+		fc_unregister_rx_pkt(FC_CANIF_OFFSET + priv->instance);
 	unregister_c_can_dev(dev);
 
 	free_c_can_dev(dev);
-- 
1.8.4.rc3
