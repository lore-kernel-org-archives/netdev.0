From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net-next] inet: remove rcu protection on tw_net
Date: Wed, 14 Dec 2011 12:17:51 -0800
Message-ID: <m1d3bqaowg.fsf@fess.ebiederm.org>
References: <1323874713.2334.33.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:57878 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757540Ab1LNUQS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Dec 2011 15:16:18 -0500
In-Reply-To: <1323874713.2334.33.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	(Eric Dumazet's message of "Wed, 14 Dec 2011 15:58:33 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> writes:

> commit b099ce2602d806 (net: Batch inet_twsk_purge) added rcu protection
> on tw_net for no obvious reason.

>From that commit I see:

                sk_nulls_for_each_rcu(sk, node, &head->twchain) {
                        tw = inet_twsk(sk);
-                       if (!net_eq(twsk_net(tw), net) ||
-                           tw->tw_family != family)
+                       if ((tw->tw_family != family) ||
+                               atomic_read(&twsk_net(tw)->count))

That atomic_read is a new dereference of twsk_net in an only rcu
protected section.  That seems like an obvious reason to me.

> struct net are refcounted anyway since timewait sockets escape from rcu
> protected sections. tw_net stay valid for the whole timwait lifetime.

What? twsk_net_set does not bump the struct net ref count.

There is that stupid hold_net/release_net over designed debugging
thinko that makes it look like we have a refcount.  We should probably
just kill that thing.  But a time wait socket unlike a normal socket
does not keep a network namespace alive.  Which is why we have to purge
pending timewait sockets when a network namespace exits.

> This also removes a lot of sparse errors.

What is sparse saying that we are doing wrong?

There may be constraints that are strong enough that we can get away
this but I am at least a little dubious.

Eric


> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> CC: Eric W. Biederman <ebiederm@xmission.com>
> ---
>  include/net/inet_timewait_sock.h |   12 ++----------
>  1 file changed, 2 insertions(+), 10 deletions(-)
>
> diff --git a/include/net/inet_timewait_sock.h b/include/net/inet_timewait_sock.h
> index e8c25b9..ba52c83 100644
> --- a/include/net/inet_timewait_sock.h
> +++ b/include/net/inet_timewait_sock.h
> @@ -218,20 +218,12 @@ extern void inet_twsk_purge(struct inet_hashinfo *hashinfo,
>  static inline
>  struct net *twsk_net(const struct inet_timewait_sock *twsk)
>  {
> -#ifdef CONFIG_NET_NS
> -	return rcu_dereference_raw(twsk->tw_net); /* protected by locking, */
> -						  /* reference counting, */
> -						  /* initialization, or RCU. */
> -#else
> -	return &init_net;
> -#endif
> +	return read_pnet(&twsk->tw_net);
>  }
>  
>  static inline
>  void twsk_net_set(struct inet_timewait_sock *twsk, struct net *net)
>  {
> -#ifdef CONFIG_NET_NS
> -	rcu_assign_pointer(twsk->tw_net, net);
> -#endif
> +	write_pnet(&twsk->tw_net, net);
>  }
>  #endif	/* _INET_TIMEWAIT_SOCK_ */
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
