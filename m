From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [PATCH 2/2] [IPv6]: UDP-Lite support
Date: Fri, 20 Oct 2006 16:28:05 +0100
Message-ID: <200610201628.06460@strip-the-willow>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jmorris@namei.org, alan@lxorguk.ukuu.org.uk, kuznet@ms2.inr.ac.ru,
	pekkas@netcore.fi, kaber@coreworks.de, yoshfuji@linux-ipv6.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:38364 "EHLO erg.abdn.ac.uk")
	by vger.kernel.org with ESMTP id S1946201AbWJTPdM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2006 11:33:12 -0400
To: davem@davemloft.net
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[UDPv6]: Support for UDP-Litev6 (RFC 3828).
	 * consolidated with UDP basis
	 * basic xfrm/netfilter support


Signed-off-by: Gerrit Renker  <gerrit@erg.abdn.ac.uk>
--

 include/net/ipv6.h            |   12 +
 include/net/transp_v6.h       |    2 
 net/ipv6/af_inet6.c           |   21 ++
 net/ipv6/ipv6_sockglue.c      |   11 +
 net/ipv6/netfilter/ip6t_LOG.c |   10 -
 net/ipv6/proc.c               |   11 +
 net/ipv6/udp.c                |  330 ++++++++++++++++++++++++------------------
 net/ipv6/udplite.c            |  103 +++++++++++++
 net/ipv6/xfrm6_policy.c       |    1 
 9 files changed, 351 insertions(+), 150 deletions(-)


diff --git a/include/net/transp_v6.h b/include/net/transp_v6.h
index 61f724c..409da3a 100644
--- a/include/net/transp_v6.h
+++ b/include/net/transp_v6.h
@@ -11,6 +11,7 @@ #ifdef __KERNEL__
 
 extern struct proto rawv6_prot;
 extern struct proto udpv6_prot;
+extern struct proto udplitev6_prot;
 extern struct proto tcpv6_prot;
 
 struct flowi;
@@ -24,6 +25,7 @@ extern void				ipv6_destopt_init(void);
 /* transport protocols */
 extern void				rawv6_init(void);
 extern void				udpv6_init(void);
+extern void 				udplitev6_init(void);
 extern void				tcpv6_init(void);
 
 extern int				udpv6_connect(struct sock *sk,
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index e0c3934..6b13ae2 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -49,6 +49,7 @@ #include <net/ip6_route.h>
 #include <net/addrconf.h>
 #include <net/ip.h>
 #include <net/udp.h>
+#include <net/udplite.h>
 #include <net/raw.h>
 #include <net/inet_common.h>
 #include <net/tcp_states.h>
@@ -66,23 +67,9 @@ static inline int udp_v6_get_port(struct
 	return udp_get_port(sk, snum, ipv6_rcv_saddr_equal);
 }
 
-static void udp_v6_hash(struct sock *sk)
-{
-	BUG();
-}
-
-static void udp_v6_unhash(struct sock *sk)
-{
- 	write_lock_bh(&udp_hash_lock);
-	if (sk_del_node_init(sk)) {
-		inet_sk(sk)->num = 0;
-		sock_prot_dec_use(sk->sk_prot);
-	}
-	write_unlock_bh(&udp_hash_lock);
-}
-
-static struct sock *udp_v6_lookup(struct in6_addr *saddr, u16 sport,
-				  struct in6_addr *daddr, u16 dport, int dif)
+static struct sock *__udp6_lib_lookup(struct in6_addr *saddr, __be16 sport,
+				      struct in6_addr *daddr, __be16 dport,
+				      int dif, struct hlist_head udptable[])
 {
 	struct sock *sk, *result = NULL;
 	struct hlist_node *node;
@@ -90,7 +77,7 @@ static struct sock *udp_v6_lookup(struct
 	int badness = -1;
 
  	read_lock(&udp_hash_lock);
-	sk_for_each(sk, node, &udp_hash[hnum & (UDP_HTABLE_SIZE - 1)]) {
+	sk_for_each(sk, node, &udptable[hnum & (UDP_HTABLE_SIZE - 1)]) {
 		struct inet_sock *inet = inet_sk(sk);
 
 		if (inet->num == hnum && sk->sk_family == PF_INET6) {
@@ -132,15 +119,6 @@ static struct sock *udp_v6_lookup(struct
 }
 
 /*
- *
- */
-
-static void udpv6_close(struct sock *sk, long timeout)
-{
-	sk_common_release(sk);
-}
-
-/*
  * 	This should be easy, if there is something there we
  * 	return it, otherwise we block.
  */
@@ -153,7 +131,7 @@ static int udpv6_recvmsg(struct kiocb *i
 	struct inet_sock *inet = inet_sk(sk);
   	struct sk_buff *skb;
 	size_t copied;
-  	int err;
+	int err, copy_only, is_udplite = IS_UDPLITE(sk);
 
   	if (addr_len)
   		*addr_len=sizeof(struct sockaddr_in6);
@@ -172,15 +150,21 @@ try_again:
   		msg->msg_flags |= MSG_TRUNC;
   	}
 
-	if (skb->ip_summed==CHECKSUM_UNNECESSARY) {
-		err = skb_copy_datagram_iovec(skb, sizeof(struct udphdr), msg->msg_iov,
-					      copied);
-	} else if (msg->msg_flags&MSG_TRUNC) {
-		if (__skb_checksum_complete(skb))
+	/*
+	 * 	Decide whether to checksum and/or copy data.
+	 */
+	copy_only = (skb->ip_summed==CHECKSUM_UNNECESSARY);
+
+	if (is_udplite  ||  (!copy_only  &&  msg->msg_flags&MSG_TRUNC)) {
+		if (__udp_lib_checksum_complete(skb))
 			goto csum_copy_err;
-		err = skb_copy_datagram_iovec(skb, sizeof(struct udphdr), msg->msg_iov,
-					      copied);
-	} else {
+		copy_only = 1;
+	}
+
+	if (copy_only)
+		err = skb_copy_datagram_iovec(skb, sizeof(struct udphdr),
+					      msg->msg_iov, copied       );
+	else {
 		err = skb_copy_and_csum_datagram_iovec(skb, sizeof(struct udphdr), msg->msg_iov);
 		if (err == -EINVAL)
 			goto csum_copy_err;
@@ -231,14 +215,15 @@ csum_copy_err:
 	skb_kill_datagram(sk, skb, flags);
 
 	if (flags & MSG_DONTWAIT) {
-		UDP6_INC_STATS_USER(UDP_MIB_INERRORS);
+		UDP6_INC_STATS_USER(UDP_MIB_INERRORS, is_udplite);
 		return -EAGAIN;
 	}
 	goto try_again;
 }
 
-static void udpv6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
-	       int type, int code, int offset, __u32 info)
+static void __udp6_lib_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
+			   int type, int code, int offset, __u32 info,
+			   struct hlist_head udptable[]                    )
 {
 	struct ipv6_pinfo *np;
 	struct ipv6hdr *hdr = (struct ipv6hdr*)skb->data;
@@ -249,8 +234,8 @@ static void udpv6_err(struct sk_buff *sk
 	struct sock *sk;
 	int err;
 
-	sk = udp_v6_lookup(daddr, uh->dest, saddr, uh->source, dev->ifindex);
-   
+	sk = __udp6_lib_lookup(daddr, uh->dest,
+			       saddr, uh->source, dev->ifindex, udptable);
 	if (sk == NULL)
 		return;
 
@@ -271,31 +256,55 @@ out:
 	sock_put(sk);
 }
 
-static inline int udpv6_queue_rcv_skb(struct sock * sk, struct sk_buff *skb)
+static __inline__ void udpv6_err(struct sk_buff *skb,
+				 struct inet6_skb_parm *opt, int type,
+				 int code, int offset, __u32 info     )
+{
+	return __udp6_lib_err(skb, opt, type, code, offset, info, udp_hash);
+}
+
+static int udpv6_queue_rcv_skb(struct sock * sk, struct sk_buff *skb)
 {
+	struct udp_sock *up = udp_sk(sk);
 	int rc;
 
-	if (!xfrm6_policy_check(sk, XFRM_POLICY_IN, skb)) {
-		kfree_skb(skb);
-		return -1;
-	}
+	if (!xfrm6_policy_check(sk, XFRM_POLICY_IN, skb))
+		goto drop;
 
-	if (skb_checksum_complete(skb)) {
-		UDP6_INC_STATS_BH(UDP_MIB_INERRORS);
-		kfree_skb(skb);
-		return 0;
+	/*
+	 * UDP-Lite specific tests, ignored on UDP sockets (see net/ipv4/udp.c).
+	 */
+	if ((up->pcflag & UDPLITE_RECV_CC)  &&  UDP_SKB_CB(skb)->partial_cov) {
+
+		if (up->pcrlen == 0) {          /* full coverage was set  */
+			LIMIT_NETDEBUG(KERN_WARNING "UDPLITE6: partial coverage"
+				" %d while full coverage %d requested\n",
+				UDP_SKB_CB(skb)->cscov, skb->len);
+			goto drop;
+		}
+		if (UDP_SKB_CB(skb)->cscov  <  up->pcrlen) {
+			LIMIT_NETDEBUG(KERN_WARNING "UDPLITE6: coverage %d "
+						    "too small, need min %d\n",
+				       UDP_SKB_CB(skb)->cscov, up->pcrlen);
+			goto drop;
+		}
 	}
 
+	if (udp_lib_checksum_complete(skb))
+		goto drop;
+
 	if ((rc = sock_queue_rcv_skb(sk,skb)) < 0) {
 		/* Note that an ENOMEM error is charged twice */
 		if (rc == -ENOMEM)
-			UDP6_INC_STATS_BH(UDP_MIB_RCVBUFERRORS);
-		UDP6_INC_STATS_BH(UDP_MIB_INERRORS);
-		kfree_skb(skb);
-		return 0;
+			UDP6_INC_STATS_BH(UDP_MIB_RCVBUFERRORS, up->pcflag);
+		goto drop;
 	}
-	UDP6_INC_STATS_BH(UDP_MIB_INDATAGRAMS);
+	UDP6_INC_STATS_BH(UDP_MIB_INDATAGRAMS, up->pcflag);
 	return 0;
+drop:
+	UDP6_INC_STATS_BH(UDP_MIB_INERRORS, up->pcflag);
+	kfree_skb(skb);
+	return -1;
 }
 
 static struct sock *udp_v6_mcast_next(struct sock *sk,
@@ -339,15 +348,15 @@ static struct sock *udp_v6_mcast_next(st
  * Note: called only from the BH handler context,
  * so we don't need to lock the hashes.
  */
-static void udpv6_mcast_deliver(struct udphdr *uh,
-				struct in6_addr *saddr, struct in6_addr *daddr,
-				struct sk_buff *skb)
+static int __udp6_lib_mcast_deliver(struct sk_buff *skb, struct in6_addr *saddr,
+		           struct in6_addr *daddr, struct hlist_head udptable[])
 {
 	struct sock *sk, *sk2;
+  	const struct udphdr *uh = skb->h.uh;
 	int dif;
 
 	read_lock(&udp_hash_lock);
-	sk = sk_head(&udp_hash[ntohs(uh->dest) & (UDP_HTABLE_SIZE - 1)]);
+	sk = sk_head(&udptable[ntohs(uh->dest) & (UDP_HTABLE_SIZE - 1)]);
 	dif = skb->dev->ifindex;
 	sk = udp_v6_mcast_next(sk, uh->dest, daddr, uh->source, saddr, dif);
 	if (!sk) {
@@ -365,9 +374,34 @@ static void udpv6_mcast_deliver(struct u
 	udpv6_queue_rcv_skb(sk, skb);
 out:
 	read_unlock(&udp_hash_lock);
+	return 0;
 }
 
-static int udpv6_rcv(struct sk_buff **pskb)
+static inline int udp6_csum_init(struct sk_buff *skb, struct udphdr *uh)
+
+{
+	if (uh->check == 0) {
+		/* RFC 2460 section 8.1 says that we SHOULD log
+		   this error. Well, it is reasonable.
+		 */
+		LIMIT_NETDEBUG(KERN_INFO "IPv6: udp checksum is 0\n");
+		return 1;
+	}
+	if (skb->ip_summed == CHECKSUM_COMPLETE &&
+	    !csum_ipv6_magic(&skb->nh.ipv6h->saddr, &skb->nh.ipv6h->daddr,
+		    	     skb->len, IPPROTO_UDP, skb->csum             ))
+		skb->ip_summed = CHECKSUM_UNNECESSARY;
+
+	if (skb->ip_summed != CHECKSUM_UNNECESSARY)
+		skb->csum = ~csum_ipv6_magic(&skb->nh.ipv6h->saddr,
+					     &skb->nh.ipv6h->daddr,
+					     skb->len, IPPROTO_UDP, 0);
+
+	return (UDP_SKB_CB(skb)->partial_cov = 0);
+}
+
+static int __udp6_lib_rcv(struct sk_buff **pskb,
+			  struct hlist_head udptable[], int is_udplite)
 {
 	struct sk_buff *skb = *pskb;
 	struct sock *sk;
@@ -384,44 +418,39 @@ static int udpv6_rcv(struct sk_buff **ps
 	uh = skb->h.uh;
 
 	ulen = ntohs(uh->len);
+	if (ulen > skb->len)
+		goto short_packet;
 
-	/* Check for jumbo payload */
-	if (ulen == 0)
-		ulen = skb->len;
+	if(! is_udplite ) {		/* UDP validates ulen. */
 
-	if (ulen > skb->len || ulen < sizeof(*uh))
-		goto short_packet;
+		/* Check for jumbo payload */
+		if (ulen == 0)
+			ulen = skb->len;
 
-	if (uh->check == 0) {
-		/* RFC 2460 section 8.1 says that we SHOULD log
-		   this error. Well, it is reasonable.
-		 */
-		LIMIT_NETDEBUG(KERN_INFO "IPv6: udp checksum is 0\n");
-		goto discard;
-	}
+		if (ulen < sizeof(*uh))
+			goto short_packet;
 
-	if (ulen < skb->len) {
-		if (pskb_trim_rcsum(skb, ulen))
-			goto discard;
-		saddr = &skb->nh.ipv6h->saddr;
-		daddr = &skb->nh.ipv6h->daddr;
-		uh = skb->h.uh;
-	}
+		if (ulen < skb->len) {
+			if (pskb_trim_rcsum(skb, ulen))
+				goto short_packet;
+			saddr = &skb->nh.ipv6h->saddr;
+			daddr = &skb->nh.ipv6h->daddr;
+			uh = skb->h.uh;
+		}
 
-	if (skb->ip_summed == CHECKSUM_COMPLETE &&
-	    !csum_ipv6_magic(saddr, daddr, ulen, IPPROTO_UDP, skb->csum))
-		skb->ip_summed = CHECKSUM_UNNECESSARY;
+		if (udp6_csum_init(skb, uh))
+			goto discard;
 
-	if (skb->ip_summed != CHECKSUM_UNNECESSARY)
-		skb->csum = ~csum_ipv6_magic(saddr, daddr, ulen, IPPROTO_UDP, 0);
+	} else 	{			/* UDP-Lite validates cscov. */
+		if (udplite6_csum_init(skb, uh))
+			goto discard;
+	}
 
 	/* 
 	 *	Multicast receive code 
 	 */
-	if (ipv6_addr_is_multicast(daddr)) {
-		udpv6_mcast_deliver(uh, saddr, daddr, skb);
-		return 0;
-	}
+	if (ipv6_addr_is_multicast(daddr))
+		return __udp6_lib_mcast_deliver(skb, saddr, daddr, udptable);
 
 	/* Unicast */
 
@@ -429,15 +458,16 @@ static int udpv6_rcv(struct sk_buff **ps
 	 * check socket cache ... must talk to Alan about his plans
 	 * for sock caches... i'll skip this for now.
 	 */
-	sk = udp_v6_lookup(saddr, uh->source, daddr, uh->dest, dev->ifindex);
+	sk = __udp6_lib_lookup(saddr, uh->source,
+			       daddr, uh->dest, dev->ifindex, udptable);
 
 	if (sk == NULL) {
 		if (!xfrm6_policy_check(NULL, XFRM_POLICY_IN, skb))
 			goto discard;
 
-		if (skb_checksum_complete(skb))
+		if (udp_lib_checksum_complete(skb))
 			goto discard;
-		UDP6_INC_STATS_BH(UDP_MIB_NOPORTS);
+		UDP6_INC_STATS_BH(UDP_MIB_NOPORTS, is_udplite);
 
 		icmpv6_send(skb, ICMPV6_DEST_UNREACH, ICMPV6_PORT_UNREACH, 0, dev);
 
@@ -452,14 +482,20 @@ static int udpv6_rcv(struct sk_buff **ps
 	return(0);
 
 short_packet:	
-	if (net_ratelimit())
-		printk(KERN_DEBUG "UDP: short packet: %d/%u\n", ulen, skb->len);
+	LIMIT_NETDEBUG(KERN_DEBUG "UDP%sv6: short packet: %d/%u\n",
+		       is_udplite? "-Lite" : "",  ulen, skb->len);
 
 discard:
-	UDP6_INC_STATS_BH(UDP_MIB_INERRORS);
+	UDP6_INC_STATS_BH(UDP_MIB_INERRORS, is_udplite);
 	kfree_skb(skb);
 	return(0);	
 }
+
+static __inline__ int udpv6_rcv(struct sk_buff **pskb)
+{
+	return __udp6_lib_rcv(pskb, udp_hash, 0);
+}
+
 /*
  * Throw away all pending data and cancel the corking. Socket is locked.
  */
@@ -485,6 +521,7 @@ static int udp_v6_push_pending_frames(st
 	struct inet_sock *inet = inet_sk(sk);
 	struct flowi *fl = &inet->cork.fl;
 	int err = 0;
+	u32 csum = 0;
 
 	/* Grab the skbuff where UDP header space exists. */
 	if ((skb = skb_peek(&sk->sk_write_queue)) == NULL)
@@ -499,35 +536,17 @@ static int udp_v6_push_pending_frames(st
 	uh->len = htons(up->len);
 	uh->check = 0;
 
-	if (sk->sk_no_check == UDP_CSUM_NOXMIT) {
-		skb->ip_summed = CHECKSUM_NONE;
-		goto send;
-	}
+	if (up->pcflag)
+		csum = udplite_csum_outgoing(sk, skb);
+	 else
+		csum = udp_csum_outgoing(sk, skb);
 
-	if (skb_queue_len(&sk->sk_write_queue) == 1) {
-		skb->csum = csum_partial((char *)uh,
-				sizeof(struct udphdr), skb->csum);
-		uh->check = csum_ipv6_magic(&fl->fl6_src,
-					    &fl->fl6_dst,
-					    up->len, fl->proto, skb->csum);
-	} else {
-		u32 tmp_csum = 0;
-
-		skb_queue_walk(&sk->sk_write_queue, skb) {
-			tmp_csum = csum_add(tmp_csum, skb->csum);
-		}
-		tmp_csum = csum_partial((char *)uh,
-				sizeof(struct udphdr), tmp_csum);
-                tmp_csum = csum_ipv6_magic(&fl->fl6_src,
-					   &fl->fl6_dst,
-					   up->len, fl->proto, tmp_csum);
-                uh->check = tmp_csum;
-
-	}
+	/* add protocol-dependent pseudo-header */
+	uh->check = csum_ipv6_magic(&fl->fl6_src, &fl->fl6_dst,
+				    up->len, fl->proto, csum   );
 	if (uh->check == 0)
 		uh->check = -1;
 
-send:
 	err = ip6_push_pending_frames(sk);
 out:
 	up->len = 0;
@@ -555,6 +574,8 @@ static int udpv6_sendmsg(struct kiocb *i
 	int corkreq = up->corkflag || msg->msg_flags&MSG_MORE;
 	int err;
 	int connected = 0;
+	int is_udplite = up->pcflag;
+	int (*getfrag)(void *, char *, int, int, int, struct sk_buff *);
 
 	/* destination address check */
 	if (sin6) {
@@ -695,7 +716,7 @@ do_udp_sendmsg:
 		opt = fl6_merge_options(&opt_space, flowlabel, opt);
 	opt = ipv6_fixup_options(&opt_space, opt);
 
-	fl.proto = IPPROTO_UDP;
+	fl.proto = sk->sk_protocol;
 	ipv6_addr_copy(&fl.fl6_dst, daddr);
 	if (ipv6_addr_any(&fl.fl6_src) && !ipv6_addr_any(&np->saddr))
 		ipv6_addr_copy(&fl.fl6_src, &np->saddr);
@@ -762,7 +783,8 @@ back_from_confirm:
 
 do_append_data:
 	up->len += ulen;
-	err = ip6_append_data(sk, ip_generic_getfrag, msg->msg_iov, ulen,
+	getfrag  =  is_udplite ?  udplite_getfrag : ip_generic_getfrag;
+	err = ip6_append_data(sk, getfrag, msg->msg_iov, ulen,
 		sizeof(struct udphdr), hlimit, tclass, opt, &fl,
 		(struct rt6_info*)dst,
 		corkreq ? msg->msg_flags|MSG_MORE : msg->msg_flags);
@@ -794,7 +816,7 @@ #endif
 out:
 	fl6_sock_release(flowlabel);
 	if (!err) {
-		UDP6_INC_STATS_USER(UDP_MIB_OUTDATAGRAMS);
+		UDP6_INC_STATS_USER(UDP_MIB_OUTDATAGRAMS, is_udplite);
 		return len;
 	}
 	/*
@@ -805,7 +827,7 @@ out:
 	 * seems like overkill.
 	 */
 	if (err == -ENOBUFS || test_bit(SOCK_NOSPACE, &sk->sk_socket->flags)) {
-		UDP6_INC_STATS_USER(UDP_MIB_SNDBUFERRORS);
+		UDP6_INC_STATS_USER(UDP_MIB_SNDBUFERRORS, is_udplite);
 	}
 	return err;
 
@@ -855,7 +877,6 @@ static int do_udpv6_setsockopt(struct so
 			release_sock(sk);
 		}
 		break;
-		
 	case UDP_ENCAP:
 		switch (val) {
 		case 0:
@@ -867,6 +888,24 @@ static int do_udpv6_setsockopt(struct so
 		}
 		break;
 
+	case UDPLITE_SEND_CSCOV:
+		if (!up->pcflag)         /* Disable the option on UDP sockets */
+			return -ENOPROTOOPT;
+		if (val != 0 && val < 8) /* Illegal coverage: use default (8) */
+			val = 8;
+		up->pcslen = val;
+		up->pcflag |= UDPLITE_SEND_CC;
+		break;
+
+	case UDPLITE_RECV_CSCOV:
+		if (!up->pcflag)         /* Disable the option on UDP sockets */
+			return -ENOPROTOOPT;
+		if (val != 0 && val < 8) /* Avoid silly minimal values.       */
+			val = 8;
+		up->pcrlen = val;
+		up->pcflag |= UDPLITE_RECV_CC;
+		break;
+
 	default:
 		err = -ENOPROTOOPT;
 		break;
@@ -878,19 +917,18 @@ static int do_udpv6_setsockopt(struct so
 static int udpv6_setsockopt(struct sock *sk, int level, int optname,
 			  char __user *optval, int optlen)
 {
-	if (level != SOL_UDP)
-		return ipv6_setsockopt(sk, level, optname, optval, optlen);
-	return do_udpv6_setsockopt(sk, level, optname, optval, optlen);
+	if (level == SOL_UDP  ||  level == SOL_UDPLITE)
+		return do_udpv6_setsockopt(sk, level, optname, optval, optlen);
+	return ipv6_setsockopt(sk, level, optname, optval, optlen);
 }
 
 #ifdef CONFIG_COMPAT
 static int compat_udpv6_setsockopt(struct sock *sk, int level, int optname,
 				   char __user *optval, int optlen)
 {
-	if (level != SOL_UDP)
-		return compat_ipv6_setsockopt(sk, level, optname,
-					      optval, optlen);
-	return do_udpv6_setsockopt(sk, level, optname, optval, optlen);
+	if (level == SOL_UDP  ||  level == SOL_UDPLITE)
+		return do_udpv6_setsockopt(sk, level, optname, optval, optlen);
+	return compat_ipv6_setsockopt(sk, level, optname, optval, optlen);
 }
 #endif
 
@@ -917,6 +955,14 @@ static int do_udpv6_getsockopt(struct so
 		val = up->encap_type;
 		break;
 
+	case UDPLITE_SEND_CSCOV:
+		val = up->pcslen;
+		break;
+
+	case UDPLITE_RECV_CSCOV:
+		val = up->pcrlen;
+		break;
+
 	default:
 		return -ENOPROTOOPT;
 	};
@@ -931,19 +977,18 @@ static int do_udpv6_getsockopt(struct so
 static int udpv6_getsockopt(struct sock *sk, int level, int optname,
 			  char __user *optval, int __user *optlen)
 {
-	if (level != SOL_UDP)
-		return ipv6_getsockopt(sk, level, optname, optval, optlen);
-	return do_udpv6_getsockopt(sk, level, optname, optval, optlen);
+	if (level == SOL_UDP  ||  level == SOL_UDPLITE)
+		return do_udpv6_getsockopt(sk, level, optname, optval, optlen);
+	return ipv6_getsockopt(sk, level, optname, optval, optlen);
 }
 
 #ifdef CONFIG_COMPAT
 static int compat_udpv6_getsockopt(struct sock *sk, int level, int optname,
 				   char __user *optval, int __user *optlen)
 {
-	if (level != SOL_UDP)
-		return compat_ipv6_getsockopt(sk, level, optname,
-					      optval, optlen);
-	return do_udpv6_getsockopt(sk, level, optname, optval, optlen);
+	if (level == SOL_UDP  ||  level == SOL_UDPLITE)
+		return do_udpv6_getsockopt(sk, level, optname, optval, optlen);
+	return compat_ipv6_getsockopt(sk, level, optname, optval, optlen);
 }
 #endif
 
@@ -1003,6 +1048,7 @@ static struct udp_seq_afinfo udp6_seq_af
 	.owner		= THIS_MODULE,
 	.name		= "udp6",
 	.family		= AF_INET6,
+	.hashtable	= udp_hash,
 	.seq_show	= udp6_seq_show,
 	.seq_fops	= &udp6_seq_fops,
 };
@@ -1022,7 +1068,7 @@ #endif /* CONFIG_PROC_FS */
 struct proto udpv6_prot = {
 	.name		   = "UDPv6",
 	.owner		   = THIS_MODULE,
-	.close		   = udpv6_close,
+	.close		   = udp_lib_close,
 	.connect	   = ip6_datagram_connect,
 	.disconnect	   = udp_disconnect,
 	.ioctl		   = udp_ioctl,
@@ -1032,8 +1078,8 @@ struct proto udpv6_prot = {
 	.sendmsg	   = udpv6_sendmsg,
 	.recvmsg	   = udpv6_recvmsg,
 	.backlog_rcv	   = udpv6_queue_rcv_skb,
-	.hash		   = udp_v6_hash,
-	.unhash		   = udp_v6_unhash,
+	.hash		   = udp_lib_hash,
+	.unhash		   = udp_lib_unhash,
 	.get_port	   = udp_v6_get_port,
 	.obj_size	   = sizeof(struct udp6_sock),
 #ifdef CONFIG_COMPAT
@@ -1059,3 +1105,5 @@ void __init udpv6_init(void)
 		printk(KERN_ERR "udpv6_init: Could not register protocol\n");
 	inet6_register_protosw(&udpv6_protosw);
 }
+/* the extensions for UDP-Lite (RFC 3828) */
+#include "udplite.c"
diff --git a/net/ipv6/udplite.c b/net/ipv6/udplite.c
new file mode 100644
index 0000000..c6e13ce
--- /dev/null
+++ b/net/ipv6/udplite.c
@@ -0,0 +1,103 @@
+/*
+ *  UDPLITEv6   An implementation of the UDP-Lite protocol over IPv6.
+ *              See also net/ipv4/udplite.c
+ *
+ *  Version:    $Id: udplite.c,v 1.9 2006/10/19 08:28:10 gerrit Exp $
+ *
+ *  Authors:    Gerrit Renker       <gerrit@erg.abdn.ac.uk>
+ *
+ *  Changes:
+ *  Fixes:
+ *		This program is free software; you can redistribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ */
+DEFINE_SNMP_STAT(struct udp_mib, udplite_stats_in6) __read_mostly;
+
+static __inline__ int udplitev6_rcv(struct sk_buff **pskb)
+{
+	return __udp6_lib_rcv(pskb, udplite_hash, 1);
+}
+
+static __inline__ void udplitev6_err(struct sk_buff *skb,
+				     struct inet6_skb_parm *opt,
+				     int type, int code, int offset, __u32 info)
+{
+	return __udp6_lib_err(skb, opt, type, code, offset, info, udplite_hash);
+}
+
+static struct inet6_protocol udplitev6_protocol = {
+	.handler	=	udplitev6_rcv,
+	.err_handler	=	udplitev6_err,
+	.flags		=	INET6_PROTO_NOPOLICY|INET6_PROTO_FINAL,
+};
+
+static __inline__ int udplite_v6_get_port(struct sock *sk, unsigned short snum)
+{
+	return udplite_get_port(sk, snum, ipv6_rcv_saddr_equal);
+}
+
+struct proto udplitev6_prot = {
+	.name		   = "UDPLITEv6",
+	.owner		   = THIS_MODULE,
+	.close		   = udp_lib_close,
+	.connect	   = ip6_datagram_connect,
+	.disconnect	   = udp_disconnect,
+	.ioctl		   = udp_ioctl,
+	.init		   = udplite_sk_init,
+	.destroy	   = udpv6_destroy_sock,
+	.setsockopt	   = udpv6_setsockopt,
+	.getsockopt	   = udpv6_getsockopt,
+	.sendmsg	   = udpv6_sendmsg,
+	.recvmsg	   = udpv6_recvmsg,
+	.backlog_rcv	   = udpv6_queue_rcv_skb,
+	.hash		   = udp_lib_hash,
+	.unhash		   = udp_lib_unhash,
+	.get_port	   = udplite_v6_get_port,
+	.obj_size	   = sizeof(struct udp6_sock),
+#ifdef CONFIG_COMPAT
+	.compat_setsockopt = compat_udpv6_setsockopt,
+	.compat_getsockopt = compat_udpv6_getsockopt,
+#endif
+};
+
+static struct inet_protosw udplite6_protosw = {
+	.type		= SOCK_DGRAM,
+	.protocol	= IPPROTO_UDPLITE,
+	.prot		= &udplitev6_prot,
+	.ops		= &inet6_dgram_ops,
+	.capability	= -1,
+	.no_check	= 0,
+	.flags		= INET_PROTOSW_PERMANENT,
+};
+
+void __init udplitev6_init(void)
+{
+	if (inet6_add_protocol(&udplitev6_protocol, IPPROTO_UDPLITE) < 0)
+		printk(KERN_ERR "%s: Could not register.\n", __FUNCTION__);
+
+	inet6_register_protosw(&udplite6_protosw);
+}
+
+#ifdef CONFIG_PROC_FS
+static struct file_operations udplite6_seq_fops;
+static struct udp_seq_afinfo udplite6_seq_afinfo = {
+	.owner		= THIS_MODULE,
+	.name		= "udplite6",
+	.family		= AF_INET6,
+	.hashtable	= udplite_hash,
+	.seq_show	= udp6_seq_show,
+	.seq_fops	= &udplite6_seq_fops,
+};
+
+int __init udplite6_proc_init(void)
+{
+	return udp_proc_register(&udplite6_seq_afinfo);
+}
+
+void udplite6_proc_exit(void)
+{
+	udp_proc_unregister(&udplite6_seq_afinfo);
+}
+#endif
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 8223c44..e19cf27 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -143,9 +143,13 @@ #define ICMP6_INC_STATS_OFFSET_BH(idev, 
 	SNMP_INC_STATS_OFFSET_BH(icmpv6_statistics, field, _offset);    	\
 })
 DECLARE_SNMP_STAT(struct udp_mib, udp_stats_in6);
-#define UDP6_INC_STATS(field)		SNMP_INC_STATS(udp_stats_in6, field)
-#define UDP6_INC_STATS_BH(field)	SNMP_INC_STATS_BH(udp_stats_in6, field)
-#define UDP6_INC_STATS_USER(field) 	SNMP_INC_STATS_USER(udp_stats_in6, field)
+DECLARE_SNMP_STAT(struct udp_mib, udplite_stats_in6);
+#define UDP6_INC_STATS_BH(field, is_udplite) 			      do  {  \
+	if (is_udplite) SNMP_INC_STATS_BH(udplite_stats_in6, field);         \
+	else		SNMP_INC_STATS_BH(udp_stats_in6, field);    } while(0)
+#define UDP6_INC_STATS_USER(field, is_udplite)			       do {    \
+	if (is_udplite) SNMP_INC_STATS_USER(udplite_stats_in6, field);         \
+	else		SNMP_INC_STATS_USER(udp_stats_in6, field);    } while(0)
 
 int snmp6_register_dev(struct inet6_dev *idev);
 int snmp6_unregister_dev(struct inet6_dev *idev);
@@ -589,6 +593,8 @@ extern int  tcp6_proc_init(void);
 extern void tcp6_proc_exit(void);
 extern int  udp6_proc_init(void);
 extern void udp6_proc_exit(void);
+extern int  udplite6_proc_init(void);
+extern void udplite6_proc_exit(void);
 extern int  ipv6_misc_proc_init(void);
 extern void ipv6_misc_proc_exit(void);
 
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 858cae2..86b4ff0 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -49,6 +49,7 @@ #include <linux/netfilter_ipv6.h>
 #include <net/ip.h>
 #include <net/ipv6.h>
 #include <net/udp.h>
+#include <net/udplite.h>
 #include <net/tcp.h>
 #include <net/ipip.h>
 #include <net/protocol.h>
@@ -737,8 +738,13 @@ static int __init init_ipv6_mibs(void)
 	if (snmp6_mib_init((void **)udp_stats_in6, sizeof (struct udp_mib),
 			   __alignof__(struct udp_mib)) < 0)
 		goto err_udp_mib;
+	if (snmp6_mib_init((void **)udplite_stats_in6, sizeof (struct udp_mib),
+			   __alignof__(struct udp_mib)) < 0)
+		goto err_udplite_mib;
 	return 0;
 
+err_udplite_mib:
+	snmp6_mib_free((void **)udp_stats_in6);
 err_udp_mib:
 	snmp6_mib_free((void **)icmpv6_statistics);
 err_icmp_mib:
@@ -753,6 +759,7 @@ static void cleanup_ipv6_mibs(void)
 	snmp6_mib_free((void **)ipv6_statistics);
 	snmp6_mib_free((void **)icmpv6_statistics);
 	snmp6_mib_free((void **)udp_stats_in6);
+	snmp6_mib_free((void **)udplite_stats_in6);
 }
 
 static int __init inet6_init(void)
@@ -780,10 +787,14 @@ #endif
 	if (err)
 		goto out_unregister_tcp_proto;
 
-	err = proto_register(&rawv6_prot, 1);
+	err = proto_register(&udplitev6_prot, 1);
 	if (err)
 		goto out_unregister_udp_proto;
 
+	err = proto_register(&rawv6_prot, 1);
+	if (err)
+		goto out_unregister_udplite_proto;
+
 
 	/* Register the socket-side information for inet6_create.  */
 	for(r = &inetsw6[0]; r < &inetsw6[SOCK_MAX]; ++r)
@@ -837,6 +848,8 @@ #ifdef CONFIG_PROC_FS
 		goto proc_tcp6_fail;
 	if (udp6_proc_init())
 		goto proc_udp6_fail;
+	if (udplite6_proc_init())
+		goto proc_udplite6_fail;
 	if (ipv6_misc_proc_init())
 		goto proc_misc6_fail;
 
@@ -862,6 +875,7 @@ #endif
 
 	/* Init v6 transport protocols. */
 	udpv6_init();
+	udplitev6_init();
 	tcpv6_init();
 
 	ipv6_packet_init();
@@ -879,6 +893,8 @@ proc_if6_fail:
 proc_anycast6_fail:
 	ipv6_misc_proc_exit();
 proc_misc6_fail:
+	udplite6_proc_exit();
+proc_udplite6_fail:
 	udp6_proc_exit();
 proc_udp6_fail:
 	tcp6_proc_exit();
@@ -902,6 +918,8 @@ out_unregister_sock:
 	sock_unregister(PF_INET6);
 out_unregister_raw_proto:
 	proto_unregister(&rawv6_prot);
+out_unregister_udplite_proto:
+	proto_unregister(&udplitev6_prot);
 out_unregister_udp_proto:
 	proto_unregister(&udpv6_prot);
 out_unregister_tcp_proto:
@@ -919,6 +937,7 @@ #ifdef CONFIG_PROC_FS
 	ac6_proc_exit();
  	ipv6_misc_proc_exit();
  	udp6_proc_exit();
+ 	udplite6_proc_exit();
  	tcp6_proc_exit();
  	raw6_proc_exit();
 #endif
diff --git a/net/ipv6/proc.c b/net/ipv6/proc.c
index efee7a6..d72b36e 100644
--- a/net/ipv6/proc.c
+++ b/net/ipv6/proc.c
@@ -49,6 +49,8 @@ static int sockstat6_seq_show(struct seq
 		       fold_prot_inuse(&tcpv6_prot));
 	seq_printf(seq, "UDP6: inuse %d\n",
 		       fold_prot_inuse(&udpv6_prot));
+	seq_printf(seq, "UDPLITE6: inuse %d\n",
+		        fold_prot_inuse(&udplitev6_prot));
 	seq_printf(seq, "RAW6: inuse %d\n",
 		       fold_prot_inuse(&rawv6_prot));
 	seq_printf(seq, "FRAG6: inuse %d memory %d\n",
@@ -133,6 +135,14 @@ static struct snmp_mib snmp6_udp6_list[]
 	SNMP_MIB_SENTINEL
 };
 
+static struct snmp_mib snmp6_udplite6_list[] = {
+	SNMP_MIB_ITEM("UdpLite6InDatagrams", UDP_MIB_INDATAGRAMS),
+	SNMP_MIB_ITEM("UdpLite6NoPorts", UDP_MIB_NOPORTS),
+	SNMP_MIB_ITEM("UdpLite6InErrors", UDP_MIB_INERRORS),
+	SNMP_MIB_ITEM("UdpLite6OutDatagrams", UDP_MIB_OUTDATAGRAMS),
+	SNMP_MIB_SENTINEL
+};
+
 static unsigned long
 fold_field(void *mib[], int offt)
 {
@@ -166,6 +176,7 @@ static int snmp6_seq_show(struct seq_fil
 		snmp6_seq_show_item(seq, (void **)ipv6_statistics, snmp6_ipstats_list);
 		snmp6_seq_show_item(seq, (void **)icmpv6_statistics, snmp6_icmp6_list);
 		snmp6_seq_show_item(seq, (void **)udp_stats_in6, snmp6_udp6_list);
+		snmp6_seq_show_item(seq, (void **)udplite_stats_in6, snmp6_udplite6_list);
 	}
 	return 0;
 }
diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index de6b919..1eafcfc 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -51,6 +51,7 @@ #include <net/addrconf.h>
 #include <net/inet_common.h>
 #include <net/tcp.h>
 #include <net/udp.h>
+#include <net/udplite.h>
 #include <net/xfrm.h>
 
 #include <asm/uaccess.h>
@@ -239,6 +240,7 @@ static int do_ipv6_setsockopt(struct soc
 			struct sk_buff *pktopt;
 
 			if (sk->sk_protocol != IPPROTO_UDP &&
+			    sk->sk_protocol != IPPROTO_UDPLITE &&
 			    sk->sk_protocol != IPPROTO_TCP)
 				break;
 
@@ -276,11 +278,15 @@ static int do_ipv6_setsockopt(struct soc
 				sk->sk_family = PF_INET;
 				tcp_sync_mss(sk, icsk->icsk_pmtu_cookie);
 			} else {
+				struct proto *prot = &udp_prot;
+
+				if (sk->sk_protocol == IPPROTO_UDPLITE)
+					prot = &udplite_prot;
 				local_bh_disable();
 				sock_prot_dec_use(sk->sk_prot);
-				sock_prot_inc_use(&udp_prot);
+				sock_prot_inc_use(prot);
 				local_bh_enable();
-				sk->sk_prot = &udp_prot;
+				sk->sk_prot = prot;
 				sk->sk_socket->ops = &inet_dgram_ops;
 				sk->sk_family = PF_INET;
 			}
@@ -813,6 +819,7 @@ static int do_ipv6_getsockopt(struct soc
 	switch (optname) {
 	case IPV6_ADDRFORM:
 		if (sk->sk_protocol != IPPROTO_UDP &&
+		    sk->sk_protocol != IPPROTO_UDPLITE &&
 		    sk->sk_protocol != IPPROTO_TCP)
 			return -EINVAL;
 		if (sk->sk_state != TCP_ESTABLISHED)
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index d400f8f..79f112c 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -274,6 +274,7 @@ _decode_session6(struct sk_buff *skb, st
 			break;
 
 		case IPPROTO_UDP:
+		case IPPROTO_UDPLITE:
 		case IPPROTO_TCP:
 		case IPPROTO_SCTP:
 		case IPPROTO_DCCP:
diff --git a/net/ipv6/netfilter/ip6t_LOG.c b/net/ipv6/netfilter/ip6t_LOG.c
index 0cf537d..3cb6bb7 100644
--- a/net/ipv6/netfilter/ip6t_LOG.c
+++ b/net/ipv6/netfilter/ip6t_LOG.c
@@ -270,11 +270,15 @@ static void dump_packet(const struct nf_
 		}
 		break;
 	}
-	case IPPROTO_UDP: {
+	case IPPROTO_UDP:
+	case IPPROTO_UDPLITE: {
 		struct udphdr _udph, *uh;
 
-		/* Max length: 10 "PROTO=UDP " */
-		printk("PROTO=UDP ");
+		if (currenthdr == IPPROTO_UDP)
+			/* Max length: 10 "PROTO=UDP "     */
+			printk("PROTO=UDP " );
+		else	/* Max length: 14 "PROTO=UDPLITE " */
+			printk("PROTO=UDPLITE ");
 
 		if (fragment)
 			break;



