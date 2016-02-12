From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] ath9k: reduce stack usage in ar9003_aic_cal_post_process
Date: Fri, 12 Feb 2016 12:55:21 +0100
Message-ID: <1455278130-1831694-1-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Arnd Bergmann <arnd@arndb.de>, netdev@vger.kernel.org,
 linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org,
 ath9k-devel@lists.ath9k.org, linux-arm-kernel@lists.infradead.org
To: QCA ath9k Development <ath9k-devel@qca.qualcomm.com>,
 Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
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

In some configurations, this function uses more than the warning limit
of 1024 bytes:

drivers/net/wireless/ath/ath9k/ar9003_aic.c: In function 'ar9003_aic_cal_post_process':
drivers/net/wireless/ath/ath9k/ar9003_aic.c:434:1: error: the frame size of 1040 bytes is larger than 1024 bytes [-Werror=frame-larger-than=]

It turns out that there are two large arrays on the stack here, but
almost all the data in them is never used outside of the loop in
which it gets written, so we can replace the array with a single
instance.

The .valid flag is used later, so I'm replacing the array of structures
with an array of bools. An obvious follow-up optimization would be
to replace it with a bitmask and set_bit()/find_first_bit()/
find_last_bit()/... operations. However, I have not tested this patch,
so I sticked to the simpler transformation that does the job of
reducing the stack usage to a harmless level.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/wireless/ath/ath9k/ar9003_aic.c | 79 +++++++++++++++--------------
 drivers/net/wireless/ath/ath9k/ar9003_aic.h |  1 -
 2 files changed, 40 insertions(+), 40 deletions(-)

diff --git a/drivers/net/wireless/ath/ath9k/ar9003_aic.c b/drivers/net/wireless/ath/ath9k/ar9003_aic.c
index 1db119d77783..547cd46da260 100644
--- a/drivers/net/wireless/ath/ath9k/ar9003_aic.c
+++ b/drivers/net/wireless/ath/ath9k/ar9003_aic.c
@@ -53,19 +53,19 @@ static bool ar9003_hw_is_aic_enabled(struct ath_hw *ah)
 	return true;
 }
 
-static int16_t ar9003_aic_find_valid(struct ath_aic_sram_info *cal_sram,
+static int16_t ar9003_aic_find_valid(bool *cal_sram_valid,
 				     bool dir, u8 index)
 {
 	int16_t i;
 
 	if (dir) {
 		for (i = index + 1; i < ATH_AIC_MAX_BT_CHANNEL; i++) {
-			if (cal_sram[i].valid)
+			if (cal_sram_valid[i])
 				break;
 		}
 	} else {
 		for (i = index - 1; i >= 0; i--) {
-			if (cal_sram[i].valid)
+			if (cal_sram_valid[i])
 				break;
 		}
 	}
@@ -264,7 +264,7 @@ static u8 ar9003_aic_cal_start(struct ath_hw *ah, u8 min_valid_count)
 static bool ar9003_aic_cal_post_process(struct ath_hw *ah)
 {
 	struct ath9k_hw_aic *aic = &ah->btcoex_hw.aic;
-	struct ath_aic_sram_info cal_sram[ATH_AIC_MAX_BT_CHANNEL];
+	bool cal_sram_valid[ATH_AIC_MAX_BT_CHANNEL];
 	struct ath_aic_out_info aic_sram[ATH_AIC_MAX_BT_CHANNEL];
 	u32 dir_path_gain_idx, quad_path_gain_idx, value;
 	u32 fixed_com_att_db;
@@ -272,33 +272,34 @@ static bool ar9003_aic_cal_post_process(struct ath_hw *ah)
 	int16_t i;
 	bool ret = true;
 
-	memset(&cal_sram, 0, sizeof(cal_sram));
+	memset(&cal_sram_valid, 0, sizeof(cal_sram_valid));
 	memset(&aic_sram, 0, sizeof(aic_sram));
 
 	for (i = 0; i < ATH_AIC_MAX_BT_CHANNEL; i++) {
+		struct ath_aic_sram_info sram;
 		value = aic->aic_sram[i];
 
-		cal_sram[i].valid =
+		cal_sram_valid[i] = sram.valid =
 			MS(value, AR_PHY_AIC_SRAM_VALID);
-		cal_sram[i].rot_quad_att_db =
+		sram.rot_quad_att_db =
 			MS(value, AR_PHY_AIC_SRAM_ROT_QUAD_ATT_DB);
-		cal_sram[i].vga_quad_sign =
+		sram.vga_quad_sign =
 			MS(value, AR_PHY_AIC_SRAM_VGA_QUAD_SIGN);
-		cal_sram[i].rot_dir_att_db =
+		sram.rot_dir_att_db =
 			MS(value, AR_PHY_AIC_SRAM_ROT_DIR_ATT_DB);
-		cal_sram[i].vga_dir_sign =
+		sram.vga_dir_sign =
 			MS(value, AR_PHY_AIC_SRAM_VGA_DIR_SIGN);
-		cal_sram[i].com_att_6db =
+		sram.com_att_6db =
 			MS(value, AR_PHY_AIC_SRAM_COM_ATT_6DB);
 
-		if (cal_sram[i].valid) {
-			dir_path_gain_idx = cal_sram[i].rot_dir_att_db +
-				com_att_db_table[cal_sram[i].com_att_6db];
-			quad_path_gain_idx = cal_sram[i].rot_quad_att_db +
-				com_att_db_table[cal_sram[i].com_att_6db];
+		if (sram.valid) {
+			dir_path_gain_idx = sram.rot_dir_att_db +
+				com_att_db_table[sram.com_att_6db];
+			quad_path_gain_idx = sram.rot_quad_att_db +
+				com_att_db_table[sram.com_att_6db];
 
-			dir_path_sign = (cal_sram[i].vga_dir_sign) ? 1 : -1;
-			quad_path_sign = (cal_sram[i].vga_quad_sign) ? 1 : -1;
+			dir_path_sign = (sram.vga_dir_sign) ? 1 : -1;
+			quad_path_sign = (sram.vga_quad_sign) ? 1 : -1;
 
 			aic_sram[i].dir_path_gain_lin = dir_path_sign *
 				aic_lin_table[dir_path_gain_idx];
@@ -310,16 +311,16 @@ static bool ar9003_aic_cal_post_process(struct ath_hw *ah)
 	for (i = 0; i < ATH_AIC_MAX_BT_CHANNEL; i++) {
 		int16_t start_idx, end_idx;
 
-		if (cal_sram[i].valid)
+		if (cal_sram_valid[i])
 			continue;
 
-		start_idx = ar9003_aic_find_valid(cal_sram, 0, i);
-		end_idx = ar9003_aic_find_valid(cal_sram, 1, i);
+		start_idx = ar9003_aic_find_valid(cal_sram_valid, 0, i);
+		end_idx = ar9003_aic_find_valid(cal_sram_valid, 1, i);
 
 		if (start_idx < 0) {
 			/* extrapolation */
 			start_idx = end_idx;
-			end_idx = ar9003_aic_find_valid(cal_sram, 1, start_idx);
+			end_idx = ar9003_aic_find_valid(cal_sram_valid, 1, start_idx);
 
 			if (end_idx < 0) {
 				ret = false;
@@ -342,7 +343,7 @@ static bool ar9003_aic_cal_post_process(struct ath_hw *ah)
 
 		if (end_idx < 0) {
 			/* extrapolation */
-			end_idx = ar9003_aic_find_valid(cal_sram, 0, start_idx);
+			end_idx = ar9003_aic_find_valid(cal_sram_valid, 0, start_idx);
 
 			if (end_idx < 0) {
 				ret = false;
@@ -378,19 +379,21 @@ static bool ar9003_aic_cal_post_process(struct ath_hw *ah)
 	}
 
 	/* From dir/quad_path_gain_lin to sram. */
-	i = ar9003_aic_find_valid(cal_sram, 1, 0);
+	i = ar9003_aic_find_valid(cal_sram_valid, 1, 0);
 	if (i < 0) {
 		i = 0;
 		ret = false;
 	}
-	fixed_com_att_db = com_att_db_table[cal_sram[i].com_att_6db];
+	fixed_com_att_db = com_att_db_table[MS(aic->aic_sram[i],
+					    AR_PHY_AIC_SRAM_COM_ATT_6DB)];
 
 	for (i = 0; i < ATH_AIC_MAX_BT_CHANNEL; i++) {
 		int16_t rot_dir_path_att_db, rot_quad_path_att_db;
+		struct ath_aic_sram_info sram;
 
-		aic_sram[i].sram.vga_dir_sign =
+		sram.vga_dir_sign =
 			(aic_sram[i].dir_path_gain_lin >= 0) ? 1 : 0;
-		aic_sram[i].sram.vga_quad_sign=
+		sram.vga_quad_sign =
 			(aic_sram[i].quad_path_gain_lin >= 0) ? 1 : 0;
 
 		rot_dir_path_att_db =
@@ -400,33 +403,31 @@ static bool ar9003_aic_cal_post_process(struct ath_hw *ah)
 			ar9003_aic_find_index(0, abs(aic_sram[i].quad_path_gain_lin)) -
 			fixed_com_att_db;
 
-		aic_sram[i].sram.com_att_6db =
+		sram.com_att_6db =
 			ar9003_aic_find_index(1, fixed_com_att_db);
 
-		aic_sram[i].sram.valid = 1;
+		sram.valid = 1;
 
-		aic_sram[i].sram.rot_dir_att_db =
+		sram.rot_dir_att_db =
 			min(max(rot_dir_path_att_db,
 				(int16_t)ATH_AIC_MIN_ROT_DIR_ATT_DB),
 			    ATH_AIC_MAX_ROT_DIR_ATT_DB);
-		aic_sram[i].sram.rot_quad_att_db =
+		sram.rot_quad_att_db =
 			min(max(rot_quad_path_att_db,
 				(int16_t)ATH_AIC_MIN_ROT_QUAD_ATT_DB),
 			    ATH_AIC_MAX_ROT_QUAD_ATT_DB);
-	}
 
-	for (i = 0; i < ATH_AIC_MAX_BT_CHANNEL; i++) {
-		aic->aic_sram[i] = (SM(aic_sram[i].sram.vga_dir_sign,
+		aic->aic_sram[i] = (SM(sram.vga_dir_sign,
 				       AR_PHY_AIC_SRAM_VGA_DIR_SIGN) |
-				    SM(aic_sram[i].sram.vga_quad_sign,
+				    SM(sram.vga_quad_sign,
 				       AR_PHY_AIC_SRAM_VGA_QUAD_SIGN) |
-				    SM(aic_sram[i].sram.com_att_6db,
+				    SM(sram.com_att_6db,
 				       AR_PHY_AIC_SRAM_COM_ATT_6DB) |
-				    SM(aic_sram[i].sram.valid,
+				    SM(sram.valid,
 				       AR_PHY_AIC_SRAM_VALID) |
-				    SM(aic_sram[i].sram.rot_dir_att_db,
+				    SM(sram.rot_dir_att_db,
 				       AR_PHY_AIC_SRAM_ROT_DIR_ATT_DB) |
-				    SM(aic_sram[i].sram.rot_quad_att_db,
+				    SM(sram.rot_quad_att_db,
 				       AR_PHY_AIC_SRAM_ROT_QUAD_ATT_DB));
 	}
 
diff --git a/drivers/net/wireless/ath/ath9k/ar9003_aic.h b/drivers/net/wireless/ath/ath9k/ar9003_aic.h
index 86f40644be43..9512c63799f2 100644
--- a/drivers/net/wireless/ath/ath9k/ar9003_aic.h
+++ b/drivers/net/wireless/ath/ath9k/ar9003_aic.h
@@ -50,7 +50,6 @@ struct ath_aic_sram_info {
 struct ath_aic_out_info {
 	int16_t dir_path_gain_lin;
 	int16_t quad_path_gain_lin;
-	struct ath_aic_sram_info sram;
 };
 
 u8 ar9003_aic_calibration(struct ath_hw *ah);
-- 
2.7.0
