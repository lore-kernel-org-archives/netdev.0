From: Jarek Poplawski <jarkao2@o2.pl>
Subject: [PATCH][NET_SCHED] sch_cbq: deactivating when grafting, purging etc.
Date: Mon, 27 Nov 2006 07:56:14 +0100
Message-ID: <20061127065614.GB1625@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from poczta.o2.pl ([193.17.41.142]:9348 "EHLO poczta.o2.pl")
	by vger.kernel.org with ESMTP id S1757106AbWK0Gtk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Nov 2006 01:49:40 -0500
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Here are some fixes proposals suggested by Patrick McHardy.

[NET_SCHED] sch_cbq:

- deactivating of active classes when grafting

- purging of queue/q.qlen adjustment when deleting an active class

- deactivating of active classes when q.qlen drops to zero in ->drop()

- a redundant instruction removed from cbq_deactivate_class (my own
  suggestion)

PS: - purging of queue and deactivating of active classes
when attaching a new child - not done (according to man, CBQ can carry
packets in any type of nodes).


Signed-off-by: Jarek Poplawski <jarkao2@o2.pl>
---

diff -Nurp linux-2.6.19-rc6-/net/sched/sch_cbq.c linux-2.6.19-rc6/net/sched/sch_cbq.c
--- linux-2.6.19-rc6-/net/sched/sch_cbq.c	2006-09-20 05:42:06.000000000 +0200
+++ linux-2.6.19-rc6/net/sched/sch_cbq.c	2006-11-26 15:10:56.000000000 +0100
@@ -371,8 +371,6 @@ static void cbq_deactivate_class(struct 
 					return;
 				}
 			}
-
-			cl = cl_prev->next_alive;
 			return;
 		}
 	} while ((cl_prev = cl) != q->active[prio]);
@@ -1258,6 +1256,8 @@ static unsigned int cbq_drop(struct Qdis
 		do {
 			if (cl->q->ops->drop && (len = cl->q->ops->drop(cl->q))) {
 				sch->q.qlen--;
+				if (!cl->q->q.qlen)
+					cbq_deactivate_class(cl);
 				return len;
 			}
 		} while ((cl = cl->next_alive) != cl_head);
@@ -1683,8 +1683,10 @@ static int cbq_graft(struct Qdisc *sch, 
 #endif
 		}
 		sch_tree_lock(sch);
-		*old = cl->q;
-		cl->q = new;
+		if (cl->next_alive)
+			cbq_deactivate_class(cl);
+
+		*old = xchg(&cl->q, new);
 		sch->q.qlen -= (*old)->q.qlen;
 		qdisc_reset(*old);
 		sch_tree_unlock(sch);
@@ -1992,6 +1994,9 @@ static int cbq_delete(struct Qdisc *sch,
 
 	sch_tree_lock(sch);
 
+	sch->q.qlen -= cl->q->q.qlen;
+	qdisc_reset(cl->q);
+
 	if (cl->next_alive)
 		cbq_deactivate_class(cl);
 
