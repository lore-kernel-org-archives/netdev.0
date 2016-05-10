From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH nf-next,v2] gtp: add initial driver for datapath of GPRS
 Tunneling Protocol (GTP-U)
Date: Tue, 10 May 2016 11:54:07 -0700
Message-ID: <1462906447.23934.97.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1462748148-17764-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, laforge@gnumonks.org,
	aschultz@tpip.net, openbsc@lists.osmocom.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:32953 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752909AbcEJSyK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2016 14:54:10 -0400
Received: by mail-pa0-f45.google.com with SMTP id xk12so8518644pac.0
        for <netdev@vger.kernel.org>; Tue, 10 May 2016 11:54:09 -0700 (PDT)
In-Reply-To: <1462748148-17764-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-05-09 at 00:55 +0200, Pablo Neira Ayuso wrote:

> +static int gtp1u_udp_encap_recv(struct gtp_dev *gtp, struct sk_buff *skb,
> +				bool xnet)
> +{
> +	unsigned int hdrlen = sizeof(struct udphdr) +
> +			      sizeof(struct gtp1_header);
> +	struct gtp1_header *gtp1;
> +	struct pdp_ctx *pctx;
> +	int ret = 0;
> +
> +	if (!pskb_may_pull(skb, hdrlen))
> +		return -1;
> +
> +	gtp1 = (struct gtp1_header *)(skb->data + sizeof(struct udphdr));
> +
> +	if ((gtp1->flags >> 5) != GTP_V1)
> +		return 1;
> +
> +	if (gtp1->type != GTP_TPDU)
> +		return 1;
> +
> +	/* From 29.060: "This field shall be present if and only if any one or
> +	 * more of the S, PN and E flags are set.".
> +	 *
> +	 * If any of the bit is set, then the remaining ones also have to be
> +	 * set.
> +	 */
> +	if (gtp1->flags & GTP1_F_MASK)
> +		hdrlen += 4;
> +
> +	/* Make sure the header is larger enough, including extensions. */
> +	if (!pskb_may_pull(skb, hdrlen))
> +		return -1;

You need to reload gtp1 here, as the previous pskb_may_pull() might have
reallocated skb->head

> +
> +	rcu_read_lock();
> +	pctx = gtp1_pdp_find(gtp, ntohl(gtp1->tid));

Or risk a use after free here.

> +	if (!pctx) {
> +		netdev_dbg(gtp->dev, "No PDP ctx to decap skb=%p\n", skb);
> +		ret = -1;
> +		goto out_rcu;
> +	}
> +
> +	if (!gtp_check_src_ms(skb, pctx, hdrlen)) {
> +		netdev_dbg(gtp->dev, "No PDP ctx for this MS\n");
> +		ret = -1;
> +		goto out_rcu;
> +	}
> +	rcu_read_unlock();
> +
> +	/* Get rid of the GTP + UDP headers. */
> +	return iptunnel_pull_header(skb, hdrlen, skb->protocol, xnet);
> +out_rcu:
> +	rcu_read_unlock();
> +	return ret;
> +}
