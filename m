From: Patrick McHardy <kaber@trash.net>
Subject: [NET_SCHED]: sch_htb/sch_hfsc: fix oops in qlen_notify
Date: Tue, 27 Mar 2007 18:28:48 +0200
Message-ID: <46094640.7010806@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000609010300040400050308"
Cc: Kernel Netdev Mailing List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:62226 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933068AbXC0Q24 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Mar 2007 12:28:56 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------000609010300040400050308
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Fix fallout from my qdisc endless loop fixes. I've checked
all qdiscs, these two should be the only broken ones.
The patch applies to current -git and the last -stable.


--------------000609010300040400050308
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

[NET_SCHED]: sch_htb/sch_hfsc: fix oops in qlen_notify

During both HTB and HFSC class deletion the class is removed from the
class hash before calling qdisc_tree_decrease_qlen. This makes the
->get operation in qdisc_tree_decrease_qlen fail, so it passes a NULL
pointer to ->qlen_notify, causing an oops.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 36ab004c1021c259b8780834287494fe630fc9ee
tree cad66b55dd7c6954ff9b55b16f791d7474adf6b0
parent 703071b5b93d88d5acb0edd5b9dd86c69ad970f2
author Patrick McHardy <kaber@trash.net> Tue, 27 Mar 2007 17:07:50 +0200
committer Patrick McHardy <kaber@trash.net> Tue, 27 Mar 2007 18:25:42 +0200

 net/sched/sch_hfsc.c |    4 +++-
 net/sched/sch_htb.c  |    6 +++---
 2 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index 396deb7..407c6fb 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -1184,10 +1184,12 @@ hfsc_delete_class(struct Qdisc *sch, unsigned long arg)
 
 	sch_tree_lock(sch);
 
-	list_del(&cl->hlist);
 	list_del(&cl->siblings);
 	hfsc_adjust_levels(cl->cl_parent);
+
 	hfsc_purge_queue(sch, cl);
+	list_del(&cl->hlist);
+
 	if (--cl->refcnt == 0)
 		hfsc_destroy_class(sch, cl);
 
diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 97cbb9a..3c3294d 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -1380,15 +1380,15 @@ static int htb_delete(struct Qdisc *sch, unsigned long arg)
 
 	sch_tree_lock(sch);
 
-	/* delete from hash and active; remainder in destroy_class */
-	hlist_del_init(&cl->hlist);
-
 	if (!cl->level) {
 		qlen = cl->un.leaf.q->q.qlen;
 		qdisc_reset(cl->un.leaf.q);
 		qdisc_tree_decrease_qlen(cl->un.leaf.q, qlen);
 	}
 
+	/* delete from hash and active; remainder in destroy_class */
+	hlist_del_init(&cl->hlist);
+
 	if (cl->prio_activity)
 		htb_deactivate(q, cl);
 

--------------000609010300040400050308--
