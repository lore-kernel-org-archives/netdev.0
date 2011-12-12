From: Xi Wang <xi.wang@gmail.com>
Subject: [PATCH] pch_can: fix error passive level test
Date: Mon, 12 Dec 2011 02:16:20 -0500
Message-ID: <1323674180-16916-1-git-send-email-xi.wang@gmail.com>
Cc: linux-can@vger.kernel.org, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Xi Wang <xi.wang@gmail.com>
To: Masayuki Ohtake <masa-korg@dsn.okisemi.com>,
	Tomoya MORINAGA <tomoya-linux@dsn.okisemi.com>,
	Wolfgang Grandegger <wg@grandegger.com>
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The test (((errc & PCH_REC) >> 8) > 127) would always be false because
the receive error counter ((errc & PCH_REC) >> 8) is at most 127, where
PCH_REC is defined as 0x7f00.  To test whether the receive error counter
has reached the error passive level, the RP bit (15) should be used.

Signed-off-by: Xi Wang <xi.wang@gmail.com>
---
 drivers/net/can/pch_can.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/can/pch_can.c b/drivers/net/can/pch_can.c
index d11fbb2..6edc25e 100644
--- a/drivers/net/can/pch_can.c
+++ b/drivers/net/can/pch_can.c
@@ -66,6 +66,7 @@
 #define PCH_IF_CREQ_BUSY	BIT(15)
 
 #define PCH_STATUS_INT		0x8000
+#define PCH_RP			0x00008000
 #define PCH_REC			0x00007f00
 #define PCH_TEC			0x000000ff
 
@@ -527,7 +528,7 @@ static void pch_can_error(struct net_device *ndev, u32 status)
 		priv->can.can_stats.error_passive++;
 		state = CAN_STATE_ERROR_PASSIVE;
 		cf->can_id |= CAN_ERR_CRTL;
-		if (((errc & PCH_REC) >> 8) > 127)
+		if (errc & PCH_RP)
 			cf->data[1] |= CAN_ERR_CRTL_RX_PASSIVE;
 		if ((errc & PCH_TEC) > 127)
 			cf->data[1] |= CAN_ERR_CRTL_TX_PASSIVE;
-- 
1.7.5.4

