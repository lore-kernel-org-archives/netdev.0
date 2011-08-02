From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [RFC PATCH] common receive API + r8169 use
Date: Tue,  2 Aug 2011 22:24:35 +0200 (CEST)
Message-ID: <f85e6be597ae30fd4dab776b924c0cd0a66514c0.1312314817.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:33885 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754944Ab1HBUYi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Aug 2011 16:24:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Here is a preliminary version of common RX path for network drivers. Th=
e idea
is an extension to Eric Dumazet's patch introducing build_skb() (it's
incorporated here for easier testing).

=46uture plans:
 - extend this API to devices which can do split buffer receives correc=
tly
   and use napi_gro_frags() instead;
 - implement DaveM's idea of RX buffer handling (fill first, process
   if buffers available) in parallel to my version (process first, refi=
ll
   later);
 - get rid of indirect calls in fast path (process_buffer() and
   add_buffer()) - ideas? inline netdev_rx_poll() and pass callback to =
it?

Version rebased on v3.0 is running succesfully on one laptop with r8169=
 on
board since about a week. No problems showed up yet. For net-next this
needs retesting because of changes in device reset handling.

Cards ID:

r8169 0000:05:00.0: eth0: RTL8168e/8111e at 0xffffc90000678000, 78:2b:c=
b:ec:df:54, XID 0c200000, ver 32, IRQ 45

lspci -v:

05:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL8111/81=
68B PCI Express Gigabit Ethernet controller (rev 06)
        Subsystem: Dell Device 04b2
        Flags: bus master, fast devsel, latency 0, IRQ 45
        I/O ports at d000 [size=3D256]
        Memory at f1104000 (64-bit, prefetchable) [size=3D4K]
        Memory at f1100000 (64-bit, prefetchable) [size=3D16K]
        Capabilities: [40] Power Management version 3
        Capabilities: [50] MSI: Enable+ Count=3D1/1 Maskable- 64bit+
        Capabilities: [70] Express Endpoint, MSI 01
        Capabilities: [b0] MSI-X: Enable- Count=3D4 Masked-
        Capabilities: [d0] Vital Product Data
        Capabilities: [100] Advanced Error Reporting
        Capabilities: [140] Virtual Channel
        Capabilities: [160] Device Serial Number [...]
        Kernel driver in use: r8169

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 drivers/net/r8169.c       |  204 ++++++++++++++++++++++++++++++++++++-=
----
 include/linux/netdevice.h |  227 +++++++++++++++++++++++++++++++++++++=
++++++++
 net/core/skbuff.c         |   49 ++++++++++
 3 files changed, 457 insertions(+), 23 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 7d9c650..c0813fd 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -7,6 +7,7 @@
  *
  * See MAINTAINERS file for support contact information.
  */
+//#define NO_COMMON_RX_API
=20
 #include <linux/module.h>
 #include <linux/moduleparam.h>
@@ -33,7 +34,7 @@
 #include <asm/io.h>
 #include <asm/irq.h>
=20
-#define RTL8169_VERSION "2.3LK-NAPI"
+#define RTL8169_VERSION "in-tree+mq"
 #define MODULENAME "r8169"
 #define PFX MODULENAME ": "
=20
@@ -651,6 +652,7 @@ struct rtl8169_private {
 	dma_addr_t TxPhyAddr;
 	dma_addr_t RxPhyAddr;
 	void *Rx_databuff[NUM_RX_DESC];	/* Rx data buffers */
+	struct netdev_ring rx_ring;
 	struct ring_info tx_skb[NUM_TX_DESC];	/* Tx data buffers */
 	struct timer_list timer;
 	u16 cp_cmd;
@@ -728,6 +730,20 @@ static void rtl8169_down(struct net_device *dev);
 static void rtl8169_rx_clear(struct rtl8169_private *tp);
 static int rtl8169_poll(struct napi_struct *napi, int budget);
=20
+static int rtl_add_rx_buffer(struct netdev_ring *ring, void *buf,
+	dma_addr_t dma);
+static dma_addr_t rtl_get_rx_buffer_addr(struct netdev_ring *ring,
+	unsigned int i);
+static int rtl_rx_buffer(struct netdev_ring *ring);
+static void rtl_rx_complete(struct netdev_ring *ring);
+
+static const struct netdev_ring_ops rtl_rx_ring_ops =3D {
+	.add_buffer =3D rtl_add_rx_buffer,
+	.get_buffer_addr =3D rtl_get_rx_buffer_addr,
+	.process_buffer =3D rtl_rx_buffer,
+	.poll_complete =3D rtl_rx_complete,
+};
+
 static u32 ocp_read(struct rtl8169_private *tp, u8 mask, u16 reg)
 {
 	void __iomem *ioaddr =3D tp->mmio_addr;
@@ -3729,6 +3745,9 @@ rtl8169_init_one(struct pci_dev *pdev, const stru=
ct pci_device_id *ent)
 	dev->base_addr =3D (unsigned long) ioaddr;
=20
 	netif_napi_add(dev, &tp->napi, rtl8169_poll, R8169_NAPI_WEIGHT);
+#ifndef NO_COMMON_RX_API
+	netdev_add_ring(dev, &tp->rx_ring, &rtl_rx_ring_ops, R8169_NAPI_WEIGH=
T);
+#endif
=20
 	/* don't enable SG, IP_CSUM and TSO by default - it might not work
 	 * properly for all devices */
@@ -3761,9 +3780,10 @@ rtl8169_init_one(struct pci_dev *pdev, const str=
uct pci_device_id *ent)
=20
 	pci_set_drvdata(pdev, dev);
=20
-	netif_info(tp, probe, dev, "%s at 0x%lx, %pM, XID %08x IRQ %d\n",
+	netif_info(tp, probe, dev, "%s at 0x%lx, %pM, XID %08x, ver %u, IRQ %=
d\n",
 		   rtl_chip_infos[chipset].name, dev->base_addr, dev->dev_addr,
-		   (u32)(RTL_R32(TxConfig) & 0x9cf0f8ff), dev->irq);
+		   (u32)(RTL_R32(TxConfig) & 0x9cf0f8ff), tp->mac_version,
+		   dev->irq);
=20
 	if (tp->mac_version =3D=3D RTL_GIGA_MAC_VER_27 ||
 	    tp->mac_version =3D=3D RTL_GIGA_MAC_VER_28 ||
@@ -3883,12 +3903,17 @@ static int rtl8169_open(struct net_device *dev)
 					     &tp->TxPhyAddr, GFP_KERNEL);
 	if (!tp->TxDescArray)
 		goto err_pm_runtime_put;
-
+#ifdef NO_COMMON_RX_API
 	tp->RxDescArray =3D dma_alloc_coherent(&pdev->dev, R8169_RX_RING_BYTE=
S,
 					     &tp->RxPhyAddr, GFP_KERNEL);
 	if (!tp->RxDescArray)
 		goto err_free_tx_0;
-
+#else
+	retval =3D netdev_alloc_ring(&tp->rx_ring, &pdev->dev, sizeof(struct =
RxDesc),
+		NUM_RX_DESC);
+	if (retval < 0)
+		goto err_free_tx_0;
+#endif
 	retval =3D rtl8169_init_ring(dev);
 	if (retval < 0)
 		goto err_free_rx_1;
@@ -3906,6 +3931,7 @@ static int rtl8169_open(struct net_device *dev)
 		goto err_release_fw_2;
=20
 	napi_enable(&tp->napi);
+	napi_enable(&tp->rx_ring.napi);
=20
 	rtl8169_init_phy(dev, tp);
=20
@@ -3926,9 +3952,14 @@ err_release_fw_2:
 	rtl_release_firmware(tp);
 	rtl8169_rx_clear(tp);
 err_free_rx_1:
+#ifdef NO_COMMON_RX_API
 	dma_free_coherent(&pdev->dev, R8169_RX_RING_BYTES, tp->RxDescArray,
 			  tp->RxPhyAddr);
 	tp->RxDescArray =3D NULL;
+#else
+	netdev_clear_rx_ring(&tp->rx_ring);
+	netdev_free_ring(&tp->rx_ring, sizeof(struct RxDesc));
+#endif
 err_free_tx_0:
 	dma_free_coherent(&pdev->dev, R8169_TX_RING_BYTES, tp->TxDescArray,
 			  tp->TxPhyAddr);
@@ -3998,8 +4029,13 @@ static void rtl_set_rx_tx_desc_registers(struct =
rtl8169_private *tp,
 	 */
 	RTL_W32(TxDescStartAddrHigh, ((u64) tp->TxPhyAddr) >> 32);
 	RTL_W32(TxDescStartAddrLow, ((u64) tp->TxPhyAddr) & DMA_BIT_MASK(32))=
;
+#ifdef NO_COMMON_RX_API
 	RTL_W32(RxDescAddrHigh, ((u64) tp->RxPhyAddr) >> 32);
 	RTL_W32(RxDescAddrLow, ((u64) tp->RxPhyAddr) & DMA_BIT_MASK(32));
+#else
+	RTL_W32(RxDescAddrHigh, cpu_to_le32((u64)tp->rx_ring.desc_dma >> 32))=
;
+	RTL_W32(RxDescAddrLow, cpu_to_le32((u32)tp->rx_ring.desc_dma));
+#endif
 }
=20
 static u16 rtl_rw_cpluscmd(void __iomem *ioaddr)
@@ -4808,6 +4844,29 @@ static inline void rtl8169_mark_as_last_descript=
or(struct RxDesc *desc)
 	desc->opts1 |=3D cpu_to_le32(RingEnd);
 }
=20
+static int rtl_add_rx_buffer(struct netdev_ring *ring, void *buf,
+	dma_addr_t dma)
+{
+	unsigned next_tail =3D (ring->tail + 1) & (NUM_RX_DESC - 1);
+	struct RxDesc *rxd =3D (struct RxDesc *)ring->desc_table + ring->tail=
;
+
+	if (next_tail =3D=3D ACCESS_ONCE(ring->head))
+		return -ENOSPC;
+	ring->buf_table[ring->tail] =3D buf;
+	ring->tail =3D next_tail;
+
+	rtl8169_map_to_asic(rxd, dma, 0);
+	return 0;
+}
+
+static dma_addr_t rtl_get_rx_buffer_addr(struct netdev_ring *ring,
+	unsigned int i)
+{
+	struct RxDesc *rxd =3D (struct RxDesc *)ring->desc_table + i;
+
+	return le64_to_cpu(rxd->addr);
+}
+
 static int rtl8169_rx_fill(struct rtl8169_private *tp)
 {
 	unsigned int i;
@@ -4841,9 +4900,16 @@ static int rtl8169_init_ring(struct net_device *=
dev)
 	rtl8169_init_ring_indexes(tp);
=20
 	memset(tp->tx_skb, 0x0, NUM_TX_DESC * sizeof(struct ring_info));
+#ifdef NO_COMMON_RX_API
 	memset(tp->Rx_databuff, 0x0, NUM_RX_DESC * sizeof(void *));
=20
 	return rtl8169_rx_fill(tp);
+#else
+	rtl8169_mark_as_last_descriptor((struct RxDesc *)tp->rx_ring.desc_tab=
le +
+		NUM_RX_DESC - 1);
+	tp->rx_ring.bufsz =3D 0x4000;
+	return netdev_fill_rx_ring(&tp->rx_ring);
+#endif
 }
=20
 static void rtl8169_unmap_tx_skb(struct device *d, struct ring_info *t=
x_skb,
@@ -4905,6 +4971,7 @@ static void rtl8169_wait_for_quiescence(struct ne=
t_device *dev)
 	synchronize_irq(dev->irq);
=20
 	/* Wait for any pending NAPI task to complete */
+	napi_disable(&tp->rx_ring.napi);
 	napi_disable(&tp->napi);
=20
 	rtl8169_irq_mask_and_ack(ioaddr);
@@ -4912,6 +4979,7 @@ static void rtl8169_wait_for_quiescence(struct ne=
t_device *dev)
 	tp->intr_mask =3D 0xffff;
 	RTL_W16(IntrMask, tp->intr_event);
 	napi_enable(&tp->napi);
+	napi_enable(&tp->rx_ring.napi);
 }
=20
 static void rtl8169_reinit_task(struct work_struct *work)
@@ -4947,7 +5015,9 @@ static void rtl8169_reset_task(struct work_struct=
 *work)
 	struct rtl8169_private *tp =3D
 		container_of(work, struct rtl8169_private, task.work);
 	struct net_device *dev =3D tp->dev;
+#ifdef NO_COMMON_RX_API
 	int i;
+#endif
=20
 	rtnl_lock();
=20
@@ -4955,10 +5025,12 @@ static void rtl8169_reset_task(struct work_stru=
ct *work)
 		goto out_unlock;
=20
 	rtl8169_wait_for_quiescence(dev);
-
+#ifdef NO_COMMON_RX_API
 	for (i =3D 0; i < NUM_RX_DESC; i++)
 		rtl8169_mark_to_asic(tp->RxDescArray + i, rx_buf_sz);
-
+#else
+	netdev_reset_rx_ring(&tp->rx_ring, tp->rx_ring.bufsz);
+#endif
 	rtl8169_tx_clear(tp);
=20
 	rtl8169_hw_reset(tp);
@@ -5356,6 +5428,91 @@ static int rtl8169_rx_interrupt(struct net_devic=
e *dev,
 	return count;
 }
=20
+static int rtl_rx_buffer(struct netdev_ring *ring)
+{
+	struct net_device *dev =3D ring->napi.dev;
+	struct RxDesc *rxd =3D (struct RxDesc *)ring->desc_table + ring->head=
;
+	dma_addr_t dma =3D le64_to_cpu(rxd->addr);
+	void *buf =3D ring->buf_table[ring->head];
+	struct sk_buff *skb;
+	u32 status;
+
+	status =3D le32_to_cpu(ACCESS_ONCE(rxd->opts1));
+	if (status & DescOwn)
+		return -ENOENT;
+
+	netdev_dbg(dev, "RxDesc[%d] =3D %08x %08x %016llx %p\n",
+		ring->head, status, le32_to_cpu(rxd->opts2), dma, buf);
+
+	/*
+	 * release this descriptor - it won't be reused at least until
+	 * netdev_reuse_rx_buffer() or this function returns.
+	 */
+	if (!(status & RingEnd))
+		++ring->head;
+	else
+		ring->head =3D 0;
+
+ 	if (unlikely(status & RxRES)) {
+		dev->stats.rx_errors++;
+		if (status & (RxRWT | RxRUNT))
+			dev->stats.rx_length_errors++;
+		if (status & RxCRC)
+			dev->stats.rx_crc_errors++;
+		if (status & RxFOVF) {
+			rtl8169_schedule_work(dev, rtl8169_reset_task);
+			dev->stats.rx_fifo_errors++;
+		}
+		netdev_reuse_rx_buffer(ring, buf, dma);
+		return -EINVAL;
+	}
+
+	/*
+	 * The chipset is broken regarding incoming fragmented
+	 * frames. If frame size > RxMaxSize, chip fills all fragment
+	 * descriptors with flags and size from first fragment.
+	 * It ignores size set in the free buffer's descriptor.
+	 */
+	if (unlikely(rtl8169_fragmented_frame(status))) {
+		dev->stats.rx_dropped++;
+		dev->stats.rx_length_errors++;
+		netdev_reuse_rx_buffer(ring, buf, dma);
+		return -EINVAL;
+	}
+
+	skb =3D netdev_wrap_rx_buffer(dev, ring, buf, dma,
+		(status & 0x1FFF) - ETH_FCS_LEN);
+	if (unlikely(!skb))
+		return -ENOMEM;
+
+	skb->protocol =3D eth_type_trans(skb, dev);
+	rtl8169_rx_csum(skb, status);
+	rtl8169_rx_vlan_tag(rxd, skb);
+
+	dev->stats.rx_bytes +=3D skb->len;
+	dev->stats.rx_packets++;
+	napi_gro_receive(&ring->napi, skb);
+
+	return 0;
+}
+
+static void rtl_rx_complete(struct netdev_ring *ring)
+{
+	struct rtl8169_private *tp =3D container_of(ring, struct rtl8169_priv=
ate, rx_ring);
+	void __iomem *ioaddr =3D tp->mmio_addr;
+
+	/* We need for force the visibility of tp->intr_mask
+	 * for other CPUs, as we can loose an MSI interrupt
+	 * and potentially wait for a retransmit timeout if we don't.
+	 * The posted write to IntrMask is safe, as it will
+	 * eventually make it to the chip and we won't loose anything
+	 * until it does.
+	 */
+	tp->intr_mask =3D 0xffff;
+	wmb();
+	RTL_W16(IntrMask, tp->intr_event);
+}
+
 static irqreturn_t rtl8169_interrupt(int irq, void *dev_instance)
 {
 	struct net_device *dev =3D dev_instance;
@@ -5426,6 +5583,7 @@ static irqreturn_t rtl8169_interrupt(int irq, voi=
d *dev_instance)
 			RTL_W16(IntrMask, tp->intr_event & ~tp->napi_event);
 			tp->intr_mask =3D ~tp->napi_event;
=20
+			napi_schedule(&tp->rx_ring.napi);
 			if (likely(napi_schedule_prep(&tp->napi)))
 				__napi_schedule(&tp->napi);
 			else
@@ -5453,22 +5611,16 @@ static int rtl8169_poll(struct napi_struct *nap=
i, int budget)
 	void __iomem *ioaddr =3D tp->mmio_addr;
 	int work_done;
=20
+#ifdef NO_COMMON_RX_API
 	work_done =3D rtl8169_rx_interrupt(dev, tp, ioaddr, (u32) budget);
+#else
+	work_done =3D 0;
+#endif
 	rtl8169_tx_interrupt(dev, tp, ioaddr);
=20
 	if (work_done < budget) {
 		napi_complete(napi);
-
-		/* We need for force the visibility of tp->intr_mask
-		 * for other CPUs, as we can loose an MSI interrupt
-		 * and potentially wait for a retransmit timeout if we don't.
-		 * The posted write to IntrMask is safe, as it will
-		 * eventually make it to the chip and we won't loose anything
-		 * until it does.
-		 */
-		tp->intr_mask =3D 0xffff;
-		wmb();
-		RTL_W16(IntrMask, tp->intr_event);
+		rtl_rx_complete(&tp->rx_ring);
 	}
=20
 	return work_done;
@@ -5494,6 +5646,7 @@ static void rtl8169_down(struct net_device *dev)
=20
 	netif_stop_queue(dev);
=20
+	napi_disable(&tp->rx_ring.napi);
 	napi_disable(&tp->napi);
=20
 	spin_lock_irq(&tp->lock);
@@ -5514,9 +5667,11 @@ static void rtl8169_down(struct net_device *dev)
 	synchronize_sched();  /* FIXME: should this be synchronize_irq()? */
=20
 	rtl8169_tx_clear(tp);
-
+#ifdef NO_COMMON_RX_API
 	rtl8169_rx_clear(tp);
-
+#else
+	netdev_clear_rx_ring(&tp->rx_ring);
+#endif
 	rtl_pll_power_down(tp);
 }
=20
@@ -5534,13 +5689,16 @@ static int rtl8169_close(struct net_device *dev=
)
=20
 	free_irq(dev->irq, dev);
=20
-	dma_free_coherent(&pdev->dev, R8169_RX_RING_BYTES, tp->RxDescArray,
-			  tp->RxPhyAddr);
 	dma_free_coherent(&pdev->dev, R8169_TX_RING_BYTES, tp->TxDescArray,
 			  tp->TxPhyAddr);
 	tp->TxDescArray =3D NULL;
+#ifdef NO_COMMON_RX_API
+	dma_free_coherent(&pdev->dev, R8169_RX_RING_BYTES, tp->RxDescArray,
+			  tp->RxPhyAddr);
 	tp->RxDescArray =3D NULL;
-
+#else
+	netdev_free_ring(&tp->rx_ring, sizeof(struct RxDesc));
+#endif
 	pm_runtime_put_sync(&pdev->dev);
=20
 	return 0;
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index ddee79b..d29218d 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1502,6 +1502,231 @@ struct napi_gro_cb {
=20
 #define NAPI_GRO_CB(skb) ((struct napi_gro_cb *)(skb)->cb)
=20
+
+/* generic receive ring handling */
+
+struct netdev_ring;
+
+struct netdev_ring_ops {
+	int (*add_buffer)(struct netdev_ring *ring, void *buf, dma_addr_t dma=
);
+	dma_addr_t (*get_buffer_addr)(struct netdev_ring *ring, unsigned int =
i);
+	int (*process_buffer)(struct netdev_ring *ring);
+	void (*poll_complete)(struct netdev_ring *ring);
+};
+
+struct netdev_ring {
+	struct napi_struct napi;
+	struct netdev_ring_ops ops;
+
+	unsigned int head, tail;
+
+	void **buf_table;
+	void *desc_table;
+
+	struct device *dev;
+	void *next_buf;
+	dma_addr_t next_dma;
+	size_t bufsz;
+
+	dma_addr_t desc_dma;
+	size_t size;
+};
+
+static inline
+void netdev_free_ring(struct netdev_ring *ring, size_t elem_size)
+{
+	kfree(ring->buf_table);
+	if (ring->desc_table)
+		dma_free_coherent(ring->dev, ring->size * elem_size,
+			ring->desc_table, ring->desc_dma);
+
+	ring->buf_table =3D NULL;
+	ring->desc_table =3D NULL;
+}
+
+static inline
+int netdev_alloc_ring(struct netdev_ring *ring, struct device *dma_dev=
,
+	size_t elem_size, unsigned int n_elems)
+{
+	ring->head =3D ring->tail =3D 0;
+	ring->size =3D n_elems;
+	ring->dev =3D dma_dev;
+	ring->desc_table =3D dma_alloc_coherent(dma_dev, ring->size * elem_si=
ze,
+		&ring->desc_dma, GFP_KERNEL);
+	ring->buf_table =3D kcalloc(n_elems, sizeof(*ring->buf_table),
+		GFP_KERNEL);
+
+	if (likely(ring->desc_table && ring->buf_table))
+		return 0;
+
+	netdev_free_ring(ring, elem_size);
+	return -ENOMEM;
+}
+
+#define SKB_DATA_SZ(x) \
+	(SKB_DATA_ALIGN((x) + NET_SKB_PAD) - \
+	 SKB_DATA_ALIGN(SKB_WITH_OVERHEAD(0)))
+
+static inline
+int netdev_fill_rx_ring(struct netdev_ring *ring)
+{
+	void *buf;
+	dma_addr_t dma;
+	int n =3D 0;
+
+	if (ring->next_buf) {
+		if (ring->ops.add_buffer(ring, ring->next_buf, ring->next_dma))
+			return 0;
+		ring->next_buf =3D NULL;
+		n =3D 1;
+	}
+
+	for(;; ++n) {
+		/* max buf =3D 8kB-8, 8B aligned */
+		buf =3D kmalloc(SKB_DATA_SZ(ring->bufsz), GFP_KERNEL);
+		if (!buf)
+			break;
+		dma =3D dma_map_single(ring->dev, buf + NET_SKB_PAD,
+			ring->bufsz, DMA_FROM_DEVICE);	// DMA dir
+		if (unlikely(dma_mapping_error(ring->dev, dma))) {
+			kfree(buf);
+			break;
+		}
+		if (ring->ops.add_buffer(ring, buf + NET_SKB_PAD, dma)) {
+			ring->next_buf =3D buf + NET_SKB_PAD;
+			ring->next_dma =3D dma;
+			break;
+		}
+	}
+
+	return n;
+}
+
+static inline
+void netdev_clear_rx_ring(struct netdev_ring *ring)
+{
+	dma_addr_t dma;
+	void *buf;
+
+	if (ring->next_buf) {
+		buf =3D ring->next_buf;
+		dma =3D ring->next_dma;
+		ring->next_buf =3D NULL;
+		goto free_buf;
+	}
+
+	while (ring->tail !=3D ring->head) {
+		if (!ring->tail)
+			ring->tail =3D ring->size;
+		--ring->tail;
+
+		buf =3D ring->buf_table[ring->tail];
+		dma =3D ring->ops.get_buffer_addr(ring, ring->tail);
+free_buf:
+		dma_unmap_single(ring->dev, dma, ring->bufsz, DMA_FROM_DEVICE);
+		kfree(buf - NET_SKB_PAD);
+	}
+}
+
+static inline
+void netdev_reset_rx_ring(struct netdev_ring *ring, size_t new_bufsz)
+{
+	netdev_clear_rx_ring(ring);
+	ring->head =3D ring->tail =3D 0;
+	ring->bufsz =3D new_bufsz;
+	netdev_fill_rx_ring(ring);
+}
+
+struct sk_buff *build_skb(void *data, unsigned int size);
+
+static inline
+void netdev_reuse_rx_buffer(struct netdev_ring *ring,
+	void *data, dma_addr_t dma)
+{
+	if (likely(!ring->ops.add_buffer(ring, data, dma)))
+		return;
+
+	if (ring->next_buf) {
+		dma_unmap_single(ring->dev, dma, ring->bufsz, DMA_FROM_DEVICE);
+		kfree(data - NET_SKB_PAD);
+	} else {
+		ring->next_buf =3D data;
+		ring->next_dma =3D dma;
+	}
+}
+
+static inline
+struct sk_buff *netdev_wrap_rx_buffer(struct net_device *dev,
+	struct netdev_ring *ring, void *data, dma_addr_t dma, unsigned int le=
n)
+{
+	size_t bufsz =3D ring->bufsz;
+	struct sk_buff *skb;
+
+	if (len < 256/* rx_copybreak */) {
+		skb =3D netdev_alloc_skb_ip_align(dev, len);
+		if (likely(skb)) {
+			dma_sync_single_for_cpu(ring->dev, dma, len, DMA_FROM_DEVICE);
+			skb_copy_to_linear_data(skb, data, len);
+			netdev_reuse_rx_buffer(ring, data, dma);
+			goto finish_skb;
+		}
+	}
+
+	dma_unmap_single(ring->dev, dma, bufsz, DMA_FROM_DEVICE);
+	skb =3D build_skb(data - NET_SKB_PAD, bufsz + NET_SKB_PAD);
+	if (!skb) {
+		dma =3D dma_map_single(ring->dev, data, bufsz, DMA_FROM_DEVICE);
+		if (likely(!dma_mapping_error(ring->dev, dma)))
+			netdev_reuse_rx_buffer(ring, data, dma);
+		else
+			kfree(data - NET_SKB_PAD);
+		return NULL;
+	}
+
+	skb_reserve(skb, NET_SKB_PAD);
+	skb->dev =3D dev;
+
+finish_skb:
+	skb_put(skb, len);
+
+	return skb;
+}
+
+static int netdev_rx_poll(struct napi_struct *napi, int budget)
+{
+	struct netdev_ring *ring =3D container_of(napi, struct netdev_ring, n=
api);
+	int max =3D budget;
+
+	while (budget > 0) {
+		if (ring->ops.process_buffer(ring) =3D=3D -ENOENT)
+			break;
+
+		--budget;
+	}
+
+	netdev_fill_rx_ring(ring);
+
+	if (budget) {
+		ring->ops.poll_complete(ring);
+		if (ring->ops.process_buffer(ring) =3D=3D -ENOENT)
+			napi_complete(&ring->napi);
+		else /* raced with rx indication - just continue polling */
+			--budget;
+	}
+
+	return max - budget;
+}
+
+static inline void netdev_add_ring(struct net_device *dev, struct netd=
ev_ring *ring,
+	const struct netdev_ring_ops *ops, int weigth)
+{
+	ring->ops =3D *ops;
+	netif_napi_add(dev, &ring->napi, netdev_rx_poll, weigth);
+}
+
+
+
+
 struct packet_type {
 	__be16			type;	/* This is really htons(ether_type). */
 	struct net_device	*dev;	/* NULL is wildcarded here	     */
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 2beda82..92fad68 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -3162,3 +3162,52 @@ void __skb_warn_lro_forwarding(const struct sk_b=
uff *skb)
 			   " while LRO is enabled\n", skb->dev->name);
 }
 EXPORT_SYMBOL(__skb_warn_lro_forwarding);
+
+ /**
+  * build_skb - build a network buffer
+  * @data: data buffer provider by caller
+  * @size: size of data buffer, not including skb_shared_info
+  *
+  * Allocate a new &sk_buff. Caller provides space holding head and
+  * skb_shared_info. Mostly used in driver RX path.
+  * The return is the buffer. On a failure the return is %NULL.
+  * Notes :
+  *  Before IO, driver allocates only data buffer where NIC put incomi=
ng frame
+  *  Driver SHOULD add room at head (NET_SKB_PAD) and
+  *  MUST add room tail (to hold skb_shared_info)
+  *  After IO, driver calls build_skb(), to get a hot skb instead of a=
 cold one
+  *  before giving packet to stack. RX rings only contains data buffer=
s, not
+  *  full skbs.
+  */
+struct sk_buff *build_skb(void *data, unsigned int size)
+{
+	struct skb_shared_info *shinfo;
+	struct sk_buff *skb;
+
+	skb =3D kmem_cache_alloc(skbuff_head_cache, GFP_ATOMIC);
+	if (!skb)
+		return NULL;
+
+	size =3D SKB_DATA_ALIGN(size);
+
+	memset(skb, 0, offsetof(struct sk_buff, tail));
+	skb->truesize =3D size + sizeof(struct sk_buff);
+	atomic_set(&skb->users, 1);
+	skb->head =3D data;
+	skb->data =3D data;
+	skb_reset_tail_pointer(skb);
+	skb->end =3D skb->tail + size;
+#ifdef NET_SKBUFF_DATA_USES_OFFSET
+	skb->mac_header =3D ~0U;
+#endif
+
+	/* make sure we initialize shinfo sequentially */
+	shinfo =3D skb_shinfo(skb);
+	memset(shinfo, 0, offsetof(struct skb_shared_info, dataref));
+	atomic_set(&shinfo->dataref, 1);
+	kmemcheck_annotate_variable(shinfo->destructor_arg);
+
+	return skb;
+}
+EXPORT_SYMBOL_GPL(build_skb);
+
--=20
1.7.5.4

