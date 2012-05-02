From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next] net: implement tcp coalescing in
 tcp_queue_rcv()
Date: Wed, 02 May 2012 13:11:24 -0700
Message-ID: <1335989484.9611.11.camel@joe2Laptop>
References: <1335523026.2775.236.camel@edumazet-glaptop>
	 <1335809434.2296.9.camel@edumazet-glaptop> <4F9F21E2.3080407@intel.com>
	 <1335835677.11396.5.camel@edumazet-glaptop>
	 <CAKgT0UdeVvJe6k5OitkKgujSw3SQSOvtQ84KrPch8xdd=5ub1A@mail.gmail.com>
	 <1335854378.11396.26.camel@edumazet-glaptop>  <4FA00C9F.8080409@intel.com>
	 <1335891892.22133.23.camel@edumazet-glaptop> <4FA06A94.8050704@intel.com>
	 <4FA06D7A.6090800@intel.com>  <1335926862.22133.42.camel@edumazet-glaptop>
	 <1335946384.22133.119.camel@edumazet-glaptop> <4FA15830.6080600@intel.com>
	 <1335975168.22133.578.camel@edumazet-glaptop> <4FA1606A.6040607@intel.com>
	 <1335977179.22133.599.camel@edumazet-glaptop>
	 <1335981358.22133.605.camel@edumazet-glaptop>
	 <1335988709.22133.632.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Tom Herbert <therbert@google.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Michael Chan <mchan@broadcom.com>,
	Matt Carlson <mcarlson@broadcom.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Maciej =?UTF-8?Q?=C5=BBenczykowski?= <maze@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:49506 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756378Ab2EBULZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 May 2012 16:11:25 -0400
In-Reply-To: <1335988709.22133.632.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-05-02 at 21:58 +0200, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> Extend tcp coalescing implementing it from tcp_queue_rcv(), the main
> receiver function when application is not blocked in recvmsg().
> 
> Function tcp_queue_rcv() is moved a bit to allow its call from
> tcp_data_queue()
> 
> This gives good results especially if GRO could not kick, and if skb
> head is a fragment.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Alexander Duyck <alexander.h.duyck@intel.com>
> Cc: Neal Cardwell <ncardwell@google.com>
> Cc: Tom Herbert <therbert@google.com>
> ---
> To be applied after "[PATCH v2 net-next] net: take care of cloned skbs
> in tcp_try_coalesce()"
> 
>  include/net/tcp.h    |    3 ++-
>  net/ipv4/tcp.c       |   10 +++++-----
>  net/ipv4/tcp_input.c |   40 +++++++++++++++++++++-------------------
>  3 files changed, 28 insertions(+), 25 deletions(-)
> 
> diff --git a/include/net/tcp.h b/include/net/tcp.h
> index 0fb84de..a9d2fb8 100644
> --- a/include/net/tcp.h
> +++ b/include/net/tcp.h
> @@ -438,7 +438,8 @@ extern int tcp_disconnect(struct sock *sk, int flags);
>  
>  void tcp_connect_init(struct sock *sk);
>  void tcp_finish_connect(struct sock *sk, struct sk_buff *skb);
> -void tcp_queue_rcv(struct sock *sk, struct sk_buff *skb, int hdrlen);
> +int __must_check tcp_queue_rcv(struct sock *sk, struct sk_buff *skb,
> +			       int hdrlen, bool *fragstolen);
>  
>  /* From syncookies.c */
>  extern __u32 syncookie_secret[2][16-4+SHA_DIGEST_WORDS];
> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> index 9670af3..bd5deff 100644
> --- a/net/ipv4/tcp.c
> +++ b/net/ipv4/tcp.c
> @@ -980,8 +980,8 @@ static inline int select_size(const struct sock *sk, bool sg)
>  static int tcp_send_rcvq(struct sock *sk, struct msghdr *msg, size_t size)
>  {
>  	struct sk_buff *skb;
> -	struct tcp_skb_cb *cb;
>  	struct tcphdr *th;
> +	bool fragstolen;

It might be useful to comment that this is/can be initialized to
false in tcp_try_coalesce via tcp_recv_queue.

>  	skb = alloc_skb(size + sizeof(*th), sk->sk_allocation);
>  	if (!skb)
> @@ -994,14 +994,14 @@ static int tcp_send_rcvq(struct sock *sk, struct msghdr *msg, size_t size)
>  	if (memcpy_fromiovec(skb_put(skb, size), msg->msg_iov, size))
>  		goto err_free;
>  
> -	cb = TCP_SKB_CB(skb);
> -
>  	TCP_SKB_CB(skb)->seq = tcp_sk(sk)->rcv_nxt;
>  	TCP_SKB_CB(skb)->end_seq = TCP_SKB_CB(skb)->seq + size;
>  	TCP_SKB_CB(skb)->ack_seq = tcp_sk(sk)->snd_una - 1;
>  
> -	tcp_queue_rcv(sk, skb, sizeof(*th));
> -
> +	if (tcp_queue_rcv(sk, skb, sizeof(*th), &fragstolen)) {
> +		WARN_ON_ONCE(fragstolen); /* should not happen */

Otherwise this looks like a possibly uninitialized test
of fragstolen.  Maybe there's a path where tail is null
in tcp_recv_queue and it's an uninitialized test anyway.

> +		__kfree_skb(skb);
> +	}
>  	return size;
>  
>  err_free:
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index f891a5e..2233468 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -4662,6 +4662,22 @@ end:
>  		skb_set_owner_r(skb, sk);
>  }
>  
> +int tcp_queue_rcv(struct sock *sk, struct sk_buff *skb, int hdrlen,
> +		  bool *fragstolen)
> +{
> +	int eaten;
> +	struct sk_buff *tail = skb_peek_tail(&sk->sk_receive_queue);
> +
> +	__skb_pull(skb, hdrlen);
> +	eaten = (tail &&
> +		 tcp_try_coalesce(sk, tail, skb, fragstolen)) ? 1 : 0;
> +	tcp_sk(sk)->rcv_nxt = TCP_SKB_CB(skb)->end_seq;
> +	if (!eaten) {
> +		__skb_queue_tail(&sk->sk_receive_queue, skb);
> +		skb_set_owner_r(skb, sk);
> +	}
> +	return eaten;
> +}
