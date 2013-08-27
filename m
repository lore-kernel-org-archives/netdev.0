From: Andrey Vagin <avagin@openvz.org>
Subject: [PATCH] tcp: don't apply tsoffset if rcv_tsecr is zero
Date: Tue, 27 Aug 2013 12:21:55 +0400
Message-ID: <1377591715-1742-1-git-send-email-avagin@openvz.org>
Cc: Cyrill Gorcunov <gorcunov@openvz.org>,
	linux-kernel@vger.kernel.org, Andrew Vagin <avagin@openvz.org>,
	Pavel Emelyanov <xemul@parallels.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Vagin <avagin@openvz.org>

The zero value means that tsecr is not valid, so it's a special case.

tsoffset is used to customize tcp_time_stamp for one socket.
tsoffset is usually zero, it's used when a socket was moved from one
host to another host.

Currently this issue affects logic of tcp_rcv_rtt_measure_ts. Due to
incorrect value of rcv_tsecr, tcp_rcv_rtt_measure_ts sets rto to
TCP_RTO_MAX.

Cc: Pavel Emelyanov <xemul@parallels.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Cc: James Morris <jmorris@namei.org>
Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Cc: Patrick McHardy <kaber@trash.net>
Reported-by: Cyrill Gorcunov <gorcunov@openvz.org>
Signed-off-by: Andrey Vagin <avagin@openvz.org>
---
 net/ipv4/tcp_input.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 28af45a..3ca2139 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3535,7 +3535,10 @@ static bool tcp_parse_aligned_timestamp(struct tcp_sock *tp, const struct tcphdr
 		++ptr;
 		tp->rx_opt.rcv_tsval = ntohl(*ptr);
 		++ptr;
-		tp->rx_opt.rcv_tsecr = ntohl(*ptr) - tp->tsoffset;
+		if (*ptr)
+			tp->rx_opt.rcv_tsecr = ntohl(*ptr) - tp->tsoffset;
+		else
+			tp->rx_opt.rcv_tsecr = 0;
 		return true;
 	}
 	return false;
@@ -3560,7 +3563,7 @@ static bool tcp_fast_parse_options(const struct sk_buff *skb,
 	}
 
 	tcp_parse_options(skb, &tp->rx_opt, 1, NULL);
-	if (tp->rx_opt.saw_tstamp)
+	if (tp->rx_opt.saw_tstamp && tp->rx_opt.rcv_tsecr)
 		tp->rx_opt.rcv_tsecr -= tp->tsoffset;
 
 	return true;
@@ -5316,7 +5319,7 @@ static int tcp_rcv_synsent_state_process(struct sock *sk, struct sk_buff *skb,
 	int saved_clamp = tp->rx_opt.mss_clamp;
 
 	tcp_parse_options(skb, &tp->rx_opt, 0, &foc);
-	if (tp->rx_opt.saw_tstamp)
+	if (tp->rx_opt.saw_tstamp && tp->rx_opt.rcv_tsecr)
 		tp->rx_opt.rcv_tsecr -= tp->tsoffset;
 
 	if (th->ack) {
-- 
1.8.3.1
