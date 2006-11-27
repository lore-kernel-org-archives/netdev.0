From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [PATCH] [UDP(-Lite)]: consolidate v4 and v6 get|setsockopt code
Date: Mon, 27 Nov 2006 10:44:33 +0000
Message-ID: <200611271044.34091@strip-the-willow>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:20098 "EHLO erg.abdn.ac.uk")
	by vger.kernel.org with ESMTP id S1757807AbWK0KoL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Nov 2006 05:44:11 -0500
Content-Disposition: inline
To: David Miller <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[UDP(-Lite)]: consolidate v4 and v6 get|setsockopt code

This is for 2.6.20.

This patch consolidates set/getsockopt code between UDP(-Lite) v4 and 6. The 
justification is that UDP(-Lite) is a transport-layer protocol and therefore
the socket option code (at least in theory) should be AF-independent. 

Furthermore, there is the following code reduplication:
 * do_udp{,v6}_getsockopt is 100% identical between v4 and v6
 * do_udp{,v6}_setsockopt is identical up to the following differerence
	--v4 in contrast to v4 additionally allows the experimental encapsulation
          types  UDP_ENCAP_ESPINUDP and UDP_ENCAP_ESPINUDP_NON_IKE
	--the remainder is identical between v4 and v6
   I believe that this difference is of little relevance. 

The advantages in not duplicating twice almost completely identical code.

The patch further simplifies the interface of udp{,v6}_push_pending_frames,
since for the second argument (struct udp_sock *up) it always holds that
up = udp_sk(sk); where sk is the first function argument.


Signed-off-by: Gerrit Renker  <gerrit@erg.abdn.ac.uk>
---
 include/net/udp.h |    5 ++
 net/ipv4/udp.c    |   30 ++++++++-----
 net/ipv6/udp.c    |  118 ++++--------------------------------------------------
 3 files changed, 32 insertions(+), 121 deletions(-)



diff --git a/include/net/udp.h b/include/net/udp.h
index eac69ff..1548d68 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -134,6 +134,11 @@ extern int	udp_ioctl(struct sock *sk, in
 extern int	udp_disconnect(struct sock *sk, int flags);
 extern unsigned int udp_poll(struct file *file, struct socket *sock,
 			     poll_table *wait);
+extern int 	udp_lib_getsockopt(struct sock *sk, int level, int optname,
+			           char __user *optval, int __user *optlen);
+extern int 	udp_lib_setsockopt(struct sock *sk, int level, int optname,
+				   char __user *optval, int optlen,
+				   int (*push_pending_frames)(struct sock *));
 
 DECLARE_SNMP_STAT(struct udp_mib, udp_statistics);
 /*
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 74a62cd..b9606fa 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -448,8 +448,9 @@ static void udp4_hwcsum_outgoing(struct 
 /*
  * Push out all pending data as one UDP datagram. Socket is locked.
  */
-static int udp_push_pending_frames(struct sock *sk, struct udp_sock *up)
+static int udp_push_pending_frames(struct sock *sk)
 {
+	struct udp_sock  *up = udp_sk(sk);
 	struct inet_sock *inet = inet_sk(sk);
 	struct flowi *fl = &inet->cork.fl;
 	struct sk_buff *skb;
@@ -673,7 +674,7 @@ do_append_data:
 	if (err)
 		udp_flush_pending_frames(sk);
 	else if (!corkreq)
-		err = udp_push_pending_frames(sk, up);
+		err = udp_push_pending_frames(sk);
 	else if (unlikely(skb_queue_empty(&sk->sk_write_queue)))
 		up->pending = 0;
 	release_sock(sk);
@@ -746,7 +747,7 @@ int udp_sendpage(struct sock *sk, struct
 
 	up->len += size;
 	if (!(up->corkflag || (flags&MSG_MORE)))
-		ret = udp_push_pending_frames(sk, up);
+		ret = udp_push_pending_frames(sk);
 	if (!ret)
 		ret = size;
 out:
@@ -1290,8 +1291,9 @@ int udp_destroy_sock(struct sock *sk)
 /*
  *	Socket option code for UDP
  */
-static int do_udp_setsockopt(struct sock *sk, int level, int optname,
-			  char __user *optval, int optlen)
+int udp_lib_setsockopt(struct sock *sk, int level, int optname,
+		       char __user *optval, int optlen,
+		       int (*push_pending_frames)(struct sock *))
 {
 	struct udp_sock *up = udp_sk(sk);
 	int val;
@@ -1310,7 +1312,7 @@ static int do_udp_setsockopt(struct sock
 		} else {
 			up->corkflag = 0;
 			lock_sock(sk);
-			udp_push_pending_frames(sk, up);
+			(*push_pending_frames)(sk);
 			release_sock(sk);
 		}
 		break;
@@ -1366,7 +1368,8 @@ int udp_setsockopt(struct sock *sk, int 
 		   char __user *optval, int optlen)
 {
 	if (level == SOL_UDP  ||  level == SOL_UDPLITE)
-		return do_udp_setsockopt(sk, level, optname, optval, optlen);
+		return udp_lib_setsockopt(sk, level, optname, optval, optlen,
+					  udp_push_pending_frames           );
 	return ip_setsockopt(sk, level, optname, optval, optlen);
 }
 
@@ -1375,13 +1378,14 @@ int compat_udp_setsockopt(struct sock *s
 			  char __user *optval, int optlen)
 {
 	if (level == SOL_UDP  ||  level == SOL_UDPLITE)
-		return do_udp_setsockopt(sk, level, optname, optval, optlen);
+		return udp_lib_setsockopt(sk, level, optname, optval, optlen,
+					  udp_push_pending_frames           );
 	return compat_ip_setsockopt(sk, level, optname, optval, optlen);
 }
 #endif
 
-static int do_udp_getsockopt(struct sock *sk, int level, int optname,
-			  char __user *optval, int __user *optlen)
+int udp_lib_getsockopt(struct sock *sk, int level, int optname,
+		       char __user *optval, int __user *optlen)
 {
 	struct udp_sock *up = udp_sk(sk);
 	int val, len;
@@ -1428,7 +1432,7 @@ int udp_getsockopt(struct sock *sk, int 
 		   char __user *optval, int __user *optlen)
 {
 	if (level == SOL_UDP  ||  level == SOL_UDPLITE)
-		return do_udp_getsockopt(sk, level, optname, optval, optlen);
+		return udp_lib_getsockopt(sk, level, optname, optval, optlen);
 	return ip_getsockopt(sk, level, optname, optval, optlen);
 }
 
@@ -1437,7 +1441,7 @@ int compat_udp_getsockopt(struct sock *s
 				 char __user *optval, int __user *optlen)
 {
 	if (level == SOL_UDP  ||  level == SOL_UDPLITE)
-		return do_udp_getsockopt(sk, level, optname, optval, optlen);
+		return udp_lib_getsockopt(sk, level, optname, optval, optlen);
 	return compat_ip_getsockopt(sk, level, optname, optval, optlen);
 }
 #endif
@@ -1707,6 +1711,8 @@ EXPORT_SYMBOL(udp_ioctl);
 EXPORT_SYMBOL(udp_get_port);
 EXPORT_SYMBOL(udp_prot);
 EXPORT_SYMBOL(udp_sendmsg);
+EXPORT_SYMBOL(udp_lib_getsockopt);
+EXPORT_SYMBOL(udp_lib_setsockopt);
 EXPORT_SYMBOL(udp_poll);
 
 #ifdef CONFIG_PROC_FS
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index a88c728..6b50ef0 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -506,10 +506,11 @@ static void udp_v6_flush_pending_frames(
  *	Sending
  */
 
-static int udp_v6_push_pending_frames(struct sock *sk, struct udp_sock *up)
+static int udp_v6_push_pending_frames(struct sock *sk)
 {
 	struct sk_buff *skb;
 	struct udphdr *uh;
+	struct udp_sock  *up = udp_sk(sk);
 	struct inet_sock *inet = inet_sk(sk);
 	struct flowi *fl = &inet->cork.fl;
 	int err = 0;
@@ -783,7 +784,7 @@ do_append_data:
 	if (err)
 		udp_v6_flush_pending_frames(sk);
 	else if (!corkreq)
-		err = udp_v6_push_pending_frames(sk, up);
+		err = udp_v6_push_pending_frames(sk);
 	else if (unlikely(skb_queue_empty(&sk->sk_write_queue)))
 		up->pending = 0;
 
@@ -845,72 +846,12 @@ int udpv6_destroy_sock(struct sock *sk)
 /*
  *	Socket option code for UDP
  */
-static int do_udpv6_setsockopt(struct sock *sk, int level, int optname,
-			  char __user *optval, int optlen)
-{
-	struct udp_sock *up = udp_sk(sk);
-	int val;
-	int err = 0;
-
-	if(optlen<sizeof(int))
-		return -EINVAL;
-
-	if (get_user(val, (int __user *)optval))
-		return -EFAULT;
-
-	switch(optname) {
-	case UDP_CORK:
-		if (val != 0) {
-			up->corkflag = 1;
-		} else {
-			up->corkflag = 0;
-			lock_sock(sk);
-			udp_v6_push_pending_frames(sk, up);
-			release_sock(sk);
-		}
-		break;
-	case UDP_ENCAP:
-		switch (val) {
-		case 0:
-			up->encap_type = val;
-			break;
-		default:
-			err = -ENOPROTOOPT;
-			break;
-		}
-		break;
-
-	case UDPLITE_SEND_CSCOV:
-		if (!up->pcflag)         /* Disable the option on UDP sockets */
-			return -ENOPROTOOPT;
-		if (val != 0 && val < 8) /* Illegal coverage: use default (8) */
-			val = 8;
-		up->pcslen = val;
-		up->pcflag |= UDPLITE_SEND_CC;
-		break;
-
-	case UDPLITE_RECV_CSCOV:
-		if (!up->pcflag)         /* Disable the option on UDP sockets */
-			return -ENOPROTOOPT;
-		if (val != 0 && val < 8) /* Avoid silly minimal values.       */
-			val = 8;
-		up->pcrlen = val;
-		up->pcflag |= UDPLITE_RECV_CC;
-		break;
-
-	default:
-		err = -ENOPROTOOPT;
-		break;
-	};
-
-	return err;
-}
-
 int udpv6_setsockopt(struct sock *sk, int level, int optname,
 		     char __user *optval, int optlen)
 {
 	if (level == SOL_UDP  ||  level == SOL_UDPLITE)
-		return do_udpv6_setsockopt(sk, level, optname, optval, optlen);
+		return udp_lib_setsockopt(sk, level, optname, optval, optlen,
+					  udp_v6_push_pending_frames         );
 	return ipv6_setsockopt(sk, level, optname, optval, optlen);
 }
 
@@ -919,58 +860,17 @@ int compat_udpv6_setsockopt(struct sock 
 			    char __user *optval, int optlen)
 {
 	if (level == SOL_UDP  ||  level == SOL_UDPLITE)
-		return do_udpv6_setsockopt(sk, level, optname, optval, optlen);
+		return udp_lib_setsockopt(sk, level, optname, optval, optlen,
+					  udp_v6_push_pending_frames         );
 	return compat_ipv6_setsockopt(sk, level, optname, optval, optlen);
 }
 #endif
 
-static int do_udpv6_getsockopt(struct sock *sk, int level, int optname,
-			  char __user *optval, int __user *optlen)
-{
-	struct udp_sock *up = udp_sk(sk);
-	int val, len;
-
-	if(get_user(len,optlen))
-		return -EFAULT;
-
-	len = min_t(unsigned int, len, sizeof(int));
-	
-	if(len < 0)
-		return -EINVAL;
-
-	switch(optname) {
-	case UDP_CORK:
-		val = up->corkflag;
-		break;
-
-	case UDP_ENCAP:
-		val = up->encap_type;
-		break;
-
-	case UDPLITE_SEND_CSCOV:
-		val = up->pcslen;
-		break;
-
-	case UDPLITE_RECV_CSCOV:
-		val = up->pcrlen;
-		break;
-
-	default:
-		return -ENOPROTOOPT;
-	};
-
-  	if(put_user(len, optlen))
-  		return -EFAULT;
-	if(copy_to_user(optval, &val,len))
-		return -EFAULT;
-  	return 0;
-}
-
 int udpv6_getsockopt(struct sock *sk, int level, int optname,
 		     char __user *optval, int __user *optlen)
 {
 	if (level == SOL_UDP  ||  level == SOL_UDPLITE)
-		return do_udpv6_getsockopt(sk, level, optname, optval, optlen);
+		return udp_lib_getsockopt(sk, level, optname, optval, optlen);
 	return ipv6_getsockopt(sk, level, optname, optval, optlen);
 }
 
@@ -979,7 +879,7 @@ int compat_udpv6_getsockopt(struct sock 
 			    char __user *optval, int __user *optlen)
 {
 	if (level == SOL_UDP  ||  level == SOL_UDPLITE)
-		return do_udpv6_getsockopt(sk, level, optname, optval, optlen);
+		return udp_lib_getsockopt(sk, level, optname, optval, optlen);
 	return compat_ipv6_getsockopt(sk, level, optname, optval, optlen);
 }
 #endif
