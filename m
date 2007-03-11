From: Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
Subject: [PATCH] zd1211rw: Reject AL2230S devices
Date: Sun, 11 Mar 2007 19:54:11 +0000 (GMT)
Message-ID: <20070311195411.401937B409F@zog.reactivated.net>
Cc: kune-hUSrv6EASfkEnNRfnnE9gw@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

zd1211rw currently detects AL2230S-based devices as AL2230, and hence
programs the RF incorrectly. Transmit silently fails on this
misconfiguration.

After this patch, AL2230S devices are rejected with an error message, to
avoid any confusion with an apparent driver bug.

Signed-off-by: Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
---

John: please merge this into 2.6.21. A patch to actually support AL2230S will
follow, but it's too late for 2.6.21 inclusion. All I'm trying to do here is
avoid the unexplainable and silent failure when AL2230S devices are used with
the current driver code. Thanks!

 zd_chip.c      |    1 +
 zd_chip.h      |    2 +-
 zd_rf_al2230.c |    6 ++++++
 3 files changed, 8 insertions(+), 1 deletions(-)

Index: linux/drivers/net/wireless/zd1211rw/zd_chip.c
===================================================================
--- linux.orig/drivers/net/wireless/zd1211rw/zd_chip.c
+++ linux/drivers/net/wireless/zd1211rw/zd_chip.c
@@ -337,6 +337,7 @@ static int read_pod(struct zd_chip *chip
 	chip->patch_cr157 = (value >> 13) & 0x1;
 	chip->patch_6m_band_edge = (value >> 21) & 0x1;
 	chip->new_phy_layout = (value >> 31) & 0x1;
+	chip->al2230s_bit = (value >> 7) & 0x1;
 	chip->link_led = ((value >> 4) & 1) ? LED1 : LED2;
 	chip->supports_tx_led = 1;
 	if (value & (1 << 24)) { /* LED scenario */
Index: linux/drivers/net/wireless/zd1211rw/zd_chip.h
===================================================================
--- linux.orig/drivers/net/wireless/zd1211rw/zd_chip.h
+++ linux/drivers/net/wireless/zd1211rw/zd_chip.h
@@ -711,7 +711,7 @@ struct zd_chip {
 	u16 link_led;
 	unsigned int pa_type:4,
 		patch_cck_gain:1, patch_cr157:1, patch_6m_band_edge:1,
-		new_phy_layout:1,
+		new_phy_layout:1, al2230s_bit:1,
 		is_zd1211b:1, supports_tx_led:1;
 };
 
Index: linux/drivers/net/wireless/zd1211rw/zd_rf_al2230.c
===================================================================
--- linux.orig/drivers/net/wireless/zd1211rw/zd_rf_al2230.c
+++ linux/drivers/net/wireless/zd1211rw/zd_rf_al2230.c
@@ -358,6 +358,12 @@ int zd_rf_init_al2230(struct zd_rf *rf)
 {
 	struct zd_chip *chip = zd_rf_to_chip(rf);
 
+	if (chip->al2230s_bit) {
+		dev_err(zd_chip_dev(chip), "AL2230S devices are not yet "
+			"supported by this driver.\n");
+		return -ENODEV;
+	}
+
 	rf->switch_radio_off = al2230_switch_radio_off;
 	if (chip->is_zd1211b) {
 		rf->init_hw = zd1211b_al2230_init_hw;
