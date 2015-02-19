From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 3/4] netfilter: xt_recent: don't reject rule if new hitcount exceeds table max
Date: Thu, 19 Feb 2015 19:19:19 +0100
Message-ID: <1424369960-10988-4-git-send-email-pablo@netfilter.org>
References: <1424369960-10988-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1424369960-10988-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>

given:
-A INPUT -m recent --update --seconds 30 --hitcount 4
and
iptables-save > foo

then
iptables-restore < foo

will fail with:
kernel: xt_recent: hitcount (4) is larger than packets to be remembered (4) for table DEFAULT

Even when the check is fixed, the restore won't work if the hitcount is
increased to e.g. 6, since by the time checkentry runs it will find the
'old' incarnation of the table.

We can avoid this by increasing the maximum threshold silently; we only
have to rm all the current entries of the table (these entries would
not have enough room to handle the increased hitcount).

This even makes (not-very-useful)
-A INPUT -m recent --update --seconds 30 --hitcount 4
-A INPUT -m recent --update --seconds 30 --hitcount 42
work.

Fixes: abc86d0f99242b7f142b (netfilter: xt_recent: relax ip_pkt_list_tot restrictions)
Tracked-down-by: Chris Vine <chris@cvine.freeserve.co.uk>
Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/xt_recent.c |   11 +++++------
 1 file changed, 5 insertions(+), 6 deletions(-)

diff --git a/net/netfilter/xt_recent.c b/net/netfilter/xt_recent.c
index 30dbe34..45e1b30 100644
--- a/net/netfilter/xt_recent.c
+++ b/net/netfilter/xt_recent.c
@@ -378,12 +378,11 @@ static int recent_mt_check(const struct xt_mtchk_param *par,
 	mutex_lock(&recent_mutex);
 	t = recent_table_lookup(recent_net, info->name);
 	if (t != NULL) {
-		if (info->hit_count > t->nstamps_max_mask) {
-			pr_info("hitcount (%u) is larger than packets to be remembered (%u) for table %s\n",
-				info->hit_count, t->nstamps_max_mask + 1,
-				info->name);
-			ret = -EINVAL;
-			goto out;
+		if (nstamp_mask > t->nstamps_max_mask) {
+			spin_lock_bh(&recent_lock);
+			recent_table_flush(t);
+			t->nstamps_max_mask = nstamp_mask;
+			spin_unlock_bh(&recent_lock);
 		}
 
 		t->refcnt++;
-- 
1.7.10.4

