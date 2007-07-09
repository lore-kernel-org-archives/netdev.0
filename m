From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [GIT PATCH] Updates for RH0 deprecation.
Date: Tue, 10 Jul 2007 02:29:01 +0900 (JST)
Message-ID: <20070710.022901.53209186.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:47667 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754655AbXGIR2Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2007 13:28:24 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

This is "take 2" of updates for deprecating RH0 for
linux-2.6.22 (or net-2.6.23).
Note: sorry, previous patches introduced a linkage error.

Though it is not a good idea to disable RH2, we retain
the knob for it so far for backward compatibility.

Changesets are available at
	git://git.linux-ipv6.org/gitroot/yoshfuji/linux-2.6-dev.git/
on the branch named
	linux-2.6.22_deprecate-rh0-20070710

Regards,

HEADLINES
---------

    [IPV6]: Restore semantics of Routing Header processing.
    [IPV6]: Do not send RH0 anymore.
    [IPV6]: Make IPV6_{RECV,2292}RTHDR boolean options.

DIFFSTAT
--------

 Documentation/networking/ip-sysctl.txt |    3 -
 include/linux/ipv6.h                   |    8 +-
 include/net/ipv6.h                     |    4 -
 net/dccp/ipv6.c                        |   20 -----
 net/ipv6/datagram.c                    |    3 -
 net/ipv6/exthdrs.c                     |  121 ++++----------------------------
 net/ipv6/ipv6_sockglue.c               |   11 +--
 net/ipv6/tcp_ipv6.c                    |   20 -----
 8 files changed, 23 insertions(+), 167 deletions(-)

CHANGESETS
----------

commit 9217342590aa4b4c97bef8b7797c036b4bd8c9d3
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Fri May 11 12:06:01 2007 +0900

    [IPV6]: Restore semantics of Routing Header processing.
    
    The "fix" for emerging security threat was overkill and it broke
    basic semantic of IPv6 routing header processing.  We should assume
    RT0 (or even RT2, depends on configuration) as "unknown" RH type so
    that we
    - silently ignore the routing header if segleft == 0
    - send ICMPv6 Parameter Problem message back to the sender,
      otherwise.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/exthdrs.c b/net/ipv6/exthdrs.c
index 14be0b9..05e9bb5 100644
--- a/net/ipv6/exthdrs.c
+++ b/net/ipv6/exthdrs.c
@@ -371,22 +371,13 @@ static int ipv6_rthdr_rcv(struct sk_buff **skbp)
 	struct rt0_hdr *rthdr;
 	int accept_source_route = ipv6_devconf.accept_source_route;
 
-	if (accept_source_route < 0 ||
-	    ((idev = in6_dev_get(skb->dev)) == NULL)) {
-		kfree_skb(skb);
-		return -1;
-	}
-	if (idev->cnf.accept_source_route < 0) {
+	idev = in6_dev_get(skb->dev);
+	if (idev) {
+		if (accept_source_route > idev->cnf.accept_source_route)
+			accept_source_route = idev->cnf.accept_source_route;
 		in6_dev_put(idev);
-		kfree_skb(skb);
-		return -1;
 	}
 
-	if (accept_source_route > idev->cnf.accept_source_route)
-		accept_source_route = idev->cnf.accept_source_route;
-
-	in6_dev_put(idev);
-
 	if (!pskb_may_pull(skb, skb_transport_offset(skb) + 8) ||
 	    !pskb_may_pull(skb, (skb_transport_offset(skb) +
 				 ((skb_transport_header(skb)[1] + 1) << 3)))) {
@@ -398,24 +389,6 @@ static int ipv6_rthdr_rcv(struct sk_buff **skbp)
 
 	hdr = (struct ipv6_rt_hdr *)skb_transport_header(skb);
 
-	switch (hdr->type) {
-#ifdef CONFIG_IPV6_MIP6
-	case IPV6_SRCRT_TYPE_2:
-		break;
-#endif
-	case IPV6_SRCRT_TYPE_0:
-		if (accept_source_route > 0)
-			break;
-		kfree_skb(skb);
-		return -1;
-	default:
-		IP6_INC_STATS_BH(ip6_dst_idev(skb->dst),
-				 IPSTATS_MIB_INHDRERRORS);
-		icmpv6_param_prob(skb, ICMPV6_HDR_FIELD,
-				  (&hdr->type) - skb_network_header(skb));
-		return -1;
-	}
-
 	if (ipv6_addr_is_multicast(&ipv6_hdr(skb)->daddr) ||
 	    skb->pkt_type != PACKET_HOST) {
 		IP6_INC_STATS_BH(ip6_dst_idev(skb->dst),
@@ -454,6 +427,8 @@ looped_back:
 
 	switch (hdr->type) {
 	case IPV6_SRCRT_TYPE_0:
+		if (accept_source_route <= 0)
+			goto unknown_rh;
 		if (hdr->hdrlen & 0x01) {
 			IP6_INC_STATS_BH(ip6_dst_idev(skb->dst),
 					 IPSTATS_MIB_INHDRERRORS);
@@ -465,6 +440,8 @@ looped_back:
 		break;
 #ifdef CONFIG_IPV6_MIP6
 	case IPV6_SRCRT_TYPE_2:
+		if (accept_source_route < 0)
+			goto unknown_rh;
 		/* Silently discard invalid RTH type 2 */
 		if (hdr->hdrlen != 2 || hdr->segments_left != 1) {
 			IP6_INC_STATS_BH(ip6_dst_idev(skb->dst),
@@ -474,6 +451,8 @@ looped_back:
 		}
 		break;
 #endif
+	default:
+		goto unknown_rh;
 	}
 
 	/*
@@ -577,6 +556,12 @@ looped_back:
 	skb_push(skb, skb->data - skb_network_header(skb));
 	dst_input(skb);
 	return -1;
+
+unknown_rh:
+	IP6_INC_STATS_BH(ip6_dst_idev(skb->dst), IPSTATS_MIB_INHDRERRORS);
+	icmpv6_param_prob(skb, ICMPV6_HDR_FIELD,
+			  (&hdr->type) - skb_network_header(skb));
+	return -1;
 }
 
 static struct inet6_protocol rthdr_protocol = {

---
commit 8abe9b9241dbad242bf8c2664b024c2b2f001e58
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Tue Jul 10 01:29:34 2007 +0900

    [IPV6]: Do not send RH0 anymore.
    
    Based on <draft-ietf-ipv6-deprecate-rh0-00.txt>.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index af6a63a..09c184e 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -874,8 +874,7 @@ accept_redirects - BOOLEAN
 accept_source_route - INTEGER
 	Accept source routing (routing extension header).
 
-	> 0: Accept routing header.
-	= 0: Accept only routing header type 2.
+	>= 0: Accept only routing header type 2.
 	< 0: Do not accept routing header.
 
 	Default: 0
diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index 648bd1f..2cfbe9a 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -27,8 +27,8 @@ struct in6_ifreq {
 	int		ifr6_ifindex; 
 };
 
-#define IPV6_SRCRT_STRICT	0x01	/* this hop must be a neighbor	*/
-#define IPV6_SRCRT_TYPE_0	0	/* IPv6 type 0 Routing Header	*/
+#define IPV6_SRCRT_STRICT	0x01	/* Deprecated; will be removed */
+#define IPV6_SRCRT_TYPE_0	0	/* Deprecated; will be removed */
 #define IPV6_SRCRT_TYPE_2	2	/* IPv6 type 2 Routing Header	*/
 
 /*
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 78a0d06..46b9dce 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -512,10 +512,6 @@ extern int 			ipv6_ext_hdr(u8 nexthdr);
 
 extern int ipv6_find_tlv(struct sk_buff *skb, int offset, int type);
 
-extern struct ipv6_txoptions *	ipv6_invert_rthdr(struct sock *sk,
-						  struct ipv6_rt_hdr *hdr);
-
-
 /*
  *	socket options (ipv6_sockglue.c)
  */
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 31737cd..b158c66 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -253,17 +253,6 @@ static int dccp_v6_send_response(struct sock *sk, struct request_sock *req,
 
 	if (dst == NULL) {
 		opt = np->opt;
-		if (opt == NULL &&
-		    np->rxopt.bits.osrcrt == 2 &&
-		    ireq6->pktopts) {
-			struct sk_buff *pktopts = ireq6->pktopts;
-			struct inet6_skb_parm *rxopt = IP6CB(pktopts);
-
-			if (rxopt->srcrt)
-				opt = ipv6_invert_rthdr(sk,
-			  (struct ipv6_rt_hdr *)(skb_network_header(pktopts) +
-						 rxopt->srcrt));
-		}
 
 		if (opt != NULL && opt->srcrt != NULL) {
 			const struct rt0_hdr *rt0 = (struct rt0_hdr *)opt->srcrt;
@@ -570,15 +559,6 @@ static struct sock *dccp_v6_request_recv_sock(struct sock *sk,
 	if (sk_acceptq_is_full(sk))
 		goto out_overflow;
 
-	if (np->rxopt.bits.osrcrt == 2 && opt == NULL && ireq6->pktopts) {
-		const struct inet6_skb_parm *rxopt = IP6CB(ireq6->pktopts);
-
-		if (rxopt->srcrt)
-			opt = ipv6_invert_rthdr(sk,
-		   (struct ipv6_rt_hdr *)(skb_network_header(ireq6->pktopts) +
-					  rxopt->srcrt));
-	}
-
 	if (dst == NULL) {
 		struct in6_addr *final_p = NULL, final;
 		struct flowi fl;
diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index b1fe7ac..debf402 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -657,11 +657,10 @@ int datagram_send_ctl(struct msghdr *msg, struct flowi *fl,
 			rthdr = (struct ipv6_rt_hdr *)CMSG_DATA(cmsg);
 
 			switch (rthdr->type) {
-			case IPV6_SRCRT_TYPE_0:
 #ifdef CONFIG_IPV6_MIP6
 			case IPV6_SRCRT_TYPE_2:
-#endif
 				break;
+#endif
 			default:
 				err = -EINVAL;
 				goto exit_f;
diff --git a/net/ipv6/exthdrs.c b/net/ipv6/exthdrs.c
index 05e9bb5..97aa36d 100644
--- a/net/ipv6/exthdrs.c
+++ b/net/ipv6/exthdrs.c
@@ -426,18 +426,6 @@ looped_back:
 	}
 
 	switch (hdr->type) {
-	case IPV6_SRCRT_TYPE_0:
-		if (accept_source_route <= 0)
-			goto unknown_rh;
-		if (hdr->hdrlen & 0x01) {
-			IP6_INC_STATS_BH(ip6_dst_idev(skb->dst),
-					 IPSTATS_MIB_INHDRERRORS);
-			icmpv6_param_prob(skb, ICMPV6_HDR_FIELD,
-					  ((&hdr->hdrlen) -
-					   skb_network_header(skb)));
-			return -1;
-		}
-		break;
 #ifdef CONFIG_IPV6_MIP6
 	case IPV6_SRCRT_TYPE_2:
 		if (accept_source_route < 0)
@@ -575,72 +563,6 @@ void __init ipv6_rthdr_init(void)
 		printk(KERN_ERR "ipv6_rthdr_init: Could not register protocol\n");
 };
 
-/*
-   This function inverts received rthdr.
-   NOTE: specs allow to make it automatically only if
-   packet authenticated.
-
-   I will not discuss it here (though, I am really pissed off at
-   this stupid requirement making rthdr idea useless)
-
-   Actually, it creates severe problems  for us.
-   Embryonic requests has no associated sockets,
-   so that user have no control over it and
-   cannot not only to set reply options, but
-   even to know, that someone wants to connect
-   without success. :-(
-
-   For now we need to test the engine, so that I created
-   temporary (or permanent) backdoor.
-   If listening socket set IPV6_RTHDR to 2, then we invert header.
-						   --ANK (980729)
- */
-
-struct ipv6_txoptions *
-ipv6_invert_rthdr(struct sock *sk, struct ipv6_rt_hdr *hdr)
-{
-	/* Received rthdr:
-
-	   [ H1 -> H2 -> ... H_prev ]  daddr=ME
-
-	   Inverted result:
-	   [ H_prev -> ... -> H1 ] daddr =sender
-
-	   Note, that IP output engine will rewrite this rthdr
-	   by rotating it left by one addr.
-	 */
-
-	int n, i;
-	struct rt0_hdr *rthdr = (struct rt0_hdr*)hdr;
-	struct rt0_hdr *irthdr;
-	struct ipv6_txoptions *opt;
-	int hdrlen = ipv6_optlen(hdr);
-
-	if (hdr->segments_left ||
-	    hdr->type != IPV6_SRCRT_TYPE_0 ||
-	    hdr->hdrlen & 0x01)
-		return NULL;
-
-	n = hdr->hdrlen >> 1;
-	opt = sock_kmalloc(sk, sizeof(*opt) + hdrlen, GFP_ATOMIC);
-	if (opt == NULL)
-		return NULL;
-	memset(opt, 0, sizeof(*opt));
-	opt->tot_len = sizeof(*opt) + hdrlen;
-	opt->srcrt = (void*)(opt+1);
-	opt->opt_nflen = hdrlen;
-
-	memcpy(opt->srcrt, hdr, sizeof(*hdr));
-	irthdr = (struct rt0_hdr*)opt->srcrt;
-	irthdr->reserved = 0;
-	opt->srcrt->segments_left = n;
-	for (i=0; i<n; i++)
-		memcpy(irthdr->addr+i, rthdr->addr+(n-1-i), 16);
-	return opt;
-}
-
-EXPORT_SYMBOL_GPL(ipv6_invert_rthdr);
-
 /**********************************
   Hop-by-hop options.
  **********************************/
diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index aa3d07c..f66ce0c 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -416,11 +416,10 @@ static int do_ipv6_setsockopt(struct sock *sk, int level, int optname,
 		if (optname == IPV6_RTHDR && opt && opt->srcrt) {
 			struct ipv6_rt_hdr *rthdr = opt->srcrt;
 			switch (rthdr->type) {
-			case IPV6_SRCRT_TYPE_0:
 #ifdef CONFIG_IPV6_MIP6
 			case IPV6_SRCRT_TYPE_2:
-#endif
 				break;
+#endif
 			default:
 				goto sticky_done;
 			}
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 193d9d6..d67fb1e 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -484,17 +484,6 @@ static int tcp_v6_send_synack(struct sock *sk, struct request_sock *req,
 
 	if (dst == NULL) {
 		opt = np->opt;
-		if (opt == NULL &&
-		    np->rxopt.bits.osrcrt == 2 &&
-		    treq->pktopts) {
-			struct sk_buff *pktopts = treq->pktopts;
-			struct inet6_skb_parm *rxopt = IP6CB(pktopts);
-			if (rxopt->srcrt)
-				opt = ipv6_invert_rthdr(sk,
-			  (struct ipv6_rt_hdr *)(skb_network_header(pktopts) +
-						 rxopt->srcrt));
-		}
-
 		if (opt && opt->srcrt) {
 			struct rt0_hdr *rt0 = (struct rt0_hdr *) opt->srcrt;
 			ipv6_addr_copy(&final, &fl.fl6_dst);
@@ -1391,15 +1380,6 @@ static struct sock * tcp_v6_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 	if (sk_acceptq_is_full(sk))
 		goto out_overflow;
 
-	if (np->rxopt.bits.osrcrt == 2 &&
-	    opt == NULL && treq->pktopts) {
-		struct inet6_skb_parm *rxopt = IP6CB(treq->pktopts);
-		if (rxopt->srcrt)
-			opt = ipv6_invert_rthdr(sk,
-		   (struct ipv6_rt_hdr *)(skb_network_header(treq->pktopts) +
-					  rxopt->srcrt));
-	}
-
 	if (dst == NULL) {
 		struct in6_addr *final_p = NULL, final;
 		struct flowi fl;

---
commit 71f7afdc5fc5ca5117d0c958b357175356301883
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Wed May 23 13:28:48 2007 +0900

    [IPV6]: Make IPV6_{RECV,2292}RTHDR boolean options.
    
    Because reversing RH0 is no longer supported by deprecation
    of RH0, let's make IPV6_{RECV,2292}RTHDR boolean options.
    Boolean are more appropriate from standard POV.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index 2cfbe9a..0b1febb 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -299,8 +299,8 @@ struct ipv6_pinfo {
 	/* pktoption flags */
 	union {
 		struct {
-			__u16	srcrt:2,
-				osrcrt:2,
+			__u16	srcrt:1,
+				osrcrt:1,
 			        rxinfo:1,
 			        rxoinfo:1,
 				rxhlim:1,
diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index f66ce0c..b5c0754 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -336,16 +336,12 @@ static int do_ipv6_setsockopt(struct sock *sk, int level, int optname,
 		break;
 
 	case IPV6_RECVRTHDR:
-		if (val < 0 || val > 2)
-			goto e_inval;
-		np->rxopt.bits.srcrt = val;
+		np->rxopt.bits.srcrt = valbool;
 		retv = 0;
 		break;
 
 	case IPV6_2292RTHDR:
-		if (val < 0 || val > 2)
-			goto e_inval;
-		np->rxopt.bits.osrcrt = val;
+		np->rxopt.bits.osrcrt = valbool;
 		retv = 0;
 		break;
 

---
