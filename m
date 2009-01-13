From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCHv2 5/7] netxen: cleanup mac list on driver unload
Date: Tue, 13 Jan 2009 11:52:42 -0800
Message-ID: <1231876364-866-6-git-send-email-dhananjay@netxen.com>
References: <1231876364-866-1-git-send-email-dhananjay@netxen.com>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nxgate.netxen.com ([38.99.60.130]:60175 "EHLO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753348AbZAMTwq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Jan 2009 14:52:46 -0500
In-Reply-To: <1231876364-866-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This fixes a tiny memory leak when driver is unloaded. The mac
address list maintained in netxen_adapter needs to deleted when
driver is going down.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic.h      |    1 +
 drivers/net/netxen/netxen_nic_hw.c   |   13 +++++++++++++
 drivers/net/netxen/netxen_nic_main.c |    3 +++
 3 files changed, 17 insertions(+), 0 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index a674a23..6598a34 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -1478,6 +1478,7 @@ int netxen_process_cmd_ring(struct netxen_adapter *adapter);
 u32 netxen_process_rcv_ring(struct netxen_adapter *adapter, int ctx, int max);
 void netxen_p2_nic_set_multi(struct net_device *netdev);
 void netxen_p3_nic_set_multi(struct net_device *netdev);
+void netxen_p3_free_mac_list(struct netxen_adapter *adapter);
 int netxen_p3_nic_set_promisc(struct netxen_adapter *adapter, u32);
 int netxen_config_intr_coalesce(struct netxen_adapter *adapter);
 
diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index 511db2a..e2d2a2f 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -627,6 +627,19 @@ int netxen_p3_nic_set_promisc(struct netxen_adapter *adapter, u32 mode)
 				(struct cmd_desc_type0 *)&req, 1);
 }
 
+void netxen_p3_free_mac_list(struct netxen_adapter *adapter)
+{
+	nx_mac_list_t *cur, *next;
+
+	cur = adapter->mac_list;
+
+	while (cur) {
+		next = cur->next;
+		kfree(cur);
+		cur = next;
+	}
+}
+
 #define	NETXEN_CONFIG_INTR_COALESCE	3
 
 /*
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index cbe2b3e..9268fd2 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -986,6 +986,9 @@ static void __devexit netxen_nic_remove(struct pci_dev *pdev)
 		netxen_free_hw_resources(adapter);
 		netxen_release_rx_buffers(adapter);
 		netxen_free_sw_resources(adapter);
+
+		if (NX_IS_REVISION_P3(adapter->ahw.revision_id))
+			netxen_p3_free_mac_list(adapter);
 	}
 
 	if (adapter->portnum == 0)
-- 
1.6.0.2

