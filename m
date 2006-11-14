From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [PATCHv2  2/2]: net/ipv{4,6}: reduce code size by inlining
Date: Tue, 14 Nov 2006 08:49:18 +0000
Message-ID: <200611140849.18324@strip-the-willow>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:24741 "EHLO erg.abdn.ac.uk")
	by vger.kernel.org with ESMTP id S933286AbWKNItl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Nov 2006 03:49:41 -0500
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[UDP]: Reduce size of shared code

This patch reduces size of source code files by moving
some of the smaller functions shared by UDP and UDP-Lite
into the header file udp_impl.h, and in-lining these.

It is an optimisation and applies on top of the previous
UDP-Lite patch.


Signed-off-by: Gerrit Renker  <gerrit@erg.abdn.ac.uk>
------------------------------------------------------------------------------

 net/ipv4/udp.c      |   74 ++-------------------------------------------------
 net/ipv4/udp_impl.h |   75 +++++++++++++++++++++++++++++++++++++++++++++-------
 net/ipv6/udp.c      |   70 ++----------------------------------------------
 net/ipv6/udp_impl.h |   72 +++++++++++++++++++++++++++++++++++++++++++------
 4 files changed, 136 insertions(+), 155 deletions(-)

------------------------------------------------------------------------------

diff --git a/net/ipv4/udp_impl.h b/net/ipv4/udp_impl.h
index f6f4277..3d12aca 100644
--- a/net/ipv4/udp_impl.h
+++ b/net/ipv4/udp_impl.h
@@ -11,26 +11,81 @@ extern void 	__udp4_lib_err(struct sk_bu
 extern int	__udp_lib_get_port(struct sock *sk, unsigned short snum,
 				   struct hlist_head udptable[], int *port_rover,
 		       	       	   int (*)(const struct sock*,const struct sock*));
-extern int	ipv4_rcv_saddr_equal(const struct sock *, const struct sock *);
 
+static inline int ipv4_rcv_saddr_equal(const struct sock *sk1, const struct sock *sk2)
+{
+	struct inet_sock *inet1 = inet_sk(sk1), *inet2 = inet_sk(sk2);
 
-extern int	udp_setsockopt(struct sock *sk, int level, int optname,
-			       char __user *optval, int optlen);
-extern int	udp_getsockopt(struct sock *sk, int level, int optname,
-			       char __user *optval, int __user *optlen);
+	return 	( !ipv6_only_sock(sk2)  &&
+		  (!inet1->rcv_saddr || !inet2->rcv_saddr ||
+		   inet1->rcv_saddr == inet2->rcv_saddr      ));
+}
+
+extern int	do_udp_setsockopt(struct sock *sk, int level, int optname,
+				  char __user *optval, int optlen);
+extern int	do_udp_getsockopt(struct sock *sk, int level, int optname,
+			          char __user *optval, int __user *optlen);
+
+static inline int udp_setsockopt(struct sock *sk, int level, int optname,
+		   		 char __user *optval, int optlen)
+{
+	if (level == SOL_UDP  ||  level == SOL_UDPLITE)
+		return do_udp_setsockopt(sk, level, optname, optval, optlen);
+	return ip_setsockopt(sk, level, optname, optval, optlen);
+}
+
+static inline int udp_getsockopt(struct sock *sk, int level, int optname,
+				 char __user *optval, int __user *optlen)
+{
+	if (level == SOL_UDP  ||  level == SOL_UDPLITE)
+		return do_udp_getsockopt(sk, level, optname, optval, optlen);
+	return ip_getsockopt(sk, level, optname, optval, optlen);
+}
 
 #ifdef CONFIG_COMPAT
-extern int	compat_udp_setsockopt(struct sock *sk, int level, int optname,
-				      char __user *optval, int optlen);
-extern int	compat_udp_getsockopt(struct sock *sk, int level, int optname,
-				      char __user *optval, int __user *optlen);
+static inline int compat_udp_setsockopt(struct sock *sk, int level, int optname,
+			  		char __user *optval, int optlen)
+{
+	if (level == SOL_UDP  ||  level == SOL_UDPLITE)
+		return do_udp_setsockopt(sk, level, optname, optval, optlen);
+	return compat_ip_setsockopt(sk, level, optname, optval, optlen);
+}
+static inline int compat_udp_getsockopt(struct sock *sk, int level, int optname,
+				 	char __user *optval, int __user *optlen)
+{
+	if (level == SOL_UDP  ||  level == SOL_UDPLITE)
+		return do_udp_getsockopt(sk, level, optname, optval, optlen);
+	return compat_ip_getsockopt(sk, level, optname, optval, optlen);
+}
 #endif
+
 extern int	udp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 			    size_t len, int noblock, int flags, int *addr_len);
 extern int	udp_sendpage(struct sock *sk, struct page *page, int offset,
 			     size_t size, int flags);
 extern int	udp_queue_rcv_skb(struct sock * sk, struct sk_buff *skb);
-extern int	udp_destroy_sock(struct sock *sk);
+
+/*
+ * Throw away all pending data and cancel the corking. Socket is locked.
+ */
+static inline void udp_flush_pending_frames(struct sock *sk)
+{
+	struct udp_sock *up = udp_sk(sk);
+
+	if (up->pending) {
+		up->len = 0;
+		up->pending = 0;
+		ip_flush_pending_frames(sk);
+	}
+}
+
+static inline int udp_destroy_sock(struct sock *sk)
+{
+	lock_sock(sk);
+	udp_flush_pending_frames(sk);
+	release_sock(sk);
+	return 0;
+}
 
 #ifdef CONFIG_PROC_FS
 extern int	udp4_seq_show(struct seq_file *seq, void *v);
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 227655c..930da4a 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -214,15 +214,6 @@ __inline__ int udp_get_port(struct sock 
 	return  __udp_lib_get_port(sk, snum, udp_hash, &udp_port_rover, scmp);
 }
 
-inline int ipv4_rcv_saddr_equal(const struct sock *sk1, const struct sock *sk2)
-{
-	struct inet_sock *inet1 = inet_sk(sk1), *inet2 = inet_sk(sk2);
-
-	return 	( !ipv6_only_sock(sk2)  &&
-		  (!inet1->rcv_saddr || !inet2->rcv_saddr ||
-		   inet1->rcv_saddr == inet2->rcv_saddr      ));
-}
-
 static inline int udp_v4_get_port(struct sock *sk, unsigned short snum)
 {
 	return udp_get_port(sk, snum, ipv4_rcv_saddr_equal);
@@ -391,20 +382,6 @@ __inline__ void udp_err(struct sk_buff *
 	return __udp4_lib_err(skb, info, udp_hash);
 }
 
-/*
- * Throw away all pending data and cancel the corking. Socket is locked.
- */
-static void udp_flush_pending_frames(struct sock *sk)
-{
-	struct udp_sock *up = udp_sk(sk);
-
-	if (up->pending) {
-		up->len = 0;
-		up->pending = 0;
-		ip_flush_pending_frames(sk);
-	}
-}
-
 /**
  * 	udp4_hwcsum_outgoing  -  handle outgoing HW checksumming
  * 	@sk: 	socket we are sending on
@@ -1278,19 +1255,11 @@ __inline__ int udp_rcv(struct sk_buff *s
 	return __udp4_lib_rcv(skb, udp_hash, 0);
 }
 
-int udp_destroy_sock(struct sock *sk)
-{
-	lock_sock(sk);
-	udp_flush_pending_frames(sk);
-	release_sock(sk);
-	return 0;
-}
-
 /*
  *	Socket option code for UDP
  */
-static int do_udp_setsockopt(struct sock *sk, int level, int optname,
-			  char __user *optval, int optlen)
+int do_udp_setsockopt(struct sock *sk, int level, int optname,
+		      char __user *optval, int optlen)
 {
 	struct udp_sock *up = udp_sk(sk);
 	int val;
@@ -1361,26 +1330,8 @@ static int do_udp_setsockopt(struct sock
 	return err;
 }
 
-int udp_setsockopt(struct sock *sk, int level, int optname,
-		   char __user *optval, int optlen)
-{
-	if (level == SOL_UDP  ||  level == SOL_UDPLITE)
-		return do_udp_setsockopt(sk, level, optname, optval, optlen);
-	return ip_setsockopt(sk, level, optname, optval, optlen);
-}
-
-#ifdef CONFIG_COMPAT
-int compat_udp_setsockopt(struct sock *sk, int level, int optname,
-			  char __user *optval, int optlen)
-{
-	if (level == SOL_UDP  ||  level == SOL_UDPLITE)
-		return do_udp_setsockopt(sk, level, optname, optval, optlen);
-	return compat_ip_setsockopt(sk, level, optname, optval, optlen);
-}
-#endif
-
-static int do_udp_getsockopt(struct sock *sk, int level, int optname,
-			  char __user *optval, int __user *optlen)
+int do_udp_getsockopt(struct sock *sk, int level, int optname,
+		      char __user *optval, int __user *optlen)
 {
 	struct udp_sock *up = udp_sk(sk);
 	int val, len;
@@ -1423,23 +1374,6 @@ static int do_udp_getsockopt(struct sock
   	return 0;
 }
 
-int udp_getsockopt(struct sock *sk, int level, int optname,
-		   char __user *optval, int __user *optlen)
-{
-	if (level == SOL_UDP  ||  level == SOL_UDPLITE)
-		return do_udp_getsockopt(sk, level, optname, optval, optlen);
-	return ip_getsockopt(sk, level, optname, optval, optlen);
-}
-
-#ifdef CONFIG_COMPAT
-int compat_udp_getsockopt(struct sock *sk, int level, int optname,
-				 char __user *optval, int __user *optlen)
-{
-	if (level == SOL_UDP  ||  level == SOL_UDPLITE)
-		return do_udp_getsockopt(sk, level, optname, optval, optlen);
-	return compat_ip_getsockopt(sk, level, optname, optval, optlen);
-}
-#endif
 /**
  * 	udp_poll - wait for a UDP event.
  *	@file - file struct
diff --git a/net/ipv6/udp_impl.h b/net/ipv6/udp_impl.h
index ec98788..4ac8fc1 100644
--- a/net/ipv6/udp_impl.h
+++ b/net/ipv6/udp_impl.h
@@ -4,29 +4,83 @@ #include <net/udp.h>
 #include <net/udplite.h>
 #include <net/protocol.h>
 #include <net/addrconf.h>
+#include <net/transp_v6.h>
 #include <net/inet_common.h>
 
 extern int  	__udp6_lib_rcv(struct sk_buff **, struct hlist_head [], int );
 extern void 	__udp6_lib_err(struct sk_buff *, struct inet6_skb_parm *,
 			       int , int , int , __be32 , struct hlist_head []);
 
-extern int	udpv6_getsockopt(struct sock *sk, int level, int optname,
-		     		 char __user *optval, int __user *optlen);
-extern int	udpv6_setsockopt(struct sock *sk, int level, int optname,
-			  	 char __user *optval, int optlen);
+extern int	do_udpv6_setsockopt(struct sock *sk, int level, int optname,
+				    char __user *optval, int optlen);
+extern int	do_udpv6_getsockopt(struct sock *sk, int level, int optname,
+				    char __user *optval, int __user *optlen);
+
+static inline int udpv6_setsockopt(struct sock *sk, int level, int optname,
+				   char __user *optval, int optlen)
+{
+	if (level == SOL_UDP  ||  level == SOL_UDPLITE)
+		return do_udpv6_setsockopt(sk, level, optname, optval, optlen);
+	return ipv6_setsockopt(sk, level, optname, optval, optlen);
+}
+
+static inline int udpv6_getsockopt(struct sock *sk, int level, int optname,
+				   char __user *optval, int __user *optlen)
+{
+	if (level == SOL_UDP  ||  level == SOL_UDPLITE)
+		return do_udpv6_getsockopt(sk, level, optname, optval, optlen);
+	return ipv6_getsockopt(sk, level, optname, optval, optlen);
+}
+
 #ifdef CONFIG_COMPAT
-extern int	compat_udpv6_setsockopt(struct sock *sk, int level, int optname,
-					char __user *optval, int optlen);
-extern int	compat_udpv6_getsockopt(struct sock *sk, int level, int optname,
-				       char __user *optval, int __user *optlen);
+static inline int compat_udpv6_setsockopt(struct sock *sk, int level, int optname,
+			    		  char __user *optval, int optlen)
+{
+	if (level == SOL_UDP  ||  level == SOL_UDPLITE)
+		return do_udpv6_setsockopt(sk, level, optname, optval, optlen);
+	return compat_ipv6_setsockopt(sk, level, optname, optval, optlen);
+}
+
+static inline int compat_udpv6_getsockopt(struct sock *sk, int level, int optname,
+					  char __user *optval, int __user *optlen)
+{
+	if (level == SOL_UDP  ||  level == SOL_UDPLITE)
+		return do_udpv6_getsockopt(sk, level, optname, optval, optlen);
+	return compat_ipv6_getsockopt(sk, level, optname, optval, optlen);
+}
 #endif
+
 extern int	udpv6_sendmsg(struct kiocb *iocb, struct sock *sk,
 			      struct msghdr *msg, size_t len);
 extern int	udpv6_recvmsg(struct kiocb *iocb, struct sock *sk,
 			      struct msghdr *msg, size_t len,
 		  	      int noblock, int flags, int *addr_len);
 extern int	udpv6_queue_rcv_skb(struct sock * sk, struct sk_buff *skb);
-extern int	udpv6_destroy_sock(struct sock *sk);
+
+/*
+ * Throw away all pending data and cancel the corking. Socket is locked.
+ */
+static inline void udp_v6_flush_pending_frames(struct sock *sk)
+{
+	struct udp_sock *up = udp_sk(sk);
+
+	if (up->pending) {
+		up->len = 0;
+		up->pending = 0;
+		ip6_flush_pending_frames(sk);
+        }
+}
+
+static inline int udpv6_destroy_sock(struct sock *sk)
+{
+	lock_sock(sk);
+	udp_v6_flush_pending_frames(sk);
+	release_sock(sk);
+
+	inet6_destroy_sock(sk);
+
+	return 0;
+}
 
 #ifdef CONFIG_PROC_FS
 extern int	udp6_seq_show(struct seq_file *seq, void *v);
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index c6161bb..23f1418 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -40,7 +40,6 @@ #include <asm/uaccess.h>
 
 #include <net/ndisc.h>
 #include <net/protocol.h>
-#include <net/transp_v6.h>
 #include <net/ip6_route.h>
 #include <net/raw.h>
 #include <net/tcp_states.h>
@@ -488,20 +487,6 @@ static __inline__ int udpv6_rcv(struct s
 }
 
 /*
- * Throw away all pending data and cancel the corking. Socket is locked.
- */
-static void udp_v6_flush_pending_frames(struct sock *sk)
-{
-	struct udp_sock *up = udp_sk(sk);
-
-	if (up->pending) {
-		up->len = 0;
-		up->pending = 0;
-		ip6_flush_pending_frames(sk);
-        }
-}
-
-/*
  *	Sending
  */
 
@@ -830,22 +815,11 @@ do_confirm:
 	goto out;
 }
 
-int udpv6_destroy_sock(struct sock *sk)
-{
-	lock_sock(sk);
-	udp_v6_flush_pending_frames(sk);
-	release_sock(sk);
-
-	inet6_destroy_sock(sk);
-
-	return 0;
-}
-
 /*
  *	Socket option code for UDP
  */
-static int do_udpv6_setsockopt(struct sock *sk, int level, int optname,
-			  char __user *optval, int optlen)
+int do_udpv6_setsockopt(struct sock *sk, int level, int optname,
+			char __user *optval, int optlen)
 {
 	struct udp_sock *up = udp_sk(sk);
 	int val;
@@ -905,26 +879,8 @@ static int do_udpv6_setsockopt(struct so
 	return err;
 }
 
-int udpv6_setsockopt(struct sock *sk, int level, int optname,
-		     char __user *optval, int optlen)
-{
-	if (level == SOL_UDP  ||  level == SOL_UDPLITE)
-		return do_udpv6_setsockopt(sk, level, optname, optval, optlen);
-	return ipv6_setsockopt(sk, level, optname, optval, optlen);
-}
-
-#ifdef CONFIG_COMPAT
-int compat_udpv6_setsockopt(struct sock *sk, int level, int optname,
-			    char __user *optval, int optlen)
-{
-	if (level == SOL_UDP  ||  level == SOL_UDPLITE)
-		return do_udpv6_setsockopt(sk, level, optname, optval, optlen);
-	return compat_ipv6_setsockopt(sk, level, optname, optval, optlen);
-}
-#endif
-
-static int do_udpv6_getsockopt(struct sock *sk, int level, int optname,
-			  char __user *optval, int __user *optlen)
+int do_udpv6_getsockopt(struct sock *sk, int level, int optname,
+			char __user *optval, int __user *optlen)
 {
 	struct udp_sock *up = udp_sk(sk);
 	int val, len;
@@ -965,24 +921,6 @@ static int do_udpv6_getsockopt(struct so
   	return 0;
 }
 
-int udpv6_getsockopt(struct sock *sk, int level, int optname,
-		     char __user *optval, int __user *optlen)
-{
-	if (level == SOL_UDP  ||  level == SOL_UDPLITE)
-		return do_udpv6_getsockopt(sk, level, optname, optval, optlen);
-	return ipv6_getsockopt(sk, level, optname, optval, optlen);
-}
-
-#ifdef CONFIG_COMPAT
-int compat_udpv6_getsockopt(struct sock *sk, int level, int optname,
-			    char __user *optval, int __user *optlen)
-{
-	if (level == SOL_UDP  ||  level == SOL_UDPLITE)
-		return do_udpv6_getsockopt(sk, level, optname, optval, optlen);
-	return compat_ipv6_getsockopt(sk, level, optname, optval, optlen);
-}
-#endif
-
 static struct inet6_protocol udpv6_protocol = {
 	.handler	=	udpv6_rcv,
 	.err_handler	=	udpv6_err,
