From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: [PATCH 2/3] NET: store cork'ing flow information in common storage
Date: Sun, 26 Oct 2003 18:54:09 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031026.185409.41408145.yoshfuji@linux-ipv6.org>
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

[2/3] NET: store cork'ing flow information in common storage in inet_opt.

--- linux-2.5-net/include/linux/ip.h	Sun Oct 19 01:10:46 2003
+++ linux-2.5-udp6_append_data/include/linux/ip.h	Sun Oct 26 16:19:58 2003
@@ -83,6 +83,7 @@
 #include <linux/types.h>
 #include <net/sock.h>
 #include <linux/igmp.h>
+#include <net/flow.h>
 
 struct ip_options {
   __u32		faddr;				/* Saved first hop address */
@@ -141,6 +142,7 @@
 		struct rtable		*rt;
 		int			length; /* Total length of all frames */
 		u32			addr;
+		struct flowi		fl;
 	} cork;
 };
 
--- linux-2.5-net/include/linux/ipv6.h	Sun Oct 26 16:19:19 2003
+++ linux-2.5-udp6_append_data/include/linux/ipv6.h	Sun Oct 26 16:19:58 2003
@@ -174,7 +174,6 @@
 #include <net/if_inet6.h>       /* struct ipv6_mc_socklist */
 #include <linux/tcp.h>
 #include <linux/udp.h>
-#include <net/flow.h>
 
 /* 
    This structure contains results of exthdrs parsing
@@ -235,7 +234,6 @@
 	struct {
 		struct ipv6_txoptions *opt;
 		struct rt6_info	*rt;
-		struct flowi fl;
 		int hop_limit;
 	} cork;
 };
--- linux-2.5-net/include/linux/udp.h	Sun Oct 19 01:10:47 2003
+++ linux-2.5-udp6_append_data/include/linux/udp.h	Sun Oct 26 16:20:00 2003
@@ -44,13 +44,9 @@
 	unsigned int	corkflag;	/* Cork is required */
   	__u16		encap_type;	/* Is this an Encapsulation socket? */
 	/*
-	 * Following members retains the infomation to create a UDP header
+	 * Following member retains the infomation to create a UDP header
 	 * when the socket is uncorked.
 	 */
-	u32		saddr;		/* source address */
-	u32		daddr;		/* destination address */
-	__u16		sport;		/* source port */
-	__u16		dport;		/* destination port */
 	__u16		len;		/* total length of pending frames */
 };
 
--- linux-2.5-net/net/ipv4/udp.c	Sun Oct 19 01:10:53 2003
+++ linux-2.5-udp6_append_data/net/ipv4/udp.c	Sun Oct 26 16:20:04 2003
@@ -398,6 +398,8 @@
  */
 static int udp_push_pending_frames(struct sock *sk, struct udp_opt *up)
 {
+	struct inet_opt *inet = inet_sk(sk);
+	struct flowi *fl = &inet->cork.fl;
 	struct sk_buff *skb;
 	struct udphdr *uh;
 	int err = 0;
@@ -410,8 +412,8 @@
 	 * Create a UDP header
 	 */
 	uh = skb->h.uh;
-	uh->source = up->sport;
-	uh->dest = up->dport;
+	uh->source = fl->fl_ip_sport;
+	uh->dest = fl->fl_ip_dport;
 	uh->len = htons(up->len);
 	uh->check = 0;
 
@@ -426,12 +428,12 @@
 		 */
 		if (skb->ip_summed == CHECKSUM_HW) {
 			skb->csum = offsetof(struct udphdr, check);
-			uh->check = ~csum_tcpudp_magic(up->saddr, up->daddr,
+			uh->check = ~csum_tcpudp_magic(fl->fl4_src, fl->fl4_dst,
 					up->len, IPPROTO_UDP, 0);
 		} else {
 			skb->csum = csum_partial((char *)uh,
 					sizeof(struct udphdr), skb->csum);
-			uh->check = csum_tcpudp_magic(up->saddr, up->daddr,
+			uh->check = csum_tcpudp_magic(fl->fl4_src, fl->fl4_dst,
 					up->len, IPPROTO_UDP, skb->csum);
 			if (uh->check == 0)
 				uh->check = -1;
@@ -456,7 +458,7 @@
 		skb_queue_walk(&sk->sk_write_queue, skb) {
 			csum = csum_add(csum, skb->csum);
 		}
-		uh->check = csum_tcpudp_magic(up->saddr, up->daddr,
+		uh->check = csum_tcpudp_magic(fl->fl4_src, fl->fl4_dst,
 				up->len, IPPROTO_UDP, csum);
 		if (uh->check == 0)
 			uh->check = -1;
@@ -636,10 +638,10 @@
 	/*
 	 *	Now cork the socket to pend data.
 	 */
-	up->daddr = daddr;
-	up->dport = dport;
-	up->saddr = saddr;
-	up->sport = inet->sport;
+	inet->cork.fl.fl4_dst = daddr;
+	inet->cork.fl.fl_ip_dport = dport;
+	inet->cork.fl.fl4_src = saddr;
+	inet->cork.fl.fl_ip_sport = inet->sport;
 	up->pending = 1;
 
 do_append_data:
--- linux-2.5-net/net/ipv6/udp.c	Sun Oct 26 16:19:19 2003
+++ linux-2.5-udp6_append_data/net/ipv6/udp.c	Sun Oct 26 16:20:00 2003
@@ -720,8 +720,8 @@
 {
 	struct sk_buff *skb;
 	struct udphdr *uh;
-	struct ipv6_pinfo *np = inet6_sk(sk);
-	struct flowi *fl = &np->cork.fl;
+	struct inet_opt *inet = inet_sk(sk);
+	struct flowi *fl = &inet->cork.fl;
 	int err = 0;
 
 	/* Grab the skbuff where UDP header space exists. */
@@ -783,7 +783,7 @@
 	struct in6_addr *daddr;
 	struct ipv6_txoptions *opt = NULL;
 	struct ip6_flowlabel *flowlabel = NULL;
-	struct flowi *fl = &np->cork.fl;
+	struct flowi *fl = &inet->cork.fl;
 	struct dst_entry *dst;
 	int addr_len = msg->msg_namelen;
 	int ulen = len;
@@ -830,7 +830,7 @@
 		if (sin6->sin6_port == 0)
 			return -EINVAL;
 
-		up->dport = sin6->sin6_port;
+		fl->fl_ip_dport = sin6->sin6_port;
 		daddr = &sin6->sin6_addr;
 
 		if (np->sndflow) {
@@ -859,7 +859,7 @@
 		if (sk->sk_state != TCP_ESTABLISHED)
 			return -EDESTADDRREQ;
 
-		up->dport = inet->dport;
+		fl->fl_ip_dport = inet->dport;
 		daddr = &np->daddr;
 		fl->fl6_flowlabel = np->flow_label;
 	}
@@ -874,7 +874,7 @@
 
 		sin.sin_family = AF_INET;
 		sin.sin_addr.s_addr = daddr->s6_addr32[3];
-		sin.sin_port = up->dport;
+		sin.sin_port = inet->cork.fl.fl_ip_dport;
 		msg->msg_name = (struct sockaddr *)(&sin);
 		msg->msg_namelen = sizeof(sin);
 		fl6_sock_release(flowlabel);
@@ -911,7 +911,6 @@
 	ipv6_addr_copy(&fl->fl6_dst, daddr);
 	if (ipv6_addr_any(&fl->fl6_src) && !ipv6_addr_any(&np->saddr))
 		ipv6_addr_copy(&fl->fl6_src, &np->saddr);
-	fl->fl_ip_dport = up->dport;
 	fl->fl_ip_sport = inet->sport;
 	
 	/* merge ip6_build_xmit from ip6_output */
--- linux-2.5-net/net/ipv6/ip6_output.c	Sun Oct 26 16:19:19 2003
+++ linux-2.5-udp6_append_data/net/ipv6/ip6_output.c	Sun Oct 26 16:20:00 2003
@@ -1239,7 +1239,7 @@
 		}
 		dst_hold(&rt->u.dst);
 		np->cork.rt = rt;
-		np->cork.fl = *fl;
+		inet->cork.fl = *fl;
 		np->cork.hop_limit = hlimit;
 		inet->cork.fragsize = mtu = dst_pmtu(&rt->u.dst);
 		inet->cork.length = 0;
@@ -1250,6 +1250,7 @@
 		transhdrlen += exthdrlen;
 	} else {
 		rt = np->cork.rt;
+		fl = &inet->cork.fl;
 		if (inet->cork.flags & IPCORK_OPT)
 			opt = np->cork.opt;
 		transhdrlen = 0;
@@ -1423,7 +1424,7 @@
 	struct ipv6hdr *hdr;
 	struct ipv6_txoptions *opt = np->cork.opt;
 	struct rt6_info *rt = np->cork.rt;
-	struct flowi *fl = &np->cork.fl;
+	struct flowi *fl = &inet->cork.fl;
 	unsigned char proto = fl->proto;
 	int err = 0;
 
@@ -1487,7 +1488,7 @@
 		dst_release(&np->cork.rt->u.dst);
 		np->cork.rt = NULL;
 	}
-	memset(&np->cork.fl, 0, sizeof(np->cork.fl));
+	memset(&inet->cork.fl, 0, sizeof(inet->cork.fl));
 	return err;
 error:
 	goto out;
@@ -1512,5 +1513,5 @@
 		dst_release(&np->cork.rt->u.dst);
 		np->cork.rt = NULL;
 	}
-	memset(&np->cork.fl, 0, sizeof(np->cork.fl));
+	memset(&inet->cork.fl, 0, sizeof(inet->cork.fl));
 }

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
