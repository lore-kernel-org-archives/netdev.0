From: pablo@netfilter.org
Subject: [PATCH 21/25] netfilter: nf_conntrack: add nf_ct_timeout_lookup
Date: Tue,  4 Sep 2012 01:54:08 +0200
Message-ID: <1346716452-3080-22-git-send-email-pablo@netfilter.org>
References: <1346716452-3080-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:37176 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756608Ab2ICX4G (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Sep 2012 19:56:06 -0400
In-Reply-To: <1346716452-3080-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>

This patch adds the new nf_ct_timeout_lookup function to encapsulate
the timeout policy attachment that is called in the nf_conntrack_in
path.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_conntrack_timeout.h |   20 ++++++++++++++++++++
 net/netfilter/nf_conntrack_core.c            |    7 +------
 2 files changed, 21 insertions(+), 6 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack_timeout.h b/include/net/netfilter/nf_conntrack_timeout.h
index 34ec89f..e41e472 100644
--- a/include/net/netfilter/nf_conntrack_timeout.h
+++ b/include/net/netfilter/nf_conntrack_timeout.h
@@ -55,6 +55,26 @@ struct nf_conn_timeout *nf_ct_timeout_ext_add(struct nf_conn *ct,
 #endif
 };
 
+static inline unsigned int *
+nf_ct_timeout_lookup(struct net *net, struct nf_conn *ct,
+		     struct nf_conntrack_l4proto *l4proto)
+{
+#ifdef CONFIG_NF_CONNTRACK_TIMEOUT
+	struct nf_conn_timeout *timeout_ext;
+	unsigned int *timeouts;
+
+	timeout_ext = nf_ct_timeout_find(ct);
+	if (timeout_ext)
+		timeouts = NF_CT_TIMEOUT_EXT_DATA(timeout_ext);
+	else
+		timeouts = l4proto->get_timeouts(net);
+
+	return timeouts;
+#else
+	return l4proto->get_timeouts(net);
+#endif
+}
+
 #ifdef CONFIG_NF_CONNTRACK_TIMEOUT
 extern int nf_conntrack_timeout_init(struct net *net);
 extern void nf_conntrack_timeout_fini(struct net *net);
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index f83e79d..c9bb994 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -930,7 +930,6 @@ nf_conntrack_in(struct net *net, u_int8_t pf, unsigned int hooknum,
 	enum ip_conntrack_info ctinfo;
 	struct nf_conntrack_l3proto *l3proto;
 	struct nf_conntrack_l4proto *l4proto;
-	struct nf_conn_timeout *timeout_ext;
 	unsigned int *timeouts;
 	unsigned int dataoff;
 	u_int8_t protonum;
@@ -997,11 +996,7 @@ nf_conntrack_in(struct net *net, u_int8_t pf, unsigned int hooknum,
 	NF_CT_ASSERT(skb->nfct);
 
 	/* Decide what timeout policy we want to apply to this flow. */
-	timeout_ext = nf_ct_timeout_find(ct);
-	if (timeout_ext)
-		timeouts = NF_CT_TIMEOUT_EXT_DATA(timeout_ext);
-	else
-		timeouts = l4proto->get_timeouts(net);
+	timeouts = nf_ct_timeout_lookup(net, ct, l4proto);
 
 	ret = l4proto->packet(ct, skb, dataoff, ctinfo, pf, hooknum, timeouts);
 	if (ret <= 0) {
-- 
1.7.10.4
