From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next 4/5] vxlan: consolidate rx handling to a single function
Date: Tue, 23 Feb 2016 18:02:58 +0100
Message-ID: <9a9721f44c501adfd66d4bb84e28e684191458f3.1456246786.git.jbenc@redhat.com>
References: <cover.1456246786.git.jbenc@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58248 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752858AbcBWRDL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Feb 2016 12:03:11 -0500
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (Postfix) with ESMTPS id 9CFB2C0C6C03
	for <netdev@vger.kernel.org>; Tue, 23 Feb 2016 17:03:11 +0000 (UTC)
Received: from griffin.upir.cz (ovpn-204-63.brq.redhat.com [10.40.204.63])
	by int-mx10.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id u1NH36AH008009
	for <netdev@vger.kernel.org>; Tue, 23 Feb 2016 12:03:11 -0500
In-Reply-To: <cover.1456246786.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now when both vxlan_udp_encap_recv and vxlan_rcv are much shorter, combine
them into a single function.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 drivers/net/vxlan.c | 72 +++++++++++++++++++++--------------------------------
 1 file changed, 28 insertions(+), 44 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 382535bc9e59..cfd6deb9f090 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1247,56 +1247,17 @@ static bool vxlan_ecn_decapsulate(struct vxlan_sock *vs, void *oiph,
 	return err <= 1;
 }
 
-static void vxlan_rcv(struct vxlan_dev *vxlan, struct vxlan_sock *vs,
-		      struct sk_buff *skb, struct vxlan_metadata *md,
-		      struct metadata_dst *tun_dst)
-{
-	struct pcpu_sw_netstats *stats;
-	void *oiph;
-
-	if (!vxlan_set_mac(vxlan, vs, skb))
-		goto drop;
-
-	if (tun_dst) {
-		skb_dst_set(skb, (struct dst_entry *)tun_dst);
-		tun_dst = NULL;
-	}
-
-	oiph = skb_network_header(skb);
-	skb_reset_network_header(skb);
-
-	if (!vxlan_ecn_decapsulate(vs, oiph, skb)) {
-		++vxlan->dev->stats.rx_frame_errors;
-		++vxlan->dev->stats.rx_errors;
-		goto drop;
-	}
-
-	stats = this_cpu_ptr(vxlan->dev->tstats);
-	u64_stats_update_begin(&stats->syncp);
-	stats->rx_packets++;
-	stats->rx_bytes += skb->len;
-	u64_stats_update_end(&stats->syncp);
-
-	gro_cells_receive(&vxlan->gro_cells, skb);
-
-	return;
-drop:
-	if (tun_dst)
-		dst_release((struct dst_entry *)tun_dst);
-
-	/* Consume bad packet */
-	kfree_skb(skb);
-}
-
 /* Callback from net/ipv4/udp.c to receive packets */
-static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
+static int vxlan_rcv(struct sock *sk, struct sk_buff *skb)
 {
 	struct metadata_dst *tun_dst = NULL;
+	struct pcpu_sw_netstats *stats;
 	struct vxlan_dev *vxlan;
 	struct vxlan_sock *vs;
 	struct vxlanhdr unparsed;
 	struct vxlan_metadata _md;
 	struct vxlan_metadata *md = &_md;
+	void *oiph;
 
 	/* Need Vxlan and inner Ethernet header to be present */
 	if (!pskb_may_pull(skb, VXLAN_HLEN))
@@ -1361,7 +1322,30 @@ static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 		goto drop;
 	}
 
-	vxlan_rcv(vxlan, vs, skb, md, tun_dst);
+	if (!vxlan_set_mac(vxlan, vs, skb))
+		goto drop;
+
+	if (tun_dst) {
+		skb_dst_set(skb, (struct dst_entry *)tun_dst);
+		tun_dst = NULL;
+	}
+
+	oiph = skb_network_header(skb);
+	skb_reset_network_header(skb);
+
+	if (!vxlan_ecn_decapsulate(vs, oiph, skb)) {
+		++vxlan->dev->stats.rx_frame_errors;
+		++vxlan->dev->stats.rx_errors;
+		goto drop;
+	}
+
+	stats = this_cpu_ptr(vxlan->dev->tstats);
+	u64_stats_update_begin(&stats->syncp);
+	stats->rx_packets++;
+	stats->rx_bytes += skb->len;
+	u64_stats_update_end(&stats->syncp);
+
+	gro_cells_receive(&vxlan->gro_cells, skb);
 	return 0;
 
 drop:
@@ -2666,7 +2650,7 @@ static struct vxlan_sock *vxlan_socket_create(struct net *net, bool ipv6,
 	/* Mark socket as an encapsulation socket. */
 	tunnel_cfg.sk_user_data = vs;
 	tunnel_cfg.encap_type = 1;
-	tunnel_cfg.encap_rcv = vxlan_udp_encap_recv;
+	tunnel_cfg.encap_rcv = vxlan_rcv;
 	tunnel_cfg.encap_destroy = NULL;
 
 	setup_udp_tunnel_sock(net, sock, &tunnel_cfg);
-- 
1.8.3.1
