From: Sriharsha Basavapatna <sriharsha.basavapatna@emulex.com>
Subject: [PATCH net] be2net: Allow GRE to work concurrently while a VxLAN tunnel is configured
Date: Thu, 15 Jan 2015 09:07:49 +0530
Message-ID: <1421293069-30518-1-git-send-email-sriharsha.basavapatna@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.emulex.com ([138.239.224.99]:23778 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751241AbbANLLl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2015 06:11:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Other tunnels like GRE break while VxLAN offloads are enabled in Skyhawk-R. To
avoid this, we should restrict offload features on a per-packet basis in such
conditions.

Signed-off-by: Sriharsha Basavapatna <sriharsha.basavapatna@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |   41 +++++++++++++++++++++++++--
 1 file changed, 38 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 41a0a54..726a4a4 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -4383,8 +4383,9 @@ static int be_ndo_bridge_getlink(struct sk_buff *skb, u32 pid, u32 seq,
  * distinguish various types of transports (VxLAN, GRE, NVGRE ..). So, offload
  * is expected to work across all types of IP tunnels once exported. Skyhawk
  * supports offloads for either VxLAN or NVGRE, exclusively. So we export VxLAN
- * offloads in hw_enc_features only when a VxLAN port is added. Note this only
- * ensures that other tunnels work fine while VxLAN offloads are not enabled.
+ * offloads in hw_enc_features only when a VxLAN port is added. If other (non
+ * VxLAN) tunnels are configured while VxLAN offloads are enabled, offloads for
+ * those other tunnels are unexported on the fly through ndo_features_check().
  *
  * Skyhawk supports VxLAN offloads only for one UDP dport. So, if the stack
  * adds more than one port, disable offloads and don't re-enable them again
@@ -4463,7 +4464,41 @@ static netdev_features_t be_features_check(struct sk_buff *skb,
 					   struct net_device *dev,
 					   netdev_features_t features)
 {
-	return vxlan_features_check(skb, features);
+	struct be_adapter *adapter = netdev_priv(dev);
+	u8 l4_hdr = 0;
+
+	/* The code below restricts offload features for some tunneled packets.
+	 * Offload features for normal(non tunnel) packets are unchanged.
+	 */
+	if (!skb->encapsulation ||
+	    !(adapter->flags & BE_FLAGS_VXLAN_OFFLOADS))
+		return features;
+
+	/* It's an encapsulated packet and VxLAN offloads are enabled. We
+	 * should disable tunnel offload features if it's not a VxLAN packet,
+	 * as tunnel offloads have been enabled only for VxLAN. This is done to
+	 * allow other tunneled trafffic like GRE work fine while VxLAN
+	 * offloads are configured in Skyhawk-R.
+	 */
+	switch (vlan_get_protocol(skb)) {
+	case htons(ETH_P_IP):
+		l4_hdr = ip_hdr(skb)->protocol;
+		break;
+	case htons(ETH_P_IPV6):
+		l4_hdr = ipv6_hdr(skb)->nexthdr;
+		break;
+	default:
+		return features;
+	}
+
+	if (l4_hdr != IPPROTO_UDP ||
+	    skb->inner_protocol_type != ENCAP_TYPE_ETHER ||
+	    skb->inner_protocol != htons(ETH_P_TEB) ||
+	    (skb_inner_mac_header(skb) - skb_transport_header(skb) !=
+	    sizeof(struct udphdr) + sizeof(struct vxlanhdr)))
+		return features & ~(NETIF_F_ALL_CSUM | NETIF_F_GSO_MASK);
+
+	return features;
 }
 #endif
 
-- 
1.7.9.5
