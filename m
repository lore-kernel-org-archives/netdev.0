From: Thierry Herbelot <thierry.herbelot@6wind.com>
Subject: [PATCH net] ixgbe: check adapter->vfinfo before dereference
Date: Wed,  8 Oct 2014 14:05:12 +0200
Message-ID: <1412769913-22306-1-git-send-email-thierry.herbelot@6wind.com>
Cc: Thierry Herbelot <thierry.herbelot@6wind.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:54753 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755750AbaJHMFh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2014 08:05:37 -0400
Received: by mail-wi0-f180.google.com with SMTP id em10so10463043wid.13
        for <netdev@vger.kernel.org>; Wed, 08 Oct 2014 05:05:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

this protects against the following panic:
(before a VF was actually created on p96p1 PF Ethernet port)
ip link set p96p1 vf 0 spoofchk off
BUG: unable to handle kernel NULL pointer dereference at 0000000000000052
IP: [<ffffffffa044a1c1>] ixgbe_ndo_set_vf_spoofchk+0x51/0x150 [ixgbe]

Signed-off-by: Thierry Herbelot <thierry.herbelot@6wind.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c |   73 +++++++++++++++++++++++-
 1 file changed, 70 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
index c14d4d8..c6c9c0a 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
@@ -314,7 +314,7 @@ static int ixgbe_set_vf_multicasts(struct ixgbe_adapter *adapter,
 	int entries = (msgbuf[0] & IXGBE_VT_MSGINFO_MASK)
 		       >> IXGBE_VT_MSGINFO_SHIFT;
 	u16 *hash_list = (u16 *)&msgbuf[1];
-	struct vf_data_storage *vfinfo = &adapter->vfinfo[vf];
+	struct vf_data_storage *vfinfo;
 	struct ixgbe_hw *hw = &adapter->hw;
 	int i;
 	u32 vector_bit;
@@ -322,6 +322,11 @@ static int ixgbe_set_vf_multicasts(struct ixgbe_adapter *adapter,
 	u32 mta_reg;
 	u32 vmolr = IXGBE_READ_REG(hw, IXGBE_VMOLR(vf));
 
+	if (!adapter->vfinfo)
+		return -1;
+
+	vfinfo = &adapter->vfinfo[vf];
+
 	/* only so many hash values supported */
 	entries = min(entries, IXGBE_MAX_VF_MC_ENTRIES);
 
@@ -363,6 +368,9 @@ void ixgbe_restore_vf_multicasts(struct ixgbe_adapter *adapter)
 	u32 vector_reg;
 	u32 mta_reg;
 
+	if (!adapter->vfinfo)
+		return;
+
 	for (i = 0; i < adapter->num_vfs; i++) {
 		u32 vmolr = IXGBE_READ_REG(hw, IXGBE_VMOLR(i));
 		vfinfo = &adapter->vfinfo[i];
@@ -416,6 +424,9 @@ static s32 ixgbe_set_vf_lpe(struct ixgbe_adapter *adapter, u32 *msgbuf, u32 vf)
 		u32 reg_offset, vf_shift, vfre;
 		s32 err = 0;
 
+		if (!adapter->vfinfo)
+			return -1;
+
 #ifdef CONFIG_FCOE
 		if (dev->features & NETIF_F_FCOE_MTU)
 			pf_max_frame = max_t(int, pf_max_frame,
@@ -505,6 +516,9 @@ static inline void ixgbe_vf_reset_event(struct ixgbe_adapter *adapter, u32 vf)
 	struct vf_data_storage *vfinfo = &adapter->vfinfo[vf];
 	u8 num_tcs = netdev_get_num_tc(adapter->netdev);
 
+	if (!adapter->vfinfo)
+		return;
+
 	/* add PF assigned VLAN or VLAN 0 */
 	ixgbe_set_vf_vlan(adapter, true, vfinfo->pf_vlan, vf);
 
@@ -541,6 +555,8 @@ static inline void ixgbe_vf_reset_event(struct ixgbe_adapter *adapter, u32 vf)
 static int ixgbe_set_vf_mac(struct ixgbe_adapter *adapter,
 			    int vf, unsigned char *mac_addr)
 {
+	if (!adapter->vfinfo)
+		return -1;
 	ixgbe_del_mac_filter(adapter, adapter->vfinfo[vf].vf_mac_addresses, vf);
 	memcpy(adapter->vfinfo[vf].vf_mac_addresses, mac_addr, ETH_ALEN);
 	ixgbe_add_mac_filter(adapter, adapter->vfinfo[vf].vf_mac_addresses, vf);
@@ -610,6 +626,9 @@ int ixgbe_vf_configuration(struct pci_dev *pdev, unsigned int event_mask)
 
 	bool enable = ((event_mask & 0x10000000U) != 0);
 
+	if (!adapter->vfinfo)
+		return -1;
+
 	if (enable)
 		eth_zero_addr(adapter->vfinfo[vfn].vf_mac_addresses);
 
@@ -620,13 +639,18 @@ static int ixgbe_vf_reset_msg(struct ixgbe_adapter *adapter, u32 vf)
 {
 	struct ixgbe_ring_feature *vmdq = &adapter->ring_feature[RING_F_VMDQ];
 	struct ixgbe_hw *hw = &adapter->hw;
-	unsigned char *vf_mac = adapter->vfinfo[vf].vf_mac_addresses;
+	unsigned char *vf_mac;
 	u32 reg, reg_offset, vf_shift;
 	u32 msgbuf[4] = {0, 0, 0, 0};
 	u8 *addr = (u8 *)(&msgbuf[1]);
 	u32 q_per_pool = __ALIGN_MASK(1, ~vmdq->mask);
 	int i;
 
+	if (!adapter->vfinfo)
+		return -1;
+
+	vf_mac = adapter->vfinfo[vf].vf_mac_addresses;
+
 	e_info(probe, "VF Reset msg received from vf %d\n", vf);
 
 	/* reset the filters for the device */
@@ -721,6 +745,9 @@ static int ixgbe_set_vf_mac_addr(struct ixgbe_adapter *adapter,
 {
 	u8 *new_mac = ((u8 *)(&msgbuf[1]));
 
+	if (!adapter->vfinfo)
+		return -1;
+
 	if (!is_valid_ether_addr(new_mac)) {
 		e_warn(drv, "VF %d attempted to set invalid mac\n", vf);
 		return -1;
@@ -773,6 +800,9 @@ static int ixgbe_set_vf_vlan_msg(struct ixgbe_adapter *adapter,
 	u32 bits;
 	u8 tcs = netdev_get_num_tc(adapter->netdev);
 
+	if (!adapter->vfinfo)
+		return -1;
+
 	if (adapter->vfinfo[vf].pf_vlan || tcs) {
 		e_warn(drv,
 		       "VF %d attempted to override administratively set VLAN configuration\n"
@@ -839,6 +869,9 @@ static int ixgbe_set_vf_macvlan_msg(struct ixgbe_adapter *adapter,
 		    IXGBE_VT_MSGINFO_SHIFT;
 	int err;
 
+	if (!adapter->vfinfo)
+		return -1;
+
 	if (adapter->vfinfo[vf].pf_set_mac && index > 0) {
 		e_warn(drv,
 		       "VF %d requested MACVLAN filter but is administratively denied\n",
@@ -875,6 +908,9 @@ static int ixgbe_negotiate_vf_api(struct ixgbe_adapter *adapter,
 {
 	int api = msgbuf[1];
 
+	if (!adapter->vfinfo)
+		return -1;
+
 	switch (api) {
 	case ixgbe_mbox_api_10:
 	case ixgbe_mbox_api_11:
@@ -897,6 +933,9 @@ static int ixgbe_get_vf_queues(struct ixgbe_adapter *adapter,
 	unsigned int default_tc = 0;
 	u8 num_tcs = netdev_get_num_tc(dev);
 
+	if (!adapter->vfinfo)
+		return -1;
+
 	/* verify the PF is supporting the correct APIs */
 	switch (adapter->vfinfo[vf].vf_api) {
 	case ixgbe_mbox_api_20:
@@ -935,6 +974,9 @@ static int ixgbe_rcv_msg_from_vf(struct ixgbe_adapter *adapter, u32 vf)
 	struct ixgbe_hw *hw = &adapter->hw;
 	s32 retval;
 
+	if (!adapter->vfinfo)
+		return -1;
+
 	retval = ixgbe_read_mbx(hw, msgbuf, mbx_size, vf);
 
 	if (retval) {
@@ -1008,6 +1050,9 @@ static void ixgbe_rcv_ack_from_vf(struct ixgbe_adapter *adapter, u32 vf)
 	struct ixgbe_hw *hw = &adapter->hw;
 	u32 msg = IXGBE_VT_MSGTYPE_NACK;
 
+	if (!adapter->vfinfo)
+		return;
+
 	/* if device isn't clear to send it shouldn't be reading either */
 	if (!adapter->vfinfo[vf].clear_to_send)
 		ixgbe_write_mbx(hw, &msg, 1, vf);
@@ -1051,6 +1096,9 @@ void ixgbe_ping_all_vfs(struct ixgbe_adapter *adapter)
 	u32 ping;
 	int i;
 
+	if (!adapter->vfinfo)
+		return -1;
+
 	for (i = 0 ; i < adapter->num_vfs; i++) {
 		ping = IXGBE_PF_CONTROL_MSG;
 		if (adapter->vfinfo[i].clear_to_send)
@@ -1064,6 +1112,9 @@ int ixgbe_ndo_set_vf_mac(struct net_device *netdev, int vf, u8 *mac)
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 	if (!is_valid_ether_addr(mac) || (vf >= adapter->num_vfs))
 		return -EINVAL;
+	if (!adapter->vfinfo)
+		return -1;
+
 	adapter->vfinfo[vf].pf_set_mac = true;
 	dev_info(&adapter->pdev->dev, "setting MAC %pM on VF %d\n", mac, vf);
 	dev_info(&adapter->pdev->dev, "Reload the VF driver to make this"
@@ -1083,6 +1134,9 @@ int ixgbe_ndo_set_vf_vlan(struct net_device *netdev, int vf, u16 vlan, u8 qos)
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 	struct ixgbe_hw *hw = &adapter->hw;
 
+	if (!adapter->vfinfo)
+		return -1;
+
 	if ((vf >= adapter->num_vfs) || (vlan > 4095) || (qos > 7))
 		return -EINVAL;
 	if (vlan || qos) {
@@ -1147,8 +1201,12 @@ static void ixgbe_set_vf_rate_limit(struct ixgbe_adapter *adapter, int vf)
 	struct ixgbe_hw *hw = &adapter->hw;
 	u32 bcnrc_val = 0;
 	u16 queue, queues_per_pool;
-	u16 tx_rate = adapter->vfinfo[vf].tx_rate;
+	u16 tx_rate;
 
+	if (!adapter->vfinfo)
+		return;
+
+	tx_rate = adapter->vfinfo[vf].tx_rate;
 	if (tx_rate) {
 		/* start with base link speed value */
 		bcnrc_val = adapter->vf_rate_link_speed;
@@ -1197,6 +1255,9 @@ void ixgbe_check_vf_rate_limit(struct ixgbe_adapter *adapter)
 {
 	int i;
 
+	if (!adapter->vfinfo)
+		return;
+
 	/* VF Tx rate limit was not set */
 	if (!adapter->vf_rate_link_speed)
 		return;
@@ -1259,6 +1320,9 @@ int ixgbe_ndo_set_vf_spoofchk(struct net_device *netdev, int vf, bool setting)
 	struct ixgbe_hw *hw = &adapter->hw;
 	u32 regval;
 
+	if (!adapter->vfinfo)
+		return;
+
 	adapter->vfinfo[vf].spoofchk_enabled = setting;
 
 	regval = IXGBE_READ_REG(hw, IXGBE_PFVFSPOOF(vf_target_reg));
@@ -1283,6 +1347,9 @@ int ixgbe_ndo_get_vf_config(struct net_device *netdev,
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 	if (vf >= adapter->num_vfs)
 		return -EINVAL;
+	if (!adapter->vfinfo)
+		return -EINVAL;
+
 	ivi->vf = vf;
 	memcpy(&ivi->mac, adapter->vfinfo[vf].vf_mac_addresses, ETH_ALEN);
 	ivi->max_tx_rate = adapter->vfinfo[vf].tx_rate;
-- 
1.7.10.4
