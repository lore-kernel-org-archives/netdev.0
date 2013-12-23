From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH 01/21] net: slight optimization of addr
	compare for some modules
Date: Mon, 23 Dec 2013 13:09:36 +0800
Message-ID: <52B7C590.7070708@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>, Netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	<e1000-devel@lists.sourceforge.net>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Use the recently added and possibly more efficient
ether_addr_equal_unaligned to instead of memcmp.

Cc: "David S. Miller" <davem@davemloft.net>
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: e1000-devel@lists.sourceforge.net
Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/bonding/bond_3ad.c                        |  2 +-
 drivers/net/ethernet/3com/3c509.c                     |  3 +--
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c        | 10 ++++------
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c     |  2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c      |  2 +-
 drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c    |  2 +-
 drivers/net/ethernet/chelsio/cxgb3/l2t.c              |  2 +-
 drivers/net/ethernet/cisco/enic/enic_pp.c             |  2 +-
 drivers/net/ethernet/emulex/benet/be_main.c           |  2 +-
 drivers/net/ethernet/intel/igbvf/netdev.c             |  2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c        |  3 +--
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c        |  4 ++--
 drivers/net/ethernet/mellanox/mlx4/resource_tracker.c |  2 +-
 drivers/net/ethernet/micrel/ksz884x.c                 |  9 ++++-----
 drivers/net/ethernet/neterion/vxge/vxge-main.c        |  2 +-
 drivers/net/ethernet/packetengines/yellowfin.c        |  8 ++------
 drivers/net/ethernet/qlogic/netxen/netxen_nic_hw.c    |  2 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c        |  4 ++--
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c        |  4 ++--
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c      |  4 ++--
 drivers/net/ethernet/renesas/sh_eth.c                 |  2 +-
 drivers/net/ethernet/seeq/sgiseeq.c                   |  2 +-
 drivers/net/ethernet/sun/sunvnet.c                    |  2 +-
 drivers/net/ethernet/ti/cpsw_ale.c                    |  2 +-
 drivers/net/fddi/skfp/fplustm.c                       |  3 ++-
 drivers/net/plip/plip.c                               |  2 +-
 net/caif/cfrfml.c                                     |  2 +-
 27 files changed, 39 insertions(+), 47 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index 58c2249..355f49e 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -91,7 +91,7 @@
 //endalloun
 
 // compare MAC addresses
-#define MAC_ADDRESS_COMPARE(A, B) memcmp(A, B, ETH_ALEN)
+#define MAC_ADDRESS_COMPARE(A, B) !ether_addr_equal_unaligned((u8 *)A, (u8 *)B)
 
 static struct mac_addr null_mac_addr = { { 0, 0, 0, 0, 0, 0 } };
 static u16 ad_ticks_per_sec;
diff --git a/drivers/net/ethernet/3com/3c509.c b/drivers/net/ethernet/3com/3c509.c
index ede8daa..f84de84 100644
--- a/drivers/net/ethernet/3com/3c509.c
+++ b/drivers/net/ethernet/3com/3c509.c
@@ -252,8 +252,7 @@ static int el3_isa_id_sequence(__be16 *phys_addr)
 		for (i = 0; i < el3_cards; i++) {
 			struct el3_private *lp = netdev_priv(el3_devs[i]);
 			if (lp->type == EL3_PNP &&
-			    !memcmp(phys_addr, el3_devs[i]->dev_addr,
-				    ETH_ALEN)) {
+			    ether_addr_equal_unaligned(phys_addr, el3_devs[i]->dev_addr)) {
 				if (el3_debug > 3)
 					pr_debug("3c509 with address %02x %02x %02x %02x %02x %02x was found by ISAPnP\n",
 						phys_addr[0] & 0xff, phys_addr[0] >> 8,
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
index 32c92ab..b9b86b5 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
@@ -663,7 +663,7 @@ static int bnx2x_check_mac_add(struct bnx2x *bp,
 
 	/* Check if a requested MAC already exists */
 	list_for_each_entry(pos, &o->head, link)
-		if (!memcmp(data->mac.mac, pos->u.mac.mac, ETH_ALEN) &&
+		if (ether_addr_equal_unaligned(data->mac.mac, pos->u.mac.mac) &&
 		    (data->mac.is_inner_mac == pos->u.mac.is_inner_mac))
 			return -EEXIST;
 
@@ -696,8 +696,7 @@ static int bnx2x_check_vlan_mac_add(struct bnx2x *bp,
 
 	list_for_each_entry(pos, &o->head, link)
 		if ((data->vlan_mac.vlan == pos->u.vlan_mac.vlan) &&
-		    (!memcmp(data->vlan_mac.mac, pos->u.vlan_mac.mac,
-				  ETH_ALEN)) &&
+		    (ether_addr_equal_unaligned(data->vlan_mac.mac, pos->u.vlan_mac.mac)) &&
 		    (data->vlan_mac.is_inner_mac ==
 		     pos->u.vlan_mac.is_inner_mac))
 			return -EEXIST;
@@ -716,7 +715,7 @@ static struct bnx2x_vlan_mac_registry_elem *
 	DP(BNX2X_MSG_SP, "Checking MAC %pM for DEL command\n", data->mac.mac);
 
 	list_for_each_entry(pos, &o->head, link)
-		if ((!memcmp(data->mac.mac, pos->u.mac.mac, ETH_ALEN)) &&
+		if ((ether_addr_equal_unaligned(data->mac.mac, pos->u.mac.mac)) &&
 		    (data->mac.is_inner_mac == pos->u.mac.is_inner_mac))
 			return pos;
 
@@ -751,8 +750,7 @@ static struct bnx2x_vlan_mac_registry_elem *
 
 	list_for_each_entry(pos, &o->head, link)
 		if ((data->vlan_mac.vlan == pos->u.vlan_mac.vlan) &&
-		    (!memcmp(data->vlan_mac.mac, pos->u.vlan_mac.mac,
-			     ETH_ALEN)) &&
+		    (ether_addr_equal_unaligned(data->vlan_mac.mac, pos->u.vlan_mac.mac)) &&
 		    (data->vlan_mac.is_inner_mac ==
 		     pos->u.vlan_mac.is_inner_mac))
 			return pos;
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
index 2e46c28..c59c1a4 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
@@ -3605,7 +3605,7 @@ enum sample_bulletin_result bnx2x_sample_bulletin(struct bnx2x *bp)
 
 	/* the mac address in bulletin board is valid and is new */
 	if (bulletin.valid_bitmap & 1 << MAC_ADDR_VALID &&
-	    memcmp(bulletin.mac, bp->old_bulletin.mac, ETH_ALEN)) {
+	    !ether_addr_equal_unaligned(bulletin.mac, bp->old_bulletin.mac)) {
 		/* update new mac to net device */
 		memcpy(bp->dev->dev_addr, bulletin.mac, ETH_ALEN);
 	}
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c
index efa8a15..c6b9b5d 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c
@@ -1702,7 +1702,7 @@ static void bnx2x_vf_mbx_set_q_filters(struct bnx2x *bp,
 
 		/* ...and only the mac set by the ndo */
 		if (filters->n_mac_vlan_filters == 1 &&
-		    memcmp(filters->filters->mac, bulletin->mac, ETH_ALEN)) {
+		    !ether_addr_equal_unaligned(filters->filters->mac, bulletin->mac)) {
 			BNX2X_ERR("VF[%d] requested the addition of a mac address not matching the one configured by set_vf_mac ndo\n",
 				  vf->abs_vfid);
 
diff --git a/drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c
index 76ae0999..0dadfd4 100644
--- a/drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c
+++ b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c
@@ -182,7 +182,7 @@ static struct net_device *get_iff_from_mac(struct adapter *adapter,
 	for_each_port(adapter, i) {
 		struct net_device *dev = adapter->port[i];
 
-		if (!memcmp(dev->dev_addr, mac, ETH_ALEN)) {
+		if (ether_addr_equal_unaligned(dev->dev_addr, mac)) {
 			rcu_read_lock();
 			if (vlan && vlan != VLAN_VID_MASK) {
 				dev = __vlan_find_dev_deep(dev, htons(ETH_P_8021Q), vlan);
diff --git a/drivers/net/ethernet/chelsio/cxgb3/l2t.c b/drivers/net/ethernet/chelsio/cxgb3/l2t.c
index 8d53438..471c27a 100644
--- a/drivers/net/ethernet/chelsio/cxgb3/l2t.c
+++ b/drivers/net/ethernet/chelsio/cxgb3/l2t.c
@@ -429,7 +429,7 @@ found:
 		} else {
 			e->state = neigh->nud_state & NUD_CONNECTED ?
 			    L2T_STATE_VALID : L2T_STATE_STALE;
-			if (memcmp(e->dmac, neigh->ha, 6))
+			if (!ether_addr_equal_unaligned(e->dmac, neigh->ha))
 				setup_l2e_send_pending(dev, NULL, e);
 		}
 	}
diff --git a/drivers/net/ethernet/cisco/enic/enic_pp.c b/drivers/net/ethernet/cisco/enic/enic_pp.c
index 43464f0..5eefdc6 100644
--- a/drivers/net/ethernet/cisco/enic/enic_pp.c
+++ b/drivers/net/ethernet/cisco/enic/enic_pp.c
@@ -162,7 +162,7 @@ static int enic_are_pp_different(struct enic_port_profile *pp1,
 	return strcmp(pp1->name, pp2->name) | !!memcmp(pp1->instance_uuid,
 		pp2->instance_uuid, PORT_UUID_MAX) |
 		!!memcmp(pp1->host_uuid, pp2->host_uuid, PORT_UUID_MAX) |
-		!!memcmp(pp1->mac_addr, pp2->mac_addr, ETH_ALEN);
+		!ether_addr_equal_unaligned(pp1->mac_addr, pp2->mac_addr);
 }
 
 static int enic_pp_preassociate(struct enic *enic, int vf,
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index f67586a..8131979 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -287,7 +287,7 @@ static int be_mac_addr_set(struct net_device *netdev, void *p)
 	/* The MAC change did not happen, either due to lack of privilege
 	 * or PF didn't pre-provision.
 	 */
-	if (memcmp(addr->sa_data, mac, ETH_ALEN)) {
+	if (!ether_addr_equal_unaligned(addr->sa_data, mac)) {
 		status = -EPERM;
 		goto err;
 	}
diff --git a/drivers/net/ethernet/intel/igbvf/netdev.c b/drivers/net/ethernet/intel/igbvf/netdev.c
index 04bf22e..a6181ec 100644
--- a/drivers/net/ethernet/intel/igbvf/netdev.c
+++ b/drivers/net/ethernet/intel/igbvf/netdev.c
@@ -1745,7 +1745,7 @@ static int igbvf_set_mac(struct net_device *netdev, void *p)
 
 	hw->mac.ops.rar_set(hw, hw->mac.addr, 0);
 
-	if (memcmp(addr->sa_data, hw->mac.addr, 6))
+	if (!ether_addr_equal_unaligned(addr->sa_data, hw->mac.addr))
 		return -EADDRNOTAVAIL;
 
 	memcpy(netdev->dev_addr, addr->sa_data, netdev->addr_len);
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
index d6f0c0d..c73dcf6 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
@@ -715,8 +715,7 @@ static int ixgbe_set_vf_mac_addr(struct ixgbe_adapter *adapter,
 	}
 
 	if (adapter->vfinfo[vf].pf_set_mac &&
-	    memcmp(adapter->vfinfo[vf].vf_mac_addresses, new_mac,
-		   ETH_ALEN)) {
+	    !ether_addr_equal_unaligned(adapter->vfinfo[vf].vf_mac_addresses, new_mac)) {
 		e_warn(drv,
 		       "VF %d attempted to override administratively set MAC address\n"
 		       "Reload the VF driver to resume operations\n",
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 6f92090..f7309cc 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -782,7 +782,7 @@ static void update_mclist_flags(struct mlx4_en_priv *priv,
 	list_for_each_entry(dst_tmp, dst, list) {
 		found = false;
 		list_for_each_entry(src_tmp, src, list) {
-			if (!memcmp(dst_tmp->addr, src_tmp->addr, ETH_ALEN)) {
+			if (ether_addr_equal_unaligned(dst_tmp->addr, src_tmp->addr)) {
 				found = true;
 				break;
 			}
@@ -797,7 +797,7 @@ static void update_mclist_flags(struct mlx4_en_priv *priv,
 	list_for_each_entry(src_tmp, src, list) {
 		found = false;
 		list_for_each_entry(dst_tmp, dst, list) {
-			if (!memcmp(dst_tmp->addr, src_tmp->addr, ETH_ALEN)) {
+			if (ether_addr_equal_unaligned(dst_tmp->addr, src_tmp->addr)) {
 				dst_tmp->action = MCLIST_NONE;
 				found = true;
 				break;
diff --git a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
index 2f3f2bc..77a6612 100644
--- a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
+++ b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
@@ -3634,7 +3634,7 @@ static int validate_eth_header_mac(int slave, struct _rule_hw *eth_header,
 	    !is_broadcast_ether_addr(eth_header->eth.dst_mac)) {
 		list_for_each_entry_safe(res, tmp, rlist, list) {
 			be_mac = cpu_to_be64(res->mac << 16);
-			if (!memcmp(&be_mac, eth_header->eth.dst_mac, ETH_ALEN))
+			if (ether_addr_equal_unaligned(&be_mac, eth_header->eth.dst_mac))
 				return 0;
 		}
 		pr_err("MAC %pM doesn't belong to VF %d, Steering rule rejected\n",
diff --git a/drivers/net/ethernet/micrel/ksz884x.c b/drivers/net/ethernet/micrel/ksz884x.c
index ddd252a..063e346 100644
--- a/drivers/net/ethernet/micrel/ksz884x.c
+++ b/drivers/net/ethernet/micrel/ksz884x.c
@@ -4128,10 +4128,10 @@ static int hw_add_addr(struct ksz_hw *hw, u8 *mac_addr)
 	int i;
 	int j = ADDITIONAL_ENTRIES;
 
-	if (!memcmp(hw->override_addr, mac_addr, ETH_ALEN))
+	if (ether_addr_equal_unaligned(hw->override_addr, mac_addr))
 		return 0;
 	for (i = 0; i < hw->addr_list_size; i++) {
-		if (!memcmp(hw->address[i], mac_addr, ETH_ALEN))
+		if (ether_addr_equal_unaligned(hw->address[i], mac_addr))
 			return 0;
 		if (ADDITIONAL_ENTRIES == j && empty_addr(hw->address[i]))
 			j = i;
@@ -4149,7 +4149,7 @@ static int hw_del_addr(struct ksz_hw *hw, u8 *mac_addr)
 	int i;
 
 	for (i = 0; i < hw->addr_list_size; i++) {
-		if (!memcmp(hw->address[i], mac_addr, ETH_ALEN)) {
+		if (ether_addr_equal_unaligned(hw->address[i], mac_addr)) {
 			memset(hw->address[i], 0, ETH_ALEN);
 			writel(0, hw->io + ADD_ADDR_INCR * i +
 				KS_ADD_ADDR_0_HI);
@@ -7104,8 +7104,7 @@ static int pcidev_init(struct pci_dev *pdev, const struct pci_device_id *id)
 			       ETH_ALEN);
 		else {
 			memcpy(dev->dev_addr, sw->other_addr, ETH_ALEN);
-			if (!memcmp(sw->other_addr, hw->override_addr,
-				    ETH_ALEN))
+			if (ether_addr_equal_unaligned(sw->other_addr, hw->override_addr))
 				dev->dev_addr[5] += port->first_port;
 		}
 
diff --git a/drivers/net/ethernet/neterion/vxge/vxge-main.c b/drivers/net/ethernet/neterion/vxge/vxge-main.c
index 11b1c70..ae3a3ab 100644
--- a/drivers/net/ethernet/neterion/vxge/vxge-main.c
+++ b/drivers/net/ethernet/neterion/vxge/vxge-main.c
@@ -1430,7 +1430,7 @@ vxge_search_mac_addr_in_da_table(struct vxge_vpath *vpath, struct macInfo *mac)
 		return status;
 	}
 
-	while (memcmp(mac->macaddr, macaddr, ETH_ALEN)) {
+	while (!ether_addr_equal_unaligned(mac->macaddr, macaddr)) {
 		status = vxge_hw_vpath_mac_addr_get_next(vpath->handle,
 				macaddr, macmask);
 		if (status != VXGE_HW_OK)
diff --git a/drivers/net/ethernet/packetengines/yellowfin.c b/drivers/net/ethernet/packetengines/yellowfin.c
index 07a890e..609caaf 100644
--- a/drivers/net/ethernet/packetengines/yellowfin.c
+++ b/drivers/net/ethernet/packetengines/yellowfin.c
@@ -1096,12 +1096,8 @@ static int yellowfin_rx(struct net_device *dev)
 			if (status2 & 0x80) dev->stats.rx_dropped++;
 #ifdef YF_PROTOTYPE		/* Support for prototype hardware errata. */
 		} else if ((yp->flags & HasMACAddrBug)  &&
-			memcmp(le32_to_cpu(yp->rx_ring_dma +
-				entry*sizeof(struct yellowfin_desc)),
-				dev->dev_addr, 6) != 0 &&
-			memcmp(le32_to_cpu(yp->rx_ring_dma +
-				entry*sizeof(struct yellowfin_desc)),
-				"\377\377\377\377\377\377", 6) != 0) {
+			!ether_addr_equal_unaligned(le32_to_cpu(yp->rx_ring_dma + entry * sizeof(struct yellowfin_desc)), dev->dev_addr) &&
+			!ether_addr_equal_unaligned(le32_to_cpu(yp->rx_ring_dma + entry * sizeof(struct yellowfin_desc)), "\377\377\377\377\377\377")) {
 			if (bogus_rx++ == 0)
 				netdev_warn(dev, "Bad frame to %pM\n",
 					    buf_addr);
diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_hw.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_hw.c
index b72b6be..7a567ea 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_hw.c
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_hw.c
@@ -661,7 +661,7 @@ static int nx_p3_nic_add_mac(struct netxen_adapter *adapter,
 	list_for_each(head, del_list) {
 		cur = list_entry(head, nx_mac_list_t, list);
 
-		if (memcmp(addr, cur->mac_addr, ETH_ALEN) == 0) {
+		if (ether_addr_equal_unaligned(addr, cur->mac_addr)) {
 			list_move_tail(head, &adapter->mac_list);
 			return 0;
 		}
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
index 3fe971c..1564252 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
@@ -462,7 +462,7 @@ int qlcnic_nic_del_mac(struct qlcnic_adapter *adapter, const u8 *addr)
 	/* Delete MAC from the existing list */
 	list_for_each(head, &adapter->mac_list) {
 		cur = list_entry(head, struct qlcnic_mac_vlan_list, list);
-		if (memcmp(addr, cur->mac_addr, ETH_ALEN) == 0) {
+		if (ether_addr_equal_unaligned(addr, cur->mac_addr)) {
 			err = qlcnic_sre_macaddr_change(adapter, cur->mac_addr,
 							0, QLCNIC_MAC_DEL);
 			if (err)
@@ -483,7 +483,7 @@ int qlcnic_nic_add_mac(struct qlcnic_adapter *adapter, const u8 *addr, u16 vlan)
 	/* look up if already exists */
 	list_for_each(head, &adapter->mac_list) {
 		cur = list_entry(head, struct qlcnic_mac_vlan_list, list);
-		if (memcmp(addr, cur->mac_addr, ETH_ALEN) == 0 &&
+		if (ether_addr_equal_unaligned(addr, cur->mac_addr) &&
 		    cur->vlan_id == vlan)
 			return 0;
 	}
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
index 0538022..9a4a3d7 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
@@ -202,7 +202,7 @@ static struct qlcnic_filter *qlcnic_find_mac_filter(struct hlist_head *head,
 	struct hlist_node *n;
 
 	hlist_for_each_entry_safe(tmp_fil, n, head, fnode) {
-		if (!memcmp(tmp_fil->faddr, addr, ETH_ALEN) &&
+		if (ether_addr_equal_unaligned(tmp_fil->faddr, addr) &&
 		    tmp_fil->vlan_id == vlan_id)
 			return tmp_fil;
 	}
@@ -346,7 +346,7 @@ static void qlcnic_send_filter(struct qlcnic_adapter *adapter,
 	head = &(adapter->fhash.fhead[hindex]);
 
 	hlist_for_each_entry_safe(tmp_fil, n, head, fnode) {
-		if (!memcmp(tmp_fil->faddr, &src_addr, ETH_ALEN) &&
+		if (ether_addr_equal_unaligned(tmp_fil->faddr, &src_addr) &&
 		    tmp_fil->vlan_id == vlan_id) {
 			if (jiffies > (QLCNIC_READD_AGE * HZ + tmp_fil->ftime))
 				qlcnic_change_filter(adapter, &src_addr,
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index bf132c9..d131ec1 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -313,7 +313,7 @@ static void qlcnic_delete_adapter_mac(struct qlcnic_adapter *adapter)
 
 	list_for_each(head, &adapter->mac_list) {
 		cur = list_entry(head, struct qlcnic_mac_vlan_list, list);
-		if (!memcmp(adapter->mac_addr, cur->mac_addr, ETH_ALEN)) {
+		if (ether_addr_equal_unaligned(adapter->mac_addr, cur->mac_addr)) {
 			qlcnic_sre_macaddr_change(adapter, cur->mac_addr,
 						  0, QLCNIC_MAC_DEL);
 			list_del(&cur->list);
@@ -337,7 +337,7 @@ static int qlcnic_set_mac(struct net_device *netdev, void *p)
 	if (!is_valid_ether_addr(addr->sa_data))
 		return -EINVAL;
 
-	if (!memcmp(adapter->mac_addr, addr->sa_data, ETH_ALEN))
+	if (ether_addr_equal_unaligned(adapter->mac_addr, addr->sa_data))
 		return 0;
 
 	if (test_bit(__QLCNIC_DEV_UP, &adapter->state)) {
diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index ca742e1..1016ed1 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -2207,7 +2207,7 @@ static int sh_eth_tsu_find_entry(struct net_device *ndev, const u8 *addr)
 
 	for (i = 0; i < SH_ETH_TSU_CAM_ENTRIES; i++, reg_offset += 8) {
 		sh_eth_tsu_read_entry(reg_offset, c_addr);
-		if (memcmp(addr, c_addr, ETH_ALEN) == 0)
+		if (ether_addr_equal_unaligned(addr, c_addr))
 			return i;
 	}
 
diff --git a/drivers/net/ethernet/seeq/sgiseeq.c b/drivers/net/ethernet/seeq/sgiseeq.c
index c765718..1e53a19 100644
--- a/drivers/net/ethernet/seeq/sgiseeq.c
+++ b/drivers/net/ethernet/seeq/sgiseeq.c
@@ -356,7 +356,7 @@ static inline void sgiseeq_rx(struct net_device *dev, struct sgiseeq_private *sp
 		if (pkt_status & SEEQ_RSTAT_FIG) {
 			/* Packet is OK. */
 			/* We don't want to receive our own packets */
-			if (memcmp(rd->skb->data + 6, dev->dev_addr, ETH_ALEN)) {
+			if (!ether_addr_equal_unaligned(rd->skb->data + 6, dev->dev_addr)) {
 				if (len > rx_copybreak) {
 					skb = rd->skb;
 					newskb = netdev_alloc_skb(dev, PKT_BUF_SZ);
diff --git a/drivers/net/ethernet/sun/sunvnet.c b/drivers/net/ethernet/sun/sunvnet.c
index 3df5684..520ac62 100644
--- a/drivers/net/ethernet/sun/sunvnet.c
+++ b/drivers/net/ethernet/sun/sunvnet.c
@@ -751,7 +751,7 @@ static struct vnet_mcast_entry *__vnet_mc_find(struct vnet *vp, u8 *addr)
 	struct vnet_mcast_entry *m;
 
 	for (m = vp->mcast_list; m; m = m->next) {
-		if (!memcmp(m->addr, addr, ETH_ALEN))
+		if (ether_addr_equal_unaligned(m->addr, addr))
 			return m;
 	}
 	return NULL;
diff --git a/drivers/net/ethernet/ti/cpsw_ale.c b/drivers/net/ethernet/ti/cpsw_ale.c
index 7fa60d6..db78542 100644
--- a/drivers/net/ethernet/ti/cpsw_ale.c
+++ b/drivers/net/ethernet/ti/cpsw_ale.c
@@ -163,7 +163,7 @@ int cpsw_ale_match_addr(struct cpsw_ale *ale, u8 *addr, u16 vid)
 		if (cpsw_ale_get_vlan_id(ale_entry) != vid)
 			continue;
 		cpsw_ale_get_addr(ale_entry, entry_addr);
-		if (memcmp(entry_addr, addr, 6) == 0)
+		if (ether_addr_equal_unaligned(entry_addr, addr))
 			return idx;
 	}
 	return -ENOENT;
diff --git a/drivers/net/fddi/skfp/fplustm.c b/drivers/net/fddi/skfp/fplustm.c
index d918d8a..0857d6a 100644
--- a/drivers/net/fddi/skfp/fplustm.c
+++ b/drivers/net/fddi/skfp/fplustm.c
@@ -23,6 +23,7 @@
 #include "h/smc.h"
 #include "h/supern_2.h"
 #include <linux/bitrev.h>
+#include <linux/etherdevice.h>
 
 #ifndef	lint
 static const char ID_sccs[] = "@(#)fplustm.c	1.32 99/02/23 (C) SK " ;
@@ -1082,7 +1083,7 @@ static struct s_fpmc* mac_get_mc_table(struct s_smc *smc,
 				slot = tb ;
 			continue ;
 		}
-		if (memcmp((char *)&tb->a,(char *)own,6))
+		if (!ether_addr_equal_unaligned((char *)&tb->a, (char *)own))
 			continue ;
 		return tb;
 	}
diff --git a/drivers/net/plip/plip.c b/drivers/net/plip/plip.c
index 7b4ff35..3e8c045 100644
--- a/drivers/net/plip/plip.c
+++ b/drivers/net/plip/plip.c
@@ -549,7 +549,7 @@ static __be16 plip_type_trans(struct sk_buff *skb, struct net_device *dev)
 
 	if(*eth->h_dest&1)
 	{
-		if(memcmp(eth->h_dest,dev->broadcast, ETH_ALEN)==0)
+		if(ether_addr_equal_unaligned(eth->h_dest, dev->broadcast))
 			skb->pkt_type=PACKET_BROADCAST;
 		else
 			skb->pkt_type=PACKET_MULTICAST;
diff --git a/net/caif/cfrfml.c b/net/caif/cfrfml.c
index 61d7617..08eb29a 100644
--- a/net/caif/cfrfml.c
+++ b/net/caif/cfrfml.c
@@ -79,7 +79,7 @@ static struct cfpkt *rfm_append(struct cfrfml *rfml, char *seghead,
 		return NULL;
 
 	/* Verify correct header */
-	if (memcmp(seghead, rfml->seghead, 6) != 0)
+	if (!ether_addr_equal_unaligned(seghead, rfml->seghead))
 		return NULL;
 
 	tmppkt = cfpkt_append(rfml->incomplete_frm, pkt,
-- 
1.8.0




------------------------------------------------------------------------------
Rapidly troubleshoot problems before they affect your business. Most IT 
organizations don't have a clear picture of how application performance 
affects their revenue. With AppDynamics, you get 100% visibility into your 
Java,.NET, & PHP application. Start your 15-day FREE TRIAL of AppDynamics Pro!
http://pubads.g.doubleclick.net/gampad/clk?id=84349831&iu=/4140/ostg.clktrk
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
