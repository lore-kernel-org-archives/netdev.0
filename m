From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCHv2 NEXT 08/10] qlcnic: support mac learning
Date: Tue, 31 Aug 2010 20:17:51 -0700
Message-ID: <1283311073-7165-9-git-send-email-amit.salecha@qlogic.com>
References: <1283311073-7165-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	anirban.chakraborty@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:21394 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1753536Ab0IADRz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Aug 2010 23:17:55 -0400
In-Reply-To: <1283311073-7165-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Device eswitch need to configure with VM's mac address.
Hypervisor doesn't provide any utility/callbacks to get VM's mac address.
Unicast mac address filter improves performance and also provide
packet loopback capability i.e communication between VM.

Above features is by default off, can be turned on with module parameter
'mac_learn'.

Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic.h      |   20 ++++++
 drivers/net/qlcnic/qlcnic_hw.c   |   48 +++++++++++++++
 drivers/net/qlcnic/qlcnic_main.c |  123 ++++++++++++++++++++++++++++++++++++++
 3 files changed, 191 insertions(+), 0 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic.h b/drivers/net/qlcnic/qlcnic.h
index cd1a2e6..4727204 100644
--- a/drivers/net/qlcnic/qlcnic.h
+++ b/drivers/net/qlcnic/qlcnic.h
@@ -926,6 +926,21 @@ struct qlcnic_mac_req {
 #define QLCNIC_INTERRUPT_TEST		1
 #define QLCNIC_LOOPBACK_TEST		2
 
+#define QLCNIC_FILTER_AGE	80
+#define QLCNIC_LB_MAX_FILTERS	64
+
+struct qlcnic_filter {
+	struct hlist_node fnode;
+	u8 faddr[ETH_ALEN];
+	unsigned long ftime;
+};
+
+struct qlcnic_filter_hash {
+	struct hlist_head *fhead;
+	u8 fnum;
+	u8 fmax;
+};
+
 struct qlcnic_adapter {
 	struct qlcnic_hardware_context ahw;
 
@@ -934,6 +949,7 @@ struct qlcnic_adapter {
 	struct list_head mac_list;
 
 	spinlock_t tx_clean_lock;
+	spinlock_t mac_learn_lock;
 
 	u16 num_txd;
 	u16 num_rxd;
@@ -1013,6 +1029,8 @@ struct qlcnic_adapter {
 
 	struct qlcnic_nic_intr_coalesce coal;
 
+	struct qlcnic_filter_hash fhash;
+
 	unsigned long state;
 	__le32 file_prd_off;	/*File fw product offset*/
 	u32 fw_version;
@@ -1211,6 +1229,8 @@ void qlcnic_pcie_sem_unlock(struct qlcnic_adapter *, int);
 int qlcnic_get_board_info(struct qlcnic_adapter *adapter);
 int qlcnic_wol_supported(struct qlcnic_adapter *adapter);
 int qlcnic_config_led(struct qlcnic_adapter *adapter, u32 state, u32 rate);
+void qlcnic_prune_lb_filters(struct qlcnic_adapter *adapter);
+void qlcnic_delete_lb_filters(struct qlcnic_adapter *adapter);
 
 /* Functions from qlcnic_init.c */
 int qlcnic_load_firmware(struct qlcnic_adapter *adapter);
diff --git a/drivers/net/qlcnic/qlcnic_hw.c b/drivers/net/qlcnic/qlcnic_hw.c
index 670a54a..5b2bce5 100644
--- a/drivers/net/qlcnic/qlcnic_hw.c
+++ b/drivers/net/qlcnic/qlcnic_hw.c
@@ -491,6 +491,54 @@ void qlcnic_free_mac_list(struct qlcnic_adapter *adapter)
 	}
 }
 
+void qlcnic_prune_lb_filters(struct qlcnic_adapter *adapter)
+{
+	struct qlcnic_filter *tmp_fil;
+	struct hlist_node *tmp_hnode, *n;
+	struct hlist_head *head;
+	int i;
+
+	for (i = 0; i < adapter->fhash.fmax; i++) {
+		head = &(adapter->fhash.fhead[i]);
+
+		hlist_for_each_entry_safe(tmp_fil, tmp_hnode, n, head, fnode)
+		{
+			if (jiffies >
+				(QLCNIC_FILTER_AGE * HZ + tmp_fil->ftime)) {
+				qlcnic_sre_macaddr_change(adapter,
+					tmp_fil->faddr, QLCNIC_MAC_DEL);
+				spin_lock_bh(&adapter->mac_learn_lock);
+				adapter->fhash.fnum--;
+				hlist_del(&tmp_fil->fnode);
+				spin_unlock_bh(&adapter->mac_learn_lock);
+				kfree(tmp_fil);
+			}
+		}
+	}
+}
+
+void qlcnic_delete_lb_filters(struct qlcnic_adapter *adapter)
+{
+	struct qlcnic_filter *tmp_fil;
+	struct hlist_node *tmp_hnode, *n;
+	struct hlist_head *head;
+	int i;
+
+	for (i = 0; i < adapter->fhash.fmax; i++) {
+		head = &(adapter->fhash.fhead[i]);
+
+		hlist_for_each_entry_safe(tmp_fil, tmp_hnode, n, head, fnode) {
+			qlcnic_sre_macaddr_change(adapter,
+					tmp_fil->faddr, QLCNIC_MAC_DEL);
+			spin_lock_bh(&adapter->mac_learn_lock);
+			adapter->fhash.fnum--;
+			hlist_del(&tmp_fil->fnode);
+			spin_unlock_bh(&adapter->mac_learn_lock);
+			kfree(tmp_fil);
+		}
+	}
+}
+
 #define	QLCNIC_CONFIG_INTR_COALESCE	3
 
 /*
diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index 130f4db..0fbfb53 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -50,6 +50,10 @@ static int port_mode = QLCNIC_PORT_MODE_AUTO_NEG;
 /* Default to restricted 1G auto-neg mode */
 static int wol_port_mode = 5;
 
+static int qlcnic_mac_learn;
+module_param(qlcnic_mac_learn, int, 0644);
+MODULE_PARM_DESC(qlcnic_mac_learn, "Mac Filter (0=disabled, 1=enabled)");
+
 static int use_msi = 1;
 module_param(use_msi, int, 0644);
 MODULE_PARM_DESC(use_msi, "MSI interrupt (0=disabled, 1=enabled");
@@ -106,6 +110,8 @@ static struct net_device_stats *qlcnic_get_stats(struct net_device *netdev);
 static void qlcnic_config_indev_addr(struct net_device *dev, unsigned long);
 static int qlcnic_start_firmware(struct qlcnic_adapter *);
 
+static void qlcnic_alloc_lb_filters_mem(struct qlcnic_adapter *adapter);
+static void qlcnic_free_lb_filters_mem(struct qlcnic_adapter *adapter);
 static void qlcnic_dev_set_npar_ready(struct qlcnic_adapter *);
 static int qlcnicvf_config_led(struct qlcnic_adapter *, u32, u32);
 static int qlcnicvf_config_bridged_mode(struct qlcnic_adapter *, u32);
@@ -1201,6 +1207,9 @@ __qlcnic_down(struct qlcnic_adapter *adapter, struct net_device *netdev)
 
 	qlcnic_free_mac_list(adapter);
 
+	if (adapter->fhash.fnum)
+		qlcnic_delete_lb_filters(adapter);
+
 	qlcnic_nic_set_promisc(adapter, QLCNIC_NIU_NON_PROMISC_MODE);
 
 	qlcnic_napi_disable(adapter);
@@ -1596,6 +1605,7 @@ qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		break;
 	}
 
+	qlcnic_alloc_lb_filters_mem(adapter);
 	qlcnic_create_diag_entries(adapter);
 
 	return 0;
@@ -1647,6 +1657,8 @@ static void __devexit qlcnic_remove(struct pci_dev *pdev)
 
 	clear_bit(__QLCNIC_RESETTING, &adapter->state);
 
+	qlcnic_free_lb_filters_mem(adapter);
+
 	qlcnic_teardown_intr(adapter);
 
 	qlcnic_remove_diag_entries(adapter);
@@ -1782,6 +1794,111 @@ static int qlcnic_close(struct net_device *netdev)
 }
 
 static void
+qlcnic_alloc_lb_filters_mem(struct qlcnic_adapter *adapter)
+{
+	void *head;
+	int i;
+
+	if (!qlcnic_mac_learn)
+		return;
+
+	spin_lock_init(&adapter->mac_learn_lock);
+
+	head = kcalloc(QLCNIC_LB_MAX_FILTERS, sizeof(struct hlist_head),
+								GFP_KERNEL);
+	if (!head)
+		return;
+
+	adapter->fhash.fmax = QLCNIC_LB_MAX_FILTERS;
+	adapter->fhash.fhead = (struct hlist_head *)head;
+
+	for (i = 0; i < adapter->fhash.fmax; i++)
+		INIT_HLIST_HEAD(&adapter->fhash.fhead[i]);
+}
+
+static void qlcnic_free_lb_filters_mem(struct qlcnic_adapter *adapter)
+{
+	if (adapter->fhash.fmax && adapter->fhash.fhead)
+		kfree(adapter->fhash.fhead);
+
+	adapter->fhash.fhead = NULL;
+	adapter->fhash.fmax = 0;
+}
+
+static void qlcnic_change_filter(struct qlcnic_adapter *adapter,
+		u64 uaddr, struct qlcnic_host_tx_ring *tx_ring)
+{
+	struct cmd_desc_type0 *hwdesc;
+	struct qlcnic_nic_req *req;
+	struct qlcnic_mac_req *mac_req;
+	u32 producer;
+	u64 word;
+
+	producer = tx_ring->producer;
+	hwdesc = &tx_ring->desc_head[tx_ring->producer];
+
+	req = (struct qlcnic_nic_req *)hwdesc;
+	memset(req, 0, sizeof(struct qlcnic_nic_req));
+	req->qhdr = cpu_to_le64(QLCNIC_REQUEST << 23);
+
+	word = QLCNIC_MAC_EVENT | ((u64)(adapter->portnum) << 16);
+	req->req_hdr = cpu_to_le64(word);
+
+	mac_req = (struct qlcnic_mac_req *)&(req->words[0]);
+	mac_req->op = QLCNIC_MAC_ADD;
+	memcpy(mac_req->mac_addr, &uaddr, ETH_ALEN);
+
+	tx_ring->producer = get_next_index(producer, tx_ring->num_desc);
+}
+
+#define QLCNIC_MAC_HASH(MAC)\
+	((((MAC) & 0x70000) >> 0x10) | (((MAC) & 0x70000000000ULL) >> 0x25))
+
+static void
+qlcnic_send_filter(struct qlcnic_adapter *adapter,
+		struct qlcnic_host_tx_ring *tx_ring,
+		struct cmd_desc_type0 *first_desc,
+		struct sk_buff *skb)
+{
+	struct ethhdr *phdr = (struct ethhdr *)(skb->data);
+	struct qlcnic_filter *fil, *tmp_fil;
+	struct hlist_node *tmp_hnode, *n;
+	struct hlist_head *head;
+	u64 src_addr = 0;
+	u8 hindex;
+
+	if (!compare_ether_addr(phdr->h_source, adapter->mac_addr))
+		return;
+
+	if (adapter->fhash.fnum >= adapter->fhash.fmax)
+		return;
+
+	memcpy(&src_addr, phdr->h_source, ETH_ALEN);
+	hindex = QLCNIC_MAC_HASH(src_addr) & (QLCNIC_LB_MAX_FILTERS - 1);
+	head = &(adapter->fhash.fhead[hindex]);
+
+	hlist_for_each_entry_safe(tmp_fil, tmp_hnode, n, head, fnode) {
+		if (!memcmp(tmp_fil->faddr, &src_addr, ETH_ALEN)) {
+			tmp_fil->ftime = jiffies;
+			return;
+		}
+	}
+
+	fil = kzalloc(sizeof(struct qlcnic_filter), GFP_ATOMIC);
+	if (!fil)
+		return;
+
+	qlcnic_change_filter(adapter, src_addr, tx_ring);
+
+	fil->ftime = jiffies;
+	memcpy(fil->faddr, &src_addr, ETH_ALEN);
+	spin_lock(&adapter->mac_learn_lock);
+	hlist_add_head(&(fil->fnode), head);
+	adapter->fhash.fnum++;
+	spin_unlock(&adapter->mac_learn_lock);
+}
+
+static void
 qlcnic_tso_check(struct net_device *netdev,
 		struct qlcnic_host_tx_ring *tx_ring,
 		struct cmd_desc_type0 *first_desc,
@@ -2090,6 +2207,9 @@ qlcnic_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 
 	qlcnic_tso_check(netdev, tx_ring, first_desc, skb);
 
+	if (qlcnic_mac_learn)
+		qlcnic_send_filter(adapter, tx_ring, first_desc, skb);
+
 	qlcnic_update_cmd_producer(adapter, tx_ring);
 
 	adapter->stats.txbytes += skb->len;
@@ -2900,6 +3020,9 @@ qlcnic_fw_poll_work(struct work_struct *work)
 	if (qlcnic_check_health(adapter))
 		return;
 
+	if (adapter->fhash.fnum)
+		qlcnic_prune_lb_filters(adapter);
+
 reschedule:
 	qlcnic_schedule_work(adapter, qlcnic_fw_poll_work, FW_POLL_DELAY);
 }
-- 
1.6.0.2

