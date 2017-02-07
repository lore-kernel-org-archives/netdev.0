From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH RFC ipsec-next 1/5] xfrm: Add a secpath_set helper.
Date: Tue, 7 Feb 2017 10:14:07 +0100
Message-ID: <1486458851-4920-2-git-send-email-steffen.klassert@secunet.com>
References: <1486458851-4920-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
        David Miller <davem@davemloft.net>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        "Sowmini Varadhan" <sowmini.varadhan@oracle.com>,
        Ilan Tayari <ilant@mellanox.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:44766 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753236AbdBGJOX (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 7 Feb 2017 04:14:23 -0500
In-Reply-To: <1486458851-4920-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a new helper to set the secpath to the skb.
This avoids code duplication, as this is used
in multiple places.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/net/xfrm.h     |  1 +
 net/ipv6/xfrm6_input.c | 15 +++------------
 net/xfrm/xfrm_input.c  | 35 +++++++++++++++++++++++------------
 3 files changed, 27 insertions(+), 24 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index d9a81dc..25082e2 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -1009,6 +1009,7 @@ static inline int secpath_exists(struct sk_buff *skb)
 }
 
 struct sec_path *secpath_dup(struct sec_path *src);
+int secpath_set(struct sk_buff *skb);
 
 static inline void
 secpath_reset(struct sk_buff *skb)
diff --git a/net/ipv6/xfrm6_input.c b/net/ipv6/xfrm6_input.c
index b578956..662fb2c 100644
--- a/net/ipv6/xfrm6_input.c
+++ b/net/ipv6/xfrm6_input.c
@@ -69,18 +69,9 @@ int xfrm6_input_addr(struct sk_buff *skb, xfrm_address_t *daddr,
 	struct xfrm_state *x = NULL;
 	int i = 0;
 
-	/* Allocate new secpath or COW existing one. */
-	if (!skb->sp || atomic_read(&skb->sp->refcnt) != 1) {
-		struct sec_path *sp;
-
-		sp = secpath_dup(skb->sp);
-		if (!sp) {
-			XFRM_INC_STATS(net, LINUX_MIB_XFRMINERROR);
-			goto drop;
-		}
-		if (skb->sp)
-			secpath_put(skb->sp);
-		skb->sp = sp;
+	if (secpath_set(skb)) {
+		XFRM_INC_STATS(net, LINUX_MIB_XFRMINERROR);
+		goto drop;
 	}
 
 	if (1 + skb->sp->len == XFRM_MAX_DEPTH) {
diff --git a/net/xfrm/xfrm_input.c b/net/xfrm/xfrm_input.c
index 3213fe8..58f5e44 100644
--- a/net/xfrm/xfrm_input.c
+++ b/net/xfrm/xfrm_input.c
@@ -126,6 +126,25 @@ struct sec_path *secpath_dup(struct sec_path *src)
 }
 EXPORT_SYMBOL(secpath_dup);
 
+int secpath_set(struct sk_buff *skb)
+{
+	struct sec_path *sp;
+
+	/* Allocate new secpath or COW existing one. */
+	if (!skb->sp || atomic_read(&skb->sp->refcnt) != 1) {
+
+		sp = secpath_dup(skb->sp);
+		if (!sp) {
+			return -ENOMEM;
+		}
+		if (skb->sp)
+			secpath_put(skb->sp);
+		skb->sp = sp;
+	}
+	return 0;
+}
+EXPORT_SYMBOL(secpath_set);
+
 /* Fetch spi and seq from ipsec header */
 
 int xfrm_parse_spi(struct sk_buff *skb, u8 nexthdr, __be32 *spi, __be32 *seq)
@@ -221,18 +240,10 @@ int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi, int encap_type)
 		break;
 	}
 
-	/* Allocate new secpath or COW existing one. */
-	if (!skb->sp || atomic_read(&skb->sp->refcnt) != 1) {
-		struct sec_path *sp;
-
-		sp = secpath_dup(skb->sp);
-		if (!sp) {
-			XFRM_INC_STATS(net, LINUX_MIB_XFRMINERROR);
-			goto drop;
-		}
-		if (skb->sp)
-			secpath_put(skb->sp);
-		skb->sp = sp;
+	err = secpath_set(skb);
+	if (err) {
+		XFRM_INC_STATS(net, LINUX_MIB_XFRMINERROR);
+		goto drop;
 	}
 
 	seq = 0;
-- 
1.9.1
