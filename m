From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/16] i40e: Implement ndo_features_check()
Date: Mon, 13 Jul 2015 02:08:22 -0700
Message-ID: <1436778517-16254-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1436778517-16254-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Joe Stringer <joestringer@nicira.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jesse Gross <jesse@nicira.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:28267 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751712AbbGMJIp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Jul 2015 05:08:45 -0400
In-Reply-To: <1436778517-16254-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Stringer <joestringer@nicira.com>

i40e supports UDP tunnel headers up to 80 bytes in length, so
this adds a check to ensure that it doesn't try to offload
packets that exceed that.

Signed-off-by: Joe Stringer <joestringer@nicira.com>
Signed-off-by: Jesse Gross <jesse@nicira.com>
Acked-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 20 ++++++++++++++++++++
 1 file changed, 20 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 48a52b3..b44eb35 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -8099,6 +8099,25 @@ static int i40e_ndo_bridge_getlink(struct sk_buff *skb, u32 pid, u32 seq,
 }
 #endif /* HAVE_BRIDGE_ATTRIBS */
 
+#define I40E_MAX_TUNNEL_HDR_LEN 80
+/**
+ * i40e_features_check - Validate encapsulated packet conforms to limits
+ * @skb: skb buff
+ * @netdev: This physical port's netdev
+ * @features: Offload features that the stack believes apply
+ **/
+static netdev_features_t i40e_features_check(struct sk_buff *skb,
+					     struct net_device *dev,
+					     netdev_features_t features)
+{
+	if (skb->encapsulation &&
+	    (skb_inner_mac_header(skb) - skb_transport_header(skb) >
+	     I40E_MAX_TUNNEL_HDR_LEN))
+		return features & ~(NETIF_F_ALL_CSUM | NETIF_F_GSO_MASK);
+
+	return features;
+}
+
 static const struct net_device_ops i40e_netdev_ops = {
 	.ndo_open		= i40e_open,
 	.ndo_stop		= i40e_close,
@@ -8133,6 +8152,7 @@ static const struct net_device_ops i40e_netdev_ops = {
 #endif
 	.ndo_get_phys_port_id	= i40e_get_phys_port_id,
 	.ndo_fdb_add		= i40e_ndo_fdb_add,
+	.ndo_features_check	= i40e_features_check,
 #ifdef HAVE_BRIDGE_ATTRIBS
 	.ndo_bridge_getlink	= i40e_ndo_bridge_getlink,
 	.ndo_bridge_setlink	= i40e_ndo_bridge_setlink,
-- 
2.4.3
