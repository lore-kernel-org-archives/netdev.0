From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH 3/3] udp: make use of static_key_slow_set_true()
 interface
Date: Fri, 28 Jun 2013 23:13:40 -0400
Message-ID: <1372475620.18733.353.camel@gandalf.local.home>
References: <cover.1372457176.git.jbaron@akamai.com>
	 <7fe0eaba62a8529b387ddb3205713d8bb6156ec1.1372457176.git.jbaron@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: andi@firstfloor.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, mingo@kernel.org, peterz@infradead.org,
	davem@davemloft.net
To: jbaron@akamai.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <7fe0eaba62a8529b387ddb3205713d8bb6156ec1.1372457176.git.jbaron@akamai.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2013-06-28 at 22:30 +0000, jbaron@akamai.com wrote:
> Make use of the simpler API.

Need to make the change log much more descriptive. Never assume someone
in the future that looks up a change to this file will know about other
commits that led to this. Each change log should be sufficient to stand
on its own.

Explain why this patch is needed. And it's not about the use of a
simpler API.

It actually fixes a real bug.


> 
> Signed-off-by: Jason Baron <jbaron@akamai.com>
> ---
>  net/ipv4/udp.c |    9 ++++-----
>  net/ipv6/udp.c |    9 ++++-----
>  2 files changed, 8 insertions(+), 10 deletions(-)
> 
> diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
> index 0bf5d39..b8d0029 100644
> --- a/net/ipv4/udp.c
> +++ b/net/ipv4/udp.c
> @@ -1421,11 +1421,10 @@ static int __udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
>  
>  }
>  
> -static struct static_key udp_encap_needed __read_mostly;
> +static struct static_key_boolean udp_encap_needed __read_mostly;
>  void udp_encap_enable(void)
>  {
> -	if (!static_key_enabled(&udp_encap_needed))
> -		static_key_slow_inc(&udp_encap_needed);
> +	static_key_slow_set_true(&udp_encap_needed);
>  }
>  EXPORT_SYMBOL(udp_encap_enable);
>  
> @@ -1450,7 +1449,7 @@ int udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
>  		goto drop;
>  	nf_reset(skb);
>  
> -	if (static_key_false(&udp_encap_needed) && up->encap_type) {
> +	if (static_key_false(&udp_encap_needed.key) && up->encap_type) {

I wonder if we should add a static_bool_key_false(), because that added
".key" is a bit confusing.

-- Steve


>  		int (*encap_rcv)(struct sock *sk, struct sk_buff *skb);
>  
>  		/*
> @@ -1773,7 +1772,7 @@ void udp_destroy_sock(struct sock *sk)
>  	bool slow = lock_sock_fast(sk);
>  	udp_flush_pending_frames(sk);
>  	unlock_sock_fast(sk, slow);
> -	if (static_key_false(&udp_encap_needed) && up->encap_type) {
> +	if (static_key_false(&udp_encap_needed.key) && up->encap_type) {
>  		void (*encap_destroy)(struct sock *sk);
>  		encap_destroy = ACCESS_ONCE(up->encap_destroy);
>  		if (encap_destroy)
> diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
> index 42923b1..94a4091 100644
> --- a/net/ipv6/udp.c
> +++ b/net/ipv6/udp.c
> @@ -573,11 +573,10 @@ static __inline__ void udpv6_err(struct sk_buff *skb,
>  	__udp6_lib_err(skb, opt, type, code, offset, info, &udp_table);
>  }
>  
> -static struct static_key udpv6_encap_needed __read_mostly;
> +static struct static_key_boolean udpv6_encap_needed __read_mostly;
>  void udpv6_encap_enable(void)
>  {
> -	if (!static_key_enabled(&udpv6_encap_needed))
> -		static_key_slow_inc(&udpv6_encap_needed);
> +	static_key_slow_set_true(&udpv6_encap_needed);
>  }
>  EXPORT_SYMBOL(udpv6_encap_enable);
>  
> @@ -590,7 +589,7 @@ int udpv6_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
>  	if (!xfrm6_policy_check(sk, XFRM_POLICY_IN, skb))
>  		goto drop;
>  
> -	if (static_key_false(&udpv6_encap_needed) && up->encap_type) {
> +	if (static_key_false(&udpv6_encap_needed.key) && up->encap_type) {
>  		int (*encap_rcv)(struct sock *sk, struct sk_buff *skb);
>  
>  		/*
> @@ -1300,7 +1299,7 @@ void udpv6_destroy_sock(struct sock *sk)
>  	udp_v6_flush_pending_frames(sk);
>  	release_sock(sk);
>  
> -	if (static_key_false(&udpv6_encap_needed) && up->encap_type) {
> +	if (static_key_false(&udpv6_encap_needed.key) && up->encap_type) {
>  		void (*encap_destroy)(struct sock *sk);
>  		encap_destroy = ACCESS_ONCE(up->encap_destroy);
>  		if (encap_destroy)
