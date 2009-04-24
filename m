From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] snmp: add missing counters for RFC 4293
Date: Fri, 24 Apr 2009 13:06:55 -0400
Message-ID: <20090424170655.GA15491@hmsreliant.think-freely.org>
References: <20090422165034.GC17947@hmsreliant.think-freely.org> <49EF566B.70203@cosmosbay.com> <20090423152823.GA30405@hmsreliant.think-freely.org> <49F09933.2010200@cosmosbay.com> <20090423165620.GB30405@hmsreliant.think-freely.org> <49F0A1C8.5080601@cosmosbay.com> <20090423172524.GC30405@hmsreliant.think-freely.org> <49F0A641.90303@cosmosbay.com> <20090423182839.GD30405@hmsreliant.think-freely.org> <49F1C847.2020106@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:37787 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760721AbZDXRHI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Apr 2009 13:07:08 -0400
Content-Disposition: inline
In-Reply-To: <49F1C847.2020106@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 24, 2009 at 04:10:15PM +0200, Eric Dumazet wrote:
> Neil Horman a =E9crit :
>=20
> >=20
> > Ok, last time (I hope :)). New patch, functionally identially.  cha=
nges are:
> >=20
> > 1) Incorporate Erics suggestion to improve efficiency of SNMP_UPD_P=
O_STATS*
> > macros by reduing use of in_softirq and per_cpu_ptr.
> >=20
> >=20
> > The IP MIB (RFC 4293) defines stats for InOctets, OutOctets, InMcas=
tOctets and
> > OutMcastOctets:
> > http://tools.ietf.org/html/rfc4293
> > But it seems we don't track those in any way that easy to separate =
from other
> > protocols.  This patch adds those missing counters to the stats fil=
e. Tested
> > successfully by me
> >=20
> > Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> >=20
>=20
> Hi Neil
>=20
> Some errors, please find my comments.
>=20
Responses inline...

> > diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
> > index a51fb33..7434f73 100644
> > --- a/net/ipv6/mcast.c
> > +++ b/net/ipv6/mcast.c
> > @@ -1449,7 +1449,8 @@ static void mld_sendpack(struct sk_buff *skb)
> >  	int err;
> >  	struct flowi fl;
> > =20
> > -	IP6_INC_STATS(net, idev, IPSTATS_MIB_OUTREQUESTS);
> > +	IP6_UPD_PO_STATS(net, idev, IPSTATS_MIB_OUT, skb->len);
>=20
> Are you sure skb->len is setup at this point ?
>=20
Yep, skbs from here are allocated in mld_newpack, and skb_put is always=
 called
on them

> > +
> >  	payload_len =3D (skb->tail - skb->network_header) - sizeof(*pip6)=
;
> >  	mldlen =3D skb->tail - skb->transport_header;
> >  	pip6->payload_len =3D htons(payload_len);
> > @@ -1479,7 +1480,7 @@ out:
> >  	if (!err) {
> >  		ICMP6MSGOUT_INC_STATS_BH(net, idev, ICMPV6_MLD2_REPORT);
> >  		ICMP6_INC_STATS_BH(net, idev, ICMP6_MIB_OUTMSGS);
> > -		IP6_INC_STATS_BH(net, idev, IPSTATS_MIB_OUTMCASTPKTS);
> > +		IP6_UPD_PO_STATS_BH(net, idev, IPSTATS_MIB_OUTMCAST, skb->len);
>=20
> skb it not anymore available here, since it was 'given' to transmit.
>=20
Yeah, I'll fix that.  I'll just record the length before I send it off,=
 and use
that instead.

> >  	} else
> >  		IP6_INC_STATS_BH(net, idev, IPSTATS_MIB_OUTDISCARDS);
> > =20
> > @@ -1774,8 +1775,8 @@ static void igmp6_send(struct in6_addr *addr,=
 struct net_device *dev, int type)
> >  	struct flowi fl;
> > =20
> >  	rcu_read_lock();
> > -	IP6_INC_STATS(net, __in6_dev_get(dev),
> > -		      IPSTATS_MIB_OUTREQUESTS);
> > +	IP6_UPD_PO_STATS(net, __in6_dev_get(dev),
> > +		      IPSTATS_MIB_OUT, skb->len);
>=20
>=20
> skb not yet initialized here, sorry, crash in progress...
>=20
Yeah, that was stupid, I think I can fix that though by using the compu=
tation of
full_len though, since we know how much space we need right before the =
call to
sock_alloc_send_skb

> Please move this a few lines after a sucessfull  sock_alloc_send_skb(=
) call
>=20
> >  	rcu_read_unlock();
> >  	if (type =3D=3D ICMPV6_MGM_REDUCTION)
> >  		snd_addr =3D &in6addr_linklocal_allrouters;
> > @@ -1844,7 +1845,7 @@ out:
> >  	if (!err) {
> >  		ICMP6MSGOUT_INC_STATS(net, idev, type);
> >  		ICMP6_INC_STATS(net, idev, ICMP6_MIB_OUTMSGS);
> > -		IP6_INC_STATS(net, idev, IPSTATS_MIB_OUTMCASTPKTS);
> > +		IP6_UPD_PO_STATS(net, idev, IPSTATS_MIB_OUTMCAST, skb->len);
>=20
> skb it not anymore available here, since it was 'given' to transmit.
>=20
Copy that, I can reuse full_len here I believe.

Thanks for the eyes, I'll fix these up and repost after I test it a bit
Neil

