From: Eric Dumazet <edumazet@google.com>
Subject: Re: [RFC PATCH net] tcp: Update pcount after skb_pull() during mtu probing
Date: Fri, 5 Jun 2015 09:53:51 -0700
Message-ID: <CANn89iLd1bqCOxbALcDNzi--Hn8A970HmvM2__ryzjwSbOwZ6Q@mail.gmail.com>
References: <1433521014-2465771-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, Kernel Team <kernel-team@fb.com>,
	Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: Martin KaFai Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:32993 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752799AbbFEQxw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Jun 2015 12:53:52 -0400
Received: by igbpi8 with SMTP id pi8so19727422igb.0
        for <netdev@vger.kernel.org>; Fri, 05 Jun 2015 09:53:52 -0700 (PDT)
In-Reply-To: <1433521014-2465771-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 5, 2015 at 9:16 AM, Martin KaFai Lau <kafai@fb.com> wrote:
> The problem is caught by this WARN_ON(len > skb->len) in tcp_fragment():
>
> [<ffffffff810510ca>] warn_slowpath_null+0x1a/0x20
> [<ffffffff8160ec90>] tcp_fragment+0x2a0/0x2b0
> [<ffffffff81604e06>] tcp_mark_head_lost+0x196/0x230
> [<ffffffff8160585d>] tcp_update_scoreboard+0x4d/0x80
> [<ffffffff8160a9ac>] tcp_fastretrans_alert+0x6ac/0xa90
> [<ffffffff8160b834>] tcp_ack+0x9d4/0x10e0
> [<ffffffff8160c699>] tcp_rcv_established+0x309/0x7e0
>
> The WARN_ON pointed out that tcp_skb_pcount (i.e.
> TCP_SKB_CB(skb)->tcp_gso_segs) and skb->len is inconsistent.
>
> The WARN_ON stack goes away after setting net.ipv4.tcp_mtu_probing to 0.
>
> This patch is to set the pcount after skb_pull() was called
> in tcp_mtu_probe().
>
> Signed-off-by: Martin KaFai Lau <kafai@fb.com>
> Reported-by: Grant Zhang <gzhang@fastly.com>
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: Neal Cardwell <ncardwell@google.com>
> Cc: Yuchung Cheng <ycheng@google.com>
> ---
>  net/ipv4/tcp_output.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
>
> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> index a369e8a..6c95c28 100644
> --- a/net/ipv4/tcp_output.c
> +++ b/net/ipv4/tcp_output.c
> @@ -1984,8 +1984,9 @@ static int tcp_mtu_probe(struct sock *sk)
>                                                                  skb->len, 0);
>                         } else {
>                                 __pskb_trim_head(skb, copy);
> -                               tcp_set_skb_tso_segs(sk, skb, mss_now);
>                         }
> +                       tcp_set_skb_tso_segs(sk, skb, mss_now);
> +
>                         TCP_SKB_CB(skb)->seq += copy;
>                 }
>
>

Sounds good, although I would simply get rid of all this complexity in
this very unlikely path.

Would you instead try the following ?

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index eeb59befaf06867b00e1dd6ded7742b2f0bcd821..41ef2c96b2e810e289d6d773e4be09c493b99c09
100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1987,16 +1987,7 @@ static int tcp_mtu_probe(struct sock *sk)
                } else {
                        TCP_SKB_CB(nskb)->tcp_flags |=
TCP_SKB_CB(skb)->tcp_flags &
                                                   ~(TCPHDR_FIN|TCPHDR_PSH);
-                       if (!skb_shinfo(skb)->nr_frags) {
-                               skb_pull(skb, copy);
-                               if (skb->ip_summed != CHECKSUM_PARTIAL)
-                                       skb->csum = csum_partial(skb->data,
-                                                                skb->len, 0);
-                       } else {
-                               __pskb_trim_head(skb, copy);
-                               tcp_set_skb_tso_segs(sk, skb, mss_now);
-                       }
-                       TCP_SKB_CB(skb)->seq += copy;
+                       tcp_trim_head(sk, skb, copy);
                }

                len += copy;
