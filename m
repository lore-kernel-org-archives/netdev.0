From: Andrey Vagin <avagin@openvz.org>
Subject: [PATCH 1/3] tcp: adding a per-socket timestamp offset
Date: Mon, 11 Feb 2013 19:50:17 +0400
Message-ID: <1360597819-23783-2-git-send-email-avagin@openvz.org>
References: <1360597819-23783-1-git-send-email-avagin@openvz.org>
Cc: criu@openvz.org, linux-kernel@vger.kernel.org,
	Andrey Vagin <avagin@openvz.org>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Eric Dumazet <edumazet@google.com>,
	Pavel Emelyanov <xemul@parallels.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1360597819-23783-1-git-send-email-avagin@openvz.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This functionality is used for restoring tcp sockets. A tcp timestamp
depends on how long a system has been running, so it's differ for each
host. The solution is to set a per-socket offset.

A per-socket offset for a TIME_WAIT socket is inherited from a proper
tcp socket.

tcp_request_sock doesn't have a timestamp offset, because the repair
mode for them are not implemented.

Cc: "David S. Miller" <davem@davemloft.net>
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Cc: James Morris <jmorris@namei.org>
Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Cc: Patrick McHardy <kaber@trash.net>
Cc: Eric Dumazet <edumazet@google.com>
Cc: Pavel Emelyanov <xemul@parallels.com>
Signed-off-by: Andrey Vagin <avagin@openvz.org>
---
 include/linux/tcp.h      | 3 +++
 net/ipv4/tcp.c           | 2 ++
 net/ipv4/tcp_minisocks.c | 2 ++
 3 files changed, 7 insertions(+)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 4e1d228..974fb4a 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -162,6 +162,8 @@ struct tcp_sock {
 	u32	rcv_tstamp;	/* timestamp of last received ACK (for keepalives) */
 	u32	lsndtime;	/* timestamp of last sent data packet (for restart window) */
 
+	u32	tsoffset;	/* timestamp offset */
+
 	struct list_head tsq_node; /* anchor in tsq_tasklet.head list */
 	unsigned long	tsq_flags;
 
@@ -354,6 +356,7 @@ struct tcp_timewait_sock {
 	u32			  tw_rcv_nxt;
 	u32			  tw_snd_nxt;
 	u32			  tw_rcv_wnd;
+	u32			  tw_ts_offset;
 	u32			  tw_ts_recent;
 	long			  tw_ts_recent_stamp;
 #ifdef CONFIG_TCP_MD5SIG
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 1ca2536..60fab09 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -400,6 +400,8 @@ void tcp_init_sock(struct sock *sk)
 	tcp_enable_early_retrans(tp);
 	icsk->icsk_ca_ops = &tcp_init_congestion_ops;
 
+	tp->tsoffset = 0;
+
 	sk->sk_state = TCP_CLOSE;
 
 	sk->sk_write_space = sk_stream_write_space;
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index f35f2df..b94940e 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -288,6 +288,7 @@ void tcp_time_wait(struct sock *sk, int state, int timeo)
 		tcptw->tw_rcv_wnd	= tcp_receive_window(tp);
 		tcptw->tw_ts_recent	= tp->rx_opt.ts_recent;
 		tcptw->tw_ts_recent_stamp = tp->rx_opt.ts_recent_stamp;
+		tcptw->tw_ts_offset	= tp->tsoffset;
 
 #if IS_ENABLED(CONFIG_IPV6)
 		if (tw->tw_family == PF_INET6) {
@@ -500,6 +501,7 @@ struct sock *tcp_create_openreq_child(struct sock *sk, struct request_sock *req,
 			newtp->rx_opt.ts_recent_stamp = 0;
 			newtp->tcp_header_len = sizeof(struct tcphdr);
 		}
+		newtp->tsoffset = 0;
 #ifdef CONFIG_TCP_MD5SIG
 		newtp->md5sig_info = NULL;	/*XXX*/
 		if (newtp->af_specific->md5_lookup(sk, newsk))
-- 
1.7.11.7
