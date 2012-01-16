From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless 2012-01-16
Date: Mon, 16 Jan 2012 14:54:35 -0500
Message-ID: <20120116195435.GB12733@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="SLDf9lqlvOQaIe6s"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--SLDf9lqlvOQaIe6s
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

commit 543d1b92d5500841e70f15e79d197bbffed36561

Dave,

Here is a set of fixes for 3.3 that I let cook over the weekend...

Included is a fix for a signedness bug in ipw2x00 from Dan Carpenter, a
fix for an oops when ejecting a b43 card from Guennadi Liakhovetski
(with a minor modification by me as noted in the changelog), a mac80211
regresion fix from Johannes Berg for a bug related to station
management, and a final fix for the rt2800pci spurious interrupt issue
=66rom Stanislaw Gruszka.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 7c7c7f01cc5e3e423120a4848a73dd5e4586f2f9:

  vhost-net: add module alias (v2.1) (2012-01-13 10:12:23 -0800)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git for-d=
avem

Dan Carpenter (1):
      ipw2x00: signedness bug handling frame length

Guennadi Liakhovetski (1):
      wireless: b43: fix Oops on card eject during transfer

Johannes Berg (1):
      mac80211: fix no-op authorized transitions

Stanislaw Gruszka (1):
      rt2800pci: fix spurious interrupts generation

 drivers/net/wireless/b43/main.c         |    5 ++++-
 drivers/net/wireless/ipw2x00/ipw2200.c  |    4 ++--
 drivers/net/wireless/rt2x00/rt2800pci.c |   28 ++++++++--------------------
 net/mac80211/cfg.c                      |    2 +-
 4 files changed, 15 insertions(+), 24 deletions(-)

diff --git a/drivers/net/wireless/b43/main.c b/drivers/net/wireless/b43/mai=
n.c
index 1c6f193..b91f28e 100644
--- a/drivers/net/wireless/b43/main.c
+++ b/drivers/net/wireless/b43/main.c
@@ -4852,6 +4852,9 @@ static void b43_op_stop(struct ieee80211_hw *hw)
=20
 	cancel_work_sync(&(wl->beacon_update_trigger));
=20
+	if (!dev)
+		goto out;
+
 	mutex_lock(&wl->mutex);
 	if (b43_status(dev) >=3D B43_STAT_STARTED) {
 		dev =3D b43_wireless_core_stop(dev);
@@ -4863,7 +4866,7 @@ static void b43_op_stop(struct ieee80211_hw *hw)
=20
 out_unlock:
 	mutex_unlock(&wl->mutex);
-
+out:
 	cancel_work_sync(&(wl->txpower_adjust_work));
 }
=20
diff --git a/drivers/net/wireless/ipw2x00/ipw2200.c b/drivers/net/wireless/=
ipw2x00/ipw2200.c
index 018a8de..4fcdac6 100644
--- a/drivers/net/wireless/ipw2x00/ipw2200.c
+++ b/drivers/net/wireless/ipw2x00/ipw2200.c
@@ -7848,7 +7848,7 @@ static void ipw_handle_data_packet_monitor(struct ipw=
_priv *priv,
 	 * more efficiently than we can parse it. ORDER MATTERS HERE */
 	struct ipw_rt_hdr *ipw_rt;
=20
-	short len =3D le16_to_cpu(pkt->u.frame.length);
+	unsigned short len =3D le16_to_cpu(pkt->u.frame.length);
=20
 	/* We received data from the HW, so stop the watchdog */
 	dev->trans_start =3D jiffies;
@@ -8023,7 +8023,7 @@ static void ipw_handle_promiscuous_rx(struct ipw_priv=
 *priv,
 	s8 signal =3D frame->rssi_dbm - IPW_RSSI_TO_DBM;
 	s8 noise =3D (s8) le16_to_cpu(frame->noise);
 	u8 rate =3D frame->rate;
-	short len =3D le16_to_cpu(pkt->u.frame.length);
+	unsigned short len =3D le16_to_cpu(pkt->u.frame.length);
 	struct sk_buff *skb;
 	int hdr_only =3D 0;
 	u16 filter =3D priv->prom_priv->filter;
diff --git a/drivers/net/wireless/rt2x00/rt2800pci.c b/drivers/net/wireless=
/rt2x00/rt2800pci.c
index 4941a1a..dc88bae 100644
--- a/drivers/net/wireless/rt2x00/rt2800pci.c
+++ b/drivers/net/wireless/rt2x00/rt2800pci.c
@@ -422,7 +422,6 @@ static int rt2800pci_init_queues(struct rt2x00_dev *rt2=
x00dev)
 static void rt2800pci_toggle_irq(struct rt2x00_dev *rt2x00dev,
 				 enum dev_state state)
 {
-	int mask =3D (state =3D=3D STATE_RADIO_IRQ_ON);
 	u32 reg;
 	unsigned long flags;
=20
@@ -436,25 +435,14 @@ static void rt2800pci_toggle_irq(struct rt2x00_dev *r=
t2x00dev,
 	}
=20
 	spin_lock_irqsave(&rt2x00dev->irqmask_lock, flags);
-	rt2x00pci_register_read(rt2x00dev, INT_MASK_CSR, &reg);
-	rt2x00_set_field32(&reg, INT_MASK_CSR_RXDELAYINT, 0);
-	rt2x00_set_field32(&reg, INT_MASK_CSR_TXDELAYINT, 0);
-	rt2x00_set_field32(&reg, INT_MASK_CSR_RX_DONE, mask);
-	rt2x00_set_field32(&reg, INT_MASK_CSR_AC0_DMA_DONE, 0);
-	rt2x00_set_field32(&reg, INT_MASK_CSR_AC1_DMA_DONE, 0);
-	rt2x00_set_field32(&reg, INT_MASK_CSR_AC2_DMA_DONE, 0);
-	rt2x00_set_field32(&reg, INT_MASK_CSR_AC3_DMA_DONE, 0);
-	rt2x00_set_field32(&reg, INT_MASK_CSR_HCCA_DMA_DONE, 0);
-	rt2x00_set_field32(&reg, INT_MASK_CSR_MGMT_DMA_DONE, 0);
-	rt2x00_set_field32(&reg, INT_MASK_CSR_MCU_COMMAND, 0);
-	rt2x00_set_field32(&reg, INT_MASK_CSR_RXTX_COHERENT, 0);
-	rt2x00_set_field32(&reg, INT_MASK_CSR_TBTT, mask);
-	rt2x00_set_field32(&reg, INT_MASK_CSR_PRE_TBTT, mask);
-	rt2x00_set_field32(&reg, INT_MASK_CSR_TX_FIFO_STATUS, mask);
-	rt2x00_set_field32(&reg, INT_MASK_CSR_AUTO_WAKEUP, mask);
-	rt2x00_set_field32(&reg, INT_MASK_CSR_GPTIMER, 0);
-	rt2x00_set_field32(&reg, INT_MASK_CSR_RX_COHERENT, 0);
-	rt2x00_set_field32(&reg, INT_MASK_CSR_TX_COHERENT, 0);
+	reg =3D 0;
+	if (state =3D=3D STATE_RADIO_IRQ_ON) {
+		rt2x00_set_field32(&reg, INT_MASK_CSR_RX_DONE, 1);
+		rt2x00_set_field32(&reg, INT_MASK_CSR_TBTT, 1);
+		rt2x00_set_field32(&reg, INT_MASK_CSR_PRE_TBTT, 1);
+		rt2x00_set_field32(&reg, INT_MASK_CSR_TX_FIFO_STATUS, 1);
+		rt2x00_set_field32(&reg, INT_MASK_CSR_AUTO_WAKEUP, 1);
+	}
 	rt2x00pci_register_write(rt2x00dev, INT_MASK_CSR, reg);
 	spin_unlock_irqrestore(&rt2x00dev->irqmask_lock, flags);
=20
diff --git a/net/mac80211/cfg.c b/net/mac80211/cfg.c
index e60df48..296620d 100644
--- a/net/mac80211/cfg.c
+++ b/net/mac80211/cfg.c
@@ -791,7 +791,7 @@ static int sta_apply_parameters(struct ieee80211_local =
*local,
 		if (set & BIT(NL80211_STA_FLAG_AUTHORIZED))
 			ret =3D sta_info_move_state_checked(sta,
 					IEEE80211_STA_AUTHORIZED);
-		else
+		else if (test_sta_flag(sta, WLAN_STA_AUTHORIZED))
 			ret =3D sta_info_move_state_checked(sta,
 					IEEE80211_STA_ASSOC);
 		if (ret)
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--SLDf9lqlvOQaIe6s
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBAgAGBQJPFIB6AAoJEJctW/TcYTgGddcP/jjLwDAVjVlbDq1BmAbNY79a
5HK/xF5b/PeVXCW2M4tf45PJoRS9nGk9S6av6xss/n6uUklhhoA+FLYYUN0pT0u5
duv/rNWXl+QgU0bUsFw+bRj8YfCgWZaQjg9AqVRI+7F/vlPn4+jis5jqxiQRFDIh
OVXia0r/FeLysJIDVV7Opf3epCLWjoOf7kRLgeYscRIJ3eN7qwgRekNQVrPhQy8Q
Np8I8eHmklvaqgmCHqj7S3MMDTDYpmAY+bcMuwZeCR44Ct4HYsbSKtxx4P/awlrT
MusubnWJLiRcyNINpTSkILA5Ig2t4JXU7tf30HnVexPgb0jLVxjr41kFuG0JMzoW
dKLa/OJeS/ozPJIqcHqitNmbwMBIYlv0pn85Q3jRZrybh1FKNDxc+4y74IuUDRmG
jZF8LBfptqyGvOI9pnBch7pfacN2FUypf6O97v+xWBfbAxorhDcvCA4Mu5SbNpWp
g1phsoZ9Y/4BkZCvllPcsk0w6rp2aL7ETsr+7rkMiAXUwmFniRWREU7IEDP5jFxE
QDquhCVC8ettH0dtU4+AplqLnl9Em3FQw+MiSGhaqkcUKwjLReUrKjR5Sxp5oX5X
TO+/cVGmi6QYCB3L6Psd9uzYo4iDRoQmhfyordEUMrMACyJJViXPAOeoMGbxLkLo
tfa/XuaLlxuemNbXpBpA
=v9+6
-----END PGP SIGNATURE-----

--SLDf9lqlvOQaIe6s--
