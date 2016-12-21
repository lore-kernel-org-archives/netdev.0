From: Satha Koteswara Rao <satha.rao@caviumnetworks.com>
Subject: [RFC PATCH 2/7] VF driver changes to enable hooks to get kernel
 notifications
Date: Wed, 21 Dec 2016 14:16:46 +0530
Message-ID: <1482310011-1862-3-git-send-email-satha.rao@caviumnetworks.com>
References: <1482310011-1862-1-git-send-email-satha.rao@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: rvatsavayi@caviumnetworks.com, rric@kernel.org, david.daney@cavium.com,
 netdev@vger.kernel.org, satha.rao@caviumnetworks.com,
 derek.chickles@caviumnetworks.com, sgoutham@cavium.com, davem@davemloft.net,
 linux-arm-kernel@lists.infradead.org, philip.romanov@cavium.com
To: <linux-kernel@vger.kernel.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1482310011-1862-1-git-send-email-satha.rao@caviumnetworks.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

---
 drivers/net/ethernet/cavium/thunder/nicvf_main.c | 579 ++++++++++++++++++++++-
 1 file changed, 565 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_main.c b/drivers/net/ethernet/cavium/thunder/nicvf_main.c
index 8a37012..8f00bc7 100644
--- a/drivers/net/ethernet/cavium/thunder/nicvf_main.c
+++ b/drivers/net/ethernet/cavium/thunder/nicvf_main.c
@@ -52,6 +52,11 @@
 MODULE_VERSION(DRV_VERSION);
 MODULE_DEVICE_TABLE(pci, nicvf_id_table);
 
+static int veb_enabled;
+
+int uc_mc_list;
+module_param(uc_mc_list, int, 0644);
+
 static int debug = 0x00;
 module_param(debug, int, 0644);
 MODULE_PARM_DESC(debug, "Debug message level bitmap");
@@ -61,6 +66,132 @@
 MODULE_PARM_DESC(cpi_alg,
 		 "PFC algorithm (0=none, 1=VLAN, 2=VLAN16, 3=IP Diffserv)");
 
+/* Initialize the Shadow List */
+void nicvf_shadow_list_init(struct netdev_hw_addr_list *list)
+{
+	INIT_LIST_HEAD(&list->list);
+	list->count = 0;
+}
+
+/*Set the sync it of the addr structure */
+void nicvf_shadow_list_setsync(struct netdev_hw_addr_list *list, int sync)
+{
+	struct netdev_hw_addr *ha, *tmp;
+
+	list_for_each_entry_safe(ha, tmp, &list->list, list) {
+		ha->synced = sync;
+	}
+}
+
+/*Flush the entire list */
+void nicvf_shadow_list_flush(struct netdev_hw_addr_list *list)
+{
+	struct netdev_hw_addr *ha, *tmp;
+
+	list_for_each_entry_safe(ha, tmp, &list->list, list) {
+		list_del(&ha->list);
+		kfree(ha);
+	}
+	list->count = 0;
+}
+
+/*Return the number of items in the list */
+int nicvf_shadow_list_count(struct netdev_hw_addr_list *list)
+{
+	return list->count;
+}
+
+/*Check if the list is empty */
+int nicvf_shadow_list_empty(struct netdev_hw_addr_list *list)
+{
+	return (list->count == 0);
+}
+
+/* Add item to list */
+int nicvf_shadow_list_add(struct netdev_hw_addr_list *list, unsigned char *addr)
+{
+	struct netdev_hw_addr *ha;
+	int alloc_size;
+
+	alloc_size = sizeof(*ha);
+	ha = kmalloc(alloc_size, GFP_ATOMIC);
+	if (!ha)
+		return -ENOMEM;
+	ether_addr_copy(ha->addr, addr);
+	ha->synced = 0;
+	list_add_tail(&ha->list, &list->list);
+	list->count++;
+	return 0;
+}
+
+/* Delete item in the list given the address */
+void nicvf_shadow_list_del_ha(struct netdev_hw_addr_list *list,
+			      struct netdev_hw_addr *ha)
+{
+	list_del(&ha->list);
+	kfree(ha);
+	list->count--;
+}
+
+/* Delete item in list by address */
+int nicvf_shadow_list_del(struct netdev_hw_addr_list *list, unsigned char *addr)
+{
+	struct netdev_hw_addr *ha, *tmp;
+
+	list_for_each_entry_safe(ha, tmp, &list->list, list)
+		if (ether_addr_equal(ha->addr, addr))
+			nicvf_shadow_list_del_ha(list, ha);
+
+	return -ENOENT;
+}
+
+/* Delete the addresses that are not in the netdev list and send delete
+ * notification
+ */
+int nicvf_shadow_list_delsync(struct netdev_hw_addr_list *list,
+			      struct nicvf *nic, int addr_type)
+{
+	int is_modified = 0;
+	union nic_mbx mbx = {};
+	struct netdev_hw_addr *ha, *tmp;
+
+	list_for_each_entry_safe(ha, tmp, &list->list, list) {
+		if (ha->synced == 1) {
+			if (!uc_mc_list) {
+				mbx.msg.msg = NIC_MBOX_MSG_UC_MC;
+				mbx.uc_mc_cfg.vf_id = nic->vf_id;
+				mbx.uc_mc_cfg.addr_type = addr_type;
+				mbx.uc_mc_cfg.is_flush = 0;
+				mbx.uc_mc_cfg.is_add = 0;
+				ether_addr_copy(mbx.uc_mc_cfg.mac_addr,
+						ha->addr);
+				if (nicvf_send_msg_to_pf(nic, &mbx)) {
+					netdev_err(nic->netdev,
+						   "PF not respond to MSG_UC_MC\n");
+				}
+			}
+			is_modified = 1;
+			nicvf_shadow_list_del_ha(list, ha);
+		}
+	}
+	return is_modified;
+}
+
+/*Check if an entry with the mac address exits in the list */
+int nicvf_shadow_list_find(struct netdev_hw_addr_list *list,
+			   unsigned char *addr)
+{
+	struct netdev_hw_addr *ha;
+
+	list_for_each_entry(ha, &list->list, list) {
+		if (ether_addr_equal(ha->addr, addr)) {
+			ha->synced = 0;
+			return 0;
+		}
+	}
+	return -ENOENT;
+}
+
 static inline u8 nicvf_netdev_qidx(struct nicvf *nic, u8 qidx)
 {
 	if (nic->sqs_mode)
@@ -113,22 +244,198 @@ static void nicvf_write_to_mbx(struct nicvf *nic, union nic_mbx *mbx)
 	nicvf_reg_write(nic, NIC_VF_PF_MAILBOX_0_1 + 8, msg[1]);
 }
 
+bool pf_ack_required(struct nicvf *nic, union nic_mbx *mbx)
+{
+	if (mbx->msg.msg == NIC_MBOX_MSG_PROMISC ||
+	    !nic->wait_for_ack)
+		return false;
+
+	return true;
+}
+
+void submit_uc_mc_mbox_msg(struct nicvf *nic, int vf, int flush, int addr_type,
+			   u8 *mac)
+{
+	union nic_mbx mbx = {};
+
+	mbx.msg.msg = NIC_MBOX_MSG_UC_MC;
+	mbx.uc_mc_cfg.vf_id = vf;
+	mbx.uc_mc_cfg.addr_type = addr_type;
+	mbx.uc_mc_cfg.is_flush = flush;
+	mbx.uc_mc_cfg.is_add = !flush;
+	if (mac)
+		ether_addr_copy(mbx.uc_mc_cfg.mac_addr, mac);
+
+	if (nicvf_send_msg_to_pf(nic, &mbx) == -EBUSY) {
+		netdev_err(nic->netdev,
+			   "PF didn't respond to MSG_UC_MC flush\n");
+	}
+}
+
+void send_uc_mc_msg(struct work_struct *work)
+{
+	struct nicvf *nic = container_of(work, struct nicvf, dwork.work);
+	struct net_device *netdev = nic->netdev;
+	union nic_mbx mbx = {};
+	int is_modified1 = 0;
+	int is_modified2 = 0;
+
+	if (nic->send_op_link_status) {
+		mbx.msg.msg = nic->link_up ? NIC_MBOX_MSG_OP_UP :
+						NIC_MBOX_MSG_OP_DOWN;
+		if (nicvf_send_msg_to_pf(nic, &mbx)) {
+			netdev_err(nic->netdev,
+				   "PF not respond to msg %d\n", mbx.msg.msg);
+		}
+		nic->send_op_link_status = false;
+		return;
+	}
+
+	/* If the netdev list is empty */
+	if (netdev_uc_empty(netdev)) {
+		/* If shadow list is not empty */
+		if (!nicvf_shadow_list_empty(&nic->uc_shadow)) {
+			/* send uc flush notifcation */
+			nicvf_shadow_list_flush(&nic->uc_shadow);
+			submit_uc_mc_mbox_msg(nic, nic->vf_id, 1, 0, NULL);
+		}
+	} else {
+		/* If shadow list is empty add all and notify */
+		if (nicvf_shadow_list_empty(&nic->uc_shadow)) {
+			struct netdev_hw_addr *ha;
+
+			netdev_for_each_uc_addr(ha, netdev) {
+				nicvf_shadow_list_add(&nic->uc_shadow,
+						      ha->addr);
+				submit_uc_mc_mbox_msg(nic, nic->vf_id, 0, 0,
+						      ha->addr);
+			}
+		} else {
+			struct netdev_hw_addr *ha;
+
+			nicvf_shadow_list_setsync(&nic->uc_shadow, 1);
+			/* ADD the entries which are present in netdev list
+			 * and not present in shadow list
+			 */
+			netdev_for_each_uc_addr(ha, netdev) {
+				if (nicvf_shadow_list_find(&nic->uc_shadow,
+							   ha->addr)) {
+					is_modified1 = 1;
+					nicvf_shadow_list_add(&nic->uc_shadow,
+							      ha->addr);
+					if (uc_mc_list)
+						continue;
+					submit_uc_mc_mbox_msg(nic, nic->vf_id,
+							      0, 0, ha->addr);
+				}
+			}
+			/* Delete items that are not present in netdev list and
+			 *  present in shadow list
+			 */
+			is_modified2 = nicvf_shadow_list_delsync(
+					&nic->uc_shadow, nic, 0);
+			if (uc_mc_list && (is_modified1 || is_modified2)) {
+				/* Now the shadow list is updated,
+				 * send the entire list
+				 */
+				netdev_for_each_uc_addr(ha, netdev)
+					submit_uc_mc_mbox_msg(nic, nic->vf_id,
+							      0, 0, ha->addr);
+			}
+		}
+	}
+
+	is_modified1 = 0;
+	is_modified2 = 0;
+	if (netdev_mc_empty(netdev)) { // If the netdev list is empty
+		/* If shadow list is not empty */
+		if (!nicvf_shadow_list_empty(&nic->mc_shadow)) {
+			// send uc flush notifcation
+			nicvf_shadow_list_flush(&nic->mc_shadow);
+			submit_uc_mc_mbox_msg(nic, nic->vf_id, 1, 1, NULL);
+		}
+	} else {
+		/* If shadow list is empty add all and notfy */
+		if (nicvf_shadow_list_empty(&nic->mc_shadow)) {
+			struct netdev_hw_addr *ha;
+
+			netdev_for_each_mc_addr(ha, netdev) {
+				nicvf_shadow_list_add(&nic->mc_shadow,
+						      ha->addr);
+				submit_uc_mc_mbox_msg(nic, nic->vf_id, 0, 1,
+						      ha->addr);
+			}
+		} else {
+			struct netdev_hw_addr *ha;
+
+			nicvf_shadow_list_setsync(&nic->mc_shadow, 1);
+			/* ADD the entries which are present in netdev list and
+			 * not present in shadow list
+			 */
+			netdev_for_each_mc_addr(ha, netdev) {
+				if (nicvf_shadow_list_find(&nic->mc_shadow,
+							   ha->addr)) {
+					is_modified1 = 1;
+					nicvf_shadow_list_add(&nic->mc_shadow,
+							      ha->addr);
+					if (!uc_mc_list)
+						submit_uc_mc_mbox_msg(
+							nic, nic->vf_id, 0, 1,
+							ha->addr);
+				}
+			}
+			/* Delete items that are not present in netdev list and
+			 * present in shadow list
+			 */
+			is_modified2 = nicvf_shadow_list_delsync(
+					&nic->mc_shadow, nic, 1);
+			if (uc_mc_list && (is_modified1 || is_modified2)) {
+				/* Now the shadow list is updated, send the
+				 * entire list
+				 */
+				netdev_for_each_mc_addr(ha, netdev)
+					submit_uc_mc_mbox_msg(nic, nic->vf_id,
+							      0, 1, ha->addr);
+			}
+		}
+	}
+}
+
 int nicvf_send_msg_to_pf(struct nicvf *nic, union nic_mbx *mbx)
 {
 	int timeout = NIC_MBOX_MSG_TIMEOUT;
 	int sleep = 10;
 
+	if (nic->pf_ack_waiting) {
+		timeout += 20;
+		while (nic->pf_ack_waiting) {
+			msleep(sleep);
+			if (!timeout)
+				break;
+			timeout -= sleep;
+		}
+		timeout = NIC_MBOX_MSG_TIMEOUT;
+	}
 	nic->pf_acked = false;
 	nic->pf_nacked = false;
+	nic->pf_ack_waiting = true;
 
 	nicvf_write_to_mbx(nic, mbx);
 
+	if (!pf_ack_required(nic, mbx)) {
+		nic->pf_ack_waiting = false;
+		nic->pf_acked = true;
+		nic->pf_nacked = true;
+		return 0;
+	}
 	/* Wait for previous message to be acked, timeout 2sec */
 	while (!nic->pf_acked) {
 		if (nic->pf_nacked) {
-			netdev_err(nic->netdev,
-				   "PF NACK to mbox msg 0x%02x from VF%d\n",
-				   (mbx->msg.msg & 0xFF), nic->vf_id);
+			if (mbx->msg.msg != NIC_MBOX_MSG_READY)
+				netdev_info(nic->netdev,
+					    "PF NACK to mbox msg 0x%02x from VF%d\n",
+					    (mbx->msg.msg & 0xFF), nic->vf_id);
+			nic->pf_ack_waiting = false;
 			return -EINVAL;
 		}
 		msleep(sleep);
@@ -139,9 +446,11 @@ int nicvf_send_msg_to_pf(struct nicvf *nic, union nic_mbx *mbx)
 			netdev_err(nic->netdev,
 				   "PF didn't ACK to mbox msg 0x%02x from VF%d\n",
 				   (mbx->msg.msg & 0xFF), nic->vf_id);
+			nic->pf_ack_waiting = false;
 			return -EBUSY;
 		}
 	}
+	nic->pf_ack_waiting = false;
 	return 0;
 }
 
@@ -151,9 +460,14 @@ int nicvf_send_msg_to_pf(struct nicvf *nic, union nic_mbx *mbx)
 static int nicvf_check_pf_ready(struct nicvf *nic)
 {
 	union nic_mbx mbx = {};
+	int ret = 0;
 
 	mbx.msg.msg = NIC_MBOX_MSG_READY;
-	if (nicvf_send_msg_to_pf(nic, &mbx)) {
+	ret = nicvf_send_msg_to_pf(nic, &mbx);
+	if (ret == -EINVAL) {
+		/* VF disabled through module parameter */
+		return 0;
+	} else if (ret) {
 		netdev_err(nic->netdev,
 			   "PF didn't respond to READY msg\n");
 		return 0;
@@ -193,12 +507,22 @@ static void  nicvf_handle_mbx_intr(struct nicvf *nic)
 		nic->vf_id = mbx.nic_cfg.vf_id & 0x7F;
 		nic->tns_mode = mbx.nic_cfg.tns_mode & 0x7F;
 		nic->node = mbx.nic_cfg.node_id;
+		nic->true_vf = mbx.nic_cfg.is_pf;
+		if (!veb_enabled)
+			veb_enabled = mbx.nic_cfg.veb_enabled;
+		if (veb_enabled)
+			snprintf(nic->phys_port_name, IFNAMSIZ, "%d %d %d %d",
+				 nic->node, mbx.nic_cfg.bgx_id,
+				 mbx.nic_cfg.lmac, mbx.nic_cfg.chan);
 		if (!nic->set_mac_pending)
 			ether_addr_copy(nic->netdev->dev_addr,
 					mbx.nic_cfg.mac_addr);
 		nic->sqs_mode = mbx.nic_cfg.sqs_mode;
 		nic->loopback_supported = mbx.nic_cfg.loopback_supported;
-		nic->link_up = false;
+		if (veb_enabled)
+			nic->link_up = mbx.nic_cfg.pf_up;
+		else
+			nic->link_up = false;
 		nic->duplex = 0;
 		nic->speed = 0;
 		break;
@@ -208,6 +532,12 @@ static void  nicvf_handle_mbx_intr(struct nicvf *nic)
 	case NIC_MBOX_MSG_NACK:
 		nic->pf_nacked = true;
 		break;
+	case NIC_MBOX_MSG_ADMIN_VLAN:
+		if (mbx.vlan_cfg.vlan_add && nic->admin_vlan_id == -1)
+			nic->admin_vlan_id = mbx.vlan_cfg.vlan_id;
+		else if (!mbx.vlan_cfg.vlan_add)
+			nic->admin_vlan_id = -1;
+		break;
 	case NIC_MBOX_MSG_RSS_SIZE:
 		nic->rss_info.rss_size = mbx.rss_size.ind_tbl_size;
 		nic->pf_acked = true;
@@ -216,16 +546,21 @@ static void  nicvf_handle_mbx_intr(struct nicvf *nic)
 		nicvf_read_bgx_stats(nic, &mbx.bgx_stats);
 		nic->pf_acked = true;
 		break;
-	case NIC_MBOX_MSG_BGX_LINK_CHANGE:
+	case NIC_MBOX_MSG_CFG_DONE:
 		nic->pf_acked = true;
 		nic->link_up = mbx.link_status.link_up;
 		nic->duplex = mbx.link_status.duplex;
 		nic->speed = mbx.link_status.speed;
+		break;
+	case NIC_MBOX_MSG_BGX_LINK_CHANGE:
+		nic->link_up = mbx.link_status.link_up;
+		nic->duplex = mbx.link_status.duplex;
+		nic->speed = mbx.link_status.speed;
 		if (nic->link_up) {
 			netdev_info(nic->netdev, "%s: Link is Up %d Mbps %s\n",
 				    nic->netdev->name, nic->speed,
 				    nic->duplex == DUPLEX_FULL ?
-				"Full duplex" : "Half duplex");
+				    "Full duplex" : "Half duplex");
 			netif_carrier_on(nic->netdev);
 			netif_tx_start_all_queues(nic->netdev);
 		} else {
@@ -563,6 +898,14 @@ static inline void nicvf_set_rxhash(struct net_device *netdev,
 	skb_set_hash(skb, hash, hash_type);
 }
 
+static inline bool is_vf_vlan(struct nicvf *nic, u16 vid)
+{
+	if (veb_enabled && ((nic->admin_vlan_id & 0xFFF) == vid))
+		return false;
+
+	return true;
+}
+
 static void nicvf_rcv_pkt_handler(struct net_device *netdev,
 				  struct napi_struct *napi,
 				  struct cqe_rx_t *cqe_rx)
@@ -617,7 +960,8 @@ static void nicvf_rcv_pkt_handler(struct net_device *netdev,
 	skb->protocol = eth_type_trans(skb, netdev);
 
 	/* Check for stripped VLAN */
-	if (cqe_rx->vlan_found && cqe_rx->vlan_stripped)
+	if (cqe_rx->vlan_found && cqe_rx->vlan_stripped &&
+	    is_vf_vlan(nic, (ntohs(cqe_rx->vlan_tci) & 0xFFF)))
 		__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q),
 				       ntohs((__force __be16)cqe_rx->vlan_tci));
 
@@ -1151,6 +1495,8 @@ int nicvf_stop(struct net_device *netdev)
 	/* disable mailbox interrupt */
 	nicvf_disable_intr(nic, NICVF_INTR_MBOX, 0);
 
+	//MBOX interrupts disabled, don't expect any ACK's from PF
+	nic->wait_for_ack = false;
 	nicvf_unregister_interrupts(nic);
 
 	nicvf_free_cq_poll(nic);
@@ -1182,6 +1528,8 @@ int nicvf_open(struct net_device *netdev)
 
 	netif_carrier_off(netdev);
 
+	//MBOX interrupts enabled, so wait for ACK from PF
+	nic->wait_for_ack = true;
 	err = nicvf_register_misc_interrupt(nic);
 	if (err)
 		return err;
@@ -1202,7 +1550,8 @@ int nicvf_open(struct net_device *netdev)
 	}
 
 	/* Check if we got MAC address from PF or else generate a radom MAC */
-	if (!nic->sqs_mode && is_zero_ether_addr(netdev->dev_addr)) {
+	if ((veb_enabled || !nic->sqs_mode) &&
+	    is_zero_ether_addr(netdev->dev_addr)) {
 		eth_hw_addr_random(netdev);
 		nicvf_hw_set_mac_addr(nic, netdev);
 	}
@@ -1268,7 +1617,17 @@ int nicvf_open(struct net_device *netdev)
 
 	/* Send VF config done msg to PF */
 	mbx.msg.msg = NIC_MBOX_MSG_CFG_DONE;
-	nicvf_write_to_mbx(nic, &mbx);
+	if (veb_enabled)
+		nicvf_send_msg_to_pf(nic, &mbx);
+	else
+		nicvf_write_to_mbx(nic, &mbx);
+
+	if (veb_enabled && nic->link_up) {
+		nic->send_op_link_status = true;
+		queue_delayed_work(nic->uc_mc_msg, &nic->dwork, 0);
+		netif_carrier_on(netdev);
+		netif_tx_start_all_queues(netdev);
+	}
 
 	return 0;
 cleanup:
@@ -1299,6 +1658,8 @@ static int nicvf_change_mtu(struct net_device *netdev, int new_mtu)
 		return -EINVAL;
 
 	netdev->mtu = new_mtu;
+	if (!nic->link_up)
+		return 0;
 
 	if (!netif_running(netdev))
 		return 0;
@@ -1508,6 +1869,142 @@ static int nicvf_set_features(struct net_device *netdev,
 	return 0;
 }
 
+static int nicvf_vlan_rx_add_vid(struct net_device *netdev,
+				 __always_unused __be16 proto, u16 vid)
+{
+	struct nicvf *nic = netdev_priv(netdev);
+	union nic_mbx mbx = {};
+	int ret = 0;
+
+	if (!veb_enabled)
+		return 0;
+
+	if (nic->admin_vlan_id != -1) {
+		netdev_err(nic->netdev,
+			   "VF %d could not add VLAN %d\n", nic->vf_id, vid);
+		return -1;
+	}
+	mbx.msg.msg = NIC_MBOX_MSG_VLAN;
+	mbx.vlan_cfg.vf_id = nic->vf_id;
+	mbx.vlan_cfg.vlan_id = vid;
+	mbx.vlan_cfg.vlan_add = 1;
+	ret = nicvf_send_msg_to_pf(nic, &mbx);
+	if (ret == -EINVAL) {
+		netdev_err(nic->netdev, "VF %d could not add VLAN %d\n",
+			   nic->vf_id, vid);
+	} else if (ret == -EBUSY) {
+		netdev_err(nic->netdev,
+			   "PF didn't respond to VLAN msg VLAN ID: %d VF: %d\n",
+			   vid, nic->vf_id);
+	}
+	return ret;
+}
+
+static int nicvf_vlan_rx_kill_vid(struct net_device *netdev,
+				  __always_unused __be16 proto, u16 vid)
+{
+	struct nicvf *nic = netdev_priv(netdev);
+	union nic_mbx mbx = {};
+
+	if (!veb_enabled)
+		return 0;
+
+	mbx.msg.msg = NIC_MBOX_MSG_VLAN;
+	mbx.vlan_cfg.vf_id = nic->vf_id;
+	mbx.vlan_cfg.vlan_id = vid;
+	mbx.vlan_cfg.vlan_add = 0;
+	if (nicvf_send_msg_to_pf(nic, &mbx)) {
+		netdev_err(nic->netdev,
+			   "PF didn't respond to VLAN msg VLAN ID: %d VF: %d\n",
+			   vid, nic->vf_id);
+		return -1;
+	}
+	return 0;
+}
+
+void nicvf_set_rx_mode(struct net_device *netdev)
+{
+	struct nicvf *nic = netdev_priv(netdev);
+
+	if (!veb_enabled)
+		return;
+
+	queue_delayed_work(nic->uc_mc_msg, &nic->dwork, 0);
+}
+
+void nicvf_change_rx_flags(struct net_device *netdev, int flags)
+{
+	struct nicvf *nic = netdev_priv(netdev);
+	union nic_mbx mbx = {};
+
+	if (!veb_enabled)
+		return;
+
+	mbx.msg.msg = NIC_MBOX_MSG_PROMISC;
+	mbx.promisc_cfg.vf_id = nic->vf_id;
+	mbx.promisc_cfg.on = netdev->flags & IFF_PROMISC;
+	if (nicvf_send_msg_to_pf(nic, &mbx)) {
+		netdev_err(nic->netdev,
+			   "PF didn't respond to PROMISC Mode\n");
+		return;
+	}
+}
+
+int nicvf_set_vf_vlan(struct net_device *netdev, int vf, u16 vlan, u8 qos,
+		      __be16 vlan_proto)
+{
+	struct nicvf *nic = netdev_priv(netdev);
+	int is_add = (vlan | qos);
+	union nic_mbx mbx = {};
+	int ret = 0;
+
+	if (!veb_enabled)
+		return 0;
+
+	mbx.msg.msg = NIC_MBOX_MSG_ADMIN_VLAN;
+	mbx.vlan_cfg.vf_id   = vf;
+	mbx.vlan_cfg.vlan_add = is_add;
+	mbx.vlan_cfg.vlan_id = vlan;
+
+	ret = nicvf_send_msg_to_pf(nic, &mbx);
+	if (ret == -EINVAL) {
+		netdev_err(nic->netdev, "ADMIN VLAN %s failed For Vf %d\n",
+			   is_add ? "Add" : "Delete", vf);
+	} else if (ret == -EBUSY) {
+		netdev_err(nic->netdev,
+			   "PF didn't respond to ADMIN VLAN UPDATE msg\n");
+	}
+	return ret;
+}
+
+static int nicvf_get_phys_port_name(struct net_device *netdev, char *name,
+				    size_t len)
+{
+	struct nicvf *nic = netdev_priv(netdev);
+	int plen;
+
+	plen = snprintf(name, len, "%s", nic->phys_port_name);
+
+	if (plen >= len)
+		return -EINVAL;
+
+	return 0;
+}
+
+static int nicvf_get_phys_port_id(struct net_device *netdev,
+				  struct netdev_phys_item_id *ppid)
+{
+	struct nicvf *nic = netdev_priv(netdev);
+
+	if (veb_enabled && !nic->true_vf)
+		return -EOPNOTSUPP;
+
+	ppid->id_len = min_t(int, sizeof(netdev->dev_addr), sizeof(ppid->id));
+	memcpy(ppid->id, netdev->dev_addr, ppid->id_len);
+
+	return 0;
+}
+
 static const struct net_device_ops nicvf_netdev_ops = {
 	.ndo_open		= nicvf_open,
 	.ndo_stop		= nicvf_stop,
@@ -1518,6 +2015,13 @@ static int nicvf_set_features(struct net_device *netdev,
 	.ndo_tx_timeout         = nicvf_tx_timeout,
 	.ndo_fix_features       = nicvf_fix_features,
 	.ndo_set_features       = nicvf_set_features,
+	.ndo_vlan_rx_add_vid    = nicvf_vlan_rx_add_vid,
+	.ndo_vlan_rx_kill_vid   = nicvf_vlan_rx_kill_vid,
+	.ndo_set_rx_mode        = nicvf_set_rx_mode,
+	.ndo_change_rx_flags    = nicvf_change_rx_flags,
+	.ndo_set_vf_vlan        = nicvf_set_vf_vlan,
+	.ndo_get_phys_port_name = nicvf_get_phys_port_name,
+	.ndo_get_phys_port_id   = nicvf_get_phys_port_id,
 };
 
 static int nicvf_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
@@ -1576,6 +2080,7 @@ static int nicvf_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	nic->pdev = pdev;
 	nic->pnicvf = nic;
 	nic->max_queues = qcount;
+	nic->pf_ack_waiting = false;
 
 	/* MAP VF's configuration registers */
 	nic->reg_base = pcim_iomap(pdev, PCI_CFG_REG_BAR_NUM, 0);
@@ -1595,6 +2100,8 @@ static int nicvf_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	if (err)
 		goto err_free_netdev;
 
+	//MBOX interrupts enabled, so wait for ACK from PF
+	nic->wait_for_ack = true;
 	/* Check if PF is alive and get MAC address for this VF */
 	err = nicvf_register_misc_interrupt(nic);
 	if (err)
@@ -1619,12 +2126,13 @@ static int nicvf_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	netdev->hw_features = (NETIF_F_RXCSUM | NETIF_F_IP_CSUM | NETIF_F_SG |
 			       NETIF_F_TSO | NETIF_F_GRO |
-			       NETIF_F_HW_VLAN_CTAG_RX);
-
-	netdev->hw_features |= NETIF_F_RXHASH;
+			       NETIF_F_HW_VLAN_CTAG_RX | NETIF_F_RXHASH);
 
 	netdev->features |= netdev->hw_features;
-	netdev->hw_features |= NETIF_F_LOOPBACK;
+	if (veb_enabled)
+		netdev->features |= NETIF_F_HW_VLAN_CTAG_FILTER;
+	else
+		netdev->hw_features |= NETIF_F_LOOPBACK;
 
 	netdev->vlan_features = NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_TSO;
 
@@ -1642,6 +2150,37 @@ static int nicvf_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	nic->msg_enable = debug;
 
 	nicvf_set_ethtool_ops(netdev);
+	if (veb_enabled) {
+		int bgx, lmac, chan, node, ret;
+
+		ret = sscanf(nic->phys_port_name, "%d %d %d %d", &node, &bgx,
+			     &lmac, &chan);
+		if (nic->true_vf) {
+			dev_info(dev,
+				 "interface %s enabled with node %d VF %d channel %d directly attached to physical port n%d-bgx-%d-%d\n",
+				 netdev->name, node, nic->vf_id, chan, node,
+				 bgx, lmac);
+		} else {
+			dev_info(dev,
+				 "interface %s enabled with node %d VF %d channel %d attached to physical port n%d-bgx-%d-%d\n",
+				 netdev->name, node, nic->vf_id, chan, node,
+				 bgx, lmac);
+		}
+		snprintf(nic->phys_port_name, IFNAMSIZ, "n%d-bgx-%d-%d",
+			 node, bgx, lmac);
+		nicvf_shadow_list_init(&nic->uc_shadow);
+		nicvf_shadow_list_init(&nic->mc_shadow);
+
+		nic->admin_vlan_id = -1;
+		nic->send_op_link_status = false;
+		nic->uc_mc_msg = alloc_workqueue("uc_mc_msg", WQ_UNBOUND |
+						 WQ_MEM_RECLAIM, 1);
+		if (!nic->uc_mc_msg)
+			return -ENOMEM;
+		INIT_DELAYED_WORK(&nic->dwork, send_uc_mc_msg);
+	} else {
+		strlcpy(nic->phys_port_name, netdev->name, IFNAMSIZ);
+	}
 
 	return 0;
 
@@ -1669,6 +2208,12 @@ static void nicvf_remove(struct pci_dev *pdev)
 		return;
 
 	nic = netdev_priv(netdev);
+	if (veb_enabled) {
+		if (nicvf_shadow_list_count(&nic->uc_shadow))
+			nicvf_shadow_list_flush(&nic->uc_shadow);
+		if (nicvf_shadow_list_count(&nic->mc_shadow))
+			nicvf_shadow_list_flush(&nic->mc_shadow);
+	}
 	pnetdev = nic->pnicvf->netdev;
 
 	/* Check if this Qset is assigned to different VF.
@@ -1678,6 +2223,12 @@ static void nicvf_remove(struct pci_dev *pdev)
 		unregister_netdev(pnetdev);
 	nicvf_unregister_interrupts(nic);
 	pci_set_drvdata(pdev, NULL);
+	if (veb_enabled) {
+		if (nic->uc_mc_msg) {
+			cancel_delayed_work_sync(&nic->dwork);
+			destroy_workqueue(nic->uc_mc_msg);
+		}
+	}
 	if (nic->drv_stats)
 		free_percpu(nic->drv_stats);
 	free_netdev(netdev);
-- 
1.8.3.1
