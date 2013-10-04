From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 32/33] netfilter: nf_ct_sip: consolidate NAT hook functions
Date: Fri,  4 Oct 2013 10:33:17 +0200
Message-ID: <1380875598-5250-33-git-send-email-pablo@netfilter.org>
References: <1380875598-5250-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1380875598-5250-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "holger@eitzenberger.org" <holger@eitzenberger.org>

There are currently seven different NAT hooks used in both
nf_conntrack_sip and nf_nat_sip, each of the hooks is exported in
nf_conntrack_sip, then set from the nf_nat_sip NAT helper.

And because each of them is exported there is quite some overhead
introduced due of this.

By introducing nf_nat_sip_hooks I am able to reduce both text/data
somewhat.  For nf_conntrack_sip e. g. I get

        text             data              bss              dec
old    15243             5256               32            20531
new    15010             5192               32            20234

Signed-off-by: Holger Eitzenberger <holger@eitzenberger.org>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netfilter/nf_conntrack_sip.h |  107 ++++++++++++-----------
 net/netfilter/nf_conntrack_sip.c           |  127 ++++++++--------------------
 net/netfilter/nf_nat_sip.c                 |   35 +++-----
 3 files changed, 107 insertions(+), 162 deletions(-)

diff --git a/include/linux/netfilter/nf_conntrack_sip.h b/include/linux/netfilter/nf_conntrack_sip.h
index ba7f571..4cb7155 100644
--- a/include/linux/netfilter/nf_conntrack_sip.h
+++ b/include/linux/netfilter/nf_conntrack_sip.h
@@ -107,55 +107,64 @@ enum sdp_header_types {
 	SDP_HDR_MEDIA,
 };
 
-extern unsigned int (*nf_nat_sip_hook)(struct sk_buff *skb,
-				       unsigned int protoff,
-				       unsigned int dataoff,
-				       const char **dptr,
-				       unsigned int *datalen);
-extern void (*nf_nat_sip_seq_adjust_hook)(struct sk_buff *skb,
-					  unsigned int protoff, s16 off);
-extern unsigned int (*nf_nat_sip_expect_hook)(struct sk_buff *skb,
-					      unsigned int protoff,
-					      unsigned int dataoff,
-					      const char **dptr,
-					      unsigned int *datalen,
-					      struct nf_conntrack_expect *exp,
-					      unsigned int matchoff,
-					      unsigned int matchlen);
-extern unsigned int (*nf_nat_sdp_addr_hook)(struct sk_buff *skb,
-					    unsigned int protoff,
-					    unsigned int dataoff,
-					    const char **dptr,
-					    unsigned int *datalen,
-					    unsigned int sdpoff,
-					    enum sdp_header_types type,
-					    enum sdp_header_types term,
-					    const union nf_inet_addr *addr);
-extern unsigned int (*nf_nat_sdp_port_hook)(struct sk_buff *skb,
-					    unsigned int protoff,
-					    unsigned int dataoff,
-					    const char **dptr,
-					    unsigned int *datalen,
-					    unsigned int matchoff,
-					    unsigned int matchlen,
-					    u_int16_t port);
-extern unsigned int (*nf_nat_sdp_session_hook)(struct sk_buff *skb,
-					       unsigned int protoff,
-					       unsigned int dataoff,
-					       const char **dptr,
-					       unsigned int *datalen,
-					       unsigned int sdpoff,
-					       const union nf_inet_addr *addr);
-extern unsigned int (*nf_nat_sdp_media_hook)(struct sk_buff *skb,
-					     unsigned int protoff,
-					     unsigned int dataoff,
-					     const char **dptr,
-					     unsigned int *datalen,
-					     struct nf_conntrack_expect *rtp_exp,
-					     struct nf_conntrack_expect *rtcp_exp,
-					     unsigned int mediaoff,
-					     unsigned int medialen,
-					     union nf_inet_addr *rtp_addr);
+struct nf_nat_sip_hooks {
+	unsigned int (*msg)(struct sk_buff *skb,
+			    unsigned int protoff,
+			    unsigned int dataoff,
+			    const char **dptr,
+			    unsigned int *datalen);
+
+	void (*seq_adjust)(struct sk_buff *skb,
+			   unsigned int protoff, s16 off);
+
+	unsigned int (*expect)(struct sk_buff *skb,
+			       unsigned int protoff,
+			       unsigned int dataoff,
+			       const char **dptr,
+			       unsigned int *datalen,
+			       struct nf_conntrack_expect *exp,
+			       unsigned int matchoff,
+			       unsigned int matchlen);
+
+	unsigned int (*sdp_addr)(struct sk_buff *skb,
+				 unsigned int protoff,
+				 unsigned int dataoff,
+				 const char **dptr,
+				 unsigned int *datalen,
+				 unsigned int sdpoff,
+				 enum sdp_header_types type,
+				 enum sdp_header_types term,
+				 const union nf_inet_addr *addr);
+
+	unsigned int (*sdp_port)(struct sk_buff *skb,
+				 unsigned int protoff,
+				 unsigned int dataoff,
+				 const char **dptr,
+				 unsigned int *datalen,
+				 unsigned int matchoff,
+				 unsigned int matchlen,
+				 u_int16_t port);
+
+	unsigned int (*sdp_session)(struct sk_buff *skb,
+				    unsigned int protoff,
+				    unsigned int dataoff,
+				    const char **dptr,
+				    unsigned int *datalen,
+				    unsigned int sdpoff,
+				    const union nf_inet_addr *addr);
+
+	unsigned int (*sdp_media)(struct sk_buff *skb,
+				  unsigned int protoff,
+				  unsigned int dataoff,
+				  const char **dptr,
+				  unsigned int *datalen,
+				  struct nf_conntrack_expect *rtp_exp,
+				  struct nf_conntrack_expect *rtcp_exp,
+				  unsigned int mediaoff,
+				  unsigned int medialen,
+				  union nf_inet_addr *rtp_addr);
+};
+extern const struct nf_nat_sip_hooks *nf_nat_sip_hooks;
 
 extern int ct_sip_parse_request(const struct nf_conn *ct,
 				const char *dptr, unsigned int datalen,
diff --git a/net/netfilter/nf_conntrack_sip.c b/net/netfilter/nf_conntrack_sip.c
index 5ed8c44..466410e 100644
--- a/net/netfilter/nf_conntrack_sip.c
+++ b/net/netfilter/nf_conntrack_sip.c
@@ -52,66 +52,8 @@ module_param(sip_direct_media, int, 0600);
 MODULE_PARM_DESC(sip_direct_media, "Expect Media streams between signalling "
 				   "endpoints only (default 1)");
 
-unsigned int (*nf_nat_sip_hook)(struct sk_buff *skb, unsigned int protoff,
-				unsigned int dataoff, const char **dptr,
-				unsigned int *datalen) __read_mostly;
-EXPORT_SYMBOL_GPL(nf_nat_sip_hook);
-
-void (*nf_nat_sip_seq_adjust_hook)(struct sk_buff *skb, unsigned int protoff,
-				   s16 off) __read_mostly;
-EXPORT_SYMBOL_GPL(nf_nat_sip_seq_adjust_hook);
-
-unsigned int (*nf_nat_sip_expect_hook)(struct sk_buff *skb,
-				       unsigned int protoff,
-				       unsigned int dataoff,
-				       const char **dptr,
-				       unsigned int *datalen,
-				       struct nf_conntrack_expect *exp,
-				       unsigned int matchoff,
-				       unsigned int matchlen) __read_mostly;
-EXPORT_SYMBOL_GPL(nf_nat_sip_expect_hook);
-
-unsigned int (*nf_nat_sdp_addr_hook)(struct sk_buff *skb, unsigned int protoff,
-				     unsigned int dataoff,
-				     const char **dptr,
-				     unsigned int *datalen,
-				     unsigned int sdpoff,
-				     enum sdp_header_types type,
-				     enum sdp_header_types term,
-				     const union nf_inet_addr *addr)
-				     __read_mostly;
-EXPORT_SYMBOL_GPL(nf_nat_sdp_addr_hook);
-
-unsigned int (*nf_nat_sdp_port_hook)(struct sk_buff *skb, unsigned int protoff,
-				     unsigned int dataoff,
-				     const char **dptr,
-				     unsigned int *datalen,
-				     unsigned int matchoff,
-				     unsigned int matchlen,
-				     u_int16_t port) __read_mostly;
-EXPORT_SYMBOL_GPL(nf_nat_sdp_port_hook);
-
-unsigned int (*nf_nat_sdp_session_hook)(struct sk_buff *skb,
-					unsigned int protoff,
-					unsigned int dataoff,
-					const char **dptr,
-					unsigned int *datalen,
-					unsigned int sdpoff,
-					const union nf_inet_addr *addr)
-					__read_mostly;
-EXPORT_SYMBOL_GPL(nf_nat_sdp_session_hook);
-
-unsigned int (*nf_nat_sdp_media_hook)(struct sk_buff *skb, unsigned int protoff,
-				      unsigned int dataoff,
-				      const char **dptr,
-				      unsigned int *datalen,
-				      struct nf_conntrack_expect *rtp_exp,
-				      struct nf_conntrack_expect *rtcp_exp,
-				      unsigned int mediaoff,
-				      unsigned int medialen,
-				      union nf_inet_addr *rtp_addr)
-				      __read_mostly;
-EXPORT_SYMBOL_GPL(nf_nat_sdp_media_hook);
+const struct nf_nat_sip_hooks *nf_nat_sip_hooks;
+EXPORT_SYMBOL_GPL(nf_nat_sip_hooks);
 
 static int string_len(const struct nf_conn *ct, const char *dptr,
 		      const char *limit, int *shift)
@@ -914,8 +856,7 @@ static int set_expected_rtp_rtcp(struct sk_buff *skb, unsigned int protoff,
 	int direct_rtp = 0, skip_expect = 0, ret = NF_DROP;
 	u_int16_t base_port;
 	__be16 rtp_port, rtcp_port;
-	typeof(nf_nat_sdp_port_hook) nf_nat_sdp_port;
-	typeof(nf_nat_sdp_media_hook) nf_nat_sdp_media;
+	const struct nf_nat_sip_hooks *hooks;
 
 	saddr = NULL;
 	if (sip_direct_media) {
@@ -972,9 +913,9 @@ static int set_expected_rtp_rtcp(struct sk_buff *skb, unsigned int protoff,
 	rtcp_port = htons(base_port + 1);
 
 	if (direct_rtp) {
-		nf_nat_sdp_port = rcu_dereference(nf_nat_sdp_port_hook);
-		if (nf_nat_sdp_port &&
-		    !nf_nat_sdp_port(skb, protoff, dataoff, dptr, datalen,
+		hooks = rcu_dereference(nf_nat_sip_hooks);
+		if (hooks &&
+		    !hooks->sdp_port(skb, protoff, dataoff, dptr, datalen,
 				     mediaoff, medialen, ntohs(rtp_port)))
 			goto err1;
 	}
@@ -996,10 +937,10 @@ static int set_expected_rtp_rtcp(struct sk_buff *skb, unsigned int protoff,
 	nf_ct_expect_init(rtcp_exp, class, nf_ct_l3num(ct), saddr, daddr,
 			  IPPROTO_UDP, NULL, &rtcp_port);
 
-	nf_nat_sdp_media = rcu_dereference(nf_nat_sdp_media_hook);
-	if (nf_nat_sdp_media && ct->status & IPS_NAT_MASK && !direct_rtp)
-		ret = nf_nat_sdp_media(skb, protoff, dataoff, dptr, datalen,
-				       rtp_exp, rtcp_exp,
+	hooks = rcu_dereference(nf_nat_sip_hooks);
+	if (hooks && ct->status & IPS_NAT_MASK && !direct_rtp)
+		ret = hooks->sdp_media(skb, protoff, dataoff, dptr,
+				       datalen, rtp_exp, rtcp_exp,
 				       mediaoff, medialen, daddr);
 	else {
 		if (nf_ct_expect_related(rtp_exp) == 0) {
@@ -1053,13 +994,12 @@ static int process_sdp(struct sk_buff *skb, unsigned int protoff,
 	unsigned int caddr_len, maddr_len;
 	unsigned int i;
 	union nf_inet_addr caddr, maddr, rtp_addr;
+	const struct nf_nat_sip_hooks *hooks;
 	unsigned int port;
 	const struct sdp_media_type *t;
 	int ret = NF_ACCEPT;
-	typeof(nf_nat_sdp_addr_hook) nf_nat_sdp_addr;
-	typeof(nf_nat_sdp_session_hook) nf_nat_sdp_session;
 
-	nf_nat_sdp_addr = rcu_dereference(nf_nat_sdp_addr_hook);
+	hooks = rcu_dereference(nf_nat_sip_hooks);
 
 	/* Find beginning of session description */
 	if (ct_sip_get_sdp_header(ct, *dptr, 0, *datalen,
@@ -1127,10 +1067,11 @@ static int process_sdp(struct sk_buff *skb, unsigned int protoff,
 		}
 
 		/* Update media connection address if present */
-		if (maddr_len && nf_nat_sdp_addr && ct->status & IPS_NAT_MASK) {
-			ret = nf_nat_sdp_addr(skb, protoff, dataoff,
+		if (maddr_len && hooks && ct->status & IPS_NAT_MASK) {
+			ret = hooks->sdp_addr(skb, protoff, dataoff,
 					      dptr, datalen, mediaoff,
-					      SDP_HDR_CONNECTION, SDP_HDR_MEDIA,
+					      SDP_HDR_CONNECTION,
+					      SDP_HDR_MEDIA,
 					      &rtp_addr);
 			if (ret != NF_ACCEPT) {
 				nf_ct_helper_log(skb, ct, "cannot mangle SDP");
@@ -1141,10 +1082,11 @@ static int process_sdp(struct sk_buff *skb, unsigned int protoff,
 	}
 
 	/* Update session connection and owner addresses */
-	nf_nat_sdp_session = rcu_dereference(nf_nat_sdp_session_hook);
-	if (nf_nat_sdp_session && ct->status & IPS_NAT_MASK)
-		ret = nf_nat_sdp_session(skb, protoff, dataoff,
-					 dptr, datalen, sdpoff, &rtp_addr);
+	hooks = rcu_dereference(nf_nat_sip_hooks);
+	if (hooks && ct->status & IPS_NAT_MASK)
+		ret = hooks->sdp_session(skb, protoff, dataoff,
+					 dptr, datalen, sdpoff,
+					 &rtp_addr);
 
 	return ret;
 }
@@ -1244,11 +1186,11 @@ static int process_register_request(struct sk_buff *skb, unsigned int protoff,
 	unsigned int matchoff, matchlen;
 	struct nf_conntrack_expect *exp;
 	union nf_inet_addr *saddr, daddr;
+	const struct nf_nat_sip_hooks *hooks;
 	__be16 port;
 	u8 proto;
 	unsigned int expires = 0;
 	int ret;
-	typeof(nf_nat_sip_expect_hook) nf_nat_sip_expect;
 
 	/* Expected connections can not register again. */
 	if (ct->status & IPS_EXPECTED)
@@ -1311,10 +1253,10 @@ static int process_register_request(struct sk_buff *skb, unsigned int protoff,
 	exp->helper = nfct_help(ct)->helper;
 	exp->flags = NF_CT_EXPECT_PERMANENT | NF_CT_EXPECT_INACTIVE;
 
-	nf_nat_sip_expect = rcu_dereference(nf_nat_sip_expect_hook);
-	if (nf_nat_sip_expect && ct->status & IPS_NAT_MASK)
-		ret = nf_nat_sip_expect(skb, protoff, dataoff, dptr, datalen,
-					exp, matchoff, matchlen);
+	hooks = rcu_dereference(nf_nat_sip_hooks);
+	if (hooks && ct->status & IPS_NAT_MASK)
+		ret = hooks->expect(skb, protoff, dataoff, dptr, datalen,
+				    exp, matchoff, matchlen);
 	else {
 		if (nf_ct_expect_related(exp) != 0) {
 			nf_ct_helper_log(skb, ct, "cannot add expectation");
@@ -1517,7 +1459,7 @@ static int process_sip_msg(struct sk_buff *skb, struct nf_conn *ct,
 			   unsigned int protoff, unsigned int dataoff,
 			   const char **dptr, unsigned int *datalen)
 {
-	typeof(nf_nat_sip_hook) nf_nat_sip;
+	const struct nf_nat_sip_hooks *hooks;
 	int ret;
 
 	if (strnicmp(*dptr, "SIP/2.0 ", strlen("SIP/2.0 ")) != 0)
@@ -1526,9 +1468,9 @@ static int process_sip_msg(struct sk_buff *skb, struct nf_conn *ct,
 		ret = process_sip_response(skb, protoff, dataoff, dptr, datalen);
 
 	if (ret == NF_ACCEPT && ct->status & IPS_NAT_MASK) {
-		nf_nat_sip = rcu_dereference(nf_nat_sip_hook);
-		if (nf_nat_sip && !nf_nat_sip(skb, protoff, dataoff,
-					      dptr, datalen)) {
+		hooks = rcu_dereference(nf_nat_sip_hooks);
+		if (hooks && !hooks->msg(skb, protoff, dataoff,
+					 dptr, datalen)) {
 			nf_ct_helper_log(skb, ct, "cannot NAT SIP message");
 			ret = NF_DROP;
 		}
@@ -1548,7 +1490,6 @@ static int sip_help_tcp(struct sk_buff *skb, unsigned int protoff,
 	s16 diff, tdiff = 0;
 	int ret = NF_ACCEPT;
 	bool term;
-	typeof(nf_nat_sip_seq_adjust_hook) nf_nat_sip_seq_adjust;
 
 	if (ctinfo != IP_CT_ESTABLISHED &&
 	    ctinfo != IP_CT_ESTABLISHED_REPLY)
@@ -1612,9 +1553,11 @@ static int sip_help_tcp(struct sk_buff *skb, unsigned int protoff,
 	}
 
 	if (ret == NF_ACCEPT && ct->status & IPS_NAT_MASK) {
-		nf_nat_sip_seq_adjust = rcu_dereference(nf_nat_sip_seq_adjust_hook);
-		if (nf_nat_sip_seq_adjust)
-			nf_nat_sip_seq_adjust(skb, protoff, tdiff);
+		const struct nf_nat_sip_hooks *hooks;
+
+		hooks = rcu_dereference(nf_nat_sip_hooks);
+		if (hooks)
+			hooks->seq_adjust(skb, protoff, tdiff);
 	}
 
 	return ret;
diff --git a/net/netfilter/nf_nat_sip.c b/net/netfilter/nf_nat_sip.c
index f979040..b4d691d 100644
--- a/net/netfilter/nf_nat_sip.c
+++ b/net/netfilter/nf_nat_sip.c
@@ -625,33 +625,26 @@ static struct nf_ct_helper_expectfn sip_nat = {
 
 static void __exit nf_nat_sip_fini(void)
 {
-	RCU_INIT_POINTER(nf_nat_sip_hook, NULL);
-	RCU_INIT_POINTER(nf_nat_sip_seq_adjust_hook, NULL);
-	RCU_INIT_POINTER(nf_nat_sip_expect_hook, NULL);
-	RCU_INIT_POINTER(nf_nat_sdp_addr_hook, NULL);
-	RCU_INIT_POINTER(nf_nat_sdp_port_hook, NULL);
-	RCU_INIT_POINTER(nf_nat_sdp_session_hook, NULL);
-	RCU_INIT_POINTER(nf_nat_sdp_media_hook, NULL);
+	RCU_INIT_POINTER(nf_nat_sip_hooks, NULL);
+
 	nf_ct_helper_expectfn_unregister(&sip_nat);
 	synchronize_rcu();
 }
 
+static const struct nf_nat_sip_hooks sip_hooks = {
+	.msg		= nf_nat_sip,
+	.seq_adjust	= nf_nat_sip_seq_adjust,
+	.expect		= nf_nat_sip_expect,
+	.sdp_addr	= nf_nat_sdp_addr,
+	.sdp_port	= nf_nat_sdp_port,
+	.sdp_session	= nf_nat_sdp_session,
+	.sdp_media	= nf_nat_sdp_media,
+};
+
 static int __init nf_nat_sip_init(void)
 {
-	BUG_ON(nf_nat_sip_hook != NULL);
-	BUG_ON(nf_nat_sip_seq_adjust_hook != NULL);
-	BUG_ON(nf_nat_sip_expect_hook != NULL);
-	BUG_ON(nf_nat_sdp_addr_hook != NULL);
-	BUG_ON(nf_nat_sdp_port_hook != NULL);
-	BUG_ON(nf_nat_sdp_session_hook != NULL);
-	BUG_ON(nf_nat_sdp_media_hook != NULL);
-	RCU_INIT_POINTER(nf_nat_sip_hook, nf_nat_sip);
-	RCU_INIT_POINTER(nf_nat_sip_seq_adjust_hook, nf_nat_sip_seq_adjust);
-	RCU_INIT_POINTER(nf_nat_sip_expect_hook, nf_nat_sip_expect);
-	RCU_INIT_POINTER(nf_nat_sdp_addr_hook, nf_nat_sdp_addr);
-	RCU_INIT_POINTER(nf_nat_sdp_port_hook, nf_nat_sdp_port);
-	RCU_INIT_POINTER(nf_nat_sdp_session_hook, nf_nat_sdp_session);
-	RCU_INIT_POINTER(nf_nat_sdp_media_hook, nf_nat_sdp_media);
+	BUG_ON(nf_nat_sip_hooks != NULL);
+	RCU_INIT_POINTER(nf_nat_sip_hooks, &sip_hooks);
 	nf_ct_helper_expectfn_register(&sip_nat);
 	return 0;
 }
-- 
1.7.10.4

