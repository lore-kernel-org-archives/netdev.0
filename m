From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: md5: check md5 signature without socket
 lock
Date: Tue, 05 Aug 2014 16:27:03 -0700 (PDT)
Message-ID: <20140805.162703.362629415553579077.davem@davemloft.net>
References: <20140805025452.1a5bec4ad0d0c5a30a22a589@qrator.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: ixaphire@qrator.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140805025452.1a5bec4ad0d0c5a30a22a589@qrator.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dmitry Popov <ixaphire@qrator.net>
Date: Tue, 5 Aug 2014 02:54:52 +0400

> Since a8afca032 (tcp: md5: protects md5sig_info with RCU) tcp_md5_do_lookup
> doesn't require socket lock, rcu_read_lock is enough. Therefore socket lock is
> no longer required for tcp_v{4,6}_inbound_md5_hash too, so we can move these
> calls (wrapped with rcu_read_{,un}lock) outside of bh_{,un}lock_sock: 
> from tcp_v{4,6}_do_rcv to tcp_v{4,6}_rcv.
> 
> Signed-off-by: Dmitry Popov <ixaphire@qrator.net>

But this change has a side effect outside of locking:

> @@ -1539,16 +1551,6 @@ static struct sock *tcp_v4_hnd_req(struct sock *sk, struct sk_buff *skb)
>  int tcp_v4_do_rcv(struct sock *sk, struct sk_buff *skb)
>  {
>  	struct sock *rsk;
> -#ifdef CONFIG_TCP_MD5SIG
> -	/*
> -	 * We really want to reject the packet as early as possible
> -	 * if:
> -	 *  o We're expecting an MD5'd packet and this is no MD5 tcp option
> -	 *  o There is an MD5 option and we're not expecting one
> -	 */
> -	if (tcp_v4_inbound_md5_hash(sk, skb))
> -		goto discard;
> -#endif
>  
>  	if (sk->sk_state == TCP_ESTABLISHED) { /* Fast path */
>  		struct dst_entry *dst = sk->sk_rx_dst;
> @@ -1751,6 +1753,18 @@ process:
>  
>  	if (!xfrm4_policy_check(sk, XFRM_POLICY_IN, skb))
>  		goto discard_and_relse;
> +
> +#ifdef CONFIG_TCP_MD5SIG
> +	/*
> +	 * We really want to reject the packet as early as possible
> +	 * if:
> +	 *  o We're expecting an MD5'd packet and this is no MD5 tcp option
> +	 *  o There is an MD5 option and we're not expecting one
> +	 */
> +	if (tcp_v4_inbound_md5_hash(sk, skb))
> +		goto discard_and_relse;
> +#endif
> +
>  	nf_reset(skb);
>  
>  	if (sk_filter(sk, skb))

The original ordering seemed very much intentional, as per the comment.

You need to either make your locking change without disturbing this
ordering, or proprosed first and separately that the early check
should be changed.

Also, you really shouldn't just move the early md5 check _after_ the
TCP_ESTABLISHED fast path, and keep the comment there as well.  The
comment makes no sense any longer if the MD5 check happens after the
TCP_ESTABLISHED fast path, right?

I'm not applying this, sorry.
