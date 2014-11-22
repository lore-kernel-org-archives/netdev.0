From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 1/3] ixgbe: Correctly disable VLAN filter in promiscuous mode
Date: Fri, 21 Nov 2014 23:52:52 -0800
Message-ID: <1416642774-17077-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Vlad Yasevich <vyasevich@gmail.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	stable <stable@vger.kernel.org>,
	Jacob Keller <jacob.e.keller@intel.com>,
	Vladislav Yasevich <vyasevic@redhat.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <stable-owner@vger.kernel.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vlad Yasevich <vyasevich@gmail.com>

IXGBE adapter seems to require that VLAN filtering be enabled if
VMDQ or SRIOV are enabled.  When those functions are disabled,
VLAN filtering may be disabled in promiscuous mode.

Prior to commit a9b8943ee129 ("ixgbe: remove vlan_filter_disable
and enable functions")

The logic was correct.  However, after the commit the logic
got reversed and VLAN filtered in now turned on when VMDQ/SRIOV
is disabled.

This patch changes the condition to enable hw vlan filtered
when VMDQ or SRIOV is enabled.

Fixes: a9b8943ee129 ("ixgbe: remove vlan_filter_disable and enable functions")
Cc: stable <stable@vger.kernel.org>
CC: Jacob Keller <jacob.e.keller@intel.com>
Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
Acked-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index d2df4e3..7acde46 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -3936,8 +3936,8 @@ void ixgbe_set_rx_mode(struct net_device *netdev)
 		 * if SR-IOV and VMDQ are disabled - otherwise ensure
 		 * that hardware VLAN filters remain enabled.
 		 */
-		if (!(adapter->flags & (IXGBE_FLAG_VMDQ_ENABLED |
-					IXGBE_FLAG_SRIOV_ENABLED)))
+		if (adapter->flags & (IXGBE_FLAG_VMDQ_ENABLED |
+				      IXGBE_FLAG_SRIOV_ENABLED))
 			vlnctrl |= (IXGBE_VLNCTRL_VFE | IXGBE_VLNCTRL_CFIEN);
 	} else {
 		if (netdev->flags & IFF_ALLMULTI) {
-- 
1.9.3
