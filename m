From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (8/17) ipx -- size_t for send/recvmsg
Date: Fri, 9 Jan 2004 14:02:23 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040109140223.3926cbeb@linux.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>,
        Arnaldo Carvalho de Melo
 <acme@conectiva.com.br>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Convert IPX to unsigned for send/receive message length.
Enforce MTU limited by header pktsize.

diff -Nru a/net/ipx/af_ipx.c b/net/ipx/af_ipx.c
--- a/net/ipx/af_ipx.c	Mon Dec  8 16:19:52 2003
+++ b/net/ipx/af_ipx.c	Mon Dec  8 16:19:52 2003
@@ -1683,7 +1683,7 @@
 }
 
 static int ipx_sendmsg(struct kiocb *iocb, struct socket *sock,
-	struct msghdr *msg, int len)
+	struct msghdr *msg, size_t len)
 {
 	struct sock *sk = sock->sk;
 	struct ipx_opt *ipxs = ipx_sk(sk);
@@ -1698,6 +1698,10 @@
 	if (flags & ~MSG_DONTWAIT)
 		goto out;
 
+	/* Max possible packet size limited by 16 bit pktsize in header */
+	if (len >= 65535 - sizeof(struct ipxhdr))
+		goto out;
+
 	if (usipx) {
 		if (!ipxs->port) {
 			struct sockaddr_ipx uaddr;
@@ -1744,7 +1748,7 @@
 
 
 static int ipx_recvmsg(struct kiocb *iocb, struct socket *sock,
-		struct msghdr *msg, int size, int flags)
+		struct msghdr *msg, size_t size, int flags)
 {
 	struct sock *sk = sock->sk;
 	struct ipx_opt *ipxs = ipx_sk(sk);
diff -Nru a/net/ipx/ipx_route.c b/net/ipx/ipx_route.c
--- a/net/ipx/ipx_route.c	Mon Dec  8 16:19:52 2003
+++ b/net/ipx/ipx_route.c	Mon Dec  8 16:19:52 2003
@@ -169,13 +169,13 @@
  * Route an outgoing frame from a socket.
  */
 int ipxrtr_route_packet(struct sock *sk, struct sockaddr_ipx *usipx,
-			struct iovec *iov, int len, int noblock)
+			struct iovec *iov, size_t len, int noblock)
 {
 	struct sk_buff *skb;
 	struct ipx_opt *ipxs = ipx_sk(sk);
 	struct ipx_interface *intrfc;
 	struct ipxhdr *ipx;
-	int size;
+	size_t size;
 	int ipx_offset;
 	struct ipx_route *rt = NULL;
 	int rc;
