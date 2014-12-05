From: Joe Stringer <joestringer@nicira.com>
Subject: [PATCHv4 net] i40e: Implement ndo_gso_check()
Date: Fri,  5 Dec 2014 10:41:12 -0800
Message-ID: <1417804872-58635-1-git-send-email-joestringer@nicira.com>
Cc: linux-kernel@vger.kernel.org, shannon.nelson@intel.com,
	jesse.brandeburg@intel.com, jeffrey.t.kirsher@intel.com,
	therbert@google.com, jesse@nicira.com, linux.nics@intel.com
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ndo_gso_check() was recently introduced to allow NICs to report the
offloading support that they have on a per-skb basis. Add an
implementation for this driver which checks for IPIP, GRE, UDP tunnels.

Signed-off-by: Joe Stringer <joestringer@nicira.com>
---
v4: Simplify the check to just do tunnel header length.
    Fix #define style issue.
v3: Drop IPIP and GRE (no driver support even though hw supports it).
    Check for UDP outer protocol for UDP tunnels.
v2: Expand to include IP in IP and IPv4/IPv6 inside GRE/UDP tunnels.
    Add MAX_INNER_LENGTH (as 80).
---
 drivers/net/ethernet/intel/i40e/i40e_main.c |   12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index c3a7f4a..9eedfd15 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -7447,6 +7447,17 @@ static int i40e_ndo_fdb_dump(struct sk_buff *skb,
 
 #endif /* USE_DEFAULT_FDB_DEL_DUMP */
 #endif /* HAVE_FDB_OPS */
+#define I40E_MAX_TUNNEL_HDR_LEN		80
+static bool i40e_gso_check(struct sk_buff *skb, struct net_device *dev)
+{
+	if (skb->encapsulation &&
+	    (skb_inner_mac_header(skb) - skb_transport_header(skb) >
+	     I40E_MAX_TUNNEL_HDR_LEN))
+			return false;
+
+	return true;
+}
+
 static const struct net_device_ops i40e_netdev_ops = {
 	.ndo_open		= i40e_open,
 	.ndo_stop		= i40e_close,
@@ -7487,6 +7498,7 @@ static const struct net_device_ops i40e_netdev_ops = {
 	.ndo_fdb_dump		= i40e_ndo_fdb_dump,
 #endif
 #endif
+	.ndo_gso_check		= i40e_gso_check,
 };
 
 /**
-- 
1.7.10.4
