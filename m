From: Li Wei <lw@cn.fujitsu.com>
Subject: [PATCH] ipv4: Save nexthop address of LSRR/SSRR option to IPCB.
Date: Wed, 23 Nov 2011 17:33:10 +0800
Message-ID: <4ECCBDD6.8080708@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:56588 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750959Ab1KWJc7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Nov 2011 04:32:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We can not update iph->daddr in ip_options_rcv_srr(), It is too early.
When some exception ocurred later (eg. in ip_forward() when goto
sr_failed) we need the ip header be identical to the original one as
ICMP need it.

Add a field 'nexthop' in struct ip_options to save nexthop of LSRR
or SSRR option.

Signed-off-by: Li Wei <lw@cn.fujitsu.com>
---
 include/net/inet_sock.h |    2 ++
 net/ipv4/ip_forward.c   |    2 +-
 net/ipv4/ip_options.c   |    5 +++--
 3 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/include/net/inet_sock.h b/include/net/inet_sock.h
index b897d6e..f941964 100644
--- a/include/net/inet_sock.h
+++ b/include/net/inet_sock.h
@@ -31,6 +31,7 @@
 /** struct ip_options - IP Options
  *
  * @faddr - Saved first hop address
+ * @nexthop - Saved nexthop address in LSRR and SSRR
  * @is_data - Options in __data, rather than skb
  * @is_strictroute - Strict source route
  * @srr_is_hit - Packet destination addr was our one
@@ -41,6 +42,7 @@
  */
 struct ip_options {
 	__be32		faddr;
+	__be32		nexthop;
 	unsigned char	optlen;
 	unsigned char	srr;
 	unsigned char	rr;
diff --git a/net/ipv4/ip_forward.c b/net/ipv4/ip_forward.c
index 3b34d1c..29a07b6 100644
--- a/net/ipv4/ip_forward.c
+++ b/net/ipv4/ip_forward.c
@@ -84,7 +84,7 @@ int ip_forward(struct sk_buff *skb)
 
 	rt = skb_rtable(skb);
 
-	if (opt->is_strictroute && ip_hdr(skb)->daddr != rt->rt_gateway)
+	if (opt->is_strictroute && opt->nexthop != rt->rt_gateway)
 		goto sr_failed;
 
 	if (unlikely(skb->len > dst_mtu(&rt->dst) && !skb_is_gso(skb) &&
diff --git a/net/ipv4/ip_options.c b/net/ipv4/ip_options.c
index 05d20cc..1e60f76 100644
--- a/net/ipv4/ip_options.c
+++ b/net/ipv4/ip_options.c
@@ -568,12 +568,13 @@ void ip_forward_options(struct sk_buff *skb)
 		     ) {
 			if (srrptr + 3 > srrspace)
 				break;
-			if (memcmp(&ip_hdr(skb)->daddr, &optptr[srrptr-1], 4) == 0)
+			if (memcmp(&opt->nexthop, &optptr[srrptr-1], 4) == 0)
 				break;
 		}
 		if (srrptr + 3 <= srrspace) {
 			opt->is_changed = 1;
 			ip_rt_get_source(&optptr[srrptr-1], skb, rt);
+			ip_hdr(skb)->daddr = opt->nexthop;
 			optptr[2] = srrptr+4;
 		} else if (net_ratelimit())
 			printk(KERN_CRIT "ip_forward(): Argh! Destination lost!\n");
@@ -640,7 +641,7 @@ int ip_options_rcv_srr(struct sk_buff *skb)
 	}
 	if (srrptr <= srrspace) {
 		opt->srr_is_hit = 1;
-		iph->daddr = nexthop;
+		opt->nexthop = nexthop;
 		opt->is_changed = 1;
 	}
 	return 0;
-- 
1.7.3.2
