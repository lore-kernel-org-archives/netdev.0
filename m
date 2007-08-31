From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 5/7] [NET] skbuff: Add skb_cow_head
Date: Fri, 31 Aug 2007 17:11:34 +0800
Message-ID: <E1IR2XO-0007QL-00@gondolin.me.apana.org.au>
References: <20070831090625.GA28175@gondor.apana.org.au>
To: James Chapman <jchapman@katalix.com>,
	"David S. Miller" <davem@davemloft.net>,
	Michal Ostrowski <mostrows@speakeasy.net>,
	Paul Mackerras <paulus@samba.org>,
	Herbert Xu <herbert@gondo
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3599 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758494AbXHaJLh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Aug 2007 05:11:37 -0400
Received: from gondolin.me.apana.org.au ([192.168.0.6] ident=mail)
	by arnor.apana.org.au with esmtp (Exim 4.50 #1 (Debian))
	id 1IR2XP-0004RW-7k
	for <netdev@vger.kernel.org>; Fri, 31 Aug 2007 19:11:35 +1000
Received: from herbert by gondolin.me.apana.org.au with local (Exim 3.36 #1 (Debian))
	id 1IR2XO-0007QL-00
	for <netdev@vger.kernel.org>; Fri, 31 Aug 2007 17:11:34 +0800
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[NET] skbuff: Add skb_cow_head

This patch adds an optimised version of skb_cow that avoids the copy if
the header can be modified even if the rest of the payload is cloned.

This can be used in encapsulating paths where we only need to modify the
header.  As it is, this can be used in PPPOE and bridging.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 drivers/net/pppoe.c       |    2 +-
 include/linux/skbuff.h    |   40 +++++++++++++++++++++++++++++++---------
 net/bridge/br_netfilter.c |    2 +-
 3 files changed, 33 insertions(+), 11 deletions(-)

diff --git a/drivers/net/pppoe.c b/drivers/net/pppoe.c
index bac3654..0d7f570 100644
--- a/drivers/net/pppoe.c
+++ b/drivers/net/pppoe.c
@@ -860,7 +860,7 @@ static int __pppoe_xmit(struct sock *sk, struct sk_buff *skb)
 	/* Copy the data if there is no space for the header or if it's
 	 * read-only.
 	 */
-	if (skb_cow(skb, sizeof(*ph) + dev->hard_header_len))
+	if (skb_cow_head(skb, sizeof(*ph) + dev->hard_header_len))
 		goto abort;
 
 	__skb_push(skb, sizeof(*ph));
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 93c27f7..a656cec 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1352,6 +1352,22 @@ static inline int skb_clone_writable(struct sk_buff *skb, int len)
 	       skb_headroom(skb) + len <= skb->hdr_len;
 }
 
+static inline int __skb_cow(struct sk_buff *skb, unsigned int headroom,
+			    int cloned)
+{
+	int delta = 0;
+
+	if (headroom < NET_SKB_PAD)
+		headroom = NET_SKB_PAD;
+	if (headroom > skb_headroom(skb))
+		delta = headroom - skb_headroom(skb);
+
+	if (delta || cloned)
+		return pskb_expand_head(skb, ALIGN(delta, NET_SKB_PAD), 0,
+					GFP_ATOMIC);
+	return 0;
+}
+
 /**
  *	skb_cow - copy header of skb when it is required
  *	@skb: buffer to cow
@@ -1366,16 +1382,22 @@ static inline int skb_clone_writable(struct sk_buff *skb, int len)
  */
 static inline int skb_cow(struct sk_buff *skb, unsigned int headroom)
 {
-	int delta = (headroom > NET_SKB_PAD ? headroom : NET_SKB_PAD) -
-			skb_headroom(skb);
-
-	if (delta < 0)
-		delta = 0;
+	return __skb_cow(skb, headroom, skb_cloned(skb));
+}
 
-	if (delta || skb_cloned(skb))
-		return pskb_expand_head(skb, (delta + (NET_SKB_PAD-1)) &
-				~(NET_SKB_PAD-1), 0, GFP_ATOMIC);
-	return 0;
+/**
+ *	skb_cow_head - skb_cow but only making the head writable
+ *	@skb: buffer to cow
+ *	@headroom: needed headroom
+ *
+ *	This function is identical to skb_cow except that we replace the
+ *	skb_cloned check by skb_header_cloned.  It should be used when
+ *	you only need to push on some header and do not need to modify
+ *	the data.
+ */
+static inline int skb_cow_head(struct sk_buff *skb, unsigned int headroom)
+{
+	return __skb_cow(skb, headroom, skb_header_cloned(skb));
 }
 
 /**
diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index 3ee2022..fc13130 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -183,7 +183,7 @@ int nf_bridge_copy_header(struct sk_buff *skb)
 	int err;
 	int header_size = ETH_HLEN + nf_bridge_encap_header_len(skb);
 
-	err = skb_cow(skb, header_size);
+	err = skb_cow_head(skb, header_size);
 	if (err)
 		return err;
 
