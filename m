From: Jiri Kosina <jkosina@suse.cz>
Subject: [PATCH] tcp: use RTAX_CWND for outgoing connections properly
Date: Fri, 17 Dec 2010 23:14:17 +0100 (CET)
Message-ID: <alpine.LNX.2.00.1012172310400.16569@pobox.suse.cz>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org, Vojtech Pavlik <vojtech@suse.cz>
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

For outgoing connections, the initial value of cwnd is always set to 2 (in 
tcp_v4_init_sock()) regardless of setting of RTAX_CWND. For incoming 
connections, this is handled properly in tcp_init_metrics().

As a result of this, Linux TCP stack always uses cwnd == 2 at the beginning of
outgoing TCP session (i.e. waits for ACK after 2 packets once the connection
has been established) and grows it in accordance with slow-start algorithm
only after it receives ACK for first two packets.

When slow-start triggers later during the connection (e.g. after idle), 
cwnd is properly re-initialized to RTAX_CWND value (if specified) through 
tcp_cwnd_restart() -> tcp_init_cwnd().

Initialize tp->snd_cwnd properly so that RTAX_CWND value is being used 
also in the slow-start phase for the first packets in the connection.

Signed-off-by: Jiri Kosina <jkosina@suse.cz>
---
 net/ipv4/tcp_output.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 61c2463..6dbc55b 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2572,6 +2572,8 @@ static void tcp_connect_init(struct sock *sk)
 				  &rcv_wscale,
 				  dst_metric(dst, RTAX_INITRWND));
 
+	tp->snd_cwnd = tcp_init_cwnd(tp, dst);
+
 	tp->rx_opt.rcv_wscale = rcv_wscale;
 	tp->rcv_ssthresh = tp->rcv_wnd;
 
-- 
1.7.3.1
