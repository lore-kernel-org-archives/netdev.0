From: James Morris <jmorris@intercode.com.au>
Subject: [PATCH] LSM networking update: socket_sock_rcv_skb() hook (3/5)
Date: Fri, 7 Feb 2003 02:17:39 +1100 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0302070215300.2174-100000@blackbird.intercode.com.au>
References: <Pine.LNX.4.44.0302070213251.2174-100000@blackbird.intercode.com.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-security-module@wirex.com, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, <kuznet@ms2.inr.ac.ru>
In-Reply-To: <Pine.LNX.4.44.0302070213251.2174-100000@blackbird.intercode.com.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


 include/linux/security.h |   18 ++++++++
 include/net/sock.h       |   95 +++++++++++++++++++++++++++++++----------------
 net/decnet/dn_nsp_in.c   |   29 +++++---------
 net/ipv4/tcp_ipv4.c      |    9 +---
 net/ipv6/tcp_ipv6.c      |   15 +++----
 net/sctp/input.c         |    4 +
 security/dummy.c         |    5 ++
 7 files changed, 112 insertions(+), 63 deletions(-)

diff -urN -X dontdiff linux-2.5.59.w0/include/linux/security.h linux-2.5.59.w1/include/linux/security.h
--- linux-2.5.59.w0/include/linux/security.h	Fri Feb  7 01:29:51 2003
+++ linux-2.5.59.w1/include/linux/security.h	Fri Feb  7 01:16:22 2003
@@ -684,6 +684,12 @@
  *	@sock contains the socket structure.
  *	@how contains the flag indicating how future sends and receives are handled.
  *	Return 0 if permission is granted.
+ * @socket_sock_rcv_skb:
+ *	Check permissions on incoming network packets.  This hook is distinct
+ *	from Netfilter's IP input hooks since it is the first time that the
+ *	incoming sk_buff @skb has been associated with a particular socket, @sk.
+ *	@sk contains the sock (not socket) associated with the incoming sk_buff.
+ *	@skb contains the incoming network data.
  *
  * Security hooks affecting all System V IPC operations.
  *
@@ -1073,6 +1079,7 @@
 	int (*socket_getsockopt) (struct socket * sock, int level, int optname);
 	int (*socket_setsockopt) (struct socket * sock, int level, int optname);
 	int (*socket_shutdown) (struct socket * sock, int how);
+	int (*socket_sock_rcv_skb) (struct sock * sk, struct sk_buff * skb);
 #endif	/* CONFIG_SECURITY_NETWORK */
 };
 
@@ -2312,6 +2319,12 @@
 {
 	return security_ops->socket_shutdown(sock, how);
 }
+
+static inline int security_sock_rcv_skb (struct sock * sk, 
+					 struct sk_buff * skb)
+{
+	return security_ops->socket_sock_rcv_skb (sk, skb);
+}
 #else	/* CONFIG_SECURITY_NETWORK */
 static inline int security_socket_create (int family, int type, int protocol)
 {
@@ -2394,6 +2407,11 @@
 {
 	return 0;
 }
+static inline int security_sock_rcv_skb (struct sock * sk, 
+					 struct sk_buff * skb)
+{
+	return 0;
+}
 #endif	/* CONFIG_SECURITY_NETWORK */
 
 #endif /* ! __LINUX_SECURITY_H */
diff -urN -X dontdiff linux-2.5.59.w0/include/net/sock.h linux-2.5.59.w1/include/net/sock.h
--- linux-2.5.59.w0/include/net/sock.h	Fri Feb  7 01:29:51 2003
+++ linux-2.5.59.w1/include/net/sock.h	Fri Feb  7 01:18:37 2003
@@ -44,6 +44,7 @@
 
 #include <linux/netdevice.h>
 #include <linux/skbuff.h>	/* struct sk_buff */
+#include <linux/security.h>
 
 #ifdef CONFIG_FILTER
 #include <linux/filter.h>
@@ -458,28 +459,45 @@
 #ifdef CONFIG_FILTER
 
 /**
- *	sk_filter - run a packet through a socket filter
+ *	__sk_filter - run a packet through a socket filter
+ *	@sk: sock associated with &sk_buff
  *	@skb: buffer to filter
- *	@filter: filter to apply
+ *	@needlock: set to 1 if the sock is not locked by caller.
  *
  * Run the filter code and then cut skb->data to correct size returned by
  * sk_run_filter. If pkt_len is 0 we toss packet. If skb->len is smaller
  * than pkt_len we keep whole skb->data. This is the socket level
  * wrapper to sk_run_filter. It returns 0 if the packet should
- * be accepted or 1 if the packet should be tossed.
+ * be accepted or -EPERM if the packet should be tossed.
+ *
+ * This function should not be called directly, use sk_filter instead
+ * to ensure that the LSM security check is also performed.
  */
- 
-static inline int sk_filter(struct sk_buff *skb, struct sk_filter *filter)
+
+static inline int __sk_filter(struct sock *sk, struct sk_buff *skb, int needlock)
 {
-	int pkt_len;
+	int err = 0;
 
-        pkt_len = sk_run_filter(skb, filter->insns, filter->len);
-        if(!pkt_len)
-                return 1;	/* Toss Packet */
-        else
-                skb_trim(skb, pkt_len);
+	if (sk->filter) {
+		struct sk_filter *filter;
+		
+		if (needlock)
+			bh_lock_sock(sk);
+		
+		filter = sk->filter;
+		if (filter) {
+			int pkt_len = sk_run_filter(skb, filter->insns,
+						    filter->len);
+			if (!pkt_len)
+				err = -EPERM;
+			else
+				skb_trim(skb, pkt_len);
+		}
 
-	return 0;
+		if (needlock)
+			bh_unlock_sock(sk);
+	}
+	return err;
 }
 
 /**
@@ -506,8 +524,26 @@
 	atomic_add(sk_filter_len(fp), &sk->omem_alloc);
 }
 
+#else
+
+static inline int __sk_filter(struct sock *sk, struct sk_buff *skb, int needlock)
+{
+	return 0;
+}
+
 #endif /* CONFIG_FILTER */
 
+static inline int sk_filter(struct sock *sk, struct sk_buff *skb, int needlock)
+{
+	int err;
+	
+	err = security_sock_rcv_skb(sk, skb);
+	if (err)
+		return err;
+	
+	return __sk_filter(sk, skb, needlock);
+}
+
 /*
  * Socket reference counting postulates.
  *
@@ -712,36 +748,31 @@
 
 static inline int sock_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 {
+	int err = 0;
+
 	/* Cast skb->rcvbuf to unsigned... It's pointless, but reduces
 	   number of warnings when compiling with -W --ANK
 	 */
-	if (atomic_read(&sk->rmem_alloc) + skb->truesize >= (unsigned)sk->rcvbuf)
-                return -ENOMEM;
-
-#ifdef CONFIG_FILTER
-	if (sk->filter) {
-		int err = 0;
-		struct sk_filter *filter;
-
-		/* It would be deadlock, if sock_queue_rcv_skb is used
-		   with socket lock! We assume that users of this
-		   function are lock free.
-		 */
-		bh_lock_sock(sk);
-		if ((filter = sk->filter) != NULL && sk_filter(skb, filter))
-			err = -EPERM;
-		bh_unlock_sock(sk);
-		if (err)
-			return err;	/* Toss packet */
+	if (atomic_read(&sk->rmem_alloc) + skb->truesize >= (unsigned)sk->rcvbuf) {
+		err = -ENOMEM;
+		goto out;
 	}
-#endif /* CONFIG_FILTER */
+
+	/* It would be deadlock, if sock_queue_rcv_skb is used
+	   with socket lock! We assume that users of this
+	   function are lock free.
+	*/
+	err = sk_filter(sk, skb, 1);
+	if (err)
+		goto out;
 
 	skb->dev = NULL;
 	skb_set_owner_r(skb, sk);
 	skb_queue_tail(&sk->receive_queue, skb);
 	if (!sk->dead)
 		sk->data_ready(sk,skb->len);
-	return 0;
+out:
+	return err;
 }
 
 static inline int sock_queue_err_skb(struct sock *sk, struct sk_buff *skb)
diff -urN -X dontdiff linux-2.5.59.w0/net/decnet/dn_nsp_in.c linux-2.5.59.w1/net/decnet/dn_nsp_in.c
--- linux-2.5.59.w0/net/decnet/dn_nsp_in.c	Fri Feb  7 01:29:51 2003
+++ linux-2.5.59.w1/net/decnet/dn_nsp_in.c	Fri Feb  7 01:16:22 2003
@@ -566,26 +566,19 @@
  */
 static __inline__ int dn_queue_skb(struct sock *sk, struct sk_buff *skb, int sig, struct sk_buff_head *queue)
 {
-#ifdef CONFIG_FILTER
-	struct sk_filter *filter;
-#endif
-
+	int err;
+	
         /* Cast skb->rcvbuf to unsigned... It's pointless, but reduces
            number of warnings when compiling with -W --ANK
          */
-        if (atomic_read(&sk->rmem_alloc) + skb->truesize >= (unsigned)sk->rcvbuf
-)
-                return -ENOMEM;
-
-#ifdef CONFIG_FILTER
-        if (sk->filter) {
-		int err = 0;
-                if ((filter = sk->filter) != NULL && sk_filter(skb, sk->filter))
-                        err = -EPERM;  /* Toss packet */
-		if (err)
-			return err;
+        if (atomic_read(&sk->rmem_alloc) + skb->truesize >= (unsigned)sk->rcvbuf) {
+        	err = -ENOMEM;
+        	goto out;
         }
-#endif /* CONFIG_FILTER */
+
+	err = sk_filter(sk, skb, 0);
+	if (err)
+		goto out;
 
         skb_set_owner_r(skb, sk);
         skb_queue_tail(queue, skb);
@@ -603,8 +596,8 @@
 				    (sig == SIGURG) ? POLL_PRI : POLL_IN);
 	}
 	read_unlock(&sk->callback_lock);
-
-        return 0;
+out:
+        return err;
 }
 
 static void dn_nsp_otherdata(struct sock *sk, struct sk_buff *skb)
diff -urN -X dontdiff linux-2.5.59.w0/net/ipv4/tcp_ipv4.c linux-2.5.59.w1/net/ipv4/tcp_ipv4.c
--- linux-2.5.59.w0/net/ipv4/tcp_ipv4.c	Fri Feb  7 01:29:51 2003
+++ linux-2.5.59.w1/net/ipv4/tcp_ipv4.c	Fri Feb  7 01:16:22 2003
@@ -1696,12 +1696,6 @@
  */
 int tcp_v4_do_rcv(struct sock *sk, struct sk_buff *skb)
 {
-#ifdef CONFIG_FILTER
-	struct sk_filter *filter = sk->filter;
-	if (filter && sk_filter(skb, filter))
-		goto discard;
-#endif /* CONFIG_FILTER */
-
 	if (sk->state == TCP_ESTABLISHED) { /* Fast path */
 		TCP_CHECK_TIMER(sk);
 		if (tcp_rcv_established(sk, skb, skb->h.th, skb->len))
@@ -1804,6 +1798,9 @@
 	if (!xfrm_policy_check(sk, XFRM_POLICY_IN, skb))
 		goto discard_and_relse;
 
+	if (sk_filter(sk, skb, 0))
+		goto discard_and_relse;
+
 	skb->dev = NULL;
 
 	bh_lock_sock(sk);
diff -urN -X dontdiff linux-2.5.59.w0/net/ipv6/tcp_ipv6.c linux-2.5.59.w1/net/ipv6/tcp_ipv6.c
--- linux-2.5.59.w0/net/ipv6/tcp_ipv6.c	Fri Feb  7 01:29:51 2003
+++ linux-2.5.59.w1/net/ipv6/tcp_ipv6.c	Fri Feb  7 01:16:22 2003
@@ -1470,9 +1470,6 @@
 {
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct tcp_opt *tp;
-#ifdef CONFIG_FILTER
-	struct sk_filter *filter;
-#endif
 	struct sk_buff *opt_skb = NULL;
 
 	/* Imagine: socket is IPv6. IPv4 packet arrives,
@@ -1486,11 +1483,8 @@
 	if (skb->protocol == htons(ETH_P_IP))
 		return tcp_v4_do_rcv(sk, skb);
 
-#ifdef CONFIG_FILTER
-	filter = sk->filter;
-	if (filter && sk_filter(skb, filter))
+	if (sk_filter(sk, skb, 0))
 		goto discard;
-#endif /* CONFIG_FILTER */
 
 	/*
 	 *	socket locking is here for SMP purposes as backlog rcv
@@ -1641,6 +1635,9 @@
 	if(sk->state == TCP_TIME_WAIT)
 		goto do_time_wait;
 
+	if (sk_filter(sk, skb, 0))
+		goto discard_and_relse;
+
 	skb->dev = NULL;
 
 	bh_lock_sock(sk);
@@ -1672,6 +1669,10 @@
 	kfree_skb(skb);
 	return 0;
 
+discard_and_relse:
+	sock_put(sk);
+	goto discard_it;
+                
 do_time_wait:
 	if (skb->len < (th->doff<<2) || tcp_checksum_complete(skb)) {
 		TCP_INC_STATS_BH(TcpInErrs);
diff -urN -X dontdiff linux-2.5.59.w0/net/sctp/input.c linux-2.5.59.w1/net/sctp/input.c
--- linux-2.5.59.w0/net/sctp/input.c	Fri Feb  7 01:29:51 2003
+++ linux-2.5.59.w1/net/sctp/input.c	Fri Feb  7 01:27:49 2003
@@ -159,6 +159,10 @@
 	if (!xfrm_policy_check(sk, XFRM_POLICY_IN, skb))
 		goto discard_release;
 
+	ret = sk_filter(sk, skb, 1);
+	if (ret)
+                goto discard_release;
+
 	/* Create an SCTP packet structure. */
 	chunk = sctp_chunkify(skb, asoc, sk);
 	if (!chunk) {
diff -urN -X dontdiff linux-2.5.59.w0/security/dummy.c linux-2.5.59.w1/security/dummy.c
--- linux-2.5.59.w0/security/dummy.c	Fri Feb  7 01:29:51 2003
+++ linux-2.5.59.w1/security/dummy.c	Fri Feb  7 01:16:22 2003
@@ -674,6 +674,10 @@
 	return 0;
 }
 
+static int dummy_socket_sock_rcv_skb (struct sock *sk, struct sk_buff *skb)
+{
+	return 0;
+}
 #endif	/* CONFIG_SECURITY_NETWORK */
 
 static int dummy_register_security (const char *name, struct security_operations *ops)
@@ -819,6 +823,7 @@
 	set_to_dummy_if_null(ops, socket_setsockopt);
 	set_to_dummy_if_null(ops, socket_getsockopt);
 	set_to_dummy_if_null(ops, socket_shutdown);
+	set_to_dummy_if_null(ops, socket_sock_rcv_skb);
 #endif	/* CONFIG_SECURITY_NETWORK */
 }
 
