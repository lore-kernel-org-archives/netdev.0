From: Harald Welte <laforge@gnumonks.org>
Subject: [PATCH 2.6] natsemi.c NAPI
Date: Mon, 20 Sep 2004 16:10:30 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040920141030.GV1307@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="7a4X6VOqfbl9xMrG"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--7a4X6VOqfbl9xMrG
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi!

As announced before, here is the NAPI-patch for natsemi.c

My 266 MHz National Geode SC1100 (http://www.pcengines.ch/wrap.htm) with
two natsemi chips can now forward 32kpps at (64bytes, 148kpps, single
flow UDP input).

Any comments welcome, just like inclusion of this patch :)

Signed-off-by: Harald Welte <laforge@gnumonks.org>

diff -Nru linux-2.6.9-rc1-plain/drivers/net/Kconfig linux-2.6.9-rc1-natsemi=
-napi/drivers/net/Kconfig
--- linux-2.6.9-rc1-plain/drivers/net/Kconfig	2004-08-31 20:24:39.000000000=
 +0200
+++ linux-2.6.9-rc1-natsemi-napi/drivers/net/Kconfig	2004-09-14 22:10:29.00=
0000000 +0200
@@ -1534,6 +1534,22 @@
 	  and others, including the 83815 chip.
 	  More specific information and updates are available from
 	  <http://www.scyld.com/network/natsemi.html>.
+config NATSEMI_NAPI
+	bool "Use Rx Polling (NAPI) (EXPERIMENTAL)"
+	depends on NATSEMI && EXPERIMENTAL
+	help
+	  NAPI is a new driver API designed to reduce CPU and interrupt load
+	  when the driver is receiving lots of packets from the card. It is
+	  still somewhat experimental and thus not yet enabled by default.
+
+	  If your estimated Rx load is 10kpps or more, or if the card will be
+	  deployed on potentially unfriendly networks (e.g. in a firewall),
+	  then say Y here.
+
+	  See <file:Documentation/networking/NAPI_HOWTO.txt> for more
+	  information.
+
+	  If in doubt, say N.
=20
 config NE2K_PCI
 	tristate "PCI NE2000 and clones support (see help)"
diff -Nru linux-2.6.9-rc1-plain/drivers/net/natsemi.c linux-2.6.9-rc1-natse=
mi-napi/drivers/net/natsemi.c
--- linux-2.6.9-rc1-plain/drivers/net/natsemi.c	2004-08-31 20:24:39.0000000=
00 +0200
+++ linux-2.6.9-rc1-natsemi-napi/drivers/net/natsemi.c	2004-09-18 14:09:59.=
000000000 +0200
@@ -3,6 +3,7 @@
 	Written/copyright 1999-2001 by Donald Becker.
 	Portions copyright (c) 2001,2002 Sun Microsystems (thockin@sun.com)
 	Portions copyright 2001,2002 Manfred Spraul (manfred@colorfullife.com)
+	Portions copyright 2004 Harald Welte <laforge@gnumonks.org>
=20
 	This software may be used and distributed according to the terms of
 	the GNU General Public License (GPL), incorporated herein by reference.
@@ -133,10 +134,12 @@
 		* comments update (Manfred)
 		* do the right thing on a phy-reset (Manfred and Tim)
=20
+	version 1.0.18:
+		* Make use of NAPI (Harald Welte)
+
 	TODO:
 	* big endian support with CFG:BEM instead of cpu_to_le32
 	* support for an external PHY
-	* NAPI
 */
=20
 #include <linux/config.h>
@@ -166,8 +169,8 @@
 #include <asm/uaccess.h>
=20
 #define DRV_NAME	"natsemi"
-#define DRV_VERSION	"1.07+LK1.0.17"
-#define DRV_RELDATE	"Sep 27, 2002"
+#define DRV_VERSION	"1.07+LK1.0.18"
+#define DRV_RELDATE	"Sep 18, 2004"
=20
 #define RX_OFFSET	2
=20
@@ -183,8 +186,6 @@
 				 NETIF_MSG_TX_ERR)
 static int debug =3D -1;
=20
-/* Maximum events (Rx packets, etc.) to handle at each interrupt. */
-static int max_interrupt_work =3D 20;
 static int mtu;
=20
 /* Maximum number of multicast addresses to filter (vs. rx-all-multicast).
@@ -251,14 +252,11 @@
 MODULE_DESCRIPTION("National Semiconductor DP8381x series PCI Ethernet dri=
ver");
 MODULE_LICENSE("GPL");
=20
-MODULE_PARM(max_interrupt_work, "i");
 MODULE_PARM(mtu, "i");
 MODULE_PARM(debug, "i");
 MODULE_PARM(rx_copybreak, "i");
 MODULE_PARM(options, "1-" __MODULE_STRING(MAX_UNITS) "i");
 MODULE_PARM(full_duplex, "1-" __MODULE_STRING(MAX_UNITS) "i");
-MODULE_PARM_DESC(max_interrupt_work,=20
-	"DP8381x maximum events handled per interrupt");
 MODULE_PARM_DESC(mtu, "DP8381x MTU (all boards)");
 MODULE_PARM_DESC(debug, "DP8381x default debug level");
 MODULE_PARM_DESC(rx_copybreak,=20
@@ -416,8 +414,12 @@
 	StatsCtrl		=3D 0x5C,
 	StatsData		=3D 0x60,
 	RxPktErrs		=3D 0x60,
-	RxMissed		=3D 0x68,
 	RxCRCErrs		=3D 0x64,
+	RxMissed		=3D 0x68,
+	RxFAErrors		=3D 0x6C,
+	RxSymbolErrors		=3D 0x70,
+	RxFrameTooLong		=3D 0x74,
+	TxSQEErrors		=3D 0x78,
 	BasicControl		=3D 0x80,
 	BasicStatus		=3D 0x84,
 	AnegAdv			=3D 0x90,
@@ -769,6 +771,20 @@
 static int netdev_get_regs(struct net_device *dev, u8 *buf);
 static int netdev_get_eeprom(struct net_device *dev, u8 *buf);
=20
+static inline void natsemi_irq_enable(struct netdev_private *np)
+{
+	/* Enable interrupts by setting the interrupt mask. */
+	writel(DEFAULT_INTR, np->base_addr + IntrMask);
+	writel(1, np->base_addr + IntrEnable);
+	mb();
+}
+
+static inline void natsemi_irq_disable(struct netdev_private *np)
+{
+	writel(0, np->base_addr + IntrEnable);
+	mb();
+}
+
 static void move_int_phy(struct net_device *dev, int addr)
 {
 	struct netdev_private *np =3D netdev_priv(dev);
@@ -923,6 +939,11 @@
 	dev->do_ioctl =3D &netdev_ioctl;
 	dev->tx_timeout =3D &tx_timeout;
 	dev->watchdog_timeo =3D TX_TIMEOUT;
+#ifdef CONFIG_NATSEMI_NAPI
+	dev->poll =3D natsemi_clean;
+	dev->weight =3D 64;
+#endif
+
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	dev->poll_controller =3D &natsemi_poll_controller;
 #endif
@@ -2135,6 +2156,62 @@
 	}
 }
=20
+/* the second half of the interrupt handler, used for NAPI and non-NAPI pa=
th */
+#ifdef CONFIG_NATSEMI_NAPI
+static int intr_handler2(struct net_device *dev, int *work_done, int work_=
to_do)
+#else
+static int intr_handler2(struct net_device *dev)
+#endif
+{
+	struct netdev_private *np =3D netdev_priv(dev);
+	long ioaddr =3D dev->base_addr;
+	int boguscnt =3D max_interrupt_work;
+
+	/* Reading automatically acknowledges all int sources. */
+	u32 intr_status =3D readl(ioaddr + IntrStatus);
+
+	if (np->hands_off)
+		return 0;
+
+	if (intr_status =3D=3D 0)
+		return 0;
+
+	if (netif_msg_intr(np))
+		printk(KERN_DEBUG
+			"%s: Interrupt, status %#08x, mask %#08x.\n",
+			dev->name, intr_status,
+			readl(ioaddr + IntrMask));
+
+	/* Abnormal error summary/uncommon events handlers. */
+	if (intr_status & IntrAbnormalSummary)
+		netdev_error(dev, intr_status);
+
+	if (intr_status &
+	   (IntrTxDone | IntrTxIntr | IntrTxIdle | IntrTxErr)) {
+		spin_lock(&np->lock);
+		netdev_tx_done(dev);
+		spin_unlock(&np->lock);
+	}
+
+	if (intr_status &
+	   (IntrRxDone | IntrRxIntr | RxStatusFIFOOver |
+	    IntrRxErr | IntrRxOverrun)) {
+#ifdef CONFIG_NATSEMI_NAPI
+		netdev_rx(dev, work_done, work_to_do);
+#else
+		netdev_rx(dev);
+#endif
+	}
+	/* FIXME: if quota not yet fulfilled, read status and restart
+	 * from top if non-null */
+
+	if (netif_msg_intr(np))
+		printk(KERN_DEBUG "%s: exiting interrupt.\n", dev->name);
+
+	return 1;
+}
+
+
 /* The interrupt handler does all of the Rx thread work and cleans up
    after the Tx thread. */
 static irqreturn_t intr_handler(int irq, void *dev_instance, struct pt_reg=
s *rgs)
@@ -2143,60 +2220,55 @@
 	struct netdev_private *np =3D netdev_priv(dev);
 	long ioaddr =3D dev->base_addr;
 	int boguscnt =3D max_interrupt_work;
-	unsigned int handled =3D 0;
=20
-	if (np->hands_off)
+#ifdef CONFIG_NATSEMI_NAPI
+	if (n->hands_off)=20
 		return IRQ_NONE;
-	do {
-		/* Reading automatically acknowledges all int sources. */
-		u32 intr_status =3D readl(ioaddr + IntrStatus);
=20
-		if (netif_msg_intr(np))
-			printk(KERN_DEBUG
-				"%s: Interrupt, status %#08x, mask %#08x.\n",
-				dev->name, intr_status,
-				readl(ioaddr + IntrMask));
-
-		if (intr_status =3D=3D 0)
-			break;
-		handled =3D 1;
-
-		if (intr_status &
-		   (IntrRxDone | IntrRxIntr | RxStatusFIFOOver |
-		    IntrRxErr | IntrRxOverrun)) {
-			netdev_rx(dev);
-		}
+	/* We cannot read IntrStatus since this would acknowledge
+	 * all interrupt sources. Thus we just blindly assume that
+	 * the interrupt really was for us -HW! */
+
+	if (netif_schedule_prep(dev)) {
+		/* Disable interrupts and register for poll */
+		natsemi_irq_disable(np);
+		__netif_rx_schedule(dev);
+	}
+	/* FIXME: IRQ_NONE since we're not sure whether it was for us ?  */=20
+	return IRQ_HANDLED;
+#else
+	return IRQ_RETVAL(intr_handler2(dev));
+#endif
+}
=20
-		if (intr_status &
-		   (IntrTxDone | IntrTxIntr | IntrTxIdle | IntrTxErr)) {
-			spin_lock(&np->lock);
-			netdev_tx_done(dev);
-			spin_unlock(&np->lock);
-		}
+#ifdef CONFIG_NATSEMI_NAPI
+static int natsemi_clean(struct net_device *dev, int *budget)
+{
+	struct netdev_private *np =3D netdev_priv(dev);
+	int work_to_do =3D min(*budget, dev->quota);
+	int work_done =3D 0;
+=09
+	intr_handler2(dev, &work_done, work_to_do);
=20
-		/* Abnormal error summary/uncommon events handlers. */
-		if (intr_status & IntrAbnormalSummary)
-			netdev_error(dev, intr_status);
-
-		if (--boguscnt < 0) {
-			if (netif_msg_intr(np))
-				printk(KERN_WARNING
-					"%s: Too much work at interrupt, "
-					"status=3D%#08x.\n",
-					dev->name, intr_status);
-			break;
-		}
-	} while (1);
+	*budget -=3D work_done;
+	dev->quota -=3D work_done;
=20
-	if (netif_msg_intr(np))
-		printk(KERN_DEBUG "%s: exiting interrupt.\n", dev->name);
+	if (work_done < work_to_do || !netif_running(dev)) {
+		netif_rx_complete(dev);
+		natsemi_irq_enable(np);
+	}
=20
-	return IRQ_RETVAL(handled);
+	return (work_done >=3D work_to_do);
 }
+#endif
=20
 /* This routine is logically part of the interrupt handler, but separated
    for clarity and better register allocation. */
+#ifdef CONFIG_NATSEMI_NAPI
+static void netdev_rx(struct net_device *dev, int *work_done, int work_to_=
do)
+#else
 static void netdev_rx(struct net_device *dev)
+#endif
 {
 	struct netdev_private *np =3D netdev_priv(dev);
 	int entry =3D np->cur_rx % RX_RING_SIZE;
@@ -2213,6 +2285,14 @@
 				entry, desc_status);
 		if (--boguscnt < 0)
 			break;
+
+#ifdef CONFIG_NATSEMI_NAPI
+		if (*work_done >=3D work_to_do)
+			break;
+
+		(*work_done)++;
+#endif
+
 		pkt_len =3D (desc_status & DescSizeMask) - 4;
 		if ((desc_status&(DescMore|DescPktOK|DescRxLong)) !=3D DescPktOK){
 			if (desc_status & DescMore) {
@@ -2269,7 +2349,11 @@
 				np->rx_skbuff[entry] =3D NULL;
 			}
 			skb->protocol =3D eth_type_trans(skb, dev);
+#ifdef CONFIG_NATSEMI_NAPI
+			netif_receive_skb(skb);
+#else
 			netif_rx(skb);
+#endif
 			dev->last_rx =3D jiffies;
 			np->stats.rx_packets++;
 			np->stats.rx_bytes +=3D pkt_len;
@@ -2355,6 +2439,7 @@
 	/* The chip only need report frame silently dropped. */
 	np->stats.rx_crc_errors	+=3D readl(ioaddr + RxCRCErrs);
 	np->stats.rx_missed_errors +=3D readl(ioaddr + RxMissed);
+	np->stats.tx_heartbeat_errors +=3D readl(ioaddr + TxSQEErrors);
 }
=20
 static struct net_device_stats *get_stats(struct net_device *dev)
--=20
- Harald Welte <laforge@gnumonks.org>               http://www.gnumonks.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
Programming is like sex: One mistake and you have to support it your lifeti=
me

--7a4X6VOqfbl9xMrG
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFBTuTWXaXGVTD0i/8RAhnyAKCASZMtVXewYeVhx2D6mVNzY3EeAwCfVmk5
4TwUC422cPGaPMzYamdEzFI=
=pegq
-----END PGP SIGNATURE-----

--7a4X6VOqfbl9xMrG--
