From: Mark Brown <broonie@opensource.wolfsonmicro.com>
Subject: [PATCH] net: DM9000: Add support for byte EEPROM access
Date: Fri, 10 Jun 2011 11:50:32 +0100
Message-ID: <1307703032-20349-1-git-send-email-broonie@opensource.wolfsonmicro.com>
Cc: netdev@vger.kernel.org, Ben Dooks <ben-linux@fluff.org>,
	Mark Brown <broonie@opensource.wolfsonmicro.com>
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from opensource.wolfsonmicro.com ([80.75.67.52]:50254 "EHLO
	opensource2.wolfsonmicro.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754621Ab1FJKuk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jun 2011 06:50:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Dooks <ben-linux@fluff.org>

Given many versions of ethtool's reluctance to do anything other than
byte accesses to the EEPROM interface, it is easier to update the driver
to support byte accesses so that all the ethtool versions that have been
observed in Debian can write the EEPROM.

Signed-off-by: Ben Dooks <ben-linux@fluff.org>
Signed-off-by: Mark Brown <broonie@opensource.wolfsonmicro.com>
---
 drivers/net/dm9000.c |   26 ++++++++++++++++++++------
 1 files changed, 20 insertions(+), 6 deletions(-)

diff --git a/drivers/net/dm9000.c b/drivers/net/dm9000.c
index 863e9c4..8ef31dc 100644
--- a/drivers/net/dm9000.c
+++ b/drivers/net/dm9000.c
@@ -535,21 +535,35 @@ static int dm9000_set_eeprom(struct net_device *dev,
 	board_info_t *dm = to_dm9000_board(dev);
 	int offset = ee->offset;
 	int len = ee->len;
-	int i;
+	int done;
 
 	/* EEPROM access is aligned to two bytes */
 
-	if ((len & 1) != 0 || (offset & 1) != 0)
-		return -EINVAL;
-
 	if (dm->flags & DM9000_PLATF_NO_EEPROM)
 		return -ENOENT;
 
 	if (ee->magic != DM_EEPROM_MAGIC)
 		return -EINVAL;
 
-	for (i = 0; i < len; i += 2)
-		dm9000_write_eeprom(dm, (offset + i) / 2, data + i);
+	while (len > 0) {
+		if (len & 1 || offset & 1) {
+			int which = offset & 1;
+			u8 tmp[2];
+
+			dm9000_read_eeprom(dm, offset / 2, tmp);
+			tmp[which] = *data;
+			dm9000_write_eeprom(dm, offset / 2, tmp);
+
+			done = 1;
+		} else {
+			dm9000_write_eeprom(dm, offset / 2, data);
+			done = 2;
+		}
+
+		data += done;
+		offset += done;
+		len -= done;
+	}
 
 	return 0;
 }
-- 
1.7.5.3

