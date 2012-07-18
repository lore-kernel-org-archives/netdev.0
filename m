From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH 0/5] Long term PMTU/redirect storage in ipv4.
Date: Wed, 18 Jul 2012 10:28:26 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1207181014050.1652@ja.ssi.bg>
References: <alpine.LFD.2.00.1207172249270.1831@ja.ssi.bg>  <20120717.134651.562831385960975623.davem@davemloft.net>  <alpine.LFD.2.00.1207180052420.2128@ja.ssi.bg>  <20120717.150920.1324071045620152376.davem@davemloft.net>  <alpine.LFD.2.00.1207180358190.2128@ja.ssi.bg>
 <1342583166.2626.1367.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:55536 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752046Ab2GRHVR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Jul 2012 03:21:17 -0400
In-Reply-To: <1342583166.2626.1367.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Wed, 18 Jul 2012, Eric Dumazet wrote:

> Hi Julian
> 
> I find this patch too complex.
> 
> You could only change fnhe_lock to a seqlock

	I'll change it, I was not sure if we are going to
use some array of seqlocks and also without adding locks in
the struct fib_nh.

> -static DEFINE_SPINLOCK(fnhe_lock);
> +static DEFINE_SEQLOCK(fnhe_seqlock);
>  
>  static struct fib_nh_exception *fnhe_oldest(struct fnhe_hash_bucket *hash, __be32 daddr)
>  {
> @@ -1454,11 +1454,11 @@ static void __ip_do_redirect(struct rtable *rt, struct sk_buff *skb, struct flow
>  				struct fib_nh *nh = &FIB_RES_NH(res);
>  				struct fib_nh_exception *fnhe;
>  
> -				spin_lock_bh(&fnhe_lock);
> +				write_seqlock_bh(&fnhe_seqlock);
>  				fnhe = find_or_create_fnhe(nh, fl4->daddr);
>  				if (fnhe)
>  					fnhe->fnhe_gw = new_gw;
> -				spin_unlock_bh(&fnhe_lock);
> +				write_sequnlock_bh(&fnhe_seqlock);
>  			}
>  			rt->rt_gateway = new_gw;
>  			rt->rt_flags |= RTCF_REDIRECTED;
> @@ -1665,13 +1665,13 @@ static void __ip_rt_update_pmtu(struct rtable *rt, struct flowi4 *fl4, u32 mtu)
>  		struct fib_nh *nh = &FIB_RES_NH(res);
>  		struct fib_nh_exception *fnhe;
>  
> -		spin_lock_bh(&fnhe_lock);
> +		write_seqlock_bh(&fnhe_seqlock);
>  		fnhe = find_or_create_fnhe(nh, fl4->daddr);
>  		if (fnhe) {
>  			fnhe->fnhe_pmtu = mtu;
>  			fnhe->fnhe_expires = jiffies + ip_rt_mtu_expires;
>  		}
> -		spin_unlock_bh(&fnhe_lock);
> +		write_sequnlock_bh(&fnhe_seqlock);
>  	}
>  	rt->rt_pmtu = mtu;
>  	dst_set_expires(&rt->dst, ip_rt_mtu_expires);
> @@ -1904,18 +1904,29 @@ static void rt_bind_exception(struct rtable *rt, struct fib_nh *nh, __be32 daddr
>  
>  	for (fnhe = rcu_dereference(hash[hval].chain); fnhe;
>  	     fnhe = rcu_dereference(fnhe->fnhe_next)) {
> -		if (fnhe->fnhe_daddr == daddr) {
> -			if (fnhe->fnhe_pmtu) {
> -				unsigned long expires = fnhe->fnhe_expires;
> -				unsigned long diff = jiffies - expires;
> +		unsigned int seq;
> +		__be32 fnhe_daddr, gw;
> +		u32 pmtu;
> +		unsigned long expires;
> +
> +		do {
> +			seq = read_seqbegin(&fnhe_seqlock);
> +			fnhe_daddr = fnhe->fnhe_daddr;
> +			gw = fnhe->fnhe_gw;
> +			pmtu = fnhe->fnhe_pmtu;
> +			expires = fnhe->fnhe_expires;
> +		} while (read_seqretry(&fnhe_seqlock, seq));

	This is going to read all values in the chain
before reaching daddr? Or may be FNHE_RECLAIM_DEPTH is
small and nobody will increase it. May be I can create
some func that searches daddr in chain instead. Do you still
prefer to remove the first daddr check or it is only
that the code is intended too much?

> +		if (fnhe_daddr == daddr) {

	Also, do we need some rcu locking in
__ip_rt_update_pmtu or may be ipv4_update_pmtu is
called always under rcu lock?

Regards

--
Julian Anastasov <ja@ssi.bg>
