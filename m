From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next] pkt_sched: fq: Fair Queue packet scheduler
Date: Wed, 04 Sep 2013 04:27:09 -0700
Message-ID: <1378294029.7360.92.camel@edumazet-glaptop>
References: <1377816595.8277.54.camel@edumazet-glaptop>
	 <5226C4A0.6040709@redhat.com> <1378274376.7360.82.camel@edumazet-glaptop>
	 <5226D39C.9070401@redhat.com> <1378290638.7360.85.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	"Michael S. Tsirkin" <mst@redhat.com>
To: Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:44807 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756563Ab3IDL1M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Sep 2013 07:27:12 -0400
Received: by mail-pd0-f169.google.com with SMTP id r10so176592pdi.0
        for <netdev@vger.kernel.org>; Wed, 04 Sep 2013 04:27:11 -0700 (PDT)
In-Reply-To: <1378290638.7360.85.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-09-04 at 03:30 -0700, Eric Dumazet wrote:
> On Wed, 2013-09-04 at 14:30 +0800, Jason Wang wrote:
> 
> > > And tcpdump would certainly help ;)
> > 
> > See attachment.
> > 
> 
> Nothing obvious on tcpdump (only that lot of frames are missing)
> 
> 1) Are you capturing part of the payload only (like tcpdump -s 128)
> 
> 2) What is the setup.
> 
> 3) tc -s -d qdisc

If you use FQ in the guest, then it could be that high resolution timers
have high latency ?

So FQ arms short timers, but effective duration could be much longer.

Here I get a smooth latency of up to ~3 us

lpq83:~# ./netperf -H lpq84 ; ./tc -s -d qd ; dmesg | tail -n1
MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to lpq84.prod.google.com () port 0 AF_INET
Recv   Send    Send                          
Socket Socket  Message  Elapsed              
Size   Size    Size     Time     Throughput  
bytes  bytes   bytes    secs.    10^6bits/sec  

 87380  16384  16384    10.00    9410.82   
qdisc fq 8005: dev eth0 root refcnt 32 limit 10000p flow_limit 100p buckets 1024 quantum 3028 initial_quantum 15140 
 Sent 50545633991 bytes 33385894 pkt (dropped 0, overlimits 0 requeues 19) 
 rate 9258Mbit 764335pps backlog 0b 0p requeues 19 
  117 flow, 115 inactive, 0 throttled
  0 gc, 0 highprio, 0 retrans, 96861 throttled, 0 flows_plimit
[  572.551664] latency = 3035 ns


What do you get with this debugging patch ?

diff --git a/net/sched/sch_fq.c b/net/sched/sch_fq.c
index 32ad015..c1312a0 100644
--- a/net/sched/sch_fq.c
+++ b/net/sched/sch_fq.c
@@ -103,6 +103,7 @@ struct fq_sched_data {
 	u64		stat_internal_packets;
 	u64		stat_tcp_retrans;
 	u64		stat_throttled;
+	s64		slatency;
 	u64		stat_flows_plimit;
 	u64		stat_pkts_too_long;
 	u64		stat_allocation_errors;
@@ -393,6 +394,7 @@ static int fq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 static void fq_check_throttled(struct fq_sched_data *q, u64 now)
 {
 	struct rb_node *p;
+	bool first = true;
 
 	if (q->time_next_delayed_flow > now)
 		return;
@@ -405,6 +407,13 @@ static void fq_check_throttled(struct fq_sched_data *q, u64 now)
 			q->time_next_delayed_flow = f->time_next_packet;
 			break;
 		}
+		if (first) {
+			s64 delay = now - f->time_next_packet;
+
+			first = false;
+			delay -= q->slatency >> 3;
+			q->slatency += delay;
+		}
 		rb_erase(p, &q->delayed);
 		q->throttled_flows--;
 		fq_flow_add_tail(&q->old_flows, f);
@@ -711,6 +720,7 @@ static int fq_dump(struct Qdisc *sch, struct sk_buff *skb)
 	if (opts == NULL)
 		goto nla_put_failure;
 
+	pr_err("latency = %lld ns\n", q->slatency >> 3);
 	if (nla_put_u32(skb, TCA_FQ_PLIMIT, sch->limit) ||
 	    nla_put_u32(skb, TCA_FQ_FLOW_PLIMIT, q->flow_plimit) ||
 	    nla_put_u32(skb, TCA_FQ_QUANTUM, q->quantum) ||
