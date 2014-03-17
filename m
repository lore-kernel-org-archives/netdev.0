From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 22/38] netfilter: avoid race with exp->master ct
Date: Mon, 17 Mar 2014 13:42:42 +0100
Message-ID: <1395060178-11833-23-git-send-email-pablo@netfilter.org>
References: <1395060178-11833-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1395060178-11833-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jesper Dangaard Brouer <brouer@redhat.com>

Preparation for disconnecting the nf_conntrack_lock from the
expectations code.  Once the nf_conntrack_lock is lifted, a race
condition is exposed.

The expectations master conntrack exp->master, can race with
delete operations, as the refcnt increment happens too late in
init_conntrack().  Race is against other CPUs invoking
->destroy() (destroy_conntrack()), or nf_ct_delete() (via timeout
or early_drop()).

Avoid this race in nf_ct_find_expectation() by using atomic_inc_not_zero(),
and checking if nf_ct_is_dying() (path via nf_ct_delete()).

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_core.c   |    2 +-
 net/netfilter/nf_conntrack_expect.c |   14 ++++++++++++++
 2 files changed, 15 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 289b279..92d5977 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -902,6 +902,7 @@ init_conntrack(struct net *net, struct nf_conn *tmpl,
 			 ct, exp);
 		/* Welcome, Mr. Bond.  We've been expecting you... */
 		__set_bit(IPS_EXPECTED_BIT, &ct->status);
+		/* exp->master safe, refcnt bumped in nf_ct_find_expectation */
 		ct->master = exp->master;
 		if (exp->helper) {
 			help = nf_ct_helper_ext_add(ct, exp->helper,
@@ -916,7 +917,6 @@ init_conntrack(struct net *net, struct nf_conn *tmpl,
 #ifdef CONFIG_NF_CONNTRACK_SECMARK
 		ct->secmark = exp->master->secmark;
 #endif
-		nf_conntrack_get(&ct->master->ct_general);
 		NF_CT_STAT_INC(net, expect_new);
 	} else {
 		__nf_ct_try_assign_helper(ct, tmpl, GFP_ATOMIC);
diff --git a/net/netfilter/nf_conntrack_expect.c b/net/netfilter/nf_conntrack_expect.c
index da2f84f..f02805e 100644
--- a/net/netfilter/nf_conntrack_expect.c
+++ b/net/netfilter/nf_conntrack_expect.c
@@ -155,6 +155,18 @@ nf_ct_find_expectation(struct net *net, u16 zone,
 	if (!nf_ct_is_confirmed(exp->master))
 		return NULL;
 
+	/* Avoid race with other CPUs, that for exp->master ct, is
+	 * about to invoke ->destroy(), or nf_ct_delete() via timeout
+	 * or early_drop().
+	 *
+	 * The atomic_inc_not_zero() check tells:  If that fails, we
+	 * know that the ct is being destroyed.  If it succeeds, we
+	 * can be sure the ct cannot disappear underneath.
+	 */
+	if (unlikely(nf_ct_is_dying(exp->master) ||
+		     !atomic_inc_not_zero(&exp->master->ct_general.use)))
+		return NULL;
+
 	if (exp->flags & NF_CT_EXPECT_PERMANENT) {
 		atomic_inc(&exp->use);
 		return exp;
@@ -162,6 +174,8 @@ nf_ct_find_expectation(struct net *net, u16 zone,
 		nf_ct_unlink_expect(exp);
 		return exp;
 	}
+	/* Undo exp->master refcnt increase, if del_timer() failed */
+	nf_ct_put(exp->master);
 
 	return NULL;
 }
-- 
1.7.10.4

