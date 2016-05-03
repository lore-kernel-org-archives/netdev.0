From: Jarno Rajahalme <jarno@ovn.org>
Subject: [PATCH net v3 1/2] udp_tunnel: Remove redundant udp_tunnel_gro_complete().
Date: Tue,  3 May 2016 16:10:20 -0700
Message-ID: <1462317021-7236-1-git-send-email-jarno@ovn.org>
Cc: jesse@kernel.org, jarno@ovn.org
To: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay4-d.mail.gandi.net ([217.70.183.196]:33456 "EHLO
	relay4-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756537AbcECXLH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 May 2016 19:11:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The setting of the UDP tunnel GSO type is already performed by
udp[46]_gro_complete().

Signed-off-by: Jarno Rajahalme <jarno@ovn.org>
---
 drivers/net/geneve.c     | 2 --
 drivers/net/vxlan.c      | 2 --
 include/net/udp_tunnel.h | 9 ---------
 net/ipv4/fou.c           | 2 --
 4 files changed, 15 deletions(-)

diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
index bc16889..98f1224 100644
--- a/drivers/net/geneve.c
+++ b/drivers/net/geneve.c
@@ -504,8 +504,6 @@ static int geneve_gro_complete(struct sk_buff *skb, int nhoff,
 	int gh_len;
 	int err = -ENOSYS;
 
-	udp_tunnel_gro_complete(skb, nhoff);
-
 	gh = (struct genevehdr *)(skb->data + nhoff);
 	gh_len = geneve_hlen(gh);
 	type = gh->proto_type;
diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 1c0fa36..dd2d032 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -616,8 +616,6 @@ out:
 static int vxlan_gro_complete(struct sk_buff *skb, int nhoff,
 			      struct udp_offload *uoff)
 {
-	udp_tunnel_gro_complete(skb, nhoff);
-
 	return eth_gro_complete(skb, nhoff + sizeof(struct vxlanhdr));
 }
 
diff --git a/include/net/udp_tunnel.h b/include/net/udp_tunnel.h
index b831140..a114024 100644
--- a/include/net/udp_tunnel.h
+++ b/include/net/udp_tunnel.h
@@ -106,15 +106,6 @@ static inline struct sk_buff *udp_tunnel_handle_offloads(struct sk_buff *skb,
 	return iptunnel_handle_offloads(skb, type);
 }
 
-static inline void udp_tunnel_gro_complete(struct sk_buff *skb, int nhoff)
-{
-	struct udphdr *uh;
-
-	uh = (struct udphdr *)(skb->data + nhoff - sizeof(struct udphdr));
-	skb_shinfo(skb)->gso_type |= uh->check ?
-				SKB_GSO_UDP_TUNNEL_CSUM : SKB_GSO_UDP_TUNNEL;
-}
-
 static inline void udp_tunnel_encap_enable(struct socket *sock)
 {
 #if IS_ENABLED(CONFIG_IPV6)
diff --git a/net/ipv4/fou.c b/net/ipv4/fou.c
index a39068b..305d9ac 100644
--- a/net/ipv4/fou.c
+++ b/net/ipv4/fou.c
@@ -228,8 +228,6 @@ static int fou_gro_complete(struct sk_buff *skb, int nhoff,
 	int err = -ENOSYS;
 	const struct net_offload **offloads;
 
-	udp_tunnel_gro_complete(skb, nhoff);
-
 	rcu_read_lock();
 	offloads = NAPI_GRO_CB(skb)->is_ipv6 ? inet6_offloads : inet_offloads;
 	ops = rcu_dereference(offloads[proto]);
-- 
2.7.4
