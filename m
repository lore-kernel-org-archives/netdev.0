From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 08/29] netfilter: conntrack: restart iteration on resize
Date: Fri, 30 Jun 2017 00:53:06 +0200
Message-ID: <1498776807-11124-9-git-send-email-pablo@netfilter.org>
References: <1498776807-11124-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1498776807-11124-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>

We could some conntracks when a resize occurs in parallel.

Avoid this by sampling generation seqcnt and doing a restart if needed.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_core.c | 20 ++++++++++++++------
 1 file changed, 14 insertions(+), 6 deletions(-)

diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 7ecee79c78b8..c3bd9b086dcc 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -1623,17 +1623,25 @@ get_next_corpse(int (*iter)(struct nf_conn *i, void *data),
 static void nf_ct_iterate_cleanup(int (*iter)(struct nf_conn *i, void *data),
 				  void *data, u32 portid, int report)
 {
+	unsigned int bucket = 0, sequence;
 	struct nf_conn *ct;
-	unsigned int bucket = 0;
 
 	might_sleep();
 
-	while ((ct = get_next_corpse(iter, data, &bucket)) != NULL) {
-		/* Time to push up daises... */
+	for (;;) {
+		sequence = read_seqcount_begin(&nf_conntrack_generation);
 
-		nf_ct_delete(ct, portid, report);
-		nf_ct_put(ct);
-		cond_resched();
+		while ((ct = get_next_corpse(iter, data, &bucket)) != NULL) {
+			/* Time to push up daises... */
+
+			nf_ct_delete(ct, portid, report);
+			nf_ct_put(ct);
+			cond_resched();
+		}
+
+		if (!read_seqcount_retry(&nf_conntrack_generation, sequence))
+			break;
+		bucket = 0;
 	}
 }
 
-- 
2.1.4

