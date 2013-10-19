From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 4/6] ipv4: gso: make inet_gso_segment() stackable
Date: Sat, 19 Oct 2013 11:42:56 -0700
Message-ID: <1382208178-22347-5-git-send-email-edumazet@google.com>
References: <1382208178-22347-1-git-send-email-edumazet@google.com>
Cc: netdev@vger.kernel.org, Jerry Chu <hkchu@google.com>,
	Tom Herbert <therbert@google.com>,
	Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f74.google.com ([209.85.216.74]:54009 "EHLO
	mail-qa0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752128Ab3JSTiW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Oct 2013 15:38:22 -0400
Received: by mail-qa0-f74.google.com with SMTP id ii20so202651qab.1
        for <netdev@vger.kernel.org>; Sat, 19 Oct 2013 12:38:22 -0700 (PDT)
In-Reply-To: <1382208178-22347-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In order to support GSO on IPIP, we need to make
inet_gso_segment() stackable.

It should not assume network header starts right after mac
header.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/linux/skbuff.h |  7 +++++--
 net/core/dev.c         |  2 ++
 net/ipv4/af_inet.c     | 25 ++++++++++++++++++-------
 3 files changed, 25 insertions(+), 9 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index ba74474..cad1e0c 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2722,9 +2722,12 @@ static inline struct sec_path *skb_sec_path(struct sk_buff *skb)
 /* Keeps track of mac header offset relative to skb->head.
  * It is useful for TSO of Tunneling protocol. e.g. GRE.
  * For non-tunnel skb it points to skb_mac_header() and for
- * tunnel skb it points to outer mac header. */
+ * tunnel skb it points to outer mac header.
+ * Keeps track of level of encapsulation of network headers.
+ */
 struct skb_gso_cb {
-	int mac_offset;
+	int	mac_offset;
+	int	encap_level;
 };
 #define SKB_GSO_CB(skb) ((struct skb_gso_cb *)(skb)->cb)
 
diff --git a/net/core/dev.c b/net/core/dev.c
index 1b6eadf..0918aad 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2377,6 +2377,8 @@ struct sk_buff *__skb_gso_segment(struct sk_buff *skb,
 	}
 
 	SKB_GSO_CB(skb)->mac_offset = skb_headroom(skb);
+	SKB_GSO_CB(skb)->encap_level = 0;
+
 	skb_reset_mac_header(skb);
 	skb_reset_mac_len(skb);
 
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 4f8cd4f..5783ab5 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1273,16 +1273,17 @@ out:
 }
 
 static struct sk_buff *inet_gso_segment(struct sk_buff *skb,
-	netdev_features_t features)
+					netdev_features_t features)
 {
 	struct sk_buff *segs = ERR_PTR(-EINVAL);
 	const struct net_offload *ops;
+	unsigned int offset = 0;
 	struct iphdr *iph;
+	bool tunnel;
 	int proto;
+	int nhoff;
 	int ihl;
 	int id;
-	unsigned int offset = 0;
-	bool tunnel;
 
 	if (unlikely(skb_shinfo(skb)->gso_type &
 		     ~(SKB_GSO_TCPV4 |
@@ -1296,6 +1297,8 @@ static struct sk_buff *inet_gso_segment(struct sk_buff *skb,
 		       0)))
 		goto out;
 
+	skb_reset_network_header(skb);
+	nhoff = skb_network_header(skb) - skb_mac_header(skb);
 	if (unlikely(!pskb_may_pull(skb, sizeof(*iph))))
 		goto out;
 
@@ -1312,7 +1315,10 @@ static struct sk_buff *inet_gso_segment(struct sk_buff *skb,
 		goto out;
 	__skb_pull(skb, ihl);
 
-	tunnel = !!skb->encapsulation;
+	tunnel = SKB_GSO_CB(skb)->encap_level > 0;
+	if (tunnel)
+		features = skb->dev->hw_enc_features & netif_skb_features(skb);
+	SKB_GSO_CB(skb)->encap_level += ihl;
 
 	skb_reset_transport_header(skb);
 
@@ -1327,18 +1333,23 @@ static struct sk_buff *inet_gso_segment(struct sk_buff *skb,
 
 	skb = segs;
 	do {
-		iph = ip_hdr(skb);
+		iph = (struct iphdr *)(skb_mac_header(skb) + nhoff);
 		if (!tunnel && proto == IPPROTO_UDP) {
 			iph->id = htons(id);
 			iph->frag_off = htons(offset >> 3);
 			if (skb->next != NULL)
 				iph->frag_off |= htons(IP_MF);
-			offset += (skb->len - skb->mac_len - iph->ihl * 4);
+			offset += skb->len - nhoff - ihl;
 		} else  {
 			iph->id = htons(id++);
 		}
-		iph->tot_len = htons(skb->len - skb->mac_len);
+		iph->tot_len = htons(skb->len - nhoff);
 		ip_send_check(iph);
+		if (tunnel) {
+			skb_reset_inner_headers(skb);
+			skb->encapsulation = 1;
+		}
+		skb->network_header = (u8 *)iph - skb->head;
 	} while ((skb = skb->next));
 
 out:
-- 
1.8.4
