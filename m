From: kaber@trash.net
Subject: [PATCH 52/84] netfilter: ctnetlink: compute message size properly
Date: Mon, 10 May 2010 22:18:23 +0200
Message-ID: <1273522735-24672-53-git-send-email-kaber@trash.net>
References: <1273522735-24672-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1273522735-24672-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jiri Pirko <jpirko@redhat.com>

Message size should be dependent on the presence of an accounting
extension, not on CONFIG_NF_CT_ACCT definition.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/netfilter/nf_conntrack_netlink.c |   17 ++++++++++++-----
 1 files changed, 12 insertions(+), 5 deletions(-)

diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 2b2af63..9a0c0d9 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -426,6 +426,17 @@ ctnetlink_proto_size(const struct nf_conn *ct)
 }
 
 static inline size_t
+ctnetlink_counters_size(const struct nf_conn *ct)
+{
+	if (!nf_ct_ext_exist(ct, NF_CT_EXT_ACCT))
+		return 0;
+	return 2 * nla_total_size(0) /* CTA_COUNTERS_ORIG|REPL */
+	       + 2 * nla_total_size(sizeof(uint64_t)) /* CTA_COUNTERS_PACKETS */
+	       + 2 * nla_total_size(sizeof(uint64_t)) /* CTA_COUNTERS_BYTES */
+	       ;
+}
+
+static inline size_t
 ctnetlink_nlmsg_size(const struct nf_conn *ct)
 {
 	return NLMSG_ALIGN(sizeof(struct nfgenmsg))
@@ -435,11 +446,7 @@ ctnetlink_nlmsg_size(const struct nf_conn *ct)
 	       + 3 * nla_total_size(sizeof(u_int8_t)) /* CTA_PROTO_NUM */
 	       + nla_total_size(sizeof(u_int32_t)) /* CTA_ID */
 	       + nla_total_size(sizeof(u_int32_t)) /* CTA_STATUS */
-#ifdef CONFIG_NF_CT_ACCT
-	       + 2 * nla_total_size(0) /* CTA_COUNTERS_ORIG|REPL */
-	       + 2 * nla_total_size(sizeof(uint64_t)) /* CTA_COUNTERS_PACKETS */
-	       + 2 * nla_total_size(sizeof(uint64_t)) /* CTA_COUNTERS_BYTES */
-#endif
+	       + ctnetlink_counters_size(ct)
 	       + nla_total_size(sizeof(u_int32_t)) /* CTA_TIMEOUT */
 	       + nla_total_size(0) /* CTA_PROTOINFO */
 	       + nla_total_size(0) /* CTA_HELP */
-- 
1.7.0.4

