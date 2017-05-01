From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 07/53] netfilter: nat: nf_nat_mangle_{udp,tcp}_packet returns boolean
Date: Mon,  1 May 2017 12:46:34 +0200
Message-ID: <1493635640-24325-8-git-send-email-pablo@netfilter.org>
References: <1493635640-24325-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1493635640-24325-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Gao Feng <fgao@ikuai8.com>

nf_nat_mangle_{udp,tcp}_packet() returns int. However, it is used as
bool type in many spots. Fix this by consistently handle this return
value as a boolean.

Signed-off-by: Gao Feng <fgao@ikuai8.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_nat_helper.h | 36 +++++++++++++++----------------
 net/ipv4/netfilter/nf_nat_pptp.c      | 20 +++++++++---------
 net/netfilter/ipvs/ip_vs_ftp.c        | 13 +++++++-----
 net/netfilter/nf_nat_amanda.c         | 11 +++++-----
 net/netfilter/nf_nat_helper.c         | 40 +++++++++++++++++------------------
 net/netfilter/nf_nat_irc.c            |  9 ++++----
 6 files changed, 65 insertions(+), 64 deletions(-)

diff --git a/include/net/netfilter/nf_nat_helper.h b/include/net/netfilter/nf_nat_helper.h
index 01bcc6bfbcc9..fbfa5acf4f14 100644
--- a/include/net/netfilter/nf_nat_helper.h
+++ b/include/net/netfilter/nf_nat_helper.h
@@ -7,31 +7,31 @@
 struct sk_buff;
 
 /* These return true or false. */
-int __nf_nat_mangle_tcp_packet(struct sk_buff *skb, struct nf_conn *ct,
-			       enum ip_conntrack_info ctinfo,
-			       unsigned int protoff, unsigned int match_offset,
-			       unsigned int match_len, const char *rep_buffer,
-			       unsigned int rep_len, bool adjust);
+bool __nf_nat_mangle_tcp_packet(struct sk_buff *skb, struct nf_conn *ct,
+				enum ip_conntrack_info ctinfo,
+				unsigned int protoff, unsigned int match_offset,
+				unsigned int match_len, const char *rep_buffer,
+				unsigned int rep_len, bool adjust);
 
-static inline int nf_nat_mangle_tcp_packet(struct sk_buff *skb,
-					   struct nf_conn *ct,
-					   enum ip_conntrack_info ctinfo,
-					   unsigned int protoff,
-					   unsigned int match_offset,
-					   unsigned int match_len,
-					   const char *rep_buffer,
-					   unsigned int rep_len)
+static inline bool nf_nat_mangle_tcp_packet(struct sk_buff *skb,
+					    struct nf_conn *ct,
+					    enum ip_conntrack_info ctinfo,
+					    unsigned int protoff,
+					    unsigned int match_offset,
+					    unsigned int match_len,
+					    const char *rep_buffer,
+					    unsigned int rep_len)
 {
 	return __nf_nat_mangle_tcp_packet(skb, ct, ctinfo, protoff,
 					  match_offset, match_len,
 					  rep_buffer, rep_len, true);
 }
 
-int nf_nat_mangle_udp_packet(struct sk_buff *skb, struct nf_conn *ct,
-			     enum ip_conntrack_info ctinfo,
-			     unsigned int protoff, unsigned int match_offset,
-			     unsigned int match_len, const char *rep_buffer,
-			     unsigned int rep_len);
+bool nf_nat_mangle_udp_packet(struct sk_buff *skb, struct nf_conn *ct,
+			      enum ip_conntrack_info ctinfo,
+			      unsigned int protoff, unsigned int match_offset,
+			      unsigned int match_len, const char *rep_buffer,
+			      unsigned int rep_len);
 
 /* Setup NAT on this expected conntrack so it follows master, but goes
  * to port ct->master->saved_proto. */
diff --git a/net/ipv4/netfilter/nf_nat_pptp.c b/net/ipv4/netfilter/nf_nat_pptp.c
index b3ca21b2ba9b..211fee5fe59d 100644
--- a/net/ipv4/netfilter/nf_nat_pptp.c
+++ b/net/ipv4/netfilter/nf_nat_pptp.c
@@ -177,11 +177,11 @@ pptp_outbound_pkt(struct sk_buff *skb,
 		 ntohs(REQ_CID(pptpReq, cid_off)), ntohs(new_callid));
 
 	/* mangle packet */
-	if (nf_nat_mangle_tcp_packet(skb, ct, ctinfo, protoff,
-				     cid_off + sizeof(struct pptp_pkt_hdr) +
-				     sizeof(struct PptpControlHeader),
-				     sizeof(new_callid), (char *)&new_callid,
-				     sizeof(new_callid)) == 0)
+	if (!nf_nat_mangle_tcp_packet(skb, ct, ctinfo, protoff,
+				      cid_off + sizeof(struct pptp_pkt_hdr) +
+				      sizeof(struct PptpControlHeader),
+				      sizeof(new_callid), (char *)&new_callid,
+				      sizeof(new_callid)))
 		return NF_DROP;
 	return NF_ACCEPT;
 }
@@ -271,11 +271,11 @@ pptp_inbound_pkt(struct sk_buff *skb,
 	pr_debug("altering peer call id from 0x%04x to 0x%04x\n",
 		 ntohs(REQ_CID(pptpReq, pcid_off)), ntohs(new_pcid));
 
-	if (nf_nat_mangle_tcp_packet(skb, ct, ctinfo, protoff,
-				     pcid_off + sizeof(struct pptp_pkt_hdr) +
-				     sizeof(struct PptpControlHeader),
-				     sizeof(new_pcid), (char *)&new_pcid,
-				     sizeof(new_pcid)) == 0)
+	if (!nf_nat_mangle_tcp_packet(skb, ct, ctinfo, protoff,
+				      pcid_off + sizeof(struct pptp_pkt_hdr) +
+				      sizeof(struct PptpControlHeader),
+				      sizeof(new_pcid), (char *)&new_pcid,
+				      sizeof(new_pcid)))
 		return NF_DROP;
 	return NF_ACCEPT;
 }
diff --git a/net/netfilter/ipvs/ip_vs_ftp.c b/net/netfilter/ipvs/ip_vs_ftp.c
index d30c327bb578..e9e721e63844 100644
--- a/net/netfilter/ipvs/ip_vs_ftp.c
+++ b/net/netfilter/ipvs/ip_vs_ftp.c
@@ -261,6 +261,8 @@ static int ip_vs_ftp_out(struct ip_vs_app *app, struct ip_vs_conn *cp,
 
 		ct = nf_ct_get(skb, &ctinfo);
 		if (ct && !nf_ct_is_untracked(ct) && nfct_nat(ct)) {
+			bool mangled;
+
 			/* If mangling fails this function will return 0
 			 * which will cause the packet to be dropped.
 			 * Mangling can only fail under memory pressure,
@@ -268,12 +270,13 @@ static int ip_vs_ftp_out(struct ip_vs_app *app, struct ip_vs_conn *cp,
 			 * packet.
 			 */
 			rcu_read_lock();
-			ret = nf_nat_mangle_tcp_packet(skb, ct, ctinfo,
-						       iph->ihl * 4,
-						       start-data, end-start,
-						       buf, buf_len);
+			mangled = nf_nat_mangle_tcp_packet(skb, ct, ctinfo,
+							   iph->ihl * 4,
+							   start - data,
+							   end - start,
+							   buf, buf_len);
 			rcu_read_unlock();
-			if (ret) {
+			if (mangled) {
 				ip_vs_nfct_expect_related(skb, ct, n_cp,
 							  IPPROTO_TCP, 0, 0);
 				if (skb->ip_summed == CHECKSUM_COMPLETE)
diff --git a/net/netfilter/nf_nat_amanda.c b/net/netfilter/nf_nat_amanda.c
index eb772380a202..e4d61a7a5258 100644
--- a/net/netfilter/nf_nat_amanda.c
+++ b/net/netfilter/nf_nat_amanda.c
@@ -33,7 +33,6 @@ static unsigned int help(struct sk_buff *skb,
 {
 	char buffer[sizeof("65535")];
 	u_int16_t port;
-	unsigned int ret;
 
 	/* Connection comes from client. */
 	exp->saved_proto.tcp.port = exp->tuple.dst.u.tcp.port;
@@ -63,14 +62,14 @@ static unsigned int help(struct sk_buff *skb,
 	}
 
 	sprintf(buffer, "%u", port);
-	ret = nf_nat_mangle_udp_packet(skb, exp->master, ctinfo,
-				       protoff, matchoff, matchlen,
-				       buffer, strlen(buffer));
-	if (ret != NF_ACCEPT) {
+	if (!nf_nat_mangle_udp_packet(skb, exp->master, ctinfo,
+				      protoff, matchoff, matchlen,
+				      buffer, strlen(buffer))) {
 		nf_ct_helper_log(skb, exp->master, "cannot mangle packet");
 		nf_ct_unexpect_related(exp);
+		return NF_DROP;
 	}
-	return ret;
+	return NF_ACCEPT;
 }
 
 static void __exit nf_nat_amanda_fini(void)
diff --git a/net/netfilter/nf_nat_helper.c b/net/netfilter/nf_nat_helper.c
index 211661cb2c90..607a373379b4 100644
--- a/net/netfilter/nf_nat_helper.c
+++ b/net/netfilter/nf_nat_helper.c
@@ -70,15 +70,15 @@ static void mangle_contents(struct sk_buff *skb,
 }
 
 /* Unusual, but possible case. */
-static int enlarge_skb(struct sk_buff *skb, unsigned int extra)
+static bool enlarge_skb(struct sk_buff *skb, unsigned int extra)
 {
 	if (skb->len + extra > 65535)
-		return 0;
+		return false;
 
 	if (pskb_expand_head(skb, 0, extra - skb_tailroom(skb), GFP_ATOMIC))
-		return 0;
+		return false;
 
-	return 1;
+	return true;
 }
 
 /* Generic function for mangling variable-length address changes inside
@@ -89,26 +89,26 @@ static int enlarge_skb(struct sk_buff *skb, unsigned int extra)
  * skb enlargement, ...
  *
  * */
-int __nf_nat_mangle_tcp_packet(struct sk_buff *skb,
-			       struct nf_conn *ct,
-			       enum ip_conntrack_info ctinfo,
-			       unsigned int protoff,
-			       unsigned int match_offset,
-			       unsigned int match_len,
-			       const char *rep_buffer,
-			       unsigned int rep_len, bool adjust)
+bool __nf_nat_mangle_tcp_packet(struct sk_buff *skb,
+				struct nf_conn *ct,
+				enum ip_conntrack_info ctinfo,
+				unsigned int protoff,
+				unsigned int match_offset,
+				unsigned int match_len,
+				const char *rep_buffer,
+				unsigned int rep_len, bool adjust)
 {
 	const struct nf_nat_l3proto *l3proto;
 	struct tcphdr *tcph;
 	int oldlen, datalen;
 
 	if (!skb_make_writable(skb, skb->len))
-		return 0;
+		return false;
 
 	if (rep_len > match_len &&
 	    rep_len - match_len > skb_tailroom(skb) &&
 	    !enlarge_skb(skb, rep_len - match_len))
-		return 0;
+		return false;
 
 	SKB_LINEAR_ASSERT(skb);
 
@@ -128,7 +128,7 @@ int __nf_nat_mangle_tcp_packet(struct sk_buff *skb,
 		nf_ct_seqadj_set(ct, ctinfo, tcph->seq,
 				 (int)rep_len - (int)match_len);
 
-	return 1;
+	return true;
 }
 EXPORT_SYMBOL(__nf_nat_mangle_tcp_packet);
 
@@ -142,7 +142,7 @@ EXPORT_SYMBOL(__nf_nat_mangle_tcp_packet);
  * XXX - This function could be merged with nf_nat_mangle_tcp_packet which
  *       should be fairly easy to do.
  */
-int
+bool
 nf_nat_mangle_udp_packet(struct sk_buff *skb,
 			 struct nf_conn *ct,
 			 enum ip_conntrack_info ctinfo,
@@ -157,12 +157,12 @@ nf_nat_mangle_udp_packet(struct sk_buff *skb,
 	int datalen, oldlen;
 
 	if (!skb_make_writable(skb, skb->len))
-		return 0;
+		return false;
 
 	if (rep_len > match_len &&
 	    rep_len - match_len > skb_tailroom(skb) &&
 	    !enlarge_skb(skb, rep_len - match_len))
-		return 0;
+		return false;
 
 	udph = (void *)skb->data + protoff;
 
@@ -176,13 +176,13 @@ nf_nat_mangle_udp_packet(struct sk_buff *skb,
 
 	/* fix udp checksum if udp checksum was previously calculated */
 	if (!udph->check && skb->ip_summed != CHECKSUM_PARTIAL)
-		return 1;
+		return true;
 
 	l3proto = __nf_nat_l3proto_find(nf_ct_l3num(ct));
 	l3proto->csum_recalc(skb, IPPROTO_UDP, udph, &udph->check,
 			     datalen, oldlen);
 
-	return 1;
+	return true;
 }
 EXPORT_SYMBOL(nf_nat_mangle_udp_packet);
 
diff --git a/net/netfilter/nf_nat_irc.c b/net/netfilter/nf_nat_irc.c
index 1fb2258c3535..0648cb096bd8 100644
--- a/net/netfilter/nf_nat_irc.c
+++ b/net/netfilter/nf_nat_irc.c
@@ -37,7 +37,6 @@ static unsigned int help(struct sk_buff *skb,
 	struct nf_conn *ct = exp->master;
 	union nf_inet_addr newaddr;
 	u_int16_t port;
-	unsigned int ret;
 
 	/* Reply comes from server. */
 	newaddr = ct->tuplehash[IP_CT_DIR_REPLY].tuple.dst.u3;
@@ -83,14 +82,14 @@ static unsigned int help(struct sk_buff *skb,
 	pr_debug("nf_nat_irc: inserting '%s' == %pI4, port %u\n",
 		 buffer, &newaddr.ip, port);
 
-	ret = nf_nat_mangle_tcp_packet(skb, ct, ctinfo, protoff, matchoff,
-				       matchlen, buffer, strlen(buffer));
-	if (ret != NF_ACCEPT) {
+	if (!nf_nat_mangle_tcp_packet(skb, ct, ctinfo, protoff, matchoff,
+				      matchlen, buffer, strlen(buffer))) {
 		nf_ct_helper_log(skb, ct, "cannot mangle packet");
 		nf_ct_unexpect_related(exp);
+		return NF_DROP;
 	}
 
-	return ret;
+	return NF_ACCEPT;
 }
 
 static void __exit nf_nat_irc_fini(void)
-- 
2.1.4

