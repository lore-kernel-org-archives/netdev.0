From: Kazunori Miyazawa <kazunori@miyazawa.org>
Subject: [PATCH][IPv6] separation xfrm_lookup from ip6_dst_lookup
Date: Fri, 30 Jul 2004 17:12:05 +0900
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040730171205.114f22ba.kazunori@miyazawa.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, usagi-core@linux-ipv6.org, kazunori@miyazawa.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com, herbert@gondor.apana.org.au
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello,

This patch separates xfrm_lookup from ip6_dst_lookup
to support srcrt correctly. ip6_dst_lookup should be
called with next hop. however xfrm_lookup should be
called with final destination. It fixes them.

This patch makes AH support routing header with
previous Mr Hervert's patch. Of course this fixes ESP and IPcomp.

I consider copying flowi(fl_rt) uses too much stack at the moment.
I'll re-send the fixed patch again.

Thank you,

--Kazunori Miyazawa


diff -ruNBE a/net/ipv6/datagram.c b/net/ipv6/datagram.c
--- a/net/ipv6/datagram.c	2004-07-28 10:07:16.000000000 +0900
+++ b/net/ipv6/datagram.c	2004-07-28 10:29:13.000000000 +0900
@@ -40,7 +40,7 @@
 	struct ipv6_pinfo      	*np = inet6_sk(sk);
 	struct in6_addr		*daddr;
 	struct dst_entry	*dst;
-	struct flowi		fl;
+	struct flowi		fl, fl_rt, *flp = &fl;
 	struct ip6_flowlabel	*flowlabel = NULL;
 	int			addr_type;
 	int			err;
@@ -157,17 +157,27 @@
 	if (flowlabel) {
 		if (flowlabel->opt && flowlabel->opt->srcrt) {
 			struct rt0_hdr *rt0 = (struct rt0_hdr *) flowlabel->opt->srcrt;
-			ipv6_addr_copy(&fl.fl6_dst, rt0->addr);
+			memcpy(&fl_rt, &fl, sizeof(fl_rt));
+			ipv6_addr_copy(&fl_rt.fl6_dst, rt0->addr);
+			flp = &fl_rt;
 		}
 	} else if (np->opt && np->opt->srcrt) {
 		struct rt0_hdr *rt0 = (struct rt0_hdr *)np->opt->srcrt;
-		ipv6_addr_copy(&fl.fl6_dst, rt0->addr);
+		memcpy(&fl_rt, &fl, sizeof(fl_rt));
+		ipv6_addr_copy(&fl_rt.fl6_dst, rt0->addr);
+		flp = &fl_rt;
 	}
 
-	err = ip6_dst_lookup(sk, &dst, &fl);
+	err = ip6_dst_lookup(sk, &dst, flp);
 	if (err)
 		goto out;
 
+	if ((err = xfrm_lookup(&dst, &fl, sk, 0)) < 0) {
+		dst_release(dst);
+		dst = NULL;
+		goto out;
+	}
+
 	/* source address lookup done in ip6_dst_lookup */
 
 	if (ipv6_addr_any(&np->saddr))
diff -ruNBE a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
--- a/net/ipv6/ip6_output.c	2004-07-28 10:07:09.000000000 +0900
+++ b/net/ipv6/ip6_output.c	2004-07-28 10:29:20.000000000 +0900
@@ -796,10 +796,6 @@
 			goto out_err_release;
 		}
 	}
-	if ((err = xfrm_lookup(dst, fl, sk, 0)) < 0) {
-		err = -ENETUNREACH;
-		goto out_err_release;
-        }
 
 	return 0;
 
diff -ruNBE a/net/ipv6/raw.c b/net/ipv6/raw.c
--- a/net/ipv6/raw.c	2004-07-28 10:08:26.000000000 +0900
+++ b/net/ipv6/raw.c	2004-07-28 10:30:22.000000000 +0900
@@ -567,7 +567,7 @@
 	struct ipv6_txoptions *opt = NULL;
 	struct ip6_flowlabel *flowlabel = NULL;
 	struct dst_entry *dst = NULL;
-	struct flowi fl;
+	struct flowi fl, fl_rt, *flp = &fl;
 	int addr_len = msg->msg_namelen;
 	int hlimit = -1;
 	u16 proto;
@@ -674,6 +674,7 @@
 		opt = fl6_merge_options(&opt_space, flowlabel, opt);
 
 	fl.proto = proto;
+ 
 	ipv6_addr_copy(&fl.fl6_dst, daddr);
 	if (ipv6_addr_any(&fl.fl6_src) && !ipv6_addr_any(&np->saddr))
 		ipv6_addr_copy(&fl.fl6_src, &np->saddr);
@@ -681,16 +682,24 @@
 	/* merge ip6_build_xmit from ip6_output */
 	if (opt && opt->srcrt) {
 		struct rt0_hdr *rt0 = (struct rt0_hdr *) opt->srcrt;
-		ipv6_addr_copy(&fl.fl6_dst, rt0->addr);
+		memcpy(&fl_rt, &fl, sizeof(fl_rt));
+		ipv6_addr_copy(&fl_rt.fl6_dst, rt0->addr);
+		flp = &fl_rt;
 	}
 
 	if (!fl.oif && ipv6_addr_is_multicast(&fl.fl6_dst))
 		fl.oif = np->mcast_oif;
 
-	err = ip6_dst_lookup(sk, &dst, &fl);
+	err = ip6_dst_lookup(sk, &dst, flp);
 	if (err)
 		goto out;
 
+	if ((err = xfrm_lookup(&dst, &fl, sk, 0)) < 0) {
+		dst_release(dst);
+		dst = NULL;
+		goto out;
+	}
+
 	if (hlimit < 0) {
 		if (ipv6_addr_is_multicast(&fl.fl6_dst))
 			hlimit = np->mcast_hops;
diff -ruNBE a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
--- a/net/ipv6/tcp_ipv6.c	2004-07-28 10:09:10.000000000 +0900
+++ b/net/ipv6/tcp_ipv6.c	2004-07-28 10:29:37.000000000 +0900
@@ -550,7 +550,7 @@
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct tcp_opt *tp = tcp_sk(sk);
 	struct in6_addr *saddr = NULL;
-	struct flowi fl;
+	struct flowi fl, fl_rt, *flp = &fl;
 	struct dst_entry *dst;
 	int addr_type;
 	int err;
@@ -666,14 +666,21 @@
 
 	if (np->opt && np->opt->srcrt) {
 		struct rt0_hdr *rt0 = (struct rt0_hdr *)np->opt->srcrt;
-		ipv6_addr_copy(&fl.fl6_dst, rt0->addr);
+		memcpy(&fl_rt, &fl, sizeof(fl_rt));
+		ipv6_addr_copy(&fl_rt.fl6_dst, rt0->addr);
+		flp = &fl_rt;
 	}
 
-	err = ip6_dst_lookup(sk, &dst, &fl);
-
+	err = ip6_dst_lookup(sk, &dst, flp);
 	if (err)
 		goto failure;
 
+	if ((err = xfrm_lookup(&dst, &fl, sk, 0)) < 0) {
+		dst_release(dst);
+		dst = NULL;
+		goto failure;
+	}
+
 	if (saddr == NULL) {
 		saddr = &fl.fl6_src;
 		ipv6_addr_copy(&np->rcv_saddr, saddr);
@@ -793,6 +800,14 @@
 				sk->sk_err_soft = -err;
 				goto out;
 			}
+
+			if ((err = xfrm_lookup(&dst, &fl, sk, 0)) < 0) {
+				sk->sk_err_soft = -err;
+				dst_release(dst);
+				dst = NULL;
+				goto out;
+			}
+
 		} else
 			dst_hold(dst);
 
@@ -863,7 +878,7 @@
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct sk_buff * skb;
 	struct ipv6_txoptions *opt = NULL;
-	struct flowi fl;
+	struct flowi fl, fl_rt, *flp = &fl;
 	int err = -1;
 
 	memset(&fl, 0, sizeof(fl));
@@ -888,12 +903,22 @@
 
 		if (opt && opt->srcrt) {
 			struct rt0_hdr *rt0 = (struct rt0_hdr *) opt->srcrt;
-			ipv6_addr_copy(&fl.fl6_dst, rt0->addr);
+			memcpy(&fl_rt, &fl, sizeof(fl_rt));
+			ipv6_addr_copy(&fl_rt.fl6_dst, rt0->addr);
+			flp = &fl_rt;
 		}
 
-		err = ip6_dst_lookup(sk, &dst, &fl);
+		err = ip6_dst_lookup(sk, &dst, flp);
 		if (err)
 			goto done;
+
+		if ((err = xfrm_lookup(&dst, &fl, sk, 0)) < 0) {
+			dst_release(dst);
+			dst = NULL;
+			goto done;
+		}
+
+
 	}
 
 	skb = tcp_make_synack(sk, dst, req);
@@ -1021,6 +1046,12 @@
 
 	/* sk = NULL, but it is safe for now. RST socket required. */
 	if (!ip6_dst_lookup(NULL, &buff->dst, &fl)) {
+
+		if ((xfrm_lookup(&buff->dst, &fl, NULL, 0)) < 0) {
+			dst_release(buff->dst);
+			return;
+		}
+
 		ip6_xmit(NULL, buff, &fl, NULL, 0);
 		TCP_INC_STATS_BH(TCP_MIB_OUTSEGS);
 		TCP_INC_STATS_BH(TCP_MIB_OUTRSTS);
@@ -1082,6 +1113,12 @@
 	fl.fl_ip_sport = t1->source;
 
 	if (!ip6_dst_lookup(NULL, &buff->dst, &fl)) {
+
+		if ((xfrm_lookup(&buff->dst, &fl, NULL, 0)) < 0) {
+			dst_release(buff->dst);
+			return;
+		}
+
 		ip6_xmit(NULL, buff, &fl, NULL, 0);
 		TCP_INC_STATS_BH(TCP_MIB_OUTSEGS);
 		return;
@@ -1313,22 +1350,31 @@
 	}
 
 	if (dst == NULL) {
-		struct flowi fl;
+		struct flowi fl, fl_rt, *flp = &fl;
 
 		memset(&fl, 0, sizeof(fl));
 		fl.proto = IPPROTO_TCP;
 		ipv6_addr_copy(&fl.fl6_dst, &req->af.v6_req.rmt_addr);
 		if (opt && opt->srcrt) {
 			struct rt0_hdr *rt0 = (struct rt0_hdr *) opt->srcrt;
-			ipv6_addr_copy(&fl.fl6_dst, rt0->addr);
+			memcpy(&fl_rt, &fl, sizeof(fl_rt));
+			ipv6_addr_copy(&fl_rt.fl6_dst, rt0->addr);
+			flp = &fl_rt;
 		}
 		ipv6_addr_copy(&fl.fl6_src, &req->af.v6_req.loc_addr);
 		fl.oif = sk->sk_bound_dev_if;
 		fl.fl_ip_dport = req->rmt_port;
 		fl.fl_ip_sport = inet_sk(sk)->sport;
 
-		if (ip6_dst_lookup(sk, &dst, &fl))
+		if (ip6_dst_lookup(sk, &dst, flp))
 			goto out;
+
+		if ((xfrm_lookup(&dst, &fl, sk, 0)) < 0) {
+			dst_release(dst);
+			dst = NULL;
+			goto out;
+		}
+
 	} 
 
 	newsk = tcp_create_openreq_child(sk, req, skb);
@@ -1710,7 +1756,7 @@
 
 	if (dst == NULL) {
 		struct inet_opt *inet = inet_sk(sk);
-		struct flowi fl;
+		struct flowi fl, fl_rt, *flp = &fl;
 
 		memset(&fl, 0, sizeof(fl));
 		fl.proto = IPPROTO_TCP;
@@ -1723,16 +1769,25 @@
 
 		if (np->opt && np->opt->srcrt) {
 			struct rt0_hdr *rt0 = (struct rt0_hdr *) np->opt->srcrt;
-			ipv6_addr_copy(&fl.fl6_dst, rt0->addr);
+			memcpy(&fl_rt, &fl, sizeof(fl_rt));
+			ipv6_addr_copy(&fl_rt.fl6_dst, rt0->addr);
+			flp = &fl_rt;
 		}
 
-		err = ip6_dst_lookup(sk, &dst, &fl);
+		err = ip6_dst_lookup(sk, &dst, flp);
 
 		if (err) {
 			sk->sk_route_caps = 0;
 			return err;
 		}
 
+		if ((err = xfrm_lookup(&dst, &fl, sk, 0)) < 0) {
+			sk->sk_route_caps = 0;
+			dst_release(dst);
+			return err;
+		}
+
+
 		ip6_dst_store(sk, dst, NULL);
 		sk->sk_route_caps = dst->dev->features &
 			~(NETIF_F_IP_CSUM | NETIF_F_TSO);
@@ -1747,7 +1802,7 @@
 	struct sock *sk = skb->sk;
 	struct inet_opt *inet = inet_sk(sk);
 	struct ipv6_pinfo *np = inet6_sk(sk);
-	struct flowi fl;
+	struct flowi fl, fl_rt, *flp = &fl;
 	struct dst_entry *dst;
 
 	memset(&fl, 0, sizeof(fl));
@@ -1762,19 +1817,27 @@
 
 	if (np->opt && np->opt->srcrt) {
 		struct rt0_hdr *rt0 = (struct rt0_hdr *) np->opt->srcrt;
-		ipv6_addr_copy(&fl.fl6_dst, rt0->addr);
+		memcpy(&fl_rt, &fl, sizeof(fl_rt));
+		ipv6_addr_copy(&fl_rt.fl6_dst, rt0->addr);
+		flp = &fl_rt;
 	}
 
 	dst = __sk_dst_check(sk, np->dst_cookie);
 
 	if (dst == NULL) {
-		int err = ip6_dst_lookup(sk, &dst, &fl);
+		int err = ip6_dst_lookup(sk, &dst, flp);
 
 		if (err) {
 			sk->sk_err_soft = -err;
 			return err;
 		}
 
+		if ((err = xfrm_lookup(&dst, &fl, sk, 0)) < 0) {
+			sk->sk_err_soft = -err;
+			dst_release(dst);
+			return err;
+		}
+
 		ip6_dst_store(sk, dst, NULL);
 		sk->sk_route_caps = dst->dev->features &
 			~(NETIF_F_IP_CSUM | NETIF_F_TSO);
diff -ruNBE a/net/ipv6/udp.c b/net/ipv6/udp.c
--- a/net/ipv6/udp.c	2004-07-28 10:10:23.000000000 +0900
+++ b/net/ipv6/udp.c	2004-07-28 10:29:41.000000000 +0900
@@ -630,13 +630,13 @@
 	struct in6_addr *daddr;
 	struct ipv6_txoptions *opt = NULL;
 	struct ip6_flowlabel *flowlabel = NULL;
-	struct flowi *fl = &inet->cork.fl;
-	struct dst_entry *dst;
+	struct flowi *fl = &inet->cork.fl, fl_rt, *flp = fl;
+	struct dst_entry *dst = NULL;
 	int addr_len = msg->msg_namelen;
 	int ulen = len;
 	int hlimit = -1;
 	int corkreq = up->corkflag || msg->msg_flags&MSG_MORE;
-	int err;
+	int err = 0;
 
 	/* destination address check */
 	if (sin6) {
@@ -779,20 +779,28 @@
 	if (ipv6_addr_any(&fl->fl6_src) && !ipv6_addr_any(&np->saddr))
 		ipv6_addr_copy(&fl->fl6_src, &np->saddr);
 	fl->fl_ip_sport = inet->sport;
-	
+
 	/* merge ip6_build_xmit from ip6_output */
 	if (opt && opt->srcrt) {
 		struct rt0_hdr *rt0 = (struct rt0_hdr *) opt->srcrt;
-		ipv6_addr_copy(&fl->fl6_dst, rt0->addr);
+		memcpy(&fl_rt, &fl, sizeof(fl_rt));
+		ipv6_addr_copy(&fl_rt.fl6_dst, rt0->addr);
+		flp = &fl_rt;
 	}
 
 	if (!fl->oif && ipv6_addr_is_multicast(&fl->fl6_dst))
 		fl->oif = np->mcast_oif;
 
-	err = ip6_dst_lookup(sk, &dst, fl);
+	err = ip6_dst_lookup(sk, &dst, flp);
 	if (err)
 		goto out;
 
+	if ((err = xfrm_lookup(&dst, fl, sk, 0)) < 0) {
+		dst_release(dst);
+		dst = NULL;
+		goto out;
+	}
+
 	if (hlimit < 0) {
 		if (ipv6_addr_is_multicast(&fl->fl6_dst))
 			hlimit = np->mcast_hops;
