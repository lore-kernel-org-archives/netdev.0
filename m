From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] pktgen: Clone skb to avoid corruption of skbs in
 ndo_start_xmit methods
Date: Wed, 20 Jul 2011 11:40:57 -0400
Message-ID: <20110720154057.GF12349@hmsreliant.think-freely.org>
References: <1311105738.3113.11.camel@edumazet-laptop>
 <20110719202922.GA2352@minipsycho>
 <1311108107.3113.22.camel@edumazet-laptop>
 <20110720001904.GA1992@neilslaptop.think-freely.org>
 <1311122593.3113.46.camel@edumazet-laptop>
 <4E2626E1.6030005@candelatech.com>
 <20110720020737.GB2692@neilslaptop.think-freely.org>
 <1311135855.3113.66.camel@edumazet-laptop>
 <20110720151827.GD12349@hmsreliant.think-freely.org>
 <CAHXqBFKD1bD8uMYOwbhsutT0ZuEiw=7pUDM1hVGpCgrdnV6zAg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Ben Greear <greearb@candelatech.com>,
	Jiri Pirko <jpirko@redhat.com>, netdev@vger.kernel.org,
	Alexey Dobriyan <adobriyan@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, robert.olsson@its.uu.se
To: =?utf-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirqus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:59203 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751577Ab1GTPlP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jul 2011 11:41:15 -0400
Content-Disposition: inline
In-Reply-To: <CAHXqBFKD1bD8uMYOwbhsutT0ZuEiw=7pUDM1hVGpCgrdnV6zAg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 20, 2011 at 05:35:47PM +0200, Micha=C5=82 Miros=C5=82aw wro=
te:
> 2011/7/20 Neil Horman <nhorman@tuxdriver.com>:
> > On Wed, Jul 20, 2011 at 06:24:15AM +0200, Eric Dumazet wrote:
> >> Le mardi 19 juillet 2011 =C3=A0 22:07 -0400, Neil Horman a =C3=A9c=
rit :
> >> > >
> >> > I think this is a good idea. =C2=A0It lets pktgen dynamically ma=
ke the clone/share
> >> > decision dynamically and only impacts performance for those syst=
ems.
> >> >
> >>
> >> Just let pktgen refuse to use clone_skb command for these devices.
> >>
> > copy that, This is by no means final, but what do you think of this=
? =C2=A0If its
> > agreeable to you, Ben, et al. I can add this to my local tree and s=
tart auditing
> > all the drivers that may need to have the flag set.
> >
> > Regards
> > Neil
> >
> >
> > diff --git a/include/linux/if.h b/include/linux/if.h
> > index 3bc63e6..ae904fe 100644
> > --- a/include/linux/if.h
> > +++ b/include/linux/if.h
> > @@ -76,6 +76,7 @@
> > =C2=A0#define IFF_BRIDGE_PORT =C2=A0 =C2=A0 =C2=A0 =C2=A00x4000 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/* device used as bridge port */
> > =C2=A0#define IFF_OVS_DATAPATH =C2=A0 =C2=A0 =C2=A0 0x8000 =C2=A0/*=
 device used as Open vSwitch
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
* datapath port */
> > +#define IFF_CANT_SHARE_SKB =C2=A0 =C2=A0 0x10000 /* Device can't s=
hare skbs in tx path */
> >
> > =C2=A0#define IF_GET_IFACE =C2=A0 0x0001 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0/* for querying only */
> > =C2=A0#define IF_GET_PROTO =C2=A0 0x0002
> > diff --git a/net/core/pktgen.c b/net/core/pktgen.c
> > index f76079c..bf6d88d 100644
> > --- a/net/core/pktgen.c
> > +++ b/net/core/pktgen.c
> > @@ -1071,6 +1071,9 @@ static ssize_t pktgen_if_write(struct file *f=
ile,
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (len < 0)
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0return len;
> >
> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (pkt_dev->pri=
v_flags & IFF_CANT_SHARE_SKB)
> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 return -EOPNOTSUPP;
> > +
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0i +=3D len;
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0pkt_dev->clo=
ne_skb =3D value;
> >
>=20
> I would prefer that the flag be inclusive, i.e. it should mark driver=
s
> which can use shared skbs. And it might be better to clone the skb in
> case the flag is disabled to keep functionality working.
>=20
Ok, I can agree with that.  But you're ok with the general approach?
Neil

> Best Regards,
> Micha=C5=82 Miros=C5=82aw
>=20
