From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH RFC 1/2] net/802: Implement Multiple Registration
 Protocol (MRP)
Date: Mon, 24 Sep 2012 23:36:48 +0200
Message-ID: <1348522608.26828.1791.camel@edumazet-glaptop>
References: <1348520855-8810-1-git-send-email-david.ward@ll.mit.edu>
	 <1348520855-8810-2-git-send-email-david.ward@ll.mit.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	Philip Foulkes <philip.foulkes@gmail.com>
To: David Ward <david.ward@ll.mit.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:43527 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750732Ab2IXVgw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Sep 2012 17:36:52 -0400
Received: by bkcjk13 with SMTP id jk13so1198582bkc.19
        for <netdev@vger.kernel.org>; Mon, 24 Sep 2012 14:36:51 -0700 (PDT)
In-Reply-To: <1348520855-8810-2-git-send-email-david.ward@ll.mit.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-09-24 at 17:07 -0400, David Ward wrote:

...

> +static int mrp_pdu_parse_end_mark(struct sk_buff *skb)
> +{
> +	__be16 *endmark;
> +
> +	if (!pskb_may_pull(skb, sizeof(*endmark)))
> +		return -1;
> +	endmark = (__be16 *)skb->data;
> +	if (get_unaligned(endmark) == MRP_END_MARK) {

You might try get_unaligned_be16(skb->data) ...

> +		skb_pull(skb, sizeof(*endmark));
> +		return -1;
> +	}
> +	return 0;
> +}
> +

...

> +
> +static int mrp_pdu_parse_msg(struct mrp_applicant *app, struct sk_buff *skb)
> +{
> +	if (!pskb_may_pull(skb, sizeof(*mrp_cb(skb)->mh)))
> +		return -1;
> +	mrp_cb(skb)->mh = (struct mrp_msg_hdr *)skb->data;

here you store a pointer to skb->data, in skb>cb[]

> +	if (mrp_cb(skb)->mh->attrtype == 0 ||
> +	    mrp_cb(skb)->mh->attrtype > app->app->maxattr ||
> +	    mrp_cb(skb)->mh->attrlen == 0)
> +		return -1;
> +	if (sizeof(struct mrp_skb_cb) + mrp_cb(skb)->mh->attrlen >
> +	    FIELD_SIZEOF(struct sk_buff, cb))
> +		return -1;
> +	skb_pull(skb, sizeof(*mrp_cb(skb)->mh));
> +
> +	while (skb->len > 0) {
> +		if (mrp_pdu_parse_end_mark(skb) < 0)
> +			break;

but skb->head can be reallocated by other pskb_may_pull() calls
done in mrp_pdu_parse_end_mark() (and elsewhere)

So skb->cb[] might contain a pointer to a freed memory.

> +		if (mrp_pdu_parse_vecattr(app, skb) < 0)
> +			return -1;
> +	}
> +	return 0;
> +}
> +

You might consider using skb_header_pointer() instead of
pskb_may_pull()/skb_pull(), it might be easier when you have such nested
headers...
