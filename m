From: pablo@netfilter.org
Subject: [PATCH 6/6] netfilter: nf_conntrack: fix early_drop with reliable event delivery
Date: Tue,  6 Mar 2012 12:22:55 +0100
Message-ID: <1331032975-5303-7-git-send-email-pablo@netfilter.org>
References: <1331032975-5303-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1331032975-5303-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>

If reliable event delivery is enabled and ctnetlink fails to deliver
the destroy event in early_drop, the conntrack subsystem cannot
drop any the candidate flow that was planned to be evicted.

Reported-by: Kerin Millar <kerframil@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_core.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index ed86a3b..fa4b82c 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -635,8 +635,12 @@ static noinline int early_drop(struct net *net, unsigned int hash)
 
 	if (del_timer(&ct->timeout)) {
 		death_by_timeout((unsigned long)ct);
-		dropped = 1;
-		NF_CT_STAT_INC_ATOMIC(net, early_drop);
+		/* Check if we indeed killed this entry. Reliable event
+		   delivery may have inserted it into the dying list. */
+		if (test_bit(IPS_DYING_BIT, &ct->status)) {
+			dropped = 1;
+			NF_CT_STAT_INC_ATOMIC(net, early_drop);
+		}
 	}
 	nf_ct_put(ct);
 	return dropped;
-- 
1.7.7.3

