From: kaber@trash.net
Subject: [PATCH 11/72] netfilter: nf_nat: better error handling of nf_ct_expect_related() in helpers
Date: Thu, 21 Oct 2010 17:18:58 +0200
Message-ID: <1287674399-31455-12-git-send-email-kaber@trash.net>
References: <1287674399-31455-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1287674399-31455-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>

This patch improves the situation in which the expectation table is
full for conntrack NAT helpers. Basically, we give up if we don't
find a place in the table instead of looping over nf_ct_expect_related()
with a different port (we should only do this if it returns -EBUSY, for
-EMFILE or -ESHUTDOWN I think that it's better to skip this).

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/ipv4/netfilter/nf_nat_amanda.c |    9 +++++-
 net/ipv4/netfilter/nf_nat_ftp.c    |    9 +++++-
 net/ipv4/netfilter/nf_nat_h323.c   |   53 +++++++++++++++++++++++++++++++-----
 net/ipv4/netfilter/nf_nat_irc.c    |    9 +++++-
 net/ipv4/netfilter/nf_nat_sip.c    |   27 +++++++++++++++---
 5 files changed, 93 insertions(+), 14 deletions(-)

diff --git a/net/ipv4/netfilter/nf_nat_amanda.c b/net/ipv4/netfilter/nf_nat_amanda.c
index c31b876..0f23b3f 100644
--- a/net/ipv4/netfilter/nf_nat_amanda.c
+++ b/net/ipv4/netfilter/nf_nat_amanda.c
@@ -44,9 +44,16 @@ static unsigned int help(struct sk_buff *skb,
 
 	/* Try to get same port: if not, try to change it. */
 	for (port = ntohs(exp->saved_proto.tcp.port); port != 0; port++) {
+		int ret;
+
 		exp->tuple.dst.u.tcp.port = htons(port);
-		if (nf_ct_expect_related(exp) == 0)
+		ret = nf_ct_expect_related(exp);
+		if (ret == 0)
+			break;
+		else if (ret != -EBUSY) {
+			port = 0;
 			break;
+		}
 	}
 
 	if (port == 0)
diff --git a/net/ipv4/netfilter/nf_nat_ftp.c b/net/ipv4/netfilter/nf_nat_ftp.c
index 86e0e84..dc73abb 100644
--- a/net/ipv4/netfilter/nf_nat_ftp.c
+++ b/net/ipv4/netfilter/nf_nat_ftp.c
@@ -79,9 +79,16 @@ static unsigned int nf_nat_ftp(struct sk_buff *skb,
 
 	/* Try to get same port: if not, try to change it. */
 	for (port = ntohs(exp->saved_proto.tcp.port); port != 0; port++) {
+		int ret;
+
 		exp->tuple.dst.u.tcp.port = htons(port);
-		if (nf_ct_expect_related(exp) == 0)
+		ret = nf_ct_expect_related(exp);
+		if (ret == 0)
+			break;
+		else if (ret != -EBUSY) {
+			port = 0;
 			break;
+		}
 	}
 
 	if (port == 0)
diff --git a/net/ipv4/netfilter/nf_nat_h323.c b/net/ipv4/netfilter/nf_nat_h323.c
index 5045196..790f316 100644
--- a/net/ipv4/netfilter/nf_nat_h323.c
+++ b/net/ipv4/netfilter/nf_nat_h323.c
@@ -222,13 +222,24 @@ static int nat_rtp_rtcp(struct sk_buff *skb, struct nf_conn *ct,
 	/* Try to get a pair of ports. */
 	for (nated_port = ntohs(rtp_exp->tuple.dst.u.udp.port);
 	     nated_port != 0; nated_port += 2) {
+		int ret;
+
 		rtp_exp->tuple.dst.u.udp.port = htons(nated_port);
-		if (nf_ct_expect_related(rtp_exp) == 0) {
+		ret = nf_ct_expect_related(rtp_exp);
+		if (ret == 0) {
 			rtcp_exp->tuple.dst.u.udp.port =
 			    htons(nated_port + 1);
-			if (nf_ct_expect_related(rtcp_exp) == 0)
+			ret = nf_ct_expect_related(rtcp_exp);
+			if (ret == 0)
+				break;
+			else if (ret != -EBUSY) {
+				nf_ct_unexpect_related(rtp_exp);
+				nated_port = 0;
 				break;
-			nf_ct_unexpect_related(rtp_exp);
+			}
+		} else if (ret != -EBUSY) {
+			nated_port = 0;
+			break;
 		}
 	}
 
@@ -284,9 +295,16 @@ static int nat_t120(struct sk_buff *skb, struct nf_conn *ct,
 
 	/* Try to get same port: if not, try to change it. */
 	for (; nated_port != 0; nated_port++) {
+		int ret;
+
 		exp->tuple.dst.u.tcp.port = htons(nated_port);
-		if (nf_ct_expect_related(exp) == 0)
+		ret = nf_ct_expect_related(exp);
+		if (ret == 0)
+			break;
+		else if (ret != -EBUSY) {
+			nated_port = 0;
 			break;
+		}
 	}
 
 	if (nated_port == 0) {	/* No port available */
@@ -334,9 +352,16 @@ static int nat_h245(struct sk_buff *skb, struct nf_conn *ct,
 
 	/* Try to get same port: if not, try to change it. */
 	for (; nated_port != 0; nated_port++) {
+		int ret;
+
 		exp->tuple.dst.u.tcp.port = htons(nated_port);
-		if (nf_ct_expect_related(exp) == 0)
+		ret = nf_ct_expect_related(exp);
+		if (ret == 0)
 			break;
+		else if (ret != -EBUSY) {
+			nated_port = 0;
+			break;
+		}
 	}
 
 	if (nated_port == 0) {	/* No port available */
@@ -418,9 +443,16 @@ static int nat_q931(struct sk_buff *skb, struct nf_conn *ct,
 
 	/* Try to get same port: if not, try to change it. */
 	for (; nated_port != 0; nated_port++) {
+		int ret;
+
 		exp->tuple.dst.u.tcp.port = htons(nated_port);
-		if (nf_ct_expect_related(exp) == 0)
+		ret = nf_ct_expect_related(exp);
+		if (ret == 0)
+			break;
+		else if (ret != -EBUSY) {
+			nated_port = 0;
 			break;
+		}
 	}
 
 	if (nated_port == 0) {	/* No port available */
@@ -500,9 +532,16 @@ static int nat_callforwarding(struct sk_buff *skb, struct nf_conn *ct,
 
 	/* Try to get same port: if not, try to change it. */
 	for (nated_port = ntohs(port); nated_port != 0; nated_port++) {
+		int ret;
+
 		exp->tuple.dst.u.tcp.port = htons(nated_port);
-		if (nf_ct_expect_related(exp) == 0)
+		ret = nf_ct_expect_related(exp);
+		if (ret == 0)
 			break;
+		else if (ret != -EBUSY) {
+			nated_port = 0;
+			break;
+		}
 	}
 
 	if (nated_port == 0) {	/* No port available */
diff --git a/net/ipv4/netfilter/nf_nat_irc.c b/net/ipv4/netfilter/nf_nat_irc.c
index ea83a88..535e1a8 100644
--- a/net/ipv4/netfilter/nf_nat_irc.c
+++ b/net/ipv4/netfilter/nf_nat_irc.c
@@ -45,9 +45,16 @@ static unsigned int help(struct sk_buff *skb,
 
 	/* Try to get same port: if not, try to change it. */
 	for (port = ntohs(exp->saved_proto.tcp.port); port != 0; port++) {
+		int ret;
+
 		exp->tuple.dst.u.tcp.port = htons(port);
-		if (nf_ct_expect_related(exp) == 0)
+		ret = nf_ct_expect_related(exp);
+		if (ret == 0)
+			break;
+		else if (ret != -EBUSY) {
+			port = 0;
 			break;
+		}
 	}
 
 	if (port == 0)
diff --git a/net/ipv4/netfilter/nf_nat_sip.c b/net/ipv4/netfilter/nf_nat_sip.c
index 11b538d..e40cf78 100644
--- a/net/ipv4/netfilter/nf_nat_sip.c
+++ b/net/ipv4/netfilter/nf_nat_sip.c
@@ -307,9 +307,16 @@ static unsigned int ip_nat_sip_expect(struct sk_buff *skb, unsigned int dataoff,
 	exp->expectfn = ip_nat_sip_expected;
 
 	for (; port != 0; port++) {
+		int ret;
+
 		exp->tuple.dst.u.udp.port = htons(port);
-		if (nf_ct_expect_related(exp) == 0)
+		ret = nf_ct_expect_related(exp);
+		if (ret == 0)
+			break;
+		else if (ret != -EBUSY) {
+			port = 0;
 			break;
+		}
 	}
 
 	if (port == 0)
@@ -480,13 +487,25 @@ static unsigned int ip_nat_sdp_media(struct sk_buff *skb, unsigned int dataoff,
 	/* Try to get same pair of ports: if not, try to change them. */
 	for (port = ntohs(rtp_exp->tuple.dst.u.udp.port);
 	     port != 0; port += 2) {
+		int ret;
+
 		rtp_exp->tuple.dst.u.udp.port = htons(port);
-		if (nf_ct_expect_related(rtp_exp) != 0)
+		ret = nf_ct_expect_related(rtp_exp);
+		if (ret == -EBUSY)
 			continue;
+		else if (ret < 0) {
+			port = 0;
+			break;
+		}
 		rtcp_exp->tuple.dst.u.udp.port = htons(port + 1);
-		if (nf_ct_expect_related(rtcp_exp) == 0)
+		ret = nf_ct_expect_related(rtcp_exp);
+		if (ret == 0)
 			break;
-		nf_ct_unexpect_related(rtp_exp);
+		else if (ret != -EBUSY) {
+			nf_ct_unexpect_related(rtp_exp);
+			port = 0;
+			break;
+		}
 	}
 
 	if (port == 0)
-- 
1.7.1

