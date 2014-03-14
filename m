From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next 02/10] e1000e: add timeout for TX HW time
 stamping work
Date: Fri, 14 Mar 2014 12:14:50 -0700
Message-ID: <1394824490.3253.11.camel@joe-AO722>
References: <1394818481-7652-1-git-send-email-kubakici@wp.pl>
	 <1394818481-7652-3-git-send-email-kubakici@wp.pl>
	 <1394819317.3253.3.camel@joe-AO722> <20140314190242.4bba2b42@north>
	 <1394822655.3253.7.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net
To: Jakub =?UTF-8?Q?Kici=C5=84ski?= <moorray3@wp.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0089.hostedemail.com ([216.40.44.89]:58247 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754113AbaCNTOz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Mar 2014 15:14:55 -0400
In-Reply-To: <1394822655.3253.7.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-03-14 at 11:44 -0700, Joe Perches wrote:
> On Fri, 2014-03-14 at 19:02 +0100, Jakub Kici=C5=84ski wrote:
> > On Fri, 14 Mar 2014 10:48:37 -0700, Joe Perches wrote:
> > > On Fri, 2014-03-14 at 18:34 +0100, Jakub Kicinski wrote:
> > > > Hardware may fail to report time stamp e.g.:
> > > >  - when hardware time stamping is not enabled
> > > >  - when time stamp is requested shortly after ifup
> > >=20
> > > trivia:
> > >=20
> > > > diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drive=
rs/net/ethernet/intel/e1000e/netdev.c
> > > []
> > > > @@ -1155,6 +1155,12 @@ static void e1000e_tx_hwtstamp_work(stru=
ct work_struct *work)
> > > >  		skb_tstamp_tx(adapter->tx_hwtstamp_skb, &shhwtstamps);
> > > >  		dev_kfree_skb_any(adapter->tx_hwtstamp_skb);
> > > >  		adapter->tx_hwtstamp_skb =3D NULL;
> > > > +	} else if (time_after(jiffies, adapter->tx_hwtstamp_start
> > > > +			      + adapter->tx_timeout_factor * HZ)) {
> > > > +		dev_kfree_skb_any(adapter->tx_hwtstamp_skb);
> > > > +		adapter->tx_hwtstamp_skb =3D NULL;
> > > > +		adapter->tx_hwtstamp_timeouts++;
> > > > +		e_warn("clearing Tx timestamp hang");
> > >=20
> > > Missing \n termination
> >=20
> > I copied that line from ixgbe and assumed that the magic macro adds
> > termination...
> >=20
> > I see that igb and i40e also lack the \n on similar messages.
>=20
> There's a bunch of them.
>=20
> >  Can I fix
> > them all in a single follow-up patch?
>=20
> There are also a bunch of _dbg messages that lack that
> \n and those seem to be function tracing uses that should
> just be deleted.

Maybe something this

Add missing newlines to e_<level> uses
Coalesce formats, add missing spaces to coalesced formats
Align arguments
Remove function tracing uses of e_dbg
Remove some unnecessary parentheses in these e_<level>
=46ix speed/duplex debugging messages
Remove unnecessary periods

---
 drivers/net/ethernet/intel/e1000/e1000_ethtool.c |  20 +--
 drivers/net/ethernet/intel/e1000/e1000_hw.c      | 202 ++++-----------=
--------
 drivers/net/ethernet/intel/e1000/e1000_main.c    |  21 +--
 drivers/net/ethernet/intel/e1000e/80003es2lan.c  |   8 +-
 drivers/net/ethernet/intel/e1000e/82571.c        |   6 +-
 drivers/net/ethernet/intel/e1000e/ethtool.c      |   8 +-
 drivers/net/ethernet/intel/e1000e/ich8lan.c      |  18 +-
 drivers/net/ethernet/intel/e1000e/mac.c          |  48 +++---
 drivers/net/ethernet/intel/e1000e/manage.c       |   6 +-
 drivers/net/ethernet/intel/e1000e/netdev.c       |  14 +-
 drivers/net/ethernet/intel/e1000e/nvm.c          |   4 +-
 drivers/net/ethernet/intel/e1000e/phy.c          |  27 ++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c |  24 ++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c    |   4 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    |  52 +++---
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c     |   2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c     |   4 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c   |   3 +-
 18 files changed, 155 insertions(+), 316 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000/e1000_ethtool.c b/drivers=
/net/ethernet/intel/e1000/e1000_ethtool.c
index 73a8aee..056fb2c 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_ethtool.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_ethtool.c
@@ -690,8 +690,7 @@ static bool reg_pattern_test(struct e1000_adapter *=
adapter, u64 *data, int reg,
 		writel(write & test[i], address);
 		read =3D readl(address);
 		if (read !=3D (write & test[i] & mask)) {
-			e_err(drv, "pattern test reg %04X failed: "
-			      "got 0x%08X expected 0x%08X\n",
+			e_err(drv, "pattern test reg %04X failed: got 0x%08X expected 0x%08=
X\n",
 			      reg, read, (write & test[i] & mask));
 			*data =3D reg;
 			return true;
@@ -710,8 +709,7 @@ static bool reg_set_and_check(struct e1000_adapter =
*adapter, u64 *data, int reg,
 	writel(write & mask, address);
 	read =3D readl(address);
 	if ((read & mask) !=3D (write & mask)) {
-		e_err(drv, "set/check reg %04X test failed: "
-		      "got 0x%08X expected 0x%08X\n",
+		e_err(drv, "set/check reg %04X test failed: got 0x%08X expected 0x%0=
8X\n",
 		      reg, (read & mask), (write & mask));
 		*data =3D reg;
 		return true;
@@ -755,8 +753,8 @@ static int e1000_reg_test(struct e1000_adapter *ada=
pter, u64 *data)
 	ew32(STATUS, toggle);
 	after =3D er32(STATUS) & toggle;
 	if (value !=3D after) {
-		e_err(drv, "failed STATUS register test got: "
-		      "0x%08X expected: 0x%08X\n", after, value);
+		e_err(drv, "failed STATUS register test got: 0x%08X expected: 0x%08X=
\n",
+		      after, value);
 		*data =3D 1;
 		return 1;
 	}
@@ -867,8 +865,8 @@ static int e1000_intr_test(struct e1000_adapter *ad=
apter, u64 *data)
 		*data =3D 1;
 		return -1;
 	}
-	e_info(hw, "testing %s interrupt\n", (shared_int ?
-	       "shared" : "unshared"));
+	e_info(hw, "testing %s interrupt\n",
+	       shared_int ? "shared" : "unshared");
=20
 	/* Disable all the interrupts */
 	ew32(IMC, 0xFFFFFFFF);
@@ -1685,8 +1683,7 @@ static void e1000_get_wol(struct net_device *netd=
ev,
 		wol->supported &=3D ~WAKE_UCAST;
=20
 		if (adapter->wol & E1000_WUFC_EX)
-			e_err(drv, "Interface does not support directed "
-			      "(unicast) frame wake-up packets\n");
+			e_err(drv, "Interface does not support directed (unicast) frame wak=
e-up packets\n");
 		break;
 	default:
 		break;
@@ -1717,8 +1714,7 @@ static int e1000_set_wol(struct net_device *netde=
v, struct ethtool_wolinfo *wol)
 	switch (hw->device_id) {
 	case E1000_DEV_ID_82546GB_QUAD_COPPER_KSP3:
 		if (wol->wolopts & WAKE_UCAST) {
-			e_err(drv, "Interface does not support directed "
-			      "(unicast) frame wake-up packets\n");
+			e_err(drv, "Interface does not support directed (unicast) frame wak=
e-up packets\n");
 			return -EOPNOTSUPP;
 		}
 		break;
diff --git a/drivers/net/ethernet/intel/e1000/e1000_hw.c b/drivers/net/=
ethernet/intel/e1000/e1000_hw.c
index 2879b96..832ecf7 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_hw.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_hw.c
@@ -115,8 +115,6 @@ static DEFINE_SPINLOCK(e1000_phy_lock);
  */
 static s32 e1000_set_phy_type(struct e1000_hw *hw)
 {
-	e_dbg("e1000_set_phy_type");
-
 	if (hw->mac_type =3D=3D e1000_undefined)
 		return -E1000_ERR_PHY_TYPE;
=20
@@ -159,8 +157,6 @@ static void e1000_phy_init_script(struct e1000_hw *=
hw)
 	u32 ret_val;
 	u16 phy_saved_data;
=20
-	e_dbg("e1000_phy_init_script");
-
 	if (hw->phy_init_script) {
 		msleep(20);
=20
@@ -253,8 +249,6 @@ static void e1000_phy_init_script(struct e1000_hw *=
hw)
  */
 s32 e1000_set_mac_type(struct e1000_hw *hw)
 {
-	e_dbg("e1000_set_mac_type");
-
 	switch (hw->device_id) {
 	case E1000_DEV_ID_82542:
 		switch (hw->revision_id) {
@@ -365,8 +359,6 @@ void e1000_set_media_type(struct e1000_hw *hw)
 {
 	u32 status;
=20
-	e_dbg("e1000_set_media_type");
-
 	if (hw->mac_type !=3D e1000_82543) {
 		/* tbi_compatibility is only valid on 82543 */
 		hw->tbi_compatibility_en =3D false;
@@ -415,8 +407,6 @@ s32 e1000_reset_hw(struct e1000_hw *hw)
 	u32 led_ctrl;
 	s32 ret_val;
=20
-	e_dbg("e1000_reset_hw");
-
 	/* For 82542 (rev 2.0), disable MWI before issuing a device reset */
 	if (hw->mac_type =3D=3D e1000_82542_rev2_0) {
 		e_dbg("Disabling MWI on 82542 rev 2.0\n");
@@ -566,8 +556,6 @@ s32 e1000_init_hw(struct e1000_hw *hw)
 	u32 mta_size;
 	u32 ctrl_ext;
=20
-	e_dbg("e1000_init_hw");
-
 	/* Initialize Identification LED */
 	ret_val =3D e1000_id_led_init(hw);
 	if (ret_val) {
@@ -683,8 +671,6 @@ static s32 e1000_adjust_serdes_amplitude(struct e10=
00_hw *hw)
 	u16 eeprom_data;
 	s32 ret_val;
=20
-	e_dbg("e1000_adjust_serdes_amplitude");
-
 	if (hw->media_type !=3D e1000_media_type_internal_serdes)
 		return E1000_SUCCESS;
=20
@@ -730,8 +716,6 @@ s32 e1000_setup_link(struct e1000_hw *hw)
 	s32 ret_val;
 	u16 eeprom_data;
=20
-	e_dbg("e1000_setup_link");
-
 	/* Read and store word 0x0F of the EEPROM. This word contains bits
 	 * that determine the hardware's default PAUSE (flow control) mode,
 	 * a bit that determines whether the HW defaults to enabling or
@@ -848,8 +832,6 @@ static s32 e1000_setup_fiber_serdes_link(struct e10=
00_hw *hw)
 	u32 signal =3D 0;
 	s32 ret_val;
=20
-	e_dbg("e1000_setup_fiber_serdes_link");
-
 	/* On adapters with a MAC newer than 82544, SWDP 1 will be
 	 * set when the optics detect a signal. On older adapters, it will be
 	 * cleared when there is a signal.  This applies to fiber media only.
@@ -1051,8 +1033,6 @@ static s32 e1000_copper_link_preconfig(struct e10=
00_hw *hw)
 	s32 ret_val;
 	u16 phy_data;
=20
-	e_dbg("e1000_copper_link_preconfig");
-
 	ctrl =3D er32(CTRL);
 	/* With 82543, we need to force speed and duplex on the MAC equal to
 	 * what the PHY speed and duplex configuration is. In addition, we ne=
ed
@@ -1074,7 +1054,7 @@ static s32 e1000_copper_link_preconfig(struct e10=
00_hw *hw)
 	/* Make sure we have a valid PHY */
 	ret_val =3D e1000_detect_gig_phy(hw);
 	if (ret_val) {
-		e_dbg("Error, did not detect valid phy.\n");
+		e_dbg("Error, did not detect valid phy\n");
 		return ret_val;
 	}
 	e_dbg("Phy ID =3D %x\n", hw->phy_id);
@@ -1112,8 +1092,6 @@ static s32 e1000_copper_link_igp_setup(struct e10=
00_hw *hw)
 	s32 ret_val;
 	u16 phy_data;
=20
-	e_dbg("e1000_copper_link_igp_setup");
-
 	if (hw->phy_reset_disable)
 		return E1000_SUCCESS;
=20
@@ -1254,8 +1232,6 @@ static s32 e1000_copper_link_mgp_setup(struct e10=
00_hw *hw)
 	s32 ret_val;
 	u16 phy_data;
=20
-	e_dbg("e1000_copper_link_mgp_setup");
-
 	if (hw->phy_reset_disable)
 		return E1000_SUCCESS;
=20
@@ -1362,8 +1338,6 @@ static s32 e1000_copper_link_autoneg(struct e1000=
_hw *hw)
 	s32 ret_val;
 	u16 phy_data;
=20
-	e_dbg("e1000_copper_link_autoneg");
-
 	/* Perform some bounds checking on the hw->autoneg_advertised
 	 * parameter.  If this variable is zero, then set it to the default.
 	 */
@@ -1405,8 +1379,7 @@ static s32 e1000_copper_link_autoneg(struct e1000=
_hw *hw)
 	if (hw->wait_autoneg_complete) {
 		ret_val =3D e1000_wait_autoneg(hw);
 		if (ret_val) {
-			e_dbg
-			    ("Error while waiting for autoneg to complete\n");
+			e_dbg("Error while waiting for autoneg to complete\n");
 			return ret_val;
 		}
 	}
@@ -1432,7 +1405,6 @@ static s32 e1000_copper_link_autoneg(struct e1000=
_hw *hw)
 static s32 e1000_copper_link_postconfig(struct e1000_hw *hw)
 {
 	s32 ret_val;
-	e_dbg("e1000_copper_link_postconfig");
=20
 	if ((hw->mac_type >=3D e1000_82544) && (hw->mac_type !=3D e1000_ce410=
0)) {
 		e1000_config_collision_dist(hw);
@@ -1473,8 +1445,6 @@ static s32 e1000_setup_copper_link(struct e1000_h=
w *hw)
 	u16 i;
 	u16 phy_data;
=20
-	e_dbg("e1000_setup_copper_link");
-
 	/* Check if it is a valid PHY and set PHY mode if necessary. */
 	ret_val =3D e1000_copper_link_preconfig(hw);
 	if (ret_val)
@@ -1554,8 +1524,6 @@ s32 e1000_phy_setup_autoneg(struct e1000_hw *hw)
 	u16 mii_autoneg_adv_reg;
 	u16 mii_1000t_ctrl_reg;
=20
-	e_dbg("e1000_phy_setup_autoneg");
-
 	/* Read the MII Auto-Neg Advertisement Register (Address 4). */
 	ret_val =3D e1000_read_phy_reg(hw, PHY_AUTONEG_ADV, &mii_autoneg_adv_=
reg);
 	if (ret_val)
@@ -1610,8 +1578,7 @@ s32 e1000_phy_setup_autoneg(struct e1000_hw *hw)
=20
 	/* We do not allow the Phy to advertise 1000 Mb Half Duplex */
 	if (hw->autoneg_advertised & ADVERTISE_1000_HALF) {
-		e_dbg
-		    ("Advertise 1000mb Half duplex requested, request denied!\n");
+		e_dbg("Advertise 1000mb Half duplex requested, request denied!\n");
 	}
=20
 	/* Do we want to advertise 1000 Mb Full Duplex? */
@@ -1707,8 +1674,6 @@ static s32 e1000_phy_force_speed_duplex(struct e1=
000_hw *hw)
 	u16 phy_data;
 	u16 i;
=20
-	e_dbg("e1000_phy_force_speed_duplex");
-
 	/* Turn off Flow control if we are forcing speed and duplex. */
 	hw->fc =3D E1000_FC_NONE;
=20
@@ -1758,13 +1723,13 @@ static s32 e1000_phy_force_speed_duplex(struct =
e1000_hw *hw)
 		ctrl |=3D E1000_CTRL_SPD_100;
 		mii_ctrl_reg |=3D MII_CR_SPEED_100;
 		mii_ctrl_reg &=3D ~(MII_CR_SPEED_1000 | MII_CR_SPEED_10);
-		e_dbg("Forcing 100mb ");
+		e_dbg("Forcing 100mb\n");
 	} else {
 		/* Set the 10Mb bit and turn off the 1000Mb and 100Mb bits. */
 		ctrl &=3D ~(E1000_CTRL_SPD_1000 | E1000_CTRL_SPD_100);
 		mii_ctrl_reg |=3D MII_CR_SPEED_10;
 		mii_ctrl_reg &=3D ~(MII_CR_SPEED_1000 | MII_CR_SPEED_100);
-		e_dbg("Forcing 10mb ");
+		e_dbg("Forcing 10mb\n");
 	}
=20
 	e1000_config_collision_dist(hw);
@@ -1827,7 +1792,7 @@ static s32 e1000_phy_force_speed_duplex(struct e1=
000_hw *hw)
 	 */
 	if (hw->wait_autoneg_complete) {
 		/* We will wait for autoneg to complete. */
-		e_dbg("Waiting for forced speed/duplex link.\n");
+		e_dbg("Waiting for forced speed/duplex link\n");
 		mii_status_reg =3D 0;
=20
 		/* Wait for autoneg to complete or 4.5 seconds to expire */
@@ -1939,8 +1904,6 @@ void e1000_config_collision_dist(struct e1000_hw =
*hw)
 {
 	u32 tctl, coll_dist;
=20
-	e_dbg("e1000_config_collision_dist");
-
 	if (hw->mac_type < e1000_82543)
 		coll_dist =3D E1000_COLLISION_DISTANCE_82542;
 	else
@@ -1970,8 +1933,6 @@ static s32 e1000_config_mac_to_phy(struct e1000_h=
w *hw)
 	s32 ret_val;
 	u16 phy_data;
=20
-	e_dbg("e1000_config_mac_to_phy");
-
 	/* 82544 or newer MAC, Auto Speed Detection takes care of
 	 * MAC speed/duplex configuration.
 	 */
@@ -2049,8 +2010,6 @@ s32 e1000_force_mac_fc(struct e1000_hw *hw)
 {
 	u32 ctrl;
=20
-	e_dbg("e1000_force_mac_fc");
-
 	/* Get the current configuration of the Device Control Register */
 	ctrl =3D er32(CTRL);
=20
@@ -2120,8 +2079,6 @@ static s32 e1000_config_fc_after_link_up(struct e=
1000_hw *hw)
 	u16 speed;
 	u16 duplex;
=20
-	e_dbg("e1000_config_fc_after_link_up");
-
 	/* Check for the case where we have fiber media and auto-neg failed
 	 * so we had to force link.  In this case, we need to force the
 	 * configuration of the MAC to match the "fc" parameter.
@@ -2217,11 +2174,10 @@ static s32 e1000_config_fc_after_link_up(struct=
 e1000_hw *hw)
 				 */
 				if (hw->original_fc =3D=3D E1000_FC_FULL) {
 					hw->fc =3D E1000_FC_FULL;
-					e_dbg("Flow Control =3D FULL.\n");
+					e_dbg("Flow Control =3D FULL\n");
 				} else {
 					hw->fc =3D E1000_FC_RX_PAUSE;
-					e_dbg
-					    ("Flow Control =3D RX PAUSE frames only.\n");
+					e_dbg("Flow Control =3D RX PAUSE frames only\n");
 				}
 			}
 			/* For receiving PAUSE frames ONLY.
@@ -2238,8 +2194,7 @@ static s32 e1000_config_fc_after_link_up(struct e=
1000_hw *hw)
 				 (mii_nway_lp_ability_reg & NWAY_LPAR_ASM_DIR))
 			{
 				hw->fc =3D E1000_FC_TX_PAUSE;
-				e_dbg
-				    ("Flow Control =3D TX PAUSE frames only.\n");
+				e_dbg("Flow Control =3D TX PAUSE frames only\n");
 			}
 			/* For transmitting PAUSE frames ONLY.
 			 *
@@ -2255,8 +2210,7 @@ static s32 e1000_config_fc_after_link_up(struct e=
1000_hw *hw)
 				 (mii_nway_lp_ability_reg & NWAY_LPAR_ASM_DIR))
 			{
 				hw->fc =3D E1000_FC_RX_PAUSE;
-				e_dbg
-				    ("Flow Control =3D RX PAUSE frames only.\n");
+				e_dbg("Flow Control =3D RX PAUSE frames only\n");
 			}
 			/* Per the IEEE spec, at this point flow control should
 			 * be disabled.  However, we want to consider that we
@@ -2284,11 +2238,10 @@ static s32 e1000_config_fc_after_link_up(struct=
 e1000_hw *hw)
 				  hw->original_fc =3D=3D E1000_FC_TX_PAUSE) ||
 				 hw->fc_strict_ieee) {
 				hw->fc =3D E1000_FC_NONE;
-				e_dbg("Flow Control =3D NONE.\n");
+				e_dbg("Flow Control =3D NONE\n");
 			} else {
 				hw->fc =3D E1000_FC_RX_PAUSE;
-				e_dbg
-				    ("Flow Control =3D RX PAUSE frames only.\n");
+				e_dbg("Flow Control =3D RX PAUSE frames only\n");
 			}
=20
 			/* Now we need to do one last check...  If we auto-
@@ -2298,8 +2251,7 @@ static s32 e1000_config_fc_after_link_up(struct e=
1000_hw *hw)
 			ret_val =3D
 			    e1000_get_speed_and_duplex(hw, &speed, &duplex);
 			if (ret_val) {
-				e_dbg
-				    ("Error getting link speed and duplex\n");
+				e_dbg("Error getting link speed and duplex\n");
 				return ret_val;
 			}
=20
@@ -2311,13 +2263,11 @@ static s32 e1000_config_fc_after_link_up(struct=
 e1000_hw *hw)
 			 */
 			ret_val =3D e1000_force_mac_fc(hw);
 			if (ret_val) {
-				e_dbg
-				    ("Error forcing flow control settings\n");
+				e_dbg("Error forcing flow control settings\n");
 				return ret_val;
 			}
 		} else {
-			e_dbg
-			    ("Copper PHY and Auto Neg has not completed.\n");
+			e_dbg("Copper PHY and Auto Neg has not completed\n");
 		}
 	}
 	return E1000_SUCCESS;
@@ -2337,8 +2287,6 @@ static s32 e1000_check_for_serdes_link_generic(st=
ruct e1000_hw *hw)
 	u32 status;
 	s32 ret_val =3D E1000_SUCCESS;
=20
-	e_dbg("e1000_check_for_serdes_link_generic");
-
 	ctrl =3D er32(CTRL);
 	status =3D er32(STATUS);
 	rxcw =3D er32(RXCW);
@@ -2355,7 +2303,7 @@ static s32 e1000_check_for_serdes_link_generic(st=
ruct e1000_hw *hw)
 			hw->autoneg_failed =3D 1;
 			goto out;
 		}
-		e_dbg("NOT RXing /C/, disable AutoNeg and force link.\n");
+		e_dbg("NOT RXing /C/, disable AutoNeg and force link\n");
=20
 		/* Disable auto-negotiation in the TXCW register */
 		ew32(TXCW, (hw->txcw & ~E1000_TXCW_ANE));
@@ -2377,7 +2325,7 @@ static s32 e1000_check_for_serdes_link_generic(st=
ruct e1000_hw *hw)
 		 * and disable forced link in the Device Control register
 		 * in an attempt to auto-negotiate with our link partner.
 		 */
-		e_dbg("RXing /C/, enable AutoNeg and stop forcing link.\n");
+		e_dbg("RXing /C/, enable AutoNeg and stop forcing link\n");
 		ew32(TXCW, hw->txcw);
 		ew32(CTRL, (ctrl & ~E1000_CTRL_SLU));
=20
@@ -2393,11 +2341,11 @@ static s32 e1000_check_for_serdes_link_generic(=
struct e1000_hw *hw)
 		if (rxcw & E1000_RXCW_SYNCH) {
 			if (!(rxcw & E1000_RXCW_IV)) {
 				hw->serdes_has_link =3D true;
-				e_dbg("SERDES: Link up - forced.\n");
+				e_dbg("SERDES: Link up - forced\n");
 			}
 		} else {
 			hw->serdes_has_link =3D false;
-			e_dbg("SERDES: Link down - force failed.\n");
+			e_dbg("SERDES: Link down - force failed\n");
 		}
 	}
=20
@@ -2410,16 +2358,14 @@ static s32 e1000_check_for_serdes_link_generic(=
struct e1000_hw *hw)
 			if (rxcw & E1000_RXCW_SYNCH) {
 				if (!(rxcw & E1000_RXCW_IV)) {
 					hw->serdes_has_link =3D true;
-					e_dbg("SERDES: Link up - autoneg "
-						 "completed successfully.\n");
+					e_dbg("SERDES: Link up - autoneg completed successfully\n");
 				} else {
 					hw->serdes_has_link =3D false;
-					e_dbg("SERDES: Link down - invalid"
-						 "codewords detected in autoneg.\n");
+					e_dbg("SERDES: Link down - invalid codewords detected in autoneg\=
n");
 				}
 			} else {
 				hw->serdes_has_link =3D false;
-				e_dbg("SERDES: Link down - no sync.\n");
+				e_dbg("SERDES: Link down - no sync\n");
 			}
 		} else {
 			hw->serdes_has_link =3D false;
@@ -2449,8 +2395,6 @@ s32 e1000_check_for_link(struct e1000_hw *hw)
 	s32 ret_val;
 	u16 phy_data;
=20
-	e_dbg("e1000_check_for_link");
-
 	ctrl =3D er32(CTRL);
 	status =3D er32(STATUS);
=20
@@ -2547,8 +2491,7 @@ s32 e1000_check_for_link(struct e1000_hw *hw)
 		else {
 			ret_val =3D e1000_config_mac_to_phy(hw);
 			if (ret_val) {
-				e_dbg
-				    ("Error configuring MAC to PHY settings\n");
+				e_dbg("Error configuring MAC to PHY settings\n");
 				return ret_val;
 			}
 		}
@@ -2577,8 +2520,7 @@ s32 e1000_check_for_link(struct e1000_hw *hw)
 			ret_val =3D
 			    e1000_get_speed_and_duplex(hw, &speed, &duplex);
 			if (ret_val) {
-				e_dbg
-				    ("Error getting link speed and duplex\n");
+				e_dbg("Error getting link speed and duplex\n");
 				return ret_val;
 			}
 			if (speed !=3D SPEED_1000) {
@@ -2632,34 +2574,31 @@ s32 e1000_get_speed_and_duplex(struct e1000_hw =
*hw, u16 *speed, u16 *duplex)
 	s32 ret_val;
 	u16 phy_data;
=20
-	e_dbg("e1000_get_speed_and_duplex");
-
 	if (hw->mac_type >=3D e1000_82543) {
 		status =3D er32(STATUS);
 		if (status & E1000_STATUS_SPEED_1000) {
 			*speed =3D SPEED_1000;
-			e_dbg("1000 Mbs, ");
 		} else if (status & E1000_STATUS_SPEED_100) {
 			*speed =3D SPEED_100;
-			e_dbg("100 Mbs, ");
 		} else {
 			*speed =3D SPEED_10;
-			e_dbg("10 Mbs, ");
 		}
=20
 		if (status & E1000_STATUS_FD) {
 			*duplex =3D FULL_DUPLEX;
-			e_dbg("Full Duplex\n");
 		} else {
 			*duplex =3D HALF_DUPLEX;
-			e_dbg(" Half Duplex\n");
 		}
 	} else {
-		e_dbg("1000 Mbs, Full Duplex\n");
 		*speed =3D SPEED_1000;
 		*duplex =3D FULL_DUPLEX;
 	}
=20
+	e_dbg("%u Mbs, %s Duplex\n",
+	      *speed =3D=3D SPEED_1000 ? 1000 :
+	      *speed =3D=3D SPEED_100 ? 100 : 10,
+	      *duplex =3D=3D FULL_DUPLEX ? "Full" : "Half");
+
 	/* IGP01 PHY may advertise full duplex operation after speed downgrad=
e
 	 * even if it is operating at half duplex.  Here we set the duplex
 	 * settings to match the duplex in the link partner's capabilities.
@@ -2699,8 +2638,7 @@ static s32 e1000_wait_autoneg(struct e1000_hw *hw=
)
 	u16 i;
 	u16 phy_data;
=20
-	e_dbg("e1000_wait_autoneg");
-	e_dbg("Waiting for Auto-Neg to complete.\n");
+	e_dbg("Waiting for Auto-Neg to complete\n");
=20
 	/* We will wait for autoneg to complete or 4.5 seconds to expire. */
 	for (i =3D PHY_AUTO_NEG_TIME; i > 0; i--) {
@@ -2866,8 +2804,6 @@ s32 e1000_read_phy_reg(struct e1000_hw *hw, u32 r=
eg_addr, u16 *phy_data)
 	u32 ret_val;
 	unsigned long flags;
=20
-	e_dbg("e1000_read_phy_reg");
-
 	spin_lock_irqsave(&e1000_phy_lock, flags);
=20
 	if ((hw->phy_type =3D=3D e1000_phy_igp) &&
@@ -2894,8 +2830,6 @@ static s32 e1000_read_phy_reg_ex(struct e1000_hw =
*hw, u32 reg_addr,
 	u32 mdic =3D 0;
 	const u32 phy_addr =3D (hw->mac_type =3D=3D e1000_ce4100) ? hw->phy_a=
ddr : 1;
=20
-	e_dbg("e1000_read_phy_reg_ex");
-
 	if (reg_addr > MAX_PHY_REG_ADDRESS) {
 		e_dbg("PHY Address %d is out of range\n", reg_addr);
 		return -E1000_ERR_PARAM;
@@ -3008,8 +2942,6 @@ s32 e1000_write_phy_reg(struct e1000_hw *hw, u32 =
reg_addr, u16 phy_data)
 	u32 ret_val;
 	unsigned long flags;
=20
-	e_dbg("e1000_write_phy_reg");
-
 	spin_lock_irqsave(&e1000_phy_lock, flags);
=20
 	if ((hw->phy_type =3D=3D e1000_phy_igp) &&
@@ -3036,8 +2968,6 @@ static s32 e1000_write_phy_reg_ex(struct e1000_hw=
 *hw, u32 reg_addr,
 	u32 mdic =3D 0;
 	const u32 phy_addr =3D (hw->mac_type =3D=3D e1000_ce4100) ? hw->phy_a=
ddr : 1;
=20
-	e_dbg("e1000_write_phy_reg_ex");
-
 	if (reg_addr > MAX_PHY_REG_ADDRESS) {
 		e_dbg("PHY Address %d is out of range\n", reg_addr);
 		return -E1000_ERR_PARAM;
@@ -3129,8 +3059,6 @@ s32 e1000_phy_hw_reset(struct e1000_hw *hw)
 	u32 ctrl, ctrl_ext;
 	u32 led_ctrl;
=20
-	e_dbg("e1000_phy_hw_reset");
-
 	e_dbg("Resetting Phy...\n");
=20
 	if (hw->mac_type > e1000_82543) {
@@ -3189,8 +3117,6 @@ s32 e1000_phy_reset(struct e1000_hw *hw)
 	s32 ret_val;
 	u16 phy_data;
=20
-	e_dbg("e1000_phy_reset");
-
 	switch (hw->phy_type) {
 	case e1000_phy_igp:
 		ret_val =3D e1000_phy_hw_reset(hw);
@@ -3229,8 +3155,6 @@ static s32 e1000_detect_gig_phy(struct e1000_hw *=
hw)
 	u16 phy_id_high, phy_id_low;
 	bool match =3D false;
=20
-	e_dbg("e1000_detect_gig_phy");
-
 	if (hw->phy_id !=3D 0)
 		return E1000_SUCCESS;
=20
@@ -3301,7 +3225,6 @@ static s32 e1000_detect_gig_phy(struct e1000_hw *=
hw)
 static s32 e1000_phy_reset_dsp(struct e1000_hw *hw)
 {
 	s32 ret_val;
-	e_dbg("e1000_phy_reset_dsp");
=20
 	do {
 		ret_val =3D e1000_write_phy_reg(hw, 29, 0x001d);
@@ -3333,8 +3256,6 @@ static s32 e1000_phy_igp_get_info(struct e1000_hw=
 *hw,
 	u16 phy_data, min_length, max_length, average;
 	e1000_rev_polarity polarity;
=20
-	e_dbg("e1000_phy_igp_get_info");
-
 	/* The downshift status is checked only once, after link is establish=
ed,
 	 * and it stored in the hw->speed_downgraded parameter.
 	 */
@@ -3414,8 +3335,6 @@ static s32 e1000_phy_m88_get_info(struct e1000_hw=
 *hw,
 	u16 phy_data;
 	e1000_rev_polarity polarity;
=20
-	e_dbg("e1000_phy_m88_get_info");
-
 	/* The downshift status is checked only once, after link is establish=
ed,
 	 * and it stored in the hw->speed_downgraded parameter.
 	 */
@@ -3487,8 +3406,6 @@ s32 e1000_phy_get_info(struct e1000_hw *hw, struc=
t e1000_phy_info *phy_info)
 	s32 ret_val;
 	u16 phy_data;
=20
-	e_dbg("e1000_phy_get_info");
-
 	phy_info->cable_length =3D e1000_cable_length_undefined;
 	phy_info->extended_10bt_distance =3D e1000_10bt_ext_dist_enable_undef=
ined;
 	phy_info->cable_polarity =3D e1000_rev_polarity_undefined;
@@ -3527,8 +3444,6 @@ s32 e1000_phy_get_info(struct e1000_hw *hw, struc=
t e1000_phy_info *phy_info)
=20
 s32 e1000_validate_mdi_setting(struct e1000_hw *hw)
 {
-	e_dbg("e1000_validate_mdi_settings");
-
 	if (!hw->autoneg && (hw->mdix =3D=3D 0 || hw->mdix =3D=3D 3)) {
 		e_dbg("Invalid MDI setting detected\n");
 		hw->mdix =3D 1;
@@ -3551,8 +3466,6 @@ s32 e1000_init_eeprom_params(struct e1000_hw *hw)
 	s32 ret_val =3D E1000_SUCCESS;
 	u16 eeprom_size;
=20
-	e_dbg("e1000_init_eeprom_params");
-
 	switch (hw->mac_type) {
 	case e1000_82542_rev2_0:
 	case e1000_82542_rev2_1:
@@ -3770,8 +3683,6 @@ static s32 e1000_acquire_eeprom(struct e1000_hw *=
hw)
 	struct e1000_eeprom_info *eeprom =3D &hw->eeprom;
 	u32 eecd, i =3D 0;
=20
-	e_dbg("e1000_acquire_eeprom");
-
 	eecd =3D er32(EECD);
=20
 	/* Request EEPROM Access */
@@ -3871,8 +3782,6 @@ static void e1000_release_eeprom(struct e1000_hw =
*hw)
 {
 	u32 eecd;
=20
-	e_dbg("e1000_release_eeprom");
-
 	eecd =3D er32(EECD);
=20
 	if (hw->eeprom.type =3D=3D e1000_eeprom_spi) {
@@ -3920,8 +3829,6 @@ static s32 e1000_spi_eeprom_ready(struct e1000_hw=
 *hw)
 	u16 retry_count =3D 0;
 	u8 spi_stat_reg;
=20
-	e_dbg("e1000_spi_eeprom_ready");
-
 	/* Read "Status Register" repeatedly until the LSB is cleared.  The
 	 * EEPROM will signal that the command has been completed by clearing
 	 * bit 0 of the internal status register.  If it's not cleared within
@@ -3974,8 +3881,6 @@ static s32 e1000_do_read_eeprom(struct e1000_hw *=
hw, u16 offset, u16 words,
 	struct e1000_eeprom_info *eeprom =3D &hw->eeprom;
 	u32 i =3D 0;
=20
-	e_dbg("e1000_read_eeprom");
-
 	if (hw->mac_type =3D=3D e1000_ce4100) {
 		GBE_CONFIG_FLASH_READ(GBE_CONFIG_BASE_VIRT, offset, words,
 		                      data);
@@ -3991,8 +3896,8 @@ static s32 e1000_do_read_eeprom(struct e1000_hw *=
hw, u16 offset, u16 words,
 	 */
 	if ((offset >=3D eeprom->word_size)
 	    || (words > eeprom->word_size - offset) || (words =3D=3D 0)) {
-		e_dbg("\"words\" parameter out of bounds. Words =3D %d,"
-		      "size =3D %d\n", offset, eeprom->word_size);
+		e_dbg("\"words\" parameter out of bounds. Words =3D %d, size =3D %d\=
n",
+		      offset, eeprom->word_size);
 		return -E1000_ERR_EEPROM;
 	}
=20
@@ -4076,8 +3981,6 @@ s32 e1000_validate_eeprom_checksum(struct e1000_h=
w *hw)
 	u16 checksum =3D 0;
 	u16 i, eeprom_data;
=20
-	e_dbg("e1000_validate_eeprom_checksum");
-
 	for (i =3D 0; i < (EEPROM_CHECKSUM_REG + 1); i++) {
 		if (e1000_read_eeprom(hw, i, 1, &eeprom_data) < 0) {
 			e_dbg("EEPROM Read Error\n");
@@ -4112,8 +4015,6 @@ s32 e1000_update_eeprom_checksum(struct e1000_hw =
*hw)
 	u16 checksum =3D 0;
 	u16 i, eeprom_data;
=20
-	e_dbg("e1000_update_eeprom_checksum");
-
 	for (i =3D 0; i < EEPROM_CHECKSUM_REG; i++) {
 		if (e1000_read_eeprom(hw, i, 1, &eeprom_data) < 0) {
 			e_dbg("EEPROM Read Error\n");
@@ -4154,8 +4055,6 @@ static s32 e1000_do_write_eeprom(struct e1000_hw =
*hw, u16 offset, u16 words,
 	struct e1000_eeprom_info *eeprom =3D &hw->eeprom;
 	s32 status =3D 0;
=20
-	e_dbg("e1000_write_eeprom");
-
 	if (hw->mac_type =3D=3D e1000_ce4100) {
 		GBE_CONFIG_FLASH_WRITE(GBE_CONFIG_BASE_VIRT, offset, words,
 		                       data);
@@ -4205,8 +4104,6 @@ static s32 e1000_write_eeprom_spi(struct e1000_hw=
 *hw, u16 offset, u16 words,
 	struct e1000_eeprom_info *eeprom =3D &hw->eeprom;
 	u16 widx =3D 0;
=20
-	e_dbg("e1000_write_eeprom_spi");
-
 	while (widx < words) {
 		u8 write_opcode =3D EEPROM_WRITE_OPCODE_SPI;
=20
@@ -4274,8 +4171,6 @@ static s32 e1000_write_eeprom_microwire(struct e1=
000_hw *hw, u16 offset,
 	u16 words_written =3D 0;
 	u16 i =3D 0;
=20
-	e_dbg("e1000_write_eeprom_microwire");
-
 	/* Send the write enable command to the EEPROM (3-bit opcode plus
 	 * 6/8-bit dummy address beginning with 11).  It's less work to inclu=
de
 	 * the 11 of the dummy address as part of the opcode than it is to sh=
ift
@@ -4354,8 +4249,6 @@ s32 e1000_read_mac_addr(struct e1000_hw *hw)
 	u16 offset;
 	u16 eeprom_data, i;
=20
-	e_dbg("e1000_read_mac_addr");
-
 	for (i =3D 0; i < NODE_ADDRESS_SIZE; i +=3D 2) {
 		offset =3D i >> 1;
 		if (e1000_read_eeprom(hw, offset, 1, &eeprom_data) < 0) {
@@ -4394,8 +4287,6 @@ static void e1000_init_rx_addrs(struct e1000_hw *=
hw)
 	u32 i;
 	u32 rar_num;
=20
-	e_dbg("e1000_init_rx_addrs");
-
 	/* Setup the receive address. */
 	e_dbg("Programming MAC Address into RAR[0]\n");
=20
@@ -4553,8 +4444,6 @@ static s32 e1000_id_led_init(struct e1000_hw *hw)
 	u16 eeprom_data, i, temp;
 	const u16 led_mask =3D 0x0F;
=20
-	e_dbg("e1000_id_led_init");
-
 	if (hw->mac_type < e1000_82540) {
 		/* Nothing to do */
 		return E1000_SUCCESS;
@@ -4626,8 +4515,6 @@ s32 e1000_setup_led(struct e1000_hw *hw)
 	u32 ledctl;
 	s32 ret_val =3D E1000_SUCCESS;
=20
-	e_dbg("e1000_setup_led");
-
 	switch (hw->mac_type) {
 	case e1000_82542_rev2_0:
 	case e1000_82542_rev2_1:
@@ -4678,8 +4565,6 @@ s32 e1000_cleanup_led(struct e1000_hw *hw)
 {
 	s32 ret_val =3D E1000_SUCCESS;
=20
-	e_dbg("e1000_cleanup_led");
-
 	switch (hw->mac_type) {
 	case e1000_82542_rev2_0:
 	case e1000_82542_rev2_1:
@@ -4714,8 +4599,6 @@ s32 e1000_led_on(struct e1000_hw *hw)
 {
 	u32 ctrl =3D er32(CTRL);
=20
-	e_dbg("e1000_led_on");
-
 	switch (hw->mac_type) {
 	case e1000_82542_rev2_0:
 	case e1000_82542_rev2_1:
@@ -4760,8 +4643,6 @@ s32 e1000_led_off(struct e1000_hw *hw)
 {
 	u32 ctrl =3D er32(CTRL);
=20
-	e_dbg("e1000_led_off");
-
 	switch (hw->mac_type) {
 	case e1000_82542_rev2_0:
 	case e1000_82542_rev2_1:
@@ -4889,8 +4770,6 @@ static void e1000_clear_hw_cntrs(struct e1000_hw =
*hw)
  */
 void e1000_reset_adaptive(struct e1000_hw *hw)
 {
-	e_dbg("e1000_reset_adaptive");
-
 	if (hw->adaptive_ifs) {
 		if (!hw->ifs_params_forced) {
 			hw->current_ifs_val =3D 0;
@@ -4917,8 +4796,6 @@ void e1000_reset_adaptive(struct e1000_hw *hw)
  */
 void e1000_update_adaptive(struct e1000_hw *hw)
 {
-	e_dbg("e1000_update_adaptive");
-
 	if (hw->adaptive_ifs) {
 		if ((hw->collision_delta *hw->ifs_ratio) > hw->tx_packet_delta) {
 			if (hw->tx_packet_delta > MIN_NUM_XMITS) {
@@ -5114,8 +4991,6 @@ static s32 e1000_get_cable_length(struct e1000_hw=
 *hw, u16 *min_length,
 	u16 i, phy_data;
 	u16 cable_length;
=20
-	e_dbg("e1000_get_cable_length");
-
 	*min_length =3D *max_length =3D 0;
=20
 	/* Use old method for Phy older than IGP */
@@ -5231,8 +5106,6 @@ static s32 e1000_check_polarity(struct e1000_hw *=
hw,
 	s32 ret_val;
 	u16 phy_data;
=20
-	e_dbg("e1000_check_polarity");
-
 	if (hw->phy_type =3D=3D e1000_phy_m88) {
 		/* return the Polarity bit in the Status register. */
 		ret_val =3D e1000_read_phy_reg(hw, M88E1000_PHY_SPEC_STATUS,
@@ -5299,8 +5172,6 @@ static s32 e1000_check_downshift(struct e1000_hw =
*hw)
 	s32 ret_val;
 	u16 phy_data;
=20
-	e_dbg("e1000_check_downshift");
-
 	if (hw->phy_type =3D=3D e1000_phy_igp) {
 		ret_val =3D e1000_read_phy_reg(hw, IGP01E1000_PHY_LINK_HEALTH,
 					     &phy_data);
@@ -5411,8 +5282,6 @@ static s32 e1000_config_dsp_after_link_change(str=
uct e1000_hw *hw, bool link_up)
 	s32 ret_val;
 	u16 phy_data, phy_saved_data, speed, duplex, i;
=20
-	e_dbg("e1000_config_dsp_after_link_change");
-
 	if (hw->phy_type !=3D e1000_phy_igp)
 		return E1000_SUCCESS;
=20
@@ -5546,8 +5415,6 @@ static s32 e1000_set_phy_mode(struct e1000_hw *hw=
)
 	s32 ret_val;
 	u16 eeprom_data;
=20
-	e_dbg("e1000_set_phy_mode");
-
 	if ((hw->mac_type =3D=3D e1000_82545_rev_3) &&
 	    (hw->media_type =3D=3D e1000_media_type_copper)) {
 		ret_val =3D
@@ -5594,7 +5461,6 @@ static s32 e1000_set_d3_lplu_state(struct e1000_h=
w *hw, bool active)
 {
 	s32 ret_val;
 	u16 phy_data;
-	e_dbg("e1000_set_d3_lplu_state");
=20
 	if (hw->phy_type !=3D e1000_phy_igp)
 		return E1000_SUCCESS;
@@ -5699,8 +5565,6 @@ static s32 e1000_set_vco_speed(struct e1000_hw *h=
w)
 	u16 default_page =3D 0;
 	u16 phy_data;
=20
-	e_dbg("e1000_set_vco_speed");
-
 	switch (hw->mac_type) {
 	case e1000_82545_rev_3:
 	case e1000_82546_rev_3:
@@ -5872,7 +5736,6 @@ static s32 e1000_polarity_reversal_workaround(str=
uct e1000_hw *hw)
  */
 static s32 e1000_get_auto_rd_done(struct e1000_hw *hw)
 {
-	e_dbg("e1000_get_auto_rd_done");
 	msleep(5);
 	return E1000_SUCCESS;
 }
@@ -5887,7 +5750,6 @@ static s32 e1000_get_auto_rd_done(struct e1000_hw=
 *hw)
  */
 static s32 e1000_get_phy_cfg_done(struct e1000_hw *hw)
 {
-	e_dbg("e1000_get_phy_cfg_done");
 	msleep(10);
 	return E1000_SUCCESS;
 }
diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/ne=
t/ethernet/intel/e1000/e1000_main.c
index 46e6544..66c9144 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_main.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
@@ -1537,8 +1537,7 @@ setup_tx_desc_die:
 					  txdr->dma);
 			dma_free_coherent(&pdev->dev, txdr->size, olddesc,
 					  olddma);
-			e_err(probe, "Unable to allocate aligned memory "
-			      "for the transmit descriptor ring\n");
+			e_err(probe, "Unable to allocate aligned memory for the transmit de=
scriptor ring\n");
 			vfree(txdr->buffer_info);
 			return -ENOMEM;
 		} else {
@@ -1729,8 +1728,7 @@ setup_rx_desc_die:
 					  rxdr->dma);
 			dma_free_coherent(&pdev->dev, rxdr->size, olddesc,
 					  olddma);
-			e_err(probe, "Unable to allocate aligned memory for "
-			      "the Rx descriptor ring\n");
+			e_err(probe, "Unable to allocate aligned memory for the Rx descript=
or ring\n");
 			goto setup_rx_desc_die;
 		} else {
 			/* Free old allocation, new allocation was successful */
@@ -3153,8 +3151,7 @@ static netdev_tx_t e1000_xmit_frame(struct sk_buf=
f *skb,
 				/* fall through */
 				pull_size =3D min((unsigned int)4, skb->data_len);
 				if (!__pskb_pull_tail(skb, pull_size)) {
-					e_err(drv, "__pskb_pull_tail "
-					      "failed.\n");
+					e_err(drv, "__pskb_pull_tail failed\n");
 					dev_kfree_skb_any(skb);
 					return NETDEV_TX_OK;
 				}
@@ -3518,7 +3515,7 @@ static int e1000_change_mtu(struct net_device *ne=
tdev, int new_mtu)
 	switch (hw->mac_type) {
 	case e1000_undefined ... e1000_82542_rev2_1:
 		if (max_frame > (ETH_FRAME_LEN + ETH_FCS_LEN)) {
-			e_err(probe, "Jumbo Frames not supported.\n");
+			e_err(probe, "Jumbo Frames not supported\n");
 			return -EINVAL;
 		}
 		break;
@@ -4142,7 +4139,7 @@ process_skb:
=20
 		/* eth type trans needs skb->data to point to something */
 		if (!pskb_may_pull(skb, ETH_HLEN)) {
-			e_err(drv, "pskb_may_pull failed.\n");
+			e_err(drv, "pskb_may_pull failed\n");
 			dev_kfree_skb(skb);
 			goto next_desc;
 		}
@@ -4463,8 +4460,8 @@ static void e1000_alloc_rx_buffers(struct e1000_a=
dapter *adapter,
 		/* Fix for errata 23, can't cross 64kB boundary */
 		if (!e1000_check_64k_bound(adapter, skb->data, bufsz)) {
 			struct sk_buff *oldskb =3D skb;
-			e_err(rx_err, "skb align check failed: %u bytes at "
-			      "%p\n", bufsz, skb->data);
+			e_err(rx_err, "skb align check failed: %u bytes at %p\n",
+			      bufsz, skb->data);
 			/* Try again, without freeing the previous */
 			skb =3D netdev_alloc_skb_ip_align(netdev, bufsz);
 			/* Failed allocation, critical failure */
@@ -4508,8 +4505,8 @@ map_skb:
 		if (!e1000_check_64k_bound(adapter,
 					(void *)(unsigned long)buffer_info->dma,
 					adapter->rx_buffer_len)) {
-			e_err(rx_err, "dma align check failed: %u bytes at "
-			      "%p\n", adapter->rx_buffer_len,
+			e_err(rx_err, "dma align check failed: %u bytes at %p\n",
+			      adapter->rx_buffer_len,
 			      (void *)(unsigned long)buffer_info->dma);
 			dev_kfree_skb(skb);
 			buffer_info->skb =3D NULL;
diff --git a/drivers/net/ethernet/intel/e1000e/80003es2lan.c b/drivers/=
net/ethernet/intel/e1000e/80003es2lan.c
index a5f6b11..56e71d0 100644
--- a/drivers/net/ethernet/intel/e1000e/80003es2lan.c
+++ b/drivers/net/ethernet/intel/e1000e/80003es2lan.c
@@ -313,7 +313,7 @@ static s32 e1000_acquire_swfw_sync_80003es2lan(stru=
ct e1000_hw *hw, u16 mask)
 	}
=20
 	if (i =3D=3D timeout) {
-		e_dbg("Driver can't access resource, SW_FW_SYNC timeout.\n");
+		e_dbg("Driver can't access resource, SW_FW_SYNC timeout\n");
 		return -E1000_ERR_SWFW_SYNC;
 	}
=20
@@ -522,7 +522,7 @@ static s32 e1000_get_cfg_done_80003es2lan(struct e1=
000_hw *hw)
 		timeout--;
 	}
 	if (!timeout) {
-		e_dbg("MNG configuration cycle has not completed.\n");
+		e_dbg("MNG configuration cycle has not completed\n");
 		return -E1000_ERR_RESET;
 	}
=20
@@ -572,7 +572,7 @@ static s32 e1000_phy_force_speed_duplex_80003es2lan=
(struct e1000_hw *hw)
 	udelay(1);
=20
 	if (hw->phy.autoneg_wait_to_complete) {
-		e_dbg("Waiting for forced speed/duplex link on GG82563 phy.\n");
+		e_dbg("Waiting for forced speed/duplex link on GG82563 phy\n");
=20
 		ret_val =3D e1000e_phy_has_link_generic(hw, PHY_FORCE_LIMIT,
 						      100000, &link);
@@ -689,7 +689,7 @@ static s32 e1000_reset_hw_80003es2lan(struct e1000_=
hw *hw)
 	 */
 	ret_val =3D e1000e_disable_pcie_master(hw);
 	if (ret_val)
-		e_dbg("PCI-E Master disable polling has failed.\n");
+		e_dbg("PCI-E Master disable polling has failed\n");
=20
 	e_dbg("Masking off all interrupts\n");
 	ew32(IMC, 0xffffffff);
diff --git a/drivers/net/ethernet/intel/e1000e/82571.c b/drivers/net/et=
hernet/intel/e1000e/82571.c
index e0aa7f1..14dbaad 100644
--- a/drivers/net/ethernet/intel/e1000e/82571.c
+++ b/drivers/net/ethernet/intel/e1000e/82571.c
@@ -480,7 +480,7 @@ static s32 e1000_get_hw_semaphore_82571(struct e100=
0_hw *hw)
 	}
=20
 	if (i =3D=3D sw_timeout) {
-		e_dbg("Driver can't access device - SMBI bit is set.\n");
+		e_dbg("Driver can't access device - SMBI bit is set\n");
 		hw->dev_spec.e82571.smb_counter++;
 	}
 	/* Get the FW semaphore. */
@@ -875,7 +875,7 @@ static s32 e1000_get_cfg_done_82571(struct e1000_hw=
 *hw)
 		timeout--;
 	}
 	if (!timeout) {
-		e_dbg("MNG configuration cycle has not completed.\n");
+		e_dbg("MNG configuration cycle has not completed\n");
 		return -E1000_ERR_RESET;
 	}
=20
@@ -969,7 +969,7 @@ static s32 e1000_reset_hw_82571(struct e1000_hw *hw=
)
 	 */
 	ret_val =3D e1000e_disable_pcie_master(hw);
 	if (ret_val)
-		e_dbg("PCI-E Master disable polling has failed.\n");
+		e_dbg("PCI-E Master disable polling has failed\n");
=20
 	e_dbg("Masking off all interrupts\n");
 	ew32(IMC, 0xffffffff);
diff --git a/drivers/net/ethernet/intel/e1000e/ethtool.c b/drivers/net/=
ethernet/intel/e1000e/ethtool.c
index 3c2898d..48ffd99 100644
--- a/drivers/net/ethernet/intel/e1000e/ethtool.c
+++ b/drivers/net/ethernet/intel/e1000e/ethtool.c
@@ -266,7 +266,7 @@ static int e1000_set_settings(struct net_device *ne=
tdev,
 	 */
 	if (hw->phy.ops.check_reset_block &&
 	    hw->phy.ops.check_reset_block(hw)) {
-		e_err("Cannot change link characteristics when SoL/IDER is active.\n=
");
+		e_err("Cannot change link characteristics when SoL/IDER is active\n"=
);
 		ret_val =3D -EINVAL;
 		goto out;
 	}
@@ -1006,7 +1006,7 @@ static int e1000_intr_test(struct e1000_adapter *=
adapter, u64 *data)
 		ret_val =3D -1;
 		goto out;
 	}
-	e_info("testing %s interrupt\n", (shared_int ? "shared" : "unshared")=
);
+	e_info("testing %s interrupt\n", shared_int ? "shared" : "unshared");
=20
 	/* Disable all the interrupts */
 	ew32(IMC, 0xFFFFFFFF);
@@ -1375,7 +1375,7 @@ static int e1000_integrated_phy_loopback(struct e=
1000_adapter *adapter)
 		/* Workaround: K1 must be disabled for stable 1Gbps operation */
 		ret_val =3D hw->phy.ops.acquire(hw);
 		if (ret_val) {
-			e_err("Cannot setup 1Gbps loopback.\n");
+			e_err("Cannot setup 1Gbps loopback\n");
 			return ret_val;
 		}
 		e1000_configure_k1_ich8lan(hw, false);
@@ -1687,7 +1687,7 @@ static int e1000_loopback_test(struct e1000_adapt=
er *adapter, u64 *data)
 	/* PHY loopback cannot be performed if SoL/IDER sessions are active *=
/
 	if (hw->phy.ops.check_reset_block &&
 	    hw->phy.ops.check_reset_block(hw)) {
-		e_err("Cannot do PHY loopback test when SoL/IDER is active.\n");
+		e_err("Cannot do PHY loopback test when SoL/IDER is active\n");
 		*data =3D 0;
 		goto out;
 	}
diff --git a/drivers/net/ethernet/intel/e1000e/ich8lan.c b/drivers/net/=
ethernet/intel/e1000e/ich8lan.c
index 9866f26..3d668b3 100644
--- a/drivers/net/ethernet/intel/e1000e/ich8lan.c
+++ b/drivers/net/ethernet/intel/e1000e/ich8lan.c
@@ -973,13 +973,13 @@ static s32 e1000_platform_pm_pch_lpt(struct e1000=
_hw *hw, bool link)
 		u32 rxa;
=20
 		if (!hw->adapter->max_frame_size) {
-			e_dbg("max_frame_size not set.\n");
+			e_dbg("max_frame_size not set\n");
 			return -E1000_ERR_CONFIG;
 		}
=20
 		hw->mac.ops.get_link_up_info(hw, &speed, &duplex);
 		if (!speed) {
-			e_dbg("Speed not set.\n");
+			e_dbg("Speed not set\n");
 			return -E1000_ERR_CONFIG;
 		}
=20
@@ -1543,7 +1543,7 @@ static s32 e1000_acquire_swflag_ich8lan(struct e1=
000_hw *hw)
 	}
=20
 	if (!timeout) {
-		e_dbg("SW has already locked the resource.\n");
+		e_dbg("SW has already locked the resource\n");
 		ret_val =3D -E1000_ERR_CONFIG;
 		goto out;
 	}
@@ -3030,7 +3030,7 @@ static s32 e1000_flash_cycle_init_ich8lan(struct =
e1000_hw *hw)
=20
 	/* Check if the flash descriptor is valid */
 	if (!hsfsts.hsf_status.fldesvalid) {
-		e_dbg("Flash descriptor invalid.  SW Sequencing must be used.\n");
+		e_dbg("Flash descriptor invalid - SW Sequencing must be used\n");
 		return -E1000_ERR_NVM;
 	}
=20
@@ -3224,7 +3224,7 @@ static s32 e1000_read_flash_data_ich8lan(struct e=
1000_hw *hw, u32 offset,
 				/* Repeat for some time before giving up. */
 				continue;
 			} else if (!hsfsts.hsf_status.flcdone) {
-				e_dbg("Timeout error - flash cycle did not complete.\n");
+				e_dbg("Timeout error - flash cycle did not complete\n");
 				break;
 			}
 		}
@@ -3368,7 +3368,7 @@ static s32 e1000_update_nvm_checksum_ich8lan(stru=
ct e1000_hw *hw)
 	 */
 	if (ret_val) {
 		/* Possibly read-only, see e1000e_write_protect_nvm_ich8lan() */
-		e_dbg("Flash commit failed.\n");
+		e_dbg("Flash commit failed\n");
 		goto release;
 	}
=20
@@ -3578,7 +3578,7 @@ static s32 e1000_write_flash_data_ich8lan(struct =
e1000_hw *hw, u32 offset,
 			/* Repeat for some time before giving up. */
 			continue;
 		if (!hsfsts.hsf_status.flcdone) {
-			e_dbg("Timeout error - flash cycle did not complete.\n");
+			e_dbg("Timeout error - flash cycle did not complete\n");
 			break;
 		}
 	} while (count++ < ICH_FLASH_CYCLE_REPEAT_COUNT);
@@ -3878,7 +3878,7 @@ static s32 e1000_reset_hw_ich8lan(struct e1000_hw=
 *hw)
 	 */
 	ret_val =3D e1000e_disable_pcie_master(hw);
 	if (ret_val)
-		e_dbg("PCI-E Master disable polling has failed.\n");
+		e_dbg("PCI-E Master disable polling has failed\n");
=20
 	e_dbg("Masking off all interrupts\n");
 	ew32(IMC, 0xffffffff);
@@ -4412,7 +4412,7 @@ void e1000e_set_kmrn_lock_loss_workaround_ich8lan=
(struct e1000_hw *hw,
 	struct e1000_dev_spec_ich8lan *dev_spec =3D &hw->dev_spec.ich8lan;
=20
 	if (hw->mac.type !=3D e1000_ich8lan) {
-		e_dbg("Workaround applies to ICH8 only.\n");
+		e_dbg("Workaround applies to ICH8 only\n");
 		return;
 	}
=20
diff --git a/drivers/net/ethernet/intel/e1000e/mac.c b/drivers/net/ethe=
rnet/intel/e1000e/mac.c
index baa0a46..a435305 100644
--- a/drivers/net/ethernet/intel/e1000e/mac.c
+++ b/drivers/net/ethernet/intel/e1000e/mac.c
@@ -493,7 +493,7 @@ s32 e1000e_check_for_fiber_link(struct e1000_hw *hw=
)
 			mac->autoneg_failed =3D true;
 			return 0;
 		}
-		e_dbg("NOT Rx'ing /C/, disable AutoNeg and force link.\n");
+		e_dbg("NOT Rx'ing /C/, disable AutoNeg and force link\n");
=20
 		/* Disable auto-negotiation in the TXCW register */
 		ew32(TXCW, (mac->txcw & ~E1000_TXCW_ANE));
@@ -515,7 +515,7 @@ s32 e1000e_check_for_fiber_link(struct e1000_hw *hw=
)
 		 * and disable forced link in the Device Control register
 		 * in an attempt to auto-negotiate with our link partner.
 		 */
-		e_dbg("Rx'ing /C/, enable AutoNeg and stop forcing link.\n");
+		e_dbg("Rx'ing /C/, enable AutoNeg and stop forcing link\n");
 		ew32(TXCW, mac->txcw);
 		ew32(CTRL, (ctrl & ~E1000_CTRL_SLU));
=20
@@ -556,7 +556,7 @@ s32 e1000e_check_for_serdes_link(struct e1000_hw *h=
w)
 			mac->autoneg_failed =3D true;
 			return 0;
 		}
-		e_dbg("NOT Rx'ing /C/, disable AutoNeg and force link.\n");
+		e_dbg("NOT Rx'ing /C/, disable AutoNeg and force link\n");
=20
 		/* Disable auto-negotiation in the TXCW register */
 		ew32(TXCW, (mac->txcw & ~E1000_TXCW_ANE));
@@ -578,7 +578,7 @@ s32 e1000e_check_for_serdes_link(struct e1000_hw *h=
w)
 		 * and disable forced link in the Device Control register
 		 * in an attempt to auto-negotiate with our link partner.
 		 */
-		e_dbg("Rx'ing /C/, enable AutoNeg and stop forcing link.\n");
+		e_dbg("Rx'ing /C/, enable AutoNeg and stop forcing link\n");
 		ew32(TXCW, mac->txcw);
 		ew32(CTRL, (ctrl & ~E1000_CTRL_SLU));
=20
@@ -594,11 +594,11 @@ s32 e1000e_check_for_serdes_link(struct e1000_hw =
*hw)
 		if (rxcw & E1000_RXCW_SYNCH) {
 			if (!(rxcw & E1000_RXCW_IV)) {
 				mac->serdes_has_link =3D true;
-				e_dbg("SERDES: Link up - forced.\n");
+				e_dbg("SERDES: Link up - forced\n");
 			}
 		} else {
 			mac->serdes_has_link =3D false;
-			e_dbg("SERDES: Link down - force failed.\n");
+			e_dbg("SERDES: Link down - force failed\n");
 		}
 	}
=20
@@ -611,14 +611,14 @@ s32 e1000e_check_for_serdes_link(struct e1000_hw =
*hw)
 			if (rxcw & E1000_RXCW_SYNCH) {
 				if (!(rxcw & E1000_RXCW_IV)) {
 					mac->serdes_has_link =3D true;
-					e_dbg("SERDES: Link up - autoneg completed successfully.\n");
+					e_dbg("SERDES: Link up - autoneg completed successfully\n");
 				} else {
 					mac->serdes_has_link =3D false;
-					e_dbg("SERDES: Link down - invalid codewords detected in autoneg.=
\n");
+					e_dbg("SERDES: Link down - invalid codewords detected in autoneg\=
n");
 				}
 			} else {
 				mac->serdes_has_link =3D false;
-				e_dbg("SERDES: Link down - no sync.\n");
+				e_dbg("SERDES: Link down - no sync\n");
 			}
 		} else {
 			mac->serdes_has_link =3D false;
@@ -1054,7 +1054,7 @@ s32 e1000e_config_fc_after_link_up(struct e1000_h=
w *hw)
 			return ret_val;
=20
 		if (!(mii_status_reg & BMSR_ANEGCOMPLETE)) {
-			e_dbg("Copper PHY and Auto Neg has not completed.\n");
+			e_dbg("Copper PHY and Auto Neg has not completed\n");
 			return ret_val;
 		}
=20
@@ -1114,10 +1114,10 @@ s32 e1000e_config_fc_after_link_up(struct e1000=
_hw *hw)
 			 */
 			if (hw->fc.requested_mode =3D=3D e1000_fc_full) {
 				hw->fc.current_mode =3D e1000_fc_full;
-				e_dbg("Flow Control =3D FULL.\n");
+				e_dbg("Flow Control =3D FULL\n");
 			} else {
 				hw->fc.current_mode =3D e1000_fc_rx_pause;
-				e_dbg("Flow Control =3D Rx PAUSE frames only.\n");
+				e_dbg("Flow Control =3D Rx PAUSE frames only\n");
 			}
 		}
 		/* For receiving PAUSE frames ONLY.
@@ -1132,7 +1132,7 @@ s32 e1000e_config_fc_after_link_up(struct e1000_h=
w *hw)
 			 (mii_nway_lp_ability_reg & LPA_PAUSE_CAP) &&
 			 (mii_nway_lp_ability_reg & LPA_PAUSE_ASYM)) {
 			hw->fc.current_mode =3D e1000_fc_tx_pause;
-			e_dbg("Flow Control =3D Tx PAUSE frames only.\n");
+			e_dbg("Flow Control =3D Tx PAUSE frames only\n");
 		}
 		/* For transmitting PAUSE frames ONLY.
 		 *
@@ -1146,13 +1146,13 @@ s32 e1000e_config_fc_after_link_up(struct e1000=
_hw *hw)
 			 !(mii_nway_lp_ability_reg & LPA_PAUSE_CAP) &&
 			 (mii_nway_lp_ability_reg & LPA_PAUSE_ASYM)) {
 			hw->fc.current_mode =3D e1000_fc_rx_pause;
-			e_dbg("Flow Control =3D Rx PAUSE frames only.\n");
+			e_dbg("Flow Control =3D Rx PAUSE frames only\n");
 		} else {
 			/* Per the IEEE spec, at this point flow control
 			 * should be disabled.
 			 */
 			hw->fc.current_mode =3D e1000_fc_none;
-			e_dbg("Flow Control =3D NONE.\n");
+			e_dbg("Flow Control =3D NONE\n");
 		}
=20
 		/* Now we need to do one last check...  If we auto-
@@ -1191,7 +1191,7 @@ s32 e1000e_config_fc_after_link_up(struct e1000_h=
w *hw)
 		pcs_status_reg =3D er32(PCS_LSTAT);
=20
 		if (!(pcs_status_reg & E1000_PCS_LSTS_AN_COMPLETE)) {
-			e_dbg("PCS Auto Neg has not completed.\n");
+			e_dbg("PCS Auto Neg has not completed\n");
 			return ret_val;
 		}
=20
@@ -1247,10 +1247,10 @@ s32 e1000e_config_fc_after_link_up(struct e1000=
_hw *hw)
 			 */
 			if (hw->fc.requested_mode =3D=3D e1000_fc_full) {
 				hw->fc.current_mode =3D e1000_fc_full;
-				e_dbg("Flow Control =3D FULL.\n");
+				e_dbg("Flow Control =3D FULL\n");
 			} else {
 				hw->fc.current_mode =3D e1000_fc_rx_pause;
-				e_dbg("Flow Control =3D Rx PAUSE frames only.\n");
+				e_dbg("Flow Control =3D Rx PAUSE frames only\n");
 			}
 		}
 		/* For receiving PAUSE frames ONLY.
@@ -1265,7 +1265,7 @@ s32 e1000e_config_fc_after_link_up(struct e1000_h=
w *hw)
 			 (pcs_lp_ability_reg & E1000_TXCW_PAUSE) &&
 			 (pcs_lp_ability_reg & E1000_TXCW_ASM_DIR)) {
 			hw->fc.current_mode =3D e1000_fc_tx_pause;
-			e_dbg("Flow Control =3D Tx PAUSE frames only.\n");
+			e_dbg("Flow Control =3D Tx PAUSE frames only\n");
 		}
 		/* For transmitting PAUSE frames ONLY.
 		 *
@@ -1279,13 +1279,13 @@ s32 e1000e_config_fc_after_link_up(struct e1000=
_hw *hw)
 			 !(pcs_lp_ability_reg & E1000_TXCW_PAUSE) &&
 			 (pcs_lp_ability_reg & E1000_TXCW_ASM_DIR)) {
 			hw->fc.current_mode =3D e1000_fc_rx_pause;
-			e_dbg("Flow Control =3D Rx PAUSE frames only.\n");
+			e_dbg("Flow Control =3D Rx PAUSE frames only\n");
 		} else {
 			/* Per the IEEE spec, at this point flow control
 			 * should be disabled.
 			 */
 			hw->fc.current_mode =3D e1000_fc_none;
-			e_dbg("Flow Control =3D NONE.\n");
+			e_dbg("Flow Control =3D NONE\n");
 		}
=20
 		/* Now we call a subroutine to actually force the MAC
@@ -1380,7 +1380,7 @@ s32 e1000e_get_hw_semaphore(struct e1000_hw *hw)
 	}
=20
 	if (i =3D=3D timeout) {
-		e_dbg("Driver can't access device - SMBI bit is set.\n");
+		e_dbg("Driver can't access device - SMBI bit is set\n");
 		return -E1000_ERR_NVM;
 	}
=20
@@ -1439,7 +1439,7 @@ s32 e1000e_get_auto_rd_done(struct e1000_hw *hw)
 	}
=20
 	if (i =3D=3D AUTO_READ_DONE_TIMEOUT) {
-		e_dbg("Auto read by HW from NVM has not completed.\n");
+		e_dbg("Auto read by HW from NVM has not completed\n");
 		return -E1000_ERR_RESET;
 	}
=20
@@ -1723,7 +1723,7 @@ s32 e1000e_disable_pcie_master(struct e1000_hw *h=
w)
 	}
=20
 	if (!timeout) {
-		e_dbg("Master requests are pending.\n");
+		e_dbg("Master requests are pending\n");
 		return -E1000_ERR_MASTER_REQUESTS_PENDING;
 	}
=20
diff --git a/drivers/net/ethernet/intel/e1000e/manage.c b/drivers/net/e=
thernet/intel/e1000e/manage.c
index cb37ff1..f88365b 100644
--- a/drivers/net/ethernet/intel/e1000e/manage.c
+++ b/drivers/net/ethernet/intel/e1000e/manage.c
@@ -59,14 +59,14 @@ static s32 e1000_mng_enable_host_if(struct e1000_hw=
 *hw)
 	u8 i;
=20
 	if (!hw->mac.arc_subsystem_valid) {
-		e_dbg("ARC subsystem not valid.\n");
+		e_dbg("ARC subsystem not valid\n");
 		return -E1000_ERR_HOST_INTERFACE_COMMAND;
 	}
=20
 	/* Check that the host interface is enabled. */
 	hicr =3D er32(HICR);
 	if (!(hicr & E1000_HICR_EN)) {
-		e_dbg("E1000_HOST_EN bit disabled.\n");
+		e_dbg("E1000_HOST_EN bit disabled\n");
 		return -E1000_ERR_HOST_INTERFACE_COMMAND;
 	}
 	/* check the previous command is completed */
@@ -78,7 +78,7 @@ static s32 e1000_mng_enable_host_if(struct e1000_hw *=
hw)
 	}
=20
 	if (i =3D=3D E1000_MNG_DHCP_COMMAND_TIMEOUT) {
-		e_dbg("Previous command timeout failed .\n");
+		e_dbg("Previous command timeout failed\n");
 		return -E1000_ERR_HOST_INTERFACE_COMMAND;
 	}
=20
diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/e=
thernet/intel/e1000e/netdev.c
index 5129c4c..34a5fbb 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -1593,7 +1593,7 @@ static bool e1000_clean_jumbo_rx_irq(struct e1000=
_ring *rx_ring, int *work_done,
=20
 		/* eth type trans needs skb->data to point to something */
 		if (!pskb_may_pull(skb, ETH_HLEN)) {
-			e_err("pskb_may_pull failed.\n");
+			e_err("pskb_may_pull failed\n");
 			dev_kfree_skb_irq(skb);
 			goto next_desc;
 		}
@@ -2044,7 +2044,7 @@ void e1000e_set_interrupt_capability(struct e1000=
_adapter *adapter)
 					return;
 			}
 			/* MSI-X failed, so fall through and try MSI */
-			e_err("Failed to initialize MSI-X interrupts.  Falling back to MSI =
interrupts.\n");
+			e_err("Failed to initialize MSI-X interrupts - falling back to MSI =
interrupts\n");
 			e1000e_reset_interrupt_capability(adapter);
 		}
 		adapter->int_mode =3D E1000E_INT_MODE_MSI;
@@ -2054,7 +2054,7 @@ void e1000e_set_interrupt_capability(struct e1000=
_adapter *adapter)
 			adapter->flags |=3D FLAG_MSI_ENABLED;
 		} else {
 			adapter->int_mode =3D E1000E_INT_MODE_LEGACY;
-			e_err("Failed to initialize MSI interrupts.  Falling back to legacy=
 interrupts.\n");
+			e_err("Failed to initialize MSI interrupts - falling back to legacy=
 interrupts\n");
 		}
 		/* Fall through */
 	case E1000E_INT_MODE_LEGACY:
@@ -4187,7 +4187,7 @@ static int e1000_test_msi_interrupt(struct e1000_=
adapter *adapter)
=20
 	if (adapter->flags & FLAG_MSI_TEST_FAILED) {
 		adapter->int_mode =3D E1000E_INT_MODE_LEGACY;
-		e_info("MSI interrupt test failed, using legacy interrupt.\n");
+		e_info("MSI interrupt test failed, using legacy interrupt\n");
 	} else {
 		e_dbg("MSI interrupt test succeeded!\n");
 	}
@@ -5479,7 +5479,7 @@ static netdev_tx_t e1000_xmit_frame(struct sk_buf=
f *skb,
=20
 			pull_size =3D min_t(unsigned int, 4, skb->data_len);
 			if (!__pskb_pull_tail(skb, pull_size)) {
-				e_err("__pskb_pull_tail failed.\n");
+				e_err("__pskb_pull_tail failed\n");
 				dev_kfree_skb_any(skb);
 				return NETDEV_TX_OK;
 			}
@@ -5658,7 +5658,7 @@ static int e1000_change_mtu(struct net_device *ne=
tdev, int new_mtu)
 	/* Jumbo frame support */
 	if ((max_frame > ETH_FRAME_LEN + ETH_FCS_LEN) &&
 	    !(adapter->flags & FLAG_HAS_JUMBO_FRAMES)) {
-		e_err("Jumbo Frames not supported.\n");
+		e_err("Jumbo Frames not supported\n");
 		return -EINVAL;
 	}
=20
@@ -5673,7 +5673,7 @@ static int e1000_change_mtu(struct net_device *ne=
tdev, int new_mtu)
 	if ((adapter->hw.mac.type >=3D e1000_pch2lan) &&
 	    !(adapter->flags2 & FLAG2_CRC_STRIPPING) &&
 	    (new_mtu > ETH_DATA_LEN)) {
-		e_err("Jumbo Frames not supported on this device when CRC stripping =
is disabled.\n");
+		e_err("Jumbo Frames not supported on this device when CRC stripping =
is disabled\n");
 		return -EINVAL;
 	}
=20
diff --git a/drivers/net/ethernet/intel/e1000e/nvm.c b/drivers/net/ethe=
rnet/intel/e1000e/nvm.c
index a9a976f..4c93785 100644
--- a/drivers/net/ethernet/intel/e1000e/nvm.c
+++ b/drivers/net/ethernet/intel/e1000e/nvm.c
@@ -598,7 +598,7 @@ s32 e1000e_update_nvm_checksum_generic(struct e1000=
_hw *hw)
 	for (i =3D 0; i < NVM_CHECKSUM_REG; i++) {
 		ret_val =3D e1000_read_nvm(hw, i, 1, &nvm_data);
 		if (ret_val) {
-			e_dbg("NVM Read Error while updating checksum.\n");
+			e_dbg("NVM Read Error while updating checksum\n");
 			return ret_val;
 		}
 		checksum +=3D nvm_data;
@@ -606,7 +606,7 @@ s32 e1000e_update_nvm_checksum_generic(struct e1000=
_hw *hw)
 	checksum =3D (u16)NVM_SUM - checksum;
 	ret_val =3D e1000_write_nvm(hw, NVM_CHECKSUM_REG, 1, &checksum);
 	if (ret_val)
-		e_dbg("NVM Write Error while updating checksum.\n");
+		e_dbg("NVM Write Error while updating checksum\n");
=20
 	return ret_val;
 }
diff --git a/drivers/net/ethernet/intel/e1000e/phy.c b/drivers/net/ethe=
rnet/intel/e1000e/phy.c
index 00b3fc9..2a08e71 100644
--- a/drivers/net/ethernet/intel/e1000e/phy.c
+++ b/drivers/net/ethernet/intel/e1000e/phy.c
@@ -847,7 +847,7 @@ s32 e1000e_copper_link_setup_igp(struct e1000_hw *h=
w)
=20
 	ret_val =3D e1000_phy_hw_reset(hw);
 	if (ret_val) {
-		e_dbg("Error resetting the PHY.\n");
+		e_dbg("Error resetting the PHY\n");
 		return ret_val;
 	}
=20
@@ -1232,7 +1232,7 @@ s32 e1000e_phy_force_speed_duplex_igp(struct e100=
0_hw *hw)
 	udelay(1);
=20
 	if (phy->autoneg_wait_to_complete) {
-		e_dbg("Waiting for forced speed/duplex link on IGP phy.\n");
+		e_dbg("Waiting for forced speed/duplex link on IGP phy\n");
=20
 		ret_val =3D e1000e_phy_has_link_generic(hw, PHY_FORCE_LIMIT,
 						      100000, &link);
@@ -1240,7 +1240,7 @@ s32 e1000e_phy_force_speed_duplex_igp(struct e100=
0_hw *hw)
 			return ret_val;
=20
 		if (!link)
-			e_dbg("Link taking longer than expected.\n");
+			e_dbg("Link taking longer than expected\n");
=20
 		/* Try once more */
 		ret_val =3D e1000e_phy_has_link_generic(hw, PHY_FORCE_LIMIT,
@@ -1299,7 +1299,7 @@ s32 e1000e_phy_force_speed_duplex_m88(struct e100=
0_hw *hw)
 	}
=20
 	if (phy->autoneg_wait_to_complete) {
-		e_dbg("Waiting for forced speed/duplex link on M88 phy.\n");
+		e_dbg("Waiting for forced speed/duplex link on M88 phy\n");
=20
 		ret_val =3D e1000e_phy_has_link_generic(hw, PHY_FORCE_LIMIT,
 						      100000, &link);
@@ -1308,7 +1308,7 @@ s32 e1000e_phy_force_speed_duplex_m88(struct e100=
0_hw *hw)
=20
 		if (!link) {
 			if (hw->phy.type !=3D e1000_phy_m88) {
-				e_dbg("Link taking longer than expected.\n");
+				e_dbg("Link taking longer than expected\n");
 			} else {
 				/* We didn't get link.
 				 * Reset the DSP and cross our fingers.
@@ -1401,7 +1401,7 @@ s32 e1000_phy_force_speed_duplex_ife(struct e1000=
_hw *hw)
 	udelay(1);
=20
 	if (phy->autoneg_wait_to_complete) {
-		e_dbg("Waiting for forced speed/duplex link on IFE phy.\n");
+		e_dbg("Waiting for forced speed/duplex link on IFE phy\n");
=20
 		ret_val =3D e1000e_phy_has_link_generic(hw, PHY_FORCE_LIMIT,
 						      100000, &link);
@@ -1409,7 +1409,7 @@ s32 e1000_phy_force_speed_duplex_ife(struct e1000=
_hw *hw)
 			return ret_val;
=20
 		if (!link)
-			e_dbg("Link taking longer than expected.\n");
+			e_dbg("Link taking longer than expected\n");
=20
 		/* Try once more */
 		ret_val =3D e1000e_phy_has_link_generic(hw, PHY_FORCE_LIMIT,
@@ -2660,8 +2660,7 @@ static s32 e1000_access_phy_wakeup_reg_bm(struct =
e1000_hw *hw, u32 offset,
 	/* Gig must be disabled for MDIO accesses to Host Wakeup reg page */
 	if ((hw->mac.type =3D=3D e1000_pchlan) &&
 	    (!(er32(PHY_CTRL) & E1000_PHY_CTRL_GBE_DISABLE)))
-		e_dbg("Attempting to access page %d while gig enabled.\n",
-		      page);
+		e_dbg("Attempting to access page %d while gig enabled\n", page);
=20
 	if (!page_set) {
 		/* Enable access to PHY wakeup registers */
@@ -2793,8 +2792,8 @@ static s32 __e1000_read_phy_reg_hv(struct e1000_h=
w *hw, u32 offset, u16 *data,
 		}
 	}
=20
-	e_dbg("reading PHY page %d (or 0x%x shifted) reg 0x%x\n", page,
-	      page << IGP_PAGE_SHIFT, reg);
+	e_dbg("reading PHY page %d (or 0x%x shifted) reg 0x%x\n",
+	      page, page << IGP_PAGE_SHIFT, reg);
=20
 	ret_val =3D e1000e_read_phy_reg_mdic(hw, MAX_PHY_REG_ADDRESS & reg, d=
ata);
 out:
@@ -2915,8 +2914,8 @@ static s32 __e1000_write_phy_reg_hv(struct e1000_=
hw *hw, u32 offset, u16 data,
 		}
 	}
=20
-	e_dbg("writing PHY page %d (or 0x%x shifted) reg 0x%x\n", page,
-	      page << IGP_PAGE_SHIFT, reg);
+	e_dbg("writing PHY page %d (or 0x%x shifted) reg 0x%x\n",
+	      page, page << IGP_PAGE_SHIFT, reg);
=20
 	ret_val =3D e1000e_write_phy_reg_mdic(hw, MAX_PHY_REG_ADDRESS & reg,
 					    data);
@@ -3136,7 +3135,7 @@ s32 e1000_phy_force_speed_duplex_82577(struct e10=
00_hw *hw)
 			return ret_val;
=20
 		if (!link)
-			e_dbg("Link taking longer than expected.\n");
+			e_dbg("Link taking longer than expected\n");
=20
 		/* Try once more */
 		ret_val =3D e1000e_phy_has_link_generic(hw, PHY_FORCE_LIMIT,
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers=
/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index f2d35c0..7ea5ef7 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -1356,8 +1356,7 @@ static bool reg_pattern_test(struct ixgbe_adapter=
 *adapter, u64 *data, int reg,
 		ixgbe_write_reg(&adapter->hw, reg, test_pattern[pat] & write);
 		val =3D ixgbe_read_reg(&adapter->hw, reg);
 		if (val !=3D (test_pattern[pat] & write & mask)) {
-			e_err(drv, "pattern test reg %04X failed: got "
-			      "0x%08X expected 0x%08X\n",
+			e_err(drv, "pattern test reg %04X failed: got 0x%08X expected 0x%08=
X\n",
 			      reg, val, (test_pattern[pat] & write & mask));
 			*data =3D reg;
 			ixgbe_write_reg(&adapter->hw, reg, before);
@@ -1381,8 +1380,8 @@ static bool reg_set_and_check(struct ixgbe_adapte=
r *adapter, u64 *data, int reg,
 	ixgbe_write_reg(&adapter->hw, reg, write & mask);
 	val =3D ixgbe_read_reg(&adapter->hw, reg);
 	if ((write & mask) !=3D (val & mask)) {
-		e_err(drv, "set/check reg %04X test failed: got 0x%08X "
-		      "expected 0x%08X\n", reg, (val & mask), (write & mask));
+		e_err(drv, "set/check reg %04X test failed: got 0x%08X expected 0x%0=
8X\n",
+		      reg, (val & mask), (write & mask));
 		*data =3D reg;
 		ixgbe_write_reg(&adapter->hw, reg, before);
 		return true;
@@ -1429,8 +1428,8 @@ static int ixgbe_reg_test(struct ixgbe_adapter *a=
dapter, u64 *data)
 	ixgbe_write_reg(&adapter->hw, IXGBE_STATUS, toggle);
 	after =3D ixgbe_read_reg(&adapter->hw, IXGBE_STATUS) & toggle;
 	if (value !=3D after) {
-		e_err(drv, "failed STATUS register test got: 0x%08X "
-		      "expected: 0x%08X\n", after, value);
+		e_err(drv, "failed STATUS register test got: 0x%08X expected: 0x%08X=
\n",
+		      after, value);
 		*data =3D 1;
 		return 1;
 	}
@@ -1539,8 +1538,8 @@ static int ixgbe_intr_test(struct ixgbe_adapter *=
adapter, u64 *data)
 		*data =3D 1;
 		return -1;
 	}
-	e_info(hw, "testing %s interrupt\n", shared_int ?
-	       "shared" : "unshared");
+	e_info(hw, "testing %s interrupt\n",
+	       shared_int ? "shared" : "unshared");
=20
 	/* Disable all the interrupts */
 	IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMC, 0xFFFFFFFF);
@@ -2036,8 +2035,7 @@ static void ixgbe_diag_test(struct net_device *ne=
tdev,
 		 * loopback diagnostic. */
 		if (adapter->flags & (IXGBE_FLAG_SRIOV_ENABLED |
 				      IXGBE_FLAG_VMDQ_ENABLED)) {
-			e_info(hw, "Skip MAC loopback diagnostic in VT "
-			       "mode\n");
+			e_info(hw, "Skip MAC loopback diagnostic in VT mode\n");
 			data[3] =3D 0;
 			goto skip_loopback;
 		}
@@ -2221,8 +2219,7 @@ static bool ixgbe_update_rsc(struct ixgbe_adapter=
 *adapter)
 	    adapter->rx_itr_setting > IXGBE_MIN_RSC_ITR) {
 		if (!(adapter->flags2 & IXGBE_FLAG2_RSC_ENABLED)) {
 			adapter->flags2 |=3D IXGBE_FLAG2_RSC_ENABLED;
-			e_info(probe, "rx-usecs value high enough "
-				      "to re-enable RSC\n");
+			e_info(probe, "rx-usecs value high enough to re-enable RSC\n");
 			return true;
 		}
 	/* if interrupt rate is too high then disable RSC */
@@ -2786,8 +2783,7 @@ static int ixgbe_set_rss_hash_opt(struct ixgbe_ad=
apter *adapter,
=20
 		if ((flags2 & UDP_RSS_FLAGS) &&
 		    !(adapter->flags2 & UDP_RSS_FLAGS))
-			e_warn(drv, "enabling UDP RSS: fragmented packets"
-			       " may arrive out of order to the stack above\n");
+			e_warn(drv, "enabling UDP RSS: fragmented packets may arrive out of=
 order to the stack above\n");
=20
 		adapter->flags2 =3D flags2;
=20
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c b/drivers/ne=
t/ethernet/intel/ixgbe/ixgbe_fcoe.c
index 0872617..ecf2131 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c
@@ -796,7 +796,7 @@ int ixgbe_fcoe_enable(struct net_device *netdev)
 	if (adapter->flags & IXGBE_FLAG_FCOE_ENABLED)
 		return -EINVAL;
=20
-	e_info(drv, "Enabling FCoE offload features.\n");
+	e_info(drv, "Enabling FCoE offload features\n");
=20
 	if (adapter->flags & IXGBE_FLAG_SRIOV_ENABLED)
 		e_warn(probe, "Enabling FCoE on PF will disable legacy VFs\n");
@@ -840,7 +840,7 @@ int ixgbe_fcoe_disable(struct net_device *netdev)
 	if (!(adapter->flags & IXGBE_FLAG_FCOE_ENABLED))
 		return -EINVAL;
=20
-	e_info(drv, "Disabling FCoE offload features.\n");
+	e_info(drv, "Disabling FCoE offload features\n");
 	if (netif_running(netdev))
 		netdev->netdev_ops->ndo_stop(netdev);
=20
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/ne=
t/ethernet/intel/ixgbe/ixgbe_main.c
index 10b35d8..7c0cbef 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -2450,9 +2450,7 @@ static void ixgbe_check_overtemp_subtask(struct i=
xgbe_adapter *adapter)
 		break;
 	}
 	e_crit(drv,
-	       "Network adapter has been stopped because it has over heated. =
"
-	       "Restart the computer. If the problem persists, "
-	       "power off the system and replace the adapter\n");
+	       "Network adapter has been stopped because it has over heated. =
Restart the computer. If the problem persists, power off the system and=
 replace the adapter.\n");
=20
 	adapter->interrupt_event =3D 0;
 }
@@ -2497,9 +2495,7 @@ static void ixgbe_check_overtemp_event(struct ixg=
be_adapter *adapter, u32 eicr)
 	}
=20
 	e_crit(drv,
-	       "Network adapter has been stopped because it has over heated. =
"
-	       "Restart the computer. If the problem persists, "
-	       "power off the system and replace the adapter\n");
+	       "Network adapter has been stopped because it has over heated. =
Restart the computer. If the problem persists, power off the system and=
 replace the adapter.\n");
 }
=20
 static void ixgbe_check_sfp_event(struct ixgbe_adapter *adapter, u32 e=
icr)
@@ -2818,8 +2814,8 @@ static int ixgbe_request_msix_irqs(struct ixgbe_a=
dapter *adapter)
 		err =3D request_irq(entry->vector, &ixgbe_msix_clean_rings, 0,
 				  q_vector->name, q_vector);
 		if (err) {
-			e_err(probe, "request_irq failed for MSIX interrupt "
-			      "Error: %d\n", err);
+			e_err(probe, "request_irq failed for MSIX interrupt - Error: %d\n",
+			      err);
 			goto free_queue_irqs;
 		}
 		/* If Flow Director is enabled, set interrupt affinity */
@@ -3405,8 +3401,8 @@ static void ixgbe_rx_desc_queue_enable(struct ixg=
be_adapter *adapter,
 	} while (--wait_loop && !(rxdctl & IXGBE_RXDCTL_ENABLE));
=20
 	if (!wait_loop) {
-		e_err(drv, "RXDCTL.ENABLE on Rx queue %d not set within "
-		      "the polling period\n", reg_idx);
+		e_err(drv, "RXDCTL.ENABLE on Rx queue %d not set within the polling =
period\n",
+		      reg_idx);
 	}
 }
=20
@@ -3437,8 +3433,8 @@ void ixgbe_disable_rx_queue(struct ixgbe_adapter =
*adapter,
 	} while (--wait_loop && (rxdctl & IXGBE_RXDCTL_ENABLE));
=20
 	if (!wait_loop) {
-		e_err(drv, "RXDCTL.ENABLE on Rx queue %d not cleared within "
-		      "the polling period\n", reg_idx);
+		e_err(drv, "RXDCTL.ENABLE on Rx queue %d not cleared within the poll=
ing period\n",
+		      reg_idx);
 	}
 }
=20
@@ -4114,9 +4110,8 @@ static int ixgbe_hpbthresh(struct ixgbe_adapter *=
adapter, int pb)
 	 * to user and a do the best we can.
 	 */
 	if (marker < 0) {
-		e_warn(drv, "Packet Buffer(%i) can not provide enough"
-			    "headroom to support flow control."
-			    "Decrease MTU or number of traffic classes\n", pb);
+		e_warn(drv, "Packet Buffer(%i) can not provide enough headroom to su=
pport flow control - decrease MTU or number of traffic classes\n",
+		       pb);
 		marker =3D tc + 1;
 	}
=20
@@ -5947,8 +5942,7 @@ static void ixgbe_fdir_reinit_subtask(struct ixgb=
e_adapter *adapter)
 		/* re-enable flow director interrupts */
 		IXGBE_WRITE_REG(hw, IXGBE_EIMS, IXGBE_EIMS_FLOW_DIR);
 	} else {
-		e_err(probe, "failed to finish FDIR re-initialization, "
-		      "ignored adding FDIR ATR filters\n");
+		e_err(probe, "failed to finish FDIR re-initialization, ignored addin=
g FDIR ATR filters\n");
 	}
 }
=20
@@ -6107,16 +6101,13 @@ static void ixgbe_watchdog_link_is_up(struct ix=
gbe_adapter *adapter)
 		ixgbe_ptp_start_cyclecounter(adapter);
=20
 	e_info(drv, "NIC Link is Up %s, Flow Control: %s\n",
-	       (link_speed =3D=3D IXGBE_LINK_SPEED_10GB_FULL ?
-	       "10 Gbps" :
-	       (link_speed =3D=3D IXGBE_LINK_SPEED_1GB_FULL ?
-	       "1 Gbps" :
-	       (link_speed =3D=3D IXGBE_LINK_SPEED_100_FULL ?
-	       "100 Mbps" :
-	       "unknown speed"))),
-	       ((flow_rx && flow_tx) ? "RX/TX" :
-	       (flow_rx ? "RX" :
-	       (flow_tx ? "TX" : "None"))));
+	       link_speed =3D=3D IXGBE_LINK_SPEED_10GB_FULL ? "10 Gbps" :
+	       link_speed =3D=3D IXGBE_LINK_SPEED_1GB_FULL ? "1 Gbps" :
+	       link_speed =3D=3D IXGBE_LINK_SPEED_100_FULL ? "100 Mbps" :
+	       "unknown speed",
+	       flow_rx && flow_tx ? "RX/TX" :
+	       flow_rx ? "RX" :
+	       flow_tx ? "TX" : "None");
=20
 	netif_carrier_on(netdev);
 	ixgbe_check_vf_rate_limit(adapter);
@@ -7508,8 +7499,7 @@ static int ixgbe_set_features(struct net_device *=
netdev,
 			adapter->flags2 |=3D IXGBE_FLAG2_RSC_ENABLED;
 			need_reset =3D true;
 		} else if ((changed ^ features) & NETIF_F_LRO) {
-			e_info(probe, "rx-usecs set too low, "
-			       "disabling RSC\n");
+			e_info(probe, "rx-usecs set too low, disabling RSC\n");
 		}
 	}
=20
@@ -7640,7 +7630,7 @@ static int ixgbe_ndo_bridge_setlink(struct net_de=
vice *dev,
 		IXGBE_WRITE_REG(&adapter->hw, IXGBE_PFDTXGSWC, reg);
=20
 		e_info(drv, "enabling bridge mode: %s\n",
-			mode =3D=3D BRIDGE_MODE_VEPA ? "VEPA" : "VEB");
+		       mode =3D=3D BRIDGE_MODE_VEPA ? "VEPA" : "VEB");
 	}
=20
 	return 0;
@@ -8503,7 +8493,7 @@ static pci_ers_result_t ixgbe_io_slot_reset(struc=
t pci_dev *pdev)
 	int err;
=20
 	if (pci_enable_device_mem(pdev)) {
-		e_err(probe, "Cannot re-enable PCI device after reset.\n");
+		e_err(probe, "Cannot re-enable PCI device after reset\n");
 		result =3D PCI_ERS_RESULT_DISCONNECT;
 	} else {
 		adapter->hw.hw_addr =3D adapter->io_addr;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c b/drivers/net=
/ethernet/intel/ixgbe/ixgbe_phy.c
index d2caae4..9ee8e64 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
@@ -1174,7 +1174,7 @@ s32 ixgbe_identify_sfp_module_generic(struct ixgb=
e_hw *hw)
 				status =3D 0;
 			} else {
 				if (hw->allow_unsupported_sfp) {
-					e_warn(drv, "WARNING: Intel (R) Network Connections are quality t=
ested using Intel (R) Ethernet Optics.  Using untested modules is not s=
upported and may cause unstable operation or damage to the module or th=
e adapter.  Intel Corporation is not responsible for any harm caused by=
 using untested modules.");
+					e_warn(drv, "WARNING: Intel (R) Network Connections are quality t=
ested using Intel (R) Ethernet Optics.  Using untested modules is not s=
upported and may cause unstable operation or damage to the module or th=
e adapter.  Intel Corporation is not responsible for any harm caused by=
 using untested modules.\n");
 					status =3D 0;
 				} else {
 					hw_dbg(hw,
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c b/drivers/net=
/ethernet/intel/ixgbe/ixgbe_ptp.c
index 9ef730f..c23d3ad 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
@@ -460,7 +460,7 @@ void ixgbe_ptp_rx_hang(struct ixgbe_adapter *adapte=
r)
 		IXGBE_READ_REG(hw, IXGBE_RXSTMPH);
 		adapter->last_rx_ptp_check =3D jiffies;
=20
-		e_warn(drv, "clearing RX Timestamp hang");
+		e_warn(drv, "clearing RX Timestamp hang\n");
 	}
 }
=20
@@ -518,7 +518,7 @@ static void ixgbe_ptp_tx_hwtstamp_work(struct work_=
struct *work)
 	if (timeout) {
 		dev_kfree_skb_any(adapter->ptp_tx_skb);
 		adapter->ptp_tx_skb =3D NULL;
-		e_warn(drv, "clearing Tx Timestamp hang");
+		e_warn(drv, "clearing Tx Timestamp hang\n");
 		return;
 	}
=20
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/n=
et/ethernet/intel/ixgbe/ixgbe_sriov.c
index dff0977..a90814e 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
@@ -164,8 +164,7 @@ void ixgbe_enable_sriov(struct ixgbe_adapter *adapt=
er)
 	/* If we have gotten to this point then there is no memory available
 	 * to manage the VF devices - print message and bail.
 	 */
-	e_err(probe, "Unable to allocate memory for VF Data Storage - "
-	      "SRIOV disabled\n");
+	e_err(probe, "Unable to allocate memory for VF Data Storage - SRIOV d=
isabled\n");
 	ixgbe_disable_sriov(adapter);
 }
=20
