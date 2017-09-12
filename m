From: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Subject: [PATCH v2] geneve: Fix setting ttl value in collect metadata mode
Date: Tue, 12 Sep 2017 15:05:11 +0800
Message-ID: <1505199911-21153-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
To: "David S. Miller" <davem@davemloft.net>,
        pravin shelar <pshelar@ovn.org>,
        Girish Moodalbail <girish.moodalbail@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Similar to vxlan/ipip tunnel, if key->tos is zero in collect metadata
mode, tos should also fallback to ip{4,6}_dst_hoplimit.

Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>

---
Changes since v2:
  * Make the commit message more clearer.
---
 drivers/net/geneve.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
index f640407..d52a65f 100644
--- a/drivers/net/geneve.c
+++ b/drivers/net/geneve.c
@@ -834,11 +834,10 @@ static int geneve_xmit_skb(struct sk_buff *skb, struct net_device *dev,
 	sport = udp_flow_src_port(geneve->net, skb, 1, USHRT_MAX, true);
 	if (geneve->collect_md) {
 		tos = ip_tunnel_ecn_encap(key->tos, ip_hdr(skb), skb);
-		ttl = key->ttl;
 	} else {
 		tos = ip_tunnel_ecn_encap(fl4.flowi4_tos, ip_hdr(skb), skb);
-		ttl = key->ttl ? : ip4_dst_hoplimit(&rt->dst);
 	}
+	ttl = key->ttl ? : ip4_dst_hoplimit(&rt->dst);
 	df = key->tun_flags & TUNNEL_DONT_FRAGMENT ? htons(IP_DF) : 0;
 
 	err = geneve_build_skb(&rt->dst, skb, info, xnet, sizeof(struct iphdr));
@@ -873,12 +872,11 @@ static int geneve6_xmit_skb(struct sk_buff *skb, struct net_device *dev,
 	sport = udp_flow_src_port(geneve->net, skb, 1, USHRT_MAX, true);
 	if (geneve->collect_md) {
 		prio = ip_tunnel_ecn_encap(key->tos, ip_hdr(skb), skb);
-		ttl = key->ttl;
 	} else {
 		prio = ip_tunnel_ecn_encap(ip6_tclass(fl6.flowlabel),
 					   ip_hdr(skb), skb);
-		ttl = key->ttl ? : ip6_dst_hoplimit(dst);
 	}
+	ttl = key->ttl ? : ip6_dst_hoplimit(dst);
 	err = geneve_build_skb(dst, skb, info, xnet, sizeof(struct ipv6hdr));
 	if (unlikely(err))
 		return err;
-- 
1.8.3.1
