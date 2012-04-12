From: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
Subject: Re: [PATCH net-next] udp: intoduce udp_encap_needed
	static_key
Date: Thu, 12 Apr 2012 23:35:52 +0900
Message-ID: <20120412143552.GA8730@verge.net.au>
References: <20120412074159.GA10866@verge.net.au>
	<1334218829.5300.5903.camel@edumazet-glaptop>
	<1334221528.5300.6008.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1334221528.5300.6008.camel@edumazet-glaptop>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 12, 2012 at 11:05:28AM +0200, Eric Dumazet wrote:
> Most machines dont use UDP encapsulation (L2TP)
> 
> Adds a static_key so that udp_queue_rcv_skb() doesnt have to perform a
> test if L2TP never setup the encap_rcv on a socket.
> 
> Idea of this patch came after Simon Horman proposal to add a hook on TCP
> as well.
> 
> If static_key is not yet enabled, the fast path does a single JMP .
> 
> When static_key is enabled, JMP destination is patched to reach the real
> encap_type/encap_rcv logic, possibly adding cache misses.

Thanks Eric,

I have not had a chance to test your code, though it should be easy enough
to do so in the context of Open vSwitch as its CAPWAP implementation makes
use of UDP's encap_rcv (which is how I arrived at adding hook to TCP to
implement STT for Open vSwtich).

I have incorporated your static_key code into a new version of my TCP
encap_rcv patch and that does appear to work. I will post it ASAP.

> 
> Signed-off-by: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Cc: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
> Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
> ---
>  include/net/udp.h    |    1 +
>  net/ipv4/udp.c       |   12 +++++++++++-
>  net/l2tp/l2tp_core.c |    1 +
>  3 files changed, 13 insertions(+), 1 deletion(-)
> 
> diff --git a/include/net/udp.h b/include/net/udp.h
> index 5d606d9..9671f5f 100644
> --- a/include/net/udp.h
> +++ b/include/net/udp.h
> @@ -267,4 +267,5 @@ extern void udp_init(void);
>  extern int udp4_ufo_send_check(struct sk_buff *skb);
>  extern struct sk_buff *udp4_ufo_fragment(struct sk_buff *skb,
>  	netdev_features_t features);
> +extern void udp_encap_enable(void);
>  #endif	/* _UDP_H */
> diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
> index fe14105..ad1e0dd 100644
> --- a/net/ipv4/udp.c
> +++ b/net/ipv4/udp.c
> @@ -107,6 +107,7 @@
>  #include <net/checksum.h>
>  #include <net/xfrm.h>
>  #include <trace/events/udp.h>
> +#include <linux/static_key.h>
>  #include "udp_impl.h"
>  
>  struct udp_table udp_table __read_mostly;
> @@ -1379,6 +1380,14 @@ static int __udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
>  
>  }
>  
> +static struct static_key udp_encap_needed __read_mostly;
> +void udp_encap_enable(void)
> +{
> +	if (!static_key_enabled(&udp_encap_needed))
> +		static_key_slow_inc(&udp_encap_needed);
> +}
> +EXPORT_SYMBOL(udp_encap_enable);
> +
>  /* returns:
>   *  -1: error
>   *   0: success
> @@ -1400,7 +1409,7 @@ int udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
>  		goto drop;
>  	nf_reset(skb);
>  
> -	if (up->encap_type) {
> +	if (static_key_false(&udp_encap_needed) && up->encap_type) {
>  		int (*encap_rcv)(struct sock *sk, struct sk_buff *skb);
>  
>  		/*
> @@ -1760,6 +1769,7 @@ int udp_lib_setsockopt(struct sock *sk, int level, int optname,
>  			/* FALLTHROUGH */
>  		case UDP_ENCAP_L2TPINUDP:
>  			up->encap_type = val;
> +			udp_encap_enable();
>  			break;
>  		default:
>  			err = -ENOPROTOOPT;
> diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
> index 89ff8c6..f6732b6 100644
> --- a/net/l2tp/l2tp_core.c
> +++ b/net/l2tp/l2tp_core.c
> @@ -1424,6 +1424,7 @@ int l2tp_tunnel_create(struct net *net, int fd, int version, u32 tunnel_id, u32
>  		/* Mark socket as an encapsulation socket. See net/ipv4/udp.c */
>  		udp_sk(sk)->encap_type = UDP_ENCAP_L2TPINUDP;
>  		udp_sk(sk)->encap_rcv = l2tp_udp_encap_recv;
> +		udp_encap_enable();
>  	}
>  
>  	sk->sk_user_data = tunnel;
> 
> 
