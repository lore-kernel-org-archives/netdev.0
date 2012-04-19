From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH v2 net-next] tcp: avoid expensive pskb_expand_head()
 calls
Date: Thu, 19 Apr 2012 14:10:38 +0300 (EEST)
Message-ID: <alpine.DEB.2.00.1204191401240.735@wel-95.cs.helsinki.fi>
References: <1334653608.6226.11.camel@edumazet-laptop>  <1334654187.2696.2.camel@jtkirshe-mobl> <4F8D93E1.9090000@intel.com>  <1334681204.2472.41.camel@edumazet-glaptop>  <1334698722.2472.71.camel@edumazet-glaptop>  <1334764184.2472.299.camel@edumazet-glaptop>
  <CADVnQy=BkhSBHyN2hyBy=_H64oM8sJvyZZfEjK1x7PYzoLv=5w@mail.gmail.com>  <1334776707.2472.316.camel@edumazet-glaptop> <1334778707.2472.333.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="8323329-435283616-1334833525=:735"
Cc: Neal Cardwell <ncardwell@google.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>,
	"=?ISO-8859-2?Q?Maciej_=AFenczykowski?=" <maze@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:55792 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754011Ab2DSLKk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Apr 2012 07:10:40 -0400
In-Reply-To: <1334778707.2472.333.camel@edumazet-glaptop>
Content-ID: <alpine.DEB.2.00.1204191405580.735@wel-95.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323329-435283616-1334833525=:735
Content-Type: TEXT/PLAIN; charset=ISO-8859-2
Content-Transfer-Encoding: 8BIT
Content-ID: <alpine.DEB.2.00.1204191405581.735@wel-95.cs.helsinki.fi>

On Wed, 18 Apr 2012, Eric Dumazet wrote:

> From: Eric Dumazet <edumazet@google.com>
> 
> While doing netperf sessions on 10Gb Intel nics (ixgbe), I noticed
> unexpected profiling results, with pskb_expand_head() being in the top.
> 
> After further analysis, I found we hit badly page refcounts,
> because when we transmit full size skb (64 KB), we can receive ACK for
> the first segments of the frame while skb was not completely sent by
> NIC.
> 
> It takes ~54 us to send a full TSO packet at 10Gb speed, but with a
> close peer, we can receive TCP ACK in less than 50 us rtt.
> 
> This is also true on 1Gb links but we were limited by wire speed, not
> cpu.
> 
> When we try to trim skb, tcp_trim_head() has to call pskb_expand_head(),
> because the skb clone we did for transmit is still alive in TX ring
> buffer.
> 
> pskb_expand_head() is really expensive : It has to make about 16+16
> atomic operations on page refcounts, not counting the skb head
> reallocation/copy. It increases chances of false sharing.
> 
> In fact, we dont really need to trim skb. This costly operation can be
> delayed to the point it is really needed : Thats when a retransmit must
> happen.
> 
> Most of the time, upcoming ACKS will ack the whole packet, and we can
> free it with minimal cost (since clone was already freed by TX
> completion)
> 
> Of course, this means we dont uncharge the acked part from socket limits
> until retransmit, but this is hardly a concern with current autotuning
> (around 4MB per socket)
> Even with small cwnd limit, a single packet can not hold more than half
> the window.
> 
> Performance results on my Q6600 cpu and 82599EB 10-Gigabit card :
> About 3% less cpu used for same workload (single netperf TCP_STREAM),
> bounded by x4 PCI-e slots (4660 Mbits).
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Tom Herbert <therbert@google.com>
> Cc: Neal Cardwell <ncardwell@google.com>
> Cc: Maciej ¯enczykowski <maze@google.com>
> Cc: Yuchung Cheng <ycheng@google.com>
> ---
> v2 : added Neal suggestions
> 
>  include/net/tcp.h     |    6 ++++--
>  net/ipv4/tcp_input.c  |   22 +++++++++++-----------
>  net/ipv4/tcp_output.c |   25 +++++++++++++++++--------
>  3 files changed, 32 insertions(+), 21 deletions(-)
> 
> diff --git a/include/net/tcp.h b/include/net/tcp.h
> index d5984e3..0f57706 100644
> --- a/include/net/tcp.h
> +++ b/include/net/tcp.h
> @@ -477,7 +477,8 @@ extern int tcp_retransmit_skb(struct sock *, struct sk_buff *);
>  extern void tcp_retransmit_timer(struct sock *sk);
>  extern void tcp_xmit_retransmit_queue(struct sock *);
>  extern void tcp_simple_retransmit(struct sock *);
> -extern int tcp_trim_head(struct sock *, struct sk_buff *, u32);
> +extern void tcp_set_skb_tso_segs(const struct sock *sk, struct sk_buff *skb,
> +				 unsigned int mss_now);
>  extern int tcp_fragment(struct sock *, struct sk_buff *, u32, unsigned int);
>  
>  extern void tcp_send_probe0(struct sock *);
> @@ -640,7 +641,8 @@ struct tcp_skb_cb {
>  #if IS_ENABLED(CONFIG_IPV6)
>  		struct inet6_skb_parm	h6;
>  #endif
> -	} header;	/* For incoming frames		*/
> +		unsigned int offset_ack; /* part of acked data in this skb */
> +	} header;
>  	__u32		seq;		/* Starting sequence number	*/
>  	__u32		end_seq;	/* SEQ + FIN + SYN + datalen	*/
>  	__u32		when;		/* used to compute rtt's	*/
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index 99448f0..bdec2e6 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -3260,25 +3260,25 @@ static void tcp_rearm_rto(struct sock *sk)
>  	}
>  }
>  
> -/* If we get here, the whole TSO packet has not been acked. */
> +/* If we get here, the whole packet has not been acked.
> + * We used to call tcp_trim_head() to remove acked data from skb,
> + * but its expensive with TSO if our previous clone is still in flight.
> + * We thus maintain an offset_ack, and hope no pskb_expand_head()
> + * is needed until whole packet is acked by upcoming ACKs.
> + */
>  static u32 tcp_tso_acked(struct sock *sk, struct sk_buff *skb)
>  {
>  	struct tcp_sock *tp = tcp_sk(sk);
> -	u32 packets_acked;
> +	u32 oldpcount = tcp_skb_pcount(skb);
>  
>  	BUG_ON(!after(TCP_SKB_CB(skb)->end_seq, tp->snd_una));
>  
> -	packets_acked = tcp_skb_pcount(skb);
> -	if (tcp_trim_head(sk, skb, tp->snd_una - TCP_SKB_CB(skb)->seq))
> -		return 0;
> -	packets_acked -= tcp_skb_pcount(skb);
> +	TCP_SKB_CB(skb)->header.offset_ack = tp->snd_una - TCP_SKB_CB(skb)->seq;

Now that you have non-zero offset_ack, are the tcp_fragment() callsites 
safe and working? ...I'm mostly worried about tcp_mark_head_lost which 
does some assumptions about tp->snd_una and TCP_SKB_CB(skb)->seq, however, 
also other fragmenting does not preserve offset_ack properly (which might 
not be end of world though)?

-- 
 i.
--8323329-435283616-1334833525=:735--
