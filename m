From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net 2/3] geneve: fix populating tclass in geneve_get_v6_dst
Date: Fri, 18 Mar 2016 18:37:58 +0100
Message-ID: <73f5bfcfdd04238271b2d47b18c078e3d43f9869.1458320940.git.daniel@iogearbox.net>
References: <cover.1458320940.git.daniel@iogearbox.net>
Cc: jbenc@redhat.com, linville@tuxdriver.com, jesse@kernel.org,
	dsa@cumulusnetworks.com, alexei.starovoitov@gmail.com,
	netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:53386 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757559AbcCRRiS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Mar 2016 13:38:18 -0400
In-Reply-To: <cover.1458320940.git.daniel@iogearbox.net>
In-Reply-To: <cover.1458320940.git.daniel@iogearbox.net>
References: <cover.1458320940.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The struct flowi6's flowi6_tos is not used in IPv6 route lookup, the
traffic class information is handled in the flowi6's flowlabel member
instead. For example, for policy routing, fib6_rule_match() uses
ip6_tclass() that is applied on the flowlabel for matching on tclass,
which would currently not work as expected.

Fixes: 3a56f86f1be6 ("geneve: handle ipv6 priority like ipv4 tos")
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 drivers/net/geneve.c | 11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
index 192631a..bc16889 100644
--- a/drivers/net/geneve.c
+++ b/drivers/net/geneve.c
@@ -843,8 +843,8 @@ static struct dst_entry *geneve_get_v6_dst(struct sk_buff *skb,
 	if (info) {
 		fl6->daddr = info->key.u.ipv6.dst;
 		fl6->saddr = info->key.u.ipv6.src;
-		fl6->flowi6_tos = RT_TOS(info->key.tos);
-		fl6->flowlabel = info->key.label;
+		fl6->flowlabel = ip6_make_flowinfo(RT_TOS(info->key.tos),
+						   info->key.label);
 		dst_cache = &info->dst_cache;
 	} else {
 		prio = geneve->tos;
@@ -855,8 +855,8 @@ static struct dst_entry *geneve_get_v6_dst(struct sk_buff *skb,
 			use_cache = false;
 		}
 
-		fl6->flowi6_tos = RT_TOS(prio);
-		fl6->flowlabel = geneve->label;
+		fl6->flowlabel = ip6_make_flowinfo(RT_TOS(prio),
+						   geneve->label);
 		fl6->daddr = geneve->remote.sin6.sin6_addr;
 		dst_cache = &geneve->dst_cache;
 	}
@@ -1049,7 +1049,8 @@ static netdev_tx_t geneve6_xmit_skb(struct sk_buff *skb, struct net_device *dev,
 		if (unlikely(err))
 			goto err;
 
-		prio = ip_tunnel_ecn_encap(fl6.flowi6_tos, iip, skb);
+		prio = ip_tunnel_ecn_encap(ip6_tclass(fl6.flowlabel),
+					   iip, skb);
 		ttl = geneve->ttl;
 		if (!ttl && ipv6_addr_is_multicast(&fl6.daddr))
 			ttl = 1;
-- 
1.9.3
