From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 03/18] ipvs: zero percpu stats
Date: Sun,  6 Mar 2011 08:45:45 +0900
Message-ID: <1299368760-14271-4-git-send-email-horms@verge.net.au>
References: <1299368760-14271-1-git-send-email-horms@verge.net.au>
Cc: Julian Anastasov <ja@ssi.bg>,
	Hans Schillstrom <hans@schillstrom.com>,
	Simon Horman <horms@verge.net.au>
To: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netfilter@vger.kernel.org, lvs-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:55480 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753383Ab1CEXqP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Mar 2011 18:46:15 -0500
In-Reply-To: <1299368760-14271-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>

 	Zero the new percpu stats because we copy from there.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_ctl.c |   17 +++++++++++++++++
 1 files changed, 17 insertions(+), 0 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index a2a67ad..fd74527 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -715,8 +715,25 @@ static void ip_vs_trash_cleanup(struct net *net)
 static void
 ip_vs_zero_stats(struct ip_vs_stats *stats)
 {
+	struct ip_vs_cpu_stats *cpustats = stats->cpustats;
+	int i;
+
 	spin_lock_bh(&stats->lock);
 
+	for_each_possible_cpu(i) {
+		struct ip_vs_cpu_stats *u = per_cpu_ptr(cpustats, i);
+		unsigned int start;
+
+		/* Do not pretend to be writer, it is enough to
+		 * sync with writers that modify the u64 counters
+		 * because under stats->lock we are the only reader.
+		 */
+		do {
+			start = u64_stats_fetch_begin(&u->syncp);
+			memset(&u->ustats, 0, sizeof(u->ustats));
+		} while (u64_stats_fetch_retry(&u->syncp, start));
+	}
+
 	memset(&stats->ustats, 0, sizeof(stats->ustats));
 	ip_vs_zero_estimator(stats);
 
-- 
1.7.2.3

