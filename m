From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [next-queu 14/19] i40e: add interrupt rate limit verbosity
Date: Thu,  2 Feb 2017 23:25:48 -0800
Message-ID: <20170203072553.168372-15-jeffrey.t.kirsher@intel.com>
References: <20170203072553.168372-1-jeffrey.t.kirsher@intel.com>
Cc: Alan Brady <alan.brady@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:50618 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752724AbdBCHZ6 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 3 Feb 2017 02:25:58 -0500
In-Reply-To: <20170203072553.168372-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alan Brady <alan.brady@intel.com>

Due to the resolution of the register controlling interrupt rate
limiting, setting certain values for the interrupt rate limit make it
appear as though the limiting is not completely accurate.  The problem
is that the interrupt rate limit is getting rounded down to the nearest
multiple of 4.  This patch fixes the problem by adding some feedback to
the user as to the actual interrupt rate limit being used when it
differs from the requested limit.  Without this patch setting interrupt
rate limits may appear to behave inaccurately.

Change-ID: I3093cf3f2d437d35a4c4f4bb5af5ce1b85ab21b7
Signed-off-by: Alan Brady <alan.brady@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 13 ++++++++++---
 1 file changed, 10 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index 7500902..c4ab3c1 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -2116,6 +2116,7 @@ static int __i40e_set_coalesce(struct net_device *netdev,
 	struct i40e_netdev_priv *np = netdev_priv(netdev);
 	struct i40e_vsi *vsi = np->vsi;
 	struct i40e_pf *pf = vsi->back;
+	u16 intrl_reg;
 	int i;
 
 	if (ec->tx_max_coalesced_frames_irq || ec->rx_max_coalesced_frames_irq)
@@ -2127,8 +2128,9 @@ static int __i40e_set_coalesce(struct net_device *netdev,
 		return -EINVAL;
 	}
 
-	if (ec->rx_coalesce_usecs_high >= INTRL_REG_TO_USEC(I40E_MAX_INTRL)) {
-		netif_info(pf, drv, netdev, "Invalid value, rx-usecs-high range is 0-235\n");
+	if (ec->rx_coalesce_usecs_high > INTRL_REG_TO_USEC(I40E_MAX_INTRL)) {
+		netif_info(pf, drv, netdev, "Invalid value, rx-usecs-high range is 0-%lu\n",
+			   INTRL_REG_TO_USEC(I40E_MAX_INTRL));
 		return -EINVAL;
 	}
 
@@ -2141,7 +2143,12 @@ static int __i40e_set_coalesce(struct net_device *netdev,
 			return -EINVAL;
 	}
 
-	vsi->int_rate_limit = ec->rx_coalesce_usecs_high;
+	intrl_reg = i40e_intrl_usec_to_reg(ec->rx_coalesce_usecs_high);
+	vsi->int_rate_limit = INTRL_REG_TO_USEC(intrl_reg);
+	if (vsi->int_rate_limit != ec->rx_coalesce_usecs_high) {
+		netif_info(pf, drv, netdev, "Interrupt rate limit rounded down to %d\n",
+			   vsi->int_rate_limit);
+	}
 
 	if (ec->tx_coalesce_usecs == 0) {
 		if (ec->use_adaptive_tx_coalesce)
-- 
2.10.2
