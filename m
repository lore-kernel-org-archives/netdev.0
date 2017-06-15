From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC] networking: convert many more places to skb_put_zero()
Date: Thu, 15 Jun 2017 08:57:42 +0200
Message-ID: <1497509862.2518.1.camel@sipsolutions.net>
References: <20170614201748.28213-1-johannes@sipsolutions.net>
         <8729016553E3654398EA69218DA29EEF15BC8D22@cnshjmbx02>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
To: YUAN Linyu <Linyu.Yuan@alcatel-sbell.com.cn>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:45826 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751141AbdFOG5u (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 15 Jun 2017 02:57:50 -0400
In-Reply-To: <8729016553E3654398EA69218DA29EEF15BC8D22@cnshjmbx02>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-06-15 at 00:23 +0000, YUAN Linyu wrote:
> Hi, 
> Indeed, it find more.
> Compare with my patch, still lost pattern like below,
> 1. sctp and openvswitch
> --- a/net/sctp/output.c
> +++ b/net/sctp/output.c
> @@ -463,7 +463,7 @@ static int sctp_packet_pack(struct sctp_packet
> *packet,
>  
>  			padding = SCTP_PAD4(chunk->skb->len) -
> chunk->skb->len;
>  			if (padding)
> -				memset(skb_put(chunk->skb, padding),
> 0, padding);
> +				skb_put_zero(chunk->skb, padding);

Yep, good catch, this finds 18 instances thereof:

@@
expression skb, len;
@@
-memset(skb_put(skb, len), 0, len);
+skb_put_zero(skb, len);


> --- a/net/dsa/tag_trailer.c
> +++ b/net/dsa/tag_trailer.c
> @@ -43,8 +43,7 @@ static struct sk_buff *trailer_xmit(struct sk_buff
> *skb, struct net_device *dev)
>  	kfree_skb(skb);
>  
>  	if (padlen) {
> -		u8 *pad = skb_put(nskb, padlen);
> -		memset(pad, 0, padlen);
> +		skb_put_zero(nskb, padlen);

I'd have thought it finds this, but indeed it doesn't; there's only one
instances this changes though:

@@
type t;
expression skb, len;
identifier p;
@@
t *p
- = skb_put(skb, len);
+ = skb_put_zero(skb, len);
-memset(p, 0, len);

and it can't figure out that it should remove the variable, without
much more work that's not really worth it for one instance :)

johannes
