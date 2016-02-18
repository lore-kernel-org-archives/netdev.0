From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next 3/4] vxlan: move vxlan device lookup before iptunnel_pull_header
Date: Thu, 18 Feb 2016 11:22:51 +0100
Message-ID: <5e822e59301ca9f50e43084fe12fb5124a7d7c7b.1455790645.git.jbenc@redhat.com>
References: <cover.1455790645.git.jbenc@redhat.com>
Cc: Jesse Gross <jesse@kernel.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44803 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1426223AbcBRKXs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Feb 2016 05:23:48 -0500
In-Reply-To: <cover.1455790645.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is in preparation for iptunnel_pull_header calling skb_scrub_packet.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 drivers/net/vxlan.c | 23 +++++++++++------------
 1 file changed, 11 insertions(+), 12 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 3a84680b5117..b43981416fb9 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1187,22 +1187,16 @@ out:
 	unparsed->vx_flags &= ~VXLAN_GBP_USED_BITS;
 }
 
-static void vxlan_rcv(struct vxlan_sock *vs, struct sk_buff *skb,
-		      struct vxlan_metadata *md, __be32 vni,
+static void vxlan_rcv(struct vxlan_dev *vxlan, struct vxlan_sock *vs,
+		      struct sk_buff *skb, struct vxlan_metadata *md,
 		      struct metadata_dst *tun_dst)
 {
 	struct iphdr *oip = NULL;
 	struct ipv6hdr *oip6 = NULL;
-	struct vxlan_dev *vxlan;
 	struct pcpu_sw_netstats *stats;
 	union vxlan_addr saddr;
 	int err = 0;
 
-	/* Is this VNI defined? */
-	vxlan = vxlan_vs_find_vni(vs, vni);
-	if (!vxlan)
-		goto drop;
-
 	skb_reset_mac_header(skb);
 	skb_scrub_packet(skb, !net_eq(vxlan->net, dev_net(vxlan->dev)));
 	skb->protocol = eth_type_trans(skb, vxlan->dev);
@@ -1281,6 +1275,7 @@ drop:
 static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 {
 	struct metadata_dst *tun_dst = NULL;
+	struct vxlan_dev *vxlan;
 	struct vxlan_sock *vs;
 	struct vxlanhdr unparsed;
 	struct vxlan_metadata _md;
@@ -1302,13 +1297,17 @@ static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 	unparsed.vx_flags &= ~VXLAN_HF_VNI;
 	unparsed.vx_vni &= ~VXLAN_VNI_MASK;
 
-	if (iptunnel_pull_header(skb, VXLAN_HLEN, htons(ETH_P_TEB)))
-		goto drop;
-
 	vs = rcu_dereference_sk_user_data(sk);
 	if (!vs)
 		goto drop;
 
+	vxlan = vxlan_vs_find_vni(vs, vxlan_vni(vxlan_hdr(skb)->vx_vni));
+	if (!vxlan)
+		goto drop;
+
+	if (iptunnel_pull_header(skb, VXLAN_HLEN, htons(ETH_P_TEB)))
+		goto drop;
+
 	if (vxlan_collect_metadata(vs)) {
 		tun_dst = udp_tun_rx_dst(skb, vxlan_get_sk_family(vs), TUNNEL_KEY,
 					 vxlan_vni(vxlan_hdr(skb)->vx_vni),
@@ -1343,7 +1342,7 @@ static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 		goto drop;
 	}
 
-	vxlan_rcv(vs, skb, md, vxlan_vni(vxlan_hdr(skb)->vx_vni), tun_dst);
+	vxlan_rcv(vxlan, vs, skb, md, tun_dst);
 	return 0;
 
 drop:
-- 
1.8.3.1
