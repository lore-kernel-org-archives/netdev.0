From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 09/47] netfilter: add and use nf_ct_unconfirmed_destroy
Date: Mon,  4 Sep 2017 00:25:51 +0200
Message-ID: <1504477589-12045-10-git-send-email-pablo@netfilter.org>
References: <1504477589-12045-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1504477589-12045-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>

This also removes __nf_ct_unconfirmed_destroy() call from
nf_ct_iterate_cleanup_net, so that function can be used only
when missing conntracks from unconfirmed list isn't a problem.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_conntrack.h |  3 +++
 net/netfilter/nf_conntrack_core.c    | 15 +++++++++++----
 net/netfilter/nfnetlink_cttimeout.c  |  1 +
 3 files changed, 15 insertions(+), 4 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack.h b/include/net/netfilter/nf_conntrack.h
index 48407569585d..6e6f678aaac7 100644
--- a/include/net/netfilter/nf_conntrack.h
+++ b/include/net/netfilter/nf_conntrack.h
@@ -224,6 +224,9 @@ extern s32 (*nf_ct_nat_offset)(const struct nf_conn *ct,
 			       enum ip_conntrack_dir dir,
 			       u32 seq);
 
+/* Set all unconfirmed conntrack as dying */
+void nf_ct_unconfirmed_destroy(struct net *);
+
 /* Iterate over all conntracks: if iter returns true, it's deleted. */
 void nf_ct_iterate_cleanup_net(struct net *net,
 			       int (*iter)(struct nf_conn *i, void *data),
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index c6f1cf0bff56..80ab4e937765 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -1686,6 +1686,17 @@ __nf_ct_unconfirmed_destroy(struct net *net)
 	}
 }
 
+void nf_ct_unconfirmed_destroy(struct net *net)
+{
+	might_sleep();
+
+	if (atomic_read(&net->ct.count) > 0) {
+		__nf_ct_unconfirmed_destroy(net);
+		synchronize_net();
+	}
+}
+EXPORT_SYMBOL_GPL(nf_ct_unconfirmed_destroy);
+
 void nf_ct_iterate_cleanup_net(struct net *net,
 			       int (*iter)(struct nf_conn *i, void *data),
 			       void *data, u32 portid, int report)
@@ -1697,14 +1708,10 @@ void nf_ct_iterate_cleanup_net(struct net *net,
 	if (atomic_read(&net->ct.count) == 0)
 		return;
 
-	__nf_ct_unconfirmed_destroy(net);
-
 	d.iter = iter;
 	d.data = data;
 	d.net = net;
 
-	synchronize_net();
-
 	nf_ct_iterate_cleanup(iter_net_only, &d, portid, report);
 }
 EXPORT_SYMBOL_GPL(nf_ct_iterate_cleanup_net);
diff --git a/net/netfilter/nfnetlink_cttimeout.c b/net/netfilter/nfnetlink_cttimeout.c
index 7ce9e86d374c..f4fb6d4dd0b9 100644
--- a/net/netfilter/nfnetlink_cttimeout.c
+++ b/net/netfilter/nfnetlink_cttimeout.c
@@ -570,6 +570,7 @@ static void __net_exit cttimeout_net_exit(struct net *net)
 {
 	struct ctnl_timeout *cur, *tmp;
 
+	nf_ct_unconfirmed_destroy(net);
 	ctnl_untimeout(net, NULL);
 
 	list_for_each_entry_safe(cur, tmp, &net->nfct_timeout_list, head) {
-- 
2.1.4


