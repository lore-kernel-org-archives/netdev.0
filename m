From: Gui Jianfeng <guijianfeng@cn.fujitsu.com>
Subject: [PATCH 2.4.35.3] Fix the "InAddrErrors" increasing problem
Date: Mon, 22 Oct 2007 14:07:07 +0800
Message-ID: <471C3E0B.2070602@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [222.73.24.84] ([222.73.24.84]:65216 "EHLO song.cn.fujitsu.com"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750908AbXJVGKt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Oct 2007 02:10:49 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,
When kernel receives a package with a wrong destination ipv4 address, it can't increase "InAddrErrors" number correctly.
InAddrErrors is located in /proc/net/snmp.

This is a patch for fixing this problem.

Signed-off-by: Gui Jianfeng <guijianfeng@cn.fujitsu.com>
---
diff -Narup linux-2.4.35.3/net/ipv4/ip_input.c linux-2.4.35.3-prep/net/ipv4/ip_input.c
--- linux-2.4.35.3/net/ipv4/ip_input.c	2007-09-24 06:02:58.000000000 +0800
+++ linux-2.4.35.3-prep/net/ipv4/ip_input.c	2007-09-26 01:24:08.000000000 +0800
@@ -310,8 +310,12 @@ static inline int ip_rcv_finish(struct s
 	 *	how the packet travels inside Linux networking.
 	 */ 
 	if (skb->dst == NULL) {
-		if (ip_route_input(skb, iph->daddr, iph->saddr, iph->tos, dev))
-			goto drop; 
+		int err = ip_route_input(skb, iph->daddr, iph->saddr, iph->tos, dev);
+		if (unlikely(err)) {
+			if (err == -EHOSTUNREACH)
+				IP_INC_STATS_BH(IpInAddrErrors);
+		}
+		goto drop; 
 	}
 
 #ifdef CONFIG_NET_CLS_ROUTE
diff -Narup linux-2.4.35.3/net/ipv4/route.c linux-2.4.35.3-prep/net/ipv4/route.c
--- linux-2.4.35.3/net/ipv4/route.c	2007-09-24 06:02:58.000000000 +0800
+++ linux-2.4.35.3-prep/net/ipv4/route.c	2007-09-26 01:26:15.000000000 +0800
@@ -1450,7 +1450,7 @@ int ip_route_input_slow(struct sk_buff *
 	 */
 	if ((err = fib_lookup(&key, &res)) != 0) {
 		if (!IN_DEV_FORWARD(in_dev))
-			goto e_inval;
+			goto e_hostunreach;
 		goto no_route;
 	}
 	free_res = 1;
@@ -1499,7 +1499,7 @@ int ip_route_input_slow(struct sk_buff *
 	}
 
 	if (!IN_DEV_FORWARD(in_dev))
-		goto e_inval;
+		goto e_hostunreach;
 	if (res.type != RTN_UNICAST)
 		goto martian_destination;
 
@@ -1668,6 +1668,11 @@ martian_destination:
 			"%u.%u.%u.%u, dev %s\n",
 			NIPQUAD(daddr), NIPQUAD(saddr), dev->name);
 #endif
+
+e_hostunreach:
+	err = -EHOSTUNREACH;
+	goto done;
+
 e_inval:
 	err = -EINVAL;
 	goto done;


