From: Kazunori Miyazawa <kazunori@miyazawa.org>
Subject: [PATCH][IPV6] fixed authentication error with TCP
Date: Wed, 6 Aug 2003 16:44:13 +0900
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030806164413.669ef5f8.kazunori@miyazawa.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, usagi@linux-ipv6.org, latten@austin.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com, kuznet@ms2.inr.ac.ru
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello,

Miss Joy (@IBM) and I investigated the bug that "authentication error" occured with
using TCP and AH in IPv6. This patch fixes the bug. This patch makes the kernel consider
extension header length in a dst.

This pach works with my previous patch which fixes zero-clear in ah6_input.

Please append the name "Joy Latten" into the log.

#I'm in summer holidays until 10th August. I will response very slowly because I only have
 dial-up line with 30kbps :-p

Best regards,

diff -ruN a/include/net/ipv6.h b/include/net/ipv6.h
--- a/include/net/ipv6.h	2003-07-28 02:07:24.000000000 +0900
+++ b/include/net/ipv6.h	2003-08-06 14:10:36.000000000 +0900
@@ -353,9 +353,7 @@
 
 extern void			ip6_flush_pending_frames(struct sock *sk);
 
-extern int			ip6_dst_lookup(struct sock *sk,
-					       struct dst_entry **dst,
-					       struct flowi *fl);
+extern struct dst_entry *	ip6_dst_lookup(struct sock *sk, struct flowi *fl);
 
 /*
  *	skb processing functions
diff -ruN a/net/ipv6/icmp.c b/net/ipv6/icmp.c
--- a/net/ipv6/icmp.c	2003-07-28 01:59:40.000000000 +0900
+++ b/net/ipv6/icmp.c	2003-08-06 14:20:29.000000000 +0900
@@ -355,8 +355,8 @@
 	if (!fl.oif && ipv6_addr_is_multicast(&fl.fl6_dst))
 		fl.oif = np->mcast_oif;
 
-	err = ip6_dst_lookup(sk, &dst, &fl);
-	if (err) goto out;
+	dst = ip6_dst_lookup(sk, &fl);
+	if (dst->error) goto out;
 
 	if (hlimit < 0) {
 		if (ipv6_addr_is_multicast(&fl.fl6_dst))
@@ -434,9 +434,9 @@
 	if (!fl.oif && ipv6_addr_is_multicast(&fl.fl6_dst))
 		fl.oif = np->mcast_oif;
 
-	err = ip6_dst_lookup(sk, &dst, &fl);
+	dst = ip6_dst_lookup(sk, &fl);
 
-	if (err) goto out;
+	if (dst->error) goto out;
 
 	if (hlimit < 0) {
 		if (ipv6_addr_is_multicast(&fl.fl6_dst))
diff -ruN a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
--- a/net/ipv6/ip6_output.c	2003-07-28 01:57:01.000000000 +0900
+++ b/net/ipv6/ip6_output.c	2003-08-06 15:35:23.000000000 +0900
@@ -211,10 +211,6 @@
 	u32 mtu;
 	int err = 0;
 
-	if ((err = xfrm_lookup(&skb->dst, fl, sk, 0)) < 0) {
-		return err;
-	}
-
 	if (opt) {
 		int head_room;
 
@@ -1141,72 +1137,73 @@
 	return err;
 }
 
-int ip6_dst_lookup(struct sock *sk, struct dst_entry **dst, struct flowi *fl)
+struct dst_entry *ip6_dst_lookup(struct sock *sk, struct flowi *fl)
 {
-	struct ipv6_pinfo *np = inet6_sk(sk);
+	struct dst_entry *dst = NULL;
 	int err = 0;
 
-	*dst = __sk_dst_check(sk, np->dst_cookie);
-	if (*dst) {
-		struct rt6_info *rt = (struct rt6_info*)*dst;
-
-			/* Yes, checking route validity in not connected
-			   case is not very simple. Take into account,
-			   that we do not support routing by source, TOS,
-			   and MSG_DONTROUTE 		--ANK (980726)
-
-			   1. If route was host route, check that
-			      cached destination is current.
-			      If it is network route, we still may
-			      check its validity using saved pointer
-			      to the last used address: daddr_cache.
-			      We do not want to save whole address now,
-			      (because main consumer of this service
-			       is tcp, which has not this problem),
-			      so that the last trick works only on connected
-			      sockets.
-			   2. oif also should be the same.
-			 */
-
-		if (((rt->rt6i_dst.plen != 128 ||
-		      ipv6_addr_cmp(&fl->fl6_dst, &rt->rt6i_dst.addr))
-		     && (np->daddr_cache == NULL ||
-			 ipv6_addr_cmp(&fl->fl6_dst, np->daddr_cache)))
-		    || (fl->oif && fl->oif != (*dst)->dev->ifindex)) {
-			*dst = NULL;
-		} else
-			dst_hold(*dst);
+	if (sk) {
+		struct ipv6_pinfo *np = inet6_sk(sk);
+	
+		dst = __sk_dst_check(sk, np->dst_cookie);
+		if (dst) {
+			struct rt6_info *rt = (struct rt6_info*)dst;
+	
+				/* Yes, checking route validity in not connected
+				   case is not very simple. Take into account,
+				   that we do not support routing by source, TOS,
+				   and MSG_DONTROUTE 		--ANK (980726)
+	
+				   1. If route was host route, check that
+				      cached destination is current.
+				      If it is network route, we still may
+				      check its validity using saved pointer
+				      to the last used address: daddr_cache.
+				      We do not want to save whole address now,
+				      (because main consumer of this service
+				       is tcp, which has not this problem),
+				      so that the last trick works only on connected
+				      sockets.
+				   2. oif also should be the same.
+				 */
+	
+			if (((rt->rt6i_dst.plen != 128 ||
+			      ipv6_addr_cmp(&fl->fl6_dst, &rt->rt6i_dst.addr))
+			     && (np->daddr_cache == NULL ||
+				 ipv6_addr_cmp(&fl->fl6_dst, np->daddr_cache)))
+			    || (fl->oif && fl->oif != dst->dev->ifindex)) {
+				dst = NULL;
+			} else
+				dst_hold(dst);
+		}
 	}
 
-	if (*dst == NULL)
-		*dst = ip6_route_output(sk, fl);
+	if (dst == NULL)
+		dst = ip6_route_output(sk, fl);
 
-	if ((*dst)->error) {
-		IP6_INC_STATS(Ip6OutNoRoutes);
-		dst_release(*dst);
-		return -ENETUNREACH;
-	}
+	if (dst->error)
+		return dst;
 
 	if (ipv6_addr_any(&fl->fl6_src)) {
-		err = ipv6_get_saddr(*dst, &fl->fl6_dst, &fl->fl6_src);
+		err = ipv6_get_saddr(dst, &fl->fl6_dst, &fl->fl6_src);
 
 		if (err) {
 #if IP6_DEBUG >= 2
 			printk(KERN_DEBUG "ip6_build_xmit: "
 			       "no available source address\n");
 #endif
-			return err;
+			dst->error = err;
+			return dst;
 		}
 	}
 
-        if (*dst) {
-		if ((err = xfrm_lookup(dst, fl, sk, 0)) < 0) {
-			dst_release(*dst);	
-			return -ENETUNREACH;
+        if (dst) {
+		if ((err = xfrm_lookup(&dst, fl, sk, 0)) < 0) {
+			dst->error = -ENETUNREACH;
 		}
         }
 
-	return 0;
+	return dst;
 }
 
 int ip6_append_data(struct sock *sk, int getfrag(void *from, char *to, int offset, int len, int odd, struct sk_buff *skb),
diff -ruN a/net/ipv6/raw.c b/net/ipv6/raw.c
--- a/net/ipv6/raw.c	2003-07-28 02:00:40.000000000 +0900
+++ b/net/ipv6/raw.c	2003-08-06 14:19:32.000000000 +0900
@@ -658,8 +658,8 @@
 	if (!fl.oif && ipv6_addr_is_multicast(&fl.fl6_dst))
 		fl.oif = np->mcast_oif;
 
-	err = ip6_dst_lookup(sk, &dst, &fl);
-	if (err)
+	dst = ip6_dst_lookup(sk, &fl);
+	if (dst->error)
 		goto out;
 
 	if (hlimit < 0) {
diff -ruN a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
--- a/net/ipv6/tcp_ipv6.c	2003-07-28 02:03:09.000000000 +0900
+++ b/net/ipv6/tcp_ipv6.c	2003-08-06 16:13:21.000000000 +0900
@@ -663,7 +663,7 @@
 		ipv6_addr_copy(&fl.fl6_dst, rt0->addr);
 	}
 
-	dst = ip6_route_output(sk, &fl);
+	dst = ip6_dst_lookup(sk, &fl);
 
 	if ((err = dst->error) != 0) {
 		dst_release(dst);
@@ -691,6 +691,8 @@
 	tp->ext_header_len = 0;
 	if (np->opt)
 		tp->ext_header_len = np->opt->opt_flen + np->opt->opt_nflen;
+	tp->ext2_header_len = dst->header_len;
+
 	tp->mss_clamp = IPV6_MIN_MTU - sizeof(struct tcphdr) - sizeof(struct ipv6hdr);
 
 	inet->dport = usin->sin6_port;
@@ -788,7 +790,7 @@
 			fl.fl_ip_dport = inet->dport;
 			fl.fl_ip_sport = inet->sport;
 
-			dst = ip6_route_output(sk, &fl);
+			dst = ip6_dst_lookup(sk, &fl);
 		} else
 			dst_hold(dst);
 
@@ -889,7 +891,7 @@
 			ipv6_addr_copy(&fl.fl6_dst, rt0->addr);
 		}
 
-		dst = ip6_route_output(sk, &fl);
+		dst = ip6_dst_lookup(sk, &fl);
 		if (dst->error)
 			goto done;
 	}
@@ -1018,7 +1020,7 @@
 	fl.fl_ip_sport = t1->source;
 
 	/* sk = NULL, but it is safe for now. RST socket required. */
-	buff->dst = ip6_route_output(NULL, &fl);
+	buff->dst = ip6_dst_lookup(NULL, &fl);
 
 	if (buff->dst->error == 0) {
 		ip6_xmit(NULL, buff, &fl, NULL, 0);
@@ -1081,7 +1083,7 @@
 	fl.fl_ip_dport = t1->dest;
 	fl.fl_ip_sport = t1->source;
 
-	buff->dst = ip6_route_output(NULL, &fl);
+	buff->dst = ip6_dst_lookup(NULL, &fl);
 
 	if (buff->dst->error == 0) {
 		ip6_xmit(NULL, buff, &fl, NULL, 0);
@@ -1329,7 +1331,7 @@
 		fl.fl_ip_dport = req->rmt_port;
 		fl.fl_ip_sport = inet_sk(sk)->sport;
 
-		dst = ip6_route_output(sk, &fl);
+		dst = ip6_dst_lookup(sk, &fl);
 	}
 
 	if (dst->error)
@@ -1401,6 +1403,7 @@
 	if (newnp->opt)
 		newtp->ext_header_len = newnp->opt->opt_nflen +
 					newnp->opt->opt_flen;
+	newtp->ext2_header_len = dst->header_len;
 
 	tcp_sync_mss(newsk, dst_pmtu(dst));
 	newtp->advmss = dst_metric(dst, RTAX_ADVMSS);
@@ -1727,7 +1730,7 @@
 			ipv6_addr_copy(&fl.fl6_dst, rt0->addr);
 		}
 
-		dst = ip6_route_output(sk, &fl);
+		dst = ip6_dst_lookup(sk, &fl);
 
 		if (dst->error) {
 			err = dst->error;
@@ -1770,7 +1773,7 @@
 	dst = __sk_dst_check(sk, np->dst_cookie);
 
 	if (dst == NULL) {
-		dst = ip6_route_output(sk, &fl);
+		dst = ip6_dst_lookup(sk, &fl);
 
 		if (dst->error) {
 			sk->sk_err_soft = -dst->error;
diff -ruN a/net/ipv6/udp.c b/net/ipv6/udp.c
--- a/net/ipv6/udp.c	2003-07-28 02:07:29.000000000 +0900
+++ b/net/ipv6/udp.c	2003-08-06 14:19:23.000000000 +0900
@@ -928,8 +928,8 @@
 	if (!fl.oif && ipv6_addr_is_multicast(&fl.fl6_dst))
 		fl.oif = np->mcast_oif;
 
-	err = ip6_dst_lookup(sk, &dst, &fl);
-	if (err)
+	dst = ip6_dst_lookup(sk, &fl);
+	if (dst->error)
 		goto out;
 
 	if (hlimit < 0) {
