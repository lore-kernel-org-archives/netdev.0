From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] PKT_SCHED: Initialize list field in dummy qdiscs
Date: Fri, 5 Nov 2004 18:58:12 +0100
Message-ID: <20041105175812.GZ12289@postel.suug.ch>
References: <418B4C7C.8000402@crocom.com.pl> <20041105115430.GP19714@rei.reeler.org> <418B4C7C.8000402@crocom.com.pl> <20041105141640.GQ19714@rei.reeler.org> <418BA66A.60804@trash.net> <20041105163951.GY12289@postel.suug.ch> <418BB7D2.6060908@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@oss.sgi.com, spam@crocom.com.pl,
        kuznet@ms2.inr.ac.ru, jmorris@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <418BB7D2.6060908@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Patrick McHardy <418BB7D2.6060908@trash.net> 2004-11-05 18:26
> ops->put seems to be safe even without holding dev->queue_lock.
> The class refcnt is only changed from userspace, and always under
> the rtnl semaphore. get/put are always balanced, so pratically a
> class can never get destroyed by put.

You are right, this cannot be the problem. However, there is a
potential risk in qdisc_destroy if dev->queue_lock is not held.
I'm not sure but aren't all callers to qdisc_destroy holding
qdisc_lock_tree(dev) such as dev_shutdown a potential risk to
deadlocks because __qdisc_destroy tries to lock again?

> Either refcnt them or add add some kind of flag to qdiscs created
> by qdisc_create/qdisc_create_default and check for that flag.
> Initializing the lists doesn't fix all problems, directly using
> noop/noqueue doesn't increment the device refcnt, so is must not
> be dropped it __qdisc_destroy.

I was irritated by the TCQ_F_BUILTIN check in __qdisc_destroy. None
of the code in __qdisc_destroy should be applied to a builtin qdisc
or am I missing something?

The patch below prevents builtin qdiscs from being destroyed and
fixes a refcnt underflow whould lead to a bogus list unlinking
and dev_put.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

--- linux-2.6.10-rc1-bk14.orig/net/sched/sch_generic.c	2004-11-05 18:44:49.000000000 +0100
+++ linux-2.6.10-rc1-bk14/net/sched/sch_generic.c	2004-11-05 18:43:52.000000000 +0100
@@ -479,15 +479,15 @@
 	module_put(ops->owner);
 
 	dev_put(qdisc->dev);
-	if (!(qdisc->flags&TCQ_F_BUILTIN))
-		kfree((char *) qdisc - qdisc->padded);
+	kfree((char *) qdisc - qdisc->padded);
 }
 
 /* Under dev->queue_lock and BH! */
 
 void qdisc_destroy(struct Qdisc *qdisc)
 {
-	if (!atomic_dec_and_test(&qdisc->refcnt))
+	if (qdisc->flags & TCQ_F_BUILTIN ||
+		!atomic_dec_and_test(&qdisc->refcnt))
 		return;
 	list_del(&qdisc->list);
 	call_rcu(&qdisc->q_rcu, __qdisc_destroy);
