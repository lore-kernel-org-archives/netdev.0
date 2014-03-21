From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 13/16] igb: Fix memory leak in igb_get_module_eeprom()
Date: Fri, 21 Mar 2014 05:10:03 -0700
Message-ID: <1395403806-29302-14-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1395403806-29302-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Christian Engelmayer <cengelma@gmx.at>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:20076 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965462AbaCUMKP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Mar 2014 08:10:15 -0400
In-Reply-To: <1395403806-29302-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christian Engelmayer <cengelma@gmx.at>

Fix a memory leak in the igb_get_module_eeprom() error handling path.
Detected by Coverity: CID 1016508.

Signed-off-by: Christian Engelmayer <cengelma@gmx.at>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_ethtool.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_ethtool.c b/drivers/net/ethernet/intel/igb/igb_ethtool.c
index e35bc1f..d5c3e65 100644
--- a/drivers/net/ethernet/intel/igb/igb_ethtool.c
+++ b/drivers/net/ethernet/intel/igb/igb_ethtool.c
@@ -2791,9 +2791,11 @@ static int igb_get_module_eeprom(struct net_device *netdev,
 	/* Read EEPROM block, SFF-8079/SFF-8472, word at a time */
 	for (i = 0; i < last_word - first_word + 1; i++) {
 		status = igb_read_phy_reg_i2c(hw, first_word + i, &dataword[i]);
-		if (status != E1000_SUCCESS)
+		if (status != E1000_SUCCESS) {
 			/* Error occurred while reading module */
+			kfree(dataword);
 			return -EIO;
+		}
 
 		be16_to_cpus(&dataword[i]);
 	}
-- 
1.8.3.1
