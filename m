From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH][PPPOL2TP]: Fix SMP oops in pppol2tp driver
Date: Mon, 25 Feb 2008 13:05:08 +0000
Message-ID: <20080225130508.GB4733@ff.dom.local>
References: <47BA0214.40703@katalix.com> <20080219230640.GA2755@ami.dom.local> <47BC4F2C.4000802@katalix.com> <20080220183837.GA2881@ami.dom.local> <47BCABC5.9080204@katalix.com> <20080221085959.GA12944@ff.dom.local> <47BD4A34.7070606@katalix.com> <20080221120829.GB12944@ff.dom.local> <47BDB030.1050105@gmail.com> <47C2B266.8070604@katalix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Paul Mackerras <paulus@samba.org>, netdev@vger.kernel.org
To: James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.184]:20355 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755678AbYBYNEQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Feb 2008 08:04:16 -0500
Received: by nf-out-0910.google.com with SMTP id g13so763762nfb.21
        for <netdev@vger.kernel.org>; Mon, 25 Feb 2008 05:04:15 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <47C2B266.8070604@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 25, 2008 at 12:19:50PM +0000, James Chapman wrote:
> Jarek Poplawski wrote:
>> Jarek Poplawski wrote, On 02/21/2008 01:08 PM:
>> ...
>>
>>> Another, probably simpler way would be to move almost all pppol2tp_xmit
>> ...
>>
>> Actually, the simplest off all seems to be now this old idea to maybe make
>> sk_dst_lock globally softirq immune. At least I think it's worth of testing,
>> to check for these other possible lockdep warnings. It should only need to
>> change all write_ and read_lock(&sk->sk_dst_lock) in very few places:
>> include/net/sock.h, include/net/ip6_route.h, and net/ipv6/ipv6_sockglue.c.
>> This could be tested together with you full _bh locking patch (maybe except
>> these other changes in pppol2tp_xmit).
>
> I did this and all lockdep errors have now gone. Tests ran all weekend.  
> See attached patch.
>
> Is this an acceptable solution? If so, I'll prepare and send official  
> patches.

IMHO this should be acceptable because I can't see any reason for
changing properly working code if there is so simple and not costly
solution. But maybe David or somebody else finds some cons? Since
this patch isn't very big I think you could try to send this
officially and we will simply see...

Regards,
Jarek P.


>
>
> -- 
> James Chapman
> Katalix Systems Ltd
> http://www.katalix.com
> Catalysts for your Embedded Linux software development
>

> Index: linux-2.6.24.2/include/net/ip6_route.h
> ===================================================================
> --- linux-2.6.24.2.orig/include/net/ip6_route.h
> +++ linux-2.6.24.2/include/net/ip6_route.h
> @@ -150,9 +150,9 @@ static inline void __ip6_dst_store(struc
>  static inline void ip6_dst_store(struct sock *sk, struct dst_entry *dst,
>  				 struct in6_addr *daddr, struct in6_addr *saddr)
>  {
> -	write_lock(&sk->sk_dst_lock);
> +	write_lock_bh(&sk->sk_dst_lock);
>  	__ip6_dst_store(sk, dst, daddr, saddr);
> -	write_unlock(&sk->sk_dst_lock);
> +	write_unlock_bh(&sk->sk_dst_lock);
>  }
>  
>  static inline int ipv6_unicast_destination(struct sk_buff *skb)
> Index: linux-2.6.24.2/include/net/sock.h
> ===================================================================
> --- linux-2.6.24.2.orig/include/net/sock.h
> +++ linux-2.6.24.2/include/net/sock.h
> @@ -1058,11 +1058,11 @@ sk_dst_get(struct sock *sk)
>  {
>  	struct dst_entry *dst;
>  
> -	read_lock(&sk->sk_dst_lock);
> +	read_lock_bh(&sk->sk_dst_lock);
>  	dst = sk->sk_dst_cache;
>  	if (dst)
>  		dst_hold(dst);
> -	read_unlock(&sk->sk_dst_lock);
> +	read_unlock_bh(&sk->sk_dst_lock);
>  	return dst;
>  }
>  
> @@ -1079,9 +1079,9 @@ __sk_dst_set(struct sock *sk, struct dst
>  static inline void
>  sk_dst_set(struct sock *sk, struct dst_entry *dst)
>  {
> -	write_lock(&sk->sk_dst_lock);
> +	write_lock_bh(&sk->sk_dst_lock);
>  	__sk_dst_set(sk, dst);
> -	write_unlock(&sk->sk_dst_lock);
> +	write_unlock_bh(&sk->sk_dst_lock);
>  }
>  
>  static inline void
> @@ -1097,9 +1097,9 @@ __sk_dst_reset(struct sock *sk)
>  static inline void
>  sk_dst_reset(struct sock *sk)
>  {
> -	write_lock(&sk->sk_dst_lock);
> +	write_lock_bh(&sk->sk_dst_lock);
>  	__sk_dst_reset(sk);
> -	write_unlock(&sk->sk_dst_lock);
> +	write_unlock_bh(&sk->sk_dst_lock);
>  }
>  
>  extern struct dst_entry *__sk_dst_check(struct sock *sk, u32 cookie);
> Index: linux-2.6.24.2/net/ipv6/ipv6_sockglue.c
> ===================================================================
> --- linux-2.6.24.2.orig/net/ipv6/ipv6_sockglue.c
> +++ linux-2.6.24.2/net/ipv6/ipv6_sockglue.c
> @@ -440,9 +440,9 @@ static int do_ipv6_setsockopt(struct soc
>  			opt = xchg(&np->opt, opt);
>  			sk_dst_reset(sk);
>  		} else {
> -			write_lock(&sk->sk_dst_lock);
> +			write_lock_bh(&sk->sk_dst_lock);
>  			opt = xchg(&np->opt, opt);
> -			write_unlock(&sk->sk_dst_lock);
> +			write_unlock_bh(&sk->sk_dst_lock);
>  			sk_dst_reset(sk);
>  		}
>  sticky_done:
> @@ -504,9 +504,9 @@ update:
>  			opt = xchg(&np->opt, opt);
>  			sk_dst_reset(sk);
>  		} else {
> -			write_lock(&sk->sk_dst_lock);
> +			write_lock_bh(&sk->sk_dst_lock);
>  			opt = xchg(&np->opt, opt);
> -			write_unlock(&sk->sk_dst_lock);
> +			write_unlock_bh(&sk->sk_dst_lock);
>  			sk_dst_reset(sk);
>  		}
>  

