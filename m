From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net-next 1/2] udp: move scratch area helpers into the include file
Date: Mon, 26 Jun 2017 19:01:50 +0200
Message-ID: <3ec681d82c56f2d9dda340b9eca0371f47621c62.1498493975.git.pabeni@redhat.com>
References: <cover.1498493975.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33078 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751544AbdFZRCc (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 26 Jun 2017 13:02:32 -0400
In-Reply-To: <cover.1498493975.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

So that they can be later used by the IPv6 code, too.
Also lift the comments a bit.

Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
 include/net/udp.h | 61 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
 net/ipv4/udp.c    | 60 ------------------------------------------------------
 2 files changed, 61 insertions(+), 60 deletions(-)

diff --git a/include/net/udp.h b/include/net/udp.h
index 1468dbd..972ce4b 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -302,6 +302,67 @@ struct sock *__udp6_lib_lookup(struct net *net,
 struct sock *udp6_lib_lookup_skb(struct sk_buff *skb,
 				 __be16 sport, __be16 dport);
 
+/* UDP uses skb->dev_scratch to cache as much information as possible and avoid
+ * possibly multiple cache miss on dequeue()
+ */
+#if BITS_PER_LONG == 64
+
+/* truesize, len and the bit needed to compute skb_csum_unnecessary will be on
+ * cold cache lines at recvmsg time.
+ * skb->len can be stored on 16 bits since the udp header has been already
+ * validated and pulled.
+ */
+struct udp_dev_scratch {
+	u32 truesize;
+	u16 len;
+	bool is_linear;
+	bool csum_unnecessary;
+};
+
+static inline unsigned int udp_skb_len(struct sk_buff *skb)
+{
+	return ((struct udp_dev_scratch *)&skb->dev_scratch)->len;
+}
+
+static inline bool udp_skb_csum_unnecessary(struct sk_buff *skb)
+{
+	return ((struct udp_dev_scratch *)&skb->dev_scratch)->csum_unnecessary;
+}
+
+static inline bool udp_skb_is_linear(struct sk_buff *skb)
+{
+	return ((struct udp_dev_scratch *)&skb->dev_scratch)->is_linear;
+}
+
+#else
+static inline unsigned int udp_skb_len(struct sk_buff *skb)
+{
+	return skb->len;
+}
+
+static inline bool udp_skb_csum_unnecessary(struct sk_buff *skb)
+{
+	return skb_csum_unnecessary(skb);
+}
+
+static inline bool udp_skb_is_linear(struct sk_buff *skb)
+{
+	return !skb_is_nonlinear(skb);
+}
+#endif
+
+static inline int copy_linear_skb(struct sk_buff *skb, int len, int off,
+				  struct iov_iter *to)
+{
+	int n, copy = len - off;
+
+	n = copy_to_iter(skb->data + off, copy, to);
+	if (n == copy)
+		return 0;
+
+	return -EFAULT;
+}
+
 /*
  * 	SNMP statistics for UDP and UDP-Lite
  */
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 47c7aa0..86fad2a 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1163,24 +1163,7 @@ int udp_sendpage(struct sock *sk, struct page *page, int offset,
 	return ret;
 }
 
-/* Copy as much information as possible into skb->dev_scratch to avoid
- * possibly multiple cache miss on dequeue();
- */
 #if BITS_PER_LONG == 64
-
-/* we can store multiple info here: truesize, len and the bit needed to
- * compute skb_csum_unnecessary will be on cold cache lines at recvmsg
- * time.
- * skb->len can be stored on 16 bits since the udp header has been already
- * validated and pulled.
- */
-struct udp_dev_scratch {
-	u32 truesize;
-	u16 len;
-	bool is_linear;
-	bool csum_unnecessary;
-};
-
 static void udp_set_dev_scratch(struct sk_buff *skb)
 {
 	struct udp_dev_scratch *scratch;
@@ -1197,22 +1180,6 @@ static int udp_skb_truesize(struct sk_buff *skb)
 {
 	return ((struct udp_dev_scratch *)&skb->dev_scratch)->truesize;
 }
-
-static unsigned int udp_skb_len(struct sk_buff *skb)
-{
-	return ((struct udp_dev_scratch *)&skb->dev_scratch)->len;
-}
-
-static bool udp_skb_csum_unnecessary(struct sk_buff *skb)
-{
-	return ((struct udp_dev_scratch *)&skb->dev_scratch)->csum_unnecessary;
-}
-
-static bool udp_skb_is_linear(struct sk_buff *skb)
-{
-	return ((struct udp_dev_scratch *)&skb->dev_scratch)->is_linear;
-}
-
 #else
 static void udp_set_dev_scratch(struct sk_buff *skb)
 {
@@ -1223,21 +1190,6 @@ static int udp_skb_truesize(struct sk_buff *skb)
 {
 	return skb->dev_scratch;
 }
-
-static unsigned int udp_skb_len(struct sk_buff *skb)
-{
-	return skb->len;
-}
-
-static bool udp_skb_csum_unnecessary(struct sk_buff *skb)
-{
-	return skb_csum_unnecessary(skb);
-}
-
-static bool udp_skb_is_linear(struct sk_buff *skb)
-{
-	return !skb_is_nonlinear(skb);
-}
 #endif
 
 /* fully reclaim rmem/fwd memory allocated for skb */
@@ -1598,18 +1550,6 @@ struct sk_buff *__skb_recv_udp(struct sock *sk, unsigned int flags,
 }
 EXPORT_SYMBOL_GPL(__skb_recv_udp);
 
-static int copy_linear_skb(struct sk_buff *skb, int len, int off,
-			   struct iov_iter *to)
-{
-	int n, copy = len - off;
-
-	n = copy_to_iter(skb->data + off, copy, to);
-	if (n == copy)
-		return 0;
-
-	return -EFAULT;
-}
-
 /*
  * 	This should be easy, if there is something there we
  * 	return it, otherwise we block.
-- 
2.9.4
