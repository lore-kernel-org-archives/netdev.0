From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [RFC] [PATCH] Optimize TCP sendmsg in favour of fast devices?
Date: Fri, 15 Jan 2010 11:03:52 +0530
Message-ID: <20100115053352.31564.765.sendpatchset@krkumar2.in.ibm.com>
Cc: ilpo.jarvinen@helsinki.fi, netdev@vger.kernel.org,
	eric.dumazet@gmail.com, Krishna Kumar <krkumar2@in.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp08.in.ibm.com ([122.248.162.8]:60583 "EHLO
	e28smtp08.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750892Ab0AOFd5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jan 2010 00:33:57 -0500
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by e28smtp08.in.ibm.com (8.14.3/8.13.1) with ESMTP id o0F50sEx018467
	for <netdev@vger.kernel.org>; Fri, 15 Jan 2010 10:30:54 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o0F5Xsja692270
	for <netdev@vger.kernel.org>; Fri, 15 Jan 2010 11:03:54 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o0F5Xr45015573
	for <netdev@vger.kernel.org>; Fri, 15 Jan 2010 16:33:54 +1100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krishna Kumar <krkumar2@in.ibm.com>

Remove inline skb data in tcp_sendmsg(). For the few devices that
don't support NETIF_F_SG, dev_queue_xmit will call skb_linearize,
and pass the penalty to those slow devices (the following drivers
do not support NETIF_F_SG: 8139cp.c, amd8111e.c, dl2k.c, dm9000.c,
dnet.c, ethoc.c, ibmveth.c, ioc3-eth.c, macb.c, ps3_gelic_net.c,
r8169.c, rionet.c, spider_net.c, tsi108_eth.c, veth.c,
via-velocity.c, atlx/atl2.c, bonding/bond_main.c, can/dev.c,
cris/eth_v10.c).

This patch does not affect devices that support SG but turn off
via ethtool after register_netdev.

I ran the following test cases with iperf - #threads: 1 4 8 16 32
64 128 192 256, I/O sizes: 256 4K 16K 64K, each test case runs for
1 minute, repeat 5 iterations. Total test run time is 6 hours.
System is 4-proc Opteron, with a Chelsio 10gbps NIC. Results (BW
figures are the aggregate across 5 iterations in mbps):

-------------------------------------------------------
#Process   I/O Size    Org-BW     New-BW   %-change
-------------------------------------------------------
1           256        2098       2147      2.33
1           4K         14057      14269     1.50
1           16K        25984      27317     5.13
1           64K        25920      27539     6.24

4           256        1895       2117      11.71
4           4K         10699      15649     46.26
4           16K        25675      26723     4.08
4           64K        27026      27545     1.92

8           256        1816       1966      8.25
8           4K         9511       12754     34.09
8           16K        25177      25281     0.41
8           64K        26288      26878     2.24

16          256        1893       2142      13.15
16          4K         16370      15805     -3.45
16          16K        25986      25890     -0.36
16          64K        26925      28036     4.12

32          256        2061       2038      -1.11
32          4K         10765      12253     13.82
32          16K        26802      28613     6.75
32          64K        28433      27739     -2.44

64          256        1885       2088      10.76
64          4K         10534      15778     49.78
64          16K        26745      28130     5.17
64          64K        29153      28708     -1.52

128         256        1884       2023      7.37
128         4K         9446       13732     45.37
128         16K        27013      27086     0.27
128         64K        26151      27933     6.81

192         256        2000       2094      4.70
192         4K         14260      13479     -5.47
192         16K        25545      27478     7.56
192         64K        26497      26482     -0.05

256         256        1947       1955      0.41
256         4K         9828       12265     24.79
256         16K        25087      24977     -0.43
256         64K        26715      27997     4.79
-------------------------------------------------------
Total:      -          600071     634906    5.80
-------------------------------------------------------

Please review if the idea is acceptable.

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
---
 net/ipv4/tcp.c |  172 ++++++++++++++++++-----------------------------
 1 file changed, 66 insertions(+), 106 deletions(-)

diff -ruNp org/net/ipv4/tcp.c new/net/ipv4/tcp.c
--- org/net/ipv4/tcp.c	2010-01-13 10:43:27.000000000 +0530
+++ new/net/ipv4/tcp.c	2010-01-13 10:43:37.000000000 +0530
@@ -876,26 +876,6 @@ ssize_t tcp_sendpage(struct socket *sock
 #define TCP_PAGE(sk)	(sk->sk_sndmsg_page)
 #define TCP_OFF(sk)	(sk->sk_sndmsg_off)
 
-static inline int select_size(struct sock *sk, int sg)
-{
-	struct tcp_sock *tp = tcp_sk(sk);
-	int tmp = tp->mss_cache;
-
-	if (sg) {
-		if (sk_can_gso(sk))
-			tmp = 0;
-		else {
-			int pgbreak = SKB_MAX_HEAD(MAX_TCP_HEADER);
-
-			if (tmp >= pgbreak &&
-			    tmp <= pgbreak + (MAX_SKB_FRAGS - 1) * PAGE_SIZE)
-				tmp = pgbreak;
-		}
-	}
-
-	return tmp;
-}
-
 int tcp_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg,
 		size_t size)
 {
@@ -905,7 +885,7 @@ int tcp_sendmsg(struct kiocb *iocb, stru
 	struct sk_buff *skb;
 	int iovlen, flags;
 	int mss_now, size_goal;
-	int sg, err, copied;
+	int err, copied;
 	long timeo;
 
 	lock_sock(sk);
@@ -933,8 +913,6 @@ int tcp_sendmsg(struct kiocb *iocb, stru
 	if (sk->sk_err || (sk->sk_shutdown & SEND_SHUTDOWN))
 		goto out_err;
 
-	sg = sk->sk_route_caps & NETIF_F_SG;
-
 	while (--iovlen >= 0) {
 		int seglen = iov->iov_len;
 		unsigned char __user *from = iov->iov_base;
@@ -944,6 +922,8 @@ int tcp_sendmsg(struct kiocb *iocb, stru
 		while (seglen > 0) {
 			int copy = 0;
 			int max = size_goal;
+			int merge, i, off;
+			struct page *page;
 
 			skb = tcp_write_queue_tail(sk);
 			if (tcp_send_head(sk)) {
@@ -954,14 +934,11 @@ int tcp_sendmsg(struct kiocb *iocb, stru
 
 			if (copy <= 0) {
 new_segment:
-				/* Allocate new segment. If the interface is SG,
-				 * allocate skb fitting to single page.
-				 */
+				/* Allocate new segment with a single page */
 				if (!sk_stream_memory_free(sk))
 					goto wait_for_sndbuf;
 
-				skb = sk_stream_alloc_skb(sk,
-							  select_size(sk, sg),
+				skb = sk_stream_alloc_skb(sk, 0,
 							  sk->sk_allocation);
 				if (!skb)
 					goto wait_for_memory;
@@ -981,84 +958,77 @@ new_segment:
 			if (copy > seglen)
 				copy = seglen;
 
-			/* Where to copy to? */
-			if (skb_tailroom(skb) > 0) {
-				/* We have some space in skb head. Superb! */
-				if (copy > skb_tailroom(skb))
-					copy = skb_tailroom(skb);
-				if ((err = skb_add_data(skb, from, copy)) != 0)
-					goto do_fault;
-			} else {
-				int merge = 0;
-				int i = skb_shinfo(skb)->nr_frags;
-				struct page *page = TCP_PAGE(sk);
-				int off = TCP_OFF(sk);
-
-				if (skb_can_coalesce(skb, i, page, off) &&
-				    off != PAGE_SIZE) {
-					/* We can extend the last page
-					 * fragment. */
-					merge = 1;
-				} else if (i == MAX_SKB_FRAGS || !sg) {
-					/* Need to add new fragment and cannot
-					 * do this because interface is non-SG,
-					 * or because all the page slots are
-					 * busy. */
-					tcp_mark_push(tp, skb);
-					goto new_segment;
-				} else if (page) {
-					if (off == PAGE_SIZE) {
-						put_page(page);
-						TCP_PAGE(sk) = page = NULL;
-						off = 0;
-					}
-				} else
+			merge = 0;
+			i = skb_shinfo(skb)->nr_frags;
+			page = TCP_PAGE(sk);
+			off = TCP_OFF(sk);
+
+			if (skb_can_coalesce(skb, i, page, off) &&
+			    off != PAGE_SIZE) {
+				/* We can extend the last page
+				 * fragment. */
+				merge = 1;
+			} else if (i == MAX_SKB_FRAGS) {
+				/*
+				 * Need to add new fragment and cannot
+				 * do this because all the page slots are
+				 * busy. For the (rare) non-SG devices,
+				 * dev_queue_xmit handles this skb.
+				 */
+				tcp_mark_push(tp, skb);
+				goto new_segment;
+			} else if (page) {
+				if (off == PAGE_SIZE) {
+					put_page(page);
+					TCP_PAGE(sk) = page = NULL;
 					off = 0;
+				}
+			} else
+				off = 0;
 
-				if (copy > PAGE_SIZE - off)
-					copy = PAGE_SIZE - off;
+			if (copy > PAGE_SIZE - off)
+				copy = PAGE_SIZE - off;
 
-				if (!sk_wmem_schedule(sk, copy))
-					goto wait_for_memory;
+			if (!sk_wmem_schedule(sk, copy))
+				goto wait_for_memory;
 
-				if (!page) {
-					/* Allocate new cache page. */
-					if (!(page = sk_stream_alloc_page(sk)))
-						goto wait_for_memory;
-				}
+			if (!page) {
+				/* Allocate new cache page. */
+				if (!(page = sk_stream_alloc_page(sk)))
+					goto wait_for_memory;
+			}
 
-				/* Time to copy data. We are close to
-				 * the end! */
-				err = skb_copy_to_page(sk, from, skb, page,
-						       off, copy);
-				if (err) {
-					/* If this page was new, give it to the
-					 * socket so it does not get leaked.
-					 */
-					if (!TCP_PAGE(sk)) {
-						TCP_PAGE(sk) = page;
-						TCP_OFF(sk) = 0;
-					}
-					goto do_error;
+			/* Time to copy data. We are close to
+			 * the end! */
+			err = skb_copy_to_page(sk, from, skb, page,
+					       off, copy);
+			if (err) {
+				/* If this page was new, give it to the
+				 * socket so it does not get leaked.
+				 */
+				if (!TCP_PAGE(sk)) {
+					TCP_PAGE(sk) = page;
+					TCP_OFF(sk) = 0;
 				}
+				goto do_error;
+			}
 
-				/* Update the skb. */
-				if (merge) {
-					skb_shinfo(skb)->frags[i - 1].size +=
-									copy;
-				} else {
-					skb_fill_page_desc(skb, i, page, off, copy);
-					if (TCP_PAGE(sk)) {
-						get_page(page);
-					} else if (off + copy < PAGE_SIZE) {
-						get_page(page);
-						TCP_PAGE(sk) = page;
-					}
+			/* Update the skb. */
+			if (merge) {
+				skb_shinfo(skb)->frags[i - 1].size +=
+								copy;
+			} else {
+				skb_fill_page_desc(skb, i, page, off, copy);
+				if (TCP_PAGE(sk)) {
+					get_page(page);
+				} else if (off + copy < PAGE_SIZE) {
+					get_page(page);
+					TCP_PAGE(sk) = page;
 				}
-
-				TCP_OFF(sk) = off + copy;
 			}
 
+			TCP_OFF(sk) = off + copy;
+
 			if (!copied)
 				TCP_SKB_CB(skb)->flags &= ~TCPCB_FLAG_PSH;
 
@@ -1101,16 +1071,6 @@ out:
 	release_sock(sk);
 	return copied;
 
-do_fault:
-	if (!skb->len) {
-		tcp_unlink_write_queue(skb, sk);
-		/* It is the one place in all of TCP, except connection
-		 * reset, where we can be unlinking the send_head.
-		 */
-		tcp_check_send_head(sk, skb);
-		sk_wmem_free_skb(sk, skb);
-	}
-
 do_error:
 	if (copied)
 		goto out;
