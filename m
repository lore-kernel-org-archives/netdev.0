From: jon@ringle.org
Subject: [PATCH 2/2] net: encx24j600: Simplified regmap_encx24j600_reg_update_bits()
Date: Mon,  5 Oct 2015 09:29:32 -0400
Message-ID: <1444051772-20270-2-git-send-email-jon@ringle.org>
References: <1444051772-20270-1-git-send-email-jon@ringle.org>
Cc: Jon Ringle <jringle@gridpoint.com>
To: broonie@kernel.org, gregkh@linuxfoundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1444051772-20270-1-git-send-email-jon@ringle.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jon Ringle <jringle@gridpoint.com>

The changes to _regmap_update_bits() to call a custom reg_update_bits()
function simplify the function signature and also don't need to deal with
registers that can't individual bit updates via the hardware. The normal
flow of _regmap_update_bits() will take care of doing read/modify/write
cycle for any register not marked as volatile.

Signed-off-by: Jon Ringle <jringle@gridpoint.com>
---

This patch is being submitted because
"[PATCH net-next v3 2/2] net: Microchip encx24j600 driver"
was applied to net-next prematurely (there was a v3 patch out for review).

This is a diff between the v2 and v3.

Thanks,

Jon

 drivers/net/ethernet/microchip/encx24j600-regmap.c | 56 ++++------------------
 1 file changed, 9 insertions(+), 47 deletions(-)

diff --git a/drivers/net/ethernet/microchip/encx24j600-regmap.c b/drivers/net/ethernet/microchip/encx24j600-regmap.c
index f1d74e3..f3bb905 100644
--- a/drivers/net/ethernet/microchip/encx24j600-regmap.c
+++ b/drivers/net/ethernet/microchip/encx24j600-regmap.c
@@ -191,8 +191,7 @@ static int regmap_encx24j600_sfr_clr_bits(struct encx24j600_context *ctx,
 
 static int regmap_encx24j600_reg_update_bits(void *context, unsigned int reg,
 					     unsigned int mask,
-					     unsigned int val, bool *change,
-					     bool force_write)
+					     unsigned int val)
 {
 	struct encx24j600_context *ctx = context;
 
@@ -200,61 +199,24 @@ static int regmap_encx24j600_reg_update_bits(void *context, unsigned int reg,
 	unsigned int set_mask = mask & val;
 	unsigned int clr_mask = mask & ~val;
 
-	if (change)
-		*change = false;
-
-	if ((reg >= 0x40 && reg < 0x6c) || reg >= 0x80) {
-		/* Must do read/modify/write cycles for
-		 * MAC/MII regs or Unbanked SFR regs
-		 */
-		u16 tmp, orig;
-
-		ret = regmap_encx24j600_sfr_read(context, reg, (u8 *)&orig,
-						 sizeof(orig));
-		if (ret != 0)
-			return ret;
-
-		tmp = orig & ~mask;
-		tmp |= val & mask;
-
-		if (force_write || (tmp != orig)) {
-			ret = regmap_encx24j600_sfr_write(context, reg,
-							  (u8 *)&tmp,
-							  sizeof(tmp));
-			if (change)
-				*change = true;
-		} else if (change) {
-			*change = false;
-		}
-
-		return ret;
-	}
+	if ((reg >= 0x40 && reg < 0x6c) || reg >= 0x80)
+		return -EINVAL;
 
-	if (set_mask & 0xff) {
+	if (set_mask & 0xff)
 		ret = regmap_encx24j600_sfr_set_bits(ctx, reg, set_mask);
-		if (ret == 0 && change)
-			*change = true;
-	}
+
 	set_mask = (set_mask & 0xff00) >> 8;
 
-	if ((set_mask & 0xff) && (ret == 0)) {
+	if ((set_mask & 0xff) && (ret == 0))
 		ret = regmap_encx24j600_sfr_set_bits(ctx, reg + 1, set_mask);
-		if (ret == 0 && change)
-			*change = true;
-	}
 
-	if ((clr_mask & 0xff) && (ret == 0)) {
+	if ((clr_mask & 0xff) && (ret == 0))
 		ret = regmap_encx24j600_sfr_clr_bits(ctx, reg, clr_mask);
-		if (ret == 0 && change)
-			*change = true;
-	}
+
 	clr_mask = (clr_mask & 0xff00) >> 8;
 
-	if ((clr_mask & 0xff) && (ret == 0)) {
+	if ((clr_mask & 0xff) && (ret == 0))
 		ret = regmap_encx24j600_sfr_clr_bits(ctx, reg + 1, clr_mask);
-		if (ret == 0 && change)
-			*change = true;
-	}
 
 	return ret;
 }
-- 
2.4.1
