From: Harald Welte <laforge@gnumonks.org>
Subject: [PATCH 2.6] Add NAPI support to sungem.c
Date: Tue, 14 Sep 2004 17:35:37 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040914153537.GE8434@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="NctWKJLgDreUm1FS"
Cc: netdev@oss.sgi.com, linuxppc-dev@lists.linuxppc.org
Return-path: <netdev-bounce@oss.sgi.com>
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--NctWKJLgDreUm1FS
Content-Type: multipart/mixed; boundary="I/+EtO164iqGPpU0"
Content-Disposition: inline


--I/+EtO164iqGPpU0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dave!

Please find the attached patch to add NAPI support to the sungem.c
driver (I was annoyed by the fact the pktgen could kill my Powerbook).

Since this is my first hack of a network driver within at least 5 years,
please be kind with me and point me to all the locking bugs and other
mistakes ;)

Any comments welcome,

	Harald

--=20
- Harald Welte <laforge@gnumonks.org>               http://www.gnumonks.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
Programming is like sex: One mistake and you have to support it your lifeti=
me

--I/+EtO164iqGPpU0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="linux-2.6.9-rc1-sungem-napi-0.01.patch"
Content-Transfer-Encoding: quoted-printable

diff -Nru linux-2.6.8.1-davem269_4/drivers/net/Kconfig linux-2.6.8.1-davem2=
69_4-sungem-napi/drivers/net/Kconfig
--- linux-2.6.8.1-davem269_4/drivers/net/Kconfig	2004-08-14 12:56:00.000000=
000 +0200
+++ linux-2.6.8.1-davem269_4-sungem-napi/drivers/net/Kconfig	2004-09-14 11:=
40:40.000000000 +0200
@@ -569,6 +569,22 @@
 	help
 	  Support for the Sun GEM chip, aka Sun GigabitEthernet/P 2.0.  See also
 	  <http://www.sun.com/products-n-solutions/hardware/docs/pdf/806-3985-10.=
pdf>.
+config SUNGEM_NAPI
+	bool "Use Rx Polling (NAPI) (EXPERIMENTAL)"
+	depends on SUNGEM && EXPERIMENTAL
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
 config NET_VENDOR_3COM
 	bool "3COM cards"
--- linux-2.6.8-rc2-nfpending-tcpwin/drivers/net/sungem.c	2004-07-22 17:48:=
43.000000000 +0200
+++ linux-2.6.8-rc2-nfpending-tcpwin-napi/drivers/net/sungem.c	2004-09-13 1=
5:48:17.299866224 +0200
@@ -5,6 +5,9 @@
  *=20
  * Support for Apple GMAC and assorted PHYs by
  * Benjamin Herrenscmidt (benh@kernel.crashing.org)
+ *
+ * Support for NAPI and NETPOLL=20
+ * 	(C) 2004 by Harald Welte <laforge@gnumonks.org>
  *=20
  * TODO:=20
  *  - Get rid of all those nasty mdelay's and replace them
@@ -187,6 +190,26 @@
 		printk(KERN_DEBUG "%s: mif interrupt\n", gp->dev->name);
 }
=20
+static inline void
+gem_irq_disable(struct gem *gp)
+{
+	/* Make sure we won't get any more interrupts */
+	writel(0xffffffff, gp->regs + GREG_IMASK);
+}
+
+static inline void
+gem_irq_enable(struct gem *gp, unsigned int mask)
+{
+	/* We don't want TXDONE, but all other interrupts */
+	writel(mask, gp->regs + GREG_IMASK);
+}
+
+static inline void
+gem_irq_acknowledge(struct gem *gp, unsigned int mask)
+{
+	writel(mask, gp->regs + GREG_IACK);
+}
+
 static int gem_pcs_interrupt(struct net_device *dev, struct gem *gp, u32 g=
em_status)
 {
 	u32 pcs_istat =3D readl(gp->regs + PCS_ISTAT);
@@ -537,6 +560,7 @@
 			printk(KERN_DEBUG "%s: no buffer for rx frame\n",
 				gp->dev->name);
 		gp->net_stats.rx_dropped++;
+		gem_irq_acknowledge(gp, GREG_STAT_RXNOBUF);
 	}
=20
 	if (gem_status & GREG_STAT_RXTAGERR) {
@@ -545,6 +569,7 @@
 			printk(KERN_DEBUG "%s: corrupt rx tag framing\n",
 				gp->dev->name);
 		gp->net_stats.rx_errors++;
+		gem_irq_acknowledge(gp, GREG_STAT_RXTAGERR);
=20
 		goto do_reset;
 	}
@@ -596,6 +621,8 @@
 		printk(KERN_DEBUG "%s: tx interrupt, gem_status: 0x%x\n",
 			gp->dev->name, gem_status);
=20
+	gem_irq_acknowledge(gp, GREG_STAT_TXALL|GREG_STAT_TXINTME);
+
 	entry =3D gp->tx_old;
 	limit =3D ((gem_status & GREG_STAT_TXNR) >> GREG_STAT_TXNR_SHIFT);
 	while (entry !=3D limit) {
@@ -678,7 +705,11 @@
 	}
 }
=20
+#ifdef CONFIG_SUNGEM_NAPI
+static void gem_rx(struct gem *gp, int *work_done, int work_to_do)
+#else
 static void gem_rx(struct gem *gp)
+#endif
 {
 	int entry, drops;
 	u32 done;
@@ -687,6 +718,8 @@
 		printk(KERN_DEBUG "%s: rx interrupt, done: %d, rx_new: %d\n",
 			gp->dev->name, readl(gp->regs + RXDMA_DONE), gp->rx_new);
=20
+	gem_irq_acknowledge(gp, GREG_STAT_RXDONE);
+
 	entry =3D gp->rx_new;
 	drops =3D 0;
 	done =3D readl(gp->regs + RXDMA_DONE);
@@ -713,6 +746,11 @@
 				break;
 		}
=20
+#ifdef CONFIG_SUNGEM_NAPI
+		if (*work_done >=3D work_to_do)
+			break;
+
+#endif
 		skb =3D gp->rx_skbs[entry];
=20
 		len =3D (status & RXDCTRL_BUFSZ) >> 16;
@@ -775,7 +813,12 @@
 		skb->csum =3D ntohs((status & RXDCTRL_TCPCSUM) ^ 0xffff);
 		skb->ip_summed =3D CHECKSUM_HW;
 		skb->protocol =3D eth_type_trans(skb, gp->dev);
+#ifdef CONFIG_SUNGEM_NAPI
+		netif_receive_skb(skb);
+		(*work_done)++;
+#else
 		netif_rx(skb);
+#endif
=20
 		gp->net_stats.rx_packets++;
 		gp->net_stats.rx_bytes +=3D len;
@@ -798,7 +841,7 @@
 {
 	struct net_device *dev =3D dev_id;
 	struct gem *gp =3D dev->priv;
-	u32 gem_status =3D readl(gp->regs + GREG_STAT);
+	u32 gem_status =3D readl(gp->regs + GREG_STAT2);
=20
 	/* Swallow interrupts when shutting the chip down */
 	if (gp->hw_running =3D=3D 0)
@@ -810,10 +853,21 @@
 		if (gem_abnormal_irq(dev, gp, gem_status))
 			goto out;
 	}
+
 	if (gem_status & (GREG_STAT_TXALL | GREG_STAT_TXINTME))
 		gem_tx(dev, gp, gem_status);
-	if (gem_status & GREG_STAT_RXDONE)
+
+	if (gem_status & GREG_STAT_RXDONE) {
+#ifdef CONFIG_SUNGEM_NAPI
+		if (netif_rx_schedule_prep(dev)) {
+			/* Disable interrupts and register for poll */
+			gem_irq_disable(gp);
+			__netif_rx_schedule(dev);
+		}
+#else
 		gem_rx(gp);
+#endif
+	}
=20
 out:
 	spin_unlock(&gp->lock);
@@ -821,6 +875,29 @@
 	return IRQ_HANDLED;
 }
=20
+#ifdef CONFIG_SUNGEM_NAPI
+static int gem_clean(struct net_device *dev, int *budget)
+{
+	struct gem *gp =3D dev->priv;
+	int work_to_do =3D min(*budget, dev->quota);
+	int work_done =3D 0;
+	u32 gem_status =3D readl(gp->regs + GREG_STAT2);
+
+	if (gem_status & GREG_STAT_RXDONE)
+		gem_rx(gp, &work_done, work_to_do);
+
+	*budget -=3D work_done;
+	dev->quota -=3D work_done;
+
+	if (work_done < work_to_do || !netif_running(dev)) {
+		__netif_rx_complete(dev);
+		gem_irq_enable(gp, GREG_STAT_TXDONE);
+	}
+
+	return (work_done >=3D work_to_do);
+}
+#endif
+
 static void gem_tx_timeout(struct net_device *dev)
 {
 	struct gem *gp =3D dev->priv;
@@ -1018,7 +1096,7 @@
 	u32 val;
=20
 	/* Make sure we won't get any more interrupts */
-	writel(0xffffffff, gp->regs + GREG_IMASK);
+	gem_irq_disable(gp);
=20
 	/* Reset the chip */
 	writel(gp->swrst_base | GREG_SWRST_TXRST | GREG_SWRST_RXRST,
@@ -1055,7 +1133,7 @@
 	(void) readl(gp->regs + MAC_RXCFG);
 	udelay(100);
=20
-	writel(GREG_STAT_TXDONE, gp->regs + GREG_IMASK);
+	gem_irq_enable(gp, GREG_STAT_TXDONE);
=20
 	writel(RX_RING_SIZE - 4, gp->regs + RXDMA_KICK);
=20
@@ -1323,7 +1401,7 @@
 		/* Make sure we don't get interrupts or tx packets */
 		netif_stop_queue(gp->dev);
=20
-		writel(0xffffffff, gp->regs + GREG_IMASK);
+		gem_irq_disable(gp);
=20
 		/* Reset the chip & rings */
 		gem_stop(gp);
@@ -2220,7 +2298,7 @@
 	spin_lock_irq(&gp->lock);
=20
 	gp->opened =3D 0;=09
-	writel(0xffffffff, gp->regs + GREG_IMASK);
+	gem_irq_disable(gp);
 	netif_stop_queue(dev);
=20
 	/* Stop chip */
@@ -2264,7 +2342,7 @@
 		/* Stop traffic, mark us closed */
 		netif_device_detach(dev);
=20
-		writel(0xffffffff, gp->regs + GREG_IMASK);
+		gem_irq_disable(gp);
=20
 		/* Stop chip */
 		gem_stop(gp);
@@ -2651,6 +2729,16 @@
 	return 0;
 }
=20
+#ifdef CONFIG_NET_POLL_CONTROLLER
+static void gem_netpoll(struct net_device *dev)
+{
+	struct gem *gp =3D dev->priv;
+	disable_irq(gp->pdev->irq);
+	gem_interrupt(gp->pdev->irq, dev, NULL);
+	enable_irq(gp->pdev->irq);
+}
+#endif
+
 static int __devinit gem_init_one(struct pci_dev *pdev,
 				  const struct pci_device_id *ent)
 {
@@ -2811,6 +2899,15 @@
 	dev->ethtool_ops =3D &gem_ethtool_ops;
 	dev->tx_timeout =3D gem_tx_timeout;
 	dev->watchdog_timeo =3D 5 * HZ;
+#ifdef CONFIG_SUNGEM_NAPI
+	dev->poll =3D gem_clean;
+	dev->weight =3D 64;
+#endif
+
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	dev->poll_controller =3D gem_netpoll;
+#endif
+
 	dev->change_mtu =3D gem_change_mtu;
 	dev->irq =3D pdev->irq;
 	dev->dma =3D 0;

--I/+EtO164iqGPpU0--

--NctWKJLgDreUm1FS
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFBRw/JXaXGVTD0i/8RAqbWAJ9wQ63jfE1S7Hi0ob0GvoWfpphUwgCghcQ9
tBj2ztJLdaPem3fw6o/Yils=
=Z+UE
-----END PGP SIGNATURE-----

--NctWKJLgDreUm1FS--
