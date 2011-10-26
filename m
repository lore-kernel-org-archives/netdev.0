From: Andy Lutomirski <luto@amacapital.net>
Subject: [PATCH] Add TCP_NO_DELAYED_ACK socket option
Date: Tue, 25 Oct 2011 19:25:27 -0700
Message-ID: <fc8b00b9978b4f956fa705badfaa138854abf919.1319595687.git.luto@amacapital.net>
Cc: Andy Lutomirski <luto@amacapital.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f181.google.com ([209.85.216.181]:33188 "EHLO
	mail-qy0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753115Ab1JZC0F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Oct 2011 22:26:05 -0400
Received: by qyk27 with SMTP id 27so1325301qyk.19
        for <netdev@vger.kernel.org>; Tue, 25 Oct 2011 19:26:04 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When talking to an unfixable interactive peer that fails to set
TCP_NODELAY, disabling delayed ACKs can help mitigate the problem.
This is an evil thing to do, but if the entire network is private,
it's not that evil.

This works around a problem with the remote *application*, so make
it a socket option instead of a sysctl or a per-route option.

Signed-off-by: Andy Lutomirski <luto@amacapital.net>
---

This patch is a bit embarrassing.  We talk to remote applications over
TCP that are very much interactive but don't set TCP_NODELAY.  These
applications apparently cannot be fixed.  As a partial workaround, if we
ACK every incoming segment, then as long as they don't transmit two
segments per rtt, we do pretty well.

Windows can do something similar, but it's per interface instead of per
socket:

http://support.microsoft.com/kb/328890

 include/linux/tcp.h                |    1 +
 include/net/inet_connection_sock.h |    3 ++-
 net/ipv4/tcp.c                     |   11 +++++++++++
 net/ipv4/tcp_input.c               |    3 ++-
 4 files changed, 16 insertions(+), 2 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 531ede8..2116f31 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -106,6 +106,7 @@ enum {
 #define TCP_THIN_LINEAR_TIMEOUTS 16      /* Use linear timeouts for thin streams*/
 #define TCP_THIN_DUPACK         17      /* Fast retrans. after 1 dupack */
 #define TCP_USER_TIMEOUT	18	/* How long for loss retry before timeout */
+#define TCP_NO_DELAYED_ACK	19	/* Do not delay ACKs.  */
 
 /* for TCP_INFO socket option */
 #define TCPI_OPT_TIMESTAMPS	1
diff --git a/include/net/inet_connection_sock.h b/include/net/inet_connection_sock.h
index e6db62e..1ad91bf 100644
--- a/include/net/inet_connection_sock.h
+++ b/include/net/inet_connection_sock.h
@@ -106,8 +106,9 @@ struct inet_connection_sock {
 	struct {
 		__u8		  pending;	 /* ACK is pending			   */
 		__u8		  quick;	 /* Scheduled number of quick acks	   */
-		__u8		  pingpong;	 /* The session is interactive		   */
 		__u8		  blocked;	 /* Delayed ACK was blocked by socket lock */
+		__u8		  pingpong:1;	 /* The session is interactive		   */
+		__u8		  nodelack:1;	 /* Delayed ACKs are disabled		   */
 		__u32		  ato;		 /* Predicted tick of soft clock	   */
 		unsigned long	  timeout;	 /* Currently scheduled timeout		   */
 		__u32		  lrcvtime;	 /* timestamp of last received data packet */
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 46febca..e8e98dc 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2385,6 +2385,13 @@ static int do_tcp_setsockopt(struct sock *sk, int level,
 		}
 		break;
 
+	case TCP_NO_DELAYED_ACK:
+		if (val == 0 || val == 1)
+			icsk->icsk_ack.nodelack = !!val;
+		else
+			err = -EINVAL;
+		break;
+
 #ifdef CONFIG_TCP_MD5SIG
 	case TCP_MD5SIG:
 		/* Read the IP->Key mappings from userspace */
@@ -2564,6 +2571,10 @@ static int do_tcp_getsockopt(struct sock *sk, int level,
 		val = !icsk->icsk_ack.pingpong;
 		break;
 
+	case TCP_NO_DELAYED_ACK:
+		val = icsk->icsk_ack.nodelack;
+		break;
+
 	case TCP_CONGESTION:
 		if (get_user(len, optlen))
 			return -EFAULT;
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 21fab3e..e7d7ee0 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -197,7 +197,8 @@ static void tcp_enter_quickack_mode(struct sock *sk)
 static inline int tcp_in_quickack_mode(const struct sock *sk)
 {
 	const struct inet_connection_sock *icsk = inet_csk(sk);
-	return icsk->icsk_ack.quick && !icsk->icsk_ack.pingpong;
+	return (icsk->icsk_ack.quick && !icsk->icsk_ack.pingpong) ||
+		icsk->icsk_ack.nodelack;
 }
 
 static inline void TCP_ECN_queue_cwr(struct tcp_sock *tp)
-- 
1.7.6.4
