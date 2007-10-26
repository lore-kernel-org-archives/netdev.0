From: Domen Puncer <domen.puncer@telargo.com>
Subject: [PATCH v4.2] FEC - fast ethernet controller for mpc52xx
Date: Fri, 26 Oct 2007 13:59:09 +0200
Message-ID: <20071026115909.GI3369@nd47.coderock.org>
References: <20071014075511.GC3000@nd47.coderock.org> <4713BA1C.2050604@pobox.com> <fa686aa40710180715u23d81adfy83ff65837725fb80@mail.gmail.com> <4717B09B.3060800@pobox.com> <20071019112700.GD27403@nd47.coderock.org> <47206209.8080109@pobox.com> <20071025185706.29496.qmail@farnsworth.org> <20071025194114.GH3369@nd47.coderock.org> <20071025202908.GA2102@xyzzy.farnsworth.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dale Farnsworth <dale@farnsworth.org>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kukmak.uni-mb.si ([164.8.100.3]:45485 "EHLO kukmak.uni-mb.si"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752340AbXJZL7b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Oct 2007 07:59:31 -0400
Content-Disposition: inline
In-Reply-To: <20071025202908.GA2102@xyzzy.farnsworth.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 25/10/07 13:29 -0700, Dale Farnsworth wrote:
> On Thu, Oct 25, 2007 at 09:41:14PM +0200, Domen Puncer wrote:
> > On 25/10/07 11:57 -0700, Dale Farnsworth wrote:
> > > Domen wrote:
> > > > > use your platform's dma mapping functions, rather than virt_t=
o_phys()
> > > > >=20
> > > > > it might be the exact same implementation, inside the platfor=
m=20
> > > > > internals, but drivers should not be using this directly.
> > > >=20
> > > > I've replaced this with dma_map_single(), unmatched with
> > > > dma_unmap_single(), since bestcomm doesn't have a way to do tha=
t
> > > > and it's blank on ppc32 anyway.
> > > >=20
> > > > Is this OK? PPC guys?
> > >=20
> > > Even though dma_unmap_single() may be a no-op, calls to
> > > dma_map_single() must be matched with calls to dma_unmap_single()=
=2E
> > >=20
> > > Perhaps with the additions below:
> > >=20
> > > > +static void mpc52xx_fec_free_rx_buffers(struct bcom_task *s)
> > > > +{
> > > > +	struct sk_buff *skb;
> > > > +
> > > > +	while (!bcom_queue_empty(s)) {
> > > > +		skb =3D bcom_retrieve_buffer(s, NULL, NULL);
> > >=20
> > > 		dma_unmap_single(&skb->dev->dev, skb-data,
> > > 				 FEC_RX_BUFFER_SIZE, DMA_FROM_DEVICE);
> >=20
> > It looks to me like dma_unmap_single takes the mapped address
> > (what dma_map_single returned), and not the address we're mapping
> > (skb->data).
>=20
> Yeah.  Sorry.  That won't be so easy.  We'll either need to
> squirrel away the mapped address, or change the interface to
> bcom_retrieve_buffers() so we can get the address.
>=20
> IMO, it's still a requirement that we call dma_unmap_single() for
> each call to dma_map_single().

D'oh, I don't know what I was reading yesterday,
bcom_retrieve_buffers is just ok, used like that

+		struct bcom_fec_bd *bd;
+		struct sk_buff *skb;
+
+		skb =3D bcom_retrieve_buffer(s, NULL, (struct bcom_bd **)&bd);
+		dma_unmap_single(&dev->dev, bd->skb_pa, skb->len, DMA_FROM_DEVICE);


And the (final?) version:

--- cut here ;-) ---

Driver for ethernet on mpc5200/mpc5200b SoCs (FEC).


Signed-off-by: Domen Puncer <domen.puncer@telargo.com>

---
 drivers/net/Kconfig           |   24=20
 drivers/net/Makefile          |    4=20
 drivers/net/fec_mpc52xx.c     | 1116 +++++++++++++++++++++++++++++++++=
+++++++++
 drivers/net/fec_mpc52xx.h     |  313 +++++++++++
 drivers/net/fec_mpc52xx_phy.c |  198 +++++++
 5 files changed, 1655 insertions(+)

Index: linux.git/drivers/net/Kconfig
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux.git.orig/drivers/net/Kconfig
+++ linux.git/drivers/net/Kconfig
@@ -1880,6 +1880,30 @@ config FEC2
 	  Say Y here if you want to use the second built-in 10/100 Fast
 	  ethernet controller on some Motorola ColdFire processors.
=20
+config FEC_MPC52xx
+	tristate "MPC52xx FEC driver"
+	depends on PPC_MPC52xx
+	select PPC_BESTCOMM
+	select PPC_BESTCOMM_FEC
+	select CRC32
+	select PHYLIB
+	---help---
+	  This option enables support for the MPC5200's on-chip
+	  Fast Ethernet Controller
+	  If compiled as module, it will be called 'fec_mpc52xx.ko'.
+
+config FEC_MPC52xx_MDIO
+	bool "MPC52xx FEC MDIO bus driver"
+	depends on FEC_MPC52xx
+	default y
+	---help---
+	  The MPC5200's FEC can connect to the Ethernet either with
+	  an external MII PHY chip or 10 Mbps 7-wire interface
+	  (Motorola? industry standard).
+	  If your board uses an external PHY connected to FEC, enable this.
+	  If not sure, enable.
+	  If compiled as module, it will be called 'fec_mpc52xx_phy.ko'.
+
 config NE_H8300
 	tristate "NE2000 compatible support for H8/300"
 	depends on H8300
Index: linux.git/drivers/net/Makefile
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux.git.orig/drivers/net/Makefile
+++ linux.git/drivers/net/Makefile
@@ -96,6 +96,10 @@ obj-$(CONFIG_SHAPER) +=3D shaper.o
 obj-$(CONFIG_HP100) +=3D hp100.o
 obj-$(CONFIG_SMC9194) +=3D smc9194.o
 obj-$(CONFIG_FEC) +=3D fec.o
+obj-$(CONFIG_FEC_MPC52xx) +=3D fec_mpc52xx.o
+ifeq ($(CONFIG_FEC_MPC52xx_MDIO),y)
+	obj-$(CONFIG_FEC_MPC52xx) +=3D fec_mpc52xx_phy.o
+endif
 obj-$(CONFIG_68360_ENET) +=3D 68360enet.o
 obj-$(CONFIG_WD80x3) +=3D wd.o 8390.o
 obj-$(CONFIG_EL2) +=3D 3c503.o 8390.o
Index: linux.git/drivers/net/fec_mpc52xx.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- /dev/null
+++ linux.git/drivers/net/fec_mpc52xx.c
@@ -0,0 +1,1116 @@
+/*
+ * Driver for the MPC5200 Fast Ethernet Controller
+ *
+ * Originally written by Dale Farnsworth <dfarnsworth@mvista.com> and
+ * now maintained by Sylvain Munaut <tnt@246tNt.com>
+ *
+ * Copyright (C) 2007  Domen Puncer, Telargo, Inc.
+ * Copyright (C) 2007  Sylvain Munaut <tnt@246tNt.com>
+ * Copyright (C) 2003-2004  MontaVista, Software, Inc.
+ *
+ * This file is licensed under the terms of the GNU General Public Lic=
ense
+ * version 2. This program is licensed "as is" without any warranty of=
 any
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
+#include "fec_mpc52xx.h"
+
+#define DRIVER_NAME "mpc52xx-fec"
+
+static irqreturn_t mpc52xx_fec_interrupt(int, void *);
+static irqreturn_t mpc52xx_fec_rx_interrupt(int, void *);
+static irqreturn_t mpc52xx_fec_tx_interrupt(int, void *);
+static void mpc52xx_fec_stop(struct net_device *dev);
+static void mpc52xx_fec_start(struct net_device *dev);
+static void mpc52xx_fec_reset(struct net_device *dev);
+
+static u8 mpc52xx_fec_mac_addr[6];
+module_param_array_named(mac, mpc52xx_fec_mac_addr, byte, NULL, 0);
+MODULE_PARM_DESC(mac, "six hex digits, ie. 0x1,0x2,0xc0,0x01,0xba,0xbe=
");
+
+#define MPC52xx_MESSAGES_DEFAULT ( NETIF_MSG_DRV | NETIF_MSG_PROBE | \
+		NETIF_MSG_LINK | NETIF_MSG_IFDOWN | NETIF_MSG_IFDOWN )
+static int debug =3D -1;	/* the above default */
+module_param(debug, int, 0);
+MODULE_PARM_DESC(debug, "debugging messages level");
+
+static void mpc52xx_fec_tx_timeout(struct net_device *dev)
+{
+	dev_warn(&dev->dev, "transmit timed out\n");
+
+	mpc52xx_fec_reset(dev);
+
+	dev->stats.tx_errors++;
+
+	netif_wake_queue(dev);
+}
+
+static void mpc52xx_fec_set_paddr(struct net_device *dev, u8 *mac)
+{
+	struct mpc52xx_fec_priv *priv =3D netdev_priv(dev);
+	struct mpc52xx_fec __iomem *fec =3D priv->fec;
+
+	out_be32(&fec->paddr1, *(u32 *)(&mac[0]));
+	out_be32(&fec->paddr2, (*(u16 *)(&mac[4]) << 16) | FEC_PADDR2_TYPE);
+}
+
+static void mpc52xx_fec_get_paddr(struct net_device *dev, u8 *mac)
+{
+	struct mpc52xx_fec_priv *priv =3D netdev_priv(dev);
+	struct mpc52xx_fec __iomem *fec =3D priv->fec;
+
+	*(u32 *)(&mac[0]) =3D in_be32(&fec->paddr1);
+	*(u16 *)(&mac[4]) =3D in_be32(&fec->paddr2) >> 16;
+}
+
+static int mpc52xx_fec_set_mac_address(struct net_device *dev, void *a=
ddr)
+{
+	struct sockaddr *sock =3D addr;
+
+	memcpy(dev->dev_addr, sock->sa_data, dev->addr_len);
+
+	mpc52xx_fec_set_paddr(dev, sock->sa_data);
+	return 0;
+}
+
+static void mpc52xx_fec_free_rx_buffers(struct net_device *dev, struct=
 bcom_task *s)
+{
+	while (!bcom_queue_empty(s)) {
+		struct bcom_fec_bd *bd;
+		struct sk_buff *skb;
+
+		skb =3D bcom_retrieve_buffer(s, NULL, (struct bcom_bd **)&bd);
+		dma_unmap_single(&dev->dev, bd->skb_pa, skb->len, DMA_FROM_DEVICE);
+		kfree_skb(skb);
+	}
+}
+
+static int mpc52xx_fec_alloc_rx_buffers(struct net_device *dev, struct=
 bcom_task *rxtsk)
+{
+	while (!bcom_queue_full(rxtsk)) {
+		struct sk_buff *skb;
+		struct bcom_fec_bd *bd;
+
+		skb =3D dev_alloc_skb(FEC_RX_BUFFER_SIZE);
+		if (skb =3D=3D NULL)
+			return -EAGAIN;
+
+		/* zero out the initial receive buffers to aid debugging */
+		memset(skb->data, 0, FEC_RX_BUFFER_SIZE);
+
+		bd =3D (struct bcom_fec_bd *)bcom_prepare_next_buffer(rxtsk);
+
+		bd->status =3D FEC_RX_BUFFER_SIZE;
+		bd->skb_pa =3D dma_map_single(&dev->dev, skb->data,
+				FEC_RX_BUFFER_SIZE, DMA_FROM_DEVICE);
+
+		bcom_submit_next_buffer(rxtsk, skb);
+	}
+
+	return 0;
+}
+
+/* based on generic_adjust_link from fs_enet-main.c */
+static void mpc52xx_fec_adjust_link(struct net_device *dev)
+{
+	struct mpc52xx_fec_priv *priv =3D netdev_priv(dev);
+	struct phy_device *phydev =3D priv->phydev;
+	int new_state =3D 0;
+
+	if (phydev->link !=3D PHY_DOWN) {
+		if (phydev->duplex !=3D priv->duplex) {
+			struct mpc52xx_fec __iomem *fec =3D priv->fec;
+			u32 rcntrl;
+			u32 tcntrl;
+
+			new_state =3D 1;
+			priv->duplex =3D phydev->duplex;
+
+			rcntrl =3D in_be32(&fec->r_cntrl);
+			tcntrl =3D in_be32(&fec->x_cntrl);
+
+			rcntrl &=3D ~FEC_RCNTRL_DRT;
+			tcntrl &=3D ~FEC_TCNTRL_FDEN;
+			if (phydev->duplex =3D=3D DUPLEX_FULL)
+				tcntrl |=3D FEC_TCNTRL_FDEN;	/* FD enable */
+			else
+				rcntrl |=3D FEC_RCNTRL_DRT;	/* disable Rx on Tx (HD) */
+
+			out_be32(&fec->r_cntrl, rcntrl);
+			out_be32(&fec->x_cntrl, tcntrl);
+		}
+
+		if (phydev->speed !=3D priv->speed) {
+			new_state =3D 1;
+			priv->speed =3D phydev->speed;
+		}
+
+		if (priv->link =3D=3D PHY_DOWN) {
+			new_state =3D 1;
+			priv->link =3D phydev->link;
+			netif_schedule(dev);
+			netif_carrier_on(dev);
+			netif_start_queue(dev);
+		}
+
+	} else if (priv->link) {
+		new_state =3D 1;
+		priv->link =3D PHY_DOWN;
+		priv->speed =3D 0;
+		priv->duplex =3D -1;
+		netif_stop_queue(dev);
+		netif_carrier_off(dev);
+	}
+
+	if (new_state && netif_msg_link(priv))
+		phy_print_status(phydev);
+}
+
+static int mpc52xx_fec_init_phy(struct net_device *dev)
+{
+	struct mpc52xx_fec_priv *priv =3D netdev_priv(dev);
+	struct phy_device *phydev;
+	char phy_id[BUS_ID_SIZE];
+
+	snprintf(phy_id, BUS_ID_SIZE, PHY_ID_FMT,
+			(unsigned int)dev->base_addr, priv->phy_addr);
+
+	priv->link =3D PHY_DOWN;
+	priv->speed =3D 0;
+	priv->duplex =3D -1;
+
+	phydev =3D phy_connect(dev, phy_id, &mpc52xx_fec_adjust_link, 0, PHY_=
INTERFACE_MODE_MII);
+	if (IS_ERR(phydev)) {
+		dev_err(&dev->dev, "phy_connect failed\n");
+		return PTR_ERR(phydev);
+	}
+	dev_info(&dev->dev, "attached phy %i to driver %s\n",
+			phydev->addr, phydev->drv->name);
+
+	priv->phydev =3D phydev;
+
+	return 0;
+}
+
+static int mpc52xx_fec_phy_start(struct net_device *dev)
+{
+	struct mpc52xx_fec_priv *priv =3D netdev_priv(dev);
+	int err;
+
+	if (!priv->has_phy)
+		return 0;
+
+	err =3D mpc52xx_fec_init_phy(dev);
+	if (err) {
+		dev_err(&dev->dev, "mpc52xx_fec_init_phy failed\n");
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
+static void mpc52xx_fec_phy_stop(struct net_device *dev)
+{
+	struct mpc52xx_fec_priv *priv =3D netdev_priv(dev);
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
+static int mpc52xx_fec_phy_mii_ioctl(struct mpc52xx_fec_priv *priv,
+		struct mii_ioctl_data *mii_data, int cmd)
+{
+	if (!priv->has_phy)
+		return -ENOTSUPP;
+
+	return phy_mii_ioctl(priv->phydev, mii_data, cmd);
+}
+
+static void mpc52xx_fec_phy_hw_init(struct mpc52xx_fec_priv *priv)
+{
+	struct mpc52xx_fec __iomem *fec =3D priv->fec;
+
+	if (!priv->has_phy)
+		return;
+
+	out_be32(&fec->mii_speed, priv->phy_speed);
+}
+
+static int mpc52xx_fec_open(struct net_device *dev)
+{
+	struct mpc52xx_fec_priv *priv =3D netdev_priv(dev);
+	int err =3D -EBUSY;
+
+	if (request_irq(dev->irq, &mpc52xx_fec_interrupt, IRQF_SHARED,
+	                DRIVER_NAME "_ctrl", dev)) {
+		dev_err(&dev->dev, "ctrl interrupt request failed\n");
+		goto out;
+	}
+	if (request_irq(priv->r_irq, &mpc52xx_fec_rx_interrupt, 0,
+	                DRIVER_NAME "_rx", dev)) {
+		dev_err(&dev->dev, "rx interrupt request failed\n");
+		goto free_ctrl_irq;
+	}
+	if (request_irq(priv->t_irq, &mpc52xx_fec_tx_interrupt, 0,
+	                DRIVER_NAME "_tx", dev)) {
+		dev_err(&dev->dev, "tx interrupt request failed\n");
+		goto free_2irqs;
+	}
+
+	bcom_fec_rx_reset(priv->rx_dmatsk);
+	bcom_fec_tx_reset(priv->tx_dmatsk);
+
+	err =3D mpc52xx_fec_alloc_rx_buffers(dev, priv->rx_dmatsk);
+	if (err) {
+		dev_err(&dev->dev, "mpc52xx_fec_alloc_rx_buffers failed\n");
+		goto free_irqs;
+	}
+
+	err =3D mpc52xx_fec_phy_start(dev);
+	if (err)
+		goto free_skbs;
+
+	bcom_enable(priv->rx_dmatsk);
+	bcom_enable(priv->tx_dmatsk);
+
+	mpc52xx_fec_start(dev);
+
+	netif_start_queue(dev);
+
+	return 0;
+
+ free_skbs:
+	mpc52xx_fec_free_rx_buffers(dev, priv->rx_dmatsk);
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
+static int mpc52xx_fec_close(struct net_device *dev)
+{
+	struct mpc52xx_fec_priv *priv =3D netdev_priv(dev);
+
+	netif_stop_queue(dev);
+
+	mpc52xx_fec_stop(dev);
+
+	mpc52xx_fec_free_rx_buffers(dev, priv->rx_dmatsk);
+
+	free_irq(dev->irq, dev);
+	free_irq(priv->r_irq, dev);
+	free_irq(priv->t_irq, dev);
+
+	mpc52xx_fec_phy_stop(dev);
+
+	return 0;
+}
+
+/* This will only be invoked if your driver is _not_ in XOFF state.
+ * What this means is that you need not check it, and that this
+ * invariant will hold if you make sure that the netif_*_queue()
+ * calls are done at the proper times.
+ */
+static int mpc52xx_fec_hard_start_xmit(struct sk_buff *skb, struct net=
_device *dev)
+{
+	struct mpc52xx_fec_priv *priv =3D netdev_priv(dev);
+	struct bcom_fec_bd *bd;
+
+	if (bcom_queue_full(priv->tx_dmatsk)) {
+		if (net_ratelimit())
+			dev_err(&dev->dev, "transmit queue overrun\n");
+		return 1;
+	}
+
+	spin_lock_irq(&priv->lock);
+	dev->trans_start =3D jiffies;
+
+	bd =3D (struct bcom_fec_bd *)
+		bcom_prepare_next_buffer(priv->tx_dmatsk);
+
+	bd->status =3D skb->len | BCOM_FEC_TX_BD_TFD | BCOM_FEC_TX_BD_TC;
+	bd->skb_pa =3D dma_map_single(&dev->dev, skb->data, skb->len, DMA_TO_=
DEVICE);
+
+	bcom_submit_next_buffer(priv->tx_dmatsk, skb);
+
+	if (bcom_queue_full(priv->tx_dmatsk)) {
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
+static irqreturn_t mpc52xx_fec_tx_interrupt(int irq, void *dev_id)
+{
+	struct net_device *dev =3D dev_id;
+	struct mpc52xx_fec_priv *priv =3D netdev_priv(dev);
+
+	spin_lock(&priv->lock);
+
+	while (bcom_buffer_done(priv->tx_dmatsk)) {
+		struct sk_buff *skb;
+		struct bcom_fec_bd *bd;
+		skb =3D bcom_retrieve_buffer(priv->tx_dmatsk, NULL,
+				(struct bcom_bd **)&bd);
+		/* Here (and in rx routines) would be a good place for
+		 * dma_unmap_single(), but bcom doesn't return bcom_bd of the
+		 * finished transfer, and _unmap is empty on this platfrom.
+		 */
+		dma_unmap_single(&dev->dev, bd->skb_pa, skb->len, DMA_TO_DEVICE);
+
+		dev_kfree_skb_irq(skb);
+	}
+
+	netif_wake_queue(dev);
+
+	spin_unlock(&priv->lock);
+
+	return IRQ_HANDLED;
+}
+
+static irqreturn_t mpc52xx_fec_rx_interrupt(int irq, void *dev_id)
+{
+	struct net_device *dev =3D dev_id;
+	struct mpc52xx_fec_priv *priv =3D netdev_priv(dev);
+
+	while (bcom_buffer_done(priv->rx_dmatsk)) {
+		struct sk_buff *skb;
+		struct sk_buff *rskb;
+		struct bcom_fec_bd *bd;
+		u32 status;
+
+		rskb =3D bcom_retrieve_buffer(priv->rx_dmatsk, &status,
+				(struct bcom_bd **)&bd);
+		dma_unmap_single(&dev->dev, bd->skb_pa, skb->len, DMA_FROM_DEVICE);
+
+		/* Test for errors in received frame */
+		if (status & BCOM_FEC_RX_BD_ERRORS) {
+			/* Drop packet and reuse the buffer */
+			bd =3D (struct bcom_fec_bd *)
+				bcom_prepare_next_buffer(priv->rx_dmatsk);
+
+			bd->status =3D FEC_RX_BUFFER_SIZE;
+			bd->skb_pa =3D dma_map_single(&dev->dev, rskb->data,
+					FEC_RX_BUFFER_SIZE, DMA_FROM_DEVICE);
+
+			bcom_submit_next_buffer(priv->rx_dmatsk, rskb);
+
+			dev->stats.rx_dropped++;
+
+			continue;
+		}
+
+		/* skbs are allocated on open, so now we allocate a new one,
+		 * and remove the old (with the packet) */
+		skb =3D dev_alloc_skb(FEC_RX_BUFFER_SIZE);
+		if (skb) {
+			/* Process the received skb */
+			int length =3D status & BCOM_FEC_RX_BD_LEN_MASK;
+
+			skb_put(rskb, length - 4);	/* length without CRC32 */
+
+			rskb->dev =3D dev;
+			rskb->protocol =3D eth_type_trans(rskb, dev);
+
+			netif_rx(rskb);
+			dev->last_rx =3D jiffies;
+		} else {
+			/* Can't get a new one : reuse the same & drop pkt */
+			dev_notice(&dev->dev, "Memory squeeze, dropping packet.\n");
+			dev->stats.rx_dropped++;
+
+			skb =3D rskb;
+		}
+
+		bd =3D (struct bcom_fec_bd *)
+			bcom_prepare_next_buffer(priv->rx_dmatsk);
+
+		bd->status =3D FEC_RX_BUFFER_SIZE;
+		bd->skb_pa =3D dma_map_single(&dev->dev, rskb->data,
+				FEC_RX_BUFFER_SIZE, DMA_FROM_DEVICE);
+
+		bcom_submit_next_buffer(priv->rx_dmatsk, skb);
+	}
+
+	return IRQ_HANDLED;
+}
+
+static irqreturn_t mpc52xx_fec_interrupt(int irq, void *dev_id)
+{
+	struct net_device *dev =3D dev_id;
+	struct mpc52xx_fec_priv *priv =3D netdev_priv(dev);
+	struct mpc52xx_fec __iomem *fec =3D priv->fec;
+	u32 ievent;
+
+	ievent =3D in_be32(&fec->ievent);
+
+	ievent &=3D ~FEC_IEVENT_MII;	/* mii is handled separately */
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
+	mpc52xx_fec_reset(dev);
+
+	netif_wake_queue(dev);
+	return IRQ_HANDLED;
+}
+
+/*
+ * Get the current statistics.
+ * This may be called with the card open or closed.
+ */
+static struct net_device_stats *mpc52xx_fec_get_stats(struct net_devic=
e *dev)
+{
+	struct mpc52xx_fec_priv *priv =3D netdev_priv(dev);
+	struct net_device_stats *stats =3D &dev->stats;
+	struct mpc52xx_fec __iomem *fec =3D priv->fec;
+
+	stats->rx_bytes =3D in_be32(&fec->rmon_r_octets);
+	stats->rx_packets =3D in_be32(&fec->rmon_r_packets);
+	stats->rx_errors =3D in_be32(&fec->rmon_r_crc_align) +
+		in_be32(&fec->rmon_r_undersize) +
+		in_be32(&fec->rmon_r_oversize) +
+		in_be32(&fec->rmon_r_frag) +
+		in_be32(&fec->rmon_r_jab);
+
+	stats->tx_bytes =3D in_be32(&fec->rmon_t_octets);
+	stats->tx_packets =3D in_be32(&fec->rmon_t_packets);
+	stats->tx_errors =3D in_be32(&fec->rmon_t_crc_align) +
+		in_be32(&fec->rmon_t_undersize) +
+		in_be32(&fec->rmon_t_oversize) +
+		in_be32(&fec->rmon_t_frag) +
+		in_be32(&fec->rmon_t_jab);
+
+	stats->multicast =3D in_be32(&fec->rmon_r_mc_pkt);
+	stats->collisions =3D in_be32(&fec->rmon_t_col);
+
+	/* detailed rx_errors: */
+	stats->rx_length_errors =3D in_be32(&fec->rmon_r_undersize)
+					+ in_be32(&fec->rmon_r_oversize)
+					+ in_be32(&fec->rmon_r_frag)
+					+ in_be32(&fec->rmon_r_jab);
+	stats->rx_over_errors =3D in_be32(&fec->r_macerr);
+	stats->rx_crc_errors =3D in_be32(&fec->ieee_r_crc);
+	stats->rx_frame_errors =3D in_be32(&fec->ieee_r_align);
+	stats->rx_fifo_errors =3D in_be32(&fec->rmon_r_drop);
+	stats->rx_missed_errors =3D in_be32(&fec->rmon_r_drop);
+
+	/* detailed tx_errors: */
+	stats->tx_aborted_errors =3D 0;
+	stats->tx_carrier_errors =3D in_be32(&fec->ieee_t_cserr);
+	stats->tx_fifo_errors =3D in_be32(&fec->rmon_t_drop);
+	stats->tx_heartbeat_errors =3D in_be32(&fec->ieee_t_sqe);
+	stats->tx_window_errors =3D in_be32(&fec->ieee_t_lcol);
+
+	return stats;
+}
+
+/*
+ * Read MIB counters in order to reset them,
+ * then zero all the stats fields in memory
+ */
+static void mpc52xx_fec_reset_stats(struct net_device *dev)
+{
+	struct mpc52xx_fec_priv *priv =3D netdev_priv(dev);
+	struct mpc52xx_fec __iomem *fec =3D priv->fec;
+
+	out_be32(&fec->mib_control, FEC_MIB_DISABLE);
+	memset_io(&fec->rmon_t_drop, 0,	(__force u32)&fec->reserved10 -
+			(__force u32)&fec->rmon_t_drop);
+	out_be32(&fec->mib_control, 0);
+
+	memset(&dev->stats, 0, sizeof(dev->stats));
+}
+
+/*
+ * Set or clear the multicast filter for this adaptor.
+ */
+static void mpc52xx_fec_set_multicast_list(struct net_device *dev)
+{
+	struct mpc52xx_fec_priv *priv =3D netdev_priv(dev);
+	struct mpc52xx_fec __iomem *fec =3D priv->fec;
+	u32 rx_control;
+
+	rx_control =3D in_be32(&fec->r_cntrl);
+
+	if (dev->flags & IFF_PROMISC) {
+		rx_control |=3D FEC_RCNTRL_PROM;
+		out_be32(&fec->r_cntrl, rx_control);
+	} else {
+		rx_control &=3D ~FEC_RCNTRL_PROM;
+		out_be32(&fec->r_cntrl, rx_control);
+
+		if (dev->flags & IFF_ALLMULTI) {
+			out_be32(&fec->gaddr1, 0xffffffff);
+			out_be32(&fec->gaddr2, 0xffffffff);
+		} else {
+			u32 crc;
+			int i;
+			struct dev_mc_list *dmi;
+			u32 gaddr1 =3D 0x00000000;
+			u32 gaddr2 =3D 0x00000000;
+
+			dmi =3D dev->mc_list;
+			for (i=3D0; i<dev->mc_count; i++) {
+				crc =3D ether_crc_le(6, dmi->dmi_addr) >> 26;
+				if (crc >=3D 32)
+					gaddr1 |=3D 1 << (crc-32);
+				else
+					gaddr2 |=3D 1 << crc;
+				dmi =3D dmi->next;
+			}
+			out_be32(&fec->gaddr1, gaddr1);
+			out_be32(&fec->gaddr2, gaddr2);
+		}
+	}
+}
+
+/**
+ * mpc52xx_fec_hw_init
+ * @dev: network device
+ *
+ * Setup various hardware setting, only needed once on start
+ */
+static void mpc52xx_fec_hw_init(struct net_device *dev)
+{
+	struct mpc52xx_fec_priv *priv =3D netdev_priv(dev);
+	struct mpc52xx_fec __iomem *fec =3D priv->fec;
+	int i;
+
+	/* Whack a reset.  We should wait for this. */
+	out_be32(&fec->ecntrl, FEC_ECNTRL_RESET);
+	for (i =3D 0; i < FEC_RESET_DELAY; ++i) {
+		if ((in_be32(&fec->ecntrl) & FEC_ECNTRL_RESET) =3D=3D 0)
+			break;
+		udelay(1);
+	}
+	if (i =3D=3D FEC_RESET_DELAY)
+		dev_err(&dev->dev, "FEC Reset timeout!\n");
+
+	/* set pause to 0x20 frames */
+	out_be32(&fec->op_pause, FEC_OP_PAUSE_OPCODE | 0x20);
+
+	/* high service request will be deasserted when there's < 7 bytes in =
fifo
+	 * low service request will be deasserted when there's < 4*7 bytes in=
 fifo
+	 */
+	out_be32(&fec->rfifo_cntrl, FEC_FIFO_CNTRL_FRAME | FEC_FIFO_CNTRL_LTG=
_7);
+	out_be32(&fec->tfifo_cntrl, FEC_FIFO_CNTRL_FRAME | FEC_FIFO_CNTRL_LTG=
_7);
+
+	/* alarm when <=3D x bytes in FIFO */
+	out_be32(&fec->rfifo_alarm, 0x0000030c);
+	out_be32(&fec->tfifo_alarm, 0x00000100);
+
+	/* begin transmittion when 256 bytes are in FIFO (or EOF or FIFO full=
) */
+	out_be32(&fec->x_wmrk, FEC_FIFO_WMRK_256B);
+
+	/* enable crc generation */
+	out_be32(&fec->xmit_fsm, FEC_XMIT_FSM_APPEND_CRC | FEC_XMIT_FSM_ENABL=
E_CRC);
+	out_be32(&fec->iaddr1, 0x00000000);	/* No individual filter */
+	out_be32(&fec->iaddr2, 0x00000000);	/* No individual filter */
+
+	/* set phy speed.
+	 * this can't be done in phy driver, since it needs to be called
+	 * before fec stuff (even on resume) */
+	mpc52xx_fec_phy_hw_init(priv);
+}
+
+/**
+ * mpc52xx_fec_start
+ * @dev: network device
+ *
+ * This function is called to start or restart the FEC during a link
+ * change.  This happens on fifo errors or when switching between half
+ * and full duplex.
+ */
+static void mpc52xx_fec_start(struct net_device *dev)
+{
+	struct mpc52xx_fec_priv *priv =3D netdev_priv(dev);
+	struct mpc52xx_fec __iomem *fec =3D priv->fec;
+	u32 rcntrl;
+	u32 tcntrl;
+	u32 tmp;
+
+	/* clear sticky error bits */
+	tmp =3D FEC_FIFO_STATUS_ERR | FEC_FIFO_STATUS_UF | FEC_FIFO_STATUS_OF=
;
+	out_be32(&fec->rfifo_status, in_be32(&fec->rfifo_status) & tmp);
+	out_be32(&fec->tfifo_status, in_be32(&fec->tfifo_status) & tmp);
+
+	/* FIFOs will reset on mpc52xx_fec_enable */
+	out_be32(&fec->reset_cntrl, FEC_RESET_CNTRL_ENABLE_IS_RESET);
+
+	/* Set station address. */
+	mpc52xx_fec_set_paddr(dev, dev->dev_addr);
+
+	mpc52xx_fec_set_multicast_list(dev);
+
+	/* set max frame len, enable flow control, select mii mode */
+	rcntrl =3D FEC_RX_BUFFER_SIZE << 16;	/* max frame length */
+	rcntrl |=3D FEC_RCNTRL_FCE;
+
+	if (priv->has_phy)
+		rcntrl |=3D FEC_RCNTRL_MII_MODE;
+
+	if (priv->duplex =3D=3D DUPLEX_FULL)
+		tcntrl =3D FEC_TCNTRL_FDEN;	/* FD enable */
+	else {
+		rcntrl |=3D FEC_RCNTRL_DRT;	/* disable Rx on Tx (HD) */
+		tcntrl =3D 0;
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
+}
+
+/**
+ * mpc52xx_fec_stop
+ * @dev: network device
+ *
+ * stop all activity on fec and empty dma buffers
+ */
+static void mpc52xx_fec_stop(struct net_device *dev)
+{
+	struct mpc52xx_fec_priv *priv =3D netdev_priv(dev);
+	struct mpc52xx_fec __iomem *fec =3D priv->fec;
+	unsigned long timeout;
+
+	/* disable all interrupts */
+	out_be32(&fec->imask, 0);
+
+	/* Disable the rx task. */
+	bcom_disable(priv->rx_dmatsk);
+
+	/* Wait for tx queue to drain, but only if we're in process context *=
/
+	if (!in_interrupt()) {
+		timeout =3D jiffies + msecs_to_jiffies(2000);
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
+static void mpc52xx_fec_reset(struct net_device *dev)
+{
+	struct mpc52xx_fec_priv *priv =3D netdev_priv(dev);
+	struct mpc52xx_fec __iomem *fec =3D priv->fec;
+
+	mpc52xx_fec_stop(dev);
+
+	out_be32(&fec->rfifo_status, in_be32(&fec->rfifo_status));
+	out_be32(&fec->reset_cntrl, FEC_RESET_CNTRL_RESET_FIFO);
+
+	mpc52xx_fec_free_rx_buffers(dev, priv->rx_dmatsk);
+
+	mpc52xx_fec_hw_init(dev);
+
+	phy_stop(priv->phydev);
+	phy_write(priv->phydev, MII_BMCR, BMCR_RESET);
+	phy_start(priv->phydev);
+
+	bcom_fec_rx_reset(priv->rx_dmatsk);
+	bcom_fec_tx_reset(priv->tx_dmatsk);
+
+	mpc52xx_fec_alloc_rx_buffers(dev, priv->rx_dmatsk);
+
+	bcom_enable(priv->rx_dmatsk);
+	bcom_enable(priv->tx_dmatsk);
+
+	mpc52xx_fec_start(dev);
+}
+
+
+/* ethtool interface */
+static void mpc52xx_fec_get_drvinfo(struct net_device *dev,
+		struct ethtool_drvinfo *info)
+{
+	strcpy(info->driver, DRIVER_NAME);
+}
+
+static int mpc52xx_fec_get_settings(struct net_device *dev, struct eth=
tool_cmd *cmd)
+{
+	struct mpc52xx_fec_priv *priv =3D netdev_priv(dev);
+	return phy_ethtool_gset(priv->phydev, cmd);
+}
+
+static int mpc52xx_fec_set_settings(struct net_device *dev, struct eth=
tool_cmd *cmd)
+{
+	struct mpc52xx_fec_priv *priv =3D netdev_priv(dev);
+	return phy_ethtool_sset(priv->phydev, cmd);
+}
+
+static u32 mpc52xx_fec_get_msglevel(struct net_device *dev)
+{
+	struct mpc52xx_fec_priv *priv =3D netdev_priv(dev);
+	return priv->msg_enable;
+}
+
+static void mpc52xx_fec_set_msglevel(struct net_device *dev, u32 level=
)
+{
+	struct mpc52xx_fec_priv *priv =3D netdev_priv(dev);
+	priv->msg_enable =3D level;
+}
+
+static const struct ethtool_ops mpc52xx_fec_ethtool_ops =3D {
+	.get_drvinfo =3D mpc52xx_fec_get_drvinfo,
+	.get_settings =3D mpc52xx_fec_get_settings,
+	.set_settings =3D mpc52xx_fec_set_settings,
+	.get_link =3D ethtool_op_get_link,
+	.get_msglevel =3D mpc52xx_fec_get_msglevel,
+	.set_msglevel =3D mpc52xx_fec_set_msglevel,
+};
+
+
+static int mpc52xx_fec_ioctl(struct net_device *dev, struct ifreq *rq,=
 int cmd)
+{
+	struct mpc52xx_fec_priv *priv =3D netdev_priv(dev);
+
+	return mpc52xx_fec_phy_mii_ioctl(priv, if_mii(rq), cmd);
+}
+
+/* =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D */
+/* OF Driver                                                          =
      */
+/* =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D */
+
+static int __devinit
+mpc52xx_fec_probe(struct of_device *op, const struct of_device_id *mat=
ch)
+{
+	int rv;
+	struct net_device *ndev;
+	struct mpc52xx_fec_priv *priv =3D NULL;
+	struct resource mem;
+	const phandle *ph;
+
+	phys_addr_t rx_fifo;
+	phys_addr_t tx_fifo;
+
+	/* Get the ether ndev & it's private zone */
+	ndev =3D alloc_etherdev(sizeof(struct mpc52xx_fec_priv));
+	if (!ndev)
+		return -ENOMEM;
+
+	priv =3D netdev_priv(ndev);
+
+	/* Reserve FEC control zone */
+	rv =3D of_address_to_resource(op->node, 0, &mem);
+	if (rv) {
+		printk(KERN_ERR DRIVER_NAME ": "
+				"Error while parsing device node resource\n" );
+		return rv;
+	}
+	if ((mem.end - mem.start + 1) !=3D sizeof(struct mpc52xx_fec)) {
+		printk(KERN_ERR DRIVER_NAME
+			" - invalid resource size (%lx !=3D %x), check mpc52xx_devices.c\n"=
,
+			(unsigned long)(mem.end - mem.start + 1), sizeof(struct mpc52xx_fec=
));
+		return -EINVAL;
+	}
+
+	if (!request_mem_region(mem.start, sizeof(struct mpc52xx_fec), DRIVER=
_NAME))
+		return -EBUSY;
+
+	/* Init ether ndev with what we have */
+	ndev->open		=3D mpc52xx_fec_open;
+	ndev->stop		=3D mpc52xx_fec_close;
+	ndev->hard_start_xmit	=3D mpc52xx_fec_hard_start_xmit;
+	ndev->do_ioctl		=3D mpc52xx_fec_ioctl;
+	ndev->ethtool_ops	=3D &mpc52xx_fec_ethtool_ops;
+	ndev->get_stats		=3D mpc52xx_fec_get_stats;
+	ndev->set_mac_address	=3D mpc52xx_fec_set_mac_address;
+	ndev->set_multicast_list =3D mpc52xx_fec_set_multicast_list;
+	ndev->tx_timeout	=3D mpc52xx_fec_tx_timeout;
+	ndev->watchdog_timeo	=3D FEC_WATCHDOG_TIMEOUT;
+	ndev->base_addr		=3D mem.start;
+
+	priv->t_irq =3D priv->r_irq =3D ndev->irq =3D NO_IRQ; /* IRQ are free=
 for now */
+
+	spin_lock_init(&priv->lock);
+
+	/* ioremap the zones */
+	priv->fec =3D ioremap(mem.start, sizeof(struct mpc52xx_fec));
+
+	if (!priv->fec) {
+		rv =3D -ENOMEM;
+		goto probe_error;
+	}
+
+	/* Bestcomm init */
+	rx_fifo =3D ndev->base_addr + offsetof(struct mpc52xx_fec, rfifo_data=
);
+	tx_fifo =3D ndev->base_addr + offsetof(struct mpc52xx_fec, tfifo_data=
);
+
+	priv->rx_dmatsk =3D bcom_fec_rx_init(FEC_RX_NUM_BD, rx_fifo, FEC_RX_B=
UFFER_SIZE);
+	priv->tx_dmatsk =3D bcom_fec_tx_init(FEC_TX_NUM_BD, tx_fifo);
+
+	if (!priv->rx_dmatsk || !priv->tx_dmatsk) {
+		printk(KERN_ERR DRIVER_NAME ": Can not init SDMA tasks\n" );
+		rv =3D -ENOMEM;
+		goto probe_error;
+	}
+
+	/* Get the IRQ we need one by one */
+		/* Control */
+	ndev->irq =3D irq_of_parse_and_map(op->node, 0);
+
+		/* RX */
+	priv->r_irq =3D bcom_get_task_irq(priv->rx_dmatsk);
+
+		/* TX */
+	priv->t_irq =3D bcom_get_task_irq(priv->tx_dmatsk);
+
+	/* MAC address init */
+	if (!is_zero_ether_addr(mpc52xx_fec_mac_addr))
+		memcpy(ndev->dev_addr, mpc52xx_fec_mac_addr, 6);
+	else
+		mpc52xx_fec_get_paddr(ndev, ndev->dev_addr);
+
+	priv->msg_enable =3D netif_msg_init(debug, MPC52xx_MESSAGES_DEFAULT);
+	priv->duplex =3D DUPLEX_FULL;
+
+	/* is the phy present in device tree? */
+	ph =3D of_get_property(op->node, "phy-handle", NULL);
+	if (ph) {
+		const unsigned int *prop;
+		struct device_node *phy_dn;
+		priv->has_phy =3D 1;
+
+		phy_dn =3D of_find_node_by_phandle(*ph);
+		prop =3D of_get_property(phy_dn, "reg", NULL);
+		priv->phy_addr =3D *prop;
+
+		of_node_put(phy_dn);
+
+		/* Phy speed */
+		priv->phy_speed =3D ((mpc52xx_find_ipb_freq(op->node) >> 20) / 5) <<=
 1;
+	} else {
+		dev_info(&ndev->dev, "can't find \"phy-handle\" in device"
+				" tree, using 7-wire mode\n");
+	}
+
+	/* Hardware init */
+	mpc52xx_fec_hw_init(ndev);
+
+	mpc52xx_fec_reset_stats(ndev);
+
+	/* Register the new network device */
+	rv =3D register_netdev(ndev);
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
+	struct mpc52xx_fec_priv *priv;
+
+	ndev =3D dev_get_drvdata(&op->dev);
+	priv =3D netdev_priv(ndev);
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
+static int mpc52xx_fec_of_suspend(struct of_device *op, pm_message_t s=
tate)
+{
+	struct net_device *dev =3D dev_get_drvdata(&op->dev);
+
+	if (netif_running(dev))
+		mpc52xx_fec_close(dev);
+
+	return 0;
+}
+
+static int mpc52xx_fec_of_resume(struct of_device *op)
+{
+	struct net_device *dev =3D dev_get_drvdata(&op->dev);
+
+	mpc52xx_fec_hw_init(dev);
+	mpc52xx_fec_reset_stats(dev);
+
+	if (netif_running(dev))
+		mpc52xx_fec_open(dev);
+
+	return 0;
+}
+#endif
+
+static struct of_device_id mpc52xx_fec_match[] =3D {
+	{
+		.type		=3D "network",
+		.compatible	=3D "mpc5200-fec",
+	},
+	{ }
+};
+
+MODULE_DEVICE_TABLE(of, mpc52xx_fec_match);
+
+static struct of_platform_driver mpc52xx_fec_driver =3D {
+	.owner		=3D THIS_MODULE,
+	.name		=3D DRIVER_NAME,
+	.match_table	=3D mpc52xx_fec_match,
+	.probe		=3D mpc52xx_fec_probe,
+	.remove		=3D mpc52xx_fec_remove,
+#ifdef CONFIG_PM
+	.suspend	=3D mpc52xx_fec_of_suspend,
+	.resume		=3D mpc52xx_fec_of_resume,
+#endif
+};
+
+
+/* =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D */
+/* Module                                                             =
      */
+/* =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D */
+
+static int __init
+mpc52xx_fec_init(void)
+{
+#ifdef CONFIG_FEC_MPC52xx_MDIO
+	int ret;
+	ret =3D of_register_platform_driver(&mpc52xx_fec_mdio_driver);
+	if (ret) {
+		printk(KERN_ERR DRIVER_NAME ": failed to register mdio driver\n");
+		return ret;
+	}
+#endif
+	return of_register_platform_driver(&mpc52xx_fec_driver);
+}
+
+static void __exit
+mpc52xx_fec_exit(void)
+{
+	of_unregister_platform_driver(&mpc52xx_fec_driver);
+#ifdef CONFIG_FEC_MPC52xx_MDIO
+	of_unregister_platform_driver(&mpc52xx_fec_mdio_driver);
+#endif
+}
+
+
+module_init(mpc52xx_fec_init);
+module_exit(mpc52xx_fec_exit);
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Dale Farnsworth");
+MODULE_DESCRIPTION("Ethernet driver for the Freescale MPC52xx FEC");
Index: linux.git/drivers/net/fec_mpc52xx.h
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- /dev/null
+++ linux.git/drivers/net/fec_mpc52xx.h
@@ -0,0 +1,313 @@
+/*
+ * drivers/drivers/net/fec_mpc52xx/fec.h
+ *
+ * Driver for the MPC5200 Fast Ethernet Controller
+ *
+ * Author: Dale Farnsworth <dfarnsworth@mvista.com>
+ *
+ * 2003-2004 (c) MontaVista, Software, Inc.  This file is licensed und=
er
+ * the terms of the GNU General Public License version 2.  This progra=
m
+ * is licensed "as is" without any warranty of any kind, whether expre=
ss
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
+struct mpc52xx_fec_priv {
+	int duplex;
+	int r_irq;
+	int t_irq;
+	struct mpc52xx_fec __iomem *fec;
+	struct bcom_task *rx_dmatsk;
+	struct bcom_task *tx_dmatsk;
+	spinlock_t lock;
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
+/* =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D */
+/* Hardware register sets & bits                                      =
      */
+/* =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D */
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
+#define FEC_MII_READ_FRAME	(FEC_MII_DATA_ST | FEC_MII_DATA_OP_RD | FEC=
_MII_DATA_TA)
+#define FEC_MII_WRITE_FRAME	(FEC_MII_DATA_ST | FEC_MII_DATA_OP_WR | FE=
C_MII_DATA_TA)
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
+extern struct of_platform_driver mpc52xx_fec_mdio_driver;
+
+#endif	/* __DRIVERS_NET_MPC52XX_FEC_H__ */
Index: linux.git/drivers/net/fec_mpc52xx_phy.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- /dev/null
+++ linux.git/drivers/net/fec_mpc52xx_phy.c
@@ -0,0 +1,198 @@
+/*
+ * Driver for the MPC5200 Fast Ethernet Controller - MDIO bus driver
+ *
+ * Copyright (C) 2007  Domen Puncer, Telargo, Inc.
+ *
+ * This file is licensed under the terms of the GNU General Public Lic=
ense
+ * version 2. This program is licensed "as is" without any warranty of=
 any
+ * kind, whether express or implied.
+ */
+
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/netdevice.h>
+#include <linux/phy.h>
+#include <linux/of_platform.h>
+#include <asm/io.h>
+#include <asm/mpc52xx.h>
+#include "fec_mpc52xx.h"
+
+struct mpc52xx_fec_mdio_priv {
+	struct mpc52xx_fec __iomem *regs;
+};
+
+static int mpc52xx_fec_mdio_read(struct mii_bus *bus, int phy_id, int =
reg)
+{
+	struct mpc52xx_fec_mdio_priv *priv =3D bus->priv;
+	struct mpc52xx_fec __iomem *fec;
+	int tries =3D 100;
+	u32 request =3D FEC_MII_READ_FRAME;
+
+	fec =3D priv->regs;
+	out_be32(&fec->ievent, FEC_IEVENT_MII);
+
+	request |=3D (phy_id << FEC_MII_DATA_PA_SHIFT) & FEC_MII_DATA_PA_MSK;
+	request |=3D (reg << FEC_MII_DATA_RA_SHIFT) & FEC_MII_DATA_RA_MSK;
+
+	out_be32(&priv->regs->mii_data, request);
+
+	/* wait for it to finish, this takes about 23 us on lite5200b */
+	while (!(in_be32(&fec->ievent) & FEC_IEVENT_MII) && --tries)
+		udelay(5);
+
+	if (tries =3D=3D 0)
+		return -ETIMEDOUT;
+
+	return in_be32(&priv->regs->mii_data) & FEC_MII_DATA_DATAMSK;
+}
+
+static int mpc52xx_fec_mdio_write(struct mii_bus *bus, int phy_id, int=
 reg, u16 data)
+{
+	struct mpc52xx_fec_mdio_priv *priv =3D bus->priv;
+	struct mpc52xx_fec __iomem *fec;
+	u32 value =3D data;
+	int tries =3D 100;
+
+	fec =3D priv->regs;
+	out_be32(&fec->ievent, FEC_IEVENT_MII);
+
+	value |=3D FEC_MII_WRITE_FRAME;
+	value |=3D (phy_id << FEC_MII_DATA_PA_SHIFT) & FEC_MII_DATA_PA_MSK;
+	value |=3D (reg << FEC_MII_DATA_RA_SHIFT) & FEC_MII_DATA_RA_MSK;
+
+	out_be32(&priv->regs->mii_data, value);
+
+	/* wait for request to finish */
+	while (!(in_be32(&fec->ievent) & FEC_IEVENT_MII) && --tries)
+		udelay(5);
+
+	if (tries =3D=3D 0)
+		return -ETIMEDOUT;
+
+	return 0;
+}
+
+static int mpc52xx_fec_mdio_probe(struct of_device *of, const struct o=
f_device_id *match)
+{
+	struct device *dev =3D &of->dev;
+	struct device_node *np =3D of->node;
+	struct device_node *child =3D NULL;
+	struct mii_bus *bus;
+	struct mpc52xx_fec_mdio_priv *priv;
+	struct resource res =3D {};
+	int err;
+	int i;
+
+	bus =3D kzalloc(sizeof(*bus), GFP_KERNEL);
+	if (bus =3D=3D NULL)
+		return -ENOMEM;
+	priv =3D kzalloc(sizeof(*priv), GFP_KERNEL);
+	if (priv =3D=3D NULL) {
+		err =3D -ENOMEM;
+		goto out_free;
+	}
+
+	bus->name =3D "mpc52xx MII bus";
+	bus->read =3D mpc52xx_fec_mdio_read;
+	bus->write =3D mpc52xx_fec_mdio_write;
+
+	/* setup irqs */
+	bus->irq =3D kmalloc(sizeof(bus->irq[0]) * PHY_MAX_ADDR, GFP_KERNEL);
+	if (bus->irq =3D=3D NULL) {
+		err =3D -ENOMEM;
+		goto out_free;
+	}
+	for (i=3D0; i<PHY_MAX_ADDR; i++)
+		bus->irq[i] =3D PHY_POLL;
+
+	while ((child =3D of_get_next_child(np, child)) !=3D NULL) {
+		int irq =3D irq_of_parse_and_map(child, 0);
+		if (irq !=3D NO_IRQ) {
+			const u32 *id =3D of_get_property(child, "reg", NULL);
+			bus->irq[*id] =3D irq;
+		}
+	}
+
+	/* setup registers */
+	err =3D of_address_to_resource(np, 0, &res);
+	if (err)
+		goto out_free;
+	priv->regs =3D ioremap(res.start, res.end - res.start + 1);
+	if (priv->regs =3D=3D NULL) {
+		err =3D -ENOMEM;
+		goto out_free;
+	}
+
+	bus->id =3D res.start;
+	bus->priv =3D priv;
+
+	bus->dev =3D dev;
+	dev_set_drvdata(dev, bus);
+
+	/* set MII speed */
+	out_be32(&priv->regs->mii_speed, ((mpc52xx_find_ipb_freq(of->node) >>=
 20) / 5) << 1);
+
+	/* enable MII interrupt */
+	out_be32(&priv->regs->imask, in_be32(&priv->regs->imask) | FEC_IMASK_=
MII);
+
+	err =3D mdiobus_register(bus);
+	if (err)
+		goto out_unmap;
+
+	return 0;
+
+ out_unmap:
+	iounmap(priv->regs);
+ out_free:
+	for (i=3D0; i<PHY_MAX_ADDR; i++)
+		if (bus->irq[i] !=3D PHY_POLL)
+			irq_dispose_mapping(bus->irq[i]);
+	kfree(bus->irq);
+	kfree(priv);
+	kfree(bus);
+
+	return err;
+}
+
+static int mpc52xx_fec_mdio_remove(struct of_device *of)
+{
+	struct device *dev =3D &of->dev;
+	struct mii_bus *bus =3D dev_get_drvdata(dev);
+	struct mpc52xx_fec_mdio_priv *priv =3D bus->priv;
+	int i;
+
+	mdiobus_unregister(bus);
+	dev_set_drvdata(dev, NULL);
+
+	iounmap(priv->regs);
+	for (i=3D0; i<PHY_MAX_ADDR; i++)
+		if (bus->irq[i])
+			irq_dispose_mapping(bus->irq[i]);
+	kfree(priv);
+	kfree(bus->irq);
+	kfree(bus);
+
+	return 0;
+}
+
+
+static struct of_device_id mpc52xx_fec_mdio_match[] =3D {
+	{
+		.type =3D "mdio",
+		.compatible =3D "mpc5200b-fec-phy",
+	},
+	{},
+};
+
+struct of_platform_driver mpc52xx_fec_mdio_driver =3D {
+	.name =3D "mpc5200b-fec-phy",
+	.probe =3D mpc52xx_fec_mdio_probe,
+	.remove =3D mpc52xx_fec_mdio_remove,
+	.match_table =3D mpc52xx_fec_mdio_match,
+};
+
+/* let fec driver call it, since this has to be registered before it *=
/
+EXPORT_SYMBOL_GPL(mpc52xx_fec_mdio_driver);
+
+
+MODULE_LICENSE("Dual BSD/GPL");
>=20
> -Dale

--=20
Domen Puncer | Research & Development
=2E....................................................................=
=2E.......................
Telargo d.o.o. | Zagreb=C5=A1ka cesta 20 | 2000 Maribor | Slovenia
=2E....................................................................=
=2E.......................
www.telargo.com
