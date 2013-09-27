From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] tcp: TSQ can use a dynamic limit
Date: Fri, 27 Sep 2013 03:28:54 -0700
Message-ID: <1380277734.30872.25.camel@edumazet-glaptop.roam.corp.google.com>
References: <20130906101635.GI14104@zion.uk.xensource.com>
	 <1378472268.31445.15.camel@edumazet-glaptop> <522A049A.7000105@citrix.com>
	 <1378486840.31445.36.camel@edumazet-glaptop>
	 <1378574494.26319.14.camel@edumazet-glaptop> <522E4080.2050802@citrix.com>
	 <1378763815.26319.39.camel@edumazet-glaptop>
	 <loom.20130921T045654-573@post.gmane.org>
	 <20130921150327.GA9078@zion.uk.xensource.com>
	 <CAM_iQpUCGA+ifOUoyh4EuPz5sn8wUgtoD=_5dpRMuYV5aqEdxQ@mail.gmail.com>
	 <1379861902.3431.12.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Wei Liu <wei.liu2@citrix.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>
To: Cong Wang <xiyou.wangcong@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ye0-f182.google.com ([209.85.213.182]:55333 "EHLO
	mail-ye0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750871Ab3I0K26 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Sep 2013 06:28:58 -0400
Received: by mail-ye0-f182.google.com with SMTP id l10so773153yen.41
        for <netdev@vger.kernel.org>; Fri, 27 Sep 2013 03:28:57 -0700 (PDT)
In-Reply-To: <1379861902.3431.12.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

When TCP Small Queues was added, we used a sysctl to limit amount of
packets queues on Qdisc/device queues for a given TCP flow.

Problem is this limit is either too big for low rates, or too small
for high rates.

Now TCP stack has rate estimation in sk->sk_pacing_rate, and TSO 
auto sizing, it can better control number of packets in Qdisc/device
queues.

New limit is two packets or at least 1 to 2 ms worth of packets.

Low rates flows benefit from this patch by having even smaller
number of packets in queues, allowing for faster recovery,
better RTT estimations.

High rates flows benefit from this patch by allowing more than 2 packets
in flight as we had reports this was a limiting factor to reach line
rate. [ In particular if TX completion is delayed because of coalescing
parameters ]

Example for a single flow on 10Gbp link controlled by FQ/pacing

14 packets in flight instead of 2

$ tc -s -d qd
qdisc fq 8001: dev eth0 root refcnt 32 limit 10000p flow_limit 100p
buckets 1024 quantum 3028 initial_quantum 15140 
 Sent 1168459366606 bytes 771822841 pkt (dropped 0, overlimits 0
requeues 6822476) 
 rate 9346Mbit 771713pps backlog 953820b 14p requeues 6822476 
  2047 flow, 2046 inactive, 1 throttled, delay 15673 ns
  2372 gc, 0 highprio, 0 retrans, 9739249 throttled, 0 flows_plimit

Note that sk_pacing_rate is currently set to twice the actual rate, but
this might be refined in the future when a flow is in congestion
avoidance.

Additional change : skb->destructor should be set to tcp_wfree().

A future patch (for linux 3.13+) might remove tcp_limit_output_bytes

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Wei Liu <wei.liu2@citrix.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>
Cc: Yuchung Cheng <ycheng@google.com>
Cc: Neal Cardwell <ncardwell@google.com>
---
 net/ipv4/tcp_output.c |   17 +++++++++++------
 1 file changed, 11 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 7c83cb8..c20e406 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -895,8 +895,7 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
 
 	skb_orphan(skb);
 	skb->sk = sk;
-	skb->destructor = (sysctl_tcp_limit_output_bytes > 0) ?
-			  tcp_wfree : sock_wfree;
+	skb->destructor = tcp_wfree;
 	atomic_add(skb->truesize, &sk->sk_wmem_alloc);
 
 	/* Build TCP header and checksum it. */
@@ -1840,7 +1839,6 @@ static bool tcp_write_xmit(struct sock *sk, unsigned int mss_now, int nonagle,
 	while ((skb = tcp_send_head(sk))) {
 		unsigned int limit;
 
-
 		tso_segs = tcp_init_tso_segs(sk, skb, mss_now);
 		BUG_ON(!tso_segs);
 
@@ -1869,13 +1867,20 @@ static bool tcp_write_xmit(struct sock *sk, unsigned int mss_now, int nonagle,
 				break;
 		}
 
-		/* TSQ : sk_wmem_alloc accounts skb truesize,
-		 * including skb overhead. But thats OK.
+		/* TCP Small Queues :
+		 * Control number of packets in qdisc/devices to two packets / or ~1 ms.
+		 * This allows for :
+		 *  - better RTT estimation and ACK scheduling
+		 *  - faster recovery
+		 *  - high rates
 		 */
-		if (atomic_read(&sk->sk_wmem_alloc) >= sysctl_tcp_limit_output_bytes) {
+		limit = max(skb->truesize, sk->sk_pacing_rate >> 10);
+
+		if (atomic_read(&sk->sk_wmem_alloc) > limit) {
 			set_bit(TSQ_THROTTLED, &tp->tsq_flags);
 			break;
 		}
+
 		limit = mss_now;
 		if (tso_segs > 1 && !tcp_urg_mode(tp))
 			limit = tcp_mss_split_point(sk, skb, mss_now,
