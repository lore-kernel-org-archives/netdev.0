From: Li Wei <lw@cn.fujitsu.com>
Subject: [PATCH] ipv4: fix a bug in SRR option matching.
Date: Tue, 08 Nov 2011 15:56:40 +0800
Message-ID: <4EB8E0B8.40500@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:61900 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752163Ab1KHH4U (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Nov 2011 02:56:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since commit 7be799a7 (ipv4: Remove rt->rt_dst reference from
ip_forward_options()) and commit 0374d9ce (ipv4: Kill spurious
write to iph->daddr in ip_forward_options()) we use iph->daddr
for SRR option matching and assume iph->daddr equals to rt->rt_dst,
Unfortunately skb_rtable(skb) has been updated in ip_options_rcv_srr()
for the nexthop in SRR option but iph->daddr *not* updated,
We should use the updated rt->rt_dst for SRR option matching
and update iph->daddr here.

Signed-off-by: Li Wei <lw@cn.fujitsu.com>
---
 net/ipv4/ip_options.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/ip_options.c b/net/ipv4/ip_options.c
index ec93335..8dca67c 100644
--- a/net/ipv4/ip_options.c
+++ b/net/ipv4/ip_options.c
@@ -568,12 +568,13 @@ void ip_forward_options(struct sk_buff *skb)
 		     ) {
 			if (srrptr + 3 > srrspace)
 				break;
-			if (memcmp(&ip_hdr(skb)->daddr, &optptr[srrptr-1], 4) == 0)
+			if (memcmp(&rt->rt_dst, &optptr[srrptr-1], 4) == 0)
 				break;
 		}
 		if (srrptr + 3 <= srrspace) {
 			opt->is_changed = 1;
 			ip_rt_get_source(&optptr[srrptr-1], skb, rt);
+			ip_hdr(skb)->daddr = rt->rt_dst;
 			optptr[2] = srrptr+4;
 		} else if (net_ratelimit())
 			printk(KERN_CRIT "ip_forward(): Argh! Destination lost!\n");
-- 
1.7.3.2
