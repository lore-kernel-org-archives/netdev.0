From: amit.salecha@qlogic.com
Subject: [PATCH NEXT 3/6] qlcnic: enable mac-learning in promiscous mode.
Date: Thu, 14 Jul 2011 06:16:52 -0700
Message-ID: <1310649415-14787-4-git-send-email-amit.salecha@qlogic.com>
References: <1310649415-14787-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	anirban.chakraborty@qlogic.com,
	Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>,
	Amit Kumar Salecha <amit.salecha@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from vpn.pathscale.com ([198.186.3.75]:44908 "HELO mx.mv.qlogic.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with SMTP
	id S1754932Ab1GNNZt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Jul 2011 09:25:49 -0400
In-Reply-To: <1310649415-14787-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>

MAC learning is required in bridge mode.
During bridge mode device will be put in promiscous mode.

Signed-off-by: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic.h      |    2 ++
 drivers/net/qlcnic/qlcnic_hw.c   |    7 +++++++
 drivers/net/qlcnic/qlcnic_main.c |   13 +++++++------
 3 files changed, 16 insertions(+), 6 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic.h b/drivers/net/qlcnic/qlcnic.h
index 7c0d6ee..3ae2450 100644
--- a/drivers/net/qlcnic/qlcnic.h
+++ b/drivers/net/qlcnic/qlcnic.h
@@ -1015,6 +1015,7 @@ struct qlcnic_adapter {
 	u8 mac_addr[ETH_ALEN];
 
 	u64 dev_rst_time;
+	u8 mac_learn;
 	unsigned long vlans[BITS_TO_LONGS(VLAN_N_VID)];
 
 	struct qlcnic_npar_info *npars;
@@ -1460,6 +1461,7 @@ netdev_tx_t qlcnic_xmit_frame(struct sk_buff *skb, struct net_device *netdev);
 int qlcnic_validate_max_rss(struct net_device *netdev, u8 max_hw, u8 val);
 int qlcnic_set_max_rss(struct qlcnic_adapter *adapter, u8 data);
 void qlcnic_dev_request_reset(struct qlcnic_adapter *);
+void qlcnic_alloc_lb_filters_mem(struct qlcnic_adapter *adapter);
 
 /* Management functions */
 int qlcnic_get_mac_address(struct qlcnic_adapter *, u8*);
diff --git a/drivers/net/qlcnic/qlcnic_hw.c b/drivers/net/qlcnic/qlcnic_hw.c
index 0391a04..4055c21 100644
--- a/drivers/net/qlcnic/qlcnic_hw.c
+++ b/drivers/net/qlcnic/qlcnic_hw.c
@@ -446,6 +446,13 @@ void qlcnic_set_multi(struct net_device *netdev)
 	}
 
 send_fw_cmd:
+	if (mode == VPORT_MISS_MODE_ACCEPT_ALL) {
+		qlcnic_alloc_lb_filters_mem(adapter);
+		adapter->mac_learn = 1;
+	} else {
+		adapter->mac_learn = 0;
+	}
+
 	qlcnic_nic_set_promisc(adapter, mode);
 }
 
diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index 6b646c6..916570d 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -90,7 +90,6 @@ static struct net_device_stats *qlcnic_get_stats(struct net_device *netdev);
 static void qlcnic_restore_indev_addr(struct net_device *dev, unsigned long);
 static int qlcnic_start_firmware(struct qlcnic_adapter *);
 
-static void qlcnic_alloc_lb_filters_mem(struct qlcnic_adapter *adapter);
 static void qlcnic_free_lb_filters_mem(struct qlcnic_adapter *adapter);
 static void qlcnic_dev_set_npar_ready(struct qlcnic_adapter *);
 static int qlcnicvf_config_led(struct qlcnic_adapter *, u32, u32);
@@ -1578,6 +1577,7 @@ qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	adapter->dev_rst_time = jiffies;
 	revision_id = pdev->revision;
 	adapter->ahw->revision_id = revision_id;
+	adapter->mac_learn = qlcnic_mac_learn;
 
 	rwlock_init(&adapter->ahw->crb_lock);
 	mutex_init(&adapter->ahw->mem_lock);
@@ -1654,7 +1654,9 @@ qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		break;
 	}
 
-	qlcnic_alloc_lb_filters_mem(adapter);
+	if (adapter->mac_learn)
+		qlcnic_alloc_lb_filters_mem(adapter);
+
 	qlcnic_create_diag_entries(adapter);
 
 	return 0;
@@ -1850,13 +1852,12 @@ static int qlcnic_close(struct net_device *netdev)
 	return 0;
 }
 
-static void
-qlcnic_alloc_lb_filters_mem(struct qlcnic_adapter *adapter)
+void qlcnic_alloc_lb_filters_mem(struct qlcnic_adapter *adapter)
 {
 	void *head;
 	int i;
 
-	if (!qlcnic_mac_learn)
+	if (adapter->fhash.fmax && adapter->fhash.fhead)
 		return;
 
 	spin_lock_init(&adapter->mac_learn_lock);
@@ -2286,7 +2287,7 @@ qlcnic_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	if (unlikely(qlcnic_tx_pkt(adapter, first_desc, skb)))
 		goto unwind_buff;
 
-	if (qlcnic_mac_learn)
+	if (adapter->mac_learn)
 		qlcnic_send_filter(adapter, tx_ring, first_desc, skb);
 
 	qlcnic_update_cmd_producer(adapter, tx_ring);
-- 
1.7.3.3

