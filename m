From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 2.6] CBQ: Destroy filters before destroying classes
Date: Tue, 19 Oct 2004 21:39:06 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041019213906.2aced91d.davem@davemloft.net>
References: <20041007175313.GA19628@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20041007175313.GA19628@postel.suug.ch>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 7 Oct 2004 19:53:13 +0200
Thomas Graf <tgraf@suug.ch> wrote:

> CBQ destroys its classes by traversing the hashtable and thus classes
> are not destroyed from root to leafs which means that class Y being
> a subclass of class X may be destroyed before X. This is a problem
> if a filter is attached to class X (parent) classifying into class Y
> (result). In case Y gets deleted before X the filter references an
> already deleted class while trying to unbind (cbq_unbind_filter).
> Therefore all filters must be destroyed before destroying classes. An
> additional BUG_TRAP has been added to document this not so obvious case.

Applied, thanks a lot Thomas.

> Patch is relative to  "Convert Qdiscs to use generic network
> statistics/estimator" patchset.

BTW, that patch set forgot to handle sch_atm.c, I'm beginning to
believe that I'm the only developer with this packet scheduler
enabled in his test builds :-)  Most people don't have it enabled
because it requires CONFIG_ATM to be on.

Anyways, I fixed that up as follows.

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/10/19 21:11:02-07:00 davem@nuts.davemloft.net 
#   [PKT_SCHED]: Fix sch_atm build.
#   
#   Move it over to use qstats/bstats.
#   
#   Signed-off-by: David S. Miller <davem@davemloft.net>
# 
# net/sched/sch_atm.c
#   2004/10/19 21:10:26-07:00 davem@nuts.davemloft.net +4 -4
#   [PKT_SCHED]: Fix sch_atm build.
# 
diff -Nru a/net/sched/sch_atm.c b/net/sched/sch_atm.c
--- a/net/sched/sch_atm.c	2004-10-19 21:21:59 -07:00
+++ b/net/sched/sch_atm.c	2004-10-19 21:21:59 -07:00
@@ -449,12 +449,12 @@
 	    result == TC_POLICE_SHOT ||
 #endif
 	    (ret = flow->q->enqueue(skb,flow->q)) != 0) {
-		sch->stats.drops++;
+		sch->qstats.drops++;
 		if (flow) flow->stats.drops++;
 		return ret;
 	}
-	sch->stats.bytes += skb->len;
-	sch->stats.packets++;
+	sch->bstats.bytes += skb->len;
+	sch->bstats.packets++;
 	flow->stats.bytes += skb->len;
 	flow->stats.packets++;
 	/*
@@ -547,7 +547,7 @@
 	ret = p->link.q->ops->requeue(skb,p->link.q);
 	if (!ret) sch->q.qlen++;
 	else {
-		sch->stats.drops++;
+		sch->qstats.drops++;
 		p->link.stats.drops++;
 	}
 	return ret;
