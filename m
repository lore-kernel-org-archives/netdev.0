From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v2] netlink: align attributes on 64-bits
Date: Mon, 17 Dec 2012 17:06:59 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B70F1@saturn3.aculab.com>
References: <1355500160.2626.9.camel@bwh-desktop.uk.solarflarecom.com> <1355762980-4285-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: <tgraf@suug.ch>, <netdev@vger.kernel.org>, <davem@davemloft.net>
To: "Nicolas Dichtel" <nicolas.dichtel@6wind.com>,
	<bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:46214 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752535Ab2LQRMm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Dec 2012 12:12:42 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 06917-07 for <netdev@vger.kernel.org>;
 Mon, 17 Dec 2012 17:12:37 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <1355762980-4285-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>  int nla_put(struct sk_buff *skb, int attrtype, int attrlen, const void *data)
>  {
> -	if (unlikely(skb_tailroom(skb) < nla_total_size(attrlen)))
> +	int align = IS_ALIGNED((unsigned long)skb_tail_pointer(skb), 8) ? 0 : 4;

I've just realised where you are adding this!
You only want to add pad if the attribute is a single 64bit item,
not whenever the destination is misaligned.

Eg what happens if you add a 4-byte item after an 8 byte one.

Are there are attributes that consist of a pair of 4 byte values?

...
> +	if (align) {
> +		/* Goal is to add an attribute with size 4. We know that
> +		 * NLA_HDRLEN is 4, hence payload is 0.
> +		 */
> +		__nla_reserve(skb, 0, 0);

One of those zeros should be 'align - 4', then the comment
can be more descriptive.

	David
