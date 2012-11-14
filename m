From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [RFC PATCH 11/13] ipv6: Update ipv6 static library with newly needed functions
Date: Tue, 13 Nov 2012 20:24:12 -0500
Message-ID: <1352856254-29667-12-git-send-email-vyasevic@redhat.com>
References: <1352856254-29667-1-git-send-email-vyasevic@redhat.com>
Cc: eric.dumazet@gmail.com, davem@davemloft.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:63157 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932389Ab2KNBYf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Nov 2012 20:24:35 -0500
In-Reply-To: <1352856254-29667-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

UDP offload needs some additional functions to be in the static kernel
for it work correclty.  Move those functions into the core.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 net/ipv6/Makefile      |    2 +-
 net/ipv6/ip6_output.c  |   65 -----------------------------------------
 net/ipv6/output_core.c |   76 ++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 77 insertions(+), 66 deletions(-)
 create mode 100644 net/ipv6/output_core.c

diff --git a/net/ipv6/Makefile b/net/ipv6/Makefile
index 7f25077..cdca302 100644
--- a/net/ipv6/Makefile
+++ b/net/ipv6/Makefile
@@ -41,6 +41,6 @@ obj-$(CONFIG_IPV6_SIT) += sit.o
 obj-$(CONFIG_IPV6_TUNNEL) += ip6_tunnel.o
 obj-$(CONFIG_IPV6_GRE) += ip6_gre.o
 
-obj-y += addrconf_core.o exthdrs_core.o
+obj-y += addrconf_core.o exthdrs_core.o output_core.o
 
 obj-$(subst m,y,$(CONFIG_IPV6)) += inet6_hashtables.o
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index aece3e7..45e6558 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -545,71 +545,6 @@ static void ip6_copy_metadata(struct sk_buff *to, struct sk_buff *from)
 	skb_copy_secmark(to, from);
 }
 
-int ip6_find_1stfragopt(struct sk_buff *skb, u8 **nexthdr)
-{
-	u16 offset = sizeof(struct ipv6hdr);
-	struct ipv6_opt_hdr *exthdr =
-				(struct ipv6_opt_hdr *)(ipv6_hdr(skb) + 1);
-	unsigned int packet_len = skb->tail - skb->network_header;
-	int found_rhdr = 0;
-	*nexthdr = &ipv6_hdr(skb)->nexthdr;
-
-	while (offset + 1 <= packet_len) {
-
-		switch (**nexthdr) {
-
-		case NEXTHDR_HOP:
-			break;
-		case NEXTHDR_ROUTING:
-			found_rhdr = 1;
-			break;
-		case NEXTHDR_DEST:
-#if defined(CONFIG_IPV6_MIP6) || defined(CONFIG_IPV6_MIP6_MODULE)
-			if (ipv6_find_tlv(skb, offset, IPV6_TLV_HAO) >= 0)
-				break;
-#endif
-			if (found_rhdr)
-				return offset;
-			break;
-		default :
-			return offset;
-		}
-
-		offset += ipv6_optlen(exthdr);
-		*nexthdr = &exthdr->nexthdr;
-		exthdr = (struct ipv6_opt_hdr *)(skb_network_header(skb) +
-						 offset);
-	}
-
-	return offset;
-}
-
-void ipv6_select_ident(struct frag_hdr *fhdr, struct rt6_info *rt)
-{
-	static atomic_t ipv6_fragmentation_id;
-	int old, new;
-
-	if (rt && !(rt->dst.flags & DST_NOPEER)) {
-		struct inet_peer *peer;
-		struct net *net;
-
-		net = dev_net(rt->dst.dev);
-		peer = inet_getpeer_v6(net->ipv6.peers, &rt->rt6i_dst.addr, 1);
-		if (peer) {
-			fhdr->identification = htonl(inet_getid(peer, 0));
-			inet_putpeer(peer);
-			return;
-		}
-	}
-	do {
-		old = atomic_read(&ipv6_fragmentation_id);
-		new = old + 1;
-		if (!new)
-			new = 1;
-	} while (atomic_cmpxchg(&ipv6_fragmentation_id, old, new) != old);
-	fhdr->identification = htonl(new);
-}
-
 int ip6_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
 {
 	struct sk_buff *frag;
diff --git a/net/ipv6/output_core.c b/net/ipv6/output_core.c
new file mode 100644
index 0000000..c2e73e6
--- /dev/null
+++ b/net/ipv6/output_core.c
@@ -0,0 +1,76 @@
+/*
+ * IPv6 library code, needed by static components when full IPv6 support is
+ * not configured or static.  These functions are needed by GSO/GRO implementation.
+ */
+#include <linux/export.h>
+#include <net/ipv6.h>
+#include <net/ip6_fib.h>
+
+void ipv6_select_ident(struct frag_hdr *fhdr, struct rt6_info *rt)
+{
+	static atomic_t ipv6_fragmentation_id;
+	int old, new;
+
+#if IS_ENABLED(CONFIG_IPV6)
+	if (rt && !(rt->dst.flags & DST_NOPEER)) {
+		struct inet_peer *peer;
+		struct net *net;
+
+		net = dev_net(rt->dst.dev);
+		peer = inet_getpeer_v6(net->ipv6.peers, &rt->rt6i_dst.addr, 1);
+		if (peer) {
+			fhdr->identification = htonl(inet_getid(peer, 0));
+			inet_putpeer(peer);
+			return;
+		}
+	}
+#endif
+	do {
+		old = atomic_read(&ipv6_fragmentation_id);
+		new = old + 1;
+		if (!new)
+			new = 1;
+	} while (atomic_cmpxchg(&ipv6_fragmentation_id, old, new) != old);
+	fhdr->identification = htonl(new);
+}
+EXPORT_SYMBOL(ipv6_select_ident);
+
+int ip6_find_1stfragopt(struct sk_buff *skb, u8 **nexthdr)
+{
+	u16 offset = sizeof(struct ipv6hdr);
+	struct ipv6_opt_hdr *exthdr =
+				(struct ipv6_opt_hdr *)(ipv6_hdr(skb) + 1);
+	unsigned int packet_len = skb->tail - skb->network_header;
+	int found_rhdr = 0;
+	*nexthdr = &ipv6_hdr(skb)->nexthdr;
+
+	while (offset + 1 <= packet_len) {
+
+		switch (**nexthdr) {
+
+		case NEXTHDR_HOP:
+			break;
+		case NEXTHDR_ROUTING:
+			found_rhdr = 1;
+			break;
+		case NEXTHDR_DEST:
+#if IS_ENABLED(CONFIG_IPV6_MIP6)
+			if (ipv6_find_tlv(skb, offset, IPV6_TLV_HAO) >= 0)
+				break;
+#endif
+			if (found_rhdr)
+				return offset;
+			break;
+		default :
+			return offset;
+		}
+
+		offset += ipv6_optlen(exthdr);
+		*nexthdr = &exthdr->nexthdr;
+		exthdr = (struct ipv6_opt_hdr *)(skb_network_header(skb) +
+						 offset);
+	}
+
+	return offset;
+}
+EXPORT_SYMBOL(ip6_find_1stfragopt);
-- 
1.7.7.6
