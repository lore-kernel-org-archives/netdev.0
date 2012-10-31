From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [PATCH net] net: fix divide by zero in tcp algorithm illinois
Date: Wed, 31 Oct 2012 11:37:08 +0100
Message-ID: <20121031103630.18756.15685.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org,
	Petr Matousek <pmatouse@redhat.com>,
	Stephen Hemminger <shemminger@vyatta.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49165 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935382Ab2JaKgC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Oct 2012 06:36:02 -0400
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

To be on the safe side, I use a local stack variable in tcp_illinois_info()
to eliminate any race conditions.  I'm not sure this is needed, as this
would also affect avg_delay(), if this race exists.  (Although this is likely
already "fix" by compiler optimization and kept in a local register)

Cc: Petr Matousek <pmatouse@redhat.com>
Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---

 net/ipv4/tcp_illinois.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_illinois.c b/net/ipv4/tcp_illinois.c
index 813b43a..343f160 100644
--- a/net/ipv4/tcp_illinois.c
+++ b/net/ipv4/tcp_illinois.c
@@ -306,6 +306,7 @@ static void tcp_illinois_info(struct sock *sk, u32 ext,
 			      struct sk_buff *skb)
 {
 	const struct illinois *ca = inet_csk_ca(sk);
+	u16 cnt_rtt;
 
 	if (ext & (1 << (INET_DIAG_VEGASINFO - 1))) {
 		struct tcpvegas_info info = {
@@ -315,8 +316,11 @@ static void tcp_illinois_info(struct sock *sk, u32 ext,
 		};
 		u64 t = ca->sum_rtt;
 
-		do_div(t, ca->cnt_rtt);
-		info.tcpv_rtt = t;
+		cnt_rtt = ca->cnt_rtt;
+		if (cnt_rtt > 0) {
+			do_div(t, cnt_rtt);
+			info.tcpv_rtt = t;
+		}
 
 		nla_put(skb, INET_DIAG_VEGASINFO, sizeof(info), &info);
 	}
