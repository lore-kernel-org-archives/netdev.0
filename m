From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: [PATCH 1/3] IPv6: Fix odd IPv6 header in UDPv6 packets when
 sending MSG_MORE flag
Date: Sun, 26 Oct 2003 18:54:05 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031026.185405.129894332.yoshfuji@linux-ipv6.org>
References: <20030807223421.70497d61.davem@redhat.com>
	<20030808.170839.90822982.yoshfuji@linux-ipv6.org>
	<20031026.185023.108406592.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, miyazawa@linux-ipv6.org, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
In-Reply-To: <20031026.185023.108406592.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

> I'm about to send 3 patches to fix them.
>
> [1/3] IPv6: Odd IPv6 header in UDPv6 packets when sending MSG_MORE flag
> [2/3] NET: store cork'ing flow information in common storage in inet_opt
> [3/3] IPv6: breakage of sendmsg to IPv4-mapped address via UDPv6 socket

[1/3] IPv6: Odd IPv6 header in UDPv6 packets when sending MSG_MORE flag

D: Broken IPv6 header for UDPv6 was generated with MSG_MORE flag.
D: Remember cork'ed flow information in real storage.

===== include/linux/ipv6.h 1.12 vs edited =====
--- 1.12/include/linux/ipv6.h	Sat Sep 13 09:25:13 2003
+++ edited/include/linux/ipv6.h	Sun Oct 26 14:56:16 2003
@@ -174,6 +174,7 @@
 #include <net/if_inet6.h>       /* struct ipv6_mc_socklist */
 #include <linux/tcp.h>
 #include <linux/udp.h>
+#include <net/flow.h>
 
 /* 
    This structure contains results of exthdrs parsing
@@ -234,7 +235,7 @@
 	struct {
 		struct ipv6_txoptions *opt;
 		struct rt6_info	*rt;
-		struct flowi *fl;
+		struct flowi fl;
 		int hop_limit;
 	} cork;
 };
===== net/ipv6/ip6_output.c 1.44 vs edited =====
--- 1.44/net/ipv6/ip6_output.c	Mon Sep  1 17:44:26 2003
+++ edited/net/ipv6/ip6_output.c	Sun Oct 26 14:56:16 2003
@@ -1239,7 +1239,7 @@
 		}
 		dst_hold(&rt->u.dst);
 		np->cork.rt = rt;
-		np->cork.fl = fl;
+		np->cork.fl = *fl;
 		np->cork.hop_limit = hlimit;
 		inet->cork.fragsize = mtu = dst_pmtu(&rt->u.dst);
 		inet->cork.length = 0;
@@ -1423,7 +1423,7 @@
 	struct ipv6hdr *hdr;
 	struct ipv6_txoptions *opt = np->cork.opt;
 	struct rt6_info *rt = np->cork.rt;
-	struct flowi *fl = np->cork.fl;
+	struct flowi *fl = &np->cork.fl;
 	unsigned char proto = fl->proto;
 	int err = 0;
 
@@ -1487,9 +1487,7 @@
 		dst_release(&np->cork.rt->u.dst);
 		np->cork.rt = NULL;
 	}
-	if (np->cork.fl) {
-		np->cork.fl = NULL;
-	}
+	memset(&np->cork.fl, 0, sizeof(np->cork.fl));
 	return err;
 error:
 	goto out;
@@ -1514,7 +1512,5 @@
 		dst_release(&np->cork.rt->u.dst);
 		np->cork.rt = NULL;
 	}
-	if (np->cork.fl) {
-		np->cork.fl = NULL;
-	}
+	memset(&np->cork.fl, 0, sizeof(np->cork.fl));
 }
===== net/ipv6/udp.c 1.50 vs edited =====
--- 1.50/net/ipv6/udp.c	Thu Oct  9 00:27:40 2003
+++ edited/net/ipv6/udp.c	Sun Oct 26 14:56:16 2003
@@ -721,7 +721,7 @@
 	struct sk_buff *skb;
 	struct udphdr *uh;
 	struct ipv6_pinfo *np = inet6_sk(sk);
-	struct flowi *fl = np->cork.fl;
+	struct flowi *fl = &np->cork.fl;
 	int err = 0;
 
 	/* Grab the skbuff where UDP header space exists. */
@@ -783,7 +783,7 @@
 	struct in6_addr *daddr;
 	struct ipv6_txoptions *opt = NULL;
 	struct ip6_flowlabel *flowlabel = NULL;
-	struct flowi fl;
+	struct flowi *fl = &np->cork.fl;
 	struct dst_entry *dst;
 	int addr_len = msg->msg_namelen;
 	int ulen = len;
@@ -812,7 +812,7 @@
 	}
 	ulen += sizeof(struct udphdr);
 
-	memset(&fl, 0, sizeof(fl));
+	memset(fl, 0, sizeof(*fl));
 
 	if (sin6) {
 		if (sin6->sin6_family == AF_INET) {
@@ -834,9 +834,9 @@
 		daddr = &sin6->sin6_addr;
 
 		if (np->sndflow) {
-			fl.fl6_flowlabel = sin6->sin6_flowinfo&IPV6_FLOWINFO_MASK;
-			if (fl.fl6_flowlabel&IPV6_FLOWLABEL_MASK) {
-				flowlabel = fl6_sock_lookup(sk, fl.fl6_flowlabel);
+			fl->fl6_flowlabel = sin6->sin6_flowinfo&IPV6_FLOWINFO_MASK;
+			if (fl->fl6_flowlabel&IPV6_FLOWLABEL_MASK) {
+				flowlabel = fl6_sock_lookup(sk, fl->fl6_flowlabel);
 				if (flowlabel == NULL)
 					return -EINVAL;
 				daddr = &flowlabel->dst;
@@ -854,14 +854,14 @@
 		if (addr_len >= sizeof(struct sockaddr_in6) &&
 		    sin6->sin6_scope_id &&
 		    ipv6_addr_type(daddr)&IPV6_ADDR_LINKLOCAL)
-			fl.oif = sin6->sin6_scope_id;
+			fl->oif = sin6->sin6_scope_id;
 	} else {
 		if (sk->sk_state != TCP_ESTABLISHED)
 			return -EDESTADDRREQ;
 
 		up->dport = inet->dport;
 		daddr = &np->daddr;
-		fl.fl6_flowlabel = np->flow_label;
+		fl->fl6_flowlabel = np->flow_label;
 	}
 
 	addr_type = ipv6_addr_type(daddr);
@@ -882,20 +882,20 @@
 		return udp_sendmsg(iocb, sk, msg, len);
 	}
 
-	if (!fl.oif)
-		fl.oif = sk->sk_bound_dev_if;
+	if (!fl->oif)
+		fl->oif = sk->sk_bound_dev_if;
 
 	if (msg->msg_controllen) {
 		opt = &opt_space;
 		memset(opt, 0, sizeof(struct ipv6_txoptions));
 
-		err = datagram_send_ctl(msg, &fl, opt, &hlimit);
+		err = datagram_send_ctl(msg, fl, opt, &hlimit);
 		if (err < 0) {
 			fl6_sock_release(flowlabel);
 			return err;
 		}
-		if ((fl.fl6_flowlabel&IPV6_FLOWLABEL_MASK) && !flowlabel) {
-			flowlabel = fl6_sock_lookup(sk, fl.fl6_flowlabel);
+		if ((fl->fl6_flowlabel&IPV6_FLOWLABEL_MASK) && !flowlabel) {
+			flowlabel = fl6_sock_lookup(sk, fl->fl6_flowlabel);
 			if (flowlabel == NULL)
 				return -EINVAL;
 		}
@@ -907,28 +907,28 @@
 	if (flowlabel)
 		opt = fl6_merge_options(&opt_space, flowlabel, opt);
 
-	fl.proto = IPPROTO_UDP;
-	ipv6_addr_copy(&fl.fl6_dst, daddr);
-	if (ipv6_addr_any(&fl.fl6_src) && !ipv6_addr_any(&np->saddr))
-		ipv6_addr_copy(&fl.fl6_src, &np->saddr);
-	fl.fl_ip_dport = up->dport;
-	fl.fl_ip_sport = inet->sport;
+	fl->proto = IPPROTO_UDP;
+	ipv6_addr_copy(&fl->fl6_dst, daddr);
+	if (ipv6_addr_any(&fl->fl6_src) && !ipv6_addr_any(&np->saddr))
+		ipv6_addr_copy(&fl->fl6_src, &np->saddr);
+	fl->fl_ip_dport = up->dport;
+	fl->fl_ip_sport = inet->sport;
 	
 	/* merge ip6_build_xmit from ip6_output */
 	if (opt && opt->srcrt) {
 		struct rt0_hdr *rt0 = (struct rt0_hdr *) opt->srcrt;
-		ipv6_addr_copy(&fl.fl6_dst, rt0->addr);
+		ipv6_addr_copy(&fl->fl6_dst, rt0->addr);
 	}
 
-	if (!fl.oif && ipv6_addr_is_multicast(&fl.fl6_dst))
-		fl.oif = np->mcast_oif;
+	if (!fl->oif && ipv6_addr_is_multicast(&fl->fl6_dst))
+		fl->oif = np->mcast_oif;
 
-	err = ip6_dst_lookup(sk, &dst, &fl);
+	err = ip6_dst_lookup(sk, &dst, fl);
 	if (err)
 		goto out;
 
 	if (hlimit < 0) {
-		if (ipv6_addr_is_multicast(&fl.fl6_dst))
+		if (ipv6_addr_is_multicast(&fl->fl6_dst))
 			hlimit = np->mcast_hops;
 		else
 			hlimit = np->hop_limit;
@@ -956,7 +956,7 @@
 do_append_data:
 	up->len += ulen;
 	err = ip6_append_data(sk, ip_generic_getfrag, msg->msg_iov, ulen, sizeof(struct udphdr),
-			      hlimit, opt, &fl, (struct rt6_info*)dst,
+			      hlimit, opt, fl, (struct rt6_info*)dst,
 			      corkreq ? msg->msg_flags|MSG_MORE : msg->msg_flags);
 	if (err)
 		udp_v6_flush_pending_frames(sk);
@@ -965,7 +965,7 @@
 
 	if (dst)
 		ip6_dst_store(sk, dst,
-			      !ipv6_addr_cmp(&fl.fl6_dst, &np->daddr) ?
+			      !ipv6_addr_cmp(&fl->fl6_dst, &np->daddr) ?
 			      &np->daddr : NULL);
 	if (err > 0)
 		err = np->recverr ? net_xmit_errno(err) : 0;

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
