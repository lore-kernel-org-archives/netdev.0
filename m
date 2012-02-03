From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless 2012-02-03
Date: Fri, 3 Feb 2012 14:29:18 -0500
Message-ID: <20120203192917.GE15601@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="EeQfGwPcQSOJBaQU"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--EeQfGwPcQSOJBaQU
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

commit 157ca9eae92bc5247f93bea4ecb50dfacc283a04

Dave,

Here is a little batch of fixes intended for 3.3...

We have a fix from Eliad Peller for an off-by-one error in mac80211 that
was preventing a timeout.  Emmanuel Grumbach provides an iwlwifi fix to
avoid incorrect manipulations on non-QoS frames that were stalling the
Tx queues.  Hauke Mehrtens provides another off-by-one fix, this one for
the SSB bus.  Jesper Juhl provies us with a fix for a memory leak in the
BCMA code.  A fix to avoid some log spam from iwlwifi is provided by me.
Finally, Luigi Tarenga provides an rt2800 fix to correctly report signal
strength.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 29830406415c227a54af429d7b300aabd4754237:

  can: peak_pci: Fix the way channels are linked together (2012-02-03 00:26=
:27 +0100)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git for-d=
avem

Eliad Peller (1):
      mac80211: timeout a single frame in the rx reorder buffer

Emmanuel Grumbach (1):
      iwlwifi: don't mess up QoS counters with non-QoS frames

Hauke Mehrtens (1):
      ssb: fix cardbus slot in hostmode

Jesper Juhl (1):
      bcma: Fix mem leak in bcma_bus_scan()

John W. Linville (2):
      iwlwifi: make "Tx aggregation enabled on ra =3D" be at DEBUG level
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless i=
nto for-davem

Luigi Tarenga (1):
      rt2800lib: fix wrong -128dBm when signal is stronger than -12dBm

 drivers/bcma/scan.c                           |   19 +++++++++++--------
 drivers/net/wireless/iwlwifi/iwl-agn-tx.c     |   14 ++++++++++----
 drivers/net/wireless/iwlwifi/iwl-commands.h   |    1 +
 drivers/net/wireless/iwlwifi/iwl-trans-pcie.c |    1 +
 drivers/net/wireless/rt2x00/rt2800lib.c       |    8 ++++----
 drivers/ssb/driver_pcicore.c                  |    2 +-
 net/mac80211/rx.c                             |    2 +-
 7 files changed, 29 insertions(+), 18 deletions(-)
diff --git a/drivers/bcma/scan.c b/drivers/bcma/scan.c
index cad9948..3a2f672 100644
--- a/drivers/bcma/scan.c
+++ b/drivers/bcma/scan.c
@@ -399,15 +399,18 @@ int bcma_bus_scan(struct bcma_bus *bus)
 		core->bus =3D bus;
=20
 		err =3D bcma_get_next_core(bus, &eromptr, NULL, core_num, core);
-		if (err =3D=3D -ENODEV) {
-			core_num++;
-			continue;
-		} else if (err =3D=3D -ENXIO)
-			continue;
-		else if (err =3D=3D -ESPIPE)
-			break;
-		else if (err < 0)
+		if (err < 0) {
+			kfree(core);
+			if (err =3D=3D -ENODEV) {
+				core_num++;
+				continue;
+			} else if (err =3D=3D -ENXIO) {
+				continue;
+			} else if (err =3D=3D -ESPIPE) {
+				break;
+			}
 			return err;
+		}
=20
 		core->core_index =3D core_num++;
 		bus->nr_cores++;
diff --git a/drivers/net/wireless/iwlwifi/iwl-agn-tx.c b/drivers/net/wirele=
ss/iwlwifi/iwl-agn-tx.c
index c664c27..63bbc60 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn-tx.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn-tx.c
@@ -91,6 +91,7 @@ static void iwlagn_tx_cmd_build_basic(struct iwl_priv *pr=
iv,
 		tx_cmd->tid_tspec =3D qc[0] & 0xf;
 		tx_flags &=3D ~TX_CMD_FLG_SEQ_CTL_MSK;
 	} else {
+		tx_cmd->tid_tspec =3D IWL_TID_NON_QOS;
 		if (info->flags & IEEE80211_TX_CTL_ASSIGN_SEQ)
 			tx_flags |=3D TX_CMD_FLG_SEQ_CTL_MSK;
 		else
@@ -620,7 +621,7 @@ int iwlagn_tx_agg_oper(struct iwl_priv *priv, struct ie=
ee80211_vif *vif,
 	sta_priv->lq_sta.lq.agg_params.agg_frame_cnt_limit =3D
 		sta_priv->max_agg_bufsize;
=20
-	IWL_INFO(priv, "Tx aggregation enabled on ra =3D %pM tid =3D %d\n",
+	IWL_DEBUG_HT(priv, "Tx aggregation enabled on ra =3D %pM tid =3D %d\n",
 		 sta->addr, tid);
=20
 	return iwl_send_lq_cmd(priv, ctx,
@@ -808,6 +809,8 @@ static void iwl_rx_reply_tx_agg(struct iwl_priv *priv,
 	u32 status =3D le16_to_cpu(tx_resp->status.status);
 	int i;
=20
+	WARN_ON(tid =3D=3D IWL_TID_NON_QOS);
+
 	if (agg->wait_for_ba)
 		IWL_DEBUG_TX_REPLY(priv,
 			"got tx response w/o block-ack\n");
@@ -1035,10 +1038,13 @@ int iwlagn_rx_reply_tx(struct iwl_priv *priv, struc=
t iwl_rx_mem_buffer *rxb,
 		}
=20
 		__skb_queue_head_init(&skbs);
-		priv->tid_data[sta_id][tid].next_reclaimed =3D next_reclaimed;
=20
-		IWL_DEBUG_TX_REPLY(priv, "Next reclaimed packet:%d",
-					  next_reclaimed);
+		if (tid !=3D IWL_TID_NON_QOS) {
+			priv->tid_data[sta_id][tid].next_reclaimed =3D
+				next_reclaimed;
+			IWL_DEBUG_TX_REPLY(priv, "Next reclaimed packet:%d",
+						  next_reclaimed);
+		}
=20
 		/*we can free until ssn % q.n_bd not inclusive */
 		WARN_ON(iwl_trans_reclaim(trans(priv), sta_id, tid, txq_id,
diff --git a/drivers/net/wireless/iwlwifi/iwl-commands.h b/drivers/net/wire=
less/iwlwifi/iwl-commands.h
index 265de39..f822ac4 100644
--- a/drivers/net/wireless/iwlwifi/iwl-commands.h
+++ b/drivers/net/wireless/iwlwifi/iwl-commands.h
@@ -815,6 +815,7 @@ struct iwl_qosparam_cmd {
=20
 #define	IWL_INVALID_STATION 	255
 #define IWL_MAX_TID_COUNT	8
+#define IWL_TID_NON_QOS IWL_MAX_TID_COUNT
=20
 #define STA_FLG_TX_RATE_MSK		cpu_to_le32(1 << 2)
 #define STA_FLG_PWR_SAVE_MSK		cpu_to_le32(1 << 8)
diff --git a/drivers/net/wireless/iwlwifi/iwl-trans-pcie.c b/drivers/net/wi=
reless/iwlwifi/iwl-trans-pcie.c
index 67d6e32..324d06d 100644
--- a/drivers/net/wireless/iwlwifi/iwl-trans-pcie.c
+++ b/drivers/net/wireless/iwlwifi/iwl-trans-pcie.c
@@ -1262,6 +1262,7 @@ static int iwl_trans_pcie_reclaim(struct iwl_trans *t=
rans, int sta_id, int tid,
 	txq->time_stamp =3D jiffies;
=20
 	if (unlikely(txq_id >=3D IWLAGN_FIRST_AMPDU_QUEUE &&
+		     tid !=3D IWL_TID_NON_QOS &&
 		     txq_id !=3D trans_pcie->agg_txq[sta_id][tid])) {
 		/*
 		 * FIXME: this is a uCode bug which need to be addressed,
diff --git a/drivers/net/wireless/rt2x00/rt2800lib.c b/drivers/net/wireless=
/rt2x00/rt2800lib.c
index 22a1a8f..7bef66d 100644
--- a/drivers/net/wireless/rt2x00/rt2800lib.c
+++ b/drivers/net/wireless/rt2x00/rt2800lib.c
@@ -514,9 +514,9 @@ EXPORT_SYMBOL_GPL(rt2800_write_tx_data);
=20
 static int rt2800_agc_to_rssi(struct rt2x00_dev *rt2x00dev, u32 rxwi_w2)
 {
-	int rssi0 =3D rt2x00_get_field32(rxwi_w2, RXWI_W2_RSSI0);
-	int rssi1 =3D rt2x00_get_field32(rxwi_w2, RXWI_W2_RSSI1);
-	int rssi2 =3D rt2x00_get_field32(rxwi_w2, RXWI_W2_RSSI2);
+	s8 rssi0 =3D rt2x00_get_field32(rxwi_w2, RXWI_W2_RSSI0);
+	s8 rssi1 =3D rt2x00_get_field32(rxwi_w2, RXWI_W2_RSSI1);
+	s8 rssi2 =3D rt2x00_get_field32(rxwi_w2, RXWI_W2_RSSI2);
 	u16 eeprom;
 	u8 offset0;
 	u8 offset1;
@@ -552,7 +552,7 @@ static int rt2800_agc_to_rssi(struct rt2x00_dev *rt2x00=
dev, u32 rxwi_w2)
 	 * which gives less energy...
 	 */
 	rssi0 =3D max(rssi0, rssi1);
-	return max(rssi0, rssi2);
+	return (int)max(rssi0, rssi2);
 }
=20
 void rt2800_process_rxwi(struct queue_entry *entry,
diff --git a/drivers/ssb/driver_pcicore.c b/drivers/ssb/driver_pcicore.c
index 520e828..49d2091 100644
--- a/drivers/ssb/driver_pcicore.c
+++ b/drivers/ssb/driver_pcicore.c
@@ -75,7 +75,7 @@ static u32 get_cfgspace_addr(struct ssb_pcicore *pc,
 	u32 tmp;
=20
 	/* We do only have one cardbus device behind the bridge. */
-	if (pc->cardbusmode && (dev >=3D 1))
+	if (pc->cardbusmode && (dev > 1))
 		goto out;
=20
 	if (bus =3D=3D 0) {
diff --git a/net/mac80211/rx.c b/net/mac80211/rx.c
index 7514091..5a5e504 100644
--- a/net/mac80211/rx.c
+++ b/net/mac80211/rx.c
@@ -611,7 +611,7 @@ static void ieee80211_sta_reorder_release(struct ieee80=
211_hw *hw,
 	index =3D seq_sub(tid_agg_rx->head_seq_num, tid_agg_rx->ssn) %
 						tid_agg_rx->buf_size;
 	if (!tid_agg_rx->reorder_buf[index] &&
-	    tid_agg_rx->stored_mpdu_num > 1) {
+	    tid_agg_rx->stored_mpdu_num) {
 		/*
 		 * No buffers ready to be released, but check whether any
 		 * frames in the reorder buffer have timed out.
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--EeQfGwPcQSOJBaQU
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBAgAGBQJPLDWNAAoJEJctW/TcYTgGoBoP/1/3AlY2NGHBKlejn1STZWV1
2Ef7vdP03Zj2pATOJ6BuVTOQVeL0ZceBfMhW8H4ZXuBAqS2TBBsXp6BHK2S/3wqL
22Xx01grE82Kysr9uXWGCImaNXe1KgRa32ElaOPA2rBoyyPmUONAvLPSr4xk+EEW
/N9m1w6RNswoEhgP4kwiFyk5OPMKP0T8e97H8qs3qB9rL/jF56NhooDRSYQtKio9
Hbmo3EOL9P/sBLfGU1y9LptzQO38aKwBpFkHFAZUAxlRTREU+bf/nxrZ5xtVm+rB
jw2uptElJ7TCYnnu+AnWtpuh6NXCI9eyvY8Fg5as/kRfQUFmpctqiAYXF5ig/k1d
7wUIR1+4+8m2T4D6tWWK6SiCEO/bE4uPtMup4SbpY1zUg7mwM2qq9vOx5Y96DWVl
2iMu8RRvw32mLSIgBS7aKvrFrolvR/VhHKYnAc/KIcoV74JZf9AGzdkRy3BvYCOs
xBFVAOxd52Hxwy28qTQcrSTDg3RyaHyt4rf0RyF3KMP2o9z4hRlflYTFeXeVKegl
4iJWLzi7+vd1jhHZ0RtC+D2FZMalqHF6Y7sNyWLqGwSKXWYCGVHMp1apmfxbQuRL
ndrTxPEyQRWOq5sTcz2smr0JID8G2fvTw8TCGBNSVZBgTimd+SmcVppF/nnEidWI
3bTl5tM5GUbHc1TpeiXw
=5pmD
-----END PGP SIGNATURE-----

--EeQfGwPcQSOJBaQU--
