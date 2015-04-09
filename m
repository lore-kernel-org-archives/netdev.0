From: Jesse Gross <jesse@nicira.com>
Subject: [PATCH net] udptunnels: Call handle_offloads after inserting vlan tag.
Date: Thu,  9 Apr 2015 11:19:14 -0700
Message-ID: <1428603554-62449-1-git-send-email-jesse@nicira.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog103.obsmtp.com ([74.125.149.71]:60419 "HELO
	na3sys009aog103.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S932940AbbDISY7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Apr 2015 14:24:59 -0400
Received: by mail-pd0-f176.google.com with SMTP id qa5so104118467pdb.1
        for <netdev@vger.kernel.org>; Thu, 09 Apr 2015 11:24:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

handle_offloads() calls skb_reset_inner_headers() to store
the layer pointers to the encapsulated packet. However, we
currently push the vlag tag (if there is one) onto the packet
afterwards. This changes the MAC header for the encapsulated
packet but it is not reflected in skb->inner_mac_header, which
breaks GSO and drivers which attempt to use this for encapsulation
offloads.

Fixes: 1eaa8178 ("vxlan: Add tx-vlan offload support.")
Signed-off-by: Jesse Gross <jesse@nicira.com>
---
 drivers/net/vxlan.c | 20 ++++++++++----------
 net/ipv4/geneve.c   |  8 ++++----
 2 files changed, 14 insertions(+), 14 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index f8528a4..fceb637 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1713,12 +1713,6 @@ static int vxlan6_xmit_skb(struct dst_entry *dst, struct sk_buff *skb,
 		}
 	}
 
-	skb = iptunnel_handle_offloads(skb, udp_sum, type);
-	if (IS_ERR(skb)) {
-		err = -EINVAL;
-		goto err;
-	}
-
 	skb_scrub_packet(skb, xnet);
 
 	min_headroom = LL_RESERVED_SPACE(dst->dev) + dst->header_len
@@ -1738,6 +1732,12 @@ static int vxlan6_xmit_skb(struct dst_entry *dst, struct sk_buff *skb,
 		goto err;
 	}
 
+	skb = iptunnel_handle_offloads(skb, udp_sum, type);
+	if (IS_ERR(skb)) {
+		err = -EINVAL;
+		goto err;
+	}
+
 	vxh = (struct vxlanhdr *) __skb_push(skb, sizeof(*vxh));
 	vxh->vx_flags = htonl(VXLAN_HF_VNI);
 	vxh->vx_vni = md->vni;
@@ -1798,10 +1798,6 @@ int vxlan_xmit_skb(struct rtable *rt, struct sk_buff *skb,
 		}
 	}
 
-	skb = iptunnel_handle_offloads(skb, udp_sum, type);
-	if (IS_ERR(skb))
-		return PTR_ERR(skb);
-
 	min_headroom = LL_RESERVED_SPACE(rt->dst.dev) + rt->dst.header_len
 			+ VXLAN_HLEN + sizeof(struct iphdr)
 			+ (skb_vlan_tag_present(skb) ? VLAN_HLEN : 0);
@@ -1817,6 +1813,10 @@ int vxlan_xmit_skb(struct rtable *rt, struct sk_buff *skb,
 	if (WARN_ON(!skb))
 		return -ENOMEM;
 
+	skb = iptunnel_handle_offloads(skb, udp_sum, type);
+	if (IS_ERR(skb))
+		return PTR_ERR(skb);
+
 	vxh = (struct vxlanhdr *) __skb_push(skb, sizeof(*vxh));
 	vxh->vx_flags = htonl(VXLAN_HF_VNI);
 	vxh->vx_vni = md->vni;
diff --git a/net/ipv4/geneve.c b/net/ipv4/geneve.c
index 5a4828b..a566a2e 100644
--- a/net/ipv4/geneve.c
+++ b/net/ipv4/geneve.c
@@ -113,10 +113,6 @@ int geneve_xmit_skb(struct geneve_sock *gs, struct rtable *rt,
 	int min_headroom;
 	int err;
 
-	skb = udp_tunnel_handle_offloads(skb, csum);
-	if (IS_ERR(skb))
-		return PTR_ERR(skb);
-
 	min_headroom = LL_RESERVED_SPACE(rt->dst.dev) + rt->dst.header_len
 			+ GENEVE_BASE_HLEN + opt_len + sizeof(struct iphdr)
 			+ (skb_vlan_tag_present(skb) ? VLAN_HLEN : 0);
@@ -131,6 +127,10 @@ int geneve_xmit_skb(struct geneve_sock *gs, struct rtable *rt,
 	if (unlikely(!skb))
 		return -ENOMEM;
 
+	skb = udp_tunnel_handle_offloads(skb, csum);
+	if (IS_ERR(skb))
+		return PTR_ERR(skb);
+
 	gnvh = (struct genevehdr *)__skb_push(skb, sizeof(*gnvh) + opt_len);
 	geneve_build_header(gnvh, tun_flags, vni, opt_len, opt);
 
-- 
1.9.1
