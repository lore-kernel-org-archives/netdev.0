From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH net-next 1/5] sky2: force receive checksum when using
 RSS on some hardware (v2)
Date: Fri, 8 Jul 2011 08:32:40 -0700
Message-ID: <20110708083240.09e8cce8@nehalam.ftrdhcpuser.net>
References: <20110707155056.939223264@vyatta.com>
	<20110707155212.000920741@vyatta.com>
	<CAHXqBF+Ha9XaMDB0x1XBD633mj2b6Jxmg9U_JSokrov90gPA-g@mail.gmail.com>
	<20110707101322.784409eb@nehalam.ftrdhcpuser.net>
	<20110707164000.6f3f58f4@nehalam.ftrdhcpuser.net>
	<CAHXqBF+XfArvVDXQ+JBGQ1hEne=w7u6eFTf=SQciLr48BD7h8w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: =?ISO-8859-2?B?TWljaGGzIE1pcm9zs2F3?= <mirqus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:48843 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751996Ab1GHPcm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jul 2011 11:32:42 -0400
In-Reply-To: <CAHXqBF+XfArvVDXQ+JBGQ1hEne=w7u6eFTf=SQciLr48BD7h8w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 8 Jul 2011 10:45:33 +0200
Micha=B3 Miros=B3aw <mirqus@gmail.com> wrote:

> 2011/7/8 Stephen Hemminger <shemminger@vyatta.com>:
> > Found when reviewing the vendor driver. Apparently some chip versio=
ns
> > require receive checksumming to be enabled in order for RSS to work=
=2E
> >
> > Also, if fix_features has to change some settings; put in message
> > in log in similar manner to netdev_fix_features.
> >
> > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> >
> > ---
> > v2 - enforce the requirement in fix_features rather than set featur=
es
> >
> > --- a/drivers/net/sky2.c =A0 =A0 =A0 =A02011-07-07 13:56:03.5754202=
73 -0700
> > +++ b/drivers/net/sky2.c =A0 =A0 =A0 =A02011-07-07 14:03:17.7754039=
38 -0700
> [...]
> > @@ -4176,8 +4180,18 @@ static u32 sky2_fix_features(struct net_
> > =A0 =A0 =A0 =A0/* In order to do Jumbo packets on these chips, need=
 to turn off the
> > =A0 =A0 =A0 =A0 * transmit store/forward. Therefore checksum offloa=
d won't work.
> > =A0 =A0 =A0 =A0 */
> > - =A0 =A0 =A0 if (dev->mtu > ETH_DATA_LEN && hw->chip_id =3D=3D CHI=
P_ID_YUKON_EC_U)
> > + =A0 =A0 =A0 if (dev->mtu > ETH_DATA_LEN && hw->chip_id =3D=3D CHI=
P_ID_YUKON_EC_U) {
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 netdev_warn(dev, "checksum offload no=
t possible with jumbo frames\n");
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0features &=3D ~(NETIF_F_TSO|NETIF_F_=
SG|NETIF_F_ALL_CSUM);
> > + =A0 =A0 =A0 }
> > +
> > + =A0 =A0 =A0 /* Some hardware requires receive checksum for RSS to=
 work. */
> > + =A0 =A0 =A0 if ( (features & NETIF_F_RXHASH) &&
> > + =A0 =A0 =A0 =A0 =A0 =A0!(features & NETIF_F_RXCSUM) &&
> > + =A0 =A0 =A0 =A0 =A0 =A0(sky2->hw->flags & SKY2_HW_RSS_CHKSUM)) {
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 netdev_warn(dev, "receive hashing for=
ces receive checksum\n");
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 features |=3D NETIF_F_RXCSUM;
> > + =A0 =A0 =A0 }
> >
> > =A0 =A0 =A0 =A0return features;
> > =A0}
>=20
> I suggest using netdev_dbg() instead of netdev_warn() so it won't spa=
m
> dmesg on every features update.

I was just copying existing policy in netdev_fix_features.
netdev_dbg() is useless because most user turn off debug messages.
Maybe notice or info is more appropriate level here.

