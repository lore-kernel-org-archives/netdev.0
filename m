From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: [RFC,PATCH] remove IPV6_AUTHHDR socket option / ancillary data
Date: Sun, 08 Feb 2004 14:11:17 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040208.141117.116936870.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

AH is now handled by the XFRM engine.
IPV6_AUTHHDR socket option / ancillary data are deprecated.

For sender side, it is very difficult (or even almost impossible) to
create "correct" AH in userspace.
For receiver side, none set opt->auth and user space application
never get authentication data.

IPV6_AUTHHDR is very Linux-specific and applications which use
these feature are not portable at all.

Let's remove almost dead code.

===== include/linux/ipv6.h 1.17 vs edited =====
--- 1.17/include/linux/ipv6.h	Fri Jan 16 07:15:33 2004
+++ edited/include/linux/ipv6.h	Sun Feb  8 13:17:28 2004
@@ -185,7 +185,6 @@
 	int			iif;
 	__u16			ra;
 	__u16			hop;
-	__u16			auth;
 	__u16			dst0;
 	__u16			srcrt;
 	__u16			dst1;
@@ -211,7 +210,6 @@
 				rxhlim:1,
 				hopopts:1,
 				dstopts:1,
-                                authhdr:1,
                                 rxflow:1;
 		} bits;
 		__u8		all;
===== net/ipv6/datagram.c 1.14 vs edited =====
--- 1.14/net/ipv6/datagram.c	Thu Jan 22 15:38:40 2004
+++ edited/net/ipv6/datagram.c	Sun Feb  8 13:20:49 2004
@@ -242,10 +242,6 @@
 		struct ipv6_rt_hdr *rthdr = (struct ipv6_rt_hdr *)(skb->nh.raw + opt->srcrt);
 		put_cmsg(msg, SOL_IPV6, IPV6_RTHDR, (rthdr->hdrlen+1) << 3, rthdr);
 	}
-	if (np->rxopt.bits.authhdr && opt->auth) {
-		u8 *ptr = skb->nh.raw + opt->auth;
-		put_cmsg(msg, SOL_IPV6, IPV6_AUTHHDR, (ptr[1]+1)<<2, ptr);
-	}
 	if (np->rxopt.bits.dstopts && opt->dst1) {
 		u8 *ptr = skb->nh.raw + opt->dst1;
 		put_cmsg(msg, SOL_IPV6, IPV6_DSTOPTS, (ptr[1]+1)<<3, ptr);
@@ -376,26 +372,6 @@
 			}
 			opt->opt_flen += len;
 			opt->dst1opt = hdr;
-			break;
-
-		case IPV6_AUTHHDR:
-                        if (cmsg->cmsg_len < CMSG_LEN(sizeof(struct ipv6_opt_hdr))) {
-				err = -EINVAL;
-				goto exit_f;
-			}
-
-			hdr = (struct ipv6_opt_hdr *)CMSG_DATA(cmsg);
-			len = ((hdr->hdrlen + 2) << 2);
-			if (cmsg->cmsg_len < CMSG_LEN(len)) {
-				err = -EINVAL;
-				goto exit_f;
-			}
-			if (len & ~7) {
-				err = -EINVAL;
-				goto exit_f;
-			}
-			opt->opt_flen += len;
-			opt->auth = hdr;
 			break;
 
 		case IPV6_RTHDR:
===== net/ipv6/exthdrs.c 1.15 vs edited =====
--- 1.15/net/ipv6/exthdrs.c	Thu Jan 29 09:06:25 2004
+++ edited/net/ipv6/exthdrs.c	Sun Feb  8 13:14:43 2004
@@ -518,17 +518,6 @@
 	return &h->nexthdr;
 }
 
-static u8 *ipv6_build_authhdr(struct sk_buff *skb, u8 *prev_hdr, struct ipv6_opt_hdr *opt)
-{
-	struct ipv6_opt_hdr *h = (struct ipv6_opt_hdr *)skb_put(skb, (opt->hdrlen+2)<<2);
-
-	memcpy(h, opt, (opt->hdrlen+2)<<2);
-	h->nexthdr = *prev_hdr;
-	*prev_hdr = NEXTHDR_AUTH;
-	return &h->nexthdr;
-}
-
-
 u8 *ipv6_build_nfrag_opts(struct sk_buff *skb, u8 *prev_hdr, struct ipv6_txoptions *opt,
 			  struct in6_addr *daddr, u32 jumbolen)
 {
@@ -567,8 +556,6 @@
 
 u8 *ipv6_build_frag_opts(struct sk_buff *skb, u8 *prev_hdr, struct ipv6_txoptions *opt)
 {
-	if (opt->auth)
-		prev_hdr = ipv6_build_authhdr(skb, prev_hdr, opt->auth);
 	if (opt->dst1opt)
 		prev_hdr = ipv6_build_exthdr(skb, prev_hdr, NEXTHDR_DEST, opt->dst1opt);
 	return prev_hdr;
@@ -608,15 +595,6 @@
 	*proto = type;
 }
 
-static void ipv6_push_authhdr(struct sk_buff *skb, u8 *proto, struct ipv6_opt_hdr *opt)
-{
-	struct ipv6_opt_hdr *h = (struct ipv6_opt_hdr *)skb_push(skb, (opt->hdrlen+2)<<2);
-
-	memcpy(h, opt, (opt->hdrlen+2)<<2);
-	h->nexthdr = *proto;
-	*proto = NEXTHDR_AUTH;
-}
-
 void ipv6_push_nfrag_opts(struct sk_buff *skb, struct ipv6_txoptions *opt,
 			  u8 *proto,
 			  struct in6_addr **daddr)
@@ -633,8 +611,6 @@
 {
 	if (opt->dst1opt)
 		ipv6_push_exthdr(skb, proto, NEXTHDR_DEST, opt->dst1opt);
-	if (opt->auth)
-		ipv6_push_authhdr(skb, proto, opt->auth);
 }
 
 struct ipv6_txoptions *
@@ -652,8 +628,6 @@
 			*((char**)&opt2->dst0opt) += dif;
 		if (opt2->dst1opt)
 			*((char**)&opt2->dst1opt) += dif;
-		if (opt2->auth)
-			*((char**)&opt2->auth) += dif;
 		if (opt2->srcrt)
 			*((char**)&opt2->srcrt) += dif;
 	}
===== net/ipv6/ipv6_sockglue.c 1.23 vs edited =====
--- 1.23/net/ipv6/ipv6_sockglue.c	Wed Jan 14 09:36:24 2004
+++ edited/net/ipv6/ipv6_sockglue.c	Sun Feb  8 13:14:15 2004
@@ -230,11 +230,6 @@
 		retv = 0;
 		break;
 
-	case IPV6_AUTHHDR:
-		np->rxopt.bits.authhdr = valbool;
-		retv = 0;
-		break;
-
 	case IPV6_DSTOPTS:
 		np->rxopt.bits.dstopts = valbool;
 		retv = 0;
@@ -621,10 +616,6 @@
 
 	case IPV6_HOPOPTS:
 		val = np->rxopt.bits.hopopts;
-		break;
-
-	case IPV6_AUTHHDR:
-		val = np->rxopt.bits.authhdr;
 		break;
 
 	case IPV6_DSTOPTS:



-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
