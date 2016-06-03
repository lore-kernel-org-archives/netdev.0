From: Guenter Roeck <linux-0h96xk9xTtrk1uMJSBkQmQ@public.gmane.org>
Subject: [PATCH] b43: Remove unused phy_a code
Date: Fri,  3 Jun 2016 14:32:46 -0700
Message-ID: <1464989566-1393-1-git-send-email-linux@roeck-us.net>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b43-dev-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Guenter Roeck <linux-0h96xk9xTtrk1uMJSBkQmQ@public.gmane.org>
To: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

gcc-6 reports the following error with -Werror=unused-const-variable.

drivers/net/wireless/broadcom/b43/phy_a.c:576:40: error:
	'b43_phyops_a' defined but not used

Turns out a lot of code in this file is unused, so let's remove it.

Reported-by: Fengguang Wu <fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org> [0-day test robot]
Signed-off-by: Guenter Roeck <linux-0h96xk9xTtrk1uMJSBkQmQ@public.gmane.org>
---
 drivers/net/wireless/broadcom/b43/phy_a.c | 298 ------------------------------
 1 file changed, 298 deletions(-)

diff --git a/drivers/net/wireless/broadcom/b43/phy_a.c b/drivers/net/wireless/broadcom/b43/phy_a.c
index 99c036f5ecb7..d9212dc276d0 100644
--- a/drivers/net/wireless/broadcom/b43/phy_a.c
+++ b/drivers/net/wireless/broadcom/b43/phy_a.c
@@ -60,25 +60,6 @@ static inline u16 freq_r3A_value(u16 frequency)
 	return value;
 }
 
-#if 0
-/* This function converts a TSSI value to dBm in Q5.2 */
-static s8 b43_aphy_estimate_power_out(struct b43_wldev *dev, s8 tssi)
-{
-	struct b43_phy *phy = &dev->phy;
-	struct b43_phy_a *aphy = phy->a;
-	s8 dbm = 0;
-	s32 tmp;
-
-	tmp = (aphy->tgt_idle_tssi - aphy->cur_idle_tssi + tssi);
-	tmp += 0x80;
-	tmp = clamp_val(tmp, 0x00, 0xFF);
-	dbm = aphy->tssi2dbm[tmp];
-	//TODO: There's a FIXME on the specs
-
-	return dbm;
-}
-#endif
-
 static void b43_radio_set_tx_iq(struct b43_wldev *dev)
 {
 	static const u8 data_high[5] = { 0x00, 0x40, 0x80, 0x90, 0xD0 };
@@ -314,282 +295,3 @@ void b43_phy_inita(struct b43_wldev *dev)
 		b43_phy_maskset(dev, B43_PHY_OFDM(0x6E), 0xE000, 0x3CF);
 	}
 }
-
-/* Initialise the TSSI->dBm lookup table */
-static int b43_aphy_init_tssi2dbm_table(struct b43_wldev *dev)
-{
-	struct b43_phy *phy = &dev->phy;
-	struct b43_phy_a *aphy = phy->a;
-	s16 pab0, pab1, pab2;
-
-	pab0 = (s16) (dev->dev->bus_sprom->pa1b0);
-	pab1 = (s16) (dev->dev->bus_sprom->pa1b1);
-	pab2 = (s16) (dev->dev->bus_sprom->pa1b2);
-
-	if (pab0 != 0 && pab1 != 0 && pab2 != 0 &&
-	    pab0 != -1 && pab1 != -1 && pab2 != -1) {
-		/* The pabX values are set in SPROM. Use them. */
-		if ((s8) dev->dev->bus_sprom->itssi_a != 0 &&
-		    (s8) dev->dev->bus_sprom->itssi_a != -1)
-			aphy->tgt_idle_tssi =
-			    (s8) (dev->dev->bus_sprom->itssi_a);
-		else
-			aphy->tgt_idle_tssi = 62;
-		aphy->tssi2dbm = b43_generate_dyn_tssi2dbm_tab(dev, pab0,
-							       pab1, pab2);
-		if (!aphy->tssi2dbm)
-			return -ENOMEM;
-	} else {
-		/* pabX values not set in SPROM,
-		 * but APHY needs a generated table. */
-		aphy->tssi2dbm = NULL;
-		b43err(dev->wl, "Could not generate tssi2dBm "
-		       "table (wrong SPROM info)!\n");
-		return -ENODEV;
-	}
-
-	return 0;
-}
-
-static int b43_aphy_op_allocate(struct b43_wldev *dev)
-{
-	struct b43_phy_a *aphy;
-	int err;
-
-	aphy = kzalloc(sizeof(*aphy), GFP_KERNEL);
-	if (!aphy)
-		return -ENOMEM;
-	dev->phy.a = aphy;
-
-	err = b43_aphy_init_tssi2dbm_table(dev);
-	if (err)
-		goto err_free_aphy;
-
-	return 0;
-
-err_free_aphy:
-	kfree(aphy);
-	dev->phy.a = NULL;
-
-	return err;
-}
-
-static void b43_aphy_op_prepare_structs(struct b43_wldev *dev)
-{
-	struct b43_phy *phy = &dev->phy;
-	struct b43_phy_a *aphy = phy->a;
-	const void *tssi2dbm;
-	int tgt_idle_tssi;
-
-	/* tssi2dbm table is constant, so it is initialized at alloc time.
-	 * Save a copy of the pointer. */
-	tssi2dbm = aphy->tssi2dbm;
-	tgt_idle_tssi = aphy->tgt_idle_tssi;
-
-	/* Zero out the whole PHY structure. */
-	memset(aphy, 0, sizeof(*aphy));
-
-	aphy->tssi2dbm = tssi2dbm;
-	aphy->tgt_idle_tssi = tgt_idle_tssi;
-
-	//TODO init struct b43_phy_a
-
-}
-
-static void b43_aphy_op_free(struct b43_wldev *dev)
-{
-	struct b43_phy *phy = &dev->phy;
-	struct b43_phy_a *aphy = phy->a;
-
-	kfree(aphy->tssi2dbm);
-	aphy->tssi2dbm = NULL;
-
-	kfree(aphy);
-	dev->phy.a = NULL;
-}
-
-static int b43_aphy_op_init(struct b43_wldev *dev)
-{
-	b43_phy_inita(dev);
-
-	return 0;
-}
-
-static inline u16 adjust_phyreg(struct b43_wldev *dev, u16 offset)
-{
-	/* OFDM registers are base-registers for the A-PHY. */
-	if ((offset & B43_PHYROUTE) == B43_PHYROUTE_OFDM_GPHY) {
-		offset &= ~B43_PHYROUTE;
-		offset |= B43_PHYROUTE_BASE;
-	}
-
-#if B43_DEBUG
-	if ((offset & B43_PHYROUTE) == B43_PHYROUTE_EXT_GPHY) {
-		/* Ext-G registers are only available on G-PHYs */
-		b43err(dev->wl, "Invalid EXT-G PHY access at "
-		       "0x%04X on A-PHY\n", offset);
-		dump_stack();
-	}
-	if ((offset & B43_PHYROUTE) == B43_PHYROUTE_N_BMODE) {
-		/* N-BMODE registers are only available on N-PHYs */
-		b43err(dev->wl, "Invalid N-BMODE PHY access at "
-		       "0x%04X on A-PHY\n", offset);
-		dump_stack();
-	}
-#endif /* B43_DEBUG */
-
-	return offset;
-}
-
-static u16 b43_aphy_op_read(struct b43_wldev *dev, u16 reg)
-{
-	reg = adjust_phyreg(dev, reg);
-	b43_write16f(dev, B43_MMIO_PHY_CONTROL, reg);
-	return b43_read16(dev, B43_MMIO_PHY_DATA);
-}
-
-static void b43_aphy_op_write(struct b43_wldev *dev, u16 reg, u16 value)
-{
-	reg = adjust_phyreg(dev, reg);
-	b43_write16f(dev, B43_MMIO_PHY_CONTROL, reg);
-	b43_write16(dev, B43_MMIO_PHY_DATA, value);
-}
-
-static u16 b43_aphy_op_radio_read(struct b43_wldev *dev, u16 reg)
-{
-	/* Register 1 is a 32-bit register. */
-	B43_WARN_ON(reg == 1);
-	/* A-PHY needs 0x40 for read access */
-	reg |= 0x40;
-
-	b43_write16(dev, B43_MMIO_RADIO_CONTROL, reg);
-	return b43_read16(dev, B43_MMIO_RADIO_DATA_LOW);
-}
-
-static void b43_aphy_op_radio_write(struct b43_wldev *dev, u16 reg, u16 value)
-{
-	/* Register 1 is a 32-bit register. */
-	B43_WARN_ON(reg == 1);
-
-	b43_write16(dev, B43_MMIO_RADIO_CONTROL, reg);
-	b43_write16(dev, B43_MMIO_RADIO_DATA_LOW, value);
-}
-
-static bool b43_aphy_op_supports_hwpctl(struct b43_wldev *dev)
-{
-	return (dev->phy.rev >= 5);
-}
-
-static void b43_aphy_op_software_rfkill(struct b43_wldev *dev,
-					bool blocked)
-{
-	struct b43_phy *phy = &dev->phy;
-
-	if (!blocked) {
-		if (phy->radio_on)
-			return;
-		b43_radio_write16(dev, 0x0004, 0x00C0);
-		b43_radio_write16(dev, 0x0005, 0x0008);
-		b43_phy_mask(dev, 0x0010, 0xFFF7);
-		b43_phy_mask(dev, 0x0011, 0xFFF7);
-		b43_radio_init2060(dev);
-	} else {
-		b43_radio_write16(dev, 0x0004, 0x00FF);
-		b43_radio_write16(dev, 0x0005, 0x00FB);
-		b43_phy_set(dev, 0x0010, 0x0008);
-		b43_phy_set(dev, 0x0011, 0x0008);
-	}
-}
-
-static int b43_aphy_op_switch_channel(struct b43_wldev *dev,
-				      unsigned int new_channel)
-{
-	if (new_channel > 200)
-		return -EINVAL;
-	aphy_channel_switch(dev, new_channel);
-
-	return 0;
-}
-
-static unsigned int b43_aphy_op_get_default_chan(struct b43_wldev *dev)
-{
-	return 36; /* Default to channel 36 */
-}
-
-static void b43_aphy_op_set_rx_antenna(struct b43_wldev *dev, int antenna)
-{//TODO
-	struct b43_phy *phy = &dev->phy;
-	u16 tmp;
-	int autodiv = 0;
-
-	if (antenna == B43_ANTENNA_AUTO0 || antenna == B43_ANTENNA_AUTO1)
-		autodiv = 1;
-
-	b43_hf_write(dev, b43_hf_read(dev) & ~B43_HF_ANTDIVHELP);
-
-	b43_phy_maskset(dev, B43_PHY_BBANDCFG, ~B43_PHY_BBANDCFG_RXANT,
-			(autodiv ? B43_ANTENNA_AUTO1 : antenna) <<
-			B43_PHY_BBANDCFG_RXANT_SHIFT);
-
-	if (autodiv) {
-		tmp = b43_phy_read(dev, B43_PHY_ANTDWELL);
-		if (antenna == B43_ANTENNA_AUTO1)
-			tmp &= ~B43_PHY_ANTDWELL_AUTODIV1;
-		else
-			tmp |= B43_PHY_ANTDWELL_AUTODIV1;
-		b43_phy_write(dev, B43_PHY_ANTDWELL, tmp);
-	}
-	if (phy->rev < 3)
-		b43_phy_maskset(dev, B43_PHY_ANTDWELL, 0xFF00, 0x24);
-	else {
-		b43_phy_set(dev, B43_PHY_OFDM61, 0x10);
-		if (phy->rev == 3) {
-			b43_phy_write(dev, B43_PHY_CLIPPWRDOWNT, 0x1D);
-			b43_phy_write(dev, B43_PHY_ADIVRELATED, 8);
-		} else {
-			b43_phy_write(dev, B43_PHY_CLIPPWRDOWNT, 0x3A);
-			b43_phy_maskset(dev, B43_PHY_ADIVRELATED, 0xFF00, 8);
-		}
-	}
-
-	b43_hf_write(dev, b43_hf_read(dev) | B43_HF_ANTDIVHELP);
-}
-
-static void b43_aphy_op_adjust_txpower(struct b43_wldev *dev)
-{//TODO
-}
-
-static enum b43_txpwr_result b43_aphy_op_recalc_txpower(struct b43_wldev *dev,
-							bool ignore_tssi)
-{//TODO
-	return B43_TXPWR_RES_DONE;
-}
-
-static void b43_aphy_op_pwork_15sec(struct b43_wldev *dev)
-{//TODO
-}
-
-static void b43_aphy_op_pwork_60sec(struct b43_wldev *dev)
-{//TODO
-}
