From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/18] i40evf: Be much more verbose about what we can and cannot offload
Date: Sat,  3 Dec 2016 01:19:14 -0800
Message-ID: <20161203091930.14268-3-jeffrey.t.kirsher@intel.com>
References: <20161203091930.14268-1-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:18542 "EHLO mga09.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750833AbcLCJU2 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 3 Dec 2016 04:20:28 -0500
In-Reply-To: <20161203091930.14268-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change makes it so that we are much more robust about defining what we
can and cannot offload.  Previously we were performing no checks.  This
should bring us up to parity with the i40e PF driver.

In addition the device only supports GSO as long as the MSS is 64 or
greater.  We were not checking this so an MSS less than that was resulting
in Tx hangs.

Change-ID: If533553ec92fc6ba694eab6ac81fdaf3004f3592
Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 59 +++++++++++++++++++++++++
 1 file changed, 59 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index db36744..7bbb55f 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -2172,6 +2172,64 @@ static int i40evf_change_mtu(struct net_device *netdev, int new_mtu)
 	return 0;
 }
 
+/**
+ * i40evf_features_check - Validate encapsulated packet conforms to limits
+ * @skb: skb buff
+ * @netdev: This physical port's netdev
+ * @features: Offload features that the stack believes apply
+ **/
+static netdev_features_t i40evf_features_check(struct sk_buff *skb,
+					       struct net_device *dev,
+					       netdev_features_t features)
+{
+	size_t len;
+
+	/* No point in doing any of this if neither checksum nor GSO are
+	 * being requested for this frame.  We can rule out both by just
+	 * checking for CHECKSUM_PARTIAL
+	 */
+	if (skb->ip_summed != CHECKSUM_PARTIAL)
+		return features;
+
+	/* We cannot support GSO if the MSS is going to be less than
+	 * 64 bytes.  If it is then we need to drop support for GSO.
+	 */
+	if (skb_is_gso(skb) && (skb_shinfo(skb)->gso_size < 64))
+		features &= ~NETIF_F_GSO_MASK;
+
+	/* MACLEN can support at most 63 words */
+	len = skb_network_header(skb) - skb->data;
+	if (len & ~(63 * 2))
+		goto out_err;
+
+	/* IPLEN and EIPLEN can support at most 127 dwords */
+	len = skb_transport_header(skb) - skb_network_header(skb);
+	if (len & ~(127 * 4))
+		goto out_err;
+
+	if (skb->encapsulation) {
+		/* L4TUNLEN can support 127 words */
+		len = skb_inner_network_header(skb) - skb_transport_header(skb);
+		if (len & ~(127 * 2))
+			goto out_err;
+
+		/* IPLEN can support at most 127 dwords */
+		len = skb_inner_transport_header(skb) -
+		      skb_inner_network_header(skb);
+		if (len & ~(127 * 4))
+			goto out_err;
+	}
+
+	/* No need to validate L4LEN as TCP is the only protocol with a
+	 * a flexible value and we support all possible values supported
+	 * by TCP, which is at most 15 dwords
+	 */
+
+	return features;
+out_err:
+	return features & ~(NETIF_F_CSUM_MASK | NETIF_F_GSO_MASK);
+}
+
 #define I40EVF_VLAN_FEATURES (NETIF_F_HW_VLAN_CTAG_TX |\
 			      NETIF_F_HW_VLAN_CTAG_RX |\
 			      NETIF_F_HW_VLAN_CTAG_FILTER)
@@ -2206,6 +2264,7 @@ static const struct net_device_ops i40evf_netdev_ops = {
 	.ndo_tx_timeout		= i40evf_tx_timeout,
 	.ndo_vlan_rx_add_vid	= i40evf_vlan_rx_add_vid,
 	.ndo_vlan_rx_kill_vid	= i40evf_vlan_rx_kill_vid,
+	.ndo_features_check	= i40evf_features_check,
 	.ndo_fix_features	= i40evf_fix_features,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= i40evf_netpoll,
-- 
2.9.3
