From: Florian Westphal <fw@strlen.de>
Subject: [PATCH stable 3.10.y 1/3] net: add and use skb_gso_transport_seglen()
Date: Sat, 22 Feb 2014 10:30:17 +0100
Message-ID: <1393061419-4892-2-git-send-email-fw@strlen.de>
References: <1393061419-4892-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:44030 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751132AbaBVJeX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Feb 2014 04:34:23 -0500
In-Reply-To: <1393061419-4892-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit de960aa9ab4decc3304959f69533eef64d05d8e8 upstream.

[ no skb_gso_seglen helper in 3.10, leave tbf alone ]

This moves part of Eric Dumazets skb_gso_seglen helper from tbf sched to
skbuff core so it may be reused by upcoming ip forwarding path patch.

Signed-off-by: Florian Westphal <fw@strlen.de>
Acked-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/linux/skbuff.h |  2 ++
 net/core/skbuff.c      | 25 +++++++++++++++++++++++++
 2 files changed, 27 insertions(+)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index ded45ec..a49e581 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2488,6 +2488,8 @@ extern int	       skb_shift(struct sk_buff *tgt, struct sk_buff *skb,
 extern struct sk_buff *skb_segment(struct sk_buff *skb,
 				   netdev_features_t features);
 
+unsigned int skb_gso_transport_seglen(const struct sk_buff *skb);
+
 static inline void *skb_header_pointer(const struct sk_buff *skb, int offset,
 				       int len, void *buffer)
 {
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 20ee14d..79143b7 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -47,6 +47,8 @@
 #include <linux/in.h>
 #include <linux/inet.h>
 #include <linux/slab.h>
+#include <linux/tcp.h>
+#include <linux/udp.h>
 #include <linux/netdevice.h>
 #ifdef CONFIG_NET_CLS_ACT
 #include <net/pkt_sched.h>
@@ -3471,3 +3473,26 @@ bool skb_try_coalesce(struct sk_buff *to, struct sk_buff *from,
 	return true;
 }
 EXPORT_SYMBOL(skb_try_coalesce);
+
+/**
+ * skb_gso_transport_seglen - Return length of individual segments of a gso packet
+ *
+ * @skb: GSO skb
+ *
+ * skb_gso_transport_seglen is used to determine the real size of the
+ * individual segments, including Layer4 headers (TCP/UDP).
+ *
+ * The MAC/L2 or network (IP, IPv6) headers are not accounted for.
+ */
+unsigned int skb_gso_transport_seglen(const struct sk_buff *skb)
+{
+	const struct skb_shared_info *shinfo = skb_shinfo(skb);
+	unsigned int hdr_len;
+
+	if (likely(shinfo->gso_type & (SKB_GSO_TCPV4 | SKB_GSO_TCPV6)))
+		hdr_len = tcp_hdrlen(skb);
+	else
+		hdr_len = sizeof(struct udphdr);
+	return hdr_len + shinfo->gso_size;
+}
+EXPORT_SYMBOL_GPL(skb_gso_transport_seglen);
-- 
1.8.1.5
