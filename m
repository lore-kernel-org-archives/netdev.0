From: YUAN Linyu <Linyu.Yuan@alcatel-sbell.com.cn>
Subject: RE: [RFC] networking: convert many more places to skb_put_zero()
Date: Thu, 15 Jun 2017 00:23:58 +0000
Message-ID: <8729016553E3654398EA69218DA29EEF15BC8D22@cnshjmbx02>
References: <20170614201748.28213-1-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Johannes Berg <johannes.berg@intel.com>
To: Johannes Berg <johannes@sipsolutions.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cnshjsmin03.alcatel-sbell.com.cn ([116.246.26.71]:43923 "EHLO
        cnshjsmin03.alcatel-sbell.com.cn" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750768AbdFOAYB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Jun 2017 20:24:01 -0400
In-Reply-To: <20170614201748.28213-1-johannes@sipsolutions.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, 
Indeed, it find more.
Compare with my patch, still lost pattern like below,
1. sctp and openvswitch
--- a/net/sctp/output.c
+++ b/net/sctp/output.c
@@ -463,7 +463,7 @@ static int sctp_packet_pack(struct sctp_packet *packet,
 
 			padding = SCTP_PAD4(chunk->skb->len) - chunk->skb->len;
 			if (padding)
-				memset(skb_put(chunk->skb, padding), 0, padding);
+				skb_put_zero(chunk->skb, padding);

--- a/net/dsa/tag_trailer.c
+++ b/net/dsa/tag_trailer.c
@@ -43,8 +43,7 @@ static struct sk_buff *trailer_xmit(struct sk_buff *skb, struct net_device *dev)
 	kfree_skb(skb);
 
 	if (padlen) {
-		u8 *pad = skb_put(nskb, padlen);
-		memset(pad, 0, padlen);
+		skb_put_zero(nskb, padlen);

I will send a separate patch for ipv6/ndisc.c once spatch done.



> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
> On Behalf Of Johannes Berg
> Sent: Thursday, June 15, 2017 4:18 AM
> To: netdev@vger.kernel.org
> Cc: Johannes Berg
> Subject: [RFC] networking: convert many more places to skb_put_zero()
> 
> From: Johannes Berg <johannes.berg@intel.com>
> 
> There were many places that my previous spatch didn't find,
> as pointed out by yuan linyu in various patches.
> 
> The following spatch found many more and also removes the
> now unnecessary casts:
> 
>     @@
>     identifier p, p2;
>     expression len;
>     expression skb;
>     type t, t2;
>     @@
>     (
>     -p = skb_put(skb, len);
>     +p = skb_put_zero(skb, len);
>     |
>     -p = (t)skb_put(skb, len);
>     +p = skb_put_zero(skb, len);
>     )
>     (
>     p2 = (t2)p;
>     -memset(p2, 0, len);
>     |
>     -memset(p, 0, len);
>     )
> 
>     @@
>     type t, t2;
>     identifier p, p2;
>     expression skb;
>     @@
>     t *p;
>     ...
>     (
>     -p = skb_put(skb, sizeof(t));
>     +p = skb_put_zero(skb, sizeof(t));
>     |
>     -p = (t *)skb_put(skb, sizeof(t));
>     +p = skb_put_zero(skb, sizeof(t));
>     )
>     (
>     p2 = (t2)p;
>     -memset(p2, 0, sizeof(*p));
>     |
>     -memset(p, 0, sizeof(*p));
>     )
> 
