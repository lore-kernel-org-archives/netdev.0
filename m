From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net PATCH V2] net: fix divide by zero in tcp algorithm illinois
Date: Wed, 31 Oct 2012 13:45:32 +0100
Message-ID: <20121031124318.30915.32293.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org,
	Petr Matousek <pmatouse@redhat.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57345 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751941Ab2JaMoZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Oct 2012 08:44:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reading TCP stats when using TCP Illinois congestion control algorithm
can cause a divide by zero kernel oops.

The division by zero occur in tcp_illinois_info() at:
 do_div(t, ca->cnt_rtt);
where ca->cnt_rtt can become zero (when rtt_reset is called)

Steps to Reproduce:
 1. Register tcp_illinois:
     # sysctl -w net.ipv4.tcp_congestion_control=illinois
 2. Monitor internal TCP information via command "ss -i"
     # watch -d ss -i
 3. Establish new TCP conn to machine

Either it fails at the initial conn, or else it needs to wait
for a loss or a reset.

This is only related to reading stats.  The function avg_delay() also
performs the same divide, but is guarded with a (ca->cnt_rtt > 0) at its
calling point in update_params().  Thus, simply fix tcp_illinois_info().

Function tcp_illinois_info() / get_info() is called without
socket lock.  Thus, eliminate any race condition on ca->cnt_rtt
by using a local stack variable.  Simply reuse info.tcpv_rttcnt,
as its already set to ca->cnt_rtt.
Function avg_delay() is not affected by this race condition, as
its called with the socket lock.

Cc: Petr Matousek <pmatouse@redhat.com>
Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>

---
V2:
 Address Eric Dumazets input:
  - Save 2 bytes of stack, by using info.tcpv_rttcnt.
  - Help compiler, and define "u64 t" inside if() lexical scope.


 net/ipv4/tcp_illinois.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/tcp_illinois.c b/net/ipv4/tcp_illinois.c
index 813b43a..834857f 100644
--- a/net/ipv4/tcp_illinois.c
+++ b/net/ipv4/tcp_illinois.c
@@ -313,11 +313,13 @@ static void tcp_illinois_info(struct sock *sk, u32 ext,
 			.tcpv_rttcnt = ca->cnt_rtt,
 			.tcpv_minrtt = ca->base_rtt,
 		};
-		u64 t = ca->sum_rtt;
 
-		do_div(t, ca->cnt_rtt);
-		info.tcpv_rtt = t;
+		if (info.tcpv_rttcnt > 0) {
+			u64 t = ca->sum_rtt;
 
+			do_div(t, info.tcpv_rttcnt);
+			info.tcpv_rtt = t;
+		}
 		nla_put(skb, INET_DIAG_VEGASINFO, sizeof(info), &info);
 	}
 }
