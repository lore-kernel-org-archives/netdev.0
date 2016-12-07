From: Paolo Abeni <pabeni@redhat.com>
Subject: Re: [PATCH net-next] net: sock_rps_record_flow() is for connected
 sockets
Date: Wed, 07 Dec 2016 08:59:11 +0100
Message-ID: <1481097551.5535.14.camel@redhat.com>
References: <1480905784.18162.509.camel@edumazet-glaptop3.roam.corp.google.com>
         <1480944138.4694.37.camel@redhat.com>
         <1480948133.18162.527.camel@edumazet-glaptop3.roam.corp.google.com>
         <1480960639.18162.556.camel@edumazet-glaptop3.roam.corp.google.com>
         <1481020451.6225.38.camel@redhat.com> <1481044098.7129.7.camel@redhat.com>
         <1481046434.18162.599.camel@edumazet-glaptop3.roam.corp.google.com>
         <1481049061.7129.18.camel@redhat.com>
         <1481050715.18162.604.camel@edumazet-glaptop3.roam.corp.google.com>
         <1481051786.7129.22.camel@redhat.com>
         <1481052922.18162.605.camel@edumazet-glaptop3.roam.corp.google.com>
         <1481081570.18162.626.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Willem de Bruijn <willemb@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56662 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751011AbcLGH7O (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 7 Dec 2016 02:59:14 -0500
In-Reply-To: <1481081570.18162.626.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-12-06 at 19:32 -0800, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> Paolo noticed a cache line miss in UDP recvmsg() to access
> sk_rxhash, sharing a cache line with sk_drops.
> 
> sk_drops might be heavily incremented by cpus handling a flood targeting
> this socket.
> 
> We might place sk_drops on a separate cache line, but lets try
> to avoid wasting 64 bytes per socket just for this, since we have
> other bottlenecks to take care of.
> 
> sock_rps_record_flow() should only access sk_rxhash for connected
> flows.
> 
> Testing sk_state for TCP_ESTABLISHED covers most of the cases for
> connected sockets, for a zero cost, since system calls using
> sock_rps_record_flow() also access sk->sk_prot which is on the
> same cache line.
> 
> A follow up patch will provide a static_key (Jump Label) since most
> hosts do not even use RFS.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Paolo Abeni <pabeni@redhat.com>
> ---
>  include/net/sock.h |   12 +++++++++++-
>  1 file changed, 11 insertions(+), 1 deletion(-)
> 
> diff --git a/include/net/sock.h b/include/net/sock.h
> index 6dfe3aa22b970eecfab4d4a0753804b1cc82a200..a7ddab993b496f1f4060f0b41831a161c284df9e 100644
> --- a/include/net/sock.h
> +++ b/include/net/sock.h
> @@ -913,7 +913,17 @@ static inline void sock_rps_record_flow_hash(__u32 hash)
>  static inline void sock_rps_record_flow(const struct sock *sk)
>  {
>  #ifdef CONFIG_RPS
> -	sock_rps_record_flow_hash(sk->sk_rxhash);
> +	/* Reading sk->sk_rxhash might incur an expensive cache line miss.
> +	 *
> +	 * TCP_ESTABLISHED does cover almost all states where RFS
> +	 * might be useful, and is cheaper [1] than testing :
> +	 *	IPv4: inet_sk(sk)->inet_daddr
> +	 * 	IPv6: ipv6_addr_any(&sk->sk_v6_daddr)
> +	 * OR	an additional socket flag
> +	 * [1] : sk_state and sk_prot are in the same cache line.
> +	 */
> +	if (sk->sk_state == TCP_ESTABLISHED)
> +		sock_rps_record_flow_hash(sk->sk_rxhash);
>  #endif
>  }

Thank you for the very prompt patch!

You made me curious about your other idea on this topic, this what you
initially talked about, right ?

LGTM.

Acked-by: Paolo Abeni <pabeni@redhat.com>
