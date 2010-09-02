From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] Gigabit Ethernet driver of Topcliff PCH
Date: Thu, 2 Sep 2010 08:10:07 -0700
Message-ID: <20100902081007.2f910bc0@nehalam>
References: <4C763A67.5040107@dsn.okisemi.com>
	<4C7D0E7A.5060309@dsn.okisemi.com>
	<1283266263.2550.106.camel@edumazet-laptop>
	<000a01cb4a9b$e8d6ab00$66f8800a@maildom.okisemi.com>
	<1283434847.2454.726.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Masayuki Ohtake <masa-korg@dsn.okisemi.com>,
	Sam Ravnborg <sam@ravnborg.org>, Joe Perches <joe@perches.com>,
	LKML <linux-kernel@vger.kernel.org>,
	ML netdev <netdev@vger.kernel.org>,
	Greg Rose <gregory.v.rose@intel.com>,
	Maxime Bizon <mbizon@freebox.fr>,
	Kristoffer Glembo <kristoffer@gaisler.com>,
	Ralf Baechle <ralf@linux-mips.org>,
	John Linn <john.linn@xilinx.com>,
	Randy Dunlap <randy.dunlap@oracle.com>,
	"David S. Miller" <davem@davemloft.net>,
	MeeGo <meego-dev@meego.com>, "Wang, Qi" <qi.wang@intel.com>,
	"Wang, Yong Y" <yong.y.wang@intel.com>,
	Andrew <andrew.chih.howe.khor@intel.com>,
	Intel OTC <joel.clark@intel.com>,
	"Foster, Margie" <margie.foster@intel.com>,
	Toshiharu Okada <okada533@dsn.okisemi.com>,
	Tomoya Morinaga <morinaga526@dsn.okisemi.com>,
	Takahiro Shimizu <shimizu394@dsn.okisemi.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1283434847.2454.726.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 02 Sep 2010 15:40:47 +0200
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Le jeudi 02 septembre 2010 =E0 21:39 +0900, Masayuki Ohtake a =E9crit=
 :
> > Hi Eric
> >=20
> > Thank you for your comments.
> >=20
> > > I find hard to believe this driver needs to copy all outgoing fra=
mes on
> > > pre-allocated skbs.
> > >
> > > +       /* [Header:14][payload] ---> [Header:14][paddong:2][paylo=
ad]    */
> > > +       memcpy(tmp_skb->data, skb->data, ETH_HLEN);
> > > +       tmp_skb->data[ETH_HLEN] =3D 0x00;
> > > +       tmp_skb->data[ETH_HLEN + 1] =3D 0x00;
> > > +       tmp_skb->len =3D skb->len;
> > > +       memcpy(&tmp_skb->data[ETH_HLEN + 2], &skb->data[ETH_HLEN]=
,
> > > +              (skb->len - ETH_HLEN));
> > > +       buffer_info->kernel_skb =3D skb;
> > > +       skb =3D tmp_skb;
> > >
> > > Whats the deal here please ?
> >=20
> > This processing depends on hardware specification.
> >=20
> > At the time of transmission.
> > Hardware accepts a packet in the following format.
> >   [Header: 14octet] + [padding: 2octet] + [payload]
> >   Also, it is necessary to align the head of a [Header: 14octet] at=
 64byte.
> >=20
> > In my knowledge, SKB received by kernel are the following format.
> >   [padding: 2octet] + [Header:14octet] + [payload]
> >   Also, The head of [payload] has aligned at 16 byte.
> >=20
> > So, it has adjusted with the format of hardware by a copy.
>=20
> The two bytes padding can be handled by network stack, if you
> force in your setup phase :
> 	dev->hard_header_len =3D ETH_HLEN + 2;
>=20
> then, you can do a single memcpy:
>=20
> memcpy(tmp_skb->data, skb->data, skb->len);
>=20
> About the 64 byte alignement, it might be a bit more complex :)

With Eric's suggestion, you might find most packets are going
to be aligned but the code should not depend on it always being true.
Packets that get forwarded have header determined by the receiving
interface.

Something like:
       skb =3D skb_realloc_headroom(skb, 2);
       if (!skb)
           goto drop;
	__skb_push(skb, 2);
        memmove(skb->data, skb->data + 2, ETH_HLEN);

	skb->data[ETH_HLEN] =3D 0;
	skb->data[ETH_HLEN+1] =3D 0;
   =20
        if (!IS_ALIGNED(skb->data, 16)) {
	    nskb =3D netdev_alloc_skb(dev, skb->len + 16);
	    if (!nskb)
                goto drop2;
            skb_reserve(nskb, PTR_ALIGN(skb->data, 16) - skb->data);
	    skb_put(skb, skb->len);
            memcpy(nskb->data, skb->data, skb->len);
	    dev_kfree_skb(skb);
            skb =3D nskb;
        }
      =20



--=20
