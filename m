From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: IP fragmentation broken in 3.6-rc ?
Date: Tue, 21 Aug 2012 18:47:13 +0200
Message-ID: <1345567633.5158.534.camel@edumazet-glaptop>
References: <CAF6-1L6DTXPGi4kbcPqbOXrrafMmZ6K1QdcAa=PxJBzZWkvojg@mail.gmail.com>
	 <1345555336.5158.493.camel@edumazet-glaptop>
	 <1345560131.5158.500.camel@edumazet-glaptop>
	 <alpine.LFD.2.00.1208211815550.2149@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Sylvain Munaut <s.munaut@whatever-company.com>,
	netdev@vger.kernel.org
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:59138 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758123Ab2HUQrT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Aug 2012 12:47:19 -0400
Received: by eeil10 with SMTP id l10so6059eei.19
        for <netdev@vger.kernel.org>; Tue, 21 Aug 2012 09:47:17 -0700 (PDT)
In-Reply-To: <alpine.LFD.2.00.1208211815550.2149@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-08-21 at 19:34 +0300, Julian Anastasov wrote:
> 	Hello,
> 
> On Tue, 21 Aug 2012, Eric Dumazet wrote:
> 
> > Following patch should help :
> > 
> > diff --git a/include/net/dst.h b/include/net/dst.h
> > index 621e351..a04aa37 100644
> > --- a/include/net/dst.h
> > +++ b/include/net/dst.h
> > @@ -435,7 +435,7 @@ static inline void dst_set_expires(struct dst_entry *dst, int timeout)
> >  	if (expires == 0)
> >  		expires = 1;
> >  
> 
> 	In theory, restart of PMTUD should not lead to
> fatal problems, we will get new MTUs. But with such
> change should be better, not much, because all MTU
> events will come at same time, later timer will expire
> and we will get again events from routers. The gain
> will be an increased period (with milliseconds to seconds)
> between PMTUD restarts. Compared to the 600-second timer,
> this should be gain below 1% in reduced traffic for PMTUD.
> Before now we started timer from first router, now we
> will start/update timer period after event from last router.
> 

Sorry I dont really understand what you mean


> 	But ipv4_link_failure and ip6_link_failure want to stop
> this timer by setting it to NOW (0). May be we have to add
> also a !timeout check here or to leave the code as before?
> 
> > -	if (dst->expires == 0 || time_before(expires, dst->expires))
> > +	if (dst->expires == 0 || time_after(expires, dst->expires))
> >  		dst->expires = expires;
> >  }
> 
> 	The original problem should be somewhere else, I think.

This patch fixed the problem for me.

My first patch was :

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index e4ba974..9858714 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -956,6 +956,7 @@ static void ip_rt_update_pmtu(struct dst_entry *dst, struct sock *sk,
 		dst->obsolete = DST_OBSOLETE_KILL;
 	} else {
 		rt->rt_pmtu = mtu;
+		rt->dst.expires = 0;
 		dst_set_expires(&rt->dst, ip_rt_mtu_expires);
 	}
 }
