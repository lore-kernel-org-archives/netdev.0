From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [PATCH 2/3] [IPV6]: Do not send RH0 anymore.
Date: Mon, 18 Jun 2007 15:05:07 +0900 (JST)
Message-ID: <20070618.150507.26285008.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pekkas@netcore.fi, yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:40397 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752524AbXFRGEr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jun 2007 02:04:47 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Based on <draft-ietf-ipv6-deprecate-rh0-00.txt>.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 Documentation/networking/ip-sysctl.txt |    3 +-
 include/linux/ipv6.h                   |    4 +-
 net/ipv6/datagram.c                    |    3 +-
 net/ipv6/exthdrs.c                     |   57 --------------------------------
 net/ipv6/ipv6_sockglue.c               |    3 +-
 net/ipv6/tcp_ipv6.c                    |   20 -----------
 6 files changed, 5 insertions(+), 85 deletions(-)

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
index 05e9bb5..c03273c 100644
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
@@ -596,51 +584,6 @@ void __init ipv6_rthdr_init(void)
 						   --ANK (980729)
  */
 
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
-- 
1.5.1

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
