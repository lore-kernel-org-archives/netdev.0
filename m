From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 24/34] ipvs: convert rr scheduler to rcu
Date: Fri, 29 Mar 2013 13:11:41 +0900
Message-ID: <1364530311-11512-25-git-send-email-horms@verge.net.au>
References: <1364530311-11512-1-git-send-email-horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	Wensong Zhang <wensong@linux-vs.org>,
	Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:33678 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753051Ab3C2EL6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Mar 2013 00:11:58 -0400
In-Reply-To: <1364530311-11512-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>

The schedule method now needs _rcu list-traversal
primitive for svc->destinations. As the previous entry
could be unlinked, limit the list traversals to 2 when
lookup started from previous entry.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_rr.c |   55 ++++++++++++++++++++++++++---------------
 1 file changed, 35 insertions(+), 20 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_rr.c b/net/netfilter/ipvs/ip_vs_rr.c
index c49b388..3942890 100644
--- a/net/netfilter/ipvs/ip_vs_rr.c
+++ b/net/netfilter/ipvs/ip_vs_rr.c
@@ -35,9 +35,18 @@ static int ip_vs_rr_init_svc(struct ip_vs_service *svc)
 }
 
 
-static int ip_vs_rr_update_svc(struct ip_vs_service *svc)
+static int ip_vs_rr_del_dest(struct ip_vs_service *svc, struct ip_vs_dest *dest)
 {
-	svc->sched_data = &svc->destinations;
+	struct list_head *p;
+
+	write_lock_bh(&svc->sched_lock);
+	p = (struct list_head *) svc->sched_data;
+	/* dest is already unlinked, so p->prev is not valid but
+	 * p->next is valid, use it to reach previous entry.
+	 */
+	if (p == &dest->n_list)
+		svc->sched_data = p->next->prev;
+	write_unlock_bh(&svc->sched_lock);
 	return 0;
 }
 
@@ -48,35 +57,40 @@ static int ip_vs_rr_update_svc(struct ip_vs_service *svc)
 static struct ip_vs_dest *
 ip_vs_rr_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 {
-	struct list_head *p, *q;
-	struct ip_vs_dest *dest;
+	struct list_head *p;
+	struct ip_vs_dest *dest, *last;
+	int pass = 0;
 
 	IP_VS_DBG(6, "%s(): Scheduling...\n", __func__);
 
 	write_lock(&svc->sched_lock);
-	p = (struct list_head *)svc->sched_data;
-	p = p->next;
-	q = p;
+	p = (struct list_head *) svc->sched_data;
+	last = dest = list_entry(p, struct ip_vs_dest, n_list);
+
 	do {
-		/* skip list head */
-		if (q == &svc->destinations) {
-			q = q->next;
-			continue;
+		list_for_each_entry_continue_rcu(dest,
+						 &svc->destinations,
+						 n_list) {
+			if (!(dest->flags & IP_VS_DEST_F_OVERLOAD) &&
+			    atomic_read(&dest->weight) > 0)
+				/* HIT */
+				goto out;
+			if (dest == last)
+				goto stop;
 		}
+		pass++;
+		/* Previous dest could be unlinked, do not loop forever.
+		 * If we stay at head there is no need for 2nd pass.
+		 */
+	} while (pass < 2 && p != &svc->destinations);
 
-		dest = list_entry(q, struct ip_vs_dest, n_list);
-		if (!(dest->flags & IP_VS_DEST_F_OVERLOAD) &&
-		    atomic_read(&dest->weight) > 0)
-			/* HIT */
-			goto out;
-		q = q->next;
-	} while (q != p);
+stop:
 	write_unlock(&svc->sched_lock);
 	ip_vs_scheduler_err(svc, "no destination available");
 	return NULL;
 
   out:
-	svc->sched_data = q;
+	svc->sched_data = &dest->n_list;
 	write_unlock(&svc->sched_lock);
 	IP_VS_DBG_BUF(6, "RR: server %s:%u "
 		      "activeconns %d refcnt %d weight %d\n",
@@ -94,7 +108,8 @@ static struct ip_vs_scheduler ip_vs_rr_scheduler = {
 	.module =		THIS_MODULE,
 	.n_list =		LIST_HEAD_INIT(ip_vs_rr_scheduler.n_list),
 	.init_service =		ip_vs_rr_init_svc,
-	.update_service =	ip_vs_rr_update_svc,
+	.add_dest =		NULL,
+	.del_dest =		ip_vs_rr_del_dest,
 	.schedule =		ip_vs_rr_schedule,
 };
 
-- 
1.7.10.4
