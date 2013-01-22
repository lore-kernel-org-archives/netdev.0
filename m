From: Andrey Vagin <avagin@openvz.org>
Subject: [PATCH net-next] tcp: add ability to set a timestamp offset
Date: Wed, 23 Jan 2013 00:52:33 +0400
Message-ID: <1358887953-28665-1-git-send-email-avagin@openvz.org>
Cc: criu@openvz.org, linux-kernel@vger.kernel.org,
	Andrey Vagin <avagin@openvz.org>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Eric Dumazet <edumazet@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Pavel Emelyanov <xemul@parallels.com>,
	Dave Jones <davej@redhat.com>,
	Michael Kerrisk <mtk.manpages@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If a TCP socket will get live-migrated from one box to another the
timestamps (which are typically ON) will get screwed up -- the new
kernel will generate TS values that has nothing to do with what they
were on dump. The solution is to yet again fix the kernel and put a
"timestamp offset" on a socket.

Cc: "David S. Miller" <davem@davemloft.net>
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Cc: James Morris <jmorris@namei.org>
Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Cc: Patrick McHardy <kaber@trash.net>
Cc: Eric Dumazet <edumazet@google.com>
Cc: Yuchung Cheng <ycheng@google.com>
Cc: Neal Cardwell <ncardwell@google.com>
Cc: Pavel Emelyanov <xemul@parallels.com>
Cc: Dave Jones <davej@redhat.com>
Cc: Michael Kerrisk <mtk.manpages@gmail.com>
Signed-off-by: Andrey Vagin <avagin@openvz.org>
---
 include/linux/tcp.h      | 2 ++
 include/uapi/linux/tcp.h | 1 +
 net/ipv4/tcp.c           | 6 ++++++
 net/ipv4/tcp_output.c    | 7 ++++---
 4 files changed, 13 insertions(+), 3 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 4e1d228..746dad5 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -162,6 +162,8 @@ struct tcp_sock {
 	u32	rcv_tstamp;	/* timestamp of last received ACK (for keepalives) */
 	u32	lsndtime;	/* timestamp of last sent data packet (for restart window) */
 
+	u32	snd_tsval_offset; /* offset for snd_tsval */
+
 	struct list_head tsq_node; /* anchor in tsq_tasklet.head list */
 	unsigned long	tsq_flags;
 
diff --git a/include/uapi/linux/tcp.h b/include/uapi/linux/tcp.h
index e962faa..6b1ead0 100644
--- a/include/uapi/linux/tcp.h
+++ b/include/uapi/linux/tcp.h
@@ -111,6 +111,7 @@ enum {
 #define TCP_QUEUE_SEQ		21
 #define TCP_REPAIR_OPTIONS	22
 #define TCP_FASTOPEN		23	/* Enable FastOpen on listeners */
+#define TCP_TIMESTAMP		24
 
 struct tcp_repair_opt {
 	__u32	opt_code;
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 1ca2536..72dee28 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2704,6 +2704,9 @@ static int do_tcp_setsockopt(struct sock *sk, int level,
 		else
 			err = -EINVAL;
 		break;
+	case TCP_TIMESTAMP:
+		tp->snd_tsval_offset = val - tcp_time_stamp;
+		break;
 	default:
 		err = -ENOPROTOOPT;
 		break;
@@ -2952,6 +2955,9 @@ static int do_tcp_getsockopt(struct sock *sk, int level,
 	case TCP_USER_TIMEOUT:
 		val = jiffies_to_msecs(icsk->icsk_user_timeout);
 		break;
+	case TCP_TIMESTAMP:
+		val = tcp_time_stamp + tp->snd_tsval_offset;
+		break;
 	default:
 		return -ENOPROTOOPT;
 	}
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 5d45159..9b6d485 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -622,7 +622,7 @@ static unsigned int tcp_syn_options(struct sock *sk, struct sk_buff *skb,
 
 	if (likely(sysctl_tcp_timestamps && *md5 == NULL)) {
 		opts->options |= OPTION_TS;
-		opts->tsval = TCP_SKB_CB(skb)->when;
+		opts->tsval = TCP_SKB_CB(skb)->when + tp->snd_tsval_offset;
 		opts->tsecr = tp->rx_opt.ts_recent;
 		remaining -= TCPOLEN_TSTAMP_ALIGNED;
 	}
@@ -705,6 +705,7 @@ static unsigned int tcp_synack_options(struct sock *sk,
 				   struct tcp_extend_values *xvp,
 				   struct tcp_fastopen_cookie *foc)
 {
+	struct tcp_sock *tp = tcp_sk(sk);
 	struct inet_request_sock *ireq = inet_rsk(req);
 	unsigned int remaining = MAX_TCP_OPTION_SPACE;
 	u8 cookie_plus = (xvp != NULL && !xvp->cookie_out_never) ?
@@ -739,7 +740,7 @@ static unsigned int tcp_synack_options(struct sock *sk,
 	}
 	if (likely(ireq->tstamp_ok)) {
 		opts->options |= OPTION_TS;
-		opts->tsval = TCP_SKB_CB(skb)->when;
+		opts->tsval = TCP_SKB_CB(skb)->when + tp->snd_tsval_offset;
 		opts->tsecr = req->ts_recent;
 		remaining -= TCPOLEN_TSTAMP_ALIGNED;
 	}
@@ -806,7 +807,7 @@ static unsigned int tcp_established_options(struct sock *sk, struct sk_buff *skb
 
 	if (likely(tp->rx_opt.tstamp_ok)) {
 		opts->options |= OPTION_TS;
-		opts->tsval = tcb ? tcb->when : 0;
+		opts->tsval = tcb ? tcb->when + tp->snd_tsval_offset : 0;
 		opts->tsecr = tp->rx_opt.ts_recent;
 		size += TCPOLEN_TSTAMP_ALIGNED;
 	}
-- 
1.7.11.7
