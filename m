From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH RFC] r8169: straighten out overlength frame detection
 (v3)
Date: Tue, 05 Jan 2010 16:15:53 +0100
Message-ID: <4B4357A9.5010507@gmail.com>
References: <20091228194834.GA18422@hmsreliant.think-freely.org> <20100105135732.GA24245@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, romieu@fr.zoreil.com
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:43265 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754450Ab0AEPQF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2010 10:16:05 -0500
In-Reply-To: <20100105135732.GA24245@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 05/01/2010 14:57, Neil Horman a =E9crit :
> Ok, third times the charm.  Its been noted that both apporaches to fi=
xing this
> bug are going to have major performance impacts, which is bad.  Unles=
s we can
> get a list of affected hardware to restrict the fix to certain NICS, =
I don't see
> how we can get around that.   I have come up with this patch however,=
 which I
> think at least partially addresses the performance concerns.
>=20
>         A while back Eric submitted a patch for r8169 in which the pr=
oper
> allocated frame size was written to RXMaxSize to prevent the NIC from=
 dmaing too
> much data.  This was done in commit fdd7b4c3302c93f6833e338903ea77245=
eb510b4.  A
> long time prior to that however, Francois posted
> 126fa4b9ca5d9d7cb7d46f779ad3bd3631ca387c, which expiclitly disabled t=
he MaxSize
> setting due to the fact that the hardware behaved in odd ways when ov=
erlong
> frames were received on NIC's supported by this driver.  This was men=
tioned in a
> security conference recently:
> http://events.ccc.de/congress/2009/Fahrplan//events/3596.en.html
>=20
> It seems that if we can't enable frame size filtering, then, as Eric =
correctly
> noticed, we can find ourselves DMA-ing too much data to a buffer, cau=
sing
> corruption.  As a result is seems that we are forced to allocate a fr=
ame which
> is ready to handle a maximally sized receive.
>=20
> This obviously has performance issues with it, so to mitigate that is=
sue, this
> patch does two things:
>=20
> 1) Raises the copybreak value to the frame allocation size, which sho=
uld force
> appropriately sized packets to get allocated on rx, rather than a ful=
l new 16k
> buffer.
>=20
> 2) This patch only disables frame filtering initially (i.e., during t=
he NIC
> open), changing the MTU results in ring buffer allocation of a size i=
n relation
> to the new mtu (along with a warning indicating that this is dangerou=
s).
>=20
> Because of item (2), individuals who can't cope with the performance =
hit (or can
> otherwise filter frames to prevent the bug), or who have hardware the=
y are sure
> is unaffected by this issue, can manually lower the copybreak and res=
et the mtu
> such that performance is restored easily.
>=20
> Signed-off-by: Neil Horman <nhorman@redhat.com>
>=20
>=20
>=20
>  r8169.c |   29 ++++++++++++++++++++++++-----
>  1 file changed, 24 insertions(+), 5 deletions(-)
>=20
>=20
> diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
> index c403ce0..9aac49c 100644
> --- a/drivers/net/r8169.c
> +++ b/drivers/net/r8169.c
> @@ -186,7 +186,12 @@ static struct pci_device_id rtl8169_pci_tbl[] =3D=
 {
> =20
>  MODULE_DEVICE_TABLE(pci, rtl8169_pci_tbl);
> =20
> -static int rx_copybreak =3D 200;
> +/*
> + * we set our copybreak very high so that we don't have
> + * to allocate 16k frames all the time (see note in
> + * rtl8169_open()
> + */=20
> +static int rx_copybreak =3D 16383;
>  static int use_dac;
>  static struct {
>  	u32 msg_enable;
> @@ -3240,9 +3245,13 @@ static void __devexit rtl8169_remove_one(struc=
t pci_dev *pdev)
>  }
> =20
>  static void rtl8169_set_rxbufsize(struct rtl8169_private *tp,
> -				  struct net_device *dev)
> +				  unsigned int mtu)
>  {
> -	unsigned int max_frame =3D dev->mtu + VLAN_ETH_HLEN + ETH_FCS_LEN;
> +	unsigned int max_frame =3D mtu + VLAN_ETH_HLEN + ETH_FCS_LEN;
> +
> +	if (max_frame !=3D 16383)
> +		printk(KERN_WARNING "WARNING! Changing of MTU on this NIC"
> +			"May lead to frame reception errors!\n");
> =20
>  	tp->rx_buf_sz =3D (max_frame > RX_BUF_SIZE) ? max_frame : RX_BUF_SI=
ZE;
>  }
> @@ -3254,7 +3263,17 @@ static int rtl8169_open(struct net_device *dev=
)
>  	int retval =3D -ENOMEM;
> =20
> =20
> -	rtl8169_set_rxbufsize(tp, dev);
> +	/*
> +	 * Note that we use a magic value here, its wierd I know
> +	 * its done because, some subset of rtl8169 hardware suffers from
> +	 * a problem in which frames received that are longer than=20
> +	 * the size set in RxMaxSize register return garbage sizes
> +	 * when received.  To avoid this we need to turn off filtering,=20
> +	 * which is done by setting a value of 16383 in the RxMaxSize regis=
ter
> +	 * and allocating 16k frames to handle the largest possible rx valu=
e
> +	 * thats what the magic math below does.
> +	 */
> +	rtl8169_set_rxbufsize(tp, 16383 - VLAN_ETH_HLEN - ETH_FCS_LEN);
> =20
>  	/*
>  	 * Rx and Tx desscriptors needs 256 bytes alignment.
> @@ -3907,7 +3926,7 @@ static int rtl8169_change_mtu(struct net_device=
 *dev, int new_mtu)
> =20
>  	rtl8169_down(dev);
> =20
> -	rtl8169_set_rxbufsize(tp, dev);
> +	rtl8169_set_rxbufsize(tp, dev->mtu);
> =20
>  	ret =3D rtl8169_init_ring(dev);
>  	if (ret < 0)
> --

Its a start, but should not depend on MTU of device.
If a script sets it to 1500, we can have the security problem again ?

We should have static buffers of 16384 bytes, and always copy to freshl=
y allocated skbs.

If hardware is buggy, driver should focus on security first,
performance doesnt matter in this case.

It seems that we should also avoid the sizeof(FCS) subtract too.
(or test that pkt_size is >=3D min_frame_size)

(the guy was able to feed driver with a 'random' status..., making mach=
ine crash again ?

Sorry, I dont have this hardware so cannot test your patch.

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 60f96c4..c2bbf59 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -4500,7 +4500,7 @@ static int rtl8169_rx_interrupt(struct net_device=
 *dev,
                } else {
                        struct sk_buff *skb =3D tp->Rx_skbuff[entry];
                        dma_addr_t addr =3D le64_to_cpu(desc->addr);
-                       int pkt_size =3D (status & 0x00001FFF) - 4;
+                       int pkt_size =3D (status & 0x00001FFF);
                        struct pci_dev *pdev =3D tp->pci_dev;
=20
                        /*


Avoiding FCS copy brings almost nothing at all anyway, many drivers don=
t care.
