From: Flavio Leitner <fbl@redhat.com>
Subject: Re: Unable to flush ICMP redirect routes in kernel 3.0+
Date: Fri, 18 Nov 2011 14:30:16 -0200
Message-ID: <20111118143016.01e24b37@asterix.rh>
References: <4EC2CA52.6020104@icdsoft.com>
	<1321391355.2602.0.camel@edumazet-laptop>
	<4EC439F2.3080809@icdsoft.com>
	<20111116223330.08de9e52@asterix.rh>
	<4EC4C160.6010804@icdsoft.com>
	<20111117111145.252924f5@asterix.rh>
	<1321535747.2751.36.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<1321540820.2751.47.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<20111117133724.59684d28@asterix.rh>
	<1321547510.2751.66.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<20111117144038.61b0525b@asterix.rh>
	<1321548319.2751.70.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<20111117150145.25e01a75@asterix.rh>
	<1321550302.2751.81.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<1321551536.2751.87.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<1321632128.3277.29.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Ivan Zahariev <famzah@icdsoft.com>, netdev@vger.kernel.org,
	Vasiliy Kulikov <segoon@openwall.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:16071 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753372Ab1KRQai (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Nov 2011 11:30:38 -0500
In-Reply-To: <1321632128.3277.29.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 18 Nov 2011 17:02:08 +0100
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> 
> 
> David, unless I missed something, we should revert commit f39925dbde77
> ipv4: Cache learned redirect information in inetpeer.)
> 
> With following patch, redirects now work for me.
> 
> Thanks !
> 
> 
> 
> [PATCH net-next] ipv4: fix redirect handling
> 
> commit f39925dbde77 (ipv4: Cache learned redirect information in
> inetpeer.) introduced a regression in ICMP redirect handling.
> 
> It assumed ipv4_dst_check() would be called because all possible
> routes were attached to the inetpeer we modify in ip_rt_redirect(),
> but thats not true.
> 
> commit 7cc9150ebe (route: fix ICMP redirect validation) tried to fix
> this but solution was not complete. (It fixed only one route)
> 
> So we must lookup existing routes (including different TOS values) and
> call check_peer_redir() on them.
> 
> Reported-by: Ivan Zahariev <famzah@icdsoft.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> CC: Flavio Leitner <fbl@redhat.com>
> ---
>  net/ipv4/route.c |  110 ++++++++++++++++++++++++---------------------
>  1 file changed, 59 insertions(+), 51 deletions(-)
> 
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index 511f4a7..0c74da8 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -1304,16 +1304,42 @@ static void rt_del(unsigned hash, struct
> rtable *rt) spin_unlock_bh(rt_hash_lock_addr(hash));
>  }
>  
> +static int check_peer_redir(struct dst_entry *dst, struct inet_peer
> *peer) +{
> +	struct rtable *rt = (struct rtable *) dst;
> +	__be32 orig_gw = rt->rt_gateway;
> +	struct neighbour *n, *old_n;
> +
> +	dst_confirm(&rt->dst);
> +
> +	rt->rt_gateway = peer->redirect_learned.a4;
> +
> +	n = ipv4_neigh_lookup(&rt->dst, &rt->rt_gateway);
> +	if (IS_ERR(n))
> +		return PTR_ERR(n);
> +	old_n = xchg(&rt->dst._neighbour, n);
> +	if (old_n)
> +		neigh_release(old_n);
> +	if (!n || !(n->nud_state & NUD_VALID)) {
> +		if (n)
> +			neigh_event_send(n, NULL);
> +		rt->rt_gateway = orig_gw;
> +		return -EAGAIN;
> +	} else {
> +		rt->rt_flags |= RTCF_REDIRECTED;
> +		call_netevent_notifiers(NETEVENT_NEIGH_UPDATE, n);
> +	}
> +	return 0;
> +}
> +
>  /* called in rcu_read_lock() section */
>  void ip_rt_redirect(__be32 old_gw, __be32 daddr, __be32 new_gw,
>  		    __be32 saddr, struct net_device *dev)
>  {
>  	int s, i;
>  	struct in_device *in_dev = __in_dev_get_rcu(dev);
> -	struct rtable *rt;
>  	__be32 skeys[2] = { saddr, 0 };
>  	int    ikeys[2] = { dev->ifindex, 0 };
> -	struct flowi4 fl4;
>  	struct inet_peer *peer;
>  	struct net *net;
>  
> @@ -1336,33 +1362,42 @@ void ip_rt_redirect(__be32 old_gw, __be32
> daddr, __be32 new_gw, goto reject_redirect;
>  	}
>  
> -	memset(&fl4, 0, sizeof(fl4));
> -	fl4.daddr = daddr;
>  	for (s = 0; s < 2; s++) {
>  		for (i = 0; i < 2; i++) {
> -			fl4.flowi4_oif = ikeys[i];
> -			fl4.saddr = skeys[s];
> -			rt = __ip_route_output_key(net, &fl4);
> -			if (IS_ERR(rt))
> -				continue;
> -
> -			if (rt->dst.error || rt->dst.dev != dev ||
> -			    rt->rt_gateway != old_gw) {
> -				ip_rt_put(rt);
> -				continue;
> -			}
> +			unsigned int hash;
> +			struct rtable __rcu **rthp;
> +			struct rtable *rt;
> +
> +			hash = rt_hash(daddr, skeys[s], ikeys[i],
> rt_genid(net)); +
> +			rthp = &rt_hash_table[hash].chain;
> +
> +			while ((rt = rcu_dereference(*rthp)) !=
> NULL) {
> +				rthp = &rt->dst.rt_next;
> +
> +				if (rt->rt_key_dst != daddr ||
> +				    rt->rt_key_src != skeys[s] ||
> +				    rt->rt_oif != ikeys[i] ||
> +				    rt_is_input_route(rt) ||
> +				    rt_is_expired(rt) ||
> +				    !net_eq(dev_net(rt->dst.dev),
> net) ||
> +				    rt->dst.error ||
> +				    rt->dst.dev != dev ||
> +				    rt->rt_gateway != old_gw)
> +					continue;
>  

I know we are reverting to get it fixed, but this adds the routing
cache back, so what is the plan? Revert to get it working and then
think on new approach to remove the route cache again later?

I had one previous patch using the routing cache posted to the list,
but it won't fix the route flush problem.

thanks,
fbl
