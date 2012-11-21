From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless 2012-11-21
Date: Wed, 21 Nov 2012 11:24:06 -0500
Message-ID: <20121121162406.GA2066@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="h31gzZEtNLTqOjlF"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--h31gzZEtNLTqOjlF
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

commit 57a0c44fca179c27808a5f2fae718e7eab9d6243

Dave,

This is a batch of fixes intended for 3.7...

Included are two pulls.  Regarding the mac80211 tree, Johannes says:

"Please pull my mac80211.git tree (see below) to get two more fixes for
3.7. Both fix regressions introduced *before* this cycle that weren't
noticed until now, one for IBSS not cleaning up properly and the other
to add back the "wireless" sysfs directory for Fedora's startup scripts."

Regarding the iwlwifi tree, Johannes says:

"Please also pull my iwlwifi.git tree, I have two fixes: one to remove a
spurious warning that can actually trigger in legitimate situations, and
the other to fix a regression from when monitor mode was changed to use
the "sniffer" firmware mode."

Also included is an nfc tree pull.  Samuel says:

"We mostly have pn533 fixes here, 2 memory leaks and an early unlocking fix.
Moreover, we also have an LLCP adapter linked list insertion fix."

On top of that, a few more bits...  Albert Pool adds a USB ID
to rtlwifi.  Bing Zhao provides two mwifiex fixes -- one to fix
a system hang during a command timeout, and the other to properly
report a suspend error to the MMC core.  Finally, Sujith Manoharan
fixes a thinko that would trigger an ath9k hang during device reset.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit aecb55be41b1bab432e81d550ebce010e7d178c6:

  net: fix build failure in xilinx (2012-11-20 15:51:55 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git for-d=
avem

for you to fetch changes up to 57a0c44fca179c27808a5f2fae718e7eab9d6243:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/li=
nville/wireless into for-davem (2012-11-21 10:42:23 -0500)

----------------------------------------------------------------

Albert Pool (1):
      rtlwifi: rtl8192cu: Add new USB ID

Bing Zhao (2):
      mwifiex: fix system hang issue in cmd timeout error case
      mwifiex: report error to MMC core if we cannot suspend

Emmanuel Grumbach (1):
      iwlwifi: don't WARN when a non empty queue is disabled

Johannes Berg (2):
      iwlwifi: fix monitor mode FCS flag
      wireless: add back sysfs directory

John W. Linville (4):
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac80211
      Merge branch 'for-john' of git://git.kernel.org/.../iwlwifi/iwlwifi-f=
ixes
      Merge tag 'nfc-fixes-3.7-1' of git://git.kernel.org/.../sameo/nfc-3.0
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless i=
nto for-davem

Simon Wunderlich (1):
      mac80211: deinitialize ibss-internals after emptiness check

Sujith Manoharan (1):
      ath9k_hw: Fix regression in device reset

Szymon Janc (2):
      NFC: pn533: Fix missing lock while operating on commands list
      NFC: pn533: Fix use after free

Thierry Escande (2):
      NFC: Fix nfc_llcp_local chained list insertion
      NFC: Fix pn533 target mode memory leak

Waldemar Rymarkiewicz (1):
      NFC: pn533: Fix mem leak in pn533_in_dep_link_up

 drivers/net/wireless/ath/ath9k/hw.c         |  2 +-
 drivers/net/wireless/iwlwifi/dvm/mac80211.c | 14 ++++++++++++++
 drivers/net/wireless/iwlwifi/pcie/tx.c      |  8 --------
 drivers/net/wireless/mwifiex/cmdevt.c       | 11 ++++++++---
 drivers/net/wireless/mwifiex/sdio.c         | 11 ++++++-----
 drivers/net/wireless/rtlwifi/rtl8192cu/sw.c |  1 +
 drivers/nfc/pn533.c                         | 25 ++++++++++++++-----------
 net/core/net-sysfs.c                        | 20 ++++++++++++++++++++
 net/mac80211/ibss.c                         |  8 ++++----
 net/nfc/llcp/llcp.c                         |  2 +-
 10 files changed, 69 insertions(+), 33 deletions(-)

diff --git a/drivers/net/wireless/ath/ath9k/hw.c b/drivers/net/wireless/ath=
/ath9k/hw.c
index 8e1559a..1829b44 100644
--- a/drivers/net/wireless/ath/ath9k/hw.c
+++ b/drivers/net/wireless/ath/ath9k/hw.c
@@ -1456,7 +1456,7 @@ static bool ath9k_hw_set_reset_reg(struct ath_hw *ah,=
 u32 type)
 	switch (type) {
 	case ATH9K_RESET_POWER_ON:
 		ret =3D ath9k_hw_set_reset_power_on(ah);
-		if (!ret)
+		if (ret)
 			ah->reset_power_on =3D true;
 		break;
 	case ATH9K_RESET_WARM:
diff --git a/drivers/net/wireless/iwlwifi/dvm/mac80211.c b/drivers/net/wire=
less/iwlwifi/dvm/mac80211.c
index fa4d1b8..2d9eee9 100644
--- a/drivers/net/wireless/iwlwifi/dvm/mac80211.c
+++ b/drivers/net/wireless/iwlwifi/dvm/mac80211.c
@@ -1354,6 +1354,20 @@ static int iwlagn_mac_add_interface(struct ieee80211=
_hw *hw,
 	vif_priv->ctx =3D ctx;
 	ctx->vif =3D vif;
=20
+	/*
+	 * In SNIFFER device type, the firmware reports the FCS to
+	 * the host, rather than snipping it off. Unfortunately,
+	 * mac80211 doesn't (yet) provide a per-packet flag for
+	 * this, so that we have to set the hardware flag based
+	 * on the interfaces added. As the monitor interface can
+	 * only be present by itself, and will be removed before
+	 * other interfaces are added, this is safe.
+	 */
+	if (vif->type =3D=3D NL80211_IFTYPE_MONITOR)
+		priv->hw->flags |=3D IEEE80211_HW_RX_INCLUDES_FCS;
+	else
+		priv->hw->flags &=3D ~IEEE80211_HW_RX_INCLUDES_FCS;
+
 	err =3D iwl_setup_interface(priv, ctx);
 	if (!err || reset)
 		goto out;
diff --git a/drivers/net/wireless/iwlwifi/pcie/tx.c b/drivers/net/wireless/=
iwlwifi/pcie/tx.c
index 105e3af..79a4ddc 100644
--- a/drivers/net/wireless/iwlwifi/pcie/tx.c
+++ b/drivers/net/wireless/iwlwifi/pcie/tx.c
@@ -480,20 +480,12 @@ void iwl_trans_pcie_txq_enable(struct iwl_trans *tran=
s, int txq_id, int fifo,
 void iwl_trans_pcie_txq_disable(struct iwl_trans *trans, int txq_id)
 {
 	struct iwl_trans_pcie *trans_pcie =3D IWL_TRANS_GET_PCIE_TRANS(trans);
-	u16 rd_ptr, wr_ptr;
-	int n_bd =3D trans_pcie->txq[txq_id].q.n_bd;
=20
 	if (!test_and_clear_bit(txq_id, trans_pcie->queue_used)) {
 		WARN_ONCE(1, "queue %d not used", txq_id);
 		return;
 	}
=20
-	rd_ptr =3D iwl_read_prph(trans, SCD_QUEUE_RDPTR(txq_id)) & (n_bd - 1);
-	wr_ptr =3D iwl_read_prph(trans, SCD_QUEUE_WRPTR(txq_id));
-
-	WARN_ONCE(rd_ptr !=3D wr_ptr, "queue %d isn't empty: [%d,%d]",
-		  txq_id, rd_ptr, wr_ptr);
-
 	iwl_txq_set_inactive(trans, txq_id);
 	IWL_DEBUG_TX_QUEUES(trans, "Deactivate queue %d\n", txq_id);
 }
diff --git a/drivers/net/wireless/mwifiex/cmdevt.c b/drivers/net/wireless/m=
wifiex/cmdevt.c
index 8d46510..ae9010e 100644
--- a/drivers/net/wireless/mwifiex/cmdevt.c
+++ b/drivers/net/wireless/mwifiex/cmdevt.c
@@ -890,9 +890,6 @@ mwifiex_cmd_timeout_func(unsigned long function_context)
 		return;
 	}
 	cmd_node =3D adapter->curr_cmd;
-	if (cmd_node->wait_q_enabled)
-		adapter->cmd_wait_q.status =3D -ETIMEDOUT;
-
 	if (cmd_node) {
 		adapter->dbg.timeout_cmd_id =3D
 			adapter->dbg.last_cmd_id[adapter->dbg.last_cmd_index];
@@ -938,6 +935,14 @@ mwifiex_cmd_timeout_func(unsigned long function_contex=
t)
=20
 		dev_err(adapter->dev, "ps_mode=3D%d ps_state=3D%d\n",
 			adapter->ps_mode, adapter->ps_state);
+
+		if (cmd_node->wait_q_enabled) {
+			adapter->cmd_wait_q.status =3D -ETIMEDOUT;
+			wake_up_interruptible(&adapter->cmd_wait_q.wait);
+			mwifiex_cancel_pending_ioctl(adapter);
+			/* reset cmd_sent flag to unblock new commands */
+			adapter->cmd_sent =3D false;
+		}
 	}
 	if (adapter->hw_status =3D=3D MWIFIEX_HW_STATUS_INITIALIZING)
 		mwifiex_init_fw_complete(adapter);
diff --git a/drivers/net/wireless/mwifiex/sdio.c b/drivers/net/wireless/mwi=
fiex/sdio.c
index fc8a9bf..82cf0fa 100644
--- a/drivers/net/wireless/mwifiex/sdio.c
+++ b/drivers/net/wireless/mwifiex/sdio.c
@@ -161,7 +161,6 @@ static int mwifiex_sdio_suspend(struct device *dev)
 	struct sdio_mmc_card *card;
 	struct mwifiex_adapter *adapter;
 	mmc_pm_flag_t pm_flag =3D 0;
-	int hs_actived =3D 0;
 	int i;
 	int ret =3D 0;
=20
@@ -188,12 +187,14 @@ static int mwifiex_sdio_suspend(struct device *dev)
 	adapter =3D card->adapter;
=20
 	/* Enable the Host Sleep */
-	hs_actived =3D mwifiex_enable_hs(adapter);
-	if (hs_actived) {
-		pr_debug("cmd: suspend with MMC_PM_KEEP_POWER\n");
-		ret =3D sdio_set_host_pm_flags(func, MMC_PM_KEEP_POWER);
+	if (!mwifiex_enable_hs(adapter)) {
+		dev_err(adapter->dev, "cmd: failed to suspend\n");
+		return -EFAULT;
 	}
=20
+	dev_dbg(adapter->dev, "cmd: suspend with MMC_PM_KEEP_POWER\n");
+	ret =3D sdio_set_host_pm_flags(func, MMC_PM_KEEP_POWER);
+
 	/* Indicate device suspended */
 	adapter->is_suspended =3D true;
=20
diff --git a/drivers/net/wireless/rtlwifi/rtl8192cu/sw.c b/drivers/net/wire=
less/rtlwifi/rtl8192cu/sw.c
index 9970c2b..b7e6607 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192cu/sw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192cu/sw.c
@@ -297,6 +297,7 @@ static struct usb_device_id rtl8192c_usb_ids[] =3D {
 	/*=3D=3D=3D Customer ID =3D=3D=3D*/
 	/****** 8188CU ********/
 	{RTL_USB_DEVICE(0x050d, 0x1102, rtl92cu_hal_cfg)}, /*Belkin - Edimax*/
+	{RTL_USB_DEVICE(0x050d, 0x11f2, rtl92cu_hal_cfg)}, /*Belkin - ISY*/
 	{RTL_USB_DEVICE(0x06f8, 0xe033, rtl92cu_hal_cfg)}, /*Hercules - Edimax*/
 	{RTL_USB_DEVICE(0x07b8, 0x8188, rtl92cu_hal_cfg)}, /*Abocom - Abocom*/
 	{RTL_USB_DEVICE(0x07b8, 0x8189, rtl92cu_hal_cfg)}, /*Funai - Abocom*/
diff --git a/drivers/nfc/pn533.c b/drivers/nfc/pn533.c
index 97c440a..30ae18a 100644
--- a/drivers/nfc/pn533.c
+++ b/drivers/nfc/pn533.c
@@ -698,13 +698,14 @@ static void pn533_wq_cmd(struct work_struct *work)
=20
 	cmd =3D list_first_entry(&dev->cmd_queue, struct pn533_cmd, queue);
=20
+	list_del(&cmd->queue);
+
 	mutex_unlock(&dev->cmd_lock);
=20
 	__pn533_send_cmd_frame_async(dev, cmd->out_frame, cmd->in_frame,
 				     cmd->in_frame_len, cmd->cmd_complete,
 				     cmd->arg, cmd->flags);
=20
-	list_del(&cmd->queue);
 	kfree(cmd);
 }
=20
@@ -1678,11 +1679,14 @@ static void pn533_deactivate_target(struct nfc_dev =
*nfc_dev,
 static int pn533_in_dep_link_up_complete(struct pn533 *dev, void *arg,
 						u8 *params, int params_len)
 {
-	struct pn533_cmd_jump_dep *cmd;
 	struct pn533_cmd_jump_dep_response *resp;
 	struct nfc_target nfc_target;
 	u8 target_gt_len;
 	int rc;
+	struct pn533_cmd_jump_dep *cmd =3D (struct pn533_cmd_jump_dep *)arg;
+	u8 active =3D cmd->active;
+
+	kfree(arg);
=20
 	if (params_len =3D=3D -ENOENT) {
 		nfc_dev_dbg(&dev->interface->dev, "");
@@ -1704,7 +1708,6 @@ static int pn533_in_dep_link_up_complete(struct pn533=
 *dev, void *arg,
 	}
=20
 	resp =3D (struct pn533_cmd_jump_dep_response *) params;
-	cmd =3D (struct pn533_cmd_jump_dep *) arg;
 	rc =3D resp->status & PN533_CMD_RET_MASK;
 	if (rc !=3D PN533_CMD_RET_SUCCESS) {
 		nfc_dev_err(&dev->interface->dev,
@@ -1734,7 +1737,7 @@ static int pn533_in_dep_link_up_complete(struct pn533=
 *dev, void *arg,
 	if (rc =3D=3D 0)
 		rc =3D nfc_dep_link_is_up(dev->nfc_dev,
 						dev->nfc_dev->targets[0].idx,
-						!cmd->active, NFC_RF_INITIATOR);
+						!active, NFC_RF_INITIATOR);
=20
 	return 0;
 }
@@ -1819,12 +1822,8 @@ static int pn533_dep_link_up(struct nfc_dev *nfc_dev=
, struct nfc_target *target,
 	rc =3D pn533_send_cmd_frame_async(dev, dev->out_frame, dev->in_frame,
 				dev->in_maxlen,	pn533_in_dep_link_up_complete,
 				cmd, GFP_KERNEL);
-	if (rc)
-		goto out;
-
-
-out:
-	kfree(cmd);
+	if (rc < 0)
+		kfree(cmd);
=20
 	return rc;
 }
@@ -2078,8 +2077,12 @@ error:
 static int pn533_tm_send_complete(struct pn533 *dev, void *arg,
 				  u8 *params, int params_len)
 {
+	struct sk_buff *skb_out =3D arg;
+
 	nfc_dev_dbg(&dev->interface->dev, "%s", __func__);
=20
+	dev_kfree_skb(skb_out);
+
 	if (params_len < 0) {
 		nfc_dev_err(&dev->interface->dev,
 			    "Error %d when sending data",
@@ -2117,7 +2120,7 @@ static int pn533_tm_send(struct nfc_dev *nfc_dev, str=
uct sk_buff *skb)
=20
 	rc =3D pn533_send_cmd_frame_async(dev, out_frame, dev->in_frame,
 					dev->in_maxlen, pn533_tm_send_complete,
-					NULL, GFP_KERNEL);
+					skb, GFP_KERNEL);
 	if (rc) {
 		nfc_dev_err(&dev->interface->dev,
 			    "Error %d when trying to send data", rc);
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index bcf02f6..017a8ba 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -429,6 +429,17 @@ static struct attribute_group netstat_group =3D {
 	.name  =3D "statistics",
 	.attrs  =3D netstat_attrs,
 };
+
+#if IS_ENABLED(CONFIG_WIRELESS_EXT) || IS_ENABLED(CONFIG_CFG80211)
+static struct attribute *wireless_attrs[] =3D {
+	NULL
+};
+
+static struct attribute_group wireless_group =3D {
+	.name =3D "wireless",
+	.attrs =3D wireless_attrs,
+};
+#endif
 #endif /* CONFIG_SYSFS */
=20
 #ifdef CONFIG_RPS
@@ -1409,6 +1420,15 @@ int netdev_register_kobject(struct net_device *net)
 		groups++;
=20
 	*groups++ =3D &netstat_group;
+
+#if IS_ENABLED(CONFIG_WIRELESS_EXT) || IS_ENABLED(CONFIG_CFG80211)
+	if (net->ieee80211_ptr)
+		*groups++ =3D &wireless_group;
+#if IS_ENABLED(CONFIG_WIRELESS_EXT)
+	else if (net->wireless_handlers)
+		*groups++ =3D &wireless_group;
+#endif
+#endif
 #endif /* CONFIG_SYSFS */
=20
 	error =3D device_add(dev);
diff --git a/net/mac80211/ibss.c b/net/mac80211/ibss.c
index bf87c70..c21e33d 100644
--- a/net/mac80211/ibss.c
+++ b/net/mac80211/ibss.c
@@ -1151,10 +1151,6 @@ int ieee80211_ibss_leave(struct ieee80211_sub_if_dat=
a *sdata)
=20
 	mutex_lock(&sdata->u.ibss.mtx);
=20
-	sdata->u.ibss.state =3D IEEE80211_IBSS_MLME_SEARCH;
-	memset(sdata->u.ibss.bssid, 0, ETH_ALEN);
-	sdata->u.ibss.ssid_len =3D 0;
-
 	active_ibss =3D ieee80211_sta_active_ibss(sdata);
=20
 	if (!active_ibss && !is_zero_ether_addr(ifibss->bssid)) {
@@ -1175,6 +1171,10 @@ int ieee80211_ibss_leave(struct ieee80211_sub_if_dat=
a *sdata)
 		}
 	}
=20
+	ifibss->state =3D IEEE80211_IBSS_MLME_SEARCH;
+	memset(ifibss->bssid, 0, ETH_ALEN);
+	ifibss->ssid_len =3D 0;
+
 	sta_info_flush(sdata->local, sdata);
=20
 	spin_lock_bh(&ifibss->incomplete_lock);
diff --git a/net/nfc/llcp/llcp.c b/net/nfc/llcp/llcp.c
index cc10d07..9e8f4b2 100644
--- a/net/nfc/llcp/llcp.c
+++ b/net/nfc/llcp/llcp.c
@@ -1210,7 +1210,7 @@ int nfc_llcp_register_device(struct nfc_dev *ndev)
 	local->remote_miu =3D LLCP_DEFAULT_MIU;
 	local->remote_lto =3D LLCP_DEFAULT_LTO;
=20
-	list_add(&llcp_devices, &local->list);
+	list_add(&local->list, &llcp_devices);
=20
 	return 0;
 }
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--h31gzZEtNLTqOjlF
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJQrQAmAAoJEJctW/TcYTgGGPoP/RWXu5OkPY+67G7UP9yZ1/lK
Ia+z96MsQOa0KZpePOuTnNjrJxj3TlZ8DoG/4pToQuYyt27naqabnIiu7Uis9kGr
R9eTx1A6fs8gyPWOdjWcsfA+JDXG8mu9bqg8B7P/XwkdsCygHZM4allPIKEJ0Oqv
91BXhtOVVf/FVvusrzpAnJtHRchg2gjcq5HzGgA0G5LJv/w3Vf4h9Pct9g7PNP5K
wxlgkTme33BLiIjoyrAEC59O/rKogzxZII4hni4Vbqd74N1LaNcB+F0C5LBzqQU+
QSU6iGU9pk5aV8emrceDUOhFG3G3F35nTuOGJdlVX87sthCOraSUbZ1006kVZEgM
DJEQjQXOqAWvNZlsrIJjJzTWHqGaN4MgBcq7l0fEpOT5jw0NlYbtKPko0K+H7hJx
KinUWsF/L8RYp+tNtg5/i4sd11rN+60LoqRMuaI0jGb3WECp21dH1aEJKOnRqfpm
hPOpOe+pABPFCV1B+XG7spszaKQqI/Qdtm9bTT4+Ul/+gvjpKewAgywNWq4qli+3
A3zlvDT4p1EnVMOocIzilTODZlmYb9bQTkB3wgyJfZslOhs+ljrD6n2nbh1+dph8
NJ5MRja1BMUlLLwcEq0uBCFuRpug6HreSObWuIIEDLF6zRnjDWqRI8zen90l1bOu
pT/SpOfMEird/ewdb58K
=TzTu
-----END PGP SIGNATURE-----

--h31gzZEtNLTqOjlF--
