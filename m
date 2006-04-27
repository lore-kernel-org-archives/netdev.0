From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH 30/32] rt2x00: Correctly initialize TX power in registers
Date: Fri, 28 Apr 2006 00:03:20 +0200
Message-ID: <200604280003.20622.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1164780.4yLMLb2Lj8";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: rt2x00-devel@lfcorreia.dyndns.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nproxy.gmail.com ([64.233.182.184]:37997 "EHLO nproxy.gmail.com")
	by vger.kernel.org with ESMTP id S1751802AbWD0WCU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2006 18:02:20 -0400
Received: by nproxy.gmail.com with SMTP id n29so1463914nfc
        for <netdev@vger.kernel.org>; Thu, 27 Apr 2006 15:02:20 -0700 (PDT)
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1164780.4yLMLb2Lj8
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

=46rom: Ivo van Doorn <IvDoorn@gmail.com>

The rate does not need to be configured for each
TX packet. The actual rate for sending is determined
in the PLCP, the rate configuration is only capable
of setting the supported rates, which is dependent
of the physical mode we are in.
When we the configuration function is called,
disable the RX for proper behaviour.

Signed-off-by: Ivo van Doorn <IvDoorn@gmail.com>

diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2400pci=
=2Ec wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2400pci=
=2Ec
=2D-- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	20=
06-04-27 22:04:47.000000000 +0200
+++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2400pci.=
c	2006-04-27 22:05:21.000000000 +0200
@@ -660,6 +660,22 @@ rt2400pci_config_rate(struct rt2x00_pci=20
 }
=20
 static void
+rt2400pci_config_phymode(struct rt2x00_pci *rt2x00pci, const int phymode)
+{
+	struct ieee80211_rate	*rate;
+
+	rate =3D &rt2x00pci->hw.modes[0].rates[
+		rt2x00pci->hw.modes[0].num_rates - 1];
+
+	rt2400pci_config_rate(rt2x00pci, rate->val2);
+
+	/*
+	 * Update physical mode for rx ring.
+	 */
+	rt2x00pci->rx_params.phymode =3D phymode;
+}
+
+static void
 rt2400pci_config_mac_address(struct rt2x00_pci *rt2x00pci, void *addr)
 {
 	u32			reg[2] =3D {0, 0};
@@ -815,11 +831,6 @@ rt2400pci_write_tx_desc(
 	u16			signal;
 	u16			service;
=20
=2D	/*
=2D	 * Update rate control register.
=2D	 */
=2D	rt2400pci_config_rate(rt2x00pci, control->tx_rate);
=2D
 	rt2x00_set_field32(&txd->word0, TXD_W0_VALID, 1);
 	rt2x00_set_field32(&txd->word0, TXD_W0_ACK, !control->no_ack);
=20
@@ -1545,14 +1556,6 @@ rt2400pci_tx(struct net_device *net_dev,
=20
 	rt2x00_ring_index_inc(ring);
=20
=2D	/*
=2D	 * We are going to cheat now, we update the register
=2D	 * with the CWmin and CWmax values for the current
=2D	 * queue. This is the alternative since we cannot
=2D	 * set the CWmin and CWmax per descriptor.
=2D	 */
=2D	rt2400pci_config_cw(rt2x00pci, &ring->tx_params);
=2D
 	rt2x00_register_read(rt2x00pci, TXCSR0, &reg);
 	if (control->queue =3D=3D IEEE80211_TX_QUEUE_DATA0)
 		rt2x00_set_field32(&reg, TXCSR0_KICK_PRIO, 1);
@@ -1769,19 +1772,46 @@ rt2400pci_config_update(void *data)
 	struct rt2x00_pci	*rt2x00pci =3D data;
 	struct net_device	*net_dev =3D pci_get_drvdata(rt2x00pci->pci_dev);
 	struct ieee80211_conf	*conf =3D ieee80211_get_hw_conf(net_dev);
+	u32			reg;
+
+	/*
+	 * Some configuration changes require the RX to be disabled.
+	 */
+	if (GET_FLAG(rt2x00pci, RADIO_ENABLED)) {
+		rt2x00_register_read(rt2x00pci, RXCSR0, &reg);
+		rt2x00_set_field32(&reg, RXCSR0_DISABLE_RX, 1);
+		rt2x00_register_write(rt2x00pci, RXCSR0, reg);
+	}
=20
=2D	rt2400pci_config_bssid(rt2x00pci, conf->client_bssid);
=2D	rt2400pci_config_type(rt2x00pci, conf->mode);
 	rt2400pci_config_channel(rt2x00pci,
 		conf->channel_val, conf->channel, conf->freq);
 	rt2400pci_config_txpower(rt2x00pci, conf->power_level);
 	rt2400pci_config_antenna(rt2x00pci, conf->antenna_sel);
 	rt2400pci_config_duration(rt2x00pci, conf->short_slot_time);
+	rt2400pci_config_phymode(rt2x00pci, conf->phymode);
=20
 	/*
=2D	 * Update active info for RX.
+	 * Reenable RX only if the radio should be on.
 	 */
=2D	rt2x00pci->rx_params.phymode =3D conf->phymode;
+	if (conf->radio_enabled) {
+		if (!GET_FLAG(rt2x00pci, RADIO_ENABLED)) {
+			if (rt2400pci_open(net_dev)) {
+				ERROR("Failed to enabled radio.\n");
+				return;
+			}
+		} else {
+			rt2x00_register_read(rt2x00pci, RXCSR0, &reg);
+			rt2x00_set_field32(&reg, RXCSR0_DISABLE_RX, 0);
+			rt2x00_register_write(rt2x00pci, RXCSR0, reg);
+		}
+	} else {
+		if (GET_FLAG(rt2x00pci, RADIO_ENABLED)) {
+			if (rt2400pci_stop(net_dev)) {
+				ERROR("Failed to disable radio.\n");
+				return;
+			}
+		}
+	}
 }
=20
 static int
@@ -1863,8 +1893,8 @@ rt2400pci_scan(void *data)
 	 * Switch channel and update active info for RX.
 	 */
 	if (rt2x00pci->scan->state =3D=3D IEEE80211_SCAN_START) {
=2D		rt2x00pci->rx_params.phymode =3D
=2D			rt2x00pci->scan->conf.scan_phymode;
+		rt2400pci_config_phymode(rt2x00pci,
+			rt2x00pci->scan->conf.scan_phymode);
=20
 		rt2400pci_config_channel(rt2x00pci,
 			rt2x00pci->scan->conf.scan_channel_val,
@@ -1874,8 +1904,8 @@ rt2400pci_scan(void *data)
 		rt2400pci_config_txpower(rt2x00pci,
 			rt2x00pci->scan->conf.scan_power_level);
 	} else {
=2D		rt2x00pci->rx_params.phymode =3D
=2D			rt2x00pci->scan->conf.running_phymode;
+		rt2400pci_config_phymode(rt2x00pci,
+			rt2x00pci->scan->conf.running_phymode);
=20
 		rt2400pci_config_channel(rt2x00pci,
 			rt2x00pci->scan->conf.running_channel_val,
@@ -2000,10 +2030,6 @@ rt2400pci_conf_tx(struct net_device *net
 	memcpy(&ring->tx_params, params, sizeof(*params));
=20
 	/*
=2D	 * TODO: We can't use different cw_min and cw_max variables
=2D	 * per queue, we need to find a good method for dealing with
=2D	 * this shortage. Also we need to find a method to possibly
=2D	 * support the other values passed in ieee80211_tx_queue_params.
 	 * The passed variables are stored as real value ((2^n)-1).
 	 * RT2400 registers require to know the bit number 'n'.
 	 */
@@ -2017,6 +2043,11 @@ rt2400pci_conf_tx(struct net_device *net
 	else
 		ring->tx_params.cw_max =3D 10; /* cw_min: 2^10 =3D 1024. */
=20
+	/*
+	 * Write configuration to register.
+	 */
+	rt2400pci_config_cw(rt2x00pci, &ring->tx_params);
+
 	return 0;
 }
=20
@@ -2330,7 +2361,7 @@ rt2400pci_init_hw(struct rt2x00_pci *rt2
 	 * RF2420 is capable of faster channel switches.
 	 */
 	if (rt2x00_rf(&rt2x00pci->chip, RF2420))
=2D		hw->channel_change_time =3D 100;
+		hw->channel_change_time =3D 150;
 	else
 		hw->channel_change_time =3D 2500;
=20
diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500pci=
=2Ec wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500pci=
=2Ec
=2D-- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	20=
06-04-27 22:04:47.000000000 +0200
+++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500pci.=
c	2006-04-27 22:05:21.000000000 +0200
@@ -703,6 +703,30 @@ rt2500pci_config_rate(struct rt2x00_pci=20
 }
=20
 static void
+rt2500pci_config_phymode(struct rt2x00_pci *rt2x00pci, const int phymode)
+{
+	struct ieee80211_rate	*rate;
+
+	if (phymode =3D=3D MODE_IEEE80211A
+	&& rt2x00_rf(&rt2x00pci->chip, RF5222))
+		rate =3D &rt2x00pci->hw.modes[2].rates[
+			rt2x00pci->hw.modes[2].num_rates - 1];
+	else if (phymode =3D=3D MODE_IEEE80211B)
+		rate =3D &rt2x00pci->hw.modes[1].rates[
+			rt2x00pci->hw.modes[1].num_rates - 1];
+	else
+		rate =3D &rt2x00pci->hw.modes[0].rates[
+			rt2x00pci->hw.modes[0].num_rates - 1];
+
+	rt2500pci_config_rate(rt2x00pci, rate->val2);
+
+	/*
+	 * Update physical mode for rx ring.
+	 */
+	rt2x00pci->rx_params.phymode =3D phymode;
+}
+
+static void
 rt2500pci_config_mac_address(struct rt2x00_pci *rt2x00pci, void *addr)
 {
 	u32			reg[2] =3D {0, 0};
@@ -870,11 +894,6 @@ rt2500pci_write_tx_desc(
 	u16			service;
 	u8			rate;
=20
=2D	/*
=2D	 * Update rate control register.
=2D	 */
=2D	rt2500pci_config_rate(rt2x00pci, control->tx_rate);
=2D
 	rt2x00_set_field32(&txd->word0, TXD_W0_VALID, 1);
 	rt2x00_set_field32(&txd->word0, TXD_W0_ACK, !control->no_ack);
=20
@@ -1879,19 +1898,46 @@ rt2500pci_config_update(void *data)
 	struct rt2x00_pci	*rt2x00pci =3D data;
 	struct net_device	*net_dev =3D pci_get_drvdata(rt2x00pci->pci_dev);
 	struct ieee80211_conf	*conf =3D ieee80211_get_hw_conf(net_dev);
+	u32			reg;
+
+	/*
+	 * Some configuration changes require the RX to be disabled.
+	 */
+	if (GET_FLAG(rt2x00pci, RADIO_ENABLED)) {
+		rt2x00_register_read(rt2x00pci, RXCSR0, &reg);
+		rt2x00_set_field32(&reg, RXCSR0_DISABLE_RX, 1);
+		rt2x00_register_write(rt2x00pci, RXCSR0, reg);
+	}
=20
=2D	rt2500pci_config_bssid(rt2x00pci, conf->client_bssid);
=2D	rt2500pci_config_type(rt2x00pci, conf->mode);
 	rt2500pci_config_channel(rt2x00pci,
 		conf->channel_val, conf->channel, conf->freq,
 		conf->power_level);
 	rt2500pci_config_antenna(rt2x00pci, conf->antenna_sel);
 	rt2500pci_config_duration(rt2x00pci, conf->short_slot_time);
+	rt2500pci_config_phymode(rt2x00pci, conf->phymode);
=20
 	/*
=2D	 * Update active info for RX.
+	 * Reenable RX only if the radio should be on.
 	 */
=2D	rt2x00pci->rx_params.phymode =3D conf->phymode;
+	if (conf->radio_enabled) {
+		if (!GET_FLAG(rt2x00pci, RADIO_ENABLED)) {
+			if (rt2500pci_open(net_dev)) {
+				ERROR("Failed to enabled radio.\n");
+				return;
+			}
+		} else {
+			rt2x00_register_read(rt2x00pci, RXCSR0, &reg);
+			rt2x00_set_field32(&reg, RXCSR0_DISABLE_RX, 0);
+			rt2x00_register_write(rt2x00pci, RXCSR0, reg);
+		}
+	} else {
+		if (GET_FLAG(rt2x00pci, RADIO_ENABLED)) {
+			if (rt2500pci_stop(net_dev)) {
+				ERROR("Failed to disable radio.\n");
+				return;
+			}
+		}
+	}
 }
=20
 static int
@@ -1973,17 +2019,17 @@ rt2500pci_scan(void *data)
 	 * Switch channel and update active info for RX.
 	 */
 	if (rt2x00pci->scan->state =3D=3D IEEE80211_SCAN_START) {
=2D		rt2x00pci->rx_params.phymode =3D
=2D			rt2x00pci->scan->conf.scan_phymode;
=2D=09
+		rt2500pci_config_phymode(rt2x00pci,
+			rt2x00pci->scan->conf.scan_phymode);
+
 		rt2500pci_config_channel(rt2x00pci,
 			rt2x00pci->scan->conf.scan_channel_val,
 			rt2x00pci->scan->conf.scan_channel,
 			rt2x00pci->scan->conf.scan_freq,
 			rt2x00pci->scan->conf.scan_power_level);
 	} else {
=2D		rt2x00pci->rx_params.phymode =3D
=2D			rt2x00pci->scan->conf.running_phymode;
+		rt2500pci_config_phymode(rt2x00pci,
+			rt2x00pci->scan->conf.running_phymode);
 =09
 		rt2500pci_config_channel(rt2x00pci,
 			rt2x00pci->scan->conf.running_channel_val,
@@ -2570,7 +2616,7 @@ rt2500pci_init_hw(struct rt2x00_pci *rt2
 	hw->device_strips_mic =3D 0;
 	hw->monitor_during_oper =3D 1;
 	hw->fraglist =3D 0;
=2D	hw->channel_change_time =3D 2500;
+	hw->channel_change_time =3D 2000;
=20
 	/*
 	 * We have 2 TX queues: TX and PRIO.
diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500usb=
=2Ec wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500usb=
=2Ec
=2D-- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	20=
06-04-27 22:04:47.000000000 +0200
+++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500usb.=
c	2006-04-27 22:05:21.000000000 +0200
@@ -384,6 +384,12 @@ rt2500usb_config_channel(struct rt2x00_u
 	rt2x00_rf_write(rt2x00usb, rf3);
 	if (rf4)
 		rt2x00_rf_write(rt2x00usb, rf4);
+
+	/*
+	 * Update active info for RX.
+	 */
+	rt2x00usb->rx_params.freq =3D freq;
+	rt2x00usb->rx_params.channel =3D channel;
 }
=20
 static void
@@ -509,9 +515,32 @@ rt2500usb_config_rate(struct rt2x00_usb=20
 }
=20
 static void
=2Drt2500usb_config_mac_address(struct net_device *net_dev, void *addr)
+rt2500usb_config_phymode(struct rt2x00_usb *rt2x00usb, const int phymode)
+{
+	struct ieee80211_rate	*rate;
+
+	if (phymode =3D=3D MODE_IEEE80211A
+	&& rt2x00_rf(&rt2x00usb->chip, RF5222))
+		rate =3D &rt2x00usb->hw.modes[2].rates[
+			rt2x00usb->hw.modes[2].num_rates - 1];
+	else if (phymode =3D=3D MODE_IEEE80211B)
+		rate =3D &rt2x00usb->hw.modes[1].rates[
+			rt2x00usb->hw.modes[1].num_rates - 1];
+	else
+		rate =3D &rt2x00usb->hw.modes[0].rates[
+			rt2x00usb->hw.modes[0].num_rates - 1];
+
+	rt2500usb_config_rate(rt2x00usb, rate->val2);
+
+	/*
+	 * Update physical mode for rx ring.
+	 */
+	rt2x00usb->rx_params.phymode =3D phymode;
+}
+
+static void
+rt2500usb_config_mac_address(struct rt2x00_usb *rt2x00usb, void *addr)
 {
=2D	struct rt2x00_usb	*rt2x00usb =3D ieee80211_dev_hw_data(net_dev);
 	u16			reg[3] =3D {0, 0, 0};
=20
 	rt2x00_set_field16_nb(&reg[0], MAC_CSR2_BYTE0, ((u8*)addr)[0]);
@@ -698,11 +727,6 @@ rt2500usb_write_tx_desc(
 	u8			service;
 	u8			rate;
=20
=2D	/*
=2D	 * Update rate control register.
=2D	 */
=2D	rt2500usb_config_rate(rt2x00usb, control->tx_rate);
=2D
 	rt2x00_set_field32(&txd->word0, TXD_W0_ACK, !control->no_ack);
=20
 	ring =3D rt2x00usb_get_ring(rt2x00usb, control->queue);
@@ -1546,19 +1570,46 @@ rt2500usb_config_update(void *data)
 	struct net_device	*net_dev =3D
 		usb_get_intfdata(rt2x00usb->usb_intf);
 	struct ieee80211_conf	*conf =3D ieee80211_get_hw_conf(net_dev);
+	u16			reg;
+
+	/*
+	 * Some configuration changes require the RX to be disabled.
+	 */
+	if (GET_FLAG(rt2x00usb, RADIO_ENABLED)) {
+		rt2x00_register_read(rt2x00usb, TXRX_CSR2, &reg);
+		rt2x00_set_field16_nb(&reg, TXRX_CSR2_DISABLE_RX, 1);
+		rt2x00_register_write(rt2x00usb, TXRX_CSR2, reg);
+	}
=20
=2D	rt2500usb_config_bssid(rt2x00usb, conf->client_bssid);
=2D	rt2500usb_config_type(rt2x00usb, conf->mode);
 	rt2500usb_config_channel(rt2x00usb,
 		conf->channel_val, conf->channel, conf->freq,
 		conf->power_level);
 	rt2500usb_config_antenna(rt2x00usb, conf->antenna_sel);
 	rt2500usb_config_duration(rt2x00usb, conf->short_slot_time);
+	rt2500usb_config_phymode(rt2x00usb, conf->phymode);
=20
 	/*
=2D	 * Update active info for RX.
+	 * Reenable RX only if the radio should be on.
 	 */
=2D	rt2x00usb->rx_params.phymode =3D conf->phymode;
+	if (conf->radio_enabled) {
+		if (!GET_FLAG(rt2x00usb, RADIO_ENABLED)) {
+			if (rt2500usb_open(net_dev)) {
+				ERROR("Failed to enabled radio.\n");
+				return;
+			}
+		} else {
+			rt2x00_register_read(rt2x00usb, TXRX_CSR2, &reg);
+			rt2x00_set_field16_nb(&reg, TXRX_CSR2_DISABLE_RX, 0);
+			rt2x00_register_write(rt2x00usb, TXRX_CSR2, reg);
+		}
+	} else {
+		if (GET_FLAG(rt2x00usb, RADIO_ENABLED)) {
+			if (rt2500usb_stop(net_dev)) {
+				ERROR("Failed to disable radio.\n");
+				return;
+			}
+		}
+	}
 }
=20
 static int
@@ -1640,8 +1691,8 @@ rt2500usb_scan(void *data)
 	 * Switch channel and update active info for RX.
 	 */
 	if (rt2x00usb->scan->state =3D=3D IEEE80211_SCAN_START) {
=2D		rt2x00usb->rx_params.phymode =3D
=2D			rt2x00usb->scan->conf.scan_phymode;
+		rt2500usb_config_phymode(rt2x00usb,
+			rt2x00usb->scan->conf.scan_phymode);
 =09
 		rt2500usb_config_channel(rt2x00usb,
 			rt2x00usb->scan->conf.scan_channel_val,
@@ -1649,8 +1700,8 @@ rt2500usb_scan(void *data)
 			rt2x00usb->scan->conf.scan_freq,
 			rt2x00usb->scan->conf.scan_power_level);
 	} else {
=2D		rt2x00usb->rx_params.phymode =3D
=2D			rt2x00usb->scan->conf.running_phymode;
+		rt2500usb_config_phymode(rt2x00usb,
+			rt2x00usb->scan->conf.running_phymode);
 =09
 		rt2500usb_config_channel(rt2x00usb,
 			rt2x00usb->scan->conf.running_channel_val,
@@ -2186,7 +2237,7 @@ rt2500usb_init_hw(struct rt2x00_usb *rt2
 	hw->device_strips_mic =3D 0;
 	hw->monitor_during_oper =3D 1;
 	hw->fraglist =3D 0;
=2D	hw->channel_change_time =3D 500;
+	hw->channel_change_time =3D 500000;
=20
 	/*
 	 * We have 2 TX queues: TX and PRIO.

--nextPart1164780.4yLMLb2Lj8
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBEUT+oaqndE37Em0gRAtEVAKCxn/mPw62+y3T0kKXi8myzf36TDACgqrFO
MSCMWFEc3a1h4j7omG2mWTs=
=JVWn
-----END PGP SIGNATURE-----

--nextPart1164780.4yLMLb2Lj8--
