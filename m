From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] netlink: align attributes on 64-bits
Date: Mon, 17 Dec 2012 09:59:01 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B70F0@saturn3.aculab.com>
References: <20121211184013.GD27746@casper.infradead.org> <1355491002-3931-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>
To: "Nicolas Dichtel" <nicolas.dichtel@6wind.com>, <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:38518 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751013Ab2LQKJ1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Dec 2012 05:09:27 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 17711-10 for <netdev@vger.kernel.org>;
 Mon, 17 Dec 2012 10:09:24 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <1355491002-3931-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -	if (unlikely(skb_tailroom(skb) < nla_total_size(attrlen)))
> +	int align = IS_ALIGNED((unsigned long)skb_tail_pointer(skb), sizeof(void *)) ? 0 : 4;
> +
> +	if (unlikely(skb_tailroom(skb) < nla_total_size(attrlen) + align))
>  		return -EMSGSIZE;
> 
> +	if (align) {
> +		/* Goal is to add an attribute with size 4. We know that
> +		 * NLA_HDRLEN is 4, hence payload is 0.
> +		 */
> +		__nla_reserve(skb, 0, 0);
> +	}
> +

Shouldn't the size of the dummy parameter be based on the value
of 'align' - and that be based on the amount of padding needed?

That aligns the write pointer, what guarantees the alignment of
the start of the buffer - so that the reader will find aligned data?

What guarantees that the reader will read the data into an
8-byte aligned buffer.

There is also the lurking issue of items that require more
than 8-byte alignment.
(x86/amd64 requires 16-byte alignment for 16-byte SSE2 regs and
32-byte alignment for the AVX regs.)

Will anyone ever want to put such items into a netlink message?

	David
