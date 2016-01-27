From: Corinna Vinschen <vinschen@redhat.com>
Subject: [PATCH] igb: Fix VLAN tag stripping on Intel i350
Date: Wed, 27 Jan 2016 14:28:04 +0100
Message-ID: <1453901284-32628-1-git-send-email-vinschen@redhat.com>
Cc: netdev@vger.kernel.org, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-n.franken.de ([193.175.24.27]:41026 "EHLO
	mail-n.franken.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932433AbcA0N6X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jan 2016 08:58:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
  PING 192.168.42.2 (192.168.42.2) from 192.168.42.1 eth0.42: 56(84) bytes of data.

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
---
 drivers/net/ethernet/intel/igb/igb_main.c | 39 ++++++++++++++++++++++++-------
 1 file changed, 31 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 31e5f39..afd3990 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -3580,6 +3580,28 @@ static void igb_rlpml_set(struct igb_adapter *adapter)
 	wr32(E1000_RLPML, max_frame_size);
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
@@ -3593,14 +3615,6 @@ static inline void igb_set_vmolr(struct igb_adapter *adapter,
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
@@ -5937,6 +5951,7 @@ static int igb_ndo_set_vf_vlan(struct net_device *netdev,
 			goto out;
 		igb_set_vmvir(adapter, vlan | (qos << VLAN_PRIO_SHIFT), vf);
 		igb_set_vmolr(adapter, vf, !vlan);
+		igb_set_vf_vlan_strip(adapter, vf, true);
 		adapter->vf_data[vf].pf_vlan = vlan;
 		adapter->vf_data[vf].pf_qos = qos;
 		dev_info(&adapter->pdev->dev,
@@ -5952,6 +5967,7 @@ static int igb_ndo_set_vf_vlan(struct net_device *netdev,
 			     false, vf);
 		igb_set_vmvir(adapter, vlan, vf);
 		igb_set_vmolr(adapter, vf, true);
+		igb_set_vf_vlan_strip(adapter, vf, false);
 		adapter->vf_data[vf].pf_vlan = 0;
 		adapter->vf_data[vf].pf_qos = 0;
 	}
@@ -5986,6 +6002,11 @@ static int igb_set_vf_vlan(struct igb_adapter *adapter, u32 *msgbuf, u32 vf)
 	int vid = (msgbuf[1] & E1000_VLVF_VLANID_MASK);
 	int err = 0;
 
+	if (vid)
+		igb_set_vf_vlan_strip(adapter, vf, true);
+	else
+		igb_set_vf_vlan_strip(adapter, vf, false);
+
 	/* If in promiscuous mode we need to make sure the PF also has
 	 * the VLAN filter set.
 	 */
@@ -7202,6 +7223,8 @@ static void igb_vlan_mode(struct net_device *netdev, netdev_features_t features)
 		wr32(E1000_CTRL, ctrl);
 	}
 
+	igb_set_vf_vlan_strip(adapter, adapter->vfs_allocated_count, enable);
+
 	igb_rlpml_set(adapter);
 }
 
-- 
2.5.0
