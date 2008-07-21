From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 25/31] netns ct: PPTP conntracking in netns
Date: Mon, 21 Jul 2008 20:53:26 +0400
Message-ID: <20080721165326.GK13390@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	dev@openvz.org, xemul@openvz.org, ebiederm@xmission.com,
	dlezcano@fr.ibm.com, benjamin.thery@bull.net
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.174]:10269 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752362AbYGUQzN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2008 12:55:13 -0400
Received: by ug-out-1314.google.com with SMTP id h2so277238ugf.16
        for <netdev@vger.kernel.org>; Mon, 21 Jul 2008 09:55:12 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 net/netfilter/nf_conntrack_pptp.c |   13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

--- a/net/netfilter/nf_conntrack_pptp.c
+++ b/net/netfilter/nf_conntrack_pptp.c
@@ -121,7 +121,7 @@ static void pptp_expectfn(struct nf_conn *ct,
 		pr_debug("trying to unexpect other dir: ");
 		nf_ct_dump_tuple(&inv_t);
 
-		exp_other = nf_ct_expect_find_get(&init_net, &inv_t);
+		exp_other = nf_ct_expect_find_get(nf_ct_net(ct), &inv_t);
 		if (exp_other) {
 			/* delete other expectation.  */
 			pr_debug("found\n");
@@ -134,7 +134,7 @@ static void pptp_expectfn(struct nf_conn *ct,
 	rcu_read_unlock();
 }
 
-static int destroy_sibling_or_exp(const struct nf_conntrack_tuple *t)
+static int destroy_sibling_or_exp(struct net *net, const struct nf_conntrack_tuple *t)
 {
 	const struct nf_conntrack_tuple_hash *h;
 	struct nf_conntrack_expect *exp;
@@ -143,7 +143,7 @@ static int destroy_sibling_or_exp(const struct nf_conntrack_tuple *t)
 	pr_debug("trying to timeout ct or exp for tuple ");
 	nf_ct_dump_tuple(t);
 
-	h = nf_conntrack_find_get(&init_net, t);
+	h = nf_conntrack_find_get(net, t);
 	if (h)  {
 		sibling = nf_ct_tuplehash_to_ctrack(h);
 		pr_debug("setting timeout of conntrack %p to 0\n", sibling);
@@ -154,7 +154,7 @@ static int destroy_sibling_or_exp(const struct nf_conntrack_tuple *t)
 		nf_ct_put(sibling);
 		return 1;
 	} else {
-		exp = nf_ct_expect_find_get(&init_net, t);
+		exp = nf_ct_expect_find_get(net, t);
 		if (exp) {
 			pr_debug("unexpect_related of expect %p\n", exp);
 			nf_ct_unexpect_related(exp);
@@ -168,6 +168,7 @@ static int destroy_sibling_or_exp(const struct nf_conntrack_tuple *t)
 /* timeout GRE data connections */
 static void pptp_destroy_siblings(struct nf_conn *ct)
 {
+	struct net *net = nf_ct_net(ct);
 	const struct nf_conn_help *help = nfct_help(ct);
 	struct nf_conntrack_tuple t;
 
@@ -178,7 +179,7 @@ static void pptp_destroy_siblings(struct nf_conn *ct)
 	t.dst.protonum = IPPROTO_GRE;
 	t.src.u.gre.key = help->help.ct_pptp_info.pns_call_id;
 	t.dst.u.gre.key = help->help.ct_pptp_info.pac_call_id;
-	if (!destroy_sibling_or_exp(&t))
+	if (!destroy_sibling_or_exp(net, &t))
 		pr_debug("failed to timeout original pns->pac ct/exp\n");
 
 	/* try reply (pac->pns) tuple */
@@ -186,7 +187,7 @@ static void pptp_destroy_siblings(struct nf_conn *ct)
 	t.dst.protonum = IPPROTO_GRE;
 	t.src.u.gre.key = help->help.ct_pptp_info.pac_call_id;
 	t.dst.u.gre.key = help->help.ct_pptp_info.pns_call_id;
-	if (!destroy_sibling_or_exp(&t))
+	if (!destroy_sibling_or_exp(net, &t))
 		pr_debug("failed to timeout reply pac->pns ct/exp\n");
 }
 
-- 
1.5.4.5


