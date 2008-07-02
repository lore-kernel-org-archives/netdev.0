From: Patrick McHardy <kaber@trash.net>
Subject: Re: net-sched 04/05: sch_htb: move hash and sibling list removal
 to htb_delete
Date: Wed, 02 Jul 2008 12:11:06 +0200
Message-ID: <486B543A.8040608@trash.net>
References: <20080702081559.GA2764@ami.dom.local>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030408010408010802000906"
Cc: netdev@vger.kernel.org, devik@cdi.cz
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:65161 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753544AbYGBKLJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jul 2008 06:11:09 -0400
In-Reply-To: <20080702081559.GA2764@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------030408010408010802000906
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

Jarek Poplawski wrote:
> Patrick McHardy wrote, On 07/01/2008 04:34 PM:
> ...
>> diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
>> index 0284791..879f0b6 100644
>> --- a/net/sched/sch_htb.c
>> +++ b/net/sched/sch_htb.c
>> @@ -1238,14 +1238,6 @@ static void htb_destroy_class(struct Qdisc *sch, struct htb_class *cl)
>>  
>>  	tcf_destroy_chain(&cl->filter_list);
>>  
>> -	while (!list_empty(&cl->children))
>> -		htb_destroy_class(sch, list_entry(cl->children.next,
>> -						  struct htb_class, sibling));
>> -
>> -	/* note: this delete may happen twice (see htb_delete) */
>> -	hlist_del_init(&cl->hlist);
>> -	list_del(&cl->sibling);
>> -
>>  	if (cl->prio_activity)
>>  		htb_deactivate(q, cl);
> 
> I'll try to check this all more later, but this probably "ain't" good:
> during deactivation a class can use a parent class, so there would be
> a use after kfree if it's not "parents after children". IMHO, it's
> better to do a separate version of htb_destroy_class() for
> htb_destroy(), and skip there htb_deactivate(), tcf_destroy_chain()
> and htb_safe_rb_erase() which are not needed at the moment.

Good point.

Actually deactivation in htb_destroy_class is unnecessary, in
htb_delete() its done immediately anyway (as it should), in
htb_destroy() the entire qdisc is killed atomically and thus
there is no need for deactivation of single classes.

The tcf_destroy_chain() call is harmless since all filters are
already gone when going through qdisc_destroy(). Which leaves
htb_safe_rb_erase(), which looks like it should also be performed
in htb_delete() since otherwise the class will still be visible
in the rb tree in the period between dropping the lock in
htb_delete() and the final destruction in htb_put(). Similar
to deactivation, removal from the rb tree is unnecessary in
the qdisc_destroy() case.

Attached is a incremental patch and the full new patch that
makes these changes.


--------------030408010408010802000906
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 879f0b6..0d49930 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -1237,13 +1237,6 @@ static void htb_destroy_class(struct Qdisc *sch, struct htb_class *cl)
 	qdisc_put_rtab(cl->ceil);
 
 	tcf_destroy_chain(&cl->filter_list);
-
-	if (cl->prio_activity)
-		htb_deactivate(q, cl);
-
-	if (cl->cmode != HTB_CAN_SEND)
-		htb_safe_rb_erase(&cl->pq_node, q->wait_pq + cl->level);
-
 	kfree(cl);
 }
 
@@ -1308,6 +1301,9 @@ static int htb_delete(struct Qdisc *sch, unsigned long arg)
 	if (cl->prio_activity)
 		htb_deactivate(q, cl);
 
+	if (cl->cmode != HTB_CAN_SEND)
+		htb_safe_rb_erase(&cl->pq_node, q->wait_pq + cl->level);
+
 	if (last_child)
 		htb_parent_to_leaf(q, cl, new_q);
 

--------------030408010408010802000906
Content-Type: text/x-diff;
 name="04.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="04.diff"

commit c5b52f74c6b35a570995472295a5dae9d3d3ca74
Author: Patrick McHardy <kaber@trash.net>
Date:   Wed Jul 2 12:10:36 2008 +0200

    net-sched: sch_htb: move hash and sibling list removal to htb_delete
    
    Hash list removal currently happens twice (once in htb_delete, once
    in htb_destroy_class), which makes it harder to use the dynamically
    sized class hash without adding special cases for HTB. The reason is
    that qdisc destruction destroys class in hierarchical order, which
    is not necessary if filters are destroyed in a seperate iteration
    during qdisc destruction.
    
    Adjust qdisc destruction to follow the same scheme as other hierarchical
    qdiscs by first performing a filter destruction pass, then destroying
    all classes in hash order.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 0284791..0d49930 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -1237,21 +1237,6 @@ static void htb_destroy_class(struct Qdisc *sch, struct htb_class *cl)
 	qdisc_put_rtab(cl->ceil);
 
 	tcf_destroy_chain(&cl->filter_list);
-
-	while (!list_empty(&cl->children))
-		htb_destroy_class(sch, list_entry(cl->children.next,
-						  struct htb_class, sibling));
-
-	/* note: this delete may happen twice (see htb_delete) */
-	hlist_del_init(&cl->hlist);
-	list_del(&cl->sibling);
-
-	if (cl->prio_activity)
-		htb_deactivate(q, cl);
-
-	if (cl->cmode != HTB_CAN_SEND)
-		htb_safe_rb_erase(&cl->pq_node, q->wait_pq + cl->level);
-
 	kfree(cl);
 }
 
@@ -1259,6 +1244,9 @@ static void htb_destroy_class(struct Qdisc *sch, struct htb_class *cl)
 static void htb_destroy(struct Qdisc *sch)
 {
 	struct htb_sched *q = qdisc_priv(sch);
+	struct hlist_node *n, *next;
+	struct htb_class *cl;
+	unsigned int i;
 
 	qdisc_watchdog_cancel(&q->watchdog);
 	/* This line used to be after htb_destroy_class call below
@@ -1267,10 +1255,14 @@ static void htb_destroy(struct Qdisc *sch)
 	   unbind_filter on it (without Oops). */
 	tcf_destroy_chain(&q->filter_list);
 
-	while (!list_empty(&q->root))
-		htb_destroy_class(sch, list_entry(q->root.next,
-						  struct htb_class, sibling));
-
+	for (i = 0; i < HTB_HSIZE; i++) {
+		hlist_for_each_entry(cl, n, q->hash + i, hlist)
+			tcf_destroy_chain(&cl->filter_list);
+	}
+	for (i = 0; i < HTB_HSIZE; i++) {
+		hlist_for_each_entry_safe(cl, n, next, q->hash + i, hlist)
+			htb_destroy_class(sch, cl);
+	}
 	__skb_queue_purge(&q->direct_queue);
 }
 
@@ -1302,12 +1294,16 @@ static int htb_delete(struct Qdisc *sch, unsigned long arg)
 		qdisc_tree_decrease_qlen(cl->un.leaf.q, qlen);
 	}
 
-	/* delete from hash and active; remainder in destroy_class */
-	hlist_del_init(&cl->hlist);
+	/* delete from hash, sibling list and active */
+	hlist_del(&cl->hlist);
+	list_del(&cl->sibling);
 
 	if (cl->prio_activity)
 		htb_deactivate(q, cl);
 
+	if (cl->cmode != HTB_CAN_SEND)
+		htb_safe_rb_erase(&cl->pq_node, q->wait_pq + cl->level);
+
 	if (last_child)
 		htb_parent_to_leaf(q, cl, new_q);
 

--------------030408010408010802000906--
