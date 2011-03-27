From: Jesper Juhl <jj@chaosbits.net>
Subject: [PATCH] Atheros, atl2: Fix mem leaks in error paths of
 atl2_set_eeprom
Date: Sun, 27 Mar 2011 21:16:12 +0200 (CEST)
Message-ID: <alpine.LNX.2.00.1103272110050.6111@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Chris Snook <csnook@redhat.com>,
	Chris Snook <chris.snook@gmail.com>,
	Chris Snook <chris.snook@gmail.com>,
	Jie Yang <jie.yang@atheros.com>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We leak in some error paths of drivers/net/atlx/atl2.c:atl2_set_eeprom().
The memory allocated to 'eeprom_buff' is not freed when we return -EIO. 
This patch fixes that up and also removes a pointless explicit cast.

Signed-off-by: Jesper Juhl <jj@chaosbits.net>
---
 atl2.c |   22 ++++++++++++++--------
 1 file changed, 14 insertions(+), 8 deletions(-)

 Compile tested only. I have no hardware to test.

diff --git a/drivers/net/atlx/atl2.c b/drivers/net/atlx/atl2.c
index e637e9f..937ef1a 100644
--- a/drivers/net/atlx/atl2.c
+++ b/drivers/net/atlx/atl2.c
@@ -1996,13 +1996,15 @@ static int atl2_set_eeprom(struct net_device *netdev,
 	if (!eeprom_buff)
 		return -ENOMEM;
 
-	ptr = (u32 *)eeprom_buff;
+	ptr = eeprom_buff;
 
 	if (eeprom->offset & 3) {
 		/* need read/modify/write of first changed EEPROM word */
 		/* only the second byte of the word is being modified */
-		if (!atl2_read_eeprom(hw, first_dword*4, &(eeprom_buff[0])))
-			return -EIO;
+		if (!atl2_read_eeprom(hw, first_dword*4, &(eeprom_buff[0]))) {
+			ret_val = -EIO;
+			goto out;
+		}
 		ptr++;
 	}
 	if (((eeprom->offset + eeprom->len) & 3)) {
@@ -2011,18 +2013,22 @@ static int atl2_set_eeprom(struct net_device *netdev,
 		 * only the first byte of the word is being modified
 		 */
 		if (!atl2_read_eeprom(hw, last_dword * 4,
-			&(eeprom_buff[last_dword - first_dword])))
-			return -EIO;
+					&(eeprom_buff[last_dword - first_dword]))) {
+			ret_val = -EIO;
+			goto out;
+		}
 	}
 
 	/* Device's eeprom is always little-endian, word addressable */
 	memcpy(ptr, bytes, eeprom->len);
 
 	for (i = 0; i < last_dword - first_dword + 1; i++) {
-		if (!atl2_write_eeprom(hw, ((first_dword+i)*4), eeprom_buff[i]))
-			return -EIO;
+		if (!atl2_write_eeprom(hw, ((first_dword+i)*4), eeprom_buff[i])) {
+			ret_val = -EIO;
+			goto out;
+		}
 	}
-
+ out:
 	kfree(eeprom_buff);
 	return ret_val;
 }


-- 
Jesper Juhl <jj@chaosbits.net>       http://www.chaosbits.net/
Don't top-post http://www.catb.org/jargon/html/T/top-post.html
Plain text mails only, please.
