From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next v2 1/6] skbuff: Add skb_list_linearize()
Date: Fri, 30 Jan 2015 21:32:16 +0300
Message-ID: <54CBCE30.1000906@cogentembedded.com>
References: <1422574164-1860-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Pravin B Shelar <pshelar@nicira.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f49.google.com ([209.85.215.49]:36141 "EHLO
	mail-la0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932434AbbA3ScU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jan 2015 13:32:20 -0500
Received: by mail-la0-f49.google.com with SMTP id gf13so25079523lab.8
        for <netdev@vger.kernel.org>; Fri, 30 Jan 2015 10:32:19 -0800 (PST)
In-Reply-To: <1422574164-1860-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 01/30/2015 02:29 AM, Pravin B Shelar wrote:

> similar to skb_linearize(), this API takes skb list as arg and
> linearize it into one big skb. STT driver patch will use this.

> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>

[...]

> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index 56db472..d6358a7 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -2329,6 +2329,40 @@ void skb_copy_and_csum_dev(const struct sk_buff *skb, u8 *to)
>   }
>   EXPORT_SYMBOL(skb_copy_and_csum_dev);
>
> +int skb_list_linearize(struct sk_buff *head, gfp_t gfp_mask)
> +{
> +	struct sk_buff *skb;
> +	int tlen = 0;
> +	int err;
> +
> +	err = skb_linearize(head);
> +	if (err)
> +		return err;
> +
> +	skb = head->next;
> +	while (skb) {
> +		tlen += skb->len;
> +		skb = skb->next;
> +	}

	for (skb = head->next; skb; skb = skb->next)
		tlen += skb->len;

> +	err = pskb_expand_head(head, 0, tlen, gfp_mask);
> +	if (err)
> +		return err;
> +
> +	skb = head->next;
> +	while (skb) {
> +		err = skb_copy_bits(skb, 0, skb_tail_pointer(head), skb->len);
> +		if (err)
> +			return err;
> +		head->tail += skb->len;
> +		skb = skb->next;
> +	}

    Likewise, this can easily be converted into a *for* loop.

[...]

WBR, Sergei
