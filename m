From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: [PATCH] [NET] use fl6_{src,dst} etc.
Date: Tue, 15 Apr 2003 02:31:58 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030415.023158.36869337.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, usagi@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com, kuznet@ms2.inr.ac.ru
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

This cleans up usage of members in flowi{}; use fl6_{src,dst} etc.
Patch is against linux-2.5.67 + Changeset 1.1202.
(I think this change is suitable for linux-2.4 but I haven't prepared patch 
againt it.)

Thanks.

Index: include/net/flow.h
===================================================================
RCS file: /cvsroot/usagi/usagi-backport/linux25/include/net/flow.h,v
retrieving revision 1.1.1.2
retrieving revision 1.1.1.2.58.1
diff -u -r1.1.1.2 -r1.1.1.2.58.1
--- include/net/flow.h	16 Oct 2002 04:25:20 -0000	1.1.1.2
+++ include/net/flow.h	14 Apr 2003 14:42:49 -0000	1.1.1.2.58.1
@@ -52,4 +52,8 @@
 	} uli_u;
 };
 
+#define fl_sport	uli_u.ports.sport
+#define fl_dport	uli_u.ports.dport
+#define fl_type		uli_u.icmpt.type
+#define fl_code		uli_u.icmpt.code
 #endif
Index: net/ipv6/datagram.c
===================================================================
RCS file: /cvsroot/usagi/usagi-backport/linux25/net/ipv6/datagram.c,v
retrieving revision 1.1.1.3
retrieving revision 1.1.1.3.54.1
diff -u -r1.1.1.3 -r1.1.1.3.54.1
--- net/ipv6/datagram.c	30 Oct 2002 09:43:18 -0000	1.1.1.3
+++ net/ipv6/datagram.c	14 Apr 2003 15:42:43 -0000	1.1.1.3.54.1
@@ -91,7 +91,7 @@
 	serr->ee.ee_info = info;
 	serr->ee.ee_data = 0;
 	serr->addr_offset = (u8*)&iph->daddr - skb->nh.raw;
-	serr->port = fl->uli_u.ports.dport;
+	serr->port = fl->fl_dport;
 
 	skb->h.raw = skb->tail;
 	__skb_pull(skb, skb->tail - skb->data);
Index: net/ipv6/icmp.c
===================================================================
RCS file: /cvsroot/usagi/usagi-backport/linux25/net/ipv6/icmp.c,v
retrieving revision 1.1.1.9
retrieving revision 1.1.1.9.10.1
diff -u -r1.1.1.9 -r1.1.1.9.10.1
--- net/ipv6/icmp.c	25 Mar 2003 04:33:45 -0000	1.1.1.9
+++ net/ipv6/icmp.c	14 Apr 2003 14:42:49 -0000	1.1.1.9.10.1
@@ -312,12 +312,12 @@
 	}
 
 	fl.proto = IPPROTO_ICMPV6;
-	fl.nl_u.ip6_u.daddr = &hdr->saddr;
-	fl.nl_u.ip6_u.saddr = saddr;
+	fl.fl6_dst = &hdr->saddr;
+	fl.fl6_src = saddr;
 	fl.oif = iif;
 	fl.fl6_flowlabel = 0;
-	fl.uli_u.icmpt.type = type;
-	fl.uli_u.icmpt.code = code;
+	fl.fl_type = type;
+	fl.fl_code = code;
 
 	icmpv6_xmit_lock();
 
@@ -386,12 +386,12 @@
 	msg.daddr =  &skb->nh.ipv6h->saddr;
 
 	fl.proto = IPPROTO_ICMPV6;
-	fl.nl_u.ip6_u.daddr = msg.daddr;
-	fl.nl_u.ip6_u.saddr = saddr;
+	fl.fl6_dst = msg.daddr;
+	fl.fl6_src = saddr;
 	fl.oif = skb->dev->ifindex;
 	fl.fl6_flowlabel = 0;
-	fl.uli_u.icmpt.type = ICMPV6_ECHO_REPLY;
-	fl.uli_u.icmpt.code = 0;
+	fl.fl_type = ICMPV6_ECHO_REPLY;
+	fl.fl_code = 0;
 
 	icmpv6_xmit_lock();
 
Index: net/ipv6/ip6_output.c
===================================================================
RCS file: /cvsroot/usagi/usagi-backport/linux25/net/ipv6/ip6_output.c,v
retrieving revision 1.1.1.8
retrieving revision 1.1.1.8.8.2
diff -u -r1.1.1.8 -r1.1.1.8.8.2
--- net/ipv6/ip6_output.c	2 Apr 2003 04:16:14 -0000	1.1.1.8
+++ net/ipv6/ip6_output.c	14 Apr 2003 15:42:43 -0000	1.1.1.8.8.2
@@ -146,8 +146,8 @@
 	fl.fl6_src = &iph->saddr;
 	fl.oif = skb->sk ? skb->sk->bound_dev_if : 0;
 	fl.fl6_flowlabel = 0;
-	fl.uli_u.ports.dport = 0;
-	fl.uli_u.ports.sport = 0;
+	fl.fl_dport = 0;
+	fl.fl_sport = 0;
 
 	dst = ip6_route_output(skb->sk, &fl);
 
@@ -186,7 +186,7 @@
 	     struct ipv6_txoptions *opt)
 {
 	struct ipv6_pinfo *np = sk ? inet6_sk(sk) : NULL;
-	struct in6_addr *first_hop = fl->nl_u.ip6_u.daddr;
+	struct in6_addr *first_hop = fl->fl6_dst;
 	struct dst_entry *dst = skb->dst;
 	struct ipv6hdr *hdr;
 	u8  proto = fl->proto;
@@ -241,7 +241,7 @@
 	hdr->nexthdr = proto;
 	hdr->hop_limit = hlimit;
 
-	ipv6_addr_copy(&hdr->saddr, fl->nl_u.ip6_u.saddr);
+	ipv6_addr_copy(&hdr->saddr, fl->fl6_src);
 	ipv6_addr_copy(&hdr->daddr, first_hop);
 
 	mtu = dst_pmtu(dst);
@@ -306,8 +306,8 @@
 	hdr->hop_limit = hlimit;
 	hdr->nexthdr = fl->proto;
 
-	ipv6_addr_copy(&hdr->saddr, fl->nl_u.ip6_u.saddr);
-	ipv6_addr_copy(&hdr->daddr, fl->nl_u.ip6_u.daddr);
+	ipv6_addr_copy(&hdr->saddr, fl->fl6_src);
+	ipv6_addr_copy(&hdr->daddr, fl->fl6_dst);
 	return hdr;
 }
 
@@ -524,7 +524,7 @@
 		fl->fl6_dst = rt0->addr;
 	}
 
-	if (!fl->oif && ipv6_addr_is_multicast(fl->nl_u.ip6_u.daddr))
+	if (!fl->oif && ipv6_addr_is_multicast(fl->fl6_dst))
 		fl->oif = np->mcast_oif;
 
 	dst = __sk_dst_check(sk, np->dst_cookie);
@@ -701,7 +701,7 @@
 	 *	cleanup
 	 */
 out:
-	ip6_dst_store(sk, dst, fl->nl_u.ip6_u.daddr == &np->daddr ? &np->daddr : NULL);
+	ip6_dst_store(sk, dst, fl->fl6_dst == &np->daddr ? &np->daddr : NULL);
 	if (err > 0)
 		err = np->recverr ? net_xmit_errno(err) : 0;
 	return err;
Index: net/ipv6/ndisc.c
===================================================================
RCS file: /cvsroot/usagi/usagi-backport/linux25/net/ipv6/ndisc.c,v
retrieving revision 1.1.1.8
retrieving revision 1.1.1.8.2.1
diff -u -r1.1.1.8 -r1.1.1.8.2.1
--- net/ipv6/ndisc.c	14 Apr 2003 04:34:17 -0000	1.1.1.8
+++ net/ipv6/ndisc.c	14 Apr 2003 14:42:49 -0000	1.1.1.8.2.1
@@ -405,8 +405,8 @@
 	fl->fl6_src		= saddr;
 	fl->fl6_dst	 	= daddr;
 	fl->proto	 	= IPPROTO_ICMPV6;
-	fl->uli_u.icmpt.type	= type;
-	fl->uli_u.icmpt.code	= 0;
+	fl->fl_type		= type;
+	fl->fl_code		= 0;
 }
 
 static void ndisc_send_na(struct net_device *dev, struct neighbour *neigh,
Index: net/ipv6/route.c
===================================================================
RCS file: /cvsroot/usagi/usagi-backport/linux25/net/ipv6/route.c,v
retrieving revision 1.1.1.11
retrieving revision 1.1.1.11.2.1
diff -u -r1.1.1.11 -r1.1.1.11.2.1
--- net/ipv6/route.c	14 Apr 2003 04:34:17 -0000	1.1.1.11
+++ net/ipv6/route.c	14 Apr 2003 14:42:49 -0000	1.1.1.11.2.1
@@ -449,13 +449,12 @@
 	int strict;
 	int attempts = 3;
 
-	strict = ipv6_addr_type(fl->nl_u.ip6_u.daddr) & (IPV6_ADDR_MULTICAST|IPV6_ADDR_LINKLOCAL);
+	strict = ipv6_addr_type(fl->fl6_dst) & (IPV6_ADDR_MULTICAST|IPV6_ADDR_LINKLOCAL);
 
 relookup:
 	read_lock_bh(&rt6_lock);
 
-	fn = fib6_lookup(&ip6_routing_table, fl->nl_u.ip6_u.daddr,
-			 fl->nl_u.ip6_u.saddr);
+	fn = fib6_lookup(&ip6_routing_table, fl->fl6_dst, fl->fl6_src);
 
 restart:
 	rt = fn->leaf;
@@ -477,9 +476,8 @@
 	if (!rt->rt6i_nexthop && !(rt->rt6i_flags & RTF_NONEXTHOP)) {
 		read_unlock_bh(&rt6_lock);
 
-		rt = rt6_cow(rt, fl->nl_u.ip6_u.daddr,
-			     fl->nl_u.ip6_u.saddr);
-			
+		rt = rt6_cow(rt, fl->fl6_dst, fl->fl6_src);
+
 		if (rt->u.dst.error != -EEXIST || --attempts <= 0)
 			goto out2;
 
@@ -1585,15 +1583,11 @@
 	skb->mac.raw = skb->data;
 	skb_reserve(skb, MAX_HEADER + sizeof(struct ipv6hdr));
 
-	fl.proto = 0;
-	fl.nl_u.ip6_u.daddr = NULL;
-	fl.nl_u.ip6_u.saddr = NULL;
-	fl.uli_u.icmpt.type = 0;
-	fl.uli_u.icmpt.code = 0;
+	memset(&fl, 0, sizeof(fl));
 	if (rta[RTA_SRC-1])
-		fl.nl_u.ip6_u.saddr = (struct in6_addr*)RTA_DATA(rta[RTA_SRC-1]);
+		fl.fl6_src = (struct in6_addr*)RTA_DATA(rta[RTA_SRC-1]);
 	if (rta[RTA_DST-1])
-		fl.nl_u.ip6_u.daddr = (struct in6_addr*)RTA_DATA(rta[RTA_DST-1]);
+		fl.fl6_dst = (struct in6_addr*)RTA_DATA(rta[RTA_DST-1]);
 
 	if (rta[RTA_IIF-1])
 		memcpy(&iif, RTA_DATA(rta[RTA_IIF-1]), sizeof(int));
@@ -1617,8 +1611,7 @@
 
 	NETLINK_CB(skb).dst_pid = NETLINK_CB(in_skb).pid;
 	err = rt6_fill_node(skb, rt, 
-			    fl.nl_u.ip6_u.daddr,
-			    fl.nl_u.ip6_u.saddr,
+			    fl.fl6_dst, fl.fl6_src,
 			    iif,
 			    RTM_NEWROUTE, NETLINK_CB(in_skb).pid,
 			    nlh->nlmsg_seq, nlh);
Index: net/ipv6/tcp_ipv6.c
===================================================================
RCS file: /cvsroot/usagi/usagi-backport/linux25/net/ipv6/tcp_ipv6.c,v
retrieving revision 1.1.1.12
retrieving revision 1.1.1.12.6.2
diff -u -r1.1.1.12 -r1.1.1.12.6.2
--- net/ipv6/tcp_ipv6.c	8 Apr 2003 08:57:58 -0000	1.1.1.12
+++ net/ipv6/tcp_ipv6.c	14 Apr 2003 15:42:43 -0000	1.1.1.12.6.2
@@ -670,12 +670,12 @@
 	fl.fl6_dst = &np->daddr;
 	fl.fl6_src = saddr;
 	fl.oif = sk->bound_dev_if;
-	fl.uli_u.ports.dport = usin->sin6_port;
-	fl.uli_u.ports.sport = inet->sport;
+	fl.fl_dport = usin->sin6_port;
+	fl.fl_sport = inet->sport;
 
 	if (np->opt && np->opt->srcrt) {
 		struct rt0_hdr *rt0 = (struct rt0_hdr *)np->opt->srcrt;
-		fl.nl_u.ip6_u.daddr = rt0->addr;
+		fl.fl6_dst = rt0->addr;
 	}
 
 	if (!fl.fl6_src)
@@ -796,11 +796,11 @@
 			   for now.
 			 */
 			fl.proto = IPPROTO_TCP;
-			fl.nl_u.ip6_u.daddr = &np->daddr;
-			fl.nl_u.ip6_u.saddr = &np->saddr;
+			fl.fl6_dst = &np->daddr;
+			fl.fl6_src = &np->saddr;
 			fl.oif = sk->bound_dev_if;
-			fl.uli_u.ports.dport = inet->dport;
-			fl.uli_u.ports.sport = inet->sport;
+			fl.fl_dport = inet->dport;
+			fl.fl_sport = inet->sport;
 
 			dst = ip6_route_output(sk, &fl);
 		} else
@@ -881,12 +881,12 @@
 	int err = -1;
 
 	fl.proto = IPPROTO_TCP;
-	fl.nl_u.ip6_u.daddr = &req->af.v6_req.rmt_addr;
-	fl.nl_u.ip6_u.saddr = &req->af.v6_req.loc_addr;
+	fl.fl6_dst = &req->af.v6_req.rmt_addr;
+	fl.fl6_src = &req->af.v6_req.loc_addr;
 	fl.fl6_flowlabel = 0;
 	fl.oif = req->af.v6_req.iif;
-	fl.uli_u.ports.dport = req->rmt_port;
-	fl.uli_u.ports.sport = inet_sk(sk)->sport;
+	fl.fl_dport = req->rmt_port;
+	fl.fl_sport = inet_sk(sk)->sport;
 
 	if (dst == NULL) {
 		opt = np->opt;
@@ -901,7 +901,7 @@
 
 		if (opt && opt->srcrt) {
 			struct rt0_hdr *rt0 = (struct rt0_hdr *) opt->srcrt;
-			fl.nl_u.ip6_u.daddr = rt0->addr;
+			fl.fl6_dst = rt0->addr;
 		}
 
 		dst = ip6_route_output(sk, &fl);
@@ -917,7 +917,7 @@
 					 &req->af.v6_req.loc_addr, &req->af.v6_req.rmt_addr,
 					 csum_partial((char *)th, skb->len, skb->csum));
 
-		fl.nl_u.ip6_u.daddr = &req->af.v6_req.rmt_addr;
+		fl.fl6_dst = &req->af.v6_req.rmt_addr;
 		err = ip6_xmit(sk, skb, &fl, opt);
 		if (err == NET_XMIT_CN)
 			err = 0;
@@ -1019,19 +1019,18 @@
 
 	buff->csum = csum_partial((char *)t1, sizeof(*t1), 0);
 
-	fl.nl_u.ip6_u.daddr = &skb->nh.ipv6h->saddr;
-	fl.nl_u.ip6_u.saddr = &skb->nh.ipv6h->daddr;
+	fl.fl6_dst = &skb->nh.ipv6h->saddr;
+	fl.fl6_src = &skb->nh.ipv6h->daddr;
 	fl.fl6_flowlabel = 0;
 
-	t1->check = csum_ipv6_magic(fl.nl_u.ip6_u.saddr,
-				    fl.nl_u.ip6_u.daddr, 
+	t1->check = csum_ipv6_magic(fl.fl6_src, fl.fl6_dst, 
 				    sizeof(*t1), IPPROTO_TCP,
 				    buff->csum);
 
 	fl.proto = IPPROTO_TCP;
 	fl.oif = tcp_v6_iif(skb);
-	fl.uli_u.ports.dport = t1->dest;
-	fl.uli_u.ports.sport = t1->source;
+	fl.fl_dport = t1->dest;
+	fl.fl_sport = t1->source;
 
 	/* sk = NULL, but it is safe for now. RST socket required. */
 	buff->dst = ip6_route_output(NULL, &fl);
@@ -1084,19 +1083,18 @@
 
 	buff->csum = csum_partial((char *)t1, tot_len, 0);
 
-	fl.nl_u.ip6_u.daddr = &skb->nh.ipv6h->saddr;
-	fl.nl_u.ip6_u.saddr = &skb->nh.ipv6h->daddr;
+	fl.fl6_dst = &skb->nh.ipv6h->saddr;
+	fl.fl6_src = &skb->nh.ipv6h->daddr;
 	fl.fl6_flowlabel = 0;
 
-	t1->check = csum_ipv6_magic(fl.nl_u.ip6_u.saddr,
-				    fl.nl_u.ip6_u.daddr, 
+	t1->check = csum_ipv6_magic(fl.fl6_src, fl.fl6_dst, 
 				    tot_len, IPPROTO_TCP,
 				    buff->csum);
 
 	fl.proto = IPPROTO_TCP;
 	fl.oif = tcp_v6_iif(skb);
-	fl.uli_u.ports.dport = t1->dest;
-	fl.uli_u.ports.sport = t1->source;
+	fl.fl_dport = t1->dest;
+	fl.fl_sport = t1->source;
 
 	buff->dst = ip6_route_output(NULL, &fl);
 
@@ -1335,16 +1333,16 @@
 
 	if (dst == NULL) {
 		fl.proto = IPPROTO_TCP;
-		fl.nl_u.ip6_u.daddr = &req->af.v6_req.rmt_addr;
+		fl.fl6_dst = &req->af.v6_req.rmt_addr;
 		if (opt && opt->srcrt) {
 			struct rt0_hdr *rt0 = (struct rt0_hdr *) opt->srcrt;
-			fl.nl_u.ip6_u.daddr = rt0->addr;
+			fl.fl6_dst = rt0->addr;
 		}
-		fl.nl_u.ip6_u.saddr = &req->af.v6_req.loc_addr;
+		fl.fl6_src = &req->af.v6_req.loc_addr;
 		fl.fl6_flowlabel = 0;
 		fl.oif = sk->bound_dev_if;
-		fl.uli_u.ports.dport = req->rmt_port;
-		fl.uli_u.ports.sport = inet_sk(sk)->sport;
+		fl.fl_dport = req->rmt_port;
+		fl.fl_sport = inet_sk(sk)->sport;
 
 		dst = ip6_route_output(sk, &fl);
 	}
@@ -1732,16 +1730,16 @@
 		struct flowi fl;
 
 		fl.proto = IPPROTO_TCP;
-		fl.nl_u.ip6_u.daddr = &np->daddr;
-		fl.nl_u.ip6_u.saddr = &np->saddr;
+		fl.fl6_dst = &np->daddr;
+		fl.fl6_src = &np->saddr;
 		fl.fl6_flowlabel = np->flow_label;
 		fl.oif = sk->bound_dev_if;
-		fl.uli_u.ports.dport = inet->dport;
-		fl.uli_u.ports.sport = inet->sport;
+		fl.fl_dport = inet->dport;
+		fl.fl_sport = inet->sport;
 
 		if (np->opt && np->opt->srcrt) {
 			struct rt0_hdr *rt0 = (struct rt0_hdr *) np->opt->srcrt;
-			fl.nl_u.ip6_u.daddr = rt0->addr;
+			fl.fl6_dst = rt0->addr;
 		}
 
 		dst = ip6_route_output(sk, &fl);
@@ -1774,12 +1772,12 @@
 	fl.fl6_flowlabel = np->flow_label;
 	IP6_ECN_flow_xmit(sk, fl.fl6_flowlabel);
 	fl.oif = sk->bound_dev_if;
-	fl.uli_u.ports.sport = inet->sport;
-	fl.uli_u.ports.dport = inet->dport;
+	fl.fl_sport = inet->sport;
+	fl.fl_dport = inet->dport;
 
 	if (np->opt && np->opt->srcrt) {
 		struct rt0_hdr *rt0 = (struct rt0_hdr *) np->opt->srcrt;
-		fl.nl_u.ip6_u.daddr = rt0->addr;
+		fl.fl6_dst = rt0->addr;
 	}
 
 	dst = __sk_dst_check(sk, np->dst_cookie);
@@ -1799,7 +1797,7 @@
 	skb->dst = dst_clone(dst);
 
 	/* Restore final destination back after routing done */
-	fl.nl_u.ip6_u.daddr = &np->daddr;
+	fl.fl6_dst = &np->daddr;
 
 	return ip6_xmit(sk, skb, &fl, np->opt);
 }
Index: net/ipv6/udp.c
===================================================================
RCS file: /cvsroot/usagi/usagi-backport/linux25/net/ipv6/udp.c,v
retrieving revision 1.1.1.9
retrieving revision 1.1.1.9.8.1
diff -u -r1.1.1.9 -r1.1.1.9.8.1
--- net/ipv6/udp.c	2 Apr 2003 04:16:14 -0000	1.1.1.9
+++ net/ipv6/udp.c	14 Apr 2003 15:42:43 -0000	1.1.1.9.8.1
@@ -352,8 +352,8 @@
 	fl.fl6_dst = &np->daddr;
 	fl.fl6_src = &saddr;
 	fl.oif = sk->bound_dev_if;
-	fl.uli_u.ports.dport = inet->dport;
-	fl.uli_u.ports.sport = inet->sport;
+	fl.fl_dport = inet->dport;
+	fl.fl_sport = inet->sport;
 
 	if (!fl.oif && (addr_type&IPV6_ADDR_MULTICAST))
 		fl.oif = np->mcast_oif;
@@ -936,8 +936,8 @@
 	fl.fl6_dst = daddr;
 	if (fl.fl6_src == NULL && !ipv6_addr_any(&np->saddr))
 		fl.fl6_src = &np->saddr;
-	fl.uli_u.ports.dport = udh.uh.dest;
-	fl.uli_u.ports.sport = udh.uh.source;
+	fl.fl_dport = udh.uh.dest;
+	fl.fl_sport = udh.uh.source;
 
 	err = ip6_build_xmit(sk, udpv6_getfrag, &udh, &fl, len, opt, hlimit,
 			     msg->msg_flags);
Index: net/ipv6/xfrm6_policy.c
===================================================================
RCS file: /cvsroot/usagi/usagi-backport/linux25/net/ipv6/xfrm6_policy.c,v
retrieving revision 1.1.1.2
retrieving revision 1.1.1.2.2.1
diff -u -r1.1.1.2 -r1.1.1.2.2.1
--- net/ipv6/xfrm6_policy.c	14 Apr 2003 04:34:17 -0000	1.1.1.2
+++ net/ipv6/xfrm6_policy.c	14 Apr 2003 15:42:43 -0000	1.1.1.2.2.1
@@ -195,8 +195,8 @@
 			if (pskb_may_pull(skb, skb->nh.raw + offset + 4 - skb->data)) {
 				u16 *ports = (u16 *)exthdr;
 
-				fl->uli_u.ports.sport = ports[0];
-				fl->uli_u.ports.dport = ports[1];
+				fl->fl_sport = ports[0];
+				fl->fl_dport = ports[1];
 			}
 			return;
 
Index: net/ipv6/xfrm6_state.c
===================================================================
RCS file: /cvsroot/usagi/usagi-backport/linux25/net/ipv6/xfrm6_state.c,v
retrieving revision 1.1.1.1
retrieving revision 1.1.1.1.10.1
diff -u -r1.1.1.1 -r1.1.1.1.10.1
--- net/ipv6/xfrm6_state.c	24 Mar 2003 05:46:10 -0000	1.1.1.1
+++ net/ipv6/xfrm6_state.c	14 Apr 2003 15:42:43 -0000	1.1.1.1.10.1
@@ -27,9 +27,9 @@
 	 * to current session. */
 	memcpy(&x->sel.daddr, fl->fl6_dst, sizeof(struct in6_addr));
 	memcpy(&x->sel.saddr, fl->fl6_src, sizeof(struct in6_addr));
-	x->sel.dport = fl->uli_u.ports.dport;
+	x->sel.dport = fl->fl_dport;
 	x->sel.dport_mask = ~0;
-	x->sel.sport = fl->uli_u.ports.sport;
+	x->sel.sport = fl->fl_sport;
 	x->sel.sport_mask = ~0;
 	x->sel.prefixlen_d = 128;
 	x->sel.prefixlen_s = 128;

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
