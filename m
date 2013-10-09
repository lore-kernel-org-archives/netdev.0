From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless 2013-10-09
Date: Wed, 9 Oct 2013 11:28:41 -0400
Message-ID: <20131009152841.GD14381@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="/04w6evG8XlLl3ft"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--/04w6evG8XlLl3ft
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Dave,

Please pull this batch of fixes intended for 3.12...

Most of the bits are for iwlwifi -- Johannes says:

"I have a fix for WoWLAN/D3, a PCIe device fix, we're removing a
warning, there's a fix for RF-kill while scanning (which goes together
with a mac80211 fix) and last but not least we have many new PCI IDs."

Also for iwlwifi is a patch from Johannes to correct some merge damage
that crept into the tree before the last merge window.

On top of that, Felix Fietkau sends an ath9k patch to avoid a Tx
scheduling hang when changing channels to do a scan.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 9684d7b0dab3cf3a897edd85dca501d413888d56:

  Merge branch 'sfc-3.12' of git://git.kernel.org/pub/scm/linux/kernel/git/=
bwh/sfc (2013-10-08 21:56:09 -0400)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git for-d=
avem

for you to fetch changes up to b26082b9945a9aca85d51be37824f852617c7129:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/li=
nville/wireless into for-davem (2013-10-09 11:19:05 -0400)

----------------------------------------------------------------

Alexander Bondar (1):
      iwlwifi: mvm: Disable uAPSD for D3 image

Emmanuel Grumbach (4):
      iwlwifi: pcie: don't reset the TX queue counter
      iwlwifi: don't WARN on host commands sent when firmware is dead
      iwlwifi: pcie: add SKUs for 6000, 6005 and 6235 series
      iwlwifi: mvm: call ieee80211_scan_completed when needed

Felix Fietkau (1):
      ath9k: fix tx queue scheduling after channel changes

Johannes Berg (1):
      iwlwifi: pcie: fix merge damage

John W. Linville (2):
      Merge branch 'for-john' of git://git.kernel.org/.../iwlwifi/iwlwifi-f=
ixes
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless i=
nto for-davem

Matti Gottlieb (1):
      iwlwifi: pcie: add new SKUs for 7000 & 3160 NIC series

 drivers/net/wireless/ath/ath9k/main.c     | 23 ++++++++---------
 drivers/net/wireless/iwlwifi/iwl-6000.c   |  6 +++++
 drivers/net/wireless/iwlwifi/iwl-config.h |  1 +
 drivers/net/wireless/iwlwifi/iwl-trans.h  |  6 +++--
 drivers/net/wireless/iwlwifi/mvm/power.c  |  5 +++-
 drivers/net/wireless/iwlwifi/mvm/scan.c   | 12 ++++++++-
 drivers/net/wireless/iwlwifi/pcie/drv.c   | 42 +++++++++++++++++++++++++++=
++++
 drivers/net/wireless/iwlwifi/pcie/trans.c |  8 +++---
 drivers/net/wireless/iwlwifi/pcie/tx.c    |  2 ++
 9 files changed, 85 insertions(+), 20 deletions(-)

diff --git a/drivers/net/wireless/ath/ath9k/main.c b/drivers/net/wireless/a=
th/ath9k/main.c
index e4f6590..709301f 100644
--- a/drivers/net/wireless/ath/ath9k/main.c
+++ b/drivers/net/wireless/ath/ath9k/main.c
@@ -208,6 +208,7 @@ static bool ath_complete_reset(struct ath_softc *sc, bo=
ol start)
 	struct ath_hw *ah =3D sc->sc_ah;
 	struct ath_common *common =3D ath9k_hw_common(ah);
 	unsigned long flags;
+	int i;
=20
 	if (ath_startrecv(sc) !=3D 0) {
 		ath_err(common, "Unable to restart recv logic\n");
@@ -235,6 +236,15 @@ static bool ath_complete_reset(struct ath_softc *sc, b=
ool start)
 		}
 	work:
 		ath_restart_work(sc);
+
+		for (i =3D 0; i < ATH9K_NUM_TX_QUEUES; i++) {
+			if (!ATH_TXQ_SETUP(sc, i))
+				continue;
+
+			spin_lock_bh(&sc->tx.txq[i].axq_lock);
+			ath_txq_schedule(sc, &sc->tx.txq[i]);
+			spin_unlock_bh(&sc->tx.txq[i].axq_lock);
+		}
 	}
=20
 	ieee80211_wake_queues(sc->hw);
@@ -539,21 +549,10 @@ chip_reset:
=20
 static int ath_reset(struct ath_softc *sc)
 {
-	int i, r;
+	int r;
=20
 	ath9k_ps_wakeup(sc);
-
 	r =3D ath_reset_internal(sc, NULL);
-
-	for (i =3D 0; i < ATH9K_NUM_TX_QUEUES; i++) {
-		if (!ATH_TXQ_SETUP(sc, i))
-			continue;
-
-		spin_lock_bh(&sc->tx.txq[i].axq_lock);
-		ath_txq_schedule(sc, &sc->tx.txq[i]);
-		spin_unlock_bh(&sc->tx.txq[i].axq_lock);
-	}
-
 	ath9k_ps_restore(sc);
=20
 	return r;
diff --git a/drivers/net/wireless/iwlwifi/iwl-6000.c b/drivers/net/wireless=
/iwlwifi/iwl-6000.c
index 30d45e2..8ac305b 100644
--- a/drivers/net/wireless/iwlwifi/iwl-6000.c
+++ b/drivers/net/wireless/iwlwifi/iwl-6000.c
@@ -240,6 +240,12 @@ const struct iwl_cfg iwl6035_2agn_cfg =3D {
 	.ht_params =3D &iwl6000_ht_params,
 };
=20
+const struct iwl_cfg iwl6035_2agn_sff_cfg =3D {
+	.name =3D "Intel(R) Centrino(R) Ultimate-N 6235 AGN",
+	IWL_DEVICE_6035,
+	.ht_params =3D &iwl6000_ht_params,
+};
+
 const struct iwl_cfg iwl1030_bgn_cfg =3D {
 	.name =3D "Intel(R) Centrino(R) Wireless-N 1030 BGN",
 	IWL_DEVICE_6030,
diff --git a/drivers/net/wireless/iwlwifi/iwl-config.h b/drivers/net/wirele=
ss/iwlwifi/iwl-config.h
index e4d370b..b03c25e 100644
--- a/drivers/net/wireless/iwlwifi/iwl-config.h
+++ b/drivers/net/wireless/iwlwifi/iwl-config.h
@@ -280,6 +280,7 @@ extern const struct iwl_cfg iwl2000_2bgn_cfg;
 extern const struct iwl_cfg iwl2000_2bgn_d_cfg;
 extern const struct iwl_cfg iwl2030_2bgn_cfg;
 extern const struct iwl_cfg iwl6035_2agn_cfg;
+extern const struct iwl_cfg iwl6035_2agn_sff_cfg;
 extern const struct iwl_cfg iwl105_bgn_cfg;
 extern const struct iwl_cfg iwl105_bgn_d_cfg;
 extern const struct iwl_cfg iwl135_bgn_cfg;
diff --git a/drivers/net/wireless/iwlwifi/iwl-trans.h b/drivers/net/wireles=
s/iwlwifi/iwl-trans.h
index dd57a36..80b4750 100644
--- a/drivers/net/wireless/iwlwifi/iwl-trans.h
+++ b/drivers/net/wireless/iwlwifi/iwl-trans.h
@@ -601,8 +601,10 @@ static inline int iwl_trans_send_cmd(struct iwl_trans =
*trans,
 {
 	int ret;
=20
-	WARN_ONCE(trans->state !=3D IWL_TRANS_FW_ALIVE,
-		  "%s bad state =3D %d", __func__, trans->state);
+	if (trans->state !=3D IWL_TRANS_FW_ALIVE) {
+		IWL_ERR(trans, "%s bad state =3D %d", __func__, trans->state);
+		return -EIO;
+	}
=20
 	if (!(cmd->flags & CMD_ASYNC))
 		lock_map_acquire_read(&trans->sync_cmd_lockdep_map);
diff --git a/drivers/net/wireless/iwlwifi/mvm/power.c b/drivers/net/wireles=
s/iwlwifi/mvm/power.c
index 21407a3..d58e393 100644
--- a/drivers/net/wireless/iwlwifi/mvm/power.c
+++ b/drivers/net/wireless/iwlwifi/mvm/power.c
@@ -273,7 +273,10 @@ static void iwl_mvm_power_build_cmd(struct iwl_mvm *mv=
m,
 		if (!mvmvif->queue_params[ac].uapsd)
 			continue;
=20
-		cmd->flags |=3D cpu_to_le16(POWER_FLAGS_ADVANCE_PM_ENA_MSK);
+		if (mvm->cur_ucode !=3D IWL_UCODE_WOWLAN)
+			cmd->flags |=3D
+				cpu_to_le16(POWER_FLAGS_ADVANCE_PM_ENA_MSK);
+
 		cmd->uapsd_ac_flags |=3D BIT(ac);
=20
 		/* QNDP TID - the highest TID with no admission control */
diff --git a/drivers/net/wireless/iwlwifi/mvm/scan.c b/drivers/net/wireless=
/iwlwifi/mvm/scan.c
index 9a7ab84..621fb71 100644
--- a/drivers/net/wireless/iwlwifi/mvm/scan.c
+++ b/drivers/net/wireless/iwlwifi/mvm/scan.c
@@ -394,6 +394,11 @@ static bool iwl_mvm_scan_abort_notif(struct iwl_notif_=
wait_data *notif_wait,
 			return false;
 		}
=20
+		/*
+		 * If scan cannot be aborted, it means that we had a
+		 * SCAN_COMPLETE_NOTIFICATION in the pipe and it called
+		 * ieee80211_scan_completed already.
+		 */
 		IWL_DEBUG_SCAN(mvm, "Scan cannot be aborted, exit now: %d\n",
 			       *resp);
 		return true;
@@ -417,14 +422,19 @@ void iwl_mvm_cancel_scan(struct iwl_mvm *mvm)
 					       SCAN_COMPLETE_NOTIFICATION };
 	int ret;
=20
+	if (mvm->scan_status =3D=3D IWL_MVM_SCAN_NONE)
+		return;
+
 	iwl_init_notification_wait(&mvm->notif_wait, &wait_scan_abort,
 				   scan_abort_notif,
 				   ARRAY_SIZE(scan_abort_notif),
 				   iwl_mvm_scan_abort_notif, NULL);
=20
-	ret =3D iwl_mvm_send_cmd_pdu(mvm, SCAN_ABORT_CMD, CMD_SYNC, 0, NULL);
+	ret =3D iwl_mvm_send_cmd_pdu(mvm, SCAN_ABORT_CMD,
+				   CMD_SYNC | CMD_SEND_IN_RFKILL, 0, NULL);
 	if (ret) {
 		IWL_ERR(mvm, "Couldn't send SCAN_ABORT_CMD: %d\n", ret);
+		/* mac80211's state will be cleaned in the fw_restart flow */
 		goto out_remove_notif;
 	}
=20
diff --git a/drivers/net/wireless/iwlwifi/pcie/drv.c b/drivers/net/wireless=
/iwlwifi/pcie/drv.c
index dc02cb9..26108a1 100644
--- a/drivers/net/wireless/iwlwifi/pcie/drv.c
+++ b/drivers/net/wireless/iwlwifi/pcie/drv.c
@@ -139,13 +139,16 @@ static DEFINE_PCI_DEVICE_TABLE(iwl_hw_card_ids) =3D {
=20
 /* 6x00 Series */
 	{IWL_PCI_DEVICE(0x422B, 0x1101, iwl6000_3agn_cfg)},
+	{IWL_PCI_DEVICE(0x422B, 0x1108, iwl6000_3agn_cfg)},
 	{IWL_PCI_DEVICE(0x422B, 0x1121, iwl6000_3agn_cfg)},
+	{IWL_PCI_DEVICE(0x422B, 0x1128, iwl6000_3agn_cfg)},
 	{IWL_PCI_DEVICE(0x422C, 0x1301, iwl6000i_2agn_cfg)},
 	{IWL_PCI_DEVICE(0x422C, 0x1306, iwl6000i_2abg_cfg)},
 	{IWL_PCI_DEVICE(0x422C, 0x1307, iwl6000i_2bg_cfg)},
 	{IWL_PCI_DEVICE(0x422C, 0x1321, iwl6000i_2agn_cfg)},
 	{IWL_PCI_DEVICE(0x422C, 0x1326, iwl6000i_2abg_cfg)},
 	{IWL_PCI_DEVICE(0x4238, 0x1111, iwl6000_3agn_cfg)},
+	{IWL_PCI_DEVICE(0x4238, 0x1118, iwl6000_3agn_cfg)},
 	{IWL_PCI_DEVICE(0x4239, 0x1311, iwl6000i_2agn_cfg)},
 	{IWL_PCI_DEVICE(0x4239, 0x1316, iwl6000i_2abg_cfg)},
=20
@@ -153,12 +156,16 @@ static DEFINE_PCI_DEVICE_TABLE(iwl_hw_card_ids) =3D {
 	{IWL_PCI_DEVICE(0x0082, 0x1301, iwl6005_2agn_cfg)},
 	{IWL_PCI_DEVICE(0x0082, 0x1306, iwl6005_2abg_cfg)},
 	{IWL_PCI_DEVICE(0x0082, 0x1307, iwl6005_2bg_cfg)},
+	{IWL_PCI_DEVICE(0x0082, 0x1308, iwl6005_2agn_cfg)},
 	{IWL_PCI_DEVICE(0x0082, 0x1321, iwl6005_2agn_cfg)},
 	{IWL_PCI_DEVICE(0x0082, 0x1326, iwl6005_2abg_cfg)},
+	{IWL_PCI_DEVICE(0x0082, 0x1328, iwl6005_2agn_cfg)},
 	{IWL_PCI_DEVICE(0x0085, 0x1311, iwl6005_2agn_cfg)},
+	{IWL_PCI_DEVICE(0x0085, 0x1318, iwl6005_2agn_cfg)},
 	{IWL_PCI_DEVICE(0x0085, 0x1316, iwl6005_2abg_cfg)},
 	{IWL_PCI_DEVICE(0x0082, 0xC020, iwl6005_2agn_sff_cfg)},
 	{IWL_PCI_DEVICE(0x0085, 0xC220, iwl6005_2agn_sff_cfg)},
+	{IWL_PCI_DEVICE(0x0085, 0xC228, iwl6005_2agn_sff_cfg)},
 	{IWL_PCI_DEVICE(0x0082, 0x4820, iwl6005_2agn_d_cfg)},
 	{IWL_PCI_DEVICE(0x0082, 0x1304, iwl6005_2agn_mow1_cfg)},/* low 5GHz activ=
e */
 	{IWL_PCI_DEVICE(0x0082, 0x1305, iwl6005_2agn_mow2_cfg)},/* high 5GHz acti=
ve */
@@ -240,8 +247,11 @@ static DEFINE_PCI_DEVICE_TABLE(iwl_hw_card_ids) =3D {
=20
 /* 6x35 Series */
 	{IWL_PCI_DEVICE(0x088E, 0x4060, iwl6035_2agn_cfg)},
+	{IWL_PCI_DEVICE(0x088E, 0x406A, iwl6035_2agn_sff_cfg)},
 	{IWL_PCI_DEVICE(0x088F, 0x4260, iwl6035_2agn_cfg)},
+	{IWL_PCI_DEVICE(0x088F, 0x426A, iwl6035_2agn_sff_cfg)},
 	{IWL_PCI_DEVICE(0x088E, 0x4460, iwl6035_2agn_cfg)},
+	{IWL_PCI_DEVICE(0x088E, 0x446A, iwl6035_2agn_sff_cfg)},
 	{IWL_PCI_DEVICE(0x088E, 0x4860, iwl6035_2agn_cfg)},
 	{IWL_PCI_DEVICE(0x088F, 0x5260, iwl6035_2agn_cfg)},
=20
@@ -260,54 +270,86 @@ static DEFINE_PCI_DEVICE_TABLE(iwl_hw_card_ids) =3D {
 #if IS_ENABLED(CONFIG_IWLMVM)
 /* 7000 Series */
 	{IWL_PCI_DEVICE(0x08B1, 0x4070, iwl7260_2ac_cfg)},
+	{IWL_PCI_DEVICE(0x08B1, 0x4072, iwl7260_2ac_cfg)},
 	{IWL_PCI_DEVICE(0x08B1, 0x4170, iwl7260_2ac_cfg)},
 	{IWL_PCI_DEVICE(0x08B1, 0x4060, iwl7260_2n_cfg)},
+	{IWL_PCI_DEVICE(0x08B1, 0x406A, iwl7260_2n_cfg)},
 	{IWL_PCI_DEVICE(0x08B1, 0x4160, iwl7260_2n_cfg)},
 	{IWL_PCI_DEVICE(0x08B1, 0x4062, iwl7260_n_cfg)},
 	{IWL_PCI_DEVICE(0x08B1, 0x4162, iwl7260_n_cfg)},
 	{IWL_PCI_DEVICE(0x08B2, 0x4270, iwl7260_2ac_cfg)},
+	{IWL_PCI_DEVICE(0x08B2, 0x4272, iwl7260_2ac_cfg)},
 	{IWL_PCI_DEVICE(0x08B2, 0x4260, iwl7260_2n_cfg)},
+	{IWL_PCI_DEVICE(0x08B2, 0x426A, iwl7260_2n_cfg)},
 	{IWL_PCI_DEVICE(0x08B2, 0x4262, iwl7260_n_cfg)},
 	{IWL_PCI_DEVICE(0x08B1, 0x4470, iwl7260_2ac_cfg)},
+	{IWL_PCI_DEVICE(0x08B1, 0x4472, iwl7260_2ac_cfg)},
 	{IWL_PCI_DEVICE(0x08B1, 0x4460, iwl7260_2n_cfg)},
+	{IWL_PCI_DEVICE(0x08B1, 0x446A, iwl7260_2n_cfg)},
 	{IWL_PCI_DEVICE(0x08B1, 0x4462, iwl7260_n_cfg)},
 	{IWL_PCI_DEVICE(0x08B1, 0x4870, iwl7260_2ac_cfg)},
 	{IWL_PCI_DEVICE(0x08B1, 0x486E, iwl7260_2ac_cfg)},
 	{IWL_PCI_DEVICE(0x08B1, 0x4A70, iwl7260_2ac_cfg_high_temp)},
 	{IWL_PCI_DEVICE(0x08B1, 0x4A6E, iwl7260_2ac_cfg_high_temp)},
 	{IWL_PCI_DEVICE(0x08B1, 0x4A6C, iwl7260_2ac_cfg_high_temp)},
+	{IWL_PCI_DEVICE(0x08B1, 0x4570, iwl7260_2ac_cfg)},
+	{IWL_PCI_DEVICE(0x08B1, 0x4560, iwl7260_2n_cfg)},
+	{IWL_PCI_DEVICE(0x08B2, 0x4370, iwl7260_2ac_cfg)},
+	{IWL_PCI_DEVICE(0x08B2, 0x4360, iwl7260_2n_cfg)},
+	{IWL_PCI_DEVICE(0x08B1, 0x5070, iwl7260_2ac_cfg)},
 	{IWL_PCI_DEVICE(0x08B1, 0x4020, iwl7260_2n_cfg)},
+	{IWL_PCI_DEVICE(0x08B1, 0x402A, iwl7260_2n_cfg)},
 	{IWL_PCI_DEVICE(0x08B2, 0x4220, iwl7260_2n_cfg)},
 	{IWL_PCI_DEVICE(0x08B1, 0x4420, iwl7260_2n_cfg)},
 	{IWL_PCI_DEVICE(0x08B1, 0xC070, iwl7260_2ac_cfg)},
+	{IWL_PCI_DEVICE(0x08B1, 0xC072, iwl7260_2ac_cfg)},
 	{IWL_PCI_DEVICE(0x08B1, 0xC170, iwl7260_2ac_cfg)},
 	{IWL_PCI_DEVICE(0x08B1, 0xC060, iwl7260_2n_cfg)},
+	{IWL_PCI_DEVICE(0x08B1, 0xC06A, iwl7260_2n_cfg)},
 	{IWL_PCI_DEVICE(0x08B1, 0xC160, iwl7260_2n_cfg)},
 	{IWL_PCI_DEVICE(0x08B1, 0xC062, iwl7260_n_cfg)},
 	{IWL_PCI_DEVICE(0x08B1, 0xC162, iwl7260_n_cfg)},
+	{IWL_PCI_DEVICE(0x08B1, 0xC770, iwl7260_2ac_cfg)},
+	{IWL_PCI_DEVICE(0x08B1, 0xC760, iwl7260_2n_cfg)},
 	{IWL_PCI_DEVICE(0x08B2, 0xC270, iwl7260_2ac_cfg)},
+	{IWL_PCI_DEVICE(0x08B2, 0xC272, iwl7260_2ac_cfg)},
 	{IWL_PCI_DEVICE(0x08B2, 0xC260, iwl7260_2n_cfg)},
+	{IWL_PCI_DEVICE(0x08B2, 0xC26A, iwl7260_n_cfg)},
 	{IWL_PCI_DEVICE(0x08B2, 0xC262, iwl7260_n_cfg)},
 	{IWL_PCI_DEVICE(0x08B1, 0xC470, iwl7260_2ac_cfg)},
+	{IWL_PCI_DEVICE(0x08B1, 0xC472, iwl7260_2ac_cfg)},
 	{IWL_PCI_DEVICE(0x08B1, 0xC460, iwl7260_2n_cfg)},
 	{IWL_PCI_DEVICE(0x08B1, 0xC462, iwl7260_n_cfg)},
+	{IWL_PCI_DEVICE(0x08B1, 0xC570, iwl7260_2ac_cfg)},
+	{IWL_PCI_DEVICE(0x08B1, 0xC560, iwl7260_2n_cfg)},
+	{IWL_PCI_DEVICE(0x08B2, 0xC370, iwl7260_2ac_cfg)},
+	{IWL_PCI_DEVICE(0x08B1, 0xC360, iwl7260_2n_cfg)},
 	{IWL_PCI_DEVICE(0x08B1, 0xC020, iwl7260_2n_cfg)},
+	{IWL_PCI_DEVICE(0x08B1, 0xC02A, iwl7260_2n_cfg)},
 	{IWL_PCI_DEVICE(0x08B2, 0xC220, iwl7260_2n_cfg)},
 	{IWL_PCI_DEVICE(0x08B1, 0xC420, iwl7260_2n_cfg)},
=20
 /* 3160 Series */
 	{IWL_PCI_DEVICE(0x08B3, 0x0070, iwl3160_2ac_cfg)},
+	{IWL_PCI_DEVICE(0x08B3, 0x0072, iwl3160_2ac_cfg)},
 	{IWL_PCI_DEVICE(0x08B3, 0x0170, iwl3160_2ac_cfg)},
+	{IWL_PCI_DEVICE(0x08B3, 0x0172, iwl3160_2ac_cfg)},
 	{IWL_PCI_DEVICE(0x08B3, 0x0060, iwl3160_2n_cfg)},
 	{IWL_PCI_DEVICE(0x08B3, 0x0062, iwl3160_n_cfg)},
 	{IWL_PCI_DEVICE(0x08B4, 0x0270, iwl3160_2ac_cfg)},
+	{IWL_PCI_DEVICE(0x08B4, 0x0272, iwl3160_2ac_cfg)},
 	{IWL_PCI_DEVICE(0x08B3, 0x0470, iwl3160_2ac_cfg)},
+	{IWL_PCI_DEVICE(0x08B3, 0x0472, iwl3160_2ac_cfg)},
+	{IWL_PCI_DEVICE(0x08B4, 0x0370, iwl3160_2ac_cfg)},
 	{IWL_PCI_DEVICE(0x08B3, 0x8070, iwl3160_2ac_cfg)},
+	{IWL_PCI_DEVICE(0x08B3, 0x8072, iwl3160_2ac_cfg)},
 	{IWL_PCI_DEVICE(0x08B3, 0x8170, iwl3160_2ac_cfg)},
+	{IWL_PCI_DEVICE(0x08B3, 0x8172, iwl3160_2ac_cfg)},
 	{IWL_PCI_DEVICE(0x08B3, 0x8060, iwl3160_2n_cfg)},
 	{IWL_PCI_DEVICE(0x08B3, 0x8062, iwl3160_n_cfg)},
 	{IWL_PCI_DEVICE(0x08B4, 0x8270, iwl3160_2ac_cfg)},
 	{IWL_PCI_DEVICE(0x08B3, 0x8470, iwl3160_2ac_cfg)},
+	{IWL_PCI_DEVICE(0x08B3, 0x8570, iwl3160_2ac_cfg)},
 #endif /* CONFIG_IWLMVM */
=20
 	{0}
diff --git a/drivers/net/wireless/iwlwifi/pcie/trans.c b/drivers/net/wirele=
ss/iwlwifi/pcie/trans.c
index bad95d2..c3f904d 100644
--- a/drivers/net/wireless/iwlwifi/pcie/trans.c
+++ b/drivers/net/wireless/iwlwifi/pcie/trans.c
@@ -1401,6 +1401,10 @@ struct iwl_trans *iwl_trans_pcie_alloc(struct pci_de=
v *pdev,
 	spin_lock_init(&trans_pcie->reg_lock);
 	init_waitqueue_head(&trans_pcie->ucode_write_waitq);
=20
+	err =3D pci_enable_device(pdev);
+	if (err)
+		goto out_no_pci;
+
 	if (!cfg->base_params->pcie_l1_allowed) {
 		/*
 		 * W/A - seems to solve weird behavior. We need to remove this
@@ -1412,10 +1416,6 @@ struct iwl_trans *iwl_trans_pcie_alloc(struct pci_de=
v *pdev,
 				       PCIE_LINK_STATE_CLKPM);
 	}
=20
-	err =3D pci_enable_device(pdev);
-	if (err)
-		goto out_no_pci;
-
 	pci_set_master(pdev);
=20
 	err =3D pci_set_dma_mask(pdev, DMA_BIT_MASK(36));
diff --git a/drivers/net/wireless/iwlwifi/pcie/tx.c b/drivers/net/wireless/=
iwlwifi/pcie/tx.c
index f45eb29..1424335 100644
--- a/drivers/net/wireless/iwlwifi/pcie/tx.c
+++ b/drivers/net/wireless/iwlwifi/pcie/tx.c
@@ -1102,6 +1102,8 @@ void iwl_trans_pcie_txq_enable(struct iwl_trans *tran=
s, int txq_id, int fifo,
 		 * non-AGG queue.
 		 */
 		iwl_clear_bits_prph(trans, SCD_AGGR_SEL, BIT(txq_id));
+
+		ssn =3D trans_pcie->txq[txq_id].q.read_ptr;
 	}
=20
 	/* Place first TFD at index corresponding to start sequence number.
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--/04w6evG8XlLl3ft
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)

iQIcBAEBAgAGBQJSVXYpAAoJEJctW/TcYTgGhgMP/iJvzC8x9hAQ1lOMiJuFaWw3
wKVPQqfv7FmZ4yqQZcBaylSbO4TY5YxBBBLplcL1JSoWkFnmGWsd+nU5BTcce1OW
7E24YdFJtOFvHPbK1iH0gF54vvOcabK9HSddHTKI1kG+NPVK2rR+caFazSa5RVNr
aKSt8JUW+Ov/fqazXGsG/y6lS21jaGmN9syRIQZ7G17iwjFqJQig7l/SMplDAMMA
LDb7kmB4XTPqvioRIfmEi0wRmzM/hWgYFaMKueyIBL95oCcnuryZg7EHFoaOteCs
jNNFobFd2njJAemFgYyx9BbIAtuPHjMxy5WNVAs90DbSePatjwLHFsYk/iS7/ZTs
SDqUzOhldaD7flIukPbTRNJBFiCm5BRLu4jIVuSaXfRvA8zfiQEu8MDuybBUsTHO
B9QQZy6kS8eIPC6vEwx8CXCD9DOH554leY7NE/Umu7DhqxOV/1QJ3hH/kEiBvUUw
9989yN3F6QR/nWt6SdVdLck1vuHEldYoiY79S5X8ACFIyYchODnZGRDQ1/d+YrAo
CBJS4fOFZiK0Y2WL2iHoD7kh7ux8F2t9TzOsVWfMc1XglcoQavE4W+bOGtb0QxQQ
BqkdP66+yemIW6OD1j16KHpisqpQBvHAYGF3SgN362fiMWZBVIP734dp2KEQhdXi
/uhq+duFGrvSjsHW5Yyu
=DcT4
-----END PGP SIGNATURE-----

--/04w6evG8XlLl3ft--
