From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH] Re: An inconsistency/bug in ingress netem timestamps
Date: Fri, 17 Apr 2009 22:08:49 +0200
Message-ID: <20090417200849.GA2750@ami.dom.local>
References: <20090416.031034.41207844.davem@davemloft.net> <20090416214846.GA9375@ami.dom.local> <20090417.050422.134655407.davem@davemloft.net> <200904171250.02258.alexandre.sidorenko@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"shemminger@vyatta.com" <shemminger@vyatta.com>
To: Alex Sidorenko <alexandre.sidorenko@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ti-out-0910.google.com ([209.85.142.186]:32990 "EHLO
	ti-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750984AbZDQUKa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Apr 2009 16:10:30 -0400
Received: by ti-out-0910.google.com with SMTP id 11so660294tim.23
        for <netdev@vger.kernel.org>; Fri, 17 Apr 2009 13:10:28 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <200904171250.02258.alexandre.sidorenko@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 17, 2009 at 12:50:02PM -0400, Alex Sidorenko wrote:
> On April 17, 2009 08:04:22 am David Miller wrote:
> > Meanwhile, Alexandre can you test Jarek's patch for your case?
> 
> I have applied Jarek's patch to 2.6.29.1 and tested with 'ping'. Everything 
> works fine.
> 
> Alex

Thanks,
Jarek P.
-------------------->
net: sch_netem: Fix an inconsistency in ingress netem timestamps.

Alex Sidorenko reported:

"while experimenting with 'netem' we have found some strange behaviour. It 
seemed that ingress delay as measured by 'ping' command shows up on some 
hosts but not on others.

After some investigation I have found that the problem is that skbuff->tstamp 
field value depends on whether there are any packet sniffers enabled. That 
is:

- if any ptype_all handler is registered, the tstamp field is as expected
- if there are no ptype_all handlers, the tstamp field does not show the delay"

This patch prevents unnecessary update of tstamp in dev_queue_xmit_nit()
on ingress path (with act_mirred) adding a check, so minimal overhead on
the fast path, but only when sniffers etc. are active.

Since netem at ingress seems to logically emulate a network before a host,
tstamp is zeroed to trigger the update and pretend delays are from the
outside.

Reported-by: Alex Sidorenko <alexandre.sidorenko@hp.com>
Tested-by: Alex Sidorenko <alexandre.sidorenko@hp.com>
Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
---

 net/core/dev.c        |    5 +++++
 net/sched/sch_netem.c |    8 ++++++++
 2 files changed, 13 insertions(+), 0 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 91d792d..ca740c0 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1336,7 +1336,12 @@ static void dev_queue_xmit_nit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct packet_type *ptype;
 
+#ifdef CONFIG_NET_CLS_ACT
+	if (!(skb->tstamp.tv64 && (G_TC_FROM(skb->tc_verd) & AT_INGRESS)))
+		net_timestamp(skb);
+#else
 	net_timestamp(skb);
+#endif
 
 	rcu_read_lock();
 	list_for_each_entry_rcu(ptype, &ptype_all, list) {
diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index d876b87..2b88295 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -280,6 +280,14 @@ static struct sk_buff *netem_dequeue(struct Qdisc *sch)
 			if (unlikely(!skb))
 				return NULL;
 
+#ifdef CONFIG_NET_CLS_ACT
+			/*
+			 * If it's at ingress let's pretend the delay is
+			 * from the network (tstamp will be updated).
+			 */
+			if (G_TC_FROM(skb->tc_verd) & AT_INGRESS)
+				skb->tstamp.tv64 = 0;
+#endif
 			pr_debug("netem_dequeue: return skb=%p\n", skb);
 			sch->q.qlen--;
 			return skb;
