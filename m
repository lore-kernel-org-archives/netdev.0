From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: [PATCH] [IPV6] LL_RESERVED_SPACE
Date: Mon, 09 Feb 2004 13:45:23 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040209.134523.27564970.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

D: [IPV6] Use LL_RESERVED_SPACE() where appricable.

===== net/ipv6/ip6_output.c 1.49 vs edited =====
--- 1.49/net/ipv6/ip6_output.c	Thu Jan 22 15:18:21 2004
+++ edited/net/ipv6/ip6_output.c	Mon Feb  9 13:25:45 2004
@@ -218,7 +218,7 @@
 		 */
 		head_room = opt->opt_nflen + opt->opt_flen;
 		seg_len += head_room;
-		head_room += sizeof(struct ipv6hdr) + ((dst->dev->hard_header_len + 15)&~15);
+		head_room += sizeof(struct ipv6hdr) + LL_RESERVED_SPACE(dst->dev);
 
 		if (skb_headroom(skb) < head_room) {
 			struct sk_buff *skb2 = skb_realloc_headroom(skb, head_room);
@@ -844,7 +844,7 @@
 		mtu = inet->cork.fragsize;
 	}
 
-	hh_len = (rt->u.dst.dev->hard_header_len&~15) + 16;
+	hh_len = LL_RESERVED_SPACE(rt->u.dst.dev);
 
 	fragheaderlen = sizeof(struct ipv6hdr) + (opt ? opt->opt_nflen : 0);
 	maxfraglen = ((mtu - fragheaderlen) & ~7) + fragheaderlen - sizeof(struct frag_hdr);
@@ -881,14 +881,14 @@
 			alloclen += sizeof(struct frag_hdr);
 			if (transhdrlen) {
 				skb = sock_alloc_send_skb(sk,
-						alloclen + hh_len + 15,
+						alloclen + hh_len,
 						(flags & MSG_DONTWAIT), &err);
 			} else {
 				skb = NULL;
 				if (atomic_read(&sk->sk_wmem_alloc) <=
 				    2 * sk->sk_sndbuf)
 					skb = sock_wmalloc(sk,
-							   alloclen + hh_len + 15, 1,
+							   alloclen + hh_len, 1,
 							   sk->sk_allocation);
 				if (unlikely(skb == NULL))
 					err = -ENOBUFS;
===== net/ipv6/mcast.c 1.50 vs edited =====
--- 1.50/net/ipv6/mcast.c	Thu Jan 29 09:06:25 2004
+++ edited/net/ipv6/mcast.c	Mon Feb  9 13:35:19 2004
@@ -1233,12 +1233,13 @@
 		     IPV6_TLV_ROUTERALERT, 2, 0, 0,
 		     IPV6_TLV_PADN, 0 };
 
-	skb = sock_alloc_send_skb(sk, size + dev->hard_header_len+15, 1, &err);
+	/* we assume size > sizeof(ra) here */
+	skb = sock_alloc_send_skb(sk, size + LL_RESERVED_SPACE(dev), 1, &err);
 
 	if (skb == 0)
 		return 0;
 
-	skb_reserve(skb, (dev->hard_header_len + 15) & ~15);
+	skb_reserve(skb, LL_RESERVED_SPACE(dev));
 	if (dev->hard_header) {
 		unsigned char ha[MAX_ADDR_LEN];
 
@@ -1580,12 +1581,12 @@
 	payload_len = len + sizeof(ra);
 	full_len = sizeof(struct ipv6hdr) + payload_len;
 
-	skb = sock_alloc_send_skb(sk, dev->hard_header_len + full_len + 15, 1, &err);
+	skb = sock_alloc_send_skb(sk, LL_RESERVED_SPACE(dev) + full_len, 1, &err);
 
 	if (skb == NULL)
 		return;
 
-	skb_reserve(skb, (dev->hard_header_len + 15) & ~15);
+	skb_reserve(skb, LL_RESERVED_SPACE(dev));
 	if (dev->hard_header) {
 		unsigned char ha[MAX_ADDR_LEN];
 		ndisc_mc_map(snd_addr, ha, dev, 1);
===== net/ipv6/ndisc.c 1.70 vs edited =====
--- 1.70/net/ipv6/ndisc.c	Sat Feb  7 08:28:55 2004
+++ edited/net/ipv6/ndisc.c	Mon Feb  9 13:25:45 2004
@@ -459,7 +459,7 @@
 			inc_opt = 0;
 	}
 
-	skb = sock_alloc_send_skb(sk, MAX_HEADER + len + dev->hard_header_len + 15,
+	skb = sock_alloc_send_skb(sk, MAX_HEADER + len + LL_RESERVED_SPACE(dev),
 				  1, &err);
 
 	if (skb == NULL) {
@@ -468,7 +468,7 @@
 		return;
 	}
 
-	skb_reserve(skb, (dev->hard_header_len + 15) & ~15);
+	skb_reserve(skb, LL_RESERVED_SPACE(dev));
 	ip6_nd_hdr(sk, skb, dev, src_addr, daddr, IPPROTO_ICMPV6, len);
 
 	msg = (struct nd_msg *)skb_put(skb, len);
@@ -545,7 +545,7 @@
 	if (send_llinfo)
 		len += NDISC_OPT_SPACE(dev->addr_len);
 
-	skb = sock_alloc_send_skb(sk, MAX_HEADER + len + dev->hard_header_len + 15,
+	skb = sock_alloc_send_skb(sk, MAX_HEADER + len + LL_RESERVED_SPACE(dev),
 				  1, &err);
 	if (skb == NULL) {
 		ND_PRINTK1("send_ns: alloc skb failed\n");
@@ -553,7 +553,7 @@
 		return;
 	}
 
-	skb_reserve(skb, (dev->hard_header_len + 15) & ~15);
+	skb_reserve(skb, LL_RESERVED_SPACE(dev));
 	ip6_nd_hdr(sk, skb, dev, saddr, daddr, IPPROTO_ICMPV6, len);
 
 	msg = (struct nd_msg *)skb_put(skb, len);
@@ -617,7 +617,7 @@
 	if (dev->addr_len)
 		len += NDISC_OPT_SPACE(dev->addr_len);
 
-        skb = sock_alloc_send_skb(sk, MAX_HEADER + len + dev->hard_header_len + 15,
+        skb = sock_alloc_send_skb(sk, MAX_HEADER + len + LL_RESERVED_SPACE(dev),
 				  1, &err);
 	if (skb == NULL) {
 		ND_PRINTK1("send_ns: alloc skb failed\n");
@@ -625,7 +625,7 @@
 		return;
 	}
 
-	skb_reserve(skb, (dev->hard_header_len + 15) & ~15);
+	skb_reserve(skb, LL_RESERVED_SPACE(dev));
 	ip6_nd_hdr(sk, skb, dev, saddr, daddr, IPPROTO_ICMPV6, len);
 
         hdr = (struct icmp6hdr *)skb_put(skb, len);
@@ -1305,7 +1305,7 @@
 	rd_len &= ~0x7;
 	len += rd_len;
 
-	buff = sock_alloc_send_skb(sk, MAX_HEADER + len + dev->hard_header_len + 15,
+	buff = sock_alloc_send_skb(sk, MAX_HEADER + len + LL_RESERVED_SPACE(dev),
 				   1, &err);
 	if (buff == NULL) {
 		ND_PRINTK1("ndisc_send_redirect: alloc_skb failed\n");
@@ -1315,7 +1315,7 @@
 
 	hlen = 0;
 
-	skb_reserve(buff, (dev->hard_header_len + 15) & ~15);
+	skb_reserve(buff, LL_RESERVED_SPACE(dev));
 	ip6_nd_hdr(sk, buff, dev, &saddr_buf, &skb->nh.ipv6h->saddr,
 		   IPPROTO_ICMPV6, len);
 


-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
