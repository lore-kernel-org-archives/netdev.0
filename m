From: Rask Ingemann Lambertsen <rask@sygehus.dk>
Subject: Re: [PATCH] [EXPERIMENTAL] 2.6: de2104x.c jumbo frames, take two
Date: Sat, 10 Jan 2004 14:47:38 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040110144738.A1385@sygehus.dk>
References: <20040110003304.A3788@sygehus.dk>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="zhXaljGHf11kAtnf"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, linux-net@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <20040110003304.A3788@sygehus.dk>; from rask@sygehus.dk on Sat, Jan 10, 2004 at 12:33:07AM +0100
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--zhXaljGHf11kAtnf
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Sat, Jan 10, 2004 at 12:33:07AM +0100, Rask Ingemann Lambertsen wrote:
> Hi.
> 
> Attached is a patch which enables jumbo frames on DS2104x based boards.

And then I forgot to include the patch. :-(

Regards,
Rask Ingemann Lambertsen

--zhXaljGHf11kAtnf
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: attachment; filename="de2104x-mtu.patch"
Content-Transfer-Encoding: quoted-printable
X-MIME-Autoconverted: from 8bit to quoted-printable by oss.sgi.com id i0ADnBTa012005

--- linux-2.6.0/drivers/net/tulip/de2104x.c-f=F8r-mtu	Sun Dec 21 14:31:04=
 2003
+++ linux-2.6.0/drivers/net/tulip/de2104x.c	Mon Jan  5 02:01:15 2004
@@ -19,7 +19,6 @@
 	  like dl2k.c/sundance.c
 	* Constants (module parms?) for Rx work limit
 	* Complete reset on PciErr
-	* Jumbo frames / dev->change_mtu
 	* Adjust Rx FIFO threshold and Max Rx DMA burst on Rx FIFO error
 	* Adjust Tx FIFO threshold and Max Tx DMA burst on Tx FIFO error
 	* Implement Tx software interrupt mitigation via
@@ -36,6 +35,7 @@
 #include <linux/kernel.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
+#include <linux/if_vlan.h>
 #include <linux/init.h>
 #include <linux/pci.h>
 #include <linux/delay.h>
@@ -67,11 +67,15 @@ static int debug =3D -1;
 MODULE_PARM (debug, "i");
 MODULE_PARM_DESC (debug, "de2104x bitmapped message enable number");
=20
+/* Each descriptor has two buffers. */
+#define DESC_BUF_SZ_MAX		2044
+#define PKT_BUF_SZ_MAX		4088	/* Maximum Rx buffer size. */
+
 /* Set the copy breakpoint for the copy-only-tiny-buffer Rx structure. *=
/
 #if defined(__alpha__) || defined(__arm__) || defined(__hppa__) \
         || defined(__sparc_) || defined(__ia64__) \
         || defined(__sh__) || defined(__mips__)
-static int rx_copybreak =3D 1518;
+static int rx_copybreak =3D PKT_BUF_SZ_MAX;
 #else
 static int rx_copybreak =3D 100;
 #endif
@@ -356,12 +360,12 @@ static const char * const media_name[DE_
  * TP AUTO(unused), BNC(unused), AUI, TP, TP FD*/
 static u16 t21040_csr13[] =3D { 0, 0, 0x8F09, 0x8F01, 0x8F01, };
 static u16 t21040_csr14[] =3D { 0, 0, 0x0705, 0xFFFF, 0xFFFD, };
-static u16 t21040_csr15[] =3D { 0, 0, 0x0006, 0x0000, 0x0000, };
+static u16 t21040_csr15[] =3D { 0, 0, 0x0017, 0x0011, 0x0011, };
=20
 /* 21041 transceiver register settings: TP AUTO, BNC, AUI, TP, TP FD*/
 static u16 t21041_csr13[] =3D { 0xEF01, 0xEF09, 0xEF09, 0xEF01, 0xEF09, =
};
 static u16 t21041_csr14[] =3D { 0xFFFF, 0xF7FD, 0xF7FD, 0x6F3F, 0x6F3D, =
};
-static u16 t21041_csr15[] =3D { 0x0008, 0x0006, 0x000E, 0x0008, 0x0008, =
};
+static u16 t21041_csr15[] =3D { 0x0019, 0x0017, 0x001F, 0x0019, 0x0019, =
};
=20
=20
 static inline unsigned long
@@ -374,6 +378,12 @@ msec_to_jiffies(unsigned long ms)
 #define dr32(reg)		readl(de->regs + (reg))
 #define dw32(reg,val)		writel((val), de->regs + (reg))
=20
+static inline u32 opts2_sizes (uint total_size)
+{
+	if (total_size <=3D DESC_BUF_SZ_MAX)
+		return (total_size);
+	return (((total_size - DESC_BUF_SZ_MAX) << 11) | DESC_BUF_SZ_MAX);
+}
=20
 static void de_rx_err_acct (struct de_private *de, unsigned rx_tail,
 			    u32 status, u32 len)
@@ -422,7 +432,9 @@ static void de_rx (struct de_private *de
 		if (status & DescOwn)
 			break;
=20
-		len =3D ((status >> 16) & 0x7ff) - 4;
+		len =3D ((status >> 16) & 0x3fff) - 4;
+		if ((len <=3D 1514) && (status & RxErrLong))
+			len +=3D 2048;
 		mapping =3D de->rx_skb[rx_tail].mapping;
=20
 		if (unlikely(drop)) {
@@ -430,7 +442,7 @@ static void de_rx (struct de_private *de
 			goto rx_next;
 		}
=20
-		if (unlikely((status & 0x38008300) !=3D 0x0300)) {
+		if (unlikely((status & 0x38004b53) !=3D 0x0300)) {
 			de_rx_err_acct(de, rx_tail, status, len);
 			goto rx_next;
 		}
@@ -483,11 +495,13 @@ static void de_rx (struct de_private *de
 rx_next:
 		de->rx_ring[rx_tail].opts1 =3D cpu_to_le32(DescOwn);
 		if (rx_tail =3D=3D (DE_RX_RING_SIZE - 1))
-			de->rx_ring[rx_tail].opts2 =3D
-				cpu_to_le32(RingEnd | de->rx_buf_sz);
+			de->rx_ring[rx_tail].opts2 =3D cpu_to_le32(
+				RingEnd | opts2_sizes (de->rx_buf_sz));
 		else
-			de->rx_ring[rx_tail].opts2 =3D cpu_to_le32(de->rx_buf_sz);
+			de->rx_ring[rx_tail].opts2 =3D cpu_to_le32(
+				opts2_sizes (de->rx_buf_sz));
 		de->rx_ring[rx_tail].addr1 =3D cpu_to_le32(mapping);
+		de->rx_ring[rx_tail].addr2 =3D cpu_to_le32(mapping + DESC_BUF_SZ_MAX);
 		rx_tail =3D NEXT_RX(rx_tail);
 	}
=20
@@ -632,9 +646,10 @@ static int de_start_xmit (struct sk_buff
 		flags |=3D RingEnd;
 	if (!tx_free || (tx_free =3D=3D (DE_TX_RING_SIZE / 2)))
 		flags |=3D TxSwInt;
-	flags |=3D len;
+	flags |=3D opts2_sizes (len);
 	txd->opts2 =3D cpu_to_le32(flags);
 	txd->addr1 =3D cpu_to_le32(mapping);
+	txd->addr2 =3D cpu_to_le32(mapping + DESC_BUF_SZ_MAX);
=20
 	de->tx_skb[entry].skb =3D skb;
 	de->tx_skb[entry].mapping =3D mapping;
@@ -770,6 +785,7 @@ static void __de_set_rx_mode (struct net
 		dummy_txd->opts2 =3D (entry =3D=3D (DE_TX_RING_SIZE - 1)) ?
 				   cpu_to_le32(RingEnd) : 0;
 		dummy_txd->addr1 =3D 0;
+		dummy_txd->addr2 =3D 0;
=20
 		/* Must set DescOwned later to avoid race with chip */
=20
@@ -788,6 +804,7 @@ static void __de_set_rx_mode (struct net
 	else
 		txd->opts2 =3D cpu_to_le32(SetupFrame | sizeof (de->setup_frame));
 	txd->addr1 =3D cpu_to_le32(mapping);
+	txd->addr2 =3D cpu_to_le32(0);
 	wmb();
=20
 	txd->opts1 =3D cpu_to_le32(DescOwn);
@@ -1277,7 +1294,9 @@ static int de_init_hw (struct de_private
 static int de_refill_rx (struct de_private *de)
 {
 	unsigned i;
+	u32 opts2;
=20
+	opts2 =3D opts2_sizes (de->rx_buf_sz);
 	for (i =3D 0; i < DE_RX_RING_SIZE; i++) {
 		struct sk_buff *skb;
=20
@@ -1294,11 +1313,11 @@ static int de_refill_rx (struct de_priva
 		de->rx_ring[i].opts1 =3D cpu_to_le32(DescOwn);
 		if (i =3D=3D (DE_RX_RING_SIZE - 1))
 			de->rx_ring[i].opts2 =3D
-				cpu_to_le32(RingEnd | de->rx_buf_sz);
+				cpu_to_le32(RingEnd | opts2);
 		else
-			de->rx_ring[i].opts2 =3D cpu_to_le32(de->rx_buf_sz);
+			de->rx_ring[i].opts2 =3D cpu_to_le32(opts2);
 		de->rx_ring[i].addr1 =3D cpu_to_le32(de->rx_skb[i].mapping);
-		de->rx_ring[i].addr2 =3D 0;
+		de->rx_ring[i].addr2 =3D cpu_to_le32(de->rx_skb[i].mapping + DESC_BUF_=
SZ_MAX);
 	}
=20
 	return 0;
@@ -1386,6 +1405,8 @@ static int de_open (struct net_device *d
 		printk(KERN_DEBUG "%s: enabling interface\n", dev->name);
=20
 	de->rx_buf_sz =3D (dev->mtu <=3D 1500 ? PKT_BUF_SZ : dev->mtu + 32);
+	if (de->rx_buf_sz > PKT_BUF_SZ_MAX)
+		de->rx_buf_sz =3D PKT_BUF_SZ_MAX;
=20
 	rc =3D de_alloc_rings(de);
 	if (rc) {
@@ -1476,6 +1497,18 @@ static void de_tx_timeout (struct net_de
 	netif_wake_queue(dev);
 }
=20
+static int de_change_mtu (struct net_device *dev, int mtu)
+{
+	if (netif_running (dev))
+		return (-EBUSY);
+
+	if (mtu < 0 || mtu > PKT_BUF_SZ_MAX - VLAN_ETH_HLEN - 4)
+		return (-EINVAL);
+
+	dev->mtu =3D mtu;
+	return (0);
+}
+
 static void __de_get_regs(struct de_private *de, u8 *buf)
 {
 	int i;
@@ -1980,6 +2013,7 @@ static int __devinit de_init_one (struct
 	dev->ethtool_ops =3D &de_ethtool_ops;
 	dev->tx_timeout =3D de_tx_timeout;
 	dev->watchdog_timeo =3D TX_TIMEOUT;
+	dev->change_mtu =3D de_change_mtu;
=20
 	dev->irq =3D pdev->irq;
=20

--zhXaljGHf11kAtnf--
