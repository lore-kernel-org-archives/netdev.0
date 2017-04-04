From: Corinna Vinschen <vinschen@redhat.com>
Subject: [PATCH] igb: Allow to remove administratively set MAC on VFs
Date: Tue,  4 Apr 2017 17:10:55 +0200
Message-ID: <20170404151055.21447-1-vinschen@redhat.com>
Cc: netdev@vger.kernel.org, Corinna Vinschen <vinschen@redhat.com>
To: intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-n.franken.de ([193.175.24.27]:37751 "EHLO drew.franken.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751092AbdDDPRJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 4 Apr 2017 11:17:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  Before libvirt modifies the MAC address and vlan tag for an SRIOV VF
  for use by a virtual machine (either using vfio device assignment or
  macvtap passthru mode), it saves the current MAC address and vlan tag
  so that it can reset them to their original value when the guest is
  done.  Libvirt can't leave the VF MAC set to the value used by the
  now-defunct guest since it may be started again later using a
  different VF, but it certainly shouldn't just pick any random value,
  either. So it saves the state of everything prior to using the VF, and
  resets it to that.

  The igb driver initializes the MAC addresses of all VFs to
  00:00:00:00:00:00, and reports that when asked (via an RTM_GETLINK
  netlink message, also visible in the list of VFs in the output of "ip
  link show"). But when libvirt attempts to restore the MAC address back
  to 00:00:00:00:00:00 (using an RTM_SETLINK netlink message) the kernel
  responds with "Invalid argument".

  Forbidding a reset back to the original value leaves the VF MAC at the
  value set for the now-defunct virtual machine. Especially on a system
  with NetworkManager enabled, this has very bad consequences, since
  NetworkManager forces all interfacess to be IFF_UP all the time - if
  the same virtual machine is restarted using a different VF (or even on
  a different host), there will be multiple interfaces watching for
  traffic with the same MAC address.

  To allow libvirt to revert to the original state, we need a way to
  remove the administrative set MAC on a VF, to allow normal host
  operation again, and to reset/overwrite the VF MAC via VF netdev.

  This patch implements the outlined scenario by allowing to set the
  VF MAC to 00:00:00:00:00:00 via RTM_SETLINK on the PF.
  igb_ndo_set_vf_mac resets the IGB_VF_FLAG_PF_SET_MAC flag to 0,
  so it's possible to reset the VF MAC back to the original value via
  the VF netdev.

  Note: Recent patches to libvirt allow for a workaround if the NIC
  isn't capable of resetting the administrative MAC back to all 0, but
  in theory the NIC should allow resetting the MAC in the fisr place.

Signed-off-by: Corinna Vinschen <vinschen@redhat.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c | 25 ++++++++++++++++++++-----
 1 file changed, 20 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 26a821f..e7a61b1 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -8125,12 +8125,27 @@ static int igb_set_vf_mac(struct igb_adapter *adapter,
 static int igb_ndo_set_vf_mac(struct net_device *netdev, int vf, u8 *mac)
 {
 	struct igb_adapter *adapter = netdev_priv(netdev);
-	if (!is_valid_ether_addr(mac) || (vf >= adapter->vfs_allocated_count))
+
+	if (vf >= adapter->vfs_allocated_count)
+		return -EINVAL;
+	/* Setting the VF MAC to 0 reverts the IGB_VF_FLAG_PF_SET_MAC
+	   flag and allows to overwrite the MAC via VF netdev.  This
+	   is necessary to allow libvirt a way to restore the original
+	   MAC after unbinding vfio-pci and reloading igbvf after shutting
+	   down a VM. */
+	if (is_zero_ether_addr(mac)) {
+		adapter->vf_data[vf].flags &= ~IGB_VF_FLAG_PF_SET_MAC;
+		dev_info(&adapter->pdev->dev,
+			 "remove administratively set MAC on VF %d\n",
+			 vf);
+	} else if (is_valid_ether_addr (mac)) {
+		adapter->vf_data[vf].flags |= IGB_VF_FLAG_PF_SET_MAC;
+		dev_info(&adapter->pdev->dev, "setting MAC %pM on VF %d\n",
+			 mac, vf);
+		dev_info(&adapter->pdev->dev,
+			 "Reload the VF driver to make this change effective.");
+	} else
 		return -EINVAL;
-	adapter->vf_data[vf].flags |= IGB_VF_FLAG_PF_SET_MAC;
-	dev_info(&adapter->pdev->dev, "setting MAC %pM on VF %d\n", mac, vf);
-	dev_info(&adapter->pdev->dev,
-		 "Reload the VF driver to make this change effective.");
 	if (test_bit(__IGB_DOWN, &adapter->state)) {
 		dev_warn(&adapter->pdev->dev,
 			 "The VF MAC address has been set, but the PF device is not up.\n");
-- 
2.9.3
