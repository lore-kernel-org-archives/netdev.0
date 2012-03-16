From: pablo@netfilter.org
Subject: [PATCH] netfilter: ctnetlink: fix race between delete and timeout expiration
Date: Fri, 16 Mar 2012 13:00:34 +0100
Message-ID: <1331899234-3123-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>

Kerin Millar reported hardlockups while running `conntrackd -c'
in a busy firewall. That system (with several processors) was
acting as backup in a primary-backup setup.

After several tries, I found a race condition between the deletion
operation of ctnetlink and timeout expiration. This patch fixes
this problem.

Tested-by: Kerin Millar <kerframil@gmail.com>
Reported-by: Kerin Millar <kerframil@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_netlink.c |   23 ++++++++++++-----------
 1 files changed, 12 insertions(+), 11 deletions(-)

diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 1068769..b49da6c 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -943,20 +943,21 @@ ctnetlink_del_conntrack(struct sock *ctnl, struct sk_buff *skb,
 		}
 	}
 
-	if (nf_conntrack_event_report(IPCT_DESTROY, ct,
-				      NETLINK_CB(skb).pid,
-				      nlmsg_report(nlh)) < 0) {
+	if (del_timer(&ct->timeout)) {
+		if (nf_conntrack_event_report(IPCT_DESTROY, ct,
+					      NETLINK_CB(skb).pid,
+					      nlmsg_report(nlh)) < 0) {
+			nf_ct_delete_from_lists(ct);
+			/* we failed to report the event, try later */
+			nf_ct_insert_dying_list(ct);
+			nf_ct_put(ct);
+			return 0;
+		}
+		/* death_by_timeout would report the event again */
+		set_bit(IPS_DYING_BIT, &ct->status);
 		nf_ct_delete_from_lists(ct);
-		/* we failed to report the event, try later */
-		nf_ct_insert_dying_list(ct);
 		nf_ct_put(ct);
-		return 0;
 	}
-
-	/* death_by_timeout would report the event again */
-	set_bit(IPS_DYING_BIT, &ct->status);
-
-	nf_ct_kill(ct);
 	nf_ct_put(ct);
 
 	return 0;
-- 
1.7.2.5

