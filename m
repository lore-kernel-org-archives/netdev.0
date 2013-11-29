From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH] ipv6: fix possible seqlock deadlock in ip6_finish_output2
Date: Fri, 29 Nov 2013 06:39:44 +0100
Message-ID: <20131129053944.GH24171@order.stressinduktion.org>
References: <13025162.118881385612276530.JavaMail.weblogic@epv6ml01> <1385659390.5352.20.camel@edumazet-glaptop2.roam.corp.google.com> <1385661082.5352.34.camel@edumazet-glaptop2.roam.corp.google.com> <20131128192231.GE24171@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: Eric Dumazet <eric.dumazet@gmail.com>, jongman.heo@samsung.com,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:45835 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751156Ab3K2Fjp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Nov 2013 00:39:45 -0500
Content-Disposition: inline
In-Reply-To: <20131128192231.GE24171@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IPv6 stats are 64 bits and thus are protected with a seqlock. By not
disabling bottom-half we could deadlock here if we don't disable bh and
a softirq reentrantly updates the same mib.

Cc: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv6/ip6_output.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 59df872..4acdb63 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -116,8 +116,8 @@ static int ip6_finish_output2(struct sk_buff *skb)
 	}
 	rcu_read_unlock_bh();
 
-	IP6_INC_STATS_BH(dev_net(dst->dev),
-			 ip6_dst_idev(dst), IPSTATS_MIB_OUTNOROUTES);
+	IP6_INC_STATS(dev_net(dst->dev),
+		      ip6_dst_idev(dst), IPSTATS_MIB_OUTNOROUTES);
 	kfree_skb(skb);
 	return -EINVAL;
 }
-- 
1.8.3.1
