From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v2] inetpeer: fix a race in inetpeer_gc_worker()
Date: Tue, 05 Jun 2012 15:00:18 +0200
Message-ID: <1338901218.2760.2615.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
	netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:64921 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757210Ab2FENAX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2012 09:00:23 -0400
Received: by bkcji2 with SMTP id ji2so4563759bkc.19
        for <netdev@vger.kernel.org>; Tue, 05 Jun 2012 06:00:22 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

commit 5faa5df1fa2024 (inetpeer: Invalidate the inetpeer tree along with
the routing cache) added a race :

Before freeing an inetpeer, we must respect a RCU grace period, and make
sure no user will attempt to increase refcnt.

inetpeer_invalidate_tree() waits for a RCU grace period before inserting
inetpeer tree into gc_list and waking the worker. At that time, no
concurrent lookup can find a inetpeer in this tree.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Steffen Klassert <steffen.klassert@secunet.com>
---
v2: use a call_rcu() to let the worker running on entries that cannot be
found by concurrent lookups.

 include/net/inetpeer.h |    5 ++++-
 net/ipv4/inetpeer.c    |   16 ++++++++++++----
 2 files changed, 16 insertions(+), 5 deletions(-)

diff --git a/include/net/inetpeer.h b/include/net/inetpeer.h
index b94765e..2040bff 100644
--- a/include/net/inetpeer.h
+++ b/include/net/inetpeer.h
@@ -40,7 +40,10 @@ struct inet_peer {
 	u32			pmtu_orig;
 	u32			pmtu_learned;
 	struct inetpeer_addr_base redirect_learned;
-	struct list_head	gc_list;
+	union {
+		struct list_head	gc_list;
+		struct rcu_head     gc_rcu;
+	};
 	/*
 	 * Once inet_peer is queued for deletion (refcnt == -1), following fields
 	 * are not available: rid, ip_id_count, tcp_ts, tcp_ts_stamp
diff --git a/net/ipv4/inetpeer.c b/net/ipv4/inetpeer.c
index d4d61b6..dfba343 100644
--- a/net/ipv4/inetpeer.c
+++ b/net/ipv4/inetpeer.c
@@ -560,6 +560,17 @@ bool inet_peer_xrlim_allow(struct inet_peer *peer, int timeout)
 }
 EXPORT_SYMBOL(inet_peer_xrlim_allow);
 
+static void inetpeer_inval_rcu(struct rcu_head *head)
+{
+	struct inet_peer *p = container_of(head, struct inet_peer, gc_rcu);
+
+	spin_lock_bh(&gc_lock);
+	list_add_tail(&p->gc_list, &gc_list);
+	spin_unlock_bh(&gc_lock);
+
+	schedule_delayed_work(&gc_work, gc_delay);
+}
+
 void inetpeer_invalidate_tree(int family)
 {
 	struct inet_peer *old, *new, *prev;
@@ -576,10 +587,7 @@ void inetpeer_invalidate_tree(int family)
 	prev = cmpxchg(&base->root, old, new);
 	if (prev == old) {
 		base->total = 0;
-		spin_lock(&gc_lock);
-		list_add_tail(&prev->gc_list, &gc_list);
-		spin_unlock(&gc_lock);
-		schedule_delayed_work(&gc_work, gc_delay);
+		call_rcu(&prev->gc_rcu, inetpeer_inval_rcu);
 	}
 
 out:
