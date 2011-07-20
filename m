From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] pktgen: Clone skb to avoid corruption of skbs in
 ndo_start_xmit methods
Date: Wed, 20 Jul 2011 11:39:58 -0400
Message-ID: <20110720153958.GE12349@hmsreliant.think-freely.org>
References: <1311105738.3113.11.camel@edumazet-laptop>
 <20110719202922.GA2352@minipsycho>
 <1311108107.3113.22.camel@edumazet-laptop>
 <20110720001904.GA1992@neilslaptop.think-freely.org>
 <1311122593.3113.46.camel@edumazet-laptop>
 <4E2626E1.6030005@candelatech.com>
 <20110720020737.GB2692@neilslaptop.think-freely.org>
 <1311135855.3113.66.camel@edumazet-laptop>
 <20110720151827.GD12349@hmsreliant.think-freely.org>
 <1311175817.2338.44.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Greear <greearb@candelatech.com>,
	Jiri Pirko <jpirko@redhat.com>, netdev@vger.kernel.org,
	Alexey Dobriyan <adobriyan@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, robert.olsson@its.uu.se
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:59176 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751476Ab1GTPkH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jul 2011 11:40:07 -0400
Content-Disposition: inline
In-Reply-To: <1311175817.2338.44.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 20, 2011 at 05:30:17PM +0200, Eric Dumazet wrote:
> Le mercredi 20 juillet 2011 =E0 11:18 -0400, Neil Horman a =E9crit :
> > On Wed, Jul 20, 2011 at 06:24:15AM +0200, Eric Dumazet wrote:
> > > Le mardi 19 juillet 2011 =E0 22:07 -0400, Neil Horman a =E9crit :
> > > > >=20
> > > > I think this is a good idea.  It lets pktgen dynamically make t=
he clone/share
> > > > decision dynamically and only impacts performance for those sys=
tems.
> > > >=20
> > >=20
> > > Just let pktgen refuse to use clone_skb command for these devices=
=2E
> > >=20
> > copy that, This is by no means final, but what do you think of this=
?  If its
> > agreeable to you, Ben, et al. I can add this to my local tree and s=
tart auditing
> > all the drivers that may need to have the flag set.
> >=20
> > Regards
> > Neil
> >=20
> >=20
> > diff --git a/include/linux/if.h b/include/linux/if.h
> > index 3bc63e6..ae904fe 100644
> > --- a/include/linux/if.h
> > +++ b/include/linux/if.h
> > @@ -76,6 +76,7 @@
> >  #define IFF_BRIDGE_PORT	0x4000		/* device used as bridge port */
> >  #define IFF_OVS_DATAPATH	0x8000	/* device used as Open vSwitch
> >  					 * datapath port */
> > +#define IFF_CANT_SHARE_SKB	0x10000	/* Device can't share skbs in t=
x path */
> > =20
> >  #define IF_GET_IFACE	0x0001		/* for querying only */
> >  #define IF_GET_PROTO	0x0002
> > diff --git a/net/core/pktgen.c b/net/core/pktgen.c
> > index f76079c..bf6d88d 100644
> > --- a/net/core/pktgen.c
> > +++ b/net/core/pktgen.c
> > @@ -1071,6 +1071,9 @@ static ssize_t pktgen_if_write(struct file *f=
ile,
> >  		if (len < 0)
> >  			return len;
> > =20
> > +		if (pkt_dev->priv_flags & IFF_CANT_SHARE_SKB)
> > +			return -EOPNOTSUPP;
> > +
>=20
> Well, the general idea was to intercept the "clone_skb XXX" command a=
nd
> cap XXX to 0 for said devices.
>=20
Isn't that exactly what this does?  Disallows a user from issuing the c=
one_skb
command in a pktgen script if the underlying driver can't support the s=
haring of
skbs.

> So some admin can still use pktgen without clone_skb stuff.
>=20
Yes. this doesn't preclude that unless you see something I dont
Neil

>=20
>=20
