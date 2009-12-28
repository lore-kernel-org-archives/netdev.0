From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH RFC] r8169: straighten out overlength frame detection
Date: Mon, 28 Dec 2009 18:49:05 -0500
Message-ID: <20091228234905.GA2551@localhost.localdomain>
References: <20091228194834.GA18422@hmsreliant.think-freely.org> <20091228195053.GB18422@hmsreliant.think-freely.org> <20091228213114.GA24285@zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	eric.dumazet@gmail.com, nhorman@redhat.com
To: =?iso-8859-1?Q?Fran=E7ois?= romieu <romieu@zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:57797 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750794AbZL1XtK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Dec 2009 18:49:10 -0500
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
Possible, but regardless, if the result is that we either dma beyond th=
e end of
an allocated skb, or get garbage in the frame size register, it seems w=
e need to
support your initially referenced commit.  Again, I'm not 100% sure her=
e, I'm
soliciting opinion, based on the above presentation.

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
I agree, thats why I'm posting this with RFC, because it seems like a t=
errible
solution.  But at the same time, if we can't rely on the NIC to report =
frame
sizes reliably, I'm not sure what other choice we have.

> I'd rather go for static buffers + copy (+ src mac address of our new=
 friend).
>=20
Thats another choice, yes.  We could probably attain that easily by set=
ting the
copybreak value to 16383 (so as to avoid changing the receive path too =
much if
there are classes of supported hw that do not encounter this problem).

> Is it enough if I write it in a pair of evening ?
>=20
Yeah, thats fine by me, I was just responding to the presentation so we=
 could
get the ball rolling.  If you like, I'd be happy to do it as well.  Jus=
t let me
know.


Thanks & regards
Neil

