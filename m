From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 27/33] netns ct: PPTP conntracking in netns
Date: Mon,  8 Sep 2008 07:03:04 +0400
Message-ID: <1220842990-30500-27-git-send-email-adobriyan@gmail.com>
References: <48C01046.2070704@trash.net>
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	containers@lists.linux-foundation.org
To: kaber@trash.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <48C01046.2070704@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

diff --git a/net/netfilter/nf_conntrack_pptp.c b/net/netfilter/nf_conntrack_pptp.c
index e47d5de..373e51e 100644
--- a/net/netfilter/nf_conntrack_pptp.c
+++ b/net/netfilter/nf_conntrack_pptp.c
@@ -98,6 +98,7 @@ EXPORT_SYMBOL(pptp_msg_name);
 static void pptp_expectfn(struct nf_conn *ct,
 			 struct nf_conntrack_expect *exp)
 {
+	struct net *net = nf_ct_net(ct);
 	typeof(nf_nat_pptp_hook_expectfn) nf_nat_pptp_expectfn;
 	pr_debug("increasing timeouts\n");
 
@@ -121,7 +122,7 @@ static void pptp_expectfn(struct nf_conn *ct,
 		pr_debug("trying to unexpect other dir: ");
 		nf_ct_dump_tuple(&inv_t);
 
-		exp_other = nf_ct_expect_find_get(&init_net, &inv_t);
+		exp_other = nf_ct_expect_find_get(net, &inv_t);
 		if (exp_other) {
 			/* delete other expectation.  */
 			pr_debug("found\n");
@@ -134,7 +135,8 @@ static void pptp_expectfn(struct nf_conn *ct,
 	rcu_read_unlock();
 }
 
-static int destroy_sibling_or_exp(const struct nf_conntrack_tuple *t)
+static int destroy_sibling_or_exp(struct net *net,
+				  const struct nf_conntrack_tuple *t)
 {
 	const struct nf_conntrack_tuple_hash *h;
 	struct nf_conntrack_expect *exp;
@@ -143,7 +145,7 @@ static int destroy_sibling_or_exp(const struct nf_conntrack_tuple *t)
 	pr_debug("trying to timeout ct or exp for tuple ");
 	nf_ct_dump_tuple(t);
 
-	h = nf_conntrack_find_get(&init_net, t);
+	h = nf_conntrack_find_get(net, t);
 	if (h)  {
 		sibling = nf_ct_tuplehash_to_ctrack(h);
 		pr_debug("setting timeout of conntrack %p to 0\n", sibling);
@@ -154,7 +156,7 @@ static int destroy_sibling_or_exp(const struct nf_conntrack_tuple *t)
 		nf_ct_put(sibling);
 		return 1;
 	} else {
-		exp = nf_ct_expect_find_get(&init_net, t);
+		exp = nf_ct_expect_find_get(net, t);
 		if (exp) {
 			pr_debug("unexpect_related of expect %p\n", exp);
 			nf_ct_unexpect_related(exp);
@@ -168,6 +170,7 @@ static int destroy_sibling_or_exp(const struct nf_conntrack_tuple *t)
 /* timeout GRE data connections */
 static void pptp_destroy_siblings(struct nf_conn *ct)
 {
+	struct net *net = nf_ct_net(ct);
 	const struct nf_conn_help *help = nfct_help(ct);
 	struct nf_conntrack_tuple t;
 
@@ -178,7 +181,7 @@ static void pptp_destroy_siblings(struct nf_conn *ct)
 	t.dst.protonum = IPPROTO_GRE;
 	t.src.u.gre.key = help->help.ct_pptp_info.pns_call_id;
 	t.dst.u.gre.key = help->help.ct_pptp_info.pac_call_id;
-	if (!destroy_sibling_or_exp(&t))
+	if (!destroy_sibling_or_exp(net, &t))
 		pr_debug("failed to timeout original pns->pac ct/exp\n");
 
 	/* try reply (pac->pns) tuple */
@@ -186,7 +189,7 @@ static void pptp_destroy_siblings(struct nf_conn *ct)
 	t.dst.protonum = IPPROTO_GRE;
 	t.src.u.gre.key = help->help.ct_pptp_info.pac_call_id;
 	t.dst.u.gre.key = help->help.ct_pptp_info.pns_call_id;
-	if (!destroy_sibling_or_exp(&t))
+	if (!destroy_sibling_or_exp(net, &t))
 		pr_debug("failed to timeout reply pac->pns ct/exp\n");
 }
 
@@ -594,15 +597,32 @@ static struct nf_conntrack_helper pptp __read_mostly = {
 	.expect_policy		= &pptp_exp_policy,
 };
 
+static void nf_conntrack_pptp_net_exit(struct net *net)
+{
+	nf_ct_gre_keymap_flush(net);
+}
+
+static struct pernet_operations nf_conntrack_pptp_net_ops = {
+	.exit = nf_conntrack_pptp_net_exit,
+};
+
 static int __init nf_conntrack_pptp_init(void)
 {
-	return nf_conntrack_helper_register(&pptp);
+	int rv;
+
+	rv = nf_conntrack_helper_register(&pptp);
+	if (rv < 0)
+		return rv;
+	rv = register_pernet_subsys(&nf_conntrack_pptp_net_ops);
+	if (rv < 0)
+		nf_conntrack_helper_unregister(&pptp);
+	return rv;
 }
 
 static void __exit nf_conntrack_pptp_fini(void)
 {
 	nf_conntrack_helper_unregister(&pptp);
-	nf_ct_gre_keymap_flush(&init_net);
+	unregister_pernet_subsys(&nf_conntrack_pptp_net_ops);
 }
 
 module_init(nf_conntrack_pptp_init);
