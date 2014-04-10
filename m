From: Andrey Vagin <avagin@openvz.org>
Subject: [PATCH 2/2] tcp: add ability to restore closing states (v2)
Date: Fri, 11 Apr 2014 00:25:39 +0400
Message-ID: <1397161539-27804-3-git-send-email-avagin@openvz.org>
References: <1397161539-27804-1-git-send-email-avagin@openvz.org>
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
Received: from mailhub.sw.ru ([195.214.232.25]:17586 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934020AbaDJU0i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Apr 2014 16:26:38 -0400
In-Reply-To: <1397161539-27804-1-git-send-email-avagin@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the TCP_REPAIR_STATE option, which allows to set a
socket state. A socket must be in the repair mode and in the
TCP_ESTABLISHED state.

Here are TCP_FIN_WAIT{1,2}, TCP_WAIT_STOP, TCP_CLOSING, TCP_LAST_ACK,
TCP_TIME_WAIT.

v2: We decide to not use control message for repairing fin packets in
queues. Because it looks quite tricky. Alexey suggested to restore each
state separately and in this case setsockopt looks more logical.

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
 include/uapi/linux/tcp.h |  1 +
 net/ipv4/tcp.c           | 61 ++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 62 insertions(+)

diff --git a/include/uapi/linux/tcp.h b/include/uapi/linux/tcp.h
index 3b97183..6009062 100644
--- a/include/uapi/linux/tcp.h
+++ b/include/uapi/linux/tcp.h
@@ -112,6 +112,7 @@ enum {
 #define TCP_FASTOPEN		23	/* Enable FastOpen on listeners */
 #define TCP_TIMESTAMP		24
 #define TCP_NOTSENT_LOWAT	25	/* limit number of unsent bytes in write queue */
+#define TCP_REPAIR_STATE	26	/* Current state of this connection */
 
 struct tcp_repair_opt {
 	__u32	opt_code;
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index bcb1d59..9ded8e8 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2431,6 +2431,60 @@ static int tcp_repair_options_est(struct tcp_sock *tp,
 	return 0;
 }
 
+static int tcp_repair_state(struct sock *sk, int state)
+{
+	struct tcp_sock *tp = tcp_sk(sk);
+
+	if (sk->sk_state != TCP_ESTABLISHED)
+		return -EINVAL;
+
+	switch (state) {
+	case TCP_ESTABLISHED:
+		break;
+
+	case TCP_FIN_WAIT2:
+		if (tp->snd_una != tp->write_seq)
+			return -EINVAL;
+		tcp_set_state(sk, TCP_FIN_WAIT2);
+		break;
+
+	case TCP_TIME_WAIT:
+		if (tp->snd_una != tp->write_seq)
+			return -EINVAL;
+		local_bh_disable();
+		tcp_time_wait(sk, TCP_TIME_WAIT, 0);
+		local_bh_enable();
+		break;
+
+	case TCP_CLOSE_WAIT:
+		tcp_set_state(sk, TCP_CLOSE_WAIT);
+		break;
+
+	case TCP_LAST_ACK:
+	case TCP_FIN_WAIT1:
+	case TCP_CLOSING:
+		tcp_set_state(sk, state);
+		tcp_send_fin(sk);
+		break;
+
+	default:
+		return -EINVAL;
+	}
+
+	if ((1 << sk->sk_state) & (TCPF_FIN_WAIT1 |
+				   TCPF_FIN_WAIT2 |
+				   TCPF_CLOSING	|
+				   TCPF_LAST_ACK))
+		sk->sk_shutdown |= SEND_SHUTDOWN;
+
+	if ((1 << sk->sk_state) & (TCPF_CLOSE_WAIT |
+				   TCPF_CLOSING |
+				   TCPF_LAST_ACK))
+		sk->sk_shutdown |= RCV_SHUTDOWN;
+
+	return 0;
+}
+
 /*
  *	Socket option code for TCP.
  */
@@ -2568,6 +2622,13 @@ static int do_tcp_setsockopt(struct sock *sk, int level,
 			err = -EPERM;
 		break;
 
+	case TCP_REPAIR_STATE:
+		if (tp->repair)
+			err = tcp_repair_state(sk, val);
+		else
+			err = -EINVAL;
+		break;
+
 	case TCP_CORK:
 		/* When set indicates to always queue non-full frames.
 		 * Later the user clears this option and we transmit
-- 
1.9.0
