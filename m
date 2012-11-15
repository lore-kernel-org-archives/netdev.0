From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH V2 11/14] ipv6: Update ipv6 static library with newly needed functions
Date: Thu, 15 Nov 2012 13:49:20 -0500
Message-ID: <1353005363-6974-12-git-send-email-vyasevic@redhat.com>
References: <1353005363-6974-1-git-send-email-vyasevic@redhat.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36075 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1768726Ab2KOSti (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Nov 2012 13:49:38 -0500
In-Reply-To: <1353005363-6974-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

UDP offload needs some additional functions to be in the static kernel
for it work correclty.  Move those functions into the core.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 net/ipv6/Makefile       |    2 +-
 net/ipv6/exthdrs.c      |   44 ---------------------------
 net/ipv6/exthdrs_core.c |   44 +++++++++++++++++++++++++++
 net/ipv6/ip6_output.c   |   65 ----------------------------------------
 net/ipv6/output_core.c  |   76 +++++++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 121 insertions(+), 110 deletions(-)
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
diff --git a/net/ipv6/exthdrs.c b/net/ipv6/exthdrs.c
index dc0faab..e9b5b33 100644
--- a/net/ipv6/exthdrs.c
+++ b/net/ipv6/exthdrs.c
@@ -50,50 +50,6 @@
 #include <asm/uaccess.h>
 #include "ip6_offload.h"
 
-int ipv6_find_tlv(struct sk_buff *skb, int offset, int type)
-{
-	const unsigned char *nh = skb_network_header(skb);
-	int packet_len = skb->tail - skb->network_header;
-	struct ipv6_opt_hdr *hdr;
-	int len;
-
-	if (offset + 2 > packet_len)
-		goto bad;
-	hdr = (struct ipv6_opt_hdr *)(nh + offset);
-	len = ((hdr->hdrlen + 1) << 3);
-
-	if (offset + len > packet_len)
-		goto bad;
-
-	offset += 2;
-	len -= 2;
-
-	while (len > 0) {
-		int opttype = nh[offset];
-		int optlen;
-
-		if (opttype == type)
-			return offset;
-
-		switch (opttype) {
-		case IPV6_TLV_PAD1:
-			optlen = 1;
-			break;
-		default:
-			optlen = nh[offset + 1] + 2;
-			if (optlen > len)
-				goto bad;
-			break;
-		}
-		offset += optlen;
-		len -= optlen;
-	}
-	/* not_found */
- bad:
-	return -1;
-}
-EXPORT_SYMBOL_GPL(ipv6_find_tlv);
-
 /*
  *	Parsing tlv encoded headers.
  *
diff --git a/net/ipv6/exthdrs_core.c b/net/ipv6/exthdrs_core.c
index f73d59a..e7d756e 100644
--- a/net/ipv6/exthdrs_core.c
+++ b/net/ipv6/exthdrs_core.c
@@ -111,3 +111,47 @@ int ipv6_skip_exthdr(const struct sk_buff *skb, int start, u8 *nexthdrp,
 	return start;
 }
 EXPORT_SYMBOL(ipv6_skip_exthdr);
+
+int ipv6_find_tlv(struct sk_buff *skb, int offset, int type)
+{
+	const unsigned char *nh = skb_network_header(skb);
+	int packet_len = skb->tail - skb->network_header;
+	struct ipv6_opt_hdr *hdr;
+	int len;
+
+	if (offset + 2 > packet_len)
+		goto bad;
+	hdr = (struct ipv6_opt_hdr *)(nh + offset);
+	len = ((hdr->hdrlen + 1) << 3);
+
+	if (offset + len > packet_len)
+		goto bad;
+
+	offset += 2;
+	len -= 2;
+
+	while (len > 0) {
+		int opttype = nh[offset];
+		int optlen;
+
+		if (opttype == type)
+			return offset;
+
+		switch (opttype) {
+		case IPV6_TLV_PAD1:
+			optlen = 1;
+			break;
+		default:
+			optlen = nh[offset + 1] + 2;
+			if (optlen > len)
+				goto bad;
+			break;
+		}
+		offset += optlen;
+		len -= optlen;
+	}
+	/* not_found */
+ bad:
+	return -1;
+}
+EXPORT_SYMBOL_GPL(ipv6_find_tlv);
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
