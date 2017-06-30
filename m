From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next 01/11] sctp: remove the typedef sctp_sctphdr_t
Date: Fri, 30 Jun 2017 11:52:12 +0800
Message-ID: <d99d14fbe257b7d7b290296646772c6df35a36c8.1498794482.git.lucien.xin@gmail.com>
References: <cover.1498794481.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:34042 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751722AbdF3Dwp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2017 23:52:45 -0400
In-Reply-To: <cover.1498794481.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1498794481.git.lucien.xin@gmail.com>
References: <cover.1498794481.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to remove the typedef sctp_sctphdr_t, and replace
with struct sctphdr in the places where it's using this typedef.

It is also to fix some indents and use sizeof(variable) instead
of sizeof(type).

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/linux/sctp.h                    |  4 ++--
 net/netfilter/ipset/ip_set_getport.c    |  4 ++--
 net/netfilter/ipvs/ip_vs_core.c         |  6 +++---
 net/netfilter/ipvs/ip_vs_proto_sctp.c   | 15 +++++++--------
 net/netfilter/nf_conntrack_proto_sctp.c |  2 +-
 net/netfilter/nf_nat_proto_sctp.c       |  2 +-
 net/netfilter/xt_sctp.c                 | 16 ++++++++--------
 7 files changed, 24 insertions(+), 25 deletions(-)

diff --git a/include/linux/sctp.h b/include/linux/sctp.h
index 7a4804c..85540ec 100644
--- a/include/linux/sctp.h
+++ b/include/linux/sctp.h
@@ -57,12 +57,12 @@
 #include <uapi/linux/sctp.h>
 
 /* Section 3.1.  SCTP Common Header Format */
-typedef struct sctphdr {
+struct sctphdr {
 	__be16 source;
 	__be16 dest;
 	__be32 vtag;
 	__le32 checksum;
-} sctp_sctphdr_t;
+};
 
 static inline struct sctphdr *sctp_hdr(const struct sk_buff *skb)
 {
diff --git a/net/netfilter/ipset/ip_set_getport.c b/net/netfilter/ipset/ip_set_getport.c
index 42c3e3b..3f09cdb 100644
--- a/net/netfilter/ipset/ip_set_getport.c
+++ b/net/netfilter/ipset/ip_set_getport.c
@@ -38,8 +38,8 @@ get_port(const struct sk_buff *skb, int protocol, unsigned int protooff,
 		break;
 	}
 	case IPPROTO_SCTP: {
-		sctp_sctphdr_t _sh;
-		const sctp_sctphdr_t *sh;
+		struct sctphdr _sh;
+		const struct sctphdr *sh;
 
 		sh = skb_header_pointer(skb, protooff, sizeof(_sh), &_sh);
 		if (!sh)
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index ad99c1c..6f39af9 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1038,8 +1038,8 @@ static int ip_vs_out_icmp_v6(struct netns_ipvs *ipvs, struct sk_buff *skb,
 static inline int is_sctp_abort(const struct sk_buff *skb, int nh_len)
 {
 	sctp_chunkhdr_t *sch, schunk;
-	sch = skb_header_pointer(skb, nh_len + sizeof(sctp_sctphdr_t),
-			sizeof(schunk), &schunk);
+	sch = skb_header_pointer(skb, nh_len + sizeof(struct sctphdr),
+				 sizeof(schunk), &schunk);
 	if (sch == NULL)
 		return 0;
 	if (sch->type == SCTP_CID_ABORT)
@@ -1072,7 +1072,7 @@ static inline bool is_new_conn(const struct sk_buff *skb,
 	case IPPROTO_SCTP: {
 		sctp_chunkhdr_t *sch, schunk;
 
-		sch = skb_header_pointer(skb, iph->len + sizeof(sctp_sctphdr_t),
+		sch = skb_header_pointer(skb, iph->len + sizeof(struct sctphdr),
 					 sizeof(schunk), &schunk);
 		if (sch == NULL)
 			return false;
diff --git a/net/netfilter/ipvs/ip_vs_proto_sctp.c b/net/netfilter/ipvs/ip_vs_proto_sctp.c
index 56f8e4b..6b38cad 100644
--- a/net/netfilter/ipvs/ip_vs_proto_sctp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_sctp.c
@@ -16,15 +16,14 @@ sctp_conn_schedule(struct netns_ipvs *ipvs, int af, struct sk_buff *skb,
 {
 	struct ip_vs_service *svc;
 	sctp_chunkhdr_t _schunkh, *sch;
-	sctp_sctphdr_t *sh, _sctph;
+	struct sctphdr *sh, _sctph;
 	__be16 _ports[2], *ports = NULL;
 
 	if (likely(!ip_vs_iph_icmp(iph))) {
 		sh = skb_header_pointer(skb, iph->len, sizeof(_sctph), &_sctph);
 		if (sh) {
-			sch = skb_header_pointer(
-				skb, iph->len + sizeof(sctp_sctphdr_t),
-				sizeof(_schunkh), &_schunkh);
+			sch = skb_header_pointer(skb, iph->len + sizeof(_sctph),
+						 sizeof(_schunkh), &_schunkh);
 			if (sch && (sch->type == SCTP_CID_INIT ||
 				    sysctl_sloppy_sctp(ipvs)))
 				ports = &sh->source;
@@ -77,7 +76,7 @@ sctp_conn_schedule(struct netns_ipvs *ipvs, int af, struct sk_buff *skb,
 	return 1;
 }
 
-static void sctp_nat_csum(struct sk_buff *skb, sctp_sctphdr_t *sctph,
+static void sctp_nat_csum(struct sk_buff *skb, struct sctphdr *sctph,
 			  unsigned int sctphoff)
 {
 	sctph->checksum = sctp_compute_cksum(skb, sctphoff);
@@ -88,7 +87,7 @@ static int
 sctp_snat_handler(struct sk_buff *skb, struct ip_vs_protocol *pp,
 		  struct ip_vs_conn *cp, struct ip_vs_iphdr *iph)
 {
-	sctp_sctphdr_t *sctph;
+	struct sctphdr *sctph;
 	unsigned int sctphoff = iph->len;
 	bool payload_csum = false;
 
@@ -135,7 +134,7 @@ static int
 sctp_dnat_handler(struct sk_buff *skb, struct ip_vs_protocol *pp,
 		  struct ip_vs_conn *cp, struct ip_vs_iphdr *iph)
 {
-	sctp_sctphdr_t *sctph;
+	struct sctphdr *sctph;
 	unsigned int sctphoff = iph->len;
 	bool payload_csum = false;
 
@@ -389,7 +388,7 @@ set_sctp_state(struct ip_vs_proto_data *pd, struct ip_vs_conn *cp,
 	ihl = ip_hdrlen(skb);
 #endif
 
-	cofs = ihl + sizeof(sctp_sctphdr_t);
+	cofs = ihl + sizeof(struct sctphdr);
 	sch = skb_header_pointer(skb, cofs, sizeof(_sctpch), &_sctpch);
 	if (sch == NULL)
 		return;
diff --git a/net/netfilter/nf_conntrack_proto_sctp.c b/net/netfilter/nf_conntrack_proto_sctp.c
index 1c5b14a..db87af4 100644
--- a/net/netfilter/nf_conntrack_proto_sctp.c
+++ b/net/netfilter/nf_conntrack_proto_sctp.c
@@ -190,7 +190,7 @@ static void sctp_print_conntrack(struct seq_file *s, struct nf_conn *ct)
 }
 
 #define for_each_sctp_chunk(skb, sch, _sch, offset, dataoff, count)	\
-for ((offset) = (dataoff) + sizeof(sctp_sctphdr_t), (count) = 0;	\
+for ((offset) = (dataoff) + sizeof(struct sctphdr), (count) = 0;	\
 	(offset) < (skb)->len &&					\
 	((sch) = skb_header_pointer((skb), (offset), sizeof(_sch), &(_sch)));	\
 	(offset) += (ntohs((sch)->length) + 3) & ~3, (count)++)
diff --git a/net/netfilter/nf_nat_proto_sctp.c b/net/netfilter/nf_nat_proto_sctp.c
index 804e8a0..c57ee32 100644
--- a/net/netfilter/nf_nat_proto_sctp.c
+++ b/net/netfilter/nf_nat_proto_sctp.c
@@ -32,7 +32,7 @@ sctp_manip_pkt(struct sk_buff *skb,
 	       const struct nf_conntrack_tuple *tuple,
 	       enum nf_nat_manip_type maniptype)
 {
-	sctp_sctphdr_t *hdr;
+	struct sctphdr *hdr;
 	int hdrsize = 8;
 
 	/* This could be an inner header returned in imcp packet; in such
diff --git a/net/netfilter/xt_sctp.c b/net/netfilter/xt_sctp.c
index 4dedb96..0f20ea4 100644
--- a/net/netfilter/xt_sctp.c
+++ b/net/netfilter/xt_sctp.c
@@ -118,8 +118,8 @@ static bool
 sctp_mt(const struct sk_buff *skb, struct xt_action_param *par)
 {
 	const struct xt_sctp_info *info = par->matchinfo;
-	const sctp_sctphdr_t *sh;
-	sctp_sctphdr_t _sh;
+	const struct sctphdr *sh;
+	struct sctphdr _sh;
 
 	if (par->fragoff != 0) {
 		pr_debug("Dropping non-first fragment.. FIXME\n");
@@ -136,13 +136,13 @@ sctp_mt(const struct sk_buff *skb, struct xt_action_param *par)
 
 	return  SCCHECK(ntohs(sh->source) >= info->spts[0]
 			&& ntohs(sh->source) <= info->spts[1],
-			XT_SCTP_SRC_PORTS, info->flags, info->invflags)
-		&& SCCHECK(ntohs(sh->dest) >= info->dpts[0]
+			XT_SCTP_SRC_PORTS, info->flags, info->invflags) &&
+		SCCHECK(ntohs(sh->dest) >= info->dpts[0]
 			&& ntohs(sh->dest) <= info->dpts[1],
-			XT_SCTP_DEST_PORTS, info->flags, info->invflags)
-		&& SCCHECK(match_packet(skb, par->thoff + sizeof(sctp_sctphdr_t),
-					info, &par->hotdrop),
-			   XT_SCTP_CHUNK_TYPES, info->flags, info->invflags);
+			XT_SCTP_DEST_PORTS, info->flags, info->invflags) &&
+		SCCHECK(match_packet(skb, par->thoff + sizeof(_sh),
+				     info, &par->hotdrop),
+			XT_SCTP_CHUNK_TYPES, info->flags, info->invflags);
 }
 
 static int sctp_mt_check(const struct xt_mtchk_param *par)
-- 
2.1.0
