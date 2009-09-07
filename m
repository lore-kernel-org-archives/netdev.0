From: Patrick McHardy <kaber@trash.net>
Subject: Re: net_sched 00/07: classful multiqueue dummy scheduler
Date: Mon, 07 Sep 2009 16:23:27 +0200
Message-ID: <4AA5175F.6030600@trash.net>
References: <20090904164111.27300.29929.sendpatchset@x2.localnet>	<4AA14377.9020200@trash.net> <20090907.015039.154939751.davem@davemloft.net> <4AA503E4.2060504@gmail.com> <4AA50ACF.9010400@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070106020708090303040102"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:35285 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753149AbZIGOX2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Sep 2009 10:23:28 -0400
In-Reply-To: <4AA50ACF.9010400@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------070106020708090303040102
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Patrick McHardy wrote:
> Eric Dumazet wrote:
>> Had very litle time to test this, but got problems very fast, if rate estimator configured.
> 
> I didn't test that, but I'll look into it.
> 
>> qdisc mq 1: root
>>  Sent 528702 bytes 3491 pkt (dropped 0, overlimits 0 requeues 0)
>>  rate 177925Kbit 49pps backlog 0b 0p requeues 0
>> qdisc pfifo 8001: parent 1:1 limit 1000p
>>  Sent 528702 bytes 3491 pkt (dropped 0, overlimits 0 requeues 0)
>>  rate 25400bit 21pps backlog 0b 0p requeues 0
>>
>> <<<crash>>>
> 
> Did you capture the crash?
> 
>> (On another term I had a "ping -i 0.1 192.168.20.120" that gave :
>>
>> 2009/08/07 14:53:42.498 64 bytes from 192.168.20.120: icmp_seq=1982 ttl=64 time=0.126 ms
>> 2009/08/07 14:53:42.598 64 bytes from 192.168.20.120: icmp_seq=1983 ttl=64 time=0.118 ms
>> 2009/08/07 14:53:42.698 64 bytes from 192.168.20.120: icmp_seq=1984 ttl=64 time=0.114 ms
>> 2009/08/07 14:53:42.798 64 bytes from 192.168.20.120: icmp_seq=1985 ttl=64 time=0.123 ms
>> 2009/08/07 14:53:42.898 64 bytes from 192.168.20.120: icmp_seq=1986 ttl=64 time=0.126 ms
>> 2009/08/07 14:53:42.998 64 bytes from 192.168.20.120: icmp_seq=1987 ttl=64 time=0.119 ms
>> 2009/08/07 14:53:43.098 64 bytes from 192.168.20.120: icmp_seq=1988 ttl=64 time=0.122 ms
>> 2009/08/07 14:53:43.198 64 bytes from 192.168.20.120: icmp_seq=1989 ttl=64 time=0.119 ms
>> 2009/08/07 14:53:43.298 64 bytes from 192.168.20.120: icmp_seq=1990 ttl=64 time=0.117 ms
>> 2009/08/07 14:53:43.398 64 bytes from 192.168.20.120: icmp_seq=1991 ttl=64 time=0.117 ms
>> ping: sendmsg: No buffer space available
> 
> Was this also with rate estimators? No buffer space available
> indicates that some class/qdisc isn't dequeued or the packets
> are leaking, so the output of tc -s -d qdisc show ... might be
> helpful.

I figured out the bug, which is likely responsible for both
problems. When grafting a mq class and creating a rate estimator,
the new qdisc is not attached to the device queue yet and also
doesn't have TC_H_ROOT as parent, so qdisc_create() selects
qdisc_root_sleeping_lock() for the estimator, which belongs to
the qdisc that is getting replaced.

This is a patch I used for testing, but I'll come up with
something more elegant (I hope) as a final fix :)



--------------070106020708090303040102
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 2a78d54..428eb34 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -732,7 +732,8 @@ static struct lock_class_key qdisc_rx_lock;
  */
 
 static struct Qdisc *
-qdisc_create(struct net_device *dev, struct netdev_queue *dev_queue,
+qdisc_create(struct net_device *dev, struct Qdisc *p,
+	     struct netdev_queue *dev_queue,
 	     u32 parent, u32 handle, struct nlattr **tca, int *errp)
 {
 	int err;
@@ -810,8 +811,9 @@ qdisc_create(struct net_device *dev, struct netdev_queue *dev_queue,
 		if (tca[TCA_RATE]) {
 			spinlock_t *root_lock;
 
-			if ((sch->parent != TC_H_ROOT) &&
-			    !(sch->flags & TCQ_F_INGRESS))
+			if (((sch->parent != TC_H_ROOT) &&
+			     !(sch->flags & TCQ_F_INGRESS)) &&
+			    (!p || !p->ops->attach))
 				root_lock = qdisc_root_sleeping_lock(sch);
 			else
 				root_lock = qdisc_lock(sch);
@@ -1097,7 +1099,7 @@ create_n_graft:
 	if (!(n->nlmsg_flags&NLM_F_CREATE))
 		return -ENOENT;
 	if (clid == TC_H_INGRESS)
-		q = qdisc_create(dev, &dev->rx_queue,
+		q = qdisc_create(dev, p, &dev->rx_queue,
 				 tcm->tcm_parent, tcm->tcm_parent,
 				 tca, &err);
 	else {
@@ -1106,7 +1108,7 @@ create_n_graft:
 		if (p && p->ops->cl_ops && p->ops->cl_ops->select_queue)
 			ntx = p->ops->cl_ops->select_queue(p, tcm);
 
-		q = qdisc_create(dev, netdev_get_tx_queue(dev, ntx),
+		q = qdisc_create(dev, p, netdev_get_tx_queue(dev, ntx),
 				 tcm->tcm_parent, tcm->tcm_handle,
 				 tca, &err);
 	}

--------------070106020708090303040102--
