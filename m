From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless 2013-04-03
Date: Wed, 3 Apr 2013 14:16:48 -0400
Message-ID: <20130403181647.GB31358@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="Dxnq1zWXvFF0Q93v"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--Dxnq1zWXvFF0Q93v
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Dave,

Here are some more fixes intended for the 3.9 stream...

Regarding the mac80211 bits, Johannes says:

"I had changed the idle handling to simplify it, but broken the
sequencing of commands, at least for ath9k-htc, one patch restores the
sequence. The other patch fixes a crash Jouni found while stress-testing
the remain-on-channel code, when an item is deleted the work struct can
run twice and crash the second time."

As for the iwlwifi bits, Johannes says:

"The only fix here is to the passive-no-RX firmware regulatory
enforcement driver support code to not drop auth frames in quick
succession, leading to not being able to connect to APs on passive
channels in certain circumstances."

Don't forget the NFC bits, about which Samuel says:

"This time we have:

- A crash fix for when a DGRAM LLCP socket is listening while the NFC adapt=
er
  is physically removed.
- A potential double skb free when the LLCP socket receive queue is full.
- A fix for properly handling multiple and consecutive LLCP connections, and
  not trash the socket ack log.
- A build failure for the MEI microread physical layer, now that the MEI bus
  APIs have been merged into char-misc-next."

On top of that, Stone Piao provides an mwifiex fix to avoid accessing
beyond the end of a buffer.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 3658f3604066d5500ebd73a04084f127dc779441:

  Merge branch 'stable' of git://git.kernel.org/pub/scm/linux/kernel/git/cm=
etcalf/linux-tile (2013-04-01 08:17:09 -0700)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git for-d=
avem

for you to fetch changes up to 407ad2b7efebe42f8331fd42c4576ed3a6117e29:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/li=
nville/wireless into for-davem (2013-04-03 13:50:34 -0400)

----------------------------------------------------------------

Johannes Berg (3):
      mac80211: fix remain-on-channel cancel crash
      mac80211: fix idle handling sequence
      iwlwifi: dvm: fix the passive-no-RX workaround

John W. Linville (4):
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac80211
      Merge branch 'for-john' of git://git.kernel.org/.../iwlwifi/iwlwifi-f=
ixes
      Merge tag 'nfc-fixes-3.9-2' of git://git.kernel.org/.../sameo/nfc-fix=
es
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless i=
nto for-davem

Samuel Ortiz (3):
      NFC: llcp: Detach socket from process context only when releasing the=
 socket
      NFC: llcp: Keep the connected socket parent pointer alive
      NFC: microread: Fix build failure due to a new MEI bus API

Stone Piao (1):
      mwifiex: limit channel number not to overflow memory

Thierry Escande (1):
      NFC: llcp: Remove possible double call to kfree_skb

 drivers/net/wireless/iwlwifi/dvm/rxon.c | 18 +++++++---------
 drivers/net/wireless/iwlwifi/dvm/tx.c   |  2 +-
 drivers/net/wireless/mwifiex/cfg80211.c |  3 ++-
 drivers/nfc/microread/mei.c             | 38 +++++++++++++++--------------=
----
 net/mac80211/cfg.c                      |  6 ++++--
 net/mac80211/chan.c                     | 17 ++++++++++++---
 net/mac80211/ieee80211_i.h              |  4 +++-
 net/mac80211/iface.c                    |  2 +-
 net/mac80211/offchannel.c               | 23 ++++++++++++++------
 net/nfc/llcp/llcp.c                     |  8 -------
 net/nfc/llcp/sock.c                     |  6 +++---
 11 files changed, 70 insertions(+), 57 deletions(-)

diff --git a/drivers/net/wireless/iwlwifi/dvm/rxon.c b/drivers/net/wireless=
/iwlwifi/dvm/rxon.c
index 23be948..a82b6b3 100644
--- a/drivers/net/wireless/iwlwifi/dvm/rxon.c
+++ b/drivers/net/wireless/iwlwifi/dvm/rxon.c
@@ -1419,6 +1419,14 @@ void iwlagn_bss_info_changed(struct ieee80211_hw *hw,
=20
 	mutex_lock(&priv->mutex);
=20
+	if (changes & BSS_CHANGED_IDLE && bss_conf->idle) {
+		/*
+		 * If we go idle, then clearly no "passive-no-rx"
+		 * workaround is needed any more, this is a reset.
+		 */
+		iwlagn_lift_passive_no_rx(priv);
+	}
+
 	if (unlikely(!iwl_is_ready(priv))) {
 		IWL_DEBUG_MAC80211(priv, "leave - not ready\n");
 		mutex_unlock(&priv->mutex);
@@ -1450,16 +1458,6 @@ void iwlagn_bss_info_changed(struct ieee80211_hw *hw,
 			priv->timestamp =3D bss_conf->sync_tsf;
 			ctx->staging.filter_flags |=3D RXON_FILTER_ASSOC_MSK;
 		} else {
-			/*
-			 * If we disassociate while there are pending
-			 * frames, just wake up the queues and let the
-			 * frames "escape" ... This shouldn't really
-			 * be happening to start with, but we should
-			 * not get stuck in this case either since it
-			 * can happen if userspace gets confused.
-			 */
-			iwlagn_lift_passive_no_rx(priv);
-
 			ctx->staging.filter_flags &=3D ~RXON_FILTER_ASSOC_MSK;
=20
 			if (ctx->ctxid =3D=3D IWL_RXON_CTX_BSS)
diff --git a/drivers/net/wireless/iwlwifi/dvm/tx.c b/drivers/net/wireless/i=
wlwifi/dvm/tx.c
index 6aec2df..d1a670d 100644
--- a/drivers/net/wireless/iwlwifi/dvm/tx.c
+++ b/drivers/net/wireless/iwlwifi/dvm/tx.c
@@ -1192,7 +1192,7 @@ int iwlagn_rx_reply_tx(struct iwl_priv *priv, struct =
iwl_rx_cmd_buffer *rxb,
 			memset(&info->status, 0, sizeof(info->status));
=20
 			if (status =3D=3D TX_STATUS_FAIL_PASSIVE_NO_RX &&
-			    iwl_is_associated_ctx(ctx) && ctx->vif &&
+			    ctx->vif &&
 			    ctx->vif->type =3D=3D NL80211_IFTYPE_STATION) {
 				/* block and stop all queues */
 				priv->passive_no_rx =3D true;
diff --git a/drivers/net/wireless/mwifiex/cfg80211.c b/drivers/net/wireless=
/mwifiex/cfg80211.c
index a44023a..8aaf56a 100644
--- a/drivers/net/wireless/mwifiex/cfg80211.c
+++ b/drivers/net/wireless/mwifiex/cfg80211.c
@@ -1892,7 +1892,8 @@ mwifiex_cfg80211_scan(struct wiphy *wiphy,
 		}
 	}
=20
-	for (i =3D 0; i < request->n_channels; i++) {
+	for (i =3D 0; i < min_t(u32, request->n_channels,
+			      MWIFIEX_USER_SCAN_CHAN_MAX); i++) {
 		chan =3D request->channels[i];
 		priv->user_scan_cfg->chan_list[i].chan_number =3D chan->hw_value;
 		priv->user_scan_cfg->chan_list[i].radio_type =3D chan->band;
diff --git a/drivers/nfc/microread/mei.c b/drivers/nfc/microread/mei.c
index eef38cf..ca33ae1 100644
--- a/drivers/nfc/microread/mei.c
+++ b/drivers/nfc/microread/mei.c
@@ -22,7 +22,7 @@
 #include <linux/slab.h>
 #include <linux/interrupt.h>
 #include <linux/gpio.h>
-#include <linux/mei_bus.h>
+#include <linux/mei_cl_bus.h>
=20
 #include <linux/nfc.h>
 #include <net/nfc/hci.h>
@@ -32,9 +32,6 @@
=20
 #define MICROREAD_DRIVER_NAME "microread"
=20
-#define MICROREAD_UUID UUID_LE(0x0bb17a78, 0x2a8e, 0x4c50, 0x94, \
-			       0xd4, 0x50, 0x26, 0x67, 0x23, 0x77, 0x5c)
-
 struct mei_nfc_hdr {
 	u8 cmd;
 	u8 status;
@@ -48,7 +45,7 @@ struct mei_nfc_hdr {
 #define MEI_NFC_MAX_READ (MEI_NFC_HEADER_SIZE + MEI_NFC_MAX_HCI_PAYLOAD)
=20
 struct microread_mei_phy {
-	struct mei_device *mei_device;
+	struct mei_cl_device *device;
 	struct nfc_hci_dev *hdev;
=20
 	int powered;
@@ -105,14 +102,14 @@ static int microread_mei_write(void *phy_id, struct s=
k_buff *skb)
=20
 	MEI_DUMP_SKB_OUT("mei frame sent", skb);
=20
-	r =3D mei_send(phy->device, skb->data, skb->len);
+	r =3D mei_cl_send(phy->device, skb->data, skb->len);
 	if (r > 0)
 		r =3D 0;
=20
 	return r;
 }
=20
-static void microread_event_cb(struct mei_device *device, u32 events,
+static void microread_event_cb(struct mei_cl_device *device, u32 events,
 			       void *context)
 {
 	struct microread_mei_phy *phy =3D context;
@@ -120,7 +117,7 @@ static void microread_event_cb(struct mei_device *devic=
e, u32 events,
 	if (phy->hard_fault !=3D 0)
 		return;
=20
-	if (events & BIT(MEI_EVENT_RX)) {
+	if (events & BIT(MEI_CL_EVENT_RX)) {
 		struct sk_buff *skb;
 		int reply_size;
=20
@@ -128,7 +125,7 @@ static void microread_event_cb(struct mei_device *devic=
e, u32 events,
 		if (!skb)
 			return;
=20
-		reply_size =3D mei_recv(device, skb->data, MEI_NFC_MAX_READ);
+		reply_size =3D mei_cl_recv(device, skb->data, MEI_NFC_MAX_READ);
 		if (reply_size < MEI_NFC_HEADER_SIZE) {
 			kfree(skb);
 			return;
@@ -149,8 +146,8 @@ static struct nfc_phy_ops mei_phy_ops =3D {
 	.disable =3D microread_mei_disable,
 };
=20
-static int microread_mei_probe(struct mei_device *device,
-			       const struct mei_id *id)
+static int microread_mei_probe(struct mei_cl_device *device,
+			       const struct mei_cl_device_id *id)
 {
 	struct microread_mei_phy *phy;
 	int r;
@@ -164,9 +161,9 @@ static int microread_mei_probe(struct mei_device *devic=
e,
 	}
=20
 	phy->device =3D device;
-	mei_set_clientdata(device, phy);
+	mei_cl_set_drvdata(device, phy);
=20
-	r =3D mei_register_event_cb(device, microread_event_cb, phy);
+	r =3D mei_cl_register_event_cb(device, microread_event_cb, phy);
 	if (r) {
 		pr_err(MICROREAD_DRIVER_NAME ": event cb registration failed\n");
 		goto err_out;
@@ -186,9 +183,9 @@ err_out:
 	return r;
 }
=20
-static int microread_mei_remove(struct mei_device *device)
+static int microread_mei_remove(struct mei_cl_device *device)
 {
-	struct microread_mei_phy *phy =3D mei_get_clientdata(device);
+	struct microread_mei_phy *phy =3D mei_cl_get_drvdata(device);
=20
 	pr_info("Removing microread\n");
=20
@@ -202,16 +199,15 @@ static int microread_mei_remove(struct mei_device *de=
vice)
 	return 0;
 }
=20
-static struct mei_id microread_mei_tbl[] =3D {
-	{ MICROREAD_DRIVER_NAME, MICROREAD_UUID },
+static struct mei_cl_device_id microread_mei_tbl[] =3D {
+	{ MICROREAD_DRIVER_NAME },
=20
 	/* required last entry */
 	{ }
 };
-
 MODULE_DEVICE_TABLE(mei, microread_mei_tbl);
=20
-static struct mei_driver microread_driver =3D {
+static struct mei_cl_driver microread_driver =3D {
 	.id_table =3D microread_mei_tbl,
 	.name =3D MICROREAD_DRIVER_NAME,
=20
@@ -225,7 +221,7 @@ static int microread_mei_init(void)
=20
 	pr_debug(DRIVER_DESC ": %s\n", __func__);
=20
-	r =3D mei_driver_register(&microread_driver);
+	r =3D mei_cl_driver_register(&microread_driver);
 	if (r) {
 		pr_err(MICROREAD_DRIVER_NAME ": driver registration failed\n");
 		return r;
@@ -236,7 +232,7 @@ static int microread_mei_init(void)
=20
 static void microread_mei_exit(void)
 {
-	mei_driver_unregister(&microread_driver);
+	mei_cl_driver_unregister(&microread_driver);
 }
=20
 module_init(microread_mei_init);
diff --git a/net/mac80211/cfg.c b/net/mac80211/cfg.c
index fb30681..a689360 100644
--- a/net/mac80211/cfg.c
+++ b/net/mac80211/cfg.c
@@ -2582,7 +2582,7 @@ static int ieee80211_cancel_roc(struct ieee80211_loca=
l *local,
 			list_del(&dep->list);
 			mutex_unlock(&local->mtx);
=20
-			ieee80211_roc_notify_destroy(dep);
+			ieee80211_roc_notify_destroy(dep, true);
 			return 0;
 		}
=20
@@ -2622,7 +2622,7 @@ static int ieee80211_cancel_roc(struct ieee80211_loca=
l *local,
 			ieee80211_start_next_roc(local);
 		mutex_unlock(&local->mtx);
=20
-		ieee80211_roc_notify_destroy(found);
+		ieee80211_roc_notify_destroy(found, true);
 	} else {
 		/* work may be pending so use it all the time */
 		found->abort =3D true;
@@ -2632,6 +2632,8 @@ static int ieee80211_cancel_roc(struct ieee80211_loca=
l *local,
=20
 		/* work will clean up etc */
 		flush_delayed_work(&found->work);
+		WARN_ON(!found->to_be_freed);
+		kfree(found);
 	}
=20
 	return 0;
diff --git a/net/mac80211/chan.c b/net/mac80211/chan.c
index 78c0d90..931be41 100644
--- a/net/mac80211/chan.c
+++ b/net/mac80211/chan.c
@@ -63,6 +63,7 @@ ieee80211_new_chanctx(struct ieee80211_local *local,
 		      enum ieee80211_chanctx_mode mode)
 {
 	struct ieee80211_chanctx *ctx;
+	u32 changed;
 	int err;
=20
 	lockdep_assert_held(&local->chanctx_mtx);
@@ -76,6 +77,13 @@ ieee80211_new_chanctx(struct ieee80211_local *local,
 	ctx->conf.rx_chains_dynamic =3D 1;
 	ctx->mode =3D mode;
=20
+	/* acquire mutex to prevent idle from changing */
+	mutex_lock(&local->mtx);
+	/* turn idle off *before* setting channel -- some drivers need that */
+	changed =3D ieee80211_idle_off(local);
+	if (changed)
+		ieee80211_hw_config(local, changed);
+
 	if (!local->use_chanctx) {
 		local->_oper_channel_type =3D
 			cfg80211_get_chandef_type(chandef);
@@ -85,14 +93,17 @@ ieee80211_new_chanctx(struct ieee80211_local *local,
 		err =3D drv_add_chanctx(local, ctx);
 		if (err) {
 			kfree(ctx);
-			return ERR_PTR(err);
+			ctx =3D ERR_PTR(err);
+
+			ieee80211_recalc_idle(local);
+			goto out;
 		}
 	}
=20
+	/* and keep the mutex held until the new chanctx is on the list */
 	list_add_rcu(&ctx->list, &local->chanctx_list);
=20
-	mutex_lock(&local->mtx);
-	ieee80211_recalc_idle(local);
+ out:
 	mutex_unlock(&local->mtx);
=20
 	return ctx;
diff --git a/net/mac80211/ieee80211_i.h b/net/mac80211/ieee80211_i.h
index 388580a..5672533 100644
--- a/net/mac80211/ieee80211_i.h
+++ b/net/mac80211/ieee80211_i.h
@@ -309,6 +309,7 @@ struct ieee80211_roc_work {
 	struct ieee80211_channel *chan;
=20
 	bool started, abort, hw_begun, notified;
+	bool to_be_freed;
=20
 	unsigned long hw_start_time;
=20
@@ -1347,7 +1348,7 @@ void ieee80211_offchannel_return(struct ieee80211_loc=
al *local);
 void ieee80211_roc_setup(struct ieee80211_local *local);
 void ieee80211_start_next_roc(struct ieee80211_local *local);
 void ieee80211_roc_purge(struct ieee80211_sub_if_data *sdata);
-void ieee80211_roc_notify_destroy(struct ieee80211_roc_work *roc);
+void ieee80211_roc_notify_destroy(struct ieee80211_roc_work *roc, bool fre=
e);
 void ieee80211_sw_roc_work(struct work_struct *work);
 void ieee80211_handle_roc_started(struct ieee80211_roc_work *roc);
=20
@@ -1361,6 +1362,7 @@ int ieee80211_if_change_type(struct ieee80211_sub_if_=
data *sdata,
 			     enum nl80211_iftype type);
 void ieee80211_if_remove(struct ieee80211_sub_if_data *sdata);
 void ieee80211_remove_interfaces(struct ieee80211_local *local);
+u32 ieee80211_idle_off(struct ieee80211_local *local);
 void ieee80211_recalc_idle(struct ieee80211_local *local);
 void ieee80211_adjust_monitor_flags(struct ieee80211_sub_if_data *sdata,
 				    const int offset);
diff --git a/net/mac80211/iface.c b/net/mac80211/iface.c
index 3bfe261..58150f8 100644
--- a/net/mac80211/iface.c
+++ b/net/mac80211/iface.c
@@ -78,7 +78,7 @@ void ieee80211_recalc_txpower(struct ieee80211_sub_if_dat=
a *sdata)
 		ieee80211_bss_info_change_notify(sdata, BSS_CHANGED_TXPOWER);
 }
=20
-static u32 ieee80211_idle_off(struct ieee80211_local *local)
+u32 ieee80211_idle_off(struct ieee80211_local *local)
 {
 	if (!(local->hw.conf.flags & IEEE80211_CONF_IDLE))
 		return 0;
diff --git a/net/mac80211/offchannel.c b/net/mac80211/offchannel.c
index cc79b4a..430bd25 100644
--- a/net/mac80211/offchannel.c
+++ b/net/mac80211/offchannel.c
@@ -297,10 +297,13 @@ void ieee80211_start_next_roc(struct ieee80211_local =
*local)
 	}
 }
=20
-void ieee80211_roc_notify_destroy(struct ieee80211_roc_work *roc)
+void ieee80211_roc_notify_destroy(struct ieee80211_roc_work *roc, bool fre=
e)
 {
 	struct ieee80211_roc_work *dep, *tmp;
=20
+	if (WARN_ON(roc->to_be_freed))
+		return;
+
 	/* was never transmitted */
 	if (roc->frame) {
 		cfg80211_mgmt_tx_status(&roc->sdata->wdev,
@@ -316,9 +319,12 @@ void ieee80211_roc_notify_destroy(struct ieee80211_roc=
_work *roc)
 						   GFP_KERNEL);
=20
 	list_for_each_entry_safe(dep, tmp, &roc->dependents, list)
-		ieee80211_roc_notify_destroy(dep);
+		ieee80211_roc_notify_destroy(dep, true);
=20
-	kfree(roc);
+	if (free)
+		kfree(roc);
+	else
+		roc->to_be_freed =3D true;
 }
=20
 void ieee80211_sw_roc_work(struct work_struct *work)
@@ -331,6 +337,9 @@ void ieee80211_sw_roc_work(struct work_struct *work)
=20
 	mutex_lock(&local->mtx);
=20
+	if (roc->to_be_freed)
+		goto out_unlock;
+
 	if (roc->abort)
 		goto finish;
=20
@@ -370,7 +379,7 @@ void ieee80211_sw_roc_work(struct work_struct *work)
  finish:
 		list_del(&roc->list);
 		started =3D roc->started;
-		ieee80211_roc_notify_destroy(roc);
+		ieee80211_roc_notify_destroy(roc, !roc->abort);
=20
 		if (started) {
 			drv_flush(local, false);
@@ -410,7 +419,7 @@ static void ieee80211_hw_roc_done(struct work_struct *w=
ork)
=20
 	list_del(&roc->list);
=20
-	ieee80211_roc_notify_destroy(roc);
+	ieee80211_roc_notify_destroy(roc, true);
=20
 	/* if there's another roc, start it now */
 	ieee80211_start_next_roc(local);
@@ -460,12 +469,14 @@ void ieee80211_roc_purge(struct ieee80211_sub_if_data=
 *sdata)
 	list_for_each_entry_safe(roc, tmp, &tmp_list, list) {
 		if (local->ops->remain_on_channel) {
 			list_del(&roc->list);
-			ieee80211_roc_notify_destroy(roc);
+			ieee80211_roc_notify_destroy(roc, true);
 		} else {
 			ieee80211_queue_delayed_work(&local->hw, &roc->work, 0);
=20
 			/* work will clean up etc */
 			flush_delayed_work(&roc->work);
+			WARN_ON(!roc->to_be_freed);
+			kfree(roc);
 		}
 	}
=20
diff --git a/net/nfc/llcp/llcp.c b/net/nfc/llcp/llcp.c
index b530afa..ee25f25 100644
--- a/net/nfc/llcp/llcp.c
+++ b/net/nfc/llcp/llcp.c
@@ -107,8 +107,6 @@ static void nfc_llcp_socket_release(struct nfc_llcp_loc=
al *local, bool listen,
 				accept_sk->sk_state_change(sk);
=20
 				bh_unlock_sock(accept_sk);
-
-				sock_orphan(accept_sk);
 			}
=20
 			if (listen =3D=3D true) {
@@ -134,8 +132,6 @@ static void nfc_llcp_socket_release(struct nfc_llcp_loc=
al *local, bool listen,
=20
 		bh_unlock_sock(sk);
=20
-		sock_orphan(sk);
-
 		sk_del_node_init(sk);
 	}
=20
@@ -164,8 +160,6 @@ static void nfc_llcp_socket_release(struct nfc_llcp_loc=
al *local, bool listen,
=20
 		bh_unlock_sock(sk);
=20
-		sock_orphan(sk);
-
 		sk_del_node_init(sk);
 	}
=20
@@ -827,7 +821,6 @@ static void nfc_llcp_recv_ui(struct nfc_llcp_local *loc=
al,
 		skb_get(skb);
 	} else {
 		pr_err("Receive queue is full\n");
-		kfree_skb(skb);
 	}
=20
 	nfc_llcp_sock_put(llcp_sock);
@@ -1028,7 +1021,6 @@ static void nfc_llcp_recv_hdlc(struct nfc_llcp_local =
*local,
 			skb_get(skb);
 		} else {
 			pr_err("Receive queue is full\n");
-			kfree_skb(skb);
 		}
 	}
=20
diff --git a/net/nfc/llcp/sock.c b/net/nfc/llcp/sock.c
index 5c7cdf3..8f02574 100644
--- a/net/nfc/llcp/sock.c
+++ b/net/nfc/llcp/sock.c
@@ -270,7 +270,9 @@ struct sock *nfc_llcp_accept_dequeue(struct sock *paren=
t,
 		}
=20
 		if (sk->sk_state =3D=3D LLCP_CONNECTED || !newsock) {
-			nfc_llcp_accept_unlink(sk);
+			list_del_init(&lsk->accept_queue);
+			sock_put(sk);
+
 			if (newsock)
 				sock_graft(sk, newsock);
=20
@@ -464,8 +466,6 @@ static int llcp_sock_release(struct socket *sock)
 			nfc_llcp_accept_unlink(accept_sk);
=20
 			release_sock(accept_sk);
-
-			sock_orphan(accept_sk);
 		}
 	}
=20
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--Dxnq1zWXvFF0Q93v
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)

iQIcBAEBAgAGBQJRXHIPAAoJEJctW/TcYTgGe84P+wfOROYqkg8qZkCIcujG91pa
VzeVVKlTFCJN0FNjqUgGSRtbJUwnDpt9ulqfzIlyTzBUxgKZGrhvyh0JqFIJKkxp
oEKwcxH2GUsj31BC1jPP3dBuv4d6Gs6DfI6FpYrzoGchN65WlKWzM0LlCf7ZpCwl
HpEkFE7yMMhv2sjOpsi1oyAly3FWuxmNX8oQqSKheRSTAE2nX7qGcdKtZJJv3l6A
DyER8l/f8oVPI5HYq42HgQag2xgJbTRQIWi3Xss/OL8Efzg/l9HPF9S7lslWG5iQ
oOIP9BX8vrQUu7bXPpHYA8EIUtSdRxQa8+PPxSZ12DK00fU4i2h2cYRs/QbQFlca
uLjhj1dFfhlJ1bhl1RbchGEH5TRSeuqNFh9v1/nDdmlX8w8hbiApfKLkERgB7qyI
fOX0uIRDcOkqIdtlUmvn1eMJmOSRsXkscIz091mJw7jj+XwpOcjKbQ/U2H01WLwl
3SpgpXJngiSZSeeBzKEa0uf7nl1BOJjiCryPIj8Ii5BZlcEgP0u8t0IOWin6+nw4
awQSD7PJnol3c/9hdtHt5z8YTYkP8gUXVzKaNuMoy3XewzzLwEnPfFzg7u91h1K8
p5u00F6qYX+7B66T89TiNk4VACUkk6Sxyu4GoU62ybpQGqthq6uH7697EtMnvJ6H
aWFM0jgenwhsM6CPYWuU
=RjMH
-----END PGP SIGNATURE-----

--Dxnq1zWXvFF0Q93v--
