From: Juerg Haefliger <juerg.haefliger@hpe.com>
Subject: [PATCH] net/ixgbe: Allow resetting VF admin mac to zero
Date: Fri,  1 Jul 2016 11:19:38 +0200
Message-ID: <1467364778-27198-1-git-send-email-juerg.haefliger@hpe.com>
Cc: linux-kernel@vger.kernel.org,
	Juerg Haefliger <juerg.haefliger@hpe.com>
To: netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The VF administrative mac addresses (stored in the PF driver) are
initialized to zero when the PF driver starts up.

These addresses may be modified in the PF driver through ndo calls
initiated by iproute2 or libvirt.

While we allow the PF/host to change the VF admin mac address from zero
to a valid unicast mac, we do not allow restoring the VF admin mac to
zero. We currently only allow changing this mac to a different unicast mac.

This leads to problems when libvirt scripts are used to deal with
VF mac addresses, and libvirt attempts to revoke the mac so this
host will not use it anymore.

Fix this by allowing resetting a VF administrative MAC back to zero.

Implementation and commit message shamelessly stolen from:
commit 6e5224224faa ("net/mlx4_core: Allow resetting VF admin mac to zero")

Signed-off-by: Juerg Haefliger <juerg.haefliger@hpe.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
index c5caacd..d075387 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
@@ -1280,7 +1280,7 @@ void ixgbe_ping_all_vfs(struct ixgbe_adapter *adapter)
 int ixgbe_ndo_set_vf_mac(struct net_device *netdev, int vf, u8 *mac)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
-	if (!is_valid_ether_addr(mac) || (vf >= adapter->num_vfs))
+	if (is_multicast_ether_addr(mac) || (vf >= adapter->num_vfs))
 		return -EINVAL;
 	adapter->vfinfo[vf].pf_set_mac = true;
 	dev_info(&adapter->pdev->dev, "setting MAC %pM on VF %d\n", mac, vf);
-- 
2.8.1
