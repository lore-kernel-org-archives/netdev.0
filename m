From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] ipv6: kill sk_dst_lock
Date: Mon, 30 Nov 2015 18:01:52 -0800
Message-ID: <1448935312.25582.6.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CACT4Y+Y=35aC5DK7MQaDF6eviKcXik2S9caTLw7FAp0L0CXdsg@mail.gmail.com>
	 <1448730683.24696.94.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1448731434.24696.97.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1448854142.24696.109.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1448901315.24696.127.camel@edumazet-glaptop2.roam.corp.google.com>
	 <565CFB87.9060402@miraclelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Dmitry Vyukov <dvyukov@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Vlad Yasevich <vyasevich@gmail.com>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>
To: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:32999 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755487AbbLACBy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2015 21:01:54 -0500
Received: by pabfh17 with SMTP id fh17so209958650pab.0
        for <netdev@vger.kernel.org>; Mon, 30 Nov 2015 18:01:54 -0800 (PST)
In-Reply-To: <565CFB87.9060402@miraclelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-12-01 at 10:44 +0900, YOSHIFUJI Hideaki wrote:
> Hi,
> 
> Eric Dumazet wrote:
> > diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
> > index 2bfb2ad2fab1..877f682989b8 100644
> > --- a/include/net/ip6_route.h
> > +++ b/include/net/ip6_route.h
> > @@ -133,27 +133,18 @@ void rt6_clean_tohost(struct net *net, struct in6_addr *gateway);
> >  /*
> >   *	Store a destination cache entry in a socket
> >   */
> > -static inline void __ip6_dst_store(struct sock *sk, struct dst_entry *dst,
> > -				   const struct in6_addr *daddr,
> > -				   const struct in6_addr *saddr)
> > +static inline void ip6_dst_store(struct sock *sk, struct dst_entry *dst,
> > +				 const struct in6_addr *daddr,
> > +				 const struct in6_addr *saddr)
> >  {
> >  	struct ipv6_pinfo *np = inet6_sk(sk);
> > -	struct rt6_info *rt = (struct rt6_info *) dst;
> >  
> > +	np->dst_cookie = rt6_get_cookie((struct rt6_info *)dst);
> >  	sk_setup_caps(sk, dst);
> >  	np->daddr_cache = daddr;
> >  #ifdef CONFIG_IPV6_SUBTREES
> >  	np->saddr_cache = saddr;
> >  #endif
> > -	np->dst_cookie = rt6_get_cookie(rt);
> > -}
> > -
> 
> I believe you do not have to change function inside, right?

I knew I forgot something in my changelog :

ip6_dst_store() can be called from process context.

As soon as the dst is installed in sk->sk_dst_cache, dst can be freed
from another cpu doing a concurrent ip6_dst_store()

Doing the dst dereference before doing the install is safer.

Otherwise, we need to add rcu_read_lock() extra sections.

I believe we have other bugs like this one (deref dst after
sk_setup_caps() calls) that need an audit.

But I prefer making smaller patches addressing one problem at a time...

Thanks !
