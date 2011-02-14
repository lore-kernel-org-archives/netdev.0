From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-2.6 2011-02-14
Date: Mon, 14 Feb 2011 15:44:06 -0500
Message-ID: <20110214204406.GG2722@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dave,

A handful of fixes intended for 2.6.38...

This includes a couple of bluetooth device IDs, a bluetooth one-liner
to avoid multiple connection responses, a locking fix to avoid some
log spam, and a patch to turn off PCLP health checking for iwl3945
(because the checking has not proven helpful and it kills performance).

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit ddfdb508866b3c07b295f6c85c271981d88afe4c:

  net/can/softing: make CAN_SOFTING_CS depend on CAN_SOFTING (2011-02-14 11:44:01 -0800)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

Bao Liang (1):
      Bluetooth: Set conn state to BT_DISCONN to avoid multiple responses

Cho, Yu-Chen (1):
      Bluetooth: add Atheros BT AR9285 fw supported

Eliad Peller (1):
      mac80211: add missing locking in ieee80211_reconfig

John W. Linville (1):
      Merge branch 'master' of git://git.kernel.org/.../padovan/bluetooth-2.6

Stanislaw Gruszka (1):
      iwl3945: remove plcp check

 drivers/bluetooth/ath3k.c               |    2 ++
 drivers/bluetooth/btusb.c               |    3 +++
 drivers/net/wireless/iwlwifi/iwl-3945.c |    1 -
 net/bluetooth/l2cap.c                   |    1 +
 net/mac80211/util.c                     |    2 ++
 5 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/drivers/bluetooth/ath3k.c b/drivers/bluetooth/ath3k.c
index a126e61..333c212 100644
--- a/drivers/bluetooth/ath3k.c
+++ b/drivers/bluetooth/ath3k.c
@@ -39,6 +39,8 @@ static struct usb_device_id ath3k_table[] = {
 	/* Atheros AR3011 with sflash firmware*/
 	{ USB_DEVICE(0x0CF3, 0x3002) },
 
+	/* Atheros AR9285 Malbec with sflash firmware */
+	{ USB_DEVICE(0x03F0, 0x311D) },
 	{ }	/* Terminating entry */
 };
 
diff --git a/drivers/bluetooth/btusb.c b/drivers/bluetooth/btusb.c
index 1da773f..4cefa91 100644
--- a/drivers/bluetooth/btusb.c
+++ b/drivers/bluetooth/btusb.c
@@ -102,6 +102,9 @@ static struct usb_device_id blacklist_table[] = {
 	/* Atheros 3011 with sflash firmware */
 	{ USB_DEVICE(0x0cf3, 0x3002), .driver_info = BTUSB_IGNORE },
 
+	/* Atheros AR9285 Malbec with sflash firmware */
+	{ USB_DEVICE(0x03f0, 0x311d), .driver_info = BTUSB_IGNORE },
+
 	/* Broadcom BCM2035 */
 	{ USB_DEVICE(0x0a5c, 0x2035), .driver_info = BTUSB_WRONG_SCO_MTU },
 	{ USB_DEVICE(0x0a5c, 0x200a), .driver_info = BTUSB_WRONG_SCO_MTU },
diff --git a/drivers/net/wireless/iwlwifi/iwl-3945.c b/drivers/net/wireless/iwlwifi/iwl-3945.c
index a9b852b..3eb14fd 100644
--- a/drivers/net/wireless/iwlwifi/iwl-3945.c
+++ b/drivers/net/wireless/iwlwifi/iwl-3945.c
@@ -2734,7 +2734,6 @@ static struct iwl_lib_ops iwl3945_lib = {
 	.isr_ops = {
 		.isr = iwl_isr_legacy,
 	},
-	.check_plcp_health = iwl3945_good_plcp_health,
 
 	.debugfs_ops = {
 		.rx_stats_read = iwl3945_ucode_rx_stats_read,
diff --git a/net/bluetooth/l2cap.c b/net/bluetooth/l2cap.c
index 7550abb..675614e 100644
--- a/net/bluetooth/l2cap.c
+++ b/net/bluetooth/l2cap.c
@@ -859,6 +859,7 @@ static void __l2cap_sock_close(struct sock *sk, int reason)
 				result = L2CAP_CR_SEC_BLOCK;
 			else
 				result = L2CAP_CR_BAD_PSM;
+			sk->sk_state = BT_DISCONN;
 
 			rsp.scid   = cpu_to_le16(l2cap_pi(sk)->dcid);
 			rsp.dcid   = cpu_to_le16(l2cap_pi(sk)->scid);
diff --git a/net/mac80211/util.c b/net/mac80211/util.c
index cf68700..d036597 100644
--- a/net/mac80211/util.c
+++ b/net/mac80211/util.c
@@ -1210,7 +1210,9 @@ int ieee80211_reconfig(struct ieee80211_local *local)
 		switch (sdata->vif.type) {
 		case NL80211_IFTYPE_STATION:
 			changed |= BSS_CHANGED_ASSOC;
+			mutex_lock(&sdata->u.mgd.mtx);
 			ieee80211_bss_info_change_notify(sdata, changed);
+			mutex_unlock(&sdata->u.mgd.mtx);
 			break;
 		case NL80211_IFTYPE_ADHOC:
 			changed |= BSS_CHANGED_IBSS;
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
