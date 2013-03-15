From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless 2013-03-15
Date: Fri, 15 Mar 2013 11:16:49 -0400
Message-ID: <20130315151649.GA25956@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="7JfCtLOvnd9MIVvH"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--7JfCtLOvnd9MIVvH
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Dave,

Please pull these fixes for the 3.9 stream.

On the NFC bits, Samuel says:

"With this one we have:

- A fix for properly decreasing socket ack log.
- A timer and works cleanup upon NFC device removal.
- A monitoroing socket cleanup round from llcp_socket_release.
- A proper error report to pending sockets upon NFC device removal."

Regarding the Bluetooth bits, Gustavo says:

"I have these two patches for 3.9, these add support for two more devices to
the bluetooth drivers."

Along with those, we have a few wireless driver fixes...

Bing Zhao provides an mwifiex to prevent an out-of-bounds memory
access.

John Crispin offers a Kconfig fix to enable some otherwise dead code
in rt2x00.  The correct symbols were added in -rc1 through a different
tree, but the symbols for enabling the wireless driver didn't match.

Larry Finger brings an rtlwifi fix for a scheduling while atomic bug,
and another fix for a reassociation problem caused by failing to
clear the BSSID after a disconnect.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit aaa0c23cb90141309f5076ba5e3bfbd39544b985:

  Fix dst_neigh_lookup/dst_neigh_lookup_skb return value handling bug (2013=
-03-15 09:06:58 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git for-d=
avem

for you to fetch changes up to f3a3440063d6b01470507ecde9cf8ed0b033362a:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/li=
nville/wireless into for-davem (2013-03-15 10:44:36 -0400)

----------------------------------------------------------------

Bing Zhao (1):
      mwifiex: fix potential out-of-boundary access to ibss rate table

John Crispin (1):
      rt2x00: fix rt2x00 to work with the new ralink SoC config symbols

John W. Linville (3):
      Merge tag 'nfc-fixes-3.9-1' of git://git.kernel.org/.../sameo/nfc-fix=
es
      Merge branch 'for-upstream' of git://git.kernel.org/.../bluetooth/blu=
etooth
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless i=
nto for-davem

Josh Boyer (1):
      Bluetooth: Add support for atheros 04ca:3004 device to ath3k

Larry Finger (2):
      rtlwifi: rtl8192cu: Fix schedule while atomic bug splat
      rtlwifi: rtl8192cu: Fix problem that prevents reassociation

Samuel Ortiz (4):
      NFC: llcp: Decrease socket ack log when accepting a connection
      NFC: llcp: Clean local timers and works when removing a device
      NFC: llcp: Clean raw sockets from nfc_llcp_socket_release
      NFC: llcp: Report error to pending sockets when a device is removed

Sunguk Lee (1):
      Bluetooth: Device 0cf3:3008 should map AR 3012

 drivers/bluetooth/ath3k.c                   |  4 ++
 drivers/bluetooth/btusb.c                   |  2 +
 drivers/net/wireless/mwifiex/join.c         |  7 +--
 drivers/net/wireless/rt2x00/Kconfig         |  4 +-
 drivers/net/wireless/rt2x00/rt2800pci.c     | 14 ++---
 drivers/net/wireless/rtlwifi/rtl8192cu/hw.c | 89 ++++++++++++-------------=
----
 net/nfc/llcp/llcp.c                         | 62 +++++++++++++++++---
 net/nfc/llcp/sock.c                         |  2 +
 8 files changed, 108 insertions(+), 76 deletions(-)

diff --git a/drivers/bluetooth/ath3k.c b/drivers/bluetooth/ath3k.c
index a8a41e07..b282af1 100644
--- a/drivers/bluetooth/ath3k.c
+++ b/drivers/bluetooth/ath3k.c
@@ -74,8 +74,10 @@ static struct usb_device_id ath3k_table[] =3D {
=20
 	/* Atheros AR3012 with sflash firmware*/
 	{ USB_DEVICE(0x0CF3, 0x3004) },
+	{ USB_DEVICE(0x0CF3, 0x3008) },
 	{ USB_DEVICE(0x0CF3, 0x311D) },
 	{ USB_DEVICE(0x13d3, 0x3375) },
+	{ USB_DEVICE(0x04CA, 0x3004) },
 	{ USB_DEVICE(0x04CA, 0x3005) },
 	{ USB_DEVICE(0x04CA, 0x3006) },
 	{ USB_DEVICE(0x04CA, 0x3008) },
@@ -106,8 +108,10 @@ static struct usb_device_id ath3k_blist_tbl[] =3D {
=20
 	/* Atheros AR3012 with sflash firmware*/
 	{ USB_DEVICE(0x0cf3, 0x3004), .driver_info =3D BTUSB_ATH3012 },
+	{ USB_DEVICE(0x0cf3, 0x3008), .driver_info =3D BTUSB_ATH3012 },
 	{ USB_DEVICE(0x0cf3, 0x311D), .driver_info =3D BTUSB_ATH3012 },
 	{ USB_DEVICE(0x13d3, 0x3375), .driver_info =3D BTUSB_ATH3012 },
+	{ USB_DEVICE(0x04ca, 0x3004), .driver_info =3D BTUSB_ATH3012 },
 	{ USB_DEVICE(0x04ca, 0x3005), .driver_info =3D BTUSB_ATH3012 },
 	{ USB_DEVICE(0x04ca, 0x3006), .driver_info =3D BTUSB_ATH3012 },
 	{ USB_DEVICE(0x04ca, 0x3008), .driver_info =3D BTUSB_ATH3012 },
diff --git a/drivers/bluetooth/btusb.c b/drivers/bluetooth/btusb.c
index 7e351e3..e547851 100644
--- a/drivers/bluetooth/btusb.c
+++ b/drivers/bluetooth/btusb.c
@@ -132,8 +132,10 @@ static struct usb_device_id blacklist_table[] =3D {
=20
 	/* Atheros 3012 with sflash firmware */
 	{ USB_DEVICE(0x0cf3, 0x3004), .driver_info =3D BTUSB_ATH3012 },
+	{ USB_DEVICE(0x0cf3, 0x3008), .driver_info =3D BTUSB_ATH3012 },
 	{ USB_DEVICE(0x0cf3, 0x311d), .driver_info =3D BTUSB_ATH3012 },
 	{ USB_DEVICE(0x13d3, 0x3375), .driver_info =3D BTUSB_ATH3012 },
+	{ USB_DEVICE(0x04ca, 0x3004), .driver_info =3D BTUSB_ATH3012 },
 	{ USB_DEVICE(0x04ca, 0x3005), .driver_info =3D BTUSB_ATH3012 },
 	{ USB_DEVICE(0x04ca, 0x3006), .driver_info =3D BTUSB_ATH3012 },
 	{ USB_DEVICE(0x04ca, 0x3008), .driver_info =3D BTUSB_ATH3012 },
diff --git a/drivers/net/wireless/mwifiex/join.c b/drivers/net/wireless/mwi=
fiex/join.c
index 246aa62..2fe0ceb 100644
--- a/drivers/net/wireless/mwifiex/join.c
+++ b/drivers/net/wireless/mwifiex/join.c
@@ -1117,10 +1117,9 @@ mwifiex_cmd_802_11_ad_hoc_join(struct mwifiex_privat=
e *priv,
 		adhoc_join->bss_descriptor.bssid,
 		adhoc_join->bss_descriptor.ssid);
=20
-	for (i =3D 0; bss_desc->supported_rates[i] &&
-			i < MWIFIEX_SUPPORTED_RATES;
-			i++)
-			;
+	for (i =3D 0; i < MWIFIEX_SUPPORTED_RATES &&
+		    bss_desc->supported_rates[i]; i++)
+		;
 	rates_size =3D i;
=20
 	/* Copy Data Rates from the Rates recorded in scan response */
diff --git a/drivers/net/wireless/rt2x00/Kconfig b/drivers/net/wireless/rt2=
x00/Kconfig
index 44d6ead..2bf4efa 100644
--- a/drivers/net/wireless/rt2x00/Kconfig
+++ b/drivers/net/wireless/rt2x00/Kconfig
@@ -55,10 +55,10 @@ config RT61PCI
=20
 config RT2800PCI
 	tristate "Ralink rt27xx/rt28xx/rt30xx (PCI/PCIe/PCMCIA) support"
-	depends on PCI || RALINK_RT288X || RALINK_RT305X
+	depends on PCI || SOC_RT288X || SOC_RT305X
 	select RT2800_LIB
 	select RT2X00_LIB_PCI if PCI
-	select RT2X00_LIB_SOC if RALINK_RT288X || RALINK_RT305X
+	select RT2X00_LIB_SOC if SOC_RT288X || SOC_RT305X
 	select RT2X00_LIB_FIRMWARE
 	select RT2X00_LIB_CRYPTO
 	select CRC_CCITT
diff --git a/drivers/net/wireless/rt2x00/rt2800pci.c b/drivers/net/wireless=
/rt2x00/rt2800pci.c
index 48a01aa..ded73da 100644
--- a/drivers/net/wireless/rt2x00/rt2800pci.c
+++ b/drivers/net/wireless/rt2x00/rt2800pci.c
@@ -89,7 +89,7 @@ static void rt2800pci_mcu_status(struct rt2x00_dev *rt2x0=
0dev, const u8 token)
 	rt2x00pci_register_write(rt2x00dev, H2M_MAILBOX_CID, ~0);
 }
=20
-#if defined(CONFIG_RALINK_RT288X) || defined(CONFIG_RALINK_RT305X)
+#if defined(CONFIG_SOC_RT288X) || defined(CONFIG_SOC_RT305X)
 static int rt2800pci_read_eeprom_soc(struct rt2x00_dev *rt2x00dev)
 {
 	void __iomem *base_addr =3D ioremap(0x1F040000, EEPROM_SIZE);
@@ -107,7 +107,7 @@ static inline int rt2800pci_read_eeprom_soc(struct rt2x=
00_dev *rt2x00dev)
 {
 	return -ENOMEM;
 }
-#endif /* CONFIG_RALINK_RT288X || CONFIG_RALINK_RT305X */
+#endif /* CONFIG_SOC_RT288X || CONFIG_SOC_RT305X */
=20
 #ifdef CONFIG_PCI
 static void rt2800pci_eepromregister_read(struct eeprom_93cx6 *eeprom)
@@ -1177,7 +1177,7 @@ MODULE_DEVICE_TABLE(pci, rt2800pci_device_table);
 #endif /* CONFIG_PCI */
 MODULE_LICENSE("GPL");
=20
-#if defined(CONFIG_RALINK_RT288X) || defined(CONFIG_RALINK_RT305X)
+#if defined(CONFIG_SOC_RT288X) || defined(CONFIG_SOC_RT305X)
 static int rt2800soc_probe(struct platform_device *pdev)
 {
 	return rt2x00soc_probe(pdev, &rt2800pci_ops);
@@ -1194,7 +1194,7 @@ static struct platform_driver rt2800soc_driver =3D {
 	.suspend	=3D rt2x00soc_suspend,
 	.resume		=3D rt2x00soc_resume,
 };
-#endif /* CONFIG_RALINK_RT288X || CONFIG_RALINK_RT305X */
+#endif /* CONFIG_SOC_RT288X || CONFIG_SOC_RT305X */
=20
 #ifdef CONFIG_PCI
 static int rt2800pci_probe(struct pci_dev *pci_dev,
@@ -1217,7 +1217,7 @@ static int __init rt2800pci_init(void)
 {
 	int ret =3D 0;
=20
-#if defined(CONFIG_RALINK_RT288X) || defined(CONFIG_RALINK_RT305X)
+#if defined(CONFIG_SOC_RT288X) || defined(CONFIG_SOC_RT305X)
 	ret =3D platform_driver_register(&rt2800soc_driver);
 	if (ret)
 		return ret;
@@ -1225,7 +1225,7 @@ static int __init rt2800pci_init(void)
 #ifdef CONFIG_PCI
 	ret =3D pci_register_driver(&rt2800pci_driver);
 	if (ret) {
-#if defined(CONFIG_RALINK_RT288X) || defined(CONFIG_RALINK_RT305X)
+#if defined(CONFIG_SOC_RT288X) || defined(CONFIG_SOC_RT305X)
 		platform_driver_unregister(&rt2800soc_driver);
 #endif
 		return ret;
@@ -1240,7 +1240,7 @@ static void __exit rt2800pci_exit(void)
 #ifdef CONFIG_PCI
 	pci_unregister_driver(&rt2800pci_driver);
 #endif
-#if defined(CONFIG_RALINK_RT288X) || defined(CONFIG_RALINK_RT305X)
+#if defined(CONFIG_SOC_RT288X) || defined(CONFIG_SOC_RT305X)
 	platform_driver_unregister(&rt2800soc_driver);
 #endif
 }
diff --git a/drivers/net/wireless/rtlwifi/rtl8192cu/hw.c b/drivers/net/wire=
less/rtlwifi/rtl8192cu/hw.c
index b1ccff4..c08d0f4 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192cu/hw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192cu/hw.c
@@ -1377,74 +1377,57 @@ void rtl92cu_card_disable(struct ieee80211_hw *hw)
=20
 void rtl92cu_set_check_bssid(struct ieee80211_hw *hw, bool check_bssid)
 {
-	/* dummy routine needed for callback from rtl_op_configure_filter() */
-}
-
-/*=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
 */
-
-static void _rtl92cu_set_check_bssid(struct ieee80211_hw *hw,
-			      enum nl80211_iftype type)
-{
 	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
-	u32 reg_rcr =3D rtl_read_dword(rtlpriv, REG_RCR);
 	struct rtl_hal *rtlhal =3D rtl_hal(rtlpriv);
-	struct rtl_phy *rtlphy =3D &(rtlpriv->phy);
-	u8 filterout_non_associated_bssid =3D false;
+	u32 reg_rcr =3D rtl_read_dword(rtlpriv, REG_RCR);
=20
-	switch (type) {
-	case NL80211_IFTYPE_ADHOC:
-	case NL80211_IFTYPE_STATION:
-		filterout_non_associated_bssid =3D true;
-		break;
-	case NL80211_IFTYPE_UNSPECIFIED:
-	case NL80211_IFTYPE_AP:
-	default:
-		break;
-	}
-	if (filterout_non_associated_bssid) {
+	if (rtlpriv->psc.rfpwr_state !=3D ERFON)
+		return;
+
+	if (check_bssid) {
+		u8 tmp;
 		if (IS_NORMAL_CHIP(rtlhal->version)) {
-			switch (rtlphy->current_io_type) {
-			case IO_CMD_RESUME_DM_BY_SCAN:
-				reg_rcr |=3D (RCR_CBSSID_DATA | RCR_CBSSID_BCN);
-				rtlpriv->cfg->ops->set_hw_reg(hw,
-						 HW_VAR_RCR, (u8 *)(&reg_rcr));
-				/* enable update TSF */
-				_rtl92cu_set_bcn_ctrl_reg(hw, 0, BIT(4));
-				break;
-			case IO_CMD_PAUSE_DM_BY_SCAN:
-				reg_rcr &=3D ~(RCR_CBSSID_DATA | RCR_CBSSID_BCN);
-				rtlpriv->cfg->ops->set_hw_reg(hw,
-						 HW_VAR_RCR, (u8 *)(&reg_rcr));
-				/* disable update TSF */
-				_rtl92cu_set_bcn_ctrl_reg(hw, BIT(4), 0);
-				break;
-			}
+			reg_rcr |=3D (RCR_CBSSID_DATA | RCR_CBSSID_BCN);
+			tmp =3D BIT(4);
 		} else {
-			reg_rcr |=3D (RCR_CBSSID);
-			rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_RCR,
-						      (u8 *)(&reg_rcr));
-			_rtl92cu_set_bcn_ctrl_reg(hw, 0, (BIT(4)|BIT(5)));
+			reg_rcr |=3D RCR_CBSSID;
+			tmp =3D BIT(4) | BIT(5);
 		}
-	} else if (filterout_non_associated_bssid =3D=3D false) {
+		rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_RCR,
+					      (u8 *) (&reg_rcr));
+		_rtl92cu_set_bcn_ctrl_reg(hw, 0, tmp);
+	} else {
+		u8 tmp;
 		if (IS_NORMAL_CHIP(rtlhal->version)) {
-			reg_rcr &=3D (~(RCR_CBSSID_DATA | RCR_CBSSID_BCN));
-			rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_RCR,
-						      (u8 *)(&reg_rcr));
-			_rtl92cu_set_bcn_ctrl_reg(hw, BIT(4), 0);
+			reg_rcr &=3D ~(RCR_CBSSID_DATA | RCR_CBSSID_BCN);
+			tmp =3D BIT(4);
 		} else {
-			reg_rcr &=3D (~RCR_CBSSID);
-			rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_RCR,
-						      (u8 *)(&reg_rcr));
-			_rtl92cu_set_bcn_ctrl_reg(hw, (BIT(4)|BIT(5)), 0);
+			reg_rcr &=3D ~RCR_CBSSID;
+			tmp =3D BIT(4) | BIT(5);
 		}
+		reg_rcr &=3D (~(RCR_CBSSID_DATA | RCR_CBSSID_BCN));
+		rtlpriv->cfg->ops->set_hw_reg(hw,
+					      HW_VAR_RCR, (u8 *) (&reg_rcr));
+		_rtl92cu_set_bcn_ctrl_reg(hw, tmp, 0);
 	}
 }
=20
+/*=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
 */
+
 int rtl92cu_set_network_type(struct ieee80211_hw *hw, enum nl80211_iftype =
type)
 {
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+
 	if (_rtl92cu_set_media_status(hw, type))
 		return -EOPNOTSUPP;
-	_rtl92cu_set_check_bssid(hw, type);
+
+	if (rtlpriv->mac80211.link_state =3D=3D MAC80211_LINKED) {
+		if (type !=3D NL80211_IFTYPE_AP)
+			rtl92cu_set_check_bssid(hw, true);
+	} else {
+		rtl92cu_set_check_bssid(hw, false);
+	}
+
 	return 0;
 }
=20
@@ -2058,8 +2041,6 @@ void rtl92cu_update_hal_rate_table(struct ieee80211_h=
w *hw,
 			       (shortgi_rate << 4) | (shortgi_rate);
 	}
 	rtl_write_dword(rtlpriv, REG_ARFR0 + ratr_index * 4, ratr_value);
-	RT_TRACE(rtlpriv, COMP_RATR, DBG_DMESG, "%x\n",
-		 rtl_read_dword(rtlpriv, REG_ARFR0));
 }
=20
 void rtl92cu_update_hal_rate_mask(struct ieee80211_hw *hw, u8 rssi_level)
diff --git a/net/nfc/llcp/llcp.c b/net/nfc/llcp/llcp.c
index 7f8266d..b530afa 100644
--- a/net/nfc/llcp/llcp.c
+++ b/net/nfc/llcp/llcp.c
@@ -68,7 +68,8 @@ static void nfc_llcp_socket_purge(struct nfc_llcp_sock *s=
ock)
 	}
 }
=20
-static void nfc_llcp_socket_release(struct nfc_llcp_local *local, bool lis=
ten)
+static void nfc_llcp_socket_release(struct nfc_llcp_local *local, bool lis=
ten,
+				    int err)
 {
 	struct sock *sk;
 	struct hlist_node *tmp;
@@ -100,7 +101,10 @@ static void nfc_llcp_socket_release(struct nfc_llcp_lo=
cal *local, bool listen)
=20
 				nfc_llcp_accept_unlink(accept_sk);
=20
+				if (err)
+					accept_sk->sk_err =3D err;
 				accept_sk->sk_state =3D LLCP_CLOSED;
+				accept_sk->sk_state_change(sk);
=20
 				bh_unlock_sock(accept_sk);
=20
@@ -123,7 +127,10 @@ static void nfc_llcp_socket_release(struct nfc_llcp_lo=
cal *local, bool listen)
 			continue;
 		}
=20
+		if (err)
+			sk->sk_err =3D err;
 		sk->sk_state =3D LLCP_CLOSED;
+		sk->sk_state_change(sk);
=20
 		bh_unlock_sock(sk);
=20
@@ -133,6 +140,36 @@ static void nfc_llcp_socket_release(struct nfc_llcp_lo=
cal *local, bool listen)
 	}
=20
 	write_unlock(&local->sockets.lock);
+
+	/*
+	 * If we want to keep the listening sockets alive,
+	 * we don't touch the RAW ones.
+	 */
+	if (listen =3D=3D true)
+		return;
+
+	write_lock(&local->raw_sockets.lock);
+
+	sk_for_each_safe(sk, tmp, &local->raw_sockets.head) {
+		llcp_sock =3D nfc_llcp_sock(sk);
+
+		bh_lock_sock(sk);
+
+		nfc_llcp_socket_purge(llcp_sock);
+
+		if (err)
+			sk->sk_err =3D err;
+		sk->sk_state =3D LLCP_CLOSED;
+		sk->sk_state_change(sk);
+
+		bh_unlock_sock(sk);
+
+		sock_orphan(sk);
+
+		sk_del_node_init(sk);
+	}
+
+	write_unlock(&local->raw_sockets.lock);
 }
=20
 struct nfc_llcp_local *nfc_llcp_local_get(struct nfc_llcp_local *local)
@@ -142,20 +179,25 @@ struct nfc_llcp_local *nfc_llcp_local_get(struct nfc_=
llcp_local *local)
 	return local;
 }
=20
-static void local_release(struct kref *ref)
+static void local_cleanup(struct nfc_llcp_local *local, bool listen)
 {
-	struct nfc_llcp_local *local;
-
-	local =3D container_of(ref, struct nfc_llcp_local, ref);
-
-	list_del(&local->list);
-	nfc_llcp_socket_release(local, false);
+	nfc_llcp_socket_release(local, listen, ENXIO);
 	del_timer_sync(&local->link_timer);
 	skb_queue_purge(&local->tx_queue);
 	cancel_work_sync(&local->tx_work);
 	cancel_work_sync(&local->rx_work);
 	cancel_work_sync(&local->timeout_work);
 	kfree_skb(local->rx_pending);
+}
+
+static void local_release(struct kref *ref)
+{
+	struct nfc_llcp_local *local;
+
+	local =3D container_of(ref, struct nfc_llcp_local, ref);
+
+	list_del(&local->list);
+	local_cleanup(local, false);
 	kfree(local);
 }
=20
@@ -1348,7 +1390,7 @@ void nfc_llcp_mac_is_down(struct nfc_dev *dev)
 		return;
=20
 	/* Close and purge all existing sockets */
-	nfc_llcp_socket_release(local, true);
+	nfc_llcp_socket_release(local, true, 0);
 }
=20
 void nfc_llcp_mac_is_up(struct nfc_dev *dev, u32 target_idx,
@@ -1427,6 +1469,8 @@ void nfc_llcp_unregister_device(struct nfc_dev *dev)
 		return;
 	}
=20
+	local_cleanup(local, false);
+
 	nfc_llcp_local_put(local);
 }
=20
diff --git a/net/nfc/llcp/sock.c b/net/nfc/llcp/sock.c
index 5332751..5c7cdf3 100644
--- a/net/nfc/llcp/sock.c
+++ b/net/nfc/llcp/sock.c
@@ -278,6 +278,8 @@ struct sock *nfc_llcp_accept_dequeue(struct sock *paren=
t,
=20
 			pr_debug("Returning sk state %d\n", sk->sk_state);
=20
+			sk_acceptq_removed(parent);
+
 			return sk;
 		}
=20
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--7JfCtLOvnd9MIVvH
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)

iQIcBAEBAgAGBQJRQzthAAoJEJctW/TcYTgGRu8P/AmPKay1aNp1989QrAzBOfNl
EVu5htMnFa1lXmr7k5Op/jMWRNIcLCk/dfJbexM56vgkxsHcdBAmYm38R51S7Lbf
hbS9NHSt29Xd1Jy82Lrmq1P5mUe+x7s7o1KMkuvr6kO57kOkdkvjqci4U7j3QMCj
WPNg2OnP3wEBFbfZ4XzUuzrRhcETP8e48bomqluZT+L9EECJWrbBiRybRMtshMx/
tzqhXy92ttrZjfq5drO3+BEGiFfmJJslUnn77twI+lo9CwqKCR+ariI28C/Z8D4b
eoFN3dAtObw8PV2msHswBNRNMJuTG3wHGmpMsU0mv1b5zA4A0IJMDEzm0BaWYYfk
1hIGN678Xcb5VDwGX0WBuUmBsJRTIDg/EqXaV2uTqwCEMAudXn4RDQpG1rIroTLA
UjZsCOtQo9yQxhJfcjCezNGkGZ8BI2323dRTnpNyoqKQuFs5Z4C2QP1oWt2RdMn7
kWL3fGZdgNfjIgwBZAeAns0w1rrsNeR5Wy5jPi276BN0dqKRH8nJnr9xOL3NMl+3
HWKuz7EfsZnsSxE7xyGvHcfle0jydBw9XNzaG04PnraR1hUJUg5Ty0eDFZjGShZ3
pfDJurJojFMzM+JiRKrPy/xqtjDDx+Ej9iufmF+jwHtEHyIYQTmfamHwk+vL1S7F
4U7125y31J03fct+7ALg
=WVIs
-----END PGP SIGNATURE-----

--7JfCtLOvnd9MIVvH--
