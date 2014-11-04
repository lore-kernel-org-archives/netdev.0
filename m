From: Joe Stringer <joestringer@nicira.com>
Subject: [PATCH net 4/5] net/mlx4_en: Implement ndo_gso_check()
Date: Tue,  4 Nov 2014 13:56:41 -0800
Message-ID: <1415138202-1197-5-git-send-email-joestringer@nicira.com>
References: <1415138202-1197-1-git-send-email-joestringer@nicira.com>
Cc: sathya.perla@emulex.com, jeffrey.t.kirsher@intel.com,
	linux.nics@intel.com, amirv@mellanox.com, shahed.shaikh@qlogic.com,
	Dept-GELinuxNICDev@qlogic.com, therbert@google.com,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1415138202-1197-1-git-send-email-joestringer@nicira.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ndo_gso_check() was recently introduced to allow NICs to report the
offloading support that they have on a per-skb basis. Add an
implementation for this driver which checks for something that looks
like VXLAN.

Implementation shamelessly stolen from Tom Herbert:
http://thread.gmane.org/gmane.linux.network/332428/focus=333111

Signed-off-by: Joe Stringer <joestringer@nicira.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |   12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index f3032fe..aca9908 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -2344,6 +2344,17 @@ static void mlx4_en_del_vxlan_port(struct  net_device *dev,
 }
 #endif
 
+static bool mlx4_en_gso_check(struct sk_buff *skb, struct net_device *dev)
+{
+	if ((skb_shinfo(skb)->gso_type & SKB_GSO_UDP_TUNNEL) &&
+	    (skb->inner_protocol_type != ENCAP_TYPE_ETHER ||
+	     skb->inner_protocol != htons(ETH_P_TEB) ||
+	     skb_inner_mac_header(skb) - skb_transport_header(skb) != 16))
+		return false;
+
+	return true;
+}
+
 static const struct net_device_ops mlx4_netdev_ops = {
 	.ndo_open		= mlx4_en_open,
 	.ndo_stop		= mlx4_en_close,
@@ -2374,6 +2385,7 @@ static const struct net_device_ops mlx4_netdev_ops = {
 	.ndo_add_vxlan_port	= mlx4_en_add_vxlan_port,
 	.ndo_del_vxlan_port	= mlx4_en_del_vxlan_port,
 #endif
+	.ndo_gso_check		= mlx4_en_gso_check,
 };
 
 static const struct net_device_ops mlx4_netdev_ops_master = {
-- 
1.7.10.4
