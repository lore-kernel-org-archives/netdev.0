From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (7/15) ax25 - size_t in send/recvmsg
Date: Fri, 9 Jan 2004 13:48:15 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040109134815.09ef4df0@linux.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, Ralf Baechle <ralf@linux-mips.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Convert Amateur Radio X.25 to unsigned size for send/receive.
Also enforce an MTU here, since there is no fragmentation logic.

diff -Nru a/net/ax25/af_ax25.c b/net/ax25/af_ax25.c
--- a/net/ax25/af_ax25.c	Mon Dec  8 16:19:49 2003
+++ b/net/ax25/af_ax25.c	Mon Dec  8 16:19:49 2003
@@ -1415,7 +1415,7 @@
 }
 
 static int ax25_sendmsg(struct kiocb *iocb, struct socket *sock,
-			struct msghdr *msg, int len)
+			struct msghdr *msg, size_t len)
 {
 	struct sockaddr_ax25 *usax = (struct sockaddr_ax25 *)msg->msg_name;
 	struct sock *sk = sock->sk;
@@ -1424,7 +1424,8 @@
 	ax25_digi dtmp, *dp;
 	unsigned char *asmptr;
 	ax25_cb *ax25;
-	int lv, size, err, addr_len = msg->msg_namelen;
+	size_t size;
+	int lv, err, addr_len = msg->msg_namelen;
 
 	if (msg->msg_flags & ~(MSG_DONTWAIT|MSG_EOR)) {
 		return -EINVAL;
@@ -1449,6 +1450,11 @@
 		goto out;
 	}
 
+	if (len > ax25->ax25_dev->dev->mtu) {
+		err = -EMSGSIZE;
+		goto out;
+	}
+		
 	if (usax != NULL) {
 		if (usax->sax25_family != AF_AX25) {
 			err = -EINVAL;
@@ -1594,7 +1600,7 @@
 }
 
 static int ax25_recvmsg(struct kiocb *iocb, struct socket *sock,
-	struct msghdr *msg, int size, int flags)
+	struct msghdr *msg, size_t size, int flags)
 {
 	struct sock *sk = sock->sk;
 	struct sk_buff *skb;
