From: "Steve Wise" <swise@opengridcomputing.com>
Subject: [PATCH v2 1/7] AMSO1100 Low Level Driver.
Date: Wed, 07 Jun 2006 15:06:49 -0500
Message-ID: <20060607200648.9259.69698.stgit@stevo-desktop>
References: <20060607200646.9259.24588.stgit@stevo-desktop>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8;
 format=fixed
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
To: rdreier@cisco.com,
	mshefty@ichips.intel.com
In-Reply-To: <20060607200646.9259.24588.stgit@stevo-desktop>
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
 <mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
 <mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org


This is the core of the driver and includes the hardware probe, low-level
device interfaces and native Ethernet support.

Review Changes:

- sizeof -> sizeof()

- dprintk() -> pr_debug()

- removed useless asserts

- assert() -> BUG_ON()

- C2_DEBUG -> DEBUG

- removed debug netevent code

- removed arp request squelch code from intr handler, replacing it
  with setting arp_ignore when the c2 netdev is brought up.

- removed c2_set_mac_addr().
---

 drivers/infiniband/hw/amso1100/c2.c      | 1255 ++++++++++++++++++++++++=
++++++
 drivers/infiniband/hw/amso1100/c2.h      |  555 +++++++++++++
 drivers/infiniband/hw/amso1100/c2_ae.c   |  359 +++++++++
 drivers/infiniband/hw/amso1100/c2_intr.c |  209 +++++
 drivers/infiniband/hw/amso1100/c2_rnic.c |  631 +++++++++++++++
 5 files changed, 3009 insertions(+), 0 deletions(-)

diff --git a/drivers/infiniband/hw/amso1100/c2.c b/drivers/infiniband/hw/=
amso1100/c2.c
new file mode 100644
index 0000000..4fdbd80
--- /dev/null
+++ b/drivers/infiniband/hw/amso1100/c2.c
@@ -0,0 +1,1255 @@
+/*
+ * Copyright (c) 2005 Ammasso, Inc. All rights reserved.
+ * Copyright (c) 2005 Open Grid Computing, Inc. All rights reserved.
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * OpenIB.org BSD license below:
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      - Redistributions of source code must retain the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer.
+ *
+ *      - Redistributions in binary form must reproduce the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer in the documentation and/or other materials
+ *        provided with the distribution.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ */
+#include <linux/module.h>
+#include <linux/moduleparam.h>
+#include <linux/pci.h>
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/inetdevice.h>
+#include <linux/delay.h>
+#include <linux/ethtool.h>
+#include <linux/mii.h>
+#include <linux/if_vlan.h>
+#include <linux/crc32.h>
+#include <linux/in.h>
+#include <linux/ip.h>
+#include <linux/tcp.h>
+#include <linux/init.h>
+#include <linux/dma-mapping.h>
+
+#include <asm/io.h>
+#include <asm/irq.h>
+#include <asm/byteorder.h>
+
+#include <rdma/ib_smi.h>
+#include "c2.h"
+#include "c2_provider.h"
+
+MODULE_AUTHOR("Tom Tucker <tom@opengridcomputing.com>");
+MODULE_DESCRIPTION("Ammasso AMSO1100 Low-level iWARP Driver");
+MODULE_LICENSE("Dual BSD/GPL");
+MODULE_VERSION(DRV_VERSION);
+
+static const u32 default_msg =3D NETIF_MSG_DRV | NETIF_MSG_PROBE | NETIF=
_MSG_LINK
+    | NETIF_MSG_IFUP | NETIF_MSG_IFDOWN;
+
+static int debug =3D -1;		/* defaults above */
+module_param(debug, int, 0);
+MODULE_PARM_DESC(debug, "Debug level (0=3Dnone,...,16=3Dall)");
+
+static int c2_up(struct net_device *netdev);
+static int c2_down(struct net_device *netdev);
+static int c2_xmit_frame(struct sk_buff *skb, struct net_device *netdev)=
;
+static void c2_tx_interrupt(struct net_device *netdev);
+static void c2_rx_interrupt(struct net_device *netdev);
+static irqreturn_t c2_interrupt(int irq, void *dev_id, struct pt_regs *r=
egs);
+static void c2_tx_timeout(struct net_device *netdev);
+static int c2_change_mtu(struct net_device *netdev, int new_mtu);
+static void c2_reset(struct c2_port *c2_port);
+static struct net_device_stats *c2_get_stats(struct net_device *netdev);
+
+static struct pci_device_id c2_pci_table[] =3D {
+	{0x18b8, 0xb001, PCI_ANY_ID, PCI_ANY_ID},
+	{0}
+};
+
+MODULE_DEVICE_TABLE(pci, c2_pci_table);
+
+static void c2_print_macaddr(struct net_device *netdev)
+{
+	pr_debug("%s: MAC %02X:%02X:%02X:%02X:%02X:%02X, "
+		"IRQ %u\n", netdev->name,
+		netdev->dev_addr[0], netdev->dev_addr[1], netdev->dev_addr[2],
+		netdev->dev_addr[3], netdev->dev_addr[4], netdev->dev_addr[5],
+		netdev->irq);
+}
+
+static void c2_set_rxbufsize(struct c2_port *c2_port)
+{
+	struct net_device *netdev =3D c2_port->netdev;
+
+	if (netdev->mtu > RX_BUF_SIZE)
+		c2_port->rx_buf_size =3D
+		    netdev->mtu + ETH_HLEN + sizeof(struct c2_rxp_hdr) +
+		    NET_IP_ALIGN;
+	else
+		c2_port->rx_buf_size =3D sizeof(struct c2_rxp_hdr) + RX_BUF_SIZE;
+}
+
+/*
+ * Allocate TX ring elements and chain them together.
+ * One-to-one association of adapter descriptors with ring elements.
+ */
+static int c2_tx_ring_alloc(struct c2_ring *tx_ring, void *vaddr,
+			    dma_addr_t base, void __iomem * mmio_txp_ring)
+{
+	struct c2_tx_desc *tx_desc;
+	struct c2_txp_desc __iomem *txp_desc;
+	struct c2_element *elem;
+	int i;
+
+	tx_ring->start =3D kmalloc(sizeof(*elem) * tx_ring->count, GFP_KERNEL);
+	if (!tx_ring->start)
+		return -ENOMEM;
+
+	elem =3D tx_ring->start;
+	tx_desc =3D vaddr;
+	txp_desc =3D mmio_txp_ring;
+	for (i =3D 0; i < tx_ring->count; i++, elem++, tx_desc++, txp_desc++) {
+		tx_desc->len =3D 0;
+		tx_desc->status =3D 0;
+
+		/* Set TXP_HTXD_UNINIT */
+		__raw_writeq(cpu_to_be64(0x1122334455667788ULL),
+			     (void __iomem *) txp_desc + C2_TXP_ADDR);
+		__raw_writew(0, (void __iomem *) txp_desc + C2_TXP_LEN);
+		__raw_writew(cpu_to_be16(TXP_HTXD_UNINIT),
+			     (void __iomem *) txp_desc + C2_TXP_FLAGS);
+
+		elem->skb =3D NULL;
+		elem->ht_desc =3D tx_desc;
+		elem->hw_desc =3D txp_desc;
+
+		if (i =3D=3D tx_ring->count - 1) {
+			elem->next =3D tx_ring->start;
+			tx_desc->next_offset =3D base;
+		} else {
+			elem->next =3D elem + 1;
+			tx_desc->next_offset =3D
+			    base + (i + 1) * sizeof(*tx_desc);
+		}
+	}
+
+	tx_ring->to_use =3D tx_ring->to_clean =3D tx_ring->start;
+
+	return 0;
+}
+
+/*
+ * Allocate RX ring elements and chain them together.
+ * One-to-one association of adapter descriptors with ring elements.
+ */
+static int c2_rx_ring_alloc(struct c2_ring *rx_ring, void *vaddr,
+			    dma_addr_t base, void __iomem * mmio_rxp_ring)
+{
+	struct c2_rx_desc *rx_desc;
+	struct c2_rxp_desc __iomem *rxp_desc;
+	struct c2_element *elem;
+	int i;
+
+	rx_ring->start =3D kmalloc(sizeof(*elem) * rx_ring->count, GFP_KERNEL);
+	if (!rx_ring->start)
+		return -ENOMEM;
+
+	elem =3D rx_ring->start;
+	rx_desc =3D vaddr;
+	rxp_desc =3D mmio_rxp_ring;
+	for (i =3D 0; i < rx_ring->count; i++, elem++, rx_desc++, rxp_desc++) {
+		rx_desc->len =3D 0;
+		rx_desc->status =3D 0;
+
+		/* Set RXP_HRXD_UNINIT */
+		__raw_writew(cpu_to_be16(RXP_HRXD_OK),
+		       (void __iomem *) rxp_desc + C2_RXP_STATUS);
+		__raw_writew(0, (void __iomem *) rxp_desc + C2_RXP_COUNT);
+		__raw_writew(0, (void __iomem *) rxp_desc + C2_RXP_LEN);
+		__raw_writeq(cpu_to_be64(0x99aabbccddeeffULL),
+			     (void __iomem *) rxp_desc + C2_RXP_ADDR);
+		__raw_writew(cpu_to_be16(RXP_HRXD_UNINIT),
+			     (void __iomem *) rxp_desc + C2_RXP_FLAGS);
+
+		elem->skb =3D NULL;
+		elem->ht_desc =3D rx_desc;
+		elem->hw_desc =3D rxp_desc;
+
+		if (i =3D=3D rx_ring->count - 1) {
+			elem->next =3D rx_ring->start;
+			rx_desc->next_offset =3D base;
+		} else {
+			elem->next =3D elem + 1;
+			rx_desc->next_offset =3D
+			    base + (i + 1) * sizeof(*rx_desc);
+		}
+	}
+
+	rx_ring->to_use =3D rx_ring->to_clean =3D rx_ring->start;
+
+	return 0;
+}
+
+/* Setup buffer for receiving */
+static inline int c2_rx_alloc(struct c2_port *c2_port, struct c2_element=
 *elem)
+{
+	struct c2_dev *c2dev =3D c2_port->c2dev;
+	struct c2_rx_desc *rx_desc =3D elem->ht_desc;
+	struct sk_buff *skb;
+	dma_addr_t mapaddr;
+	u32 maplen;
+	struct c2_rxp_hdr *rxp_hdr;
+
+	skb =3D dev_alloc_skb(c2_port->rx_buf_size);
+	if (unlikely(!skb)) {
+		pr_debug("%s: out of memory for receive\n",
+			c2_port->netdev->name);
+		return -ENOMEM;
+	}
+
+	/* Zero out the rxp hdr in the sk_buff */
+	memset(skb->data, 0, sizeof(*rxp_hdr));
+
+	skb->dev =3D c2_port->netdev;
+
+	maplen =3D c2_port->rx_buf_size;
+	mapaddr =3D
+	    pci_map_single(c2dev->pcidev, skb->data, maplen,
+			   PCI_DMA_FROMDEVICE);
+
+	/* Set the sk_buff RXP_header to RXP_HRXD_READY */
+	rxp_hdr =3D (struct c2_rxp_hdr *) skb->data;
+	rxp_hdr->flags =3D RXP_HRXD_READY;
+
+	__raw_writew(0, elem->hw_desc + C2_RXP_STATUS);
+	__raw_writew(cpu_to_be16((u16) maplen - sizeof(*rxp_hdr)),
+		     elem->hw_desc + C2_RXP_LEN);
+	__raw_writeq(cpu_to_be64(mapaddr), elem->hw_desc + C2_RXP_ADDR);
+	__raw_writew(cpu_to_be16(RXP_HRXD_READY), elem->hw_desc + C2_RXP_FLAGS)=
;
+
+	elem->skb =3D skb;
+	elem->mapaddr =3D mapaddr;
+	elem->maplen =3D maplen;
+	rx_desc->len =3D maplen;
+
+	return 0;
+}
+
+/*
+ * Allocate buffers for the Rx ring
+ * For receive:  rx_ring.to_clean is next received frame
+ */
+static int c2_rx_fill(struct c2_port *c2_port)
+{
+	struct c2_ring *rx_ring =3D &c2_port->rx_ring;
+	struct c2_element *elem;
+	int ret =3D 0;
+
+	elem =3D rx_ring->start;
+	do {
+		if (c2_rx_alloc(c2_port, elem)) {
+			ret =3D 1;
+			break;
+		}
+	} while ((elem =3D elem->next) !=3D rx_ring->start);
+
+	rx_ring->to_clean =3D rx_ring->start;
+	return ret;
+}
+
+/* Free all buffers in RX ring, assumes receiver stopped */
+static void c2_rx_clean(struct c2_port *c2_port)
+{
+	struct c2_dev *c2dev =3D c2_port->c2dev;
+	struct c2_ring *rx_ring =3D &c2_port->rx_ring;
+	struct c2_element *elem;
+	struct c2_rx_desc *rx_desc;
+
+	elem =3D rx_ring->start;
+	do {
+		rx_desc =3D elem->ht_desc;
+		rx_desc->len =3D 0;
+
+		__raw_writew(0, elem->hw_desc + C2_RXP_STATUS);
+		__raw_writew(0, elem->hw_desc + C2_RXP_COUNT);
+		__raw_writew(0, elem->hw_desc + C2_RXP_LEN);
+		__raw_writeq(cpu_to_be64(0x99aabbccddeeffULL),
+			     elem->hw_desc + C2_RXP_ADDR);
+		__raw_writew(cpu_to_be16(RXP_HRXD_UNINIT),
+			     elem->hw_desc + C2_RXP_FLAGS);
+
+		if (elem->skb) {
+			pci_unmap_single(c2dev->pcidev, elem->mapaddr,
+					 elem->maplen, PCI_DMA_FROMDEVICE);
+			dev_kfree_skb(elem->skb);
+			elem->skb =3D NULL;
+		}
+	} while ((elem =3D elem->next) !=3D rx_ring->start);
+}
+
+static inline int c2_tx_free(struct c2_dev *c2dev, struct c2_element *el=
em)
+{
+	struct c2_tx_desc *tx_desc =3D elem->ht_desc;
+
+	tx_desc->len =3D 0;
+
+	pci_unmap_single(c2dev->pcidev, elem->mapaddr, elem->maplen,
+			 PCI_DMA_TODEVICE);
+
+	if (elem->skb) {
+		dev_kfree_skb_any(elem->skb);
+		elem->skb =3D NULL;
+	}
+
+	return 0;
+}
+
+/* Free all buffers in TX ring, assumes transmitter stopped */
+static void c2_tx_clean(struct c2_port *c2_port)
+{
+	struct c2_ring *tx_ring =3D &c2_port->tx_ring;
+	struct c2_element *elem;
+	struct c2_txp_desc txp_htxd;
+	int retry;
+	unsigned long flags;
+
+	spin_lock_irqsave(&c2_port->tx_lock, flags);
+
+	elem =3D tx_ring->start;
+
+	do {
+		retry =3D 0;
+		do {
+			txp_htxd.flags =3D
+			    readw(elem->hw_desc + C2_TXP_FLAGS);
+
+			if (txp_htxd.flags =3D=3D TXP_HTXD_READY) {
+				retry =3D 1;
+				__raw_writew(0,
+					     elem->hw_desc + C2_TXP_LEN);
+				__raw_writeq(0,
+					     elem->hw_desc + C2_TXP_ADDR);
+				__raw_writew(cpu_to_be16(TXP_HTXD_DONE),
+					     elem->hw_desc + C2_TXP_FLAGS);
+				c2_port->netstats.tx_dropped++;
+				break;
+			} else {
+				__raw_writew(0,
+					     elem->hw_desc + C2_TXP_LEN);
+				__raw_writeq(cpu_to_be64(0x1122334455667788ULL),
+					     elem->hw_desc + C2_TXP_ADDR);
+				__raw_writew(cpu_to_be16(TXP_HTXD_UNINIT),
+					     elem->hw_desc + C2_TXP_FLAGS);
+			}
+
+			c2_tx_free(c2_port->c2dev, elem);
+
+		} while ((elem =3D elem->next) !=3D tx_ring->start);
+	} while (retry);
+
+	c2_port->tx_avail =3D c2_port->tx_ring.count - 1;
+	c2_port->c2dev->cur_tx =3D tx_ring->to_use - tx_ring->start;
+
+	if (c2_port->tx_avail > MAX_SKB_FRAGS + 1)
+		netif_wake_queue(c2_port->netdev);
+
+	spin_unlock_irqrestore(&c2_port->tx_lock, flags);
+}
+
+/*
+ * Process transmit descriptors marked 'DONE' by the firmware,
+ * freeing up their unneeded sk_buffs.
+ */
+static void c2_tx_interrupt(struct net_device *netdev)
+{
+	struct c2_port *c2_port =3D netdev_priv(netdev);
+	struct c2_dev *c2dev =3D c2_port->c2dev;
+	struct c2_ring *tx_ring =3D &c2_port->tx_ring;
+	struct c2_element *elem;
+	struct c2_txp_desc txp_htxd;
+
+	spin_lock(&c2_port->tx_lock);
+
+	for (elem =3D tx_ring->to_clean; elem !=3D tx_ring->to_use;
+	     elem =3D elem->next) {
+		txp_htxd.flags =3D
+		    be16_to_cpu(readw(elem->hw_desc + C2_TXP_FLAGS));
+
+		if (txp_htxd.flags !=3D TXP_HTXD_DONE)
+			break;
+
+		if (netif_msg_tx_done(c2_port)) {
+			/* PCI reads are expensive in fast path */
+			txp_htxd.len =3D
+			    be16_to_cpu(readw(elem->hw_desc + C2_TXP_LEN));
+			pr_debug("%s: tx done slot %3Zu status 0x%x len "
+				"%5u bytes\n",
+				netdev->name, elem - tx_ring->start,
+				txp_htxd.flags, txp_htxd.len);
+		}
+
+		c2_tx_free(c2dev, elem);
+		++(c2_port->tx_avail);
+	}
+
+	tx_ring->to_clean =3D elem;
+
+	if (netif_queue_stopped(netdev)
+	    && c2_port->tx_avail > MAX_SKB_FRAGS + 1)
+		netif_wake_queue(netdev);
+
+	spin_unlock(&c2_port->tx_lock);
+}
+
+static void c2_rx_error(struct c2_port *c2_port, struct c2_element *elem=
)
+{
+	struct c2_rx_desc *rx_desc =3D elem->ht_desc;
+	struct c2_rxp_hdr *rxp_hdr =3D (struct c2_rxp_hdr *) elem->skb->data;
+
+	if (rxp_hdr->status !=3D RXP_HRXD_OK ||
+	    rxp_hdr->len > (rx_desc->len - sizeof(*rxp_hdr))) {
+		pr_debug("BAD RXP_HRXD\n");
+		pr_debug("  rx_desc : %p\n", rx_desc);
+		pr_debug("    index : %Zu\n",
+			elem - c2_port->rx_ring.start);
+		pr_debug("    len   : %u\n", rx_desc->len);
+		pr_debug("  rxp_hdr : %p [PA %p]\n", rxp_hdr,
+			(void *) __pa((unsigned long) rxp_hdr));
+		pr_debug("    flags : 0x%x\n", rxp_hdr->flags);
+		pr_debug("    status: 0x%x\n", rxp_hdr->status);
+		pr_debug("    len   : %u\n", rxp_hdr->len);
+		pr_debug("    rsvd  : 0x%x\n", rxp_hdr->rsvd);
+	}
+
+	/* Setup the skb for reuse since we're dropping this pkt */
+	elem->skb->tail =3D elem->skb->data =3D elem->skb->head;
+
+	/* Zero out the rxp hdr in the sk_buff */
+	memset(elem->skb->data, 0, sizeof(*rxp_hdr));
+
+	/* Write the descriptor to the adapter's rx ring */
+	__raw_writew(0, elem->hw_desc + C2_RXP_STATUS);
+	__raw_writew(0, elem->hw_desc + C2_RXP_COUNT);
+	__raw_writew(cpu_to_be16((u16) elem->maplen - sizeof(*rxp_hdr)),
+		     elem->hw_desc + C2_RXP_LEN);
+	__raw_writeq(cpu_to_be64(elem->mapaddr), elem->hw_desc + C2_RXP_ADDR);
+	__raw_writew(cpu_to_be16(RXP_HRXD_READY), elem->hw_desc + C2_RXP_FLAGS)=
;
+
+	pr_debug("packet dropped\n");
+	c2_port->netstats.rx_dropped++;
+}
+
+static void c2_rx_interrupt(struct net_device *netdev)
+{
+	struct c2_port *c2_port =3D netdev_priv(netdev);
+	struct c2_dev *c2dev =3D c2_port->c2dev;
+	struct c2_ring *rx_ring =3D &c2_port->rx_ring;
+	struct c2_element *elem;
+	struct c2_rx_desc *rx_desc;
+	struct c2_rxp_hdr *rxp_hdr;
+	struct sk_buff *skb;
+	dma_addr_t mapaddr;
+	u32 maplen, buflen;
+	unsigned long flags;
+
+	spin_lock_irqsave(&c2dev->lock, flags);
+
+	/* Begin where we left off */
+	rx_ring->to_clean =3D rx_ring->start + c2dev->cur_rx;
+
+	for (elem =3D rx_ring->to_clean; elem->next !=3D rx_ring->to_clean;
+	     elem =3D elem->next) {
+		rx_desc =3D elem->ht_desc;
+		mapaddr =3D elem->mapaddr;
+		maplen =3D elem->maplen;
+		skb =3D elem->skb;
+		rxp_hdr =3D (struct c2_rxp_hdr *) skb->data;
+
+		if (rxp_hdr->flags !=3D RXP_HRXD_DONE)
+			break;
+		buflen =3D rxp_hdr->len;
+
+		/* Sanity check the RXP header */
+		if (rxp_hdr->status !=3D RXP_HRXD_OK ||
+		    buflen > (rx_desc->len - sizeof(*rxp_hdr))) {
+			c2_rx_error(c2_port, elem);
+			continue;
+		}
+
+		/*=20
+		 * Allocate and map a new skb for replenishing the host=20
+		 * RX desc=20
+		 */
+		if (c2_rx_alloc(c2_port, elem)) {
+			c2_rx_error(c2_port, elem);
+			continue;
+		}
+
+		/* Unmap the old skb */
+		pci_unmap_single(c2dev->pcidev, mapaddr, maplen,
+				 PCI_DMA_FROMDEVICE);
+
+		prefetch(skb->data);
+
+		/*
+		 * Skip past the leading 8 bytes comprising of the=20
+		 * "struct c2_rxp_hdr", prepended by the adapter=20
+		 * to the usual Ethernet header ("struct ethhdr"),=20
+		 * to the start of the raw Ethernet packet.
+		 *=20
+		 * Fix up the various fields in the sk_buff before=20
+		 * passing it up to netif_rx(). The transfer size=20
+		 * (in bytes) specified by the adapter len field of=20
+		 * the "struct rxp_hdr_t" does NOT include the=20
+		 * "sizeof(struct c2_rxp_hdr)".
+		 */
+		skb->data +=3D sizeof(*rxp_hdr);
+		skb->tail =3D skb->data + buflen;
+		skb->len =3D buflen;
+		skb->dev =3D netdev;
+		skb->protocol =3D eth_type_trans(skb, netdev);
+
+		netif_rx(skb);
+
+		netdev->last_rx =3D jiffies;
+		c2_port->netstats.rx_packets++;
+		c2_port->netstats.rx_bytes +=3D buflen;
+	}
+
+	/* Save where we left off */
+	rx_ring->to_clean =3D elem;
+	c2dev->cur_rx =3D elem - rx_ring->start;
+	C2_SET_CUR_RX(c2dev, c2dev->cur_rx);
+
+	spin_unlock_irqrestore(&c2dev->lock, flags);
+}
+
+/*
+ * Handle netisr0 TX & RX interrupts.
+ */
+static irqreturn_t c2_interrupt(int irq, void *dev_id, struct pt_regs *r=
egs)
+{
+	unsigned int netisr0, dmaisr;
+	int handled =3D 0;
+	struct c2_dev *c2dev =3D (struct c2_dev *) dev_id;
+
+	/* Process CCILNET interrupts */
+	netisr0 =3D readl(c2dev->regs + C2_NISR0);
+	if (netisr0) {
+
+		/*
+		 * There is an issue with the firmware that always
+		 * provides the status of RX for both TX & RX=20
+		 * interrupts.  So process both queues here.
+		 */
+		c2_rx_interrupt(c2dev->netdev);
+		c2_tx_interrupt(c2dev->netdev);
+
+		/* Clear the interrupt */
+		writel(netisr0, c2dev->regs + C2_NISR0);
+		handled++;
+	}
+
+	/* Process RNIC interrupts */
+	dmaisr =3D readl(c2dev->regs + C2_DISR);
+	if (dmaisr) {
+		writel(dmaisr, c2dev->regs + C2_DISR);
+		c2_rnic_interrupt(c2dev);
+		handled++;
+	}
+
+	if (handled) {
+		return IRQ_HANDLED;
+	} else {
+		return IRQ_NONE;
+	}
+}
+
+static int c2_up(struct net_device *netdev)
+{
+	struct c2_port *c2_port =3D netdev_priv(netdev);
+	struct c2_dev *c2dev =3D c2_port->c2dev;
+	struct c2_element *elem;
+	struct c2_rxp_hdr *rxp_hdr;
+	struct in_device *in_dev;
+	size_t rx_size, tx_size;
+	int ret, i;
+	unsigned int netimr0;
+
+	if (netif_msg_ifup(c2_port))
+		pr_debug("%s: enabling interface\n", netdev->name);
+
+	/* Set the Rx buffer size based on MTU */
+	c2_set_rxbufsize(c2_port);
+
+	/* Allocate DMA'able memory for Tx/Rx host descriptor rings */
+	rx_size =3D c2_port->rx_ring.count * sizeof(struct c2_rx_desc);
+	tx_size =3D c2_port->tx_ring.count * sizeof(struct c2_tx_desc);
+
+	c2_port->mem_size =3D tx_size + rx_size;
+	c2_port->mem =3D pci_alloc_consistent(c2dev->pcidev, c2_port->mem_size,
+					    &c2_port->dma);
+	if (c2_port->mem =3D=3D NULL) {
+		pr_debug("Unable to allocate memory for "
+			"host descriptor rings\n");
+		return -ENOMEM;
+	}
+
+	memset(c2_port->mem, 0, c2_port->mem_size);
+
+	/* Create the Rx host descriptor ring */
+	if ((ret =3D
+	     c2_rx_ring_alloc(&c2_port->rx_ring, c2_port->mem, c2_port->dma,
+			      c2dev->mmio_rxp_ring))) {
+		pr_debug("Unable to create RX ring\n");
+		goto bail0;
+	}
+
+	/* Allocate Rx buffers for the host descriptor ring */
+	if (c2_rx_fill(c2_port)) {
+		pr_debug("Unable to fill RX ring\n");
+		goto bail1;
+	}
+
+	/* Create the Tx host descriptor ring */
+	if ((ret =3D c2_tx_ring_alloc(&c2_port->tx_ring, c2_port->mem + rx_size=
,
+				    c2_port->dma + rx_size,
+				    c2dev->mmio_txp_ring))) {
+		pr_debug("Unable to create TX ring\n");
+		goto bail1;
+	}
+
+	/* Set the TX pointer to where we left off */
+	c2_port->tx_avail =3D c2_port->tx_ring.count - 1;
+	c2_port->tx_ring.to_use =3D c2_port->tx_ring.to_clean =3D
+	    c2_port->tx_ring.start + c2dev->cur_tx;
+
+	/* missing: Initialize MAC */
+
+	BUG_ON(c2_port->tx_ring.to_use !=3D c2_port->tx_ring.to_clean);
+
+	/* Reset the adapter, ensures the driver is in sync with the RXP */
+	c2_reset(c2_port);
+
+	/* Reset the READY bit in the sk_buff RXP headers & adapter HRXDQ */
+	for (i =3D 0, elem =3D c2_port->rx_ring.start; i < c2_port->rx_ring.cou=
nt;
+	     i++, elem++) {
+		rxp_hdr =3D (struct c2_rxp_hdr *) elem->skb->data;
+		rxp_hdr->flags =3D 0;
+		__raw_writew(cpu_to_be16(RXP_HRXD_READY),
+			     elem->hw_desc + C2_RXP_FLAGS);
+	}
+
+	/* Enable network packets */
+	netif_start_queue(netdev);
+
+	/* Enable IRQ */
+	writel(0, c2dev->regs + C2_IDIS);
+	netimr0 =3D readl(c2dev->regs + C2_NIMR0);
+	netimr0 &=3D ~(C2_PCI_HTX_INT | C2_PCI_HRX_INT);
+	writel(netimr0, c2dev->regs + C2_NIMR0);
+
+	/* Tell the stack to ignore arp requests for ipaddrs bound to=20
+	 * other interfaces.  This is needed to prevent the host stack
+	 * from responding to arp requests to the ipaddr bound on the
+	 * rdma interface.
+	 */
+	in_dev =3D in_dev_get(netdev);
+	in_dev->cnf.arp_ignore =3D 1;
+	in_dev_put(in_dev);
+
+	return 0;
+
+      bail1:
+	c2_rx_clean(c2_port);
+	kfree(c2_port->rx_ring.start);
+
+      bail0:
+	pci_free_consistent(c2dev->pcidev, c2_port->mem_size, c2_port->mem,
+			    c2_port->dma);
+
+	return ret;
+}
+
+static int c2_down(struct net_device *netdev)
+{
+	struct c2_port *c2_port =3D netdev_priv(netdev);
+	struct c2_dev *c2dev =3D c2_port->c2dev;
+
+	if (netif_msg_ifdown(c2_port))
+		pr_debug("%s: disabling interface\n",
+			netdev->name);
+
+	/* Wait for all the queued packets to get sent */
+	c2_tx_interrupt(netdev);
+
+	/* Disable network packets */
+	netif_stop_queue(netdev);
+
+	/* Disable IRQs by clearing the interrupt mask */
+	writel(1, c2dev->regs + C2_IDIS);
+	writel(0, c2dev->regs + C2_NIMR0);
+
+	/* missing: Stop transmitter */
+
+	/* missing: Stop receiver */
+
+	/* Reset the adapter, ensures the driver is in sync with the RXP */
+	c2_reset(c2_port);
+
+	/* missing: Turn off LEDs here */
+
+	/* Free all buffers in the host descriptor rings */
+	c2_tx_clean(c2_port);
+	c2_rx_clean(c2_port);
+
+	/* Free the host descriptor rings */
+	kfree(c2_port->rx_ring.start);
+	kfree(c2_port->tx_ring.start);
+	pci_free_consistent(c2dev->pcidev, c2_port->mem_size, c2_port->mem,
+			    c2_port->dma);
+
+	return 0;
+}
+
+static void c2_reset(struct c2_port *c2_port)
+{
+	struct c2_dev *c2dev =3D c2_port->c2dev;
+	unsigned int cur_rx =3D c2dev->cur_rx;
+
+	/* Tell the hardware to quiesce */
+	C2_SET_CUR_RX(c2dev, cur_rx | C2_PCI_HRX_QUI);
+
+	/*
+	 * The hardware will reset the C2_PCI_HRX_QUI bit once
+	 * the RXP is quiesced.  Wait 2 seconds for this.
+	 */
+	ssleep(2);
+
+	cur_rx =3D C2_GET_CUR_RX(c2dev);
+
+	if (cur_rx & C2_PCI_HRX_QUI)
+		pr_debug("c2_reset: failed to quiesce the hardware!\n");
+
+	cur_rx &=3D ~C2_PCI_HRX_QUI;
+
+	c2dev->cur_rx =3D cur_rx;
+
+	pr_debug("Current RX: %u\n", c2dev->cur_rx);
+}
+
+static int c2_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
+{
+	struct c2_port *c2_port =3D netdev_priv(netdev);
+	struct c2_dev *c2dev =3D c2_port->c2dev;
+	struct c2_ring *tx_ring =3D &c2_port->tx_ring;
+	struct c2_element *elem;
+	dma_addr_t mapaddr;
+	u32 maplen;
+	unsigned long flags;
+	unsigned int i;
+
+	spin_lock_irqsave(&c2_port->tx_lock, flags);
+
+	if (unlikely(c2_port->tx_avail < (skb_shinfo(skb)->nr_frags + 1))) {
+		netif_stop_queue(netdev);
+		spin_unlock_irqrestore(&c2_port->tx_lock, flags);
+
+		pr_debug("%s: Tx ring full when queue awake!\n",
+			netdev->name);
+		return NETDEV_TX_BUSY;
+	}
+
+	maplen =3D skb_headlen(skb);
+	mapaddr =3D
+	    pci_map_single(c2dev->pcidev, skb->data, maplen, PCI_DMA_TODEVICE);
+
+	elem =3D tx_ring->to_use;
+	elem->skb =3D skb;
+	elem->mapaddr =3D mapaddr;
+	elem->maplen =3D maplen;
+
+	/* Tell HW to xmit */
+	__raw_writeq(cpu_to_be64(mapaddr), elem->hw_desc + C2_TXP_ADDR);
+	__raw_writew(cpu_to_be16(maplen), elem->hw_desc + C2_TXP_LEN);
+	__raw_writew(cpu_to_be16(TXP_HTXD_READY), elem->hw_desc + C2_TXP_FLAGS)=
;
+
+	c2_port->netstats.tx_packets++;
+	c2_port->netstats.tx_bytes +=3D maplen;
+
+	/* Loop thru additional data fragments and queue them */
+	if (skb_shinfo(skb)->nr_frags) {
+		for (i =3D 0; i < skb_shinfo(skb)->nr_frags; i++) {
+			skb_frag_t *frag =3D &skb_shinfo(skb)->frags[i];
+			maplen =3D frag->size;
+			mapaddr =3D
+			    pci_map_page(c2dev->pcidev, frag->page,
+					 frag->page_offset, maplen,
+					 PCI_DMA_TODEVICE);
+
+			elem =3D elem->next;
+			elem->skb =3D NULL;
+			elem->mapaddr =3D mapaddr;
+			elem->maplen =3D maplen;
+
+			/* Tell HW to xmit */
+			__raw_writeq(cpu_to_be64(mapaddr),
+				     elem->hw_desc + C2_TXP_ADDR);
+			__raw_writew(cpu_to_be16(maplen),
+				     elem->hw_desc + C2_TXP_LEN);
+			__raw_writew(cpu_to_be16(TXP_HTXD_READY),
+				     elem->hw_desc + C2_TXP_FLAGS);
+
+			c2_port->netstats.tx_packets++;
+			c2_port->netstats.tx_bytes +=3D maplen;
+		}
+	}
+
+	tx_ring->to_use =3D elem->next;
+	c2_port->tx_avail -=3D (skb_shinfo(skb)->nr_frags + 1);
+
+	if (c2_port->tx_avail <=3D MAX_SKB_FRAGS + 1) {
+		netif_stop_queue(netdev);
+		if (netif_msg_tx_queued(c2_port))
+			pr_debug("%s: transmit queue full\n",
+				netdev->name);
+	}
+
+	spin_unlock_irqrestore(&c2_port->tx_lock, flags);
+
+	netdev->trans_start =3D jiffies;
+
+	return NETDEV_TX_OK;
+}
+
+static struct net_device_stats *c2_get_stats(struct net_device *netdev)
+{
+	struct c2_port *c2_port =3D netdev_priv(netdev);
+
+	return &c2_port->netstats;
+}
+
+static void c2_tx_timeout(struct net_device *netdev)
+{
+	struct c2_port *c2_port =3D netdev_priv(netdev);
+
+	if (netif_msg_timer(c2_port))
+		pr_debug("%s: tx timeout\n", netdev->name);
+
+	c2_tx_clean(c2_port);
+}
+
+static int c2_change_mtu(struct net_device *netdev, int new_mtu)
+{
+	int ret =3D 0;
+
+	if (new_mtu < ETH_ZLEN || new_mtu > ETH_JUMBO_MTU)
+		return -EINVAL;
+
+	netdev->mtu =3D new_mtu;
+
+	if (netif_running(netdev)) {
+		c2_down(netdev);
+
+		c2_up(netdev);
+	}
+
+	return ret;
+}
+
+/* Initialize network device */
+static struct net_device *c2_devinit(struct c2_dev *c2dev,
+				     void __iomem * mmio_addr)
+{
+	struct c2_port *c2_port =3D NULL;
+	struct net_device *netdev =3D alloc_etherdev(sizeof(*c2_port));
+
+	if (!netdev) {
+		pr_debug("c2_port etherdev alloc failed");
+		return NULL;
+	}
+
+	SET_MODULE_OWNER(netdev);
+	SET_NETDEV_DEV(netdev, &c2dev->pcidev->dev);
+
+	netdev->open =3D c2_up;
+	netdev->stop =3D c2_down;
+	netdev->hard_start_xmit =3D c2_xmit_frame;
+	netdev->get_stats =3D c2_get_stats;
+	netdev->tx_timeout =3D c2_tx_timeout;
+	netdev->change_mtu =3D c2_change_mtu;
+	netdev->watchdog_timeo =3D C2_TX_TIMEOUT;
+	netdev->irq =3D c2dev->pcidev->irq;
+
+	c2_port =3D netdev_priv(netdev);
+	c2_port->netdev =3D netdev;
+	c2_port->c2dev =3D c2dev;
+	c2_port->msg_enable =3D netif_msg_init(debug, default_msg);
+	c2_port->tx_ring.count =3D C2_NUM_TX_DESC;
+	c2_port->rx_ring.count =3D C2_NUM_RX_DESC;
+
+	spin_lock_init(&c2_port->tx_lock);
+
+	/* Copy our 48-bit ethernet hardware address */
+	memcpy_fromio(netdev->dev_addr, mmio_addr + C2_REGS_ENADDR, 6);
+
+	/* Validate the MAC address */
+	if (!is_valid_ether_addr(netdev->dev_addr)) {
+		pr_debug("Invalid MAC Address\n");
+		c2_print_macaddr(netdev);
+		free_netdev(netdev);
+		return NULL;
+	}
+
+	c2dev->netdev =3D netdev;
+
+	return netdev;
+}
+
+static int __devinit c2_probe(struct pci_dev *pcidev,
+			      const struct pci_device_id *ent)
+{
+	int ret =3D 0, i;
+	unsigned long reg0_start, reg0_flags, reg0_len;
+	unsigned long reg2_start, reg2_flags, reg2_len;
+	unsigned long reg4_start, reg4_flags, reg4_len;
+	unsigned kva_map_size;
+	struct net_device *netdev =3D NULL;
+	struct c2_dev *c2dev =3D NULL;
+	void __iomem *mmio_regs =3D NULL;
+
+	printk(KERN_INFO PFX "AMSO1100 Gigabit Ethernet driver v%s loaded\n",
+		DRV_VERSION);
+
+	/* Enable PCI device */
+	ret =3D pci_enable_device(pcidev);
+	if (ret) {
+		printk(KERN_ERR PFX "%s: Unable to enable PCI device\n",
+			pci_name(pcidev));
+		goto bail0;
+	}
+
+	reg0_start =3D pci_resource_start(pcidev, BAR_0);
+	reg0_len =3D pci_resource_len(pcidev, BAR_0);
+	reg0_flags =3D pci_resource_flags(pcidev, BAR_0);
+
+	reg2_start =3D pci_resource_start(pcidev, BAR_2);
+	reg2_len =3D pci_resource_len(pcidev, BAR_2);
+	reg2_flags =3D pci_resource_flags(pcidev, BAR_2);
+
+	reg4_start =3D pci_resource_start(pcidev, BAR_4);
+	reg4_len =3D pci_resource_len(pcidev, BAR_4);
+	reg4_flags =3D pci_resource_flags(pcidev, BAR_4);
+
+	pr_debug("BAR0 size =3D 0x%lX bytes\n", reg0_len);
+	pr_debug("BAR2 size =3D 0x%lX bytes\n", reg2_len);
+	pr_debug("BAR4 size =3D 0x%lX bytes\n", reg4_len);
+
+	/* Make sure PCI base addr are MMIO */
+	if (!(reg0_flags & IORESOURCE_MEM) ||
+	    !(reg2_flags & IORESOURCE_MEM) || !(reg4_flags & IORESOURCE_MEM)) {
+		printk(KERN_ERR PFX "PCI regions not an MMIO resource\n");
+		ret =3D -ENODEV;
+		goto bail1;
+	}
+
+	/* Check for weird/broken PCI region reporting */
+	if ((reg0_len < C2_REG0_SIZE) ||
+	    (reg2_len < C2_REG2_SIZE) || (reg4_len < C2_REG4_SIZE)) {
+		printk(KERN_ERR PFX "Invalid PCI region sizes\n");
+		ret =3D -ENODEV;
+		goto bail1;
+	}
+
+	/* Reserve PCI I/O and memory resources */
+	ret =3D pci_request_regions(pcidev, DRV_NAME);
+	if (ret) {
+		printk(KERN_ERR PFX "%s: Unable to request regions\n",
+			pci_name(pcidev));
+		goto bail1;
+	}
+
+	if ((sizeof(dma_addr_t) > 4)) {
+		ret =3D pci_set_dma_mask(pcidev, DMA_64BIT_MASK);
+		if (ret < 0) {
+			printk(KERN_ERR PFX "64b DMA configuration failed\n");
+			goto bail2;
+		}
+	} else {
+		ret =3D pci_set_dma_mask(pcidev, DMA_32BIT_MASK);
+		if (ret < 0) {
+			printk(KERN_ERR PFX "32b DMA configuration failed\n");
+			goto bail2;
+		}
+	}
+
+	/* Enables bus-mastering on the device */
+	pci_set_master(pcidev);
+
+	/* Remap the adapter PCI registers in BAR4 */
+	mmio_regs =3D ioremap_nocache(reg4_start + C2_PCI_REGS_OFFSET,
+				    sizeof(struct c2_adapter_pci_regs));
+	if (mmio_regs =3D=3D 0UL) {
+		printk(KERN_ERR PFX
+			"Unable to remap adapter PCI registers in BAR4\n");
+		ret =3D -EIO;
+		goto bail2;
+	}
+
+	/* Validate PCI regs magic */
+	for (i =3D 0; i < sizeof(c2_magic); i++) {
+		if (c2_magic[i] !=3D readb(mmio_regs + C2_REGS_MAGIC + i)) {
+			printk(KERN_ERR PFX "Downlevel Firmware boot loader "
+				"[%d/%Zd: got 0x%x, exp 0x%x]. Use the cc_flash "
+			       "utility to update your boot loader\n",
+				i + 1, sizeof(c2_magic),
+				readb(mmio_regs + C2_REGS_MAGIC + i),
+				c2_magic[i]);
+			printk(KERN_ERR PFX "Adapter not claimed\n");
+			iounmap(mmio_regs);
+			ret =3D -EIO;
+			goto bail2;
+		}
+	}
+
+	/* Validate the adapter version */
+	if (be32_to_cpu(readl(mmio_regs + C2_REGS_VERS)) !=3D C2_VERSION) {
+		printk(KERN_ERR PFX "Version mismatch "
+			"[fw=3D%u, c2=3D%u], Adapter not claimed\n",
+			be32_to_cpu(readl(mmio_regs + C2_REGS_VERS)),
+			C2_VERSION);
+		ret =3D -EINVAL;
+		iounmap(mmio_regs);
+		goto bail2;
+	}
+
+	/* Validate the adapter IVN */
+	if (be32_to_cpu(readl(mmio_regs + C2_REGS_IVN)) !=3D C2_IVN) {
+		printk(KERN_ERR PFX "Downlevel FIrmware level. You should be using "
+		       "the OpenIB device support kit. "
+		       "[fw=3D0x%x, c2=3D0x%x], Adapter not claimed\n",
+			be32_to_cpu(readl(mmio_regs + C2_REGS_IVN)),
+			C2_IVN);
+		ret =3D -EINVAL;
+		iounmap(mmio_regs);
+		goto bail2;
+	}
+
+	/* Allocate hardware structure */
+	c2dev =3D (struct c2_dev *) ib_alloc_device(sizeof(*c2dev));
+	if (!c2dev) {
+		printk(KERN_ERR PFX "%s: Unable to alloc hardware struct\n",
+			pci_name(pcidev));
+		ret =3D -ENOMEM;
+		iounmap(mmio_regs);
+		goto bail2;
+	}
+
+	memset(c2dev, 0, sizeof(*c2dev));
+	spin_lock_init(&c2dev->lock);
+	c2dev->pcidev =3D pcidev;
+	c2dev->cur_tx =3D 0;
+
+	/* Get the last RX index */
+	c2dev->cur_rx =3D
+	    (be32_to_cpu(readl(mmio_regs + C2_REGS_HRX_CUR)) -
+	     0xffffc000) / sizeof(struct c2_rxp_desc);
+
+	/* Request an interrupt line for the driver */
+	ret =3D request_irq(pcidev->irq, c2_interrupt, SA_SHIRQ, DRV_NAME, c2de=
v);
+	if (ret) {
+		printk(KERN_ERR PFX "%s: requested IRQ %u is busy\n",
+			pci_name(pcidev), pcidev->irq);
+		iounmap(mmio_regs);
+		goto bail3;
+	}
+
+	/* Set driver specific data */
+	pci_set_drvdata(pcidev, c2dev);
+
+	/* Initialize network device */
+	if ((netdev =3D c2_devinit(c2dev, mmio_regs)) =3D=3D NULL) {
+		iounmap(mmio_regs);
+		goto bail4;
+	}
+
+	/* Save off the actual size prior to unmapping mmio_regs */
+	kva_map_size =3D be32_to_cpu(readl(mmio_regs + C2_REGS_PCI_WINSIZE));
+
+	/* Unmap the adapter PCI registers in BAR4 */
+	iounmap(mmio_regs);
+
+	/* Register network device */
+	ret =3D register_netdev(netdev);
+	if (ret) {
+		printk(KERN_ERR PFX "Unable to register netdev, ret =3D %d\n",
+			ret);
+		goto bail5;
+	}
+
+	/* Disable network packets */
+	netif_stop_queue(netdev);
+
+	/* Remap the adapter HRXDQ PA space to kernel VA space */
+	c2dev->mmio_rxp_ring =3D ioremap_nocache(reg4_start + C2_RXP_HRXDQ_OFFS=
ET,
+					       C2_RXP_HRXDQ_SIZE);
+	if (c2dev->mmio_rxp_ring =3D=3D 0UL) {
+		printk(KERN_ERR PFX "Unable to remap MMIO HRXDQ region\n");
+		ret =3D -EIO;
+		goto bail6;
+	}
+
+	/* Remap the adapter HTXDQ PA space to kernel VA space */
+	c2dev->mmio_txp_ring =3D ioremap_nocache(reg4_start + C2_TXP_HTXDQ_OFFS=
ET,
+					       C2_TXP_HTXDQ_SIZE);
+	if (c2dev->mmio_txp_ring =3D=3D 0UL) {
+		printk(KERN_ERR PFX "Unable to remap MMIO HTXDQ region\n");
+		ret =3D -EIO;
+		goto bail7;
+	}
+
+	/* Save off the current RX index in the last 4 bytes of the TXP Ring */
+	C2_SET_CUR_RX(c2dev, c2dev->cur_rx);
+
+	/* Remap the PCI registers in adapter BAR0 to kernel VA space */
+	c2dev->regs =3D ioremap_nocache(reg0_start, reg0_len);
+	if (c2dev->regs =3D=3D 0UL) {
+		printk(KERN_ERR PFX "Unable to remap BAR0\n");
+		ret =3D -EIO;
+		goto bail8;
+	}
+
+	/* Remap the PCI registers in adapter BAR4 to kernel VA space */
+	c2dev->pa =3D reg4_start + C2_PCI_REGS_OFFSET;
+	c2dev->kva =3D ioremap_nocache(reg4_start + C2_PCI_REGS_OFFSET,=20
+				     kva_map_size);
+	if (c2dev->kva =3D=3D 0UL) {
+		printk(KERN_ERR PFX "Unable to remap BAR4\n");
+		ret =3D -EIO;
+		goto bail9;
+	}
+
+	/* Print out the MAC address */
+	c2_print_macaddr(netdev);
+
+	ret =3D c2_rnic_init(c2dev);
+	if (ret) {
+		printk(KERN_ERR PFX "c2_rnic_init failed: %d\n", ret);
+		goto bail10;
+	}
+
+	c2_register_device(c2dev);
+
+	return 0;
+
+ bail10:
+	iounmap(c2dev->kva);
+
+ bail9:
+	iounmap(c2dev->regs);
+
+ bail8:
+	iounmap(c2dev->mmio_txp_ring);
+
+ bail7:
+	iounmap(c2dev->mmio_rxp_ring);
+
+ bail6:
+	unregister_netdev(netdev);
+
+ bail5:
+	free_netdev(netdev);
+
+ bail4:
+	free_irq(pcidev->irq, c2dev);
+
+ bail3:
+	ib_dealloc_device(&c2dev->ibdev);
+
+ bail2:
+	pci_release_regions(pcidev);
+
+ bail1:
+	pci_disable_device(pcidev);
+
+ bail0:
+	return ret;
+}
+
+static void __devexit c2_remove(struct pci_dev *pcidev)
+{
+	struct c2_dev *c2dev =3D pci_get_drvdata(pcidev);
+	struct net_device *netdev =3D c2dev->netdev;
+
+	/* Unregister with OpenIB */
+	c2_unregister_device(c2dev);
+
+	/* Clean up the RNIC resources */
+	c2_rnic_term(c2dev);
+
+	/* Remove network device from the kernel */
+	unregister_netdev(netdev);
+
+	/* Free network device */
+	free_netdev(netdev);
+
+	/* Free the interrupt line */
+	free_irq(pcidev->irq, c2dev);
+
+	/* missing: Turn LEDs off here */
+
+	/* Unmap adapter PA space */
+	iounmap(c2dev->kva);
+	iounmap(c2dev->regs);
+	iounmap(c2dev->mmio_txp_ring);
+	iounmap(c2dev->mmio_rxp_ring);
+
+	/* Free the hardware structure */
+	ib_dealloc_device(&c2dev->ibdev);
+
+	/* Release reserved PCI I/O and memory resources */
+	pci_release_regions(pcidev);
+
+	/* Disable PCI device */
+	pci_disable_device(pcidev);
+
+	/* Clear driver specific data */
+	pci_set_drvdata(pcidev, NULL);
+}
+
+static struct pci_driver c2_pci_driver =3D {
+	.name =3D DRV_NAME,
+	.id_table =3D c2_pci_table,
+	.probe =3D c2_probe,
+	.remove =3D __devexit_p(c2_remove),
+};
+
+static int __init c2_init_module(void)
+{
+	return pci_module_init(&c2_pci_driver);
+}
+
+static void __exit c2_exit_module(void)
+{
+	pci_unregister_driver(&c2_pci_driver);
+}
+
+module_init(c2_init_module);
+module_exit(c2_exit_module);
diff --git a/drivers/infiniband/hw/amso1100/c2.h b/drivers/infiniband/hw/=
amso1100/c2.h
new file mode 100644
index 0000000..3251e8f
--- /dev/null
+++ b/drivers/infiniband/hw/amso1100/c2.h
@@ -0,0 +1,555 @@
+/*
+ * Copyright (c) 2005 Ammasso, Inc. All rights reserved.
+ * Copyright (c) 2005 Open Grid Computing, Inc. All rights reserved.
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * OpenIB.org BSD license below:
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      - Redistributions of source code must retain the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer.
+ *
+ *      - Redistributions in binary form must reproduce the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer in the documentation and/or other materials
+ *        provided with the distribution.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ */
+
+#ifndef __C2_H
+#define __C2_H
+
+#include <linux/netdevice.h>
+#include <linux/spinlock.h>
+#include <linux/kernel.h>
+#include <linux/pci.h>
+#include <linux/dma-mapping.h>
+#include <asm/semaphore.h>
+
+#include "c2_provider.h"
+#include "c2_mq.h"
+#include "c2_status.h"
+
+#define DRV_NAME     "c2"
+#define DRV_VERSION  "1.1"
+#define PFX          DRV_NAME ": "
+
+#define BAR_0                0
+#define BAR_2                2
+#define BAR_4                4
+
+#define RX_BUF_SIZE         (1536 + 8)
+#define ETH_JUMBO_MTU        9000
+#define C2_MAGIC            "CEPHEUS"
+#define C2_VERSION           4
+#define C2_IVN              (18 & 0x7fffffff)
+
+#define C2_REG0_SIZE        (16 * 1024)
+#define C2_REG2_SIZE        (2 * 1024 * 1024)
+#define C2_REG4_SIZE        (256 * 1024 * 1024)
+#define C2_NUM_TX_DESC       341
+#define C2_NUM_RX_DESC       256
+#define C2_PCI_REGS_OFFSET  (0x10000)
+#define C2_RXP_HRXDQ_OFFSET (((C2_REG4_SIZE)/2))
+#define C2_RXP_HRXDQ_SIZE   (4096)
+#define C2_TXP_HTXDQ_OFFSET (((C2_REG4_SIZE)/2) + C2_RXP_HRXDQ_SIZE)
+#define C2_TXP_HTXDQ_SIZE   (4096)
+#define C2_TX_TIMEOUT	    (6*HZ)
+
+/* CEPHEUS */
+static const u8 c2_magic[] =3D {
+	0x43, 0x45, 0x50, 0x48, 0x45, 0x55, 0x53
+};
+
+enum adapter_pci_regs {
+	C2_REGS_MAGIC =3D 0x0000,
+	C2_REGS_VERS =3D 0x0008,
+	C2_REGS_IVN =3D 0x000C,
+	C2_REGS_PCI_WINSIZE =3D 0x0010,
+	C2_REGS_Q0_QSIZE =3D 0x0014,
+	C2_REGS_Q0_MSGSIZE =3D 0x0018,
+	C2_REGS_Q0_POOLSTART =3D 0x001C,
+	C2_REGS_Q0_SHARED =3D 0x0020,
+	C2_REGS_Q1_QSIZE =3D 0x0024,
+	C2_REGS_Q1_MSGSIZE =3D 0x0028,
+	C2_REGS_Q1_SHARED =3D 0x0030,
+	C2_REGS_Q2_QSIZE =3D 0x0034,
+	C2_REGS_Q2_MSGSIZE =3D 0x0038,
+	C2_REGS_Q2_SHARED =3D 0x0040,
+	C2_REGS_ENADDR =3D 0x004C,
+	C2_REGS_RDMA_ENADDR =3D 0x0054,
+	C2_REGS_HRX_CUR =3D 0x006C,
+};
+
+struct c2_adapter_pci_regs {
+	char reg_magic[8];
+	u32 version;
+	u32 ivn;
+	u32 pci_window_size;
+	u32 q0_q_size;
+	u32 q0_msg_size;
+	u32 q0_pool_start;
+	u32 q0_shared;
+	u32 q1_q_size;
+	u32 q1_msg_size;
+	u32 q1_pool_start;
+	u32 q1_shared;
+	u32 q2_q_size;
+	u32 q2_msg_size;
+	u32 q2_pool_start;
+	u32 q2_shared;
+	u32 log_start;
+	u32 log_size;
+	u8 host_enaddr[8];
+	u8 rdma_enaddr[8];
+	u32 crash_entry;
+	u32 crash_ready[2];
+	u32 fw_txd_cur;
+	u32 fw_hrxd_cur;
+	u32 fw_rxd_cur;
+};
+
+enum pci_regs {
+	C2_HISR =3D 0x0000,
+	C2_DISR =3D 0x0004,
+	C2_HIMR =3D 0x0008,
+	C2_DIMR =3D 0x000C,
+	C2_NISR0 =3D 0x0010,
+	C2_NISR1 =3D 0x0014,
+	C2_NIMR0 =3D 0x0018,
+	C2_NIMR1 =3D 0x001C,
+	C2_IDIS =3D 0x0020,
+};
+
+enum {
+	C2_PCI_HRX_INT =3D 1 << 8,
+	C2_PCI_HTX_INT =3D 1 << 17,
+	C2_PCI_HRX_QUI =3D 1 << 31,
+};
+
+/*
+ * Cepheus registers in BAR0.
+ */
+struct c2_pci_regs {
+	u32 hostisr;
+	u32 dmaisr;
+	u32 hostimr;
+	u32 dmaimr;
+	u32 netisr0;
+	u32 netisr1;
+	u32 netimr0;
+	u32 netimr1;
+	u32 int_disable;
+};
+
+/* TXP flags */
+enum c2_txp_flags {
+	TXP_HTXD_DONE =3D 0,
+	TXP_HTXD_READY =3D 1 << 0,
+	TXP_HTXD_UNINIT =3D 1 << 1,
+};
+
+/* RXP flags */
+enum c2_rxp_flags {
+	RXP_HRXD_UNINIT =3D 0,
+	RXP_HRXD_READY =3D 1 << 0,
+	RXP_HRXD_DONE =3D 1 << 1,
+};
+
+/* RXP status */
+enum c2_rxp_status {
+	RXP_HRXD_ZERO =3D 0,
+	RXP_HRXD_OK =3D 1 << 0,
+	RXP_HRXD_BUF_OV =3D 1 << 1,
+};
+
+/* TXP descriptor fields */
+enum txp_desc {
+	C2_TXP_FLAGS =3D 0x0000,
+	C2_TXP_LEN =3D 0x0002,
+	C2_TXP_ADDR =3D 0x0004,
+};
+
+/* RXP descriptor fields */
+enum rxp_desc {
+	C2_RXP_FLAGS =3D 0x0000,
+	C2_RXP_STATUS =3D 0x0002,
+	C2_RXP_COUNT =3D 0x0004,
+	C2_RXP_LEN =3D 0x0006,
+	C2_RXP_ADDR =3D 0x0008,
+};
+
+struct c2_txp_desc {
+	u16 flags;
+	u16 len;
+	u64 addr;
+} __attribute__ ((packed));
+
+struct c2_rxp_desc {
+	u16 flags;
+	u16 status;
+	u16 count;
+	u16 len;
+	u64 addr;
+} __attribute__ ((packed));
+
+struct c2_rxp_hdr {
+	u16 flags;
+	u16 status;
+	u16 len;
+	u16 rsvd;
+} __attribute__ ((packed));
+
+struct c2_tx_desc {
+	u32 len;
+	u32 status;
+	dma_addr_t next_offset;
+};
+
+struct c2_rx_desc {
+	u32 len;
+	u32 status;
+	dma_addr_t next_offset;
+};
+
+struct c2_alloc {
+	u32 last;
+	u32 max;
+	spinlock_t lock;
+	unsigned long *table;
+};
+
+struct c2_array {
+	struct {
+		void **page;
+		int used;
+	} *page_list;
+};
+
+/*
+ * The MQ shared pointer pool is organized as a linked list of
+ * chunks. Each chunk contains a linked list of free shared pointers
+ * that can be allocated to a given user mode client.
+ *
+ */
+struct sp_chunk {
+	struct sp_chunk *next;
+	gfp_t gfp_mask;
+	u16 head;
+	u16 shared_ptr[0];
+};
+
+struct c2_pd_table {
+	struct c2_alloc alloc;
+	struct c2_array pd;
+};
+
+struct c2_qp_table {
+	struct c2_alloc alloc;
+	spinlock_t lock;
+	struct c2_array qp;
+	struct c2_qp** map;
+};
+
+struct c2_element {
+	struct c2_element *next;
+	void *ht_desc;		/* host     descriptor */
+	void __iomem *hw_desc;	/* hardware descriptor */
+	struct sk_buff *skb;
+	dma_addr_t mapaddr;
+	u32 maplen;
+};
+
+struct c2_ring {
+	struct c2_element *to_clean;
+	struct c2_element *to_use;
+	struct c2_element *start;
+	unsigned long count;
+};
+
+struct c2_dev {
+	struct ib_device ibdev;
+	void __iomem *regs;
+	void __iomem *mmio_txp_ring; /* remapped adapter memory for hw rings */
+	void __iomem *mmio_rxp_ring;
+	spinlock_t lock;
+	struct pci_dev *pcidev;
+	struct net_device *netdev;
+	struct net_device *pseudo_netdev;
+	unsigned int cur_tx;
+	unsigned int cur_rx;
+	u32 adapter_handle;
+	int device_cap_flags;
+	void __iomem *kva;	/* KVA device memory */
+	unsigned long pa;	/* PA device memory */
+	void **qptr_array;
+
+	kmem_cache_t *host_msg_cache;
+
+	struct list_head cca_link;		/* adapter list */
+	struct list_head eh_wakeup_list;	/* event wakeup list */
+	wait_queue_head_t req_vq_wo;
+
+	/* Cached RNIC properties */
+	struct ib_device_attr props;
+
+	struct c2_pd_table pd_table;
+	struct c2_qp_table qp_table;
+	int ports;		/* num of GigE ports */
+	int devnum;
+	spinlock_t vqlock;	/* sync vbs req MQ */
+
+	/* Verbs Queues */
+	struct c2_mq req_vq;	/* Verbs Request MQ */
+	struct c2_mq rep_vq;	/* Verbs Reply MQ */
+	struct c2_mq aeq;	/* Async Events MQ */
+
+	/* Kernel client MQs */
+	struct sp_chunk *kern_mqsp_pool;
+
+	/* Device updates these values when posting messages to a host
+	 * target queue */
+	u16 req_vq_shared;
+	u16 rep_vq_shared;
+	u16 aeq_shared;
+	u16 irq_claimed;
+
+	/*
+	 * Shared host target pages for user-accessible MQs.
+	 */
+	int hthead;		/* index of first free entry */
+	void *htpages;		/* kernel vaddr */
+	int htlen;		/* length of htpages memory */
+	void *htuva;		/* user mapped vaddr */
+	spinlock_t htlock;	/* serialize allocation */
+
+	u64 adapter_hint_uva;	/* access to the activity FIFO */
+
+	//	spinlock_t aeq_lock;
+	//	spinlock_t rnic_lock;
+
+	u16 hint_count;
+	u16 hints_read;
+
+	int init;		/* TRUE if it's ready */
+	char ae_cache_name[16];
+	char vq_cache_name[16];
+};
+
+struct c2_port {
+	u32 msg_enable;
+	struct c2_dev *c2dev;
+	struct net_device *netdev;
+
+	spinlock_t tx_lock;
+	u32 tx_avail;
+	struct c2_ring tx_ring;
+	struct c2_ring rx_ring;
+
+	void *mem;		/* PCI memory for host rings */
+	dma_addr_t dma;
+	unsigned long mem_size;
+
+	u32 rx_buf_size;
+
+	struct net_device_stats netstats;
+};
+
+/*
+ * Activity FIFO registers in BAR0.
+ */
+#define PCI_BAR0_HOST_HINT	0x100
+#define PCI_BAR0_ADAPTER_HINT	0x2000
+
+/*
+ * Ammasso PCI vendor id and Cepheus PCI device id.
+ */
+#define CQ_ARMED 	0x01
+#define CQ_WAIT_FOR_DMA	0x80
+
+/*
+ * The format of a hint is as follows:
+ * Lower 16 bits are the count of hints for the queue.
+ * Next 15 bits are the qp_index
+ * Upper most bit depends on who reads it:
+ *    If read by producer, then it means Full (1) or Not-Full (0)
+ *    If read by consumer, then it means Empty (1) or Not-Empty (0)
+ */
+#define C2_HINT_MAKE(q_index, hint_count) (((q_index) << 16) | hint_coun=
t)
+#define C2_HINT_GET_INDEX(hint) (((hint) & 0x7FFF0000) >> 16)
+#define C2_HINT_GET_COUNT(hint) ((hint) & 0x0000FFFF)
+
+
+/*
+ * The following defines the offset in SDRAM for the c2_adapter_pci_regs=
_t
+ * struct.=20
+ */
+#define C2_ADAPTER_PCI_REGS_OFFSET 0x10000
+
+#ifndef readq
+static inline u64 readq(const void __iomem * addr)
+{
+	u64 ret =3D readl(addr + 4);
+	ret <<=3D 32;
+	ret |=3D readl(addr);
+
+	return ret;
+}
+#endif
+
+#ifndef __raw_writeq
+static inline void __raw_writeq(u64 val, void __iomem * addr)
+{
+	__raw_writel((u32) (val), addr);
+	__raw_writel((u32) (val >> 32), (addr + 4));
+}
+#endif
+
+#define C2_SET_CUR_RX(c2dev, cur_rx) \
+	__raw_writel(cpu_to_be32(cur_rx), c2dev->mmio_txp_ring + 4092)
+
+#define C2_GET_CUR_RX(c2dev) \
+	be32_to_cpu(readl(c2dev->mmio_txp_ring + 4092))
+
+static inline struct c2_dev *to_c2dev(struct ib_device *ibdev)
+{
+	return container_of(ibdev, struct c2_dev, ibdev);
+}
+
+static inline int c2_errno(void *reply)
+{
+	switch (c2_wr_get_result(reply)) {
+	case C2_OK:
+		return 0;
+	case CCERR_NO_BUFS:
+	case CCERR_INSUFFICIENT_RESOURCES:
+	case CCERR_ZERO_RDMA_READ_RESOURCES:
+		return -ENOMEM;
+	case CCERR_MR_IN_USE:
+	case CCERR_QP_IN_USE:
+		return -EBUSY;
+	case CCERR_ADDR_IN_USE:
+		return -EADDRINUSE;
+	case CCERR_ADDR_NOT_AVAIL:
+		return -EADDRNOTAVAIL;
+	case CCERR_CONN_RESET:
+		return -ECONNRESET;
+	case CCERR_NOT_IMPLEMENTED:
+	case CCERR_INVALID_WQE:
+		return -ENOSYS;
+	case CCERR_QP_NOT_PRIVILEGED:
+		return -EPERM;
+	case CCERR_STACK_ERROR:
+		return -EPROTO;
+	case CCERR_ACCESS_VIOLATION:
+	case CCERR_BASE_AND_BOUNDS_VIOLATION:
+		return -EFAULT;
+	case CCERR_STAG_STATE_NOT_INVALID:
+	case CCERR_INVALID_ADDRESS:
+	case CCERR_INVALID_CQ:
+	case CCERR_INVALID_EP:
+	case CCERR_INVALID_MODIFIER:
+	case CCERR_INVALID_MTU:
+	case CCERR_INVALID_PD_ID:
+	case CCERR_INVALID_QP:
+	case CCERR_INVALID_RNIC:
+	case CCERR_INVALID_STAG:
+		return -EINVAL;
+	default:
+		return -EAGAIN;
+	}
+}
+
+/* Device */
+extern int c2_register_device(struct c2_dev *c2dev);
+extern void c2_unregister_device(struct c2_dev *c2dev);
+extern int c2_rnic_init(struct c2_dev *c2dev);
+extern void c2_rnic_term(struct c2_dev *c2dev);
+extern void c2_rnic_interrupt(struct c2_dev *c2dev);
+extern int c2_rnic_query(struct c2_dev *c2dev, struct ib_device_attr *pr=
ops);
+extern int c2_del_addr(struct c2_dev *c2dev, u32 inaddr, u32 inmask);
+extern int c2_add_addr(struct c2_dev *c2dev, u32 inaddr, u32 inmask);
+
+/* QPs */
+extern int c2_alloc_qp(struct c2_dev *c2dev, struct c2_pd *pd,
+		       struct ib_qp_init_attr *qp_attrs, struct c2_qp *qp);
+extern void c2_free_qp(struct c2_dev *c2dev, struct c2_qp *qp);
+extern struct ib_qp *c2_get_qp(struct ib_device *device, int qpn);
+extern int c2_qp_modify(struct c2_dev *c2dev, struct c2_qp *qp,
+			struct ib_qp_attr *attr, int attr_mask);
+extern int c2_qp_set_read_limits(struct c2_dev *c2dev, struct c2_qp *qp,=
=20
+				 int ord, int ird);
+extern int c2_post_send(struct ib_qp *ibqp, struct ib_send_wr *ib_wr,
+			struct ib_send_wr **bad_wr);
+extern int c2_post_receive(struct ib_qp *ibqp, struct ib_recv_wr *ib_wr,
+			   struct ib_recv_wr **bad_wr);
+extern int __devinit c2_init_qp_table(struct c2_dev *c2dev);
+extern void __devexit c2_cleanup_qp_table(struct c2_dev *c2dev);
+extern void c2_set_qp_state(struct c2_qp *, int);
+
+/* PDs */
+extern int c2_pd_alloc(struct c2_dev *c2dev, int privileged, struct c2_p=
d *pd);
+extern void c2_pd_free(struct c2_dev *c2dev, struct c2_pd *pd);
+extern int __devinit c2_init_pd_table(struct c2_dev *c2dev);
+extern void __devexit c2_cleanup_pd_table(struct c2_dev *c2dev);
+
+/* CQs */
+extern int c2_init_cq(struct c2_dev *c2dev, int entries,
+		      struct c2_ucontext *ctx, struct c2_cq *cq);
+extern void c2_free_cq(struct c2_dev *c2dev, struct c2_cq *cq);
+extern void c2_cq_event(struct c2_dev *c2dev, u32 mq_index);
+extern void c2_cq_clean(struct c2_dev *c2dev, struct c2_qp *qp, u32 mq_i=
ndex);
+extern int c2_poll_cq(struct ib_cq *ibcq, int num_entries, struct ib_wc =
*entry);
+extern int c2_arm_cq(struct ib_cq *ibcq, enum ib_cq_notify notify);
+
+/* CM */
+extern int c2_llp_connect(struct iw_cm_id *cm_id,=20
+			  struct iw_cm_conn_param *iw_param);
+extern int c2_llp_accept(struct iw_cm_id *cm_id,=20
+			 struct iw_cm_conn_param *iw_param);
+extern int c2_llp_reject(struct iw_cm_id *cm_id, const void *pdata,
+			 u8 pdata_len);
+extern int c2_llp_service_create(struct iw_cm_id *cm_id, int backlog);
+extern int c2_llp_service_destroy(struct iw_cm_id *cm_id);
+
+/* MM */
+extern int c2_nsmr_register_phys_kern(struct c2_dev *c2dev, u64 *addr_li=
st,
+ 				      int page_size, int pbl_depth, u32 length,=20
+ 				      u32 off, u64 *va, enum c2_acf acf,=20
+				      struct c2_mr *mr);
+extern int c2_stag_dealloc(struct c2_dev *c2dev, u32 stag_index);
+
+/* AE */
+extern void c2_ae_event(struct c2_dev *c2dev, u32 mq_index);
+
+/* Allocators */
+extern u32 c2_alloc(struct c2_alloc *alloc);
+extern void c2_free(struct c2_alloc *alloc, u32 obj);
+extern int c2_alloc_init(struct c2_alloc *alloc, u32 num, u32 reserved);
+extern void c2_alloc_cleanup(struct c2_alloc *alloc);
+extern int c2_init_mqsp_pool(gfp_t gfp_mask, struct sp_chunk **root);
+extern void c2_free_mqsp_pool(struct sp_chunk *root);
+extern u16 *c2_alloc_mqsp(struct sp_chunk *head);
+extern void c2_free_mqsp(u16 * mqsp);
+extern void c2_array_cleanup(struct c2_array *array, int nent);
+extern int c2_array_init(struct c2_array *array, int nent);
+extern void c2_array_clear(struct c2_array *array, int index);
+extern int c2_array_set(struct c2_array *array, int index, void *value);
+extern void *c2_array_get(struct c2_array *array, int index);
+
+#endif
diff --git a/drivers/infiniband/hw/amso1100/c2_ae.c b/drivers/infiniband/=
hw/amso1100/c2_ae.c
new file mode 100644
index 0000000..c979ef6
--- /dev/null
+++ b/drivers/infiniband/hw/amso1100/c2_ae.c
@@ -0,0 +1,359 @@
+/*
+ * Copyright (c) 2005 Ammasso, Inc. All rights reserved.
+ * Copyright (c) 2005 Open Grid Computing, Inc. All rights reserved.
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * OpenIB.org BSD license below:
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      - Redistributions of source code must retain the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer.
+ *
+ *      - Redistributions in binary form must reproduce the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer in the documentation and/or other materials
+ *        provided with the distribution.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ */
+#include "c2.h"
+#include <rdma/iw_cm.h>
+#include "c2_status.h"
+#include "c2_ae.h"
+
+static int c2_convert_cm_status(u32 c2_status)
+{
+	switch (c2_status) {
+	case C2_CONN_STATUS_SUCCESS:
+		return 0;
+	case C2_CONN_STATUS_REJECTED:
+		return -ENETRESET;
+	case C2_CONN_STATUS_REFUSED:
+		return -ECONNREFUSED;
+	case C2_CONN_STATUS_TIMEDOUT:
+		return -ETIMEDOUT;
+	case C2_CONN_STATUS_NETUNREACH:
+		return -ENETUNREACH;
+	case C2_CONN_STATUS_HOSTUNREACH:
+		return -EHOSTUNREACH;
+	case C2_CONN_STATUS_INVALID_RNIC:
+		return -EINVAL;
+	case C2_CONN_STATUS_INVALID_QP:
+		return -EINVAL;
+	case C2_CONN_STATUS_INVALID_QP_STATE:
+		return -EINVAL;
+	case C2_CONN_STATUS_ADDR_NOT_AVAIL:
+		return -EADDRNOTAVAIL;
+	default:
+		printk(KERN_ERR PFX
+		       "%s - Unable to convert CM status: %d\n",
+		       __FUNCTION__, c2_status);
+		return -EIO;
+	}
+}
+
+#ifdef DEBUG
+static const char* to_event_str(int event)
+{
+	static const char* event_str[] =3D {
+		"CCAE_REMOTE_SHUTDOWN",
+		"CCAE_ACTIVE_CONNECT_RESULTS",
+		"CCAE_CONNECTION_REQUEST",
+		"CCAE_LLP_CLOSE_COMPLETE",
+		"CCAE_TERMINATE_MESSAGE_RECEIVED",
+		"CCAE_LLP_CONNECTION_RESET",
+		"CCAE_LLP_CONNECTION_LOST",
+		"CCAE_LLP_SEGMENT_SIZE_INVALID",
+		"CCAE_LLP_INVALID_CRC",
+		"CCAE_LLP_BAD_FPDU",
+		"CCAE_INVALID_DDP_VERSION",
+		"CCAE_INVALID_RDMA_VERSION",
+		"CCAE_UNEXPECTED_OPCODE",
+		"CCAE_INVALID_DDP_QUEUE_NUMBER",
+		"CCAE_RDMA_READ_NOT_ENABLED",
+		"CCAE_RDMA_WRITE_NOT_ENABLED",
+		"CCAE_RDMA_READ_TOO_SMALL",
+		"CCAE_NO_L_BIT",
+		"CCAE_TAGGED_INVALID_STAG",
+		"CCAE_TAGGED_BASE_BOUNDS_VIOLATION",
+		"CCAE_TAGGED_ACCESS_RIGHTS_VIOLATION",
+		"CCAE_TAGGED_INVALID_PD",
+		"CCAE_WRAP_ERROR",
+		"CCAE_BAD_CLOSE",
+		"CCAE_BAD_LLP_CLOSE",
+		"CCAE_INVALID_MSN_RANGE",
+		"CCAE_INVALID_MSN_GAP",
+		"CCAE_IRRQ_OVERFLOW",
+		"CCAE_IRRQ_MSN_GAP",
+		"CCAE_IRRQ_MSN_RANGE",
+		"CCAE_IRRQ_INVALID_STAG",
+		"CCAE_IRRQ_BASE_BOUNDS_VIOLATION",
+		"CCAE_IRRQ_ACCESS_RIGHTS_VIOLATION",
+		"CCAE_IRRQ_INVALID_PD",
+		"CCAE_IRRQ_WRAP_ERROR",
+		"CCAE_CQ_SQ_COMPLETION_OVERFLOW",
+		"CCAE_CQ_RQ_COMPLETION_ERROR",
+		"CCAE_QP_SRQ_WQE_ERROR",
+		"CCAE_QP_LOCAL_CATASTROPHIC_ERROR",
+		"CCAE_CQ_OVERFLOW",
+		"CCAE_CQ_OPERATION_ERROR",
+		"CCAE_SRQ_LIMIT_REACHED",
+		"CCAE_QP_RQ_LIMIT_REACHED",
+		"CCAE_SRQ_CATASTROPHIC_ERROR",
+		"CCAE_RNIC_CATASTROPHIC_ERROR"
+	};
+
+	if (event < CCAE_REMOTE_SHUTDOWN ||=20
+	    event > CCAE_RNIC_CATASTROPHIC_ERROR)
+		return "<invalid event>";
+
+	event -=3D CCAE_REMOTE_SHUTDOWN;
+	return event_str[event];
+}
+
+const char *to_qp_state_str(int state)
+{
+	switch (state) {
+	case C2_QP_STATE_IDLE:
+		return "C2_QP_STATE_IDLE";
+	case C2_QP_STATE_CONNECTING:
+		return "C2_QP_STATE_CONNECTING";
+	case C2_QP_STATE_RTS:
+		return "C2_QP_STATE_RTS";
+	case C2_QP_STATE_CLOSING:
+		return "C2_QP_STATE_CLOSING";
+	case C2_QP_STATE_TERMINATE:
+		return "C2_QP_STATE_TERMINATE";
+	case C2_QP_STATE_ERROR:
+		return "C2_QP_STATE_ERROR";
+	default:
+		return "<invalid QP state>";
+	};
+}
+#endif
+
+void c2_ae_event(struct c2_dev *c2dev, u32 mq_index)
+{
+	struct c2_mq *mq =3D c2dev->qptr_array[mq_index];
+	union c2wr *wr;
+	void *resource_user_context;
+	struct iw_cm_event cm_event;
+	struct ib_event ib_event;
+	enum c2_resource_indicator resource_indicator;
+	enum c2_event_id event_id;
+	unsigned long flags;
+	u8 *pdata =3D NULL;
+	int status;
+
+	/*
+	 * retreive the message
+	 */
+	wr =3D c2_mq_consume(mq);
+	if (!wr)
+		return;
+
+	memset(&ib_event, 0, sizeof(ib_event));
+	memset(&cm_event, 0, sizeof(cm_event));
+
+	event_id =3D c2_wr_get_id(wr);
+	resource_indicator =3D be32_to_cpu(wr->ae.ae_generic.resource_type);
+	resource_user_context =3D
+	    (void *) (unsigned long) wr->ae.ae_generic.user_context;
+
+	status =3D cm_event.status =3D c2_convert_cm_status(c2_wr_get_result(wr=
));
+
+	pr_debug("event received c2_dev=3D%p, event_id=3D%d, "
+		"resource_indicator=3D%d, user_context=3D%p, status =3D %d\n",
+		c2dev, event_id, resource_indicator, resource_user_context,=20
+		status);
+
+	switch (resource_indicator) {
+	case C2_RES_IND_QP:{
+
+		struct c2_qp *qp =3D (struct c2_qp *)resource_user_context;
+		struct iw_cm_id *cm_id =3D qp->cm_id;
+		struct c2wr_ae_active_connect_results *res;
+
+		if (!cm_id) {
+			pr_debug("event received, but cm_id is <nul>, qp=3D%p!\n",
+				qp);
+			goto ignore_it;
+		}
+		pr_debug("%s: event =3D %s, user_context=3D%llx, "
+			"resource_type=3D%x, "
+			"resource=3D%x, qp_state=3D%s\n",
+			__FUNCTION__,
+			to_event_str(event_id),
+			be64_to_cpu(wr->ae.ae_generic.user_context),
+			be32_to_cpu(wr->ae.ae_generic.resource_type),
+			be32_to_cpu(wr->ae.ae_generic.resource),
+			to_qp_state_str(be32_to_cpu(wr->ae.ae_generic.qp_state)));
+		=09
+		c2_set_qp_state(qp, be32_to_cpu(wr->ae.ae_generic.qp_state));
+
+		switch (event_id) {
+		case CCAE_ACTIVE_CONNECT_RESULTS:
+			res =3D &wr->ae.ae_active_connect_results;
+			cm_event.event =3D IW_CM_EVENT_CONNECT_REPLY;
+			cm_event.local_addr.sin_addr.s_addr =3D res->laddr;
+			cm_event.remote_addr.sin_addr.s_addr =3D res->raddr;
+			cm_event.local_addr.sin_port =3D res->lport;
+			cm_event.remote_addr.sin_port =3D	res->rport;
+			if (status =3D=3D 0) {
+				cm_event.private_data_len =3D=20
+					be32_to_cpu(res->private_data_length);
+			} else {
+				spin_lock_irqsave(&qp->lock, flags);
+				if (qp->cm_id) {
+					qp->cm_id->rem_ref(qp->cm_id);
+					qp->cm_id =3D NULL;
+				}
+				spin_unlock_irqrestore(&qp->lock, flags);
+				cm_event.private_data_len =3D 0;
+				cm_event.private_data =3D NULL;
+			}
+			if (cm_event.private_data_len) {
+				/* copy private data */
+				pdata =3D
+				    kmalloc(cm_event.private_data_len,
+					    GFP_ATOMIC);
+				if (!pdata) {
+					/* Ignore the request, maybe the=20
+					 * remote peer will retry */
+					pr_debug ("Ignored connect request -- "
+						 "no memory for pdata"
+						 "private_data_len=3D%d\n",
+						 cm_event.private_data_len);
+					goto ignore_it;
+				}
+
+				memcpy(pdata, res->private_data,
+				       cm_event.private_data_len);
+
+				cm_event.private_data =3D pdata;
+			}
+			if (cm_id->event_handler)
+				cm_id->event_handler(cm_id, &cm_event);
+			break;
+		case CCAE_TERMINATE_MESSAGE_RECEIVED:
+		case CCAE_CQ_SQ_COMPLETION_OVERFLOW:
+			ib_event.device =3D &c2dev->ibdev;
+			ib_event.element.qp =3D &qp->ibqp;
+			ib_event.event =3D IB_EVENT_QP_REQ_ERR;
+
+			if (qp->ibqp.event_handler)
+				qp->ibqp.event_handler(&ib_event,
+						       qp->ibqp.
+						       qp_context);
+			break;
+		case CCAE_BAD_CLOSE:
+		case CCAE_LLP_CLOSE_COMPLETE:
+		case CCAE_LLP_CONNECTION_RESET:
+		case CCAE_LLP_CONNECTION_LOST:
+			BUG_ON(cm_id->event_handler=3D=3D(void*)0x6b6b6b6b);
+
+			spin_lock_irqsave(&qp->lock, flags);
+			if (qp->cm_id) {
+				qp->cm_id->rem_ref(qp->cm_id);
+				qp->cm_id =3D NULL;
+			}
+			spin_unlock_irqrestore(&qp->lock, flags);
+			cm_event.event =3D IW_CM_EVENT_CLOSE;
+			cm_event.status =3D 0;
+			if (cm_id->event_handler)
+				cm_id->event_handler(cm_id, &cm_event);
+			break;
+		default:
+			BUG_ON(1);
+			pr_debug("%s:%d Unexpected event_id=3D%d on QP=3D%p, "
+				"CM_ID=3D%p\n",
+				__FUNCTION__, __LINE__,
+				event_id, qp, cm_id);
+			break;
+		}
+		break;
+	}
+
+	case C2_RES_IND_EP:{
+
+		struct c2wr_ae_connection_request *req =3D=20
+			&wr->ae.ae_connection_request;
+		struct iw_cm_id *cm_id =3D=20
+			(struct iw_cm_id *)resource_user_context;
+
+		pr_debug("C2_RES_IND_EP event_id=3D%d\n", event_id);
+		if (event_id !=3D CCAE_CONNECTION_REQUEST) {
+			pr_debug("%s: Invalid event_id: %d\n",
+				__FUNCTION__, event_id);
+			break;
+		}
+		cm_event.event =3D IW_CM_EVENT_CONNECT_REQUEST;
+		cm_event.provider_data =3D (void*)(unsigned long)req->cr_handle;
+		cm_event.local_addr.sin_addr.s_addr =3D req->laddr;
+		cm_event.remote_addr.sin_addr.s_addr =3D req->raddr;
+		cm_event.local_addr.sin_port =3D req->lport;
+		cm_event.remote_addr.sin_port =3D req->rport;
+		cm_event.private_data_len =3D=20
+			be32_to_cpu(req->private_data_length);
+
+		if (cm_event.private_data_len) {
+			pdata =3D
+			    kmalloc(cm_event.private_data_len,
+				    GFP_ATOMIC);
+			if (!pdata) {
+				/* Ignore the request, maybe the remote peer=20
+				 * will retry */
+				pr_debug ("Ignored connect request -- "
+					 "no memory for pdata"
+					 "private_data_len=3D%d\n",
+					 cm_event.private_data_len);
+				goto ignore_it;
+			}
+			memcpy(pdata,
+			       req->private_data,=20
+			       cm_event.private_data_len);
+
+			cm_event.private_data =3D pdata;
+		}
+		if (cm_id->event_handler)
+			cm_id->event_handler(cm_id, &cm_event);
+		break;
+	}
+
+	case C2_RES_IND_CQ:{
+		struct c2_cq *cq =3D
+		    (struct c2_cq *) resource_user_context;
+
+		pr_debug("IB_EVENT_CQ_ERR\n");
+		ib_event.device =3D &c2dev->ibdev;
+		ib_event.element.cq =3D &cq->ibcq;
+		ib_event.event =3D IB_EVENT_CQ_ERR;
+
+		if (cq->ibcq.event_handler)
+			cq->ibcq.event_handler(&ib_event,
+					       cq->ibcq.cq_context);
+	}
+
+	default:
+		printk("Bad resource indicator =3D %d\n",
+		       resource_indicator);
+		break;
+	}
+
+ ignore_it:
+	c2_mq_free(mq);
+}
diff --git a/drivers/infiniband/hw/amso1100/c2_intr.c b/drivers/infiniban=
d/hw/amso1100/c2_intr.c
new file mode 100644
index 0000000..75bb18c
--- /dev/null
+++ b/drivers/infiniband/hw/amso1100/c2_intr.c
@@ -0,0 +1,209 @@
+/*
+ * Copyright (c) 2005 Ammasso, Inc. All rights reserved.
+ * Copyright (c) 2005 Open Grid Computing, Inc. All rights reserved.
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * OpenIB.org BSD license below:
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      - Redistributions of source code must retain the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer.
+ *
+ *      - Redistributions in binary form must reproduce the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer in the documentation and/or other materials
+ *        provided with the distribution.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ */
+#include "c2.h"
+#include <rdma/iw_cm.h>
+#include "c2_vq.h"
+
+static void handle_mq(struct c2_dev *c2dev, u32 index);
+static void handle_vq(struct c2_dev *c2dev, u32 mq_index);
+
+/*
+ * Handle RNIC interrupts
+ */
+void c2_rnic_interrupt(struct c2_dev *c2dev)
+{
+	unsigned int mq_index;
+
+	while (c2dev->hints_read !=3D be16_to_cpu(c2dev->hint_count)) {
+		mq_index =3D readl(c2dev->regs + PCI_BAR0_HOST_HINT);
+		if (mq_index & 0x80000000) {
+			break;
+		}
+
+		c2dev->hints_read++;
+		handle_mq(c2dev, mq_index);
+	}
+
+}
+
+/*
+ * Top level MQ handler=20
+ */
+static void handle_mq(struct c2_dev *c2dev, u32 mq_index)
+{
+	if (c2dev->qptr_array[mq_index] =3D=3D NULL) {
+		pr_debug(KERN_INFO "handle_mq: stray activity for mq_index=3D%d\n",
+			mq_index);
+		return;
+	}
+
+	switch (mq_index) {
+	case (0):
+		/*
+		 * An index of 0 in the activity queue
+		 * indicates the req vq now has messages
+		 * available...
+		 *
+		 * Wake up any waiters waiting on req VQ=20
+		 * message availability. =20
+		 */
+		wake_up(&c2dev->req_vq_wo);
+		break;
+	case (1):
+		handle_vq(c2dev, mq_index);
+		break;
+	case (2):
+		/* We have to purge the VQ in case there are pending
+		 * accept reply requests that would result in the
+		 * generation of an ESTABLISHED event. If we don't
+		 * generate these first, a CLOSE event could end up
+		 * being delivered before the ESTABLISHED event.
+		 */
+		handle_vq(c2dev, 1);
+
+		c2_ae_event(c2dev, mq_index);
+		break;
+	default:
+		/* There is no event synchronization between CQ events
+		 * and AE or CM events. In fact, CQE could be
+		 * delivered for all of the I/O up to and including the
+		 * FLUSH for a peer disconenct prior to the ESTABLISHED
+		 * event being delivered to the app. The reason for this
+		 * is that CM events are delivered on a thread, while AE
+		 * and CM events are delivered on interrupt context.=20
+		 */
+		c2_cq_event(c2dev, mq_index);
+		break;
+	}
+
+	return;
+}
+
+/*
+ * Handles verbs WR replies.
+ */
+static void handle_vq(struct c2_dev *c2dev, u32 mq_index)
+{
+	void *adapter_msg, *reply_msg;
+	struct c2wr_hdr *host_msg;
+	struct c2wr_hdr tmp;
+	struct c2_mq *reply_vq;
+	struct c2_vq_req *req;
+	struct iw_cm_event cm_event;
+	int err;
+
+	reply_vq =3D (struct c2_mq *) c2dev->qptr_array[mq_index];
+
+	/*
+	 * get next msg from mq_index into adapter_msg.
+	 * don't free it yet.
+	 */
+	adapter_msg =3D c2_mq_consume(reply_vq);
+	if (adapter_msg =3D=3D NULL) {
+		return;
+	}
+
+	host_msg =3D vq_repbuf_alloc(c2dev);
+
+	/*
+	 * If we can't get a host buffer, then we'll still=20
+	 * wakeup the waiter, we just won't give him the msg.
+	 * It is assumed the waiter will deal with this...
+	 */
+	if (!host_msg) {
+		pr_debug("handle_vq: no repbufs!\n");
+
+		/*     =20
+		 * just copy the WR header into a local variable.
+		 * this allows us to still demux on the context
+		 */
+		host_msg =3D &tmp;
+		memcpy(host_msg, adapter_msg, sizeof(tmp));
+		reply_msg =3D NULL;
+	} else {
+		memcpy(host_msg, adapter_msg, reply_vq->msg_size);
+		reply_msg =3D host_msg;
+	}
+
+	/*
+	 * consume the msg from the MQ
+	 */
+	c2_mq_free(reply_vq);
+
+	/*
+	 * wakeup the waiter.
+	 */
+	req =3D (struct c2_vq_req *) (unsigned long) host_msg->context;
+	if (req =3D=3D NULL) {
+		/*
+		 * We should never get here, as the adapter should
+		 * never send us a reply that we're not expecting.
+		 */
+		vq_repbuf_free(c2dev, host_msg);
+		pr_debug("handle_vq: UNEXPECTEDLY got NULL req\n");
+		return;
+	}
+
+	err =3D c2_errno(reply_msg);
+	if (!err) switch (req->event) {
+	case IW_CM_EVENT_ESTABLISHED:
+		c2_set_qp_state(req->qp,
+				C2_QP_STATE_RTS);
+	case IW_CM_EVENT_CLOSE:
+
+		/*=20
+		 * Move the QP to RTS if this is=20
+		 * the established event=20
+		 */
+		cm_event.event =3D req->event;
+		cm_event.status =3D 0;
+		cm_event.local_addr =3D req->cm_id->local_addr;
+		cm_event.remote_addr =3D req->cm_id->remote_addr;
+		cm_event.private_data =3D NULL;
+		cm_event.private_data_len =3D 0;
+		req->cm_id->event_handler(req->cm_id, &cm_event);
+		break;
+	default:
+		break;
+	}
+
+	req->reply_msg =3D (u64) (unsigned long) (reply_msg);
+	atomic_set(&req->reply_ready, 1);
+	wake_up(&req->wait_object);
+
+	/*
+	 * If the request was cancelled, then this put will
+	 * free the vq_req memory...and reply_msg!!!
+	 */
+	vq_req_put(c2dev, req);
+}
diff --git a/drivers/infiniband/hw/amso1100/c2_rnic.c b/drivers/infiniban=
d/hw/amso1100/c2_rnic.c
new file mode 100644
index 0000000..49645a9
--- /dev/null
+++ b/drivers/infiniband/hw/amso1100/c2_rnic.c
@@ -0,0 +1,631 @@
+/*
+ * Copyright (c) 2005 Ammasso, Inc. All rights reserved.
+ * Copyright (c) 2005 Open Grid Computing, Inc. All rights reserved.
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * OpenIB.org BSD license below:
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      - Redistributions of source code must retain the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer.
+ *
+ *      - Redistributions in binary form must reproduce the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer in the documentation and/or other materials
+ *        provided with the distribution.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ *
+ */
+
+
+#include <linux/module.h>
+#include <linux/moduleparam.h>
+#include <linux/pci.h>
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/delay.h>
+#include <linux/ethtool.h>
+#include <linux/mii.h>
+#include <linux/if_vlan.h>
+#include <linux/crc32.h>
+#include <linux/in.h>
+#include <linux/ip.h>
+#include <linux/tcp.h>
+#include <linux/init.h>
+#include <linux/dma-mapping.h>
+#include <linux/mm.h>
+#include <linux/inet.h>
+
+#include <linux/route.h>
+
+#include <asm/io.h>
+#include <asm/irq.h>
+#include <asm/byteorder.h>
+#include <rdma/ib_smi.h>
+#include "c2.h"
+#include "c2_vq.h"
+
+/* Device capabilities */
+#define C2_MIN_PAGESIZE  1024
+
+#define C2_MAX_MRS       32768
+#define C2_MAX_QPS       16000
+#define C2_MAX_WQE_SZ    256
+#define C2_MAX_QP_WR     ((128*1024)/C2_MAX_WQE_SZ)
+#define C2_MAX_SGES      4
+#define C2_MAX_SGE_RD    1
+#define C2_MAX_CQS       32768
+#define C2_MAX_CQES      4096
+#define C2_MAX_PDS       16384
+
+/*
+ * Send the adapter INIT message to the amso1100
+ */
+static int c2_adapter_init(struct c2_dev *c2dev)
+{
+	struct c2wr_init_req wr;
+	int err;
+
+	memset(&wr, 0, sizeof(wr));
+	c2_wr_set_id(&wr, CCWR_INIT);
+	wr.hdr.context =3D 0;
+	wr.hint_count =3D cpu_to_be64(__pa(&c2dev->hint_count));
+	wr.q0_host_shared =3D cpu_to_be64(__pa(c2dev->req_vq.shared));
+	wr.q1_host_shared =3D cpu_to_be64(__pa(c2dev->rep_vq.shared));
+	wr.q1_host_msg_pool =3D cpu_to_be64(__pa(c2dev->rep_vq.msg_pool.host));
+	wr.q2_host_shared =3D cpu_to_be64(__pa(c2dev->aeq.shared));
+	wr.q2_host_msg_pool =3D cpu_to_be64(__pa(c2dev->aeq.msg_pool.host));
+
+	/* Post the init message */
+	err =3D vq_send_wr(c2dev, (union c2wr *) & wr);
+
+	return err;
+}
+
+/*
+ * Send the adapter TERM message to the amso1100
+ */
+static void c2_adapter_term(struct c2_dev *c2dev)
+{
+	struct c2wr_init_req wr;
+
+	memset(&wr, 0, sizeof(wr));
+	c2_wr_set_id(&wr, CCWR_TERM);
+	wr.hdr.context =3D 0;
+
+	/* Post the init message */
+	vq_send_wr(c2dev, (union c2wr *) & wr);
+	c2dev->init =3D 0;
+
+	return;
+}
+
+/*
+ * Query the adapter
+ */
+int c2_rnic_query(struct c2_dev *c2dev,
+		  struct ib_device_attr *props)
+{
+	struct c2_vq_req *vq_req;
+	struct c2wr_rnic_query_req wr;
+	struct c2wr_rnic_query_rep *reply;
+	int err;
+
+	vq_req =3D vq_req_alloc(c2dev);
+	if (!vq_req)
+		return -ENOMEM;
+
+	c2_wr_set_id(&wr, CCWR_RNIC_QUERY);
+	wr.hdr.context =3D (unsigned long) vq_req;
+	wr.rnic_handle =3D c2dev->adapter_handle;
+
+	vq_req_get(c2dev, vq_req);
+
+	err =3D vq_send_wr(c2dev, (union c2wr *) &wr);
+	if (err) {
+		vq_req_put(c2dev, vq_req);
+		goto bail1;
+	}
+
+	err =3D vq_wait_for_reply(c2dev, vq_req);
+	if (err)
+		goto bail1;
+
+	reply =3D
+	    (struct c2wr_rnic_query_rep *) (unsigned long) (vq_req->reply_msg);
+	if (!reply)
+		err =3D -ENOMEM;
+
+	err =3D c2_errno(reply);
+	if (err)
+		goto bail2;
+
+	props->fw_ver =3D=20
+		((u64)be32_to_cpu(reply->fw_ver_major) << 32) |
+		((be32_to_cpu(reply->fw_ver_minor) && 0xFFFF) << 16) |
+		(be32_to_cpu(reply->fw_ver_patch) && 0xFFFF);
+	memcpy(&props->sys_image_guid, c2dev->netdev->dev_addr, 6);
+	props->max_mr_size         =3D 0xFFFFFFFF;
+	props->page_size_cap       =3D ~(C2_MIN_PAGESIZE-1);
+	props->vendor_id           =3D be32_to_cpu(reply->vendor_id);
+	props->vendor_part_id      =3D be32_to_cpu(reply->part_number);
+	props->hw_ver              =3D be32_to_cpu(reply->hw_version);
+	props->max_qp              =3D be32_to_cpu(reply->max_qps);
+	props->max_qp_wr           =3D be32_to_cpu(reply->max_qp_depth);
+	props->device_cap_flags    =3D c2dev->device_cap_flags;
+	props->max_sge             =3D C2_MAX_SGES;
+	props->max_sge_rd          =3D C2_MAX_SGE_RD;
+	props->max_cq              =3D be32_to_cpu(reply->max_cqs);
+	props->max_cqe             =3D be32_to_cpu(reply->max_cq_depth);
+	props->max_mr              =3D be32_to_cpu(reply->max_mrs);
+	props->max_pd              =3D be32_to_cpu(reply->max_pds);
+	props->max_qp_rd_atom      =3D be32_to_cpu(reply->max_qp_ird);
+	props->max_ee_rd_atom      =3D 0;
+	props->max_res_rd_atom     =3D be32_to_cpu(reply->max_global_ird);
+	props->max_qp_init_rd_atom =3D be32_to_cpu(reply->max_qp_ord);
+	props->max_ee_init_rd_atom =3D 0;
+	props->atomic_cap          =3D IB_ATOMIC_NONE;
+	props->max_ee              =3D 0;
+	props->max_rdd             =3D 0;
+	props->max_mw              =3D be32_to_cpu(reply->max_mws);
+	props->max_raw_ipv6_qp     =3D 0;
+	props->max_raw_ethy_qp     =3D 0;
+	props->max_mcast_grp       =3D 0;
+	props->max_mcast_qp_attach =3D 0;
+	props->max_total_mcast_qp_attach =3D 0;
+	props->max_ah              =3D 0;
+	props->max_fmr             =3D 0;
+	props->max_map_per_fmr     =3D 0;
+	props->max_srq             =3D 0;
+	props->max_srq_wr          =3D 0;
+	props->max_srq_sge         =3D 0;
+	props->max_pkeys           =3D 0;
+	props->local_ca_ack_delay  =3D 0;
+
+ bail2:
+	vq_repbuf_free(c2dev, reply);
+
+ bail1:
+	vq_req_free(c2dev, vq_req);
+	return err;
+}
+
+/*
+ * Add an IP address to the RNIC interface
+ */
+int c2_add_addr(struct c2_dev *c2dev, u32 inaddr, u32 inmask)
+{
+	struct c2_vq_req *vq_req;
+	struct c2wr_rnic_setconfig_req *wr;
+	struct c2wr_rnic_setconfig_rep *reply;
+	struct c2_netaddr netaddr;
+	int err, len;
+
+	vq_req =3D vq_req_alloc(c2dev);
+	if (!vq_req)
+		return -ENOMEM;
+
+	len =3D sizeof(struct c2_netaddr);
+	wr =3D kmalloc(c2dev->req_vq.msg_size, GFP_KERNEL);
+	if (!wr) {
+		err =3D -ENOMEM;
+		goto bail0;
+	}
+
+	c2_wr_set_id(wr, CCWR_RNIC_SETCONFIG);
+	wr->hdr.context =3D (unsigned long) vq_req;
+	wr->rnic_handle =3D c2dev->adapter_handle;
+	wr->option =3D cpu_to_be32(C2_CFG_ADD_ADDR);
+
+	netaddr.ip_addr =3D inaddr;
+	netaddr.netmask =3D inmask;
+	netaddr.mtu =3D 0;
+
+	memcpy(wr->data, &netaddr, len);
+
+	vq_req_get(c2dev, vq_req);
+
+	err =3D vq_send_wr(c2dev, (union c2wr *) wr);
+	if (err) {
+		vq_req_put(c2dev, vq_req);
+		goto bail1;
+	}
+
+	err =3D vq_wait_for_reply(c2dev, vq_req);
+	if (err)
+		goto bail1;
+
+	reply =3D
+	    (struct c2wr_rnic_setconfig_rep *) (unsigned long) (vq_req->reply_m=
sg);
+	if (!reply) {
+		err =3D -ENOMEM;
+		goto bail1;
+	}
+
+	err =3D c2_errno(reply);
+	vq_repbuf_free(c2dev, reply);
+
+      bail1:
+	kfree(wr);
+      bail0:
+	vq_req_free(c2dev, vq_req);
+	return err;
+}
+
+/*
+ * Delete an IP address from the RNIC interface
+ */
+int c2_del_addr(struct c2_dev *c2dev, u32 inaddr, u32 inmask)
+{
+	struct c2_vq_req *vq_req;
+	struct c2wr_rnic_setconfig_req *wr;
+	struct c2wr_rnic_setconfig_rep *reply;
+	struct c2_netaddr netaddr;
+	int err, len;
+
+	vq_req =3D vq_req_alloc(c2dev);
+	if (!vq_req)
+		return -ENOMEM;
+
+	len =3D sizeof(struct c2_netaddr);
+	wr =3D kmalloc(c2dev->req_vq.msg_size, GFP_KERNEL);
+	if (!wr) {
+		err =3D -ENOMEM;
+		goto bail0;
+	}
+
+	c2_wr_set_id(wr, CCWR_RNIC_SETCONFIG);
+	wr->hdr.context =3D (unsigned long) vq_req;
+	wr->rnic_handle =3D c2dev->adapter_handle;
+	wr->option =3D cpu_to_be32(C2_CFG_DEL_ADDR);
+
+	netaddr.ip_addr =3D inaddr;
+	netaddr.netmask =3D inmask;
+	netaddr.mtu =3D 0;
+
+	memcpy(wr->data, &netaddr, len);
+
+	vq_req_get(c2dev, vq_req);
+
+	err =3D vq_send_wr(c2dev, (union c2wr *) wr);
+	if (err) {
+		vq_req_put(c2dev, vq_req);
+		goto bail1;
+	}
+
+	err =3D vq_wait_for_reply(c2dev, vq_req);
+	if (err)
+		goto bail1;
+
+	reply =3D
+	    (struct c2wr_rnic_setconfig_rep *) (unsigned long) (vq_req->reply_m=
sg);
+	if (!reply) {
+		err =3D -ENOMEM;
+		goto bail1;
+	}
+
+	err =3D c2_errno(reply);
+	vq_repbuf_free(c2dev, reply);
+
+      bail1:
+	kfree(wr);
+      bail0:
+	vq_req_free(c2dev, vq_req);
+	return err;
+}
+
+/*
+ * Open a single RNIC instance to use with all
+ * low level openib calls
+ */
+static int c2_rnic_open(struct c2_dev *c2dev)
+{
+	struct c2_vq_req *vq_req;
+	union c2wr wr;
+	struct c2wr_rnic_open_rep *reply;
+	int err;
+
+	vq_req =3D vq_req_alloc(c2dev);
+	if (vq_req =3D=3D NULL) {
+		return -ENOMEM;
+	}
+
+	memset(&wr, 0, sizeof(wr));
+	c2_wr_set_id(&wr, CCWR_RNIC_OPEN);
+	wr.rnic_open.req.hdr.context =3D (unsigned long) (vq_req);
+	wr.rnic_open.req.flags =3D cpu_to_be16(RNIC_PRIV_MODE);
+	wr.rnic_open.req.port_num =3D cpu_to_be16(0);
+	wr.rnic_open.req.user_context =3D (unsigned long) c2dev;
+
+	vq_req_get(c2dev, vq_req);
+
+	err =3D vq_send_wr(c2dev, &wr);
+	if (err) {
+		vq_req_put(c2dev, vq_req);
+		goto bail0;
+	}
+
+	err =3D vq_wait_for_reply(c2dev, vq_req);
+	if (err) {
+		goto bail0;
+	}
+
+	reply =3D (struct c2wr_rnic_open_rep *) (unsigned long) (vq_req->reply_=
msg);
+	if (!reply) {
+		err =3D -ENOMEM;
+		goto bail0;
+	}
+
+	if ((err =3D c2_errno(reply)) !=3D 0) {
+		goto bail1;
+	}
+
+	c2dev->adapter_handle =3D reply->rnic_handle;
+
+      bail1:
+	vq_repbuf_free(c2dev, reply);
+      bail0:
+	vq_req_free(c2dev, vq_req);
+	return err;
+}
+
+/*
+ * Close the RNIC instance
+ */
+static int c2_rnic_close(struct c2_dev *c2dev)
+{
+	struct c2_vq_req *vq_req;
+	union c2wr wr;
+	struct c2wr_rnic_close_rep *reply;
+	int err;
+
+	vq_req =3D vq_req_alloc(c2dev);
+	if (vq_req =3D=3D NULL) {
+		return -ENOMEM;
+	}
+
+	memset(&wr, 0, sizeof(wr));
+	c2_wr_set_id(&wr, CCWR_RNIC_CLOSE);
+	wr.rnic_close.req.hdr.context =3D (unsigned long) vq_req;
+	wr.rnic_close.req.rnic_handle =3D c2dev->adapter_handle;
+
+	vq_req_get(c2dev, vq_req);
+
+	err =3D vq_send_wr(c2dev, &wr);
+	if (err) {
+		vq_req_put(c2dev, vq_req);
+		goto bail0;
+	}
+
+	err =3D vq_wait_for_reply(c2dev, vq_req);
+	if (err) {
+		goto bail0;
+	}
+
+	reply =3D (struct c2wr_rnic_close_rep *) (unsigned long) (vq_req->reply=
_msg);
+	if (!reply) {
+		err =3D -ENOMEM;
+		goto bail0;
+	}
+
+	if ((err =3D c2_errno(reply)) !=3D 0) {
+		goto bail1;
+	}
+
+	c2dev->adapter_handle =3D 0;
+
+      bail1:
+	vq_repbuf_free(c2dev, reply);
+      bail0:
+	vq_req_free(c2dev, vq_req);
+	return err;
+}
+
+/*
+ * Called by c2_probe to initialize the RNIC. This principally
+ * involves initalizing the various limits and resouce pools that
+ * comprise the RNIC instance.
+ */
+int c2_rnic_init(struct c2_dev *c2dev)
+{
+	int err;
+	u32 qsize, msgsize;
+	void *q1_pages;
+	void *q2_pages;
+	void __iomem *mmio_regs;
+
+	/* Device capabilities */
+	c2dev->device_cap_flags =3D
+	    (IB_DEVICE_RESIZE_MAX_WR |
+	     IB_DEVICE_CURR_QP_STATE_MOD |
+	     IB_DEVICE_SYS_IMAGE_GUID |
+	     IB_DEVICE_ZERO_STAG |
+	     IB_DEVICE_SEND_W_INV | IB_DEVICE_MEM_WINDOW);
+
+	/* Allocate the qptr_array */
+	c2dev->qptr_array =3D vmalloc(C2_MAX_CQS * sizeof(void *));
+	if (!c2dev->qptr_array) {
+		return -ENOMEM;
+	}
+
+	/* Inialize the qptr_array */
+	memset(c2dev->qptr_array, 0, C2_MAX_CQS * sizeof(void *));
+	c2dev->qptr_array[0] =3D (void *) &c2dev->req_vq;
+	c2dev->qptr_array[1] =3D (void *) &c2dev->rep_vq;
+	c2dev->qptr_array[2] =3D (void *) &c2dev->aeq;
+
+	/* Initialize data structures */
+	init_waitqueue_head(&c2dev->req_vq_wo);
+	spin_lock_init(&c2dev->vqlock);
+	spin_lock_init(&c2dev->lock);
+
+	/* Allocate MQ shared pointer pool for kernel clients. User
+	 * mode client pools are hung off the user context
+	 */
+	err =3D c2_init_mqsp_pool(GFP_KERNEL, &c2dev->kern_mqsp_pool);
+	if (err) {
+		goto bail0;
+	}
+
+	/* Allocate shared pointers for Q0, Q1, and Q2 from
+	 * the shared pointer pool.
+	 */
+	c2dev->req_vq.shared =3D c2_alloc_mqsp(c2dev->kern_mqsp_pool);
+	c2dev->rep_vq.shared =3D c2_alloc_mqsp(c2dev->kern_mqsp_pool);
+	c2dev->aeq.shared =3D c2_alloc_mqsp(c2dev->kern_mqsp_pool);
+	if (!c2dev->req_vq.shared ||
+	    !c2dev->rep_vq.shared || !c2dev->aeq.shared) {
+		err =3D -ENOMEM;
+		goto bail1;
+	}
+
+	mmio_regs =3D c2dev->kva;
+	/* Initialize the Verbs Request Queue */
+	c2_mq_req_init(&c2dev->req_vq, 0,
+		       be32_to_cpu(readl(mmio_regs + C2_REGS_Q0_QSIZE)),
+		       be32_to_cpu(readl(mmio_regs + C2_REGS_Q0_MSGSIZE)),
+		       mmio_regs +
+		       be32_to_cpu(readl(mmio_regs + C2_REGS_Q0_POOLSTART)),
+		       mmio_regs +
+		       be32_to_cpu(readl(mmio_regs + C2_REGS_Q0_SHARED)),
+		       C2_MQ_ADAPTER_TARGET);
+
+	/* Initialize the Verbs Reply Queue */
+	qsize =3D be32_to_cpu(readl(mmio_regs + C2_REGS_Q1_QSIZE));
+	msgsize =3D be32_to_cpu(readl(mmio_regs + C2_REGS_Q1_MSGSIZE));
+	q1_pages =3D kmalloc(qsize * msgsize, GFP_KERNEL);
+	if (!q1_pages) {
+		err =3D -ENOMEM;
+		goto bail1;
+	}
+	c2_mq_rep_init(&c2dev->rep_vq,
+		   1,
+		   qsize,
+		   msgsize,
+		   q1_pages,
+		   mmio_regs +
+		   be32_to_cpu(readl(mmio_regs + C2_REGS_Q1_SHARED)),
+		   C2_MQ_HOST_TARGET);
+
+	/* Initialize the Asynchronus Event Queue */
+	qsize =3D be32_to_cpu(readl(mmio_regs + C2_REGS_Q2_QSIZE));
+	msgsize =3D be32_to_cpu(readl(mmio_regs + C2_REGS_Q2_MSGSIZE));
+	q2_pages =3D kmalloc(qsize * msgsize, GFP_KERNEL);
+	if (!q2_pages) {
+		err =3D -ENOMEM;
+		goto bail2;
+	}
+	c2_mq_rep_init(&c2dev->aeq,
+		       2,
+		       qsize,
+		       msgsize,
+		       q2_pages,
+		       mmio_regs +
+		       be32_to_cpu(readl(mmio_regs + C2_REGS_Q2_SHARED)),
+		       C2_MQ_HOST_TARGET);
+
+	/* Initialize the verbs request allocator */
+	err =3D vq_init(c2dev);
+	if (err)
+		goto bail3;
+
+	/* Enable interrupts on the adapter */
+	writel(0, c2dev->regs + C2_IDIS);
+
+	/* create the WR init message */
+	err =3D c2_adapter_init(c2dev);
+	if (err)
+		goto bail4;
+	c2dev->init++;
+
+	/* open an adapter instance */
+	err =3D c2_rnic_open(c2dev);
+	if (err)
+		goto bail4;
+
+	/* Initialize cached the adapter limits */
+	if (c2_rnic_query(c2dev, &c2dev->props))
+		goto bail4;
+
+	/* Initialize the PD pool */
+	err =3D c2_init_pd_table(c2dev);
+	if (err)
+		goto bail5;
+
+	/* Initialize the QP pool */
+	err =3D c2_init_qp_table(c2dev);
+	if (err)
+		goto bail6;
+	return 0;
+
+      bail6:
+	c2_cleanup_pd_table(c2dev);
+      bail5:
+	c2_rnic_close(c2dev);
+      bail4:
+	vq_term(c2dev);
+      bail3:
+	kfree(q2_pages);
+      bail2:
+	kfree(q1_pages);
+      bail1:
+	c2_free_mqsp_pool(c2dev->kern_mqsp_pool);
+      bail0:
+	vfree(c2dev->qptr_array);
+
+	return err;
+}
+
+/*
+ * Called by c2_remove to cleanup the RNIC resources.=20
+ */
+void c2_rnic_term(struct c2_dev *c2dev)
+{
+
+	/* Close the open adapter instance */
+	c2_rnic_close(c2dev);
+
+	/* Send the TERM message to the adapter */
+	c2_adapter_term(c2dev);
+
+	/* Disable interrupts on the adapter */
+	writel(1, c2dev->regs + C2_IDIS);
+
+	/* Free the QP pool */
+	c2_cleanup_qp_table(c2dev);
+
+	/* Free the PD pool */
+	c2_cleanup_pd_table(c2dev);
+
+	/* Free the verbs request allocator */
+	vq_term(c2dev);
+
+	/* Free the asynchronus event queue */
+	kfree(c2dev->aeq.msg_pool.host);
+
+	/* Free the verbs reply queue */
+	kfree(c2dev->rep_vq.msg_pool.host);
+
+	/* Free the MQ shared pointer pool */
+	c2_free_mqsp_pool(c2dev->kern_mqsp_pool);
+
+	/* Free the qptr_array */
+	vfree(c2dev->qptr_array);
+
+	return;
+}
