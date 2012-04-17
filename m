From: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
Subject: [PATCH 1/3] ehea: fix allmulticast support
Date: Tue, 17 Apr 2012 11:41:53 -0300
Message-ID: <1334673715-16338-2-git-send-email-cascardo@linux.vnet.ibm.com>
References: <1334673715-16338-1-git-send-email-cascardo@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org,
	Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp05.br.ibm.com ([32.104.18.26]:35064 "EHLO
	e24smtp05.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752339Ab2DQOmQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Apr 2012 10:42:16 -0400
Received: from /spool/local
	by e24smtp05.br.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <cascardo@linux.vnet.ibm.com>;
	Tue, 17 Apr 2012 11:42:15 -0300
Received: from d24relay03.br.ibm.com (d24relay03.br.ibm.com [9.13.184.25])
	by d24dlp01.br.ibm.com (Postfix) with ESMTP id B68FE3520050
	for <netdev@vger.kernel.org>; Tue, 17 Apr 2012 11:42:09 -0300 (BRT)
Received: from d24av01.br.ibm.com (d24av01.br.ibm.com [9.8.31.91])
	by d24relay03.br.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q3HEftKA56688944
	for <netdev@vger.kernel.org>; Tue, 17 Apr 2012 11:41:55 -0300
Received: from d24av01.br.ibm.com (loopback [127.0.0.1])
	by d24av01.br.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q3HCg5QV025240
	for <netdev@vger.kernel.org>; Tue, 17 Apr 2012 09:42:05 -0300
In-Reply-To: <1334673715-16338-1-git-send-email-cascardo@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There was a bug in the mask of regtype parameter for registering a
multicast filter. It was ignoring the scope bit, which was wrongly being
used for all filters. The SCOPE_ALL value adds a filter that allows all
multicast packets and ignores the MAC parameter, just what allmulticast
needs. The normals filters, however, should not use SCOPE_ALL.

Signed-off-by: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ehea/ehea_main.c |   24 +++++++++++++++---------
 drivers/net/ethernet/ibm/ehea/ehea_phyp.h |    2 +-
 2 files changed, 16 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/ibm/ehea/ehea_main.c b/drivers/net/ethernet/ibm/ehea/ehea_main.c
index 3516e17..25d1258 100644
--- a/drivers/net/ethernet/ibm/ehea/ehea_main.c
+++ b/drivers/net/ethernet/ibm/ehea/ehea_main.c
@@ -290,16 +290,18 @@ static void ehea_update_bcmc_registrations(void)
 
 				arr[i].adh = adapter->handle;
 				arr[i].port_id = port->logical_port_id;
-				arr[i].reg_type = EHEA_BCMC_SCOPE_ALL |
-						  EHEA_BCMC_MULTICAST |
+				arr[i].reg_type = EHEA_BCMC_MULTICAST |
 						  EHEA_BCMC_UNTAGGED;
+				if (mc_entry->macaddr == 0)
+					arr[i].reg_type |= EHEA_BCMC_SCOPE_ALL;
 				arr[i++].macaddr = mc_entry->macaddr;
 
 				arr[i].adh = adapter->handle;
 				arr[i].port_id = port->logical_port_id;
-				arr[i].reg_type = EHEA_BCMC_SCOPE_ALL |
-						  EHEA_BCMC_MULTICAST |
+				arr[i].reg_type = EHEA_BCMC_MULTICAST |
 						  EHEA_BCMC_VLANID_ALL;
+				if (mc_entry->macaddr == 0)
+					arr[i].reg_type |= EHEA_BCMC_SCOPE_ALL;
 				arr[i++].macaddr = mc_entry->macaddr;
 				num_registrations -= 2;
 			}
@@ -1838,8 +1840,9 @@ static u64 ehea_multicast_reg_helper(struct ehea_port *port, u64 mc_mac_addr,
 	u64 hret;
 	u8 reg_type;
 
-	reg_type = EHEA_BCMC_SCOPE_ALL | EHEA_BCMC_MULTICAST
-		 | EHEA_BCMC_UNTAGGED;
+	reg_type = EHEA_BCMC_MULTICAST | EHEA_BCMC_UNTAGGED;
+	if (mc_mac_addr == 0)
+		reg_type |= EHEA_BCMC_SCOPE_ALL;
 
 	hret = ehea_h_reg_dereg_bcmc(port->adapter->handle,
 				     port->logical_port_id,
@@ -1847,8 +1850,9 @@ static u64 ehea_multicast_reg_helper(struct ehea_port *port, u64 mc_mac_addr,
 	if (hret)
 		goto out;
 
-	reg_type = EHEA_BCMC_SCOPE_ALL | EHEA_BCMC_MULTICAST
-		 | EHEA_BCMC_VLANID_ALL;
+	reg_type = EHEA_BCMC_MULTICAST | EHEA_BCMC_VLANID_ALL;
+	if (mc_mac_addr == 0)
+		reg_type |= EHEA_BCMC_SCOPE_ALL;
 
 	hret = ehea_h_reg_dereg_bcmc(port->adapter->handle,
 				     port->logical_port_id,
@@ -1898,7 +1902,7 @@ static void ehea_allmulti(struct net_device *dev, int enable)
 				netdev_err(dev,
 					   "failed enabling IFF_ALLMULTI\n");
 		}
-	} else
+	} else {
 		if (!enable) {
 			/* Disable ALLMULTI */
 			hret = ehea_multicast_reg_helper(port, 0, H_DEREG_BCMC);
@@ -1908,6 +1912,7 @@ static void ehea_allmulti(struct net_device *dev, int enable)
 				netdev_err(dev,
 					   "failed disabling IFF_ALLMULTI\n");
 		}
+	}
 }
 
 static void ehea_add_multicast_entry(struct ehea_port *port, u8 *mc_mac_addr)
@@ -2463,6 +2468,7 @@ static int ehea_down(struct net_device *dev)
 		return 0;
 
 	ehea_drop_multicast_list(dev);
+	ehea_allmulti(dev, 0);
 	ehea_broadcast_reg_helper(port, H_DEREG_BCMC);
 
 	ehea_free_interrupts(dev);
diff --git a/drivers/net/ethernet/ibm/ehea/ehea_phyp.h b/drivers/net/ethernet/ibm/ehea/ehea_phyp.h
index 52c456e..8364815 100644
--- a/drivers/net/ethernet/ibm/ehea/ehea_phyp.h
+++ b/drivers/net/ethernet/ibm/ehea/ehea_phyp.h
@@ -450,7 +450,7 @@ u64 ehea_h_modify_ehea_port(const u64 adapter_handle, const u16 port_num,
 			    void *cb_addr);
 
 #define H_REGBCMC_PN            EHEA_BMASK_IBM(48, 63)
-#define H_REGBCMC_REGTYPE       EHEA_BMASK_IBM(61, 63)
+#define H_REGBCMC_REGTYPE       EHEA_BMASK_IBM(60, 63)
 #define H_REGBCMC_MACADDR       EHEA_BMASK_IBM(16, 63)
 #define H_REGBCMC_VLANID        EHEA_BMASK_IBM(52, 63)
 
-- 
1.7.4.4
