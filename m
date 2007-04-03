From: Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
Subject: [PATCH] zd1211rw: Fix E2P_PHY_REG patching
Date: Tue,  3 Apr 2007 23:17:37 +0100 (BST)
Message-ID: <20070403221737.3473A7B409F@zog.reactivated.net>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: kune-hUSrv6EASfkEnNRfnnE9gw@public.gmane.org
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Due to conflicting/confusing defines in the vendor driver, we were
reading E2P_PHY_REG from the wrong location.

CR157 patching was slightly incorrect in that the vendor driver only
patches in an 8-bit value, whereas we were patching 24 bits.

Additionally, CR157 patching was happening on both zd1211 and zd1211b,
but this should only happen on zd1211.

Signed-off-by: Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
Signed-off-by: Ulrich Kunitz <kune-hUSrv6EASfkEnNRfnnE9gw@public.gmane.org>
---
 zd_chip.c |   11 +++--------
 zd_chip.h |    2 +-
 2 files changed, 4 insertions(+), 9 deletions(-)

Index: linux/drivers/net/wireless/zd1211rw/zd_chip.c
===================================================================
--- linux.orig/drivers/net/wireless/zd1211rw/zd_chip.c
+++ linux/drivers/net/wireless/zd1211rw/zd_chip.c
@@ -593,16 +593,16 @@ int zd_chip_unlock_phy_regs(struct zd_ch
 	return r;
 }
 
-/* CR157 can be optionally patched by the EEPROM */
+/* CR157 can be optionally patched by the EEPROM for original ZD1211 */
 static int patch_cr157(struct zd_chip *chip)
 {
 	int r;
-	u32 value;
+	u16 value;
 
 	if (!chip->patch_cr157)
 		return 0;
 
-	r = zd_ioread32_locked(chip, &value, E2P_PHY_REG);
+	r = zd_ioread16_locked(chip, &value, E2P_PHY_REG);
 	if (r)
 		return r;
 
@@ -792,11 +792,6 @@ static int zd1211b_hw_reset_phy(struct z
 		goto out;
 
 	r = zd_iowrite16a_locked(chip, ioreqs, ARRAY_SIZE(ioreqs));
-	if (r)
-		goto unlock;
-
-	r = patch_cr157(chip);
-unlock:
 	t = zd_chip_unlock_phy_regs(chip);
 	if (t && !r)
 		r = t;
Index: linux/drivers/net/wireless/zd1211rw/zd_chip.h
===================================================================
--- linux.orig/drivers/net/wireless/zd1211rw/zd_chip.h
+++ linux/drivers/net/wireless/zd1211rw/zd_chip.h
@@ -641,8 +641,8 @@ enum {
  * also only 11 channels. */
 #define E2P_ALLOWED_CHANNEL	E2P_DATA(0x18)
 
-#define E2P_PHY_REG		E2P_DATA(0x1a)
 #define E2P_DEVICE_VER		E2P_DATA(0x20)
+#define E2P_PHY_REG		E2P_DATA(0x25)
 #define E2P_36M_CAL_VALUE1	E2P_DATA(0x28)
 #define E2P_36M_CAL_VALUE2      E2P_DATA(0x2a)
 #define E2P_36M_CAL_VALUE3      E2P_DATA(0x2c)
