From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] snmp: add missing counters for RFC 4293
Date: Tue, 21 Apr 2009 16:09:58 -0400
Message-ID: <20090421200958.GD9577@hmsreliant.think-freely.org>
References: <20090421193937.GC9577@hmsreliant.think-freely.org> <49EE257B.6090600@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:57060 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752853AbZDUUKJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Apr 2009 16:10:09 -0400
Content-Disposition: inline
In-Reply-To: <49EE257B.6090600@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 21, 2009 at 09:58:51PM +0200, Eric Dumazet wrote:
> Neil Horman a =E9crit :
> > The IP MIB (RFC 4293) defines stats for InOctets, OutOctets, InMcas=
tOctets and
> > OutMcastOctets:
> > http://tools.ietf.org/html/rfc4293
> > But it seems we don't track those in any way that easy to separate =
from other
> > protocols.  This patch adds those missing counters to the stats fil=
e.  Tested
> > successfully by me
> >=20
> > Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> >=20
> >=20
> >  include/linux/snmp.h  |    4 ++++
> >  net/ipv4/ip_input.c   |    4 ++++
> >  net/ipv4/ip_output.c  |    3 +++
> >  net/ipv4/proc.c       |    4 ++++
> >  net/ipv6/ip6_input.c  |    4 ++++
> >  net/ipv6/ip6_output.c |    8 ++++++++
> >  net/ipv6/mcast.c      |    9 +++++++++
> >  net/ipv6/ndisc.c      |    3 +++
> >  net/ipv6/proc.c       |    4 ++++
> >  net/ipv6/raw.c        |    6 ++++++
> >  10 files changed, 49 insertions(+)
> >=20
> > diff --git a/include/linux/snmp.h b/include/linux/snmp.h
> > index aee3f1e..95c17f6 100644
> > --- a/include/linux/snmp.h
> > +++ b/include/linux/snmp.h
> > @@ -19,6 +19,8 @@ enum
> >  {
> >  	IPSTATS_MIB_NUM =3D 0,
> >  	IPSTATS_MIB_INRECEIVES,			/* InReceives */
> > +	IPSTATS_MIB_INOCTETS,			/* InOctets */
> > +	IPSTATS_MIB_INMCASTOCTETS,		/* InMcastOctets */
> >  	IPSTATS_MIB_INHDRERRORS,		/* InHdrErrors */
> >  	IPSTATS_MIB_INTOOBIGERRORS,		/* InTooBigErrors */
> >  	IPSTATS_MIB_INNOROUTES,			/* InNoRoutes */
> > @@ -29,6 +31,8 @@ enum
> >  	IPSTATS_MIB_INDELIVERS,			/* InDelivers */
> >  	IPSTATS_MIB_OUTFORWDATAGRAMS,		/* OutForwDatagrams */
> >  	IPSTATS_MIB_OUTREQUESTS,		/* OutRequests */
> > +	IPSTATS_MIB_OUTOCTETS,			/* OutOctets */
> > +	IPSTATS_MIB_OUTMCASTOCTETS,		/* OutMcastOctets */
> >  	IPSTATS_MIB_OUTDISCARDS,		/* OutDiscards */
> >  	IPSTATS_MIB_OUTNOROUTES,		/* OutNoRoutes */
> >  	IPSTATS_MIB_REASMTIMEOUT,		/* ReasmTimeout */
> > diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
> > index 1a58a6f..bc9169b 100644
> > --- a/net/ipv4/ip_input.c
> > +++ b/net/ipv4/ip_input.c
> > @@ -385,6 +385,7 @@ int ip_rcv(struct sk_buff *skb, struct net_devi=
ce *dev, struct packet_type *pt,
> >  		goto drop;
> > =20
> >  	IP_INC_STATS_BH(dev_net(dev), IPSTATS_MIB_INRECEIVES);
> > +	IP_ADD_STATS_BH(dev_net(dev), IPSTATS_MIB_INOCTETS, skb->len);
> > =20
> >  	if ((skb =3D skb_share_check(skb, GFP_ATOMIC)) =3D=3D NULL) {
> >  		IP_INC_STATS_BH(dev_net(dev), IPSTATS_MIB_INDISCARDS);
> > @@ -396,6 +397,9 @@ int ip_rcv(struct sk_buff *skb, struct net_devi=
ce *dev, struct packet_type *pt,
> > =20
> >  	iph =3D ip_hdr(skb);
> > =20
> > +	if (ipv4_is_multicast(iph->daddr))
> > +		IP_ADD_STATS_BH(dev_net(dev), IPSTATS_MIB_INMCASTOCTETS, skb->le=
n);
> > +
> >  	/*
> >  	 *	RFC1122: 3.2.1.2 MUST silently discard any IP frame that fails=
 the checksum.
> >  	 *
> > diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
> > index 3e7e910..8a68dc2 100644
> > --- a/net/ipv4/ip_output.c
> > +++ b/net/ipv4/ip_output.c
> > @@ -245,6 +245,8 @@ int ip_mc_output(struct sk_buff *skb)
> >  	 *	If the indicated interface is up and running, send the packet.
> >  	 */
>=20
> >  	IP_INC_STATS(dev_net(dev), IPSTATS_MIB_OUTREQUESTS);
> > +	IP_ADD_STATS_BH(dev_net(dev), IPSTATS_MIB_OUTOCTETS, skb->len);
> > +	IP_ADD_STATS_BH(dev_net(dev), IPSTATS_MIB_OUTMCASTOCTETS, skb->le=
n);
>=20
> So you use the _BH variant right after IP_INC_STATS() ?
> Which one is right (or which one is false ?)
>=20

Both are correct (right now), at least as far as I can tell.  I'm not 1=
00% sure why ADD
was named ADD_BH, except for the fact that it doesn't toggle the use of=
 the mib
array passed in.  I think the right solution would be to simply rename
IP_ADD_STATS_BH to IP_ADD_STATS, and modify its implementation to acces=
s
mib[!in_softirq()] rather than just mib[0].  I had planned to do this i=
n a
followup cleanup patch.  Alternatively, I could add a new IP_ADD_STATS =
to be
complete, but I don't really see the advantage (asside from not checkin=
g
in_softirq quite as often).

Same with all the other cases below.
Neil

