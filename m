From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [PATCH 6/8] tcp: Add GRO support
Date: Fri, 12 Dec 2008 22:56:15 +0300
Message-ID: <20081212195615.GC27281@ioremap.net>
References: <20081212053116.GA2927@gondor.apana.org.au> <E1LB0d1-0000rd-B2@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cet.com.ru ([195.178.208.66]:40015 "EHLO tservice.net.ru"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753397AbYLLT4Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Dec 2008 14:56:16 -0500
Content-Disposition: inline
In-Reply-To: <E1LB0d1-0000rd-B2@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 12, 2008 at 04:31:55PM +1100, Herbert Xu (herbert@gondor.apana.org.au) wrote:
> +struct sk_buff **tcp_gro_receive(struct sk_buff **head, struct sk_buff *skb)
> +{
> +	struct sk_buff **pp = NULL;
> +	struct sk_buff *p;
> +	struct tcphdr *th;
> +	struct tcphdr *th2;
> +	unsigned int thlen;
> +	unsigned int flags;
> +	unsigned int total;
> +	unsigned int mss = 1;
> +	int flush = 1;
> +
> +	if (!pskb_may_pull(skb, sizeof(*th)))
> +		goto out;
> +
> +	th = tcp_hdr(skb);
> +	thlen = th->doff * 4;
> +	if (thlen < sizeof(*th))
> +		goto out;
> +
> +	if (!pskb_may_pull(skb, thlen))
> +		goto out;
> +
> +	th = tcp_hdr(skb);
> +	__skb_pull(skb, thlen);
> +
> +	flags = tcp_flag_word(th);
> +
> +	for (; (p = *head); head = &p->next) {
> +		if (!NAPI_GRO_CB(p)->same_flow)
> +			continue;
> +
> +		th2 = tcp_hdr(p);
> +
> +		if (th->source != th2->source || th->dest != th2->dest) {
> +			NAPI_GRO_CB(p)->same_flow = 0;
> +			continue;
> +		}
> +
> +		goto found;
> +	}
> +
> +	goto out_check_final;
> +
> +found:
> +	flush = NAPI_GRO_CB(p)->flush;
> +	flush |= flags & TCP_FLAG_CWR;
> +	flush |= (flags ^ tcp_flag_word(th2)) &
> +		  ~(TCP_FLAG_CWR | TCP_FLAG_FIN | TCP_FLAG_PSH);
> +	flush |= th->ack_seq != th2->ack_seq || th->window != th2->window;
> +	flush |= memcmp(th + 1, th2 + 1, thlen - sizeof(*th));
> +
> +	total = p->len;
> +	mss = total;
> +	if (skb_shinfo(p)->frag_list)
> +		mss = skb_shinfo(p)->frag_list->len;
> +
> +	flush |= skb->len > mss || skb->len <= 0;
> +	flush |= ntohl(th2->seq) + total != ntohl(th->seq);
> +

No timestamp check?

> +	if (flush || skb_gro_receive(head, skb)) {
> +		mss = 1;
> +		goto out_check_final;
> +	}
> +
> +	p = *head;
> +	th2 = tcp_hdr(p);
> +	tcp_flag_word(th2) |= flags & (TCP_FLAG_FIN | TCP_FLAG_PSH);
> +
> +out_check_final:
> +	flush = skb->len < mss;
> +	flush |= flags & (TCP_FLAG_URG | TCP_FLAG_PSH | TCP_FLAG_RST |
> +			  TCP_FLAG_SYN | TCP_FLAG_FIN);
> +
> +	if (p && (!NAPI_GRO_CB(skb)->same_flow || flush))
> +		pp = head;
> +
> +out:
> +	NAPI_GRO_CB(skb)->flush |= flush;
> +
> +	return pp;
> +}

-- 
	Evgeniy Polyakov
