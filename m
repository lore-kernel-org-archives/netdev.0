From: Andrey Vagin <avagin@openvz.org>
Subject: [PATCH 3/3] tcp: add ability to restore a fin packet
Date: Fri, 21 Mar 2014 17:33:01 +0400
Message-ID: <1395408781-8145-4-git-send-email-avagin@openvz.org>
References: <1395408781-8145-1-git-send-email-avagin@openvz.org>
Cc: criu@openvz.org, netdev@vger.kernel.org,
	Andrey Vagin <avagin@openvz.org>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Eric Dumazet <edumazet@google.com>,
	Pavel Emelyanov <xemul@parallels.com>,
	Cyrill Gorcunov <gorcunov@openvz.org>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:23672 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760995AbaCUNdn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Mar 2014 09:33:43 -0400
In-Reply-To: <1395408781-8145-1-git-send-email-avagin@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It's required for restoring sockets in closing states:
TCP_FIN_WAIT{1,2}, TCP_WAIT_STOP, TCP_CLOSING, TCP_LAST_ACK.

A fin packet is restored by sending a control message (ancillary data).
In which queue a packet is restored depends on a value of
tp->repair_queue.

This interface is choosen, because we are goint to use sendmsg for
restoring sockets in TCP_SYN_RECV states.  Requests in the TCP_SYN_RECV
state will be restored by sending messages in a proper listen socket. A
message will contain address and a control messages with sequence
numbers.

Cc: "David S. Miller" <davem@davemloft.net>
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Cc: James Morris <jmorris@namei.org>
Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Cc: Patrick McHardy <kaber@trash.net>
Cc: Eric Dumazet <edumazet@google.com>
Cc: Pavel Emelyanov <xemul@parallels.com>
Cc: Cyrill Gorcunov <gorcunov@openvz.org>
Signed-off-by: Andrey Vagin <avagin@openvz.org>
---
 include/net/tcp.h        |  1 +
 include/uapi/linux/tcp.h |  3 +++
 net/ipv4/tcp.c           | 40 ++++++++++++++++++++++++++++++++++++++++
 net/ipv4/tcp_input.c     |  2 +-
 4 files changed, 45 insertions(+), 1 deletion(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 8c4dd63..4b4d9e8 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -561,6 +561,7 @@ void tcp_cwnd_application_limited(struct sock *sk);
 void tcp_resume_early_retransmit(struct sock *sk);
 void tcp_rearm_rto(struct sock *sk);
 void tcp_reset(struct sock *sk);
+void tcp_fin(struct sock *sk);
 
 /* tcp_timer.c */
 void tcp_init_xmit_timers(struct sock *);
diff --git a/include/uapi/linux/tcp.h b/include/uapi/linux/tcp.h
index 377f1e5..2cc6876 100644
--- a/include/uapi/linux/tcp.h
+++ b/include/uapi/linux/tcp.h
@@ -199,4 +199,7 @@ struct tcp_md5sig {
 	__u8	tcpm_key[TCP_MD5SIG_MAXKEYLEN];		/* key (binary) */
 };
 
+/* Conntroll message types to repair tcp connections */
+#define TCP_REPAIR_SEND_FIN	1
+
 #endif /* _UAPI_LINUX_TCP_H */
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 4cd0e87..7f5a15c 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1070,6 +1070,34 @@ static int tcp_sendmsg_fastopen(struct sock *sk, struct msghdr *msg,
 	return err;
 }
 
+static int tcp_repair_cmsg(struct sock *sk, struct msghdr *msg)
+{
+	struct tcp_sock *tp = tcp_sk(sk);
+	struct cmsghdr *cmsg;
+
+	for (cmsg = CMSG_FIRSTHDR(msg); cmsg; cmsg = CMSG_NXTHDR(msg, cmsg)) {
+		if (!CMSG_OK(msg, cmsg))
+			return -EINVAL;
+		if (cmsg->cmsg_level != SOL_TCP)
+			continue;
+
+		switch (cmsg->cmsg_type) {
+		case TCP_REPAIR_SEND_FIN:
+			if (tp->repair_queue == TCP_RECV_QUEUE)
+				tcp_fin(sk);
+			else if (tp->repair_queue == TCP_SEND_QUEUE)
+				tcp_shutdown(sk, SEND_SHUTDOWN);
+			else
+				return -EINVAL;
+			break;
+		default:
+			return -EINVAL;
+		}
+	}
+
+	return 0;
+}
+
 int tcp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 		size_t size)
 {
@@ -1090,6 +1118,18 @@ int tcp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 		if (tp->repair_queue == TCP_NO_QUEUE)
 			goto out_err;
 
+		if (msg->msg_controllen) {
+			if (size != 0)
+				return -EINVAL;
+
+			err = tcp_repair_cmsg(sk, msg);
+			if (err < 0)
+				goto out_err;
+
+			goto out;
+		}
+
+		err = -EINVAL;
 		if (sk->sk_state != TCP_ESTABLISHED)
 			goto out_err;
 
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index eeaac39..352480c 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3820,7 +3820,7 @@ void tcp_reset(struct sock *sk)
  *
  *	If we are in FINWAIT-2, a received FIN moves us to TIME-WAIT.
  */
-static void tcp_fin(struct sock *sk)
+void tcp_fin(struct sock *sk)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	const struct dst_entry *dst;
-- 
1.8.5.3
