From: fgao@ikuai8.com
Subject: [PATCH 1/1] netfilter: gre: Use the consitent GRE and PPTP struct instead of the structures defined in netfilter
Date: Fri, 19 Aug 2016 23:01:34 +0800
Message-ID: <1471618894-10582-1-git-send-email-fgao@ikuai8.com>
Cc: gfree.wind@gmail.com, Gao Feng <fgao@ikuai8.com>
To: pablo@netfilter.org, kaber@trash.net,
        netfilter-devel@vger.kernel.org, philipp@redfish-solutions.com,
        netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Gao Feng <fgao@ikuai8.com>

There are two structures which define the GRE header and PPTP
header. So it is unneccessary to define duplicated structures in
netfilter again.

Signed-off-by: Gao Feng <fgao@ikuai8.com>
---
 v1: Intial patch

 include/linux/netfilter/nf_conntrack_proto_gre.h | 63 +-----------------------
 include/uapi/linux/if_tunnel.h                   |  1 +
 net/ipv4/netfilter/nf_nat_proto_gre.c            | 15 +++---
 net/netfilter/nf_conntrack_proto_gre.c           | 14 +++---
 4 files changed, 19 insertions(+), 74 deletions(-)

diff --git a/include/linux/netfilter/nf_conntrack_proto_gre.h b/include/linux/netfilter/nf_conntrack_proto_gre.h
index df78dc2..9c741da 100644
--- a/include/linux/netfilter/nf_conntrack_proto_gre.h
+++ b/include/linux/netfilter/nf_conntrack_proto_gre.h
@@ -2,67 +2,8 @@
 #define _CONNTRACK_PROTO_GRE_H
 #include <asm/byteorder.h>
 
-/* GRE PROTOCOL HEADER */
-
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
-/* GRE is a mess: Four different standards */
-struct gre_hdr {
-#if defined(__LITTLE_ENDIAN_BITFIELD)
-	__u16	rec:3,
-		srr:1,
-		seq:1,
-		key:1,
-		routing:1,
-		csum:1,
-		version:3,
-		reserved:4,
-		ack:1;
-#elif defined(__BIG_ENDIAN_BITFIELD)
-	__u16	csum:1,
-		routing:1,
-		key:1,
-		seq:1,
-		srr:1,
-		rec:3,
-		ack:1,
-		reserved:4,
-		version:3;
-#else
-#error "Adjust your <asm/byteorder.h> defines"
-#endif
-	__be16	protocol;
-};
-
-/* modified GRE header for PPTP */
-struct gre_hdr_pptp {
-	__u8   flags;		/* bitfield */
-	__u8   version;		/* should be GRE_VERSION_PPTP */
-	__be16 protocol;	/* should be GRE_PROTOCOL_PPTP */
-	__be16 payload_len;	/* size of ppp payload, not inc. gre header */
-	__be16 call_id;		/* peer's call_id for this session */
-	__be32 seq;		/* sequence number.  Present if S==1 */
-	__be32 ack;		/* seq number of highest packet received by */
-				/*  sender in this session */
-};
+#include <net/gre.h>
+#include <net/pptp.h>
 
 struct nf_ct_gre {
 	unsigned int stream_timeout;
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
index 9414923..afe81a8 100644
--- a/net/ipv4/netfilter/nf_nat_proto_gre.c
+++ b/net/ipv4/netfilter/nf_nat_proto_gre.c
@@ -88,8 +88,9 @@ gre_manip_pkt(struct sk_buff *skb,
 	      const struct nf_conntrack_tuple *tuple,
 	      enum nf_nat_manip_type maniptype)
 {
-	const struct gre_hdr *greh;
-	struct gre_hdr_pptp *pgreh;
+	const struct gre_base_hdr *greh;
+	struct pptp_gre_header *pgreh;
+	u16 gre_ver;
 
 	/* pgreh includes two optional 32bit fields which are not required
 	 * to be there.  That's where the magic '8' comes from */
@@ -97,18 +98,20 @@ gre_manip_pkt(struct sk_buff *skb,
 		return false;
 
 	greh = (void *)skb->data + hdroff;
-	pgreh = (struct gre_hdr_pptp *)greh;
+	pgreh = (struct pptp_gre_header *)greh;
 
 	/* we only have destination manip of a packet, since 'source key'
 	 * is not present in the packet itself */
 	if (maniptype != NF_NAT_MANIP_DST)
 		return true;
-	switch (greh->version) {
-	case GRE_VERSION_1701:
+
+	gre_ver = ntohs(greh->flags & GRE_VERSION);
+	switch (gre_ver) {
+	case GRE_VERSION_0:
 		/* We do not currently NAT any GREv0 packets.
 		 * Try to behave like "nf_nat_proto_unknown" */
 		break;
-	case GRE_VERSION_PPTP:
+	case GRE_VERSION_1:
 		pr_debug("call_id -> 0x%04x\n", ntohs(tuple->dst.u.gre.key));
 		pgreh->call_id = tuple->dst.u.gre.key;
 		break;
diff --git a/net/netfilter/nf_conntrack_proto_gre.c b/net/netfilter/nf_conntrack_proto_gre.c
index a96451a..f46597f 100644
--- a/net/netfilter/nf_conntrack_proto_gre.c
+++ b/net/netfilter/nf_conntrack_proto_gre.c
@@ -192,15 +192,15 @@ static bool gre_invert_tuple(struct nf_conntrack_tuple *tuple,
 static bool gre_pkt_to_tuple(const struct sk_buff *skb, unsigned int dataoff,
 			     struct net *net, struct nf_conntrack_tuple *tuple)
 {
-	const struct gre_hdr_pptp *pgrehdr;
-	struct gre_hdr_pptp _pgrehdr;
+	const struct pptp_gre_header *pgrehdr;
+	struct pptp_gre_header _pgrehdr;
 	__be16 srckey;
-	const struct gre_hdr *grehdr;
-	struct gre_hdr _grehdr;
+	const struct gre_base_hdr *grehdr;
+	struct gre_base_hdr _grehdr;
 
 	/* first only delinearize old RFC1701 GRE header */
 	grehdr = skb_header_pointer(skb, dataoff, sizeof(_grehdr), &_grehdr);
-	if (!grehdr || grehdr->version != GRE_VERSION_PPTP) {
+	if (!grehdr || ntohs(grehdr->flags & GRE_VERSION) != GRE_VERSION_1) {
 		/* try to behave like "nf_conntrack_proto_generic" */
 		tuple->src.u.all = 0;
 		tuple->dst.u.all = 0;
@@ -212,8 +212,8 @@ static bool gre_pkt_to_tuple(const struct sk_buff *skb, unsigned int dataoff,
 	if (!pgrehdr)
 		return true;
 
-	if (ntohs(grehdr->protocol) != GRE_PROTOCOL_PPTP) {
-		pr_debug("GRE_VERSION_PPTP but unknown proto\n");
+	if (grehdr->protocol != GRE_PROTO_PPP) {
+		pr_debug("Unknown GRE proto(0x%x)\n", ntohs(grehdr->protocol));
 		return false;
 	}
 
-- 
1.9.1

