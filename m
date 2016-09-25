From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 02/53] netfilter: gre: Use consistent GRE and PTTP header structure instead of the ones defined by netfilter
Date: Mon, 26 Sep 2016 01:06:12 +0200
Message-ID: <1474844823-2026-3-git-send-email-pablo@netfilter.org>
References: <1474844823-2026-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1474844823-2026-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Gao Feng <fgao@ikuai8.com>

There are two existing strutures which defines the GRE and PPTP header.
So use these two structures instead of the ones defined by netfilter to
keep consitent with other codes.

Signed-off-by: Gao Feng <fgao@ikuai8.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netfilter/nf_conntrack_proto_gre.h | 42 ------------------------
 net/ipv4/netfilter/nf_nat_proto_gre.c            | 13 ++++----
 net/netfilter/nf_conntrack_proto_gre.c           | 12 +++----
 3 files changed, 13 insertions(+), 54 deletions(-)

diff --git a/include/linux/netfilter/nf_conntrack_proto_gre.h b/include/linux/netfilter/nf_conntrack_proto_gre.h
index 0189747f2691..dee0acd0dd31 100644
--- a/include/linux/netfilter/nf_conntrack_proto_gre.h
+++ b/include/linux/netfilter/nf_conntrack_proto_gre.h
@@ -4,48 +4,6 @@
 #include <net/gre.h>
 #include <net/pptp.h>
 
-/* GRE PROTOCOL HEADER */
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
-
 struct nf_ct_gre {
 	unsigned int stream_timeout;
 	unsigned int timeout;
diff --git a/net/ipv4/netfilter/nf_nat_proto_gre.c b/net/ipv4/netfilter/nf_nat_proto_gre.c
index 93198d71dbb6..edf05002d674 100644
--- a/net/ipv4/netfilter/nf_nat_proto_gre.c
+++ b/net/ipv4/netfilter/nf_nat_proto_gre.c
@@ -88,8 +88,8 @@ gre_manip_pkt(struct sk_buff *skb,
 	      const struct nf_conntrack_tuple *tuple,
 	      enum nf_nat_manip_type maniptype)
 {
-	const struct gre_hdr *greh;
-	struct gre_hdr_pptp *pgreh;
+	const struct gre_base_hdr *greh;
+	struct pptp_gre_header *pgreh;
 
 	/* pgreh includes two optional 32bit fields which are not required
 	 * to be there.  That's where the magic '8' comes from */
@@ -97,18 +97,19 @@ gre_manip_pkt(struct sk_buff *skb,
 		return false;
 
 	greh = (void *)skb->data + hdroff;
-	pgreh = (struct gre_hdr_pptp *)greh;
+	pgreh = (struct pptp_gre_header *)greh;
 
 	/* we only have destination manip of a packet, since 'source key'
 	 * is not present in the packet itself */
 	if (maniptype != NF_NAT_MANIP_DST)
 		return true;
-	switch (greh->version) {
-	case ntohs(GRE_VERSION_0):
+
+	switch (greh->flags & GRE_VERSION) {
+	case GRE_VERSION_0:
 		/* We do not currently NAT any GREv0 packets.
 		 * Try to behave like "nf_nat_proto_unknown" */
 		break;
-	case ntohs(GRE_VERSION_1):
+	case GRE_VERSION_1:
 		pr_debug("call_id -> 0x%04x\n", ntohs(tuple->dst.u.gre.key));
 		pgreh->call_id = tuple->dst.u.gre.key;
 		break;
diff --git a/net/netfilter/nf_conntrack_proto_gre.c b/net/netfilter/nf_conntrack_proto_gre.c
index deb239a014e4..9a715f88b2f1 100644
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
-	if (!grehdr || grehdr->version != ntohs(GRE_VERSION_1)) {
+	if (!grehdr || (grehdr->flags & GRE_VERSION) != GRE_VERSION_1) {
 		/* try to behave like "nf_conntrack_proto_generic" */
 		tuple->src.u.all = 0;
 		tuple->dst.u.all = 0;
@@ -213,7 +213,7 @@ static bool gre_pkt_to_tuple(const struct sk_buff *skb, unsigned int dataoff,
 		return true;
 
 	if (grehdr->protocol != GRE_PROTO_PPP) {
-		pr_debug("GRE_VERSION_PPTP but unknown proto\n");
+		pr_debug("Unsupported GRE proto(0x%x)\n", ntohs(grehdr->protocol));
 		return false;
 	}
 
-- 
2.1.4

