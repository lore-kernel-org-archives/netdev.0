From: Dmitry Mishin <dim@openvz.org>
Subject: [PATCH] fix sk->sk_filter field access
Date: Wed, 30 Aug 2006 17:07:14 +0400
Message-ID: <200608301707.14250.dim@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Kirill Korotaev <dev@sw.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.233.200]:40894 "EHLO relay.sw.ru")
	by vger.kernel.org with ESMTP id S1750990AbWH3NHu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2006 09:07:50 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello, all!

Function sk_filter() is called from tcp_v{4,6}_rcv() functions with argue 
needlock = 0, while socket is not locked at that moment. In order to avoid 
this and similar issues in the future, use rcu for sk->sk_filter field read 
protection.

Patch is for net-2.6.19

Signed-off-by: Dmitry Mishin <dim@openvz.org>
Signed-off-by: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Signed-off-by: Kirill Korotaev <dev@openvz.org>
--
 include/linux/filter.h |   13 +++++++------
 include/net/sock.h     |   34 +++++++++++++++++-----------------
 net/core/filter.c      |    8 ++++----
 net/core/sock.c        |   22 +++++++++-------------
 net/dccp/ipv6.c        |    2 +-
 net/decnet/dn_nsp_in.c |    2 +-
 net/ipv4/tcp_ipv4.c    |    2 +-
 net/ipv6/tcp_ipv6.c    |    4 ++--
 net/packet/af_packet.c |   43 ++++++++++++++++++-------------------------
 net/sctp/input.c       |    2 +-
 10 files changed, 61 insertions(+), 71 deletions(-)

diff --git a/include/linux/filter.h b/include/linux/filter.h
index c6cb8f0..91b2e3b 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -25,10 +25,10 @@
  
 struct sock_filter	/* Filter block */
 {
-        __u16	code;   /* Actual filter code */
-        __u8	jt;	/* Jump true */
-        __u8	jf;	/* Jump false */
-        __u32	k;      /* Generic multiuse field */
+	__u16	code;   /* Actual filter code */
+	__u8	jt;	/* Jump true */
+	__u8	jf;	/* Jump false */
+	__u32	k;      /* Generic multiuse field */
 };
 
 struct sock_fprog	/* Required for SO_ATTACH_FILTER. */
@@ -41,8 +41,9 @@ struct sock_fprog	/* Required for SO_ATT
 struct sk_filter
 {
 	atomic_t		refcnt;
-        unsigned int         	len;	/* Number of filter blocks */
-        struct sock_filter     	insns[0];
+	unsigned int         	len;	/* Number of filter blocks */
+	struct rcu_head		rcu;
+	struct sock_filter     	insns[0];
 };
 
 static inline unsigned int sk_filter_len(struct sk_filter *fp)
diff --git a/include/net/sock.h b/include/net/sock.h
index 337ebec..edd4d73 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -862,30 +862,24 @@ extern void sock_init_data(struct socket
  *
  */
 
-static inline int sk_filter(struct sock *sk, struct sk_buff *skb, int 
needlock)
+static inline int sk_filter(struct sock *sk, struct sk_buff *skb)
 {
 	int err;
+	struct sk_filter *filter;
 	
 	err = security_sock_rcv_skb(sk, skb);
 	if (err)
 		return err;
 	
-	if (sk->sk_filter) {
-		struct sk_filter *filter;
-		
-		if (needlock)
-			bh_lock_sock(sk);
-		
-		filter = sk->sk_filter;
-		if (filter) {
-			unsigned int pkt_len = sk_run_filter(skb, filter->insns,
-							     filter->len);
-			err = pkt_len ? pskb_trim(skb, pkt_len) : -EPERM;
-		}
-
-		if (needlock)
-			bh_unlock_sock(sk);
+	rcu_read_lock_bh();
+	filter = sk->sk_filter;
+	if (filter) {
+		unsigned int pkt_len = sk_run_filter(skb, filter->insns,
+				filter->len);
+		err = pkt_len ? pskb_trim(skb, pkt_len) : -EPERM;
 	}
+ 	rcu_read_unlock_bh();
+
 	return err;
 }
 
@@ -897,6 +891,12 @@ static inline int sk_filter(struct sock 
  *	Remove a filter from a socket and release its resources.
  */
  
+static inline void sk_filter_rcu_free(struct rcu_head *rcu)
+{
+	struct sk_filter *fp = container_of(rcu, struct sk_filter, rcu);
+	kfree(fp);
+}
+
 static inline void sk_filter_release(struct sock *sk, struct sk_filter *fp)
 {
 	unsigned int size = sk_filter_len(fp);
@@ -904,7 +904,7 @@ static inline void sk_filter_release(str
 	atomic_sub(size, &sk->sk_omem_alloc);
 
 	if (atomic_dec_and_test(&fp->refcnt))
-		kfree(fp);
+		call_rcu_bh(&fp->rcu, sk_filter_rcu_free);
 }
 
 static inline void sk_filter_charge(struct sock *sk, struct sk_filter *fp)
diff --git a/net/core/filter.c b/net/core/filter.c
index 5b4486a..6732782 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -422,10 +422,10 @@ int sk_attach_filter(struct sock_fprog *
 	if (!err) {
 		struct sk_filter *old_fp;
 
-		spin_lock_bh(&sk->sk_lock.slock);
-		old_fp = sk->sk_filter;
-		sk->sk_filter = fp;
-		spin_unlock_bh(&sk->sk_lock.slock);
+		rcu_read_lock_bh();
+		old_fp = rcu_dereference(sk->sk_filter);
+		rcu_assign_pointer(sk->sk_filter, fp);
+		rcu_read_unlock_bh();
 		fp = old_fp;
 	}
 
diff --git a/net/core/sock.c b/net/core/sock.c
index cfaf090..b77e155 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -247,11 +247,7 @@ int sock_queue_rcv_skb(struct sock *sk, 
 		goto out;
 	}
 
-	/* It would be deadlock, if sock_queue_rcv_skb is used
-	   with socket lock! We assume that users of this
-	   function are lock free.
-	*/
-	err = sk_filter(sk, skb, 1);
+	err = sk_filter(sk, skb);
 	if (err)
 		goto out;
 
@@ -278,7 +274,7 @@ int sk_receive_skb(struct sock *sk, stru
 {
 	int rc = NET_RX_SUCCESS;
 
-	if (sk_filter(sk, skb, 0))
+	if (sk_filter(sk, skb))
 		goto discard_and_relse;
 
 	skb->dev = NULL;
@@ -606,15 +602,15 @@ set_rcvbuf:
 			break;
 
 		case SO_DETACH_FILTER:
-			spin_lock_bh(&sk->sk_lock.slock);
-			filter = sk->sk_filter;
+			rcu_read_lock_bh();
+			filter = rcu_dereference(sk->sk_filter);
                         if (filter) {
-				sk->sk_filter = NULL;
-				spin_unlock_bh(&sk->sk_lock.slock);
+				rcu_assign_pointer(sk->sk_filter, NULL);
 				sk_filter_release(sk, filter);
+				rcu_read_unlock_bh();
 				break;
 			}
-			spin_unlock_bh(&sk->sk_lock.slock);
+			rcu_read_unlock_bh();
 			ret = -ENONET;
 			break;
 
@@ -884,10 +880,10 @@ void sk_free(struct sock *sk)
 	if (sk->sk_destruct)
 		sk->sk_destruct(sk);
 
-	filter = sk->sk_filter;
+	filter = rcu_dereference(sk->sk_filter);
 	if (filter) {
 		sk_filter_release(sk, filter);
-		sk->sk_filter = NULL;
+		rcu_assign_pointer(sk->sk_filter, NULL);
 	}
 
 	sock_disable_timestamp(sk);
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index f9c5e12..7a47399 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -970,7 +970,7 @@ static int dccp_v6_do_rcv(struct sock *s
 	if (skb->protocol == htons(ETH_P_IP))
 		return dccp_v4_do_rcv(sk, skb);
 
-	if (sk_filter(sk, skb, 0))
+	if (sk_filter(sk, skb))
 		goto discard;
 
 	/*
diff --git a/net/decnet/dn_nsp_in.c b/net/decnet/dn_nsp_in.c
index 86f7f3b..72ecc6e 100644
--- a/net/decnet/dn_nsp_in.c
+++ b/net/decnet/dn_nsp_in.c
@@ -586,7 +586,7 @@ static __inline__ int dn_queue_skb(struc
         	goto out;
         }
 
-	err = sk_filter(sk, skb, 0);
+	err = sk_filter(sk, skb);
 	if (err)
 		goto out;
 
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 23b46e3..39b1798 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1104,7 +1104,7 @@ process:
 		goto discard_and_relse;
 	nf_reset(skb);
 
-	if (sk_filter(sk, skb, 0))
+	if (sk_filter(sk, skb))
 		goto discard_and_relse;
 
 	skb->dev = NULL;
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 2b18918..2546fc9 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1075,7 +1075,7 @@ static int tcp_v6_do_rcv(struct sock *sk
 	if (skb->protocol == htons(ETH_P_IP))
 		return tcp_v4_do_rcv(sk, skb);
 
-	if (sk_filter(sk, skb, 0))
+	if (sk_filter(sk, skb))
 		goto discard;
 
 	/*
@@ -1232,7 +1232,7 @@ process:
 	if (!xfrm6_policy_check(sk, XFRM_POLICY_IN, skb))
 		goto discard_and_relse;
 
-	if (sk_filter(sk, skb, 0))
+	if (sk_filter(sk, skb))
 		goto discard_and_relse;
 
 	skb->dev = NULL;
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 0492e83..170bf76 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -427,21 +427,24 @@ out_unlock:
 }
 #endif
 
-static inline unsigned run_filter(struct sk_buff *skb, struct sock *sk, 
unsigned res)
+static inline int run_filter(struct sk_buff *skb, struct sock *sk,
+							unsigned *snaplen)
 {
 	struct sk_filter *filter;
+	int err = 0;
 
-	bh_lock_sock(sk);
-	filter = sk->sk_filter;
-	/*
-	 * Our caller already checked that filter != NULL but we need to
-	 * verify that under bh_lock_sock() to be safe
-	 */
-	if (likely(filter != NULL))
-		res = sk_run_filter(skb, filter->insns, filter->len);
-	bh_unlock_sock(sk);
+	rcu_read_lock_bh();
+	filter = rcu_dereference(sk->sk_filter);
+	if (filter != NULL) {
+		err = sk_run_filter(skb, filter->insns, filter->len);
+		if (!err)
+			err = -EPERM;
+		else if (*snaplen > err)
+			*snaplen = err;
+	}
+	rcu_read_unlock_bh();
 
-	return res;
+	return err;
 }
 
 /*
@@ -491,13 +494,8 @@ static int packet_rcv(struct sk_buff *sk
 
 	snaplen = skb->len;
 
-	if (sk->sk_filter) {
-		unsigned res = run_filter(skb, sk, snaplen);
-		if (res == 0)
-			goto drop_n_restore;
-		if (snaplen > res)
-			snaplen = res;
-	}
+	if (run_filter(skb, sk, &snaplen) < 0)
+		goto drop_n_restore;
 
 	if (atomic_read(&sk->sk_rmem_alloc) + skb->truesize >=
 	    (unsigned)sk->sk_rcvbuf)
@@ -593,13 +591,8 @@ static int tpacket_rcv(struct sk_buff *s
 
 	snaplen = skb->len;
 
-	if (sk->sk_filter) {
-		unsigned res = run_filter(skb, sk, snaplen);
-		if (res == 0)
-			goto drop_n_restore;
-		if (snaplen > res)
-			snaplen = res;
-	}
+	if (run_filter(skb, sk, &snaplen) < 0)
+		goto drop_n_restore;
 
 	if (sk->sk_type == SOCK_DGRAM) {
 		macoff = netoff = TPACKET_ALIGN(TPACKET_HDRLEN) + 16;
diff --git a/net/sctp/input.c b/net/sctp/input.c
index 8a34d95..03f65de 100644
--- a/net/sctp/input.c
+++ b/net/sctp/input.c
@@ -228,7 +228,7 @@ int sctp_rcv(struct sk_buff *skb)
 		goto discard_release;
 	nf_reset(skb);
 
-	if (sk_filter(sk, skb, 1))
+	if (sk_filter(sk, skb))
                 goto discard_release;
 
 	/* Create an SCTP packet structure. */
