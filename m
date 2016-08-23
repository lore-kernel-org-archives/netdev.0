From: fgao@ikuai8.com
Subject: [PATCH v2 1/2 net-next] netfilter: gre: Use consistent GRE_* macros instead of ones defined by netfilter.
Date: Tue, 23 Aug 2016 10:15:07 +0800
Message-ID: <1471918507-4847-1-git-send-email-fgao@ikuai8.com>
Cc: gfree.wind@gmail.com, Gao Feng <fgao@ikuai8.com>
To: pablo@netfilter.org, kaber@trash.net, kadlec@blackhole.kfki.hu,
        netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpbg278.qq.com ([113.108.11.203]:55383 "EHLO smtpbg278.qq.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754177AbcHWCQR (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 22 Aug 2016 22:16:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao Feng <fgao@ikuai8.com>

There are already some GRE_* macros in kernel, so it is unnecessary
to define these macros. And remove some useless macros

Signed-off-by: Gao Feng <fgao@ikuai8.com>
---
 v2: Split the original patch to review easily
 v1: Intial patch

 include/linux/netfilter/nf_conntrack_proto_gre.h | 22 ++--------------------
 include/uapi/linux/if_tunnel.h                   |  1 +
 net/ipv4/netfilter/nf_nat_proto_gre.c            |  4 ++--
 net/netfilter/nf_conntrack_proto_gre.c           |  4 ++--
 4 files changed, 7 insertions(+), 24 deletions(-)

diff --git a/include/linux/netfilter/nf_conntrack_proto_gre.h b/include/linux/netfilter/nf_conntrack_proto_gre.h
index df78dc2..0189747 100644
--- a/include/linux/netfilter/nf_conntrack_proto_gre.h
+++ b/include/linux/netfilter/nf_conntrack_proto_gre.h
@@ -1,29 +1,11 @@
 #ifndef _CONNTRACK_PROTO_GRE_H
 #define _CONNTRACK_PROTO_GRE_H
 #include <asm/byteorder.h>
+#include <net/gre.h>
+#include <net/pptp.h>
 
 /* GRE PROTOCOL HEADER */
 
-/* GRE Version field */
-#define GRE_VERSION_1701	0x0
-#define GRE_VERSION_PPTP	0x1
-
-/* GRE Protocol field */
-#define GRE_PROTOCOL_PPTP	0x880B
-
-/* GRE Flags */
-#define GRE_FLAG_C		0x80
-#define GRE_FLAG_R		0x40
-#define GRE_FLAG_K		0x20
-#define GRE_FLAG_S		0x10
-#define GRE_FLAG_A		0x80
-
-#define GRE_IS_C(f)	((f)&GRE_FLAG_C)
-#define GRE_IS_R(f)	((f)&GRE_FLAG_R)
-#define GRE_IS_K(f)	((f)&GRE_FLAG_K)
-#define GRE_IS_S(f)	((f)&GRE_FLAG_S)
-#define GRE_IS_A(f)	((f)&GRE_FLAG_A)
-
 /* GRE is a mess: Four different standards */
 struct gre_hdr {
 #if defined(__LITTLE_ENDIAN_BITFIELD)
diff --git a/include/uapi/linux/if_tunnel.h b/include/uapi/linux/if_tunnel.h
index 361b9f0..1b27e2c 100644
--- a/include/uapi/linux/if_tunnel.h
+++ b/include/uapi/linux/if_tunnel.h
@@ -36,6 +36,7 @@
 #define GRE_IS_REC(f)		((f) & GRE_REC)
 #define GRE_IS_ACK(f)		((f) & GRE_ACK)
 
+#define GRE_VERSION_0		__cpu_to_be16(0x0000)
 #define GRE_VERSION_1		__cpu_to_be16(0x0001)
 #define GRE_PROTO_PPP		__cpu_to_be16(0x880b)
 #define GRE_PPTP_KEY_MASK	__cpu_to_be32(0xffff)
diff --git a/net/ipv4/netfilter/nf_nat_proto_gre.c b/net/ipv4/netfilter/nf_nat_proto_gre.c
index 9414923..93198d7 100644
--- a/net/ipv4/netfilter/nf_nat_proto_gre.c
+++ b/net/ipv4/netfilter/nf_nat_proto_gre.c
@@ -104,11 +104,11 @@ gre_manip_pkt(struct sk_buff *skb,
 	if (maniptype != NF_NAT_MANIP_DST)
 		return true;
 	switch (greh->version) {
-	case GRE_VERSION_1701:
+	case ntohs(GRE_VERSION_0):
 		/* We do not currently NAT any GREv0 packets.
 		 * Try to behave like "nf_nat_proto_unknown" */
 		break;
-	case GRE_VERSION_PPTP:
+	case ntohs(GRE_VERSION_1):
 		pr_debug("call_id -> 0x%04x\n", ntohs(tuple->dst.u.gre.key));
 		pgreh->call_id = tuple->dst.u.gre.key;
 		break;
diff --git a/net/netfilter/nf_conntrack_proto_gre.c b/net/netfilter/nf_conntrack_proto_gre.c
index a96451a..deb239a 100644
--- a/net/netfilter/nf_conntrack_proto_gre.c
+++ b/net/netfilter/nf_conntrack_proto_gre.c
@@ -200,7 +200,7 @@ static bool gre_pkt_to_tuple(const struct sk_buff *skb, unsigned int dataoff,
 
 	/* first only delinearize old RFC1701 GRE header */
 	grehdr = skb_header_pointer(skb, dataoff, sizeof(_grehdr), &_grehdr);
-	if (!grehdr || grehdr->version != GRE_VERSION_PPTP) {
+	if (!grehdr || grehdr->version != ntohs(GRE_VERSION_1)) {
 		/* try to behave like "nf_conntrack_proto_generic" */
 		tuple->src.u.all = 0;
 		tuple->dst.u.all = 0;
@@ -212,7 +212,7 @@ static bool gre_pkt_to_tuple(const struct sk_buff *skb, unsigned int dataoff,
 	if (!pgrehdr)
 		return true;
 
-	if (ntohs(grehdr->protocol) != GRE_PROTOCOL_PPTP) {
+	if (grehdr->protocol != GRE_PROTO_PPP) {
 		pr_debug("GRE_VERSION_PPTP but unknown proto\n");
 		return false;
 	}
-- 
1.9.1
