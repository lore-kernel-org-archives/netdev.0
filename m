From: Roopa Prabhu <roprabhu@cisco.com>
Subject: [net-next-2.6 PATCH 3/4] enic: Fix ndo_set_vf_mac and ndo_set_vf_port
	to set/get the sriov vf's mac
Date: Mon, 20 Feb 2012 02:11:58 -0800
Message-ID: <20120220101158.5794.19172.stgit@rhel6.1>
References: <20120220101140.5794.60233.stgit@rhel6.1>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtv-iport-3.cisco.com ([173.36.130.14]:38192 "EHLO
	mtv-iport-3.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753411Ab2BTCSE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Feb 2012 21:18:04 -0500
In-Reply-To: <20120220101140.5794.60233.stgit@rhel6.1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roprabhu@cisco.com>

This patch fixes the ndo_set_vf_mac netdev op to set the sriov vf mac
in adapter using the new fw devcmd CMD_SET_MAC_ADDR. During port profile
associate the pf driver gets the vf mac using CMD_GET_MAC_ADDR.

Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
Signed-off-by: Christian Benvenuti <benve@cisco.com>
Signed-off-by: Sujith Sankar <ssujith@cisco.com>
---
 drivers/net/ethernet/cisco/enic/enic.h      |    2 +
 drivers/net/ethernet/cisco/enic/enic_main.c |   37 +++++++++++++++++++++------
 2 files changed, 30 insertions(+), 9 deletions(-)


diff --git a/drivers/net/ethernet/cisco/enic/enic.h b/drivers/net/ethernet/cisco/enic/enic.h
index 06fba32..922b646 100644
--- a/drivers/net/ethernet/cisco/enic/enic.h
+++ b/drivers/net/ethernet/cisco/enic/enic.h
@@ -32,7 +32,7 @@
 
 #define DRV_NAME		"enic"
 #define DRV_DESCRIPTION		"Cisco VIC Ethernet NIC Driver"
-#define DRV_VERSION		"2.1.1.36"
+#define DRV_VERSION		"2.1.1.37"
 #define DRV_COPYRIGHT		"Copyright 2008-2011 Cisco Systems, Inc"
 
 #define ENIC_BARS_MAX		6
diff --git a/drivers/net/ethernet/cisco/enic/enic_main.c b/drivers/net/ethernet/cisco/enic/enic_main.c
index 7dfa567..2278c43 100644
--- a/drivers/net/ethernet/cisco/enic/enic_main.c
+++ b/drivers/net/ethernet/cisco/enic/enic_main.c
@@ -1070,8 +1070,17 @@ static int enic_set_vf_mac(struct net_device *netdev, int vf, u8 *mac)
 		return err;
 
 	if (is_valid_ether_addr(mac)) {
-		memcpy(pp->vf_mac, mac, ETH_ALEN);
-		return 0;
+		if (vf == PORT_SELF_VF) {
+			memcpy(pp->vf_mac, mac, ETH_ALEN);
+			return 0;
+		} else {
+			/*
+			 * For sriov vf's set the mac in hw
+			 */
+			ENIC_DEVCMD_PROXY_BY_INDEX(vf, err, enic,
+				vnic_dev_set_mac_addr, mac);
+			return enic_dev_status_to_errno(err);
+		}
 	} else
 		return -EINVAL;
 }
@@ -1115,12 +1124,23 @@ static int enic_set_vf_port(struct net_device *netdev, int vf,
 			nla_data(port[IFLA_PORT_HOST_UUID]), PORT_UUID_MAX);
 	}
 
-	/* Special case handling: mac came from IFLA_VF_MAC */
-	if (!is_zero_ether_addr(prev_pp.vf_mac))
-		memcpy(pp->mac_addr, prev_pp.vf_mac, ETH_ALEN);
+	if (vf == PORT_SELF_VF) {
+		/* Special case handling: mac came from IFLA_VF_MAC */
+		if (!is_zero_ether_addr(prev_pp.vf_mac))
+			memcpy(pp->mac_addr, prev_pp.vf_mac, ETH_ALEN);
 
-	if (vf == PORT_SELF_VF && is_zero_ether_addr(netdev->dev_addr))
-		eth_hw_addr_random(netdev);
+		if (is_zero_ether_addr(netdev->dev_addr))
+			eth_hw_addr_random(netdev);
+	} else {
+		/* SR-IOV VF: get mac from adapter */
+		ENIC_DEVCMD_PROXY_BY_INDEX(vf, err, enic,
+			vnic_dev_get_mac_addr, pp->mac_addr);
+		if (err) {
+			netdev_err(netdev, "Error getting mac for vf %d\n", vf);
+			memcpy(pp, &prev_pp, sizeof(*pp));
+			return enic_dev_status_to_errno(err);
+		}
+	}
 
 	err = enic_process_set_pp_request(enic, vf, &prev_pp, &restore_pp);
 	if (err) {
@@ -1148,7 +1168,8 @@ static int enic_set_vf_port(struct net_device *netdev, int vf,
 		}
 	}
 
-	memset(pp->vf_mac, 0, ETH_ALEN);
+	if (vf == PORT_SELF_VF)
+		memset(pp->vf_mac, 0, ETH_ALEN);
 
 	return err;
 }
