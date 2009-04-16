From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: An inconsistency/bug in ingress netem timestamps
Date: Thu, 16 Apr 2009 23:48:46 +0200
Message-ID: <20090416214846.GA9375@ami.dom.local>
References: <20090416.031034.41207844.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: alexandre.sidorenko@hp.com, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f169.google.com ([209.85.218.169]:60104 "EHLO
	mail-bw0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750916AbZDPVto (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2009 17:49:44 -0400
Received: by bwz17 with SMTP id 17so629988bwz.37
        for <netdev@vger.kernel.org>; Thu, 16 Apr 2009 14:49:42 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20090416.031034.41207844.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote, On 04/16/2009 12:10 PM:

> From: Alex Sidorenko <alexandre.sidorenko@hp.com>
> Date: Wed, 15 Apr 2009 16:10:43 -0400
> 
>> On April 15, 2009 03:50:22 pm Jarek Poplawski wrote:
>>
>>> Isn't it when act_mirred calls dev_queue_xmit with dev_queue_xmit_nit?
>>> But, as above mentioned, I doubt it's "updated properly" in this case.
>> I can see that dev_queue_xmit_nit calls net_timestamp(skb) unconditionally. I 
>> agree that to fix this properly we need to update tstamp in another place 
>> explicitly (in ifb or netem?).
> 
> Since IFB completely bypasses netif_rx() and netif_receive_skb() I
> think it should unconditionally set skb->tstamp.tv64 to zero and
> invoke net_timestamp()

IFB calls netif_rx() and I don't understand why do we need to update
tstamp again except for this netem case.

> This would match the behavior of loopback and tunnels, and in my
> opinion this is reasonable.  There will be virtually no overhead
> added unless timestamping is enabled via ping or similar, and in
> return we get what I think is correctness :-)

I think we need some consistency in counting or not counting packet
scheduling delays into timestamps. Anyway we should avoid unnecessary
updates like now, so I'm proposing something different (for testing).

Jarek P.
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
