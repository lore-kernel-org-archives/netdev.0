From: Li Wei <lw@cn.fujitsu.com>
Subject: [PATCH v2] ipv4: Fix wrong order of ip_rt_get_source() and update
 iph->daddr.
Date: Fri, 10 Feb 2012 15:15:25 +0800
Message-ID: <4F34C40D.5010503@cn.fujitsu.com>
References: <4F34BDAD.8080608@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:62508 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753385Ab2BJHPV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Feb 2012 02:15:21 -0500
In-Reply-To: <4F34BDAD.8080608@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fix a bug which introduced by commit ac8a4810 (ipv4: Save
nexthop address of LSRR/SSRR option to IPCB.).In that patch, we saved
the nexthop of SRR in ip_option->nexthop and update iph->daddr until
we get to ip_forward_options(), but we need to update it before 
ip_rt_get_source(), otherwise we may get a wrong src.

Signed-off-by: Li Wei <lw@cn.fujitsu.com>
---
 net/ipv4/ip_options.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/ip_options.c b/net/ipv4/ip_options.c
index 1e60f76..42dd1a9 100644
--- a/net/ipv4/ip_options.c
+++ b/net/ipv4/ip_options.c
@@ -573,8 +573,8 @@ void ip_forward_options(struct sk_buff *skb)
 		}
 		if (srrptr + 3 <= srrspace) {
 			opt->is_changed = 1;
-			ip_rt_get_source(&optptr[srrptr-1], skb, rt);
 			ip_hdr(skb)->daddr = opt->nexthop;
+			ip_rt_get_source(&optptr[srrptr-1], skb, rt);
 			optptr[2] = srrptr+4;
 		} else if (net_ratelimit())
 			printk(KERN_CRIT "ip_forward(): Argh! Destination lost!\n");
-- 1.7.1 
