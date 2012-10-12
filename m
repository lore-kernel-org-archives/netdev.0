From: Shawn Lu <shawn.lu@ericsson.com>
Subject: RE: [PATCH] tcp resets are misrouted
Date: Fri, 12 Oct 2012 13:31:11 -0400
Message-ID: <62162DF05402B341B3DB59932A1FA992BB7FD4730D@EUSAACMS0702.eamcs.ericsson.se>
References: <20121012143417.GA8481@ms2.inr.ac.ru>
 <CAATkVEwBenKmZLVPzu7XoxziOCcWGz3sGXfOx7J9Yp43MJAK-A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"sol@eqv.ru" <sol@eqv.ru>
To: Debabrata Banerjee <dbavatar@gmail.com>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Banerjee, Debabrata" <dbanerje@akamai.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from imr3.ericy.com ([198.24.6.13]:34159 "EHLO imr3.ericy.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753973Ab2JLSmf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Oct 2012 14:42:35 -0400
In-Reply-To: <CAATkVEwBenKmZLVPzu7XoxziOCcWGz3sGXfOx7J9Yp43MJAK-A@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I admit the commit e2446eaa did break the reset in asymmetric case.  There are also many use cases in interface binding, we don't want to break it too... I am ok with your patch, if asymmetric route take higher priority. Somehow, we need  come up with another one to resolve RST lost in binding interface case, otherwise, people using interface binding will find later on that RST break again...    

thanks!

Shawn Lu <shawn.lu@ericsson.com> 

> -----Original Message-----
> From: Debabrata Banerjee [mailto:dbavatar@gmail.com] 
> Sent: Friday, October 12, 2012 8:57 AM
> To: Alexey Kuznetsov; Banerjee, Debabrata
> Cc: netdev@vger.kernel.org; davem@davemloft.net; Shawn Lu; 
> eric.dumazet@gmail.com; sol@eqv.ru
> Subject: Re: [PATCH] tcp resets are misrouted
> 
> On Fri, Oct 12, 2012 at 10:34 AM, Alexey Kuznetsov 
> <kuznet@ms2.inr.ac.ru> wrote:
> > After commit e2446eaa.. tcp resets are always lost, when 
> routing is asymmetric.
> > Yes, backing out that patch will result in misrouting of resets for 
> > dead connections which used interface binding when were 
> alive, but we actually cannot do anything here.
> > What's died that's died and correct handling normal unbound 
> connections is obviously a priority.
> >
> > Comment to comment:
> >> This has few benefits:
> >>   1. tcp_v6_send_reset already did that.
> >
> > It was done to route resets for IPv6 link local addresses. It was a 
> > mistake to do so for global addresses. The patch fixes this as well.
> >
> > Actually, the problem appears to be even more serious than 
> guaranteed loss of resets.
> > As reported by Sergey Soloviev <sol@eqv.ru>, those misrouted resets 
> > create a lot of arp traffic and huge amount of unresolved 
> arp entires 
> > putting down to knees NAT firewalls which use asymmetric routing.
> >
> > Signed-off-by: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
> > ---
> >  net/ipv4/tcp_ipv4.c |    7 ++++---
> >  net/ipv6/tcp_ipv6.c |    3 ++-
> >  2 files changed, 6 insertions(+), 4 deletions(-)
> >
> > diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c index 
> > 75735c9..ef998b0 100644
> > --- a/net/ipv4/tcp_ipv4.c
> > +++ b/net/ipv4/tcp_ipv4.c
> > @@ -708,10 +708,11 @@ static void tcp_v4_send_reset(struct 
> sock *sk, struct sk_buff *skb)
> >         arg.csumoffset = offsetof(struct tcphdr, check) / 2;
> >         arg.flags = (sk && inet_sk(sk)->transparent) ? 
> IP_REPLY_ARG_NOSRCCHECK : 0;
> >         /* When socket is gone, all binding information is lost.
> > -        * routing might fail in this case. using iif for oif to
> > -        * make sure we can deliver it
> > +        * routing might fail in this case. No choice here, 
> if we choose to force
> > +        * input interface, we will misroute in case of 
> asymmetric route.
> >          */
> > -       arg.bound_dev_if = sk ? sk->sk_bound_dev_if : inet_iif(skb);
> > +       if (sk)
> > +               arg.bound_dev_if = sk->sk_bound_dev_if;
> >
> >         net = dev_net(skb_dst(skb)->dev);
> >         arg.tos = ip_hdr(skb)->tos;
> > diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c index 
> > 49c8903..26175bf 100644
> > --- a/net/ipv6/tcp_ipv6.c
> > +++ b/net/ipv6/tcp_ipv6.c
> > @@ -877,7 +877,8 @@ static void tcp_v6_send_response(struct 
> sk_buff *skb, u32 seq, u32 ack, u32 win,
> >         __tcp_v6_send_check(buff, &fl6.saddr, &fl6.daddr);
> >
> >         fl6.flowi6_proto = IPPROTO_TCP;
> > -       fl6.flowi6_oif = inet6_iif(skb);
> > +       if (ipv6_addr_type(&fl6.daddr) & IPV6_ADDR_LINKLOCAL)
> > +               fl6.flowi6_oif = inet6_iif(skb);
> >         fl6.fl6_dport = t1->dest;
> >         fl6.fl6_sport = t1->source;
> >         security_skb_classify_flow(skb, flowi6_to_flowi(&fl6));
> > --
> > 1.7.2.3
> >
> 
> We ran into this as well and pulled that commit from our 
> tree, it was causing serious problems. Sending the RST back 
> on the iif was definitely the wrong thing to do. Patch looks 
> good to me.
> 
> Thanks,
> Debabrata
> 