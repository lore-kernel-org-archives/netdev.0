From: kaber@trash.net
Subject: [PATCH 07/17] netfilter: conntrack: restrict NAT helper invocation to IPv4
Date: Mon, 21 Nov 2011 06:45:59 +0100
Message-ID: <1321854369-3432-8-git-send-email-kaber@trash.net>
References: <1321854369-3432-1-git-send-email-kaber@trash.net>
Cc: netdev@vger.kernel.org, kaber@trash.net, ulrich.weber@sophos.com
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:61110 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751516Ab1KUFrp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2011 00:47:45 -0500
In-Reply-To: <1321854369-3432-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>

The NAT helpers currently only handle IPv4 packets correctly. Restrict
invocation of the helpers to IPv4 in preparation of IPv6 NAT.

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/netfilter/nf_conntrack_amanda.c    |    3 +-
 net/netfilter/nf_conntrack_ftp.c       |    3 +-
 net/netfilter/nf_conntrack_h323_main.c |   41 ++++++++++++++++++++++---------
 net/netfilter/nf_conntrack_irc.c       |    3 +-
 net/netfilter/nf_conntrack_sip.c       |   18 +++++++++----
 net/netfilter/nf_conntrack_tftp.c      |    3 +-
 6 files changed, 49 insertions(+), 22 deletions(-)

diff --git a/net/netfilter/nf_conntrack_amanda.c b/net/netfilter/nf_conntrack_amanda.c
index 13fd2c5..49880c8 100644
--- a/net/netfilter/nf_conntrack_amanda.c
+++ b/net/netfilter/nf_conntrack_amanda.c
@@ -155,7 +155,8 @@ static int amanda_help(struct sk_buff *skb,
 				  IPPROTO_TCP, NULL, &port);
 
 		nf_nat_amanda = rcu_dereference(nf_nat_amanda_hook);
-		if (nf_nat_amanda && ct->status & IPS_NAT_MASK)
+		if (nf_nat_amanda && nf_ct_l3num(ct) == NFPROTO_IPV4 &&
+		    ct->status & IPS_NAT_MASK)
 			ret = nf_nat_amanda(skb, ctinfo, off - dataoff,
 					    len, exp);
 		else if (nf_ct_expect_related(exp) != 0)
diff --git a/net/netfilter/nf_conntrack_ftp.c b/net/netfilter/nf_conntrack_ftp.c
index 6f5801e..9e738eb 100644
--- a/net/netfilter/nf_conntrack_ftp.c
+++ b/net/netfilter/nf_conntrack_ftp.c
@@ -487,7 +487,8 @@ static int help(struct sk_buff *skb,
 	/* Now, NAT might want to mangle the packet, and register the
 	 * (possibly changed) expectation itself. */
 	nf_nat_ftp = rcu_dereference(nf_nat_ftp_hook);
-	if (nf_nat_ftp && ct->status & IPS_NAT_MASK)
+	if (nf_nat_ftp && nf_ct_l3num(ct) == NFPROTO_IPV4 &&
+	    ct->status & IPS_NAT_MASK)
 		ret = nf_nat_ftp(skb, ctinfo, search[dir][i].ftptype,
 				 matchoff, matchlen, exp);
 	else {
diff --git a/net/netfilter/nf_conntrack_h323_main.c b/net/netfilter/nf_conntrack_h323_main.c
index f03c2d4..200c7a4 100644
--- a/net/netfilter/nf_conntrack_h323_main.c
+++ b/net/netfilter/nf_conntrack_h323_main.c
@@ -296,6 +296,7 @@ static int expect_rtp_rtcp(struct sk_buff *skb, struct nf_conn *ct,
 		   &ct->tuplehash[!dir].tuple.dst.u3,
 		   sizeof(ct->tuplehash[dir].tuple.src.u3)) &&
 		   (nat_rtp_rtcp = rcu_dereference(nat_rtp_rtcp_hook)) &&
+		   nf_ct_l3num(ct) == NFPROTO_IPV4 &&
 		   ct->status & IPS_NAT_MASK) {
 		/* NAT needed */
 		ret = nat_rtp_rtcp(skb, ct, ctinfo, data, dataoff,
@@ -354,6 +355,7 @@ static int expect_t120(struct sk_buff *skb,
 		   &ct->tuplehash[!dir].tuple.dst.u3,
 		   sizeof(ct->tuplehash[dir].tuple.src.u3)) &&
 	    (nat_t120 = rcu_dereference(nat_t120_hook)) &&
+	    nf_ct_l3num(ct) == NFPROTO_IPV4 &&
 	    ct->status & IPS_NAT_MASK) {
 		/* NAT needed */
 		ret = nat_t120(skb, ct, ctinfo, data, dataoff, taddr,
@@ -689,6 +691,7 @@ static int expect_h245(struct sk_buff *skb, struct nf_conn *ct,
 		   &ct->tuplehash[!dir].tuple.dst.u3,
 		   sizeof(ct->tuplehash[dir].tuple.src.u3)) &&
 	    (nat_h245 = rcu_dereference(nat_h245_hook)) &&
+	    nf_ct_l3num(ct) == NFPROTO_IPV4 &&
 	    ct->status & IPS_NAT_MASK) {
 		/* NAT needed */
 		ret = nat_h245(skb, ct, ctinfo, data, dataoff, taddr,
@@ -813,6 +816,7 @@ static int expect_callforwarding(struct sk_buff *skb,
 		   &ct->tuplehash[!dir].tuple.dst.u3,
 		   sizeof(ct->tuplehash[dir].tuple.src.u3)) &&
 	    (nat_callforwarding = rcu_dereference(nat_callforwarding_hook)) &&
+	    nf_ct_l3num(ct) == NFPROTO_IPV4 &&
 	    ct->status & IPS_NAT_MASK) {
 		/* Need NAT */
 		ret = nat_callforwarding(skb, ct, ctinfo, data, dataoff,
@@ -854,7 +858,8 @@ static int process_setup(struct sk_buff *skb, struct nf_conn *ct,
 
 	set_h225_addr = rcu_dereference(set_h225_addr_hook);
 	if ((setup->options & eSetup_UUIE_destCallSignalAddress) &&
-	    (set_h225_addr) && ct->status & IPS_NAT_MASK &&
+	    (set_h225_addr) && nf_ct_l3num(ct) == NFPROTO_IPV4 &&
+	    ct->status & IPS_NAT_MASK &&
 	    get_h225_addr(ct, *data, &setup->destCallSignalAddress,
 			  &addr, &port) &&
 	    memcmp(&addr, &ct->tuplehash[!dir].tuple.src.u3, sizeof(addr))) {
@@ -870,7 +875,8 @@ static int process_setup(struct sk_buff *skb, struct nf_conn *ct,
 	}
 
 	if ((setup->options & eSetup_UUIE_sourceCallSignalAddress) &&
-	    (set_h225_addr) && ct->status & IPS_NAT_MASK &&
+	    (set_h225_addr) && nf_ct_l3num(ct) == NFPROTO_IPV4 &&
+	    ct->status & IPS_NAT_MASK &&
 	    get_h225_addr(ct, *data, &setup->sourceCallSignalAddress,
 			  &addr, &port) &&
 	    memcmp(&addr, &ct->tuplehash[!dir].tuple.dst.u3, sizeof(addr))) {
@@ -1280,7 +1286,8 @@ static int expect_q931(struct sk_buff *skb, struct nf_conn *ct,
 	exp->flags = NF_CT_EXPECT_PERMANENT;	/* Accept multiple calls */
 
 	nat_q931 = rcu_dereference(nat_q931_hook);
-	if (nat_q931 && ct->status & IPS_NAT_MASK) {	/* Need NAT */
+	if (nat_q931 && nf_ct_l3num(ct) == NFPROTO_IPV4 &&
+	    ct->status & IPS_NAT_MASK) {	/* Need NAT */
 		ret = nat_q931(skb, ct, ctinfo, data, taddr, i, port, exp);
 	} else {		/* Conntrack only */
 		if (nf_ct_expect_related(exp) == 0) {
@@ -1308,7 +1315,8 @@ static int process_grq(struct sk_buff *skb, struct nf_conn *ct,
 	pr_debug("nf_ct_ras: GRQ\n");
 
 	set_ras_addr = rcu_dereference(set_ras_addr_hook);
-	if (set_ras_addr && ct->status & IPS_NAT_MASK)	/* NATed */
+	if (set_ras_addr && nf_ct_l3num(ct) == NFPROTO_IPV4 &&
+	    ct->status & IPS_NAT_MASK)	/* NATed */
 		return set_ras_addr(skb, ct, ctinfo, data,
 				    &grq->rasAddress, 1);
 	return 0;
@@ -1376,7 +1384,8 @@ static int process_rrq(struct sk_buff *skb, struct nf_conn *ct,
 		return -1;
 
 	set_ras_addr = rcu_dereference(set_ras_addr_hook);
-	if (set_ras_addr && ct->status & IPS_NAT_MASK) {
+	if (set_ras_addr && nf_ct_l3num(ct) == NFPROTO_IPV4 &&
+	    ct->status & IPS_NAT_MASK) {
 		ret = set_ras_addr(skb, ct, ctinfo, data,
 				   rrq->rasAddress.item,
 				   rrq->rasAddress.count);
@@ -1407,7 +1416,8 @@ static int process_rcf(struct sk_buff *skb, struct nf_conn *ct,
 	pr_debug("nf_ct_ras: RCF\n");
 
 	set_sig_addr = rcu_dereference(set_sig_addr_hook);
-	if (set_sig_addr && ct->status & IPS_NAT_MASK) {
+	if (set_sig_addr && nf_ct_l3num(ct) == NFPROTO_IPV4 &&
+	    ct->status & IPS_NAT_MASK) {
 		ret = set_sig_addr(skb, ct, ctinfo, data,
 					rcf->callSignalAddress.item,
 					rcf->callSignalAddress.count);
@@ -1455,7 +1465,8 @@ static int process_urq(struct sk_buff *skb, struct nf_conn *ct,
 	pr_debug("nf_ct_ras: URQ\n");
 
 	set_sig_addr = rcu_dereference(set_sig_addr_hook);
-	if (set_sig_addr && ct->status & IPS_NAT_MASK) {
+	if (set_sig_addr && nf_ct_l3num(ct) == NFPROTO_IPV4 &&
+	    ct->status & IPS_NAT_MASK) {
 		ret = set_sig_addr(skb, ct, ctinfo, data,
 				   urq->callSignalAddress.item,
 				   urq->callSignalAddress.count);
@@ -1493,6 +1504,7 @@ static int process_arq(struct sk_buff *skb, struct nf_conn *ct,
 			  &addr, &port) &&
 	    !memcmp(&addr, &ct->tuplehash[dir].tuple.src.u3, sizeof(addr)) &&
 	    port == info->sig_port[dir] &&
+	    nf_ct_l3num(ct) == NFPROTO_IPV4 &&
 	    set_h225_addr && ct->status & IPS_NAT_MASK) {
 		/* Answering ARQ */
 		return set_h225_addr(skb, data, 0,
@@ -1505,7 +1517,8 @@ static int process_arq(struct sk_buff *skb, struct nf_conn *ct,
 	    get_h225_addr(ct, *data, &arq->srcCallSignalAddress,
 			  &addr, &port) &&
 	    !memcmp(&addr, &ct->tuplehash[dir].tuple.src.u3, sizeof(addr)) &&
-	    set_h225_addr && ct->status & IPS_NAT_MASK) {
+	    set_h225_addr && nf_ct_l3num(ct) == NFPROTO_IPV4 &&
+	    ct->status & IPS_NAT_MASK) {
 		/* Calling ARQ */
 		return set_h225_addr(skb, data, 0,
 				     &arq->srcCallSignalAddress,
@@ -1537,7 +1550,8 @@ static int process_acf(struct sk_buff *skb, struct nf_conn *ct,
 	if (!memcmp(&addr, &ct->tuplehash[dir].tuple.dst.u3, sizeof(addr))) {
 		/* Answering ACF */
 		set_sig_addr = rcu_dereference(set_sig_addr_hook);
-		if (set_sig_addr && ct->status & IPS_NAT_MASK)
+		if (set_sig_addr && nf_ct_l3num(ct) == NFPROTO_IPV4 &&
+		    ct->status & IPS_NAT_MASK)
 			return set_sig_addr(skb, ct, ctinfo, data,
 					    &acf->destCallSignalAddress, 1);
 		return 0;
@@ -1573,7 +1587,8 @@ static int process_lrq(struct sk_buff *skb, struct nf_conn *ct,
 	pr_debug("nf_ct_ras: LRQ\n");
 
 	set_ras_addr = rcu_dereference(set_ras_addr_hook);
-	if (set_ras_addr && ct->status & IPS_NAT_MASK)
+	if (set_ras_addr && nf_ct_l3num(ct) == NFPROTO_IPV4 &&
+	    ct->status & IPS_NAT_MASK)
 		return set_ras_addr(skb, ct, ctinfo, data,
 				    &lrq->replyAddress, 1);
 	return 0;
@@ -1630,7 +1645,8 @@ static int process_irr(struct sk_buff *skb, struct nf_conn *ct,
 	pr_debug("nf_ct_ras: IRR\n");
 
 	set_ras_addr = rcu_dereference(set_ras_addr_hook);
-	if (set_ras_addr && ct->status & IPS_NAT_MASK) {
+	if (set_ras_addr && nf_ct_l3num(ct) == NFPROTO_IPV4 &&
+	    ct->status & IPS_NAT_MASK) {
 		ret = set_ras_addr(skb, ct, ctinfo, data,
 				   &irr->rasAddress, 1);
 		if (ret < 0)
@@ -1638,7 +1654,8 @@ static int process_irr(struct sk_buff *skb, struct nf_conn *ct,
 	}
 
 	set_sig_addr = rcu_dereference(set_sig_addr_hook);
-	if (set_sig_addr && ct->status & IPS_NAT_MASK) {
+	if (set_sig_addr && nf_ct_l3num(ct) == NFPROTO_IPV4 &&
+	    ct->status & IPS_NAT_MASK) {
 		ret = set_sig_addr(skb, ct, ctinfo, data,
 					irr->callSignalAddress.item,
 					irr->callSignalAddress.count);
diff --git a/net/netfilter/nf_conntrack_irc.c b/net/netfilter/nf_conntrack_irc.c
index 4f9390b..17ad9a4 100644
--- a/net/netfilter/nf_conntrack_irc.c
+++ b/net/netfilter/nf_conntrack_irc.c
@@ -206,7 +206,8 @@ static int help(struct sk_buff *skb, unsigned int protoff,
 					  IPPROTO_TCP, NULL, &port);
 
 			nf_nat_irc = rcu_dereference(nf_nat_irc_hook);
-			if (nf_nat_irc && ct->status & IPS_NAT_MASK)
+			if (nf_nat_irc && nf_ct_l3num(ct) == NFPROTO_IPV4 &&
+			    ct->status & IPS_NAT_MASK)
 				ret = nf_nat_irc(skb, ctinfo,
 						 addr_beg_p - ib_ptr,
 						 addr_end_p - addr_beg_p,
diff --git a/net/netfilter/nf_conntrack_sip.c b/net/netfilter/nf_conntrack_sip.c
index 93faf6a..6294f02 100644
--- a/net/netfilter/nf_conntrack_sip.c
+++ b/net/netfilter/nf_conntrack_sip.c
@@ -928,7 +928,8 @@ static int set_expected_rtp_rtcp(struct sk_buff *skb, unsigned int dataoff,
 			  IPPROTO_UDP, NULL, &rtcp_port);
 
 	nf_nat_sdp_media = rcu_dereference(nf_nat_sdp_media_hook);
-	if (nf_nat_sdp_media && ct->status & IPS_NAT_MASK && !direct_rtp)
+	if (nf_nat_sdp_media && nf_ct_l3num(ct) == NFPROTO_IPV4 &&
+	    ct->status & IPS_NAT_MASK && !direct_rtp)
 		ret = nf_nat_sdp_media(skb, dataoff, dptr, datalen,
 				       rtp_exp, rtcp_exp,
 				       mediaoff, medialen, daddr);
@@ -1051,7 +1052,8 @@ static int process_sdp(struct sk_buff *skb, unsigned int dataoff,
 			return ret;
 
 		/* Update media connection address if present */
-		if (maddr_len && nf_nat_sdp_addr && ct->status & IPS_NAT_MASK) {
+		if (maddr_len && nf_nat_sdp_addr &&
+		    nf_ct_l3num(ct) == NFPROTO_IPV4 && ct->status & IPS_NAT_MASK) {
 			ret = nf_nat_sdp_addr(skb, dataoff, dptr, datalen,
 					      mediaoff, c_hdr, SDP_HDR_MEDIA,
 					      &rtp_addr);
@@ -1063,7 +1065,8 @@ static int process_sdp(struct sk_buff *skb, unsigned int dataoff,
 
 	/* Update session connection and owner addresses */
 	nf_nat_sdp_session = rcu_dereference(nf_nat_sdp_session_hook);
-	if (nf_nat_sdp_session && ct->status & IPS_NAT_MASK)
+	if (nf_nat_sdp_session && nf_ct_l3num(ct) == NFPROTO_IPV4 &&
+	    ct->status & IPS_NAT_MASK)
 		ret = nf_nat_sdp_session(skb, dataoff, dptr, datalen, sdpoff,
 					 &rtp_addr);
 
@@ -1222,7 +1225,8 @@ static int process_register_request(struct sk_buff *skb, unsigned int dataoff,
 	exp->flags = NF_CT_EXPECT_PERMANENT | NF_CT_EXPECT_INACTIVE;
 
 	nf_nat_sip_expect = rcu_dereference(nf_nat_sip_expect_hook);
-	if (nf_nat_sip_expect && ct->status & IPS_NAT_MASK)
+	if (nf_nat_sip_expect && nf_ct_l3num(ct) == NFPROTO_IPV4 &&
+	    ct->status & IPS_NAT_MASK)
 		ret = nf_nat_sip_expect(skb, dataoff, dptr, datalen, exp,
 					matchoff, matchlen);
 	else {
@@ -1400,7 +1404,8 @@ static int process_sip_msg(struct sk_buff *skb, struct nf_conn *ct,
 	else
 		ret = process_sip_response(skb, dataoff, dptr, datalen);
 
-	if (ret == NF_ACCEPT && ct->status & IPS_NAT_MASK) {
+	if (ret == NF_ACCEPT && nf_ct_l3num(ct) == NFPROTO_IPV4 &&
+	    ct->status & IPS_NAT_MASK) {
 		nf_nat_sip = rcu_dereference(nf_nat_sip_hook);
 		if (nf_nat_sip && !nf_nat_sip(skb, dataoff, dptr, datalen))
 			ret = NF_DROP;
@@ -1481,7 +1486,8 @@ static int sip_help_tcp(struct sk_buff *skb, unsigned int protoff,
 		datalen  = datalen + diff - msglen;
 	}
 
-	if (ret == NF_ACCEPT && ct->status & IPS_NAT_MASK) {
+	if (ret == NF_ACCEPT && nf_ct_l3num(ct) == NFPROTO_IPV4 &&
+	    ct->status & IPS_NAT_MASK) {
 		nf_nat_sip_seq_adjust = rcu_dereference(nf_nat_sip_seq_adjust_hook);
 		if (nf_nat_sip_seq_adjust)
 			nf_nat_sip_seq_adjust(skb, tdiff);
diff --git a/net/netfilter/nf_conntrack_tftp.c b/net/netfilter/nf_conntrack_tftp.c
index 75466fd..abc2a5e 100644
--- a/net/netfilter/nf_conntrack_tftp.c
+++ b/net/netfilter/nf_conntrack_tftp.c
@@ -72,7 +72,8 @@ static int tftp_help(struct sk_buff *skb,
 		nf_ct_dump_tuple(&exp->tuple);
 
 		nf_nat_tftp = rcu_dereference(nf_nat_tftp_hook);
-		if (nf_nat_tftp && ct->status & IPS_NAT_MASK)
+		if (nf_nat_tftp && nf_ct_l3num(ct) == NFPROTO_IPV4 &&
+		    ct->status & IPS_NAT_MASK)
 			ret = nf_nat_tftp(skb, ctinfo, exp);
 		else if (nf_ct_expect_related(exp) != 0)
 			ret = NF_DROP;
-- 
1.7.1
