From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: [IPV6] IP6CB
Date: Tue, 08 Jun 2004 12:08:17 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040608.120817.49979734.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Introduce IP6CB(skb), like other protocols such as IPv4.

===== include/linux/ipv6.h 1.19 vs edited =====
--- 1.19/include/linux/ipv6.h	2004-02-17 15:49:11 +09:00
+++ edited/include/linux/ipv6.h	2004-06-08 11:48:25 +09:00
@@ -192,6 +192,8 @@
 	__u16			dst1;
 };
 
+#define IP6CB(skb)	((struct inet6_skb_parm*)((skb)->cb))
+
 struct ipv6_pinfo {
 	struct in6_addr 	saddr;
 	struct in6_addr 	rcv_saddr;
===== net/ipv6/datagram.c 1.16 vs edited =====
--- 1.16/net/ipv6/datagram.c	2004-04-17 05:54:43 +09:00
+++ edited/net/ipv6/datagram.c	2004-06-08 11:57:21 +09:00
@@ -145,10 +145,8 @@
 			  (struct in6_addr *)(skb->nh.raw + serr->addr_offset));
 			if (np->sndflow)
 				sin->sin6_flowinfo = *(u32*)(skb->nh.raw + serr->addr_offset - 24) & IPV6_FLOWINFO_MASK;
-			if (ipv6_addr_type(&sin->sin6_addr) & IPV6_ADDR_LINKLOCAL) {
-				struct inet6_skb_parm *opt = (struct inet6_skb_parm *) skb->cb;
-				sin->sin6_scope_id = opt->iif;
-			}
+			if (ipv6_addr_type(&sin->sin6_addr) & IPV6_ADDR_LINKLOCAL)
+				sin->sin6_scope_id = IP6CB(skb)->iif;
 		} else {
 			ipv6_addr_set(&sin->sin6_addr, 0, 0,
 				      htonl(0xffff),
@@ -167,10 +165,8 @@
 			ipv6_addr_copy(&sin->sin6_addr, &skb->nh.ipv6h->saddr);
 			if (np->rxopt.all)
 				datagram_recv_ctl(sk, msg, skb);
-			if (ipv6_addr_type(&sin->sin6_addr) & IPV6_ADDR_LINKLOCAL) {
-				struct inet6_skb_parm *opt = (struct inet6_skb_parm *) skb->cb;
-				sin->sin6_scope_id = opt->iif;
-			}
+			if (ipv6_addr_type(&sin->sin6_addr) & IPV6_ADDR_LINKLOCAL)
+				sin->sin6_scope_id = IP6CB(skb)->iif;
 		} else {
 			struct inet_opt *inet = inet_sk(sk);
 
@@ -211,7 +207,7 @@
 int datagram_recv_ctl(struct sock *sk, struct msghdr *msg, struct sk_buff *skb)
 {
 	struct ipv6_pinfo *np = inet6_sk(sk);
-	struct inet6_skb_parm *opt = (struct inet6_skb_parm *) skb->cb;
+	struct inet6_skb_parm *opt = IP6CB(skb);
 
 	if (np->rxopt.bits.rxinfo) {
 		struct in6_pktinfo src_info;
===== net/ipv6/exthdrs.c 1.25 vs edited =====
--- 1.25/net/ipv6/exthdrs.c	2004-06-01 16:22:49 +09:00
+++ edited/net/ipv6/exthdrs.c	2004-06-08 11:51:57 +09:00
@@ -155,7 +155,7 @@
 static int ipv6_destopt_rcv(struct sk_buff **skbp, unsigned int *nhoffp)
 {
 	struct sk_buff *skb = *skbp;
-	struct inet6_skb_parm *opt = (struct inet6_skb_parm *)skb->cb;
+	struct inet6_skb_parm *opt = IP6CB(skb);
 
 	if (!pskb_may_pull(skb, (skb->h.raw-skb->data)+8) ||
 	    !pskb_may_pull(skb, (skb->h.raw-skb->data)+((skb->h.raw[1]+1)<<3))) {
@@ -217,7 +217,7 @@
 static int ipv6_rthdr_rcv(struct sk_buff **skbp, unsigned int *nhoffp)
 {
 	struct sk_buff *skb = *skbp;
-	struct inet6_skb_parm *opt = (struct inet6_skb_parm *)skb->cb;
+	struct inet6_skb_parm *opt = IP6CB(skb);
 	struct in6_addr *addr;
 	struct in6_addr daddr;
 	int n, i;
@@ -288,7 +288,7 @@
 			return -1;
 		}
 		*skbp = skb = skb2;
-		opt = (struct inet6_skb_parm *)skb2->cb;
+		opt = IP6CB(skb2);
 		hdr = (struct ipv6_rt_hdr *) skb2->h.raw;
 	}
 
@@ -418,7 +418,7 @@
 static int ipv6_hop_ra(struct sk_buff *skb, int optoff)
 {
 	if (skb->nh.raw[optoff+1] == 2) {
-		((struct inet6_skb_parm*)skb->cb)->ra = optoff;
+		IP6CB(skb)->ra = optoff;
 		return 1;
 	}
 	LIMIT_NETDEBUG(
@@ -482,7 +482,7 @@
 
 int ipv6_parse_hopopts(struct sk_buff *skb, int nhoff)
 {
-	((struct inet6_skb_parm*)skb->cb)->hop = sizeof(struct ipv6hdr);
+	IP6CB(skb)->hop = sizeof(struct ipv6hdr);
 	if (ip6_parse_tlv(tlvprochopopt_lst, skb))
 		return sizeof(struct ipv6hdr);
 	return -1;
===== net/ipv6/ip6_input.c 1.19 vs edited =====
--- 1.19/net/ipv6/ip6_input.c	2004-06-01 16:22:49 +09:00
+++ edited/net/ipv6/ip6_input.c	2004-06-08 11:52:42 +09:00
@@ -74,7 +74,7 @@
 	/* Store incoming device index. When the packet will
 	   be queued, we cannot refer to skb->dev anymore.
 	 */
-	((struct inet6_skb_parm *)skb->cb)->iif = dev->ifindex;
+	IP6CB(skb)->iif = dev->ifindex;
 
 	if (skb->len < sizeof(struct ipv6hdr))
 		goto err;
===== net/ipv6/ip6_output.c 1.58 vs edited =====
--- 1.58/net/ipv6/ip6_output.c	2004-06-04 14:02:47 +09:00
+++ edited/net/ipv6/ip6_output.c	2004-06-08 11:52:52 +09:00
@@ -349,7 +349,7 @@
 {
 	struct dst_entry *dst = skb->dst;
 	struct ipv6hdr *hdr = skb->nh.ipv6h;
-	struct inet6_skb_parm *opt =(struct inet6_skb_parm*)skb->cb;
+	struct inet6_skb_parm *opt = IP6CB(skb);
 	
 	if (ipv6_devconf.forwarding == 0)
 		goto error;
===== net/ipv6/raw.c 1.61 vs edited =====
--- 1.61/net/ipv6/raw.c	2004-06-01 16:22:49 +09:00
+++ edited/net/ipv6/raw.c	2004-06-08 11:53:09 +09:00
@@ -409,10 +409,8 @@
 		ipv6_addr_copy(&sin6->sin6_addr, &skb->nh.ipv6h->saddr);
 		sin6->sin6_flowinfo = 0;
 		sin6->sin6_scope_id = 0;
-		if (ipv6_addr_type(&sin6->sin6_addr) & IPV6_ADDR_LINKLOCAL) {
-			struct inet6_skb_parm *opt = (struct inet6_skb_parm *) skb->cb;
-			sin6->sin6_scope_id = opt->iif;
-		}
+		if (ipv6_addr_type(&sin6->sin6_addr) & IPV6_ADDR_LINKLOCAL)
+			sin6->sin6_scope_id = IP6CB(skb)->iif;
 	}
 
 	sock_recv_timestamp(msg, sk, skb);
===== net/ipv6/tcp_ipv6.c 1.81 vs edited =====
--- 1.81/net/ipv6/tcp_ipv6.c	2004-05-20 15:27:57 +09:00
+++ edited/net/ipv6/tcp_ipv6.c	2004-06-08 11:55:02 +09:00
@@ -536,8 +536,7 @@
 
 static __inline__ int tcp_v6_iif(struct sk_buff *skb)
 {
-	struct inet6_skb_parm *opt = (struct inet6_skb_parm *) skb->cb;
-	return opt->iif;
+	return IP6CB(skb)->iif;
 }
 
 static int tcp_v6_connect(struct sock *sk, struct sockaddr *uaddr, 
@@ -879,7 +878,7 @@
 		    np->rxopt.bits.srcrt == 2 &&
 		    req->af.v6_req.pktopts) {
 			struct sk_buff *pktopts = req->af.v6_req.pktopts;
-			struct inet6_skb_parm *rxopt = (struct inet6_skb_parm *)pktopts->cb;
+			struct inet6_skb_parm *rxopt = IP6CB(pktopts);
 			if (rxopt->srcrt)
 				opt = ipv6_invert_rthdr(sk, (struct ipv6_rt_hdr*)(pktopts->nh.raw + rxopt->srcrt));
 		}
@@ -932,7 +931,7 @@
 static int ipv6_opt_accepted(struct sock *sk, struct sk_buff *skb)
 {
 	struct ipv6_pinfo *np = inet6_sk(sk);
-	struct inet6_skb_parm *opt = (struct inet6_skb_parm *)skb->cb;
+	struct inet6_skb_parm *opt = IP6CB(skb);
 
 	if (np->rxopt.all) {
 		if ((opt->hop && np->rxopt.bits.hopopts) ||
@@ -1305,7 +1304,7 @@
 
 	if (np->rxopt.bits.srcrt == 2 &&
 	    opt == NULL && req->af.v6_req.pktopts) {
-		struct inet6_skb_parm *rxopt = (struct inet6_skb_parm *)req->af.v6_req.pktopts->cb;
+		struct inet6_skb_parm *rxopt = IP6CB(req->af.v6_req.pktopts);
 		if (rxopt->srcrt)
 			opt = ipv6_invert_rthdr(sk, (struct ipv6_rt_hdr*)(req->af.v6_req.pktopts->nh.raw+rxopt->srcrt));
 	}
===== net/ipv6/udp.c 1.63 vs edited =====
--- 1.63/net/ipv6/udp.c	2004-05-30 06:47:37 +09:00
+++ edited/net/ipv6/udp.c	2004-06-08 11:55:30 +09:00
@@ -432,10 +432,8 @@
 
 			if (np->rxopt.all)
 				datagram_recv_ctl(sk, msg, skb);
-			if (ipv6_addr_type(&sin6->sin6_addr) & IPV6_ADDR_LINKLOCAL) {
-				struct inet6_skb_parm *opt = (struct inet6_skb_parm *) skb->cb;
-				sin6->sin6_scope_id = opt->iif;
-			}
+			if (ipv6_addr_type(&sin6->sin6_addr) & IPV6_ADDR_LINKLOCAL)
+				sin6->sin6_scope_id = IP6CB(skb)->iif;
 		}
   	}
 	err = copied;

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
