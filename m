From: sandr8 <sandr8_NOSPAM_@crocetta.org>
Subject: [PATCH 2/4] deferred drop, __parent workaround, reshape_fail
Date: Fri, 13 Aug 2004 02:48:14 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <411C0FCE.9060906@crocetta.org>
Reply-To: sandr8_NOSPAM_@crocetta.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, netfilter-devel@lists.netfilter.org
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca, kuznet@ms2.inr.ac.ru, davem@redhat.com, devik@cdi.cz,
        shemminger@osdl.org, kaber@trash.net, rusty@rustcorp.com.au,
        laforge@netfilter.org
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

2) The second patch eliminates the need for the deprecated __parent 
field and eliminates some tricks such as the rx_class field...
to do so it introduces a slight change in the interface of the enqueue() 
and requeue() operations... the "struct sk_buff * skb" becomes now a 
"struct sk_buff ** const skb". All the in-2.6.8-kernel packet schedulers 
and the core/dev.c are updated consequently... changes are quite trivial 
so there's no issue for out-of-the-kernel-tree schedulers.

in order to make it clearer i should give a broader insight... i hate to 
describe the gory details but it's a bit delicate.

a) the socket buffer for a dropped packet is freed as late as possible 
(lazy lazy lazy!). in other words, locally, a packet is _candidated_ to 
be dropped, but the latest word is the most global one.

who's got the most global viewpoint? Elementary! My Dear Watson! the 
most external enqueuing operation. Ok... now you get it... the stack is 
your friend and will discriminate for free :) the pointer to the socket 
buffer structure always stays at the same location, but is updated by 
the enqueueing operations.

This means that whatever packet "Barabba" is choosen to be dropped 
internally, it can be further saved by the caller, who can exchange it 
with an other victim... (i think there's no need to say who)

b) the changes in (a) made it possible to remove the deprecated
__parent field due to cbq. this is done by handling the reshape 
operation from the outside (in a very stupid loop cycle), whoever
drops whatever.

this way we also avoid saving the class in the rx_class field, calling a 
function that retrieves it and doing complex tricks to cope with the old 
byval api

c) now it's possible to have (almost) a single point (core/dev.c) where 
packets are dropped. Though there are some other few places, the inline 
function before_explicit_drop() easies the centralization of the 
operations. this comes into great help for patch 4.

Also, the empty macro IMPLICIT_DROP() behaves as a marker for the 
reader   and the coder, helping maintainance and readability.

d) yet the reshape_fail field is kept, and the code that handled it in 
the leaf disciplines is kept as well (slightly reworked but kept). this 
just in case some out-of-the-kernel classful schedulers use it: we don't 
want to break them (for what concerns the in-kernel-schedulers, you can 
wipe out all the code related to reshape_fail without any harm, it is 
not any more needed... with regard to it, what about wrapping it in some 
#ifdef CONFIG_TC_DONT_BREAK_OUT_OF_THE_KERNEL_CLASSFUL_SCHEDULERS ?)

NOTA BENE
e) it is darn important that if a packet is dropped all the outmost 
queueing discipline's enqueue()'s return value tells it!

NOTA BENE
f) kfree_skb() for locally allocated socket buffers are still there and 
must stay there

NOTA BENE
g) kfree_skb() whose semantic is to just decrement the user count are 
not a packet drop. furthermore, the same kfree_skb() could have a 
different run-time semantic, and is hence splitted in two, as in the 
following excerpt of code:

         }
 
         if (terminal) {
-            kfree_skb(skb);
+            if( any_dropped(*qres) ){
+                before_explicit_drop(*skb);
+                IMPLICIT_DROP();
+            } else
+                kfree_skb(*skb);
             return NULL;
         }

Alessandro Salvatori
--
the _NOSPAM_ account is the one i am subscribed with, please remove 
_NOSPAM_ for personal replies

diff -NaurX dontdiff 
linux-2.6.8-rc4-netxmitcodes/include/net/pkt_sched.h 
linux-2.6.8-rc4-apichanged/include/net/pkt_sched.h
--- linux-2.6.8-rc4-netxmitcodes/include/net/pkt_sched.h    2004-08-12 
13:31:12.000000000 +0200
+++ linux-2.6.8-rc4-apichanged/include/net/pkt_sched.h    2004-08-12 
16:01:09.134153672 +0200
@@ -52,10 +52,10 @@
     char            id[IFNAMSIZ];
     int            priv_size;
 
-    int             (*enqueue)(struct sk_buff *, struct Qdisc *);
+    int             (*enqueue)(struct sk_buff ** const, struct Qdisc *);
     struct sk_buff *    (*dequeue)(struct Qdisc *);
-    int             (*requeue)(struct sk_buff *, struct Qdisc *);
-    unsigned int        (*drop)(struct Qdisc *);
+    int             (*requeue)(struct sk_buff ** const, struct Qdisc *);
+    unsigned int        (*drop)(struct Qdisc *, struct sk_buff ** const);
 
     int            (*init)(struct Qdisc *, struct rtattr *arg);
     void            (*reset)(struct Qdisc *);
@@ -71,7 +71,7 @@
 
 struct Qdisc
 {
-    int             (*enqueue)(struct sk_buff *skb, struct Qdisc *dev);
+    int             (*enqueue)(struct sk_buff ** const skb, struct 
Qdisc *dev);
     struct sk_buff *    (*dequeue)(struct Qdisc *dev);
     unsigned        flags;
 #define TCQ_F_BUILTIN    1
@@ -88,14 +88,17 @@
     struct tc_stats        stats;
     spinlock_t        *stats_lock;
     struct rcu_head     q_rcu;
-    int            (*reshape_fail)(struct sk_buff *skb, struct Qdisc *q);
-
-    /* This field is deprecated, but it is still used by CBQ
-     * and it will live until better solution will be invented.
-     */
-    struct Qdisc        *__parent;
+    int            (*reshape_fail)(struct sk_buff ** const skb,
+                    struct Qdisc *q);
 };
 
+#define IMPLICIT_DROP() do; while (0) /* readability: just to be aware 
of what you are doing!!! */
+
+static inline void before_explicit_drop(const struct sk_buff * skb)
+{
+    /* for the moment there's nothing to do. see next patch!!! */
+}
+
 #define    QDISC_ALIGN        32
 #define    QDISC_ALIGN_CONST    (QDISC_ALIGN - 1)
 
diff -NaurX dontdiff linux-2.6.8-rc4-netxmitcodes/net/core/dev.c 
linux-2.6.8-rc4-apichanged/net/core/dev.c
--- linux-2.6.8-rc4-netxmitcodes/net/core/dev.c    2004-08-10 
12:27:35.000000000 +0200
+++ linux-2.6.8-rc4-apichanged/net/core/dev.c    2004-08-12 
17:23:43.682947768 +0200
@@ -1341,13 +1341,18 @@
         /* Grab device queue */
         spin_lock_bh(&dev->queue_lock);
 
-        rc = q->enqueue(skb, q);
+        rc = q->enqueue(&skb, q);
 
         qdisc_run(dev);
 
         spin_unlock_bh(&dev->queue_lock);
         rcu_read_unlock();
         rc = rc == NET_XMIT_BYPASS ? NET_XMIT_SUCCESS : rc;
+
+        if(rc!=NET_XMIT_SUCCESS){ /* unlikely? better dynamically IMHO */
+            before_explicit_drop(skb);
+            goto out_kfree_skb;
+        }
         goto out;
     }
     rcu_read_unlock();
@@ -1747,7 +1752,7 @@
         }
         spin_lock(&dev->ingress_lock);
         if ((q = dev->qdisc_ingress) != NULL)
-            result = q->enqueue(skb, q);
+            result = q->enqueue(&skb, q);
         spin_unlock(&dev->ingress_lock);
 
     }
diff -NaurX dontdiff linux-2.6.8-rc4-netxmitcodes/net/sched/sch_api.c 
linux-2.6.8-rc4-apichanged/net/sched/sch_api.c
--- linux-2.6.8-rc4-netxmitcodes/net/sched/sch_api.c    2004-08-10 
12:27:36.000000000 +0200
+++ linux-2.6.8-rc4-apichanged/net/sched/sch_api.c    2004-08-12 
17:00:27.707168344 +0200
@@ -13,6 +13,7 @@
  * Rani Assaf <rani@magic.metawire.com> :980802: JIFFIES and CPU clock 
sources are repaired.
  * Eduardo J. Blanco <ejbs@netlabs.com.uy> :990222: kmod support
  * Jamal Hadi Salim <hadi@nortelnetworks.com>: 990601: ingress support
+ * sandr8 <alessandro.salvatori@eurecom.fr> :040812: api change, 
deferred drop, __parent workaround
  */
 
 #include <linux/config.h>
@@ -95,9 +96,9 @@
 
    ---enqueue
 
-   enqueue returns 0, if packet was enqueued successfully.
+   enqueue returns an even number, if packet was enqueued successfully.
    If packet (this one or another one) was dropped, it returns
-   not zero error code.
+   an odd error code.
    NET_XMIT_DROP     - this packet dropped
      Expected action: do not backoff, but wait until queue will clear.
    NET_XMIT_CN         - probably this packet enqueued, but another one 
dropped.
diff -NaurX dontdiff linux-2.6.8-rc4-netxmitcodes/net/sched/sch_atm.c 
linux-2.6.8-rc4-apichanged/net/sched/sch_atm.c
--- linux-2.6.8-rc4-netxmitcodes/net/sched/sch_atm.c    2004-08-10 
12:27:36.000000000 +0200
+++ linux-2.6.8-rc4-apichanged/net/sched/sch_atm.c    2004-08-12 
16:39:10.000000000 +0200
@@ -398,7 +398,7 @@
 /* --------------------------- Qdisc operations 
---------------------------- */
 
 
-static int atm_tc_enqueue(struct sk_buff *skb,struct Qdisc *sch)
+static int atm_tc_enqueue(struct sk_buff ** const skb,struct Qdisc *sch)
 {
     struct atm_qdisc_data *p = PRIV(sch);
     struct atm_flow_data *flow = NULL ; /* @@@ */
@@ -406,13 +406,13 @@
     int result;
     int ret = NET_XMIT_POLICED;
 
-    D2PRINTK("atm_tc_enqueue(skb %p,sch %p,[qdisc %p])\n",skb,sch,p);
+    D2PRINTK("atm_tc_enqueue(skb %p,sch %p,[qdisc %p])\n",*skb,sch,p);
     result = TC_POLICE_OK; /* be nice to gcc */
-    if (TC_H_MAJ(skb->priority) != sch->handle ||
-        !(flow = (struct atm_flow_data *) atm_tc_get(sch,skb->priority)))
+    if (TC_H_MAJ((*skb)->priority) != sch->handle ||
+        !(flow = (struct atm_flow_data *) 
atm_tc_get(sch,(*skb)->priority)))
         for (flow = p->flows; flow; flow = flow->next)
             if (flow->filter_list) {
-                result = tc_classify(skb,flow->filter_list,
+                result = tc_classify((*skb),flow->filter_list,
                     &res);
                 if (result < 0) continue;
                 flow = (struct atm_flow_data *) res.class;
@@ -422,17 +422,17 @@
     if (!flow) flow = &p->link;
     else {
         if (flow->vcc)
-            ATM_SKB(skb)->atm_options = flow->vcc->atm_options;
+            ATM_SKB(*skb)->atm_options = flow->vcc->atm_options;
             /*@@@ looks good ... but it's not supposed to work :-)*/
 #ifdef CONFIG_NET_CLS_POLICE
         switch (result) {
             case TC_POLICE_SHOT:
-                kfree_skb(skb);
+                IMPLICIT_DROP();
                 break;
             case TC_POLICE_RECLASSIFY:
                 if (flow->excess) flow = flow->excess;
                 else {
-                    ATM_SKB(skb)->atm_options |=
+                    ATM_SKB(*skb)->atm_options |=
                         ATM_ATMOPT_CLP;
                     break;
                 }
@@ -508,8 +508,11 @@
                 struct sk_buff *new;
 
                 new = skb_realloc_headroom(skb,flow->hdr_len);
+                if(!new)
+                    before_explicit_drop(skb);
                 dev_kfree_skb(skb);
-                if (!new) continue;
+                if (!new)
+                    continue;
                 skb = new;
             }
             D2PRINTK("sch_atm_dequeue: ip %p, data %p\n",
@@ -538,12 +541,12 @@
 }
 
 
-static int atm_tc_requeue(struct sk_buff *skb,struct Qdisc *sch)
+static int atm_tc_requeue(struct sk_buff ** const skb,struct Qdisc *sch)
 {
     struct atm_qdisc_data *p = PRIV(sch);
     int ret;
 
-    D2PRINTK("atm_tc_requeue(skb %p,sch %p,[qdisc %p])\n",skb,sch,p);
+    D2PRINTK("atm_tc_requeue(skb %p,sch %p,[qdisc %p])\n",*skb,sch,p);
     ret = p->link.q->ops->requeue(skb,p->link.q);
     if (!ret) sch->q.qlen++;
     else {
@@ -554,7 +557,7 @@
 }
 
 
-static unsigned int atm_tc_drop(struct Qdisc *sch)
+static unsigned int atm_tc_drop(struct Qdisc *sch, struct sk_buff ** 
const  skb)
 {
     struct atm_qdisc_data *p = PRIV(sch);
     struct atm_flow_data *flow;
@@ -562,7 +565,7 @@
 
     DPRINTK("atm_tc_drop(sch %p,[qdisc %p])\n",sch,p);
     for (flow = p->flows; flow; flow = flow->next)
-        if (flow->q->ops->drop && (len = flow->q->ops->drop(flow->q)))
+        if (flow->q->ops->drop && (len = flow->q->ops->drop(flow->q, skb)))
             return len;
     return 0;
 }
diff -NaurX dontdiff linux-2.6.8-rc4-netxmitcodes/net/sched/sch_cbq.c 
linux-2.6.8-rc4-apichanged/net/sched/sch_cbq.c
--- linux-2.6.8-rc4-netxmitcodes/net/sched/sch_cbq.c    2004-08-10 
12:27:36.000000000 +0200
+++ linux-2.6.8-rc4-apichanged/net/sched/sch_cbq.c    2004-08-12 
17:03:46.257984032 +0200
@@ -8,6 +8,8 @@
  *
  * Authors:    Alexey Kuznetsov, <kuznet@ms2.inr.ac.ru>
  *
+ * Fixes:
+ * sandr8 <alessandro.salvatori@eurecom.fr> __parent workaround, 
rx_class removal
  */
 
 #include <linux/config.h>
@@ -170,9 +172,6 @@
     struct cbq_class    *active[TC_CBQ_MAXPRIO+1];    /* List of all 
classes
                                    with backlog */
 
-#ifdef CONFIG_NET_CLS_POLICE
-    struct cbq_class    *rx_class;
-#endif
     struct cbq_class    *tx_class;
     struct cbq_class    *tx_borrowed;
     int            tx_len;
@@ -239,17 +238,17 @@
  */
 
 static struct cbq_class *
-cbq_classify(struct sk_buff *skb, struct Qdisc *sch, int *qres)
+cbq_classify(struct sk_buff ** const skb, struct Qdisc *sch, int *qres)
 {
     struct cbq_sched_data *q = qdisc_priv(sch);
     struct cbq_class *head = &q->link;
     struct cbq_class **defmap;
     struct cbq_class *cl = NULL;
-    u32 prio = skb->priority;
+    u32 prio = (*skb)->priority;
     struct tcf_result res;
 
     /*
-     *  Step 1. If skb->priority points to one of our classes, use it.
+     *  Step 1. If (*skb)->priority points to one of our classes, use it.
      */
     if (TC_H_MAJ(prio^sch->handle) == 0 &&
         (cl = cbq_class_lookup(q, prio)) != NULL)
@@ -265,7 +264,7 @@
         /*
          * Step 2+n. Apply classifier.
          */
-        if (!head->filter_list || (result = tc_classify(skb, 
head->filter_list, &res)) < 0)
+        if (!head->filter_list || (result = tc_classify(*skb, 
head->filter_list, &res)) < 0)
             goto fallback;
 
         if ((cl = (void*)res.class) == NULL) {
@@ -296,14 +295,18 @@
         }
 
         if (terminal) {
-            kfree_skb(skb);
+            if( any_dropped(*qres) ){
+                before_explicit_drop(*skb);
+                IMPLICIT_DROP();
+            } else
+                kfree_skb(*skb);
             return NULL;
         }
 #else
 #ifdef CONFIG_NET_CLS_POLICE
         switch (result) {
         case TC_POLICE_RECLASSIFY:
-            return cbq_reclassify(skb, cl);
+            return cbq_reclassify(*skb, cl);
         case TC_POLICE_SHOT:
             return NULL;
         default:
@@ -417,61 +420,61 @@
 }
 
 static int
-cbq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
+cbq_enqueue(struct sk_buff ** const skb, struct Qdisc *sch)
 {
     struct cbq_sched_data *q = qdisc_priv(sch);
-    int len = skb->len;
     int ret = NET_XMIT_SUCCESS;
     struct cbq_class *cl = cbq_classify(skb, sch,&ret);
 
-#ifdef CONFIG_NET_CLS_POLICE
-    q->rx_class = cl;
-#endif
-    if (cl) {
-#ifdef CONFIG_NET_CLS_POLICE
-        cl->q->__parent = sch;
-#endif
-        if ((ret = cl->q->enqueue(skb, cl->q)) == NET_XMIT_SUCCESS) {
+    while (cl) {
+        cbq_mark_toplevel(q, cl);
+        if ( no_dropped(ret = cl->q->enqueue(skb, cl->q)) ) {
             sch->q.qlen++;
             sch->stats.packets++;
-            sch->stats.bytes+=len;
-            cbq_mark_toplevel(q, cl);
+            sch->stats.bytes+=(*skb)->len;
             if (!cl->next_alive)
                 cbq_activate_class(cl);
             return ret;
+#ifdef CONFIG_NET_CLS_POLICE
+        } else {
+            /* we renqueue the the (latest) dropped packet */
+            cl->stats.drops++;
+           
+            if(cl->police != TC_POLICE_RECLASSIFY)
+                break;
+            /* just one line follows. this is instead of the
+             * old reshape_fail, without the need of the
+             * tricks with rx_class and __parent */
+            cl=cbq_reclassify(*skb, cl);
+#endif
         }
     }
 
 #ifndef CONFIG_NET_CLS_ACT
     sch->stats.drops++;
     if (cl == NULL)
-        kfree_skb(skb);
+        IMPLICIT_DROP();
     else {
         cbq_mark_toplevel(q, cl);
         cl->stats.drops++;
     }
 #else
-    if ( NET_XMIT_DROP == ret) {
+    if ( any_dropped(ret) ) {
         sch->stats.drops++;
     }
-
-    if (cl != NULL) {
-        cbq_mark_toplevel(q, cl);
-        cl->stats.drops++;
-    }
 #endif
     return ret;
 }
 
 static int
-cbq_requeue(struct sk_buff *skb, struct Qdisc *sch)
+cbq_requeue(struct sk_buff ** const skb, struct Qdisc *sch)
 {
     struct cbq_sched_data *q = qdisc_priv(sch);
     struct cbq_class *cl;
     int ret;
 
     if ((cl = q->tx_class) == NULL) {
-        kfree_skb(skb);
+        IMPLICIT_DROP();
         sch->stats.drops++;
         return NET_XMIT_CN;
     }
@@ -479,10 +482,6 @@
 
     cbq_mark_toplevel(q, cl);
 
-#ifdef CONFIG_NET_CLS_POLICE
-    q->rx_class = cl;
-    cl->q->__parent = sch;
-#endif
     if ((ret = cl->q->ops->requeue(skb, cl->q)) == 0) {
         sch->q.qlen++;
         if (!cl->next_alive)
@@ -625,9 +624,13 @@
 
 static void cbq_ovl_drop(struct cbq_class *cl)
 {
+    struct sk_buff * skb;
+
     if (cl->q->ops->drop)
-        if (cl->q->ops->drop(cl->q))
+        if (cl->q->ops->drop(cl->q, &skb)){
+            before_explicit_drop(skb);
             cl->qdisc->q.qlen--;
+        }
     cl->xstats.overactions++;
     cbq_ovl_classic(cl);
 }
@@ -708,42 +711,6 @@
     netif_schedule(sch->dev);
 }
 
-
-#ifdef CONFIG_NET_CLS_POLICE
-
-static int cbq_reshape_fail(struct sk_buff *skb, struct Qdisc *child)
-{
-    int len = skb->len;
-    struct Qdisc *sch = child->__parent;
-    struct cbq_sched_data *q = qdisc_priv(sch);
-    struct cbq_class *cl = q->rx_class;
-
-    q->rx_class = NULL;
-
-    if (cl && (cl = cbq_reclassify(skb, cl)) != NULL) {
-
-        cbq_mark_toplevel(q, cl);
-
-        q->rx_class = cl;
-        cl->q->__parent = sch;
-
-        if (cl->q->enqueue(skb, cl->q) == 0) {
-            sch->q.qlen++;
-            sch->stats.packets++;
-            sch->stats.bytes+=len;
-            if (!cl->next_alive)
-                cbq_activate_class(cl);
-            return 0;
-        }
-        sch->stats.drops++;
-        return 0;
-    }
-
-    sch->stats.drops++;
-    return -1;
-}
-#endif
-
 /*
    It is mission critical procedure.
 
@@ -1268,7 +1235,7 @@
     }
 }
 
-static unsigned int cbq_drop(struct Qdisc* sch)
+static unsigned int cbq_drop(struct Qdisc* sch, struct sk_buff ** 
const  skb)
 {
     struct cbq_sched_data *q = qdisc_priv(sch);
     struct cbq_class *cl, *cl_head;
@@ -1281,7 +1248,7 @@
 
         cl = cl_head;
         do {
-            if (cl->q->ops->drop && (len = cl->q->ops->drop(cl->q))) {
+            if (cl->q->ops->drop && (len = cl->q->ops->drop(cl->q, skb))) {
                 sch->q.qlen--;
                 return len;
             }
@@ -1413,13 +1380,7 @@
 static int cbq_set_police(struct cbq_class *cl, struct tc_cbq_police *p)
 {
     cl->police = p->police;
-
-    if (cl->q->handle) {
-        if (p->police == TC_POLICE_RECLASSIFY)
-            cl->q->reshape_fail = cbq_reshape_fail;
-        else
-            cl->q->reshape_fail = NULL;
-    }
+printk("police set to: %d", cl->police);
     return 0;
 }
 #endif
@@ -1698,11 +1659,6 @@
         if (new == NULL) {
             if ((new = qdisc_create_dflt(sch->dev, &pfifo_qdisc_ops)) 
== NULL)
                 return -ENOBUFS;
-        } else {
-#ifdef CONFIG_NET_CLS_POLICE
-            if (cl->police == TC_POLICE_RECLASSIFY)
-                new->reshape_fail = cbq_reshape_fail;
-#endif
         }
         sch_tree_lock(sch);
         *old = cl->q;
@@ -1764,9 +1720,6 @@
     struct cbq_class *cl;
     unsigned h;
 
-#ifdef CONFIG_NET_CLS_POLICE
-    q->rx_class = NULL;
-#endif
     for (h = 0; h < 16; h++) {
         for (cl = q->classes[h]; cl; cl = cl->next)
             cbq_destroy_filters(cl);
@@ -1790,15 +1743,6 @@
     struct cbq_class *cl = (struct cbq_class*)arg;
 
     if (--cl->refcnt == 0) {
-#ifdef CONFIG_NET_CLS_POLICE
-        struct cbq_sched_data *q = qdisc_priv(sch);
-
-        spin_lock_bh(&sch->dev->queue_lock);
-        if (q->rx_class == cl)
-            q->rx_class = NULL;
-        spin_unlock_bh(&sch->dev->queue_lock);
-#endif
-
         cbq_destroy_class(cl);
     }
 }
@@ -2021,10 +1965,6 @@
         q->tx_class = NULL;
         q->tx_borrowed = NULL;
     }
-#ifdef CONFIG_NET_CLS_POLICE
-    if (q->rx_class == cl)
-        q->rx_class = NULL;
-#endif
 
     cbq_unlink_class(cl);
     cbq_adjust_levels(cl->tparent);
diff -NaurX dontdiff linux-2.6.8-rc4-netxmitcodes/net/sched/sch_dsmark.c 
linux-2.6.8-rc4-apichanged/net/sched/sch_dsmark.c
--- linux-2.6.8-rc4-netxmitcodes/net/sched/sch_dsmark.c    2004-08-10 
12:27:36.000000000 +0200
+++ linux-2.6.8-rc4-apichanged/net/sched/sch_dsmark.c    2004-08-12 
16:39:11.000000000 +0200
@@ -186,38 +186,38 @@
 /* --------------------------- Qdisc operations 
---------------------------- */
 
 
-static int dsmark_enqueue(struct sk_buff *skb,struct Qdisc *sch)
+static int dsmark_enqueue(struct sk_buff ** const skb,struct Qdisc *sch)
 {
     struct dsmark_qdisc_data *p = PRIV(sch);
     struct tcf_result res;
     int result;
     int ret = NET_XMIT_POLICED;
 
-    D2PRINTK("dsmark_enqueue(skb %p,sch %p,[qdisc %p])\n",skb,sch,p);
+    D2PRINTK("dsmark_enqueue(skb %p,sch %p,[qdisc %p])\n",*skb,sch,p);
     if (p->set_tc_index) {
         /* FIXME: Safe with non-linear skbs? --RR */
-        switch (skb->protocol) {
+        switch ((*skb)->protocol) {
             case __constant_htons(ETH_P_IP):
-                skb->tc_index = ipv4_get_dsfield(skb->nh.iph);
+                (*skb)->tc_index = ipv4_get_dsfield((*skb)->nh.iph);
                 break;
             case __constant_htons(ETH_P_IPV6):
-                skb->tc_index = ipv6_get_dsfield(skb->nh.ipv6h);
+                (*skb)->tc_index = ipv6_get_dsfield((*skb)->nh.ipv6h);
                 break;
             default:
-                skb->tc_index = 0;
+                (*skb)->tc_index = 0;
                 break;
         };
     }
     result = TC_POLICE_OK; /* be nice to gcc */
-    if (TC_H_MAJ(skb->priority) == sch->handle) {
-        skb->tc_index = TC_H_MIN(skb->priority);
+    if (TC_H_MAJ((*skb)->priority) == sch->handle) {
+        (*skb)->tc_index = TC_H_MIN((*skb)->priority);
     } else {
-        result = tc_classify(skb,p->filter_list,&res);
+        result = tc_classify(*skb,p->filter_list,&res);
         D2PRINTK("result %d class 0x%04x\n",result,res.classid);
         switch (result) {
 #ifdef CONFIG_NET_CLS_POLICE
             case TC_POLICE_SHOT:
-                kfree_skb(skb);
+                IMPLICIT_DROP(); /* this whole ifdef will never be 
coded! */
                 break;
 #if 0
             case TC_POLICE_RECLASSIFY:
@@ -225,13 +225,13 @@
 #endif
 #endif
             case TC_POLICE_OK:
-                skb->tc_index = TC_H_MIN(res.classid);
+                (*skb)->tc_index = TC_H_MIN(res.classid);
                 break;
             case TC_POLICE_UNSPEC:
                 /* fall through */
             default:
                 if (p->default_index != NO_DEFAULT_INDEX)
-                    skb->tc_index = p->default_index;
+                    (*skb)->tc_index = p->default_index;
                 break;
         };
     }
@@ -240,11 +240,11 @@
         result == TC_POLICE_SHOT ||
 #endif
 
-        ((ret = p->q->enqueue(skb,p->q)) != 0)) {
+        (0x1 & (ret = p->q->enqueue(skb,p->q))) ) {
         sch->stats.drops++;
         return ret;
     }
-    sch->stats.bytes += skb->len;
+    sch->stats.bytes += (*skb)->len;
     sch->stats.packets++;
     sch->q.qlen++;
     return ret;
@@ -289,12 +289,12 @@
 }
 
 
-static int dsmark_requeue(struct sk_buff *skb,struct Qdisc *sch)
+static int dsmark_requeue(struct sk_buff ** const skb,struct Qdisc *sch)
 {
     int ret;
     struct dsmark_qdisc_data *p = PRIV(sch);
 
-    D2PRINTK("dsmark_requeue(skb %p,sch %p,[qdisc %p])\n",skb,sch,p);
+    D2PRINTK("dsmark_requeue(skb %p,sch %p,[qdisc %p])\n",*skb,sch,p);
         if ((ret = p->q->ops->requeue(skb, p->q)) == 0) {
         sch->q.qlen++;
         return 0;
@@ -304,7 +304,7 @@
 }
 
 
-static unsigned int dsmark_drop(struct Qdisc *sch)
+static unsigned int dsmark_drop(struct Qdisc *sch, struct sk_buff ** 
const  skb)
 {
     struct dsmark_qdisc_data *p = PRIV(sch);
     unsigned int len;
@@ -312,7 +312,7 @@
     DPRINTK("dsmark_reset(sch %p,[qdisc %p])\n",sch,p);
     if (!p->q->ops->drop)
         return 0;
-    if (!(len = p->q->ops->drop(p->q)))
+    if (!(len = p->q->ops->drop(p->q, skb)))
         return 0;
     sch->q.qlen--;
     return len;
diff -NaurX dontdiff linux-2.6.8-rc4-netxmitcodes/net/sched/sch_fifo.c 
linux-2.6.8-rc4-apichanged/net/sched/sch_fifo.c
--- linux-2.6.8-rc4-netxmitcodes/net/sched/sch_fifo.c    2004-08-10 
12:27:36.000000000 +0200
+++ linux-2.6.8-rc4-apichanged/net/sched/sch_fifo.c    2004-08-12 
16:39:11.000000000 +0200
@@ -43,30 +43,34 @@
 };
 
 static int
-bfifo_enqueue(struct sk_buff *skb, struct Qdisc* sch)
+bfifo_enqueue(struct sk_buff ** const skb, struct Qdisc* sch)
 {
     struct fifo_sched_data *q = qdisc_priv(sch);
 
-    if (sch->stats.backlog + skb->len <= q->limit) {
-        __skb_queue_tail(&sch->q, skb);
-        sch->stats.backlog += skb->len;
-        sch->stats.bytes += skb->len;
+    if (sch->stats.backlog + (*skb)->len <= q->limit) {
+        __skb_queue_tail(&sch->q, *skb);
+        sch->stats.backlog += (*skb)->len;
+        sch->stats.bytes += (*skb)->len;
         sch->stats.packets++;
         return 0;
     }
     sch->stats.drops++;
 #ifdef CONFIG_NET_CLS_POLICE
-    if (sch->reshape_fail==NULL || sch->reshape_fail(skb, sch))
+    if (sch->reshape_fail==NULL || sch->reshape_fail(skb, sch)){
+#endif
+        IMPLICIT_DROP();
+        return NET_XMIT_DROP;
+#ifdef CONFIG_NET_CLS_POLICE
+    }
+    return NET_XMIT_RESHAPED;
 #endif
-        kfree_skb(skb);
-    return NET_XMIT_DROP;
 }
 
 static int
-bfifo_requeue(struct sk_buff *skb, struct Qdisc* sch)
+bfifo_requeue(struct sk_buff ** const skb, struct Qdisc* sch)
 {
-    __skb_queue_head(&sch->q, skb);
-    sch->stats.backlog += skb->len;
+    __skb_queue_head(&sch->q, *skb);
+    sch->stats.backlog += (*skb)->len;
     return 0;
 }
 
@@ -82,15 +86,13 @@
 }
 
 static unsigned int
-fifo_drop(struct Qdisc* sch)
+fifo_drop(struct Qdisc* sch, struct sk_buff ** const  skb)
 {
-    struct sk_buff *skb;
-
-    skb = __skb_dequeue_tail(&sch->q);
-    if (skb) {
-        unsigned int len = skb->len;
+    *skb = __skb_dequeue_tail(&sch->q);
+    if (*skb) {
+        unsigned int len = (*skb)->len;
         sch->stats.backlog -= len;
-        kfree_skb(skb);
+        IMPLICIT_DROP();
         return len;
     }
     return 0;
@@ -104,28 +106,33 @@
 }
 
 static int
-pfifo_enqueue(struct sk_buff *skb, struct Qdisc* sch)
+pfifo_enqueue(struct sk_buff ** const skb, struct Qdisc* sch)
 {
     struct fifo_sched_data *q = qdisc_priv(sch);
 
     if (sch->q.qlen < q->limit) {
-        __skb_queue_tail(&sch->q, skb);
-        sch->stats.bytes += skb->len;
+        __skb_queue_tail(&sch->q, *skb);
+        sch->stats.bytes += (*skb)->len;
         sch->stats.packets++;
         return 0;
     }
     sch->stats.drops++;
+
+#ifdef CONFIG_NET_CLS_POLICE
+    if (sch->reshape_fail==NULL || sch->reshape_fail(skb, sch)){
+#endif
+        IMPLICIT_DROP();
+        return NET_XMIT_DROP;
 #ifdef CONFIG_NET_CLS_POLICE
-    if (sch->reshape_fail==NULL || sch->reshape_fail(skb, sch))
+    }
+    return NET_XMIT_RESHAPED;
 #endif
-        kfree_skb(skb);
-    return NET_XMIT_DROP;
 }
 
 static int
-pfifo_requeue(struct sk_buff *skb, struct Qdisc* sch)
+pfifo_requeue(struct sk_buff ** const skb, struct Qdisc* sch)
 {
-    __skb_queue_head(&sch->q, skb);
+    __skb_queue_head(&sch->q, *skb);
     return 0;
 }
 
diff -NaurX dontdiff 
linux-2.6.8-rc4-netxmitcodes/net/sched/sch_generic.c 
linux-2.6.8-rc4-apichanged/net/sched/sch_generic.c
--- linux-2.6.8-rc4-netxmitcodes/net/sched/sch_generic.c    2004-08-10 
12:27:36.000000000 +0200
+++ linux-2.6.8-rc4-apichanged/net/sched/sch_generic.c    2004-08-12 
16:39:11.000000000 +0200
@@ -131,6 +131,7 @@
                packet when deadloop is detected.
              */
             if (dev->xmit_lock_owner == smp_processor_id()) {
+                before_explicit_drop(skb);
                 kfree_skb(skb);
                 if (net_ratelimit())
                     printk(KERN_DEBUG "Dead loop on netdevice %s, fix 
it urgently!\n", dev->name);
@@ -149,7 +150,7 @@
            3. device is buggy (ppp)
          */
 
-        q->ops->requeue(skb, q);
+        q->ops->requeue(&skb, q);
         netif_schedule(dev);
         return 1;
     }
@@ -217,9 +218,9 @@
  */
 
 static int
-noop_enqueue(struct sk_buff *skb, struct Qdisc * qdisc)
+noop_enqueue(struct sk_buff ** const skb, struct Qdisc * qdisc)
 {
-    kfree_skb(skb);
+    IMPLICIT_DROP();
     return NET_XMIT_CN;
 }
 
@@ -230,11 +231,11 @@
 }
 
 static int
-noop_requeue(struct sk_buff *skb, struct Qdisc* qdisc)
+noop_requeue(struct sk_buff ** const  skb, struct Qdisc* qdisc)
 {
     if (net_ratelimit())
-        printk(KERN_DEBUG "%s deferred output. It is buggy.\n", 
skb->dev->name);
-    kfree_skb(skb);
+        printk(KERN_DEBUG "%s deferred output. It is buggy.\n", 
(*skb)->dev->name);
+    IMPLICIT_DROP();
     return NET_XMIT_CN;
 }
 
@@ -283,21 +284,21 @@
  */
 
 static int
-pfifo_fast_enqueue(struct sk_buff *skb, struct Qdisc* qdisc)
+pfifo_fast_enqueue(struct sk_buff ** const skb, struct Qdisc* qdisc)
 {
     struct sk_buff_head *list = qdisc_priv(qdisc);
 
-    list += prio2band[skb->priority&TC_PRIO_MAX];
+    list += prio2band[(*skb)->priority&TC_PRIO_MAX];
 
     if (list->qlen < qdisc->dev->tx_queue_len) {
-        __skb_queue_tail(list, skb);
+        __skb_queue_tail(list, (*skb));
         qdisc->q.qlen++;
-        qdisc->stats.bytes += skb->len;
+        qdisc->stats.bytes += (*skb)->len;
         qdisc->stats.packets++;
         return 0;
     }
     qdisc->stats.drops++;
-    kfree_skb(skb);
+    IMPLICIT_DROP();
     return NET_XMIT_DROP;
 }
 
@@ -319,13 +320,13 @@
 }
 
 static int
-pfifo_fast_requeue(struct sk_buff *skb, struct Qdisc* qdisc)
+pfifo_fast_requeue(struct sk_buff ** const  skb, struct Qdisc* qdisc)
 {
     struct sk_buff_head *list = qdisc_priv(qdisc);
 
-    list += prio2band[skb->priority&TC_PRIO_MAX];
+    list += prio2band[(*skb)->priority&TC_PRIO_MAX];
 
-    __skb_queue_head(list, skb);
+    __skb_queue_head(list, *skb);
     qdisc->q.qlen++;
     return 0;
 }
diff -NaurX dontdiff linux-2.6.8-rc4-netxmitcodes/net/sched/sch_gred.c 
linux-2.6.8-rc4-apichanged/net/sched/sch_gred.c
--- linux-2.6.8-rc4-netxmitcodes/net/sched/sch_gred.c    2004-08-10 
12:27:36.000000000 +0200
+++ linux-2.6.8-rc4-apichanged/net/sched/sch_gred.c    2004-08-12 
16:39:11.000000000 +0200
@@ -102,7 +102,7 @@
 };
 
 static int
-gred_enqueue(struct sk_buff *skb, struct Qdisc* sch)
+gred_enqueue(struct sk_buff ** const skb, struct Qdisc* sch)
 {
     psched_time_t now;
     struct gred_sched_data *q=NULL;
@@ -116,7 +116,7 @@
     }
 
 
-    if ( ((skb->tc_index&0xf) > (t->DPs -1)) || 
!(q=t->tab[skb->tc_index&0xf])) {
+    if ( (((*skb)->tc_index&0xf) > (t->DPs -1)) || 
!(q=t->tab[(*skb)->tc_index&0xf])) {
         printk("GRED: setting to default (%d)\n ",t->def);
         if (!(q=t->tab[t->def])) {
             DPRINTK("GRED: setting to default FAILED! dropping!! "
@@ -125,11 +125,11 @@
         }
         /* fix tc_index? --could be controvesial but needed for
            requeueing */
-        skb->tc_index=(skb->tc_index&0xfffffff0) | t->def;
+        (*skb)->tc_index=((*skb)->tc_index&0xfffffff0) | t->def;
     }
 
     D2PRINTK("gred_enqueue virtualQ 0x%x classid %x backlog %d "
-        "general backlog %d\n",skb->tc_index&0xf,sch->handle,q->backlog,
+        "general backlog %d\n",(*skb)->tc_index&0xf,sch->handle,q->backlog,
         sch->stats.backlog);
     /* sum up all the qaves of prios <= to ours to get the new qave*/
     if (!t->eqp && t->grio) {
@@ -144,7 +144,7 @@
     }
 
     q->packetsin++;
-    q->bytesin+=skb->len;
+    q->bytesin+=(*skb)->len;
 
     if (t->eqp && t->grio) {
         qave=0;
@@ -175,12 +175,12 @@
     if ((q->qave+qave) < q->qth_min) {
         q->qcount = -1;
 enqueue:
-        if (q->backlog + skb->len <= q->limit) {
-            q->backlog += skb->len;
+        if (q->backlog + (*skb)->len <= q->limit) {
+            q->backlog += (*skb)->len;
 do_enqueue:
-            __skb_queue_tail(&sch->q, skb);
-            sch->stats.backlog += skb->len;
-            sch->stats.bytes += skb->len;
+            __skb_queue_tail(&sch->q, *skb);
+            sch->stats.backlog += (*skb)->len;
+            sch->stats.bytes += (*skb)->len;
             sch->stats.packets++;
             return 0;
         } else {
@@ -188,7 +188,7 @@
         }
 
 drop:
-        kfree_skb(skb);
+        IMPLICIT_DROP();
         sch->stats.drops++;
         return NET_XMIT_DROP;
     }
@@ -212,17 +212,17 @@
 }
 
 static int
-gred_requeue(struct sk_buff *skb, struct Qdisc* sch)
+gred_requeue(struct sk_buff ** const skb, struct Qdisc* sch)
 {
     struct gred_sched_data *q;
     struct gred_sched *t= qdisc_priv(sch);
-    q= t->tab[(skb->tc_index&0xf)];
+    q= t->tab[((*skb)->tc_index&0xf)];
 /* error checking here -- probably unnecessary */
     PSCHED_SET_PASTPERFECT(q->qidlestart);
 
-    __skb_queue_head(&sch->q, skb);
-    sch->stats.backlog += skb->len;
-    q->backlog += skb->len;
+    __skb_queue_head(&sch->q, *skb);
+    sch->stats.backlog += (*skb)->len;
+    q->backlog += (*skb)->len;
     return 0;
 }
 
@@ -259,29 +259,27 @@
     return NULL;
 }
 
-static unsigned int gred_drop(struct Qdisc* sch)
+static unsigned int gred_drop(struct Qdisc* sch, struct sk_buff ** 
const  skb)
 {
-    struct sk_buff *skb;
-
     struct gred_sched_data *q;
     struct gred_sched *t= qdisc_priv(sch);
 
-    skb = __skb_dequeue_tail(&sch->q);
-    if (skb) {
-        unsigned int len = skb->len;
+    *skb = __skb_dequeue_tail(&sch->q);
+    if (*skb) {
+        unsigned int len = (*skb)->len;
         sch->stats.backlog -= len;
         sch->stats.drops++;
-        q= t->tab[(skb->tc_index&0xf)];
+        q= t->tab[((*skb)->tc_index&0xf)];
         if (q) {
             q->backlog -= len;
             q->other++;
             if (!q->backlog && !t->eqp)
                 PSCHED_GET_TIME(q->qidlestart);
         } else {
-            D2PRINTK("gred_dequeue: skb has bad tcindex 
%x\n",skb->tc_index&0xf);
+            D2PRINTK("gred_dequeue: skb has bad tcindex 
%x\n",(*skb)->tc_index&0xf);
         }
 
-        kfree_skb(skb);
+        IMPLICIT_DROP();
         return len;
     }
 
diff -NaurX dontdiff linux-2.6.8-rc4-netxmitcodes/net/sched/sch_hfsc.c 
linux-2.6.8-rc4-apichanged/net/sched/sch_hfsc.c
--- linux-2.6.8-rc4-netxmitcodes/net/sched/sch_hfsc.c    2004-08-10 
12:27:36.000000000 +0200
+++ linux-2.6.8-rc4-apichanged/net/sched/sch_hfsc.c    2004-08-12 
16:39:11.000000000 +0200
@@ -967,7 +967,8 @@
         return 0;
     }
     len = skb->len;
-    if (unlikely(sch->ops->requeue(skb, sch) != NET_XMIT_SUCCESS)) {
+    if (unlikely(sch->ops->requeue(&skb, sch) != NET_XMIT_SUCCESS)) {
+        before_explicit_drop(skb);
         if (net_ratelimit())
             printk("qdisc_peek_len: failed to requeue\n");
         return 0;
@@ -1238,7 +1239,7 @@
 }
 
 static struct hfsc_class *
-hfsc_classify(struct sk_buff *skb, struct Qdisc *sch, int *qres)
+hfsc_classify(struct sk_buff ** const skb, struct Qdisc *sch, int *qres)
 {
     struct hfsc_sched *q = qdisc_priv(sch);
     struct hfsc_class *cl;
@@ -1246,13 +1247,13 @@
     struct tcf_proto *tcf;
     int result;
 
-    if (TC_H_MAJ(skb->priority ^ sch->handle) == 0 &&
-        (cl = hfsc_find_class(skb->priority, sch)) != NULL)
+    if (TC_H_MAJ((*skb)->priority ^ sch->handle) == 0 &&
+        (cl = hfsc_find_class((*skb)->priority, sch)) != NULL)
         if (cl->level == 0)
             return cl;
 
     tcf = q->root.filter_list;
-    while (tcf && (result = tc_classify(skb, tcf, &res)) >= 0) {
+    while (tcf && (result = tc_classify(*skb, tcf, &res)) >= 0) {
 #ifdef CONFIG_NET_CLS_ACT
         int terminal = 0;
         switch (result) {
@@ -1272,7 +1273,11 @@
         }
 
         if (terminal) {
-            kfree_skb(skb);
+            if( any_dropped(*qres) ){
+                before_explicit_drop(*skb);
+                IMPLICIT_DROP();
+            } else
+                kfree_skb(*skb);
             return NULL;
         }
 #else
@@ -1685,11 +1690,11 @@
 }
 
 static int
-hfsc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
+hfsc_enqueue(struct sk_buff ** const skb, struct Qdisc *sch)
 {
     int ret = NET_XMIT_SUCCESS;
     struct hfsc_class *cl = hfsc_classify(skb, sch, &ret);
-    unsigned int len = skb->len;
+    unsigned int len = (*skb)->len;
     int err;
 
 
@@ -1702,14 +1707,14 @@
     }
 #else
     if (cl == NULL) {
-        kfree_skb(skb);
+        IMPLICIT_DROP();
         sch->stats.drops++;
         return NET_XMIT_DROP;
     }
 #endif
 
     err = cl->qdisc->enqueue(skb, cl->qdisc);
-    if (unlikely(err != NET_XMIT_SUCCESS)) {
+    if (unlikely(any_dropped(err))) {
         cl->stats.drops++;
         sch->stats.drops++;
         return err;
@@ -1797,17 +1802,17 @@
 }
 
 static int
-hfsc_requeue(struct sk_buff *skb, struct Qdisc *sch)
+hfsc_requeue(struct sk_buff ** const skb, struct Qdisc *sch)
 {
     struct hfsc_sched *q = qdisc_priv(sch);
 
-    __skb_queue_head(&q->requeue, skb);
+    __skb_queue_head(&q->requeue, *skb);
     sch->q.qlen++;
     return NET_XMIT_SUCCESS;
 }
 
 static unsigned int
-hfsc_drop(struct Qdisc *sch)
+hfsc_drop(struct Qdisc *sch, struct sk_buff ** const  skb)
 {
     struct hfsc_sched *q = qdisc_priv(sch);
     struct hfsc_class *cl;
@@ -1815,7 +1820,7 @@
 
     list_for_each_entry(cl, &q->droplist, dlist) {
         if (cl->qdisc->ops->drop != NULL &&
-            (len = cl->qdisc->ops->drop(cl->qdisc)) > 0) {
+            (len = cl->qdisc->ops->drop(cl->qdisc, skb)) > 0) {
             if (cl->qdisc->q.qlen == 0) {
                 update_vf(cl, 0, 0);
                 set_passive(cl);
diff -NaurX dontdiff linux-2.6.8-rc4-netxmitcodes/net/sched/sch_htb.c 
linux-2.6.8-rc4-apichanged/net/sched/sch_htb.c
--- linux-2.6.8-rc4-netxmitcodes/net/sched/sch_htb.c    2004-08-10 
12:27:36.000000000 +0200
+++ linux-2.6.8-rc4-apichanged/net/sched/sch_htb.c    2004-08-12 
16:39:11.000000000 +0200
@@ -298,7 +298,7 @@
     return (cl && cl != HTB_DIRECT) ? cl->classid : TC_H_UNSPEC;
 }
 
-static struct htb_class *htb_classify(struct sk_buff *skb, struct Qdisc 
*sch, int *qres)
+static struct htb_class *htb_classify(struct sk_buff ** const skb, 
struct Qdisc *sch, int *qres)
 {
     struct htb_sched *q = qdisc_priv(sch);
     struct htb_class *cl;
@@ -306,16 +306,16 @@
     struct tcf_proto *tcf;
     int result;
 
-    /* allow to select class by setting skb->priority to valid classid;
+    /* allow to select class by setting *skb->priority to valid classid;
        note that nfmark can be used too by attaching filter fw with no
        rules in it */
-    if (skb->priority == sch->handle)
+    if ((*skb)->priority == sch->handle)
         return HTB_DIRECT;  /* X:0 (direct flow) selected */
-    if ((cl = htb_find(skb->priority,sch)) != NULL && cl->level == 0)
+    if ((cl = htb_find((*skb)->priority,sch)) != NULL && cl->level == 0)
         return cl;
 
     tcf = q->filter_list;
-    while (tcf && (result = tc_classify(skb, tcf, &res)) >= 0) {
+    while (tcf && (result = tc_classify(*skb, tcf, &res)) >= 0) {
 #ifdef CONFIG_NET_CLS_ACT
         int terminal = 0;
         switch (result) {
@@ -335,7 +335,11 @@
         }
 
         if (terminal) {
-            kfree_skb(skb);
+            if( any_dropped(*qres) ){
+                before_explicit_drop(*skb);
+                IMPLICIT_DROP();
+            } else
+                kfree_skb(*skb);
             return NULL;
         }
 #else
@@ -709,7 +713,7 @@
     list_del_init(&cl->un.leaf.drop_list);
 }
 
-static int htb_enqueue(struct sk_buff *skb, struct Qdisc *sch)
+static int htb_enqueue(struct sk_buff ** const skb, struct Qdisc *sch)
 {
     int ret = NET_XMIT_SUCCESS;
     struct htb_sched *q = qdisc_priv(sch);
@@ -719,7 +723,7 @@
 #ifdef CONFIG_NET_CLS_ACT
     if (cl == HTB_DIRECT ) {
     if (q->direct_queue.qlen < q->direct_qlen ) {
-        __skb_queue_tail(&q->direct_queue, skb);
+        __skb_queue_tail(&q->direct_queue, *skb);
         q->direct_pkts++;
     }
     } else if (!cl) {
@@ -732,10 +736,10 @@
     if (cl == HTB_DIRECT || !cl) {
     /* enqueue to helper queue */
     if (q->direct_queue.qlen < q->direct_qlen && cl) {
-        __skb_queue_tail(&q->direct_queue, skb);
+        __skb_queue_tail(&q->direct_queue, *skb);
         q->direct_pkts++;
     } else {
-        kfree_skb (skb);
+        IMPLICIT_DROP();
         sch->stats.drops++;
         return NET_XMIT_DROP;
     }
@@ -746,32 +750,31 @@
     cl->stats.drops++;
     return NET_XMIT_DROP;
     } else {
-    cl->stats.packets++; cl->stats.bytes += skb->len;
+    cl->stats.packets++; cl->stats.bytes += (*skb)->len;
     htb_activate (q,cl);
     }
 
     sch->q.qlen++;
-    sch->stats.packets++; sch->stats.bytes += skb->len;
-    HTB_DBG(1,1,"htb_enq_ok cl=%X skb=%p\n",(cl && cl != 
HTB_DIRECT)?cl->classid:0,skb);
+    sch->stats.packets++; sch->stats.bytes += (*skb)->len;
+    HTB_DBG(1,1,"htb_enq_ok cl=%X skb=%p\n",(cl && cl != 
HTB_DIRECT)?cl->classid:0,*skb);
     return NET_XMIT_SUCCESS;
 }
 
 /* TODO: requeuing packet charges it to policers again !! */
-static int htb_requeue(struct sk_buff *skb, struct Qdisc *sch)
+static int htb_requeue(struct sk_buff ** const skb, struct Qdisc *sch)
 {
     struct htb_sched *q = qdisc_priv(sch);
     int ret =  NET_XMIT_SUCCESS;
     struct htb_class *cl = htb_classify(skb,sch, &ret);
-    struct sk_buff *tskb;
 
     if (cl == HTB_DIRECT || !cl) {
     /* enqueue to helper queue */
     if (q->direct_queue.qlen < q->direct_qlen && cl) {
-        __skb_queue_head(&q->direct_queue, skb);
+        __skb_queue_head(&q->direct_queue, *skb);
     } else {
-            __skb_queue_head(&q->direct_queue, skb);
-            tskb = __skb_dequeue_tail(&q->direct_queue);
-            kfree_skb (tskb);
+            __skb_queue_head(&q->direct_queue, *skb);
+            *skb = __skb_dequeue_tail(&q->direct_queue);
+            IMPLICIT_DROP();
             sch->stats.drops++;
             return NET_XMIT_CN;   
     }
@@ -783,7 +786,7 @@
         htb_activate (q,cl);
 
     sch->q.qlen++;
-    HTB_DBG(1,1,"htb_req_ok cl=%X skb=%p\n",(cl && cl != 
HTB_DIRECT)?cl->classid:0,skb);
+    HTB_DBG(1,1,"htb_req_ok cl=%X skb=%p\n",(cl && cl != 
HTB_DIRECT)?cl->classid:0,*skb);
     return NET_XMIT_SUCCESS;
 }
 
@@ -1145,7 +1148,7 @@
 }
 
 /* try to drop from each class (by prio) until one succeed */
-static unsigned int htb_drop(struct Qdisc* sch)
+static unsigned int htb_drop(struct Qdisc* sch, struct sk_buff ** 
const  skb)
 {
     struct htb_sched *q = qdisc_priv(sch);
     int prio;
@@ -1157,7 +1160,7 @@
                               un.leaf.drop_list);
             unsigned int len;
             if (cl->un.leaf.q->ops->drop &&
-                (len = cl->un.leaf.q->ops->drop(cl->un.leaf.q))) {
+                (len = cl->un.leaf.q->ops->drop(cl->un.leaf.q, skb))) {
                 sch->q.qlen--;
                 if (!cl->un.leaf.q->q.qlen)
                     htb_deactivate (q,cl);
diff -NaurX dontdiff 
linux-2.6.8-rc4-netxmitcodes/net/sched/sch_ingress.c 
linux-2.6.8-rc4-apichanged/net/sched/sch_ingress.c
--- linux-2.6.8-rc4-netxmitcodes/net/sched/sch_ingress.c    2004-08-10 
12:27:36.000000000 +0200
+++ linux-2.6.8-rc4-apichanged/net/sched/sch_ingress.c    2004-08-12 
16:39:11.000000000 +0200
@@ -137,14 +137,14 @@
 /* --------------------------- Qdisc operations 
---------------------------- */
 
 
-static int ingress_enqueue(struct sk_buff *skb,struct Qdisc *sch)
+static int ingress_enqueue(struct sk_buff ** const skb,struct Qdisc *sch)
 {
     struct ingress_qdisc_data *p = PRIV(sch);
     struct tcf_result res;
     int result;
 
-    D2PRINTK("ingress_enqueue(skb %p,sch %p,[qdisc %p])\n", skb, sch, p);
-    result = tc_classify(skb, p->filter_list, &res);
+    D2PRINTK("ingress_enqueue(skb %p,sch %p,[qdisc %p])\n", *skb, sch, p);
+    result = tc_classify(*skb, p->filter_list, &res);
     D2PRINTK("result %d class 0x%04x\n", result, res.classid);
     /*
      * Unlike normal "enqueue" functions, ingress_enqueue returns a
@@ -152,7 +152,7 @@
      */
 #ifdef CONFIG_NET_CLS_ACT
     sch->stats.packets++;
-    sch->stats.bytes += skb->len;
+    sch->stats.bytes += (*skb)->len;
     switch (result) {
         case TC_ACT_SHOT:
             result = TC_ACT_SHOT;
@@ -166,7 +166,7 @@
         case TC_ACT_OK:
         case TC_ACT_UNSPEC:
         default:
-            skb->tc_index = TC_H_MIN(res.classid);
+            (*skb)->tc_index = TC_H_MIN(res.classid);
             result = TC_ACT_OK;
             break;
     };
@@ -183,7 +183,7 @@
         case TC_POLICE_UNSPEC:
         default:
         sch->stats.packets++;
-        sch->stats.bytes += skb->len;
+        sch->stats.bytes += (*skb)->len;
         result = NF_ACCEPT;
         break;
     };
@@ -192,7 +192,7 @@
     D2PRINTK("Overriding result to ACCEPT\n");
     result = NF_ACCEPT;
     sch->stats.packets++;
-    sch->stats.bytes += skb->len;
+    sch->stats.bytes += (*skb)->len;
 #endif
 #endif
 
@@ -210,21 +210,24 @@
 }
 
 
-static int ingress_requeue(struct sk_buff *skb,struct Qdisc *sch)
+static int ingress_requeue(struct sk_buff ** const skb,struct Qdisc *sch)
 {
 /*
     struct ingress_qdisc_data *p = PRIV(sch);
-    D2PRINTK("ingress_requeue(skb %p,sch %p,[qdisc 
%p])\n",skb,sch,PRIV(p));
+    D2PRINTK("ingress_requeue(skb %p,sch %p,[qdisc 
%p])\n",*skb,sch,PRIV(p));
 */
     return 0;
 }
 
-static unsigned int ingress_drop(struct Qdisc *sch)
+static unsigned int ingress_drop(struct Qdisc *sch, struct sk_buff ** 
const skb)
 {
 #ifdef DEBUG_INGRESS
     struct ingress_qdisc_data *p = PRIV(sch);
 #endif
     DPRINTK("ingress_drop(sch %p,[qdisc %p])\n", sch, p);
+   
+    *skb=NULL; // if somebody tries to free me... :>
+   
     return 0;
 }
 
@@ -254,8 +257,12 @@
 
     if (dev->qdisc_ingress) {
         spin_lock(&dev->queue_lock);
-        if ((q = dev->qdisc_ingress) != NULL)
-            fwres = q->enqueue(skb, q);
+        if ((q = dev->qdisc_ingress) != NULL){
+            fwres = q->enqueue(pskb, q);
+            if(any_dropped(fwres)){
+                before_explicit_drop(*pskb);
+            }
+        }
         spin_unlock(&dev->queue_lock);
         }
            
diff -NaurX dontdiff linux-2.6.8-rc4-netxmitcodes/net/sched/sch_netem.c 
linux-2.6.8-rc4-apichanged/net/sched/sch_netem.c
--- linux-2.6.8-rc4-netxmitcodes/net/sched/sch_netem.c    2004-08-10 
12:27:36.000000000 +0200
+++ linux-2.6.8-rc4-apichanged/net/sched/sch_netem.c    2004-08-12 
16:39:11.000000000 +0200
@@ -601,14 +601,14 @@
 /* Enqueue packets with underlying discipline (fifo)
  * but mark them with current time first.
  */
-static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
+static int netem_enqueue(struct sk_buff ** const skb, struct Qdisc *sch)
 {
     struct netem_sched_data *q = qdisc_priv(sch);
-    struct netem_skb_cb *cb = (struct netem_skb_cb *)skb->cb;
+    struct netem_skb_cb *cb = (struct netem_skb_cb *)(*skb)->cb;
     psched_time_t now;
     long delay;
 
-    pr_debug("netem_enqueue skb=%p @%lu\n", skb, jiffies);
+    pr_debug("netem_enqueue skb=%p @%lu\n", *skb, jiffies);
 
     /* Random packet drop 0 => none, ~0 => all */
     if (q->loss && q->loss >= net_random()) {
@@ -644,20 +644,20 @@
    
     /* Always queue at tail to keep packets in order */
     if (likely(q->delayed.qlen < q->limit)) {
-        __skb_queue_tail(&q->delayed, skb);
+        __skb_queue_tail(&q->delayed, *skb);
         sch->q.qlen++;
-        sch->stats.bytes += skb->len;
+        sch->stats.bytes += (*skb)->len;
         sch->stats.packets++;
         return 0;
     }
 
     sch->stats.drops++;
-    kfree_skb(skb);
+    IMPLICIT_DROP();
     return NET_XMIT_DROP;
 }
 
 /* Requeue packets but don't change time stamp */
-static int netem_requeue(struct sk_buff *skb, struct Qdisc *sch)
+static int netem_requeue(struct sk_buff ** const skb, struct Qdisc *sch)
 {
     struct netem_sched_data *q = qdisc_priv(sch);
     int ret;
@@ -668,12 +668,12 @@
     return ret;
 }
 
-static unsigned int netem_drop(struct Qdisc* sch)
+static unsigned int netem_drop(struct Qdisc* sch, struct sk_buff ** 
const skb)
 {
     struct netem_sched_data *q = qdisc_priv(sch);
     unsigned int len;
 
-    if ((len = q->qdisc->ops->drop(q->qdisc)) != 0) {
+    if ((len = q->qdisc->ops->drop(q->qdisc, skb)) != 0) {
         sch->q.qlen--;
         sch->stats.drops++;
     }
@@ -706,7 +706,7 @@
         }
         __skb_unlink(skb, &q->delayed);
 
-        if (q->qdisc->enqueue(skb, q->qdisc))
+        if (q->qdisc->enqueue(&skb, q->qdisc))
             sch->stats.drops++;
     }
 
diff -NaurX dontdiff linux-2.6.8-rc4-netxmitcodes/net/sched/sch_prio.c 
linux-2.6.8-rc4-apichanged/net/sched/sch_prio.c
--- linux-2.6.8-rc4-netxmitcodes/net/sched/sch_prio.c    2004-08-10 
12:27:36.000000000 +0200
+++ linux-2.6.8-rc4-apichanged/net/sched/sch_prio.c    2004-08-12 
16:41:53.936487224 +0200
@@ -47,16 +47,16 @@
 };
 
 
-struct Qdisc *prio_classify(struct sk_buff *skb, struct Qdisc *sch,int *r)
+struct Qdisc *prio_classify(struct sk_buff ** const skb, struct Qdisc 
*sch,int *r)
 {
     struct prio_sched_data *q = qdisc_priv(sch);
-    u32 band = skb->priority;
+    u32 band = (*skb)->priority;
     struct tcf_result res;
 
-    if (TC_H_MAJ(skb->priority) != sch->handle) {
+    if (TC_H_MAJ((*skb)->priority) != sch->handle) {
 #ifdef CONFIG_NET_CLS_ACT
         int result = 0, terminal = 0;
-        result = tc_classify(skb, q->filter_list, &res);
+        result = tc_classify(*skb, q->filter_list, &res);
 
         switch (result) {
             case TC_ACT_SHOT:
@@ -74,13 +74,17 @@
             break;
         };
         if (terminal) {
-            kfree_skb(skb);
+            if( any_dropped(*r) ){
+                before_explicit_drop(*skb);
+                IMPLICIT_DROP();
+            } else
+                kfree_skb(*skb);
             return NULL;
-        }
+        }
 
         if (!q->filter_list ) {
 #else
-        if (!q->filter_list || tc_classify(skb, q->filter_list, &res)) {
+        if (!q->filter_list || tc_classify(*skb, q->filter_list, &res)) {
 #endif
             if (TC_H_MAJ(band))
                 band = 0;
@@ -96,7 +100,7 @@
 }
 
 static int
-prio_enqueue(struct sk_buff *skb, struct Qdisc* sch)
+prio_enqueue(struct sk_buff ** const skb, struct Qdisc* sch)
 {
     struct Qdisc *qdisc;
     int ret = NET_XMIT_SUCCESS;
@@ -107,7 +111,7 @@
         goto dropped;
 
     if ((ret = qdisc->enqueue(skb, qdisc)) == NET_XMIT_SUCCESS) {
-        sch->stats.bytes += skb->len;
+        sch->stats.bytes += (*skb)->len;
         sch->stats.packets++;
         sch->q.qlen++;
         return NET_XMIT_SUCCESS;
@@ -128,7 +132,7 @@
 
 
 static int
-prio_requeue(struct sk_buff *skb, struct Qdisc* sch)
+prio_requeue(struct sk_buff ** const skb, struct Qdisc* sch)
 {
     struct Qdisc *qdisc;
     int ret = NET_XMIT_DROP;
@@ -167,7 +171,7 @@
 
 }
 
-static unsigned int prio_drop(struct Qdisc* sch)
+static unsigned int prio_drop(struct Qdisc* sch, struct sk_buff ** 
const  skb)
 {
     struct prio_sched_data *q = qdisc_priv(sch);
     int prio;
@@ -176,7 +180,7 @@
 
     for (prio = q->bands-1; prio >= 0; prio--) {
         qdisc = q->queues[prio];
-        if ((len = qdisc->ops->drop(qdisc)) != 0) {
+        if ((len = qdisc->ops->drop(qdisc, skb)) != 0) {
             sch->q.qlen--;
             return len;
         }
diff -NaurX dontdiff linux-2.6.8-rc4-netxmitcodes/net/sched/sch_red.c 
linux-2.6.8-rc4-apichanged/net/sched/sch_red.c
--- linux-2.6.8-rc4-netxmitcodes/net/sched/sch_red.c    2004-08-10 
12:27:36.000000000 +0200
+++ linux-2.6.8-rc4-apichanged/net/sched/sch_red.c    2004-08-12 
16:39:11.000000000 +0200
@@ -178,7 +178,7 @@
 }
 
 static int
-red_enqueue(struct sk_buff *skb, struct Qdisc* sch)
+red_enqueue(struct sk_buff ** const skb, struct Qdisc* sch)
 {
     struct red_sched_data *q = qdisc_priv(sch);
 
@@ -242,16 +242,16 @@
     if (q->qave < q->qth_min) {
         q->qcount = -1;
 enqueue:
-        if (sch->stats.backlog + skb->len <= q->limit) {
-            __skb_queue_tail(&sch->q, skb);
-            sch->stats.backlog += skb->len;
-            sch->stats.bytes += skb->len;
+        if (sch->stats.backlog + (*skb)->len <= q->limit) {
+            __skb_queue_tail(&sch->q, *skb);
+            sch->stats.backlog += (*skb)->len;
+            sch->stats.bytes += (*skb)->len;
             sch->stats.packets++;
             return NET_XMIT_SUCCESS;
         } else {
             q->st.pdrop++;
         }
-        kfree_skb(skb);
+        IMPLICIT_DROP();
         sch->stats.drops++;
         return NET_XMIT_DROP;
     }
@@ -259,7 +259,7 @@
         q->qcount = -1;
         sch->stats.overlimits++;
 mark:
-        if  (!(q->flags&TC_RED_ECN) || !red_ecn_mark(skb)) {
+        if  (!(q->flags&TC_RED_ECN) || !red_ecn_mark(*skb)) {
             q->st.early++;
             goto drop;
         }
@@ -295,20 +295,20 @@
     goto enqueue;
 
 drop:
-    kfree_skb(skb);
+    IMPLICIT_DROP();
     sch->stats.drops++;
     return NET_XMIT_CN;
 }
 
 static int
-red_requeue(struct sk_buff *skb, struct Qdisc* sch)
+red_requeue(struct sk_buff ** const skb, struct Qdisc* sch)
 {
     struct red_sched_data *q = qdisc_priv(sch);
 
     PSCHED_SET_PASTPERFECT(q->qidlestart);
 
-    __skb_queue_head(&sch->q, skb);
-    sch->stats.backlog += skb->len;
+    __skb_queue_head(&sch->q, *skb);
+    sch->stats.backlog += (*skb)->len;
     return 0;
 }
 
@@ -327,18 +327,17 @@
     return NULL;
 }
 
-static unsigned int red_drop(struct Qdisc* sch)
+static unsigned int red_drop(struct Qdisc* sch, struct sk_buff ** 
const  skb)
 {
-    struct sk_buff *skb;
     struct red_sched_data *q = qdisc_priv(sch);
 
-    skb = __skb_dequeue_tail(&sch->q);
-    if (skb) {
-        unsigned int len = skb->len;
+    *skb = __skb_dequeue_tail(&sch->q);
+    if (*skb) {
+        unsigned int len = (*skb)->len;
         sch->stats.backlog -= len;
         sch->stats.drops++;
         q->st.other++;
-        kfree_skb(skb);
+        IMPLICIT_DROP();
         return len;
     }
     PSCHED_GET_TIME(q->qidlestart);
diff -NaurX dontdiff linux-2.6.8-rc4-netxmitcodes/net/sched/sch_sfq.c 
linux-2.6.8-rc4-apichanged/net/sched/sch_sfq.c
--- linux-2.6.8-rc4-netxmitcodes/net/sched/sch_sfq.c    2004-08-10 
12:27:36.000000000 +0200
+++ linux-2.6.8-rc4-apichanged/net/sched/sch_sfq.c    2004-08-12 
16:39:11.000000000 +0200
@@ -209,11 +209,10 @@
     sfq_link(q, x);
 }
 
-static unsigned int sfq_drop(struct Qdisc *sch)
+static unsigned int sfq_drop(struct Qdisc *sch, struct sk_buff ** const 
skb)
 {
     struct sfq_sched_data *q = qdisc_priv(sch);
     sfq_index d = q->max_depth;
-    struct sk_buff *skb;
     unsigned int len;
 
     /* Queue is full! Find the longest slot and
@@ -221,10 +220,10 @@
 
     if (d > 1) {
         sfq_index x = q->dep[d+SFQ_DEPTH].next;
-        skb = q->qs[x].prev;
-        len = skb->len;
-        __skb_unlink(skb, &q->qs[x]);
-        kfree_skb(skb);
+        *skb = q->qs[x].prev;
+        len = (*skb)->len;
+        __skb_unlink(*skb, &q->qs[x]);
+        IMPLICIT_DROP();
         sfq_dec(q, x);
         sch->q.qlen--;
         sch->stats.drops++;
@@ -236,10 +235,10 @@
         d = q->next[q->tail];
         q->next[q->tail] = q->next[d];
         q->allot[q->next[d]] += q->quantum;
-        skb = q->qs[d].prev;
-        len = skb->len;
-        __skb_unlink(skb, &q->qs[d]);
-        kfree_skb(skb);
+        *skb = q->qs[d].prev;
+        len = (*skb)->len;
+        __skb_unlink(*skb, &q->qs[d]);
+        IMPLICIT_DROP();
         sfq_dec(q, d);
         sch->q.qlen--;
         q->ht[q->hash[d]] = SFQ_DEPTH;
@@ -251,10 +250,10 @@
 }
 
 static int
-sfq_enqueue(struct sk_buff *skb, struct Qdisc* sch)
+sfq_enqueue(struct sk_buff ** const skb, struct Qdisc* sch)
 {
     struct sfq_sched_data *q = qdisc_priv(sch);
-    unsigned hash = sfq_hash(q, skb);
+    unsigned hash = sfq_hash(q, *skb);
     sfq_index x;
 
     x = q->ht[hash];
@@ -262,7 +261,7 @@
         q->ht[hash] = x = q->dep[SFQ_DEPTH].next;
         q->hash[x] = hash;
     }
-    __skb_queue_tail(&q->qs[x], skb);
+    __skb_queue_tail(&q->qs[x], *skb);
     sfq_inc(q, x);
     if (q->qs[x].qlen == 1) {        /* The flow is new */
         if (q->tail == SFQ_DEPTH) {    /* It is the first flow */
@@ -276,20 +275,20 @@
         }
     }
     if (++sch->q.qlen < q->limit-1) {
-        sch->stats.bytes += skb->len;
+        sch->stats.bytes += (*skb)->len;
         sch->stats.packets++;
         return 0;
     }
 
-    sfq_drop(sch);
+    sfq_drop(sch, skb);
     return NET_XMIT_CN;
 }
 
 static int
-sfq_requeue(struct sk_buff *skb, struct Qdisc* sch)
+sfq_requeue(struct sk_buff ** const skb, struct Qdisc* sch)
 {
     struct sfq_sched_data *q = qdisc_priv(sch);
-    unsigned hash = sfq_hash(q, skb);
+    unsigned hash = sfq_hash(q, *skb);
     sfq_index x;
 
     x = q->ht[hash];
@@ -297,7 +296,7 @@
         q->ht[hash] = x = q->dep[SFQ_DEPTH].next;
         q->hash[x] = hash;
     }
-    __skb_queue_head(&q->qs[x], skb);
+    __skb_queue_head(&q->qs[x], *skb);
     sfq_inc(q, x);
     if (q->qs[x].qlen == 1) {        /* The flow is new */
         if (q->tail == SFQ_DEPTH) {    /* It is the first flow */
@@ -314,7 +313,7 @@
         return 0;
 
     sch->stats.drops++;
-    sfq_drop(sch);
+    sfq_drop(sch, skb);
     return NET_XMIT_CN;
 }
 
@@ -362,8 +361,10 @@
 {
     struct sk_buff *skb;
 
-    while ((skb = sfq_dequeue(sch)) != NULL)
+    while ((skb = sfq_dequeue(sch)) != NULL){
+        before_explicit_drop(skb);
         kfree_skb(skb);
+    }
 }
 
 static void sfq_perturbation(unsigned long arg)
@@ -394,8 +395,11 @@
     if (ctl->limit)
         q->limit = min_t(u32, ctl->limit, SFQ_DEPTH);
 
-    while (sch->q.qlen >= q->limit-1)
-        sfq_drop(sch);
+    struct sk_buff * skb;
+    while (sch->q.qlen >= q->limit-1){
+        sfq_drop(sch, &skb);
+        before_explicit_drop(skb);
+    }
 
     del_timer(&q->perturb_timer);
     if (q->perturb_period) {
diff -NaurX dontdiff linux-2.6.8-rc4-netxmitcodes/net/sched/sch_tbf.c 
linux-2.6.8-rc4-apichanged/net/sched/sch_tbf.c
--- linux-2.6.8-rc4-netxmitcodes/net/sched/sch_tbf.c    2004-08-10 
12:27:36.000000000 +0200
+++ linux-2.6.8-rc4-apichanged/net/sched/sch_tbf.c    2004-08-12 
16:39:11.000000000 +0200
@@ -135,19 +135,23 @@
 #define L2T(q,L)   ((q)->R_tab->data[(L)>>(q)->R_tab->rate.cell_log])
 #define L2T_P(q,L) ((q)->P_tab->data[(L)>>(q)->P_tab->rate.cell_log])
 
-static int tbf_enqueue(struct sk_buff *skb, struct Qdisc* sch)
+static int tbf_enqueue(struct sk_buff ** const skb, struct Qdisc* sch)
 {
     struct tbf_sched_data *q = qdisc_priv(sch);
     int ret;
 
-    if (skb->len > q->max_size) {
+    if ((*skb)->len > q->max_size) {
         sch->stats.drops++;
+
 #ifdef CONFIG_NET_CLS_POLICE
-        if (sch->reshape_fail == NULL || sch->reshape_fail(skb, sch))
+        if (sch->reshape_fail==NULL || sch->reshape_fail(skb, sch)){
+#endif
+            IMPLICIT_DROP();
+            return NET_XMIT_DROP;
+#ifdef CONFIG_NET_CLS_POLICE
+        }
+        return NET_XMIT_RESHAPED;
 #endif
-            kfree_skb(skb);
-
-        return NET_XMIT_DROP;
     }
 
     if ((ret = q->qdisc->enqueue(skb, q->qdisc)) != 0) {
@@ -156,12 +160,12 @@
     }
 
     sch->q.qlen++;
-    sch->stats.bytes += skb->len;
+    sch->stats.bytes += (*skb)->len;
     sch->stats.packets++;
     return 0;
 }
 
-static int tbf_requeue(struct sk_buff *skb, struct Qdisc* sch)
+static int tbf_requeue(struct sk_buff ** const skb, struct Qdisc* sch)
 {
     struct tbf_sched_data *q = qdisc_priv(sch);
     int ret;
@@ -172,12 +176,12 @@
     return ret;
 }
 
-static unsigned int tbf_drop(struct Qdisc* sch)
+static unsigned int tbf_drop(struct Qdisc* sch, struct sk_buff ** const 
skb)
 {
     struct tbf_sched_data *q = qdisc_priv(sch);
     unsigned int len;
 
-    if ((len = q->qdisc->ops->drop(q->qdisc)) != 0) {
+    if ((len = q->qdisc->ops->drop(q->qdisc, skb)) != 0) {
         sch->q.qlen--;
         sch->stats.drops++;
     }
@@ -247,8 +251,9 @@
            (cf. CSZ, HPFQ, HFSC)
          */
 
-        if (q->qdisc->ops->requeue(skb, q->qdisc) != NET_XMIT_SUCCESS) {
+        if (q->qdisc->ops->requeue(&skb, q->qdisc) != NET_XMIT_SUCCESS) {
             /* When requeue fails skb is dropped */
+            before_explicit_drop(skb);
             sch->q.qlen--;
             sch->stats.drops++;
         }
diff -NaurX dontdiff linux-2.6.8-rc4-netxmitcodes/net/sched/sch_teql.c 
linux-2.6.8-rc4-apichanged/net/sched/sch_teql.c
--- linux-2.6.8-rc4-netxmitcodes/net/sched/sch_teql.c    2004-08-10 
12:27:36.000000000 +0200
+++ linux-2.6.8-rc4-apichanged/net/sched/sch_teql.c    2004-08-12 
16:39:43.808269720 +0200
@@ -88,30 +88,30 @@
 /* "teql*" qdisc routines */
 
 static int
-teql_enqueue(struct sk_buff *skb, struct Qdisc* sch)
+teql_enqueue(struct sk_buff ** const skb, struct Qdisc* sch)
 {
     struct net_device *dev = sch->dev;
     struct teql_sched_data *q = qdisc_priv(sch);
 
-    __skb_queue_tail(&q->q, skb);
+    __skb_queue_tail(&q->q, *skb);
     if (q->q.qlen <= dev->tx_queue_len) {
-        sch->stats.bytes += skb->len;
+        sch->stats.bytes += (*skb)->len;
         sch->stats.packets++;
         return 0;
     }
 
-    __skb_unlink(skb, &q->q);
-    kfree_skb(skb);
+    __skb_unlink(*skb, &q->q);
+    IMPLICIT_DROP();
     sch->stats.drops++;
     return NET_XMIT_DROP;
 }
 
 static int
-teql_requeue(struct sk_buff *skb, struct Qdisc* sch)
+teql_requeue(struct sk_buff ** const skb, struct Qdisc* sch)
 {
     struct teql_sched_data *q = qdisc_priv(sch);
 
-    __skb_queue_head(&q->q, skb);
+    __skb_queue_head(&q->q, *skb);
     return 0;
 }
 
@@ -340,6 +340,7 @@
 
 drop:
     master->stats.tx_dropped++;
+    before_explicit_drop(skb);
     dev_kfree_skb(skb);
     return 0;
 }
