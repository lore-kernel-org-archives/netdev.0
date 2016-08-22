From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH net-next] net-tcp: retire TFO_SERVER_WO_SOCKOPT2 config
Date: Mon, 22 Aug 2016 16:30:05 -0700
Message-ID: <1471908605-10080-1-git-send-email-ycheng@google.com>
Cc: netdev@vger.kernel.org, ncardwell@google.com, edumazet@google.com,
        Yuchung Cheng <ycheng@google.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:33696 "EHLO
        mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933038AbcHVXaX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2016 19:30:23 -0400
Received: by mail-pf0-f180.google.com with SMTP id y134so36897259pfg.0
        for <netdev@vger.kernel.org>; Mon, 22 Aug 2016 16:30:22 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

TFO_SERVER_WO_SOCKOPT2 was intended for debugging purposes during
Fast Open development. Remove this config option and also
update/clean-up the documentation of the Fast Open sysctl.

Reported-by: Piotr Jurkiewicz <piotr.jerzy.jurkiewicz@gmail.com>
---
 Documentation/networking/ip-sysctl.txt | 45 +++++++++++++++++-----------------
 include/net/tcp.h                      |  3 +--
 net/ipv4/af_inet.c                     | 21 ++++++----------
 3 files changed, 32 insertions(+), 37 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index 9ae9293..3db8c67 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -575,32 +575,33 @@ tcp_syncookies - BOOLEAN
 	unconditionally generation of syncookies.
 
 tcp_fastopen - INTEGER
-	Enable TCP Fast Open feature (draft-ietf-tcpm-fastopen) to send data
-	in the opening SYN packet. To use this feature, the client application
-	must use sendmsg() or sendto() with MSG_FASTOPEN flag rather than
-	connect() to perform a TCP handshake automatically.
+	Enable TCP Fast Open (RFC7413) to send and accept data in the opening
+	SYN packet.
 
-	The values (bitmap) are
-	1: Enables sending data in the opening SYN on the client w/ MSG_FASTOPEN.
-	2: Enables TCP Fast Open on the server side, i.e., allowing data in
-	   a SYN packet to be accepted and passed to the application before
-	   3-way hand shake finishes.
-	4: Send data in the opening SYN regardless of cookie availability and
-	   without a cookie option.
-	0x100: Accept SYN data w/o validating the cookie.
-	0x200: Accept data-in-SYN w/o any cookie option present.
-	0x400/0x800: Enable Fast Open on all listeners regardless of the
-	   TCP_FASTOPEN socket option. The two different flags designate two
-	   different ways of setting max_qlen without the TCP_FASTOPEN socket
-	   option.
+	The client support is enabled by flag 0x1 (on by default). The client
+	then must use sendmsg() or sendto() with the MSG_FASTOPEN flag,
+	rather than connect() to send data in SYN.
 
-	Default: 1
+	The server support is enabled by flag 0x2 (off by default). Then
+	either enable for all listeners with another flag (0x400) or
+	enable individual listeners via TCP_FASTOPEN socket option with
+	the option value being the length of the syn-data backlog.
 
-	Note that the client & server side Fast Open flags (1 and 2
-	respectively) must be also enabled before the rest of flags can take
-	effect.
+	The values (bitmap) are
+	  0x1: (client) enables sending data in the opening SYN on the client.
+	  0x2: (server) enables the server support, i.e., allowing data in
+			a SYN packet to be accepted and passed to the
+			application before 3-way handshake finishes.
+	  0x4: (client) send data in the opening SYN regardless of cookie
+			availability and without a cookie option.
+	0x200: (server) accept data-in-SYN w/o any cookie option present.
+	0x400: (server) enable all listeners to support Fast Open by
+			default without explicit TCP_FASTOPEN socket option.
+
+	Default: 0x1
 
-	See include/net/tcp.h and the code for more details.
+	Note that that additional client or server features are only
+	effective if the basic support (0x1 and 0x2) are enabled respectively.
 
 tcp_syn_retries - INTEGER
 	Number of times initial SYNs for an active TCP connection attempt
diff --git a/include/net/tcp.h b/include/net/tcp.h
index c00e7d5..25d64f6 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -227,10 +227,9 @@ void tcp_time_wait(struct sock *sk, int state, int timeo);
 #define	TFO_SERVER_COOKIE_NOT_REQD	0x200
 
 /* Force enable TFO on all listeners, i.e., not requiring the
- * TCP_FASTOPEN socket option. SOCKOPT1/2 determine how to set max_qlen.
+ * TCP_FASTOPEN socket option.
  */
 #define	TFO_SERVER_WO_SOCKOPT1	0x400
-#define	TFO_SERVER_WO_SOCKOPT2	0x800
 
 extern struct inet_timewait_death_row tcp_death_row;
 
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 55513e6..989a362 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -211,24 +211,19 @@ int inet_listen(struct socket *sock, int backlog)
 	 * we can only allow the backlog to be adjusted.
 	 */
 	if (old_state != TCP_LISTEN) {
-		/* Check special setups for testing purpose to enable TFO w/o
-		 * requiring TCP_FASTOPEN sockopt.
+		/* Enable TFO w/o requiring TCP_FASTOPEN socket option.
 		 * Note that only TCP sockets (SOCK_STREAM) will reach here.
-		 * Also fastopenq may already been allocated because this
-		 * socket was in TCP_LISTEN state previously but was
-		 * shutdown() (rather than close()).
+		 * Also fastopen backlog may already been set via the option
+		 * because the socket was in TCP_LISTEN state previously but
+		 * was shutdown() rather than close().
 		 */
-		if ((sysctl_tcp_fastopen & TFO_SERVER_ENABLE) != 0 &&
+		if ((sysctl_tcp_fastopen & TFO_SERVER_WO_SOCKOPT1) &&
+		    (sysctl_tcp_fastopen & TFO_SERVER_ENABLE) &&
 		    !inet_csk(sk)->icsk_accept_queue.fastopenq.max_qlen) {
-			if ((sysctl_tcp_fastopen & TFO_SERVER_WO_SOCKOPT1) != 0)
-				fastopen_queue_tune(sk, backlog);
-			else if ((sysctl_tcp_fastopen &
-				  TFO_SERVER_WO_SOCKOPT2) != 0)
-				fastopen_queue_tune(sk,
-				    ((uint)sysctl_tcp_fastopen) >> 16);
-
+			fastopen_queue_tune(sk, backlog);
 			tcp_fastopen_init_key_once(true);
 		}
+
 		err = inet_csk_listen_start(sk, backlog);
 		if (err)
 			goto out;
-- 
2.8.0.rc3.226.g39d4020
