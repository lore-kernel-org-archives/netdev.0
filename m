From: Kulikov Vasiliy <segooon@gmail.com>
Subject: [PATCH] net: s2io: fix buffer overflow
Date: Fri, 23 Jul 2010 20:36:15 +0400
Message-ID: <1279902976-27146-1-git-send-email-segooon@gmail.com>
Cc: Ramkrishna Vepa <ramkrishna.vepa@exar.com>,
	Sivakumar Subramani <sivakumar.subramani@exar.com>,
	Sreenivasa Honnur <sreenivasa.honnur@exar.com>,
	Jon Mason <jon.mason@exar.com>,
	"David S. Miller" <davem@davemloft.net>,
	Joe Perches <joe@perches.com>, Jiri Pirko <jpirko@redhat.com>,
	netdev@vger.kernel.org
To: kernel-janitors@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:47216 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753395Ab0GWQgb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jul 2010 12:36:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

vpd_data[] is allocated as kmalloc(256, GFP_KERNEL), so if cnt = 255
then (cnt + 3) overflows 256. memset() is executed without checking.
vpd_data[cnt+2] must be less than 256-cnt-2 as the latter is number of
vpd_data[] elements to copy.

Do not fill with zero the beginning of nic->serial_num as it will
be filled with vpd_data[].

String in product_name[] should be terminated by '\0'.

Signed-off-by: Kulikov Vasiliy <segooon@gmail.com>
---
 drivers/net/s2io.c |   28 ++++++++++++++++++----------
 1 files changed, 18 insertions(+), 10 deletions(-)

diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index b8b8584..18bc5b7 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -5796,7 +5796,7 @@ static void s2io_vpd_read(struct s2io_nic *nic)
 {
 	u8 *vpd_data;
 	u8 data;
-	int i = 0, cnt, fail = 0;
+	int i = 0, cnt, len, fail = 0;
 	int vpd_addr = 0x80;
 	struct swStat *swstats = &nic->mac_control.stats_info->sw_stat;
 
@@ -5837,20 +5837,28 @@ static void s2io_vpd_read(struct s2io_nic *nic)
 
 	if (!fail) {
 		/* read serial number of adapter */
-		for (cnt = 0; cnt < 256; cnt++) {
+		for (cnt = 0; cnt < 252; cnt++) {
 			if ((vpd_data[cnt] == 'S') &&
-			    (vpd_data[cnt+1] == 'N') &&
-			    (vpd_data[cnt+2] < VPD_STRING_LEN)) {
-				memset(nic->serial_num, 0, VPD_STRING_LEN);
-				memcpy(nic->serial_num, &vpd_data[cnt + 3],
-				       vpd_data[cnt+2]);
-				break;
+			    (vpd_data[cnt+1] == 'N')) {
+				len = vpd_data[cnt+2];
+				if (len < min(VPD_STRING_LEN, 256-cnt-2)) {
+					memcpy(nic->serial_num,
+					       &vpd_data[cnt + 3],
+					       len);
+					memset(nic->serial_num+len,
+					       0,
+					       VPD_STRING_LEN-len);
+					break;
+				}
 			}
 		}
 	}
 
-	if ((!fail) && (vpd_data[1] < VPD_STRING_LEN))
-		memcpy(nic->product_name, &vpd_data[3], vpd_data[1]);
+	if ((!fail) && (vpd_data[1] < VPD_STRING_LEN)) {
+		len = vpd_data[1];
+		memcpy(nic->product_name, &vpd_data[3], len);
+		nic->product_name[len] = 0;
+	}
 	kfree(vpd_data);
 	swstats->mem_freed += 256;
 }
-- 
1.7.0.4

