From: kaber@trash.net
Subject: [PATCH 1/2] ipvs: fix dst_lock locking on dest update
Date: Wed,  2 Mar 2011 12:56:20 +0100
Message-ID: <1299066981-14058-2-git-send-email-kaber@trash.net>
References: <1299066981-14058-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1299066981-14058-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julian Anastasov <ja@ssi.bg>

	Fix dst_lock usage in __ip_vs_update_dest. We need
_bh locking because destination is updated in user context.
Can cause lockups on frequent destination updates.
Problem reported by Simon Kirby. Bug was introduced
in 2.6.37 from the "ipvs: changes for local real server"
change.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Hans Schillstrom <hans@schillstrom.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_ctl.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 22f7ad5..ba98e13 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -808,9 +808,9 @@ __ip_vs_update_dest(struct ip_vs_service *svc, struct ip_vs_dest *dest,
 	dest->u_threshold = udest->u_threshold;
 	dest->l_threshold = udest->l_threshold;
 
-	spin_lock(&dest->dst_lock);
+	spin_lock_bh(&dest->dst_lock);
 	ip_vs_dst_reset(dest);
-	spin_unlock(&dest->dst_lock);
+	spin_unlock_bh(&dest->dst_lock);
 
 	if (add)
 		ip_vs_new_estimator(&dest->stats);
-- 
1.7.4

