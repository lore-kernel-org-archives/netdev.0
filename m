From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: PROBLEM: kernel lockup while changing TC rules
Date: Sat, 3 May 2008 18:39:39 +0200
Message-ID: <20080503163939.GA6484@ami.dom.local>
References: <20080503071651.GA3313@ami.dom.local> <481C33D2.2090308@ya.bofh.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jan 'yanek' Bortl <yanek@ya.bofh.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.153]:44287 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761738AbYECQiy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 May 2008 12:38:54 -0400
Received: by fg-out-1718.google.com with SMTP id 19so1356391fgg.17
        for <netdev@vger.kernel.org>; Sat, 03 May 2008 09:38:49 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <481C33D2.2090308@ya.bofh.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 03, 2008 at 11:43:46AM +0200, Jan 'yanek' Bortl wrote:
...
>>> I have found this problem with today's git (2.6.25-00000-ge4c576b) and 2.6.25:
>>
>> Does this mean the bug triggers in 2.6.25 and later, but not in 2.6.24?
>> If so, is it possible to reproduce this e.g. with 2.6.25-rc6?
>
> I firstly discovered this on 2.6.22-6~bpo40+1 (debian's backports), but 
> I'm not sure if that was same thing (it is long ago).
>
> Now i tested on test machine with these kernels:
> 2.6.24, 2.6.24.6  
> (http://ya.bofh.cz/archive/kernel-2.6-htbcrash/2/netconsole-2.6.24.6-slon.txt), 
> 2.6.25
>
> I can test anything you want.

Here is a suspect #1. (BTW, this place reminds me something...)

Thanks,
Jarek P.

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
