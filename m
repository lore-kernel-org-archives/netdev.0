From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net] ip6_tunnel: disable caching when the traffic class is inherited
Date: Wed, 16 Nov 2016 16:26:46 +0100
Message-ID: <67662ec875375c86e95666a7e47fc61c3a869d86.1479309929.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        Liam McBirnie <liam.mcbirnie@boeing.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53090 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932808AbcKPP04 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 16 Nov 2016 10:26:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If an ip6 tunnel is configured to inherit the traffic class from
the inner header, the dst_cache must be disabled or it will foul
the policy routing.

The issue is apprently there since at leat Linux-2.6.12-rc2.

Reported-by: Liam McBirnie <liam.mcbirnie@boeing.com>
Cc: Liam McBirnie <liam.mcbirnie@boeing.com>
Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
 net/ipv6/ip6_tunnel.c | 13 +++++++++++--
 1 file changed, 11 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 8778456..0a4759b 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -1034,6 +1034,7 @@ int ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev, __u8 dsfield,
 	int mtu;
 	unsigned int psh_hlen = sizeof(struct ipv6hdr) + t->encap_hlen;
 	unsigned int max_headroom = psh_hlen;
+	bool use_cache = false;
 	u8 hop_limit;
 	int err = -1;
 
@@ -1066,7 +1067,15 @@ int ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev, __u8 dsfield,
 
 		memcpy(&fl6->daddr, addr6, sizeof(fl6->daddr));
 		neigh_release(neigh);
-	} else if (!fl6->flowi6_mark)
+	} else if (!(t->parms.flags &
+		     (IP6_TNL_F_USE_ORIG_TCLASS | IP6_TNL_F_USE_ORIG_FWMARK))) {
+		/* enable the cache only only if the routing decision does
+		 * not depend on the current inner header value
+		 */
+		use_cache = true;
+	}
+
+	if (use_cache)
 		dst = dst_cache_get(&t->dst_cache);
 
 	if (!ip6_tnl_xmit_ctl(t, &fl6->saddr, &fl6->daddr))
@@ -1150,7 +1159,7 @@ int ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev, __u8 dsfield,
 		if (t->encap.type != TUNNEL_ENCAP_NONE)
 			goto tx_err_dst_release;
 	} else {
-		if (!fl6->flowi6_mark && ndst)
+		if (use_cache && ndst)
 			dst_cache_set_ip6(&t->dst_cache, ndst, &fl6->saddr);
 	}
 	skb_dst_set(skb, dst);
-- 
1.8.3.1
