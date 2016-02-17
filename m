From: Doron Shikmoni <doron.shikmoni@gmail.com>
Subject: [PATCH] igb: Garbled output for "ethtool -m"
Date: Wed, 17 Feb 2016 09:34:25 +0200
Message-ID: <1455694465-1226-1-git-send-email-doron.shikmoni@gmail.com>
Cc: netdev@vger.kernel.org, Doron Shikmoni <doron.shikmoni@gmail.com>
To: intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:32931 "EHLO
	mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932680AbcBQHhT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2016 02:37:19 -0500
Received: by mail-wm0-f50.google.com with SMTP id g62so224444553wme.0
        for <netdev@vger.kernel.org>; Tue, 16 Feb 2016 23:37:18 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

Garbled output for "ethtool -m ethX", in igb-driven NICs with module /
plugin EEPROM (i.e. SFP information). Each output data byte appears
duplicated.

In igb_ethtool.c, igb_get_module_eeprom() is reading the EEPROM via i2c;
the eeprom offset for each word that's read via igb_read_phy_reg_i2c()
was passed in #words, whereas it needs to be a byte offset.
This patches fixes the bug.

Signed-off-by: Doron Shikmoni <doron.shikmoni@gmail.com>
---
 drivers/net/ethernet/intel/igb/igb_ethtool.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_ethtool.c b/drivers/net/ethernet/intel/igb/igb_ethtool.c
index 1d329f1..7bcc0e1e 100644
--- a/drivers/net/ethernet/intel/igb/igb_ethtool.c
+++ b/drivers/net/ethernet/intel/igb/igb_ethtool.c
@@ -2831,7 +2831,7 @@ static int igb_get_module_eeprom(struct net_device *netdev,
 
 	/* Read EEPROM block, SFF-8079/SFF-8472, word at a time */
 	for (i = 0; i < last_word - first_word + 1; i++) {
-		status = igb_read_phy_reg_i2c(hw, first_word + i, &dataword[i]);
+		status = igb_read_phy_reg_i2c(hw, (first_word + i) * 2, &dataword[i]);
 		if (status) {
 			/* Error occurred while reading module */
 			kfree(dataword);
-- 
1.7.10.4
