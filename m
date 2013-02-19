From: pablo@netfilter.org
Subject: [PATCH 7/7] netfilter: nf_ct_helper: better logging for dropped packets
Date: Tue, 19 Feb 2013 01:10:51 +0100
Message-ID: <1361232651-5626-8-git-send-email-pablo@netfilter.org>
References: <1361232651-5626-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netfilter-devel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from slan-550-85.anhosting.com ([209.236.71.68]:34480 "EHLO
	slan-550-85.anhosting.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757844Ab3BSAL0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Feb 2013 19:11:26 -0500
In-Reply-To: <1361232651-5626-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>

Connection tracking helpers have to drop packets under exceptional
situations. Currently, the user gets the following logging message
in case that happens:

	nf_ct_%s: dropping packet ...

However, depending on the helper, there are different reasons why a
packet can be dropped.

This patch modifies the existing code to provide more specific
error message in the scope of each helper to help users to debug
the reason why the packet has been dropped, ie:

	nf_ct_%s: dropping packet: reason ...

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_conntrack_helper.h    |    3 +
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c |   10 +--
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c |    8 +--
 net/netfilter/nf_conntrack_amanda.c            |    5 +-
 net/netfilter/nf_conntrack_ftp.c               |   10 +--
 net/netfilter/nf_conntrack_h323_main.c         |    6 +-
 net/netfilter/nf_conntrack_helper.c            |   18 ++++++
 net/netfilter/nf_conntrack_irc.c               |    7 ++-
 net/netfilter/nf_conntrack_sane.c              |    5 +-
 net/netfilter/nf_conntrack_sip.c               |   80 ++++++++++++++++++------
 net/netfilter/nf_conntrack_tftp.c              |    8 ++-
 net/netfilter/nf_nat_amanda.c                  |    8 ++-
 net/netfilter/nf_nat_ftp.c                     |    5 +-
 net/netfilter/nf_nat_irc.c                     |    8 ++-
 net/netfilter/nf_nat_sip.c                     |   49 +++++++++++----
 net/netfilter/nf_nat_tftp.c                    |    4 +-
 16 files changed, 169 insertions(+), 65 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack_helper.h b/include/net/netfilter/nf_conntrack_helper.h
index ce27edf..1803cdf 100644
--- a/include/net/netfilter/nf_conntrack_helper.h
+++ b/include/net/netfilter/nf_conntrack_helper.h
@@ -100,6 +100,9 @@ struct nf_ct_helper_expectfn {
 	void (*expectfn)(struct nf_conn *ct, struct nf_conntrack_expect *exp);
 };
 
+extern void nf_ct_helper_log(struct sk_buff *skb, const struct nf_conn *,
+			     const char *fmt, ...);
+
 void nf_ct_helper_expectfn_register(struct nf_ct_helper_expectfn *n);
 void nf_ct_helper_expectfn_unregister(struct nf_ct_helper_expectfn *n);
 struct nf_ct_helper_expectfn *
diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
index 48990ad..2820aa1 100644
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
@@ -100,7 +100,6 @@ static unsigned int ipv4_helper(unsigned int hooknum,
 	enum ip_conntrack_info ctinfo;
 	const struct nf_conn_help *help;
 	const struct nf_conntrack_helper *helper;
-	unsigned int ret;
 
 	/* This is where we call the helper: as the packet goes out. */
 	ct = nf_ct_get(skb, &ctinfo);
@@ -116,13 +115,8 @@ static unsigned int ipv4_helper(unsigned int hooknum,
 	if (!helper)
 		return NF_ACCEPT;
 
-	ret = helper->help(skb, skb_network_offset(skb) + ip_hdrlen(skb),
-			   ct, ctinfo);
-	if (ret != NF_ACCEPT && (ret & NF_VERDICT_MASK) != NF_QUEUE) {
-		nf_log_packet(NFPROTO_IPV4, hooknum, skb, in, out, NULL,
-			      "nf_ct_%s: dropping packet", helper->name);
-	}
-	return ret;
+	return helper->help(skb, skb_network_offset(skb) + ip_hdrlen(skb),
+			    ct, ctinfo);
 }
 
 static unsigned int ipv4_confirm(unsigned int hooknum,
diff --git a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
index 8a45bb2..2b6c226 100644
--- a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
@@ -104,7 +104,6 @@ static unsigned int ipv6_helper(unsigned int hooknum,
 	const struct nf_conn_help *help;
 	const struct nf_conntrack_helper *helper;
 	enum ip_conntrack_info ctinfo;
-	unsigned int ret;
 	__be16 frag_off;
 	int protoff;
 	u8 nexthdr;
@@ -130,12 +129,7 @@ static unsigned int ipv6_helper(unsigned int hooknum,
 		return NF_ACCEPT;
 	}
 
-	ret = helper->help(skb, protoff, ct, ctinfo);
-	if (ret != NF_ACCEPT && (ret & NF_VERDICT_MASK) != NF_QUEUE) {
-		nf_log_packet(NFPROTO_IPV6, hooknum, skb, in, out, NULL,
-			      "nf_ct_%s: dropping packet", helper->name);
-	}
-	return ret;
+	return helper->help(skb, protoff, ct, ctinfo);
 }
 
 static unsigned int ipv6_confirm(unsigned int hooknum,
diff --git a/net/netfilter/nf_conntrack_amanda.c b/net/netfilter/nf_conntrack_amanda.c
index c514fe6..dbdaa11 100644
--- a/net/netfilter/nf_conntrack_amanda.c
+++ b/net/netfilter/nf_conntrack_amanda.c
@@ -145,6 +145,7 @@ static int amanda_help(struct sk_buff *skb,
 
 		exp = nf_ct_expect_alloc(ct);
 		if (exp == NULL) {
+			nf_ct_helper_log(skb, ct, "cannot alloc expectation");
 			ret = NF_DROP;
 			goto out;
 		}
@@ -158,8 +159,10 @@ static int amanda_help(struct sk_buff *skb,
 		if (nf_nat_amanda && ct->status & IPS_NAT_MASK)
 			ret = nf_nat_amanda(skb, ctinfo, protoff,
 					    off - dataoff, len, exp);
-		else if (nf_ct_expect_related(exp) != 0)
+		else if (nf_ct_expect_related(exp) != 0) {
+			nf_ct_helper_log(skb, ct, "cannot add expectation");
 			ret = NF_DROP;
+		}
 		nf_ct_expect_put(exp);
 	}
 
diff --git a/net/netfilter/nf_conntrack_ftp.c b/net/netfilter/nf_conntrack_ftp.c
index 1ce3bef..62fb8fa 100644
--- a/net/netfilter/nf_conntrack_ftp.c
+++ b/net/netfilter/nf_conntrack_ftp.c
@@ -435,8 +435,8 @@ skip_nl_seq:
 		   connection tracking, not packet filtering.
 		   However, it is necessary for accurate tracking in
 		   this case. */
-		pr_debug("conntrack_ftp: partial %s %u+%u\n",
-			 search[dir][i].pattern,  ntohl(th->seq), datalen);
+		nf_ct_helper_log(skb, ct, "partial matching of `%s'",
+			         search[dir][i].pattern);
 		ret = NF_DROP;
 		goto out;
 	} else if (found == 0) { /* No match */
@@ -450,6 +450,7 @@ skip_nl_seq:
 
 	exp = nf_ct_expect_alloc(ct);
 	if (exp == NULL) {
+		nf_ct_helper_log(skb, ct, "cannot alloc expectation");
 		ret = NF_DROP;
 		goto out;
 	}
@@ -500,9 +501,10 @@ skip_nl_seq:
 				 protoff, matchoff, matchlen, exp);
 	else {
 		/* Can't expect this?  Best to drop packet now. */
-		if (nf_ct_expect_related(exp) != 0)
+		if (nf_ct_expect_related(exp) != 0) {
+			nf_ct_helper_log(skb, ct, "cannot add expectation");
 			ret = NF_DROP;
-		else
+		} else
 			ret = NF_ACCEPT;
 	}
 
diff --git a/net/netfilter/nf_conntrack_h323_main.c b/net/netfilter/nf_conntrack_h323_main.c
index 962795e..7df7b36 100644
--- a/net/netfilter/nf_conntrack_h323_main.c
+++ b/net/netfilter/nf_conntrack_h323_main.c
@@ -623,7 +623,7 @@ static int h245_help(struct sk_buff *skb, unsigned int protoff,
 
       drop:
 	spin_unlock_bh(&nf_h323_lock);
-	net_info_ratelimited("nf_ct_h245: packet dropped\n");
+	nf_ct_helper_log(skb, ct, "cannot process H.245 message");
 	return NF_DROP;
 }
 
@@ -1197,7 +1197,7 @@ static int q931_help(struct sk_buff *skb, unsigned int protoff,
 
       drop:
 	spin_unlock_bh(&nf_h323_lock);
-	net_info_ratelimited("nf_ct_q931: packet dropped\n");
+	nf_ct_helper_log(skb, ct, "cannot process Q.931 message");
 	return NF_DROP;
 }
 
@@ -1795,7 +1795,7 @@ static int ras_help(struct sk_buff *skb, unsigned int protoff,
 
       drop:
 	spin_unlock_bh(&nf_h323_lock);
-	net_info_ratelimited("nf_ct_ras: packet dropped\n");
+	nf_ct_helper_log(skb, ct, "cannot process RAS message");
 	return NF_DROP;
 }
 
diff --git a/net/netfilter/nf_conntrack_helper.c b/net/netfilter/nf_conntrack_helper.c
index 2f380f7..2d77503 100644
--- a/net/netfilter/nf_conntrack_helper.c
+++ b/net/netfilter/nf_conntrack_helper.c
@@ -28,6 +28,7 @@
 #include <net/netfilter/nf_conntrack_helper.h>
 #include <net/netfilter/nf_conntrack_core.h>
 #include <net/netfilter/nf_conntrack_extend.h>
+#include <net/netfilter/nf_log.h>
 
 static DEFINE_MUTEX(nf_ct_helper_mutex);
 struct hlist_head *nf_ct_helper_hash __read_mostly;
@@ -332,6 +333,23 @@ nf_ct_helper_expectfn_find_by_symbol(const void *symbol)
 }
 EXPORT_SYMBOL_GPL(nf_ct_helper_expectfn_find_by_symbol);
 
+void nf_ct_helper_log(struct sk_buff *skb, const struct nf_conn *ct,
+		      const char *fmt, ...)
+{
+	const struct nf_conn_help *help;
+	const struct nf_conntrack_helper *helper;
+
+	/* Called from the helper function, this call never fails */
+	help = nfct_help(ct);
+
+	/* rcu_read_lock()ed by nf_hook_slow */
+	helper = rcu_dereference(help->helper);
+
+	nf_log_packet(nf_ct_l3num(ct), 0, skb, NULL, NULL, NULL,
+		      "nf_ct_%s: dropping packet: %s ", helper->name, fmt);
+}
+EXPORT_SYMBOL_GPL(nf_ct_helper_log);
+
 int nf_conntrack_helper_register(struct nf_conntrack_helper *me)
 {
 	int ret = 0;
diff --git a/net/netfilter/nf_conntrack_irc.c b/net/netfilter/nf_conntrack_irc.c
index 3b20aa7..e990792 100644
--- a/net/netfilter/nf_conntrack_irc.c
+++ b/net/netfilter/nf_conntrack_irc.c
@@ -194,6 +194,8 @@ static int help(struct sk_buff *skb, unsigned int protoff,
 
 			exp = nf_ct_expect_alloc(ct);
 			if (exp == NULL) {
+				nf_ct_helper_log(skb, ct, "cannot alloc "
+							  "expectation");
 				ret = NF_DROP;
 				goto out;
 			}
@@ -210,8 +212,11 @@ static int help(struct sk_buff *skb, unsigned int protoff,
 						 addr_beg_p - ib_ptr,
 						 addr_end_p - addr_beg_p,
 						 exp);
-			else if (nf_ct_expect_related(exp) != 0)
+			else if (nf_ct_expect_related(exp) != 0) {
+				nf_ct_helper_log(skb, ct, "cannot add "
+							  "expectation");
 				ret = NF_DROP;
+			}
 			nf_ct_expect_put(exp);
 			goto out;
 		}
diff --git a/net/netfilter/nf_conntrack_sane.c b/net/netfilter/nf_conntrack_sane.c
index 295429f..4a2134f 100644
--- a/net/netfilter/nf_conntrack_sane.c
+++ b/net/netfilter/nf_conntrack_sane.c
@@ -138,6 +138,7 @@ static int help(struct sk_buff *skb,
 
 	exp = nf_ct_expect_alloc(ct);
 	if (exp == NULL) {
+		nf_ct_helper_log(skb, ct, "cannot alloc expectation");
 		ret = NF_DROP;
 		goto out;
 	}
@@ -151,8 +152,10 @@ static int help(struct sk_buff *skb,
 	nf_ct_dump_tuple(&exp->tuple);
 
 	/* Can't expect this?  Best to drop packet now. */
-	if (nf_ct_expect_related(exp) != 0)
+	if (nf_ct_expect_related(exp) != 0) {
+		nf_ct_helper_log(skb, ct, "cannot add expectation");
 		ret = NF_DROP;
+	}
 
 	nf_ct_expect_put(exp);
 
diff --git a/net/netfilter/nf_conntrack_sip.c b/net/netfilter/nf_conntrack_sip.c
index 72a67bb..1b00517 100644
--- a/net/netfilter/nf_conntrack_sip.c
+++ b/net/netfilter/nf_conntrack_sip.c
@@ -1095,8 +1095,10 @@ static int process_sdp(struct sk_buff *skb, unsigned int protoff,
 		port = simple_strtoul(*dptr + mediaoff, NULL, 10);
 		if (port == 0)
 			continue;
-		if (port < 1024 || port > 65535)
+		if (port < 1024 || port > 65535) {
+			nf_ct_helper_log(skb, ct, "wrong port %u", port);
 			return NF_DROP;
+		}
 
 		/* The media description overrides the session description. */
 		maddr_len = 0;
@@ -1107,15 +1109,20 @@ static int process_sdp(struct sk_buff *skb, unsigned int protoff,
 			memcpy(&rtp_addr, &maddr, sizeof(rtp_addr));
 		} else if (caddr_len)
 			memcpy(&rtp_addr, &caddr, sizeof(rtp_addr));
-		else
+		else {
+			nf_ct_helper_log(skb, ct, "cannot parse SDP message");
 			return NF_DROP;
+		}
 
 		ret = set_expected_rtp_rtcp(skb, protoff, dataoff,
 					    dptr, datalen,
 					    &rtp_addr, htons(port), t->class,
 					    mediaoff, medialen);
-		if (ret != NF_ACCEPT)
+		if (ret != NF_ACCEPT) {
+			nf_ct_helper_log(skb, ct, "cannot add expectation "
+						  "for RTP/RTCP traffic");
 			return ret;
+		}
 
 		/* Update media connection address if present */
 		if (maddr_len && nf_nat_sdp_addr && ct->status & IPS_NAT_MASK) {
@@ -1123,8 +1130,11 @@ static int process_sdp(struct sk_buff *skb, unsigned int protoff,
 					      dptr, datalen, mediaoff,
 					      SDP_HDR_CONNECTION, SDP_HDR_MEDIA,
 					      &rtp_addr);
-			if (ret != NF_ACCEPT)
+			if (ret != NF_ACCEPT) {
+				nf_ct_helper_log(skb, ct, "cannot mangle "
+							  "media connection");
 				return ret;
+			}
 		}
 		i++;
 	}
@@ -1258,9 +1268,10 @@ static int process_register_request(struct sk_buff *skb, unsigned int protoff,
 	ret = ct_sip_parse_header_uri(ct, *dptr, NULL, *datalen,
 				      SIP_HDR_CONTACT, NULL,
 				      &matchoff, &matchlen, &daddr, &port);
-	if (ret < 0)
+	if (ret < 0) {
+		nf_ct_helper_log(skb, ct, "cannot parse register request");
 		return NF_DROP;
-	else if (ret == 0)
+	} else if (ret == 0)
 		return NF_ACCEPT;
 
 	/* We don't support third-party registrations */
@@ -1273,8 +1284,11 @@ static int process_register_request(struct sk_buff *skb, unsigned int protoff,
 
 	if (ct_sip_parse_numerical_param(ct, *dptr,
 					 matchoff + matchlen, *datalen,
-					 "expires=", NULL, NULL, &expires) < 0)
+					 "expires=", NULL, NULL, &expires) < 0) {
+		nf_ct_helper_log(skb, ct, "cannot parse numerical parameter "
+					  "in register request");
 		return NF_DROP;
+	}
 
 	if (expires == 0) {
 		ret = NF_ACCEPT;
@@ -1282,8 +1296,10 @@ static int process_register_request(struct sk_buff *skb, unsigned int protoff,
 	}
 
 	exp = nf_ct_expect_alloc(ct);
-	if (!exp)
+	if (!exp) {
+		nf_ct_helper_log(skb, ct, "cannot alloc expectation");
 		return NF_DROP;
+	}
 
 	saddr = NULL;
 	if (sip_direct_signalling)
@@ -1300,9 +1316,10 @@ static int process_register_request(struct sk_buff *skb, unsigned int protoff,
 		ret = nf_nat_sip_expect(skb, protoff, dataoff, dptr, datalen,
 					exp, matchoff, matchlen);
 	else {
-		if (nf_ct_expect_related(exp) != 0)
+		if (nf_ct_expect_related(exp) != 0) {
+			nf_ct_helper_log(skb, ct, "cannot add expectation");
 			ret = NF_DROP;
-		else
+		} else
 			ret = NF_ACCEPT;
 	}
 	nf_ct_expect_put(exp);
@@ -1356,9 +1373,11 @@ static int process_register_response(struct sk_buff *skb, unsigned int protoff,
 					      SIP_HDR_CONTACT, &in_contact,
 					      &matchoff, &matchlen,
 					      &addr, &port);
-		if (ret < 0)
+		if (ret < 0) {
+			nf_ct_helper_log(skb, ct, "cannot parse register "
+						  "response");
 			return NF_DROP;
-		else if (ret == 0)
+		} else if (ret == 0)
 			break;
 
 		/* We don't support third-party registrations */
@@ -1373,8 +1392,12 @@ static int process_register_response(struct sk_buff *skb, unsigned int protoff,
 						   matchoff + matchlen,
 						   *datalen, "expires=",
 						   NULL, NULL, &c_expires);
-		if (ret < 0)
+		if (ret < 0) {
+			nf_ct_helper_log(skb, ct, "cannot parse numerical "
+						  "parameter in register "
+						  "request");
 			return NF_DROP;
+		}
 		if (c_expires == 0)
 			break;
 		if (refresh_signalling_expectation(ct, &addr, proto, port,
@@ -1408,15 +1431,21 @@ static int process_sip_response(struct sk_buff *skb, unsigned int protoff,
 	if (*datalen < strlen("SIP/2.0 200"))
 		return NF_ACCEPT;
 	code = simple_strtoul(*dptr + strlen("SIP/2.0 "), NULL, 10);
-	if (!code)
+	if (!code) {
+		nf_ct_helper_log(skb, ct, "cannot parse code in response");
 		return NF_DROP;
+	}
 
 	if (ct_sip_get_header(ct, *dptr, 0, *datalen, SIP_HDR_CSEQ,
-			      &matchoff, &matchlen) <= 0)
+			      &matchoff, &matchlen) <= 0) {
+		nf_ct_helper_log(skb, ct, "cannot parse header in response");
 		return NF_DROP;
+	}
 	cseq = simple_strtoul(*dptr + matchoff, NULL, 10);
-	if (!cseq)
+	if (!cseq) {
+		nf_ct_helper_log(skb, ct, "cannot parse cseq in response");
 		return NF_DROP;
+	}
 	matchend = matchoff + matchlen + 1;
 
 	for (i = 0; i < ARRAY_SIZE(sip_handlers); i++) {
@@ -1471,11 +1500,17 @@ static int process_sip_request(struct sk_buff *skb, unsigned int protoff,
 			continue;
 
 		if (ct_sip_get_header(ct, *dptr, 0, *datalen, SIP_HDR_CSEQ,
-				      &matchoff, &matchlen) <= 0)
+				      &matchoff, &matchlen) <= 0) {
+			nf_ct_helper_log(skb, ct, "cannot parse header "
+						  "in request");
 			return NF_DROP;
+		}
 		cseq = simple_strtoul(*dptr + matchoff, NULL, 10);
-		if (!cseq)
+		if (!cseq) {
+			nf_ct_helper_log(skb, ct, "cannot parse cseq "
+						  "in request");
 			return NF_DROP;
+		}
 
 		return handler->request(skb, protoff, dataoff, dptr, datalen,
 					cseq);
@@ -1498,8 +1533,10 @@ static int process_sip_msg(struct sk_buff *skb, struct nf_conn *ct,
 	if (ret == NF_ACCEPT && ct->status & IPS_NAT_MASK) {
 		nf_nat_sip = rcu_dereference(nf_nat_sip_hook);
 		if (nf_nat_sip && !nf_nat_sip(skb, protoff, dataoff,
-					      dptr, datalen))
+					      dptr, datalen)) {
+			nf_ct_helper_log(skb, ct, "cannot NAT SIP message");
 			ret = NF_DROP;
+		}
 	}
 
 	return ret;
@@ -1563,11 +1600,14 @@ static int sip_help_tcp(struct sk_buff *skb, unsigned int protoff,
 		end += strlen("\r\n\r\n") + clen;
 
 		msglen = origlen = end - dptr;
-		if (msglen > datalen)
+		if (msglen > datalen) {
+			nf_ct_helper_log(skb, ct, "incomplete/bad SIP message");
 			return NF_DROP;
+		}
 
 		ret = process_sip_msg(skb, ct, protoff, dataoff,
 				      &dptr, &msglen);
+		/* process_sip_* functions report why this packet is dropped */
 		if (ret != NF_ACCEPT)
 			break;
 		diff     = msglen - origlen;
diff --git a/net/netfilter/nf_conntrack_tftp.c b/net/netfilter/nf_conntrack_tftp.c
index 81fc61c..e9936c8 100644
--- a/net/netfilter/nf_conntrack_tftp.c
+++ b/net/netfilter/nf_conntrack_tftp.c
@@ -60,8 +60,10 @@ static int tftp_help(struct sk_buff *skb,
 		nf_ct_dump_tuple(&ct->tuplehash[IP_CT_DIR_REPLY].tuple);
 
 		exp = nf_ct_expect_alloc(ct);
-		if (exp == NULL)
+		if (exp == NULL) {
+			nf_ct_helper_log(skb, ct, "cannot alloc expectation");
 			return NF_DROP;
+		}
 		tuple = &ct->tuplehash[IP_CT_DIR_REPLY].tuple;
 		nf_ct_expect_init(exp, NF_CT_EXPECT_CLASS_DEFAULT,
 				  nf_ct_l3num(ct),
@@ -74,8 +76,10 @@ static int tftp_help(struct sk_buff *skb,
 		nf_nat_tftp = rcu_dereference(nf_nat_tftp_hook);
 		if (nf_nat_tftp && ct->status & IPS_NAT_MASK)
 			ret = nf_nat_tftp(skb, ctinfo, exp);
-		else if (nf_ct_expect_related(exp) != 0)
+		else if (nf_ct_expect_related(exp) != 0) {
+			nf_ct_helper_log(skb, ct, "cannot add expectation");
 			ret = NF_DROP;
+		}
 		nf_ct_expect_put(exp);
 		break;
 	case TFTP_OPCODE_DATA:
diff --git a/net/netfilter/nf_nat_amanda.c b/net/netfilter/nf_nat_amanda.c
index 42d3378..3b67c9d 100644
--- a/net/netfilter/nf_nat_amanda.c
+++ b/net/netfilter/nf_nat_amanda.c
@@ -56,15 +56,19 @@ static unsigned int help(struct sk_buff *skb,
 		}
 	}
 
-	if (port == 0)
+	if (port == 0) {
+		nf_ct_helper_log(skb, exp->master, "all ports in use");
 		return NF_DROP;
+	}
 
 	sprintf(buffer, "%u", port);
 	ret = nf_nat_mangle_udp_packet(skb, exp->master, ctinfo,
 				       protoff, matchoff, matchlen,
 				       buffer, strlen(buffer));
-	if (ret != NF_ACCEPT)
+	if (ret != NF_ACCEPT) {
+		nf_ct_helper_log(skb, exp->master, "cannot mangle packet");
 		nf_ct_unexpect_related(exp);
+	}
 	return ret;
 }
 
diff --git a/net/netfilter/nf_nat_ftp.c b/net/netfilter/nf_nat_ftp.c
index e839b97..e84a578 100644
--- a/net/netfilter/nf_nat_ftp.c
+++ b/net/netfilter/nf_nat_ftp.c
@@ -96,8 +96,10 @@ static unsigned int nf_nat_ftp(struct sk_buff *skb,
 		}
 	}
 
-	if (port == 0)
+	if (port == 0) {
+		nf_ct_helper_log(skb, ct, "all ports in use");
 		return NF_DROP;
+	}
 
 	buflen = nf_nat_ftp_fmt_cmd(ct, type, buffer, sizeof(buffer),
 				    &newaddr, port);
@@ -113,6 +115,7 @@ static unsigned int nf_nat_ftp(struct sk_buff *skb,
 	return NF_ACCEPT;
 
 out:
+	nf_ct_helper_log(skb, ct, "cannot mangle packet");
 	nf_ct_unexpect_related(exp);
 	return NF_DROP;
 }
diff --git a/net/netfilter/nf_nat_irc.c b/net/netfilter/nf_nat_irc.c
index 1fedee6..f02b360 100644
--- a/net/netfilter/nf_nat_irc.c
+++ b/net/netfilter/nf_nat_irc.c
@@ -56,14 +56,18 @@ static unsigned int help(struct sk_buff *skb,
 		}
 	}
 
-	if (port == 0)
+	if (port == 0) {
+		nf_ct_helper_log(skb, exp->master, "all ports in use");
 		return NF_DROP;
+	}
 
 	ret = nf_nat_mangle_tcp_packet(skb, exp->master, ctinfo,
 				       protoff, matchoff, matchlen, buffer,
 				       strlen(buffer));
-	if (ret != NF_ACCEPT)
+	if (ret != NF_ACCEPT) {
+		nf_ct_helper_log(skb, exp->master, "cannot mangle packet");
 		nf_ct_unexpect_related(exp);
+	}
 	return ret;
 }
 
diff --git a/net/netfilter/nf_nat_sip.c b/net/netfilter/nf_nat_sip.c
index 5951146e..96ccdf7 100644
--- a/net/netfilter/nf_nat_sip.c
+++ b/net/netfilter/nf_nat_sip.c
@@ -159,8 +159,10 @@ static unsigned int nf_nat_sip(struct sk_buff *skb, unsigned int protoff,
 					 &matchoff, &matchlen,
 					 &addr, &port) > 0 &&
 		    !map_addr(skb, protoff, dataoff, dptr, datalen,
-			      matchoff, matchlen, &addr, port))
+			      matchoff, matchlen, &addr, port)) {
+			nf_ct_helper_log(skb, ct, "cannot mangle SIP message");
 			return NF_DROP;
+		}
 		request = 1;
 	} else
 		request = 0;
@@ -193,8 +195,10 @@ static unsigned int nf_nat_sip(struct sk_buff *skb, unsigned int protoff,
 
 		olen = *datalen;
 		if (!map_addr(skb, protoff, dataoff, dptr, datalen,
-			      matchoff, matchlen, &addr, port))
+			      matchoff, matchlen, &addr, port)) {
+			nf_ct_helper_log(skb, ct, "cannot mangle Via header");
 			return NF_DROP;
+		}
 
 		matchend = matchoff + matchlen + *datalen - olen;
 
@@ -209,8 +213,10 @@ static unsigned int nf_nat_sip(struct sk_buff *skb, unsigned int protoff,
 					&ct->tuplehash[!dir].tuple.dst.u3,
 					true);
 			if (!mangle_packet(skb, protoff, dataoff, dptr, datalen,
-					   poff, plen, buffer, buflen))
+					   poff, plen, buffer, buflen)) {
+				nf_ct_helper_log(skb, ct, "cannot mangle maddr");
 				return NF_DROP;
+			}
 		}
 
 		/* The received= parameter (RFC 2361) contains the address
@@ -225,6 +231,7 @@ static unsigned int nf_nat_sip(struct sk_buff *skb, unsigned int protoff,
 					false);
 			if (!mangle_packet(skb, protoff, dataoff, dptr, datalen,
 					   poff, plen, buffer, buflen))
+				nf_ct_helper_log(skb, ct, "cannot mangle received");
 				return NF_DROP;
 		}
 
@@ -238,8 +245,10 @@ static unsigned int nf_nat_sip(struct sk_buff *skb, unsigned int protoff,
 			__be16 p = ct->tuplehash[!dir].tuple.src.u.udp.port;
 			buflen = sprintf(buffer, "%u", ntohs(p));
 			if (!mangle_packet(skb, protoff, dataoff, dptr, datalen,
-					   poff, plen, buffer, buflen))
+					   poff, plen, buffer, buflen)) {
+				nf_ct_helper_log(skb, ct, "cannot mangle rport");
 				return NF_DROP;
+			}
 		}
 	}
 
@@ -253,27 +262,35 @@ next:
 				       &addr, &port) > 0) {
 		if (!map_addr(skb, protoff, dataoff, dptr, datalen,
 			      matchoff, matchlen,
-			      &addr, port))
+			      &addr, port)) {
+			nf_ct_helper_log(skb, ct, "cannot mangle contact");
 			return NF_DROP;
+		}
 	}
 
 	if (!map_sip_addr(skb, protoff, dataoff, dptr, datalen, SIP_HDR_FROM) ||
-	    !map_sip_addr(skb, protoff, dataoff, dptr, datalen, SIP_HDR_TO))
+	    !map_sip_addr(skb, protoff, dataoff, dptr, datalen, SIP_HDR_TO)) {
+		nf_ct_helper_log(skb, ct, "cannot mangle SIP from/to");
 		return NF_DROP;
+	}
 
 	/* Mangle destination port for Cisco phones, then fix up checksums */
 	if (dir == IP_CT_DIR_REPLY && ct_sip_info->forced_dport) {
 		struct udphdr *uh;
 
-		if (!skb_make_writable(skb, skb->len))
+		if (!skb_make_writable(skb, skb->len)) {
+			nf_ct_helper_log(skb, ct, "cannot mangle packet");
 			return NF_DROP;
+		}
 
 		uh = (void *)skb->data + protoff;
 		uh->dest = ct_sip_info->forced_dport;
 
 		if (!nf_nat_mangle_udp_packet(skb, ct, ctinfo, protoff,
-					      0, 0, NULL, 0))
+					      0, 0, NULL, 0)) {
+			nf_ct_helper_log(skb, ct, "cannot mangle packet");
 			return NF_DROP;
+		}
 	}
 
 	return NF_ACCEPT;
@@ -372,15 +389,19 @@ static unsigned int nf_nat_sip_expect(struct sk_buff *skb, unsigned int protoff,
 		}
 	}
 
-	if (port == 0)
+	if (port == 0) {
+		nf_ct_helper_log(skb, ct, "all ports in use for SIP");
 		return NF_DROP;
+	}
 
 	if (!nf_inet_addr_cmp(&exp->tuple.dst.u3, &exp->saved_addr) ||
 	    exp->tuple.dst.u.udp.port != exp->saved_proto.udp.port) {
 		buflen = sip_sprintf_addr_port(ct, buffer, &newaddr, port);
 		if (!mangle_packet(skb, protoff, dataoff, dptr, datalen,
-				   matchoff, matchlen, buffer, buflen))
+				   matchoff, matchlen, buffer, buflen)) {
+			nf_ct_helper_log(skb, ct, "cannot mangle packet");
 			goto err;
+		}
 	}
 	return NF_ACCEPT;
 
@@ -573,14 +594,18 @@ static unsigned int nf_nat_sdp_media(struct sk_buff *skb, unsigned int protoff,
 		}
 	}
 
-	if (port == 0)
+	if (port == 0) {
+		nf_ct_helper_log(skb, ct, "all ports in use for SDP media");
 		goto err1;
+	}
 
 	/* Update media port. */
 	if (rtp_exp->tuple.dst.u.udp.port != rtp_exp->saved_proto.udp.port &&
 	    !nf_nat_sdp_port(skb, protoff, dataoff, dptr, datalen,
-			     mediaoff, medialen, port))
+			     mediaoff, medialen, port)) {
+		nf_ct_helper_log(skb, ct, "cannot mangle SDP message");
 		goto err2;
+	}
 
 	return NF_ACCEPT;
 
diff --git a/net/netfilter/nf_nat_tftp.c b/net/netfilter/nf_nat_tftp.c
index ccabbda..7f67e1d 100644
--- a/net/netfilter/nf_nat_tftp.c
+++ b/net/netfilter/nf_nat_tftp.c
@@ -28,8 +28,10 @@ static unsigned int help(struct sk_buff *skb,
 		= ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple.src.u.udp.port;
 	exp->dir = IP_CT_DIR_REPLY;
 	exp->expectfn = nf_nat_follow_master;
-	if (nf_ct_expect_related(exp) != 0)
+	if (nf_ct_expect_related(exp) != 0) {
+		nf_ct_helper_log(skb, exp->master, "cannot add expectation");
 		return NF_DROP;
+	}
 	return NF_ACCEPT;
 }
 
-- 
1.7.10.4
