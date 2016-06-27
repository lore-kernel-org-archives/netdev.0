From: Andrey Vagin <avagin@openvz.org>
Subject: [PATCH] tcp: add an ability to dump and restore window parameters
Date: Mon, 27 Jun 2016 15:33:56 -0700
Message-ID: <1467066836-3817-1-git-send-email-avagin@openvz.org>
Cc: linux-kernel@vger.kernel.org, criu@openvz.org,
	Andrey Vagin <avagin@openvz.org>,
	Pavel Emelyanov <xemul@parallels.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We found that sometimes a restored tcp socket doesn't work.

A reason of this bug is incorrect window parameters and in this case
tcp_acceptable_seq() returns tcp_wnd_end(tp) instead of tp->snd_nxt. The
other side drops packets with this seq, because seq is less than
tp->rcv_nxt ( tcp_sequence() ).

Data from a send queue is sent only if there is enough space in a
window, so when we restore unacked data, we need to expand a window to
fit this data.

This was in a first version of this patch:
"tcp: extend window to fit all restored unacked data in a send queue"

Then Alexey recommended me to restore window parameters instead of
adjusted them according with data in a sent queue. This sounds resonable.

rcv_wnd has to be restored, because it was reported to another side
and the offered window is never shrunk.
One of reasons why we need to restore snd_wnd was described above.

Cc: Pavel Emelyanov <xemul@parallels.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Cc: James Morris <jmorris@namei.org>
Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Cc: Patrick McHardy <kaber@trash.net>
Signed-off-by: Andrey Vagin <avagin@openvz.org>
---
 include/uapi/linux/tcp.h | 10 +++++++++
 net/ipv4/tcp.c           | 57 ++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 67 insertions(+)

diff --git a/include/uapi/linux/tcp.h b/include/uapi/linux/tcp.h
index 53e8e3f..482898f 100644
--- a/include/uapi/linux/tcp.h
+++ b/include/uapi/linux/tcp.h
@@ -115,12 +115,22 @@ enum {
 #define TCP_CC_INFO		26	/* Get Congestion Control (optional) info */
 #define TCP_SAVE_SYN		27	/* Record SYN headers for new connections */
 #define TCP_SAVED_SYN		28	/* Get SYN headers recorded for connection */
+#define TCP_REPAIR_WINDOW	29	/* Get/set window parameters */
 
 struct tcp_repair_opt {
 	__u32	opt_code;
 	__u32	opt_val;
 };
 
+struct tcp_repair_window {
+	__u32	snd_wl1;
+	__u32	snd_wnd;
+	__u32	max_window;
+
+	__u32	rcv_wnd;
+	__u32	rcv_wup;
+};
+
 enum {
 	TCP_NO_QUEUE,
 	TCP_RECV_QUEUE,
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 5c7ed14..108ef2a 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2277,6 +2277,38 @@ static inline bool tcp_can_repair_sock(const struct sock *sk)
 		((1 << sk->sk_state) & (TCPF_CLOSE | TCPF_ESTABLISHED));
 }
 
+static int tcp_repair_set_window(struct tcp_sock *tp, char __user *optbuf, int len)
+{
+	struct tcp_repair_window opt;
+
+	if (!tp->repair)
+		return -EPERM;
+
+	if (len != sizeof(opt))
+		return -EINVAL;
+
+	if (copy_from_user(&opt, optbuf, sizeof(opt)))
+		return -EFAULT;
+
+	if (opt.max_window < opt.snd_wnd)
+		return -EINVAL;
+
+	if (after(opt.snd_wl1, tp->rcv_nxt + opt.rcv_wnd))
+		return -EINVAL;
+
+	if (after(opt.rcv_wup, tp->rcv_nxt))
+		return -EINVAL;
+
+	tp->snd_wl1	= opt.snd_wl1;
+	tp->snd_wnd	= opt.snd_wnd;
+	tp->max_window	= opt.max_window;
+
+	tp->rcv_wnd	= opt.rcv_wnd;
+	tp->rcv_wup	= opt.rcv_wup;
+
+	return 0;
+}
+
 static int tcp_repair_options_est(struct tcp_sock *tp,
 		struct tcp_repair_opt __user *optbuf, unsigned int len)
 {
@@ -2604,6 +2636,9 @@ static int do_tcp_setsockopt(struct sock *sk, int level,
 		else
 			tp->tsoffset = val - tcp_time_stamp;
 		break;
+	case TCP_REPAIR_WINDOW:
+		err = tcp_repair_set_window(tp, optval, optlen);
+		break;
 	case TCP_NOTSENT_LOWAT:
 		tp->notsent_lowat = val;
 		sk->sk_write_space(sk);
@@ -2860,6 +2895,28 @@ static int do_tcp_getsockopt(struct sock *sk, int level,
 			return -EINVAL;
 		break;
 
+	case TCP_REPAIR_WINDOW: {
+		struct tcp_repair_window opt;
+
+		if (get_user(len, optlen))
+			return -EFAULT;
+
+		if (len != sizeof(opt))
+			return -EINVAL;
+
+		if (!tp->repair)
+			return -EPERM;
+
+		opt.snd_wl1	= tp->snd_wl1;
+		opt.snd_wnd	= tp->snd_wnd;
+		opt.max_window	= tp->max_window;
+		opt.rcv_wnd	= tp->rcv_wnd;
+		opt.rcv_wup	= tp->rcv_wup;
+
+		if (copy_to_user(optval, &opt, len))
+			return -EFAULT;
+		return 0;
+	}
 	case TCP_QUEUE_SEQ:
 		if (tp->repair_queue == TCP_SEND_QUEUE)
 			val = tp->write_seq;
-- 
2.5.5
