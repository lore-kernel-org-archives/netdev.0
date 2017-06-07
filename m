From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 1/3] rxrpc: Provide a getsockopt call to query what
 cmsgs types are supported
Date: Wed, 07 Jun 2017 22:12:39 +0100
Message-ID: <149686995901.21359.5364493405042515983.stgit@warthog.procyon.org.uk>
References: <149686995195.21359.17550471913376009423.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <149686995195.21359.17550471913376009423.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Provide a getsockopt() call that can query what cmsg types are supported by
AF_RXRPC.
---

 Documentation/networking/rxrpc.txt |    9 +++++++++
 include/linux/rxrpc.h              |   24 ++++++++++++++----------
 net/rxrpc/af_rxrpc.c               |   30 +++++++++++++++++++++++++++++-
 3 files changed, 52 insertions(+), 11 deletions(-)

diff --git a/Documentation/networking/rxrpc.txt b/Documentation/networking/rxrpc.txt
index 18078e630a63..bce8e10a2a8e 100644
--- a/Documentation/networking/rxrpc.txt
+++ b/Documentation/networking/rxrpc.txt
@@ -406,6 +406,10 @@ calls, to invoke certain actions and to report certain conditions.  These are:
      future communication to that server and RXRPC_UPGRADE_SERVICE should no
      longer be set.
 
+The symbol RXRPC__SUPPORTED is defined as one more than the highest control
+message type supported.  At run time this can be queried by means of the
+RXRPC_SUPPORTED_CMSG socket option (see below).
+
 
 ==============
 SOCKET OPTIONS
@@ -459,6 +463,11 @@ AF_RXRPC sockets support a few socket options at the SOL_RXRPC level:
      must point to an array of two unsigned short ints.  The first is the
      service ID to upgrade from and the second the service ID to upgrade to.
 
+ (*) RXRPC_SUPPORTED_CMSG
+
+     This is a read-only option that writes an int into the buffer indicating
+     the highest control message type supported.
+
 
 ========
 SECURITY
diff --git a/include/linux/rxrpc.h b/include/linux/rxrpc.h
index 707910c6c6c5..bdd3175b9a48 100644
--- a/include/linux/rxrpc.h
+++ b/include/linux/rxrpc.h
@@ -38,6 +38,7 @@ struct sockaddr_rxrpc {
 #define RXRPC_EXCLUSIVE_CONNECTION	3	/* Deprecated; use RXRPC_EXCLUSIVE_CALL instead */
 #define RXRPC_MIN_SECURITY_LEVEL	4	/* minimum security level */
 #define RXRPC_UPGRADEABLE_SERVICE	5	/* Upgrade service[0] -> service[1] */
+#define RXRPC_SUPPORTED_CMSG		6	/* Get highest supported control message type */
 
 /*
  * RxRPC control messages
@@ -45,16 +46,19 @@ struct sockaddr_rxrpc {
  * - terminal messages mean that a user call ID tag can be recycled
  * - s/r/- indicate whether these are applicable to sendmsg() and/or recvmsg()
  */
-#define RXRPC_USER_CALL_ID	1	/* sr: user call ID specifier */
-#define RXRPC_ABORT		2	/* sr: abort request / notification [terminal] */
-#define RXRPC_ACK		3	/* -r: [Service] RPC op final ACK received [terminal] */
-#define RXRPC_NET_ERROR		5	/* -r: network error received [terminal] */
-#define RXRPC_BUSY		6	/* -r: server busy received [terminal] */
-#define RXRPC_LOCAL_ERROR	7	/* -r: local error generated [terminal] */
-#define RXRPC_NEW_CALL		8	/* -r: [Service] new incoming call notification */
-#define RXRPC_ACCEPT		9	/* s-: [Service] accept request */
-#define RXRPC_EXCLUSIVE_CALL	10	/* s-: Call should be on exclusive connection */
-#define RXRPC_UPGRADE_SERVICE	11	/* s-: Request service upgrade for client call */
+enum rxrpc_cmsg_type {
+	RXRPC_USER_CALL_ID	= 1,	/* sr: user call ID specifier */
+	RXRPC_ABORT		= 2,	/* sr: abort request / notification [terminal] */
+	RXRPC_ACK		= 3,	/* -r: [Service] RPC op final ACK received [terminal] */
+	RXRPC_NET_ERROR		= 5,	/* -r: network error received [terminal] */
+	RXRPC_BUSY		= 6,	/* -r: server busy received [terminal] */
+	RXRPC_LOCAL_ERROR	= 7,	/* -r: local error generated [terminal] */
+	RXRPC_NEW_CALL		= 8,	/* -r: [Service] new incoming call notification */
+	RXRPC_ACCEPT		= 9,	/* s-: [Service] accept request */
+	RXRPC_EXCLUSIVE_CALL	= 10,	/* s-: Call should be on exclusive connection */
+	RXRPC_UPGRADE_SERVICE	= 11,	/* s-: Request service upgrade for client call */
+	RXRPC__SUPPORTED
+};
 
 /*
  * RxRPC security levels
diff --git a/net/rxrpc/af_rxrpc.c b/net/rxrpc/af_rxrpc.c
index 0c4dc4a7832c..44a52b82bb5d 100644
--- a/net/rxrpc/af_rxrpc.c
+++ b/net/rxrpc/af_rxrpc.c
@@ -582,6 +582,34 @@ static int rxrpc_setsockopt(struct socket *sock, int level, int optname,
 }
 
 /*
+ * Get socket options.
+ */
+static int rxrpc_getsockopt(struct socket *sock, int level, int optname,
+			    char __user *optval, int __user *_optlen)
+{
+	int optlen;
+	
+	if (level != SOL_RXRPC)
+		return -EOPNOTSUPP;
+
+	if (get_user(optlen, _optlen))
+		return -EFAULT;
+	
+	switch (optname) {
+	case RXRPC_SUPPORTED_CMSG:
+		if (optlen < sizeof(int))
+			return -ETOOSMALL;
+		if (put_user(RXRPC__SUPPORTED - 1, (int __user *)optval) ||
+		    put_user(sizeof(int), _optlen))
+			return -EFAULT;
+		return 0;
+		
+	default:
+		return -EOPNOTSUPP;
+	}
+}
+
+/*
  * permit an RxRPC socket to be polled
  */
 static unsigned int rxrpc_poll(struct file *file, struct socket *sock,
@@ -784,7 +812,7 @@ static const struct proto_ops rxrpc_rpc_ops = {
 	.listen		= rxrpc_listen,
 	.shutdown	= rxrpc_shutdown,
 	.setsockopt	= rxrpc_setsockopt,
-	.getsockopt	= sock_no_getsockopt,
+	.getsockopt	= rxrpc_getsockopt,
 	.sendmsg	= rxrpc_sendmsg,
 	.recvmsg	= rxrpc_recvmsg,
 	.mmap		= sock_no_mmap,
