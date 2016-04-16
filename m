From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] netfilter: ctnetlink: add more #ifdef around unused code
Date: Sat, 16 Apr 2016 22:17:43 +0200
Message-ID: <1460837916-1241019-1-git-send-email-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>, Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Ken-ichirou MATSUZAWA <chamaken@gmail.com>,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.17.10]:52494 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751711AbcDPUTQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Apr 2016 16:19:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A recent patch removed many 'inline' annotations for static
functions in this file, which has caused warnings for functions
that are not used in a given configuration, in particular when
CONFIG_NF_CONNTRACK_EVENTS is disabled:

nf_conntrack_netlink.c:572:15: 'ctnetlink_timestamp_size' defined but not used
nf_conntrack_netlink.c:546:15: 'ctnetlink_acct_size' defined but not used
nf_conntrack_netlink.c:339:12: 'ctnetlink_label_size' defined but not used

I first tried to replace some of the existing #ifdefs with nicer
'if (IS_ENABLED())' checks, but ran into several other problems
with that, so this patch adds even more #ifdef conditionals to
avoid the remaining warnings. Another option would be to put
'__maybe_unused' annotations in place of the previous 'inline'
keyword.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Fixes: 4054ff45454a ("netfilter: ctnetlink: remove unnecessary inlining")
---
 net/netfilter/nf_conntrack_netlink.c | 26 +++++++++++++++-----------
 1 file changed, 15 insertions(+), 11 deletions(-)

diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index caa4efe5930b..f893012986c7 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -336,6 +336,7 @@ nla_put_failure:
 #endif
 
 #ifdef CONFIG_NF_CONNTRACK_LABELS
+#ifdef CONFIG_NF_CONNTRACK_EVENTS
 static int ctnetlink_label_size(const struct nf_conn *ct)
 {
 	struct nf_conn_labels *labels = nf_ct_labels_find(ct);
@@ -344,6 +345,7 @@ static int ctnetlink_label_size(const struct nf_conn *ct)
 		return 0;
 	return nla_total_size(labels->words * sizeof(long));
 }
+#endif
 
 static int
 ctnetlink_dump_labels(struct sk_buff *skb, const struct nf_conn *ct)
@@ -526,6 +528,7 @@ nla_put_failure:
 	return -1;
 }
 
+#if defined(CONFIG_NF_CONNTRACK_EVENTS) || defined(CONFIG_NETFILTER_NETLINK_GLUE_CT)
 static size_t ctnetlink_proto_size(const struct nf_conn *ct)
 {
 	struct nf_conntrack_l3proto *l3proto;
@@ -543,16 +546,6 @@ static size_t ctnetlink_proto_size(const struct nf_conn *ct)
 	return len;
 }
 
-static size_t ctnetlink_acct_size(const struct nf_conn *ct)
-{
-	if (!nf_ct_ext_exist(ct, NF_CT_EXT_ACCT))
-		return 0;
-	return 2 * nla_total_size(0) /* CTA_COUNTERS_ORIG|REPL */
-	       + 2 * nla_total_size(sizeof(uint64_t)) /* CTA_COUNTERS_PACKETS */
-	       + 2 * nla_total_size(sizeof(uint64_t)) /* CTA_COUNTERS_BYTES */
-	       ;
-}
-
 static int ctnetlink_secctx_size(const struct nf_conn *ct)
 {
 #ifdef CONFIG_NF_CONNTRACK_SECMARK
@@ -568,6 +561,18 @@ static int ctnetlink_secctx_size(const struct nf_conn *ct)
 	return 0;
 #endif
 }
+#endif
+
+#ifdef CONFIG_NF_CONNTRACK_EVENTS
+static size_t ctnetlink_acct_size(const struct nf_conn *ct)
+{
+	if (!nf_ct_ext_exist(ct, NF_CT_EXT_ACCT))
+		return 0;
+	return 2 * nla_total_size(0) /* CTA_COUNTERS_ORIG|REPL */
+	       + 2 * nla_total_size(sizeof(uint64_t)) /* CTA_COUNTERS_PACKETS */
+	       + 2 * nla_total_size(sizeof(uint64_t)) /* CTA_COUNTERS_BYTES */
+	       ;
+}
 
 static size_t ctnetlink_timestamp_size(const struct nf_conn *ct)
 {
@@ -580,7 +585,6 @@ static size_t ctnetlink_timestamp_size(const struct nf_conn *ct)
 #endif
 }
 
-#ifdef CONFIG_NF_CONNTRACK_EVENTS
 static size_t ctnetlink_nlmsg_size(const struct nf_conn *ct)
 {
 	return NLMSG_ALIGN(sizeof(struct nfgenmsg))
-- 
2.7.0
