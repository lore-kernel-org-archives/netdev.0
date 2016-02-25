From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 14/15] igb: Fix VLAN tag stripping on Intel i350
Date: Wed, 24 Feb 2016 18:15:01 -0800
Message-ID: <1456366502-132841-15-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1456366502-132841-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Corinna Vinschen <vinschen@redhat.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:65100 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759297AbcBYC0F (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Feb 2016 21:26:05 -0500
In-Reply-To: <1456366502-132841-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Corinna Vinschen <vinschen@redhat.com>

Problem: When switching off VLAN offloading on an i350, the VLAN
interface gets unusable.  For testing, set up a VLAN on an i350
and some remote machine, e.g.:

  $ ip link add link eth0 name eth0.42 type vlan id 42
  $ ip addr add 192.168.42.1/24 dev eth0.42
  $ ip link set dev eth0.42 up

Offloading is switched on by default:

  $ ethtool -k eth0 | grep vlan-offload
  rx-vlan-offload: on
  tx-vlan-offload: on

  $ ping -c 3 -I eth0.42 192.168.42.2
  [...works as usual...]

Now switch off VLAN offloading and try again:

  $ ethtool -K eth0 rxvlan off
  Actual changes:
  rx-vlan-offload: off
  tx-vlan-offload: off [requested on]
  $ ping -c 3 -I eth0.42 192.168.42.2
  PING 192.168.42.2 (192.168.42.2) from 192.168.42.1 eth0.42: 56(84) bytes of da
ta.

  --- 192.168.42.2 ping statistics ---
  3 packets transmitted, 0 received, 100% packet loss, time 1999ms

I can only reproduce it on an i350, the above works fine on a 82580.

While inspecting the igb source, I came across the code in igb_set_vmolr
which sets the E1000_VMOLR_STRVLAN/E1000_DVMOLR_STRVLAN flags once and
for all, and in all of the igb code there's no other place where the
STRVLAN is set or cleared.  Thus, VLAN stripping is enabled in igb
unconditionally, independently of the offloading setting.

I compared that to the latest Intel igb-5.3.3.5 driver from
http://sourceforge.net/projects/e1000/ which in fact sets and clears the
STRVLAN flag independently from igb_set_vmolr in its own function
igb_set_vf_vlan_strip, depending on the vlan settings.

So I included the STRVLAN handling from the igb-5.3.3.5 driver into our
current igb driver and tested the above scenario again.  This time ping
still works after switching off VLAN offloading.

Tested on i350, with and without addtional VFs, as well as on 82580
successfully.

Signed-off-by: Corinna Vinschen <vinschen@redhat.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c | 41 ++++++++++++++++++++++++-------
 1 file changed, 32 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index d90dcd1..3b56f80 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -3589,6 +3589,28 @@ static inline int igb_set_vf_rlpml(struct igb_adapter *adapter, int size,
 	return 0;
 }
 
+static inline void igb_set_vf_vlan_strip(struct igb_adapter *adapter,
+					 int vfn, bool enable)
+{
+	struct e1000_hw *hw = &adapter->hw;
+	u32 val, reg;
+
+	if (hw->mac.type < e1000_82576)
+		return;
+
+	if (hw->mac.type == e1000_i350)
+		reg = E1000_DVMOLR(vfn);
+	else
+		reg = E1000_VMOLR(vfn);
+
+	val = rd32(reg);
+	if (enable)
+		val |= E1000_VMOLR_STRVLAN;
+	else
+		val &= ~(E1000_VMOLR_STRVLAN);
+	wr32(reg, val);
+}
+
 static inline void igb_set_vmolr(struct igb_adapter *adapter,
 				 int vfn, bool aupe)
 {
@@ -3602,14 +3624,6 @@ static inline void igb_set_vmolr(struct igb_adapter *adapter,
 		return;
 
 	vmolr = rd32(E1000_VMOLR(vfn));
-	vmolr |= E1000_VMOLR_STRVLAN; /* Strip vlan tags */
-	if (hw->mac.type == e1000_i350) {
-		u32 dvmolr;
-
-		dvmolr = rd32(E1000_DVMOLR(vfn));
-		dvmolr |= E1000_DVMOLR_STRVLAN;
-		wr32(E1000_DVMOLR(vfn), dvmolr);
-	}
 	if (aupe)
 		vmolr |= E1000_VMOLR_AUPE; /* Accept untagged packets */
 	else
@@ -6099,6 +6113,7 @@ static int igb_enable_port_vlan(struct igb_adapter *adapter, int vf,
 
 	adapter->vf_data[vf].pf_vlan = vlan;
 	adapter->vf_data[vf].pf_qos = qos;
+	igb_set_vf_vlan_strip(adapter, vf, true);
 	dev_info(&adapter->pdev->dev,
 		 "Setting VLAN %d, QOS 0x%x on VF %d\n", vlan, qos, vf);
 	if (test_bit(__IGB_DOWN, &adapter->state)) {
@@ -6126,6 +6141,7 @@ static int igb_disable_port_vlan(struct igb_adapter *adapter, int vf)
 
 	adapter->vf_data[vf].pf_vlan = 0;
 	adapter->vf_data[vf].pf_qos = 0;
+	igb_set_vf_vlan_strip(adapter, vf, false);
 
 	return 0;
 }
@@ -6146,6 +6162,7 @@ static int igb_set_vf_vlan_msg(struct igb_adapter *adapter, u32 *msgbuf, u32 vf)
 {
 	int add = (msgbuf[0] & E1000_VT_MSGINFO_MASK) >> E1000_VT_MSGINFO_SHIFT;
 	int vid = (msgbuf[1] & E1000_VLVF_VLANID_MASK);
+	int ret;
 
 	if (adapter->vf_data[vf].pf_vlan)
 		return -1;
@@ -6154,7 +6171,10 @@ static int igb_set_vf_vlan_msg(struct igb_adapter *adapter, u32 *msgbuf, u32 vf)
 	if (!vid && !add)
 		return 0;
 
-	return igb_set_vf_vlan(adapter, vid, !!add, vf);
+	ret = igb_set_vf_vlan(adapter, vid, !!add, vf);
+	if (!ret)
+		igb_set_vf_vlan_strip(adapter, vf, !!vid);
+	return ret;
 }
 
 static inline void igb_vf_reset(struct igb_adapter *adapter, u32 vf)
@@ -6171,6 +6191,7 @@ static inline void igb_vf_reset(struct igb_adapter *adapter, u32 vf)
 	igb_set_vmvir(adapter, vf_data->pf_vlan |
 			       (vf_data->pf_qos << VLAN_PRIO_SHIFT), vf);
 	igb_set_vmolr(adapter, vf, !vf_data->pf_vlan);
+	igb_set_vf_vlan_strip(adapter, vf, !!(vf_data->pf_vlan));
 
 	/* reset multicast table array for vf */
 	adapter->vf_data[vf].num_vf_mc_hashes = 0;
@@ -7323,6 +7344,8 @@ static void igb_vlan_mode(struct net_device *netdev, netdev_features_t features)
 		ctrl &= ~E1000_CTRL_VME;
 		wr32(E1000_CTRL, ctrl);
 	}
+
+	igb_set_vf_vlan_strip(adapter, adapter->vfs_allocated_count, enable);
 }
 
 static int igb_vlan_rx_add_vid(struct net_device *netdev,
-- 
2.5.0
