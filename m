From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless 2014-12-16
Date: Tue, 16 Dec 2014 13:16:13 -0500
Message-ID: <20141216181613.GF19658@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="lEGEL1/lMxI0MVQ2"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--lEGEL1/lMxI0MVQ2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Dave,

Please pull this batch of fixes intended for the 3.19 stream!

For the Bluetooth bits, Johan says:

"The patches consist of:

 - Coccinelle warning fix
 - hci_dev_lock/unlock fixes
 - Fixes for pending mgmt command handling
 - Fixes for properly following the force_lesc_support switch
 - Fix for a Microsoft branded Broadcom adapter
 - New device id for Atheros AR3012
 - Fix for BR/EDR Secure Connections enabling"

Along with that...

Brian Norris avoids leaking some kernel memory contents via printk in brcms=
mac.

Julia Lawall corrects some misspellings in a few drivers.

Larry Finger gives us one more rtlwifi fix to correct a porting oversight.

Wei Yongjun fixes a sparse warning in rtlwifi.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 67e2c3883828b39548cee2091b36656787775d95:

  Merge branch 'next' of git://git.kernel.org/pub/scm/linux/kernel/git/jmor=
ris/linux-security (2014-12-14 20:36:37 -0800)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git tags/=
master-2014-12-15

for you to fetch changes up to 9a1dce3a059111a7289680f4b8c0ec4f8736b6ee:

  rtlwifi: rtl8192ce: Set fw_ready flag (2014-12-15 13:46:20 -0500)

----------------------------------------------------------------
Brian Norris (1):
      brcmsmac: don't leak kernel memory via printk()

Fengguang Wu (1):
      Bluetooth: fix err_cast.cocci warnings

Jaganath Kanakkassery (2):
      Bluetooth: Fix missing hci_dev_lock/unlock in mgmt req_complete()
      Bluetooth: Fix missing hci_dev_lock/unlock in hci_event

Janne Heikkinen (1):
      Bluetooth: Add USB device 04ca:3010 as Atheros AR3012

Johan Hedberg (5):
      Bluetooth: Fix calling hci_conn_put too early
      Bluetooth: Fix incorrect pending cmd removal in pairing_complete()
      Bluetooth: Fix notifying mgmt power off before flushing connection li=
st
      Bluetooth: Fix enabling BR/EDR SC when powering on
      Bluetooth: Fix mgmt response status when removing adapter

John W. Linville (1):
      Merge branch 'for-upstream' of git://git.kernel.org/.../bluetooth/blu=
etooth-next

Julia Lawall (3):
      zd1211rw: fix misspelling of current function in string
      hostap_cs: fix misspelling of current function in string
      rtlwifi: rtl8821ae: fix misspelling of current function in string

Larry Finger (1):
      rtlwifi: rtl8192ce: Set fw_ready flag

Marcel Holtmann (4):
      Bluetooth: Check for force_lesc_support when enabling SMP over BR/EDR
      Bluetooth: Check for force_lesc_support before rejecting SMP over BR/=
EDR
      Bluetooth: Fix generation of non-resolvable private addresses
      Bluetooth: Fix check for support for page scan related commands

Wei Yongjun (1):
      rtlwifi: rtl8192cu: Fix sparse non static symbol warning

 drivers/bluetooth/ath3k.c                      |  2 +
 drivers/bluetooth/btusb.c                      |  1 +
 drivers/net/wireless/brcm80211/brcmsmac/main.c |  2 +-
 drivers/net/wireless/hostap/hostap_cs.c        | 15 ++---
 drivers/net/wireless/rtlwifi/rtl8192ce/hw.c    |  2 +
 drivers/net/wireless/rtlwifi/rtl8192cu/hw.c    |  2 +-
 drivers/net/wireless/rtlwifi/rtl8821ae/dm.c    | 11 ++--
 drivers/net/wireless/zd1211rw/zd_chip.c        |  6 +-
 net/bluetooth/hci_conn.c                       |  2 +-
 net/bluetooth/hci_core.c                       | 60 ++++++++++--------
 net/bluetooth/hci_event.c                      | 20 ++++++
 net/bluetooth/l2cap_core.c                     |  5 +-
 net/bluetooth/mgmt.c                           | 85 ++++++++++++++++++----=
----
 net/bluetooth/smp.c                            |  5 +-
 14 files changed, 143 insertions(+), 75 deletions(-)

diff --git a/drivers/bluetooth/ath3k.c b/drivers/bluetooth/ath3k.c
index fce758896280..1ee27ac18de0 100644
--- a/drivers/bluetooth/ath3k.c
+++ b/drivers/bluetooth/ath3k.c
@@ -87,6 +87,7 @@ static const struct usb_device_id ath3k_table[] =3D {
 	{ USB_DEVICE(0x04CA, 0x3007) },
 	{ USB_DEVICE(0x04CA, 0x3008) },
 	{ USB_DEVICE(0x04CA, 0x300b) },
+	{ USB_DEVICE(0x04CA, 0x3010) },
 	{ USB_DEVICE(0x0930, 0x0219) },
 	{ USB_DEVICE(0x0930, 0x0220) },
 	{ USB_DEVICE(0x0930, 0x0227) },
@@ -140,6 +141,7 @@ static const struct usb_device_id ath3k_blist_tbl[] =3D=
 {
 	{ USB_DEVICE(0x04ca, 0x3007), .driver_info =3D BTUSB_ATH3012 },
 	{ USB_DEVICE(0x04ca, 0x3008), .driver_info =3D BTUSB_ATH3012 },
 	{ USB_DEVICE(0x04ca, 0x300b), .driver_info =3D BTUSB_ATH3012 },
+	{ USB_DEVICE(0x04ca, 0x3010), .driver_info =3D BTUSB_ATH3012 },
 	{ USB_DEVICE(0x0930, 0x0219), .driver_info =3D BTUSB_ATH3012 },
 	{ USB_DEVICE(0x0930, 0x0220), .driver_info =3D BTUSB_ATH3012 },
 	{ USB_DEVICE(0x0930, 0x0227), .driver_info =3D BTUSB_ATH3012 },
diff --git a/drivers/bluetooth/btusb.c b/drivers/bluetooth/btusb.c
index 31dd24ac9926..19cf2cf22e87 100644
--- a/drivers/bluetooth/btusb.c
+++ b/drivers/bluetooth/btusb.c
@@ -167,6 +167,7 @@ static const struct usb_device_id blacklist_table[] =3D=
 {
 	{ USB_DEVICE(0x04ca, 0x3007), .driver_info =3D BTUSB_ATH3012 },
 	{ USB_DEVICE(0x04ca, 0x3008), .driver_info =3D BTUSB_ATH3012 },
 	{ USB_DEVICE(0x04ca, 0x300b), .driver_info =3D BTUSB_ATH3012 },
+	{ USB_DEVICE(0x04ca, 0x3010), .driver_info =3D BTUSB_ATH3012 },
 	{ USB_DEVICE(0x0930, 0x0219), .driver_info =3D BTUSB_ATH3012 },
 	{ USB_DEVICE(0x0930, 0x0220), .driver_info =3D BTUSB_ATH3012 },
 	{ USB_DEVICE(0x0930, 0x0227), .driver_info =3D BTUSB_ATH3012 },
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/main.c b/drivers/net/w=
ireless/brcm80211/brcmsmac/main.c
index a104d7ac3796..eb8584a9c49a 100644
--- a/drivers/net/wireless/brcm80211/brcmsmac/main.c
+++ b/drivers/net/wireless/brcm80211/brcmsmac/main.c
@@ -316,7 +316,7 @@ static const u16 xmtfifo_sz[][NFIFO] =3D {
 static const char * const fifo_names[] =3D {
 	"AC_BK", "AC_BE", "AC_VI", "AC_VO", "BCMC", "ATIM" };
 #else
-static const char fifo_names[6][0];
+static const char fifo_names[6][1];
 #endif
=20
 #ifdef DEBUG
diff --git a/drivers/net/wireless/hostap/hostap_cs.c b/drivers/net/wireless=
/hostap/hostap_cs.c
index b6ec51923b20..50033aa7c7d5 100644
--- a/drivers/net/wireless/hostap/hostap_cs.c
+++ b/drivers/net/wireless/hostap/hostap_cs.c
@@ -381,18 +381,15 @@ static void prism2_pccard_genesis_reset(local_info_t =
*local, int hcr)
=20
 	res =3D pcmcia_read_config_byte(hw_priv->link, CISREG_COR, &old_cor);
 	if (res !=3D 0) {
-		printk(KERN_DEBUG "prism2_pccard_genesis_sreset failed 1 "
-		       "(%d)\n", res);
+		printk(KERN_DEBUG "%s failed 1 (%d)\n", __func__, res);
 		return;
 	}
-	printk(KERN_DEBUG "prism2_pccard_genesis_sreset: original COR %02x\n",
-		old_cor);
+	printk(KERN_DEBUG "%s: original COR %02x\n", __func__, old_cor);
=20
 	res =3D pcmcia_write_config_byte(hw_priv->link, CISREG_COR,
 				old_cor | COR_SOFT_RESET);
 	if (res !=3D 0) {
-		printk(KERN_DEBUG "prism2_pccard_genesis_sreset failed 2 "
-		       "(%d)\n", res);
+		printk(KERN_DEBUG "%s failed 2 (%d)\n", __func__, res);
 		return;
 	}
=20
@@ -401,8 +398,7 @@ static void prism2_pccard_genesis_reset(local_info_t *l=
ocal, int hcr)
 	/* Setup Genesis mode */
 	res =3D pcmcia_write_config_byte(hw_priv->link, CISREG_CCSR, hcr);
 	if (res !=3D 0) {
-		printk(KERN_DEBUG "prism2_pccard_genesis_sreset failed 3 "
-		       "(%d)\n", res);
+		printk(KERN_DEBUG "%s failed 3 (%d)\n", __func__, res);
 		return;
 	}
 	mdelay(10);
@@ -410,8 +406,7 @@ static void prism2_pccard_genesis_reset(local_info_t *l=
ocal, int hcr)
 	res =3D pcmcia_write_config_byte(hw_priv->link, CISREG_COR,
 				old_cor & ~COR_SOFT_RESET);
 	if (res !=3D 0) {
-		printk(KERN_DEBUG "prism2_pccard_genesis_sreset failed 4 "
-		       "(%d)\n", res);
+		printk(KERN_DEBUG "%s failed 4 (%d)\n", __func__, res);
 		return;
 	}
=20
diff --git a/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c b/drivers/net/wire=
less/rtlwifi/rtl8192ce/hw.c
index d2ec5160bbf0..5c646d5f7bb8 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c
@@ -955,6 +955,7 @@ int rtl92ce_hw_init(struct ieee80211_hw *hw)
 	local_save_flags(flags);
 	local_irq_enable();
=20
+	rtlhal->fw_ready =3D false;
 	rtlpriv->intf_ops->disable_aspm(hw);
 	rtstatus =3D _rtl92ce_init_mac(hw);
 	if (!rtstatus) {
@@ -971,6 +972,7 @@ int rtl92ce_hw_init(struct ieee80211_hw *hw)
 		goto exit;
 	}
=20
+	rtlhal->fw_ready =3D true;
 	rtlhal->last_hmeboxnum =3D 0;
 	rtl92c_phy_mac_config(hw);
 	/* because last function modify RCR, so we update
diff --git a/drivers/net/wireless/rtlwifi/rtl8192cu/hw.c b/drivers/net/wire=
less/rtlwifi/rtl8192cu/hw.c
index 873363acbacf..551321728ae0 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192cu/hw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192cu/hw.c
@@ -1592,7 +1592,7 @@ void rtl92cu_get_hw_reg(struct ieee80211_hw *hw, u8 v=
ariable, u8 *val)
 	}
 }
=20
-bool usb_cmd_send_packet(struct ieee80211_hw *hw, struct sk_buff *skb)
+static bool usb_cmd_send_packet(struct ieee80211_hw *hw, struct sk_buff *s=
kb)
 {
   /* Currently nothing happens here.
    * Traffic stops after some seconds in WPA2 802.11n mode.
diff --git a/drivers/net/wireless/rtlwifi/rtl8821ae/dm.c b/drivers/net/wire=
less/rtlwifi/rtl8821ae/dm.c
index 9be106109921..ba30b0d250fd 100644
--- a/drivers/net/wireless/rtlwifi/rtl8821ae/dm.c
+++ b/drivers/net/wireless/rtlwifi/rtl8821ae/dm.c
@@ -2078,8 +2078,7 @@ void rtl8821ae_dm_txpwr_track_set_pwr(struct ieee8021=
1_hw *hw,
 	if (rtldm->tx_rate !=3D 0xFF)
 		tx_rate =3D rtl8821ae_hw_rate_to_mrate(hw, rtldm->tx_rate);
=20
-	RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
-		 "=3D=3D=3D>rtl8812ae_dm_txpwr_track_set_pwr\n");
+	RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD, "=3D=3D=3D>%s\n", __func=
__);
=20
 	if (tx_rate !=3D 0xFF) { /* Mimic Modify High Rate BBSwing Limit.*/
 		/*CCK*/
@@ -2128,7 +2127,7 @@ void rtl8821ae_dm_txpwr_track_set_pwr(struct ieee8021=
1_hw *hw,
=20
 	if (method =3D=3D BBSWING) {
 		RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
-			 "=3D=3D=3D>rtl8812ae_dm_txpwr_track_set_pwr\n");
+			 "=3D=3D=3D>%s\n", __func__);
 		if (rf_path =3D=3D RF90_PATH_A) {
 			final_swing_idx[RF90_PATH_A] =3D
 				(rtldm->ofdm_index[RF90_PATH_A] >
@@ -2260,7 +2259,8 @@ void rtl8821ae_dm_txpower_tracking_callback_thermalme=
ter(
 	rtldm->txpower_trackinginit =3D true;
=20
 	RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
-		 "=3D=3D=3D>rtl8812ae_dm_txpower_tracking_callback_thermalmeter,\n pDM_O=
dm->BbSwingIdxCckBase: %d,pDM_Odm->BbSwingIdxOfdmBase[A]:%d, pDM_Odm->Defau=
ltOfdmIndex: %d\n",
+		 "=3D=3D=3D>%s,\n pDM_Odm->BbSwingIdxCckBase: %d,pDM_Odm->BbSwingIdxOfdm=
Base[A]:%d, pDM_Odm->DefaultOfdmIndex: %d\n",
+		 __func__,
 		 rtldm->swing_idx_cck_base,
 		 rtldm->swing_idx_ofdm_base[RF90_PATH_A],
 		 rtldm->default_ofdm_index);
@@ -2539,8 +2539,7 @@ void rtl8821ae_dm_txpower_tracking_callback_thermalme=
ter(
 		}
 	}
=20
-	RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
-		 "<=3D=3D=3Drtl8812ae_dm_txpower_tracking_callback_thermalmeter\n");
+	RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD, "<=3D=3D=3D%s\n", __func=
__);
 }
=20
 void rtl8821ae_dm_check_txpower_tracking_thermalmeter(struct ieee80211_hw =
*hw)
diff --git a/drivers/net/wireless/zd1211rw/zd_chip.c b/drivers/net/wireless=
/zd1211rw/zd_chip.c
index 73a49b868035..07b94eda9604 100644
--- a/drivers/net/wireless/zd1211rw/zd_chip.c
+++ b/drivers/net/wireless/zd1211rw/zd_chip.c
@@ -129,7 +129,7 @@ int zd_ioread32v_locked(struct zd_chip *chip, u32 *valu=
es, const zd_addr_t *addr
 	r =3D zd_ioread16v_locked(chip, v16, a16, count16);
 	if (r) {
 		dev_dbg_f(zd_chip_dev(chip),
-			  "error: zd_ioread16v_locked. Error number %d\n", r);
+			  "error: %s. Error number %d\n", __func__, r);
 		return r;
 	}
=20
@@ -256,8 +256,8 @@ int zd_iowrite32a_locked(struct zd_chip *chip,
 		if (r) {
 			zd_usb_iowrite16v_async_end(&chip->usb, 0);
 			dev_dbg_f(zd_chip_dev(chip),
-				"error _zd_iowrite32v_locked."
-				" Error number %d\n", r);
+				"error _%s. Error number %d\n", __func__,
+				r);
 			return r;
 		}
 	}
diff --git a/net/bluetooth/hci_conn.c b/net/bluetooth/hci_conn.c
index 79d84b88b8f0..fe18825cc8a4 100644
--- a/net/bluetooth/hci_conn.c
+++ b/net/bluetooth/hci_conn.c
@@ -661,7 +661,7 @@ static void hci_req_add_le_create_conn(struct hci_reque=
st *req,
 	memset(&cp, 0, sizeof(cp));
=20
 	/* Update random address, but set require_privacy to false so
-	 * that we never connect with an unresolvable address.
+	 * that we never connect with an non-resolvable address.
 	 */
 	if (hci_update_random_address(req, false, &own_addr_type))
 		return;
diff --git a/net/bluetooth/hci_core.c b/net/bluetooth/hci_core.c
index 93f92a085506..5dcacf9607e4 100644
--- a/net/bluetooth/hci_core.c
+++ b/net/bluetooth/hci_core.c
@@ -1373,8 +1373,6 @@ static void hci_init1_req(struct hci_request *req, un=
signed long opt)
=20
 static void bredr_setup(struct hci_request *req)
 {
-	struct hci_dev *hdev =3D req->hdev;
-
 	__le16 param;
 	__u8 flt_type;
=20
@@ -1403,14 +1401,6 @@ static void bredr_setup(struct hci_request *req)
 	/* Connection accept timeout ~20 secs */
 	param =3D cpu_to_le16(0x7d00);
 	hci_req_add(req, HCI_OP_WRITE_CA_TIMEOUT, 2, &param);
-
-	/* AVM Berlin (31), aka "BlueFRITZ!", reports version 1.2,
-	 * but it does not support page scan related HCI commands.
-	 */
-	if (hdev->manufacturer !=3D 31 && hdev->hci_ver > BLUETOOTH_VER_1_1) {
-		hci_req_add(req, HCI_OP_READ_PAGE_SCAN_ACTIVITY, 0, NULL);
-		hci_req_add(req, HCI_OP_READ_PAGE_SCAN_TYPE, 0, NULL);
-	}
 }
=20
 static void le_setup(struct hci_request *req)
@@ -1718,6 +1708,16 @@ static void hci_init3_req(struct hci_request *req, u=
nsigned long opt)
 	if (hdev->commands[5] & 0x10)
 		hci_setup_link_policy(req);
=20
+	if (hdev->commands[8] & 0x01)
+		hci_req_add(req, HCI_OP_READ_PAGE_SCAN_ACTIVITY, 0, NULL);
+
+	/* Some older Broadcom based Bluetooth 1.2 controllers do not
+	 * support the Read Page Scan Type command. Check support for
+	 * this command in the bit mask of supported commands.
+	 */
+	if (hdev->commands[13] & 0x01)
+		hci_req_add(req, HCI_OP_READ_PAGE_SCAN_TYPE, 0, NULL);
+
 	if (lmp_le_capable(hdev)) {
 		u8 events[8];
=20
@@ -2634,6 +2634,12 @@ static int hci_dev_do_close(struct hci_dev *hdev)
 	drain_workqueue(hdev->workqueue);
=20
 	hci_dev_lock(hdev);
+
+	if (!test_and_clear_bit(HCI_AUTO_OFF, &hdev->dev_flags)) {
+		if (hdev->dev_type =3D=3D HCI_BREDR)
+			mgmt_powered(hdev, 0);
+	}
+
 	hci_inquiry_cache_flush(hdev);
 	hci_pend_le_actions_clear(hdev);
 	hci_conn_hash_flush(hdev);
@@ -2681,14 +2687,6 @@ static int hci_dev_do_close(struct hci_dev *hdev)
 	hdev->flags &=3D BIT(HCI_RAW);
 	hdev->dev_flags &=3D ~HCI_PERSISTENT_MASK;
=20
-	if (!test_and_clear_bit(HCI_AUTO_OFF, &hdev->dev_flags)) {
-		if (hdev->dev_type =3D=3D HCI_BREDR) {
-			hci_dev_lock(hdev);
-			mgmt_powered(hdev, 0);
-			hci_dev_unlock(hdev);
-		}
-	}
-
 	/* Controller radio is available but is currently powered down */
 	hdev->amp_status =3D AMP_STATUS_POWERED_DOWN;
=20
@@ -3083,7 +3081,9 @@ static void hci_power_on(struct work_struct *work)
=20
 	err =3D hci_dev_do_open(hdev);
 	if (err < 0) {
+		hci_dev_lock(hdev);
 		mgmt_set_powered_failed(hdev, err);
+		hci_dev_unlock(hdev);
 		return;
 	}
=20
@@ -3959,17 +3959,29 @@ int hci_update_random_address(struct hci_request *r=
eq, bool require_privacy,
 	}
=20
 	/* In case of required privacy without resolvable private address,
-	 * use an unresolvable private address. This is useful for active
+	 * use an non-resolvable private address. This is useful for active
 	 * scanning and non-connectable advertising.
 	 */
 	if (require_privacy) {
-		bdaddr_t urpa;
+		bdaddr_t nrpa;
+
+		while (true) {
+			/* The non-resolvable private address is generated
+			 * from random six bytes with the two most significant
+			 * bits cleared.
+			 */
+			get_random_bytes(&nrpa, 6);
+			nrpa.b[5] &=3D 0x3f;
=20
-		get_random_bytes(&urpa, 6);
-		urpa.b[5] &=3D 0x3f;	/* Clear two most significant bits */
+			/* The non-resolvable private address shall not be
+			 * equal to the public address.
+			 */
+			if (bacmp(&hdev->bdaddr, &nrpa))
+				break;
+		}
=20
 		*own_addr_type =3D ADDR_LE_DEV_RANDOM;
-		set_random_addr(req, &urpa);
+		set_random_addr(req, &nrpa);
 		return 0;
 	}
=20
@@ -5625,7 +5637,7 @@ void hci_req_add_le_passive_scan(struct hci_request *=
req)
 	u8 filter_policy;
=20
 	/* Set require_privacy to false since no SCAN_REQ are send
-	 * during passive scanning. Not using an unresolvable address
+	 * during passive scanning. Not using an non-resolvable address
 	 * here is important so that peer devices using direct
 	 * advertising with our address will be correctly reported
 	 * by the controller.
diff --git a/net/bluetooth/hci_event.c b/net/bluetooth/hci_event.c
index 322abbbbcef9..39a5c8a01726 100644
--- a/net/bluetooth/hci_event.c
+++ b/net/bluetooth/hci_event.c
@@ -257,6 +257,8 @@ static void hci_cc_write_auth_enable(struct hci_dev *hd=
ev, struct sk_buff *skb)
 	if (!sent)
 		return;
=20
+	hci_dev_lock(hdev);
+
 	if (!status) {
 		__u8 param =3D *((__u8 *) sent);
=20
@@ -268,6 +270,8 @@ static void hci_cc_write_auth_enable(struct hci_dev *hd=
ev, struct sk_buff *skb)
=20
 	if (test_bit(HCI_MGMT, &hdev->dev_flags))
 		mgmt_auth_enable_complete(hdev, status);
+
+	hci_dev_unlock(hdev);
 }
=20
 static void hci_cc_write_encrypt_mode(struct hci_dev *hdev, struct sk_buff=
 *skb)
@@ -443,6 +447,8 @@ static void hci_cc_write_ssp_mode(struct hci_dev *hdev,=
 struct sk_buff *skb)
 	if (!sent)
 		return;
=20
+	hci_dev_lock(hdev);
+
 	if (!status) {
 		if (sent->mode)
 			hdev->features[1][0] |=3D LMP_HOST_SSP;
@@ -458,6 +464,8 @@ static void hci_cc_write_ssp_mode(struct hci_dev *hdev,=
 struct sk_buff *skb)
 		else
 			clear_bit(HCI_SSP_ENABLED, &hdev->dev_flags);
 	}
+
+	hci_dev_unlock(hdev);
 }
=20
 static void hci_cc_write_sc_support(struct hci_dev *hdev, struct sk_buff *=
skb)
@@ -471,6 +479,8 @@ static void hci_cc_write_sc_support(struct hci_dev *hde=
v, struct sk_buff *skb)
 	if (!sent)
 		return;
=20
+	hci_dev_lock(hdev);
+
 	if (!status) {
 		if (sent->support)
 			hdev->features[1][0] |=3D LMP_HOST_SC;
@@ -486,6 +496,8 @@ static void hci_cc_write_sc_support(struct hci_dev *hde=
v, struct sk_buff *skb)
 		else
 			clear_bit(HCI_SC_ENABLED, &hdev->dev_flags);
 	}
+
+	hci_dev_unlock(hdev);
 }
=20
 static void hci_cc_read_local_version(struct hci_dev *hdev, struct sk_buff=
 *skb)
@@ -1135,6 +1147,8 @@ static void hci_cc_le_set_scan_enable(struct hci_dev =
*hdev,
 	if (!cp)
 		return;
=20
+	hci_dev_lock(hdev);
+
 	switch (cp->enable) {
 	case LE_SCAN_ENABLE:
 		set_bit(HCI_LE_SCAN, &hdev->dev_flags);
@@ -1184,6 +1198,8 @@ static void hci_cc_le_set_scan_enable(struct hci_dev =
*hdev,
 		BT_ERR("Used reserved LE_Scan_Enable param %d", cp->enable);
 		break;
 	}
+
+	hci_dev_unlock(hdev);
 }
=20
 static void hci_cc_le_read_white_list_size(struct hci_dev *hdev,
@@ -1278,6 +1294,8 @@ static void hci_cc_write_le_host_supported(struct hci=
_dev *hdev,
 	if (!sent)
 		return;
=20
+	hci_dev_lock(hdev);
+
 	if (sent->le) {
 		hdev->features[1][0] |=3D LMP_HOST_LE;
 		set_bit(HCI_LE_ENABLED, &hdev->dev_flags);
@@ -1291,6 +1309,8 @@ static void hci_cc_write_le_host_supported(struct hci=
_dev *hdev,
 		hdev->features[1][0] |=3D LMP_HOST_LE_BREDR;
 	else
 		hdev->features[1][0] &=3D ~LMP_HOST_LE_BREDR;
+
+	hci_dev_unlock(hdev);
 }
=20
 static void hci_cc_set_adv_param(struct hci_dev *hdev, struct sk_buff *skb)
diff --git a/net/bluetooth/l2cap_core.c b/net/bluetooth/l2cap_core.c
index a2b6dfa38a0c..d04dc0095736 100644
--- a/net/bluetooth/l2cap_core.c
+++ b/net/bluetooth/l2cap_core.c
@@ -6966,8 +6966,9 @@ static struct l2cap_conn *l2cap_conn_add(struct hci_c=
onn *hcon)
 	    test_bit(HCI_HS_ENABLED, &hcon->hdev->dev_flags))
 		conn->local_fixed_chan |=3D L2CAP_FC_A2MP;
=20
-	if (bredr_sc_enabled(hcon->hdev) &&
-	    test_bit(HCI_LE_ENABLED, &hcon->hdev->dev_flags))
+	if (test_bit(HCI_LE_ENABLED, &hcon->hdev->dev_flags) &&
+	    (bredr_sc_enabled(hcon->hdev) ||
+	     test_bit(HCI_FORCE_LESC, &hcon->hdev->dbg_flags)))
 		conn->local_fixed_chan |=3D L2CAP_FC_SMP_BREDR;
=20
 	mutex_init(&conn->ident_lock);
diff --git a/net/bluetooth/mgmt.c b/net/bluetooth/mgmt.c
index 7384f1161336..06c2e652e4b6 100644
--- a/net/bluetooth/mgmt.c
+++ b/net/bluetooth/mgmt.c
@@ -2199,12 +2199,14 @@ static void le_enable_complete(struct hci_dev *hdev=
, u8 status)
 {
 	struct cmd_lookup match =3D { NULL, hdev };
=20
+	hci_dev_lock(hdev);
+
 	if (status) {
 		u8 mgmt_err =3D mgmt_status(status);
=20
 		mgmt_pending_foreach(MGMT_OP_SET_LE, hdev, cmd_status_rsp,
 				     &mgmt_err);
-		return;
+		goto unlock;
 	}
=20
 	mgmt_pending_foreach(MGMT_OP_SET_LE, hdev, settings_rsp, &match);
@@ -2222,17 +2224,16 @@ static void le_enable_complete(struct hci_dev *hdev=
, u8 status)
 	if (test_bit(HCI_LE_ENABLED, &hdev->dev_flags)) {
 		struct hci_request req;
=20
-		hci_dev_lock(hdev);
-
 		hci_req_init(&req, hdev);
 		update_adv_data(&req);
 		update_scan_rsp_data(&req);
 		hci_req_run(&req, NULL);
=20
 		hci_update_background_scan(hdev);
-
-		hci_dev_unlock(hdev);
 	}
+
+unlock:
+	hci_dev_unlock(hdev);
 }
=20
 static int set_le(struct sock *sk, struct hci_dev *hdev, void *data, u16 l=
en)
@@ -3114,14 +3115,13 @@ static void pairing_complete(struct pending_cmd *cm=
d, u8 status)
 	conn->disconn_cfm_cb =3D NULL;
=20
 	hci_conn_drop(conn);
-	hci_conn_put(conn);
-
-	mgmt_pending_remove(cmd);
=20
 	/* The device is paired so there is no need to remove
 	 * its connection parameters anymore.
 	 */
 	clear_bit(HCI_CONN_PARAM_REMOVAL_PEND, &conn->flags);
+
+	hci_conn_put(conn);
 }
=20
 void mgmt_smp_complete(struct hci_conn *conn, bool complete)
@@ -3130,8 +3130,10 @@ void mgmt_smp_complete(struct hci_conn *conn, bool c=
omplete)
 	struct pending_cmd *cmd;
=20
 	cmd =3D find_pairing(conn);
-	if (cmd)
+	if (cmd) {
 		cmd->cmd_complete(cmd, status);
+		mgmt_pending_remove(cmd);
+	}
 }
=20
 static void pairing_complete_cb(struct hci_conn *conn, u8 status)
@@ -3141,10 +3143,13 @@ static void pairing_complete_cb(struct hci_conn *co=
nn, u8 status)
 	BT_DBG("status %u", status);
=20
 	cmd =3D find_pairing(conn);
-	if (!cmd)
+	if (!cmd) {
 		BT_DBG("Unable to find a pending command");
-	else
-		cmd->cmd_complete(cmd, mgmt_status(status));
+		return;
+	}
+
+	cmd->cmd_complete(cmd, mgmt_status(status));
+	mgmt_pending_remove(cmd);
 }
=20
 static void le_pairing_complete_cb(struct hci_conn *conn, u8 status)
@@ -3157,10 +3162,13 @@ static void le_pairing_complete_cb(struct hci_conn =
*conn, u8 status)
 		return;
=20
 	cmd =3D find_pairing(conn);
-	if (!cmd)
+	if (!cmd) {
 		BT_DBG("Unable to find a pending command");
-	else
-		cmd->cmd_complete(cmd, mgmt_status(status));
+		return;
+	}
+
+	cmd->cmd_complete(cmd, mgmt_status(status));
+	mgmt_pending_remove(cmd);
 }
=20
 static int pair_device(struct sock *sk, struct hci_dev *hdev, void *data,
@@ -3274,8 +3282,10 @@ static int pair_device(struct sock *sk, struct hci_d=
ev *hdev, void *data,
 	cmd->user_data =3D hci_conn_get(conn);
=20
 	if ((conn->state =3D=3D BT_CONNECTED || conn->state =3D=3D BT_CONFIG) &&
-	    hci_conn_security(conn, sec_level, auth_type, true))
-		pairing_complete(cmd, 0);
+	    hci_conn_security(conn, sec_level, auth_type, true)) {
+		cmd->cmd_complete(cmd, 0);
+		mgmt_pending_remove(cmd);
+	}
=20
 	err =3D 0;
=20
@@ -3317,7 +3327,8 @@ static int cancel_pair_device(struct sock *sk, struct=
 hci_dev *hdev, void *data,
 		goto unlock;
 	}
=20
-	pairing_complete(cmd, MGMT_STATUS_CANCELLED);
+	cmd->cmd_complete(cmd, MGMT_STATUS_CANCELLED);
+	mgmt_pending_remove(cmd);
=20
 	err =3D cmd_complete(sk, hdev->id, MGMT_OP_CANCEL_PAIR_DEVICE, 0,
 			   addr, sizeof(*addr));
@@ -3791,7 +3802,7 @@ static bool trigger_discovery(struct hci_request *req=
, u8 *status)
=20
 		/* All active scans will be done with either a resolvable
 		 * private address (when privacy feature has been enabled)
-		 * or unresolvable private address.
+		 * or non-resolvable private address.
 		 */
 		err =3D hci_update_random_address(req, true, &own_addr_type);
 		if (err < 0) {
@@ -4279,12 +4290,14 @@ static void set_advertising_complete(struct hci_dev=
 *hdev, u8 status)
 {
 	struct cmd_lookup match =3D { NULL, hdev };
=20
+	hci_dev_lock(hdev);
+
 	if (status) {
 		u8 mgmt_err =3D mgmt_status(status);
=20
 		mgmt_pending_foreach(MGMT_OP_SET_ADVERTISING, hdev,
 				     cmd_status_rsp, &mgmt_err);
-		return;
+		goto unlock;
 	}
=20
 	if (test_bit(HCI_LE_ADV, &hdev->dev_flags))
@@ -4299,6 +4312,9 @@ static void set_advertising_complete(struct hci_dev *=
hdev, u8 status)
=20
 	if (match.sk)
 		sock_put(match.sk);
+
+unlock:
+	hci_dev_unlock(hdev);
 }
=20
 static int set_advertising(struct sock *sk, struct hci_dev *hdev, void *da=
ta,
@@ -6081,6 +6097,11 @@ static int powered_update_hci(struct hci_dev *hdev)
 		hci_req_add(&req, HCI_OP_WRITE_SSP_MODE, 1, &ssp);
 	}
=20
+	if (bredr_sc_enabled(hdev) && !lmp_host_sc_capable(hdev)) {
+		u8 sc =3D 0x01;
+		hci_req_add(&req, HCI_OP_WRITE_SC_SUPPORT, sizeof(sc), &sc);
+	}
+
 	if (test_bit(HCI_LE_ENABLED, &hdev->dev_flags) &&
 	    lmp_bredr_capable(hdev)) {
 		struct hci_cp_write_le_host_supported cp;
@@ -6130,8 +6151,7 @@ static int powered_update_hci(struct hci_dev *hdev)
 int mgmt_powered(struct hci_dev *hdev, u8 powered)
 {
 	struct cmd_lookup match =3D { NULL, hdev };
-	u8 status_not_powered =3D MGMT_STATUS_NOT_POWERED;
-	u8 zero_cod[] =3D { 0, 0, 0 };
+	u8 status, zero_cod[] =3D { 0, 0, 0 };
 	int err;
=20
 	if (!test_bit(HCI_MGMT, &hdev->dev_flags))
@@ -6147,7 +6167,20 @@ int mgmt_powered(struct hci_dev *hdev, u8 powered)
 	}
=20
 	mgmt_pending_foreach(MGMT_OP_SET_POWERED, hdev, settings_rsp, &match);
-	mgmt_pending_foreach(0, hdev, cmd_complete_rsp, &status_not_powered);
+
+	/* If the power off is because of hdev unregistration let
+	 * use the appropriate INVALID_INDEX status. Otherwise use
+	 * NOT_POWERED. We cover both scenarios here since later in
+	 * mgmt_index_removed() any hci_conn callbacks will have already
+	 * been triggered, potentially causing misleading DISCONNECTED
+	 * status responses.
+	 */
+	if (test_bit(HCI_UNREGISTER, &hdev->dev_flags))
+		status =3D MGMT_STATUS_INVALID_INDEX;
+	else
+		status =3D MGMT_STATUS_NOT_POWERED;
+
+	mgmt_pending_foreach(0, hdev, cmd_complete_rsp, &status);
=20
 	if (memcmp(hdev->dev_class, zero_cod, sizeof(zero_cod)) !=3D 0)
 		mgmt_event(MGMT_EV_CLASS_OF_DEV_CHANGED, hdev,
@@ -6681,8 +6714,10 @@ void mgmt_auth_failed(struct hci_conn *conn, u8 hci_=
status)
 	mgmt_event(MGMT_EV_AUTH_FAILED, conn->hdev, &ev, sizeof(ev),
 		    cmd ? cmd->sk : NULL);
=20
-	if (cmd)
-		pairing_complete(cmd, status);
+	if (cmd) {
+		cmd->cmd_complete(cmd, status);
+		mgmt_pending_remove(cmd);
+	}
 }
=20
 void mgmt_auth_enable_complete(struct hci_dev *hdev, u8 status)
diff --git a/net/bluetooth/smp.c b/net/bluetooth/smp.c
index 6a46252fe66f..b67749bb55bf 100644
--- a/net/bluetooth/smp.c
+++ b/net/bluetooth/smp.c
@@ -1673,7 +1673,8 @@ static u8 smp_cmd_pairing_req(struct l2cap_conn *conn=
, struct sk_buff *skb)
 	/* SMP over BR/EDR requires special treatment */
 	if (conn->hcon->type =3D=3D ACL_LINK) {
 		/* We must have a BR/EDR SC link */
-		if (!test_bit(HCI_CONN_AES_CCM, &conn->hcon->flags))
+		if (!test_bit(HCI_CONN_AES_CCM, &conn->hcon->flags) &&
+		    !test_bit(HCI_FORCE_LESC, &hdev->dbg_flags))
 			return SMP_CROSS_TRANSP_NOT_ALLOWED;
=20
 		set_bit(SMP_FLAG_SC, &smp->flags);
@@ -2927,7 +2928,7 @@ static struct l2cap_chan *smp_add_cid(struct hci_dev =
*hdev, u16 cid)
 	tfm_aes =3D crypto_alloc_blkcipher("ecb(aes)", 0, 0);
 	if (IS_ERR(tfm_aes)) {
 		BT_ERR("Unable to create crypto context");
-		return ERR_PTR(PTR_ERR(tfm_aes));
+		return ERR_CAST(tfm_aes);
 	}
=20
 create_chan:
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--lEGEL1/lMxI0MVQ2
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUkHbtAAoJEJctW/TcYTgGQowQAJeNoPJyffhmAYZKXkmd4TMw
RaNYCFmvayd4CA05NZR/Dp2DOEf/G4JpDiZtADGDVGdaUpxOdvfNxDnZx7b/5W9Z
SnRnN4qLb07cSfRXvBxF33IwVs5qaoM3GClP9IYqdhj/spgo00ROpeXd5/V7Tby8
t+tUgFoNTdchOgwkgDAmvYkJAYCZwennq8SAQbNii+nNfzPEsOyyr+6bTz1XC8WX
clGV1k76XMiiyiTCSs79O5/EhvePhbRDmlJw3ZPYRgZGtoxz2gmqjxGIGwd+PW1w
LzeTQCN9b5rjC0NufELTMWQf7lQTcGV78SZAhSgM4YXAQ8XfTuIoIFayhHf7M4ka
i/wy1nWp2t3lnzCGkUh4Hmjw8z8yWy5QSH2yyh8bf3wM3ukoq+NTYa2GaoJkiADO
3cbUFAyyWrorE/q2TOsHgR+x7BSqzwHuShx/9ojKVOkziflDpiWOfQJ6NArHu5o9
SP2rtmcjpEBlqpLwy3XtUu56DAiLonTACq7GaF34kJTliLN7Haw9ML88UE/4lKjJ
mqXo+OL1hzzV1JJUW6NOkXou/x+JKea/u/q1w0Hi3VLBqNgiNLoRLIILoU5Q3jqY
U9ev2dqH5DKWC2hwk12J27d0NXkSQpxMBL+e+SWCFqy/n/GuLwn6jzMtazKUuwTT
DzjDzytZlzaeowquO3ZG
=P+JG
-----END PGP SIGNATURE-----

--lEGEL1/lMxI0MVQ2--
