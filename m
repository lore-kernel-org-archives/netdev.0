From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net 1/8] qlcnic: Fix setting MAC address
Date: Tue, 7 May 2013 15:54:59 -0400
Message-ID: <1367956506-3290-2-git-send-email-shahed.shaikh@qlogic.com>
References: <1367956506-3290-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Manish Chopra <manish.chopra@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe001.messaging.microsoft.com ([216.32.180.11]:59980
	"EHLO va3outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756181Ab3EGUTr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 May 2013 16:19:47 -0400
In-Reply-To: <1367956506-3290-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Manish Chopra <manish.chopra@qlogic.com>

o Delete previous unicast MAC which is already programmed
  in adapter before setting new unicast MAC

Signed-off-by: Manish Chopra <manish.chopra@qlogic.com>
Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c |   21 +++++++++++++++++++++
 1 files changed, 21 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 264d5a4..04037b5 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -308,6 +308,23 @@ int qlcnic_read_mac_addr(struct qlcnic_adapter *adapter)
 	return 0;
 }
 
+static void qlcnic_delete_adapter_mac(struct qlcnic_adapter *adapter)
+{
+	struct qlcnic_mac_list_s *cur;
+	struct list_head *head;
+
+	list_for_each(head, &adapter->mac_list) {
+		cur = list_entry(head, struct qlcnic_mac_list_s, list);
+		if (!memcmp(adapter->mac_addr, cur->mac_addr, ETH_ALEN)) {
+			qlcnic_sre_macaddr_change(adapter, cur->mac_addr,
+						  0, QLCNIC_MAC_DEL);
+			list_del(&cur->list);
+			kfree(cur);
+			return;
+		}
+	}
+}
+
 static int qlcnic_set_mac(struct net_device *netdev, void *p)
 {
 	struct qlcnic_adapter *adapter = netdev_priv(netdev);
@@ -322,11 +339,15 @@ static int qlcnic_set_mac(struct net_device *netdev, void *p)
 	if (!is_valid_ether_addr(addr->sa_data))
 		return -EINVAL;
 
+	if (!memcmp(adapter->mac_addr, addr->sa_data, ETH_ALEN))
+		return 0;
+
 	if (test_bit(__QLCNIC_DEV_UP, &adapter->state)) {
 		netif_device_detach(netdev);
 		qlcnic_napi_disable(adapter);
 	}
 
+	qlcnic_delete_adapter_mac(adapter);
 	memcpy(adapter->mac_addr, addr->sa_data, netdev->addr_len);
 	memcpy(netdev->dev_addr, addr->sa_data, netdev->addr_len);
 	qlcnic_set_multi(adapter->netdev);
-- 
1.5.6
