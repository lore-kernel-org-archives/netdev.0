From: Richard =?ISO-8859-1?Q?R=F6jfors?=
	<richard.rojfors@pelagicore.com>
Subject: [PATCH v2] ks8842: Support DMA when accessed via timberdale
Date: Wed, 28 Jul 2010 00:57:01 +0200
Message-ID: <1280271421.11916.2.camel@debian>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-gw11.han.skanova.net ([81.236.55.20]:55240 "EHLO
	smtp-gw11.han.skanova.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753834Ab0G0W5H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jul 2010 18:57:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for RX and TX DMA via the DMA API,
this is only supported when the KS8842 is accessed via timberdale.

There is no support for DMA on the generic bus interface it self,
a state machine inside the FPGA is handling RX and TX transfers to/from
buffers in the FPGA. The host CPU can do DMA to and from these buffers.

The FPGA has to handle the RX interrupts, so these must be enabled in
the ks8842 but not in the FPGA. The driver must not disable the RX inte=
rrupt
that would mean that the data transfers into the FPGA buffers would sto=
p.

The host shall not enable TX interrupts since TX is handled by the FPGA=
,
the host is notified by DMA callbacks when transfers are finished.

Which DMA channels to use are added as parameters in the platform data =
struct.

Signed-off-by: Richard R=C3=B6jfors <richard.rojfors@pelagicore.com>
---
diff --git a/drivers/net/ks8842.c b/drivers/net/ks8842.c
index 289b0be..3fe38c7 100644
--- a/drivers/net/ks8842.c
+++ b/drivers/net/ks8842.c
@@ -30,6 +30,9 @@
 #include <linux/etherdevice.h>
 #include <linux/ethtool.h>
 #include <linux/ks8842.h>
+#include <linux/dmaengine.h>
+#include <linux/dma-mapping.h>
+#include <linux/scatterlist.h>
=20
 #define DRV_NAME "ks8842"
=20
@@ -82,6 +85,15 @@
 #define IRQ_RX_ERROR	0x0080
 #define ENABLED_IRQS	(IRQ_LINK_CHANGE | IRQ_TX | IRQ_RX | IRQ_RX_STOPP=
ED | \
 		IRQ_TX_STOPPED | IRQ_RX_OVERRUN | IRQ_RX_ERROR)
+/* When running via timberdale in DMA mode, the RX interrupt should be
+   enabled in the KS8842, but not in the FPGA IP, since the IP handles
+   RX DMA internally.
+   TX interrupts are not needed it is handled by the FPGA the driver i=
s
+   notified via DMA callbacks.
+*/
+#define ENABLED_IRQS_DMA_IP	(IRQ_LINK_CHANGE | IRQ_RX_STOPPED | \
+	IRQ_TX_STOPPED | IRQ_RX_OVERRUN | IRQ_RX_ERROR)
+#define ENABLED_IRQS_DMA	(ENABLED_IRQS_DMA_IP | IRQ_RX)
 #define REG_ISR		0x02
 #define REG_RXSR	0x04
 #define RXSR_VALID	0x8000
@@ -124,6 +136,28 @@
 #define	MICREL_KS884X		0x01	/* 0=3DTimeberdale(FPGA), 1=3DMicrel */
 #define	KS884X_16BIT		0x02	/*  1=3D16bit, 0=3D32bit */
=20
+#define DMA_BUFFER_SIZE		2048
+
+struct ks8842_tx_dma_ctl {
+	struct dma_chan *chan;
+	struct dma_async_tx_descriptor *adesc;
+	void *buf;
+	struct scatterlist sg;
+	int channel;
+};
+
+struct ks8842_rx_dma_ctl {
+	struct dma_chan *chan;
+	struct dma_async_tx_descriptor *adesc;
+	struct sk_buff  *skb;
+	struct scatterlist sg;
+	struct tasklet_struct tasklet;
+	int channel;
+};
+
+#define KS8842_USE_DMA(adapter) (((adapter)->dma_tx.channel !=3D -1) &=
& \
+	 ((adapter)->dma_rx.channel !=3D -1))
+
 struct ks8842_adapter {
 	void __iomem	*hw_addr;
 	int		irq;
@@ -132,8 +166,19 @@ struct ks8842_adapter {
 	spinlock_t	lock; /* spinlock to be interrupt safe */
 	struct work_struct timeout_work;
 	struct net_device *netdev;
+	struct device *dev;
+	struct ks8842_tx_dma_ctl	dma_tx;
+	struct ks8842_rx_dma_ctl	dma_rx;
 };
=20
+static void ks8842_dma_rx_cb(void *data);
+static void ks8842_dma_tx_cb(void *data);
+
+static inline void ks8842_resume_dma(struct ks8842_adapter *adapter)
+{
+	iowrite32(1, adapter->hw_addr + REQ_TIMB_DMA_RESUME);
+}
+
 static inline void ks8842_select_bank(struct ks8842_adapter *adapter, =
u16 bank)
 {
 	iowrite16(bank, adapter->hw_addr + REG_SELECT_BANK);
@@ -297,8 +342,19 @@ static void ks8842_reset_hw(struct ks8842_adapter =
*adapter)
 	ks8842_write16(adapter, 18, 0xffff, REG_ISR);
=20
 	/* enable interrupts */
-	ks8842_write16(adapter, 18, ENABLED_IRQS, REG_IER);
-
+	if (KS8842_USE_DMA(adapter)) {
+		/* When running in DMA Mode the RX interrupt is not enabled in
+		   timberdale because RX data is received by DMA callbacks
+		   it must still be enabled in the KS8842 because it indicates
+		   to timberdale when there is RX data for it's DMA FIFOs */
+		iowrite16(ENABLED_IRQS_DMA_IP, adapter->hw_addr + REG_TIMB_IER);
+		ks8842_write16(adapter, 18, ENABLED_IRQS_DMA, REG_IER);
+	} else {
+		if (!(adapter->conf_flags & MICREL_KS884X))
+			iowrite16(ENABLED_IRQS,
+				adapter->hw_addr + REG_TIMB_IER);
+		ks8842_write16(adapter, 18, ENABLED_IRQS, REG_IER);
+	}
 	/* enable the switch */
 	ks8842_write16(adapter, 32, 0x1, REG_SW_ID_AND_ENABLE);
 }
@@ -371,6 +427,53 @@ static inline u16 ks8842_tx_fifo_space(struct ks88=
42_adapter *adapter)
 	return ks8842_read16(adapter, 16, REG_TXMIR) & 0x1fff;
 }
=20
+static int ks8842_tx_frame_dma(struct sk_buff *skb, struct net_device =
*netdev)
+{
+	struct ks8842_adapter *adapter =3D netdev_priv(netdev);
+	struct ks8842_tx_dma_ctl *ctl =3D &adapter->dma_tx;
+	u8 *buf =3D ctl->buf;
+
+	if (ctl->adesc) {
+		netdev_dbg(netdev, "%s: TX ongoing\n", __func__);
+		/* transfer ongoing */
+		return NETDEV_TX_BUSY;
+	}
+
+	sg_dma_len(&ctl->sg) =3D skb->len + sizeof(u32);
+
+	/* copy data to the TX buffer */
+	/* the control word, enable IRQ, port 1 and the length */
+	*buf++ =3D 0x00;
+	*buf++ =3D 0x01; /* Port 1 */
+	*buf++ =3D skb->len & 0xff;
+	*buf++ =3D (skb->len >> 8) & 0xff;
+	skb_copy_from_linear_data(skb, buf, skb->len);
+
+	dma_sync_single_range_for_device(adapter->dev,
+		sg_dma_address(&ctl->sg), 0, sg_dma_len(&ctl->sg),
+		DMA_TO_DEVICE);
+
+	/* make sure the length is a multiple of 4 */
+	if (sg_dma_len(&ctl->sg) % 4)
+		sg_dma_len(&ctl->sg) +=3D 4 - sg_dma_len(&ctl->sg) % 4;
+
+	ctl->adesc =3D ctl->chan->device->device_prep_slave_sg(ctl->chan,
+		&ctl->sg, 1, DMA_TO_DEVICE,
+		DMA_PREP_INTERRUPT | DMA_COMPL_SKIP_SRC_UNMAP);
+	if (!ctl->adesc)
+		return NETDEV_TX_BUSY;
+
+	ctl->adesc->callback_param =3D netdev;
+	ctl->adesc->callback =3D ks8842_dma_tx_cb;
+	ctl->adesc->tx_submit(ctl->adesc);
+
+	netdev->stats.tx_bytes +=3D skb->len;
+
+	dev_kfree_skb(skb);
+
+	return NETDEV_TX_OK;
+}
+
 static int ks8842_tx_frame(struct sk_buff *skb, struct net_device *net=
dev)
 {
 	struct ks8842_adapter *adapter =3D netdev_priv(netdev);
@@ -422,6 +525,121 @@ static int ks8842_tx_frame(struct sk_buff *skb, s=
truct net_device *netdev)
 	return NETDEV_TX_OK;
 }
=20
+static void ks8842_update_rx_err_counters(struct net_device *netdev, u=
32 status)
+{
+	netdev_dbg(netdev, "RX error, status: %x\n", status);
+
+	netdev->stats.rx_errors++;
+	if (status & RXSR_TOO_LONG)
+		netdev->stats.rx_length_errors++;
+	if (status & RXSR_CRC_ERROR)
+		netdev->stats.rx_crc_errors++;
+	if (status & RXSR_RUNT)
+		netdev->stats.rx_frame_errors++;
+}
+
+static void ks8842_update_rx_counters(struct net_device *netdev, u32 s=
tatus,
+	int len)
+{
+	netdev_dbg(netdev, "RX packet, len: %d\n", len);
+
+	netdev->stats.rx_packets++;
+	netdev->stats.rx_bytes +=3D len;
+	if (status & RXSR_MULTICAST)
+		netdev->stats.multicast++;
+}
+
+static int __ks8842_start_new_rx_dma(struct net_device *netdev)
+{
+	struct ks8842_adapter *adapter =3D netdev_priv(netdev);
+	struct ks8842_rx_dma_ctl *ctl =3D &adapter->dma_rx;
+	struct scatterlist *sg =3D &ctl->sg;
+	int err;
+
+	ctl->skb =3D netdev_alloc_skb(netdev, DMA_BUFFER_SIZE);
+	if (ctl->skb) {
+		sg_init_table(sg, 1);
+		sg_dma_address(sg) =3D dma_map_single(adapter->dev,
+			ctl->skb->data, DMA_BUFFER_SIZE, DMA_FROM_DEVICE);
+		err =3D dma_mapping_error(adapter->dev, sg_dma_address(sg));
+		if (unlikely(err)) {
+			sg_dma_address(sg) =3D 0;
+			goto out;
+		}
+
+		sg_dma_len(sg) =3D DMA_BUFFER_SIZE;
+
+		ctl->adesc =3D ctl->chan->device->device_prep_slave_sg(ctl->chan,
+			sg, 1, DMA_FROM_DEVICE,
+			DMA_PREP_INTERRUPT | DMA_COMPL_SKIP_SRC_UNMAP);
+
+		if (!ctl->adesc)
+			goto out;
+
+		ctl->adesc->callback_param =3D netdev;
+		ctl->adesc->callback =3D ks8842_dma_rx_cb;
+		ctl->adesc->tx_submit(ctl->adesc);
+	} else {
+		err =3D -ENOMEM;
+		sg_dma_address(sg) =3D 0;
+		goto out;
+	}
+
+	return err;
+out:
+	if (sg_dma_address(sg))
+		dma_unmap_single(adapter->dev, sg_dma_address(sg),
+			DMA_BUFFER_SIZE, DMA_FROM_DEVICE);
+	sg_dma_address(sg) =3D 0;
+	if (ctl->skb)
+		dev_kfree_skb(ctl->skb);
+
+	ctl->skb =3D NULL;
+
+	printk(KERN_ERR DRV_NAME": Failed to start RX DMA: %d\n", err);
+	return err;
+}
+
+static void ks8842_rx_frame_dma_tasklet(unsigned long arg)
+{
+	struct net_device *netdev =3D (struct net_device *)arg;
+	struct ks8842_adapter *adapter =3D netdev_priv(netdev);
+	struct ks8842_rx_dma_ctl *ctl =3D &adapter->dma_rx;
+	struct sk_buff *skb =3D ctl->skb;
+	dma_addr_t addr =3D sg_dma_address(&ctl->sg);
+	u32 status;
+
+	ctl->adesc =3D NULL;
+
+	/* kick next transfer going */
+	__ks8842_start_new_rx_dma(netdev);
+
+	/* now handle the data we got */
+	dma_unmap_single(adapter->dev, addr, DMA_BUFFER_SIZE, DMA_FROM_DEVICE=
);
+
+	status =3D *((u32 *)skb->data);
+
+	netdev_dbg(netdev, "%s - rx_data: status: %x\n",
+		__func__, status & 0xffff);
+
+	/* check the status */
+	if ((status & RXSR_VALID) && !(status & RXSR_ERROR)) {
+		int len =3D (status >> 16) & 0x7ff;
+
+		ks8842_update_rx_counters(netdev, status, len);
+
+		/* reserve 4 bytes which is the status word */
+		skb_reserve(skb, 4);
+		skb_put(skb, len);
+
+		skb->protocol =3D eth_type_trans(skb, netdev);
+		netif_rx(skb);
+	} else {
+		ks8842_update_rx_err_counters(netdev, status);
+		dev_kfree_skb(skb);
+	}
+}
+
 static void ks8842_rx_frame(struct net_device *netdev,
 	struct ks8842_adapter *adapter)
 {
@@ -445,13 +663,9 @@ static void ks8842_rx_frame(struct net_device *net=
dev,
 	if ((status & RXSR_VALID) && !(status & RXSR_ERROR)) {
 		struct sk_buff *skb =3D netdev_alloc_skb_ip_align(netdev, len);
=20
-		netdev_dbg(netdev, "%s, got package, len: %d\n", __func__, len);
 		if (skb) {
=20
-			netdev->stats.rx_packets++;
-			netdev->stats.rx_bytes +=3D len;
-			if (status & RXSR_MULTICAST)
-				netdev->stats.multicast++;
+			ks8842_update_rx_counters(netdev, status, len);
=20
 			if (adapter->conf_flags & KS884X_16BIT) {
 				u16 *data16 =3D (u16 *)skb_put(skb, len);
@@ -477,16 +691,8 @@ static void ks8842_rx_frame(struct net_device *net=
dev,
 			netif_rx(skb);
 		} else
 			netdev->stats.rx_dropped++;
-	} else {
-		netdev_dbg(netdev, "RX error, status: %x\n", status);
-		netdev->stats.rx_errors++;
-		if (status & RXSR_TOO_LONG)
-			netdev->stats.rx_length_errors++;
-		if (status & RXSR_CRC_ERROR)
-			netdev->stats.rx_crc_errors++;
-		if (status & RXSR_RUNT)
-			netdev->stats.rx_frame_errors++;
-	}
+	} else
+		ks8842_update_rx_err_counters(netdev, status);
=20
 	/* set high watermark to 3K */
 	ks8842_clear_bits(adapter, 0, 1 << 12, REG_QRFCR);
@@ -541,6 +747,12 @@ void ks8842_tasklet(unsigned long arg)
 	isr =3D ks8842_read16(adapter, 18, REG_ISR);
 	netdev_dbg(netdev, "%s - ISR: 0x%x\n", __func__, isr);
=20
+	/* when running in DMA mode, do not ack RX interrupts, it is handled
+	   internally by timberdale, otherwise it's DMA FIFO:s would stop
+	*/
+	if (KS8842_USE_DMA(adapter))
+		isr &=3D ~IRQ_RX;
+
 	/* Ack */
 	ks8842_write16(adapter, 18, isr, REG_ISR);
=20
@@ -554,9 +766,11 @@ void ks8842_tasklet(unsigned long arg)
 	if (isr & IRQ_LINK_CHANGE)
 		ks8842_update_link_status(netdev, adapter);
=20
-	if (isr & (IRQ_RX | IRQ_RX_ERROR))
+	/* should not get IRQ_RX when running DMA mode */
+	if (isr & (IRQ_RX | IRQ_RX_ERROR) && !KS8842_USE_DMA(adapter))
 		ks8842_handle_rx(netdev, adapter);
=20
+	/* should only happen when in PIO mode */
 	if (isr & IRQ_TX)
 		ks8842_handle_tx(netdev, adapter);
=20
@@ -575,8 +789,17 @@ void ks8842_tasklet(unsigned long arg)
=20
 	/* re-enable interrupts, put back the bank selection register */
 	spin_lock_irqsave(&adapter->lock, flags);
-	ks8842_write16(adapter, 18, ENABLED_IRQS, REG_IER);
+	if (KS8842_USE_DMA(adapter))
+		ks8842_write16(adapter, 18, ENABLED_IRQS_DMA, REG_IER);
+	else
+		ks8842_write16(adapter, 18, ENABLED_IRQS, REG_IER);
 	iowrite16(entry_bank, adapter->hw_addr + REG_SELECT_BANK);
+
+	/* Make sure timberdale continues DMA operations, they are stopped wh=
ile
+	   we are handling the ks8842 because we might change bank */
+	if (KS8842_USE_DMA(adapter))
+		ks8842_resume_dma(adapter);
+
 	spin_unlock_irqrestore(&adapter->lock, flags);
 }
=20
@@ -592,8 +815,12 @@ static irqreturn_t ks8842_irq(int irq, void *devid=
)
 	netdev_dbg(netdev, "%s - ISR: 0x%x\n", __func__, isr);
=20
 	if (isr) {
-		/* disable IRQ */
-		ks8842_write16(adapter, 18, 0x00, REG_IER);
+		if (KS8842_USE_DMA(adapter))
+			/* disable all but RX IRQ, since the FPGA relies on it*/
+			ks8842_write16(adapter, 18, IRQ_RX, REG_IER);
+		else
+			/* disable IRQ */
+			ks8842_write16(adapter, 18, 0x00, REG_IER);
=20
 		/* schedule tasklet */
 		tasklet_schedule(&adapter->tasklet);
@@ -603,9 +830,151 @@ static irqreturn_t ks8842_irq(int irq, void *devi=
d)
=20
 	iowrite16(entry_bank, adapter->hw_addr + REG_SELECT_BANK);
=20
+	/* After an interrupt, tell timberdale to continue DMA operations.
+	   DMA is disabled while we are handling the ks8842 because we might
+	   change bank */
+	ks8842_resume_dma(adapter);
+
 	return ret;
 }
=20
+static void ks8842_dma_rx_cb(void *data)
+{
+	struct net_device	*netdev =3D data;
+	struct ks8842_adapter	*adapter =3D netdev_priv(netdev);
+
+	netdev_dbg(netdev, "RX DMA finished\n");
+	/* schedule tasklet */
+	if (adapter->dma_rx.adesc)
+		tasklet_schedule(&adapter->dma_rx.tasklet);
+}
+
+static void ks8842_dma_tx_cb(void *data)
+{
+	struct net_device		*netdev =3D data;
+	struct ks8842_adapter		*adapter =3D netdev_priv(netdev);
+	struct ks8842_tx_dma_ctl	*ctl =3D &adapter->dma_tx;
+
+	netdev_dbg(netdev, "TX DMA finished\n");
+
+	if (!ctl->adesc)
+		return;
+
+	netdev->stats.tx_packets++;
+	ctl->adesc =3D NULL;
+
+	if (netif_queue_stopped(netdev))
+		netif_wake_queue(netdev);
+}
+
+static void ks8842_stop_dma(struct ks8842_adapter *adapter)
+{
+	struct ks8842_tx_dma_ctl *tx_ctl =3D &adapter->dma_tx;
+	struct ks8842_rx_dma_ctl *rx_ctl =3D &adapter->dma_rx;
+
+	tx_ctl->adesc =3D NULL;
+	if (tx_ctl->chan)
+		tx_ctl->chan->device->device_control(tx_ctl->chan,
+			DMA_TERMINATE_ALL, 0);
+
+	rx_ctl->adesc =3D NULL;
+	if (rx_ctl->chan)
+		rx_ctl->chan->device->device_control(rx_ctl->chan,
+			DMA_TERMINATE_ALL, 0);
+
+	if (sg_dma_address(&rx_ctl->sg))
+		dma_unmap_single(adapter->dev, sg_dma_address(&rx_ctl->sg),
+			DMA_BUFFER_SIZE, DMA_FROM_DEVICE);
+	sg_dma_address(&rx_ctl->sg) =3D 0;
+
+	dev_kfree_skb(rx_ctl->skb);
+	rx_ctl->skb =3D NULL;
+}
+
+static void ks8842_dealloc_dma_bufs(struct ks8842_adapter *adapter)
+{
+	struct ks8842_tx_dma_ctl *tx_ctl =3D &adapter->dma_tx;
+	struct ks8842_rx_dma_ctl *rx_ctl =3D &adapter->dma_rx;
+
+	ks8842_stop_dma(adapter);
+
+	if (tx_ctl->chan)
+		dma_release_channel(tx_ctl->chan);
+	tx_ctl->chan =3D NULL;
+
+	if (rx_ctl->chan)
+		dma_release_channel(rx_ctl->chan);
+	rx_ctl->chan =3D NULL;
+
+	tasklet_kill(&rx_ctl->tasklet);
+
+	if (sg_dma_address(&tx_ctl->sg))
+		dma_unmap_single(adapter->dev, sg_dma_address(&tx_ctl->sg),
+			DMA_BUFFER_SIZE, DMA_TO_DEVICE);
+	sg_dma_address(&tx_ctl->sg) =3D 0;
+
+	kfree(tx_ctl->buf);
+	tx_ctl->buf =3D NULL;
+}
+
+static bool ks8842_dma_filter_fn(struct dma_chan *chan, void *filter_p=
aram)
+{
+	return chan->chan_id =3D=3D (int)filter_param;
+}
+
+static int ks8842_alloc_dma_bufs(struct net_device *netdev)
+{
+	struct ks8842_adapter *adapter =3D netdev_priv(netdev);
+	struct ks8842_tx_dma_ctl *tx_ctl =3D &adapter->dma_tx;
+	struct ks8842_rx_dma_ctl *rx_ctl =3D &adapter->dma_rx;
+	int err;
+
+	dma_cap_mask_t mask;
+
+	dma_cap_zero(mask);
+	dma_cap_set(DMA_SLAVE, mask);
+	dma_cap_set(DMA_PRIVATE, mask);
+
+	sg_init_table(&tx_ctl->sg, 1);
+
+	tx_ctl->chan =3D dma_request_channel(mask, ks8842_dma_filter_fn,
+		(void *)tx_ctl->channel);
+	if (!tx_ctl->chan) {
+		err =3D -ENODEV;
+		goto err;
+	}
+
+	/* allocate DMA buffer */
+	tx_ctl->buf =3D kmalloc(DMA_BUFFER_SIZE, GFP_KERNEL);
+	if (!tx_ctl->buf) {
+		err =3D -ENOMEM;
+		goto err;
+	}
+
+	sg_dma_address(&tx_ctl->sg) =3D dma_map_single(adapter->dev,
+		tx_ctl->buf, DMA_BUFFER_SIZE, DMA_TO_DEVICE);
+	err =3D dma_mapping_error(adapter->dev,
+		sg_dma_address(&tx_ctl->sg));
+	if (err) {
+		sg_dma_address(&tx_ctl->sg) =3D 0;
+		goto err;
+	}
+
+	rx_ctl->chan =3D dma_request_channel(mask, ks8842_dma_filter_fn,
+		(void *)rx_ctl->channel);
+	if (!rx_ctl->chan) {
+		err =3D -ENODEV;
+		goto err;
+	}
+
+	tasklet_init(&rx_ctl->tasklet, ks8842_rx_frame_dma_tasklet,
+		(unsigned long)netdev);
+
+	return 0;
+err:
+	ks8842_dealloc_dma_bufs(adapter);
+	return err;
+}
=20
 /* Netdevice operations */
=20
@@ -616,6 +985,25 @@ static int ks8842_open(struct net_device *netdev)
=20
 	netdev_dbg(netdev, "%s - entry\n", __func__);
=20
+	if (KS8842_USE_DMA(adapter)) {
+		err =3D ks8842_alloc_dma_bufs(netdev);
+
+		if (!err) {
+			/* start RX dma */
+			err =3D __ks8842_start_new_rx_dma(netdev);
+			if (err)
+				ks8842_dealloc_dma_bufs(adapter);
+		}
+
+		if (err) {
+			printk(KERN_WARNING DRV_NAME
+				": Failed to initiate DMA, running PIO\n");
+			ks8842_dealloc_dma_bufs(adapter);
+			adapter->dma_rx.channel =3D -1;
+			adapter->dma_tx.channel =3D -1;
+		}
+	}
+
 	/* reset the HW */
 	ks8842_reset_hw(adapter);
=20
@@ -641,6 +1029,9 @@ static int ks8842_close(struct net_device *netdev)
=20
 	cancel_work_sync(&adapter->timeout_work);
=20
+	if (KS8842_USE_DMA(adapter))
+		ks8842_dealloc_dma_bufs(adapter);
+
 	/* free the irq */
 	free_irq(adapter->irq, netdev);
=20
@@ -658,6 +1049,17 @@ static netdev_tx_t ks8842_xmit_frame(struct sk_bu=
ff *skb,
=20
 	netdev_dbg(netdev, "%s: entry\n", __func__);
=20
+	if (KS8842_USE_DMA(adapter)) {
+		unsigned long flags;
+		ret =3D ks8842_tx_frame_dma(skb, netdev);
+		/* for now only allow one transfer at the time */
+		spin_lock_irqsave(&adapter->lock, flags);
+		if (adapter->dma_tx.adesc)
+			netif_stop_queue(netdev);
+		spin_unlock_irqrestore(&adapter->lock, flags);
+		return ret;
+	}
+
 	ret =3D ks8842_tx_frame(skb, netdev);
=20
 	if (ks8842_tx_fifo_space(adapter) <  netdev->mtu + 8)
@@ -693,6 +1095,10 @@ static void ks8842_tx_timeout_work(struct work_st=
ruct *work)
 	netdev_dbg(netdev, "%s: entry\n", __func__);
=20
 	spin_lock_irqsave(&adapter->lock, flags);
+
+	if (KS8842_USE_DMA(adapter))
+		ks8842_stop_dma(adapter);
+
 	/* disable interrupts */
 	ks8842_write16(adapter, 18, 0, REG_IER);
 	ks8842_write16(adapter, 18, 0xFFFF, REG_ISR);
@@ -706,6 +1112,9 @@ static void ks8842_tx_timeout_work(struct work_str=
uct *work)
 	ks8842_write_mac_addr(adapter, netdev->dev_addr);
=20
 	ks8842_update_link_status(netdev, adapter);
+
+	if (KS8842_USE_DMA(adapter))
+		__ks8842_start_new_rx_dma(netdev);
 }
=20
 static void ks8842_tx_timeout(struct net_device *netdev)
@@ -765,6 +1174,19 @@ static int __devinit ks8842_probe(struct platform=
_device *pdev)
 		goto err_get_irq;
 	}
=20
+	adapter->dev =3D (pdev->dev.parent) ? pdev->dev.parent : &pdev->dev;
+
+	/* DMA is only supported when accessed via timberdale */
+	if (!(adapter->conf_flags & MICREL_KS884X) && pdata &&
+		(pdata->tx_dma_channel !=3D -1) &&
+		(pdata->rx_dma_channel !=3D -1)) {
+		adapter->dma_rx.channel =3D pdata->rx_dma_channel;
+		adapter->dma_tx.channel =3D pdata->tx_dma_channel;
+	} else {
+		adapter->dma_rx.channel =3D -1;
+		adapter->dma_tx.channel =3D -1;
+	}
+
 	tasklet_init(&adapter->tasklet, ks8842_tasklet, (unsigned long)netdev=
);
 	spin_lock_init(&adapter->lock);
=20
diff --git a/include/linux/ks8842.h b/include/linux/ks8842.h
index da0341b..14ba445 100644
--- a/include/linux/ks8842.h
+++ b/include/linux/ks8842.h
@@ -25,10 +25,14 @@
  * struct ks8842_platform_data - Platform data of the KS8842 network d=
river
  * @macaddr:	The MAC address of the device, set to all 0:s to use the =
on in
  *		the chip.
+ * @rx_dma_channel:	The DMA channel to use for RX, -1 for none.
+ * @tx_dma_channel:	The DMA channel to use for TX, -1 for none.
  *
  */
 struct ks8842_platform_data {
 	u8 macaddr[ETH_ALEN];
+	int rx_dma_channel;
+	int tx_dma_channel;
 };
=20
 #endif

