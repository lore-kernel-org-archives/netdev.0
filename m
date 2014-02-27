From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [nf-next PATCH 3/5] netfilter: avoid race with exp->master ct
Date: Thu, 27 Feb 2014 19:23:40 +0100
Message-ID: <20140227182340.25907.6773.stgit@dragon>
References: <20140227182220.25907.12758.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Florian Westphal <fw@strlen.de>,
	"Patrick McHardy" <kaber@trash.net>
To: netfilter-devel@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52642 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753656AbaB0SXs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Feb 2014 13:23:48 -0500
In-Reply-To: <20140227182220.25907.12758.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
---

 net/netfilter/nf_conntrack_core.c   |    2 +-
 net/netfilter/nf_conntrack_expect.c |   16 +++++++++++++++-
 2 files changed, 16 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index ac85fd1..a822720 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -898,6 +898,7 @@ init_conntrack(struct net *net, struct nf_conn *tmpl,
 			 ct, exp);
 		/* Welcome, Mr. Bond.  We've been expecting you... */
 		__set_bit(IPS_EXPECTED_BIT, &ct->status);
+		/* exp->master safe, refcnt bumped in nf_ct_find_expectation */
 		ct->master = exp->master;
 		if (exp->helper) {
 			help = nf_ct_helper_ext_add(ct, exp->helper,
@@ -912,7 +913,6 @@ init_conntrack(struct net *net, struct nf_conn *tmpl,
 #ifdef CONFIG_NF_CONNTRACK_SECMARK
 		ct->secmark = exp->master->secmark;
 #endif
-		nf_conntrack_get(&ct->master->ct_general);
 		NF_CT_STAT_INC(net, expect_new);
 	} else {
 		__nf_ct_try_assign_helper(ct, tmpl, GFP_ATOMIC);
diff --git a/net/netfilter/nf_conntrack_expect.c b/net/netfilter/nf_conntrack_expect.c
index 4fd1ca9..2c4ffdb 100644
--- a/net/netfilter/nf_conntrack_expect.c
+++ b/net/netfilter/nf_conntrack_expect.c
@@ -147,13 +147,27 @@ nf_ct_find_expectation(struct net *net, u16 zone,
 	if (!exp)
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
 	/* If master is not in hash table yet (ie. packet hasn't left
 	   this machine yet), how can other end know about expected?
 	   Hence these are not the droids you are looking for (if
 	   master ct never got confirmed, we'd hold a reference to it
 	   and weird things would happen to future packets). */
-	if (!nf_ct_is_confirmed(exp->master))
+	if (!nf_ct_is_confirmed(exp->master)) {
+		atomic_dec(&exp->master->ct_general.use);
 		return NULL;
+	}
 
 	if (exp->flags & NF_CT_EXPECT_PERMANENT) {
 		atomic_inc(&exp->use);
