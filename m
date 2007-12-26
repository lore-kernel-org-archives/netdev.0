From: dhananjay@netxen.com
Subject: [patch 4/7] netxen: stop second phy correctly
Date: Wed, 26 Dec 2007 10:23:56 -0800
Message-ID: <20071226182927.458002764@netxen.com>
References: <20071226182352.704678179@netxen.com>
Cc: jeff@garzik.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [64.209.101.202] ([64.209.101.202]:45035 "EHLO dut46.unminc.com"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751494AbXLZSZy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Dec 2007 13:25:54 -0500
Content-Disposition: inline; filename=stop_port.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes bug that doesn't quiesce second port when interface is
brought down, which could lead to unwarranted interrupt during rmmod / 
ifdown.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>

Index: upstream/drivers/net/netxen/netxen_nic_niu.c
===================================================================
--- upstream.orig/drivers/net/netxen/netxen_nic_niu.c
+++ upstream/drivers/net/netxen/netxen_nic_niu.c
@@ -742,12 +742,12 @@ int netxen_niu_disable_xg_port(struct ne
 	__u32 mac_cfg;
 	u32 port = physical_port[adapter->portnum];
 
-	if (port != 0)
+	if (port > NETXEN_NIU_MAX_XG_PORTS)
 		return -EINVAL;
+
 	mac_cfg = 0;
-	netxen_xg_soft_reset(mac_cfg);
-	if (netxen_nic_hw_write_wx(adapter, NETXEN_NIU_XGE_CONFIG_0,
-				   &mac_cfg, 4))
+	if (netxen_nic_hw_write_wx(adapter,
+		NETXEN_NIU_XGE_CONFIG_0 + (0x10000 * port), &mac_cfg, 4))
 		return -EIO;
 	return 0;
 }
Index: upstream/drivers/net/netxen/netxen_nic_main.c
===================================================================
--- upstream.orig/drivers/net/netxen/netxen_nic_main.c
+++ upstream/drivers/net/netxen/netxen_nic_main.c
@@ -725,11 +725,6 @@ static void __devexit netxen_nic_remove(
 
 	unregister_netdev(netdev);
 
-	if (adapter->stop_port)
-		adapter->stop_port(adapter);
-
-	netxen_nic_disable_int(adapter);
-
 	if (adapter->is_up == NETXEN_ADAPTER_UP_MAGIC) {
 		init_firmware_done++;
 		netxen_free_hw_resources(adapter);
@@ -912,6 +907,9 @@ static int netxen_nic_close(struct net_d
 	netif_stop_queue(netdev);
 	napi_disable(&adapter->napi);
 
+	if (adapter->stop_port)
+		adapter->stop_port(adapter);
+
 	netxen_nic_disable_int(adapter);
 
 	cmd_buff = adapter->cmd_buf_arr;

-- 
