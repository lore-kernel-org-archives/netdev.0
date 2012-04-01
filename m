From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [Bug 43018] New: calling function of "dev_queue_xmit()" from a
 interrupt may be deadlock.
Date: Sun, 1 Apr 2012 12:14:52 -0700
Message-ID: <20120401121452.6f8364f8@s6510.linuxnetplumber.net>
References: <bug-43018-100@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: bugzilla-daemon@bugzilla.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:59060 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752599Ab2DATO5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 1 Apr 2012 15:14:57 -0400
In-Reply-To: <bug-43018-100@https.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Redirecting this to netdev list. 

I don't think this bug is possible in normal flow because of the implicit
rules about network devices:

The network standard output path is never called with interrupts
disabled. It is called with soft interrupt disabled (ie when forwarding).
Where in the standard kernel code do you see a possibility of calling
dev_queue_xmit with from an interrupt?

There is one special case which is the netconsole/netpoll code which
calls the network device transmit directly (ndo_start_xmit). This code
takes special precautions to allow being called from an interrupt routine
and does not go through dev_queue_xmit().


On Sat, 31 Mar 2012 02:10:51 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=43018
> 
>            Summary: calling function of "dev_queue_xmit()" from a
>                     interrupt may be deadlock.
>            Product: Networking
>            Version: 2.5
>     Kernel Version: 3.0.26
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: IPV4
>         AssignedTo: shemminger@linux-foundation.org
>         ReportedBy: qiuli.wu@symbio.com
>         Regression: No
> 
> 
> Enter this function to send packet:
> 
> static void net_tx_action(struct softirq_action *h)
> {
>     struct softnet_data *sd = &__get_cpu_var(softnet_data);
> 
>     if (sd->completion_queue) {
>         struct sk_buff *clist;
> 
>         local_irq_disable();
>         clist = sd->completion_queue;
>         sd->completion_queue = NULL;
>         local_irq_enable();
> 
>         while (clist) {
>             struct sk_buff *skb = clist;
>             clist = clist->next;
> 
>             WARN_ON(atomic_read(&skb->users));
>             trace_kfree_skb(skb, net_tx_action);
>             __kfree_skb(skb);
>         }
>     }
> 
>     if (sd->output_queue) {
>         struct Qdisc *head;
> 
>         local_irq_disable();
>         head = sd->output_queue;
>         sd->output_queue = NULL;
>         sd->output_queue_tailp = &sd->output_queue;
>         local_irq_enable();
> 
>         while (head) {
>             struct Qdisc *q = head;
>             spinlock_t *root_lock;
> 
>             head = head->next_sched;
> 
>             root_lock = qdisc_lock(q);
>             if (spin_trylock(root_lock)) {
> //##########################################################################
>                                 //here we have got lock of "root_lock",
>                                 //just this time a interrupt coming ,and 
>                                 //in this interrupt I call "dev_queue_xmit" to
>                                 //send skb and the Qdisc is same one.
> //############################################################################ 
>                 smp_mb__before_clear_bit();
>                 clear_bit(__QDISC_STATE_SCHED,
>                       &q->state);
>                 qdisc_run(q);
>                 spin_unlock(root_lock);
>             } else {
>                 if (!test_bit(__QDISC_STATE_DEACTIVATED,
>                           &q->state)) {
>                     __netif_reschedule(q);
>                 } else {
>                     smp_mb__before_clear_bit();
>                     clear_bit(__QDISC_STATE_SCHED,
>                           &q->state);
>                 }
>             }
>         }
>     }
> }
> 
> 
> //int dev_queue_xmit(struct sk_buff *skb)->__dev_xmit_skb
> 
> static inline int __dev_xmit_skb(struct sk_buff *skb, struct Qdisc *q,
>                  struct net_device *dev,
>                  struct netdev_queue *txq)
> {
>     spinlock_t *root_lock = qdisc_lock(q);
>     bool contended;
>     int rc;
> 
>     qdisc_skb_cb(skb)->pkt_len = skb->len;
>     qdisc_calculate_pkt_len(skb, q);
>     /*
>      * Heuristic to force contended enqueues to serialize on a
>      * separate lock before trying to get qdisc main lock.
>      * This permits __QDISC_STATE_RUNNING owner to get the lock more often
>      * and dequeue packets faster.
>      */
>     contended = qdisc_is_running(q);
>     if (unlikely(contended))
>         spin_lock(&q->busylock);
> //############################################################################  
>         //HERE can't get root_lock,because soft interrupt have got it and it be
>         // interrupted .deadlock happen.
> //#############################################################################
>     spin_lock(root_lock);
>     if (unlikely(test_bit(__QDISC_STATE_DEACTIVATED, &q->state))) {
>         kfree_skb(skb);
>         rc = NET_XMIT_DROP;
>     } else if ((q->flags & TCQ_F_CAN_BYPASS) && !qdisc_qlen(q) &&
>            qdisc_run_begin(q)) {
>         /*
>          * This is a work-conserving queue; there are no old skbs
>          * waiting to be sent out; and the qdisc is not running -
>          * xmit the skb directly.
>          */
>         if (!(dev->priv_flags & IFF_XMIT_DST_RELEASE))
>             skb_dst_force(skb);
> 
>         qdisc_bstats_update(q, skb);
> 
>         if (sch_direct_xmit(skb, q, dev, txq, root_lock)) {
>             if (unlikely(contended)) {
>                 spin_unlock(&q->busylock);
>                 contended = false;
>             }
>             __qdisc_run(q);
>         } else
>             qdisc_run_end(q);
> 
>         rc = NET_XMIT_SUCCESS;
>     } else {
>         skb_dst_force(skb);
>         rc = q->enqueue(skb, q) & NET_XMIT_MASK;
>         if (qdisc_run_begin(q)) {
>             if (unlikely(contended)) {
>                 spin_unlock(&q->busylock);
>                 contended = false;
>             }
>             __qdisc_run(q);
>         }
>     }
>     spin_unlock(root_lock);
>     if (unlikely(contended))
>         spin_unlock(&q->busylock);
>     return rc;
> }
> 
