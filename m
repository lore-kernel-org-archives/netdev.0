From: David Miller <davem@davemloft.net>
Subject: Re: net-next: unitialized lock
Date: Fri, 18 Jul 2008 23:01:01 -0700 (PDT)
Message-ID: <20080718.230101.193691931.davem@davemloft.net>
References: <20080718201945.669917ab@extreme>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38999
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750777AbYGSGBD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Jul 2008 02:01:03 -0400
In-Reply-To: <20080718201945.669917ab@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Fri, 18 Jul 2008 20:19:45 -0700

> Looks like locks on qdisc aren't initialized properly after
> Dave's conversion to MQ.
> 
> # brctl addbr br0
> # ifconfig br0 10.1.1.1
> # ifconfig br0 down

The noqueue_qdisc is missing some initialization, the following
should fix it.

pkt_sched: Fix noqueue_qdisc initialization.

Like noop_qdisc, it needs a dummy backpointer and
explicit qdisc->q.lock initialization.

Based upon a report by Stephen Hemminger.

Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 14cc443..522a41a 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -340,12 +340,19 @@ static struct Qdisc_ops noqueue_qdisc_ops __read_mostly = {
 	.owner		=	THIS_MODULE,
 };
 
+static struct Qdisc noqueue_qdisc;
+static struct netdev_queue noqueue_netdev_queue = {
+	.qdisc		=	&noqueue_qdisc,
+};
+
 static struct Qdisc noqueue_qdisc = {
 	.enqueue	=	NULL,
 	.dequeue	=	noop_dequeue,
 	.flags		=	TCQ_F_BUILTIN,
 	.ops		=	&noqueue_qdisc_ops,
 	.list		=	LIST_HEAD_INIT(noqueue_qdisc.list),
+	.q.lock		=	__SPIN_LOCK_UNLOCKED(noqueue_qdisc.q.lock),
+	.dev_queue	=	&noqueue_netdev_queue,
 };
 
 
