From: Li Wei <lw@cn.fujitsu.com>
Subject: [PATCH] ipv4: fix a bug in strict route gateway comparation.
Date: Tue, 08 Nov 2011 16:44:40 +0800
Message-ID: <4EB8EBF8.1080508@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:52430 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753534Ab1KHIoS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Nov 2011 03:44:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since commit def57687 (ipv4: Elide use of rt->rt_dst in ip_forward())
we use iph->daddr for strict route gateway comparation, Unfortunately
skb_rtable(skb) has been updated in ip_options_rcv_srr() for the
nexthop in SRR option but iph->daddr *not* updated, So rt->rt_dst is
not equals to iph->daddr, We should use the updated rt->rt_dst instead.

Signed-off-by: Li Wei <lw@cn.fujitsu.com>
---
 net/ipv4/ip_forward.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/ip_forward.c b/net/ipv4/ip_forward.c
index 3b34d1c..99461f0 100644
--- a/net/ipv4/ip_forward.c
+++ b/net/ipv4/ip_forward.c
@@ -84,7 +84,7 @@ int ip_forward(struct sk_buff *skb)
 
 	rt = skb_rtable(skb);
 
-	if (opt->is_strictroute && ip_hdr(skb)->daddr != rt->rt_gateway)
+	if (opt->is_strictroute && rt->rt_dst != rt->rt_gateway)
 		goto sr_failed;
 
 	if (unlikely(skb->len > dst_mtu(&rt->dst) && !skb_is_gso(skb) &&
-- 
1.7.3.2
