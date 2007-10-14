From: Domen Puncer <domen.puncer@telargo.com>
Subject: [PATCH v3 3/4] FEC mpc52xx: the driver
Date: Sun, 14 Oct 2007 09:59:21 +0200
Message-ID: <20071014075921.GF3000@nd47.coderock.org>
References: <20071014075511.GC3000@nd47.coderock.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org
To: galak@kernel.crashing.org, jgarzik@pobox.com
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
Content-Disposition: inline
In-Reply-To: <20071014075511.GC3000@nd47.coderock.org>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

Driver for ethernet on mpc5200/mpc5200b SoCs (FEC).


Signed-off-by: Domen Puncer <domen.puncer@telargo.com>

---
 drivers/net/Kconfig              |    1 
 drivers/net/Makefile             |    1 
 drivers/net/fec_mpc52xx/Kconfig  |   15 
 drivers/net/fec_mpc52xx/Makefile |    2 
 drivers/net/fec_mpc52xx/fec.c    | 1098 +++++++++++++++++++++++++++++++++++++++
 drivers/net/fec_mpc52xx/fec.h    |  313 +++++++++++
 6 files changed, 1430 insertions(+)

Index: linux.git/drivers/net/Kconfig
===================================================================
--- linux.git.orig/drivers/net/Kconfig
+++ linux.git/drivers/net/Kconfig
@@ -1894,6 +1894,7 @@ config NE_H8300
 	  controller on the Renesas H8/300 processor.
 
 source "drivers/net/fec_8xx/Kconfig"
+source "drivers/net/fec_mpc52xx/Kconfig"
 source "drivers/net/fs_enet/Kconfig"
 
 endif # NET_ETHERNET
Index: linux.git/drivers/net/Makefile
===================================================================
--- linux.git.orig/drivers/net/Makefile
+++ linux.git/drivers/net/Makefile
@@ -210,6 +210,7 @@ obj-$(CONFIG_SMC911X) += smc911x.o
 obj-$(CONFIG_BFIN_MAC) += bfin_mac.o
 obj-$(CONFIG_DM9000) += dm9000.o
 obj-$(CONFIG_FEC_8XX) += fec_8xx/
+obj-$(CONFIG_FEC_MPC52xx) += fec_mpc52xx/
 obj-$(CONFIG_PASEMI_MAC) += pasemi_mac.o
 obj-$(CONFIG_MLX4_CORE) += mlx4/
 
Index: linux.git/drivers/net/fec_mpc52xx/Kconfig
===================================================================
--- /dev/null
+++ linux.git/drivers/net/fec_mpc52xx/Kconfig
@@ -0,0 +1,15 @@
+menu "MPC5200 Networking Options"
+	depends PPC_MPC52xx && NET_ETHERNET
+
+config FEC_MPC52xx
+	tristate "FEC driver"
+	depends on NET_ETHERNET
+	select PPC_BESTCOMM
+	select PPC_BESTCOMM_FEC
+	select CRC32
+	select PHYLIB
+	---help---
+	  This option enables support for the MPC5200's on-chip
+	  Fast Ethernet Controller
+
+endmenu
Index: linux.git/drivers/net/fec_mpc52xx/Makefile
===================================================================
--- /dev/null
+++ linux.git/drivers/net/fec_mpc52xx/Makefile
@@ -0,0 +1,2 @@
+obj-$(CONFIG_FEC_MPC52xx) += fec_mpc52xx.o
+fec_mpc52xx-objs := fec.o
Index: linux.git/drivers/net/fec_mpc52xx/fec.c
===================================================================
--- /dev/null
+++ linux.git/drivers/net/fec_mpc52xx/fec.c
@@ -0,0 +1,1098 @@
+/*
+ * drivers/drivers/net/fec_mpc52xx/fec.c
+ *
+ * Driver for the MPC5200 Fast Ethernet Controller
+ *
+ * Originally written by Dale Farnsworth <dfarnsworth@mvista.com> and
+ * now maintained by Sylvain Munaut <tnt@246tNt.com>
+ *
+ * Copyright (C) 2007  Domen Puncer, Telargo, Inc.
+ * Copyright (C) 2007  Sylvain Munaut <tnt@246tNt.com>
+ * Copyright (C) 2003-2004  MontaVista, Software, Inc.
+ *
+ * This file is licensed under the terms of the GNU General Public License
+ * version 2. This program is licensed "as is" without any warranty of any
+ * kind, whether express or implied.
+ *
+ */
+
+#include <linux/module.h>
+
+#include <linux/kernel.h>
+#include <linux/types.h>
+#include <linux/spinlock.h>
+#include <linux/errno.h>
+#include <linux/init.h>
+#include <linux/crc32.h>
+#include <linux/hardirq.h>
+#include <linux/delay.h>
+#include <linux/of_device.h>
+#include <linux/of_platform.h>
+
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/ethtool.h>
+#include <linux/skbuff.h>
+
+#include <asm/io.h>
+#include <asm/delay.h>
+#include <asm/mpc52xx.h>
+
+#include <sysdev/bestcomm/bestcomm.h>
+#include <sysdev/bestcomm/fec.h>
+
+#include "fec.h"
+
+#define DRIVER_NAME "mpc52xx-fec"
+
+static irqreturn_t fec_interrupt(int, void *);
+static irqreturn_t fec_rx_interrupt(int, void *);
+static irqreturn_t fec_tx_interrupt(int, void *);
+static void fec_stop(struct net_device *dev);
+static void fec_start(struct net_device *dev);
+static void fec_reset(struct net_device *dev);
+
+static u8 mpc52xx_fec_mac_addr[6];
+module_param_array_named(mac, mpc52xx_fec_mac_addr, byte, NULL, 0);
+MODULE_PARM_DESC(mac, "six hex digits, ie. 0x1,0x2,0xc0,0x01,0xba,0xbe");
+
+static void fec_tx_timeout(struct net_device *dev)
+{
+	struct fec_priv *priv = netdev_priv(dev);
+
+	dev_warn(&dev->dev, "transmit timed out\n");
+
+	fec_reset(dev);
+
+	priv->stats.tx_errors++;
+
+	if (!priv->tx_full)
+		netif_wake_queue(dev);
+}
+
+static void fec_set_paddr(struct net_device *dev, u8 *mac)
+{
+	struct fec_priv *priv = netdev_priv(dev);
+	struct mpc52xx_fec __iomem *fec = priv->fec;
+
+	out_be32(&fec->paddr1, *(u32 *)(&mac[0]));
+	out_be32(&fec->paddr2, (*(u16 *)(&mac[4]) << 16) | FEC_PADDR2_TYPE);
+}
+
+static void fec_get_paddr(struct net_device *dev, u8 *mac)
+{
+	struct fec_priv *priv = netdev_priv(dev);
+	struct mpc52xx_fec __iomem *fec = priv->fec;
+
+	*(u32 *)(&mac[0]) = in_be32(&fec->paddr1);
+	*(u16 *)(&mac[4]) = in_be32(&fec->paddr2) >> 16;
+}
+
+static int fec_set_mac_address(struct net_device *dev, void *addr)
+{
+	struct sockaddr *sock = addr;
+
+	memcpy(dev->dev_addr, sock->sa_data, dev->addr_len);
+
+	fec_set_paddr(dev, sock->sa_data);
+	return 0;
+}
+
+static void fec_free_rx_buffers(struct bcom_task *s)
+{
+	struct sk_buff *skb;
+
+	while (!bcom_queue_empty(s)) {
+		skb = bcom_retrieve_buffer(s, NULL, NULL);
+		kfree_skb(skb);
+	}
+}
+
+static int fec_alloc_rx_buffers(struct bcom_task *rxtsk)
+{
+	while (!bcom_queue_full(rxtsk)) {
+		struct sk_buff *skb;
+		struct bcom_fec_bd *bd;
+
+		skb = dev_alloc_skb(FEC_RX_BUFFER_SIZE);
+		if (skb == NULL)
+			return -EAGAIN;
+
+		/* zero out the initial receive buffers to aid debugging */
+		memset(skb->data, 0, FEC_RX_BUFFER_SIZE);
+
+		bd = (struct bcom_fec_bd *)bcom_prepare_next_buffer(rxtsk);
+
+		bd->status = FEC_RX_BUFFER_SIZE;
+		bd->skb_pa = virt_to_phys(skb->data);
+
+		bcom_submit_next_buffer(rxtsk, skb);
+	}
+
+	return 0;
+}
+
+/* based on generic_adjust_link from fs_enet-main.c */
+static void fec_adjust_link(struct net_device *dev)
+{
+	struct fec_priv *priv = netdev_priv(dev);
+	struct phy_device *phydev = priv->phydev;
+	int new_state = 0;
+
+	if (phydev->link != PHY_DOWN) {
+		if (phydev->duplex != priv->duplex) {
+			struct mpc52xx_fec __iomem *fec = priv->fec;
+			u32 rcntrl;
+			u32 tcntrl;
+
+			new_state = 1;
+			priv->duplex = phydev->duplex;
+
+			rcntrl = in_be32(&fec->r_cntrl);
+			tcntrl = in_be32(&fec->x_cntrl);
+
+			rcntrl &= ~FEC_RCNTRL_DRT;
+			tcntrl &= ~FEC_TCNTRL_FDEN;
+			if (phydev->duplex == DUPLEX_FULL)
+				tcntrl |= FEC_TCNTRL_FDEN;	/* FD enable */
+			else
+				rcntrl |= FEC_RCNTRL_DRT;	/* disable Rx on Tx (HD) */
+
+			out_be32(&fec->r_cntrl, rcntrl);
+			out_be32(&fec->x_cntrl, tcntrl);
+		}
+
+		if (phydev->speed != priv->speed) {
+			new_state = 1;
+			priv->speed = phydev->speed;
+		}
+
+		if (priv->link == PHY_DOWN) {
+			new_state = 1;
+			priv->link = phydev->link;
+			netif_schedule(dev);
+			netif_carrier_on(dev);
+			netif_start_queue(dev);
+		}
+
+	} else if (priv->link) {
+		new_state = 1;
+		priv->link = PHY_DOWN;
+		priv->speed = 0;
+		priv->duplex = -1;
+		netif_stop_queue(dev);
+		netif_carrier_off(dev);
+	}
+
+	if (new_state && netif_msg_link(priv))
+		phy_print_status(phydev);
+}
+
+static int fec_init_phy(struct net_device *dev)
+{
+	struct fec_priv *priv = netdev_priv(dev);
+	struct phy_device *phydev;
+	char phy_id[BUS_ID_SIZE];
+
+	snprintf(phy_id, BUS_ID_SIZE, PHY_ID_FMT,
+			(unsigned int)dev->base_addr, priv->phy_addr);
+
+	priv->link = PHY_DOWN;
+	priv->speed = 0;
+	priv->duplex = -1;
+
+	phydev = phy_connect(dev, phy_id, &fec_adjust_link, 0, PHY_INTERFACE_MODE_MII);
+	if (IS_ERR(phydev)) {
+		dev_err(&dev->dev, "phy_connect failed\n");
+		return PTR_ERR(phydev);
+	}
+	dev_info(&dev->dev, "attached phy %i to driver %s\n",
+			phydev->addr, phydev->drv->name);
+
+	priv->phydev = phydev;
+
+	return 0;
+}
+
+static int fec_phy_start(struct net_device *dev)
+{
+	struct fec_priv *priv = netdev_priv(dev);
+	int err;
+
+	if (!priv->has_phy)
+		return 0;
+
+	err = fec_init_phy(dev);
+	if (err) {
+		dev_err(&dev->dev, "fec_init_phy failed\n");
+		return err;
+	}
+
+	/* reset phy - this also wakes it from PDOWN */
+	phy_write(priv->phydev, MII_BMCR, BMCR_RESET);
+	phy_start(priv->phydev);
+
+	return 0;
+}
+
+static void fec_phy_stop(struct net_device *dev)
+{
+	struct fec_priv *priv = netdev_priv(dev);
+
+	if (!priv->has_phy)
+		return;
+
+	phy_disconnect(priv->phydev);
+	/* power down phy */
+	phy_stop(priv->phydev);
+	phy_write(priv->phydev, MII_BMCR, BMCR_PDOWN);
+}
+
+static int fec_phy_mii_ioctl(struct fec_priv *priv,
+		struct mii_ioctl_data *mii_data, int cmd)
+{
+	if (!priv->has_phy)
+		return -ENOTSUPP;
+
+	return phy_mii_ioctl(priv->phydev, mii_data, cmd);
+}
+
+static void fec_phy_hw_init(struct fec_priv *priv)
+{
+	struct mpc52xx_fec __iomem *fec = priv->fec;
+
+	if (!priv->has_phy)
+		return;
+
+	out_be32(&fec->mii_speed, priv->phy_speed);
+}
+
+static int fec_open(struct net_device *dev)
+{
+	struct fec_priv *priv = netdev_priv(dev);
+	int err = -EBUSY;
+
+	if (request_irq(dev->irq, &fec_interrupt, IRQF_DISABLED | IRQF_SHARED,
+	                DRIVER_NAME "_ctrl", dev)) {
+		dev_err(&dev->dev, "ctrl interrupt request failed\n");
+		goto out;
+	}
+	if (request_irq(priv->r_irq, &fec_rx_interrupt, IRQF_DISABLED,
+	                DRIVER_NAME "_rx", dev)) {
+		dev_err(&dev->dev, "rx interrupt request failed\n");
+		goto free_ctrl_irq;
+	}
+	if (request_irq(priv->t_irq, &fec_tx_interrupt, IRQF_DISABLED,
+	                DRIVER_NAME "_tx", dev)) {
+		dev_err(&dev->dev, "tx interrupt request failed\n");
+		goto free_2irqs;
+	}
+
+	bcom_fec_rx_reset(priv->rx_dmatsk);
+	bcom_fec_tx_reset(priv->tx_dmatsk);
+
+	err = fec_alloc_rx_buffers(priv->rx_dmatsk);
+	if (err) {
+		dev_err(&dev->dev, "fec_alloc_rx_buffers failed\n");
+		goto free_irqs;
+	}
+
+	err = fec_phy_start(dev);
+	if (err)
+		goto free_skbs;
+
+	bcom_enable(priv->rx_dmatsk);
+	bcom_enable(priv->tx_dmatsk);
+
+	fec_start(dev);
+
+	netif_start_queue(dev);
+
+	return 0;
+
+ free_skbs:
+	fec_free_rx_buffers(priv->rx_dmatsk);
+
+ free_irqs:
+	free_irq(priv->t_irq, dev);
+ free_2irqs:
+	free_irq(priv->r_irq, dev);
+ free_ctrl_irq:
+	free_irq(dev->irq, dev);
+ out:
+
+	return err;
+}
+
+static int fec_close(struct net_device *dev)
+{
+	struct fec_priv *priv = netdev_priv(dev);
+
+	netif_stop_queue(dev);
+
+	fec_stop(dev);
+
+	fec_free_rx_buffers(priv->rx_dmatsk);
+
+	free_irq(dev->irq, dev);
+	free_irq(priv->r_irq, dev);
+	free_irq(priv->t_irq, dev);
+
+	fec_phy_stop(dev);
+
+	return 0;
+}
+
+/* This will only be invoked if your driver is _not_ in XOFF state.
+ * What this means is that you need not check it, and that this
+ * invariant will hold if you make sure that the netif_*_queue()
+ * calls are done at the proper times.
+ */
+static int fec_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct fec_priv *priv = netdev_priv(dev);
+	struct bcom_fec_bd *bd;
+
+	if (bcom_queue_full(priv->tx_dmatsk)) {
+		if (net_ratelimit())
+			dev_err(&dev->dev, "transmit queue overrun\n");
+		return 1;
+	}
+
+	spin_lock_irq(&priv->lock);
+	dev->trans_start = jiffies;
+
+	bd = (struct bcom_fec_bd *)
+		bcom_prepare_next_buffer(priv->tx_dmatsk);
+
+	bd->status = skb->len | BCOM_FEC_TX_BD_TFD | BCOM_FEC_TX_BD_TC;
+	bd->skb_pa = virt_to_phys(skb->data);
+
+	bcom_submit_next_buffer(priv->tx_dmatsk, skb);
+
+	if (bcom_queue_full(priv->tx_dmatsk)) {
+		priv->tx_full = 1;
+		netif_stop_queue(dev);
+	}
+
+	spin_unlock_irq(&priv->lock);
+
+	return 0;
+}
+
+/* This handles BestComm transmit task interrupts
+ */
+static irqreturn_t fec_tx_interrupt(int irq, void *dev_id)
+{
+	struct net_device *dev = dev_id;
+	struct fec_priv *priv = netdev_priv(dev);
+
+	spin_lock(&priv->lock);
+
+	while (bcom_buffer_done(priv->tx_dmatsk)) {
+		struct sk_buff *skb;
+		skb = bcom_retrieve_buffer(priv->tx_dmatsk, NULL, NULL);
+
+		priv->tx_full = 0;
+		dev_kfree_skb_irq(skb);
+	}
+
+	if (netif_queue_stopped(dev) && !priv->tx_full)
+		netif_wake_queue(dev);
+
+	spin_unlock(&priv->lock);
+
+	return IRQ_HANDLED;
+}
+
+static irqreturn_t fec_rx_interrupt(int irq, void *dev_id)
+{
+	struct net_device *dev = dev_id;
+	struct fec_priv *priv = netdev_priv(dev);
+
+	while (bcom_buffer_done(priv->rx_dmatsk)) {
+		struct sk_buff *skb;
+		struct sk_buff *rskb;
+		struct bcom_fec_bd *bd;
+		u32 status;
+
+		rskb = bcom_retrieve_buffer(priv->rx_dmatsk, &status, NULL);
+
+		/* Test for errors in received frame */
+		if (status & BCOM_FEC_RX_BD_ERRORS) {
+			/* Drop packet and reuse the buffer */
+			bd = (struct bcom_fec_bd *)
+				bcom_prepare_next_buffer(priv->rx_dmatsk);
+
+			bd->status = FEC_RX_BUFFER_SIZE;
+			bd->skb_pa = virt_to_phys(rskb->data);
+
+			bcom_submit_next_buffer(priv->rx_dmatsk, rskb);
+
+			priv->stats.rx_dropped++;
+
+			continue;
+		}
+
+		/* skbs are allocated on open, so now we allocate a new one,
+		 * and remove the old (with the packet) */
+		skb = dev_alloc_skb(FEC_RX_BUFFER_SIZE);
+		if (skb) {
+			/* Process the received skb */
+			int length = status & BCOM_FEC_RX_BD_LEN_MASK;
+
+			skb_put(rskb, length - 4);	/* length without CRC32 */
+
+			rskb->dev = dev;
+			rskb->protocol = eth_type_trans(rskb, dev);
+
+			netif_rx(rskb);
+			dev->last_rx = jiffies;
+		} else {
+			/* Can't get a new one : reuse the same & drop pkt */
+			dev_notice(&dev->dev, "Memory squeeze, dropping packet.\n");
+			priv->stats.rx_dropped++;
+
+			skb = rskb;
+		}
+
+		bd = (struct bcom_fec_bd *)
+			bcom_prepare_next_buffer(priv->rx_dmatsk);
+
+		bd->status = FEC_RX_BUFFER_SIZE;
+		bd->skb_pa = virt_to_phys(skb->data);
+
+		bcom_submit_next_buffer(priv->rx_dmatsk, skb);
+	}
+
+	return IRQ_HANDLED;
+}
+
+static irqreturn_t fec_interrupt(int irq, void *dev_id)
+{
+	struct net_device *dev = dev_id;
+	struct fec_priv *priv = netdev_priv(dev);
+	struct mpc52xx_fec __iomem *fec = priv->fec;
+	u32 ievent;
+
+	ievent = in_be32(&fec->ievent);
+
+	ievent &= ~FEC_IEVENT_MII;	/* mii is handled separately */
+	if (!ievent)
+		return IRQ_NONE;
+
+	out_be32(&fec->ievent, ievent);		/* clear pending events */
+
+	if (ievent & ~(FEC_IEVENT_RFIFO_ERROR | FEC_IEVENT_XFIFO_ERROR)) {
+		if (ievent & ~FEC_IEVENT_TFINT)
+			dev_dbg(&dev->dev, "ievent: %08x\n", ievent);
+		return IRQ_HANDLED;
+	}
+
+	if (net_ratelimit() && (ievent & FEC_IEVENT_RFIFO_ERROR))
+		dev_warn(&dev->dev, "FEC_IEVENT_RFIFO_ERROR\n");
+	if (net_ratelimit() && (ievent & FEC_IEVENT_XFIFO_ERROR))
+		dev_warn(&dev->dev, "FEC_IEVENT_XFIFO_ERROR\n");
+
+	fec_reset(dev);
+
+	netif_wake_queue(dev);
+	return IRQ_HANDLED;
+}
+
+/*
+ * Get the current statistics.
+ * This may be called with the card open or closed.
+ */
+static struct net_device_stats *fec_get_stats(struct net_device *dev)
+{
+	struct fec_priv *priv = netdev_priv(dev);
+	struct net_device_stats *stats = &priv->stats;
+	struct mpc52xx_fec __iomem *fec = priv->fec;
+
+	stats->rx_bytes = in_be32(&fec->rmon_r_octets);
+	stats->rx_packets = in_be32(&fec->rmon_r_packets);
+	stats->rx_errors = in_be32(&fec->rmon_r_crc_align) +
+		in_be32(&fec->rmon_r_undersize) +
+		in_be32(&fec->rmon_r_oversize) +
+		in_be32(&fec->rmon_r_frag) +
+		in_be32(&fec->rmon_r_jab);
+
+	stats->tx_bytes = in_be32(&fec->rmon_t_octets);
+	stats->tx_packets = in_be32(&fec->rmon_t_packets);
+	stats->tx_errors = in_be32(&fec->rmon_t_crc_align) +
+		in_be32(&fec->rmon_t_undersize) +
+		in_be32(&fec->rmon_t_oversize) +
+		in_be32(&fec->rmon_t_frag) +
+		in_be32(&fec->rmon_t_jab);
+
+	stats->multicast = in_be32(&fec->rmon_r_mc_pkt);
+	stats->collisions = in_be32(&fec->rmon_t_col);
+
+	/* detailed rx_errors: */
+	stats->rx_length_errors = in_be32(&fec->rmon_r_undersize)
+					+ in_be32(&fec->rmon_r_oversize)
+					+ in_be32(&fec->rmon_r_frag)
+					+ in_be32(&fec->rmon_r_jab);
+	stats->rx_over_errors = in_be32(&fec->r_macerr);
+	stats->rx_crc_errors = in_be32(&fec->ieee_r_crc);
+	stats->rx_frame_errors = in_be32(&fec->ieee_r_align);
+	stats->rx_fifo_errors = in_be32(&fec->rmon_r_drop);
+	stats->rx_missed_errors = in_be32(&fec->rmon_r_drop);
+
+	/* detailed tx_errors: */
+	stats->tx_aborted_errors = 0;
+	stats->tx_carrier_errors = in_be32(&fec->ieee_t_cserr);
+	stats->tx_fifo_errors = in_be32(&fec->rmon_t_drop);
+	stats->tx_heartbeat_errors = in_be32(&fec->ieee_t_sqe);
+	stats->tx_window_errors = in_be32(&fec->ieee_t_lcol);
+
+	return stats;
+}
+
+/*
+ * Read MIB counters in order to reset them,
+ * then zero all the stats fields in memory
+ */
+static void fec_reset_stats(struct net_device *dev)
+{
+	struct fec_priv *priv = netdev_priv(dev);
+	struct mpc52xx_fec __iomem *fec = priv->fec;
+
+	out_be32(&fec->mib_control, FEC_MIB_DISABLE);
+	memset_io(&fec->rmon_t_drop, 0,	(__force u32)&fec->reserved10 -
+			(__force u32)&fec->rmon_t_drop);
+	out_be32(&fec->mib_control, 0);
+
+	memset(&priv->stats, 0, sizeof(priv->stats));
+}
+
+/*
+ * Set or clear the multicast filter for this adaptor.
+ */
+static void fec_set_multicast_list(struct net_device *dev)
+{
+	struct fec_priv *priv = netdev_priv(dev);
+	struct mpc52xx_fec __iomem *fec = priv->fec;
+	u32 rx_control;
+
+	rx_control = in_be32(&fec->r_cntrl);
+
+	if (dev->flags & IFF_PROMISC) {
+		rx_control |= FEC_RCNTRL_PROM;
+		out_be32(&fec->r_cntrl, rx_control);
+	} else {
+		rx_control &= ~FEC_RCNTRL_PROM;
+		out_be32(&fec->r_cntrl, rx_control);
+
+		if (dev->flags & IFF_ALLMULTI) {
+			out_be32(&fec->gaddr1, 0xffffffff);
+			out_be32(&fec->gaddr2, 0xffffffff);
+		} else {
+			u32 crc;
+			int i;
+			struct dev_mc_list *dmi;
+			u32 gaddr1 = 0x00000000;
+			u32 gaddr2 = 0x00000000;
+
+			dmi = dev->mc_list;
+			for (i=0; i<dev->mc_count; i++) {
+				crc = ether_crc_le(6, dmi->dmi_addr) >> 26;
+				if (crc >= 32)
+					gaddr1 |= 1 << (crc-32);
+				else
+					gaddr2 |= 1 << crc;
+				dmi = dmi->next;
+			}
+			out_be32(&fec->gaddr1, gaddr1);
+			out_be32(&fec->gaddr2, gaddr2);
+		}
+	}
+}
+
+/**
+ * fec_hw_init
+ * @dev: network device
+ *
+ * Setup various hardware setting, only needed once on start
+ */
+static void fec_hw_init(struct net_device *dev)
+{
+	struct fec_priv *priv = netdev_priv(dev);
+	struct mpc52xx_fec __iomem *fec = priv->fec;
+	int i;
+
+	/* Whack a reset.  We should wait for this. */
+	out_be32(&fec->ecntrl, FEC_ECNTRL_RESET);
+	for (i = 0; i < FEC_RESET_DELAY; ++i) {
+		if ((in_be32(&fec->ecntrl) & FEC_ECNTRL_RESET) == 0)
+			break;
+		udelay(1);
+	}
+	if (i == FEC_RESET_DELAY)
+		dev_err(&dev->dev, "FEC Reset timeout!\n");
+
+	/* set pause to 0x20 frames */
+	out_be32(&fec->op_pause, FEC_OP_PAUSE_OPCODE | 0x20);
+
+	/* high service request will be deasserted when there's < 7 bytes in fifo
+	 * low service request will be deasserted when there's < 4*7 bytes in fifo
+	 */
+	out_be32(&fec->rfifo_cntrl, FEC_FIFO_CNTRL_FRAME | FEC_FIFO_CNTRL_LTG_7);
+	out_be32(&fec->tfifo_cntrl, FEC_FIFO_CNTRL_FRAME | FEC_FIFO_CNTRL_LTG_7);
+
+	/* alarm when <= x bytes in FIFO */
+	out_be32(&fec->rfifo_alarm, 0x0000030c);
+	out_be32(&fec->tfifo_alarm, 0x00000100);
+
+	/* begin transmittion when 256 bytes are in FIFO (or EOF or FIFO full) */
+	out_be32(&fec->x_wmrk, FEC_FIFO_WMRK_256B);
+
+	/* enable crc generation */
+	out_be32(&fec->xmit_fsm, FEC_XMIT_FSM_APPEND_CRC | FEC_XMIT_FSM_ENABLE_CRC);
+	out_be32(&fec->iaddr1, 0x00000000);	/* No individual filter */
+	out_be32(&fec->iaddr2, 0x00000000);	/* No individual filter */
+
+	/* set phy speed.
+	 * this can't be done in phy driver, since it needs to be called
+	 * before fec stuff (even on resume) */
+	fec_phy_hw_init(priv);
+}
+
+/**
+ * fec_start
+ * @dev: network device
+ *
+ * This function is called to start or restart the FEC during a link
+ * change.  This happens on fifo errors or when switching between half
+ * and full duplex.
+ */
+static void fec_start(struct net_device *dev)
+{
+	struct fec_priv *priv = netdev_priv(dev);
+	struct mpc52xx_fec __iomem *fec = priv->fec;
+	u32 rcntrl;
+	u32 tcntrl;
+	u32 tmp;
+
+	/* clear sticky error bits */
+	tmp = FEC_FIFO_STATUS_ERR | FEC_FIFO_STATUS_UF | FEC_FIFO_STATUS_OF;
+	out_be32(&fec->rfifo_status, in_be32(&fec->rfifo_status) & tmp);
+	out_be32(&fec->tfifo_status, in_be32(&fec->tfifo_status) & tmp);
+
+	/* FIFOs will reset on fec_enable */
+	out_be32(&fec->reset_cntrl, FEC_RESET_CNTRL_ENABLE_IS_RESET);
+
+	/* Set station address. */
+	fec_set_paddr(dev, dev->dev_addr);
+
+	fec_set_multicast_list(dev);
+
+	/* set max frame len, enable flow control, select mii mode */
+	rcntrl = FEC_RX_BUFFER_SIZE << 16;	/* max frame length */
+	rcntrl |= FEC_RCNTRL_FCE;
+
+	if (priv->has_phy)
+		rcntrl |= FEC_RCNTRL_MII_MODE;
+
+	if (priv->duplex == DUPLEX_FULL)
+		tcntrl = FEC_TCNTRL_FDEN;	/* FD enable */
+	else {
+		rcntrl |= FEC_RCNTRL_DRT;	/* disable Rx on Tx (HD) */
+		tcntrl = 0;
+	}
+	out_be32(&fec->r_cntrl, rcntrl);
+	out_be32(&fec->x_cntrl, tcntrl);
+
+	/* Clear any outstanding interrupt. */
+	out_be32(&fec->ievent, 0xffffffff);
+
+	/* Enable interrupts we wish to service. */
+	out_be32(&fec->imask, FEC_IMASK_ENABLE);
+
+	/* And last, enable the transmit and receive processing. */
+	out_be32(&fec->ecntrl, FEC_ECNTRL_ETHER_EN);
+	out_be32(&fec->r_des_active, 0x01000000);
+
+	priv->tx_full = 0;
+}
+
+/**
+ * fec_stop
+ * @dev: network device
+ *
+ * stop all activity on fec and empty dma buffers
+ */
+static void fec_stop(struct net_device *dev)
+{
+	struct fec_priv *priv = netdev_priv(dev);
+	struct mpc52xx_fec __iomem *fec = priv->fec;
+	unsigned long timeout;
+
+	/* disable all interrupts */
+	out_be32(&fec->imask, 0);
+
+	/* Disable the rx task. */
+	bcom_disable(priv->rx_dmatsk);
+
+	/* Wait for tx queue to drain, but only if we're in process context */
+	if (!in_interrupt()) {
+		timeout = jiffies + msecs_to_jiffies(2000);
+		while (time_before(jiffies, timeout) &&
+				!bcom_queue_empty(priv->tx_dmatsk))
+			msleep(100);
+
+		if (time_after_eq(jiffies, timeout))
+			dev_err(&dev->dev, "queues didn't drain\n");
+#if 1
+		if (time_after_eq(jiffies, timeout)) {
+			dev_err(&dev->dev, "  tx: index: %i, outdex: %i\n",
+					priv->tx_dmatsk->index,
+					priv->tx_dmatsk->outdex);
+			dev_err(&dev->dev, "  rx: index: %i, outdex: %i\n",
+					priv->rx_dmatsk->index,
+					priv->rx_dmatsk->outdex);
+		}
+#endif
+	}
+
+	bcom_disable(priv->tx_dmatsk);
+
+	/* Stop FEC */
+	out_be32(&fec->ecntrl, in_be32(&fec->ecntrl) & ~FEC_ECNTRL_ETHER_EN);
+
+	return;
+}
+
+/* reset fec and bestcomm tasks */
+static void fec_reset(struct net_device *dev)
+{
+	struct fec_priv *priv = netdev_priv(dev);
+	struct mpc52xx_fec __iomem *fec = priv->fec;
+
+	fec_stop(dev);
+
+	out_be32(&fec->rfifo_status, in_be32(&fec->rfifo_status));
+	out_be32(&fec->reset_cntrl, FEC_RESET_CNTRL_RESET_FIFO);
+
+	fec_free_rx_buffers(priv->rx_dmatsk);
+
+	fec_hw_init(dev);
+
+	phy_stop(priv->phydev);
+	phy_write(priv->phydev, MII_BMCR, BMCR_RESET);
+	phy_start(priv->phydev);
+
+	bcom_fec_rx_reset(priv->rx_dmatsk);
+	bcom_fec_tx_reset(priv->tx_dmatsk);
+
+	fec_alloc_rx_buffers(priv->rx_dmatsk);
+
+	bcom_enable(priv->rx_dmatsk);
+	bcom_enable(priv->tx_dmatsk);
+
+	fec_start(dev);
+}
+
+
+/* ethtool interface */
+static void fec_get_drvinfo(struct net_device *dev,
+		struct ethtool_drvinfo *info)
+{
+	strcpy(info->driver, DRIVER_NAME);
+}
+
+static int fec_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+{
+	struct fec_priv *priv = netdev_priv(dev);
+	return phy_ethtool_gset(priv->phydev, cmd);
+}
+
+static int fec_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+{
+	struct fec_priv *priv = netdev_priv(dev);
+	return phy_ethtool_sset(priv->phydev, cmd);
+}
+
+static u32 fec_get_msglevel(struct net_device *dev)
+{
+	struct fec_priv *priv = netdev_priv(dev);
+	return priv->msg_enable;
+}
+
+static void fec_set_msglevel(struct net_device *dev, u32 level)
+{
+	struct fec_priv *priv = netdev_priv(dev);
+	priv->msg_enable = level;
+}
+
+static const struct ethtool_ops fec_ethtool_ops = {
+	.get_drvinfo = fec_get_drvinfo,
+	.get_settings = fec_get_settings,
+	.set_settings = fec_set_settings,
+	.get_link = ethtool_op_get_link,
+	.get_msglevel = fec_get_msglevel,
+	.set_msglevel = fec_set_msglevel,
+};
+
+
+static int fec_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
+{
+	struct fec_priv *priv = netdev_priv(dev);
+
+	return fec_phy_mii_ioctl(priv, if_mii(rq), cmd);
+}
+
+/* ======================================================================== */
+/* OF Driver                                                                */
+/* ======================================================================== */
+
+static int __devinit
+mpc52xx_fec_probe(struct of_device *op, const struct of_device_id *match)
+{
+	int rv;
+	struct net_device *ndev;
+	struct fec_priv *priv = NULL;
+	struct resource mem;
+	const phandle *ph;
+
+	phys_addr_t rx_fifo;
+	phys_addr_t tx_fifo;
+
+	/* Get the ether ndev & it's private zone */
+	ndev = alloc_etherdev(sizeof(struct fec_priv));
+	if (!ndev)
+		return -ENOMEM;
+
+	priv = netdev_priv(ndev);
+
+	/* Reserve FEC control zone */
+	rv = of_address_to_resource(op->node, 0, &mem);
+	if (rv) {
+		printk(KERN_ERR DRIVER_NAME ": "
+				"Error while parsing device node resource\n" );
+		return rv;
+	}
+	if ((mem.end - mem.start + 1) != sizeof(struct mpc52xx_fec)) {
+		printk(KERN_ERR DRIVER_NAME
+			" - invalid resource size (%lx != %x), check mpc52xx_devices.c\n",
+			(unsigned long)(mem.end - mem.start + 1), sizeof(struct mpc52xx_fec));
+		return -EINVAL;
+	}
+
+	if (!request_mem_region(mem.start, sizeof(struct mpc52xx_fec), DRIVER_NAME))
+		return -EBUSY;
+
+	/* Init ether ndev with what we have */
+	ndev->open		= fec_open;
+	ndev->stop		= fec_close;
+	ndev->hard_start_xmit	= fec_hard_start_xmit;
+	ndev->do_ioctl		= fec_ioctl;
+	ndev->ethtool_ops	= &fec_ethtool_ops;
+	ndev->get_stats		= fec_get_stats;
+	ndev->set_mac_address	= fec_set_mac_address;
+	ndev->set_multicast_list = fec_set_multicast_list;
+	ndev->tx_timeout	= fec_tx_timeout;
+	ndev->watchdog_timeo	= FEC_WATCHDOG_TIMEOUT;
+	ndev->flags &= ~IFF_RUNNING;
+	ndev->base_addr		= mem.start;
+
+	priv->t_irq = priv->r_irq = ndev->irq = NO_IRQ; /* IRQ are free for now */
+
+	spin_lock_init(&priv->lock);
+
+	/* ioremap the zones */
+	priv->fec = ioremap(mem.start, sizeof(struct mpc52xx_fec));
+
+	if (!priv->fec) {
+		rv = -ENOMEM;
+		goto probe_error;
+	}
+
+	/* Bestcomm init */
+	rx_fifo = ndev->base_addr + offsetof(struct mpc52xx_fec, rfifo_data);
+	tx_fifo = ndev->base_addr + offsetof(struct mpc52xx_fec, tfifo_data);
+
+	priv->rx_dmatsk = bcom_fec_rx_init(FEC_RX_NUM_BD, rx_fifo, FEC_RX_BUFFER_SIZE);
+	priv->tx_dmatsk = bcom_fec_tx_init(FEC_TX_NUM_BD, tx_fifo);
+
+	if (!priv->rx_dmatsk || !priv->tx_dmatsk) {
+		printk(KERN_ERR DRIVER_NAME ": Can not init SDMA tasks\n" );
+		rv = -ENOMEM;
+		goto probe_error;
+	}
+
+	/* Get the IRQ we need one by one */
+		/* Control */
+	ndev->irq = irq_of_parse_and_map(op->node, 0);
+
+		/* RX */
+	priv->r_irq = bcom_get_task_irq(priv->rx_dmatsk);
+
+		/* TX */
+	priv->t_irq = bcom_get_task_irq(priv->tx_dmatsk);
+
+	/* MAC address init */
+	if (!is_zero_ether_addr(mpc52xx_fec_mac_addr))
+		memcpy(ndev->dev_addr, mpc52xx_fec_mac_addr, 6);
+	else
+		fec_get_paddr(ndev, ndev->dev_addr);
+
+	priv->msg_enable = (NETIF_MSG_IFUP << 1) - 1;
+	priv->duplex = DUPLEX_FULL;
+
+	/* is the phy present in device tree? */
+	ph = of_get_property(op->node, "phy-handle", NULL);
+	if (ph) {
+		const unsigned int *prop;
+		struct device_node *phy_dn;
+		priv->has_phy = 1;
+
+		phy_dn = of_find_node_by_phandle(*ph);
+		prop = of_get_property(phy_dn, "reg", NULL);
+		priv->phy_addr = *prop;
+
+		of_node_put(phy_dn);
+
+		/* Phy speed */
+		priv->phy_speed = ((mpc52xx_find_ipb_freq(op->node) >> 20) / 5) << 1;
+	} else {
+		dev_info(&ndev->dev, "can't find \"phy-handle\" in device"
+				" tree, using 7-wire mode\n");
+	}
+
+	/* Hardware init */
+	fec_hw_init(ndev);
+
+	fec_reset_stats(ndev);
+
+	/* Register the new network device */
+	rv = register_netdev(ndev);
+	if (rv < 0)
+		goto probe_error;
+
+	/* We're done ! */
+	dev_set_drvdata(&op->dev, ndev);
+
+	return 0;
+
+
+	/* Error handling - free everything that might be allocated */
+probe_error:
+
+	irq_dispose_mapping(ndev->irq);
+
+	if (priv->rx_dmatsk)
+		bcom_fec_rx_release(priv->rx_dmatsk);
+	if (priv->tx_dmatsk)
+		bcom_fec_tx_release(priv->tx_dmatsk);
+
+	if (priv->fec)
+		iounmap(priv->fec);
+
+	release_mem_region(mem.start, sizeof(struct mpc52xx_fec));
+
+	free_netdev(ndev);
+
+	return rv;
+}
+
+static int
+mpc52xx_fec_remove(struct of_device *op)
+{
+	struct net_device *ndev;
+	struct fec_priv *priv;
+
+	ndev = dev_get_drvdata(&op->dev);
+	if (!ndev)
+		return 0;
+	priv = netdev_priv(ndev);
+
+	unregister_netdev(ndev);
+
+	irq_dispose_mapping(ndev->irq);
+
+	bcom_fec_rx_release(priv->rx_dmatsk);
+	bcom_fec_tx_release(priv->tx_dmatsk);
+
+	iounmap(priv->fec);
+
+	release_mem_region(ndev->base_addr, sizeof(struct mpc52xx_fec));
+
+	free_netdev(ndev);
+
+	dev_set_drvdata(&op->dev, NULL);
+	return 0;
+}
+
+#ifdef CONFIG_PM
+static int mpc52xx_fec_of_suspend(struct of_device *op, pm_message_t state)
+{
+	struct net_device *dev = dev_get_drvdata(&op->dev);
+
+	if (netif_running(dev))
+		fec_close(dev);
+
+	return 0;
+}
+
+static int mpc52xx_fec_of_resume(struct of_device *op)
+{
+	struct net_device *dev = dev_get_drvdata(&op->dev);
+
+	fec_hw_init(dev);
+	fec_reset_stats(dev);
+
+	if (netif_running(dev))
+		fec_open(dev);
+
+	return 0;
+}
+#endif
+
+static struct of_device_id mpc52xx_fec_match[] = {
+	{
+		.type		= "network",
+		.compatible	= "mpc5200-fec",
+	},
+	{ }
+};
+
+MODULE_DEVICE_TABLE(of, mpc52xx_fec_match);
+
+static struct of_platform_driver mpc52xx_fec_driver = {
+	.owner		= THIS_MODULE,
+	.name		= DRIVER_NAME,
+	.match_table	= mpc52xx_fec_match,
+	.probe		= mpc52xx_fec_probe,
+	.remove		= mpc52xx_fec_remove,
+#ifdef CONFIG_PM
+	.suspend	= mpc52xx_fec_of_suspend,
+	.resume		= mpc52xx_fec_of_resume,
+#endif
+};
+
+
+/* ======================================================================== */
+/* Module                                                                   */
+/* ======================================================================== */
+
+static int __init
+mpc52xx_fec_init(void)
+{
+	return of_register_platform_driver(&mpc52xx_fec_driver);
+}
+
+static void __exit
+mpc52xx_fec_exit(void)
+{
+	of_unregister_platform_driver(&mpc52xx_fec_driver);
+}
+
+
+module_init(mpc52xx_fec_init);
+module_exit(mpc52xx_fec_exit);
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Dale Farnsworth");
+MODULE_DESCRIPTION("Ethernet driver for the Freescale MPC52xx FEC");
Index: linux.git/drivers/net/fec_mpc52xx/fec.h
===================================================================
--- /dev/null
+++ linux.git/drivers/net/fec_mpc52xx/fec.h
@@ -0,0 +1,313 @@
+/*
+ * drivers/drivers/net/fec_mpc52xx/fec.h
+ *
+ * Driver for the MPC5200 Fast Ethernet Controller
+ *
+ * Author: Dale Farnsworth <dfarnsworth@mvista.com>
+ *
+ * 2003-2004 (c) MontaVista, Software, Inc.  This file is licensed under
+ * the terms of the GNU General Public License version 2.  This program
+ * is licensed "as is" without any warranty of any kind, whether express
+ * or implied.
+ */
+
+#ifndef __DRIVERS_NET_MPC52XX_FEC_H__
+#define __DRIVERS_NET_MPC52XX_FEC_H__
+
+#include <linux/phy.h>
+
+/* Tunable constant */
+/* FEC_RX_BUFFER_SIZE includes 4 bytes for CRC32 */
+#define FEC_RX_BUFFER_SIZE	1522	/* max receive packet size */
+#define FEC_RX_NUM_BD		256
+#define FEC_TX_NUM_BD		64
+
+#define FEC_RESET_DELAY		50 	/* uS */
+
+#define FEC_WATCHDOG_TIMEOUT	((400*HZ)/1000)
+
+struct fec_priv {
+	int duplex;
+	int tx_full;
+	int r_irq;
+	int t_irq;
+	struct mpc52xx_fec __iomem *fec;
+	struct bcom_task *rx_dmatsk;
+	struct bcom_task *tx_dmatsk;
+	spinlock_t lock;
+	struct net_device_stats stats;
+	int msg_enable;
+
+	int has_phy;
+	unsigned int phy_speed;
+	unsigned int phy_addr;
+	struct phy_device *phydev;
+	enum phy_state link;
+	int speed;
+};
+
+
+/* ======================================================================== */
+/* Hardware register sets & bits                                            */
+/* ======================================================================== */
+
+struct mpc52xx_fec {
+	u32 fec_id;			/* FEC + 0x000 */
+	u32 ievent;			/* FEC + 0x004 */
+	u32 imask;			/* FEC + 0x008 */
+
+	u32 reserved0[1];		/* FEC + 0x00C */
+	u32 r_des_active;		/* FEC + 0x010 */
+	u32 x_des_active;		/* FEC + 0x014 */
+	u32 r_des_active_cl;		/* FEC + 0x018 */
+	u32 x_des_active_cl;		/* FEC + 0x01C */
+	u32 ivent_set;			/* FEC + 0x020 */
+	u32 ecntrl;			/* FEC + 0x024 */
+
+	u32 reserved1[6];		/* FEC + 0x028-03C */
+	u32 mii_data;			/* FEC + 0x040 */
+	u32 mii_speed;			/* FEC + 0x044 */
+	u32 mii_status;			/* FEC + 0x048 */
+
+	u32 reserved2[5];		/* FEC + 0x04C-05C */
+	u32 mib_data;			/* FEC + 0x060 */
+	u32 mib_control;		/* FEC + 0x064 */
+
+	u32 reserved3[6];		/* FEC + 0x068-7C */
+	u32 r_activate;			/* FEC + 0x080 */
+	u32 r_cntrl;			/* FEC + 0x084 */
+	u32 r_hash;			/* FEC + 0x088 */
+	u32 r_data;			/* FEC + 0x08C */
+	u32 ar_done;			/* FEC + 0x090 */
+	u32 r_test;			/* FEC + 0x094 */
+	u32 r_mib;			/* FEC + 0x098 */
+	u32 r_da_low;			/* FEC + 0x09C */
+	u32 r_da_high;			/* FEC + 0x0A0 */
+
+	u32 reserved4[7];		/* FEC + 0x0A4-0BC */
+	u32 x_activate;			/* FEC + 0x0C0 */
+	u32 x_cntrl;			/* FEC + 0x0C4 */
+	u32 backoff;			/* FEC + 0x0C8 */
+	u32 x_data;			/* FEC + 0x0CC */
+	u32 x_status;			/* FEC + 0x0D0 */
+	u32 x_mib;			/* FEC + 0x0D4 */
+	u32 x_test;			/* FEC + 0x0D8 */
+	u32 fdxfc_da1;			/* FEC + 0x0DC */
+	u32 fdxfc_da2;			/* FEC + 0x0E0 */
+	u32 paddr1;			/* FEC + 0x0E4 */
+	u32 paddr2;			/* FEC + 0x0E8 */
+	u32 op_pause;			/* FEC + 0x0EC */
+
+	u32 reserved5[4];		/* FEC + 0x0F0-0FC */
+	u32 instr_reg;			/* FEC + 0x100 */
+	u32 context_reg;		/* FEC + 0x104 */
+	u32 test_cntrl;			/* FEC + 0x108 */
+	u32 acc_reg;			/* FEC + 0x10C */
+	u32 ones;			/* FEC + 0x110 */
+	u32 zeros;			/* FEC + 0x114 */
+	u32 iaddr1;			/* FEC + 0x118 */
+	u32 iaddr2;			/* FEC + 0x11C */
+	u32 gaddr1;			/* FEC + 0x120 */
+	u32 gaddr2;			/* FEC + 0x124 */
+	u32 random;			/* FEC + 0x128 */
+	u32 rand1;			/* FEC + 0x12C */
+	u32 tmp;			/* FEC + 0x130 */
+
+	u32 reserved6[3];		/* FEC + 0x134-13C */
+	u32 fifo_id;			/* FEC + 0x140 */
+	u32 x_wmrk;			/* FEC + 0x144 */
+	u32 fcntrl;			/* FEC + 0x148 */
+	u32 r_bound;			/* FEC + 0x14C */
+	u32 r_fstart;			/* FEC + 0x150 */
+	u32 r_count;			/* FEC + 0x154 */
+	u32 r_lag;			/* FEC + 0x158 */
+	u32 r_read;			/* FEC + 0x15C */
+	u32 r_write;			/* FEC + 0x160 */
+	u32 x_count;			/* FEC + 0x164 */
+	u32 x_lag;			/* FEC + 0x168 */
+	u32 x_retry;			/* FEC + 0x16C */
+	u32 x_write;			/* FEC + 0x170 */
+	u32 x_read;			/* FEC + 0x174 */
+
+	u32 reserved7[2];		/* FEC + 0x178-17C */
+	u32 fm_cntrl;			/* FEC + 0x180 */
+	u32 rfifo_data;			/* FEC + 0x184 */
+	u32 rfifo_status;		/* FEC + 0x188 */
+	u32 rfifo_cntrl;		/* FEC + 0x18C */
+	u32 rfifo_lrf_ptr;		/* FEC + 0x190 */
+	u32 rfifo_lwf_ptr;		/* FEC + 0x194 */
+	u32 rfifo_alarm;		/* FEC + 0x198 */
+	u32 rfifo_rdptr;		/* FEC + 0x19C */
+	u32 rfifo_wrptr;		/* FEC + 0x1A0 */
+	u32 tfifo_data;			/* FEC + 0x1A4 */
+	u32 tfifo_status;		/* FEC + 0x1A8 */
+	u32 tfifo_cntrl;		/* FEC + 0x1AC */
+	u32 tfifo_lrf_ptr;		/* FEC + 0x1B0 */
+	u32 tfifo_lwf_ptr;		/* FEC + 0x1B4 */
+	u32 tfifo_alarm;		/* FEC + 0x1B8 */
+	u32 tfifo_rdptr;		/* FEC + 0x1BC */
+	u32 tfifo_wrptr;		/* FEC + 0x1C0 */
+
+	u32 reset_cntrl;		/* FEC + 0x1C4 */
+	u32 xmit_fsm;			/* FEC + 0x1C8 */
+
+	u32 reserved8[3];		/* FEC + 0x1CC-1D4 */
+	u32 rdes_data0;			/* FEC + 0x1D8 */
+	u32 rdes_data1;			/* FEC + 0x1DC */
+	u32 r_length;			/* FEC + 0x1E0 */
+	u32 x_length;			/* FEC + 0x1E4 */
+	u32 x_addr;			/* FEC + 0x1E8 */
+	u32 cdes_data;			/* FEC + 0x1EC */
+	u32 status;			/* FEC + 0x1F0 */
+	u32 dma_control;		/* FEC + 0x1F4 */
+	u32 des_cmnd;			/* FEC + 0x1F8 */
+	u32 data;			/* FEC + 0x1FC */
+
+	u32 rmon_t_drop;		/* FEC + 0x200 */
+	u32 rmon_t_packets;		/* FEC + 0x204 */
+	u32 rmon_t_bc_pkt;		/* FEC + 0x208 */
+	u32 rmon_t_mc_pkt;		/* FEC + 0x20C */
+	u32 rmon_t_crc_align;		/* FEC + 0x210 */
+	u32 rmon_t_undersize;		/* FEC + 0x214 */
+	u32 rmon_t_oversize;		/* FEC + 0x218 */
+	u32 rmon_t_frag;		/* FEC + 0x21C */
+	u32 rmon_t_jab;			/* FEC + 0x220 */
+	u32 rmon_t_col;			/* FEC + 0x224 */
+	u32 rmon_t_p64;			/* FEC + 0x228 */
+	u32 rmon_t_p65to127;		/* FEC + 0x22C */
+	u32 rmon_t_p128to255;		/* FEC + 0x230 */
+	u32 rmon_t_p256to511;		/* FEC + 0x234 */
+	u32 rmon_t_p512to1023;		/* FEC + 0x238 */
+	u32 rmon_t_p1024to2047;		/* FEC + 0x23C */
+	u32 rmon_t_p_gte2048;		/* FEC + 0x240 */
+	u32 rmon_t_octets;		/* FEC + 0x244 */
+	u32 ieee_t_drop;		/* FEC + 0x248 */
+	u32 ieee_t_frame_ok;		/* FEC + 0x24C */
+	u32 ieee_t_1col;		/* FEC + 0x250 */
+	u32 ieee_t_mcol;		/* FEC + 0x254 */
+	u32 ieee_t_def;			/* FEC + 0x258 */
+	u32 ieee_t_lcol;		/* FEC + 0x25C */
+	u32 ieee_t_excol;		/* FEC + 0x260 */
+	u32 ieee_t_macerr;		/* FEC + 0x264 */
+	u32 ieee_t_cserr;		/* FEC + 0x268 */
+	u32 ieee_t_sqe;			/* FEC + 0x26C */
+	u32 t_fdxfc;			/* FEC + 0x270 */
+	u32 ieee_t_octets_ok;		/* FEC + 0x274 */
+
+	u32 reserved9[2];		/* FEC + 0x278-27C */
+	u32 rmon_r_drop;		/* FEC + 0x280 */
+	u32 rmon_r_packets;		/* FEC + 0x284 */
+	u32 rmon_r_bc_pkt;		/* FEC + 0x288 */
+	u32 rmon_r_mc_pkt;		/* FEC + 0x28C */
+	u32 rmon_r_crc_align;		/* FEC + 0x290 */
+	u32 rmon_r_undersize;		/* FEC + 0x294 */
+	u32 rmon_r_oversize;		/* FEC + 0x298 */
+	u32 rmon_r_frag;		/* FEC + 0x29C */
+	u32 rmon_r_jab;			/* FEC + 0x2A0 */
+
+	u32 rmon_r_resvd_0;		/* FEC + 0x2A4 */
+
+	u32 rmon_r_p64;			/* FEC + 0x2A8 */
+	u32 rmon_r_p65to127;		/* FEC + 0x2AC */
+	u32 rmon_r_p128to255;		/* FEC + 0x2B0 */
+	u32 rmon_r_p256to511;		/* FEC + 0x2B4 */
+	u32 rmon_r_p512to1023;		/* FEC + 0x2B8 */
+	u32 rmon_r_p1024to2047;		/* FEC + 0x2BC */
+	u32 rmon_r_p_gte2048;		/* FEC + 0x2C0 */
+	u32 rmon_r_octets;		/* FEC + 0x2C4 */
+	u32 ieee_r_drop;		/* FEC + 0x2C8 */
+	u32 ieee_r_frame_ok;		/* FEC + 0x2CC */
+	u32 ieee_r_crc;			/* FEC + 0x2D0 */
+	u32 ieee_r_align;		/* FEC + 0x2D4 */
+	u32 r_macerr;			/* FEC + 0x2D8 */
+	u32 r_fdxfc;			/* FEC + 0x2DC */
+	u32 ieee_r_octets_ok;		/* FEC + 0x2E0 */
+
+	u32 reserved10[7];		/* FEC + 0x2E4-2FC */
+
+	u32 reserved11[64];		/* FEC + 0x300-3FF */
+};
+
+#define	FEC_MIB_DISABLE			0x80000000
+
+#define	FEC_IEVENT_HBERR		0x80000000
+#define	FEC_IEVENT_BABR			0x40000000
+#define	FEC_IEVENT_BABT			0x20000000
+#define	FEC_IEVENT_GRA			0x10000000
+#define	FEC_IEVENT_TFINT		0x08000000
+#define	FEC_IEVENT_MII			0x00800000
+#define	FEC_IEVENT_LATE_COL		0x00200000
+#define	FEC_IEVENT_COL_RETRY_LIM	0x00100000
+#define	FEC_IEVENT_XFIFO_UN		0x00080000
+#define	FEC_IEVENT_XFIFO_ERROR		0x00040000
+#define	FEC_IEVENT_RFIFO_ERROR		0x00020000
+
+#define	FEC_IMASK_HBERR			0x80000000
+#define	FEC_IMASK_BABR			0x40000000
+#define	FEC_IMASK_BABT			0x20000000
+#define	FEC_IMASK_GRA			0x10000000
+#define	FEC_IMASK_MII			0x00800000
+#define	FEC_IMASK_LATE_COL		0x00200000
+#define	FEC_IMASK_COL_RETRY_LIM		0x00100000
+#define	FEC_IMASK_XFIFO_UN		0x00080000
+#define	FEC_IMASK_XFIFO_ERROR		0x00040000
+#define	FEC_IMASK_RFIFO_ERROR		0x00020000
+
+/* all but MII, which is enabled separately */
+#define FEC_IMASK_ENABLE	(FEC_IMASK_HBERR | FEC_IMASK_BABR | \
+		FEC_IMASK_BABT | FEC_IMASK_GRA | FEC_IMASK_LATE_COL | \
+		FEC_IMASK_COL_RETRY_LIM | FEC_IMASK_XFIFO_UN | \
+		FEC_IMASK_XFIFO_ERROR | FEC_IMASK_RFIFO_ERROR)
+
+#define	FEC_RCNTRL_MAX_FL_SHIFT		16
+#define	FEC_RCNTRL_LOOP			0x01
+#define	FEC_RCNTRL_DRT			0x02
+#define	FEC_RCNTRL_MII_MODE		0x04
+#define	FEC_RCNTRL_PROM			0x08
+#define	FEC_RCNTRL_BC_REJ		0x10
+#define	FEC_RCNTRL_FCE			0x20
+
+#define	FEC_TCNTRL_GTS			0x00000001
+#define	FEC_TCNTRL_HBC			0x00000002
+#define	FEC_TCNTRL_FDEN			0x00000004
+#define	FEC_TCNTRL_TFC_PAUSE		0x00000008
+#define	FEC_TCNTRL_RFC_PAUSE		0x00000010
+
+#define	FEC_ECNTRL_RESET		0x00000001
+#define	FEC_ECNTRL_ETHER_EN		0x00000002
+
+#define FEC_MII_DATA_ST			0x40000000	/* Start frame */
+#define FEC_MII_DATA_OP_RD		0x20000000	/* Perform read */
+#define FEC_MII_DATA_OP_WR		0x10000000	/* Perform write */
+#define FEC_MII_DATA_PA_MSK		0x0f800000	/* PHY Address mask */
+#define FEC_MII_DATA_RA_MSK		0x007c0000	/* PHY Register mask */
+#define FEC_MII_DATA_TA			0x00020000	/* Turnaround */
+#define FEC_MII_DATA_DATAMSK		0x0000ffff	/* PHY data mask */
+
+#define FEC_MII_READ_FRAME	(FEC_MII_DATA_ST | FEC_MII_DATA_OP_RD | FEC_MII_DATA_TA)
+#define FEC_MII_WRITE_FRAME	(FEC_MII_DATA_ST | FEC_MII_DATA_OP_WR | FEC_MII_DATA_TA)
+
+#define FEC_MII_DATA_RA_SHIFT		0x12		/* MII reg addr bits */
+#define FEC_MII_DATA_PA_SHIFT		0x17		/* MII PHY addr bits */
+
+#define FEC_PADDR2_TYPE			0x8808
+
+#define FEC_OP_PAUSE_OPCODE		0x00010000
+
+#define FEC_FIFO_WMRK_256B		0x3
+
+#define FEC_FIFO_STATUS_ERR		0x00400000
+#define FEC_FIFO_STATUS_UF		0x00200000
+#define FEC_FIFO_STATUS_OF		0x00100000
+
+#define FEC_FIFO_CNTRL_FRAME		0x08000000
+#define FEC_FIFO_CNTRL_LTG_7		0x07000000
+
+#define FEC_RESET_CNTRL_RESET_FIFO	0x02000000
+#define FEC_RESET_CNTRL_ENABLE_IS_RESET	0x01000000
+
+#define FEC_XMIT_FSM_APPEND_CRC		0x02000000
+#define FEC_XMIT_FSM_ENABLE_CRC		0x01000000
+
+
+#endif	/* __DRIVERS_NET_MPC52XX_FEC_H__ */
