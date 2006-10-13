From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [PATCHv4 2/3] net/ipv6: v6-side of UDP-Lite
Date: Fri, 13 Oct 2006 16:14:29 +0100
Message-ID: <200610131614.29880@strip-the-willow>
References: <200609190825.23709@strip-the-willow> <200610120849.19984@strip-the-willow> <20061012.020140.39159089.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:22733 "EHLO erg.abdn.ac.uk")
	by vger.kernel.org with ESMTP id S1751156AbWJMPOx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Oct 2006 11:14:53 -0400
To: "YOSHIFUJI Hideaki / =?utf-8?q?=E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E?="
	<yoshfuji@linux-ipv6.org>
In-Reply-To: <20061012.020140.39159089.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This provides consolidated UDP-Lite support over IPv6.
Changes to net/ipv6/udp.c reflect those in net/ipv4/udp.c. 


Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 include/net/ipv6.h      |   10 +
 include/net/transp_v6.h |    3
 net/ipv6/af_inet6.c     |    3
 net/ipv6/proc.c         |   11 +
 net/ipv6/udp.c          |  333 ++++++++++++++++++++++++++++--------------------
 net/ipv6/udplite.c      |  131 ++++++++++++++++++
 6 files changed, 350 insertions(+), 141 deletions(-)

diff --git a/include/net/transp_v6.h b/include/net/transp_v6.h
index 61f724c..d5a337d 100644
--- a/include/net/transp_v6.h
+++ b/include/net/transp_v6.h
@@ -11,6 +11,7 @@ #ifdef __KERNEL__
 
 extern struct proto rawv6_prot;
 extern struct proto udpv6_prot;
+extern struct proto udplitev6_prot;
 extern struct proto tcpv6_prot;
 
 struct flowi;
@@ -24,6 +25,8 @@ extern void				ipv6_destopt_init(void);
 /* transport protocols */
 extern void				rawv6_init(void);
 extern void				udpv6_init(void);
+extern void 				udplitev6_init(void);
+extern void 				udplitev6_cleanup(void);
 extern void				tcpv6_init(void);
 
 extern int				udpv6_connect(struct sock *sk,
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index e0c3934..72f3d69 100644
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
@@ -131,13 +118,11 @@ static struct sock *udp_v6_lookup(struct
 	return result;
 }
 
-/*
- *
- */
-
-static void udpv6_close(struct sock *sk, long timeout)
+static __inline__ struct sock *udp_v6_lookup(struct in6_addr *saddr, __be16 sport,
+				  	     struct in6_addr *daddr, __be16 dport,
+					     int dif)
 {
-	sk_common_release(sk);
+	return __udp6_lib_lookup(saddr, sport, daddr, dport, dif, udp_hash);
 }
 
 /*
@@ -153,7 +138,7 @@ static int udpv6_recvmsg(struct kiocb *i
 	struct inet_sock *inet = inet_sk(sk);
   	struct sk_buff *skb;
 	size_t copied;
-  	int err;
+	int err, copy_only, is_udplite = IS_UDPLITE(sk);
 
   	if (addr_len)
   		*addr_len=sizeof(struct sockaddr_in6);
@@ -172,15 +157,21 @@ try_again:
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
@@ -231,14 +222,15 @@ csum_copy_err:
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
@@ -249,8 +241,8 @@ static void udpv6_err(struct sk_buff *sk
 	struct sock *sk;
 	int err;
 
-	sk = udp_v6_lookup(daddr, uh->dest, saddr, uh->source, dev->ifindex);
-   
+	sk = __udp6_lib_lookup(daddr, uh->dest,
+			       saddr, uh->source, dev->ifindex, udptable);
 	if (sk == NULL)
 		return;
 
@@ -271,31 +263,56 @@ out:
 	sock_put(sk);
 }
 
-static inline int udpv6_queue_rcv_skb(struct sock * sk, struct sk_buff *skb)
+static __inline__ void udpv6_err(struct sk_buff *skb,
+				 struct inet6_skb_parm *opt, int type,
+				 int code, int offset, __u32 info     )
 {
+	return __udp6_lib_err(skb, opt, type, code, offset, info, udp_hash);
+}
+
+static int udpv6_queue_rcv_skb(struct sock * sk, struct sk_buff *skb)
+{
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
+	 * 	UDP-Lite specific tests, ignored on UDP sockets.
+	 *      For comments on these cases, see net/ipv4/udp.c
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
 
+	if (__udp_lib_checksum_complete(skb))
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
@@ -339,15 +356,15 @@ static struct sock *udp_v6_mcast_next(st
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
@@ -365,9 +382,34 @@ static void udpv6_mcast_deliver(struct u
 	udpv6_queue_rcv_skb(sk, skb);
 out:
 	read_unlock(&udp_hash_lock);
+	return 0;
+}
+
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
 }
 
-static int udpv6_rcv(struct sk_buff **pskb)
+static int __udp6_lib_rcv(struct sk_buff **pskb,
+			  struct hlist_head udptable[], int is_udplite)
 {
 	struct sk_buff *skb = *pskb;
 	struct sock *sk;
@@ -384,44 +426,39 @@ static int udpv6_rcv(struct sk_buff **ps
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
 
@@ -429,15 +466,16 @@ static int udpv6_rcv(struct sk_buff **ps
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
+		if (__udp_lib_checksum_complete(skb))
 			goto discard;
-		UDP6_INC_STATS_BH(UDP_MIB_NOPORTS);
+		UDP6_INC_STATS_BH(UDP_MIB_NOPORTS, is_udplite);
 
 		icmpv6_send(skb, ICMPV6_DEST_UNREACH, ICMPV6_PORT_UNREACH, 0, dev);
 
@@ -452,14 +490,20 @@ static int udpv6_rcv(struct sk_buff **ps
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
@@ -485,6 +529,7 @@ static int udp_v6_push_pending_frames(st
 	struct inet_sock *inet = inet_sk(sk);
 	struct flowi *fl = &inet->cork.fl;
 	int err = 0;
+	u32 csum = 0;
 
 	/* Grab the skbuff where UDP header space exists. */
 	if ((skb = skb_peek(&sk->sk_write_queue)) == NULL)
@@ -499,35 +544,17 @@ static int udp_v6_push_pending_frames(st
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
@@ -555,6 +582,8 @@ static int udpv6_sendmsg(struct kiocb *i
 	int corkreq = up->corkflag || msg->msg_flags&MSG_MORE;
 	int err;
 	int connected = 0;
+	int is_udplite = up->pcflag;
+	int (*getfrag)(void *, char *, int, int, int, struct sk_buff *);
 
 	/* destination address check */
 	if (sin6) {
@@ -695,7 +724,7 @@ do_udp_sendmsg:
 		opt = fl6_merge_options(&opt_space, flowlabel, opt);
 	opt = ipv6_fixup_options(&opt_space, opt);
 
-	fl.proto = IPPROTO_UDP;
+	fl.proto = sk->sk_protocol,
 	ipv6_addr_copy(&fl.fl6_dst, daddr);
 	if (ipv6_addr_any(&fl.fl6_src) && !ipv6_addr_any(&np->saddr))
 		ipv6_addr_copy(&fl.fl6_src, &np->saddr);
@@ -762,7 +791,8 @@ back_from_confirm:
 
 do_append_data:
 	up->len += ulen;
-	err = ip6_append_data(sk, ip_generic_getfrag, msg->msg_iov, ulen,
+	getfrag  =  is_udplite ?  udplite_getfrag : ip_generic_getfrag;
+	err = ip6_append_data(sk, getfrag, msg->msg_iov, ulen,
 		sizeof(struct udphdr), hlimit, tclass, opt, &fl,
 		(struct rt6_info*)dst,
 		corkreq ? msg->msg_flags|MSG_MORE : msg->msg_flags);
@@ -794,7 +824,7 @@ #endif
 out:
 	fl6_sock_release(flowlabel);
 	if (!err) {
-		UDP6_INC_STATS_USER(UDP_MIB_OUTDATAGRAMS);
+		UDP6_INC_STATS_USER(UDP_MIB_OUTDATAGRAMS, is_udplite);
 		return len;
 	}
 	/*
@@ -805,7 +835,7 @@ out:
 	 * seems like overkill.
 	 */
 	if (err == -ENOBUFS || test_bit(SOCK_NOSPACE, &sk->sk_socket->flags)) {
-		UDP6_INC_STATS_USER(UDP_MIB_SNDBUFERRORS);
+		UDP6_INC_STATS_USER(UDP_MIB_SNDBUFERRORS, is_udplite);
 	}
 	return err;
 
@@ -855,7 +885,7 @@ static int do_udpv6_setsockopt(struct so
 			release_sock(sk);
 		}
 		break;
-		
+
 	case UDP_ENCAP:
 		switch (val) {
 		case 0:
@@ -866,6 +896,24 @@ static int do_udpv6_setsockopt(struct so
 			break;
 		}
 		break;
+
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
 
 	default:
 		err = -ENOPROTOOPT;
@@ -878,19 +926,18 @@ static int do_udpv6_setsockopt(struct so
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
 
@@ -917,6 +964,14 @@ static int do_udpv6_getsockopt(struct so
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
@@ -931,19 +986,18 @@ static int do_udpv6_getsockopt(struct so
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
 
@@ -1003,6 +1057,7 @@ static struct udp_seq_afinfo udp6_seq_af
 	.owner		= THIS_MODULE,
 	.name		= "udp6",
 	.family		= AF_INET6,
+	.hashtable	= udp_hash,
 	.seq_show	= udp6_seq_show,
 	.seq_fops	= &udp6_seq_fops,
 };
@@ -1022,7 +1077,7 @@ #endif /* CONFIG_PROC_FS */
 struct proto udpv6_prot = {
 	.name		   = "UDPv6",
 	.owner		   = THIS_MODULE,
-	.close		   = udpv6_close,
+	.close		   = udp_lib_close,
 	.connect	   = ip6_datagram_connect,
 	.disconnect	   = udp_disconnect,
 	.ioctl		   = udp_ioctl,
@@ -1032,8 +1087,8 @@ struct proto udpv6_prot = {
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
@@ -1059,3 +1114,5 @@ void __init udpv6_init(void)
 		printk(KERN_ERR "udpv6_init: Could not register protocol\n");
 	inet6_register_protosw(&udpv6_protosw);
 }
+/* the extensions for UDP-Lite (RFC 3828) */
+#include "udplite.c"
diff --git a/net/ipv6/udplite.c b/net/ipv6/udplite.c
new file mode 100644
index 0000000..ee410f7
--- /dev/null
+++ b/net/ipv6/udplite.c
@@ -0,0 +1,131 @@
+/*
+ *  UDPLITEv6   An implementation of the UDP-Lite protocol over IPv6.
+ *              See also net/ipv4/udplite.c
+ *
+ *  Version:    $Id: udplite.c,v 1.8 2006/07/14 09:06:24 gerrit Exp gerrit $
+ *
+ *  Authors:    Gerrit Renker       <gerrit@erg.abdn.ac.uk>
+ *
+ *  Changes:
+ *  Fixes:
+ *
+ *		This program is free software; you can redistribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ */
+DEFINE_SNMP_STAT(struct udp_mib, udplite_stats_in6) __read_mostly;
+
+static __inline__ int udplite6_mib_init(void)
+{
+	return snmp6_mib_init((void **)udplite_stats_in6,
+			      sizeof(struct udp_mib),
+			      __alignof__(struct udp_mib) );
+}
+
+static __inline__ int udplite_v6_get_port(struct sock *sk, unsigned short snum)
+{
+	return udplite_get_port(sk, snum, ipv6_rcv_saddr_equal);
+}
+
+static __inline__ struct sock *udplite_v6_lookup(struct in6_addr *saddr, __be16 sport,
+				  		 struct in6_addr *daddr, __be16 dport,
+						 int dif)
+{
+	return __udp6_lib_lookup(saddr, sport, daddr, dport, dif, udplite_hash);
+}
+
+static __inline__ int udplitev6_rcv(struct sk_buff **pskb)
+{
+	return __udp6_lib_rcv(pskb, udplite_hash, 1);
+}
+
+static __inline__ void udplitev6_err(struct sk_buff *skb,
+				     struct inet6_skb_parm *opt, int type,
+				     int code, int offset, __u32 info     )
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
+#endif
+
+void __init udplitev6_init(void)
+{
+	if (proto_register(&udplitev6_prot, 1))
+		goto out_register_err;
+
+	if (inet6_add_protocol(&udplitev6_protocol, IPPROTO_UDPLITE) < 0)
+		goto out_unregister_proto;
+
+	inet6_register_protosw(&udplite6_protosw);
+
+        if(udplite6_mib_init() < 0)
+		printk(KERN_ERR "%s: Can not add MIB support.\n", __FUNCTION__);
+
+#ifdef CONFIG_PROC_FS
+	if (udp_proc_register(&udplite6_seq_afinfo))
+		printk(KERN_ERR "%s: Cannot register /proc!\n", __FUNCTION__);
+#endif
+	return;
+
+out_unregister_proto:
+	proto_unregister(&udplitev6_prot);
+out_register_err:
+	printk(KERN_ERR "%s: Could not register.\n", __FUNCTION__);
+}
+
+void __exit udplitev6_cleanup(void)
+{
+	snmp6_mib_free((void **)udplite_stats_in6);
+	proto_unregister(&udplitev6_prot);
+}
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 8223c44..60cbe35 100644
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
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 858cae2..fdc7bef 100644
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
@@ -862,6 +863,7 @@ #endif
 
 	/* Init v6 transport protocols. */
 	udpv6_init();
+	udplitev6_init();
 	tcpv6_init();
 
 	ipv6_packet_init();
@@ -926,6 +928,7 @@ #ifdef CONFIG_IPV6_MIP6
 	mip6_fini();
 #endif
 	/* Cleanup code parts. */
+	udplitev6_cleanup();
 	ip6_flowlabel_cleanup();
 	addrconf_cleanup();
 	ip6_route_cleanup();

