From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 4/8] igb: Garbled output for "ethtool -m"
Date: Wed,  6 Apr 2016 21:37:29 -0700
Message-ID: <1460003853-133949-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1460003853-133949-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Doron Shikmoni <doron.shikmoni@gmail.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:5553 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751997AbcDGEhh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Apr 2016 00:37:37 -0400
In-Reply-To: <1460003853-133949-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Doron Shikmoni <doron.shikmoni@gmail.com>

Garbled output for "ethtool -m ethX", in igb-driven NICs with module /
plugin EEPROM (i.e. SFP information). Each output data byte appears
duplicated.

In igb_ethtool.c, igb_get_module_eeprom() is reading the EEPROM via i2c;
the eeprom offset for each word that's read via igb_read_phy_reg_i2c()
was passed in #words, whereas it needs to be a byte offset.
This patches fixes the bug.

Signed-off-by: Doron Shikmoni <doron.shikmoni@gmail.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_ethtool.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_ethtool.c b/drivers/net/ethernet/intel/igb/igb_ethtool.c
index 7982243..bb4d6cd 100644
--- a/drivers/net/ethernet/intel/igb/igb_ethtool.c
+++ b/drivers/net/ethernet/intel/igb/igb_ethtool.c
@@ -2831,7 +2831,8 @@ static int igb_get_module_eeprom(struct net_device *netdev,
 
 	/* Read EEPROM block, SFF-8079/SFF-8472, word at a time */
 	for (i = 0; i < last_word - first_word + 1; i++) {
-		status = igb_read_phy_reg_i2c(hw, first_word + i, &dataword[i]);
+		status = igb_read_phy_reg_i2c(hw, (first_word + i) * 2,
+					      &dataword[i]);
 		if (status) {
 			/* Error occurred while reading module */
 			kfree(dataword);
-- 
2.5.5
