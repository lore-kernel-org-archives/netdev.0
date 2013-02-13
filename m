From: pablo@netfilter.org
Subject: [PATCH 2/3] netfilter: nf_ct_helper: don't discard helper if it is actually the same
Date: Wed, 13 Feb 2013 21:38:32 +0100
Message-ID: <1360787913-10335-3-git-send-email-pablo@netfilter.org>
References: <1360787913-10335-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1360787913-10335-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>

commit (32f5376 netfilter: nf_ct_helper: disable automatic helper
re-assignment of different type) broke transparent proxy scenarios.

For example, initial helper lookup might yield "ftp" (dport 21),
while re-lookup after REDIRECT yields "ftp-2121".

This causes the autoassign code to toss the ftp helper, even
though these are just different instances of the same helper.

Change the test to check for the helper function address instead
of the helper address, as suggested by Pablo.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@gnumonks.org>
---
 net/netfilter/nf_conntrack_helper.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/nf_conntrack_helper.c b/net/netfilter/nf_conntrack_helper.c
index 884f2b3..91527d5 100644
--- a/net/netfilter/nf_conntrack_helper.c
+++ b/net/netfilter/nf_conntrack_helper.c
@@ -236,7 +236,9 @@ int __nf_ct_try_assign_helper(struct nf_conn *ct, struct nf_conn *tmpl,
 		/* We only allow helper re-assignment of the same sort since
 		 * we cannot reallocate the helper extension area.
 		 */
-		if (help->helper != helper) {
+		struct nf_conntrack_helper *tmp = rcu_dereference(help->helper);
+
+		if (tmp && tmp->help != helper->help) {
 			RCU_INIT_POINTER(help->helper, NULL);
 			goto out;
 		}
-- 
1.7.10.4

