From: Patrick McHardy <kaber@trash.net>
Subject: net-sched 02/02: fix filter destruction in atm/hfsc qdisc destruction
Date: Tue, 01 Jul 2008 12:06:25 +0200
Message-ID: <486A01A1.5060102@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020308060207040102090804"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:63866 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753295AbYGAKG1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jul 2008 06:06:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------020308060207040102090804
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit


--------------020308060207040102090804
Content-Type: text/x-diff;
 name="02.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="02.diff"

commit 096191c2ded6435a9a22fe0e2ee494b6e7686f95
Author: Patrick McHardy <kaber@trash.net>
Date:   Thu Jun 26 18:55:20 2008 +0200

    net-sched: fix filter destruction in atm/hfsc qdisc destruction
    
    Filters need to be destroyed before beginning to destroy classes
    since the destination class needs to still be alive to unbind the
    filter.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/sched/sch_atm.c b/net/sched/sch_atm.c
index 8e5f70b..db0e23a 100644
--- a/net/sched/sch_atm.c
+++ b/net/sched/sch_atm.c
@@ -586,9 +586,11 @@ static void atm_tc_destroy(struct Qdisc *sch)
 	struct atm_flow_data *flow;
 
 	pr_debug("atm_tc_destroy(sch %p,[qdisc %p])\n", sch, p);
+	for (flow = p->flows; flow; flow = flow->next)
+		tcf_destroy_chain(&flow->filter_list);
+
 	/* races ? */
 	while ((flow = p->flows)) {
-		tcf_destroy_chain(&flow->filter_list);
 		if (flow->ref > 1)
 			printk(KERN_ERR "atm_destroy: %p->ref = %d\n", flow,
 			       flow->ref);
diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index eca83a3..e817aa0 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -1541,6 +1541,10 @@ hfsc_destroy_qdisc(struct Qdisc *sch)
 	unsigned int i;
 
 	for (i = 0; i < HFSC_HSIZE; i++) {
+		list_for_each_entry(cl, &q->clhash[i], hlist)
+			tcf_destroy_chain(&cl->filter_list);
+	}
+	for (i = 0; i < HFSC_HSIZE; i++) {
 		list_for_each_entry_safe(cl, next, &q->clhash[i], hlist)
 			hfsc_destroy_class(sch, cl);
 	}

--------------020308060207040102090804--
