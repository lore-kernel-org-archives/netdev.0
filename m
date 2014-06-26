From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH] net: fix setting csum_start in skb_segment()
Date: Wed, 25 Jun 2014 19:15:52 -0700
Message-ID: <CA+mtBx9gYcG02NQ71BoWkfBMQm++RVYg=yXV25cg5DQAwYNaKA@mail.gmail.com>
References: <alpine.DEB.2.02.1406242056330.29780@tomh.mtv.corp.google.com>
	<1403725861.3796.47.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	davej@redhat.com, Andrew Morton <akpm@linux-foundation.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1403725861.3796.47.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 25, 2014 at 12:51 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Tom Herbert <therbert@google.com>
>
> Dave Jones reported that a crash is occurring in
>
> csum_partial
> tcp_gso_segment
> inet_gso_segment
> ? update_dl_migration
> skb_mac_gso_segment
> __skb_gso_segment
> dev_hard_start_xmit
> sch_direct_xmit
> __dev_queue_xmit
> ? dev_hard_start_xmit
> dev_queue_xmit
> ip_finish_output
> ? ip_output
> ip_output
> ip_forward_finish
> ip_forward
> ip_rcv_finish
> ip_rcv
> __netif_receive_skb_core
> ? __netif_receive_skb_core
> ? trace_hardirqs_on
> __netif_receive_skb
> netif_receive_skb_internal
> napi_gro_complete
> ? napi_gro_complete
> dev_gro_receive
> ? dev_gro_receive
> napi_gro_receive
>
> It looks like a likely culprit is that SKB_GSO_CB()->csum_start is
> not set correctly when doing non-scatter gather. We are using
> offset as opposed to doffset.
>
Acked-by: Tom Herbert <therbert@google.com>

> Reported-by: Dave Jones <davej@redhat.com>
> Tested-by: Dave Jones <davej@redhat.com>
> Signed-off-by: Tom Herbert <therbert@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Fixes: 7e2b10c1e52ca ("net: Support for multiple checksums with gso")
> ---
>  net/core/skbuff.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index 9cd5344fad73..c1a33033cbe2 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -2993,7 +2993,7 @@ struct sk_buff *skb_segment(struct sk_buff *head_skb,
>                                                             skb_put(nskb, len),
>                                                             len, 0);
>                         SKB_GSO_CB(nskb)->csum_start =
> -                           skb_headroom(nskb) + offset;
> +                           skb_headroom(nskb) + doffset;
>                         continue;
>                 }
>
>
>
