From: <zyjzyj2000@gmail.com>
Subject: [PATCH 1/1] ixgbe: get link speed as a slave nic unrelated with link up
Date: Mon, 1 Feb 2016 15:27:55 +0800
Message-ID: <1454311675-24676-2-git-send-email-zyjzyj2000@gmail.com>
References: <1452258030-63996-5-git-send-email-jeffrey.t.kirsher@intel.com>
 <1454311675-24676-1-git-send-email-zyjzyj2000@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <zyjzyj2000@gmail.com>, <emil.s.tantilov@intel.com>,
	<phillip.j.schmitt@intel.com>, <jeffrey.t.kirsher@intel.com>,
	<netdev@vger.kernel.org>, <e1000-devel@lists.sourceforge.net>,
	<Boris.Shteinbock@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:52175 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750733AbcBAH0G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Feb 2016 02:26:06 -0500
In-Reply-To: <1454311675-24676-1-git-send-email-zyjzyj2000@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhu Yanjun <zyjzyj2000@gmail.com>

The commit 0e4d422f5f72 ("ixgbe: do not call check_link for ethtool
in ixgbe_get_settings()") decreases the bonding failures. But the
following time slice still results in a bonding failure.

bonding                ixgbe
  |                     |
  |                    carrier_on
  |                     |
  |    <----------------|
 link_up                |
  |                     |
  |                    carrier_off
  |                     |
 get_link_speed ------->|
  |                     |

As such, the nic link speed can unconditionally be gotten as a
slave nic whether the link is up or not.

Signed-off-by: Zhu Yanjun <zyjzyj2000@gmail.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index bea96b3..53edf39 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -311,7 +311,7 @@ static int ixgbe_get_settings(struct net_device *netdev,
 		break;
 	}
 
-	if (netif_carrier_ok(netdev)) {
+	if (netif_carrier_ok(netdev) || (netdev->flags & IFF_SLAVE)) {
 		switch (adapter->link_speed) {
 		case IXGBE_LINK_SPEED_10GB_FULL:
 			ethtool_cmd_speed_set(ecmd, SPEED_10000);
-- 
1.7.9.5
