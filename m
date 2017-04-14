From: Matthias Schiffer <mschiffer@universe-factory.net>
Subject: [PATCH net-next v2 5/6] vxlan: fix snooping for link-local IPv6 addresses
Date: Fri, 14 Apr 2017 18:44:45 +0200
Message-ID: <99545c929ec12feb9d4ce1008d6b16ffb3b5e889.1492187126.git.mschiffer@universe-factory.net>
References: <cover.1492187126.git.mschiffer@universe-factory.net>
Cc: netdev@vger.kernel.org, dev@openvswitch.org,
        linux-kernel@vger.kernel.org
To: davem@davemloft.net, jbenc@redhat.com, hannes@stressinduktion.org,
        pshelar@ovn.org, aduyck@mirantis.com, roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from chaos.universe-factory.net ([37.72.148.22]:34348 "EHLO
        chaos.universe-factory.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751558AbdDNQo6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Apr 2017 12:44:58 -0400
In-Reply-To: <cover.1492187126.git.mschiffer@universe-factory.net>
In-Reply-To: <cover.1492187126.git.mschiffer@universe-factory.net>
References: <cover.1492187126.git.mschiffer@universe-factory.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If VXLAN is run over link-local IPv6 addresses, it is necessary to store
the ifindex in the FDB entries. Otherwise, the used interface is undefined
and unicast communication will most likely fail.

Signed-off-by: Matthias Schiffer <mschiffer@universe-factory.net>
---

v2: use u32 instead of __u32

 drivers/net/vxlan.c | 20 +++++++++++++++-----
 1 file changed, 15 insertions(+), 5 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 95a71546e8f2..2995b57a1551 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -941,16 +941,24 @@ static int vxlan_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb,
  */
 static bool vxlan_snoop(struct net_device *dev,
 			union vxlan_addr *src_ip, const u8 *src_mac,
-			__be32 vni)
+			u32 src_ifindex, __be32 vni)
 {
 	struct vxlan_dev *vxlan = netdev_priv(dev);
 	struct vxlan_fdb *f;
+	u32 ifindex = 0;
+
+#if IS_ENABLED(CONFIG_IPV6)
+	if (src_ip->sa.sa_family == AF_INET6 &&
+	    (ipv6_addr_type(&src_ip->sin6.sin6_addr) & IPV6_ADDR_LINKLOCAL))
+		ifindex = src_ifindex;
+#endif
 
 	f = vxlan_find_mac(vxlan, src_mac, vni);
 	if (likely(f)) {
 		struct vxlan_rdst *rdst = first_remote_rcu(f);
 
-		if (likely(vxlan_addr_equal(&rdst->remote_ip, src_ip)))
+		if (likely(vxlan_addr_equal(&rdst->remote_ip, src_ip) &&
+			   rdst->remote_ifindex == ifindex))
 			return false;
 
 		/* Don't migrate static entries, drop packets */
@@ -977,7 +985,7 @@ static bool vxlan_snoop(struct net_device *dev,
 					 vxlan->cfg.dst_port,
 					 vni,
 					 vxlan->default_dst.remote_vni,
-					 0, NTF_SELF);
+					 ifindex, NTF_SELF);
 		spin_unlock(&vxlan->hash_lock);
 	}
 
@@ -1246,6 +1254,7 @@ static bool vxlan_set_mac(struct vxlan_dev *vxlan,
 			  struct sk_buff *skb, __be32 vni)
 {
 	union vxlan_addr saddr;
+	u32 ifindex = skb->dev->ifindex;
 
 	skb_reset_mac_header(skb);
 	skb->protocol = eth_type_trans(skb, vxlan->dev);
@@ -1267,7 +1276,7 @@ static bool vxlan_set_mac(struct vxlan_dev *vxlan,
 	}
 
 	if ((vxlan->cfg.flags & VXLAN_F_LEARN) &&
-	    vxlan_snoop(skb->dev, &saddr, eth_hdr(skb)->h_source, vni))
+	    vxlan_snoop(skb->dev, &saddr, eth_hdr(skb)->h_source, ifindex, vni))
 		return false;
 
 	return true;
@@ -1978,7 +1987,8 @@ static void vxlan_encap_bypass(struct sk_buff *skb, struct vxlan_dev *src_vxlan,
 	}
 
 	if (dst_vxlan->cfg.flags & VXLAN_F_LEARN)
-		vxlan_snoop(skb->dev, &loopback, eth_hdr(skb)->h_source, vni);
+		vxlan_snoop(skb->dev, &loopback, eth_hdr(skb)->h_source, 0,
+			    vni);
 
 	u64_stats_update_begin(&tx_stats->syncp);
 	tx_stats->tx_packets++;
-- 
2.12.2
