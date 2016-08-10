From: sunil.kovvuri@gmail.com
Subject: [PATCH 21/21] net: thunderx: Don't set RX_PACKET_DIS while
 initializing
Date: Wed, 10 Aug 2016 12:12:53 +0530
Message-ID: <1470811373-28277-22-git-send-email-sunil.kovvuri@gmail.com>
References: <1470811373-28277-1-git-send-email-sunil.kovvuri@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Sunil Goutham <sgoutham@cavium.com>, linux-kernel@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org
To: netdev@vger.kernel.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1470811373-28277-1-git-send-email-sunil.kovvuri@gmail.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

From: Sunil Goutham <sgoutham@cavium.com>

Setting BGXX_SPUX_MISC_CONTROL::RX_PACKET_DIS is not needed as
packet reception is anyway disabled by BGXX_CMRX_CONFIG::DATA_PKT_RX_EN.
Also setting RX_PACKET_DIS causes a bogus remote fault condition
which delays link detection.

Signed-off-by: Sunil Goutham <sgoutham@cavium.com>
---
 drivers/net/ethernet/cavium/thunder/thunder_bgx.c | 18 +++++++-----------
 1 file changed, 7 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/cavium/thunder/thunder_bgx.c b/drivers/net/ethernet/cavium/thunder/thunder_bgx.c
index ca58d7f..8bbaedb 100644
--- a/drivers/net/ethernet/cavium/thunder/thunder_bgx.c
+++ b/drivers/net/ethernet/cavium/thunder/thunder_bgx.c
@@ -459,12 +459,14 @@ static int bgx_lmac_xaui_init(struct bgx *bgx, struct lmac *lmac)
 
 	bgx_reg_modify(bgx, lmacid, BGX_SPUX_CONTROL1, SPU_CTL_LOW_POWER);
 	/* Set interleaved running disparity for RXAUI */
-	if (lmac->lmac_type != BGX_MODE_RXAUI)
-		bgx_reg_modify(bgx, lmacid,
-			       BGX_SPUX_MISC_CONTROL, SPU_MISC_CTL_RX_DIS);
-	else
+	if (lmac->lmac_type == BGX_MODE_RXAUI)
 		bgx_reg_modify(bgx, lmacid, BGX_SPUX_MISC_CONTROL,
-			       SPU_MISC_CTL_RX_DIS | SPU_MISC_CTL_INTLV_RDISP);
+			       SPU_MISC_CTL_INTLV_RDISP);
+
+	/* Clear receive packet disable */
+	cfg = bgx_reg_read(bgx, lmacid, BGX_SPUX_MISC_CONTROL);
+	cfg &= ~SPU_MISC_CTL_RX_DIS;
+	bgx_reg_write(bgx, lmacid, BGX_SPUX_MISC_CONTROL, cfg);
 
 	/* clear all interrupts */
 	cfg = bgx_reg_read(bgx, lmacid, BGX_SMUX_RX_INT);
@@ -537,7 +539,6 @@ static int bgx_xaui_check_link(struct lmac *lmac)
 	int lmac_type = lmac->lmac_type;
 	u64 cfg;
 
-	bgx_reg_modify(bgx, lmacid, BGX_SPUX_MISC_CONTROL, SPU_MISC_CTL_RX_DIS);
 	if (lmac->use_training) {
 		cfg = bgx_reg_read(bgx, lmacid, BGX_SPUX_INT);
 		if (!(cfg & (1ull << 13))) {
@@ -607,11 +608,6 @@ static int bgx_xaui_check_link(struct lmac *lmac)
 		return -1;
 	}
 
-	/* Clear receive packet disable */
-	cfg = bgx_reg_read(bgx, lmacid, BGX_SPUX_MISC_CONTROL);
-	cfg &= ~SPU_MISC_CTL_RX_DIS;
-	bgx_reg_write(bgx, lmacid, BGX_SPUX_MISC_CONTROL, cfg);
-
 	/* Check for MAC RX faults */
 	cfg = bgx_reg_read(bgx, lmacid, BGX_SMUX_RX_CTL);
 	/* 0 - Link is okay, 1 - Local fault, 2 - Remote fault */
-- 
2.7.4
