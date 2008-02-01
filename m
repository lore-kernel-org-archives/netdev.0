From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [RFC PATCH]: TCP + SACK + skb processing latency
Date: Fri, 1 Feb 2008 21:23:07 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0802012121360.12931@kivilampi-30.cs.helsinki.fi>
References: <Pine.LNX.4.64.0802011756140.31652@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/Mixed; boundary="-696243703-367280119-1201882682=:31652"
Cc: David Miller <davem@davemloft.net>
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:36658 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751227AbYBATXJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Feb 2008 14:23:09 -0500
In-Reply-To: <Pine.LNX.4.64.0802011756140.31652@kivilampi-30.cs.helsinki.fi>
Content-ID: <Pine.LNX.4.64.0802012121361.12931@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-367280119-1201882682=:31652
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0802012121362.12931@kivilampi-30.cs.helsinki.fi>

On Fri, 1 Feb 2008, Ilpo Järvinen wrote:

> @@ -1322,6 +1324,206 @@ static int tcp_sacktag_one(struct sk_buff *skb, struct sock *sk,
>  	return flag;
>  }
>  
> +/* Attempts to shift up to shiftlen worth of bytes from prev to skb.
> + * Returns number bytes shifted.
> + *
> + * TODO: in case the prev runs out of frag space, operation could be
> + * made to return with a partial result (would allow tighter packing).
> + */
> +static int skb_shift(struct sk_buff *prev, struct sk_buff *skb,
> +		     unsigned int shiftlen)
> +{
> +	int i, to, merge;
> +	unsigned int todo;
> +	struct skb_frag_struct *from, *fragto;
> +
> +	if (skb_cloned(skb) || skb_cloned(prev))
> +		return 0;
> +
> +	todo = shiftlen;
> +	i = 0;
> +	from = &skb_shinfo(skb)->frags[i];
> +	to = skb_shinfo(prev)->nr_frags;
> +
> +	merge = to - 1;
> +	if (!skb_can_coalesce(prev, merge + 1, from->page, from->page_offset))
> +		merge = -1;
> +	if (merge >= 0) {
> +		i++;
> +		if (from->size >= shiftlen)
> +			goto onlymerge;
> +		todo -= from->size;
> +	}
> +
> +	/* Skip full, not-fitting skb to avoid expensive operations */
> +	if ((shiftlen == skb->len) &&
> +	    (skb_shinfo(skb)->nr_frags - merge) < (MAX_SKB_FRAGS - to))

Before somebody else notices it:
  s/merge/i/, a leftover from flag -> idx conversion.

> +		return 0;
> +
> +	while (todo && (i < skb_shinfo(skb)->nr_frags)) {
> +		if (to == MAX_SKB_FRAGS)
> +			return 0;
> +


-- 
 i.
---696243703-367280119-1201882682=:31652--
