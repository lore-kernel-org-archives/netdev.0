From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [PATCH 1/2] iwlwifi: mvm: Fix the build of mvm/mac-ctxt.c with debugfs disabled
Date: Fri, 06 Mar 2015 20:36:34 -0600
Message-ID: <87bnk57cul.fsf_-_@x220.int.ebiederm.org>
References: <874mpy2gw5.fsf@kamboji.qca.qualcomm.com>
	<87fv9h7cwl.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Emmanuel Grumbach <emmanuel.grumbach-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <87fv9h7cwl.fsf-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org> (Eric W. Biederman's
	message of "Fri, 06 Mar 2015 20:35:22 -0600")
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


When attempting to build my kernel I get:
  CC      drivers/net/wireless/iwlwifi/mvm/mac-ctxt.o
 drivers/net/wireless/iwlwifi/mvm/mac-ctxt.c: In function =E2=80=98iwl_=
mvm_beacon_loss_iterator=E2=80=99:
 drivers/net/wireless/iwlwifi/mvm/mac-ctxt.c:1378:30: error: =E2=80=98s=
truct iwl_mvm_vif=E2=80=99 has no member named =E2=80=98mvm=E2=80=99

=46ix that by making the new code depend on IWLWIFI_DEBUGFS as the
definition of mvm in struct iwl_mvm_if does.

Cc: Emmanuel Grumbach <emmanuel.grumbach-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
=46ixes: 9d761fd8a58360e iwlwifi: mvm: add trigger for firmware dump up=
on missed beacons
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 drivers/net/wireless/iwlwifi/mvm/mac-ctxt.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/drivers/net/wireless/iwlwifi/mvm/mac-ctxt.c b/drivers/net/=
wireless/iwlwifi/mvm/mac-ctxt.c
index 581b3b8f29f9..7ad736ff90ff 100644
--- a/drivers/net/wireless/iwlwifi/mvm/mac-ctxt.c
+++ b/drivers/net/wireless/iwlwifi/mvm/mac-ctxt.c
@@ -1375,18 +1375,21 @@ static void iwl_mvm_beacon_loss_iterator(void *=
_data, u8 *mac,
 {
 	struct iwl_missed_beacons_notif *missed_beacons =3D _data;
 	struct iwl_mvm_vif *mvmvif =3D iwl_mvm_vif_from_mac80211(vif);
+#ifdef CONFIG_IWLWIFI_DEBUGFS
 	struct iwl_mvm *mvm =3D mvmvif->mvm;
 	struct iwl_fw_dbg_trigger_missed_bcon *bcon_trig;
 	struct iwl_fw_dbg_trigger_tlv *trigger;
 	u32 stop_trig_missed_bcon, stop_trig_missed_bcon_since_rx;
 	u32 rx_missed_bcon, rx_missed_bcon_since_rx;
+#endif
=20
 	if (mvmvif->id !=3D (u16)le32_to_cpu(missed_beacons->mac_id))
 		return;
-
+#ifdef CONFIG_IWLWIFI_DEBUGFS
 	rx_missed_bcon =3D le32_to_cpu(missed_beacons->consec_missed_beacons)=
;
 	rx_missed_bcon_since_rx =3D
 		le32_to_cpu(missed_beacons->consec_missed_beacons_since_last_rx);
+#endif
 	/*
 	 * TODO: the threshold should be adjusted based on latency conditions=
,
 	 * and/or in case of a CS flow on one of the other AP vifs.
@@ -1395,6 +1398,7 @@ static void iwl_mvm_beacon_loss_iterator(void *_d=
ata, u8 *mac,
 	     IWL_MVM_MISSED_BEACONS_THRESHOLD)
 		ieee80211_beacon_loss(vif);
=20
+#ifdef CONFIG_IWLWIFI_DEBUGFS
 	if (!iwl_fw_dbg_trigger_enabled(mvm->fw,
 					FW_DBG_TRIGGER_MISSED_BEACONS))
 		return;
@@ -1414,6 +1418,7 @@ static void iwl_mvm_beacon_loss_iterator(void *_d=
ata, u8 *mac,
 	if (rx_missed_bcon_since_rx >=3D stop_trig_missed_bcon_since_rx ||
 	    rx_missed_bcon >=3D stop_trig_missed_bcon)
 		iwl_mvm_fw_dbg_collect_trig(mvm, trigger, NULL, 0);
+#endif /* CONFIG_IWLWIFI_DEBUGFS */
 }
=20
 int iwl_mvm_rx_missed_beacons_notif(struct iwl_mvm *mvm,
--=20
2.2.1

--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
