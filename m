From: "David S. Miller" <davem@redhat.com>
Subject: Re: IPSec: IPv6 random failures
Date: Thu, 22 May 2003 17:43:17 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030522.174317.21915853.davem@redhat.com>
References: <OF5D0301D4.91C949F2-ON86256D2E.0061C9C3-86256D2E.006456C0@pok.ibm.com>
	<20030522.155408.85396915.davem@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, kuznet@ms2.inr.ac.ru
Return-path: <netdev-bounce@oss.sgi.com>
To: toml@us.ibm.com
In-Reply-To: <20030522.155408.85396915.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: "David S. Miller" <davem@redhat.com>
   Date: Thu, 22 May 2003 15:54:08 -0700 (PDT)
   
   I'll see how much work it is to change all of ipv6 to store
   addresses directly into the flowi's instead of via pointers.
   
Whoa, what a rats nest area of the ipv6 stack :-(((

Ok, this cleaned up a LOT of crap.  Silly kmalloc's of in6_addr
objects and all sorts of junk like that (especially ip6_dst_lookup()).
The rt0_hdr handling was a little tricky, but I think I got it all
sorted out.

Can someone review and stress test out this patch for me?

One thing to look out for are not-fully initialized flowi
structures.  Ie. there are only two valid ways to setup
such objects:

	struct flowi fl = { .foo = x, .bar = y, ... };

and

	struct flowi fl;

	memset(&fl, 0, sizeof(fl));
	fl.foo = x;
	fl.bar = y;
	...

So if there are any cases left that don't do this correctly
please let me know.

--- ./include/net/flow.h.~1~	Thu May 22 15:58:19 2003
+++ ./include/net/flow.h	Thu May 22 17:25:11 2003
@@ -7,6 +7,8 @@
 #ifndef _NET_FLOW_H
 #define _NET_FLOW_H
 
+#include <linux/in6.h>
+
 struct flowi {
 	int	oif;
 	int	iif;
@@ -21,8 +23,8 @@ struct flowi {
 		} ip4_u;
 		
 		struct {
-			struct in6_addr *	daddr;
-			struct in6_addr *	saddr;
+			struct in6_addr		daddr;
+			struct in6_addr		saddr;
 			__u32			flowlabel;
 		} ip6_u;
 
--- ./include/net/xfrm.h.~1~	Thu May 22 16:00:14 2003
+++ ./include/net/xfrm.h	Thu May 22 16:00:49 2003
@@ -315,14 +315,14 @@ static inline u32 __flow_hash4(struct fl
 
 static inline u32 __flow_hash6(struct flowi *fl)
 {
-	u32 hash = fl->fl6_src->s6_addr32[2] ^
-		   fl->fl6_src->s6_addr32[3] ^ 
+	u32 hash = fl->fl6_src.s6_addr32[2] ^
+		   fl->fl6_src.s6_addr32[3] ^ 
 		   fl->fl_ip_sport;
 
 	hash = ((hash & 0xF0F0F0F0) >> 4) | ((hash & 0x0F0F0F0F) << 4);
 
-	hash ^= fl->fl6_dst->s6_addr32[2] ^
-		fl->fl6_dst->s6_addr32[3] ^ 
+	hash ^= fl->fl6_dst.s6_addr32[2] ^
+		fl->fl6_dst.s6_addr32[3] ^ 
 		fl->fl_ip_dport;
 	hash ^= (hash >> 10);
 	hash ^= (hash >> 20);
@@ -471,8 +471,8 @@ __xfrm4_selector_match(struct xfrm_selec
 static inline int
 __xfrm6_selector_match(struct xfrm_selector *sel, struct flowi *fl)
 {
-	return  addr_match(fl->fl6_dst, &sel->daddr, sel->prefixlen_d) &&
-		addr_match(fl->fl6_src, &sel->saddr, sel->prefixlen_s) &&
+	return  addr_match(&fl->fl6_dst, &sel->daddr, sel->prefixlen_d) &&
+		addr_match(&fl->fl6_src, &sel->saddr, sel->prefixlen_s) &&
 		!((fl->fl_ip_dport^sel->dport)&sel->dport_mask) &&
 		!((fl->fl_ip_sport^sel->sport)&sel->sport_mask) &&
 		(fl->proto == sel->proto || !sel->proto) &&
@@ -654,7 +654,7 @@ xfrm_address_t *xfrm_flowi_daddr(struct 
 	case AF_INET:
 		return (xfrm_address_t *)&fl->fl4_dst;
 	case AF_INET6:
-		return (xfrm_address_t *)fl->fl6_dst;
+		return (xfrm_address_t *)&fl->fl6_dst;
 	}
 	return NULL;
 }
@@ -666,7 +666,7 @@ xfrm_address_t *xfrm_flowi_saddr(struct 
 	case AF_INET:
 		return (xfrm_address_t *)&fl->fl4_src;
 	case AF_INET6:
-		return (xfrm_address_t *)fl->fl6_src;
+		return (xfrm_address_t *)&fl->fl6_src;
 	}
 	return NULL;
 }
--- ./include/net/ipv6.h.~1~	Thu May 22 16:40:49 2003
+++ ./include/net/ipv6.h	Thu May 22 16:41:00 2003
@@ -334,8 +334,7 @@ extern void			ip6_flush_pending_frames(s
 
 extern int			ip6_dst_lookup(struct sock *sk,
 					       struct dst_entry **dst,
-					       struct flowi *fl,
-					       struct in6_addr **saddr);
+					       struct flowi *fl);
 
 /*
  *	skb processing functions
--- ./net/ipv6/datagram.c.~1~	Thu May 22 16:00:14 2003
+++ ./net/ipv6/datagram.c	Thu May 22 16:01:17 2003
@@ -80,7 +80,7 @@ void ipv6_local_error(struct sock *sk, i
 
 	iph = (struct ipv6hdr*)skb_put(skb, sizeof(struct ipv6hdr));
 	skb->nh.ipv6h = iph;
-	ipv6_addr_copy(&iph->daddr, fl->fl6_dst);
+	ipv6_addr_copy(&iph->daddr, &fl->fl6_dst);
 
 	serr = SKB_EXT_ERR(skb);
 	serr->ee.ee_errno = err;
@@ -297,7 +297,8 @@ int datagram_send_ctl(struct msghdr *msg
 					goto exit_f;
 				}
 
-				fl->fl6_src = &src_info->ipi6_addr;
+				ipv6_addr_copy(&fl->fl6_src,
+					       &src_info->ipi6_addr);
 			}
 
 			break;
--- ./net/ipv6/icmp.c.~1~	Thu May 22 16:00:14 2003
+++ ./net/ipv6/icmp.c	Thu May 22 17:36:53 2003
@@ -223,9 +223,10 @@ int icmpv6_push_pending_frames(struct so
 	if (skb_queue_len(&sk->write_queue) == 1) {
 		skb->csum = csum_partial((char *)icmp6h,
 					sizeof(struct icmp6hdr), skb->csum);
-		icmp6h->icmp6_cksum = csum_ipv6_magic(fl->fl6_src,
-					     fl->fl6_dst,
-					     len, fl->proto, skb->csum);
+		icmp6h->icmp6_cksum = csum_ipv6_magic(&fl->fl6_src,
+						      &fl->fl6_dst,
+						      len, fl->proto,
+						      skb->csum);
 	} else {
 		u32 tmp_csum = 0;
 
@@ -235,8 +236,8 @@ int icmpv6_push_pending_frames(struct so
 
 		tmp_csum = csum_partial((char *)icmp6h,
 					sizeof(struct icmp6hdr), tmp_csum);
-		tmp_csum = csum_ipv6_magic(fl->fl6_src,
-					   fl->fl6_dst,
+		tmp_csum = csum_ipv6_magic(&fl->fl6_src,
+					   &fl->fl6_dst,
 					   len, fl->proto, tmp_csum);
 		icmp6h->icmp6_cksum = tmp_csum;
 	}
@@ -266,7 +267,7 @@ void icmpv6_send(struct sk_buff *skb, in
 	struct ipv6hdr *hdr = skb->nh.ipv6h;
 	struct sock *sk = icmpv6_socket->sk;
 	struct ipv6_pinfo *np = inet6_sk(sk);
-	struct in6_addr *saddr = NULL, *tmp_saddr = NULL;
+	struct in6_addr *saddr = NULL;
 	struct dst_entry *dst;
 	struct icmp6hdr tmp_hdr;
 	struct flowi fl;
@@ -332,11 +333,12 @@ void icmpv6_send(struct sk_buff *skb, in
 		return;
 	}
 
+	memset(&fl, 0, sizeof(fl));
 	fl.proto = IPPROTO_ICMPV6;
-	fl.fl6_dst = &hdr->saddr;
-	fl.fl6_src = saddr;
+	ipv6_addr_copy(&fl.fl6_dst, &hdr->saddr);
+	if (saddr)
+		ipv6_addr_copy(&fl.fl6_src, saddr);
 	fl.oif = iif;
-	fl.fl6_flowlabel = 0;
 	fl.fl_icmp_type = type;
 	fl.fl_icmp_code = code;
 
@@ -350,14 +352,14 @@ void icmpv6_send(struct sk_buff *skb, in
 	tmp_hdr.icmp6_cksum = 0;
 	tmp_hdr.icmp6_pointer = htonl(info);
 
-	if (!fl.oif && ipv6_addr_is_multicast(fl.fl6_dst))
+	if (!fl.oif && ipv6_addr_is_multicast(&fl.fl6_dst))
 		fl.oif = np->mcast_oif;
 
-	err = ip6_dst_lookup(sk, &dst, &fl, &tmp_saddr);
+	err = ip6_dst_lookup(sk, &dst, &fl);
 	if (err) goto out;
 
 	if (hlimit < 0) {
-		if (ipv6_addr_is_multicast(fl.fl6_dst))
+		if (ipv6_addr_is_multicast(&fl.fl6_dst))
 			hlimit = np->mcast_hops;
 		else
 			hlimit = np->hop_limit;
@@ -394,7 +396,6 @@ void icmpv6_send(struct sk_buff *skb, in
 	if (likely(idev != NULL))
 		in6_dev_put(idev);
 out:
-	if (tmp_saddr) kfree(tmp_saddr);
 	icmpv6_xmit_unlock();
 }
 
@@ -403,7 +404,7 @@ static void icmpv6_echo_reply(struct sk_
 	struct sock *sk = icmpv6_socket->sk;
 	struct inet6_dev *idev;
 	struct ipv6_pinfo *np = inet6_sk(sk);
-	struct in6_addr *saddr = NULL, *tmp_saddr = NULL;
+	struct in6_addr *saddr = NULL;
 	struct icmp6hdr *icmph = (struct icmp6hdr *) skb->h.raw;
 	struct icmp6hdr tmp_hdr;
 	struct flowi fl;
@@ -420,25 +421,25 @@ static void icmpv6_echo_reply(struct sk_
 	memcpy(&tmp_hdr, icmph, sizeof(tmp_hdr));
 	tmp_hdr.icmp6_type = ICMPV6_ECHO_REPLY;
 
+	memset(&fl, 0, sizeof(fl));
 	fl.proto = IPPROTO_ICMPV6;
-	fl.fl6_dst = &skb->nh.ipv6h->saddr;
-	fl.fl6_src = saddr;
+	ipv6_addr_copy(&fl.fl6_dst, &skb->nh.ipv6h->saddr);
+	if (saddr)
+		ipv6_addr_copy(&fl.fl6_src, saddr);
 	fl.oif = skb->dev->ifindex;
-	fl.fl6_flowlabel = 0;
 	fl.fl_icmp_type = ICMPV6_ECHO_REPLY;
-	fl.fl_icmp_code = 0;
 
 	icmpv6_xmit_lock();
 
-	if (!fl.oif && ipv6_addr_is_multicast(fl.nl_u.ip6_u.daddr))
+	if (!fl.oif && ipv6_addr_is_multicast(&fl.fl6_dst))
 		fl.oif = np->mcast_oif;
 
-	err = ip6_dst_lookup(sk, &dst, &fl, &tmp_saddr);
+	err = ip6_dst_lookup(sk, &dst, &fl);
 
 	if (err) goto out;
 
 	if (hlimit < 0) {
-		if (ipv6_addr_is_multicast(fl.fl6_dst))
+		if (ipv6_addr_is_multicast(&fl.fl6_dst))
 			hlimit = np->mcast_hops;
 		else
 			hlimit = np->hop_limit;
@@ -464,7 +465,6 @@ static void icmpv6_echo_reply(struct sk_
 	if (likely(idev != NULL))
 		in6_dev_put(idev);
 out: 
-	if (tmp_saddr) kfree(tmp_saddr);
 	icmpv6_xmit_unlock();
 }
 
--- ./net/ipv6/ip6_output.c.~1~	Thu May 22 16:00:14 2003
+++ ./net/ipv6/ip6_output.c	Thu May 22 17:27:35 2003
@@ -152,15 +152,14 @@ int ip6_route_me_harder(struct sk_buff *
 {
 	struct ipv6hdr *iph = skb->nh.ipv6h;
 	struct dst_entry *dst;
-	struct flowi fl;
-
-	fl.proto = iph->nexthdr;
-	fl.fl6_dst = &iph->daddr;
-	fl.fl6_src = &iph->saddr;
-	fl.oif = skb->sk ? skb->sk->bound_dev_if : 0;
-	fl.fl6_flowlabel = 0;
-	fl.fl_ip_dport = 0;
-	fl.fl_ip_sport = 0;
+	struct flowi fl = {
+		.oif = skb->sk ? skb->sk->bound_dev_if : 0,
+		.nl_u =
+		{ .ip6_u =
+		  { .daddr = iph->daddr,
+		    .saddr = iph->saddr, } },
+		.proto = iph->nexthdr,
+	};
 
 	dst = ip6_route_output(skb->sk, &fl);
 
@@ -200,7 +199,7 @@ int ip6_xmit(struct sock *sk, struct sk_
 	     struct ipv6_txoptions *opt)
 {
 	struct ipv6_pinfo *np = sk ? inet6_sk(sk) : NULL;
-	struct in6_addr *first_hop = fl->fl6_dst;
+	struct in6_addr *first_hop = &fl->fl6_dst;
 	struct dst_entry *dst = skb->dst;
 	struct ipv6hdr *hdr;
 	u8  proto = fl->proto;
@@ -255,7 +254,7 @@ int ip6_xmit(struct sock *sk, struct sk_
 	hdr->nexthdr = proto;
 	hdr->hop_limit = hlimit;
 
-	ipv6_addr_copy(&hdr->saddr, fl->fl6_src);
+	ipv6_addr_copy(&hdr->saddr, &fl->fl6_src);
 	ipv6_addr_copy(&hdr->daddr, first_hop);
 
 	mtu = dst_pmtu(dst);
@@ -320,8 +319,8 @@ static struct ipv6hdr * ip6_bld_1(struct
 	hdr->hop_limit = hlimit;
 	hdr->nexthdr = fl->proto;
 
-	ipv6_addr_copy(&hdr->saddr, fl->fl6_src);
-	ipv6_addr_copy(&hdr->daddr, fl->fl6_dst);
+	ipv6_addr_copy(&hdr->saddr, &fl->fl6_src);
+	ipv6_addr_copy(&hdr->daddr, &fl->fl6_dst);
 	return hdr;
 }
 
@@ -526,19 +525,19 @@ int ip6_build_xmit(struct sock *sk, inet
 {
 	struct inet_opt *inet = inet_sk(sk);
 	struct ipv6_pinfo *np = inet6_sk(sk);
-	struct in6_addr *final_dst = NULL;
+	struct in6_addr final_dst_buf, *final_dst = NULL;
 	struct dst_entry *dst;
 	int err = 0;
 	unsigned int pktlength, jumbolen, mtu;
-	struct in6_addr saddr;
 
 	if (opt && opt->srcrt) {
 		struct rt0_hdr *rt0 = (struct rt0_hdr *) opt->srcrt;
-		final_dst = fl->fl6_dst;
-		fl->fl6_dst = rt0->addr;
+		ipv6_addr_copy(&final_dst_buf, &fl->fl6_dst);
+		final_dst = &final_dst_buf;
+		ipv6_addr_copy(&fl->fl6_dst, rt0->addr);
 	}
 
-	if (!fl->oif && ipv6_addr_is_multicast(fl->fl6_dst))
+	if (!fl->oif && ipv6_addr_is_multicast(&fl->fl6_dst))
 		fl->oif = np->mcast_oif;
 
 	dst = __sk_dst_check(sk, np->dst_cookie);
@@ -564,9 +563,9 @@ int ip6_build_xmit(struct sock *sk, inet
 			 */
 
 		if (((rt->rt6i_dst.plen != 128 ||
-		      ipv6_addr_cmp(fl->fl6_dst, &rt->rt6i_dst.addr))
+		      ipv6_addr_cmp(&fl->fl6_dst, &rt->rt6i_dst.addr))
 		     && (np->daddr_cache == NULL ||
-			 ipv6_addr_cmp(fl->fl6_dst, np->daddr_cache)))
+			 ipv6_addr_cmp(&fl->fl6_dst, np->daddr_cache)))
 		    || (fl->oif && fl->oif != dst->dev->ifindex)) {
 			dst = NULL;
 		} else
@@ -582,8 +581,8 @@ int ip6_build_xmit(struct sock *sk, inet
 		return -ENETUNREACH;
 	}
 
-	if (fl->fl6_src == NULL) {
-		err = ipv6_get_saddr(dst, fl->fl6_dst, &saddr);
+	if (ipv6_addr_any(&fl->fl6_src)) {
+		err = ipv6_get_saddr(dst, &fl->fl6_dst, &fl->fl6_src);
 
 		if (err) {
 #if IP6_DEBUG >= 2
@@ -592,7 +591,6 @@ int ip6_build_xmit(struct sock *sk, inet
 #endif
 			goto out;
 		}
-		fl->fl6_src = &saddr;
 	}
 	pktlength = length;
 
@@ -604,7 +602,7 @@ int ip6_build_xmit(struct sock *sk, inet
         }
 
 	if (hlimit < 0) {
-		if (ipv6_addr_is_multicast(fl->fl6_dst))
+		if (ipv6_addr_is_multicast(&fl->fl6_dst))
 			hlimit = np->mcast_hops;
 		else
 			hlimit = np->hop_limit;
@@ -715,7 +713,9 @@ int ip6_build_xmit(struct sock *sk, inet
 	 *	cleanup
 	 */
 out:
-	ip6_dst_store(sk, dst, fl->fl6_dst == &np->daddr ? &np->daddr : NULL);
+	ip6_dst_store(sk, dst,
+		      !ipv6_addr_cmp(&fl->fl6_dst, &np->daddr) ?
+		      &np->daddr : NULL);
 	if (err > 0)
 		err = np->recverr ? net_xmit_errno(err) : 0;
 	return err;
@@ -1135,7 +1135,7 @@ fail:
 	return err;
 }
 
-int ip6_dst_lookup(struct sock *sk, struct dst_entry **dst, struct flowi *fl, struct in6_addr **saddr)
+int ip6_dst_lookup(struct sock *sk, struct dst_entry **dst, struct flowi *fl)
 {
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	int err = 0;
@@ -1163,9 +1163,9 @@ int ip6_dst_lookup(struct sock *sk, stru
 			 */
 
 		if (((rt->rt6i_dst.plen != 128 ||
-		      ipv6_addr_cmp(fl->fl6_dst, &rt->rt6i_dst.addr))
+		      ipv6_addr_cmp(&fl->fl6_dst, &rt->rt6i_dst.addr))
 		     && (np->daddr_cache == NULL ||
-			 ipv6_addr_cmp(fl->fl6_dst, np->daddr_cache)))
+			 ipv6_addr_cmp(&fl->fl6_dst, np->daddr_cache)))
 		    || (fl->oif && fl->oif != (*dst)->dev->ifindex)) {
 			*dst = NULL;
 		} else
@@ -1181,9 +1181,8 @@ int ip6_dst_lookup(struct sock *sk, stru
 		return -ENETUNREACH;
 	}
 
-	if (fl->fl6_src == NULL) {
-		*saddr = kmalloc(sizeof(struct in6_addr), GFP_ATOMIC);
-		err = ipv6_get_saddr(*dst, fl->fl6_dst, *saddr);
+	if (ipv6_addr_any(&fl->fl6_src)) {
+		err = ipv6_get_saddr(*dst, &fl->fl6_dst, &fl->fl6_src);
 
 		if (err) {
 #if IP6_DEBUG >= 2
@@ -1192,7 +1191,6 @@ int ip6_dst_lookup(struct sock *sk, stru
 #endif
 			return err;
 		}
-		fl->fl6_src = *saddr;
 	}
 
         if (*dst) {
@@ -1415,7 +1413,7 @@ int ip6_push_pending_frames(struct sock 
 {
 	struct sk_buff *skb, *tmp_skb;
 	struct sk_buff **tail_skb;
-	struct in6_addr *final_dst = NULL;
+	struct in6_addr final_dst_buf, *final_dst = &final_dst_buf;
 	struct inet_opt *inet = inet_sk(sk);
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct ipv6hdr *hdr;
@@ -1446,7 +1444,7 @@ int ip6_push_pending_frames(struct sock 
 #endif
 	}
 
-	final_dst = fl->fl6_dst;
+	ipv6_addr_copy(final_dst, &fl->fl6_dst);
 	__skb_pull(skb, skb->h.raw - skb->nh.raw);
 	if (opt && opt->opt_flen)
 		ipv6_push_frag_opts(skb, opt, &proto);
@@ -1463,7 +1461,7 @@ int ip6_push_pending_frames(struct sock 
 		hdr->payload_len = 0;
 	hdr->hop_limit = np->hop_limit;
 	hdr->nexthdr = proto;
-	ipv6_addr_copy(&hdr->saddr, fl->fl6_src);
+	ipv6_addr_copy(&hdr->saddr, &fl->fl6_src);
 	ipv6_addr_copy(&hdr->daddr, final_dst);
 
 	skb->dst = dst_clone(&rt->u.dst);
--- ./net/ipv6/raw.c.~1~	Thu May 22 16:00:14 2003
+++ ./net/ipv6/raw.c	Thu May 22 16:57:18 2003
@@ -461,9 +461,9 @@ static int rawv6_push_pending_frames(str
 		 * Only one fragment on the socket.
 		 */
 		/* should be check HW csum miyazawa */
-		*csum = csum_ipv6_magic(fl->fl6_src,
-					     fl->fl6_dst,
-					     len, fl->proto, skb->csum);
+		*csum = csum_ipv6_magic(&fl->fl6_src,
+					&fl->fl6_dst,
+					len, fl->proto, skb->csum);
 	} else {
 		u32 tmp_csum = 0;
 
@@ -471,9 +471,9 @@ static int rawv6_push_pending_frames(str
 			tmp_csum = csum_add(tmp_csum, skb->csum);
 		}
 
-		tmp_csum = csum_ipv6_magic(fl->fl6_src,
-					fl->fl6_dst,
-					len, fl->proto, tmp_csum);
+		tmp_csum = csum_ipv6_magic(&fl->fl6_src,
+					   &fl->fl6_dst,
+					   len, fl->proto, tmp_csum);
 		*csum = tmp_csum;
 	}
 	if (*csum == 0)
@@ -540,7 +540,7 @@ static int rawv6_sendmsg(struct kiocb *i
 {
 	struct ipv6_txoptions opt_space;
 	struct sockaddr_in6 * sin6 = (struct sockaddr_in6 *) msg->msg_name;
-	struct in6_addr *daddr, *saddr = NULL;
+	struct in6_addr *daddr;
 	struct inet_opt *inet = inet_sk(sk);
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct raw6_opt *raw_opt = raw6_sk(sk);
@@ -566,9 +566,7 @@ static int rawv6_sendmsg(struct kiocb *i
 	/*
 	 *	Get and verify the address. 
 	 */
-
-	fl.fl6_flowlabel = 0;
-	fl.oif = 0;
+	memset(&fl, 0, sizeof(fl));
 
 	if (sin6) {
 		if (addr_len < SIN6_LEN_RFC2133) 
@@ -628,7 +626,6 @@ static int rawv6_sendmsg(struct kiocb *i
 
 	if (fl.oif == 0)
 		fl.oif = sk->bound_dev_if;
-	fl.fl6_src = NULL;
 
 	if (msg->msg_controllen) {
 		opt = &opt_space;
@@ -653,26 +650,25 @@ static int rawv6_sendmsg(struct kiocb *i
 		opt = fl6_merge_options(&opt_space, flowlabel, opt);
 
 	fl.proto = proto;
-	fl.fl6_dst = daddr;
-	if (fl.fl6_src == NULL && !ipv6_addr_any(&np->saddr))
-		fl.fl6_src = &np->saddr;
-	fl.fl_icmp_type = 0;
-	fl.fl_icmp_code = 0;
+	ipv6_addr_copy(&fl.fl6_dst, daddr);
+	if (ipv6_addr_any(&fl.fl6_src) && !ipv6_addr_any(&np->saddr))
+		ipv6_addr_copy(&fl.fl6_src, &np->saddr);
 
 	/* merge ip6_build_xmit from ip6_output */
 	if (opt && opt->srcrt) {
 		struct rt0_hdr *rt0 = (struct rt0_hdr *) opt->srcrt;
-		fl.fl6_dst = rt0->addr;
+		ipv6_addr_copy(&fl.fl6_dst, rt0->addr);
 	}
 
-	if (!fl.oif && ipv6_addr_is_multicast(fl.nl_u.ip6_u.daddr))
+	if (!fl.oif && ipv6_addr_is_multicast(&fl.fl6_dst))
 		fl.oif = np->mcast_oif;
 
-	err = ip6_dst_lookup(sk, &dst, &fl, &saddr);
-	if (err) goto out;
+	err = ip6_dst_lookup(sk, &dst, &fl);
+	if (err)
+		goto out;
 
 	if (hlimit < 0) {
-		if (ipv6_addr_is_multicast(fl.fl6_dst))
+		if (ipv6_addr_is_multicast(&fl.fl6_dst))
 			hlimit = np->mcast_hops;
 		else
 			hlimit = np->hop_limit;
@@ -702,14 +698,15 @@ back_from_confirm:
 		}
 	}
 done:
-	ip6_dst_store(sk, dst, fl.nl_u.ip6_u.daddr == &np->daddr ? &np->daddr : NULL);
+	ip6_dst_store(sk, dst,
+		      !ipv6_addr_cmp(&fl.fl6_dst, &np->daddr) ?
+		      &np->daddr : NULL);
 	if (err > 0)
 		err = np->recverr ? net_xmit_errno(err) : 0;
 
 	release_sock(sk);
 out:	
 	fl6_sock_release(flowlabel);
-	if (saddr) kfree(saddr);
 	return err<0?err:len;
 do_confirm:
 	dst_confirm(dst);
--- ./net/ipv6/udp.c.~1~	Thu May 22 16:00:14 2003
+++ ./net/ipv6/udp.c	Thu May 22 17:15:56 2003
@@ -270,7 +270,7 @@ int udpv6_connect(struct sock *sk, struc
 	if (usin->sin6_family != AF_INET6) 
 	  	return -EAFNOSUPPORT;
 
-	fl.fl6_flowlabel = 0;
+	memset(&fl, 0, sizeof(fl));
 	if (np->sndflow) {
 		fl.fl6_flowlabel = usin->sin6_flowinfo&IPV6_FLOWINFO_MASK;
 		if (fl.fl6_flowlabel&IPV6_FLOWLABEL_MASK) {
@@ -350,8 +350,8 @@ ipv4_connected:
 	 */
 
 	fl.proto = IPPROTO_UDP;
-	fl.fl6_dst = &np->daddr;
-	fl.fl6_src = &saddr;
+	ipv6_addr_copy(&fl.fl6_dst, &np->daddr);
+	ipv6_addr_copy(&fl.fl6_src, &saddr);
 	fl.oif = sk->bound_dev_if;
 	fl.fl_ip_dport = inet->dport;
 	fl.fl_ip_sport = inet->sport;
@@ -362,11 +362,11 @@ ipv4_connected:
 	if (flowlabel) {
 		if (flowlabel->opt && flowlabel->opt->srcrt) {
 			struct rt0_hdr *rt0 = (struct rt0_hdr *) flowlabel->opt->srcrt;
-			fl.fl6_dst = rt0->addr;
+			ipv6_addr_copy(&fl.fl6_dst, rt0->addr);
 		}
 	} else if (np->opt && np->opt->srcrt) {
 		struct rt0_hdr *rt0 = (struct rt0_hdr *)np->opt->srcrt;
-		fl.fl6_dst = rt0->addr;
+		ipv6_addr_copy(&fl.fl6_dst, rt0->addr);
 	}
 
 	dst = ip6_route_output(sk, &fl);
@@ -377,7 +377,7 @@ ipv4_connected:
 		return err;
 	}
 
-	ip6_dst_store(sk, dst, fl.fl6_dst);
+	ip6_dst_store(sk, dst, &fl.fl6_dst);
 
 	/* get the source address used in the appropriate device */
 
@@ -784,8 +784,8 @@ static int udp_v6_push_pending_frames(st
 	if (skb_queue_len(&sk->write_queue) == 1) {
 		skb->csum = csum_partial((char *)uh,
 				sizeof(struct udphdr), skb->csum);
-		uh->check = csum_ipv6_magic(fl->fl6_src,
-					    fl->fl6_dst,
+		uh->check = csum_ipv6_magic(&fl->fl6_src,
+					    &fl->fl6_dst,
 					    up->len, fl->proto, skb->csum);
 	} else {
 		u32 tmp_csum = 0;
@@ -795,8 +795,8 @@ static int udp_v6_push_pending_frames(st
 		}
 		tmp_csum = csum_partial((char *)uh,
 				sizeof(struct udphdr), tmp_csum);
-                tmp_csum = csum_ipv6_magic(fl->fl6_src,
-					   fl->fl6_dst,
+                tmp_csum = csum_ipv6_magic(&fl->fl6_src,
+					   &fl->fl6_dst,
 					   up->len, fl->proto, tmp_csum);
                 uh->check = tmp_csum;
 
@@ -819,7 +819,7 @@ static int udpv6_sendmsg(struct kiocb *i
 	struct inet_opt *inet = inet_sk(sk);
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct sockaddr_in6 *sin6 = (struct sockaddr_in6 *) msg->msg_name;
-	struct in6_addr *daddr, *saddr = NULL;
+	struct in6_addr *daddr;
 	struct ipv6_txoptions *opt = NULL;
 	struct ip6_flowlabel *flowlabel = NULL;
 	struct flowi fl;
@@ -849,8 +849,7 @@ static int udpv6_sendmsg(struct kiocb *i
 	}
 	ulen += sizeof(struct udphdr);
 
-	fl.fl6_flowlabel = 0;
-	fl.oif = 0;
+	memset(&fl, 0, sizeof(fl));
 
 	if (sin6) {
 		if (sin6->sin6_family == AF_INET) {
@@ -919,7 +918,6 @@ static int udpv6_sendmsg(struct kiocb *i
 
 	if (!fl.oif)
 		fl.oif = sk->bound_dev_if;
-	fl.fl6_src = NULL;
 
 	if (msg->msg_controllen) {
 		opt = &opt_space;
@@ -944,26 +942,27 @@ static int udpv6_sendmsg(struct kiocb *i
 		opt = fl6_merge_options(&opt_space, flowlabel, opt);
 
 	fl.proto = IPPROTO_UDP;
-	fl.fl6_dst = daddr;
-	if (fl.fl6_src == NULL && !ipv6_addr_any(&np->saddr))
-		fl.fl6_src = &np->saddr;
+	ipv6_addr_copy(&fl.fl6_dst, daddr);
+	if (ipv6_addr_any(&fl.fl6_src) && !ipv6_addr_any(&np->saddr))
+		ipv6_addr_copy(&fl.fl6_src, &np->saddr);
 	fl.fl_ip_dport = up->dport;
 	fl.fl_ip_sport = inet->sport;
 	
 	/* merge ip6_build_xmit from ip6_output */
 	if (opt && opt->srcrt) {
 		struct rt0_hdr *rt0 = (struct rt0_hdr *) opt->srcrt;
-		fl.fl6_dst = rt0->addr;
+		ipv6_addr_copy(&fl.fl6_dst, rt0->addr);
 	}
 
-	if (!fl.oif && ipv6_addr_is_multicast(fl.nl_u.ip6_u.daddr))
+	if (!fl.oif && ipv6_addr_is_multicast(&fl.fl6_dst))
 		fl.oif = np->mcast_oif;
 
-	err = ip6_dst_lookup(sk, &dst, &fl, &saddr);
-	if (err) goto out;
+	err = ip6_dst_lookup(sk, &dst, &fl);
+	if (err)
+		goto out;
 
 	if (hlimit < 0) {
-		if (ipv6_addr_is_multicast(fl.fl6_dst))
+		if (ipv6_addr_is_multicast(&fl.fl6_dst))
 			hlimit = np->mcast_hops;
 		else
 			hlimit = np->hop_limit;
@@ -998,13 +997,14 @@ do_append_data:
 	else if (!corkreq)
 		err = udp_v6_push_pending_frames(sk, up);
 
-	ip6_dst_store(sk, dst, fl.nl_u.ip6_u.daddr == &np->daddr ? &np->daddr : NULL);
+	ip6_dst_store(sk, dst,
+		      !ipv6_addr_cmp(&fl.fl6_dst, &np->daddr) ?
+		      &np->daddr : NULL);
 	if (err > 0)
 		err = np->recverr ? net_xmit_errno(err) : 0;
 	release_sock(sk);
 out:
 	fl6_sock_release(flowlabel);
-	if (saddr) kfree(saddr);
 	if (!err) {
 		UDP6_INC_STATS_USER(UdpOutDatagrams);
 		return len;
--- ./net/ipv6/ndisc.c.~1~	Thu May 22 16:00:14 2003
+++ ./net/ipv6/ndisc.c	Thu May 22 16:51:55 2003
@@ -405,8 +405,8 @@ static inline void ndisc_flow_init(struc
 			    struct in6_addr *saddr, struct in6_addr *daddr)
 {
 	memset(fl, 0, sizeof(*fl));
-	fl->fl6_src		= saddr;
-	fl->fl6_dst	 	= daddr;
+	ipv6_addr_copy(&fl->fl6_src, saddr);
+	ipv6_addr_copy(&fl->fl6_dst, daddr);
 	fl->proto	 	= IPPROTO_ICMPV6;
 	fl->fl_icmp_type	= type;
 	fl->fl_icmp_code	= 0;
--- ./net/ipv6/route.c.~1~	Thu May 22 16:00:14 2003
+++ ./net/ipv6/route.c	Thu May 22 16:58:35 2003
@@ -454,12 +454,12 @@ struct dst_entry * ip6_route_output(stru
 	int strict;
 	int attempts = 3;
 
-	strict = ipv6_addr_type(fl->fl6_dst) & (IPV6_ADDR_MULTICAST|IPV6_ADDR_LINKLOCAL);
+	strict = ipv6_addr_type(&fl->fl6_dst) & (IPV6_ADDR_MULTICAST|IPV6_ADDR_LINKLOCAL);
 
 relookup:
 	read_lock_bh(&rt6_lock);
 
-	fn = fib6_lookup(&ip6_routing_table, fl->fl6_dst, fl->fl6_src);
+	fn = fib6_lookup(&ip6_routing_table, &fl->fl6_dst, &fl->fl6_src);
 
 restart:
 	rt = fn->leaf;
@@ -481,7 +481,7 @@ restart:
 	if (!rt->rt6i_nexthop && !(rt->rt6i_flags & RTF_NONEXTHOP)) {
 		read_unlock_bh(&rt6_lock);
 
-		rt = rt6_cow(rt, fl->fl6_dst, fl->fl6_src);
+		rt = rt6_cow(rt, &fl->fl6_dst, &fl->fl6_src);
 
 		if (rt->u.dst.error != -EEXIST || --attempts <= 0)
 			goto out2;
@@ -1616,9 +1616,11 @@ int inet6_rtm_getroute(struct sk_buff *i
 
 	memset(&fl, 0, sizeof(fl));
 	if (rta[RTA_SRC-1])
-		fl.fl6_src = (struct in6_addr*)RTA_DATA(rta[RTA_SRC-1]);
+		ipv6_addr_copy(&fl.fl6_src,
+			       (struct in6_addr*)RTA_DATA(rta[RTA_SRC-1]));
 	if (rta[RTA_DST-1])
-		fl.fl6_dst = (struct in6_addr*)RTA_DATA(rta[RTA_DST-1]);
+		ipv6_addr_copy(&fl.fl6_dst,
+			       (struct in6_addr*)RTA_DATA(rta[RTA_DST-1]));
 
 	if (rta[RTA_IIF-1])
 		memcpy(&iif, RTA_DATA(rta[RTA_IIF-1]), sizeof(int));
@@ -1642,7 +1644,7 @@ int inet6_rtm_getroute(struct sk_buff *i
 
 	NETLINK_CB(skb).dst_pid = NETLINK_CB(in_skb).pid;
 	err = rt6_fill_node(skb, rt, 
-			    fl.fl6_dst, fl.fl6_src,
+			    &fl.fl6_dst, &fl.fl6_src,
 			    iif,
 			    RTM_NEWROUTE, NETLINK_CB(in_skb).pid,
 			    nlh->nlmsg_seq, nlh);
--- ./net/ipv6/tcp_ipv6.c.~1~	Thu May 22 16:00:14 2003
+++ ./net/ipv6/tcp_ipv6.c	Thu May 22 17:11:38 2003
@@ -571,7 +571,8 @@ static int tcp_v6_connect(struct sock *s
 	if (usin->sin6_family != AF_INET6) 
 		return(-EAFNOSUPPORT);
 
-	fl.fl6_flowlabel = 0;
+	memset(&fl, 0, sizeof(fl));
+
 	if (np->sndflow) {
 		fl.fl6_flowlabel = usin->sin6_flowinfo&IPV6_FLOWINFO_MASK;
 		IP6_ECN_flow_init(fl.fl6_flowlabel);
@@ -666,20 +667,18 @@ static int tcp_v6_connect(struct sock *s
 		saddr = &np->rcv_saddr;
 
 	fl.proto = IPPROTO_TCP;
-	fl.fl6_dst = &np->daddr;
-	fl.fl6_src = saddr;
+	ipv6_addr_copy(&fl.fl6_dst, &np->daddr);
+	ipv6_addr_copy(&fl.fl6_src,
+		       (saddr ? saddr : &np->saddr));
 	fl.oif = sk->bound_dev_if;
 	fl.fl_ip_dport = usin->sin6_port;
 	fl.fl_ip_sport = inet->sport;
 
 	if (np->opt && np->opt->srcrt) {
 		struct rt0_hdr *rt0 = (struct rt0_hdr *)np->opt->srcrt;
-		fl.fl6_dst = rt0->addr;
+		ipv6_addr_copy(&fl.fl6_dst, rt0->addr);
 	}
 
-	if (!fl.fl6_src)
-		fl.fl6_src = &np->saddr;
-
 	dst = ip6_route_output(sk, &fl);
 
 	if ((err = dst->error) != 0) {
@@ -794,9 +793,10 @@ static void tcp_v6_err(struct sk_buff *s
 			   to handle rthdr case. Ignore this complexity
 			   for now.
 			 */
+			memset(&fl, 0, sizeof(fl));
 			fl.proto = IPPROTO_TCP;
-			fl.fl6_dst = &np->daddr;
-			fl.fl6_src = &np->saddr;
+			ipv6_addr_copy(&fl.fl6_dst, &np->daddr);
+			ipv6_addr_copy(&fl.fl6_src, &np->saddr);
 			fl.oif = sk->bound_dev_if;
 			fl.fl_ip_dport = inet->dport;
 			fl.fl_ip_sport = inet->sport;
@@ -879,9 +879,10 @@ static int tcp_v6_send_synack(struct soc
 	struct flowi fl;
 	int err = -1;
 
+	memset(&fl, 0, sizeof(fl));
 	fl.proto = IPPROTO_TCP;
-	fl.fl6_dst = &req->af.v6_req.rmt_addr;
-	fl.fl6_src = &req->af.v6_req.loc_addr;
+	ipv6_addr_copy(&fl.fl6_dst, &req->af.v6_req.rmt_addr);
+	ipv6_addr_copy(&fl.fl6_src, &req->af.v6_req.loc_addr);
 	fl.fl6_flowlabel = 0;
 	fl.oif = req->af.v6_req.iif;
 	fl.fl_ip_dport = req->rmt_port;
@@ -900,7 +901,7 @@ static int tcp_v6_send_synack(struct soc
 
 		if (opt && opt->srcrt) {
 			struct rt0_hdr *rt0 = (struct rt0_hdr *) opt->srcrt;
-			fl.fl6_dst = rt0->addr;
+			ipv6_addr_copy(&fl.fl6_dst, rt0->addr);
 		}
 
 		dst = ip6_route_output(sk, &fl);
@@ -916,7 +917,7 @@ static int tcp_v6_send_synack(struct soc
 					 &req->af.v6_req.loc_addr, &req->af.v6_req.rmt_addr,
 					 csum_partial((char *)th, skb->len, skb->csum));
 
-		fl.fl6_dst = &req->af.v6_req.rmt_addr;
+		ipv6_addr_copy(&fl.fl6_dst, &req->af.v6_req.rmt_addr);
 		err = ip6_xmit(sk, skb, &fl, opt);
 		if (err == NET_XMIT_CN)
 			err = 0;
@@ -1018,11 +1019,11 @@ static void tcp_v6_send_reset(struct sk_
 
 	buff->csum = csum_partial((char *)t1, sizeof(*t1), 0);
 
-	fl.fl6_dst = &skb->nh.ipv6h->saddr;
-	fl.fl6_src = &skb->nh.ipv6h->daddr;
-	fl.fl6_flowlabel = 0;
+	memset(&fl, 0, sizeof(fl));
+	ipv6_addr_copy(&fl.fl6_dst, &skb->nh.ipv6h->saddr);
+	ipv6_addr_copy(&fl.fl6_src, &skb->nh.ipv6h->daddr);
 
-	t1->check = csum_ipv6_magic(fl.fl6_src, fl.fl6_dst, 
+	t1->check = csum_ipv6_magic(&fl.fl6_src, &fl.fl6_dst,
 				    sizeof(*t1), IPPROTO_TCP,
 				    buff->csum);
 
@@ -1082,11 +1083,11 @@ static void tcp_v6_send_ack(struct sk_bu
 
 	buff->csum = csum_partial((char *)t1, tot_len, 0);
 
-	fl.fl6_dst = &skb->nh.ipv6h->saddr;
-	fl.fl6_src = &skb->nh.ipv6h->daddr;
-	fl.fl6_flowlabel = 0;
+	memset(&fl, 0, sizeof(fl));
+	ipv6_addr_copy(&fl.fl6_dst, &skb->nh.ipv6h->saddr);
+	ipv6_addr_copy(&fl.fl6_src, &skb->nh.ipv6h->daddr);
 
-	t1->check = csum_ipv6_magic(fl.fl6_src, fl.fl6_dst, 
+	t1->check = csum_ipv6_magic(&fl.fl6_src, &fl.fl6_dst,
 				    tot_len, IPPROTO_TCP,
 				    buff->csum);
 
@@ -1261,7 +1262,6 @@ static struct sock * tcp_v6_syn_recv_soc
 {
 	struct ipv6_pinfo *newnp, *np = inet6_sk(sk);
 	struct tcp6_sock *newtcp6sk;
-	struct flowi fl;
 	struct inet_opt *newinet;
 	struct tcp_opt *newtp;
 	struct sock *newsk;
@@ -1330,14 +1330,16 @@ static struct sock * tcp_v6_syn_recv_soc
 	}
 
 	if (dst == NULL) {
+		struct flowi fl;
+
+		memset(&fl, 0, sizeof(fl));
 		fl.proto = IPPROTO_TCP;
-		fl.fl6_dst = &req->af.v6_req.rmt_addr;
+		ipv6_addr_copy(&fl.fl6_dst, &req->af.v6_req.rmt_addr);
 		if (opt && opt->srcrt) {
 			struct rt0_hdr *rt0 = (struct rt0_hdr *) opt->srcrt;
-			fl.fl6_dst = rt0->addr;
+			ipv6_addr_copy(&fl.fl6_dst, rt0->addr);
 		}
-		fl.fl6_src = &req->af.v6_req.loc_addr;
-		fl.fl6_flowlabel = 0;
+		ipv6_addr_copy(&fl.fl6_src, &req->af.v6_req.loc_addr);
 		fl.oif = sk->bound_dev_if;
 		fl.fl_ip_dport = req->rmt_port;
 		fl.fl_ip_sport = inet_sk(sk)->sport;
@@ -1725,9 +1727,10 @@ static int tcp_v6_rebuild_header(struct 
 		struct inet_opt *inet = inet_sk(sk);
 		struct flowi fl;
 
+		memset(&fl, 0, sizeof(fl));
 		fl.proto = IPPROTO_TCP;
-		fl.fl6_dst = &np->daddr;
-		fl.fl6_src = &np->saddr;
+		ipv6_addr_copy(&fl.fl6_dst, &np->daddr);
+		ipv6_addr_copy(&fl.fl6_src, &np->saddr);
 		fl.fl6_flowlabel = np->flow_label;
 		fl.oif = sk->bound_dev_if;
 		fl.fl_ip_dport = inet->dport;
@@ -1735,7 +1738,7 @@ static int tcp_v6_rebuild_header(struct 
 
 		if (np->opt && np->opt->srcrt) {
 			struct rt0_hdr *rt0 = (struct rt0_hdr *) np->opt->srcrt;
-			fl.fl6_dst = rt0->addr;
+			ipv6_addr_copy(&fl.fl6_dst, rt0->addr);
 		}
 
 		dst = ip6_route_output(sk, &fl);
@@ -1762,9 +1765,10 @@ static int tcp_v6_xmit(struct sk_buff *s
 	struct flowi fl;
 	struct dst_entry *dst;
 
+	memset(&fl, 0, sizeof(fl));
 	fl.proto = IPPROTO_TCP;
-	fl.fl6_dst = &np->daddr;
-	fl.fl6_src = &np->saddr;
+	ipv6_addr_copy(&fl.fl6_dst, &np->daddr);
+	ipv6_addr_copy(&fl.fl6_src, &np->saddr);
 	fl.fl6_flowlabel = np->flow_label;
 	IP6_ECN_flow_xmit(sk, fl.fl6_flowlabel);
 	fl.oif = sk->bound_dev_if;
@@ -1773,7 +1777,7 @@ static int tcp_v6_xmit(struct sk_buff *s
 
 	if (np->opt && np->opt->srcrt) {
 		struct rt0_hdr *rt0 = (struct rt0_hdr *) np->opt->srcrt;
-		fl.fl6_dst = rt0->addr;
+		ipv6_addr_copy(&fl.fl6_dst, rt0->addr);
 	}
 
 	dst = __sk_dst_check(sk, np->dst_cookie);
@@ -1793,7 +1797,7 @@ static int tcp_v6_xmit(struct sk_buff *s
 	skb->dst = dst_clone(dst);
 
 	/* Restore final destination back after routing done */
-	fl.fl6_dst = &np->daddr;
+	ipv6_addr_copy(&fl.fl6_dst, &np->daddr);
 
 	return ip6_xmit(sk, skb, &fl, np->opt);
 }
--- ./net/ipv6/xfrm6_policy.c.~1~	Thu May 22 16:00:14 2003
+++ ./net/ipv6/xfrm6_policy.c	Thu May 22 17:17:59 2003
@@ -60,8 +60,8 @@ __xfrm6_find_bundle(struct flowi *fl, st
 	read_lock_bh(&policy->lock);
 	for (dst = policy->bundles; dst; dst = dst->next) {
 		struct xfrm_dst *xdst = (struct xfrm_dst*)dst;
-		if (!ipv6_addr_cmp(&xdst->u.rt6.rt6i_dst.addr, fl->fl6_dst) &&
-		    !ipv6_addr_cmp(&xdst->u.rt6.rt6i_src.addr, fl->fl6_src) &&
+		if (!ipv6_addr_cmp(&xdst->u.rt6.rt6i_dst.addr, &fl->fl6_dst) &&
+		    !ipv6_addr_cmp(&xdst->u.rt6.rt6i_src.addr, &fl->fl6_src) &&
 		    __xfrm6_bundle_ok(xdst, fl)) {
 			dst_clone(dst);
 			break;
@@ -82,8 +82,8 @@ __xfrm6_bundle_create(struct xfrm_policy
 	struct dst_entry *dst, *dst_prev;
 	struct rt6_info *rt0 = (struct rt6_info*)(*dst_p);
 	struct rt6_info *rt  = rt0;
-	struct in6_addr *remote = fl->fl6_dst;
-	struct in6_addr *local  = fl->fl6_src;
+	struct in6_addr *remote = &fl->fl6_dst;
+	struct in6_addr *local  = &fl->fl6_src;
 	int i;
 	int err = 0;
 	int header_len = 0;
@@ -116,13 +116,15 @@ __xfrm6_bundle_create(struct xfrm_policy
 		trailer_len += xfrm[i]->props.trailer_len;
 	}
 
-	if (ipv6_addr_cmp(remote, fl->fl6_dst)) {
-		struct flowi fl_tunnel = { .nl_u = { .ip6_u =
-						     { .daddr = remote,
-						       .saddr = local }
-					           }
-				         };
-		err = xfrm_dst_lookup((struct xfrm_dst**)&rt, &fl_tunnel, AF_INET6);
+	if (ipv6_addr_cmp(remote, &fl->fl6_dst)) {
+		struct flowi fl_tunnel;
+
+		memset(&fl_tunnel, 0, sizeof(fl_tunnel));
+		ipv6_addr_copy(&fl_tunnel.fl6_dst, remote);
+		ipv6_addr_copy(&fl_tunnel.fl6_src, local);
+
+		err = xfrm_dst_lookup((struct xfrm_dst **) &rt,
+				      &fl_tunnel, AF_INET6);
 		if (err)
 			goto error;
 	} else {
@@ -175,8 +177,8 @@ _decode_session6(struct sk_buff *skb, st
 	struct ipv6_opt_hdr *exthdr = (struct ipv6_opt_hdr*)(skb->nh.raw + offset);
 	u8 nexthdr = skb->nh.ipv6h->nexthdr;
 
-	fl->fl6_dst = &hdr->daddr;
-	fl->fl6_src = &hdr->saddr;
+	ipv6_addr_copy(&fl->fl6_dst, &hdr->daddr);
+	ipv6_addr_copy(&fl->fl6_src, &hdr->saddr);
 
 	while (pskb_may_pull(skb, skb->nh.raw + offset + 1 - skb->data)) {
 		switch (nexthdr) {
--- ./net/ipv6/xfrm6_state.c.~1~	Thu May 22 16:00:14 2003
+++ ./net/ipv6/xfrm6_state.c	Thu May 22 17:18:24 2003
@@ -25,8 +25,8 @@ __xfrm6_init_tempsel(struct xfrm_state *
 {
 	/* Initialize temporary selector matching only
 	 * to current session. */
-	ipv6_addr_copy((struct in6_addr *)&x->sel.daddr, fl->fl6_dst);
-	ipv6_addr_copy((struct in6_addr *)&x->sel.saddr, fl->fl6_src);
+	ipv6_addr_copy((struct in6_addr *)&x->sel.daddr, &fl->fl6_dst);
+	ipv6_addr_copy((struct in6_addr *)&x->sel.saddr, &fl->fl6_src);
 	x->sel.dport = fl->fl_ip_dport;
 	x->sel.dport_mask = ~0;
 	x->sel.sport = fl->fl_ip_sport;
--- ./net/sctp/ipv6.c.~1~	Thu May 22 16:00:14 2003
+++ ./net/sctp/ipv6.c	Thu May 22 17:29:21 2003
@@ -144,17 +144,19 @@ static int sctp_v6_xmit(struct sk_buff *
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct flowi fl;
 
+	memset(&fl, 0, sizeof(fl));
+
 	fl.proto = sk->protocol;
 
 	/* Fill in the dest address from the route entry passed with the skb
 	 * and the source address from the transport.
 	 */
-	fl.fl6_dst = &transport->ipaddr.v6.sin6_addr;
-	fl.fl6_src = &transport->saddr.v6.sin6_addr;
+	ipv6_addr_copy(&fl.fl6_dst, &transport->ipaddr.v6.sin6_addr);
+	ipv6_addr_copy(&fl.fl6_src, &transport->saddr.v6.sin6_addr);
 
 	fl.fl6_flowlabel = np->flow_label;
 	IP6_ECN_flow_xmit(sk, fl.fl6_flowlabel);
-	if (ipv6_addr_type(fl.fl6_src) & IPV6_ADDR_LINKLOCAL)
+	if (ipv6_addr_type(&fl.fl6_src) & IPV6_ADDR_LINKLOCAL)
 		fl.oif = transport->saddr.v6.sin6_scope_id;
 	else
 		fl.oif = sk->bound_dev_if;
@@ -163,14 +165,14 @@ static int sctp_v6_xmit(struct sk_buff *
 
 	if (np->opt && np->opt->srcrt) {
 		struct rt0_hdr *rt0 = (struct rt0_hdr *) np->opt->srcrt;
-		fl.nl_u.ip6_u.daddr = rt0->addr;
+		ipv6_addr_copy(&fl.fl6_dst, rt0->addr);
 	}
 
 	SCTP_DEBUG_PRINTK("%s: skb:%p, len:%d, "
 			  "src:%04x:%04x:%04x:%04x:%04x:%04x:%04x:%04x "
 			  "dst:%04x:%04x:%04x:%04x:%04x:%04x:%04x:%04x\n",
 			  __FUNCTION__, skb, skb->len, 
-			  NIP6(*fl.fl6_src), NIP6(*fl.fl6_dst));
+			  NIP6(fl.fl6_src), NIP6(fl.fl6_dst));
 
 	SCTP_INC_STATS(SctpOutSCTPPacks);
 
@@ -185,17 +187,19 @@ struct dst_entry *sctp_v6_get_dst(struct
 				  union sctp_addr *saddr)
 {
 	struct dst_entry *dst;
-	struct flowi fl = {
-		.nl_u = { .ip6_u = { .daddr = &daddr->v6.sin6_addr, } } };
+	struct flowi fl;
+
+	memset(&fl, 0, sizeof(fl));
+	ipv6_addr_copy(&fl.fl6_dst, &daddr->v6.sin6_addr);
 
 	SCTP_DEBUG_PRINTK("%s: DST=%04x:%04x:%04x:%04x:%04x:%04x:%04x:%04x ",
-			  __FUNCTION__, NIP6(*fl.fl6_dst));
+			  __FUNCTION__, NIP6(fl.fl6_dst));
 
 	if (saddr) {
-		fl.fl6_src = &saddr->v6.sin6_addr;
+		ipv6_addr_copy(&fl.fl6_src, &saddr->v6.sin6_addr);
 		SCTP_DEBUG_PRINTK(
 			"SRC=%04x:%04x:%04x:%04x:%04x:%04x:%04x:%04x - ",
-			NIP6(*fl.fl6_src));
+			NIP6(fl.fl6_src));
 	}
 
 	dst = ip6_route_output(NULL, &fl);
