From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH] tcp repair: Fix unaligned access when repairing options
Date: Wed, 25 Apr 2012 16:35:53 +0400
Message-ID: <4F97EFA9.2080903@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:12271 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751388Ab2DYMgA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Apr 2012 08:36:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Don't pick __u8/__u16 values directly from raw pointers, but instead use
an array of structures of code:value pairs. This is OK, since the buffer
we take options from is not an skb memory, but a user-to-kernel one.

For those options which don't require any value now, require this to be
zero (for potential future extension of this API).

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
---
 include/linux/tcp.h |    5 ++++
 net/ipv4/tcp.c      |   60 +++++++++++++++++---------------------------------
 2 files changed, 26 insertions(+), 39 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 9865936..d0401d9 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -111,6 +111,11 @@ enum {
 #define TCP_QUEUE_SEQ		21
 #define TCP_REPAIR_OPTIONS	22
 
+struct tcp_repair_opt {
+	__u8	opt_code;
+	__u16	opt_val;
+};
+
 enum {
 	TCP_NO_QUEUE,
 	TCP_RECV_QUEUE,
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index de6a238..9670af3 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2283,60 +2283,40 @@ static inline int tcp_can_repair_sock(struct sock *sk)
 		((1 << sk->sk_state) & (TCPF_CLOSE | TCPF_ESTABLISHED));
 }
 
-static int tcp_repair_options_est(struct tcp_sock *tp, char __user *optbuf, unsigned int len)
+static int tcp_repair_options_est(struct tcp_sock *tp,
+		struct tcp_repair_opt __user *optbuf, unsigned int len)
 {
-	/*
-	 * Options are stored in CODE:VALUE form where CODE is 8bit and VALUE
-	 * fits the respective TCPOLEN_ size
-	 */
+	struct tcp_repair_opt opt;
 
-	while (len > 0) {
-		u8 opcode;
-
-		if (get_user(opcode, optbuf))
+	while (len >= sizeof(opt)) {
+		if (copy_from_user(&opt, optbuf, sizeof(opt)))
 			return -EFAULT;
 
 		optbuf++;
-		len--;
-
-		switch (opcode) {
-		case TCPOPT_MSS: {
-			u16 in_mss;
+		len -= sizeof(opt);
 
-			if (len < sizeof(in_mss))
-				return -ENODATA;
-			if (get_user(in_mss, optbuf))
-				return -EFAULT;
-
-			tp->rx_opt.mss_clamp = in_mss;
-
-			optbuf += sizeof(in_mss);
-			len -= sizeof(in_mss);
+		switch (opt.opt_code) {
+		case TCPOPT_MSS:
+			tp->rx_opt.mss_clamp = opt.opt_val;
 			break;
-		}
-		case TCPOPT_WINDOW: {
-			u8 wscale;
-
-			if (len < sizeof(wscale))
-				return -ENODATA;
-			if (get_user(wscale, optbuf))
-				return -EFAULT;
-
-			if (wscale > 14)
+		case TCPOPT_WINDOW:
+			if (opt.opt_val > 14)
 				return -EFBIG;
 
-			tp->rx_opt.snd_wscale = wscale;
-
-			optbuf += sizeof(wscale);
-			len -= sizeof(wscale);
+			tp->rx_opt.snd_wscale = opt.opt_val;
 			break;
-		}
 		case TCPOPT_SACK_PERM:
+			if (opt.opt_val != 0)
+				return -EINVAL;
+
 			tp->rx_opt.sack_ok |= TCP_SACK_SEEN;
 			if (sysctl_tcp_fack)
 				tcp_enable_fack(tp);
 			break;
 		case TCPOPT_TIMESTAMP:
+			if (opt.opt_val != 0)
+				return -EINVAL;
+
 			tp->rx_opt.tstamp_ok = 1;
 			break;
 		}
@@ -2557,7 +2537,9 @@ static int do_tcp_setsockopt(struct sock *sk, int level,
 		if (!tp->repair)
 			err = -EINVAL;
 		else if (sk->sk_state == TCP_ESTABLISHED)
-			err = tcp_repair_options_est(tp, optval, optlen);
+			err = tcp_repair_options_est(tp,
+					(struct tcp_repair_opt __user *)optval,
+					optlen);
 		else
 			err = -EPERM;
 		break;
-- 
1.5.5.6
