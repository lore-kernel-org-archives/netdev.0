From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (2/17) ipv4/ipv6 - size_t for send/recvmsg
Date: Fri, 9 Jan 2004 13:39:50 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040109133950.52e423fd@linux.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Convert sendmsg/recvmsg from size as int to size as size_t.
Remove comment in UDP that addresses this very issue.

diff -Nru a/include/net/inet_common.h b/include/net/inet_common.h
--- a/include/net/inet_common.h	Fri Jan  9 13:38:06 2004
+++ b/include/net/inet_common.h	Fri Jan  9 13:38:06 2004
@@ -23,11 +23,11 @@
 extern int			inet_recvmsg(struct kiocb *iocb,
 					     struct socket *sock, 
 					     struct msghdr *ubuf, 
-					     int size, int flags);
+					     size_t size, int flags);
 extern int			inet_sendmsg(struct kiocb *iocb,
 					     struct socket *sock, 
 					     struct msghdr *msg, 
-					     int size);
+					     size_t size);
 extern int			inet_shutdown(struct socket *sock, int how);
 extern unsigned int		inet_poll(struct file * file, struct socket *sock, struct poll_table_struct *wait);
 extern int			inet_setsockopt(struct socket *sock, int level,
diff -Nru a/include/net/tcp.h b/include/net/tcp.h
--- a/include/net/tcp.h	Fri Jan  9 13:38:06 2004
+++ b/include/net/tcp.h	Fri Jan  9 13:38:06 2004
@@ -752,7 +752,7 @@
 extern int		    	tcp_v4_tw_remember_stamp(struct tcp_tw_bucket *tw);
 
 extern int			tcp_sendmsg(struct kiocb *iocb, struct sock *sk,
-					    struct msghdr *msg, int size);
+					    struct msghdr *msg, size_t size);
 extern ssize_t			tcp_sendpage(struct socket *sock, struct page *page, int offset, size_t size, int flags);
 
 extern int			tcp_ioctl(struct sock *sk, 
@@ -846,7 +846,7 @@
 extern void			tcp_set_keepalive(struct sock *sk, int val);
 extern int			tcp_recvmsg(struct kiocb *iocb, struct sock *sk,
 					    struct msghdr *msg,
-					    int len, int nonblock, 
+					    size_t len, int nonblock, 
 					    int flags, int *addr_len);
 
 extern int			tcp_listen_start(struct sock *sk);
diff -Nru a/include/net/udp.h b/include/net/udp.h
--- a/include/net/udp.h	Fri Jan  9 13:38:06 2004
+++ b/include/net/udp.h	Fri Jan  9 13:38:06 2004
@@ -68,7 +68,7 @@
 			    struct sockaddr *usin, int addr_len);
 
 extern int	udp_sendmsg(struct kiocb *iocb, struct sock *sk,
-			    struct msghdr *msg, int len);
+			    struct msghdr *msg, size_t len);
 
 extern int	udp_rcv(struct sk_buff *skb);
 extern int	udp_ioctl(struct sock *sk, int cmd, unsigned long arg);
diff -Nru a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
--- a/net/ipv4/af_inet.c	Fri Jan  9 13:38:06 2004
+++ b/net/ipv4/af_inet.c	Fri Jan  9 13:38:06 2004
@@ -731,7 +731,7 @@
 
 
 int inet_recvmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg,
-		 int size, int flags)
+		 size_t size, int flags)
 {
 	struct sock *sk = sock->sk;
 	int addr_len = 0;
@@ -746,7 +746,7 @@
 
 
 int inet_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg,
-		 int size)
+		 size_t size)
 {
 	struct sock *sk = sock->sk;
 
diff -Nru a/net/ipv4/raw.c b/net/ipv4/raw.c
--- a/net/ipv4/raw.c	Fri Jan  9 13:38:06 2004
+++ b/net/ipv4/raw.c	Fri Jan  9 13:38:06 2004
@@ -324,7 +324,7 @@
 }
 
 static int raw_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
-		       int len)
+		       size_t len)
 {
 	struct inet_opt *inet = inet_sk(sk);
 	struct ipcm_cookie ipc;
@@ -335,17 +335,6 @@
 	u8  tos;
 	int err;
 
-	/* This check is ONLY to check for arithmetic overflow
-	   on integer(!) len. Not more! Real check will be made
-	   in ip_build_xmit --ANK
-
-	   BTW socket.c -> af_*.c -> ... make multiple
-	   invalid conversions size_t -> int. We MUST repair it f.e.
-	   by replacing all of them with size_t and revise all
-	   the places sort of len += sizeof(struct iphdr)
-	   If len was ULONG_MAX-10 it would be cathastrophe  --ANK
-	 */
-
 	err = -EMSGSIZE;
 	if (len < 0 || len > 0xFFFF)
 		goto out;
@@ -523,10 +512,10 @@
  */
 
 int raw_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
-		int len, int noblock, int flags, int *addr_len)
+		size_t len, int noblock, int flags, int *addr_len)
 {
 	struct inet_opt *inet = inet_sk(sk);
-	int copied = 0;
+	size_t copied = 0;
 	int err = -EOPNOTSUPP;
 	struct sockaddr_in *sin = (struct sockaddr_in *)msg->msg_name;
 	struct sk_buff *skb;
diff -Nru a/net/ipv4/tcp.c b/net/ipv4/tcp.c
--- a/net/ipv4/tcp.c	Fri Jan  9 13:38:06 2004
+++ b/net/ipv4/tcp.c	Fri Jan  9 13:38:06 2004
@@ -1029,7 +1029,7 @@
 }
 
 int tcp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
-		int size)
+		size_t size)
 {
 	struct iovec *iov;
 	struct tcp_opt *tp = tcp_sk(sk);
@@ -1498,7 +1498,7 @@
  */
 
 int tcp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
-		int len, int nonblock, int flags, int *addr_len)
+		size_t len, int nonblock, int flags, int *addr_len)
 {
 	struct tcp_opt *tp = tcp_sk(sk);
 	int copied = 0;
diff -Nru a/net/ipv4/udp.c b/net/ipv4/udp.c
--- a/net/ipv4/udp.c	Fri Jan  9 13:38:06 2004
+++ b/net/ipv4/udp.c	Fri Jan  9 13:38:06 2004
@@ -478,7 +478,7 @@
 }
 
 int udp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
-		int len)
+		size_t len)
 {
 	struct inet_opt *inet = inet_sk(sk);
 	struct udp_opt *up = udp_sk(sk);
@@ -493,18 +493,7 @@
 	int err;
 	int corkreq = up->corkflag || msg->msg_flags&MSG_MORE;
 
-	/* This check is ONLY to check for arithmetic overflow
-	   on integer(!) len. Not more! Real check will be made
-	   in ip_append_* --ANK
-
-	   BTW socket.c -> af_*.c -> ... make multiple
-	   invalid conversions size_t -> int. We MUST repair it f.e.
-	   by replacing all of them with size_t and revise all
-	   the places sort of len += sizeof(struct iphdr)
-	   If len was ULONG_MAX-10 it would be cathastrophe  --ANK
-	 */
-
-	if (len < 0 || len > 0xFFFF)
+	if (len > 0xFFFF)
 		return -EMSGSIZE;
 
 	/* 
@@ -782,7 +771,7 @@
  */
 
 int udp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
-		int len, int noblock, int flags, int *addr_len)
+		size_t len, int noblock, int flags, int *addr_len)
 {
 	struct inet_opt *inet = inet_sk(sk);
   	struct sockaddr_in *sin = (struct sockaddr_in *)msg->msg_name;
diff -Nru a/net/ipv6/raw.c b/net/ipv6/raw.c
--- a/net/ipv6/raw.c	Fri Jan  9 13:38:06 2004
+++ b/net/ipv6/raw.c	Fri Jan  9 13:38:06 2004
@@ -345,13 +345,15 @@
  *	we return it, otherwise we block.
  */
 
-static int rawv6_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg, int len,
+static int rawv6_recvmsg(struct kiocb *iocb, struct sock *sk,
+		  struct msghdr *msg, size_t len,
 		  int noblock, int flags, int *addr_len)
 {
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct sockaddr_in6 *sin6 = (struct sockaddr_in6 *)msg->msg_name;
 	struct sk_buff *skb;
-	int copied, err;
+	size_t copied;
+	int err;
 
 	if (flags & MSG_OOB)
 		return -EOPNOTSUPP;
@@ -527,7 +529,8 @@
 	IP6_INC_STATS(Ip6OutDiscards);
 	return err; 
 }
-static int rawv6_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg, int len)
+static int rawv6_sendmsg(struct kiocb *iocb, struct sock *sk,
+		   struct msghdr *msg, size_t len)
 {
 	struct ipv6_txoptions opt_space;
 	struct sockaddr_in6 * sin6 = (struct sockaddr_in6 *) msg->msg_name;
diff -Nru a/net/ipv6/udp.c b/net/ipv6/udp.c
--- a/net/ipv6/udp.c	Fri Jan  9 13:38:06 2004
+++ b/net/ipv6/udp.c	Fri Jan  9 13:38:06 2004
@@ -366,12 +366,14 @@
  * 	return it, otherwise we block.
  */
 
-static int udpv6_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg, int len,
+static int udpv6_recvmsg(struct kiocb *iocb, struct sock *sk, 
+		  struct msghdr *msg, size_t len,
 		  int noblock, int flags, int *addr_len)
 {
 	struct ipv6_pinfo *np = inet6_sk(sk);
   	struct sk_buff *skb;
-  	int copied, err;
+	size_t copied;
+  	int err;
 
   	if (addr_len)
   		*addr_len=sizeof(struct sockaddr_in6);
@@ -774,7 +776,8 @@
 	return err;
 }
 
-static int udpv6_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg, int len)
+static int udpv6_sendmsg(struct kiocb *iocb, struct sock *sk, 
+		  struct msghdr *msg, size_t len)
 {
 	struct ipv6_txoptions opt_space;
 	struct udp_opt *up = udp_sk(sk);
@@ -841,7 +844,7 @@
 	/* Rough check on arithmetic overflow,
 	   better check is made in ip6_build_xmit
 	   */
-	if (len < 0 || len > INT_MAX - sizeof(struct udphdr))
+	if (len > INT_MAX - sizeof(struct udphdr))
 		return -EMSGSIZE;
 	
 	if (up->pending) {
diff -Nru a/net/sctp/socket.c b/net/sctp/socket.c
--- a/net/sctp/socket.c	Fri Jan  9 13:38:06 2004
+++ b/net/sctp/socket.c	Fri Jan  9 13:38:06 2004
@@ -90,7 +90,7 @@
 static inline void sctp_set_owner_w(struct sctp_chunk *chunk);
 static void sctp_wfree(struct sk_buff *skb);
 static int sctp_wait_for_sndbuf(struct sctp_association *, long *timeo_p,
-				int msg_len);
+				size_t msg_len);
 static int sctp_wait_for_packet(struct sock * sk, int *err, long *timeo_p);
 static int sctp_wait_for_connect(struct sctp_association *, long *timeo_p);
 static int sctp_wait_for_accept(struct sock *sk, long timeo);
@@ -943,7 +943,7 @@
 SCTP_STATIC int sctp_msghdr_parse(const struct msghdr *, sctp_cmsgs_t *);
 
 SCTP_STATIC int sctp_sendmsg(struct kiocb *iocb, struct sock *sk,
-			     struct msghdr *msg, int msg_len)
+			     struct msghdr *msg, size_t msg_len)
 {
 	struct sctp_opt *sp;
 	struct sctp_endpoint *ep;
@@ -965,7 +965,7 @@
 	struct list_head *pos;
 	int msg_flags = msg->msg_flags;
 
-	SCTP_DEBUG_PRINTK("sctp_sendmsg(sk: %p, msg: %p, msg_len: %d)\n",
+	SCTP_DEBUG_PRINTK("sctp_sendmsg(sk: %p, msg: %p, msg_len: %u)\n",
 			  sk, msg, msg_len);
 
 	err = 0;
@@ -1021,7 +1021,7 @@
 		associd = sinfo->sinfo_assoc_id;
 	}
 
-	SCTP_DEBUG_PRINTK("msg_len: %d, sinfo_flags: 0x%x\n",
+	SCTP_DEBUG_PRINTK("msg_len: %u, sinfo_flags: 0x%x\n",
 			  msg_len, sinfo_flags);
 
 	/* MSG_EOF or MSG_ABORT cannot be set on a TCP-style socket. */
@@ -1377,7 +1377,7 @@
 static struct sk_buff *sctp_skb_recv_datagram(struct sock *, int, int, int *);
 
 SCTP_STATIC int sctp_recvmsg(struct kiocb *iocb, struct sock *sk,
-			     struct msghdr *msg, int len, int noblock,
+			     struct msghdr *msg, size_t len, int noblock,
 			     int flags, int *addr_len)
 {
 	struct sctp_ulpevent *event = NULL;
@@ -4157,14 +4157,14 @@
 
 /* Helper function to wait for space in the sndbuf.  */
 static int sctp_wait_for_sndbuf(struct sctp_association *asoc, long *timeo_p,
-				int msg_len)
+				size_t msg_len)
 {
 	struct sock *sk = asoc->base.sk;
 	int err = 0;
 	long current_timeo = *timeo_p;
 	DEFINE_WAIT(wait);
 
-	SCTP_DEBUG_PRINTK("wait_for_sndbuf: asoc=%p, timeo=%ld, msg_len=%d\n",
+	SCTP_DEBUG_PRINTK("wait_for_sndbuf: asoc=%p, timeo=%ld, msg_len=%u\n",
 	                  asoc, (long)(*timeo_p), msg_len);
 
 	/* Increment the association's refcnt.  */
