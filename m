From: Tom Herbert <therbert@google.com>
Subject: [RFC PATCH] xmit_compl_seq: information to reclaim vmsplice
 buffers
Date: Tue, 14 Sep 2010 13:28:08 -0700 (PDT)
Message-ID: <alpine.DEB.1.00.1009141318490.20088@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: sridharr@google.com
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.35]:37862 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754321Ab0INU2P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Sep 2010 16:28:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In this patch we propose to adds some socket API to retrieve the
 "transmit completion sequence number", essentially a byte counter
for the number of bytes that have been transmitted and will not be
retransmitted.  In the case of TCP, this should correspond to snd_una.

The purpose of this API is to provide information to userspace about
which buffers can be reclaimed when sending with vmsplice() on a
socket.

There are two methods for retrieving the completed sequence number:
through a simple getsockopt (implemented here for TCP), as well as
returning the value in the ancilary data of a recvmsg.

The expected flow would be something like:
   - Connect is created
   - Initial completion seq # is retrieved through the sockopt, and is
     stored in userspace "compl_seq" variable for the connection.
   - Whenever a send is done, compl_seq += # bytes sent.
   - When doing a vmsplice the completion sequence number is saved
     for each user space buffer, buffer_compl_seq = compl_seq.
   - When recvmsg returns with a completion sequence number in
     ancillary data, any buffers cover by that sequence number
     (where buffer_compl_seq < recvmsg_compl_seq) are reclaimed
     and can be written to again.
   - If no data is receieved on a connection (recvmsg does not
     return), a timeout can be used to call the getsockopt and
     reclaim buffers as a fallback.

Using recvmsg data in this manner is sort of a cheap way to get a
"callback" for when a vmspliced buffer is consumed.  It will work
well for a client where the response causes recvmsg to return.
On the server side it works well if there are a sufficient
number of requests coming on the connection (resorting to the
timeout if necessary as described above).

---
diff --git a/include/asm-generic/socket.h b/include/asm-generic/socket.h
index 9a6115e..6dc1ed8 100644
--- a/include/asm-generic/socket.h
+++ b/include/asm-generic/socket.h
@@ -64,4 +64,7 @@
 #define SO_DOMAIN		39
 
 #define SO_RXQ_OVFL             40
+
+#define SO_XMIT_COMPL_SEQ	41
+#define SCM_XMIT_COMPL_SEQ	SO_XMIT_COMPL_SEQ
 #endif /* __ASM_GENERIC_SOCKET_H */
diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index e64f4c6..f044aff 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -106,6 +106,7 @@ enum {
 #define TCP_THIN_LINEAR_TIMEOUTS 16      /* Use linear timeouts for thin streams*/
 #define TCP_THIN_DUPACK         17      /* Fast retrans. after 1 dupack */
 #define TCP_USER_TIMEOUT	18	/* How long for loss retry before timeout */
+#define TCP_XMIT_COMPL_SEQ	19	/* Return current snd_una */
 
 /* for TCP_INFO socket option */
 #define TCPI_OPT_TIMESTAMPS	1
diff --git a/include/net/sock.h b/include/net/sock.h
index 8ae97c4..e820e2b 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -543,6 +543,7 @@ enum sock_flags {
 	SOCK_TIMESTAMPING_SYS_HARDWARE, /* %SOF_TIMESTAMPING_SYS_HARDWARE */
 	SOCK_FASYNC, /* fasync() active */
 	SOCK_RXQ_OVFL,
+	SOCK_XMIT_COMPL_SEQ, /* SO_XMIT_COMPL_SEQ setting */
 };
 
 static inline void sock_copy_flags(struct sock *nsk, struct sock *osk)
diff --git a/net/core/sock.c b/net/core/sock.c
index f3a06c4..7a10215 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -740,6 +740,12 @@ set_rcvbuf:
 		else
 			sock_reset_flag(sk, SOCK_RXQ_OVFL);
 		break;
+	case SO_XMIT_COMPL_SEQ:
+		if (valbool)
+			sock_set_flag(sk, SOCK_XMIT_COMPL_SEQ);
+		else
+			sock_reset_flag(sk, SOCK_XMIT_COMPL_SEQ);
+		break;
 	default:
 		ret = -ENOPROTOOPT;
 		break;
@@ -961,6 +967,10 @@ int sock_getsockopt(struct socket *sock, int level, int optname,
 		v.val = !!sock_flag(sk, SOCK_RXQ_OVFL);
 		break;
 
+	case SO_XMIT_COMPL_SEQ:
+		v.val = !!sock_flag(sk, SOCK_XMIT_COMPL_SEQ);
+		break;
+
 	default:
 		return -ENOPROTOOPT;
 	}
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 3e8a4db..5e30381 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1387,6 +1387,21 @@ int tcp_read_sock(struct sock *sk, read_descriptor_t *desc,
 EXPORT_SYMBOL(tcp_read_sock);
 
 /*
+ * Copy the first unacked seq into the receive msg control part.
+ */
+static inline void tcp_sock_xmit_compl_seq(struct msghdr *msg,
+					   struct sock *sk)
+{
+	if (sock_flag(sk, SOCK_XMIT_COMPL_SEQ)) {
+		struct tcp_sock *tp = tcp_sk(sk);
+		if (msg->msg_controllen >= sizeof(tp->snd_una)) {
+			put_cmsg(msg, SOL_SOCKET, SCM_XMIT_COMPL_SEQ,
+			    sizeof(tp->snd_una), &tp->snd_una);
+		}
+	}
+}
+
+/*
  *	This routine copies from a sock struct into the user buffer.
  *
  *	Technical note: in 2.3 we work on _locked_ socket, so that
@@ -1763,6 +1778,8 @@ skip_copy:
 	 * on connected socket. I was just happy when found this 8) --ANK
 	 */
 
+	tcp_sock_xmit_compl_seq(msg, sk);
+
 	/* Clean up data we have read: This will do ACK frames. */
 	tcp_cleanup_rbuf(sk, copied);
 
@@ -2617,6 +2634,9 @@ static int do_tcp_getsockopt(struct sock *sk, int level,
 	case TCP_USER_TIMEOUT:
 		val = jiffies_to_msecs(icsk->icsk_user_timeout);
 		break;
+	case TCP_XMIT_COMPL_SEQ:
+		val = tp->snd_una;
+		break;
 	default:
 		return -ENOPROTOOPT;
 	}
