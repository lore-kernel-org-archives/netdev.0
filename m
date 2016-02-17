From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 13/15] i40e: Enable Geneve offload for FW API ver > 1.4 for XL710/X710 devices
Date: Wed, 17 Feb 2016 09:51:44 -0800
Message-ID: <1455731506-62165-14-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1455731506-62165-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai <anjali.singhai@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:4789 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161644AbcBQRvx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Feb 2016 12:51:53 -0500
In-Reply-To: <1455731506-62165-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai <anjali.singhai@intel.com>

This patch makes sure we check the GENEVE offload capable flag before
we attempt offload.
It also enables the Capability for XL710/X710 devices with FW API
version higher than 1.4

Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 15 ++++++++++++++-
 1 file changed, 14 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 6e12626..99d7a5c 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -5354,7 +5354,8 @@ int i40e_open(struct net_device *netdev)
 	vxlan_get_rx_port(netdev);
 #endif
 #ifdef CONFIG_I40E_GENEVE
-	geneve_get_rx_port(netdev);
+	if (pf->flags & I40E_FLAG_GENEVE_OFFLOAD_CAPABLE)
+		geneve_get_rx_port(netdev);
 #endif
 
 	return 0;
@@ -8458,7 +8459,13 @@ static int i40e_sw_init(struct i40e_pf *pf)
 			     I40E_FLAG_MULTIPLE_TCP_UDP_RSS_PCTYPE |
 			     I40E_FLAG_100M_SGMII_CAPABLE |
 			     I40E_FLAG_GENEVE_OFFLOAD_CAPABLE;
+	} else if ((pf->hw.aq.api_maj_ver > 1) ||
+		   ((pf->hw.aq.api_maj_ver == 1) &&
+		    (pf->hw.aq.api_min_ver > 4))) {
+		/* Supported in FW API version higher than 1.4 */
+		pf->flags |= I40E_FLAG_GENEVE_OFFLOAD_CAPABLE;
 	}
+
 	pf->eeprom_version = 0xDEAD;
 	pf->lan_veb = I40E_NO_VEB;
 	pf->lan_vsi = I40E_NO_VSI;
@@ -8672,6 +8679,9 @@ static void i40e_add_geneve_port(struct net_device *netdev,
 	u8 next_idx;
 	u8 idx;
 
+	if (!(pf->flags & I40E_FLAG_GENEVE_OFFLOAD_CAPABLE))
+		return;
+
 	if (sa_family == AF_INET6)
 		return;
 
@@ -8719,6 +8729,9 @@ static void i40e_del_geneve_port(struct net_device *netdev,
 	if (sa_family == AF_INET6)
 		return;
 
+	if (!(pf->flags & I40E_FLAG_GENEVE_OFFLOAD_CAPABLE))
+		return;
+
 	idx = i40e_get_udp_port_idx(pf, port);
 
 	/* Check if port already exists */
-- 
2.5.0
