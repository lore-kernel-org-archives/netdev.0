From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless 2014-06-18
Date: Wed, 18 Jun 2014 14:54:14 -0400
Message-ID: <20140618185414.GA14033@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="6TrnltStXW4iwmi0"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--6TrnltStXW4iwmi0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Dave,

Please pull this batch of fixes intended for the 3.16 stream!

For the Bluetooth bits, Gustavo says:

"This is our first batch of fixes for 3.16. Be aware that two patches here
are not exactly bugfixes:

* 71f28af57066 Bluetooth: Add clarifying comment for conn->auth_type
This commit just add some important security comments to the code, we found
it important enough to include it here for 3.16 since it is security relate=
d.

* 9f7ec8871132 Bluetooth: Refactor discovery stopping into its own function
This commit is just a refactor in a preparation for a fix in the next
commit (f8680f128b).

All the other patches are fixes for deadlocks and for the Bluetooth protoco=
ls,
most of them related to authentication and encryption."

On top of that...

Chin-Ran Lo fixes a problems with overlapping DMA areas in mwifiex.

Michael Braun corrects a couple of issues in order to enable a new
device in rt2800usb.

Rafa=C5=82 Mi=C5=82ecki reverts a b43 patch that caused a regression, fixes=
 a
Kconfig typo, and corrects a frequency reporting error with the G-PHY.

Stanislaw Grsuzka fixes an rfkill regression for rt2500pci, and avoids
a rt2x00 scheduling while atomic BUG.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 62a02c98ce03bb214009509a4802b7b63f59621c:

  net: fec: Don't clear IPV6 header checksum field when IP accelerator enab=
le (2014-06-17 21:58:35 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git for-d=
avem

for you to fetch changes up to 2ee3f63d39dbebd94b4a77df04455617ce12156b:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/li=
nville/wireless into for-davem (2014-06-18 14:39:25 -0400)

----------------------------------------------------------------

Chin-Ran Lo (1):
      mwifiex: fix tx_info/rx_info overlap with PCIe dma_mapping

Johan Hedberg (9):
      Bluetooth: Fix incorrectly overriding conn->src_type
      Bluetooth: Fix check for connection encryption
      Bluetooth: Fix SSP acceptor just-works confirmation without MITM
      Bluetooth: Add clarifying comment for conn->auth_type
      Bluetooth: Fix setting correct authentication information for SMP STK
      Bluetooth: Fix indicating discovery state when canceling inquiry
      Bluetooth: Refactor discovery stopping into its own function
      Bluetooth: Reuse hci_stop_discovery function when cleaning up HCI sta=
te
      Bluetooth: Fix locking of hdev when calling into SMP code

John W. Linville (2):
      Merge branch 'for-upstream' of git://git.kernel.org/.../bluetooth/blu=
etooth
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless i=
nto for-davem

Jukka Taimisto (1):
      Bluetooth: Fix deadlock in l2cap_conn_del()

Marcin Kraglak (1):
      Bluetooth: Allow change security level on ATT_CID in slave role

Michael Braun (2):
      rt2800usb:fix efuse detection
      rt2800usb:fix hang during firmware load

Rafa=C5=82 Mi=C5=82ecki (3):
      b43: disable 5 GHz on G-PHY
      b43: fix typo in Kconfig (make B43_BUSES_BCMA_AND_SSB the default for=
 real)
      b43: fix frequency reported on G-PHY with /new/ firmware

Stanislaw Gruszka (2):
      rt2x00: disable TKIP on USB
      rt2x00: fix rfkill regression on rt2500pci

 drivers/net/wireless/b43/Kconfig        |   2 +-
 drivers/net/wireless/b43/main.c         |   1 +
 drivers/net/wireless/b43/xmit.c         |  10 ++-
 drivers/net/wireless/mwifiex/pcie.c     |   4 +-
 drivers/net/wireless/mwifiex/util.h     |  43 ++++++++++---
 drivers/net/wireless/rt2x00/rt2500pci.c |   7 ++-
 drivers/net/wireless/rt2x00/rt2800usb.c |  39 +++++++++++-
 drivers/net/wireless/rt2x00/rt2x00.h    |   1 +
 drivers/net/wireless/rt2x00/rt2x00dev.c |  24 +++++++-
 drivers/net/wireless/rt2x00/rt2x00mac.c |   2 +
 drivers/net/wireless/rt2x00/rt2x00usb.h |   1 +
 net/bluetooth/hci_conn.c                |   7 +--
 net/bluetooth/hci_event.c               |  17 +++++-
 net/bluetooth/l2cap_core.c              |   8 ++-
 net/bluetooth/l2cap_sock.c              |   5 --
 net/bluetooth/mgmt.c                    | 104 +++++++++++++++++-----------=
----
 net/bluetooth/smp.c                     |   9 ++-
 17 files changed, 196 insertions(+), 88 deletions(-)

diff --git a/drivers/net/wireless/b43/Kconfig b/drivers/net/wireless/b43/Kc=
onfig
index e3f67b8d3f80..40fd9b7b1426 100644
--- a/drivers/net/wireless/b43/Kconfig
+++ b/drivers/net/wireless/b43/Kconfig
@@ -36,7 +36,7 @@ config B43_SSB
 choice
 	prompt "Supported bus types"
 	depends on B43
-	default B43_BCMA_AND_SSB
+	default B43_BUSES_BCMA_AND_SSB
=20
 config B43_BUSES_BCMA_AND_SSB
 	bool "BCMA and SSB"
diff --git a/drivers/net/wireless/b43/main.c b/drivers/net/wireless/b43/mai=
n.c
index 32538ac5f7e4..0d6a0bb1f876 100644
--- a/drivers/net/wireless/b43/main.c
+++ b/drivers/net/wireless/b43/main.c
@@ -5221,6 +5221,7 @@ static int b43_wireless_core_attach(struct b43_wldev =
*dev)
 	/* We don't support 5 GHz on some PHYs yet */
 	switch (dev->phy.type) {
 	case B43_PHYTYPE_A:
+	case B43_PHYTYPE_G:
 	case B43_PHYTYPE_N:
 	case B43_PHYTYPE_LP:
 	case B43_PHYTYPE_HT:
diff --git a/drivers/net/wireless/b43/xmit.c b/drivers/net/wireless/b43/xmi=
t.c
index 4f38f19b8e3d..6e6ef3fc2247 100644
--- a/drivers/net/wireless/b43/xmit.c
+++ b/drivers/net/wireless/b43/xmit.c
@@ -811,9 +811,13 @@ void b43_rx(struct b43_wldev *dev, struct sk_buff *skb=
, const void *_rxhdr)
 		break;
 	case B43_PHYTYPE_G:
 		status.band =3D IEEE80211_BAND_2GHZ;
-		/* chanid is the radio channel cookie value as used
-		 * to tune the radio. */
-		status.freq =3D chanid + 2400;
+		/* Somewhere between 478.104 and 508.1084 firmware for G-PHY
+		 * has been modified to be compatible with N-PHY and others.
+		 */
+		if (dev->fw.rev >=3D 508)
+			status.freq =3D ieee80211_channel_to_frequency(chanid, status.band);
+		else
+			status.freq =3D chanid + 2400;
 		break;
 	case B43_PHYTYPE_N:
 	case B43_PHYTYPE_LP:
diff --git a/drivers/net/wireless/mwifiex/pcie.c b/drivers/net/wireless/mwi=
fiex/pcie.c
index 574d4b597468..2cc9b6fca490 100644
--- a/drivers/net/wireless/mwifiex/pcie.c
+++ b/drivers/net/wireless/mwifiex/pcie.c
@@ -50,7 +50,7 @@ mwifiex_map_pci_memory(struct mwifiex_adapter *adapter, s=
truct sk_buff *skb,
 		return -1;
 	}
 	mapping.len =3D size;
-	memcpy(skb->cb, &mapping, sizeof(mapping));
+	mwifiex_store_mapping(skb, &mapping);
 	return 0;
 }
=20
@@ -60,7 +60,7 @@ static void mwifiex_unmap_pci_memory(struct mwifiex_adapt=
er *adapter,
 	struct pcie_service_card *card =3D adapter->card;
 	struct mwifiex_dma_mapping mapping;
=20
-	MWIFIEX_SKB_PACB(skb, &mapping);
+	mwifiex_get_mapping(skb, &mapping);
 	pci_unmap_single(card->dev, mapping.addr, mapping.len, flags);
 }
=20
diff --git a/drivers/net/wireless/mwifiex/util.h b/drivers/net/wireless/mwi=
fiex/util.h
index ddae57021397..caadb3737b9e 100644
--- a/drivers/net/wireless/mwifiex/util.h
+++ b/drivers/net/wireless/mwifiex/util.h
@@ -20,32 +20,55 @@
 #ifndef _MWIFIEX_UTIL_H_
 #define _MWIFIEX_UTIL_H_
=20
+struct mwifiex_dma_mapping {
+	dma_addr_t addr;
+	size_t len;
+};
+
+struct mwifiex_cb {
+	struct mwifiex_dma_mapping dma_mapping;
+	union {
+		struct mwifiex_rxinfo rx_info;
+		struct mwifiex_txinfo tx_info;
+	};
+};
+
 static inline struct mwifiex_rxinfo *MWIFIEX_SKB_RXCB(struct sk_buff *skb)
 {
-	return (struct mwifiex_rxinfo *)(skb->cb + sizeof(dma_addr_t));
+	struct mwifiex_cb *cb =3D (struct mwifiex_cb *)skb->cb;
+
+	BUILD_BUG_ON(sizeof(struct mwifiex_cb) > sizeof(skb->cb));
+	return &cb->rx_info;
 }
=20
 static inline struct mwifiex_txinfo *MWIFIEX_SKB_TXCB(struct sk_buff *skb)
 {
-	return (struct mwifiex_txinfo *)(skb->cb + sizeof(dma_addr_t));
+	struct mwifiex_cb *cb =3D (struct mwifiex_cb *)skb->cb;
+
+	return &cb->tx_info;
 }
=20
-struct mwifiex_dma_mapping {
-	dma_addr_t addr;
-	size_t len;
-};
+static inline void mwifiex_store_mapping(struct sk_buff *skb,
+					 struct mwifiex_dma_mapping *mapping)
+{
+	struct mwifiex_cb *cb =3D (struct mwifiex_cb *)skb->cb;
+
+	memcpy(&cb->dma_mapping, mapping, sizeof(*mapping));
+}
=20
-static inline void MWIFIEX_SKB_PACB(struct sk_buff *skb,
-					struct mwifiex_dma_mapping *mapping)
+static inline void mwifiex_get_mapping(struct sk_buff *skb,
+				       struct mwifiex_dma_mapping *mapping)
 {
-	memcpy(mapping, skb->cb, sizeof(*mapping));
+	struct mwifiex_cb *cb =3D (struct mwifiex_cb *)skb->cb;
+
+	memcpy(mapping, &cb->dma_mapping, sizeof(*mapping));
 }
=20
 static inline dma_addr_t MWIFIEX_SKB_DMA_ADDR(struct sk_buff *skb)
 {
 	struct mwifiex_dma_mapping mapping;
=20
-	MWIFIEX_SKB_PACB(skb, &mapping);
+	mwifiex_get_mapping(skb, &mapping);
=20
 	return mapping.addr;
 }
diff --git a/drivers/net/wireless/rt2x00/rt2500pci.c b/drivers/net/wireless=
/rt2x00/rt2500pci.c
index 2f1cd929c6f6..a511cccc9f01 100644
--- a/drivers/net/wireless/rt2x00/rt2500pci.c
+++ b/drivers/net/wireless/rt2x00/rt2500pci.c
@@ -1681,8 +1681,13 @@ static int rt2500pci_init_eeprom(struct rt2x00_dev *=
rt2x00dev)
 	/*
 	 * Detect if this device has an hardware controlled radio.
 	 */
-	if (rt2x00_get_field16(eeprom, EEPROM_ANTENNA_HARDWARE_RADIO))
+	if (rt2x00_get_field16(eeprom, EEPROM_ANTENNA_HARDWARE_RADIO)) {
 		__set_bit(CAPABILITY_HW_BUTTON, &rt2x00dev->cap_flags);
+		/*
+		 * On this device RFKILL initialized during probe does not work.
+		 */
+		__set_bit(REQUIRE_DELAYED_RFKILL, &rt2x00dev->cap_flags);
+	}
=20
 	/*
 	 * Check if the BBP tuning should be enabled.
diff --git a/drivers/net/wireless/rt2x00/rt2800usb.c b/drivers/net/wireless=
/rt2x00/rt2800usb.c
index a49c3d73ea2c..e11dab2216c6 100644
--- a/drivers/net/wireless/rt2x00/rt2800usb.c
+++ b/drivers/net/wireless/rt2x00/rt2800usb.c
@@ -229,6 +229,27 @@ static enum hrtimer_restart rt2800usb_tx_sta_fifo_time=
out(struct hrtimer *timer)
 /*
  * Firmware functions
  */
+static int rt2800usb_autorun_detect(struct rt2x00_dev *rt2x00dev)
+{
+	__le32 reg;
+	u32 fw_mode;
+
+	/* cannot use rt2x00usb_register_read here as it uses different
+	 * mode (MULTI_READ vs. DEVICE_MODE) and does not pass the
+	 * magic value USB_MODE_AUTORUN (0x11) to the device, thus the
+	 * returned value would be invalid.
+	 */
+	rt2x00usb_vendor_request(rt2x00dev, USB_DEVICE_MODE,
+				 USB_VENDOR_REQUEST_IN, 0, USB_MODE_AUTORUN,
+				 &reg, sizeof(reg), REGISTER_TIMEOUT_FIRMWARE);
+	fw_mode =3D le32_to_cpu(reg);
+
+	if ((fw_mode & 0x00000003) =3D=3D 2)
+		return 1;
+
+	return 0;
+}
+
 static char *rt2800usb_get_firmware_name(struct rt2x00_dev *rt2x00dev)
 {
 	return FIRMWARE_RT2870;
@@ -257,8 +278,13 @@ static int rt2800usb_write_firmware(struct rt2x00_dev =
*rt2x00dev,
 	/*
 	 * Write firmware to device.
 	 */
-	rt2x00usb_register_multiwrite(rt2x00dev, FIRMWARE_IMAGE_BASE,
-				      data + offset, length);
+	if (rt2800usb_autorun_detect(rt2x00dev)) {
+		rt2x00_info(rt2x00dev,
+			    "Firmware loading not required - NIC in AutoRun mode\n");
+	} else {
+		rt2x00usb_register_multiwrite(rt2x00dev, FIRMWARE_IMAGE_BASE,
+					      data + offset, length);
+	}
=20
 	rt2x00usb_register_write(rt2x00dev, H2M_MAILBOX_CID, ~0);
 	rt2x00usb_register_write(rt2x00dev, H2M_MAILBOX_STATUS, ~0);
@@ -735,11 +761,18 @@ static void rt2800usb_fill_rxdone(struct queue_entry =
*entry,
 /*
  * Device probe functions.
  */
+static int rt2800usb_efuse_detect(struct rt2x00_dev *rt2x00dev)
+{
+	if (rt2800usb_autorun_detect(rt2x00dev))
+		return 1;
+	return rt2800_efuse_detect(rt2x00dev);
+}
+
 static int rt2800usb_read_eeprom(struct rt2x00_dev *rt2x00dev)
 {
 	int retval;
=20
-	if (rt2800_efuse_detect(rt2x00dev))
+	if (rt2800usb_efuse_detect(rt2x00dev))
 		retval =3D rt2800_read_eeprom_efuse(rt2x00dev);
 	else
 		retval =3D rt2x00usb_eeprom_read(rt2x00dev, rt2x00dev->eeprom,
diff --git a/drivers/net/wireless/rt2x00/rt2x00.h b/drivers/net/wireless/rt=
2x00/rt2x00.h
index 010b76505243..d13f25cd70d5 100644
--- a/drivers/net/wireless/rt2x00/rt2x00.h
+++ b/drivers/net/wireless/rt2x00/rt2x00.h
@@ -693,6 +693,7 @@ enum rt2x00_capability_flags {
 	REQUIRE_SW_SEQNO,
 	REQUIRE_HT_TX_DESC,
 	REQUIRE_PS_AUTOWAKE,
+	REQUIRE_DELAYED_RFKILL,
=20
 	/*
 	 * Capabilities
diff --git a/drivers/net/wireless/rt2x00/rt2x00dev.c b/drivers/net/wireless=
/rt2x00/rt2x00dev.c
index 2bde6729f5e6..4fa43a2eeb73 100644
--- a/drivers/net/wireless/rt2x00/rt2x00dev.c
+++ b/drivers/net/wireless/rt2x00/rt2x00dev.c
@@ -1126,9 +1126,10 @@ static void rt2x00lib_uninitialize(struct rt2x00_dev=
 *rt2x00dev)
 		return;
=20
 	/*
-	 * Unregister extra components.
+	 * Stop rfkill polling.
 	 */
-	rt2x00rfkill_unregister(rt2x00dev);
+	if (test_bit(REQUIRE_DELAYED_RFKILL, &rt2x00dev->cap_flags))
+		rt2x00rfkill_unregister(rt2x00dev);
=20
 	/*
 	 * Allow the HW to uninitialize.
@@ -1166,6 +1167,12 @@ static int rt2x00lib_initialize(struct rt2x00_dev *r=
t2x00dev)
=20
 	set_bit(DEVICE_STATE_INITIALIZED, &rt2x00dev->flags);
=20
+	/*
+	 * Start rfkill polling.
+	 */
+	if (test_bit(REQUIRE_DELAYED_RFKILL, &rt2x00dev->cap_flags))
+		rt2x00rfkill_register(rt2x00dev);
+
 	return 0;
 }
=20
@@ -1375,7 +1382,12 @@ int rt2x00lib_probe_dev(struct rt2x00_dev *rt2x00dev)
 	rt2x00link_register(rt2x00dev);
 	rt2x00leds_register(rt2x00dev);
 	rt2x00debug_register(rt2x00dev);
-	rt2x00rfkill_register(rt2x00dev);
+
+	/*
+	 * Start rfkill polling.
+	 */
+	if (!test_bit(REQUIRE_DELAYED_RFKILL, &rt2x00dev->cap_flags))
+		rt2x00rfkill_register(rt2x00dev);
=20
 	return 0;
=20
@@ -1391,6 +1403,12 @@ void rt2x00lib_remove_dev(struct rt2x00_dev *rt2x00d=
ev)
 	clear_bit(DEVICE_STATE_PRESENT, &rt2x00dev->flags);
=20
 	/*
+	 * Stop rfkill polling.
+	 */
+	if (!test_bit(REQUIRE_DELAYED_RFKILL, &rt2x00dev->cap_flags))
+		rt2x00rfkill_unregister(rt2x00dev);
+
+	/*
 	 * Disable radio.
 	 */
 	rt2x00lib_disable_radio(rt2x00dev);
diff --git a/drivers/net/wireless/rt2x00/rt2x00mac.c b/drivers/net/wireless=
/rt2x00/rt2x00mac.c
index 212ac4842c16..004dff9b962d 100644
--- a/drivers/net/wireless/rt2x00/rt2x00mac.c
+++ b/drivers/net/wireless/rt2x00/rt2x00mac.c
@@ -487,6 +487,8 @@ int rt2x00mac_set_key(struct ieee80211_hw *hw, enum set=
_key_cmd cmd,
 	crypto.cipher =3D rt2x00crypto_key_to_cipher(key);
 	if (crypto.cipher =3D=3D CIPHER_NONE)
 		return -EOPNOTSUPP;
+	if (crypto.cipher =3D=3D CIPHER_TKIP && rt2x00_is_usb(rt2x00dev))
+		return -EOPNOTSUPP;
=20
 	crypto.cmd =3D cmd;
=20
diff --git a/drivers/net/wireless/rt2x00/rt2x00usb.h b/drivers/net/wireless=
/rt2x00/rt2x00usb.h
index e7bcf62347d5..831b65f93feb 100644
--- a/drivers/net/wireless/rt2x00/rt2x00usb.h
+++ b/drivers/net/wireless/rt2x00/rt2x00usb.h
@@ -93,6 +93,7 @@ enum rt2x00usb_mode_offset {
 	USB_MODE_SLEEP =3D 7,	/* RT73USB */
 	USB_MODE_FIRMWARE =3D 8,	/* RT73USB */
 	USB_MODE_WAKEUP =3D 9,	/* RT73USB */
+	USB_MODE_AUTORUN =3D 17, /* RT2800USB */
 };
=20
 /**
diff --git a/net/bluetooth/hci_conn.c b/net/bluetooth/hci_conn.c
index 8671bc79a35b..ca01d1861854 100644
--- a/net/bluetooth/hci_conn.c
+++ b/net/bluetooth/hci_conn.c
@@ -610,11 +610,6 @@ static void hci_req_add_le_create_conn(struct hci_requ=
est *req,
 	if (hci_update_random_address(req, false, &own_addr_type))
 		return;
=20
-	/* Save the address type used for this connnection attempt so we able
-	 * to retrieve this information if we need it.
-	 */
-	conn->src_type =3D own_addr_type;
-
 	cp.scan_interval =3D cpu_to_le16(hdev->le_scan_interval);
 	cp.scan_window =3D cpu_to_le16(hdev->le_scan_window);
 	bacpy(&cp.peer_addr, &conn->dst);
@@ -894,7 +889,7 @@ static int hci_conn_auth(struct hci_conn *conn, __u8 se=
c_level, __u8 auth_type)
 		/* If we're already encrypted set the REAUTH_PEND flag,
 		 * otherwise set the ENCRYPT_PEND.
 		 */
-		if (conn->key_type !=3D 0xff)
+		if (conn->link_mode & HCI_LM_ENCRYPT)
 			set_bit(HCI_CONN_REAUTH_PEND, &conn->flags);
 		else
 			set_bit(HCI_CONN_ENCRYPT_PEND, &conn->flags);
diff --git a/net/bluetooth/hci_event.c b/net/bluetooth/hci_event.c
index 21e5913d12e0..640c54ec1bd2 100644
--- a/net/bluetooth/hci_event.c
+++ b/net/bluetooth/hci_event.c
@@ -48,6 +48,10 @@ static void hci_cc_inquiry_cancel(struct hci_dev *hdev, =
struct sk_buff *skb)
 	smp_mb__after_atomic(); /* wake_up_bit advises about this barrier */
 	wake_up_bit(&hdev->flags, HCI_INQUIRY);
=20
+	hci_dev_lock(hdev);
+	hci_discovery_set_state(hdev, DISCOVERY_STOPPED);
+	hci_dev_unlock(hdev);
+
 	hci_conn_check_pending(hdev);
 }
=20
@@ -3537,7 +3541,11 @@ static void hci_io_capa_request_evt(struct hci_dev *=
hdev, struct sk_buff *skb)
 			cp.authentication =3D conn->auth_type;
=20
 			/* Request MITM protection if our IO caps allow it
-			 * except for the no-bonding case
+			 * except for the no-bonding case.
+			 * conn->auth_type is not updated here since
+			 * that might cause the user confirmation to be
+			 * rejected in case the remote doesn't have the
+			 * IO capabilities for MITM.
 			 */
 			if (conn->io_capability !=3D HCI_IO_NO_INPUT_OUTPUT &&
 			    cp.authentication !=3D HCI_AT_NO_BONDING)
@@ -3628,8 +3636,11 @@ static void hci_user_confirm_request_evt(struct hci_=
dev *hdev,
=20
 		/* If we're not the initiators request authorization to
 		 * proceed from user space (mgmt_user_confirm with
-		 * confirm_hint set to 1). */
-		if (!test_bit(HCI_CONN_AUTH_PEND, &conn->flags)) {
+		 * confirm_hint set to 1). The exception is if neither
+		 * side had MITM in which case we do auto-accept.
+		 */
+		if (!test_bit(HCI_CONN_AUTH_PEND, &conn->flags) &&
+		    (loc_mitm || rem_mitm)) {
 			BT_DBG("Confirming auto-accept as acceptor");
 			confirm_hint =3D 1;
 			goto confirm;
diff --git a/net/bluetooth/l2cap_core.c b/net/bluetooth/l2cap_core.c
index 6eabbe05fe54..323f23cd2c37 100644
--- a/net/bluetooth/l2cap_core.c
+++ b/net/bluetooth/l2cap_core.c
@@ -1663,7 +1663,13 @@ static void l2cap_conn_del(struct hci_conn *hcon, in=
t err)
 	kfree_skb(conn->rx_skb);
=20
 	skb_queue_purge(&conn->pending_rx);
-	flush_work(&conn->pending_rx_work);
+
+	/* We can not call flush_work(&conn->pending_rx_work) here since we
+	 * might block if we are running on a worker from the same workqueue
+	 * pending_rx_work is waiting on.
+	 */
+	if (work_pending(&conn->pending_rx_work))
+		cancel_work_sync(&conn->pending_rx_work);
=20
 	l2cap_unregister_all_users(conn);
=20
diff --git a/net/bluetooth/l2cap_sock.c b/net/bluetooth/l2cap_sock.c
index ade3fb4c23bc..e1378693cc90 100644
--- a/net/bluetooth/l2cap_sock.c
+++ b/net/bluetooth/l2cap_sock.c
@@ -787,11 +787,6 @@ static int l2cap_sock_setsockopt(struct socket *sock, =
int level, int optname,
=20
 		/*change security for LE channels */
 		if (chan->scid =3D=3D L2CAP_CID_ATT) {
-			if (!conn->hcon->out) {
-				err =3D -EINVAL;
-				break;
-			}
-
 			if (smp_conn_security(conn->hcon, sec.level))
 				break;
 			sk->sk_state =3D BT_CONFIG;
diff --git a/net/bluetooth/mgmt.c b/net/bluetooth/mgmt.c
index 0fce54412ffd..af8e0a6243b7 100644
--- a/net/bluetooth/mgmt.c
+++ b/net/bluetooth/mgmt.c
@@ -1047,6 +1047,43 @@ static void clean_up_hci_complete(struct hci_dev *hd=
ev, u8 status)
 	}
 }
=20
+static void hci_stop_discovery(struct hci_request *req)
+{
+	struct hci_dev *hdev =3D req->hdev;
+	struct hci_cp_remote_name_req_cancel cp;
+	struct inquiry_entry *e;
+
+	switch (hdev->discovery.state) {
+	case DISCOVERY_FINDING:
+		if (test_bit(HCI_INQUIRY, &hdev->flags)) {
+			hci_req_add(req, HCI_OP_INQUIRY_CANCEL, 0, NULL);
+		} else {
+			cancel_delayed_work(&hdev->le_scan_disable);
+			hci_req_add_le_scan_disable(req);
+		}
+
+		break;
+
+	case DISCOVERY_RESOLVING:
+		e =3D hci_inquiry_cache_lookup_resolve(hdev, BDADDR_ANY,
+						     NAME_PENDING);
+		if (!e)
+			return;
+
+		bacpy(&cp.bdaddr, &e->data.bdaddr);
+		hci_req_add(req, HCI_OP_REMOTE_NAME_REQ_CANCEL, sizeof(cp),
+			    &cp);
+
+		break;
+
+	default:
+		/* Passive scanning */
+		if (test_bit(HCI_LE_SCAN, &hdev->dev_flags))
+			hci_req_add_le_scan_disable(req);
+		break;
+	}
+}
+
 static int clean_up_hci_state(struct hci_dev *hdev)
 {
 	struct hci_request req;
@@ -1063,9 +1100,7 @@ static int clean_up_hci_state(struct hci_dev *hdev)
 	if (test_bit(HCI_ADVERTISING, &hdev->dev_flags))
 		disable_advertising(&req);
=20
-	if (test_bit(HCI_LE_SCAN, &hdev->dev_flags)) {
-		hci_req_add_le_scan_disable(&req);
-	}
+	hci_stop_discovery(&req);
=20
 	list_for_each_entry(conn, &hdev->conn_hash.list, list) {
 		struct hci_cp_disconnect dc;
@@ -2996,8 +3031,13 @@ static int user_pairing_resp(struct sock *sk, struct=
 hci_dev *hdev,
 	}
=20
 	if (addr->type =3D=3D BDADDR_LE_PUBLIC || addr->type =3D=3D BDADDR_LE_RAN=
DOM) {
-		/* Continue with pairing via SMP */
+		/* Continue with pairing via SMP. The hdev lock must be
+		 * released as SMP may try to recquire it for crypto
+		 * purposes.
+		 */
+		hci_dev_unlock(hdev);
 		err =3D smp_user_confirm_reply(conn, mgmt_op, passkey);
+		hci_dev_lock(hdev);
=20
 		if (!err)
 			err =3D cmd_complete(sk, hdev->id, mgmt_op,
@@ -3574,8 +3614,6 @@ static int stop_discovery(struct sock *sk, struct hci=
_dev *hdev, void *data,
 {
 	struct mgmt_cp_stop_discovery *mgmt_cp =3D data;
 	struct pending_cmd *cmd;
-	struct hci_cp_remote_name_req_cancel cp;
-	struct inquiry_entry *e;
 	struct hci_request req;
 	int err;
=20
@@ -3605,52 +3643,22 @@ static int stop_discovery(struct sock *sk, struct h=
ci_dev *hdev, void *data,
=20
 	hci_req_init(&req, hdev);
=20
-	switch (hdev->discovery.state) {
-	case DISCOVERY_FINDING:
-		if (test_bit(HCI_INQUIRY, &hdev->flags)) {
-			hci_req_add(&req, HCI_OP_INQUIRY_CANCEL, 0, NULL);
-		} else {
-			cancel_delayed_work(&hdev->le_scan_disable);
-
-			hci_req_add_le_scan_disable(&req);
-		}
-
-		break;
+	hci_stop_discovery(&req);
=20
-	case DISCOVERY_RESOLVING:
-		e =3D hci_inquiry_cache_lookup_resolve(hdev, BDADDR_ANY,
-						     NAME_PENDING);
-		if (!e) {
-			mgmt_pending_remove(cmd);
-			err =3D cmd_complete(sk, hdev->id,
-					   MGMT_OP_STOP_DISCOVERY, 0,
-					   &mgmt_cp->type,
-					   sizeof(mgmt_cp->type));
-			hci_discovery_set_state(hdev, DISCOVERY_STOPPED);
-			goto unlock;
-		}
-
-		bacpy(&cp.bdaddr, &e->data.bdaddr);
-		hci_req_add(&req, HCI_OP_REMOTE_NAME_REQ_CANCEL, sizeof(cp),
-			    &cp);
-
-		break;
-
-	default:
-		BT_DBG("unknown discovery state %u", hdev->discovery.state);
-
-		mgmt_pending_remove(cmd);
-		err =3D cmd_complete(sk, hdev->id, MGMT_OP_STOP_DISCOVERY,
-				   MGMT_STATUS_FAILED, &mgmt_cp->type,
-				   sizeof(mgmt_cp->type));
+	err =3D hci_req_run(&req, stop_discovery_complete);
+	if (!err) {
+		hci_discovery_set_state(hdev, DISCOVERY_STOPPING);
 		goto unlock;
 	}
=20
-	err =3D hci_req_run(&req, stop_discovery_complete);
-	if (err < 0)
-		mgmt_pending_remove(cmd);
-	else
-		hci_discovery_set_state(hdev, DISCOVERY_STOPPING);
+	mgmt_pending_remove(cmd);
+
+	/* If no HCI commands were sent we're done */
+	if (err =3D=3D -ENODATA) {
+		err =3D cmd_complete(sk, hdev->id, MGMT_OP_STOP_DISCOVERY, 0,
+				   &mgmt_cp->type, sizeof(mgmt_cp->type));
+		hci_discovery_set_state(hdev, DISCOVERY_STOPPED);
+	}
=20
 unlock:
 	hci_dev_unlock(hdev);
diff --git a/net/bluetooth/smp.c b/net/bluetooth/smp.c
index 3d1cc164557d..f2829a7932e2 100644
--- a/net/bluetooth/smp.c
+++ b/net/bluetooth/smp.c
@@ -544,7 +544,7 @@ static u8 smp_random(struct smp_chan *smp)
 		hci_le_start_enc(hcon, ediv, rand, stk);
 		hcon->enc_key_size =3D smp->enc_key_size;
 	} else {
-		u8 stk[16];
+		u8 stk[16], auth;
 		__le64 rand =3D 0;
 		__le16 ediv =3D 0;
=20
@@ -556,8 +556,13 @@ static u8 smp_random(struct smp_chan *smp)
 		memset(stk + smp->enc_key_size, 0,
 		       SMP_MAX_ENC_KEY_SIZE - smp->enc_key_size);
=20
+		if (hcon->pending_sec_level =3D=3D BT_SECURITY_HIGH)
+			auth =3D 1;
+		else
+			auth =3D 0;
+
 		hci_add_ltk(hcon->hdev, &hcon->dst, hcon->dst_type,
-			    HCI_SMP_STK_SLAVE, 0, stk, smp->enc_key_size,
+			    HCI_SMP_STK_SLAVE, auth, stk, smp->enc_key_size,
 			    ediv, rand);
 	}
=20
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--6TrnltStXW4iwmi0
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJToeBWAAoJEJctW/TcYTgG2hAP/3pyR4prv3sBkT0f9yJ0g4CG
xq99FpXTQaPg+DcmAw9YuAT9qBImpPrUuCp5L3oW3qWcuX+xy84UgPCWP+3AXobo
iAadJ+W8WuesJP1VakQKwelqUOVoRYCSb0R6WllKpY5GO7P5Y09AS39/TqCFj6WD
BGRK6G4rZ+CcI4hawYGKgtC74kRGid2ulEbXQuFPQhePI+vgHBMgVMtXX+q7Jf8o
xjVhroKoR/fSX0k5CENoeLk+8yE0A/KS7cVKnAY8x2aZyoESW6f7jZf9KHPzLIVK
bNeBRlOnwhSDA4VPlv7e09rerzbzGkhKRAnLPFNQTDR9w0/9ajEeCkvIAvy22Hsk
HihPGRgwnL4ciVJQGgoLbLwtYUR/BmvsmKY4/t2JnaqxMuL/fuZhYWSFf1KLi4YT
bnJ1oo4gxlF6iHr/5cW9YpL9RBJl9W2rVw3p8G/QFZDmjmfXpV+2gDY/X7yGTo4M
DJiz+fA619snvLWPXDvYF+biLKr6zHsNfSwczJV23cCcud1B5T1BacQOYUVfalsj
sYvjX4frpll44SHG/aSsC1WOFU3xGqKcvPvUpzUPBS7XOG+YBMkcTJCwqE6ofDTv
gbua1rEjiJjNTjUHbvHOk+S1cloE49vHh2IxXNdLRzNyr8NaHMSFc1pTOS8hGD72
xlFJTBY1BTrYNUiqHPGY
=IuuW
-----END PGP SIGNATURE-----

--6TrnltStXW4iwmi0--
