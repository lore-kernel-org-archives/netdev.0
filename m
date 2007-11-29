From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 2/2] [IPSEC]: Reinject v6 packet on input instead
	of	calling netfilter
Date: Thu, 29 Nov 2007 16:12:41 -0500
Message-ID: <1196370761.4437.28.camel@localhost>
References: <1196369551.4437.24.camel@localhost>
	 <474F275D.3030401@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.178]:1092 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756123AbXK2VMr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2007 16:12:47 -0500
Received: by py-out-1112.google.com with SMTP id u77so3861177pyb
        for <netdev@vger.kernel.org>; Thu, 29 Nov 2007 13:12:46 -0800 (PST)
In-Reply-To: <474F275D.3030401@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-29-11 at 21:55 +0100, Patrick McHardy wrote:
> jamal wrote:
> 
> [ can't quote because non-inline attachment ]

Evolution seems to have whitespace issues everytime i inlined the
attachment; and Dave has been able to tolerate me doing this so far.
I have just read it in

> I think Yoshifuji had some objections to this because extension
> headers will be processed twice.

ah, i missed that part. Could you point to a specific portion?
I wouldnt mind just ipv4 going in - but that would be lacking
consistency. Is there anything that can be done to get the extension
headers to be processed only once?

cheers,
jamal
>From 83d91d3c6f5df027a446b575af8dd4a3fdf90148 Mon Sep 17 00:00:00 2001
From: Jamal Hadi Salim <hadi@cyberus.ca>
Date: Thu, 29 Nov 2007 15:41:21 -0500
Subject: [PATCH 2/2] [IPSEC]: Reinject v6 packet on input instead of
calling netfilter

This is the ipv6 version.
Derived from an earlier down-trodden patch from Herbert.
We re-inject a decrypted ipsec back and let it bubble up the
network stack. This improves packet debugability (since sniffers like
tcpdump can see the packet) and ingress tc filters can act on it.

Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>
---
 net/ipv6/xfrm6_input.c |   23 ++++++++++++++---------
 1 files changed, 14 insertions(+), 9 deletions(-)

diff --git a/net/ipv6/xfrm6_input.c b/net/ipv6/xfrm6_input.c
index e2c3efd..c741fba 100644
--- a/net/ipv6/xfrm6_input.c
+++ b/net/ipv6/xfrm6_input.c
@@ -33,19 +33,24 @@ int xfrm6_transport_finish(struct sk_buff *skb, int
async)
 	skb_network_header(skb)[IP6CB(skb)->nhoff] =
 		XFRM_MODE_SKB_CB(skb)->protocol;
 
-#ifdef CONFIG_NETFILTER
+	if (async)
+		return ip6_rcv_finish(skb);
+
 	ipv6_hdr(skb)->payload_len = htons(skb->len);
 	__skb_push(skb, skb->data - skb_network_header(skb));
 
-	NF_HOOK(PF_INET6, NF_INET_PRE_ROUTING, skb, skb->dev, NULL,
-		ip6_rcv_finish);
-	return -1;
-#else
-	if (async)
-		return ip6_rcv_finish(skb);
+	dst_release(skb->dst);
+	skb->dst = NULL;
+	{
+		/* make some packet-sock user (eg tcpdump) happy */
+		const unsigned char *old_mac;
+		old_mac = skb_mac_header(skb);
+		skb_set_mac_header(skb, -skb->mac_len);
+		memmove(skb_mac_header(skb), old_mac, skb->mac_len);
+	}
 
-	return 1;
-#endif
+	netif_rx(skb);
+	return 0;
 }
 
 int xfrm6_rcv(struct sk_buff *skb)
-- 
1.4.4.1.gaed4




