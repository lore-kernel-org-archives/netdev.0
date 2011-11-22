From: =?UTF-8?q?Maciej=20=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: [PATCH] net-e1000e: Report carrier in loopback mode.
Date: Tue, 22 Nov 2011 12:34:51 -0800
Message-ID: <1321994091-7589-1-git-send-email-zenczykowski@gmail.com>
References: <CAHo-OozdBn5jBNsRVzbCnmxozquJnTAYa0bNbK5VoaiKaK=7qQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	=?UTF-8?q?Maciej=20=C5=BBenczykowski?= <maze@google.com>
To: =?UTF-8?q?Maciej=20=C5=BBenczykowski?= <maze@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:60229 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753125Ab1KVUfE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2011 15:35:04 -0500
Received: by ggnr5 with SMTP id r5so646595ggn.19
        for <netdev@vger.kernel.org>; Tue, 22 Nov 2011 12:35:03 -0800 (PST)
In-Reply-To: <CAHo-OozdBn5jBNsRVzbCnmxozquJnTAYa0bNbK5VoaiKaK=7qQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Maciej =C5=BBenczykowski <maze@google.com>

When loopback mode is forced on interface, and if the carrier check ret=
urns
negative, then force carrier check positive.  This is useful when inter=
face
does not have carrier and test puts the interface in loopback mode.

While we're at it rework the code to fix other bugs in it.
---
 drivers/net/ethernet/intel/e1000e/e1000.h   |    4 +-
 drivers/net/ethernet/intel/e1000e/ich8lan.c |    4 +-
 drivers/net/ethernet/intel/e1000e/lib.c     |    2 +-
 drivers/net/ethernet/intel/e1000e/phy.c     |   98 +++++++++++++++++--=
--------
 4 files changed, 68 insertions(+), 40 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/e1000.h b/drivers/net/et=
hernet/intel/e1000e/e1000.h
index 9fe18d1..93ffc39 100644
--- a/drivers/net/ethernet/intel/e1000e/e1000.h
+++ b/drivers/net/ethernet/intel/e1000e/e1000.h
@@ -620,8 +620,8 @@ extern s32 e1000e_write_kmrn_reg_locked(struct e100=
0_hw *hw, u32 offset,
 extern s32 e1000e_read_kmrn_reg(struct e1000_hw *hw, u32 offset, u16 *=
data);
 extern s32 e1000e_read_kmrn_reg_locked(struct e1000_hw *hw, u32 offset=
,
                                        u16 *data);
-extern s32 e1000e_phy_has_link_generic(struct e1000_hw *hw, u32 iterat=
ions,
-			       u32 usec_interval, bool *success);
+extern s32 e1000e_phy_has_link_generic(struct e1000_hw *hw, int interv=
als,
+			       u32 usec_interval, bool *link);
 extern s32 e1000e_phy_reset_dsp(struct e1000_hw *hw);
 extern void e1000_power_up_phy_copper(struct e1000_hw *hw);
 extern void e1000_power_down_phy_copper(struct e1000_hw *hw);
diff --git a/drivers/net/ethernet/intel/e1000e/ich8lan.c b/drivers/net/=
ethernet/intel/e1000e/ich8lan.c
index e2a80a2..955cd8c 100644
--- a/drivers/net/ethernet/intel/e1000e/ich8lan.c
+++ b/drivers/net/ethernet/intel/e1000e/ich8lan.c
@@ -681,7 +681,7 @@ static s32 e1000_check_for_copper_link_ich8lan(stru=
ct e1000_hw *hw)
 	 * link.  If so, then we want to get the current speed/duplex
 	 * of the PHY.
 	 */
-	ret_val =3D e1000e_phy_has_link_generic(hw, 1, 0, &link);
+	ret_val =3D e1000e_phy_has_link_generic(hw, 0, 0, &link);
 	if (ret_val)
 		goto out;
=20
@@ -3527,7 +3527,7 @@ static s32 e1000_kmrn_lock_loss_workaround_ich8la=
n(struct e1000_hw *hw)
 	 * Attempting this while link is negotiating fouled up link
 	 * stability
 	 */
-	ret_val =3D e1000e_phy_has_link_generic(hw, 1, 0, &link);
+	ret_val =3D e1000e_phy_has_link_generic(hw, 0, 0, &link);
 	if (!link)
 		return 0;
=20
diff --git a/drivers/net/ethernet/intel/e1000e/lib.c b/drivers/net/ethe=
rnet/intel/e1000e/lib.c
index 0893ab1..e9b9e52 100644
--- a/drivers/net/ethernet/intel/e1000e/lib.c
+++ b/drivers/net/ethernet/intel/e1000e/lib.c
@@ -456,7 +456,7 @@ s32 e1000e_check_for_copper_link(struct e1000_hw *h=
w)
 	 * link.  If so, then we want to get the current speed/duplex
 	 * of the PHY.
 	 */
-	ret_val =3D e1000e_phy_has_link_generic(hw, 1, 0, &link);
+	ret_val =3D e1000e_phy_has_link_generic(hw, 0, 0, &link);
 	if (ret_val)
 		return ret_val;
=20
diff --git a/drivers/net/ethernet/intel/e1000e/phy.c b/drivers/net/ethe=
rnet/intel/e1000e/phy.c
index 8666476..f026cba 100644
--- a/drivers/net/ethernet/intel/e1000e/phy.c
+++ b/drivers/net/ethernet/intel/e1000e/phy.c
@@ -1768,46 +1768,74 @@ static s32 e1000_wait_autoneg(struct e1000_hw *=
hw)
 /**
  *  e1000e_phy_has_link_generic - Polls PHY for link
  *  @hw: pointer to the HW structure
- *  @iterations: number of times to poll for link
+ *  @intervals: number of times to delay between polls for link
  *  @usec_interval: delay between polling attempts
- *  @success: pointer to whether polling was successful or not
+ *  @link: pointer to whether link was present or not
  *
- *  Polls the PHY status register for link, 'iterations' number of tim=
es.
+ *  Polls the PHY status register for link, 'intervals + 1' number of =
times.
+ *  Max run time is approx 'intervals * usec_interval' microseconds.
  **/
-s32 e1000e_phy_has_link_generic(struct e1000_hw *hw, u32 iterations,
-			       u32 usec_interval, bool *success)
+s32 e1000e_phy_has_link_generic(struct e1000_hw *hw, int intervals,
+				u32 usec_interval, bool *link)
 {
-	s32 ret_val =3D 0;
-	u16 i, phy_status;
+	int good_reads_phy_status =3D 0;
+	bool loopback_checked =3D false;
+	s32 err;
+	u16 reg;
+
+	/* Remember that e1e_rphy may fail because of another entity
+	 * (like the firmware) holding the lock, we need to handle
+	 * this gracefully - by waiting and trying again.
+	 *
+	 * Some PHYs require the PHY_STATUS register to be
+	 * read twice due to the link bit being sticky.
+	 * No harm doing it across the board.
+	 *
+	 * This first initial read slightly improves the probability of
+	 * a successful double read of the PHY_STATUS on the first iteration.
+	 * (and thus also whenever this function is called with iterations =3D=
=3D 0)
+	 */
+	err =3D e1e_rphy(hw, PHY_STATUS, &reg);
+	if (!err) ++good_reads_phy_status;
+
+	for (;;) {
+		err =3D e1e_rphy(hw, PHY_STATUS, &reg);
+		if (!err) {
+			if (++good_reads_phy_status < 2) continue;
+			if (reg & MII_SR_LINK_STATUS) {
+				*link =3D true;
+				return 0; /* success: link up */
+			}
+		}
+
+		if (!loopback_checked) {
+			/* If the interface is in loopback-mode... */
+			err =3D e1e_rphy(hw, PHY_CONTROL, &reg);
+			if (!err) {
+				loopback_checked =3D true;
+				if (reg & MII_CR_LOOPBACK) {
+					/* ... fake link up. */
+					*link =3D true;
+					return 0; /* success: link up */
+				}
+			}
+		}
+
+		if (--intervals < 0) {
+			/* timeout waiting for link to go up (or only errors) */
+			if (good_reads_phy_status < 2) {
+				if (!err) err =3D -E1000_ERR_PHY;
+				return err; /* failure */
+			}
+			*link =3D false;
+			return 0; /* success: link down */
+		}
=20
-	for (i =3D 0; i < iterations; i++) {
-		/*
-		 * Some PHYs require the PHY_STATUS register to be read
-		 * twice due to the link bit being sticky.  No harm doing
-		 * it across the board.
-		 */
-		ret_val =3D e1e_rphy(hw, PHY_STATUS, &phy_status);
-		if (ret_val)
-			/*
-			 * If the first read fails, another entity may have
-			 * ownership of the resources, wait and try again to
-			 * see if they have relinquished the resources yet.
-			 */
-			udelay(usec_interval);
-		ret_val =3D e1e_rphy(hw, PHY_STATUS, &phy_status);
-		if (ret_val)
-			break;
-		if (phy_status & MII_SR_LINK_STATUS)
-			break;
 		if (usec_interval >=3D 1000)
-			mdelay(usec_interval/1000);
+			mdelay(usec_interval / 1000);
 		else
 			udelay(usec_interval);
 	}
-
-	*success =3D (i < iterations);
-
-	return ret_val;
 }
=20
 /**
@@ -1943,7 +1971,7 @@ s32 e1000e_get_phy_info_m88(struct e1000_hw *hw)
 		return -E1000_ERR_CONFIG;
 	}
=20
-	ret_val =3D e1000e_phy_has_link_generic(hw, 1, 0, &link);
+	ret_val =3D e1000e_phy_has_link_generic(hw, 0, 0, &link);
 	if (ret_val)
 		return ret_val;
=20
@@ -2011,7 +2039,7 @@ s32 e1000e_get_phy_info_igp(struct e1000_hw *hw)
 	u16 data;
 	bool link;
=20
-	ret_val =3D e1000e_phy_has_link_generic(hw, 1, 0, &link);
+	ret_val =3D e1000e_phy_has_link_generic(hw, 0, 0, &link);
 	if (ret_val)
 		return ret_val;
=20
@@ -2071,7 +2099,7 @@ s32 e1000_get_phy_info_ife(struct e1000_hw *hw)
 	u16 data;
 	bool link;
=20
-	ret_val =3D e1000e_phy_has_link_generic(hw, 1, 0, &link);
+	ret_val =3D e1000e_phy_has_link_generic(hw, 0, 0, &link);
 	if (ret_val)
 		goto out;
=20
@@ -3298,7 +3326,7 @@ s32 e1000_get_phy_info_82577(struct e1000_hw *hw)
 	u16 data;
 	bool link;
=20
-	ret_val =3D e1000e_phy_has_link_generic(hw, 1, 0, &link);
+	ret_val =3D e1000e_phy_has_link_generic(hw, 0, 0, &link);
 	if (ret_val)
 		goto out;
=20
--=20
1.7.3.1
