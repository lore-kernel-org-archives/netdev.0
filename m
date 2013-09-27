From: Ajit Khaparde <ajit.khaparde@emulex.com>
Subject: [PATCH net 6/7] be2net: Fix to configure VLAN priority for a VF
 interface.
Date: Fri, 27 Sep 2013 15:18:46 -0500
Message-ID: <20130927201846.GA4599@emulex.com>
Reply-To: Ajit Khaparde <ajit.khaparde@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:29057 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753213Ab3I0USs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Sep 2013 16:18:48 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thix fix allows the VLAN priority to be configured for a VF interface
via the "ip link set DEVICE vf NUM" path.

Signed-off-by: Ajit Khaparde <ajit.khaparde@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c | 21 +++++++++++----------
 1 file changed, 11 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 9c25607..ad593ca 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -1212,28 +1212,29 @@ static int be_set_vf_vlan(struct net_device *netdev,
 			int vf, u16 vlan, u8 qos)
 {
 	struct be_adapter *adapter = netdev_priv(netdev);
+	struct be_vf_cfg *vf_cfg = &adapter->vf_cfg[vf];
 	int status = 0;
 
 	if (!sriov_enabled(adapter))
 		return -EPERM;
 
-	if (vf >= adapter->num_vfs || vlan > 4095)
+	if (vf >= adapter->num_vfs || vlan > 4095 || qos > 7)
 		return -EINVAL;
 
-	if (vlan) {
-		if (adapter->vf_cfg[vf].vlan_tag != vlan) {
+	if (vlan || qos) {
+		vlan |= qos << VLAN_PRIO_SHIFT;
+		if (vf_cfg->vlan_tag != vlan) {
 			/* If this is new value, program it. Else skip. */
-			adapter->vf_cfg[vf].vlan_tag = vlan;
-
-			status = be_cmd_set_hsw_config(adapter, vlan,
-				vf + 1, adapter->vf_cfg[vf].if_handle, 0);
+			vf_cfg->vlan_tag = vlan;
+			status = be_cmd_set_hsw_config(adapter, vlan, vf + 1,
+						       vf_cfg->if_handle, 0);
 		}
 	} else {
 		/* Reset Transparent Vlan Tagging. */
-		adapter->vf_cfg[vf].vlan_tag = 0;
-		vlan = adapter->vf_cfg[vf].def_vid;
+		vf_cfg->vlan_tag = 0;
+		vlan = vf_cfg->def_vid;
 		status = be_cmd_set_hsw_config(adapter, vlan, vf + 1,
-			adapter->vf_cfg[vf].if_handle, 0);
+					       vf_cfg->if_handle, 0);
 	}
 
 
-- 
1.8.1.2
