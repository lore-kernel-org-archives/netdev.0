From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (11/17) econet -- size_t for send/recvmsg
Date: Fri, 9 Jan 2004 14:03:23 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040109140323.7d48f9db@linux.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Convert econet over to unsigned length for send/recv msg.
Add a bounds check based on device mtu - header.

diff -Nru a/net/econet/af_econet.c b/net/econet/af_econet.c
--- a/net/econet/af_econet.c	Mon Dec  8 16:20:01 2003
+++ b/net/econet/af_econet.c	Mon Dec  8 16:20:01 2003
@@ -113,11 +113,12 @@
  */
 
 static int econet_recvmsg(struct kiocb *iocb, struct socket *sock,
-			  struct msghdr *msg, int len, int flags)
+			  struct msghdr *msg, size_t len, int flags)
 {
 	struct sock *sk = sock->sk;
 	struct sk_buff *skb;
-	int copied, err;
+	size_t copied;
+	int err;
 
 	msg->msg_namelen = sizeof(struct sockaddr_ec);
 
@@ -246,7 +247,7 @@
  */
 
 static int econet_sendmsg(struct kiocb *iocb, struct socket *sock,
-			  struct msghdr *msg, int len)
+			  struct msghdr *msg, size_t len)
 {
 	struct sock *sk = sock->sk;
 	struct sockaddr_ec *saddr=(struct sockaddr_ec *)msg->msg_name;
@@ -307,6 +308,9 @@
 		if (dev == NULL)
 			return -ENETDOWN;
 	}
+
+	if (len + 15 > dev->mtu)
+		return -EMSGSIZE;
 
 	if (dev->type == ARPHRD_ECONET)
 	{
