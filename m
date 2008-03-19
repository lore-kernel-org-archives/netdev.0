From: Florian Fainelli <florian.fainelli@telecomint.eu>
Subject: Re: [PATCH] Add support the Korina (IDT RC32434) Ethernet MAC
Date: Wed, 19 Mar 2008 17:14:51 +0100
Message-ID: <200803191714.52407.florian.fainelli@telecomint.eu>
References: <200803052345.06610.florian.fainelli@telecomint.eu> <200803131155.28164.florian.fainelli@telecomint.eu> <20080317223153.GA3462@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Johannes Berg <johannes@sipsolutions.net>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Jeff Garzik <jeff@garzik.org>, Felix Fietkau <nbd@openwrt.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4.int-evry.fr ([157.159.10.71]:44451 "EHLO
	smtp4.int-evry.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752686AbYCSTeN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Mar 2008 15:34:13 -0400
In-Reply-To: <20080317223153.GA3462@electric-eye.fr.zoreil.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Francois,

Le lundi 17 mars 2008, Francois Romieu a =E9crit=A0:
> > Thanks for your comments, here is a third try which adresses the
> > mentionned problems.

It is allright, thanks for your concise answers. 1-2,4-15 should be fix=
ed now.

> 3. korina_rx() still drops the received skb each time dev_alloc_skb f=
ails.
>    This is far from optimal.

I now simply break into the while loop, which should allow more luck fo=
r failed allocation descriptors on next round. Seems like other=20

Also, I fixed the multicast handling which was not done for filtered mu=
lticast traffic.

Below is the fourth try of the driver.
--
=46rom: Florian Fainelli <florian.fainelli@telecomint.eu>
Subject: [PATCH] Add support the Korina (IDT RC32434) Ethernet MAC

This patch adds support for the IDT rc32434 Ethernet MAC
we can find in the IDT boards and the Mikrotik RB500.
Driver references some code from the linux-mips RB500
support.

Signed-off-by: Florian Fainelli <florian.fainelli@telecomint.eu>
Signed-off-by: Felix Fietkau <nbd@openwrt.org>
Signed-off-by: Philip Rischel <rischelp@idt.com>
---
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index fe7b5ec..7a855f9 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -467,6 +467,13 @@ config SNI_82596
 	  Say Y here to support the on-board Intel 82596 ethernet controller
 	  built into SNI RM machines.
=20
+config KORINA
+	tristate "Korina (IDT RC32434) Ethernet support"
+	depends on NET_ETHERNET && MIKROTIK_RB500
+	help
+	  If you have a Mikrotik RouterBoard 500 or IDT RC32434
+	  based system say Y. Otherwise say N.
+
 config MIPS_JAZZ_SONIC
 	tristate "MIPS JAZZ onboard SONIC Ethernet support"
 	depends on MACH_JAZZ
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 3b1ea32..b00d4e8 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -191,6 +191,7 @@ obj-$(CONFIG_ZORRO8390) +=3D zorro8390.o
 obj-$(CONFIG_HPLANCE) +=3D hplance.o 7990.o
 obj-$(CONFIG_MVME147_NET) +=3D mvme147.o 7990.o
 obj-$(CONFIG_EQUALIZER) +=3D eql.o
+obj-$(CONFIG_KORINA) +=3D korina.o
 obj-$(CONFIG_MIPS_JAZZ_SONIC) +=3D jazzsonic.o
 obj-$(CONFIG_MIPS_AU1X00_ENET) +=3D au1000_eth.o
 obj-$(CONFIG_MIPS_SIM_NET) +=3D mipsnet.o
diff --git a/drivers/net/korina.c b/drivers/net/korina.c
new file mode 100644
index 0000000..1d24a73
--- /dev/null
+++ b/drivers/net/korina.c
@@ -0,0 +1,1233 @@
+/*
+ *  Driver for the IDT RC32434 (Korina) on-chip ethernet controller.
+ *
+ *  Copyright 2004 IDT Inc. (rischelp@idt.com)
+ *  Copyright 2006 Felix Fietkau <nbd@openwrt.org>
+ *  Copyright 2008 Florian Fainelli <florian@openwrt.org>
+ *
+ *  This program is free software; you can redistribute  it and/or mod=
ify it
+ *  under  the terms of  the GNU General  Public License as published =
by the
+ *  Free Software Foundation;  either version 2 of the  License, or (a=
t your
+ *  option) any later version.
+ *
+ *  THIS  SOFTWARE  IS PROVIDED   ``AS  IS'' AND   ANY  EXPRESS OR IMP=
LIED
+ *  WARRANTIES,   INCLUDING, BUT NOT  LIMITED  TO, THE IMPLIED WARRANT=
IES OF
+ *  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIME=
D.  IN
+ *  NO  EVENT  SHALL   THE AUTHOR  BE    LIABLE FOR ANY   DIRECT, INDI=
RECT,
+ *  INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDIN=
G, BUT
+ *  NOT LIMITED   TO, PROCUREMENT OF  SUBSTITUTE GOODS  OR SERVICES; L=
OSS OF
+ *  USE, DATA,  OR PROFITS; OR  BUSINESS INTERRUPTION) HOWEVER CAUSED =
AND ON
+ *  ANY THEORY OF LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, O=
R TORT
+ *  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE =
USE OF
+ *  THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ *
+ *  You should have received a copy of the  GNU General Public License=
 along
+ *  with this program; if not, write  to the Free Software Foundation,=
 Inc.,
+ *  675 Mass Ave, Cambridge, MA 02139, USA.
+ *
+ *  Writing to a DMA status register:
+ *
+ *  When writing to the status register, you should mask the bit you h=
ave
+ *  been testing the status register with. Both Tx and Rx DMA register=
s
+ *  should stick to this procedure.
+ */
+
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/moduleparam.h>
+#include <linux/sched.h>
+#include <linux/ctype.h>
+#include <linux/types.h>
+#include <linux/interrupt.h>
+#include <linux/init.h>
+#include <linux/ioport.h>
+#include <linux/in.h>
+#include <linux/slab.h>
+#include <linux/string.h>
+#include <linux/delay.h>
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/skbuff.h>
+#include <linux/errno.h>
+#include <linux/platform_device.h>
+#include <linux/mii.h>
+#include <linux/ethtool.h>
+#include <linux/crc32.h>
+
+#include <asm/bootinfo.h>
+#include <asm/system.h>
+#include <asm/bitops.h>
+#include <asm/pgtable.h>
+#include <asm/segment.h>
+#include <asm/io.h>
+#include <asm/dma.h>
+
+#include <asm/mach-rc32434/rb.h>
+#include <asm/mach-rc32434/rc32434.h>
+#include <asm/mach-rc32434/eth.h>
+#include <asm/mach-rc32434/dma_v.h>
+
+#define DRV_NAME        "korina"
+#define DRV_VERSION     "0.10"
+#define DRV_RELDATE     "04Mar2008"
+
+#define STATION_ADDRESS_HIGH(dev) (((dev)->dev_addr[0] << 8) | \
+				   ((dev)->dev_addr[1]))
+#define STATION_ADDRESS_LOW(dev)  (((dev)->dev_addr[2] << 24) | \
+				   ((dev)->dev_addr[3] << 16) | \
+				   ((dev)->dev_addr[4] << 8)  | \
+				   ((dev)->dev_addr[5]))
+
+#define MII_CLOCK 1250000 	/* no more than 2.5MHz */
+
+/* the following must be powers of two */
+#define KORINA_NUM_RDS	64  /* number of receive descriptors */
+#define KORINA_NUM_TDS	64  /* number of transmit descriptors */
+
+#define KORINA_RBSIZE	536 /* size of one resource buffer =3D Ether MTU=
 */
+#define KORINA_RDS_MASK	(KORINA_NUM_RDS - 1)
+#define KORINA_TDS_MASK	(KORINA_NUM_TDS - 1)
+#define RD_RING_SIZE 	(KORINA_NUM_RDS * sizeof(struct dma_desc))
+#define TD_RING_SIZE	(KORINA_NUM_TDS * sizeof(struct dma_desc))
+
+#define TX_TIMEOUT 	(6000 * HZ / 1000)
+
+enum chain_status { desc_filled, desc_empty };
+#define IS_DMA_FINISHED(X)   (((X) & (DMA_DESC_FINI)) !=3D 0)
+#define IS_DMA_DONE(X)   (((X) & (DMA_DESC_DONE)) !=3D 0)
+#define RCVPKT_LENGTH(X)     (((X) & ETH_RX_LEN) >> ETH_RX_LEN_BIT)
+
+/* Information that need to be kept for each board. */
+struct korina_private {
+	struct eth_regs *eth_regs;
+	struct dma_reg *rx_dma_regs;
+	struct dma_reg *tx_dma_regs;
+	struct dma_desc *td_ring; /* transmit descriptor ring */
+	struct dma_desc *rd_ring; /* receive descriptor ring  */
+
+	struct sk_buff *tx_skb[KORINA_NUM_TDS];
+	struct sk_buff *rx_skb[KORINA_NUM_RDS];
+
+	int rx_next_done;
+	int rx_chain_head;
+	int rx_chain_tail;
+	enum chain_status rx_chain_status;
+
+	int tx_next_done;
+	int tx_chain_head;
+	int tx_chain_tail;
+	enum chain_status tx_chain_status;
+	int tx_count;
+	int tx_full;
+
+	int rx_irq;
+	int tx_irq;
+	int ovr_irq;
+	int und_irq;
+
+	spinlock_t lock;        /* NIC xmit lock */
+
+	int dma_halt_cnt;
+	int dma_run_cnt;
+	struct napi_struct napi;
+	struct mii_if_info mii_if;
+	struct net_device *dev;
+	int phy_addr;
+};
+
+extern unsigned int idt_cpu_freq;
+
+static inline void korina_start_dma(struct dma_reg *ch, u32 dma_addr)
+{
+	writel(0, &ch->dmandptr);
+	writel(dma_addr, &ch->dmadptr);
+}
+
+static inline void korina_abort_dma(struct net_device *dev,
+					struct dma_reg *ch)
+{
+       if (readl(&ch->dmac) & DMA_CHAN_RUN_BIT) {
+	       writel(0x10, &ch->dmac);
+
+	       while (!(readl(&ch->dmas) & DMA_STAT_HALT))
+		       dev->trans_start =3D jiffies;
+
+	       writel(0, &ch->dmas);
+       }
+
+       writel(0, &ch->dmadptr);
+       writel(0, &ch->dmandptr);
+}
+
+static inline void korina_chain_dma(struct dma_reg *ch, u32 dma_addr)
+{
+	writel(dma_addr, &ch->dmandptr);
+}
+
+static void korina_abort_tx(struct net_device *dev)
+{
+	struct korina_private *lp =3D netdev_priv(dev);
+
+	korina_abort_dma(dev, lp->tx_dma_regs);
+}
+
+static void korina_abort_rx(struct net_device *dev)
+{
+	struct korina_private *lp =3D netdev_priv(dev);
+
+	korina_abort_dma(dev, lp->rx_dma_regs);
+}
+
+static void korina_start_rx(struct korina_private *lp,
+					struct dma_desc *rd)
+{
+	korina_start_dma(lp->rx_dma_regs, CPHYSADDR(rd));
+}
+
+static void korina_chain_rx(struct korina_private *lp,
+					struct dma_desc *rd)
+{
+	korina_chain_dma(lp->rx_dma_regs, CPHYSADDR(rd));
+}
+
+/* transmit packet */
+static int korina_send_packet(struct sk_buff *skb, struct net_device *=
dev)
+{
+	struct korina_private *lp =3D netdev_priv(dev);
+	unsigned long flags;
+	u32 length;
+	u32 chain_index;
+	struct dma_desc *td;
+
+	spin_lock_irqsave(&lp->lock, flags);
+
+	td =3D &lp->td_ring[lp->tx_chain_tail];
+
+	/* stop queue when full, drop pkts if queue already full */
+	if (lp->tx_count >=3D (KORINA_NUM_TDS - 2)) {
+		lp->tx_full =3D 1;
+
+		if (lp->tx_count =3D=3D (KORINA_NUM_TDS - 2))
+			netif_stop_queue(dev);
+		else {
+			dev->stats.tx_dropped++;
+			dev_kfree_skb_any(skb);
+			spin_unlock_irqrestore(&lp->lock, flags);
+
+			return NETDEV_TX_BUSY;
+		}
+	}
+
+	lp->tx_count++;
+
+	lp->tx_skb[lp->tx_chain_tail] =3D skb;
+
+	length =3D skb->len;
+	dma_cache_wback((u32)skb->data, skb->len);
+
+	/* Setup the transmit descriptor. */
+	dma_cache_inv((u32) td, sizeof(*td));
+	td->ca =3D CPHYSADDR(skb->data);
+	chain_index =3D (lp->tx_chain_tail - 1) &
+			KORINA_TDS_MASK;
+
+	if (readl(&(lp->tx_dma_regs->dmandptr)) =3D=3D 0) {
+		if (lp->tx_chain_status =3D=3D desc_empty) {
+			/* Update tail */
+			td->control =3D DMA_COUNT(length) |
+					DMA_DESC_COF | DMA_DESC_IOF;
+			/* Move tail */
+			lp->tx_chain_tail =3D chain_index;
+			/* Write to NDPTR */
+			writel(CPHYSADDR(&lp->td_ring[lp->tx_chain_head]),
+					&lp->tx_dma_regs->dmandptr);
+			/* Move head to tail */
+			lp->tx_chain_head =3D lp->tx_chain_tail;
+		} else {
+			/* Update tail */
+			td->control =3D DMA_COUNT(length) |
+					DMA_DESC_COF | DMA_DESC_IOF;
+			/* Link to prev */
+			lp->td_ring[chain_index].control &=3D
+					~DMA_DESC_COF;
+			/* Link to prev */
+			lp->td_ring[chain_index].link =3D  CPHYSADDR(td);
+			/* Move tail */
+			lp->tx_chain_tail =3D chain_index;
+			/* Write to NDPTR */
+			writel(CPHYSADDR(&lp->td_ring[lp->tx_chain_head]),
+					&(lp->tx_dma_regs->dmandptr));
+			/* Move head to tail */
+			lp->tx_chain_head =3D lp->tx_chain_tail;
+			lp->tx_chain_status =3D desc_empty;
+		}
+	} else {
+		if (lp->tx_chain_status =3D=3D desc_empty) {
+			/* Update tail */
+			td->control =3D DMA_COUNT(length) |
+					DMA_DESC_COF | DMA_DESC_IOF;
+			/* Move tail */
+			lp->tx_chain_tail =3D chain_index;
+			lp->tx_chain_status =3D desc_filled;
+			netif_stop_queue(dev);
+		} else {
+			/* Update tail */
+			td->control =3D DMA_COUNT(length) |
+					DMA_DESC_COF | DMA_DESC_IOF;
+			lp->td_ring[chain_index].control &=3D
+					~DMA_DESC_COF;
+			lp->td_ring[chain_index].link =3D  CPHYSADDR(td);
+			lp->tx_chain_tail =3D chain_index;
+		}
+	}
+	dma_cache_wback((u32) td, sizeof(*td));
+
+	dev->trans_start =3D jiffies;
+	spin_unlock_irqrestore(&lp->lock, flags);
+
+	return NETDEV_TX_OK;
+}
+
+static int mdio_read(struct net_device *dev, int mii_id, int reg)
+{
+	struct korina_private *lp =3D netdev_priv(dev);
+	int ret;
+
+	mii_id =3D ((lp->rx_irq =3D=3D 0x2c ? 1 : 0) << 8);
+
+	writel(0, &lp->eth_regs->miimcfg);
+	writel(0, &lp->eth_regs->miimcmd);
+	writel(mii_id | reg, &lp->eth_regs->miimaddr);
+	writel(ETH_MII_CMD_SCN, &lp->eth_regs->miimcmd);
+
+	ret =3D (int)(readl(&lp->eth_regs->miimrdd));
+	return ret;
+}
+
+static void mdio_write(struct net_device *dev, int mii_id, int reg, in=
t val)
+{
+	struct korina_private *lp =3D netdev_priv(dev);
+
+	mii_id =3D ((lp->rx_irq =3D=3D 0x2c ? 1 : 0) << 8);
+
+	writel(0, &lp->eth_regs->miimcfg);
+	writel(1, &lp->eth_regs->miimcmd);
+	writel(mii_id | reg, &lp->eth_regs->miimaddr);
+	writel(ETH_MII_CMD_SCN, &lp->eth_regs->miimcmd);
+	writel(val, &lp->eth_regs->miimwtd);
+}
+
+/* Ethernet Rx DMA interrupt */
+static irqreturn_t korina_rx_dma_interrupt(int irq, void *dev_id)
+{
+	struct net_device *dev =3D dev_id;
+	struct korina_private *lp =3D netdev_priv(dev);
+	u32 dmas, dmasm;
+	irqreturn_t retval;
+
+	dmas =3D readl(&lp->rx_dma_regs->dmas);
+	if (dmas & (DMA_STAT_DONE | DMA_STAT_HALT | DMA_STAT_ERR)) {
+		netif_rx_schedule_prep(dev, &lp->napi);
+
+		dmasm =3D readl(&lp->rx_dma_regs->dmasm);
+		writel(dmasm | (DMA_STAT_DONE |
+				DMA_STAT_HALT | DMA_STAT_ERR),
+				&lp->rx_dma_regs->dmasm);
+
+		if (dmas & DMA_STAT_ERR)
+			printk(KERN_ERR DRV_NAME "%s: DMA error\n", dev->name);
+
+		retval =3D IRQ_HANDLED;
+	} else
+		retval =3D IRQ_NONE;
+
+	return retval;
+}
+
+static int korina_rx(struct net_device *dev, int limit)
+{
+	struct korina_private *lp =3D netdev_priv(dev);
+	struct dma_desc *rd =3D &lp->rd_ring[lp->rx_next_done];
+	struct sk_buff *skb, *skb_new;
+	u8 *pkt_buf;
+	u32 devcs, pkt_len, dmas, rx_free_desc;
+	int count;
+
+	dma_cache_inv((u32)rd, sizeof(*rd));
+
+	for (count =3D 0; count < limit; count++) {
+
+		devcs =3D rd->devcs;
+
+		/* Update statistics counters */
+		if (devcs & ETH_RX_CRC)
+			dev->stats.rx_crc_errors++;
+		if (devcs & ETH_RX_LOR)
+			dev->stats.rx_length_errors++;
+		if (devcs & ETH_RX_LE)
+			dev->stats.rx_length_errors++;
+		if (devcs & ETH_RX_OVR)
+			dev->stats.rx_over_errors++;
+		if (devcs & ETH_RX_CV)
+			dev->stats.rx_frame_errors++;
+		if (devcs & ETH_RX_CES)
+			dev->stats.rx_length_errors++;
+		if (devcs & ETH_RX_MP)
+			dev->stats.multicast++;
+
+		if ((devcs & ETH_RX_LD) !=3D ETH_RX_LD) {
+			/* check that this is a whole packet
+			 * WARNING: DMA_FD bit incorrectly set
+			 * in Rc32434 (errata ref #077) */
+			dev->stats.rx_errors++;
+			dev->stats.rx_dropped++;
+		}
+
+		while ((rx_free_desc =3D KORINA_RBSIZE - (u32)DMA_COUNT(rd->control)=
) !=3D 0) {
+			/* init the var. used for the later
+			 * operations within the while loop */
+			skb_new =3D NULL;
+			pkt_len =3D RCVPKT_LENGTH(devcs);
+			skb =3D lp->rx_skb[lp->rx_next_done];
+
+			if ((devcs & ETH_RX_ROK)) {
+				/* must be the (first and) last
+				 * descriptor then */
+				pkt_buf =3D (u8 *)lp->rx_skb[lp->rx_next_done]->data;
+
+				/* invalidate the cache */
+				dma_cache_inv((unsigned long)pkt_buf, pkt_len - 4);
+
+				/* Malloc up new buffer. */
+				skb_new =3D netdev_alloc_skb(dev, KORINA_RBSIZE + 2);
+
+				if (!skb_new)
+					break;
+				/* Do not count the CRC */
+				skb_put(skb, pkt_len - 4);
+				skb->protocol =3D eth_type_trans(skb, dev);
+
+				/* Pass the packet to upper layers */
+				netif_receive_skb(skb);
+				dev->last_rx =3D jiffies;
+				dev->stats.rx_packets++;
+				dev->stats.rx_bytes +=3D pkt_len;
+
+				/* Update the mcast stats */
+				if (devcs & ETH_RX_MP)
+					dev->stats.multicast++;
+
+				lp->rx_skb[lp->rx_next_done] =3D skb_new;
+			}
+
+			rd->devcs =3D 0;
+
+			/* Restore descriptor's curr_addr */
+			if (skb_new)
+				rd->ca =3D CPHYSADDR(skb_new->data);
+			else
+				rd->ca =3D CPHYSADDR(skb->data);
+
+			rd->control =3D DMA_COUNT(KORINA_RBSIZE) |
+				DMA_DESC_COD | DMA_DESC_IOD;
+			lp->rd_ring[(lp->rx_next_done - 1) &
+				KORINA_RDS_MASK].control &=3D
+				~DMA_DESC_COD;
+
+			lp->rx_next_done =3D (lp->rx_next_done + 1) & KORINA_RDS_MASK;
+			dma_cache_wback((u32)rd, sizeof(*rd));
+			rd =3D &lp->rd_ring[lp->rx_next_done];
+			writel(~DMA_STAT_DONE, &lp->rx_dma_regs->dmas);
+		}
+	}
+
+	dmas =3D readl(&lp->rx_dma_regs->dmas);
+
+	if (dmas & DMA_STAT_HALT) {
+		writel(~(DMA_STAT_HALT | DMA_STAT_ERR),
+				&lp->rx_dma_regs->dmas);
+
+		lp->dma_halt_cnt++;
+		rd->devcs =3D 0;
+		skb =3D lp->rx_skb[lp->rx_next_done];
+		rd->ca =3D CPHYSADDR(skb->data);
+		dma_cache_wback((u32)rd, sizeof(*rd));
+		korina_chain_rx(lp, rd);
+	}
+
+	return count;
+}
+
+static int korina_poll(struct napi_struct *napi, int budget)
+{
+	struct korina_private *lp =3D
+		container_of(napi, struct korina_private, napi);
+	struct net_device *dev =3D lp->dev;
+	int work_done;
+
+	work_done =3D korina_rx(dev, budget);
+	if (work_done < budget) {
+		netif_rx_complete(dev, napi);
+
+		writel(readl(&lp->rx_dma_regs->dmasm) &
+			~(DMA_STAT_DONE | DMA_STAT_HALT | DMA_STAT_ERR),
+			&lp->rx_dma_regs->dmasm);
+	}
+	return work_done;
+}
+
+/*
+ * Set or clear the multicast filter for this adaptor.
+ */
+static void korina_multicast_list(struct net_device *dev)
+{
+	struct korina_private *lp =3D netdev_priv(dev);
+	unsigned long flags;
+	struct dev_mc_list *dmi =3D dev->mc_list;
+	u32 recognise =3D ETH_ARC_AB;	/* always accept broadcasts */
+	int i;
+
+	/* Set promiscuous mode */
+	if (dev->flags & IFF_PROMISC)
+		recognise |=3D ETH_ARC_PRO;
+
+	else if ((dev->flags & IFF_ALLMULTI) || (dev->mc_count > 4))
+		/* All multicast and broadcast */
+		recognise |=3D ETH_ARC_AM;
+
+	/* Build the hash table */
+	if (dev->mc_count > 4) {
+		u16 hash_table[4];
+		u32 crc;
+
+		for (i =3D 0; i < 4; i++)
+			hash_table[i] =3D 0;
+
+		for (i =3D 0; i < dev->mc_count; i++) {
+			char *addrs =3D dmi->dmi_addr;
+
+			dmi =3D dmi->next;
+
+			if (!(*addrs & 1))
+				continue;
+
+			crc =3D ether_crc_le(6, addrs);
+			crc >>=3D 26;
+			hash_table[crc >> 4] |=3D 1 << (15 - (crc & 0xf));
+		}
+		/* Accept filtered multicast */
+		recognise |=3D ETH_ARC_AFM;
+
+		/* Fill the MAC hash tables with their values */
+		writel((u32)(hash_table[1] << 16 | hash_table[0]),
+					&lp->eth_regs->ethhash0);
+		writel((u32)(hash_table[3] << 16 | hash_table[2]),
+					&lp->eth_regs->ethhash1);
+	}
+
+	spin_lock_irqsave(&lp->lock, flags);
+	writel(recognise, &lp->eth_regs->etharc);
+	spin_unlock_irqrestore(&lp->lock, flags);
+}
+
+static void korina_tx(struct net_device *dev)
+{
+	struct korina_private *lp =3D netdev_priv(dev);
+	struct dma_desc *td =3D &lp->td_ring[lp->tx_next_done];
+	u32 devcs;
+	u32 dmas;
+
+	spin_lock(&lp->lock);
+
+	/* Process all desc that are done */
+	while (IS_DMA_FINISHED(td->control)) {
+		if (lp->tx_full =3D=3D 1) {
+			netif_wake_queue(dev);
+			lp->tx_full =3D 0;
+		}
+
+		devcs =3D lp->td_ring[lp->tx_next_done].devcs;
+		if ((devcs & (ETH_TX_FD | ETH_TX_LD)) !=3D
+				(ETH_TX_FD | ETH_TX_LD)) {
+			dev->stats.tx_errors++;
+			dev->stats.tx_dropped++;
+
+			/* Should never happen */
+			printk(KERN_ERR DRV_NAME "%s: split tx ignored\n",
+							dev->name);
+		} else if (devcs & ETH_TX_TOK) {
+			dev->stats.tx_packets++;
+			dev->stats.tx_bytes +=3D
+					lp->tx_skb[lp->tx_next_done]->len;
+		} else {
+			dev->stats.tx_errors++;
+			dev->stats.tx_dropped++;
+
+			/* Underflow */
+			if (devcs & ETH_TX_UND)
+				dev->stats.tx_fifo_errors++;
+
+			/* Oversized frame */
+			if (devcs & ETH_TX_OF)
+				dev->stats.tx_aborted_errors++;
+
+			/* Excessive deferrals */
+			if (devcs & ETH_TX_ED)
+				dev->stats.tx_carrier_errors++;
+
+			/* Collisions: medium busy */
+			if (devcs & ETH_TX_EC)
+				dev->stats.collisions++;
+
+			/* Late collision */
+			if (devcs & ETH_TX_LC)
+				dev->stats.tx_window_errors++;
+		}
+
+		/* We must always free the original skb */
+		if (lp->tx_skb[lp->tx_next_done]) {
+			dev_kfree_skb_any(lp->tx_skb[lp->tx_next_done]);
+			lp->tx_skb[lp->tx_next_done] =3D NULL;
+		}
+
+		lp->td_ring[lp->tx_next_done].control =3D DMA_DESC_IOF;
+		lp->td_ring[lp->tx_next_done].devcs =3D ETH_TX_FD | ETH_TX_LD;
+		lp->td_ring[lp->tx_next_done].link =3D 0;
+		lp->td_ring[lp->tx_next_done].ca =3D 0;
+		lp->tx_count--;
+
+		/* Go on to next transmission */
+		lp->tx_next_done =3D (lp->tx_next_done + 1) & KORINA_TDS_MASK;
+		td =3D &lp->td_ring[lp->tx_next_done];
+
+	}
+
+	/* Clear the DMA status register */
+	dmas =3D readl(&lp->tx_dma_regs->dmas);
+	writel(~dmas, &lp->tx_dma_regs->dmas);
+
+	writel(readl(&lp->tx_dma_regs->dmasm) &
+			~(DMA_STAT_FINI | DMA_STAT_ERR),
+			&lp->tx_dma_regs->dmasm);
+
+	spin_unlock(&lp->lock);
+}
+
+static irqreturn_t
+korina_tx_dma_interrupt(int irq, void *dev_id)
+{
+	struct net_device *dev =3D dev_id;
+	struct korina_private *lp =3D netdev_priv(dev);
+	u32 dmas, dmasm;
+	irqreturn_t retval;
+
+	dmas =3D readl(&lp->tx_dma_regs->dmas);
+
+	if (dmas & (DMA_STAT_FINI | DMA_STAT_ERR)) {
+		korina_tx(dev);
+
+		dmasm =3D readl(&lp->tx_dma_regs->dmasm);
+		writel(dmasm | (DMA_STAT_FINI | DMA_STAT_ERR),
+				&lp->tx_dma_regs->dmasm);
+
+		if (lp->tx_chain_status =3D=3D desc_filled &&
+			(readl(&(lp->tx_dma_regs->dmandptr)) =3D=3D 0)) {
+			writel(CPHYSADDR(&lp->td_ring[lp->tx_chain_head]),
+				&(lp->tx_dma_regs->dmandptr));
+			lp->tx_chain_status =3D desc_empty;
+			lp->tx_chain_head =3D lp->tx_chain_tail;
+			dev->trans_start =3D jiffies;
+		}
+		if (dmas & DMA_STAT_ERR)
+			printk(KERN_ERR DRV_NAME "%s: DMA error\n", dev->name);
+
+		retval =3D IRQ_HANDLED;
+	} else
+		retval =3D IRQ_NONE;
+
+	return retval;
+}
+
+
+static void korina_check_media(struct net_device *dev, unsigned int in=
it_media)
+{
+	struct korina_private *lp =3D netdev_priv(dev);
+
+	mii_check_media(&lp->mii_if, 0, init_media);
+
+	if (lp->mii_if.full_duplex)
+		writel(readl(&lp->eth_regs->ethmac2) | ETH_MAC2_FD,
+						&lp->eth_regs->ethmac2);
+	else
+		writel(readl(&lp->eth_regs->ethmac2) & ~ETH_MAC2_FD,
+						&lp->eth_regs->ethmac2);
+}
+
+static void korina_set_carrier(struct mii_if_info *mii)
+{
+	if (mii->force_media) {
+		/* autoneg is off: Link is always assumed to be up */
+		if (!netif_carrier_ok(mii->dev))
+			netif_carrier_on(mii->dev);
+	} else  /* Let MMI library update carrier status */
+		korina_check_media(mii->dev, 0);
+}
+
+static int korina_ioctl(struct net_device *dev, struct ifreq *rq, int =
cmd)
+{
+	struct korina_private *lp =3D netdev_priv(dev);
+	struct mii_ioctl_data *data =3D if_mii(rq);
+	int rc;
+
+	if (!netif_running(dev))
+		return -EINVAL;
+	spin_lock_irq(&lp->lock);
+	rc =3D generic_mii_ioctl(&lp->mii_if, data, cmd, NULL);
+	spin_unlock_irq(&lp->lock);
+	korina_set_carrier(&lp->mii_if);
+
+	return rc;
+}
+
+/* ethtool helpers */
+static void netdev_get_drvinfo(struct net_device *dev,
+			struct ethtool_drvinfo *info)
+{
+	struct korina_private *lp =3D netdev_priv(dev);
+
+	strcpy(info->driver, DRV_NAME);
+	strcpy(info->version, DRV_VERSION);
+	strcpy(info->bus_info, lp->dev->name);
+}
+
+static int netdev_get_settings(struct net_device *dev, struct ethtool_=
cmd *cmd)
+{
+	struct korina_private *lp =3D netdev_priv(dev);
+	int rc;
+
+	spin_lock_irq(&lp->lock);
+	rc =3D mii_ethtool_gset(&lp->mii_if, cmd);
+	spin_unlock_irq(&lp->lock);
+
+	return rc;
+}
+
+static int netdev_set_settings(struct net_device *dev, struct ethtool_=
cmd *cmd)
+{
+	struct korina_private *lp =3D netdev_priv(dev);
+	int rc;
+
+	spin_lock_irq(&lp->lock);
+	rc =3D mii_ethtool_sset(&lp->mii_if, cmd);
+	spin_unlock_irq(&lp->lock);
+	korina_set_carrier(&lp->mii_if);
+
+	return rc;
+}
+
+static u32 netdev_get_link(struct net_device *dev)
+{
+	struct korina_private *lp =3D netdev_priv(dev);
+
+	return mii_link_ok(&lp->mii_if);
+}
+
+static struct ethtool_ops netdev_ethtool_ops =3D {
+	.get_drvinfo            =3D netdev_get_drvinfo,
+	.get_settings           =3D netdev_get_settings,
+	.set_settings           =3D netdev_set_settings,
+	.get_link               =3D netdev_get_link,
+};
+
+static void korina_alloc_ring(struct net_device *dev)
+{
+	struct korina_private *lp =3D netdev_priv(dev);
+	int i;
+
+	/* Initialize the transmit descriptors */
+	for (i =3D 0; i < KORINA_NUM_TDS; i++) {
+		lp->td_ring[i].control =3D DMA_DESC_IOF;
+		lp->td_ring[i].devcs =3D ETH_TX_FD | ETH_TX_LD;
+		lp->td_ring[i].ca =3D 0;
+		lp->td_ring[i].link =3D 0;
+	}
+	lp->tx_next_done =3D lp->tx_chain_head =3D lp->tx_chain_tail =3D
+			lp->tx_full =3D lp->tx_count =3D 0;
+	lp->tx_chain_status =3D desc_empty;
+
+	/* Initialize the receive descriptors */
+	for (i =3D 0; i < KORINA_NUM_RDS; i++) {
+		struct sk_buff *skb =3D lp->rx_skb[i];
+
+		skb =3D dev_alloc_skb(KORINA_RBSIZE + 2);
+		if (!skb)
+			break;
+		skb_reserve(skb, 2);
+		lp->rx_skb[i] =3D skb;
+		lp->rd_ring[i].control =3D DMA_DESC_IOD |
+				DMA_COUNT(KORINA_RBSIZE);
+		lp->rd_ring[i].devcs =3D 0;
+		lp->rd_ring[i].ca =3D CPHYSADDR(skb->data);
+		lp->rd_ring[i].link =3D CPHYSADDR(&lp->rd_ring[i+1]);
+	}
+
+	/* loop back */
+	lp->rd_ring[i].link =3D CPHYSADDR(&lp->rd_ring[0]);
+	lp->rx_next_done  =3D 0;
+
+	lp->rd_ring[i].control |=3D DMA_DESC_COD;
+	lp->rx_chain_head =3D 0;
+	lp->rx_chain_tail =3D 0;
+	lp->rx_chain_status =3D desc_empty;
+}
+
+static void korina_free_ring(struct net_device *dev)
+{
+	struct korina_private *lp =3D netdev_priv(dev);
+	int i;
+
+	for (i =3D 0; i < KORINA_NUM_RDS; i++) {
+		lp->rd_ring[i].control =3D 0;
+		if (lp->rx_skb[i])
+			dev_kfree_skb_any(lp->rx_skb[i]);
+		lp->rx_skb[i] =3D NULL;
+	}
+
+	for (i =3D 0; i < KORINA_NUM_TDS; i++) {
+		lp->td_ring[i].control =3D 0;
+		if (lp->tx_skb[i])
+			dev_kfree_skb_any(lp->tx_skb[i]);
+		lp->tx_skb[i] =3D NULL;
+	}
+}
+
+/*
+ * Initialize the RC32434 ethernet controller.
+ */
+static int korina_init(struct net_device *dev)
+{
+	struct korina_private *lp =3D netdev_priv(dev);
+
+	/* Disable DMA */
+	korina_abort_tx(dev);
+	korina_abort_rx(dev);
+
+	/* reset ethernet logic */
+	writel(0, &lp->eth_regs->ethintfc);
+	while ((readl(&lp->eth_regs->ethintfc) & ETH_INT_FC_RIP))
+		dev->trans_start =3D jiffies;
+
+	/* Enable Ethernet Interface */
+	writel(ETH_INT_FC_EN, &lp->eth_regs->ethintfc);
+
+	/* Allocate rings */
+	korina_alloc_ring(dev);
+
+	writel(0, &lp->rx_dma_regs->dmas);
+	/* Start Rx DMA */
+	korina_start_rx(lp, &lp->rd_ring[0]);
+
+	writel(readl(&lp->tx_dma_regs->dmasm) &
+			~(DMA_STAT_FINI | DMA_STAT_ERR),
+			&lp->tx_dma_regs->dmasm);
+	writel(readl(&lp->rx_dma_regs->dmasm) &
+			~(DMA_STAT_DONE | DMA_STAT_HALT | DMA_STAT_ERR),
+			&lp->rx_dma_regs->dmasm);
+
+	/* Accept only packets destined for this Ethernet device address */
+	writel(ETH_ARC_AB, &lp->eth_regs->etharc);
+
+	/* Set all Ether station address registers to their initial values */
+	writel(STATION_ADDRESS_LOW(dev), &lp->eth_regs->ethsal0);
+	writel(STATION_ADDRESS_HIGH(dev), &lp->eth_regs->ethsah0);
+
+	writel(STATION_ADDRESS_LOW(dev), &lp->eth_regs->ethsal1);
+	writel(STATION_ADDRESS_HIGH(dev), &lp->eth_regs->ethsah1);
+
+	writel(STATION_ADDRESS_LOW(dev), &lp->eth_regs->ethsal2);
+	writel(STATION_ADDRESS_HIGH(dev), &lp->eth_regs->ethsah2);
+
+	writel(STATION_ADDRESS_LOW(dev), &lp->eth_regs->ethsal3);
+	writel(STATION_ADDRESS_HIGH(dev), &lp->eth_regs->ethsah3);
+
+
+	/* Frame Length Checking, Pad Enable, CRC Enable, Full Duplex set */
+	writel(ETH_MAC2_PE | ETH_MAC2_CEN | ETH_MAC2_FD,
+			&lp->eth_regs->ethmac2);
+
+	/* Back to back inter-packet-gap */
+	writel(0x15, &lp->eth_regs->ethipgt);
+	/* Non - Back to back inter-packet-gap */
+	writel(0x12, &lp->eth_regs->ethipgr);
+
+	/* Management Clock Prescaler Divisor
+	 * Clock independent setting */
+	writel(((idt_cpu_freq) / MII_CLOCK + 1) & ~1,
+		       &lp->eth_regs->ethmcp);
+
+	/* don't transmit until fifo contains 48b */
+	writel(48, &lp->eth_regs->ethfifott);
+
+	writel(ETH_MAC1_RE, &lp->eth_regs->ethmac1);
+
+	napi_enable(&lp->napi);
+	netif_start_queue(dev);
+
+	return 0;
+}
+
+/*
+ * Restart the RC32434 ethernet controller.
+ * FIXME: check the return status where we call it
+ */
+static int korina_restart(struct net_device *dev)
+{
+	struct korina_private *lp =3D netdev_priv(dev);
+	int ret =3D 0;
+
+	/*
+	 * Disable interrupts
+	 */
+	disable_irq(lp->rx_irq);
+	disable_irq(lp->tx_irq);
+	disable_irq(lp->ovr_irq);
+	disable_irq(lp->und_irq);
+
+	writel(readl(&lp->tx_dma_regs->dmasm) |
+				DMA_STAT_FINI | DMA_STAT_ERR,
+				&lp->tx_dma_regs->dmasm);
+	writel(readl(&lp->rx_dma_regs->dmasm) |
+				DMA_STAT_DONE | DMA_STAT_HALT | DMA_STAT_ERR,
+				&lp->rx_dma_regs->dmasm);
+
+	korina_free_ring(dev);
+
+	ret =3D korina_init(dev);
+	if (ret < 0) {
+		printk(KERN_ERR DRV_NAME "%s: cannot restart device\n",
+								dev->name);
+		return ret;
+	}
+	korina_multicast_list(dev);
+
+	enable_irq(lp->und_irq);
+	enable_irq(lp->ovr_irq);
+	enable_irq(lp->tx_irq);
+	enable_irq(lp->rx_irq);
+
+	return ret;
+}
+
+static void korina_clear_and_restart(struct net_device *dev, u32 value=
)
+{
+	struct korina_private *lp =3D netdev_priv(dev);
+
+	netif_stop_queue(dev);
+	writel(value, &lp->eth_regs->ethintfc);
+	korina_restart(dev);
+}
+
+/* Ethernet Tx Underflow interrupt */
+static irqreturn_t korina_und_interrupt(int irq, void *dev_id)
+{
+	struct net_device *dev =3D dev_id;
+	struct korina_private *lp =3D netdev_priv(dev);
+	unsigned int und;
+
+	spin_lock(&lp->lock);
+
+	und =3D readl(&lp->eth_regs->ethintfc);
+
+	if (und & ETH_INT_FC_UND)
+		korina_clear_and_restart(dev, und & ~ETH_INT_FC_UND);
+
+	spin_unlock(&lp->lock);
+
+	return IRQ_HANDLED;
+}
+
+static void korina_tx_timeout(struct net_device *dev)
+{
+	struct korina_private *lp =3D netdev_priv(dev);
+	unsigned long flags;
+
+	spin_lock_irqsave(&lp->lock, flags);
+	korina_restart(dev);
+	spin_unlock_irqrestore(&lp->lock, flags);
+}
+
+/* Ethernet Rx Overflow interrupt */
+static irqreturn_t
+korina_ovr_interrupt(int irq, void *dev_id)
+{
+	struct net_device *dev =3D dev_id;
+	struct korina_private *lp =3D netdev_priv(dev);
+	unsigned int ovr;
+
+	spin_lock(&lp->lock);
+	ovr =3D readl(&lp->eth_regs->ethintfc);
+
+	if (ovr & ETH_INT_FC_OVR)
+		korina_clear_and_restart(dev, ovr & ~ETH_INT_FC_OVR);
+
+	spin_unlock(&lp->lock);
+
+	return IRQ_HANDLED;
+}
+
+#ifdef CONFIG_NET_POLL_CONTROLLER
+static void korina_poll_controller(struct net_device *dev)
+{
+	disable_irq(dev->irq);
+	korina_tx_dma_interrupt(dev->irq, dev);
+	enable_irq(dev->irq);
+}
+#endif
+
+static int korina_open(struct net_device *dev)
+{
+	struct korina_private *lp =3D netdev_priv(dev);
+	int ret =3D 0;
+
+	/* Initialize */
+	ret =3D korina_init(dev);
+	if (ret < 0) {
+		printk(KERN_ERR DRV_NAME "%s: cannot open device\n", dev->name);
+		goto out;
+	}
+
+	/* Install the interrupt handler
+	 * that handles the Done Finished
+	 * Ovr and Und Events */
+	ret =3D request_irq(lp->rx_irq, &korina_rx_dma_interrupt,
+		IRQF_SHARED | IRQF_DISABLED, "Korina ethernet Rx", dev);
+	if (ret < 0) {
+		printk(KERN_ERR DRV_NAME "%s: unable to get Rx DMA IRQ %d\n",
+		    dev->name, lp->rx_irq);
+		goto err_release;
+	}
+	ret =3D request_irq(lp->tx_irq, &korina_tx_dma_interrupt,
+		IRQF_SHARED | IRQF_DISABLED, "Korina ethernet Tx", dev);
+	if (ret < 0) {
+		printk(KERN_ERR DRV_NAME "%s: unable to get Tx DMA IRQ %d\n",
+		    dev->name, lp->tx_irq);
+		goto err_free_rx_irq;
+	}
+
+	/* Install handler for overrun error. */
+	ret =3D request_irq(lp->ovr_irq, &korina_ovr_interrupt,
+			IRQF_SHARED | IRQF_DISABLED, "Ethernet Overflow", dev);
+	if (ret < 0) {
+		printk(KERN_ERR DRV_NAME"%s: unable to get OVR IRQ %d\n",
+		    dev->name, lp->ovr_irq);
+		goto err_free_tx_irq;
+	}
+
+	/* Install handler for underflow error. */
+	ret =3D request_irq(lp->und_irq, &korina_und_interrupt,
+			IRQF_SHARED | IRQF_DISABLED, "Ethernet Underflow", dev);
+	if (ret < 0) {
+		printk(KERN_ERR DRV_NAME "%s: unable to get UND IRQ %d\n",
+		    dev->name, lp->und_irq);
+		goto err_free_ovr_irq;
+	}
+
+err_free_ovr_irq:
+	free_irq(lp->ovr_irq, dev);
+err_free_tx_irq:
+	free_irq(lp->tx_irq, dev);
+err_free_rx_irq:
+	free_irq(lp->rx_irq, dev);
+err_release:
+	korina_free_ring(dev);
+	goto out;
+out:
+	return ret;
+}
+
+static int korina_close(struct net_device *dev)
+{
+	struct korina_private *lp =3D netdev_priv(dev);
+	u32 tmp;
+
+	/* Disable interrupts */
+	disable_irq(lp->rx_irq);
+	disable_irq(lp->tx_irq);
+	disable_irq(lp->ovr_irq);
+	disable_irq(lp->und_irq);
+
+	korina_abort_tx(dev);
+	tmp =3D readl(&lp->tx_dma_regs->dmasm);
+	tmp =3D tmp | DMA_STAT_FINI | DMA_STAT_ERR;
+	writel(tmp, &lp->tx_dma_regs->dmasm);
+
+	korina_abort_rx(dev);
+	tmp =3D readl(&lp->rx_dma_regs->dmasm);
+	tmp =3D tmp | DMA_STAT_DONE | DMA_STAT_HALT | DMA_STAT_ERR;
+	writel(tmp, &lp->rx_dma_regs->dmasm);
+
+	korina_free_ring(dev);
+
+	free_irq(lp->rx_irq, dev);
+	free_irq(lp->tx_irq, dev);
+	free_irq(lp->ovr_irq, dev);
+	free_irq(lp->und_irq, dev);
+
+	return 0;
+}
+
+static int korina_probe(struct platform_device *pdev)
+{
+	struct korina_device *bif =3D platform_get_drvdata(pdev);
+	struct korina_private *lp;
+	struct net_device *dev;
+	struct resource *r;
+	int retval, err;
+
+	dev =3D alloc_etherdev(sizeof(struct korina_private));
+	if (!dev) {
+		printk(KERN_ERR DRV_NAME ": alloc_etherdev failed\n");
+		return -ENOMEM;
+	}
+	SET_NETDEV_DEV(dev, &pdev->dev);
+	platform_set_drvdata(pdev, dev);
+	lp =3D netdev_priv(dev);
+
+	bif->dev =3D dev;
+	memcpy(dev->dev_addr, bif->mac, 6);
+
+	lp->rx_irq =3D platform_get_irq_byname(pdev, "korina_rx");
+	lp->tx_irq =3D platform_get_irq_byname(pdev, "korina_tx");
+	lp->ovr_irq =3D platform_get_irq_byname(pdev, "korina_ovr");
+	lp->und_irq =3D platform_get_irq_byname(pdev, "korina_und");
+
+	r =3D platform_get_resource_byname(pdev, IORESOURCE_MEM, "korina_regs=
");
+	dev->base_addr =3D r->start;
+	lp->eth_regs =3D ioremap_nocache(r->start, r->end - r->start);
+	if (!lp->eth_regs) {
+		printk(KERN_ERR DRV_NAME "cannot remap registers\n");
+		retval =3D -ENXIO;
+		goto probe_err_out;
+	}
+
+	r =3D platform_get_resource_byname(pdev, IORESOURCE_MEM, "korina_dma_=
rx");
+	lp->rx_dma_regs =3D ioremap_nocache(r->start, r->end - r->start);
+	if (!lp->rx_dma_regs) {
+		printk(KERN_ERR DRV_NAME "cannot remap Rx DMA registers\n");
+		retval =3D -ENXIO;
+		goto probe_err_dma_rx;
+	}
+
+	r =3D platform_get_resource_byname(pdev, IORESOURCE_MEM, "korina_dma_=
tx");
+	lp->tx_dma_regs =3D ioremap_nocache(r->start, r->end - r->start);
+	if (!lp->tx_dma_regs) {
+		printk(KERN_ERR DRV_NAME "cannot remap Tx DMA registers\n");
+		retval =3D -ENXIO;
+		goto probe_err_dma_tx;
+	}
+
+	lp->td_ring =3D kmalloc(TD_RING_SIZE + RD_RING_SIZE, GFP_KERNEL);
+	if (!lp->td_ring) {
+		printk(KERN_ERR DRV_NAME "cannot allocate descriptors\n");
+		retval =3D -ENOMEM;
+		goto probe_err_td_ring;
+	}
+
+	dma_cache_inv((unsigned long)(lp->td_ring),
+			TD_RING_SIZE + RD_RING_SIZE);
+
+	/* now convert TD_RING pointer to KSEG1 */
+	lp->td_ring =3D (struct dma_desc *)KSEG1ADDR(lp->td_ring);
+	lp->rd_ring =3D &lp->td_ring[KORINA_NUM_TDS];
+
+	spin_lock_init(&lp->lock);
+	/* just use the rx dma irq */
+	dev->irq =3D lp->rx_irq;
+	lp->dev =3D dev;
+
+	dev->open =3D korina_open;
+	dev->stop =3D korina_close;
+	dev->hard_start_xmit =3D korina_send_packet;
+	dev->set_multicast_list =3D &korina_multicast_list;
+	dev->ethtool_ops =3D &netdev_ethtool_ops;
+	dev->tx_timeout =3D korina_tx_timeout;
+	dev->watchdog_timeo =3D TX_TIMEOUT;
+	dev->do_ioctl =3D &korina_ioctl;
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	dev->poll_controller =3D korina_poll_controller;
+#endif
+	netif_napi_add(dev, &lp->napi, korina_poll, 64);
+
+	lp->phy_addr =3D (((lp->rx_irq =3D=3D 0x2c? 1:0) << 8) | 0x05);
+	lp->mii_if.dev =3D dev;
+	lp->mii_if.mdio_read =3D mdio_read;
+	lp->mii_if.mdio_write =3D mdio_write;
+	lp->mii_if.phy_id =3D lp->phy_addr;
+	lp->mii_if.phy_id_mask =3D 0x1f;
+	lp->mii_if.reg_num_mask =3D 0x1f;
+
+	err =3D register_netdev(dev);
+	if (err) {
+		printk(KERN_ERR DRV_NAME
+			": cannot register net device %d\n", err);
+		retval =3D -EINVAL;
+		goto probe_err_register;
+	}
+	return 0;
+
+probe_err_register:
+	kfree(lp->td_ring);
+probe_err_td_ring:
+	iounmap(lp->tx_dma_regs);
+probe_err_dma_tx:
+	iounmap(lp->rx_dma_regs);
+probe_err_dma_rx:
+	iounmap(lp->eth_regs);
+probe_err_out:
+	free_netdev(dev);
+	return retval;
+}
+
+static int korina_remove(struct platform_device *pdev)
+{
+	struct korina_device *bif =3D platform_get_drvdata(pdev);
+	struct korina_private *lp =3D netdev_priv(bif->dev);
+
+	if (lp->eth_regs)
+		iounmap(lp->eth_regs);
+	if (lp->rx_dma_regs)
+		iounmap(lp->rx_dma_regs);
+	if (lp->tx_dma_regs)
+		iounmap(lp->tx_dma_regs);
+
+	platform_set_drvdata(pdev, NULL);
+	unregister_netdev(bif->dev);
+	free_netdev(bif->dev);
+
+	return 0;
+}
+
+static struct platform_driver korina_driver =3D {
+	.driver.name =3D "korina",
+	.probe =3D korina_probe,
+	.remove =3D korina_remove,
+};
+
+static int __init korina_init_module(void)
+{
+	return platform_driver_register(&korina_driver);
+}
+
+static void korina_cleanup_module(void)
+{
+	return platform_driver_unregister(&korina_driver);
+}
+
+module_init(korina_init_module);
+module_exit(korina_cleanup_module);
+
+MODULE_AUTHOR("Philip Rischel <rischelp@idt.com>");
+MODULE_AUTHOR("Felix Fietkau <nbd@openwrt.org>");
+MODULE_AUTHOR("Florian Fainelli <florian@openwrt.org>");
+MODULE_DESCRIPTION("IDT RC32434 (Korina) Ethernet driver");
+MODULE_LICENSE("GPL");
