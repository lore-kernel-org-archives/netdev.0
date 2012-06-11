From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/5] inet: Hide route peer accesses behind helpers.
Date: Mon, 11 Jun 2012 12:51:02 +0200
Message-ID: <1339411862.6001.2015.camel@edumazet-glaptop>
References: <20120611.022908.953732817435232845.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:50853 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751451Ab2FKKvH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jun 2012 06:51:07 -0400
Received: by eeit10 with SMTP id t10so1782810eei.19
        for <netdev@vger.kernel.org>; Mon, 11 Jun 2012 03:51:05 -0700 (PDT)
In-Reply-To: <20120611.022908.953732817435232845.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

On Mon, 2012-06-11 at 02:29 -0700, David Miller wrote:
> We encode the pointer(s) into an unsigned long with one state bit.
> 
> The state bit is used so we can store the inetpeer tree root to use
> when resolving the peer later.
> 
> Later the peer roots will be per-FIB table, and this change works to
> facilitate that.

...

> +static inline bool inetpeer_ptr_set_peer(unsigned long *ptr, struct inet_peer *peer)
> +{
> +	unsigned long val = (unsigned long) peer;
> +	unsigned long orig = *ptr;
> +
> +	if (!(orig & INETPEER_BASE_BIT) || !val ||
> +	    cmpxchg(ptr, orig, val) != orig)
> +		return false;
> +	return true;
> +}

If peer is NULL here, we return false;



So we might have a NULL deref later :

>  
>  void rt_bind_peer(struct rtable *rt, __be32 daddr, int create)
>  {
> -	struct net *net = dev_net(rt->dst.dev);
> +	struct inet_peer_base *base;
>  	struct inet_peer *peer;
>  
> -	peer = inet_getpeer_v4(net->ipv4.peers, daddr, create);
> +	base = inetpeer_base_ptr(rt->_peer);
> +	if (!base)
> +		return;
> +
> +	peer = inet_getpeer_v4(base, daddr, create);
>  

Here, peer can be NULL

> -	if (peer && cmpxchg(&rt->peer, NULL, peer) != NULL)
> +	if (!rt_set_peer(rt, peer))
>  		inet_putpeer(peer); << CRASH >>
>  	else
>  		rt->rt_peer_genid = rt_peer_genid();



and in :

>  void rt6_bind_peer(struct rt6_info *rt, int create)
>  {
> -	struct net *net = dev_net(rt->dst.dev);
> +	struct inet_peer_base *base;
>  	struct inet_peer *peer;
>  
> -	peer = inet_getpeer_v6(net->ipv6.peers, &rt->rt6i_dst.addr, create);
> -	if (peer && cmpxchg(&rt->rt6i_peer, NULL, peer) != NULL)
> +	base = inetpeer_base_ptr(rt->_rt6i_peer);
> +	if (!base)
> +		return;
> +
> +	peer = inet_getpeer_v6(base, &rt->rt6i_dst.addr, create);

peer can be NULL

> +	if (!rt6_set_peer(rt, peer))
>  		inet_putpeer(peer);


[PATCH net-next] net: allow NULL param in inet_putpeer()

inet_putpeer() can be called with NULL peer, we must take care of it.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/inetpeer.c      |    2 ++
 net/ipv4/ip_fragment.c   |    3 +--
 net/ipv4/tcp_minisocks.c |    3 +--
 3 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/inetpeer.c b/net/ipv4/inetpeer.c
index cac02ad..cf1e7aa 100644
--- a/net/ipv4/inetpeer.c
+++ b/net/ipv4/inetpeer.c
@@ -527,6 +527,8 @@ EXPORT_SYMBOL_GPL(inet_getpeer);
 
 void inet_putpeer(struct inet_peer *p)
 {
+	if (!p)
+		return;
 	p->dtime = (__u32)jiffies;
 	smp_mb__before_atomic_dec();
 	atomic_dec(&p->refcnt);
diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index 8d07c97..3bd3ed5 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -192,8 +192,7 @@ static __inline__ void ip4_frag_free(struct inet_frag_queue *q)
 	struct ipq *qp;
 
 	qp = container_of(q, struct ipq, q);
-	if (qp->peer)
-		inet_putpeer(qp->peer);
+	inet_putpeer(qp->peer);
 }
 
 
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index cb01531..b2d89b0 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -410,8 +410,7 @@ void tcp_twsk_destructor(struct sock *sk)
 {
 	struct tcp_timewait_sock *twsk = tcp_twsk(sk);
 
-	if (twsk->tw_peer)
-		inet_putpeer(twsk->tw_peer);
+	inet_putpeer(twsk->tw_peer);
 #ifdef CONFIG_TCP_MD5SIG
 	if (twsk->tw_md5_key) {
 		tcp_free_md5sig_pool();
