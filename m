From: kaber@trash.net
Subject: [PATCH 08/19] netfilter: nf_nat: add protoff argument to packet mangling functions
Date: Thu,  9 Aug 2012 22:08:52 +0200
Message-ID: <1344542943-11588-9-git-send-email-kaber@trash.net>
References: <1344542943-11588-1-git-send-email-kaber@trash.net>
Cc: netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:65317 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754756Ab2HIUSi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Aug 2012 16:18:38 -0400
In-Reply-To: <1344542943-11588-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>

For mangling IPv6 packets the protocol header offset needs to be known
by the NAT packet mangling functions. Add a so far unused protoff argument
and convert the conntrack and NAT helpers to use it in preparation of
IPv6 NAT.

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/linux/netfilter/nf_conntrack_amanda.h  |    1 +
 include/linux/netfilter/nf_conntrack_ftp.h     |    1 +
 include/linux/netfilter/nf_conntrack_h323.h    |   15 ++-
 include/linux/netfilter/nf_conntrack_irc.h     |    1 +
 include/linux/netfilter/nf_conntrack_pptp.h    |    2 +
 include/linux/netfilter/nf_conntrack_sip.h     |   12 ++-
 include/net/netfilter/nf_nat_helper.h          |   11 +-
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c |    6 +-
 net/ipv4/netfilter/nf_nat_amanda.c             |    3 +-
 net/ipv4/netfilter/nf_nat_ftp.c                |    3 +-
 net/ipv4/netfilter/nf_nat_h323.c               |   48 ++++---
 net/ipv4/netfilter/nf_nat_helper.c             |    9 +-
 net/ipv4/netfilter/nf_nat_irc.c                |    3 +-
 net/ipv4/netfilter/nf_nat_pptp.c               |    6 +-
 net/ipv4/netfilter/nf_nat_sip.c                |   96 +++++++-----
 net/netfilter/ipvs/ip_vs_ftp.c                 |    1 +
 net/netfilter/nf_conntrack_amanda.c            |    5 +-
 net/netfilter/nf_conntrack_ftp.c               |    3 +-
 net/netfilter/nf_conntrack_h323_main.c         |  191 +++++++++++++++---------
 net/netfilter/nf_conntrack_irc.c               |    3 +-
 net/netfilter/nf_conntrack_pptp.c              |   18 ++-
 net/netfilter/nf_conntrack_sip.c               |   95 +++++++-----
 22 files changed, 328 insertions(+), 205 deletions(-)

diff --git a/include/linux/netfilter/nf_conntrack_amanda.h b/include/linux/netfilter/nf_conntrack_amanda.h
index 0bb5a69..4b59a15 100644
--- a/include/linux/netfilter/nf_conntrack_amanda.h
+++ b/include/linux/netfilter/nf_conntrack_amanda.h
@@ -4,6 +4,7 @@
 
 extern unsigned int (*nf_nat_amanda_hook)(struct sk_buff *skb,
 					  enum ip_conntrack_info ctinfo,
+					  unsigned int protoff,
 					  unsigned int matchoff,
 					  unsigned int matchlen,
 					  struct nf_conntrack_expect *exp);
diff --git a/include/linux/netfilter/nf_conntrack_ftp.h b/include/linux/netfilter/nf_conntrack_ftp.h
index 3e3aa08..28f18df 100644
--- a/include/linux/netfilter/nf_conntrack_ftp.h
+++ b/include/linux/netfilter/nf_conntrack_ftp.h
@@ -34,6 +34,7 @@ struct nf_conntrack_expect;
 extern unsigned int (*nf_nat_ftp_hook)(struct sk_buff *skb,
 				       enum ip_conntrack_info ctinfo,
 				       enum nf_ct_ftp_type type,
+				       unsigned int protoff,
 				       unsigned int matchoff,
 				       unsigned int matchlen,
 				       struct nf_conntrack_expect *exp);
diff --git a/include/linux/netfilter/nf_conntrack_h323.h b/include/linux/netfilter/nf_conntrack_h323.h
index 26f9226..f381020 100644
--- a/include/linux/netfilter/nf_conntrack_h323.h
+++ b/include/linux/netfilter/nf_conntrack_h323.h
@@ -36,12 +36,12 @@ extern void nf_conntrack_h245_expect(struct nf_conn *new,
 				     struct nf_conntrack_expect *this);
 extern void nf_conntrack_q931_expect(struct nf_conn *new,
 				     struct nf_conntrack_expect *this);
-extern int (*set_h245_addr_hook) (struct sk_buff *skb,
+extern int (*set_h245_addr_hook) (struct sk_buff *skb, unsigned int protoff,
 				  unsigned char **data, int dataoff,
 				  H245_TransportAddress *taddr,
 				  union nf_inet_addr *addr,
 				  __be16 port);
-extern int (*set_h225_addr_hook) (struct sk_buff *skb,
+extern int (*set_h225_addr_hook) (struct sk_buff *skb, unsigned int protoff,
 				  unsigned char **data, int dataoff,
 				  TransportAddress *taddr,
 				  union nf_inet_addr *addr,
@@ -49,40 +49,45 @@ extern int (*set_h225_addr_hook) (struct sk_buff *skb,
 extern int (*set_sig_addr_hook) (struct sk_buff *skb,
 				 struct nf_conn *ct,
 				 enum ip_conntrack_info ctinfo,
-				 unsigned char **data,
+				 unsigned int protoff, unsigned char **data,
 				 TransportAddress *taddr, int count);
 extern int (*set_ras_addr_hook) (struct sk_buff *skb,
 				 struct nf_conn *ct,
 				 enum ip_conntrack_info ctinfo,
-				 unsigned char **data,
+				 unsigned int protoff, unsigned char **data,
 				 TransportAddress *taddr, int count);
 extern int (*nat_rtp_rtcp_hook) (struct sk_buff *skb,
 				 struct nf_conn *ct,
 				 enum ip_conntrack_info ctinfo,
-				 unsigned char **data, int dataoff,
+				 unsigned int protoff, unsigned char **data,
+				 int dataoff,
 				 H245_TransportAddress *taddr,
 				 __be16 port, __be16 rtp_port,
 				 struct nf_conntrack_expect *rtp_exp,
 				 struct nf_conntrack_expect *rtcp_exp);
 extern int (*nat_t120_hook) (struct sk_buff *skb, struct nf_conn *ct,
 			     enum ip_conntrack_info ctinfo,
+			     unsigned int protoff,
 			     unsigned char **data, int dataoff,
 			     H245_TransportAddress *taddr, __be16 port,
 			     struct nf_conntrack_expect *exp);
 extern int (*nat_h245_hook) (struct sk_buff *skb, struct nf_conn *ct,
 			     enum ip_conntrack_info ctinfo,
+			     unsigned int protoff,
 			     unsigned char **data, int dataoff,
 			     TransportAddress *taddr, __be16 port,
 			     struct nf_conntrack_expect *exp);
 extern int (*nat_callforwarding_hook) (struct sk_buff *skb,
 				       struct nf_conn *ct,
 				       enum ip_conntrack_info ctinfo,
+				       unsigned int protoff,
 				       unsigned char **data, int dataoff,
 				       TransportAddress *taddr,
 				       __be16 port,
 				       struct nf_conntrack_expect *exp);
 extern int (*nat_q931_hook) (struct sk_buff *skb, struct nf_conn *ct,
 			     enum ip_conntrack_info ctinfo,
+			     unsigned int protoff,
 			     unsigned char **data, TransportAddress *taddr,
 			     int idx, __be16 port,
 			     struct nf_conntrack_expect *exp);
diff --git a/include/linux/netfilter/nf_conntrack_irc.h b/include/linux/netfilter/nf_conntrack_irc.h
index 36282bf..4bb9bae 100644
--- a/include/linux/netfilter/nf_conntrack_irc.h
+++ b/include/linux/netfilter/nf_conntrack_irc.h
@@ -7,6 +7,7 @@
 
 extern unsigned int (*nf_nat_irc_hook)(struct sk_buff *skb,
 				       enum ip_conntrack_info ctinfo,
+				       unsigned int protoff,
 				       unsigned int matchoff,
 				       unsigned int matchlen,
 				       struct nf_conntrack_expect *exp);
diff --git a/include/linux/netfilter/nf_conntrack_pptp.h b/include/linux/netfilter/nf_conntrack_pptp.h
index 3bbde0c..2ab2830 100644
--- a/include/linux/netfilter/nf_conntrack_pptp.h
+++ b/include/linux/netfilter/nf_conntrack_pptp.h
@@ -303,12 +303,14 @@ struct nf_conntrack_expect;
 extern int
 (*nf_nat_pptp_hook_outbound)(struct sk_buff *skb,
 			     struct nf_conn *ct, enum ip_conntrack_info ctinfo,
+			     unsigned int protoff,
 			     struct PptpControlHeader *ctlh,
 			     union pptp_ctrl_union *pptpReq);
 
 extern int
 (*nf_nat_pptp_hook_inbound)(struct sk_buff *skb,
 			    struct nf_conn *ct, enum ip_conntrack_info ctinfo,
+			    unsigned int protoff,
 			    struct PptpControlHeader *ctlh,
 			    union pptp_ctrl_union *pptpReq);
 
diff --git a/include/linux/netfilter/nf_conntrack_sip.h b/include/linux/netfilter/nf_conntrack_sip.h
index 89f2a62..1afc669 100644
--- a/include/linux/netfilter/nf_conntrack_sip.h
+++ b/include/linux/netfilter/nf_conntrack_sip.h
@@ -37,10 +37,12 @@ struct sdp_media_type {
 struct sip_handler {
 	const char	*method;
 	unsigned int	len;
-	int		(*request)(struct sk_buff *skb, unsigned int dataoff,
+	int		(*request)(struct sk_buff *skb, unsigned int protoff,
+				   unsigned int dataoff,
 				   const char **dptr, unsigned int *datalen,
 				   unsigned int cseq);
-	int		(*response)(struct sk_buff *skb, unsigned int dataoff,
+	int		(*response)(struct sk_buff *skb, unsigned int protoff,
+				    unsigned int dataoff,
 				    const char **dptr, unsigned int *datalen,
 				    unsigned int cseq, unsigned int code);
 };
@@ -105,11 +107,13 @@ enum sdp_header_types {
 };
 
 extern unsigned int (*nf_nat_sip_hook)(struct sk_buff *skb,
+				       unsigned int protoff,
 				       unsigned int dataoff,
 				       const char **dptr,
 				       unsigned int *datalen);
 extern void (*nf_nat_sip_seq_adjust_hook)(struct sk_buff *skb, s16 off);
 extern unsigned int (*nf_nat_sip_expect_hook)(struct sk_buff *skb,
+					      unsigned int protoff,
 					      unsigned int dataoff,
 					      const char **dptr,
 					      unsigned int *datalen,
@@ -117,6 +121,7 @@ extern unsigned int (*nf_nat_sip_expect_hook)(struct sk_buff *skb,
 					      unsigned int matchoff,
 					      unsigned int matchlen);
 extern unsigned int (*nf_nat_sdp_addr_hook)(struct sk_buff *skb,
+					    unsigned int protoff,
 					    unsigned int dataoff,
 					    const char **dptr,
 					    unsigned int *datalen,
@@ -125,6 +130,7 @@ extern unsigned int (*nf_nat_sdp_addr_hook)(struct sk_buff *skb,
 					    enum sdp_header_types term,
 					    const union nf_inet_addr *addr);
 extern unsigned int (*nf_nat_sdp_port_hook)(struct sk_buff *skb,
+					    unsigned int protoff,
 					    unsigned int dataoff,
 					    const char **dptr,
 					    unsigned int *datalen,
@@ -132,12 +138,14 @@ extern unsigned int (*nf_nat_sdp_port_hook)(struct sk_buff *skb,
 					    unsigned int matchlen,
 					    u_int16_t port);
 extern unsigned int (*nf_nat_sdp_session_hook)(struct sk_buff *skb,
+					       unsigned int protoff,
 					       unsigned int dataoff,
 					       const char **dptr,
 					       unsigned int *datalen,
 					       unsigned int sdpoff,
 					       const union nf_inet_addr *addr);
 extern unsigned int (*nf_nat_sdp_media_hook)(struct sk_buff *skb,
+					     unsigned int protoff,
 					     unsigned int dataoff,
 					     const char **dptr,
 					     unsigned int *datalen,
diff --git a/include/net/netfilter/nf_nat_helper.h b/include/net/netfilter/nf_nat_helper.h
index 7d8fb7b..b4d6bfc 100644
--- a/include/net/netfilter/nf_nat_helper.h
+++ b/include/net/netfilter/nf_nat_helper.h
@@ -10,6 +10,7 @@ struct sk_buff;
 extern int __nf_nat_mangle_tcp_packet(struct sk_buff *skb,
 				      struct nf_conn *ct,
 				      enum ip_conntrack_info ctinfo,
+				      unsigned int protoff,
 				      unsigned int match_offset,
 				      unsigned int match_len,
 				      const char *rep_buffer,
@@ -18,12 +19,13 @@ extern int __nf_nat_mangle_tcp_packet(struct sk_buff *skb,
 static inline int nf_nat_mangle_tcp_packet(struct sk_buff *skb,
 					   struct nf_conn *ct,
 					   enum ip_conntrack_info ctinfo,
+					   unsigned int protoff,
 					   unsigned int match_offset,
 					   unsigned int match_len,
 					   const char *rep_buffer,
 					   unsigned int rep_len)
 {
-	return __nf_nat_mangle_tcp_packet(skb, ct, ctinfo,
+	return __nf_nat_mangle_tcp_packet(skb, ct, ctinfo, protoff,
 					  match_offset, match_len,
 					  rep_buffer, rep_len, true);
 }
@@ -31,6 +33,7 @@ static inline int nf_nat_mangle_tcp_packet(struct sk_buff *skb,
 extern int nf_nat_mangle_udp_packet(struct sk_buff *skb,
 				    struct nf_conn *ct,
 				    enum ip_conntrack_info ctinfo,
+				    unsigned int protoff,
 				    unsigned int match_offset,
 				    unsigned int match_len,
 				    const char *rep_buffer,
@@ -41,10 +44,12 @@ extern void nf_nat_set_seq_adjust(struct nf_conn *ct,
 				  __be32 seq, s16 off);
 extern int nf_nat_seq_adjust(struct sk_buff *skb,
 			     struct nf_conn *ct,
-			     enum ip_conntrack_info ctinfo);
+			     enum ip_conntrack_info ctinfo,
+			     unsigned int protoff);
 extern int (*nf_nat_seq_adjust_hook)(struct sk_buff *skb,
 				     struct nf_conn *ct,
-				     enum ip_conntrack_info ctinfo);
+				     enum ip_conntrack_info ctinfo,
+				     unsigned int protoff);
 
 /* Setup NAT on this expected conntrack so it follows master, but goes
  * to port ct->master->saved_proto. */
diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
index e7ff2dc..4ada329 100644
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
@@ -31,7 +31,8 @@
 
 int (*nf_nat_seq_adjust_hook)(struct sk_buff *skb,
 			      struct nf_conn *ct,
-			      enum ip_conntrack_info ctinfo);
+			      enum ip_conntrack_info ctinfo,
+			      unsigned int protoff);
 EXPORT_SYMBOL_GPL(nf_nat_seq_adjust_hook);
 
 static bool ipv4_pkt_to_tuple(const struct sk_buff *skb, unsigned int nhoff,
@@ -149,7 +150,8 @@ static unsigned int ipv4_confirm(unsigned int hooknum,
 		typeof(nf_nat_seq_adjust_hook) seq_adjust;
 
 		seq_adjust = rcu_dereference(nf_nat_seq_adjust_hook);
-		if (!seq_adjust || !seq_adjust(skb, ct, ctinfo)) {
+		if (!seq_adjust ||
+		    !seq_adjust(skb, ct, ctinfo, ip_hdrlen(skb))) {
 			NF_CT_STAT_INC_ATOMIC(nf_ct_net(ct), drop);
 			return NF_DROP;
 		}
diff --git a/net/ipv4/netfilter/nf_nat_amanda.c b/net/ipv4/netfilter/nf_nat_amanda.c
index 3c04d24..75464b6 100644
--- a/net/ipv4/netfilter/nf_nat_amanda.c
+++ b/net/ipv4/netfilter/nf_nat_amanda.c
@@ -26,6 +26,7 @@ MODULE_ALIAS("ip_nat_amanda");
 
 static unsigned int help(struct sk_buff *skb,
 			 enum ip_conntrack_info ctinfo,
+			 unsigned int protoff,
 			 unsigned int matchoff,
 			 unsigned int matchlen,
 			 struct nf_conntrack_expect *exp)
@@ -61,7 +62,7 @@ static unsigned int help(struct sk_buff *skb,
 
 	sprintf(buffer, "%u", port);
 	ret = nf_nat_mangle_udp_packet(skb, exp->master, ctinfo,
-				       matchoff, matchlen,
+				       protoff, matchoff, matchlen,
 				       buffer, strlen(buffer));
 	if (ret != NF_ACCEPT)
 		nf_ct_unexpect_related(exp);
diff --git a/net/ipv4/netfilter/nf_nat_ftp.c b/net/ipv4/netfilter/nf_nat_ftp.c
index e462a95..5589f3a 100644
--- a/net/ipv4/netfilter/nf_nat_ftp.c
+++ b/net/ipv4/netfilter/nf_nat_ftp.c
@@ -55,6 +55,7 @@ static int nf_nat_ftp_fmt_cmd(enum nf_ct_ftp_type type,
 static unsigned int nf_nat_ftp(struct sk_buff *skb,
 			       enum ip_conntrack_info ctinfo,
 			       enum nf_ct_ftp_type type,
+			       unsigned int protoff,
 			       unsigned int matchoff,
 			       unsigned int matchlen,
 			       struct nf_conntrack_expect *exp)
@@ -100,7 +101,7 @@ static unsigned int nf_nat_ftp(struct sk_buff *skb,
 
 	pr_debug("calling nf_nat_mangle_tcp_packet\n");
 
-	if (!nf_nat_mangle_tcp_packet(skb, ct, ctinfo, matchoff,
+	if (!nf_nat_mangle_tcp_packet(skb, ct, ctinfo, protoff, matchoff,
 				      matchlen, buffer, buflen))
 		goto out;
 
diff --git a/net/ipv4/netfilter/nf_nat_h323.c b/net/ipv4/netfilter/nf_nat_h323.c
index c6784a1..d2c228d 100644
--- a/net/ipv4/netfilter/nf_nat_h323.c
+++ b/net/ipv4/netfilter/nf_nat_h323.c
@@ -21,7 +21,7 @@
 #include <linux/netfilter/nf_conntrack_h323.h>
 
 /****************************************************************************/
-static int set_addr(struct sk_buff *skb,
+static int set_addr(struct sk_buff *skb, unsigned int protoff,
 		    unsigned char **data, int dataoff,
 		    unsigned int addroff, __be32 ip, __be16 port)
 {
@@ -40,7 +40,7 @@ static int set_addr(struct sk_buff *skb,
 
 	if (ip_hdr(skb)->protocol == IPPROTO_TCP) {
 		if (!nf_nat_mangle_tcp_packet(skb, ct, ctinfo,
-					      addroff, sizeof(buf),
+					      protoff, addroff, sizeof(buf),
 					      (char *) &buf, sizeof(buf))) {
 			net_notice_ratelimited("nf_nat_h323: nf_nat_mangle_tcp_packet error\n");
 			return -1;
@@ -54,7 +54,7 @@ static int set_addr(struct sk_buff *skb,
 		*data = skb->data + ip_hdrlen(skb) + th->doff * 4 + dataoff;
 	} else {
 		if (!nf_nat_mangle_udp_packet(skb, ct, ctinfo,
-					      addroff, sizeof(buf),
+					      protoff, addroff, sizeof(buf),
 					      (char *) &buf, sizeof(buf))) {
 			net_notice_ratelimited("nf_nat_h323: nf_nat_mangle_udp_packet error\n");
 			return -1;
@@ -69,22 +69,22 @@ static int set_addr(struct sk_buff *skb,
 }
 
 /****************************************************************************/
-static int set_h225_addr(struct sk_buff *skb,
+static int set_h225_addr(struct sk_buff *skb, unsigned int protoff,
 			 unsigned char **data, int dataoff,
 			 TransportAddress *taddr,
 			 union nf_inet_addr *addr, __be16 port)
 {
-	return set_addr(skb, data, dataoff, taddr->ipAddress.ip,
+	return set_addr(skb, protoff, data, dataoff, taddr->ipAddress.ip,
 			addr->ip, port);
 }
 
 /****************************************************************************/
-static int set_h245_addr(struct sk_buff *skb,
+static int set_h245_addr(struct sk_buff *skb, unsigned protoff,
 			 unsigned char **data, int dataoff,
 			 H245_TransportAddress *taddr,
 			 union nf_inet_addr *addr, __be16 port)
 {
-	return set_addr(skb, data, dataoff,
+	return set_addr(skb, protoff, data, dataoff,
 			taddr->unicastAddress.iPAddress.network,
 			addr->ip, port);
 }
@@ -92,7 +92,7 @@ static int set_h245_addr(struct sk_buff *skb,
 /****************************************************************************/
 static int set_sig_addr(struct sk_buff *skb, struct nf_conn *ct,
 			enum ip_conntrack_info ctinfo,
-			unsigned char **data,
+			unsigned int protoff, unsigned char **data,
 			TransportAddress *taddr, int count)
 {
 	const struct nf_ct_h323_master *info = nfct_help_data(ct);
@@ -118,7 +118,8 @@ static int set_sig_addr(struct sk_buff *skb, struct nf_conn *ct,
 					 &addr.ip, port,
 					 &ct->tuplehash[!dir].tuple.dst.u3.ip,
 					 info->sig_port[!dir]);
-				return set_h225_addr(skb, data, 0, &taddr[i],
+				return set_h225_addr(skb, protoff, data, 0,
+						     &taddr[i],
 						     &ct->tuplehash[!dir].
 						     tuple.dst.u3,
 						     info->sig_port[!dir]);
@@ -129,7 +130,8 @@ static int set_sig_addr(struct sk_buff *skb, struct nf_conn *ct,
 					 &addr.ip, port,
 					 &ct->tuplehash[!dir].tuple.src.u3.ip,
 					 info->sig_port[!dir]);
-				return set_h225_addr(skb, data, 0, &taddr[i],
+				return set_h225_addr(skb, protoff, data, 0,
+						     &taddr[i],
 						     &ct->tuplehash[!dir].
 						     tuple.src.u3,
 						     info->sig_port[!dir]);
@@ -143,7 +145,7 @@ static int set_sig_addr(struct sk_buff *skb, struct nf_conn *ct,
 /****************************************************************************/
 static int set_ras_addr(struct sk_buff *skb, struct nf_conn *ct,
 			enum ip_conntrack_info ctinfo,
-			unsigned char **data,
+			unsigned int protoff, unsigned char **data,
 			TransportAddress *taddr, int count)
 {
 	int dir = CTINFO2DIR(ctinfo);
@@ -159,7 +161,7 @@ static int set_ras_addr(struct sk_buff *skb, struct nf_conn *ct,
 				 &addr.ip, ntohs(port),
 				 &ct->tuplehash[!dir].tuple.dst.u3.ip,
 				 ntohs(ct->tuplehash[!dir].tuple.dst.u.udp.port));
-			return set_h225_addr(skb, data, 0, &taddr[i],
+			return set_h225_addr(skb, protoff, data, 0, &taddr[i],
 					     &ct->tuplehash[!dir].tuple.dst.u3,
 					     ct->tuplehash[!dir].tuple.
 								dst.u.udp.port);
@@ -172,7 +174,7 @@ static int set_ras_addr(struct sk_buff *skb, struct nf_conn *ct,
 /****************************************************************************/
 static int nat_rtp_rtcp(struct sk_buff *skb, struct nf_conn *ct,
 			enum ip_conntrack_info ctinfo,
-			unsigned char **data, int dataoff,
+			unsigned int protoff, unsigned char **data, int dataoff,
 			H245_TransportAddress *taddr,
 			__be16 port, __be16 rtp_port,
 			struct nf_conntrack_expect *rtp_exp,
@@ -244,7 +246,7 @@ static int nat_rtp_rtcp(struct sk_buff *skb, struct nf_conn *ct,
 	}
 
 	/* Modify signal */
-	if (set_h245_addr(skb, data, dataoff, taddr,
+	if (set_h245_addr(skb, protoff, data, dataoff, taddr,
 			  &ct->tuplehash[!dir].tuple.dst.u3,
 			  htons((port & htons(1)) ? nated_port + 1 :
 						    nated_port)) == 0) {
@@ -275,7 +277,7 @@ static int nat_rtp_rtcp(struct sk_buff *skb, struct nf_conn *ct,
 /****************************************************************************/
 static int nat_t120(struct sk_buff *skb, struct nf_conn *ct,
 		    enum ip_conntrack_info ctinfo,
-		    unsigned char **data, int dataoff,
+		    unsigned int protoff, unsigned char **data, int dataoff,
 		    H245_TransportAddress *taddr, __be16 port,
 		    struct nf_conntrack_expect *exp)
 {
@@ -307,7 +309,7 @@ static int nat_t120(struct sk_buff *skb, struct nf_conn *ct,
 	}
 
 	/* Modify signal */
-	if (set_h245_addr(skb, data, dataoff, taddr,
+	if (set_h245_addr(skb, protoff, data, dataoff, taddr,
 			  &ct->tuplehash[!dir].tuple.dst.u3,
 			  htons(nated_port)) < 0) {
 		nf_ct_unexpect_related(exp);
@@ -326,7 +328,7 @@ static int nat_t120(struct sk_buff *skb, struct nf_conn *ct,
 /****************************************************************************/
 static int nat_h245(struct sk_buff *skb, struct nf_conn *ct,
 		    enum ip_conntrack_info ctinfo,
-		    unsigned char **data, int dataoff,
+		    unsigned int protoff, unsigned char **data, int dataoff,
 		    TransportAddress *taddr, __be16 port,
 		    struct nf_conntrack_expect *exp)
 {
@@ -363,7 +365,7 @@ static int nat_h245(struct sk_buff *skb, struct nf_conn *ct,
 	}
 
 	/* Modify signal */
-	if (set_h225_addr(skb, data, dataoff, taddr,
+	if (set_h225_addr(skb, protoff, data, dataoff, taddr,
 			  &ct->tuplehash[!dir].tuple.dst.u3,
 			  htons(nated_port)) == 0) {
 		/* Save ports */
@@ -416,7 +418,8 @@ static void ip_nat_q931_expect(struct nf_conn *new,
 /****************************************************************************/
 static int nat_q931(struct sk_buff *skb, struct nf_conn *ct,
 		    enum ip_conntrack_info ctinfo,
-		    unsigned char **data, TransportAddress *taddr, int idx,
+		    unsigned int protoff, unsigned char **data,
+		    TransportAddress *taddr, int idx,
 		    __be16 port, struct nf_conntrack_expect *exp)
 {
 	struct nf_ct_h323_master *info = nfct_help_data(ct);
@@ -453,7 +456,7 @@ static int nat_q931(struct sk_buff *skb, struct nf_conn *ct,
 	}
 
 	/* Modify signal */
-	if (set_h225_addr(skb, data, 0, &taddr[idx],
+	if (set_h225_addr(skb, protoff, data, 0, &taddr[idx],
 			  &ct->tuplehash[!dir].tuple.dst.u3,
 			  htons(nated_port)) == 0) {
 		/* Save ports */
@@ -464,7 +467,7 @@ static int nat_q931(struct sk_buff *skb, struct nf_conn *ct,
 		if (idx > 0 &&
 		    get_h225_addr(ct, *data, &taddr[0], &addr, &port) &&
 		    (ntohl(addr.ip) & 0xff000000) == 0x7f000000) {
-			set_h225_addr(skb, data, 0, &taddr[0],
+			set_h225_addr(skb, protoff, data, 0, &taddr[0],
 				      &ct->tuplehash[!dir].tuple.dst.u3,
 				      info->sig_port[!dir]);
 		}
@@ -507,6 +510,7 @@ static void ip_nat_callforwarding_expect(struct nf_conn *new,
 /****************************************************************************/
 static int nat_callforwarding(struct sk_buff *skb, struct nf_conn *ct,
 			      enum ip_conntrack_info ctinfo,
+			      unsigned int protoff,
 			      unsigned char **data, int dataoff,
 			      TransportAddress *taddr, __be16 port,
 			      struct nf_conntrack_expect *exp)
@@ -541,7 +545,7 @@ static int nat_callforwarding(struct sk_buff *skb, struct nf_conn *ct,
 	}
 
 	/* Modify signal */
-	if (!set_h225_addr(skb, data, dataoff, taddr,
+	if (!set_h225_addr(skb, protoff, data, dataoff, taddr,
 			   &ct->tuplehash[!dir].tuple.dst.u3,
 			   htons(nated_port)) == 0) {
 		nf_ct_unexpect_related(exp);
diff --git a/net/ipv4/netfilter/nf_nat_helper.c b/net/ipv4/netfilter/nf_nat_helper.c
index 2e59ad0..2fefec5 100644
--- a/net/ipv4/netfilter/nf_nat_helper.c
+++ b/net/ipv4/netfilter/nf_nat_helper.c
@@ -206,6 +206,7 @@ static void nf_nat_csum(struct sk_buff *skb, const struct iphdr *iph, void *data
 int __nf_nat_mangle_tcp_packet(struct sk_buff *skb,
 			       struct nf_conn *ct,
 			       enum ip_conntrack_info ctinfo,
+			       unsigned int protoff,
 			       unsigned int match_offset,
 			       unsigned int match_len,
 			       const char *rep_buffer,
@@ -257,6 +258,7 @@ int
 nf_nat_mangle_udp_packet(struct sk_buff *skb,
 			 struct nf_conn *ct,
 			 enum ip_conntrack_info ctinfo,
+			 unsigned int protoff,
 			 unsigned int match_offset,
 			 unsigned int match_len,
 			 const char *rep_buffer,
@@ -387,7 +389,8 @@ nf_nat_sack_adjust(struct sk_buff *skb,
 int
 nf_nat_seq_adjust(struct sk_buff *skb,
 		  struct nf_conn *ct,
-		  enum ip_conntrack_info ctinfo)
+		  enum ip_conntrack_info ctinfo,
+		  unsigned int protoff)
 {
 	struct tcphdr *tcph;
 	int dir;
@@ -401,10 +404,10 @@ nf_nat_seq_adjust(struct sk_buff *skb,
 	this_way = &nat->seq[dir];
 	other_way = &nat->seq[!dir];
 
-	if (!skb_make_writable(skb, ip_hdrlen(skb) + sizeof(*tcph)))
+	if (!skb_make_writable(skb, protoff + sizeof(*tcph)))
 		return 0;
 
-	tcph = (void *)skb->data + ip_hdrlen(skb);
+	tcph = (void *)skb->data + protoff;
 	if (after(ntohl(tcph->seq), this_way->correction_pos))
 		seqoff = this_way->offset_after;
 	else
diff --git a/net/ipv4/netfilter/nf_nat_irc.c b/net/ipv4/netfilter/nf_nat_irc.c
index 979ae16..5b0c20a 100644
--- a/net/ipv4/netfilter/nf_nat_irc.c
+++ b/net/ipv4/netfilter/nf_nat_irc.c
@@ -29,6 +29,7 @@ MODULE_ALIAS("ip_nat_irc");
 
 static unsigned int help(struct sk_buff *skb,
 			 enum ip_conntrack_info ctinfo,
+			 unsigned int protoff,
 			 unsigned int matchoff,
 			 unsigned int matchlen,
 			 struct nf_conntrack_expect *exp)
@@ -66,7 +67,7 @@ static unsigned int help(struct sk_buff *skb,
 		 buffer, &ip, port);
 
 	ret = nf_nat_mangle_tcp_packet(skb, exp->master, ctinfo,
-				       matchoff, matchlen, buffer,
+				       protoff, matchoff, matchlen, buffer,
 				       strlen(buffer));
 	if (ret != NF_ACCEPT)
 		nf_ct_unexpect_related(exp);
diff --git a/net/ipv4/netfilter/nf_nat_pptp.c b/net/ipv4/netfilter/nf_nat_pptp.c
index 3881408..31ef890 100644
--- a/net/ipv4/netfilter/nf_nat_pptp.c
+++ b/net/ipv4/netfilter/nf_nat_pptp.c
@@ -113,6 +113,7 @@ static int
 pptp_outbound_pkt(struct sk_buff *skb,
 		  struct nf_conn *ct,
 		  enum ip_conntrack_info ctinfo,
+		  unsigned int protoff,
 		  struct PptpControlHeader *ctlh,
 		  union pptp_ctrl_union *pptpReq)
 
@@ -175,7 +176,7 @@ pptp_outbound_pkt(struct sk_buff *skb,
 		 ntohs(REQ_CID(pptpReq, cid_off)), ntohs(new_callid));
 
 	/* mangle packet */
-	if (nf_nat_mangle_tcp_packet(skb, ct, ctinfo,
+	if (nf_nat_mangle_tcp_packet(skb, ct, ctinfo, protoff,
 				     cid_off + sizeof(struct pptp_pkt_hdr) +
 				     sizeof(struct PptpControlHeader),
 				     sizeof(new_callid), (char *)&new_callid,
@@ -216,6 +217,7 @@ static int
 pptp_inbound_pkt(struct sk_buff *skb,
 		 struct nf_conn *ct,
 		 enum ip_conntrack_info ctinfo,
+		 unsigned int protoff,
 		 struct PptpControlHeader *ctlh,
 		 union pptp_ctrl_union *pptpReq)
 {
@@ -268,7 +270,7 @@ pptp_inbound_pkt(struct sk_buff *skb,
 	pr_debug("altering peer call id from 0x%04x to 0x%04x\n",
 		 ntohs(REQ_CID(pptpReq, pcid_off)), ntohs(new_pcid));
 
-	if (nf_nat_mangle_tcp_packet(skb, ct, ctinfo,
+	if (nf_nat_mangle_tcp_packet(skb, ct, ctinfo, protoff,
 				     pcid_off + sizeof(struct pptp_pkt_hdr) +
 				     sizeof(struct PptpControlHeader),
 				     sizeof(new_pcid), (char *)&new_pcid,
diff --git a/net/ipv4/netfilter/nf_nat_sip.c b/net/ipv4/netfilter/nf_nat_sip.c
index 4ad9cf1..df626af 100644
--- a/net/ipv4/netfilter/nf_nat_sip.c
+++ b/net/ipv4/netfilter/nf_nat_sip.c
@@ -30,7 +30,8 @@ MODULE_DESCRIPTION("SIP NAT helper");
 MODULE_ALIAS("ip_nat_sip");
 
 
-static unsigned int mangle_packet(struct sk_buff *skb, unsigned int dataoff,
+static unsigned int mangle_packet(struct sk_buff *skb, unsigned int protoff,
+				  unsigned int dataoff,
 				  const char **dptr, unsigned int *datalen,
 				  unsigned int matchoff, unsigned int matchlen,
 				  const char *buffer, unsigned int buflen)
@@ -46,7 +47,7 @@ static unsigned int mangle_packet(struct sk_buff *skb, unsigned int dataoff,
 		matchoff += dataoff - baseoff;
 
 		if (!__nf_nat_mangle_tcp_packet(skb, ct, ctinfo,
-						matchoff, matchlen,
+						protoff, matchoff, matchlen,
 						buffer, buflen, false))
 			return 0;
 	} else {
@@ -54,7 +55,7 @@ static unsigned int mangle_packet(struct sk_buff *skb, unsigned int dataoff,
 		matchoff += dataoff - baseoff;
 
 		if (!nf_nat_mangle_udp_packet(skb, ct, ctinfo,
-					      matchoff, matchlen,
+					      protoff, matchoff, matchlen,
 					      buffer, buflen))
 			return 0;
 	}
@@ -65,7 +66,8 @@ static unsigned int mangle_packet(struct sk_buff *skb, unsigned int dataoff,
 	return 1;
 }
 
-static int map_addr(struct sk_buff *skb, unsigned int dataoff,
+static int map_addr(struct sk_buff *skb, unsigned int protoff,
+		    unsigned int dataoff,
 		    const char **dptr, unsigned int *datalen,
 		    unsigned int matchoff, unsigned int matchlen,
 		    union nf_inet_addr *addr, __be16 port)
@@ -94,11 +96,12 @@ static int map_addr(struct sk_buff *skb, unsigned int dataoff,
 
 	buflen = sprintf(buffer, "%pI4:%u", &newaddr, ntohs(newport));
 
-	return mangle_packet(skb, dataoff, dptr, datalen, matchoff, matchlen,
-			     buffer, buflen);
+	return mangle_packet(skb, protoff, dataoff, dptr, datalen,
+			     matchoff, matchlen, buffer, buflen);
 }
 
-static int map_sip_addr(struct sk_buff *skb, unsigned int dataoff,
+static int map_sip_addr(struct sk_buff *skb, unsigned int protoff,
+			unsigned int dataoff,
 			const char **dptr, unsigned int *datalen,
 			enum sip_header_types type)
 {
@@ -111,11 +114,12 @@ static int map_sip_addr(struct sk_buff *skb, unsigned int dataoff,
 	if (ct_sip_parse_header_uri(ct, *dptr, NULL, *datalen, type, NULL,
 				    &matchoff, &matchlen, &addr, &port) <= 0)
 		return 1;
-	return map_addr(skb, dataoff, dptr, datalen, matchoff, matchlen,
-			&addr, port);
+	return map_addr(skb, protoff, dataoff, dptr, datalen,
+			matchoff, matchlen, &addr, port);
 }
 
-static unsigned int ip_nat_sip(struct sk_buff *skb, unsigned int dataoff,
+static unsigned int ip_nat_sip(struct sk_buff *skb, unsigned int protoff,
+			       unsigned int dataoff,
 			       const char **dptr, unsigned int *datalen)
 {
 	enum ip_conntrack_info ctinfo;
@@ -132,8 +136,8 @@ static unsigned int ip_nat_sip(struct sk_buff *skb, unsigned int dataoff,
 		if (ct_sip_parse_request(ct, *dptr, *datalen,
 					 &matchoff, &matchlen,
 					 &addr, &port) > 0 &&
-		    !map_addr(skb, dataoff, dptr, datalen, matchoff, matchlen,
-			      &addr, port))
+		    !map_addr(skb, protoff, dataoff, dptr, datalen,
+			      matchoff, matchlen, &addr, port))
 			return NF_DROP;
 		request = 1;
 	} else
@@ -164,8 +168,8 @@ static unsigned int ip_nat_sip(struct sk_buff *skb, unsigned int dataoff,
 		}
 
 		olen = *datalen;
-		if (!map_addr(skb, dataoff, dptr, datalen, matchoff, matchlen,
-			      &addr, port))
+		if (!map_addr(skb, protoff, dataoff, dptr, datalen,
+			      matchoff, matchlen, &addr, port))
 			return NF_DROP;
 
 		matchend = matchoff + matchlen + *datalen - olen;
@@ -179,7 +183,7 @@ static unsigned int ip_nat_sip(struct sk_buff *skb, unsigned int dataoff,
 		    addr.ip != ct->tuplehash[!dir].tuple.dst.u3.ip) {
 			buflen = sprintf(buffer, "%pI4",
 					&ct->tuplehash[!dir].tuple.dst.u3.ip);
-			if (!mangle_packet(skb, dataoff, dptr, datalen,
+			if (!mangle_packet(skb, protoff, dataoff, dptr, datalen,
 					   poff, plen, buffer, buflen))
 				return NF_DROP;
 		}
@@ -193,7 +197,7 @@ static unsigned int ip_nat_sip(struct sk_buff *skb, unsigned int dataoff,
 		    addr.ip != ct->tuplehash[!dir].tuple.src.u3.ip) {
 			buflen = sprintf(buffer, "%pI4",
 					&ct->tuplehash[!dir].tuple.src.u3.ip);
-			if (!mangle_packet(skb, dataoff, dptr, datalen,
+			if (!mangle_packet(skb, protoff, dataoff, dptr, datalen,
 					   poff, plen, buffer, buflen))
 				return NF_DROP;
 		}
@@ -207,7 +211,7 @@ static unsigned int ip_nat_sip(struct sk_buff *skb, unsigned int dataoff,
 		    htons(n) != ct->tuplehash[!dir].tuple.src.u.udp.port) {
 			__be16 p = ct->tuplehash[!dir].tuple.src.u.udp.port;
 			buflen = sprintf(buffer, "%u", ntohs(p));
-			if (!mangle_packet(skb, dataoff, dptr, datalen,
+			if (!mangle_packet(skb, protoff, dataoff, dptr, datalen,
 					   poff, plen, buffer, buflen))
 				return NF_DROP;
 		}
@@ -221,13 +225,14 @@ next:
 				       SIP_HDR_CONTACT, &in_header,
 				       &matchoff, &matchlen,
 				       &addr, &port) > 0) {
-		if (!map_addr(skb, dataoff, dptr, datalen, matchoff, matchlen,
+		if (!map_addr(skb, protoff, dataoff, dptr, datalen,
+			      matchoff, matchlen,
 			      &addr, port))
 			return NF_DROP;
 	}
 
-	if (!map_sip_addr(skb, dataoff, dptr, datalen, SIP_HDR_FROM) ||
-	    !map_sip_addr(skb, dataoff, dptr, datalen, SIP_HDR_TO))
+	if (!map_sip_addr(skb, protoff, dataoff, dptr, datalen, SIP_HDR_FROM) ||
+	    !map_sip_addr(skb, protoff, dataoff, dptr, datalen, SIP_HDR_TO))
 		return NF_DROP;
 
 	return NF_ACCEPT;
@@ -272,7 +277,8 @@ static void ip_nat_sip_expected(struct nf_conn *ct,
 	}
 }
 
-static unsigned int ip_nat_sip_expect(struct sk_buff *skb, unsigned int dataoff,
+static unsigned int ip_nat_sip_expect(struct sk_buff *skb, unsigned int protoff,
+				      unsigned int dataoff,
 				      const char **dptr, unsigned int *datalen,
 				      struct nf_conntrack_expect *exp,
 				      unsigned int matchoff,
@@ -326,7 +332,7 @@ static unsigned int ip_nat_sip_expect(struct sk_buff *skb, unsigned int dataoff,
 	if (exp->tuple.dst.u3.ip != exp->saved_ip ||
 	    exp->tuple.dst.u.udp.port != exp->saved_proto.udp.port) {
 		buflen = sprintf(buffer, "%pI4:%u", &newip, port);
-		if (!mangle_packet(skb, dataoff, dptr, datalen,
+		if (!mangle_packet(skb, protoff, dataoff, dptr, datalen,
 				   matchoff, matchlen, buffer, buflen))
 			goto err;
 	}
@@ -337,7 +343,8 @@ err:
 	return NF_DROP;
 }
 
-static int mangle_content_len(struct sk_buff *skb, unsigned int dataoff,
+static int mangle_content_len(struct sk_buff *skb, unsigned int protoff,
+			      unsigned int dataoff,
 			      const char **dptr, unsigned int *datalen)
 {
 	enum ip_conntrack_info ctinfo;
@@ -359,11 +366,12 @@ static int mangle_content_len(struct sk_buff *skb, unsigned int dataoff,
 		return 0;
 
 	buflen = sprintf(buffer, "%u", c_len);
-	return mangle_packet(skb, dataoff, dptr, datalen, matchoff, matchlen,
-			     buffer, buflen);
+	return mangle_packet(skb, protoff, dataoff, dptr, datalen,
+			     matchoff, matchlen, buffer, buflen);
 }
 
-static int mangle_sdp_packet(struct sk_buff *skb, unsigned int dataoff,
+static int mangle_sdp_packet(struct sk_buff *skb, unsigned int protoff,
+			     unsigned int dataoff,
 			     const char **dptr, unsigned int *datalen,
 			     unsigned int sdpoff,
 			     enum sdp_header_types type,
@@ -377,11 +385,12 @@ static int mangle_sdp_packet(struct sk_buff *skb, unsigned int dataoff,
 	if (ct_sip_get_sdp_header(ct, *dptr, sdpoff, *datalen, type, term,
 				  &matchoff, &matchlen) <= 0)
 		return -ENOENT;
-	return mangle_packet(skb, dataoff, dptr, datalen, matchoff, matchlen,
-			     buffer, buflen) ? 0 : -EINVAL;
+	return mangle_packet(skb, protoff, dataoff, dptr, datalen,
+			     matchoff, matchlen, buffer, buflen) ? 0 : -EINVAL;
 }
 
-static unsigned int ip_nat_sdp_addr(struct sk_buff *skb, unsigned int dataoff,
+static unsigned int ip_nat_sdp_addr(struct sk_buff *skb, unsigned int protoff,
+				    unsigned int dataoff,
 				    const char **dptr, unsigned int *datalen,
 				    unsigned int sdpoff,
 				    enum sdp_header_types type,
@@ -392,14 +401,15 @@ static unsigned int ip_nat_sdp_addr(struct sk_buff *skb, unsigned int dataoff,
 	unsigned int buflen;
 
 	buflen = sprintf(buffer, "%pI4", &addr->ip);
-	if (mangle_sdp_packet(skb, dataoff, dptr, datalen, sdpoff, type, term,
-			      buffer, buflen))
+	if (mangle_sdp_packet(skb, protoff, dataoff, dptr, datalen,
+			      sdpoff, type, term, buffer, buflen))
 		return 0;
 
-	return mangle_content_len(skb, dataoff, dptr, datalen);
+	return mangle_content_len(skb, protoff, dataoff, dptr, datalen);
 }
 
-static unsigned int ip_nat_sdp_port(struct sk_buff *skb, unsigned int dataoff,
+static unsigned int ip_nat_sdp_port(struct sk_buff *skb, unsigned int protoff,
+				    unsigned int dataoff,
 				    const char **dptr, unsigned int *datalen,
 				    unsigned int matchoff,
 				    unsigned int matchlen,
@@ -409,14 +419,15 @@ static unsigned int ip_nat_sdp_port(struct sk_buff *skb, unsigned int dataoff,
 	unsigned int buflen;
 
 	buflen = sprintf(buffer, "%u", port);
-	if (!mangle_packet(skb, dataoff, dptr, datalen, matchoff, matchlen,
-			   buffer, buflen))
+	if (!mangle_packet(skb, protoff, dataoff, dptr, datalen,
+			   matchoff, matchlen, buffer, buflen))
 		return 0;
 
-	return mangle_content_len(skb, dataoff, dptr, datalen);
+	return mangle_content_len(skb, protoff, dataoff, dptr, datalen);
 }
 
-static unsigned int ip_nat_sdp_session(struct sk_buff *skb, unsigned int dataoff,
+static unsigned int ip_nat_sdp_session(struct sk_buff *skb, unsigned int protoff,
+				       unsigned int dataoff,
 				       const char **dptr, unsigned int *datalen,
 				       unsigned int sdpoff,
 				       const union nf_inet_addr *addr)
@@ -426,12 +437,12 @@ static unsigned int ip_nat_sdp_session(struct sk_buff *skb, unsigned int dataoff
 
 	/* Mangle session description owner and contact addresses */
 	buflen = sprintf(buffer, "%pI4", &addr->ip);
-	if (mangle_sdp_packet(skb, dataoff, dptr, datalen, sdpoff,
+	if (mangle_sdp_packet(skb, protoff, dataoff, dptr, datalen, sdpoff,
 			       SDP_HDR_OWNER_IP4, SDP_HDR_MEDIA,
 			       buffer, buflen))
 		return 0;
 
-	switch (mangle_sdp_packet(skb, dataoff, dptr, datalen, sdpoff,
+	switch (mangle_sdp_packet(skb, protoff, dataoff, dptr, datalen, sdpoff,
 				  SDP_HDR_CONNECTION_IP4, SDP_HDR_MEDIA,
 				  buffer, buflen)) {
 	case 0:
@@ -448,12 +459,13 @@ static unsigned int ip_nat_sdp_session(struct sk_buff *skb, unsigned int dataoff
 		return 0;
 	}
 
-	return mangle_content_len(skb, dataoff, dptr, datalen);
+	return mangle_content_len(skb, protoff, dataoff, dptr, datalen);
 }
 
 /* So, this packet has hit the connection tracking matching code.
    Mangle it, and change the expectation to match the new version. */
-static unsigned int ip_nat_sdp_media(struct sk_buff *skb, unsigned int dataoff,
+static unsigned int ip_nat_sdp_media(struct sk_buff *skb, unsigned int protoff,
+				     unsigned int dataoff,
 				     const char **dptr, unsigned int *datalen,
 				     struct nf_conntrack_expect *rtp_exp,
 				     struct nf_conntrack_expect *rtcp_exp,
@@ -514,7 +526,7 @@ static unsigned int ip_nat_sdp_media(struct sk_buff *skb, unsigned int dataoff,
 
 	/* Update media port. */
 	if (rtp_exp->tuple.dst.u.udp.port != rtp_exp->saved_proto.udp.port &&
-	    !ip_nat_sdp_port(skb, dataoff, dptr, datalen,
+	    !ip_nat_sdp_port(skb, protoff, dataoff, dptr, datalen,
 			     mediaoff, medialen, port))
 		goto err2;
 
diff --git a/net/netfilter/ipvs/ip_vs_ftp.c b/net/netfilter/ipvs/ip_vs_ftp.c
index b20b29c..390c195 100644
--- a/net/netfilter/ipvs/ip_vs_ftp.c
+++ b/net/netfilter/ipvs/ip_vs_ftp.c
@@ -268,6 +268,7 @@ static int ip_vs_ftp_out(struct ip_vs_app *app, struct ip_vs_conn *cp,
 			 * packet.
 			 */
 			ret = nf_nat_mangle_tcp_packet(skb, ct, ctinfo,
+						       iph->ihl * 4,
 						       start-data, end-start,
 						       buf, buf_len);
 			if (ret) {
diff --git a/net/netfilter/nf_conntrack_amanda.c b/net/netfilter/nf_conntrack_amanda.c
index 184c0dc..e0212b5 100644
--- a/net/netfilter/nf_conntrack_amanda.c
+++ b/net/netfilter/nf_conntrack_amanda.c
@@ -40,6 +40,7 @@ MODULE_PARM_DESC(ts_algo, "textsearch algorithm to use (default kmp)");
 
 unsigned int (*nf_nat_amanda_hook)(struct sk_buff *skb,
 				   enum ip_conntrack_info ctinfo,
+				   unsigned int protoff,
 				   unsigned int matchoff,
 				   unsigned int matchlen,
 				   struct nf_conntrack_expect *exp)
@@ -156,8 +157,8 @@ static int amanda_help(struct sk_buff *skb,
 		nf_nat_amanda = rcu_dereference(nf_nat_amanda_hook);
 		if (nf_nat_amanda && nf_ct_l3num(ct) == NFPROTO_IPV4 &&
 		    ct->status & IPS_NAT_MASK)
-			ret = nf_nat_amanda(skb, ctinfo, off - dataoff,
-					    len, exp);
+			ret = nf_nat_amanda(skb, ctinfo, protoff,
+					    off - dataoff, len, exp);
 		else if (nf_ct_expect_related(exp) != 0)
 			ret = NF_DROP;
 		nf_ct_expect_put(exp);
diff --git a/net/netfilter/nf_conntrack_ftp.c b/net/netfilter/nf_conntrack_ftp.c
index 3e1587e..c0f4a5b 100644
--- a/net/netfilter/nf_conntrack_ftp.c
+++ b/net/netfilter/nf_conntrack_ftp.c
@@ -48,6 +48,7 @@ module_param(loose, bool, 0600);
 unsigned int (*nf_nat_ftp_hook)(struct sk_buff *skb,
 				enum ip_conntrack_info ctinfo,
 				enum nf_ct_ftp_type type,
+				unsigned int protoff,
 				unsigned int matchoff,
 				unsigned int matchlen,
 				struct nf_conntrack_expect *exp);
@@ -490,7 +491,7 @@ static int help(struct sk_buff *skb,
 	if (nf_nat_ftp && nf_ct_l3num(ct) == NFPROTO_IPV4 &&
 	    ct->status & IPS_NAT_MASK)
 		ret = nf_nat_ftp(skb, ctinfo, search[dir][i].ftptype,
-				 matchoff, matchlen, exp);
+				 protoff, matchoff, matchlen, exp);
 	else {
 		/* Can't expect this?  Best to drop packet now. */
 		if (nf_ct_expect_related(exp) != 0)
diff --git a/net/netfilter/nf_conntrack_h323_main.c b/net/netfilter/nf_conntrack_h323_main.c
index 517c5e3..1b30b0d 100644
--- a/net/netfilter/nf_conntrack_h323_main.c
+++ b/net/netfilter/nf_conntrack_h323_main.c
@@ -49,12 +49,12 @@ MODULE_PARM_DESC(callforward_filter, "only create call forwarding expectations "
 				     "(determined by routing information)");
 
 /* Hooks for NAT */
-int (*set_h245_addr_hook) (struct sk_buff *skb,
+int (*set_h245_addr_hook) (struct sk_buff *skb, unsigned int protoff,
 			   unsigned char **data, int dataoff,
 			   H245_TransportAddress *taddr,
 			   union nf_inet_addr *addr, __be16 port)
 			   __read_mostly;
-int (*set_h225_addr_hook) (struct sk_buff *skb,
+int (*set_h225_addr_hook) (struct sk_buff *skb, unsigned int protoff,
 			   unsigned char **data, int dataoff,
 			   TransportAddress *taddr,
 			   union nf_inet_addr *addr, __be16 port)
@@ -62,16 +62,17 @@ int (*set_h225_addr_hook) (struct sk_buff *skb,
 int (*set_sig_addr_hook) (struct sk_buff *skb,
 			  struct nf_conn *ct,
 			  enum ip_conntrack_info ctinfo,
-			  unsigned char **data,
+			  unsigned int protoff, unsigned char **data,
 			  TransportAddress *taddr, int count) __read_mostly;
 int (*set_ras_addr_hook) (struct sk_buff *skb,
 			  struct nf_conn *ct,
 			  enum ip_conntrack_info ctinfo,
-			  unsigned char **data,
+			  unsigned int protoff, unsigned char **data,
 			  TransportAddress *taddr, int count) __read_mostly;
 int (*nat_rtp_rtcp_hook) (struct sk_buff *skb,
 			  struct nf_conn *ct,
 			  enum ip_conntrack_info ctinfo,
+			  unsigned int protoff,
 			  unsigned char **data, int dataoff,
 			  H245_TransportAddress *taddr,
 			  __be16 port, __be16 rtp_port,
@@ -80,24 +81,28 @@ int (*nat_rtp_rtcp_hook) (struct sk_buff *skb,
 int (*nat_t120_hook) (struct sk_buff *skb,
 		      struct nf_conn *ct,
 		      enum ip_conntrack_info ctinfo,
+		      unsigned int protoff,
 		      unsigned char **data, int dataoff,
 		      H245_TransportAddress *taddr, __be16 port,
 		      struct nf_conntrack_expect *exp) __read_mostly;
 int (*nat_h245_hook) (struct sk_buff *skb,
 		      struct nf_conn *ct,
 		      enum ip_conntrack_info ctinfo,
+		      unsigned int protoff,
 		      unsigned char **data, int dataoff,
 		      TransportAddress *taddr, __be16 port,
 		      struct nf_conntrack_expect *exp) __read_mostly;
 int (*nat_callforwarding_hook) (struct sk_buff *skb,
 				struct nf_conn *ct,
 				enum ip_conntrack_info ctinfo,
+				unsigned int protoff,
 				unsigned char **data, int dataoff,
 				TransportAddress *taddr, __be16 port,
 				struct nf_conntrack_expect *exp) __read_mostly;
 int (*nat_q931_hook) (struct sk_buff *skb,
 		      struct nf_conn *ct,
 		      enum ip_conntrack_info ctinfo,
+		      unsigned int protoff,
 		      unsigned char **data, TransportAddress *taddr, int idx,
 		      __be16 port, struct nf_conntrack_expect *exp)
 		      __read_mostly;
@@ -251,6 +256,7 @@ static int get_h245_addr(struct nf_conn *ct, const unsigned char *data,
 /****************************************************************************/
 static int expect_rtp_rtcp(struct sk_buff *skb, struct nf_conn *ct,
 			   enum ip_conntrack_info ctinfo,
+			   unsigned int protoff,
 			   unsigned char **data, int dataoff,
 			   H245_TransportAddress *taddr)
 {
@@ -298,7 +304,7 @@ static int expect_rtp_rtcp(struct sk_buff *skb, struct nf_conn *ct,
 		   nf_ct_l3num(ct) == NFPROTO_IPV4 &&
 		   ct->status & IPS_NAT_MASK) {
 		/* NAT needed */
-		ret = nat_rtp_rtcp(skb, ct, ctinfo, data, dataoff,
+		ret = nat_rtp_rtcp(skb, ct, ctinfo, protoff, data, dataoff,
 				   taddr, port, rtp_port, rtp_exp, rtcp_exp);
 	} else {		/* Conntrack only */
 		if (nf_ct_expect_related(rtp_exp) == 0) {
@@ -325,6 +331,7 @@ static int expect_rtp_rtcp(struct sk_buff *skb, struct nf_conn *ct,
 static int expect_t120(struct sk_buff *skb,
 		       struct nf_conn *ct,
 		       enum ip_conntrack_info ctinfo,
+		       unsigned int protoff,
 		       unsigned char **data, int dataoff,
 		       H245_TransportAddress *taddr)
 {
@@ -357,7 +364,7 @@ static int expect_t120(struct sk_buff *skb,
 	    nf_ct_l3num(ct) == NFPROTO_IPV4 &&
 	    ct->status & IPS_NAT_MASK) {
 		/* NAT needed */
-		ret = nat_t120(skb, ct, ctinfo, data, dataoff, taddr,
+		ret = nat_t120(skb, ct, ctinfo, protoff, data, dataoff, taddr,
 			       port, exp);
 	} else {		/* Conntrack only */
 		if (nf_ct_expect_related(exp) == 0) {
@@ -376,6 +383,7 @@ static int expect_t120(struct sk_buff *skb,
 static int process_h245_channel(struct sk_buff *skb,
 				struct nf_conn *ct,
 				enum ip_conntrack_info ctinfo,
+				unsigned int protoff,
 				unsigned char **data, int dataoff,
 				H2250LogicalChannelParameters *channel)
 {
@@ -383,7 +391,7 @@ static int process_h245_channel(struct sk_buff *skb,
 
 	if (channel->options & eH2250LogicalChannelParameters_mediaChannel) {
 		/* RTP */
-		ret = expect_rtp_rtcp(skb, ct, ctinfo, data, dataoff,
+		ret = expect_rtp_rtcp(skb, ct, ctinfo, protoff, data, dataoff,
 				      &channel->mediaChannel);
 		if (ret < 0)
 			return -1;
@@ -392,7 +400,7 @@ static int process_h245_channel(struct sk_buff *skb,
 	if (channel->
 	    options & eH2250LogicalChannelParameters_mediaControlChannel) {
 		/* RTCP */
-		ret = expect_rtp_rtcp(skb, ct, ctinfo, data, dataoff,
+		ret = expect_rtp_rtcp(skb, ct, ctinfo, protoff, data, dataoff,
 				      &channel->mediaControlChannel);
 		if (ret < 0)
 			return -1;
@@ -404,6 +412,7 @@ static int process_h245_channel(struct sk_buff *skb,
 /****************************************************************************/
 static int process_olc(struct sk_buff *skb, struct nf_conn *ct,
 		       enum ip_conntrack_info ctinfo,
+		       unsigned int protoff,
 		       unsigned char **data, int dataoff,
 		       OpenLogicalChannel *olc)
 {
@@ -414,7 +423,8 @@ static int process_olc(struct sk_buff *skb, struct nf_conn *ct,
 	if (olc->forwardLogicalChannelParameters.multiplexParameters.choice ==
 	    eOpenLogicalChannel_forwardLogicalChannelParameters_multiplexParameters_h2250LogicalChannelParameters)
 	{
-		ret = process_h245_channel(skb, ct, ctinfo, data, dataoff,
+		ret = process_h245_channel(skb, ct, ctinfo,
+					   protoff, data, dataoff,
 					   &olc->
 					   forwardLogicalChannelParameters.
 					   multiplexParameters.
@@ -432,7 +442,8 @@ static int process_olc(struct sk_buff *skb, struct nf_conn *ct,
 		eOpenLogicalChannel_reverseLogicalChannelParameters_multiplexParameters_h2250LogicalChannelParameters))
 	{
 		ret =
-		    process_h245_channel(skb, ct, ctinfo, data, dataoff,
+		    process_h245_channel(skb, ct, ctinfo,
+					 protoff, data, dataoff,
 					 &olc->
 					 reverseLogicalChannelParameters.
 					 multiplexParameters.
@@ -450,7 +461,7 @@ static int process_olc(struct sk_buff *skb, struct nf_conn *ct,
 	    t120.choice == eDataProtocolCapability_separateLANStack &&
 	    olc->separateStack.networkAddress.choice ==
 	    eNetworkAccessParameters_networkAddress_localAreaAddress) {
-		ret = expect_t120(skb, ct, ctinfo, data, dataoff,
+		ret = expect_t120(skb, ct, ctinfo, protoff, data, dataoff,
 				  &olc->separateStack.networkAddress.
 				  localAreaAddress);
 		if (ret < 0)
@@ -463,7 +474,7 @@ static int process_olc(struct sk_buff *skb, struct nf_conn *ct,
 /****************************************************************************/
 static int process_olca(struct sk_buff *skb, struct nf_conn *ct,
 			enum ip_conntrack_info ctinfo,
-			unsigned char **data, int dataoff,
+			unsigned int protoff, unsigned char **data, int dataoff,
 			OpenLogicalChannelAck *olca)
 {
 	H2250LogicalChannelAckParameters *ack;
@@ -479,7 +490,8 @@ static int process_olca(struct sk_buff *skb, struct nf_conn *ct,
 		choice ==
 		eOpenLogicalChannelAck_reverseLogicalChannelParameters_multiplexParameters_h2250LogicalChannelParameters))
 	{
-		ret = process_h245_channel(skb, ct, ctinfo, data, dataoff,
+		ret = process_h245_channel(skb, ct, ctinfo,
+					   protoff, data, dataoff,
 					   &olca->
 					   reverseLogicalChannelParameters.
 					   multiplexParameters.
@@ -498,7 +510,8 @@ static int process_olca(struct sk_buff *skb, struct nf_conn *ct,
 		if (ack->options &
 		    eH2250LogicalChannelAckParameters_mediaChannel) {
 			/* RTP */
-			ret = expect_rtp_rtcp(skb, ct, ctinfo, data, dataoff,
+			ret = expect_rtp_rtcp(skb, ct, ctinfo,
+					      protoff, data, dataoff,
 					      &ack->mediaChannel);
 			if (ret < 0)
 				return -1;
@@ -507,7 +520,8 @@ static int process_olca(struct sk_buff *skb, struct nf_conn *ct,
 		if (ack->options &
 		    eH2250LogicalChannelAckParameters_mediaControlChannel) {
 			/* RTCP */
-			ret = expect_rtp_rtcp(skb, ct, ctinfo, data, dataoff,
+			ret = expect_rtp_rtcp(skb, ct, ctinfo,
+					      protoff, data, dataoff,
 					      &ack->mediaControlChannel);
 			if (ret < 0)
 				return -1;
@@ -517,7 +531,7 @@ static int process_olca(struct sk_buff *skb, struct nf_conn *ct,
 	if ((olca->options & eOpenLogicalChannelAck_separateStack) &&
 		olca->separateStack.networkAddress.choice ==
 		eNetworkAccessParameters_networkAddress_localAreaAddress) {
-		ret = expect_t120(skb, ct, ctinfo, data, dataoff,
+		ret = expect_t120(skb, ct, ctinfo, protoff, data, dataoff,
 				  &olca->separateStack.networkAddress.
 				  localAreaAddress);
 		if (ret < 0)
@@ -530,14 +544,15 @@ static int process_olca(struct sk_buff *skb, struct nf_conn *ct,
 /****************************************************************************/
 static int process_h245(struct sk_buff *skb, struct nf_conn *ct,
 			enum ip_conntrack_info ctinfo,
-			unsigned char **data, int dataoff,
+			unsigned int protoff, unsigned char **data, int dataoff,
 			MultimediaSystemControlMessage *mscm)
 {
 	switch (mscm->choice) {
 	case eMultimediaSystemControlMessage_request:
 		if (mscm->request.choice ==
 		    eRequestMessage_openLogicalChannel) {
-			return process_olc(skb, ct, ctinfo, data, dataoff,
+			return process_olc(skb, ct, ctinfo,
+					   protoff, data, dataoff,
 					   &mscm->request.openLogicalChannel);
 		}
 		pr_debug("nf_ct_h323: H.245 Request %d\n",
@@ -546,7 +561,8 @@ static int process_h245(struct sk_buff *skb, struct nf_conn *ct,
 	case eMultimediaSystemControlMessage_response:
 		if (mscm->response.choice ==
 		    eResponseMessage_openLogicalChannelAck) {
-			return process_olca(skb, ct, ctinfo, data, dataoff,
+			return process_olca(skb, ct, ctinfo,
+					    protoff, data, dataoff,
 					    &mscm->response.
 					    openLogicalChannelAck);
 		}
@@ -597,7 +613,8 @@ static int h245_help(struct sk_buff *skb, unsigned int protoff,
 		}
 
 		/* Process H.245 signal */
-		if (process_h245(skb, ct, ctinfo, &data, dataoff, &mscm) < 0)
+		if (process_h245(skb, ct, ctinfo, protoff,
+				 &data, dataoff, &mscm) < 0)
 			goto drop;
 	}
 
@@ -661,7 +678,7 @@ int get_h225_addr(struct nf_conn *ct, unsigned char *data,
 /****************************************************************************/
 static int expect_h245(struct sk_buff *skb, struct nf_conn *ct,
 		       enum ip_conntrack_info ctinfo,
-		       unsigned char **data, int dataoff,
+		       unsigned int protoff, unsigned char **data, int dataoff,
 		       TransportAddress *taddr)
 {
 	int dir = CTINFO2DIR(ctinfo);
@@ -693,7 +710,7 @@ static int expect_h245(struct sk_buff *skb, struct nf_conn *ct,
 	    nf_ct_l3num(ct) == NFPROTO_IPV4 &&
 	    ct->status & IPS_NAT_MASK) {
 		/* NAT needed */
-		ret = nat_h245(skb, ct, ctinfo, data, dataoff, taddr,
+		ret = nat_h245(skb, ct, ctinfo, protoff, data, dataoff, taddr,
 			       port, exp);
 	} else {		/* Conntrack only */
 		if (nf_ct_expect_related(exp) == 0) {
@@ -779,6 +796,7 @@ static int callforward_do_filter(const union nf_inet_addr *src,
 static int expect_callforwarding(struct sk_buff *skb,
 				 struct nf_conn *ct,
 				 enum ip_conntrack_info ctinfo,
+				 unsigned int protoff,
 				 unsigned char **data, int dataoff,
 				 TransportAddress *taddr)
 {
@@ -817,7 +835,8 @@ static int expect_callforwarding(struct sk_buff *skb,
 	    nf_ct_l3num(ct) == NFPROTO_IPV4 &&
 	    ct->status & IPS_NAT_MASK) {
 		/* Need NAT */
-		ret = nat_callforwarding(skb, ct, ctinfo, data, dataoff,
+		ret = nat_callforwarding(skb, ct, ctinfo,
+					 protoff, data, dataoff,
 					 taddr, port, exp);
 	} else {		/* Conntrack only */
 		if (nf_ct_expect_related(exp) == 0) {
@@ -835,6 +854,7 @@ static int expect_callforwarding(struct sk_buff *skb,
 /****************************************************************************/
 static int process_setup(struct sk_buff *skb, struct nf_conn *ct,
 			 enum ip_conntrack_info ctinfo,
+			 unsigned int protoff,
 			 unsigned char **data, int dataoff,
 			 Setup_UUIE *setup)
 {
@@ -848,7 +868,7 @@ static int process_setup(struct sk_buff *skb, struct nf_conn *ct,
 	pr_debug("nf_ct_q931: Setup\n");
 
 	if (setup->options & eSetup_UUIE_h245Address) {
-		ret = expect_h245(skb, ct, ctinfo, data, dataoff,
+		ret = expect_h245(skb, ct, ctinfo, protoff, data, dataoff,
 				  &setup->h245Address);
 		if (ret < 0)
 			return -1;
@@ -864,7 +884,7 @@ static int process_setup(struct sk_buff *skb, struct nf_conn *ct,
 		pr_debug("nf_ct_q931: set destCallSignalAddress %pI6:%hu->%pI6:%hu\n",
 			 &addr, ntohs(port), &ct->tuplehash[!dir].tuple.src.u3,
 			 ntohs(ct->tuplehash[!dir].tuple.src.u.tcp.port));
-		ret = set_h225_addr(skb, data, dataoff,
+		ret = set_h225_addr(skb, protoff, data, dataoff,
 				    &setup->destCallSignalAddress,
 				    &ct->tuplehash[!dir].tuple.src.u3,
 				    ct->tuplehash[!dir].tuple.src.u.tcp.port);
@@ -881,7 +901,7 @@ static int process_setup(struct sk_buff *skb, struct nf_conn *ct,
 		pr_debug("nf_ct_q931: set sourceCallSignalAddress %pI6:%hu->%pI6:%hu\n",
 			 &addr, ntohs(port), &ct->tuplehash[!dir].tuple.dst.u3,
 			 ntohs(ct->tuplehash[!dir].tuple.dst.u.tcp.port));
-		ret = set_h225_addr(skb, data, dataoff,
+		ret = set_h225_addr(skb, protoff, data, dataoff,
 				    &setup->sourceCallSignalAddress,
 				    &ct->tuplehash[!dir].tuple.dst.u3,
 				    ct->tuplehash[!dir].tuple.dst.u.tcp.port);
@@ -891,7 +911,8 @@ static int process_setup(struct sk_buff *skb, struct nf_conn *ct,
 
 	if (setup->options & eSetup_UUIE_fastStart) {
 		for (i = 0; i < setup->fastStart.count; i++) {
-			ret = process_olc(skb, ct, ctinfo, data, dataoff,
+			ret = process_olc(skb, ct, ctinfo,
+					  protoff, data, dataoff,
 					  &setup->fastStart.item[i]);
 			if (ret < 0)
 				return -1;
@@ -905,6 +926,7 @@ static int process_setup(struct sk_buff *skb, struct nf_conn *ct,
 static int process_callproceeding(struct sk_buff *skb,
 				  struct nf_conn *ct,
 				  enum ip_conntrack_info ctinfo,
+				  unsigned int protoff,
 				  unsigned char **data, int dataoff,
 				  CallProceeding_UUIE *callproc)
 {
@@ -914,7 +936,7 @@ static int process_callproceeding(struct sk_buff *skb,
 	pr_debug("nf_ct_q931: CallProceeding\n");
 
 	if (callproc->options & eCallProceeding_UUIE_h245Address) {
-		ret = expect_h245(skb, ct, ctinfo, data, dataoff,
+		ret = expect_h245(skb, ct, ctinfo, protoff, data, dataoff,
 				  &callproc->h245Address);
 		if (ret < 0)
 			return -1;
@@ -922,7 +944,8 @@ static int process_callproceeding(struct sk_buff *skb,
 
 	if (callproc->options & eCallProceeding_UUIE_fastStart) {
 		for (i = 0; i < callproc->fastStart.count; i++) {
-			ret = process_olc(skb, ct, ctinfo, data, dataoff,
+			ret = process_olc(skb, ct, ctinfo,
+					  protoff, data, dataoff,
 					  &callproc->fastStart.item[i]);
 			if (ret < 0)
 				return -1;
@@ -935,6 +958,7 @@ static int process_callproceeding(struct sk_buff *skb,
 /****************************************************************************/
 static int process_connect(struct sk_buff *skb, struct nf_conn *ct,
 			   enum ip_conntrack_info ctinfo,
+			   unsigned int protoff,
 			   unsigned char **data, int dataoff,
 			   Connect_UUIE *connect)
 {
@@ -944,7 +968,7 @@ static int process_connect(struct sk_buff *skb, struct nf_conn *ct,
 	pr_debug("nf_ct_q931: Connect\n");
 
 	if (connect->options & eConnect_UUIE_h245Address) {
-		ret = expect_h245(skb, ct, ctinfo, data, dataoff,
+		ret = expect_h245(skb, ct, ctinfo, protoff, data, dataoff,
 				  &connect->h245Address);
 		if (ret < 0)
 			return -1;
@@ -952,7 +976,8 @@ static int process_connect(struct sk_buff *skb, struct nf_conn *ct,
 
 	if (connect->options & eConnect_UUIE_fastStart) {
 		for (i = 0; i < connect->fastStart.count; i++) {
-			ret = process_olc(skb, ct, ctinfo, data, dataoff,
+			ret = process_olc(skb, ct, ctinfo,
+					  protoff, data, dataoff,
 					  &connect->fastStart.item[i]);
 			if (ret < 0)
 				return -1;
@@ -965,6 +990,7 @@ static int process_connect(struct sk_buff *skb, struct nf_conn *ct,
 /****************************************************************************/
 static int process_alerting(struct sk_buff *skb, struct nf_conn *ct,
 			    enum ip_conntrack_info ctinfo,
+			    unsigned int protoff,
 			    unsigned char **data, int dataoff,
 			    Alerting_UUIE *alert)
 {
@@ -974,7 +1000,7 @@ static int process_alerting(struct sk_buff *skb, struct nf_conn *ct,
 	pr_debug("nf_ct_q931: Alerting\n");
 
 	if (alert->options & eAlerting_UUIE_h245Address) {
-		ret = expect_h245(skb, ct, ctinfo, data, dataoff,
+		ret = expect_h245(skb, ct, ctinfo, protoff, data, dataoff,
 				  &alert->h245Address);
 		if (ret < 0)
 			return -1;
@@ -982,7 +1008,8 @@ static int process_alerting(struct sk_buff *skb, struct nf_conn *ct,
 
 	if (alert->options & eAlerting_UUIE_fastStart) {
 		for (i = 0; i < alert->fastStart.count; i++) {
-			ret = process_olc(skb, ct, ctinfo, data, dataoff,
+			ret = process_olc(skb, ct, ctinfo,
+					  protoff, data, dataoff,
 					  &alert->fastStart.item[i]);
 			if (ret < 0)
 				return -1;
@@ -995,6 +1022,7 @@ static int process_alerting(struct sk_buff *skb, struct nf_conn *ct,
 /****************************************************************************/
 static int process_facility(struct sk_buff *skb, struct nf_conn *ct,
 			    enum ip_conntrack_info ctinfo,
+			    unsigned int protoff,
 			    unsigned char **data, int dataoff,
 			    Facility_UUIE *facility)
 {
@@ -1005,15 +1033,15 @@ static int process_facility(struct sk_buff *skb, struct nf_conn *ct,
 
 	if (facility->reason.choice == eFacilityReason_callForwarded) {
 		if (facility->options & eFacility_UUIE_alternativeAddress)
-			return expect_callforwarding(skb, ct, ctinfo, data,
-						     dataoff,
+			return expect_callforwarding(skb, ct, ctinfo,
+						     protoff, data, dataoff,
 						     &facility->
 						     alternativeAddress);
 		return 0;
 	}
 
 	if (facility->options & eFacility_UUIE_h245Address) {
-		ret = expect_h245(skb, ct, ctinfo, data, dataoff,
+		ret = expect_h245(skb, ct, ctinfo, protoff, data, dataoff,
 				  &facility->h245Address);
 		if (ret < 0)
 			return -1;
@@ -1021,7 +1049,8 @@ static int process_facility(struct sk_buff *skb, struct nf_conn *ct,
 
 	if (facility->options & eFacility_UUIE_fastStart) {
 		for (i = 0; i < facility->fastStart.count; i++) {
-			ret = process_olc(skb, ct, ctinfo, data, dataoff,
+			ret = process_olc(skb, ct, ctinfo,
+					  protoff, data, dataoff,
 					  &facility->fastStart.item[i]);
 			if (ret < 0)
 				return -1;
@@ -1034,6 +1063,7 @@ static int process_facility(struct sk_buff *skb, struct nf_conn *ct,
 /****************************************************************************/
 static int process_progress(struct sk_buff *skb, struct nf_conn *ct,
 			    enum ip_conntrack_info ctinfo,
+			    unsigned int protoff,
 			    unsigned char **data, int dataoff,
 			    Progress_UUIE *progress)
 {
@@ -1043,7 +1073,7 @@ static int process_progress(struct sk_buff *skb, struct nf_conn *ct,
 	pr_debug("nf_ct_q931: Progress\n");
 
 	if (progress->options & eProgress_UUIE_h245Address) {
-		ret = expect_h245(skb, ct, ctinfo, data, dataoff,
+		ret = expect_h245(skb, ct, ctinfo, protoff, data, dataoff,
 				  &progress->h245Address);
 		if (ret < 0)
 			return -1;
@@ -1051,7 +1081,8 @@ static int process_progress(struct sk_buff *skb, struct nf_conn *ct,
 
 	if (progress->options & eProgress_UUIE_fastStart) {
 		for (i = 0; i < progress->fastStart.count; i++) {
-			ret = process_olc(skb, ct, ctinfo, data, dataoff,
+			ret = process_olc(skb, ct, ctinfo,
+					  protoff, data, dataoff,
 					  &progress->fastStart.item[i]);
 			if (ret < 0)
 				return -1;
@@ -1064,7 +1095,8 @@ static int process_progress(struct sk_buff *skb, struct nf_conn *ct,
 /****************************************************************************/
 static int process_q931(struct sk_buff *skb, struct nf_conn *ct,
 			enum ip_conntrack_info ctinfo,
-			unsigned char **data, int dataoff, Q931 *q931)
+			unsigned int protoff, unsigned char **data, int dataoff,
+			Q931 *q931)
 {
 	H323_UU_PDU *pdu = &q931->UUIE.h323_uu_pdu;
 	int i;
@@ -1072,28 +1104,29 @@ static int process_q931(struct sk_buff *skb, struct nf_conn *ct,
 
 	switch (pdu->h323_message_body.choice) {
 	case eH323_UU_PDU_h323_message_body_setup:
-		ret = process_setup(skb, ct, ctinfo, data, dataoff,
+		ret = process_setup(skb, ct, ctinfo, protoff, data, dataoff,
 				    &pdu->h323_message_body.setup);
 		break;
 	case eH323_UU_PDU_h323_message_body_callProceeding:
-		ret = process_callproceeding(skb, ct, ctinfo, data, dataoff,
+		ret = process_callproceeding(skb, ct, ctinfo,
+					     protoff, data, dataoff,
 					     &pdu->h323_message_body.
 					     callProceeding);
 		break;
 	case eH323_UU_PDU_h323_message_body_connect:
-		ret = process_connect(skb, ct, ctinfo, data, dataoff,
+		ret = process_connect(skb, ct, ctinfo, protoff, data, dataoff,
 				      &pdu->h323_message_body.connect);
 		break;
 	case eH323_UU_PDU_h323_message_body_alerting:
-		ret = process_alerting(skb, ct, ctinfo, data, dataoff,
+		ret = process_alerting(skb, ct, ctinfo, protoff, data, dataoff,
 				       &pdu->h323_message_body.alerting);
 		break;
 	case eH323_UU_PDU_h323_message_body_facility:
-		ret = process_facility(skb, ct, ctinfo, data, dataoff,
+		ret = process_facility(skb, ct, ctinfo, protoff, data, dataoff,
 				       &pdu->h323_message_body.facility);
 		break;
 	case eH323_UU_PDU_h323_message_body_progress:
-		ret = process_progress(skb, ct, ctinfo, data, dataoff,
+		ret = process_progress(skb, ct, ctinfo, protoff, data, dataoff,
 				       &pdu->h323_message_body.progress);
 		break;
 	default:
@@ -1107,7 +1140,8 @@ static int process_q931(struct sk_buff *skb, struct nf_conn *ct,
 
 	if (pdu->options & eH323_UU_PDU_h245Control) {
 		for (i = 0; i < pdu->h245Control.count; i++) {
-			ret = process_h245(skb, ct, ctinfo, data, dataoff,
+			ret = process_h245(skb, ct, ctinfo,
+					   protoff, data, dataoff,
 					   &pdu->h245Control.item[i]);
 			if (ret < 0)
 				return -1;
@@ -1152,7 +1186,8 @@ static int q931_help(struct sk_buff *skb, unsigned int protoff,
 		}
 
 		/* Process Q.931 signal */
-		if (process_q931(skb, ct, ctinfo, &data, dataoff, &q931) < 0)
+		if (process_q931(skb, ct, ctinfo, protoff,
+				 &data, dataoff, &q931) < 0)
 			goto drop;
 	}
 
@@ -1249,7 +1284,7 @@ static int set_expect_timeout(struct nf_conntrack_expect *exp,
 /****************************************************************************/
 static int expect_q931(struct sk_buff *skb, struct nf_conn *ct,
 		       enum ip_conntrack_info ctinfo,
-		       unsigned char **data,
+		       unsigned int protoff, unsigned char **data,
 		       TransportAddress *taddr, int count)
 {
 	struct nf_ct_h323_master *info = nfct_help_data(ct);
@@ -1286,7 +1321,8 @@ static int expect_q931(struct sk_buff *skb, struct nf_conn *ct,
 	nat_q931 = rcu_dereference(nat_q931_hook);
 	if (nat_q931 && nf_ct_l3num(ct) == NFPROTO_IPV4 &&
 	    ct->status & IPS_NAT_MASK) {	/* Need NAT */
-		ret = nat_q931(skb, ct, ctinfo, data, taddr, i, port, exp);
+		ret = nat_q931(skb, ct, ctinfo, protoff, data,
+			       taddr, i, port, exp);
 	} else {		/* Conntrack only */
 		if (nf_ct_expect_related(exp) == 0) {
 			pr_debug("nf_ct_ras: expect Q.931 ");
@@ -1306,6 +1342,7 @@ static int expect_q931(struct sk_buff *skb, struct nf_conn *ct,
 /****************************************************************************/
 static int process_grq(struct sk_buff *skb, struct nf_conn *ct,
 		       enum ip_conntrack_info ctinfo,
+		       unsigned int protoff,
 		       unsigned char **data, GatekeeperRequest *grq)
 {
 	typeof(set_ras_addr_hook) set_ras_addr;
@@ -1315,7 +1352,7 @@ static int process_grq(struct sk_buff *skb, struct nf_conn *ct,
 	set_ras_addr = rcu_dereference(set_ras_addr_hook);
 	if (set_ras_addr && nf_ct_l3num(ct) == NFPROTO_IPV4 &&
 	    ct->status & IPS_NAT_MASK)	/* NATed */
-		return set_ras_addr(skb, ct, ctinfo, data,
+		return set_ras_addr(skb, ct, ctinfo, protoff, data,
 				    &grq->rasAddress, 1);
 	return 0;
 }
@@ -1323,6 +1360,7 @@ static int process_grq(struct sk_buff *skb, struct nf_conn *ct,
 /****************************************************************************/
 static int process_gcf(struct sk_buff *skb, struct nf_conn *ct,
 		       enum ip_conntrack_info ctinfo,
+		       unsigned int protoff,
 		       unsigned char **data, GatekeeperConfirm *gcf)
 {
 	int dir = CTINFO2DIR(ctinfo);
@@ -1367,6 +1405,7 @@ static int process_gcf(struct sk_buff *skb, struct nf_conn *ct,
 /****************************************************************************/
 static int process_rrq(struct sk_buff *skb, struct nf_conn *ct,
 		       enum ip_conntrack_info ctinfo,
+		       unsigned int protoff,
 		       unsigned char **data, RegistrationRequest *rrq)
 {
 	struct nf_ct_h323_master *info = nfct_help_data(ct);
@@ -1375,7 +1414,7 @@ static int process_rrq(struct sk_buff *skb, struct nf_conn *ct,
 
 	pr_debug("nf_ct_ras: RRQ\n");
 
-	ret = expect_q931(skb, ct, ctinfo, data,
+	ret = expect_q931(skb, ct, ctinfo, protoff, data,
 			  rrq->callSignalAddress.item,
 			  rrq->callSignalAddress.count);
 	if (ret < 0)
@@ -1384,7 +1423,7 @@ static int process_rrq(struct sk_buff *skb, struct nf_conn *ct,
 	set_ras_addr = rcu_dereference(set_ras_addr_hook);
 	if (set_ras_addr && nf_ct_l3num(ct) == NFPROTO_IPV4 &&
 	    ct->status & IPS_NAT_MASK) {
-		ret = set_ras_addr(skb, ct, ctinfo, data,
+		ret = set_ras_addr(skb, ct, ctinfo, protoff, data,
 				   rrq->rasAddress.item,
 				   rrq->rasAddress.count);
 		if (ret < 0)
@@ -1403,6 +1442,7 @@ static int process_rrq(struct sk_buff *skb, struct nf_conn *ct,
 /****************************************************************************/
 static int process_rcf(struct sk_buff *skb, struct nf_conn *ct,
 		       enum ip_conntrack_info ctinfo,
+		       unsigned int protoff,
 		       unsigned char **data, RegistrationConfirm *rcf)
 {
 	struct nf_ct_h323_master *info = nfct_help_data(ct);
@@ -1416,7 +1456,7 @@ static int process_rcf(struct sk_buff *skb, struct nf_conn *ct,
 	set_sig_addr = rcu_dereference(set_sig_addr_hook);
 	if (set_sig_addr && nf_ct_l3num(ct) == NFPROTO_IPV4 &&
 	    ct->status & IPS_NAT_MASK) {
-		ret = set_sig_addr(skb, ct, ctinfo, data,
+		ret = set_sig_addr(skb, ct, ctinfo, protoff, data,
 					rcf->callSignalAddress.item,
 					rcf->callSignalAddress.count);
 		if (ret < 0)
@@ -1453,6 +1493,7 @@ static int process_rcf(struct sk_buff *skb, struct nf_conn *ct,
 /****************************************************************************/
 static int process_urq(struct sk_buff *skb, struct nf_conn *ct,
 		       enum ip_conntrack_info ctinfo,
+		       unsigned int protoff,
 		       unsigned char **data, UnregistrationRequest *urq)
 {
 	struct nf_ct_h323_master *info = nfct_help_data(ct);
@@ -1465,7 +1506,7 @@ static int process_urq(struct sk_buff *skb, struct nf_conn *ct,
 	set_sig_addr = rcu_dereference(set_sig_addr_hook);
 	if (set_sig_addr && nf_ct_l3num(ct) == NFPROTO_IPV4 &&
 	    ct->status & IPS_NAT_MASK) {
-		ret = set_sig_addr(skb, ct, ctinfo, data,
+		ret = set_sig_addr(skb, ct, ctinfo, protoff, data,
 				   urq->callSignalAddress.item,
 				   urq->callSignalAddress.count);
 		if (ret < 0)
@@ -1486,6 +1527,7 @@ static int process_urq(struct sk_buff *skb, struct nf_conn *ct,
 /****************************************************************************/
 static int process_arq(struct sk_buff *skb, struct nf_conn *ct,
 		       enum ip_conntrack_info ctinfo,
+		       unsigned int protoff,
 		       unsigned char **data, AdmissionRequest *arq)
 {
 	const struct nf_ct_h323_master *info = nfct_help_data(ct);
@@ -1505,7 +1547,7 @@ static int process_arq(struct sk_buff *skb, struct nf_conn *ct,
 	    nf_ct_l3num(ct) == NFPROTO_IPV4 &&
 	    set_h225_addr && ct->status & IPS_NAT_MASK) {
 		/* Answering ARQ */
-		return set_h225_addr(skb, data, 0,
+		return set_h225_addr(skb, protoff, data, 0,
 				     &arq->destCallSignalAddress,
 				     &ct->tuplehash[!dir].tuple.dst.u3,
 				     info->sig_port[!dir]);
@@ -1518,7 +1560,7 @@ static int process_arq(struct sk_buff *skb, struct nf_conn *ct,
 	    set_h225_addr && nf_ct_l3num(ct) == NFPROTO_IPV4 &&
 	    ct->status & IPS_NAT_MASK) {
 		/* Calling ARQ */
-		return set_h225_addr(skb, data, 0,
+		return set_h225_addr(skb, protoff, data, 0,
 				     &arq->srcCallSignalAddress,
 				     &ct->tuplehash[!dir].tuple.dst.u3,
 				     port);
@@ -1530,6 +1572,7 @@ static int process_arq(struct sk_buff *skb, struct nf_conn *ct,
 /****************************************************************************/
 static int process_acf(struct sk_buff *skb, struct nf_conn *ct,
 		       enum ip_conntrack_info ctinfo,
+		       unsigned int protoff,
 		       unsigned char **data, AdmissionConfirm *acf)
 {
 	int dir = CTINFO2DIR(ctinfo);
@@ -1550,7 +1593,7 @@ static int process_acf(struct sk_buff *skb, struct nf_conn *ct,
 		set_sig_addr = rcu_dereference(set_sig_addr_hook);
 		if (set_sig_addr && nf_ct_l3num(ct) == NFPROTO_IPV4 &&
 		    ct->status & IPS_NAT_MASK)
-			return set_sig_addr(skb, ct, ctinfo, data,
+			return set_sig_addr(skb, ct, ctinfo, protoff, data,
 					    &acf->destCallSignalAddress, 1);
 		return 0;
 	}
@@ -1578,6 +1621,7 @@ static int process_acf(struct sk_buff *skb, struct nf_conn *ct,
 /****************************************************************************/
 static int process_lrq(struct sk_buff *skb, struct nf_conn *ct,
 		       enum ip_conntrack_info ctinfo,
+		       unsigned int protoff,
 		       unsigned char **data, LocationRequest *lrq)
 {
 	typeof(set_ras_addr_hook) set_ras_addr;
@@ -1587,7 +1631,7 @@ static int process_lrq(struct sk_buff *skb, struct nf_conn *ct,
 	set_ras_addr = rcu_dereference(set_ras_addr_hook);
 	if (set_ras_addr && nf_ct_l3num(ct) == NFPROTO_IPV4 &&
 	    ct->status & IPS_NAT_MASK)
-		return set_ras_addr(skb, ct, ctinfo, data,
+		return set_ras_addr(skb, ct, ctinfo, protoff, data,
 				    &lrq->replyAddress, 1);
 	return 0;
 }
@@ -1595,6 +1639,7 @@ static int process_lrq(struct sk_buff *skb, struct nf_conn *ct,
 /****************************************************************************/
 static int process_lcf(struct sk_buff *skb, struct nf_conn *ct,
 		       enum ip_conntrack_info ctinfo,
+		       unsigned int protoff,
 		       unsigned char **data, LocationConfirm *lcf)
 {
 	int dir = CTINFO2DIR(ctinfo);
@@ -1634,6 +1679,7 @@ static int process_lcf(struct sk_buff *skb, struct nf_conn *ct,
 /****************************************************************************/
 static int process_irr(struct sk_buff *skb, struct nf_conn *ct,
 		       enum ip_conntrack_info ctinfo,
+		       unsigned int protoff,
 		       unsigned char **data, InfoRequestResponse *irr)
 {
 	int ret;
@@ -1645,7 +1691,7 @@ static int process_irr(struct sk_buff *skb, struct nf_conn *ct,
 	set_ras_addr = rcu_dereference(set_ras_addr_hook);
 	if (set_ras_addr && nf_ct_l3num(ct) == NFPROTO_IPV4 &&
 	    ct->status & IPS_NAT_MASK) {
-		ret = set_ras_addr(skb, ct, ctinfo, data,
+		ret = set_ras_addr(skb, ct, ctinfo, protoff, data,
 				   &irr->rasAddress, 1);
 		if (ret < 0)
 			return -1;
@@ -1654,7 +1700,7 @@ static int process_irr(struct sk_buff *skb, struct nf_conn *ct,
 	set_sig_addr = rcu_dereference(set_sig_addr_hook);
 	if (set_sig_addr && nf_ct_l3num(ct) == NFPROTO_IPV4 &&
 	    ct->status & IPS_NAT_MASK) {
-		ret = set_sig_addr(skb, ct, ctinfo, data,
+		ret = set_sig_addr(skb, ct, ctinfo, protoff, data,
 					irr->callSignalAddress.item,
 					irr->callSignalAddress.count);
 		if (ret < 0)
@@ -1667,38 +1713,39 @@ static int process_irr(struct sk_buff *skb, struct nf_conn *ct,
 /****************************************************************************/
 static int process_ras(struct sk_buff *skb, struct nf_conn *ct,
 		       enum ip_conntrack_info ctinfo,
+		       unsigned int protoff,
 		       unsigned char **data, RasMessage *ras)
 {
 	switch (ras->choice) {
 	case eRasMessage_gatekeeperRequest:
-		return process_grq(skb, ct, ctinfo, data,
+		return process_grq(skb, ct, ctinfo, protoff, data,
 				   &ras->gatekeeperRequest);
 	case eRasMessage_gatekeeperConfirm:
-		return process_gcf(skb, ct, ctinfo, data,
+		return process_gcf(skb, ct, ctinfo, protoff, data,
 				   &ras->gatekeeperConfirm);
 	case eRasMessage_registrationRequest:
-		return process_rrq(skb, ct, ctinfo, data,
+		return process_rrq(skb, ct, ctinfo, protoff, data,
 				   &ras->registrationRequest);
 	case eRasMessage_registrationConfirm:
-		return process_rcf(skb, ct, ctinfo, data,
+		return process_rcf(skb, ct, ctinfo, protoff, data,
 				   &ras->registrationConfirm);
 	case eRasMessage_unregistrationRequest:
-		return process_urq(skb, ct, ctinfo, data,
+		return process_urq(skb, ct, ctinfo, protoff, data,
 				   &ras->unregistrationRequest);
 	case eRasMessage_admissionRequest:
-		return process_arq(skb, ct, ctinfo, data,
+		return process_arq(skb, ct, ctinfo, protoff, data,
 				   &ras->admissionRequest);
 	case eRasMessage_admissionConfirm:
-		return process_acf(skb, ct, ctinfo, data,
+		return process_acf(skb, ct, ctinfo, protoff, data,
 				   &ras->admissionConfirm);
 	case eRasMessage_locationRequest:
-		return process_lrq(skb, ct, ctinfo, data,
+		return process_lrq(skb, ct, ctinfo, protoff, data,
 				   &ras->locationRequest);
 	case eRasMessage_locationConfirm:
-		return process_lcf(skb, ct, ctinfo, data,
+		return process_lcf(skb, ct, ctinfo, protoff, data,
 				   &ras->locationConfirm);
 	case eRasMessage_infoRequestResponse:
-		return process_irr(skb, ct, ctinfo, data,
+		return process_irr(skb, ct, ctinfo, protoff, data,
 				   &ras->infoRequestResponse);
 	default:
 		pr_debug("nf_ct_ras: RAS message %d\n", ras->choice);
@@ -1738,7 +1785,7 @@ static int ras_help(struct sk_buff *skb, unsigned int protoff,
 	}
 
 	/* Process RAS message */
-	if (process_ras(skb, ct, ctinfo, &data, &ras) < 0)
+	if (process_ras(skb, ct, ctinfo, protoff, &data, &ras) < 0)
 		goto drop;
 
       accept:
diff --git a/net/netfilter/nf_conntrack_irc.c b/net/netfilter/nf_conntrack_irc.c
index e06dc2f..95d097c 100644
--- a/net/netfilter/nf_conntrack_irc.c
+++ b/net/netfilter/nf_conntrack_irc.c
@@ -33,6 +33,7 @@ static DEFINE_SPINLOCK(irc_buffer_lock);
 
 unsigned int (*nf_nat_irc_hook)(struct sk_buff *skb,
 				enum ip_conntrack_info ctinfo,
+				unsigned int protoff,
 				unsigned int matchoff,
 				unsigned int matchlen,
 				struct nf_conntrack_expect *exp) __read_mostly;
@@ -206,7 +207,7 @@ static int help(struct sk_buff *skb, unsigned int protoff,
 			nf_nat_irc = rcu_dereference(nf_nat_irc_hook);
 			if (nf_nat_irc && nf_ct_l3num(ct) == NFPROTO_IPV4 &&
 			    ct->status & IPS_NAT_MASK)
-				ret = nf_nat_irc(skb, ctinfo,
+				ret = nf_nat_irc(skb, ctinfo, protoff,
 						 addr_beg_p - ib_ptr,
 						 addr_end_p - addr_beg_p,
 						 exp);
diff --git a/net/netfilter/nf_conntrack_pptp.c b/net/netfilter/nf_conntrack_pptp.c
index 6fed9ec..cc7669e 100644
--- a/net/netfilter/nf_conntrack_pptp.c
+++ b/net/netfilter/nf_conntrack_pptp.c
@@ -45,14 +45,14 @@ static DEFINE_SPINLOCK(nf_pptp_lock);
 int
 (*nf_nat_pptp_hook_outbound)(struct sk_buff *skb,
 			     struct nf_conn *ct, enum ip_conntrack_info ctinfo,
-			     struct PptpControlHeader *ctlh,
+			     unsigned int protoff, struct PptpControlHeader *ctlh,
 			     union pptp_ctrl_union *pptpReq) __read_mostly;
 EXPORT_SYMBOL_GPL(nf_nat_pptp_hook_outbound);
 
 int
 (*nf_nat_pptp_hook_inbound)(struct sk_buff *skb,
 			    struct nf_conn *ct, enum ip_conntrack_info ctinfo,
-			    struct PptpControlHeader *ctlh,
+			    unsigned int protoff, struct PptpControlHeader *ctlh,
 			    union pptp_ctrl_union *pptpReq) __read_mostly;
 EXPORT_SYMBOL_GPL(nf_nat_pptp_hook_inbound);
 
@@ -262,7 +262,7 @@ out_unexpect_orig:
 }
 
 static inline int
-pptp_inbound_pkt(struct sk_buff *skb,
+pptp_inbound_pkt(struct sk_buff *skb, unsigned int protoff,
 		 struct PptpControlHeader *ctlh,
 		 union pptp_ctrl_union *pptpReq,
 		 unsigned int reqlen,
@@ -376,7 +376,8 @@ pptp_inbound_pkt(struct sk_buff *skb,
 
 	nf_nat_pptp_inbound = rcu_dereference(nf_nat_pptp_hook_inbound);
 	if (nf_nat_pptp_inbound && ct->status & IPS_NAT_MASK)
-		return nf_nat_pptp_inbound(skb, ct, ctinfo, ctlh, pptpReq);
+		return nf_nat_pptp_inbound(skb, ct, ctinfo,
+					   protoff, ctlh, pptpReq);
 	return NF_ACCEPT;
 
 invalid:
@@ -389,7 +390,7 @@ invalid:
 }
 
 static inline int
-pptp_outbound_pkt(struct sk_buff *skb,
+pptp_outbound_pkt(struct sk_buff *skb, unsigned int protoff,
 		  struct PptpControlHeader *ctlh,
 		  union pptp_ctrl_union *pptpReq,
 		  unsigned int reqlen,
@@ -471,7 +472,8 @@ pptp_outbound_pkt(struct sk_buff *skb,
 
 	nf_nat_pptp_outbound = rcu_dereference(nf_nat_pptp_hook_outbound);
 	if (nf_nat_pptp_outbound && ct->status & IPS_NAT_MASK)
-		return nf_nat_pptp_outbound(skb, ct, ctinfo, ctlh, pptpReq);
+		return nf_nat_pptp_outbound(skb, ct, ctinfo,
+					    protoff, ctlh, pptpReq);
 	return NF_ACCEPT;
 
 invalid:
@@ -570,11 +572,11 @@ conntrack_pptp_help(struct sk_buff *skb, unsigned int protoff,
 	 * established from PNS->PAC.  However, RFC makes no guarantee */
 	if (dir == IP_CT_DIR_ORIGINAL)
 		/* client -> server (PNS -> PAC) */
-		ret = pptp_outbound_pkt(skb, ctlh, pptpReq, reqlen, ct,
+		ret = pptp_outbound_pkt(skb, protoff, ctlh, pptpReq, reqlen, ct,
 					ctinfo);
 	else
 		/* server -> client (PAC -> PNS) */
-		ret = pptp_inbound_pkt(skb, ctlh, pptpReq, reqlen, ct,
+		ret = pptp_inbound_pkt(skb, protoff, ctlh, pptpReq, reqlen, ct,
 				       ctinfo);
 	pr_debug("sstate: %d->%d, cstate: %d->%d\n",
 		 oldsstate, info->sstate, oldcstate, info->cstate);
diff --git a/net/netfilter/nf_conntrack_sip.c b/net/netfilter/nf_conntrack_sip.c
index d08e0ba..590f0ab 100644
--- a/net/netfilter/nf_conntrack_sip.c
+++ b/net/netfilter/nf_conntrack_sip.c
@@ -52,8 +52,8 @@ module_param(sip_direct_media, int, 0600);
 MODULE_PARM_DESC(sip_direct_media, "Expect Media streams between signalling "
 				   "endpoints only (default 1)");
 
-unsigned int (*nf_nat_sip_hook)(struct sk_buff *skb, unsigned int dataoff,
-				const char **dptr,
+unsigned int (*nf_nat_sip_hook)(struct sk_buff *skb, unsigned int protoff,
+				unsigned int dataoff, const char **dptr,
 				unsigned int *datalen) __read_mostly;
 EXPORT_SYMBOL_GPL(nf_nat_sip_hook);
 
@@ -61,6 +61,7 @@ void (*nf_nat_sip_seq_adjust_hook)(struct sk_buff *skb, s16 off) __read_mostly;
 EXPORT_SYMBOL_GPL(nf_nat_sip_seq_adjust_hook);
 
 unsigned int (*nf_nat_sip_expect_hook)(struct sk_buff *skb,
+				       unsigned int protoff,
 				       unsigned int dataoff,
 				       const char **dptr,
 				       unsigned int *datalen,
@@ -69,7 +70,8 @@ unsigned int (*nf_nat_sip_expect_hook)(struct sk_buff *skb,
 				       unsigned int matchlen) __read_mostly;
 EXPORT_SYMBOL_GPL(nf_nat_sip_expect_hook);
 
-unsigned int (*nf_nat_sdp_addr_hook)(struct sk_buff *skb, unsigned int dataoff,
+unsigned int (*nf_nat_sdp_addr_hook)(struct sk_buff *skb, unsigned int protoff,
+				     unsigned int dataoff,
 				     const char **dptr,
 				     unsigned int *datalen,
 				     unsigned int sdpoff,
@@ -79,7 +81,8 @@ unsigned int (*nf_nat_sdp_addr_hook)(struct sk_buff *skb, unsigned int dataoff,
 				     __read_mostly;
 EXPORT_SYMBOL_GPL(nf_nat_sdp_addr_hook);
 
-unsigned int (*nf_nat_sdp_port_hook)(struct sk_buff *skb, unsigned int dataoff,
+unsigned int (*nf_nat_sdp_port_hook)(struct sk_buff *skb, unsigned int protoff,
+				     unsigned int dataoff,
 				     const char **dptr,
 				     unsigned int *datalen,
 				     unsigned int matchoff,
@@ -88,6 +91,7 @@ unsigned int (*nf_nat_sdp_port_hook)(struct sk_buff *skb, unsigned int dataoff,
 EXPORT_SYMBOL_GPL(nf_nat_sdp_port_hook);
 
 unsigned int (*nf_nat_sdp_session_hook)(struct sk_buff *skb,
+					unsigned int protoff,
 					unsigned int dataoff,
 					const char **dptr,
 					unsigned int *datalen,
@@ -96,7 +100,8 @@ unsigned int (*nf_nat_sdp_session_hook)(struct sk_buff *skb,
 					__read_mostly;
 EXPORT_SYMBOL_GPL(nf_nat_sdp_session_hook);
 
-unsigned int (*nf_nat_sdp_media_hook)(struct sk_buff *skb, unsigned int dataoff,
+unsigned int (*nf_nat_sdp_media_hook)(struct sk_buff *skb, unsigned int protoff,
+				      unsigned int dataoff,
 				      const char **dptr,
 				      unsigned int *datalen,
 				      struct nf_conntrack_expect *rtp_exp,
@@ -883,7 +888,8 @@ static void flush_expectations(struct nf_conn *ct, bool media)
 	spin_unlock_bh(&nf_conntrack_lock);
 }
 
-static int set_expected_rtp_rtcp(struct sk_buff *skb, unsigned int dataoff,
+static int set_expected_rtp_rtcp(struct sk_buff *skb, unsigned int protoff,
+				 unsigned int dataoff,
 				 const char **dptr, unsigned int *datalen,
 				 union nf_inet_addr *daddr, __be16 port,
 				 enum sip_expectation_classes class,
@@ -960,7 +966,7 @@ static int set_expected_rtp_rtcp(struct sk_buff *skb, unsigned int dataoff,
 	if (direct_rtp) {
 		nf_nat_sdp_port = rcu_dereference(nf_nat_sdp_port_hook);
 		if (nf_nat_sdp_port &&
-		    !nf_nat_sdp_port(skb, dataoff, dptr, datalen,
+		    !nf_nat_sdp_port(skb, protoff, dataoff, dptr, datalen,
 				     mediaoff, medialen, ntohs(rtp_port)))
 			goto err1;
 	}
@@ -983,7 +989,7 @@ static int set_expected_rtp_rtcp(struct sk_buff *skb, unsigned int dataoff,
 	nf_nat_sdp_media = rcu_dereference(nf_nat_sdp_media_hook);
 	if (nf_nat_sdp_media && nf_ct_l3num(ct) == NFPROTO_IPV4 &&
 	    ct->status & IPS_NAT_MASK && !direct_rtp)
-		ret = nf_nat_sdp_media(skb, dataoff, dptr, datalen,
+		ret = nf_nat_sdp_media(skb, protoff, dataoff, dptr, datalen,
 				       rtp_exp, rtcp_exp,
 				       mediaoff, medialen, daddr);
 	else {
@@ -1024,7 +1030,8 @@ static const struct sdp_media_type *sdp_media_type(const char *dptr,
 	return NULL;
 }
 
-static int process_sdp(struct sk_buff *skb, unsigned int dataoff,
+static int process_sdp(struct sk_buff *skb, unsigned int protoff,
+		       unsigned int dataoff,
 		       const char **dptr, unsigned int *datalen,
 		       unsigned int cseq)
 {
@@ -1098,7 +1105,8 @@ static int process_sdp(struct sk_buff *skb, unsigned int dataoff,
 		else
 			return NF_DROP;
 
-		ret = set_expected_rtp_rtcp(skb, dataoff, dptr, datalen,
+		ret = set_expected_rtp_rtcp(skb, protoff, dataoff,
+					    dptr, datalen,
 					    &rtp_addr, htons(port), t->class,
 					    mediaoff, medialen);
 		if (ret != NF_ACCEPT)
@@ -1107,7 +1115,8 @@ static int process_sdp(struct sk_buff *skb, unsigned int dataoff,
 		/* Update media connection address if present */
 		if (maddr_len && nf_nat_sdp_addr &&
 		    nf_ct_l3num(ct) == NFPROTO_IPV4 && ct->status & IPS_NAT_MASK) {
-			ret = nf_nat_sdp_addr(skb, dataoff, dptr, datalen,
+			ret = nf_nat_sdp_addr(skb, protoff, dataoff,
+					      dptr, datalen,
 					      mediaoff, c_hdr, SDP_HDR_MEDIA,
 					      &rtp_addr);
 			if (ret != NF_ACCEPT)
@@ -1120,12 +1129,13 @@ static int process_sdp(struct sk_buff *skb, unsigned int dataoff,
 	nf_nat_sdp_session = rcu_dereference(nf_nat_sdp_session_hook);
 	if (nf_nat_sdp_session && nf_ct_l3num(ct) == NFPROTO_IPV4 &&
 	    ct->status & IPS_NAT_MASK)
-		ret = nf_nat_sdp_session(skb, dataoff, dptr, datalen, sdpoff,
-					 &rtp_addr);
+		ret = nf_nat_sdp_session(skb, protoff, dataoff,
+					 dptr, datalen, sdpoff, &rtp_addr);
 
 	return ret;
 }
-static int process_invite_response(struct sk_buff *skb, unsigned int dataoff,
+static int process_invite_response(struct sk_buff *skb, unsigned int protoff,
+				   unsigned int dataoff,
 				   const char **dptr, unsigned int *datalen,
 				   unsigned int cseq, unsigned int code)
 {
@@ -1135,13 +1145,14 @@ static int process_invite_response(struct sk_buff *skb, unsigned int dataoff,
 
 	if ((code >= 100 && code <= 199) ||
 	    (code >= 200 && code <= 299))
-		return process_sdp(skb, dataoff, dptr, datalen, cseq);
+		return process_sdp(skb, protoff, dataoff, dptr, datalen, cseq);
 	else if (ct_sip_info->invite_cseq == cseq)
 		flush_expectations(ct, true);
 	return NF_ACCEPT;
 }
 
-static int process_update_response(struct sk_buff *skb, unsigned int dataoff,
+static int process_update_response(struct sk_buff *skb, unsigned int protoff,
+				   unsigned int dataoff,
 				   const char **dptr, unsigned int *datalen,
 				   unsigned int cseq, unsigned int code)
 {
@@ -1151,13 +1162,14 @@ static int process_update_response(struct sk_buff *skb, unsigned int dataoff,
 
 	if ((code >= 100 && code <= 199) ||
 	    (code >= 200 && code <= 299))
-		return process_sdp(skb, dataoff, dptr, datalen, cseq);
+		return process_sdp(skb, protoff, dataoff, dptr, datalen, cseq);
 	else if (ct_sip_info->invite_cseq == cseq)
 		flush_expectations(ct, true);
 	return NF_ACCEPT;
 }
 
-static int process_prack_response(struct sk_buff *skb, unsigned int dataoff,
+static int process_prack_response(struct sk_buff *skb, unsigned int protoff,
+				  unsigned int dataoff,
 				  const char **dptr, unsigned int *datalen,
 				  unsigned int cseq, unsigned int code)
 {
@@ -1167,13 +1179,14 @@ static int process_prack_response(struct sk_buff *skb, unsigned int dataoff,
 
 	if ((code >= 100 && code <= 199) ||
 	    (code >= 200 && code <= 299))
-		return process_sdp(skb, dataoff, dptr, datalen, cseq);
+		return process_sdp(skb, protoff, dataoff, dptr, datalen, cseq);
 	else if (ct_sip_info->invite_cseq == cseq)
 		flush_expectations(ct, true);
 	return NF_ACCEPT;
 }
 
-static int process_invite_request(struct sk_buff *skb, unsigned int dataoff,
+static int process_invite_request(struct sk_buff *skb, unsigned int protoff,
+				  unsigned int dataoff,
 				  const char **dptr, unsigned int *datalen,
 				  unsigned int cseq)
 {
@@ -1183,13 +1196,14 @@ static int process_invite_request(struct sk_buff *skb, unsigned int dataoff,
 	unsigned int ret;
 
 	flush_expectations(ct, true);
-	ret = process_sdp(skb, dataoff, dptr, datalen, cseq);
+	ret = process_sdp(skb, protoff, dataoff, dptr, datalen, cseq);
 	if (ret == NF_ACCEPT)
 		ct_sip_info->invite_cseq = cseq;
 	return ret;
 }
 
-static int process_bye_request(struct sk_buff *skb, unsigned int dataoff,
+static int process_bye_request(struct sk_buff *skb, unsigned int protoff,
+			       unsigned int dataoff,
 			       const char **dptr, unsigned int *datalen,
 			       unsigned int cseq)
 {
@@ -1204,7 +1218,8 @@ static int process_bye_request(struct sk_buff *skb, unsigned int dataoff,
  * signalling connections. The expectation is marked inactive and is activated
  * when receiving a response indicating success from the registrar.
  */
-static int process_register_request(struct sk_buff *skb, unsigned int dataoff,
+static int process_register_request(struct sk_buff *skb, unsigned int protoff,
+				    unsigned int dataoff,
 				    const char **dptr, unsigned int *datalen,
 				    unsigned int cseq)
 {
@@ -1280,8 +1295,8 @@ static int process_register_request(struct sk_buff *skb, unsigned int dataoff,
 	nf_nat_sip_expect = rcu_dereference(nf_nat_sip_expect_hook);
 	if (nf_nat_sip_expect && nf_ct_l3num(ct) == NFPROTO_IPV4 &&
 	    ct->status & IPS_NAT_MASK)
-		ret = nf_nat_sip_expect(skb, dataoff, dptr, datalen, exp,
-					matchoff, matchlen);
+		ret = nf_nat_sip_expect(skb, protoff, dataoff, dptr, datalen,
+					exp, matchoff, matchlen);
 	else {
 		if (nf_ct_expect_related(exp) != 0)
 			ret = NF_DROP;
@@ -1296,7 +1311,8 @@ store_cseq:
 	return ret;
 }
 
-static int process_register_response(struct sk_buff *skb, unsigned int dataoff,
+static int process_register_response(struct sk_buff *skb, unsigned int protoff,
+				     unsigned int dataoff,
 				     const char **dptr, unsigned int *datalen,
 				     unsigned int cseq, unsigned int code)
 {
@@ -1378,7 +1394,8 @@ static const struct sip_handler sip_handlers[] = {
 	SIP_HANDLER("REGISTER", process_register_request, process_register_response),
 };
 
-static int process_sip_response(struct sk_buff *skb, unsigned int dataoff,
+static int process_sip_response(struct sk_buff *skb, unsigned int protoff,
+				unsigned int dataoff,
 				const char **dptr, unsigned int *datalen)
 {
 	enum ip_conntrack_info ctinfo;
@@ -1409,13 +1426,14 @@ static int process_sip_response(struct sk_buff *skb, unsigned int dataoff,
 		if (*datalen < matchend + handler->len ||
 		    strnicmp(*dptr + matchend, handler->method, handler->len))
 			continue;
-		return handler->response(skb, dataoff, dptr, datalen,
+		return handler->response(skb, protoff, dataoff, dptr, datalen,
 					 cseq, code);
 	}
 	return NF_ACCEPT;
 }
 
-static int process_sip_request(struct sk_buff *skb, unsigned int dataoff,
+static int process_sip_request(struct sk_buff *skb, unsigned int protoff,
+			       unsigned int dataoff,
 			       const char **dptr, unsigned int *datalen)
 {
 	enum ip_conntrack_info ctinfo;
@@ -1440,27 +1458,29 @@ static int process_sip_request(struct sk_buff *skb, unsigned int dataoff,
 		if (!cseq)
 			return NF_DROP;
 
-		return handler->request(skb, dataoff, dptr, datalen, cseq);
+		return handler->request(skb, protoff, dataoff, dptr, datalen,
+					cseq);
 	}
 	return NF_ACCEPT;
 }
 
 static int process_sip_msg(struct sk_buff *skb, struct nf_conn *ct,
-			   unsigned int dataoff, const char **dptr,
-			   unsigned int *datalen)
+			   unsigned int protoff, unsigned int dataoff,
+			   const char **dptr, unsigned int *datalen)
 {
 	typeof(nf_nat_sip_hook) nf_nat_sip;
 	int ret;
 
 	if (strnicmp(*dptr, "SIP/2.0 ", strlen("SIP/2.0 ")) != 0)
-		ret = process_sip_request(skb, dataoff, dptr, datalen);
+		ret = process_sip_request(skb, protoff, dataoff, dptr, datalen);
 	else
-		ret = process_sip_response(skb, dataoff, dptr, datalen);
+		ret = process_sip_response(skb, protoff, dataoff, dptr, datalen);
 
 	if (ret == NF_ACCEPT && nf_ct_l3num(ct) == NFPROTO_IPV4 &&
 	    ct->status & IPS_NAT_MASK) {
 		nf_nat_sip = rcu_dereference(nf_nat_sip_hook);
-		if (nf_nat_sip && !nf_nat_sip(skb, dataoff, dptr, datalen))
+		if (nf_nat_sip && !nf_nat_sip(skb, protoff, dataoff,
+					      dptr, datalen))
 			ret = NF_DROP;
 	}
 
@@ -1528,7 +1548,8 @@ static int sip_help_tcp(struct sk_buff *skb, unsigned int protoff,
 		if (msglen > datalen)
 			return NF_DROP;
 
-		ret = process_sip_msg(skb, ct, dataoff, &dptr, &msglen);
+		ret = process_sip_msg(skb, ct, protoff, dataoff,
+				      &dptr, &msglen);
 		if (ret != NF_ACCEPT)
 			break;
 		diff     = msglen - origlen;
@@ -1570,7 +1591,7 @@ static int sip_help_udp(struct sk_buff *skb, unsigned int protoff,
 	if (datalen < strlen("SIP/2.0 200"))
 		return NF_ACCEPT;
 
-	return process_sip_msg(skb, ct, dataoff, &dptr, &datalen);
+	return process_sip_msg(skb, ct, protoff, dataoff, &dptr, &datalen);
 }
 
 static struct nf_conntrack_helper sip[MAX_PORTS][4] __read_mostly;
-- 
1.7.1
