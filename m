From: Florian Westphal <fw@strlen.de>
Subject: [PATCH 1/2] net: add and use skb_gso_transport_seglen()
Date: Sat, 22 Feb 2014 10:33:25 +0100
Message-ID: <1393061606-5422-2-git-send-email-fw@strlen.de>
References: <1393061606-5422-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:44047 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751536AbaBVJha (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Feb 2014 04:37:30 -0500
In-Reply-To: <1393061606-5422-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit de960aa9ab4decc3304959f69533eef64d05d8e8 upstream.

[ no skb_gso_seglen helper in 3.4, leave tbf alone ]

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
index 42b919c..9cfc1ff 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2159,6 +2159,8 @@ extern int	       skb_shift(struct sk_buff *tgt, struct sk_buff *skb,
 extern struct sk_buff *skb_segment(struct sk_buff *skb,
 				   netdev_features_t features);
 
+unsigned int skb_gso_transport_seglen(const struct sk_buff *skb);
+
 static inline void *skb_header_pointer(const struct sk_buff *skb, int offset,
 				       int len, void *buffer)
 {
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index e99aedd..7a597d4 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -45,6 +45,8 @@
 #include <linux/in.h>
 #include <linux/inet.h>
 #include <linux/slab.h>
+#include <linux/tcp.h>
+#include <linux/udp.h>
 #include <linux/netdevice.h>
 #ifdef CONFIG_NET_CLS_ACT
 #include <net/pkt_sched.h>
@@ -3281,3 +3283,26 @@ void __skb_warn_lro_forwarding(const struct sk_buff *skb)
 			   " while LRO is enabled\n", skb->dev->name);
 }
 EXPORT_SYMBOL(__skb_warn_lro_forwarding);
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
