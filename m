From: Thierry Herbelot <thierry.herbelot@6wind.com>
Subject: [PATCH v3 net] ixgbe: check adapter->vfinfo before dereference
Date: Wed, 15 Oct 2014 11:58:00 +0200
Message-ID: <1413367080-31540-1-git-send-email-thierry.herbelot@6wind.com>
References: <1412930732-892-1-git-send-email-thierry.herbelot@6wind.com>
Cc: Thierry Herbelot <thierry.herbelot@6wind.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	<emil.s.tantilov@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f171.google.com ([209.85.212.171]:33677 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751793AbaJOJ6h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Oct 2014 05:58:37 -0400
Received: by mail-wi0-f171.google.com with SMTP id em10so12426093wid.16
        for <netdev@vger.kernel.org>; Wed, 15 Oct 2014 02:58:35 -0700 (PDT)
In-Reply-To: <1412930732-892-1-git-send-email-thierry.herbelot@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

this protects against the following panic:
(before a VF was actually created on p96p1 PF Ethernet port)

ip link set p96p1 vf 0 spoofchk off
BUG: unable to handle kernel NULL pointer dereference at 0000000000000052
IP: [<ffffffffa044a1c1>] ixgbe_ndo_set_vf_spoofchk+0x51/0x150 [ixgbe]

Signed-off-by: Thierry Herbelot <thierry.herbelot@6wind.com>
---

v2:
  compilation fixes

v3:
  remove checks in functions where vfinfo is known not to be NULL
  return -EINVAL as error code

 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c |   42 ++++++++++++++++++++++--
 1 file changed, 40 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
index 706fc69..fab0157 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
@@ -365,6 +365,9 @@ void ixgbe_restore_vf_multicasts(struct ixgbe_adapter *adapter)
 	u32 vector_reg;
 	u32 mta_reg;
 
+	if (!adapter->vfinfo)
+		return;
+
 	for (i = 0; i < adapter->num_vfs; i++) {
 		u32 vmolr = IXGBE_READ_REG(hw, IXGBE_VMOLR(i));
 		vfinfo = &adapter->vfinfo[i];
@@ -504,9 +507,13 @@ static void ixgbe_clear_vmvir(struct ixgbe_adapter *adapter, u32 vf)
 static inline void ixgbe_vf_reset_event(struct ixgbe_adapter *adapter, u32 vf)
 {
 	struct ixgbe_hw *hw = &adapter->hw;
-	struct vf_data_storage *vfinfo = &adapter->vfinfo[vf];
+	struct vf_data_storage *vfinfo;
 	u8 num_tcs = netdev_get_num_tc(adapter->netdev);
 
+	if (!adapter->vfinfo)
+		return;
+	vfinfo = &adapter->vfinfo[vf];
+
 	/* add PF assigned VLAN or VLAN 0 */
 	ixgbe_set_vf_vlan(adapter, true, vfinfo->pf_vlan, vf);
 
@@ -612,6 +619,9 @@ int ixgbe_vf_configuration(struct pci_dev *pdev, unsigned int event_mask)
 
 	bool enable = ((event_mask & 0x10000000U) != 0);
 
+	if (!adapter->vfinfo)
+		return -EINVAL;
+
 	if (enable)
 		eth_zero_addr(adapter->vfinfo[vfn].vf_mac_addresses);
 
@@ -937,6 +947,9 @@ static int ixgbe_rcv_msg_from_vf(struct ixgbe_adapter *adapter, u32 vf)
 	struct ixgbe_hw *hw = &adapter->hw;
 	s32 retval;
 
+	if (!adapter->vfinfo)
+		return -EINVAL;
+
 	retval = ixgbe_read_mbx(hw, msgbuf, mbx_size, vf);
 
 	if (retval) {
@@ -1010,6 +1023,9 @@ static void ixgbe_rcv_ack_from_vf(struct ixgbe_adapter *adapter, u32 vf)
 	struct ixgbe_hw *hw = &adapter->hw;
 	u32 msg = IXGBE_VT_MSGTYPE_NACK;
 
+	if (!adapter->vfinfo)
+		return;
+
 	/* if device isn't clear to send it shouldn't be reading either */
 	if (!adapter->vfinfo[vf].clear_to_send)
 		ixgbe_write_mbx(hw, &msg, 1, vf);
@@ -1053,6 +1069,9 @@ void ixgbe_ping_all_vfs(struct ixgbe_adapter *adapter)
 	u32 ping;
 	int i;
 
+	if (!adapter->vfinfo)
+		return;
+
 	for (i = 0 ; i < adapter->num_vfs; i++) {
 		ping = IXGBE_PF_CONTROL_MSG;
 		if (adapter->vfinfo[i].clear_to_send)
@@ -1066,6 +1085,9 @@ int ixgbe_ndo_set_vf_mac(struct net_device *netdev, int vf, u8 *mac)
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 	if (!is_valid_ether_addr(mac) || (vf >= adapter->num_vfs))
 		return -EINVAL;
+	if (!adapter->vfinfo)
+		return -EINVAL;
+
 	adapter->vfinfo[vf].pf_set_mac = true;
 	dev_info(&adapter->pdev->dev, "setting MAC %pM on VF %d\n", mac, vf);
 	dev_info(&adapter->pdev->dev, "Reload the VF driver to make this"
@@ -1085,6 +1107,9 @@ int ixgbe_ndo_set_vf_vlan(struct net_device *netdev, int vf, u16 vlan, u8 qos)
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 	struct ixgbe_hw *hw = &adapter->hw;
 
+	if (!adapter->vfinfo)
+		return -EINVAL;
+
 	if ((vf >= adapter->num_vfs) || (vlan > 4095) || (qos > 7))
 		return -EINVAL;
 	if (vlan || qos) {
@@ -1149,7 +1174,11 @@ static void ixgbe_set_vf_rate_limit(struct ixgbe_adapter *adapter, int vf)
 	struct ixgbe_hw *hw = &adapter->hw;
 	u32 bcnrc_val = 0;
 	u16 queue, queues_per_pool;
-	u16 tx_rate = adapter->vfinfo[vf].tx_rate;
+	u16 tx_rate;
+
+	if (!adapter->vfinfo)
+		return;
+	tx_rate = adapter->vfinfo[vf].tx_rate;
 
 	if (tx_rate) {
 		/* start with base link speed value */
@@ -1199,6 +1228,9 @@ void ixgbe_check_vf_rate_limit(struct ixgbe_adapter *adapter)
 {
 	int i;
 
+	if (!adapter->vfinfo)
+		return;
+
 	/* VF Tx rate limit was not set */
 	if (!adapter->vf_rate_link_speed)
 		return;
@@ -1261,6 +1293,9 @@ int ixgbe_ndo_set_vf_spoofchk(struct net_device *netdev, int vf, bool setting)
 	struct ixgbe_hw *hw = &adapter->hw;
 	u32 regval;
 
+	if (!adapter->vfinfo)
+		return -EINVAL;
+
 	adapter->vfinfo[vf].spoofchk_enabled = setting;
 
 	regval = IXGBE_READ_REG(hw, IXGBE_PFVFSPOOF(vf_target_reg));
@@ -1285,6 +1320,9 @@ int ixgbe_ndo_get_vf_config(struct net_device *netdev,
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
