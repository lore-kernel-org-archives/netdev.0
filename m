From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH][NET_SCHED] sch_htb: remove from event queue in
	htb_parent_to_leaf()
Date: Sat, 3 May 2008 20:42:45 +0200
Message-ID: <20080503184245.GB6484@ami.dom.local>
References: <20080503071651.GA3313@ami.dom.local> <481C33D2.2090308@ya.bofh.cz> <20080503163939.GA6484@ami.dom.local> <481CA037.3000909@ya.bofh.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jan 'yanek' Bortl <yanek@ya.bofh.cz>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.172]:5921 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750713AbYECSkz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 May 2008 14:40:55 -0400
Received: by ug-out-1314.google.com with SMTP id h3so353248ugf.16
        for <netdev@vger.kernel.org>; Sat, 03 May 2008 11:40:54 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <481CA037.3000909@ya.bofh.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 03, 2008 at 07:26:15PM +0200, Jan 'yanek' Bortl wrote:
> Jarek Poplawski wrote:
>> ...
>>
>> Here is a suspect #1. (BTW, this place reminds me something...)
>
> Great! Seems to solve my problem. I'll do some tests.

Hi David,

IMHO this patch is needed even if there is something more.

Thanks,
Jarek P.

-------------------->

[NET_SCHED] sch_htb: remove from event queue in htb_parent_to_leaf()

There is lack of removing a class from the event queue while changing
from parent to leaf which can cause corruption of this rb tree. This
patch fixes a bug introduced by my patch: "sch_htb: turn intermediate
classes into leaves" commit: 160d5e10f87b1dc88fd9b84b31b1718e0fd76398.

Many thanks to Jan 'yanek' Bortl for finding a way to reproduce this
rare bug and narrowing the test case, which made possible proper
diagnosing.

This patch is recommended for all kernels starting from 2.6.20.

Reported-and-tested-by: Jan 'yanek' Bortl <yanek@ya.bofh.cz>
Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

---

 net/sched/sch_htb.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 66148cc..5bc1ed4 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -1197,12 +1197,16 @@ static inline int htb_parent_last_child(struct htb_class *cl)
 	return 1;
 }
 
-static void htb_parent_to_leaf(struct htb_class *cl, struct Qdisc *new_q)
+static void htb_parent_to_leaf(struct htb_sched *q, struct htb_class *cl,
+			       struct Qdisc *new_q)
 {
 	struct htb_class *parent = cl->parent;
 
 	BUG_TRAP(!cl->level && cl->un.leaf.q && !cl->prio_activity);
 
+	if (parent->cmode != HTB_CAN_SEND)
+		htb_safe_rb_erase(&parent->pq_node, q->wait_pq + parent->level);
+
 	parent->level = 0;
 	memset(&parent->un.inner, 0, sizeof(parent->un.inner));
 	INIT_LIST_HEAD(&parent->un.leaf.drop_list);
@@ -1300,7 +1304,7 @@ static int htb_delete(struct Qdisc *sch, unsigned long arg)
 		htb_deactivate(q, cl);
 
 	if (last_child)
-		htb_parent_to_leaf(cl, new_q);
+		htb_parent_to_leaf(q, cl, new_q);
 
 	if (--cl->refcnt == 0)
 		htb_destroy_class(sch, cl);
