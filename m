From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: [PATCH 23/31]: pkt_sched: Kill qdisc_lock_tree usage in cls_route.c
Date: Thu, 17 Jul 2008 05:17:43 -0700 (PDT)
Message-ID: <20080717.051743.112915778.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org, johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


It just wants the qdisc tree to be synchronized, so grabbing
qdisc_root_lock() is sufficient.

Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
---
 net/sched/cls_route.c |   12 +++++++-----
 1 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/net/sched/cls_route.c b/net/sched/cls_route.c
index 5a16ca2..481260a 100644
--- a/net/sched/cls_route.c
+++ b/net/sched/cls_route.c
@@ -73,11 +73,13 @@ static __inline__ int route4_fastmap_hash(u32 id, int iif)
 }
 
 static inline
-void route4_reset_fastmap(struct net_device *dev, struct route4_head *head, u32 id)
+void route4_reset_fastmap(struct Qdisc *q, struct route4_head *head, u32 id)
 {
-	qdisc_lock_tree(dev);
+	spinlock_t *root_lock = qdisc_root_lock(q);
+
+	spin_lock_bh(root_lock);
 	memset(head->fastmap, 0, sizeof(head->fastmap));
-	qdisc_unlock_tree(dev);
+	spin_unlock_bh(root_lock);
 }
 
 static inline void
@@ -302,7 +304,7 @@ static int route4_delete(struct tcf_proto *tp, unsigned long arg)
 			*fp = f->next;
 			tcf_tree_unlock(tp);
 
-			route4_reset_fastmap(qdisc_dev(tp->q), head, f->id);
+			route4_reset_fastmap(tp->q, head, f->id);
 			route4_delete_filter(tp, f);
 
 			/* Strip tree */
@@ -500,7 +502,7 @@ reinsert:
 	}
 	tcf_tree_unlock(tp);
 
-	route4_reset_fastmap(qdisc_dev(tp->q), head, f->id);
+	route4_reset_fastmap(tp->q, head, f->id);
 	*arg = (unsigned long)f;
 	return 0;
 
-- 
1.5.6.2.255.gbed62

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
