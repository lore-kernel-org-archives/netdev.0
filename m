From: Patrick McHardy <kaber@trash.net>
Subject: Re: Fw: BUG: atomic counter underflow when running "rmmod tg3" on
 2.6.10-rc1-mm3
Date: Tue, 09 Nov 2004 06:51:31 +0100
Message-ID: <41905AE3.8040509@trash.net>
References: <20041108214159.6400e8de.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010708020604060505080903"
Cc: netdev@oss.sgi.com, Bernhard Rosenkraenzer <bero@arklinux.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20041108214159.6400e8de.akpm@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------010708020604060505080903
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Andrew Morton wrote:

>There's a debug patch in -mm which generates a trace when someone does
>atomic_dec_and_test() on an atomic_t which already has a value of zero.
>
>ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.10-rc1/2.6.10-rc1-mm3/broken-out/detect-atomic-counter-underflows.patch
>
>It looks like it has found a problem in qdisc_destroy().
>  
>
Already fixed in latest -bk by the attached patch. The builtin qdiscs
are not refcounted, but qdisc_destroy treated them as other qdiscs.

Regards
Patrick


--------------010708020604060505080903
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/11/05 16:30:34-08:00 tgraf@suug.ch 
#   [PKT_SCHED]: Builtin qdiscs should avoid all qdisc_destroy() processing.
#   
#   None of the code in __qdisc_destroy should be applied to a builtin qdisc
#   or am I missing something?
#   
#   The patch below prevents builtin qdiscs from being destroyed and
#   fixes a refcnt underflow whould lead to a bogus list unlinking
#   and dev_put.
#   
#   Signed-off-by: Thomas Graf <tgraf@suug.ch>
#   Signed-off-by: David S. Miller <davem@davemloft.net>
# 
# net/sched/sch_generic.c
#   2004/11/05 16:30:14-08:00 tgraf@suug.ch +3 -3
#   [PKT_SCHED]: Builtin qdiscs should avoid all qdisc_destroy() processing.
#   
#   None of the code in __qdisc_destroy should be applied to a builtin qdisc
#   or am I missing something?
#   
#   The patch below prevents builtin qdiscs from being destroyed and
#   fixes a refcnt underflow whould lead to a bogus list unlinking
#   and dev_put.
#   
#   Signed-off-by: Thomas Graf <tgraf@suug.ch>
#   Signed-off-by: David S. Miller <davem@davemloft.net>
# 
diff -Nru a/net/sched/sch_generic.c b/net/sched/sch_generic.c
--- a/net/sched/sch_generic.c	2004-11-09 06:50:10 +01:00
+++ b/net/sched/sch_generic.c	2004-11-09 06:50:10 +01:00
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

--------------010708020604060505080903--
