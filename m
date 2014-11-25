From: Yang Yingliang <yangyingliang@huawei.com>
Subject: [PATCH net-next 0/3] sch_fq: segment too big GSO packets
Date: Tue, 25 Nov 2014 21:24:49 +0800
Message-ID: <1416921892-4756-1-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <eric.dumazet@gmail.com>, <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:3086 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754823AbaKYNZR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 08:25:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As the TODO says: "maybe segment the too big skb, as in commit
e43ac79a4bc ("sch_tbf: segment too big GSO packets")" in fq_dequeue(),
this patchset segment the GSO packets that are too big.

Sometimes a GSO packet is too big at a low rate. This patchset check
the packet before it's enqueued, if the GSO packet cost more than 125ms
to send, it will be segmented, then enqueue the segments one by one.
Because of the segment, the qlen may be bigger than limit in some condition.
My way is that let the packet in if qlen is smaller than limit before
it's segmented.

Test way:
 Step 1.
 # tc qdisc add dev eth4 root handle 1: htb default 1
 # tc class add dev eth4 parent 1:0 classid 1:1 htb rate 100mbit ceil 100mbit
 # tc qdisc add dev eth4 parent 1:1 handle 11: fq maxrate 180kbit quantum 1000

 Step 2. use iperf to send packets

 Step 3. # tc -s -d qdisc show dev eth4
 There is no too long packets and there are some packets to send in queue:

qdisc htb 1: root refcnt 2 r2q 10 default 1 direct_packets_stat 0 ver 3.17 direct_qlen 1000
 Sent 1273136 bytes 1158 pkt (dropped 0, overlimits 1544 requeues 0) 
 backlog 0b 54p requeues 0 
qdisc fq 11: parent 1:1 limit 10000p flow_limit 100p buckets 1024 quantum 1000 initial_quantum 15140 maxrate 180Kbit 
 Sent 1273136 bytes 1158 pkt (dropped 0, overlimits 0 requeues 0) 
 backlog 81756b 54p requeues 0 
  4 flows (3 inactive, 1 throttled), next packet delay 2015043 ns
  0 gc, 2 highprio, 792 throttled

 Several seconds later after stopping iperf, show qdisc again, all packets has been sent:

qdisc htb 1: root refcnt 2 r2q 10 default 1 direct_packets_stat 0 ver 3.17 direct_qlen 1000
 Sent 2800098 bytes 2359 pkt (dropped 0, overlimits 3166 requeues 0) 
 backlog 0b 0p requeues 0 
qdisc fq 11: parent 1:1 limit 10000p flow_limit 100p buckets 1024 quantum 1000 initial_quantum 15140 maxrate 180Kbit 
 Sent 2800098 bytes 2359 pkt (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 0p requeues 0 
  5 flows (3 inactive, 0 throttled)
  0 gc, 6 highprio, 1782 throttled

 Step 4. Without this patchset, do step1-2, then show the qdisc,
 there are some too long packets:

qdisc htb 1: root refcnt 2 r2q 10 default 1 direct_packets_stat 0 ver 3.17 direct_qlen 1000
 Sent 1897859 bytes 2674 pkt (dropped 0, overlimits 1362 requeues 0) 
 backlog 0b 36p requeues 0 
qdisc fq 11: parent 1:1 limit 10000p flow_limit 100p buckets 1024 quantum 1000 initial_quantum 15140 maxrate 180Kbit 
 Sent 1897859 bytes 2674 pkt (dropped 0, overlimits 0 requeues 0) 
 backlog 109008b 36p requeues 0 
  9 flows (8 inactive, 1 throttled), next packet delay 21671844 ns
  0 gc, 82 highprio, 568 throttled
  513 _too long pkts_, 0 alloc errors

Yang Yingliang (3):
  sch_fq: add skb_is_too_big() helper
  sch_fq: add __fq_enqueue() helper
  sch_fq: segment too big GSO packets

 net/sched/sch_fq.c | 112 ++++++++++++++++++++++++++++++++++++-----------------
 1 file changed, 77 insertions(+), 35 deletions(-)

-- 
1.8.0
