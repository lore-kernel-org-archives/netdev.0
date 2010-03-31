From: Jiri Pirko <jpirko@redhat.com>
Subject: [net-next-2.6 PATCH] netfilter: ctnetlink: compute message size
 properly
Date: Wed, 31 Mar 2010 17:11:03 +0200
Message-ID: <20100331151102.GB8043@psychotron.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, kaber@trash.net,
	netfilter@vger.kernel.org, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42122 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751813Ab0CaPLL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Mar 2010 11:11:11 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Message size should be dependent on net->ct.sysctl_acct, not on
CONFIG_NF_CT_ACCT definition.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>

diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 569410a..2b0cfa4 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -426,6 +426,19 @@ ctnetlink_proto_size(const struct nf_conn *ct)
 }
 
 static inline size_t
+ctnetlink_counters_size(const struct nf_conn *ct)
+{
+	struct net *net = nf_ct_net(ct);
+
+	if (!net->ct.sysctl_acct)
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
@@ -435,11 +448,7 @@ ctnetlink_nlmsg_size(const struct nf_conn *ct)
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

