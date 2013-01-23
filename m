From: Andrey Vagin <avagin@openvz.org>
Subject: [PATCH 2/2] tcp: add ability to set a timestamp offset (v2)
Date: Wed, 23 Jan 2013 19:01:54 +0400
Message-ID: <1358953314-12979-3-git-send-email-avagin@openvz.org>
References: <1358953314-12979-1-git-send-email-avagin@openvz.org>
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
In-Reply-To: <1358953314-12979-1-git-send-email-avagin@openvz.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If a TCP socket will get live-migrated from one box to another the
timestamps (which are typically ON) will get screwed up -- the new
kernel will generate TS values that has nothing to do with what they
were on dump. The solution is to yet again fix the kernel and put a
"timestamp offset" on a socket.

This patch adds one more tcp socket option TCP_TIMESTAMP, which is used
for getting and setting a current value of tcp_timestamp.

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
 include/net/tcp.h        | 2 +-
 include/uapi/linux/tcp.h | 1 +
 net/ipv4/tcp.c           | 7 +++++++
 4 files changed, 11 insertions(+), 1 deletion(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 4e1d228..5ebc67c 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -162,6 +162,8 @@ struct tcp_sock {
 	u32	rcv_tstamp;	/* timestamp of last received ACK (for keepalives) */
 	u32	lsndtime;	/* timestamp of last sent data packet (for restart window) */
 
+	u32	tsoffset;	/* timestamp offset */
+
 	struct list_head tsq_node; /* anchor in tsq_tasklet.head list */
 	unsigned long	tsq_flags;
 
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 3e242ba..25119c0 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -677,7 +677,7 @@ void tcp_send_window_probe(struct sock *sk);
  */
 static inline u32 tcp_time_stamp(const struct tcp_sock *tp)
 {
-	return (__u32)jiffies;
+	return (__u32)(jiffies) + tp->tsoffset;
 }
 
 #define tcp_flag_byte(th) (((u_int8_t *)th)[13])
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
index 086ceda..23f93d4 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2704,6 +2704,10 @@ static int do_tcp_setsockopt(struct sock *sk, int level,
 		else
 			err = -EINVAL;
 		break;
+	case TCP_TIMESTAMP:
+		tp->tsoffset = 0;
+		tp->tsoffset = val - tcp_time_stamp(tp);
+		break;
 	default:
 		err = -ENOPROTOOPT;
 		break;
@@ -2952,6 +2956,9 @@ static int do_tcp_getsockopt(struct sock *sk, int level,
 	case TCP_USER_TIMEOUT:
 		val = jiffies_to_msecs(icsk->icsk_user_timeout);
 		break;
+	case TCP_TIMESTAMP:
+		val = tcp_time_stamp(tp);
+		break;
 	default:
 		return -ENOPROTOOPT;
 	}
-- 
1.7.11.7
