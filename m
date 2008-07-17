From: David Miller <davem@davemloft.net>
Subject: [PATCH 22/31]: pkt_sched: Remove qdisc_lock_tree usage in cls_api.c
Date: Thu, 17 Jul 2008 05:17:37 -0700 (PDT)
Message-ID: <20080717.051737.247187813.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, johannes@sipsolutions.net,
	linux-wireless@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51683
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758642AbYGQMRh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2008 08:17:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


It just wants the qdisc tree for the filter to be synchronized.
So just BH lock qdisc_root_lock(q) instead.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/sched/cls_api.c |   11 +++++++----
 1 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index d0b0a9b..d2b6f54 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -120,6 +120,7 @@ static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
 {
 	struct net *net = sock_net(skb->sk);
 	struct nlattr *tca[TCA_MAX + 1];
+	spinlock_t *root_lock;
 	struct tcmsg *t;
 	u32 protocol;
 	u32 prio;
@@ -204,6 +205,8 @@ replay:
 		}
 	}
 
+	root_lock = qdisc_root_lock(q);
+
 	if (tp == NULL) {
 		/* Proto-tcf does not exist, create new one */
 
@@ -263,10 +266,10 @@ replay:
 			goto errout;
 		}
 
-		qdisc_lock_tree(dev);
+		spin_lock_bh(root_lock);
 		tp->next = *back;
 		*back = tp;
-		qdisc_unlock_tree(dev);
+		spin_unlock_bh(root_lock);
 
 	} else if (tca[TCA_KIND] && nla_strcmp(tca[TCA_KIND], tp->ops->kind))
 		goto errout;
@@ -275,9 +278,9 @@ replay:
 
 	if (fh == 0) {
 		if (n->nlmsg_type == RTM_DELTFILTER && t->tcm_handle == 0) {
-			qdisc_lock_tree(dev);
+			spin_lock_bh(root_lock);
 			*back = tp->next;
-			qdisc_unlock_tree(dev);
+			spin_lock_bh(root_lock);
 
 			tfilter_notify(skb, n, tp, fh, RTM_DELTFILTER);
 			tcf_destroy(tp);
-- 
1.5.6.2.255.gbed62

