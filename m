From: "Ritesh Kumar" <ritesh@cs.unc.edu>
Subject: Netem tfifo implementation
Date: Fri, 2 Mar 2007 14:01:59 -0500
Message-ID: <f47983b00703021101h344f58e6ife56c01b54f3adaf@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.234]:49856 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964781AbXCBTCB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Mar 2007 14:02:01 -0500
Received: by wr-out-0506.google.com with SMTP id 37so466606wra
        for <netdev@vger.kernel.org>; Fri, 02 Mar 2007 11:02:00 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,
    I recently saw the qdisc "tfifo" in the netem module
(net/sched/sch_netem.c) when I migrated some of my patches from 2.6.14
to 2.6.20. As I understand, tfifo helps in keeping the queue of
packets sorted according to their "time_to_send". [tfifo was not
present in 2.6.14 perhaps because arrival order of packets was always
equal to the departure order]. However, tfifo uses a linear search in
the packet queue to find where to enqueue the packet.
    Quite some time ago (2.6.14 era), I needed a similar functionality
from the netem module and I ended up coding a pointer based min-heap
for the same. I was wondering if the community was interested in using
the min-heap implementation to replace the linear search
implementation. I have tested the min-heap quite a few times and it
seems to work.
    The implementation is slightly non-trivial because it uses
pointers to maintain the heap structure instead if using good old
fixed size arrays. I did this mainly so that the limit of the netem
qdisc could be changed on the fly. However, because every sk_buff now
needs two pointers for its children nodes, I added an extra
(sk_buff*)next2 to struct sk_buff (sorry!). However, this can probably
be changed to a pointer inside netem_skb_cb.  Also, because I needed
this for personal work and 2.6.14 didn't contain tfifo, I basically
removed the embedded qdisc and made netem a classless qdisc with my
min heap as the native "queue" (sorry again! :) )
     My patch on sch_netem.c is included. If there is interest, I will
be glad to make this into a proper tfifo patch along with any more of
your suggestions.


diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index 79542af..66881ab 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -24,6 +24,9 @@

 #include <net/pkt_sched.h>


 #define VERSION "1.2"

 /*     Network Emulation Queuing algorithm.
@@ -53,7 +56,11 @@
 */

  struct netem_sched_data {
-       struct Qdisc    *qdisc;
+       struct sk_buff  *root;          /* The root of the heap of packets */
+       struct sk_buff  *end;           /* The last element in the heap */
+       int     heap_size;                              /* The current
size of the heap */
+       __u64   num_arrivals;           /* records the number of
arrivals; to be used
+                                                                  for
stable ordering in t
he heap */
        struct timer_list timer;

        u32 latency;
@@ -75,11 +82,15 @@ struct netem_sched_data {
                u32  size;
                s16 table[0];
        } *delay_dist;
 };

 /* Time stamp put into socket buffer control block */
  struct netem_skb_cb {
        psched_time_t   time_to_send;
+       __u64                   arrival_order;
 };

 /* init_crandom - initialize correlated random number generator
@@ -139,6 +150,210 @@ static long tabledist(unsigned long mu, long sigma,
        return  x / NETEM_DIST_SCALE + (sigma / NETEM_DIST_SCALE) * t + mu;
 }

+int netem_time_less(struct sk_buff *skb1, struct sk_buff *skb2)
+{
+       int r;
+       struct netem_skb_cb *cb1 = (struct netem_skb_cb *)skb1->cb;
+       struct netem_skb_cb *cb2 = (struct netem_skb_cb *)skb2->cb;
+       r = PSCHED_TDIFF(cb1->time_to_send, cb2->time_to_send);
+       if(r == 0) return (cb1->arrival_order < cb2->arrival_order);
+       else return (r < 0);
+}
+
+int netem_insert_heap(struct sk_buff *skb, struct netem_sched_data *q)
+{
+       struct sk_buff *tmp;
+       struct netem_skb_cb *cb = (struct netem_skb_cb *)skb->cb;
+
+       if(q->heap_size >= q->limit)
+               return NET_XMIT_DROP;
+
+       skb->next = NULL;
+       skb->next2 = NULL;
+       //Use the arrival order in the heap to maintain stability.
cb->arrival order
+       //is 64 bits... so it should take a few years before this wraps around.
+       cb->arrival_order = q->num_arrivals++;
+       //root is the root of the heap. end is the last element of the heap.
+       if(q->root == NULL){
+               q->root = skb;
+               skb->prev = NULL;
+               q->end = skb;
+               goto success;
+       }
+       tmp = q->end;
+       //Note that the pointer next is left and next2 is right.
+       while(tmp->prev != NULL && tmp == tmp->prev->next2) tmp = tmp->prev;
+       if(tmp->prev == NULL){
+               //Complete tree: make a new node at a new level. Also
now, tmp == q->root
+               while(tmp->next != NULL) tmp = tmp->next;
+               tmp->next = skb;
+               skb->prev = tmp;
+       }else if(tmp->prev->next2 == NULL){
+               tmp->prev->next2 = skb;
+               skb->prev = tmp->prev;
+       }else{
+               tmp = tmp->prev->next2;
+               while(tmp->next != NULL) tmp = tmp->next;
+               tmp->next = skb;
+               skb->prev = tmp;
+       }
+
+       //Now skb is at the end of the heap though q->end is not
adjusted as yet.
+       if(netem_time_less(skb, skb->prev))
+               q->end = skb->prev;
+       else
+               q->end = skb;
+       //Time to correct the heap order.
+       while((tmp = skb->prev) != NULL){
+               if(netem_time_less(skb, tmp)){
+                       struct sk_buff *tmp1;
+                       skb->prev = tmp->prev;
+                       if(tmp->next == skb){
+                               tmp->next = skb->next;
+                               if(tmp->next != NULL)
+                                       tmp->next->prev = tmp;
+                               skb->next = tmp;
+                               tmp1 = skb->next2;
+                               skb->next2 = tmp->next2;
+                               tmp->next2 = tmp1;
+                               if(skb->next2 != NULL)
+                                       skb->next2->prev = skb;
+                               if(tmp->next2 != NULL)
+                                       tmp->next2->prev = tmp;
+                       }else{
+                               tmp->next2 = skb->next2;
+                               if(tmp->next2 != NULL)
+                                       tmp->next2->prev = tmp;
+                               skb->next2 = tmp;
+                               tmp1 = skb->next;
+                               skb->next = tmp->next;
+                               tmp->next = tmp1;
+                               if(skb->next != NULL)
+                                       skb->next->prev = skb;
+                               if(tmp->next != NULL)
+                                       tmp->next->prev = tmp;
+                       }
+                       if(tmp->prev == NULL){
+                               q->root = skb;
+                       }else if(tmp->prev->next == tmp){
+                               tmp->prev->next = skb;
+                       }else{
+                               tmp->prev->next2 = skb;
+                       }
+                       tmp->prev = skb;
+               }else
+                       break;
+       }
+
+success:
+       q->heap_size++;
+       return NET_XMIT_SUCCESS;
+}
+
+struct sk_buff *netem_extract_heap(struct netem_sched_data *q)
+{
+       struct sk_buff *ret;
+       struct sk_buff *tmp;
+
+       ret = q->root;
+       if(ret == NULL) return NULL;
+
+       if(ret == q->end){
+               q->root = NULL;
+               q->end = NULL;
+               goto success;
+       }
+
+       tmp = q->end;
+       //Note that the pointer next is left and next2 is right.
+       while(tmp->prev != NULL && tmp == tmp->prev->next) tmp = tmp->prev;
+       if(tmp->prev == NULL){
+               //Also now, tmp == q->root
+               while(tmp->next2 != NULL) tmp = tmp->next2;
+       }else{
+               tmp = tmp->prev->next;
+               while(tmp->next2 != NULL) tmp = tmp->next2;
+       }
+       //tmp is now the new "q->end" unless it is the one being returned.
+       //Splice out q->end and put it at q->root. Then sift it down.
+       q->root = q->end;
+       if(tmp != ret)
+               q->end = tmp;
+       //We know that q->root->next(2) are NULL
+       //To maintain correct tree (border case 3 nodes) first splice...
+       if(q->root->prev->next == q->root)
+               q->root->prev->next = NULL;
+       else
+               q->root->prev->next2 = NULL;
+       //... and then graft.
+       q->root->next = ret->next;
+       if(q->root->next != NULL)
+               q->root->next->prev = q->root;
+       q->root->next2 = ret->next2;
+       if(q->root->next2 != NULL)
+               q->root->next2->prev = q->root;
+       q->root->prev = NULL;
+       //The Siftdown operation from the root.
+       tmp = q->root;
+       while(!(tmp->next == NULL && tmp->next2 == NULL)){
+               struct sk_buff *tmp1;
+               struct sk_buff *tmp2;
+               if(tmp->next == NULL)
+                       tmp1 = tmp->next2;
+               else if(tmp->next2 == NULL)
+                       tmp1 = tmp->next;
+               else{
+                       if(netem_time_less(tmp->next, tmp->next2))
+                               tmp1 = tmp->next;
+                       else
+                               tmp1 = tmp->next2;
+               }
+               if(netem_time_less(tmp1, tmp)){
+                       if(q->end == tmp1)
+                               q->end = tmp;
+                       tmp1->prev = tmp->prev;
+                       if(tmp->next == tmp1){
+                               tmp->next = tmp1->next;
+                               if(tmp->next != NULL)
+                                       tmp->next->prev = tmp;
+                               tmp1->next = tmp;
+                               tmp2 = tmp1->next2;
+                               tmp1->next2 = tmp->next2;
+                               tmp->next2 = tmp2;
+                               if(tmp1->next2 != NULL)
+                                       tmp1->next2->prev = tmp1;
+                               if(tmp->next2 != NULL)
+                                       tmp->next2->prev = tmp;
+                       }else{
+                               tmp->next2 = tmp1->next2;
+                               if(tmp->next2 != NULL)
+                                       tmp->next2->prev = tmp;
+                               tmp1->next2 = tmp;
+                               tmp2 = tmp1->next;
+                               tmp1->next = tmp->next;
+                               tmp->next = tmp2;
+                               if(tmp1->next != NULL)
+                                       tmp1->next->prev = tmp1;
+                               if(tmp->next != NULL)
+                                       tmp->next->prev = tmp;
+                       }
+                       if(tmp->prev == NULL){
+                               q->root = tmp1;
+                       }else if(tmp->prev->next == tmp){
+                               tmp->prev->next = tmp1;
+                       }else{
+                               tmp->prev->next2 = tmp1;
+                       }
+                       tmp->prev = tmp1;
+               }else
+                       break;
+       }
+success:
+       q->heap_size--;
+       ret->next = ret->next2 = ret->prev = NULL;
+       return ret;
+}
+
 /*
  * Insert one skb into qdisc.
  * Note: parent depends on return value to account for queue length.
@@ -214,9 +462,14 @@ static int netem_enqueue(struct sk_buff *skb,
struct Qdisc *sch)
                                  &q->delay_cor, q->delay_dist);

                PSCHED_GET_TIME(now);
                PSCHED_TADD2(now, delay, cb->time_to_send);
                ++q->counter;
-               ret = q->qdisc->enqueue(skb, q->qdisc);
+               //Insert in heap
+               ret = netem_insert_heap(skb, q);
        } else {
                /*
                 * Do re-ordering by putting one out of N packets at the front
@@ -224,7 +477,11 @@ static int netem_enqueue(struct sk_buff *skb,
struct Qdisc *sch)
                 */
                PSCHED_GET_TIME(cb->time_to_send);
                q->counter = 0;
-               ret = q->qdisc->ops->requeue(skb, q->qdisc);
+
+               //Reordering is the same as insert_heap as we changed
the time for skb to now.
+               ret = netem_insert_heap(skb, q);
        }

        if (likely(ret == NET_XMIT_SUCCESS)) {
@@ -244,7 +501,8 @@ static int netem_requeue(struct sk_buff *skb,
struct Qdisc *sch)
        struct netem_sched_data *q = qdisc_priv(sch);
        int ret;

-       if ((ret = q->qdisc->ops->requeue(skb, q->qdisc)) == 0) {
+       //Do a simple insert here as nothing else makes sense
+       if ((ret = netem_insert_heap(skb, q)) == 0) {
                sch->q.qlen++;
                sch->qstats.requeues++;
        }
@@ -257,7 +515,13 @@ static unsigned int netem_drop(struct Qdisc* sch)
        struct netem_sched_data *q = qdisc_priv(sch);
        unsigned int len = 0;

-       if (q->qdisc->ops->drop && (len = q->qdisc->ops->drop(q->qdisc)) != 0) {
+       //Drop a packet from the head of the heap
+       struct sk_buff *skb;
+       skb = netem_extract_heap(q);
+       len = 0;
+       if(skb != NULL){
+               len = skb->len;
+               kfree_skb(skb);
                sch->q.qlen--;
                sch->qstats.drops++;
        }
@@ -269,7 +533,8 @@ static struct sk_buff *netem_dequeue(struct Qdisc *sch)
        struct netem_sched_data *q = qdisc_priv(sch);
        struct sk_buff *skb;
-       skb = q->qdisc->dequeue(q->qdisc);
+       //peek into the heap
+       skb = q->root;
        if (skb) {
                const struct netem_skb_cb *cb
                        = (const struct netem_skb_cb *)skb->cb;
@@ -282,16 +547,12 @@ static struct sk_buff *netem_dequeue(struct Qdisc *sch)
                        pr_debug("netem_dequeue: return skb=%p\n", skb);
                        sch->q.qlen--;
                        sch->flags &= ~TCQ_F_THROTTLED;
+                       netem_extract_heap(q);
                        return skb;
                } else {
                        psched_tdiff_t delay =
PSCHED_TDIFF(cb->time_to_send, now);

-                       if (q->qdisc->ops->requeue(skb, q->qdisc) !=
NET_XMIT_SUCCESS) {
-                               qdisc_tree_decrease_qlen(q->qdisc, 1);
-                               sch->qstats.drops++;
-                               printk(KERN_ERR "netem: queue
discpline %s could not requeu
e\n",
-                                      q->qdisc->ops->id);
-                       }
+                       //Don't do anything (instead of requeuing)

                        mod_timer(&q->timer, jiffies + PSCHED_US2JIFFIE(delay));
                        sch->flags |= TCQ_F_THROTTLED;
@@ -314,34 +575,18 @@ static void netem_reset(struct Qdisc *sch)
 {
        struct netem_sched_data *q = qdisc_priv(sch);

-       qdisc_reset(q->qdisc);
+       struct sk_buff *skb;
+       //purge all the packets (kfree_skb them)
+       while((skb = netem_extract_heap(q)) != NULL)
+               kfree_skb(skb);
+       //Take this oppurtunity to reset arrival count
+       q->num_arrivals = 0;
+
        sch->q.qlen = 0;
        sch->flags &= ~TCQ_F_THROTTLED;
        del_timer_sync(&q->timer);
 }

-/* Pass size change message down to embedded FIFO */
-static int set_fifo_limit(struct Qdisc *q, int limit)
-{
-        struct rtattr *rta;
-       int ret = -ENOMEM;
-
-       /* Hack to avoid sending change message to non-FIFO */
-       if (strncmp(q->ops->id + 1, "fifo", 4) != 0)
-               return 0;
-
-       rta = kmalloc(RTA_LENGTH(sizeof(struct tc_fifo_qopt)), GFP_KERNEL);
-       if (rta) {
-               rta->rta_type = RTM_NEWQDISC;
-               rta->rta_len = RTA_LENGTH(sizeof(struct tc_fifo_qopt));
-               ((struct tc_fifo_qopt *)RTA_DATA(rta))->limit = limit;
-
-               ret = q->ops->change(q, rta);
-               kfree(rta);
-       }
-       return ret;
-}
-
 /*
  * Distribution data is a variable size payload containing
  * signed 16 bit values.
@@ -424,11 +669,6 @@ static int netem_change(struct Qdisc *sch, struct
rtattr *opt)
                return -EINVAL;

        qopt = RTA_DATA(opt);
-       ret = set_fifo_limit(q->qdisc, qopt->limit);
-       if (ret) {
-               pr_debug("netem: can't set fifo limit\n");
-               return ret;
-       }

        q->latency = qopt->latency;
        q->jitter = qopt->jitter;
@@ -571,17 +814,14 @@ static int netem_init(struct Qdisc *sch, struct
rtattr *opt)
        q->timer.function = netem_watchdog;
        q->timer.data = (unsigned long) sch;

-       q->qdisc = qdisc_create_dflt(sch->dev, &tfifo_qdisc_ops,
-                                    TC_H_MAKE(sch->handle, 1));
-       if (!q->qdisc) {
-               pr_debug("netem: qdisc create failed\n");
-               return -ENOMEM;
-       }
+       q->root = NULL;
+       q->end = NULL;
+       q->heap_size = 0;
+       q->num_arrivals = 0;

        ret = netem_change(sch, opt);
        if (ret) {
                pr_debug("netem: change failed\n");
-               qdisc_destroy(q->qdisc);
        }
        return ret;
 }
@@ -591,7 +831,6 @@ static void netem_destroy(struct Qdisc *sch)
        struct netem_sched_data *q = qdisc_priv(sch);

        del_timer_sync(&q->timer);
-       qdisc_destroy(q->qdisc);
        kfree(q->delay_dist);
 }

@@ -635,95 +874,8 @@ rtattr_failure:
        return -1;
 }

-static int netem_dump_class(struct Qdisc *sch, unsigned long cl,
-                         struct sk_buff *skb, struct tcmsg *tcm)
-{
-       struct netem_sched_data *q = qdisc_priv(sch);
-
-       if (cl != 1)    /* only one class */
-               return -ENOENT;
-
-       tcm->tcm_handle |= TC_H_MIN(1);
-       tcm->tcm_info = q->qdisc->handle;
-
-       return 0;
-}
-
-static int netem_graft(struct Qdisc *sch, unsigned long arg, struct Qdisc *new,
-                    struct Qdisc **old)
-{
-       struct netem_sched_data *q = qdisc_priv(sch);
-
-       if (new == NULL)
-               new = &noop_qdisc;
-
-       sch_tree_lock(sch);
-       *old = xchg(&q->qdisc, new);
-       qdisc_tree_decrease_qlen(*old, (*old)->q.qlen);
-       qdisc_reset(*old);
-       sch_tree_unlock(sch);
-
-       return 0;
-}
-
-static struct Qdisc *netem_leaf(struct Qdisc *sch, unsigned long arg)
-{
-       struct netem_sched_data *q = qdisc_priv(sch);
-       return q->qdisc;
-}
-
-static unsigned long netem_get(struct Qdisc *sch, u32 classid)
-{
-       return 1;
-}
-
-static void netem_put(struct Qdisc *sch, unsigned long arg)
-{
-}
-
-static int netem_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
-                           struct rtattr **tca, unsigned long *arg)
-{
-       return -ENOSYS;
-}
-
-static int netem_delete(struct Qdisc *sch, unsigned long arg)
-{
-       return -ENOSYS;
-}
-
-static void netem_walk(struct Qdisc *sch, struct qdisc_walker *walker)
-{
-       if (!walker->stop) {
-               if (walker->count >= walker->skip)
-                       if (walker->fn(sch, 1, walker) < 0) {
-                               walker->stop = 1;
-                               return;
-                       }
-               walker->count++;
-       }
-}
-
-static struct tcf_proto **netem_find_tcf(struct Qdisc *sch, unsigned long cl)
-{
-       return NULL;
-}
-
-static struct Qdisc_class_ops netem_class_ops = {
-       .graft          =       netem_graft,
-       .leaf           =       netem_leaf,
-       .get            =       netem_get,
-       .put            =       netem_put,
-       .change         =       netem_change_class,
-       .delete         =       netem_delete,
-       .walk           =       netem_walk,
-       .tcf_chain      =       netem_find_tcf,
-       .dump           =       netem_dump_class,
-};
-
  static struct Qdisc_ops netem_qdisc_ops = {
        .id             =       "netem",
-       .cl_ops         =       &netem_class_ops,
        .priv_size      =       sizeof(struct netem_sched_data),
        .enqueue        =       netem_enqueue,
        .dequeue        =       netem_dequeue,
