From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [RFC PATCH net] tcp: Update pcount after skb_pull() during mtu
 probing
Date: Fri, 5 Jun 2015 11:02:55 -0700
Message-ID: <20150605180254.GC2951343@devbig242.prn2.facebook.com>
References: <1433521014-2465771-1-git-send-email-kafai@fb.com>
 <CANn89iLd1bqCOxbALcDNzi--Hn8A970HmvM2__ryzjwSbOwZ6Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: netdev <netdev@vger.kernel.org>, Kernel Team <kernel-team@fb.com>,
	Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:31945 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751765AbbFESDG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Jun 2015 14:03:06 -0400
Content-Disposition: inline
In-Reply-To: <CANn89iLd1bqCOxbALcDNzi--Hn8A970HmvM2__ryzjwSbOwZ6Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 05, 2015 at 09:53:51AM -0700, Eric Dumazet wrote:
> Sounds good, although I would simply get rid of all this complexity in
> this very unlikely path.
> 
> Would you instead try the following ?
> 
> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> index eeb59befaf06867b00e1dd6ded7742b2f0bcd821..41ef2c96b2e810e289d6d773e4be09c493b99c09
> 100644
> --- a/net/ipv4/tcp_output.c
> +++ b/net/ipv4/tcp_output.c
> @@ -1987,16 +1987,7 @@ static int tcp_mtu_probe(struct sock *sk)
>                 } else {
>                         TCP_SKB_CB(nskb)->tcp_flags |=
> TCP_SKB_CB(skb)->tcp_flags &
>                                                    ~(TCPHDR_FIN|TCPHDR_PSH);
> -                       if (!skb_shinfo(skb)->nr_frags) {
> -                               skb_pull(skb, copy);
> -                               if (skb->ip_summed != CHECKSUM_PARTIAL)
> -                                       skb->csum = csum_partial(skb->data,
> -                                                                skb->len, 0);
> -                       } else {
> -                               __pskb_trim_head(skb, copy);
> -                               tcp_set_skb_tso_segs(sk, skb, mss_now);
> -                       }
> -                       TCP_SKB_CB(skb)->seq += copy;
> +                       tcp_trim_head(sk, skb, copy);
tcp_trim_head() does not take the mss_now.
Is it fine to have mss_now <= tcp_skb_mss(skb)? or we can depend on
the tcp_init_tso_segs() in the tcp_write_xmit() to take care of it?
