From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [RFC PATCH v2 net-next 4/7] tcp: Make use of MSG_EOR flag in
 tcp_sendmsg
Date: Mon, 18 Apr 2016 20:18:11 -0700
Message-ID: <20160419031811.GA36188@ashokk-mba.local.DHCP.thefacebook.com>
References: <1461019569-3037369-1-git-send-email-kafai@fb.com>
 <1461019569-3037369-5-git-send-email-kafai@fb.com>
 <1461021493.10638.131.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160418234202.GA27948@kafai-mba.local>
 <1461024417.10638.141.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160419022704.GB35817@dreloong-mbp.local.DHCP.thefacebook.com>
 <1461034241.10638.145.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, Eric Dumazet <edumazet@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Soheil Hassas Yeganeh <soheil.kdev@gmail.com>,
	Willem de Bruijn <willemb@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Kernel Team <kernel-team@fb.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:56651 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752108AbcDSDSZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Apr 2016 23:18:25 -0400
Content-Disposition: inline
In-Reply-To: <1461034241.10638.145.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 18, 2016 at 07:50:41PM -0700, Eric Dumazet wrote:
> I believe it is slightly wrong (to do the goto new_segment if there is
> no data to send)
Aha. Thanks for pointing it out.

>
> I would instead use this fast path, doing the test _when_ we already
> have an skb to test for.
The v1 was doing a check in the loop but the feedback was, instead
of doing this unlikely(test) repeatedly in the loop, do it before
entering the loop and do a goto new_segment if needed.

I agree that doing it in the loop is easier to follow/read
and checking TCP_SKB_CB(skb)->eor is cheaper than my v1.
I will respin with your suggestion.

> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> index 6451b83d81e9..acfbff81ef47 100644
> --- a/net/ipv4/tcp_output.c
> +++ b/net/ipv4/tcp_output.c
> @@ -1171,6 +1171,8 @@ int tcp_fragment(struct sock *sk, struct sk_buff *skb, u32 len,
>  	TCP_SKB_CB(skb)->tcp_flags = flags & ~(TCPHDR_FIN | TCPHDR_PSH);
>  	TCP_SKB_CB(buff)->tcp_flags = flags;
>  	TCP_SKB_CB(buff)->sacked = TCP_SKB_CB(skb)->sacked;
> +	TCP_SKB_CB(buff)->eor = TCP_SKB_CB(skb)->eor;
> +	TCP_SKB_CB(skb)->eor = 0;
>
>  	if (!skb_shinfo(skb)->nr_frags && skb->ip_summed != CHECKSUM_PARTIAL) {
>  		/* Copy and checksum data tail into the new buffer. */
> @@ -1730,6 +1732,8 @@ static int tso_fragment(struct sock *sk, struct sk_buff *skb, unsigned int len,
>
>  	/* This packet was never sent out yet, so no SACK bits. */
>  	TCP_SKB_CB(buff)->sacked = 0;
> +	TCP_SKB_CB(buff)->eor = TCP_SKB_CB(skb)->eor;
> +	TCP_SKB_CB(skb)->eor = 0;
>
>  	buff->ip_summed = skb->ip_summed = CHECKSUM_PARTIAL;
>  	skb_split(skb, buff, len);
> @@ -2471,6 +2475,7 @@ static void tcp_collapse_retrans(struct sock *sk, struct sk_buff *skb)
>
>  	/* Merge over control information. This moves PSH/FIN etc. over */
>  	TCP_SKB_CB(skb)->tcp_flags |= TCP_SKB_CB(next_skb)->tcp_flags;
> +	TCP_SKB_CB(skb)->eor = TCP_SKB_CB(next_skb)->eor;
>
>  	/* All done, get rid of second SKB and account for it so
>  	 * packet counting does not break.
> @@ -2502,7 +2507,8 @@ static bool tcp_can_collapse(const struct sock *sk, const struct sk_buff *skb)
>  	/* Some heurestics for collapsing over SACK'd could be invented */
>  	if (TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_ACKED)
>  		return false;
> -
> +	if (TCP_SKB_CB(skb)->eor)
> +		return false;
>  	return true;
>  }
Thanks for this diff.  It confirms that I probably understand your last
suggestion correctly.  I also have similar diff for the sacks handling.
