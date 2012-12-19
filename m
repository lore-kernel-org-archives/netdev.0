From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH v2] netlink: align attributes on 64-bits
Date: Wed, 19 Dec 2012 17:09:12 +0000
Message-ID: <20121219170912.GB6975@casper.infradead.org>
References: <1355500160.2626.9.camel@bwh-desktop.uk.solarflarecom.com>
 <1355762980-4285-1-git-send-email-nicolas.dichtel@6wind.com>
 <20121218125735.GG27746@casper.infradead.org>
 <50D1A37C.8090705@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org,
	davem@davemloft.net, David.Laight@ACULAB.COM
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:35584 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751622Ab2LSRJR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Dec 2012 12:09:17 -0500
Content-Disposition: inline
In-Reply-To: <50D1A37C.8090705@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/19/12 at 12:22pm, Nicolas Dichtel wrote:
> Here padlen will return 4, which is wrong: padlen + NLA_HDRLEN = 8,
> alignment is the same than before. Here is a proposal fix:
> 
> diff --git a/lib/nlattr.c b/lib/nlattr.c
> index e4f0329..1556313 100644
> --- a/lib/nlattr.c
> +++ b/lib/nlattr.c
> @@ -338,7 +338,10 @@ struct nlattr *__nla_reserve(struct sk_buff
> *skb, int attrtype, int attrlen)
>  		struct nlattr *pad;
>  		size_t padlen;
> 
> -		padlen = nla_total_size(offset) - offset -  NLA_HDRLEN;
> +		/* We need to remove NLA_HDRLEN two times: one time for the
> +		 * attribute hdr and one time for the pad attribute hdr.
> +		 */
> +		padlen = nla_total_size(offset) - offset -  2 * NLA_HDRLEN;
>  		pad = (struct nlattr *) skb_put(skb, nla_attr_size(padlen));
>  		pad->nla_type = 0;
>  		pad->nla_len = nla_attr_size(padlen);
> 
> With this patch, it seems goods. attribute are always aligned on 8 bytes. Also
> I did not notice any problem with size calculation (I try some ip
> link, ip xfrm, ip [m]route).
> 
> Do you want to make more tests? Or will your repost the full patch?
> I can do it if you don't have time.

Thanks.

I would like to do some testing as well. I do expect some fallout from
this. There is likely some interface abuse that will now be exposed
due to this.

We'll have to wait for the next merge window to open anyway. I'd
consider this a new feature and not a bugfix based on the possible
regression impact it could have.

I'll post a new version of the patch integrating your fix above so
others (especially subsystem maintainers depending on netlink) can run
the patch as well.
