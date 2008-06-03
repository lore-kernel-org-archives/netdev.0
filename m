From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 25/39] mv643xx_eth: massively simplify multicast address crc8 computation
Date: Tue,  3 Jun 2008 13:02:40 +0200
Message-ID: <1212490974-23719-26-git-send-email-buytenh@wantstofly.org>
References: <1212490974-23719-1-git-send-email-buytenh@wantstofly.org>
Cc: netdev@vger.kernel.org
To: Dale Farnsworth <dale@farnsworth.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:48756 "EHLO
	delta.wantstofly.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754641AbYFCMA3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 08:00:29 -0400
In-Reply-To: <1212490974-23719-1-git-send-email-buytenh@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace the 70-line crc8 computation (used for multicast address
filtering tables) by a 5-line version.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
---
 drivers/net/mv643xx_eth.c |   95 ++++++++++-----------------------------------
 1 files changed, 21 insertions(+), 74 deletions(-)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index b3be8fe..beb4cf9 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -1132,16 +1132,29 @@ static int mv643xx_eth_set_mac_address(struct net_device *dev, void *addr)
 	return 0;
 }
 
+static int addr_crc(unsigned char *addr)
+{
+	int crc = 0;
+	int i;
+
+	for (i = 0; i < 6; i++) {
+		int j;
+
+		crc = (crc ^ addr[i]) << 8;
+		for (j = 7; j >= 0; j--) {
+			if (crc & (0x100 << j))
+				crc ^= 0x107 << j;
+		}
+	}
+
+	return crc;
+}
+
 static void mc_addr(struct mv643xx_eth_private *mep, unsigned char *addr)
 {
 	unsigned int port_num = mep->port_num;
-	unsigned int mac_h;
-	unsigned int mac_l;
-	unsigned char crc_result = 0;
 	int table;
-	int mac_array[48];
-	int crc[8];
-	int i;
+	int crc;
 
 	if ((addr[0] == 0x01) && (addr[1] == 0x00) &&
 	    (addr[2] == 0x5E) && (addr[3] == 0x00) && (addr[4] == 0x00)) {
@@ -1150,76 +1163,10 @@ static void mc_addr(struct mv643xx_eth_private *mep, unsigned char *addr)
 		return;
 	}
 
-	/* Calculate CRC-8 out of the given address */
-	mac_h = (addr[0] << 8) | (addr[1]);
-	mac_l = (addr[2] << 24) | (addr[3] << 16) |
-			(addr[4] << 8) | (addr[5] << 0);
-
-	for (i = 0; i < 32; i++)
-		mac_array[i] = (mac_l >> i) & 0x1;
-	for (i = 32; i < 48; i++)
-		mac_array[i] = (mac_h >> (i - 32)) & 0x1;
-
-	crc[0] = mac_array[45] ^ mac_array[43] ^ mac_array[40] ^ mac_array[39] ^
-		 mac_array[35] ^ mac_array[34] ^ mac_array[31] ^ mac_array[30] ^
-		 mac_array[28] ^ mac_array[23] ^ mac_array[21] ^ mac_array[19] ^
-		 mac_array[18] ^ mac_array[16] ^ mac_array[14] ^ mac_array[12] ^
-		 mac_array[8]  ^ mac_array[7]  ^ mac_array[6]  ^ mac_array[0];
-
-	crc[1] = mac_array[46] ^ mac_array[45] ^ mac_array[44] ^ mac_array[43] ^
-		 mac_array[41] ^ mac_array[39] ^ mac_array[36] ^ mac_array[34] ^
-		 mac_array[32] ^ mac_array[30] ^ mac_array[29] ^ mac_array[28] ^
-		 mac_array[24] ^ mac_array[23] ^ mac_array[22] ^ mac_array[21] ^
-		 mac_array[20] ^ mac_array[18] ^ mac_array[17] ^ mac_array[16] ^
-		 mac_array[15] ^ mac_array[14] ^ mac_array[13] ^ mac_array[12] ^
-		 mac_array[9]  ^ mac_array[6]  ^ mac_array[1]  ^ mac_array[0];
-
-	crc[2] = mac_array[47] ^ mac_array[46] ^ mac_array[44] ^ mac_array[43] ^
-		 mac_array[42] ^ mac_array[39] ^ mac_array[37] ^ mac_array[34] ^
-		 mac_array[33] ^ mac_array[29] ^ mac_array[28] ^ mac_array[25] ^
-		 mac_array[24] ^ mac_array[22] ^ mac_array[17] ^ mac_array[15] ^
-		 mac_array[13] ^ mac_array[12] ^ mac_array[10] ^ mac_array[8]  ^
-		 mac_array[6]  ^ mac_array[2]  ^ mac_array[1]  ^ mac_array[0];
-
-	crc[3] = mac_array[47] ^ mac_array[45] ^ mac_array[44] ^ mac_array[43] ^
-		 mac_array[40] ^ mac_array[38] ^ mac_array[35] ^ mac_array[34] ^
-		 mac_array[30] ^ mac_array[29] ^ mac_array[26] ^ mac_array[25] ^
-		 mac_array[23] ^ mac_array[18] ^ mac_array[16] ^ mac_array[14] ^
-		 mac_array[13] ^ mac_array[11] ^ mac_array[9]  ^ mac_array[7]  ^
-		 mac_array[3]  ^ mac_array[2]  ^ mac_array[1];
-
-	crc[4] = mac_array[46] ^ mac_array[45] ^ mac_array[44] ^ mac_array[41] ^
-		 mac_array[39] ^ mac_array[36] ^ mac_array[35] ^ mac_array[31] ^
-		 mac_array[30] ^ mac_array[27] ^ mac_array[26] ^ mac_array[24] ^
-		 mac_array[19] ^ mac_array[17] ^ mac_array[15] ^ mac_array[14] ^
-		 mac_array[12] ^ mac_array[10] ^ mac_array[8]  ^ mac_array[4]  ^
-		 mac_array[3]  ^ mac_array[2];
-
-	crc[5] = mac_array[47] ^ mac_array[46] ^ mac_array[45] ^ mac_array[42] ^
-		 mac_array[40] ^ mac_array[37] ^ mac_array[36] ^ mac_array[32] ^
-		 mac_array[31] ^ mac_array[28] ^ mac_array[27] ^ mac_array[25] ^
-		 mac_array[20] ^ mac_array[18] ^ mac_array[16] ^ mac_array[15] ^
-		 mac_array[13] ^ mac_array[11] ^ mac_array[9]  ^ mac_array[5]  ^
-		 mac_array[4]  ^ mac_array[3];
-
-	crc[6] = mac_array[47] ^ mac_array[46] ^ mac_array[43] ^ mac_array[41] ^
-		 mac_array[38] ^ mac_array[37] ^ mac_array[33] ^ mac_array[32] ^
-		 mac_array[29] ^ mac_array[28] ^ mac_array[26] ^ mac_array[21] ^
-		 mac_array[19] ^ mac_array[17] ^ mac_array[16] ^ mac_array[14] ^
-		 mac_array[12] ^ mac_array[10] ^ mac_array[6]  ^ mac_array[5]  ^
-		 mac_array[4];
-
-	crc[7] = mac_array[47] ^ mac_array[44] ^ mac_array[42] ^ mac_array[39] ^
-		 mac_array[38] ^ mac_array[34] ^ mac_array[33] ^ mac_array[30] ^
-		 mac_array[29] ^ mac_array[27] ^ mac_array[22] ^ mac_array[20] ^
-		 mac_array[18] ^ mac_array[17] ^ mac_array[15] ^ mac_array[13] ^
-		 mac_array[11] ^ mac_array[7]  ^ mac_array[6]  ^ mac_array[5];
-
-	for (i = 0; i < 8; i++)
-		crc_result = crc_result | (crc[i] << i);
+	crc = addr_crc(addr);
 
 	table = OTHER_MCAST_TABLE(port_num);
-	set_filter_table_entry(mep, table, crc_result);
+	set_filter_table_entry(mep, table, crc);
 }
 
 static void set_multicast_list(struct net_device *dev)
-- 
1.5.3.4

