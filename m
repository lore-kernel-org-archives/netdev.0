From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] ipv6: check if dereference of ipv6 header is safe
Date: Fri, 18 Jan 2013 03:06:12 +0100
Message-ID: <20130118020612.GA14833@order.stressinduktion.org>
References: <20130117035652.GB23782@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:35135 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752781Ab3ARCGN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2013 21:06:13 -0500
Content-Disposition: inline
In-Reply-To: <20130117035652.GB23782@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 17, 2013 at 04:56:52AM +0100, Hannes Frederic Sowa wrote:
> When ipip6_rcv gets called we are sure that we have a full blown
> ipv4 packet header in the linear skb buffer (this is checked by
> xfrm4_mode_tunnel_input). Because we dereference fields of the inner
> ipv6 header we should actually check for the length of the sum of the
> ipv4 and ipv6 header.
> 
> If the skb is too short this packet could very well be destined for
> another tunnel. So we should notify the caller accordingly (albeit
> currently xfrm4_mode_tunnel_input does not care; this could need another
> patch).

While grepping for xfrm_tunnel and handler I studied the wrong
call stack. ipip6_rcv is not called by xfrm_mode_tunnel_input but by
tunnel64_rcv. This function already ensures that we can safely dereference
the ipv6 header. I got confused by xfrm_mode_tunnel only checking for
the size of an ipv4 header and assumed that the data section of the
skb had not been rolled forward. This patch brings ipip6_rcv in line
with ipip_rcv.

This patch superseds the old one:

[PATCH] ipv6: remove unneeded check to pskb_may_pull

This is already checked by the caller (tunnel64_rcv) and brings ipip6_rcv
in line with ipip_rcv.

Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv6/sit.c | 7 +------
 1 file changed, 1 insertion(+), 6 deletions(-)

diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index cfba99b..98fe536 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -592,15 +592,10 @@ out:
 
 static int ipip6_rcv(struct sk_buff *skb)
 {
-	const struct iphdr *iph;
+	const struct iphdr *iph = ip_hdr(skb);
 	struct ip_tunnel *tunnel;
 	int err;
 
-	if (!pskb_may_pull(skb, sizeof(struct ipv6hdr)))
-		goto out;
-
-	iph = ip_hdr(skb);
-
 	tunnel = ipip6_tunnel_lookup(dev_net(skb->dev), skb->dev,
 				     iph->saddr, iph->daddr);
 	if (tunnel != NULL) {
-- 
1.7.11.7
