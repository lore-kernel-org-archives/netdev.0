From: pablo@netfilter.org
Subject: [PATCH 2/4] netfilter: xt_CT: fix timeout setting with IPv6
Date: Wed, 17 Oct 2012 12:40:09 +0200
Message-ID: <1350470411-5793-2-git-send-email-pablo@netfilter.org>
References: <1350470411-5793-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1350470411-5793-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>

This patch fixes ip6tables and the CT target if it is used to set
some custom conntrack timeout policy for IPv6.

Use xt_ct_find_proto which already handles the ip6tables case for us.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/xt_CT.c |   10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/xt_CT.c b/net/netfilter/xt_CT.c
index 16c7125..ae7f5da 100644
--- a/net/netfilter/xt_CT.c
+++ b/net/netfilter/xt_CT.c
@@ -180,9 +180,9 @@ xt_ct_set_timeout(struct nf_conn *ct, const struct xt_tgchk_param *par,
 	typeof(nf_ct_timeout_find_get_hook) timeout_find_get;
 	struct ctnl_timeout *timeout;
 	struct nf_conn_timeout *timeout_ext;
-	const struct ipt_entry *e = par->entryinfo;
 	struct nf_conntrack_l4proto *l4proto;
 	int ret = 0;
+	u8 proto;
 
 	rcu_read_lock();
 	timeout_find_get = rcu_dereference(nf_ct_timeout_find_get_hook);
@@ -192,9 +192,11 @@ xt_ct_set_timeout(struct nf_conn *ct, const struct xt_tgchk_param *par,
 		goto out;
 	}
 
-	if (e->ip.invflags & IPT_INV_PROTO) {
+	proto = xt_ct_find_proto(par);
+	if (!proto) {
 		ret = -EINVAL;
-		pr_info("You cannot use inversion on L4 protocol\n");
+		pr_info("You must specify a L4 protocol, and not use "
+			"inversions on it.\n");
 		goto out;
 	}
 
@@ -214,7 +216,7 @@ xt_ct_set_timeout(struct nf_conn *ct, const struct xt_tgchk_param *par,
 	/* Make sure the timeout policy matches any existing protocol tracker,
 	 * otherwise default to generic.
 	 */
-	l4proto = __nf_ct_l4proto_find(par->family, e->ip.proto);
+	l4proto = __nf_ct_l4proto_find(par->family, proto);
 	if (timeout->l4proto->l4proto != l4proto->l4proto) {
 		ret = -EINVAL;
 		pr_info("Timeout policy `%s' can only be used by L4 protocol "
-- 
1.7.10.4

