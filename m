From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH RFC] r8169: straighten out overlength frame detection
Date: Mon, 28 Dec 2009 20:20:46 -0500
Message-ID: <20091229012046.GD7037@localhost.localdomain>
References: <20091228194834.GA18422@hmsreliant.think-freely.org>
 <20091228195053.GB18422@hmsreliant.think-freely.org>
 <20091228213114.GA24285@zoreil.com>
 <1262046291.8998.6.camel@obelisk.thedillows.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?iso-8859-1?Q?Fran=E7ois?= romieu <romieu@zoreil.com>,
	netdev@vger.kernel.org, davem@davemloft.net,
	eric.dumazet@gmail.com, nhorman@redhat.com
To: David Dillow <dave@thedillows.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:33102 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751700AbZL2BUy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Dec 2009 20:20:54 -0500
Content-Disposition: inline
In-Reply-To: <1262046291.8998.6.camel@obelisk.thedillows.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 28, 2009 at 07:24:51PM -0500, David Dillow wrote:
> On Mon, 2009-12-28 at 22:31 +0100, Fran=E7ois romieu wrote:
> > (I'm back)
> >=20
> > The Mon, Dec 28, 2009 at 02:50:53PM -0500, Neil Horman wrote :
> > [...]
> > I doubt that we will be able to allocate that much memory reliably =
for long.
> >=20
> > I'd rather go for static buffers + copy (+ src mac address of our n=
ew friend).
>=20
> The driver doesn't support fragmented receives, but it seems like the=
 HW
> does -- is this known to work on the different revisions? Or
> alternatively, is it known to be broken on any of them? It seems like=
 it
> would be preferable to implement this and use RxMaxSize to tell the N=
IC
> how big the allocated buffer fragments are.
>=20
> Or I'm misreading the capabilities of the NIC?
>=20
> In any event, I'm probably not going to have time to write/test it on
> the HW I have anytime soon, so perhaps the static buffers/copy is the
> safest option for now, albeit non-optimal.
>=20
Agreed, very non-optimal, but the only safe solution, if the rx size re=
gister
can't be trusted. =20

What about this solution?  Its the same as before, but it takes Francoi=
s'
thoughts into account.  It ups the default copybreak value to 16383 so =
that all
the recevied frames should succede in try_rx_copy.  Again, completely u=
ntested,
but it compiles.  If theres some way to identify hardware subclasses th=
at are
affected by this issues, you can restrict the affect by chaning the RxM=
axSize
and copybreak in the probe routine.

Regards
Neil

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>


 r8169.c |   13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)


diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 60f96c4..c4e331c 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -63,6 +63,7 @@ static const int multicast_filter_limit =3D 32;
 #define RX_DMA_BURST	6	/* Maximum PCI burst, '6' is 1024 */
 #define TX_DMA_BURST	6	/* Maximum PCI burst, '6' is 1024 */
 #define EarlyTxThld	0x3F	/* 0x3F means NO early transmit */
+#define RxPacketMaxSize	0x3FE8	/* 16K - 1 - ETH_HLEN - VLAN - CRC... *=
/
 #define SafeMtu		0x1c20	/* ... actually life sucks beyond ~7k */
 #define InterFrameGap	0x03	/* 3 means InterFrameGap =3D the shortest o=
ne */
=20
@@ -186,7 +187,7 @@ static struct pci_device_id rtl8169_pci_tbl[] =3D {
=20
 MODULE_DEVICE_TABLE(pci, rtl8169_pci_tbl);
=20
-static int rx_copybreak =3D 200;
+static int rx_copybreak =3D 16383;
 static int use_dac;
 static struct {
 	u32 msg_enable;
@@ -3383,7 +3384,7 @@ static u16 rtl_rw_cpluscmd(void __iomem *ioaddr)
 static void rtl_set_rx_max_size(void __iomem *ioaddr, unsigned int rx_=
buf_sz)
 {
 	/* Low hurts. Let's disable the filtering. */
-	RTL_W16(RxMaxSize, rx_buf_sz + 1);
+	RTL_W16(RxMaxSize, 16383);
 }
=20
 static void rtl8169_set_magic_reg(void __iomem *ioaddr, unsigned mac_v=
ersion)
@@ -3430,7 +3431,7 @@ static void rtl_hw_start_8169(struct net_device *=
dev)
=20
 	RTL_W8(EarlyTxThres, EarlyTxThld);
=20
-	rtl_set_rx_max_size(ioaddr, tp->rx_buf_sz);
+	rtl_set_rx_max_size(ioaddr, 16383);
=20
 	if ((tp->mac_version =3D=3D RTL_GIGA_MAC_VER_01) ||
 	    (tp->mac_version =3D=3D RTL_GIGA_MAC_VER_02) ||
@@ -3691,7 +3692,7 @@ static void rtl_hw_start_8168(struct net_device *=
dev)
=20
 	RTL_W8(EarlyTxThres, EarlyTxThld);
=20
-	rtl_set_rx_max_size(ioaddr, tp->rx_buf_sz);
+	rtl_set_rx_max_size(ioaddr, 16383);
=20
 	tp->cp_cmd |=3D RTL_R16(CPlusCmd) | PktCntrDisable | INTT_1;
=20
@@ -3871,7 +3872,7 @@ static void rtl_hw_start_8101(struct net_device *=
dev)
=20
 	RTL_W8(EarlyTxThres, EarlyTxThld);
=20
-	rtl_set_rx_max_size(ioaddr, tp->rx_buf_sz);
+	rtl_set_rx_max_size(ioaddr, 16383);
=20
 	tp->cp_cmd |=3D rtl_rw_cpluscmd(ioaddr) | PCIMulRW;
=20
@@ -3972,7 +3973,7 @@ static struct sk_buff *rtl8169_alloc_rx_skb(struc=
t pci_dev *pdev,
=20
 	pad =3D align ? align : NET_IP_ALIGN;
=20
-	skb =3D netdev_alloc_skb(dev, rx_buf_sz + pad);
+	skb =3D netdev_alloc_skb(dev, 16383 + pad);
 	if (!skb)
 		goto err_out;
=20
