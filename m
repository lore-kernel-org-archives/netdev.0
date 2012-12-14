From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] netlink: align attributes on 64-bits
Date: Fri, 14 Dec 2012 15:49:20 +0000
Message-ID: <1355500160.2626.9.camel@bwh-desktop.uk.solarflarecom.com>
References: <20121211184013.GD27746@casper.infradead.org>
	 <1355491002-3931-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <tgraf@suug.ch>, <netdev@vger.kernel.org>, <davem@davemloft.net>,
	<David.Laight@ACULAB.COM>
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:44590 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756439Ab2LNPt0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Dec 2012 10:49:26 -0500
In-Reply-To: <1355491002-3931-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-12-14 at 14:16 +0100, Nicolas Dichtel wrote:
> On 64 bits arch, we must ensure that attributes are always aligned on 64-bits
> boundary. We do that by adding attributes of type 0, size 4 (alignment on
> 32-bits is already done) when needed. Attribute type 0 should be available and
> unused in all netlink families.
[...]
> --- a/lib/nlattr.c
> +++ b/lib/nlattr.c
> @@ -450,9 +450,18 @@ EXPORT_SYMBOL(__nla_put_nohdr);
>   */
>  int nla_put(struct sk_buff *skb, int attrtype, int attrlen, const void *data)
>  {
> -	if (unlikely(skb_tailroom(skb) < nla_total_size(attrlen)))
> +	int align = IS_ALIGNED((unsigned long)skb_tail_pointer(skb), sizeof(void *)) ? 0 : 4;

The assumption here is that nothing needs to be aligned to a greater
width than that of a pointer.  However, for most 32-bit architectures
(i386 being an exception) the C ABI requires 64-bit alignment for 64-bit
types.  There may be cases where a mostly 32-bit processor really
requires 64-bit alignment, e.g. to load or save a pair of registers.

Ben.

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
>  	__nla_put(skb, attrtype, attrlen, data);
>  	return 0;
>  }

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
