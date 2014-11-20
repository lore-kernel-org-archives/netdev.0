From: Joe Stringer <joestringer@nicira.com>
Subject: [PATCHv2 net] i40e: Implement ndo_gso_check()
Date: Thu, 20 Nov 2014 15:11:21 -0800
Message-ID: <1416525081-27779-1-git-send-email-joestringer@nicira.com>
Cc: shannon.nelson@intel.com, jesse.brandeburg@intel.com,
	jeffrey.t.kirsher@intel.com, therbert@google.com,
	linux.nics@intel.com, linux-kernel@vger.kernel.org,
	jesse@nicira.com
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ndo_gso_check() was recently introduced to allow NICs to report the
offloading support that they have on a per-skb basis. Add an
implementation for this driver which checks for IPIP, GRE, UDP tunnels.

Signed-off-by: Joe Stringer <joestringer@nicira.com>
---
v2: Expand to include IP in IP and IPv4/IPv6 inside GRE/UDP tunnels.
    Add MAX_INNER_LENGTH (as 80).
---
 drivers/net/ethernet/intel/i40e/i40e_main.c |   31 +++++++++++++++++++++++++++
 1 file changed, 31 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index c3a7f4a..2b01c8d 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -7447,6 +7447,36 @@ static int i40e_ndo_fdb_dump(struct sk_buff *skb,
 
 #endif /* USE_DEFAULT_FDB_DEL_DUMP */
 #endif /* HAVE_FDB_OPS */
+static bool i40e_gso_check(struct sk_buff *skb, struct net_device *dev)
+{
+	if ((skb_shinfo(skb)->gso_type & SKB_GSO_IPIP) &&
+	    (skb->inner_protocol_type != ENCAP_TYPE_IPPROTO ||
+	     skb->inner_protocol != htons(IPPROTO_IPIP))) {
+		return false;
+	}
+
+	if (skb_shinfo(skb)->gso_type & (SKB_GSO_GRE | SKB_GSO_UDP_TUNNEL)) {
+		unsigned char *ihdr;
+
+		if (skb->inner_protocol_type != ENCAP_TYPE_ETHER)
+			return false;
+
+		if (skb->inner_protocol == htons(ETH_P_TEB))
+			ihdr = skb_inner_mac_header(skb);
+		else if (skb->inner_protocol == htons(ETH_P_IP) ||
+			 skb->inner_protocol == htons(ETH_P_IPV6))
+			ihdr = skb_inner_network_header(skb);
+		else
+			return false;
+
+#define MAX_TUNNEL_HDR_LEN	80
+		if (ihdr - skb_transport_header(skb) > MAX_TUNNEL_HDR_LEN)
+			return false;
+	}
+
+	return true;
+}
+
 static const struct net_device_ops i40e_netdev_ops = {
 	.ndo_open		= i40e_open,
 	.ndo_stop		= i40e_close,
@@ -7487,6 +7517,7 @@ static const struct net_device_ops i40e_netdev_ops = {
 	.ndo_fdb_dump		= i40e_ndo_fdb_dump,
 #endif
 #endif
+	.ndo_gso_check		= i40e_gso_check,
 };
 
 /**
-- 
1.7.10.4
