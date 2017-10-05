From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] rsi: fix integer overflow warning
Date: Thu,  5 Oct 2017 14:05:24 +0200
Message-ID: <20171005120547.328687-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>,
        Pavani Muthyala <pavani.muthyala@redpinesignals.com>,
        Karun Eagalapati <karun256@gmail.com>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Kalle Valo <kvalo@codeaurora.org>,
        Prameela Rani Garnepudi <prameela.j04cs@gmail.com>,
        Amitkumar Karwar <amit.karwar@redpinesignals.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

gcc produces a harmless warning about a recently introduced
signed integer overflow:

drivers/net/wireless/rsi/rsi_91x_hal.c: In function 'rsi_prepare_mgmt_desc':
include/uapi/linux/swab.h:13:15: error: integer overflow in expression [-Werror=overflow]
  (((__u16)(x) & (__u16)0x00ffU) << 8) |   \
   ~~~~~~~~~~~~^~~~~~~~~~~~~~~~~
include/uapi/linux/swab.h:104:2: note: in expansion of macro '___constant_swab16'
  ___constant_swab16(x) :   \
  ^~~~~~~~~~~~~~~~~~
include/uapi/linux/byteorder/big_endian.h:34:43: note: in expansion of macro '__swab16'
 #define __cpu_to_le16(x) ((__force __le16)__swab16((x)))
                                           ^~~~~~~~
include/linux/byteorder/generic.h:89:21: note: in expansion of macro '__cpu_to_le16'
 #define cpu_to_le16 __cpu_to_le16
                     ^~~~~~~~~~~~~
drivers/net/wireless/rsi/rsi_91x_hal.c:136:3: note: in expansion of macro 'cpu_to_le16'
   cpu_to_le16((tx_params->vap_id << RSI_DESC_VAP_ID_OFST) &
   ^~~~~~~~~~~

The problem is that the 'mask' value is a signed integer that gets
turned into a negative number when truncated to 16 bits. Making it
an unsigned constant avoids this.

Fixes: eac4eed3224b ("rsi: tx and rx path enhancements for p2p mode")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/wireless/rsi/rsi_mgmt.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/rsi/rsi_mgmt.h b/drivers/net/wireless/rsi/rsi_mgmt.h
index b9d0802c1b0f..e21723013f8d 100644
--- a/drivers/net/wireless/rsi/rsi_mgmt.h
+++ b/drivers/net/wireless/rsi/rsi_mgmt.h
@@ -189,7 +189,7 @@
 	 IEEE80211_WMM_IE_STA_QOSINFO_AC_BE | \
 	 IEEE80211_WMM_IE_STA_QOSINFO_AC_BK)
 
-#define RSI_DESC_VAP_ID_MASK		0xC000
+#define RSI_DESC_VAP_ID_MASK		0xC000u
 #define RSI_DESC_VAP_ID_OFST		14
 #define RSI_DATA_DESC_MAC_BBP_INFO	BIT(0)
 #define RSI_DATA_DESC_NO_ACK_IND	BIT(9)
-- 
2.9.0
