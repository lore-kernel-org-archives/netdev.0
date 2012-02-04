From: Julian Anastasov <ja@ssi.bg>
Subject: Re: Connect hangs for a while before returns -1 with ECONNREFUSED
 on 3.2 for loopback
Date: Sat, 4 Feb 2012 22:51:38 +0200 (EET)
Message-ID: <alpine.LFD.2.00.1202042217180.1496@ja.ssi.bg>
References: <4F2B7DF1.5050303@oktetlabs.ru>    <1328279894.2157.23.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>    <1328282126.2157.27.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>   <1328358402.2731.11.camel@edumazet-laptop>   <alpine.LFD.2.00.1202041537370.1496@ja.ssi.bg>
  <1328374715.2731.21.camel@edumazet-laptop>  <alpine.LFD.2.00.1202041912430.1496@ja.ssi.bg> <1328384630.2731.46.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1463811672-445831842-1328388699=:1496"
Cc: "Yurij M. Plotnikov" <Yurij.Plotnikov@oktetlabs.ru>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:38334 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751877Ab2BDUvF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 4 Feb 2012 15:51:05 -0500
In-Reply-To: <1328384630.2731.46.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1463811672-445831842-1328388699=:1496
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: 8BIT


	Hello,

On Sat, 4 Feb 2012, Eric Dumazet wrote:

> Le samedi 04 février 2012 à 19:39 +0200, Julian Anastasov a écrit :
> 
> > [PATCH] ipv4: reset flowi parameters on route connect
> > 
> > 	ip_route_connect and ip_route_newports need to reset
> > some flowi fields that are input parameters because we do not
> > want unnecessary binding to oif. Fixes problem with lost
> > RST packets when connecting to local port that has no
> > listener.
> > 
> > Signed-off-by: Julian Anastasov <ja@ssi.bg>
> 
> Please Julian, dont submit an official patch like this without proper
> credits, and proper reference to bug origin, to help stable backport.
> 
> Issue was reported by Yurij, and I spent some time on it to find the
> problem, introduced in 3.0.

	Sorry, you take care, I just wanted to give example.

> > ---
> >  include/net/flow.h  |   10 ++++++++++
> >  include/net/route.h |    4 ++++
> >  2 files changed, 14 insertions(+), 0 deletions(-)
> > 
> > diff --git a/include/net/flow.h b/include/net/flow.h
> > index 9b58243..6c469db 100644
> > --- a/include/net/flow.h
> > +++ b/include/net/flow.h
> > @@ -93,6 +93,16 @@ static inline void flowi4_init_output(struct flowi4 *fl4, int oif,
> >  	fl4->fl4_dport = dport;
> >  	fl4->fl4_sport = sport;
> >  }
> > +
> > +/* Reset some input parameters after previous lookup */
> > +static inline void flowi4_update_output(struct flowi4 *fl4, int oif, __u8 tos,
> > +					__be32 daddr, __be32 saddr)
> > +{
> > +	fl4->flowi4_oif = oif;
> > +	fl4->flowi4_tos = tos;
> > +	fl4->daddr = daddr;
> > +	fl4->saddr = saddr;
> 
> > +}
> >  				      
> 
> 
> >  
> >  struct flowi6 {
> > diff --git a/include/net/route.h b/include/net/route.h
> > index 91855d1..b1c0d5b 100644
> > --- a/include/net/route.h
> > +++ b/include/net/route.h
> > @@ -270,6 +270,7 @@ static inline struct rtable *ip_route_connect(struct flowi4 *fl4,
> >  		if (IS_ERR(rt))
> >  			return rt;
> >  		ip_rt_put(rt);
> > +		flowi4_update_output(fl4, oif, tos, fl4->daddr, fl4->saddr);
> >  	}
> >  	security_sk_classify_flow(sk, flowi4_to_flowi(fl4));
> >  	return ip_route_output_flow(net, fl4, sk);
> > @@ -284,6 +285,9 @@ static inline struct rtable *ip_route_newports(struct flowi4 *fl4, struct rtable
> >  		fl4->fl4_dport = dport;
> >  		fl4->fl4_sport = sport;
> >  		ip_rt_put(rt);
> > +		flowi4_update_output(fl4, sk->sk_bound_dev_if,
> > +				     RT_CONN_FLAGS(sk), fl4->daddr,
> > +				     fl4->saddr);
> >  		security_sk_classify_flow(sk, flowi4_to_flowi(fl4));
> >  		return ip_route_output_flow(sock_net(sk), fl4, sk);
> >  	}
> 
> I dont understand the saddr/daddr part, since you basically have :
> 
> 	fl4->daddr = fl4->daddr;
> 	fl4->saddr = fl4->saddr;

	Yes, it is optimized by compiler. I just wanted
to add a function that has the list of all input parameters
that are modified by the routing lookup, so that we can
use it at every place that needs to reuse the fl4. It also
shows that in ip_route_connect and ip_route_newports
fl4->daddr and fl4->saddr from previous step are reused
while the other fields are set with original values.
For icmp_route_lookup it will help when xfrm_decode_session_reverse
fills fl4_dec to clarify which fields should be provided
to __ip_route_output_key because now for me it is not clear
which fields should be preserved. Currently, only tos is
provided but if xfrm_decode_session_reverse is changed one
day to fill oif we have to be specific what happens exactly.

> __ip_route_output_key() always had the possibility to change
> saddr/daddr, I dont think we have to deal with it.

	I rely on the fact that fields that are reused
do not generate code but it will make the logic visible.
It will help in case one day we modify the semantics for
the fl4 fields (input/output type).

Regards

--
Julian Anastasov <ja@ssi.bg>
---1463811672-445831842-1328388699=:1496--
