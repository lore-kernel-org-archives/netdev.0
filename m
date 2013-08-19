From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless 2013-08-19
Date: Mon, 19 Aug 2013 14:59:40 -0400
Message-ID: <20130819185940.GE30753@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="cNdxnHkX5QqsyA0e"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--cNdxnHkX5QqsyA0e
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Dave,

This is a batch of fixes intended for the 3.11 stream...

Regarding the iwlwifi bits, Johannes says:

"We revert an rfkill bugfix that unfortunately caused more bugs, shuffle
some code to avoid touching the PCIe device before it's enabled and
disconnect if firmware fails to do our bidding. I also have Stanislaw's
fix to not crash in some channel switch scenarios."

As for the mac80211 bits, Johannes says:

"This time, I have one fix from Dan Carpenter for users of
nl80211hdr_put(), and one fix from myself fixing a regression with the
libertas driver."

Along with the above...

Dan Carpenter fixes some incorrectly placed "address of" operators
in hostap that caused copying of junk data.

Jussi Kivilinna corrects zd1201 to use an allocated buffer rather
than the stack for a URB operation.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 0f7dd1aa8f959216f1faa71513b9d3c1a9065e5a:

  Merge tag 'clk-fixes-for-linus' of git://git.linaro.org/people/mturquette=
/linux (2013-08-16 10:00:18 -0700)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git for-d=
avem

for you to fetch changes up to 22f0d2d1e7e76758f75887e616f2976323f85c26:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/li=
nville/wireless into for-davem (2013-08-19 14:24:45 -0400)

----------------------------------------------------------------

Dan Carpenter (2):
      Hostap: copying wrong data prism2_ioctl_giwaplist()
      nl80211: nl80211hdr_put() doesn't return an ERR_PTR

Emmanuel Grumbach (1):
      iwlwifi: pcie: disable L1 Active after pci_enable_device

Guy Cohen (1):
      Revert "iwlwifi: pcie: clear RFKILL interrupt in AMPG"

Johannes Berg (2):
      iwlwifi: mvm: disconnect if time event scheduling fails
      cfg80211: don't request disconnect if not connected

John W. Linville (3):
      Merge branch 'for-john' of git://git.kernel.org/.../iwlwifi/iwlwifi-f=
ixes
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac80211
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless i=
nto for-davem

Jussi Kivilinna (1):
      zd1201: do not use stack as URB transfer_buffer

Stanislaw Gruszka (1):
      iwlwifi: dvm: fix calling ieee80211_chswitch_done() with NULL

 drivers/net/wireless/hostap/hostap_ioctl.c    |  4 ++--
 drivers/net/wireless/iwlwifi/dvm/mac80211.c   |  5 +++-
 drivers/net/wireless/iwlwifi/iwl-prph.h       |  2 --
 drivers/net/wireless/iwlwifi/mvm/time-event.c | 33 +++++++++++++++++++----=
----
 drivers/net/wireless/iwlwifi/pcie/rx.c        |  8 -------
 drivers/net/wireless/iwlwifi/pcie/trans.c     | 10 ++++----
 drivers/net/wireless/zd1201.c                 |  4 +++-
 net/wireless/nl80211.c                        | 22 +++++++++---------
 net/wireless/sme.c                            | 10 ++++----
 9 files changed, 52 insertions(+), 46 deletions(-)

diff --git a/drivers/net/wireless/hostap/hostap_ioctl.c b/drivers/net/wirel=
ess/hostap/hostap_ioctl.c
index ac07473..e509030 100644
--- a/drivers/net/wireless/hostap/hostap_ioctl.c
+++ b/drivers/net/wireless/hostap/hostap_ioctl.c
@@ -523,9 +523,9 @@ static int prism2_ioctl_giwaplist(struct net_device *de=
v,
=20
 	data->length =3D prism2_ap_get_sta_qual(local, addr, qual, IW_MAX_AP, 1);
=20
-	memcpy(extra, &addr, sizeof(struct sockaddr) * data->length);
+	memcpy(extra, addr, sizeof(struct sockaddr) * data->length);
 	data->flags =3D 1; /* has quality information */
-	memcpy(extra + sizeof(struct sockaddr) * data->length, &qual,
+	memcpy(extra + sizeof(struct sockaddr) * data->length, qual,
 	       sizeof(struct iw_quality) * data->length);
=20
 	kfree(addr);
diff --git a/drivers/net/wireless/iwlwifi/dvm/mac80211.c b/drivers/net/wire=
less/iwlwifi/dvm/mac80211.c
index 822f1a0..3193872 100644
--- a/drivers/net/wireless/iwlwifi/dvm/mac80211.c
+++ b/drivers/net/wireless/iwlwifi/dvm/mac80211.c
@@ -1068,7 +1068,10 @@ void iwl_chswitch_done(struct iwl_priv *priv, bool i=
s_success)
 	if (test_bit(STATUS_EXIT_PENDING, &priv->status))
 		return;
=20
-	if (test_and_clear_bit(STATUS_CHANNEL_SWITCH_PENDING, &priv->status))
+	if (!test_and_clear_bit(STATUS_CHANNEL_SWITCH_PENDING, &priv->status))
+		return;
+
+	if (ctx->vif)
 		ieee80211_chswitch_done(ctx->vif, is_success);
 }
=20
diff --git a/drivers/net/wireless/iwlwifi/iwl-prph.h b/drivers/net/wireless=
/iwlwifi/iwl-prph.h
index a70c7b9..ff8cc75 100644
--- a/drivers/net/wireless/iwlwifi/iwl-prph.h
+++ b/drivers/net/wireless/iwlwifi/iwl-prph.h
@@ -97,8 +97,6 @@
=20
 #define APMG_PCIDEV_STT_VAL_L1_ACT_DIS		(0x00000800)
=20
-#define APMG_RTC_INT_STT_RFKILL		(0x10000000)
-
 /* Device system time */
 #define DEVICE_SYSTEM_TIME_REG 0xA0206C
=20
diff --git a/drivers/net/wireless/iwlwifi/mvm/time-event.c b/drivers/net/wi=
reless/iwlwifi/mvm/time-event.c
index ad9bbca..7fd6fbf 100644
--- a/drivers/net/wireless/iwlwifi/mvm/time-event.c
+++ b/drivers/net/wireless/iwlwifi/mvm/time-event.c
@@ -138,6 +138,20 @@ static void iwl_mvm_roc_finished(struct iwl_mvm *mvm)
 	schedule_work(&mvm->roc_done_wk);
 }
=20
+static bool iwl_mvm_te_check_disconnect(struct iwl_mvm *mvm,
+					struct ieee80211_vif *vif,
+					const char *errmsg)
+{
+	if (vif->type !=3D NL80211_IFTYPE_STATION)
+		return false;
+	if (vif->bss_conf.assoc && vif->bss_conf.dtim_period)
+		return false;
+	if (errmsg)
+		IWL_ERR(mvm, "%s\n", errmsg);
+	ieee80211_connection_loss(vif);
+	return true;
+}
+
 /*
  * Handles a FW notification for an event that is known to the driver.
  *
@@ -163,8 +177,13 @@ static void iwl_mvm_te_handle_notif(struct iwl_mvm *mv=
m,
 	 * P2P Device discoveribility, while there are other higher priority
 	 * events in the system).
 	 */
-	WARN_ONCE(!le32_to_cpu(notif->status),
-		  "Failed to schedule time event\n");
+	if (WARN_ONCE(!le32_to_cpu(notif->status),
+		      "Failed to schedule time event\n")) {
+		if (iwl_mvm_te_check_disconnect(mvm, te_data->vif, NULL)) {
+			iwl_mvm_te_clear_data(mvm, te_data);
+			return;
+		}
+	}
=20
 	if (le32_to_cpu(notif->action) & TE_NOTIF_HOST_EVENT_END) {
 		IWL_DEBUG_TE(mvm,
@@ -180,14 +199,8 @@ static void iwl_mvm_te_handle_notif(struct iwl_mvm *mv=
m,
 		 * By now, we should have finished association
 		 * and know the dtim period.
 		 */
-		if (te_data->vif->type =3D=3D NL80211_IFTYPE_STATION &&
-		    (!te_data->vif->bss_conf.assoc ||
-		     !te_data->vif->bss_conf.dtim_period)) {
-			IWL_ERR(mvm,
-				"No assocation and the time event is over already...\n");
-			ieee80211_connection_loss(te_data->vif);
-		}
-
+		iwl_mvm_te_check_disconnect(mvm, te_data->vif,
+			"No assocation and the time event is over already...");
 		iwl_mvm_te_clear_data(mvm, te_data);
 	} else if (le32_to_cpu(notif->action) & TE_NOTIF_HOST_EVENT_START) {
 		te_data->running =3D true;
diff --git a/drivers/net/wireless/iwlwifi/pcie/rx.c b/drivers/net/wireless/=
iwlwifi/pcie/rx.c
index f600e68..fd848cd 100644
--- a/drivers/net/wireless/iwlwifi/pcie/rx.c
+++ b/drivers/net/wireless/iwlwifi/pcie/rx.c
@@ -888,14 +888,6 @@ irqreturn_t iwl_pcie_irq_handler(int irq, void *dev_id)
=20
 		iwl_op_mode_hw_rf_kill(trans->op_mode, hw_rfkill);
 		if (hw_rfkill) {
-			/*
-			 * Clear the interrupt in APMG if the NIC is going down.
-			 * Note that when the NIC exits RFkill (else branch), we
-			 * can't access prph and the NIC will be reset in
-			 * start_hw anyway.
-			 */
-			iwl_write_prph(trans, APMG_RTC_INT_STT_REG,
-				       APMG_RTC_INT_STT_RFKILL);
 			set_bit(STATUS_RFKILL, &trans_pcie->status);
 			if (test_and_clear_bit(STATUS_HCMD_ACTIVE,
 					       &trans_pcie->status))
diff --git a/drivers/net/wireless/iwlwifi/pcie/trans.c b/drivers/net/wirele=
ss/iwlwifi/pcie/trans.c
index 96cfcdd..390e2f0 100644
--- a/drivers/net/wireless/iwlwifi/pcie/trans.c
+++ b/drivers/net/wireless/iwlwifi/pcie/trans.c
@@ -1502,16 +1502,16 @@ struct iwl_trans *iwl_trans_pcie_alloc(struct pci_d=
ev *pdev,
 	spin_lock_init(&trans_pcie->reg_lock);
 	init_waitqueue_head(&trans_pcie->ucode_write_waitq);
=20
-	/* W/A - seems to solve weird behavior. We need to remove this if we
-	 * don't want to stay in L1 all the time. This wastes a lot of power */
-	pci_disable_link_state(pdev, PCIE_LINK_STATE_L0S | PCIE_LINK_STATE_L1 |
-			       PCIE_LINK_STATE_CLKPM);
-
 	if (pci_enable_device(pdev)) {
 		err =3D -ENODEV;
 		goto out_no_pci;
 	}
=20
+	/* W/A - seems to solve weird behavior. We need to remove this if we
+	 * don't want to stay in L1 all the time. This wastes a lot of power */
+	pci_disable_link_state(pdev, PCIE_LINK_STATE_L0S | PCIE_LINK_STATE_L1 |
+			       PCIE_LINK_STATE_CLKPM);
+
 	pci_set_master(pdev);
=20
 	err =3D pci_set_dma_mask(pdev, DMA_BIT_MASK(36));
diff --git a/drivers/net/wireless/zd1201.c b/drivers/net/wireless/zd1201.c
index 4941f20..b8ba1f9 100644
--- a/drivers/net/wireless/zd1201.c
+++ b/drivers/net/wireless/zd1201.c
@@ -98,10 +98,12 @@ static int zd1201_fw_upload(struct usb_device *dev, int=
 apfw)
 		goto exit;
=20
 	err =3D usb_control_msg(dev, usb_rcvctrlpipe(dev, 0), 0x4,
-	    USB_DIR_IN | 0x40, 0,0, &ret, sizeof(ret), ZD1201_FW_TIMEOUT);
+	    USB_DIR_IN | 0x40, 0, 0, buf, sizeof(ret), ZD1201_FW_TIMEOUT);
 	if (err < 0)
 		goto exit;
=20
+	memcpy(&ret, buf, sizeof(ret));
+
 	if (ret & 0x80) {
 		err =3D -EIO;
 		goto exit;
diff --git a/net/wireless/nl80211.c b/net/wireless/nl80211.c
index 3fcba69..5f6e982 100644
--- a/net/wireless/nl80211.c
+++ b/net/wireless/nl80211.c
@@ -2622,8 +2622,8 @@ static int nl80211_get_key(struct sk_buff *skb, struc=
t genl_info *info)
=20
 	hdr =3D nl80211hdr_put(msg, info->snd_portid, info->snd_seq, 0,
 			     NL80211_CMD_NEW_KEY);
-	if (IS_ERR(hdr))
-		return PTR_ERR(hdr);
+	if (!hdr)
+		return -ENOBUFS;
=20
 	cookie.msg =3D msg;
 	cookie.idx =3D key_idx;
@@ -6507,6 +6507,9 @@ static int nl80211_testmode_dump(struct sk_buff *skb,
 					   NL80211_CMD_TESTMODE);
 		struct nlattr *tmdata;
=20
+		if (!hdr)
+			break;
+
 		if (nla_put_u32(skb, NL80211_ATTR_WIPHY, phy_idx)) {
 			genlmsg_cancel(skb, hdr);
 			break;
@@ -6951,9 +6954,8 @@ static int nl80211_remain_on_channel(struct sk_buff *=
skb,
=20
 	hdr =3D nl80211hdr_put(msg, info->snd_portid, info->snd_seq, 0,
 			     NL80211_CMD_REMAIN_ON_CHANNEL);
-
-	if (IS_ERR(hdr)) {
-		err =3D PTR_ERR(hdr);
+	if (!hdr) {
+		err =3D -ENOBUFS;
 		goto free_msg;
 	}
=20
@@ -7251,9 +7253,8 @@ static int nl80211_tx_mgmt(struct sk_buff *skb, struc=
t genl_info *info)
=20
 		hdr =3D nl80211hdr_put(msg, info->snd_portid, info->snd_seq, 0,
 				     NL80211_CMD_FRAME);
-
-		if (IS_ERR(hdr)) {
-			err =3D PTR_ERR(hdr);
+		if (!hdr) {
+			err =3D -ENOBUFS;
 			goto free_msg;
 		}
 	}
@@ -8132,9 +8133,8 @@ static int nl80211_probe_client(struct sk_buff *skb,
=20
 	hdr =3D nl80211hdr_put(msg, info->snd_portid, info->snd_seq, 0,
 			     NL80211_CMD_PROBE_CLIENT);
-
-	if (IS_ERR(hdr)) {
-		err =3D PTR_ERR(hdr);
+	if (!hdr) {
+		err =3D -ENOBUFS;
 		goto free_msg;
 	}
=20
diff --git a/net/wireless/sme.c b/net/wireless/sme.c
index 81c8a10..20e86a9 100644
--- a/net/wireless/sme.c
+++ b/net/wireless/sme.c
@@ -976,21 +976,19 @@ int cfg80211_disconnect(struct cfg80211_registered_de=
vice *rdev,
 			struct net_device *dev, u16 reason, bool wextev)
 {
 	struct wireless_dev *wdev =3D dev->ieee80211_ptr;
-	int err;
+	int err =3D 0;
=20
 	ASSERT_WDEV_LOCK(wdev);
=20
 	kfree(wdev->connect_keys);
 	wdev->connect_keys =3D NULL;
=20
-	if (wdev->conn) {
+	if (wdev->conn)
 		err =3D cfg80211_sme_disconnect(wdev, reason);
-	} else if (!rdev->ops->disconnect) {
+	else if (!rdev->ops->disconnect)
 		cfg80211_mlme_down(rdev, dev);
-		err =3D 0;
-	} else {
+	else if (wdev->current_bss)
 		err =3D rdev_disconnect(rdev, dev, reason);
-	}
=20
 	return err;
 }
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--cNdxnHkX5QqsyA0e
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)

iQIcBAEBAgAGBQJSEmscAAoJEJctW/TcYTgGn6YP/19vEIEPuuEFFtELHXG+jwrI
u9AweiMEGvfmb7gxSJ3pUCJkeLlz1suPidiLZa6C6KwmjrCKx9ZiWEVV1uBiGKvl
eEhph7AZVOM5A4Rb5fVKkiX3BXlPT5hg24fU49+MmjNydJ6X32UBgQE+26dXOVnQ
knFRVLt5FrekcT6MIKErAXQN8d3mzuTjksqgb55wfiXOqfh1EmBWIW/Sp1RXD6Pw
8vkwQF3/QfS5jU+ccP4m6huDfvekLUmIhJxf4gokNsPx7Oux0t2DYyRsA5loq293
5h/NmDlltx/MIbnQFIlfclJMoQ+mDLkk88JU3c0RDX19Qq9NGq+Z8NLjnldryJ+s
wvlkDSkSs348BcyWLhP4iwoc/jN9yM9uWEphmpuZ2nfA2TeaAuIC0FnXMk4YyDyB
V2FhMz82sQW2dusq8CZLotE6Jdw/0QgBLYKzEpLafqVP5s2jO4IEBav8FzuPUMru
f45MGOSEjOqeP52iYhPzXz+ivlSzH+/5DjcSRdd7n7E2eoWr6ip+USyVHRnVXRg6
vgUc0vfu826KdJCKcK24k5n8O26WELa0UaTetDWkKrsQ23RDA36bWm4vpyjJR0Ze
87rs7su8vGp8nVPiPPARc76BnvU0bOSbsdCMjvRVfLSmTV1crOQBcOX/GLBvitiz
NZsRIzQy+7Bo7+GXZpkv
=qhyJ
-----END PGP SIGNATURE-----

--cNdxnHkX5QqsyA0e--
