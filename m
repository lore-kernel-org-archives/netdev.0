From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH RFC] r8169: straighten out overlength frame detection
Date: Tue, 29 Dec 2009 10:35:11 -0500
Message-ID: <20091229153511.GA15442@hmsreliant.think-freely.org>
References: <20091228194834.GA18422@hmsreliant.think-freely.org>
 <20091228195053.GB18422@hmsreliant.think-freely.org>
 <20091228213114.GA24285@zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	eric.dumazet@gmail.com, nhorman@redhat.com
To: =?iso-8859-1?Q?Fran=E7ois?= romieu <romieu@zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:33138 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753466AbZL2PfT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Dec 2009 10:35:19 -0500
Content-Disposition: inline
In-Reply-To: <20091228213114.GA24285@zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 28, 2009 at 10:31:14PM +0100, Fran=E7ois romieu wrote:
> (I'm back)
>=20
> The Mon, Dec 28, 2009 at 02:50:53PM -0500, Neil Horman wrote :
> [...]
> > frames were received on NIC's supported by this driver.  This was m=
entioned in a
> > security conference recently:
> > http://events.ccc.de/congress/2009/Fahrplan//events/3596.en.html
>=20
> Is there a paper ?
>=20
> > It seems that if we can't enable frame size filtering, then, as Eri=
c correctly
> > noticed, we can find ourselves DMA-ing too much data to a buffer, c=
ausing
> > corruption.  As a result is seems that we are forced to allocate a =
frame which
> > is ready to handle a maximally sized receive.
>=20
> Either that or the switch does not allow jumbo frames.
>=20
> > I've not tested the below patch at all, and clearly it stinks to ha=
ve to do.
> > But I thought it would be worth posting to solicit comments on it.
> [...]
> > diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
> > index 60f96c4..42e3b22 100644
> > --- a/drivers/net/r8169.c
> > +++ b/drivers/net/r8169.c
> > @@ -3972,7 +3973,7 @@ static struct sk_buff *rtl8169_alloc_rx_skb(s=
truct pci_dev *pdev,
> > =20
> >  	pad =3D align ? align : NET_IP_ALIGN;
> > =20
> > -	skb =3D netdev_alloc_skb(dev, rx_buf_sz + pad);
> > +	skb =3D netdev_alloc_skb(dev, 16383 + pad);
>=20
> I doubt that we will be able to allocate that much memory reliably fo=
r long.
>=20
> I'd rather go for static buffers + copy (+ src mac address of our new=
 friend).
>=20
> Is it enough if I write it in a pair of evening ?
>=20
> --=20
> Ueimor
>=20

Sorry for the noise, but I'm juggling this and family visits at the sam=
e time
over the hollidays :)

It just occured to me that this would be a much easier way to fix this =
issue,
than what I had previously posted.  Instead of reverting Erics patch, w=
e just
set rx_buf_sz and copybreak to 16383.  That should force the behavior w=
e're
after, and it can easily be tuned for hw that works properly in set_rx_=
max_buf

Regards
Neil

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>


 r8169.c |   20 +++++++++++++++-----
 1 file changed, 15 insertions(+), 5 deletions(-)


diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 60f96c4..cba3966 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -186,7 +186,12 @@ static struct pci_device_id rtl8169_pci_tbl[] =3D =
{
=20
 MODULE_DEVICE_TABLE(pci, rtl8169_pci_tbl);
=20
-static int rx_copybreak =3D 200;
+/*
+ * copybreak default is set here so that we
+ * can copy frames rather than needing to constantly
+ * reallocate 4 page skbs
+ */
+static int rx_copybreak =3D 16383;
 static int use_dac;
 static struct {
 	u32 msg_enable;
@@ -3247,9 +3252,14 @@ static void __devexit rtl8169_remove_one(struct =
pci_dev *pdev)
 static void rtl8169_set_rxbufsize(struct rtl8169_private *tp,
 				  struct net_device *dev)
 {
-	unsigned int max_frame =3D dev->mtu + VLAN_ETH_HLEN + ETH_FCS_LEN;
-
-	tp->rx_buf_sz =3D (max_frame > RX_BUF_SIZE) ? max_frame : RX_BUF_SIZE=
;
+	/*
+	 * Note: Don't touch this.  Some r8169 hw
+	 * Can't deliver a proper frame length
+	 * if rx filtering is enabled, so we need to=20
+	 * disable it, which in turn means we need to
+	 * be ready to receive maximally sized frames
+	 */
+	tp->rx_buf_sz =3D 16383;
 }
=20
 static int rtl8169_open(struct net_device *dev)
@@ -3383,7 +3393,7 @@ static u16 rtl_rw_cpluscmd(void __iomem *ioaddr)
 static void rtl_set_rx_max_size(void __iomem *ioaddr, unsigned int rx_=
buf_sz)
 {
 	/* Low hurts. Let's disable the filtering. */
-	RTL_W16(RxMaxSize, rx_buf_sz + 1);
+	RTL_W16(RxMaxSize, (rx_buf_sz =3D=3D 16383) ? rx_buf_sz : rx_buf_sz +=
 1);
 }
=20
 static void rtl8169_set_magic_reg(void __iomem *ioaddr, unsigned mac_v=
ersion)
