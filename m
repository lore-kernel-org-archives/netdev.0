From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] tcp: tsq: restore minimal amount of queueing
Date: Tue, 12 Nov 2013 06:39:01 -0800
Message-ID: <1384267141.28458.24.camel@edumazet-glaptop2.roam.corp.google.com>
References: <8761s0cqhh.fsf@natisbad.org>
	 <slrnl83jr5.49f.xiyou.wangcong@linux-6brj.site>
	 <87y54u59zq.fsf@natisbad.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org,
	Felix Fietkau <nbd@openwrt.org>
To: Arnaud Ebalard <arno@natisbad.org>,
	David Miller <davem@davemloft.net>,
	Sujith Manoharan <sujith@msujith.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:54208 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751478Ab3KLOjD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Nov 2013 09:39:03 -0500
Received: by mail-pd0-f171.google.com with SMTP id w10so6951999pde.30
        for <netdev@vger.kernel.org>; Tue, 12 Nov 2013 06:39:03 -0800 (PST)
In-Reply-To: <87y54u59zq.fsf@natisbad.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

After commit c9eeec26e32e ("tcp: TSQ can use a dynamic limit"), several
users reported throughput regressions, notably on mvneta and wifi
adapters.

802.11 AMPDU requires a fair amount of queueing to be effective.

This patch partially reverts the change done in tcp_write_xmit()
so that the minimal amount is sysctl_tcp_limit_output_bytes.

It also remove the use of this sysctl while building skb stored
in write queue, as TSO autosizing does the right thing anyway.

Users with well behaving NICS and correct qdisc (like sch_fq),
can then lower the default sysctl_tcp_limit_output_bytes value from
128KB to 8KB.

The new usage of sysctl_tcp_limit_output_bytes permits each driver
author to check how driver performs when/if the value is set
to a minimum of 4KB :

Normally, line rate for a single TCP flow should be possible, 
but some drivers rely on timers to perform TX completion and
too long delays prevent reaching full throughput.

Fixes: c9eeec26e32e ("tcp: TSQ can use a dynamic limit")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Sujith Manoharan <sujith@msujith.org>
Reported-by: Arnaud Ebalard <arno@natisbad.org>
Cc: Felix Fietkau <nbd@openwrt.org>
---
 Documentation/networking/ip-sysctl.txt |    3 ---
 net/ipv4/tcp.c                         |    6 ------
 net/ipv4/tcp_output.c                  |    6 +++++-
 3 files changed, 5 insertions(+), 10 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index a46d785..7d8dc93 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -588,9 +588,6 @@ tcp_limit_output_bytes - INTEGER
 	typical pfifo_fast qdiscs.
 	tcp_limit_output_bytes limits the number of bytes on qdisc
 	or device to reduce artificial RTT/cwnd and reduce bufferbloat.
-	Note: For GSO/TSO enabled flows, we try to have at least two
-	packets in flight. Reducing tcp_limit_output_bytes might also
-	reduce the size of individual GSO packet (64KB being the max)
 	Default: 131072
 
 tcp_challenge_ack_limit - INTEGER
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 6e5617b..be5246e 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -806,12 +806,6 @@ static unsigned int tcp_xmit_size_goal(struct sock *sk, u32 mss_now,
 		xmit_size_goal = min_t(u32, gso_size,
 				       sk->sk_gso_max_size - 1 - hlen);
 
-		/* TSQ : try to have at least two segments in flight
-		 * (one in NIC TX ring, another in Qdisc)
-		 */
-		xmit_size_goal = min_t(u32, xmit_size_goal,
-				       sysctl_tcp_limit_output_bytes >> 1);
-
 		xmit_size_goal = tcp_bound_to_half_wnd(tp, xmit_size_goal);
 
 		/* We try hard to avoid divides here */
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index d46f214..9f0b338 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1875,8 +1875,12 @@ static bool tcp_write_xmit(struct sock *sk, unsigned int mss_now, int nonagle,
 		 *  - better RTT estimation and ACK scheduling
 		 *  - faster recovery
 		 *  - high rates
+		 * Alas, some drivers / subsystems require a fair amount
+		 * of queued bytes to ensure line rate.
+		 * One example is wifi aggregation (802.11 AMPDU)
 		 */
-		limit = max(skb->truesize, sk->sk_pacing_rate >> 10);
+		limit = max(sysctl_tcp_limit_output_bytes,
+			    sk->sk_pacing_rate >> 10);
 
 		if (atomic_read(&sk->sk_wmem_alloc) > limit) {
 			set_bit(TSQ_THROTTLED, &tp->tsq_flags);
