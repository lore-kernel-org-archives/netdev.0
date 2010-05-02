From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: eth_type_trans() should inline
 skb_pull()
Date: Sat, 01 May 2010 18:15:58 -0700 (PDT)
Message-ID: <20100501.181558.141243424.davem@davemloft.net>
References: <1272696145.2230.101.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, therbert@google.com, hadi@cyberus.ca
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49759
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753648Ab0EBBPy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 May 2010 21:15:54 -0400
In-Reply-To: <1272696145.2230.101.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 01 May 2010 08:42:25 +0200

> [PATCH net-next-2.6] net: eth_type_trans() should inline skb_pull()
> 
> With RPS, this patch can give a 5 % boost in performance.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Awesome, but let's do this in a way that allows us to easily annotate
where inlining makes sense in other places, not just here.

Something like this, ok?

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 82f5116..746a652 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1128,6 +1128,11 @@ static inline unsigned char *__skb_pull(struct sk_buff *skb, unsigned int len)
 	return skb->data += len;
 }
 
+static inline unsigned char *skb_pull_inline(struct sk_buff *skb, unsigned int len)
+{
+	return unlikely(len > skb->len) ? NULL : __skb_pull(skb, len);
+}
+
 extern unsigned char *__pskb_pull_tail(struct sk_buff *skb, int delta);
 
 static inline unsigned char *__pskb_pull(struct sk_buff *skb, unsigned int len)
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 4218ff4..8b9c109 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -1051,7 +1051,7 @@ EXPORT_SYMBOL(skb_push);
  */
 unsigned char *skb_pull(struct sk_buff *skb, unsigned int len)
 {
-	return unlikely(len > skb->len) ? NULL : __skb_pull(skb, len);
+	return skb_pull_inline(skb, len);
 }
 EXPORT_SYMBOL(skb_pull);
 
diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
index 0c0d272..61ec032 100644
--- a/net/ethernet/eth.c
+++ b/net/ethernet/eth.c
@@ -162,7 +162,7 @@ __be16 eth_type_trans(struct sk_buff *skb, struct net_device *dev)
 
 	skb->dev = dev;
 	skb_reset_mac_header(skb);
-	skb_pull(skb, ETH_HLEN);
+	skb_pull_inline(skb, ETH_HLEN);
 	eth = eth_hdr(skb);
 
 	if (unlikely(is_multicast_ether_addr(eth->h_dest))) {
