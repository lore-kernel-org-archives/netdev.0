From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next 3/5] vxlan: move ECN decapsulation to a separate function
Date: Tue, 23 Feb 2016 18:02:57 +0100
Message-ID: <a573f52d4f121f5df6228d08cd8f25d4452bbcfb.1456246786.git.jbenc@redhat.com>
References: <cover.1456246786.git.jbenc@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45809 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754217AbcBWRDK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Feb 2016 12:03:10 -0500
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (Postfix) with ESMTPS id A1E753F3AF
	for <netdev@vger.kernel.org>; Tue, 23 Feb 2016 17:03:10 +0000 (UTC)
Received: from griffin.upir.cz (ovpn-204-63.brq.redhat.com [10.40.204.63])
	by int-mx10.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id u1NH36AG008009
	for <netdev@vger.kernel.org>; Tue, 23 Feb 2016 12:03:10 -0500
In-Reply-To: <cover.1456246786.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It simplifies the vxlan_rcv function.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 drivers/net/vxlan.c | 62 ++++++++++++++++++++++++++---------------------------
 1 file changed, 31 insertions(+), 31 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 68a8f9f43e2a..382535bc9e59 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1205,7 +1205,7 @@ static bool vxlan_set_mac(struct vxlan_dev *vxlan,
 	if (ether_addr_equal(eth_hdr(skb)->h_source, vxlan->dev->dev_addr))
 		return false;
 
-	/* Get data from the outer IP header */
+	/* Get address from the outer IP header */
 	if (vxlan_get_sk_family(vs) == AF_INET) {
 		saddr.sin.sin_addr.s_addr = ip_hdr(skb)->saddr;
 		saddr.sa.sa_family = AF_INET;
@@ -1223,52 +1223,52 @@ static bool vxlan_set_mac(struct vxlan_dev *vxlan,
 	return true;
 }
 
+static bool vxlan_ecn_decapsulate(struct vxlan_sock *vs, void *oiph,
+				  struct sk_buff *skb)
+{
+	int err = 0;
+
+	if (vxlan_get_sk_family(vs) == AF_INET)
+		err = IP_ECN_decapsulate(oiph, skb);
+#if IS_ENABLED(CONFIG_IPV6)
+	else
+		err = IP6_ECN_decapsulate(oiph, skb);
+#endif
+
+	if (unlikely(err) && log_ecn_error) {
+		if (vxlan_get_sk_family(vs) == AF_INET)
+			net_info_ratelimited("non-ECT from %pI4 with TOS=%#x\n",
+					     &((struct iphdr *)oiph)->saddr,
+					     ((struct iphdr *)oiph)->tos);
+		else
+			net_info_ratelimited("non-ECT from %pI6\n",
+					     &((struct ipv6hdr *)oiph)->saddr);
+	}
+	return err <= 1;
+}
+
 static void vxlan_rcv(struct vxlan_dev *vxlan, struct vxlan_sock *vs,
 		      struct sk_buff *skb, struct vxlan_metadata *md,
 		      struct metadata_dst *tun_dst)
 {
-	struct iphdr *oip = NULL;
-	struct ipv6hdr *oip6 = NULL;
 	struct pcpu_sw_netstats *stats;
-	int err = 0;
+	void *oiph;
 
 	if (!vxlan_set_mac(vxlan, vs, skb))
 		goto drop;
 
-	/* Get data from the outer IP header */
-	if (vxlan_get_sk_family(vs) == AF_INET)
-		oip = ip_hdr(skb);
-#if IS_ENABLED(CONFIG_IPV6)
-	else
-		oip6 = ipv6_hdr(skb);
-#endif
-
 	if (tun_dst) {
 		skb_dst_set(skb, (struct dst_entry *)tun_dst);
 		tun_dst = NULL;
 	}
 
+	oiph = skb_network_header(skb);
 	skb_reset_network_header(skb);
 
-	if (oip6)
-		err = IP6_ECN_decapsulate(oip6, skb);
-	if (oip)
-		err = IP_ECN_decapsulate(oip, skb);
-
-	if (unlikely(err)) {
-		if (log_ecn_error) {
-			if (oip6)
-				net_info_ratelimited("non-ECT from %pI6\n",
-						     &oip6->saddr);
-			if (oip)
-				net_info_ratelimited("non-ECT from %pI4 with TOS=%#x\n",
-						     &oip->saddr, oip->tos);
-		}
-		if (err > 1) {
-			++vxlan->dev->stats.rx_frame_errors;
-			++vxlan->dev->stats.rx_errors;
-			goto drop;
-		}
+	if (!vxlan_ecn_decapsulate(vs, oiph, skb)) {
+		++vxlan->dev->stats.rx_frame_errors;
+		++vxlan->dev->stats.rx_errors;
+		goto drop;
 	}
 
 	stats = this_cpu_ptr(vxlan->dev->tstats);
-- 
1.8.3.1
