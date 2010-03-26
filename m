From: Brandon L Black <blblack@gmail.com>
Subject: [PATCH] Add MSG_WAITFORONE flag to recvmmsg
Date: Fri, 26 Mar 2010 17:35:30 -0500
Message-ID: <20100326223530.GA11817@xpc.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Arnaldo Carvalho de Melo <acme@redhat.com>,
	Ulrich Drepper <drepper@gmail.com>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


From: Brandon L Black <blblack@gmail.com>

Add new flag MSG_WAITFORONE for the recvmmsg() syscall.
When this flag is specified for a blocking socket, recvmmsg()
will only block until at least 1 packet is available.  The
default behavior is to block until all vlen packets are
available.  This flag has no effect on non-blocking sockets
or when used in combination with MSG_DONTWAIT.

Signed-off-by: Brandon L Black <blblack@gmail.com>

---
diff --git a/include/linux/socket.h b/include/linux/socket.h
index 7b3aae2..354cc56 100644
--- a/include/linux/socket.h
+++ b/include/linux/socket.h
@@ -255,6 +255,7 @@ struct ucred {
 #define MSG_ERRQUEUE	0x2000	/* Fetch message from error queue */
 #define MSG_NOSIGNAL	0x4000	/* Do not generate SIGPIPE */
 #define MSG_MORE	0x8000	/* Sender will send more */
+#define MSG_WAITFORONE	0x10000	/* recvmmsg(): block until 1+ packets avail */
 
 #define MSG_EOF         MSG_FIN
 
diff --git a/net/socket.c b/net/socket.c
index 769c386..33304d1 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -2133,7 +2133,10 @@ int __sys_recvmmsg(int fd, struct mmsghdr __user *mmsg, unsigned int vlen,
 
 		if (err)
 			break;
-		++datagrams;
+
+		/* MSG_WAITFORONE turns on MSG_DONTWAIT after one packet */
+		if (!datagrams++ && (flags & MSG_WAITFORONE))
+			flags |= MSG_DONTWAIT;
 
 		if (timeout) {
 			ktime_get_ts(timeout);
