From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless 2014-08-28
Date: Thu, 28 Aug 2014 14:17:14 -0400
Message-ID: <20140828181713.GL13758@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="UugvWAfsgieZRqgk"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--UugvWAfsgieZRqgk
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Dave,

Please pull this batch of fixes intended for the 3.17 stream.

For the Bluetooth/6LowPAN/802.15.4 bits, Johan says:

'It contains a connection reference counting fix for LE where a
connection might stay up even though it should get disconnected.

The other 802.15.4 6LoWPAN related patches were sent to the bluetooth
tree by Alexander Aring and described as follows by him:

"
these patches contains patches for the bluetooth branch.

This series includes memory leak fixes and an errno value fix.
Also there are two patches for sending and receiving 1280 6LoWPAN
packets, which makes the IEEE 802.15.4 6LoWPAN stack more RFC
compliant.
"'

Along with that...

Alexey Khoroshilov fixes a use-after-free bug on at76c50x-usb.

Hauke Mehrtens adds a PCI ID to bcma.

Himangi Saraogi fixes a silly "A || A" test in rtlwifi.

Larry Finger adds a device ID to rtl8192cu.

Maks Naumov fixes a strncmp argument in ath9k.

=C1lvaro Fern=E1ndez Rojas adds a PCI ID to ssb.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 47e4df94d129cbca84de252ff63c4ded08a513e7:

  mac80211: fix channel switch for chanctx-based drivers (2014-08-22 14:45:=
49 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git tags/=
master-2014-08-25

for you to fetch changes up to c66517165610b911e4c6d268f28d8c640832dbd1:

  rtlwifi: rtl8192cu: Add new ID (2014-08-25 15:39:23 -0400)

----------------------------------------------------------------
Alexander Aring (2):
      ieee802154: 6lowpan_rtnl: fix correct errno value
      ieee802154: 6lowpan: ensure of sending 1280 packets

Alexey Khoroshilov (1):
      at76c50x-usb: fix use after free on failure path in at76_probe()

Hauke Mehrtens (1):
      bcma: add PCI ID for spromless BCM43217

Himangi Saraogi (1):
      rtlwifi: btcoexist: adjust double test

Johan Hedberg (1):
      Bluetooth: Fix hci_conn reference counting for auto-connections

John W. Linville (1):
      Merge branch 'for-upstream' of git://git.kernel.org/.../bluetooth/blu=
etooth

Larry Finger (1):
      rtlwifi: rtl8192cu: Add new ID

Maks Naumov (1):
      ath9k: fix wrong string size for strncmp in write_file_spec_scan_ctl()

Martin Townsend (3):
      mac802154: fixed potential skb leak with mac802154_parse_frame_start
      ieee802154: mac802154: handle the reserved dest mode by dropping the =
packet
      ieee802154: 6lowpan: ensure MTU of 1280 for 6lowpan

Mika Westerberg (1):
      net: rfkill: gpio: Add more Broadcom bluetooth ACPI IDs

=C1lvaro Fern=E1ndez Rojas (1):
      ssb: add PCI ID 0x4351

 drivers/bcma/host_pci.c                               |  1 +
 drivers/net/wireless/at76c50x-usb.c                   |  3 +--
 drivers/net/wireless/ath/ath9k/spectral.c             |  2 +-
 drivers/net/wireless/rtlwifi/btcoexist/halbtcoutsrc.c |  2 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/sw.c           |  1 +
 drivers/ssb/b43_pci_bridge.c                          |  1 +
 include/net/bluetooth/hci_core.h                      |  2 ++
 include/net/netns/ieee802154_6lowpan.h                |  1 -
 net/bluetooth/hci_conn.c                              |  8 ++++++++
 net/bluetooth/hci_core.c                              | 14 ++++++++++++--
 net/bluetooth/hci_event.c                             | 17 +++++++++++++++=
--
 net/ieee802154/6lowpan_rtnl.c                         |  4 ++--
 net/ieee802154/reassembly.c                           | 15 +++------------
 net/mac802154/wpan.c                                  |  6 +++++-
 net/rfkill/rfkill-gpio.c                              |  1 +
 15 files changed, 54 insertions(+), 24 deletions(-)

diff --git a/drivers/bcma/host_pci.c b/drivers/bcma/host_pci.c
index 294a7dd25190..f032ed6dd459 100644
--- a/drivers/bcma/host_pci.c
+++ b/drivers/bcma/host_pci.c
@@ -282,6 +282,7 @@ static const struct pci_device_id bcma_pci_bridge_tbl[]=
 =3D {
 	{ PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, 0x43a9) },
 	{ PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, 0x43aa) },
 	{ PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, 0x4727) },
+	{ PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, 43227) },	/* 0xA8DB */
 	{ 0, },
 };
 MODULE_DEVICE_TABLE(pci, bcma_pci_bridge_tbl);
diff --git a/drivers/net/wireless/at76c50x-usb.c b/drivers/net/wireless/at7=
6c50x-usb.c
index 334c2ece855a..da92bfa76b7c 100644
--- a/drivers/net/wireless/at76c50x-usb.c
+++ b/drivers/net/wireless/at76c50x-usb.c
@@ -2423,8 +2423,6 @@ static void at76_delete_device(struct at76_priv *priv)
=20
 	kfree_skb(priv->rx_skb);
=20
-	usb_put_dev(priv->udev);
-
 	at76_dbg(DBG_PROC_ENTRY, "%s: before freeing priv/ieee80211_hw",
 		 __func__);
 	ieee80211_free_hw(priv->hw);
@@ -2558,6 +2556,7 @@ static void at76_disconnect(struct usb_interface *int=
erface)
=20
 	wiphy_info(priv->hw->wiphy, "disconnecting\n");
 	at76_delete_device(priv);
+	usb_put_dev(priv->udev);
 	dev_info(&interface->dev, "disconnected\n");
 }
=20
diff --git a/drivers/net/wireless/ath/ath9k/spectral.c b/drivers/net/wirele=
ss/ath/ath9k/spectral.c
index 5fe29b9f8fa2..8f68426ca653 100644
--- a/drivers/net/wireless/ath/ath9k/spectral.c
+++ b/drivers/net/wireless/ath/ath9k/spectral.c
@@ -253,7 +253,7 @@ static ssize_t write_file_spec_scan_ctl(struct file *fi=
le,
=20
 	if (strncmp("trigger", buf, 7) =3D=3D 0) {
 		ath9k_spectral_scan_trigger(sc->hw);
-	} else if (strncmp("background", buf, 9) =3D=3D 0) {
+	} else if (strncmp("background", buf, 10) =3D=3D 0) {
 		ath9k_spectral_scan_config(sc->hw, SPECTRAL_BACKGROUND);
 		ath_dbg(common, CONFIG, "spectral scan: background mode enabled\n");
 	} else if (strncmp("chanscan", buf, 8) =3D=3D 0) {
diff --git a/drivers/net/wireless/rtlwifi/btcoexist/halbtcoutsrc.c b/driver=
s/net/wireless/rtlwifi/btcoexist/halbtcoutsrc.c
index 33da3dfcfa4f..d4bd550f505c 100644
--- a/drivers/net/wireless/rtlwifi/btcoexist/halbtcoutsrc.c
+++ b/drivers/net/wireless/rtlwifi/btcoexist/halbtcoutsrc.c
@@ -101,7 +101,7 @@ static bool halbtc_legacy(struct rtl_priv *adapter)
=20
 	bool is_legacy =3D false;
=20
-	if ((mac->mode =3D=3D WIRELESS_MODE_B) || (mac->mode =3D=3D WIRELESS_MODE=
_B))
+	if ((mac->mode =3D=3D WIRELESS_MODE_B) || (mac->mode =3D=3D WIRELESS_MODE=
_G))
 		is_legacy =3D true;
=20
 	return is_legacy;
diff --git a/drivers/net/wireless/rtlwifi/rtl8192cu/sw.c b/drivers/net/wire=
less/rtlwifi/rtl8192cu/sw.c
index 361435f8608a..1ac6383e7947 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192cu/sw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192cu/sw.c
@@ -317,6 +317,7 @@ static struct usb_device_id rtl8192c_usb_ids[] =3D {
 	{RTL_USB_DEVICE(0x0bda, 0x5088, rtl92cu_hal_cfg)}, /*Thinkware-CC&C*/
 	{RTL_USB_DEVICE(0x0df6, 0x0052, rtl92cu_hal_cfg)}, /*Sitecom - Edimax*/
 	{RTL_USB_DEVICE(0x0df6, 0x005c, rtl92cu_hal_cfg)}, /*Sitecom - Edimax*/
+	{RTL_USB_DEVICE(0x0df6, 0x0070, rtl92cu_hal_cfg)}, /*Sitecom - 150N */
 	{RTL_USB_DEVICE(0x0df6, 0x0077, rtl92cu_hal_cfg)}, /*Sitecom-WLA2100V2*/
 	{RTL_USB_DEVICE(0x0eb0, 0x9071, rtl92cu_hal_cfg)}, /*NO Brand - Etop*/
 	{RTL_USB_DEVICE(0x4856, 0x0091, rtl92cu_hal_cfg)}, /*NetweeN - Feixun*/
diff --git a/drivers/ssb/b43_pci_bridge.c b/drivers/ssb/b43_pci_bridge.c
index 19396dc4ee47..bed2fedeb057 100644
--- a/drivers/ssb/b43_pci_bridge.c
+++ b/drivers/ssb/b43_pci_bridge.c
@@ -38,6 +38,7 @@ static const struct pci_device_id b43_pci_bridge_tbl[] =
=3D {
 	{ PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, 0x432b) },
 	{ PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, 0x432c) },
 	{ PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, 0x4350) },
+	{ PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, 0x4351) },
 	{ 0, },
 };
 MODULE_DEVICE_TABLE(pci, b43_pci_bridge_tbl);
diff --git a/include/net/bluetooth/hci_core.h b/include/net/bluetooth/hci_c=
ore.h
index b5d5af3aa469..6f884e6c731e 100644
--- a/include/net/bluetooth/hci_core.h
+++ b/include/net/bluetooth/hci_core.h
@@ -464,6 +464,8 @@ struct hci_conn_params {
 		HCI_AUTO_CONN_ALWAYS,
 		HCI_AUTO_CONN_LINK_LOSS,
 	} auto_connect;
+
+	struct hci_conn *conn;
 };
=20
 extern struct list_head hci_dev_list;
diff --git a/include/net/netns/ieee802154_6lowpan.h b/include/net/netns/iee=
e802154_6lowpan.h
index e2070960bac0..8170f8d7052b 100644
--- a/include/net/netns/ieee802154_6lowpan.h
+++ b/include/net/netns/ieee802154_6lowpan.h
@@ -16,7 +16,6 @@ struct netns_sysctl_lowpan {
 struct netns_ieee802154_lowpan {
 	struct netns_sysctl_lowpan sysctl;
 	struct netns_frags	frags;
-	int			max_dsize;
 };
=20
 #endif
diff --git a/net/bluetooth/hci_conn.c b/net/bluetooth/hci_conn.c
index b50dabb3f86a..faff6247ac8f 100644
--- a/net/bluetooth/hci_conn.c
+++ b/net/bluetooth/hci_conn.c
@@ -589,6 +589,14 @@ EXPORT_SYMBOL(hci_get_route);
 void hci_le_conn_failed(struct hci_conn *conn, u8 status)
 {
 	struct hci_dev *hdev =3D conn->hdev;
+	struct hci_conn_params *params;
+
+	params =3D hci_pend_le_action_lookup(&hdev->pend_le_conns, &conn->dst,
+					   conn->dst_type);
+	if (params && params->conn) {
+		hci_conn_drop(params->conn);
+		params->conn =3D NULL;
+	}
=20
 	conn->state =3D BT_CLOSED;
=20
diff --git a/net/bluetooth/hci_core.c b/net/bluetooth/hci_core.c
index c32d361c0cf7..1d9c29a00568 100644
--- a/net/bluetooth/hci_core.c
+++ b/net/bluetooth/hci_core.c
@@ -2536,8 +2536,13 @@ static void hci_pend_le_actions_clear(struct hci_dev=
 *hdev)
 {
 	struct hci_conn_params *p;
=20
-	list_for_each_entry(p, &hdev->le_conn_params, list)
+	list_for_each_entry(p, &hdev->le_conn_params, list) {
+		if (p->conn) {
+			hci_conn_drop(p->conn);
+			p->conn =3D NULL;
+		}
 		list_del_init(&p->action);
+	}
=20
 	BT_DBG("All LE pending actions cleared");
 }
@@ -2578,8 +2583,8 @@ static int hci_dev_do_close(struct hci_dev *hdev)
=20
 	hci_dev_lock(hdev);
 	hci_inquiry_cache_flush(hdev);
-	hci_conn_hash_flush(hdev);
 	hci_pend_le_actions_clear(hdev);
+	hci_conn_hash_flush(hdev);
 	hci_dev_unlock(hdev);
=20
 	hci_notify(hdev, HCI_DEV_DOWN);
@@ -3727,6 +3732,9 @@ void hci_conn_params_del(struct hci_dev *hdev, bdaddr=
_t *addr, u8 addr_type)
 	if (!params)
 		return;
=20
+	if (params->conn)
+		hci_conn_drop(params->conn);
+
 	list_del(&params->action);
 	list_del(&params->list);
 	kfree(params);
@@ -3757,6 +3765,8 @@ void hci_conn_params_clear_all(struct hci_dev *hdev)
 	struct hci_conn_params *params, *tmp;
=20
 	list_for_each_entry_safe(params, tmp, &hdev->le_conn_params, list) {
+		if (params->conn)
+			hci_conn_drop(params->conn);
 		list_del(&params->action);
 		list_del(&params->list);
 		kfree(params);
diff --git a/net/bluetooth/hci_event.c b/net/bluetooth/hci_event.c
index be35598984d9..a6000823f0ff 100644
--- a/net/bluetooth/hci_event.c
+++ b/net/bluetooth/hci_event.c
@@ -4221,8 +4221,13 @@ static void hci_le_conn_complete_evt(struct hci_dev =
*hdev, struct sk_buff *skb)
 	hci_proto_connect_cfm(conn, ev->status);
=20
 	params =3D hci_conn_params_lookup(hdev, &conn->dst, conn->dst_type);
-	if (params)
+	if (params) {
 		list_del_init(&params->action);
+		if (params->conn) {
+			hci_conn_drop(params->conn);
+			params->conn =3D NULL;
+		}
+	}
=20
 unlock:
 	hci_update_background_scan(hdev);
@@ -4304,8 +4309,16 @@ static void check_pending_le_conn(struct hci_dev *hd=
ev, bdaddr_t *addr,
=20
 	conn =3D hci_connect_le(hdev, addr, addr_type, BT_SECURITY_LOW,
 			      HCI_LE_AUTOCONN_TIMEOUT, HCI_ROLE_MASTER);
-	if (!IS_ERR(conn))
+	if (!IS_ERR(conn)) {
+		/* Store the pointer since we don't really have any
+		 * other owner of the object besides the params that
+		 * triggered it. This way we can abort the connection if
+		 * the parameters get removed and keep the reference
+		 * count consistent once the connection is established.
+		 */
+		params->conn =3D conn;
 		return;
+	}
=20
 	switch (PTR_ERR(conn)) {
 	case -EBUSY:
diff --git a/net/ieee802154/6lowpan_rtnl.c b/net/ieee802154/6lowpan_rtnl.c
index 016b77ee88f0..6591d27e53a4 100644
--- a/net/ieee802154/6lowpan_rtnl.c
+++ b/net/ieee802154/6lowpan_rtnl.c
@@ -246,7 +246,7 @@ lowpan_alloc_frag(struct sk_buff *skb, int size,
 			return ERR_PTR(-rc);
 		}
 	} else {
-		frag =3D ERR_PTR(ENOMEM);
+		frag =3D ERR_PTR(-ENOMEM);
 	}
=20
 	return frag;
@@ -437,7 +437,7 @@ static void lowpan_setup(struct net_device *dev)
 	/* Frame Control + Sequence Number + Address fields + Security Header */
 	dev->hard_header_len	=3D 2 + 1 + 20 + 14;
 	dev->needed_tailroom	=3D 2; /* FCS */
-	dev->mtu		=3D 1281;
+	dev->mtu		=3D IPV6_MIN_MTU;
 	dev->tx_queue_len	=3D 0;
 	dev->flags		=3D IFF_BROADCAST | IFF_MULTICAST;
 	dev->watchdog_timeo	=3D 0;
diff --git a/net/ieee802154/reassembly.c b/net/ieee802154/reassembly.c
index ffec6ce51005..32755cb7e64e 100644
--- a/net/ieee802154/reassembly.c
+++ b/net/ieee802154/reassembly.c
@@ -355,8 +355,6 @@ int lowpan_frag_rcv(struct sk_buff *skb, const u8 frag_=
type)
 	struct net *net =3D dev_net(skb->dev);
 	struct lowpan_frag_info *frag_info =3D lowpan_cb(skb);
 	struct ieee802154_addr source, dest;
-	struct netns_ieee802154_lowpan *ieee802154_lowpan =3D
-		net_ieee802154_lowpan(net);
 	int err;
=20
 	source =3D mac_cb(skb)->source;
@@ -366,8 +364,10 @@ int lowpan_frag_rcv(struct sk_buff *skb, const u8 frag=
_type)
 	if (err < 0)
 		goto err;
=20
-	if (frag_info->d_size > ieee802154_lowpan->max_dsize)
+	if (frag_info->d_size > IPV6_MIN_MTU) {
+		net_warn_ratelimited("lowpan_frag_rcv: datagram size exceeds MTU\n");
 		goto err;
+	}
=20
 	fq =3D fq_find(net, frag_info, &source, &dest);
 	if (fq !=3D NULL) {
@@ -415,13 +415,6 @@ static struct ctl_table lowpan_frags_ns_ctl_table[] =
=3D {
 		.mode		=3D 0644,
 		.proc_handler	=3D proc_dointvec_jiffies,
 	},
-	{
-		.procname	=3D "6lowpanfrag_max_datagram_size",
-		.data		=3D &init_net.ieee802154_lowpan.max_dsize,
-		.maxlen		=3D sizeof(int),
-		.mode		=3D 0644,
-		.proc_handler	=3D proc_dointvec
-	},
 	{ }
 };
=20
@@ -458,7 +451,6 @@ static int __net_init lowpan_frags_ns_sysctl_register(s=
truct net *net)
 		table[1].data =3D &ieee802154_lowpan->frags.low_thresh;
 		table[1].extra2 =3D &ieee802154_lowpan->frags.high_thresh;
 		table[2].data =3D &ieee802154_lowpan->frags.timeout;
-		table[3].data =3D &ieee802154_lowpan->max_dsize;
=20
 		/* Don't export sysctls to unprivileged users */
 		if (net->user_ns !=3D &init_user_ns)
@@ -533,7 +525,6 @@ static int __net_init lowpan_frags_init_net(struct net =
*net)
 	ieee802154_lowpan->frags.high_thresh =3D IPV6_FRAG_HIGH_THRESH;
 	ieee802154_lowpan->frags.low_thresh =3D IPV6_FRAG_LOW_THRESH;
 	ieee802154_lowpan->frags.timeout =3D IPV6_FRAG_TIMEOUT;
-	ieee802154_lowpan->max_dsize =3D 0xFFFF;
=20
 	inet_frags_init_net(&ieee802154_lowpan->frags);
=20
diff --git a/net/mac802154/wpan.c b/net/mac802154/wpan.c
index 3c3069fd6971..547838822d5e 100644
--- a/net/mac802154/wpan.c
+++ b/net/mac802154/wpan.c
@@ -462,7 +462,10 @@ mac802154_subif_frame(struct mac802154_sub_if_data *sd=
ata, struct sk_buff *skb,
 			skb->pkt_type =3D PACKET_OTHERHOST;
 		break;
 	default:
-		break;
+		spin_unlock_bh(&sdata->mib_lock);
+		pr_debug("invalid dest mode\n");
+		kfree_skb(skb);
+		return NET_RX_DROP;
 	}
=20
 	spin_unlock_bh(&sdata->mib_lock);
@@ -573,6 +576,7 @@ void mac802154_wpans_rx(struct mac802154_priv *priv, st=
ruct sk_buff *skb)
 	ret =3D mac802154_parse_frame_start(skb, &hdr);
 	if (ret) {
 		pr_debug("got invalid frame\n");
+		kfree_skb(skb);
 		return;
 	}
=20
diff --git a/net/rfkill/rfkill-gpio.c b/net/rfkill/rfkill-gpio.c
index 14c98e48f261..02a86a27fd84 100644
--- a/net/rfkill/rfkill-gpio.c
+++ b/net/rfkill/rfkill-gpio.c
@@ -158,6 +158,7 @@ static const struct acpi_device_id rfkill_acpi_match[] =
=3D {
 	{ "BCM2E1A", RFKILL_TYPE_BLUETOOTH },
 	{ "BCM2E39", RFKILL_TYPE_BLUETOOTH },
 	{ "BCM2E3D", RFKILL_TYPE_BLUETOOTH },
+	{ "BCM2E64", RFKILL_TYPE_BLUETOOTH },
 	{ "BCM4752", RFKILL_TYPE_GPS },
 	{ "LNV4752", RFKILL_TYPE_GPS },
 	{ },
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--UugvWAfsgieZRqgk
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJT/3IpAAoJEJctW/TcYTgG9eoP/3o3sasvbKnrpo0u8F86deJp
RWeTTzULV5VyELNtp1KPPOqQf+X7TafCgNQVlg5PoLQj7YTIsy1918chomzzJI7N
aKgr1hemNnl2fRJcF6aYA5XqzaDoV6exoHTghHteoPwe3kE4LFco03fl57zZ5sKb
m3JV7zRLWzd7aoYMJLR7H0jtFpKmkqtcxXUU9zqM99MsYnNccam8/XItjK89bQTY
Plztrevw/HE/4VzgAtj1m/80DrOdAWz3JAjOkfCgfPdNEFji0FnAiBc+r5qaxUWa
24/c1XSDghgATtwcXdJBeZkJ7S+V8fN875Ehm2CyzkIvroavoPezueU7HU/PRKyz
VyWo3ncuDL+FwcQC6JR3UAX4iSAvYDsf66Q88nvJ/gBJInNEXIMSrJTgBKFRsRSQ
sPkyMgwx0+XmPlGLihIIDmZQo44mekYckZdgzWh1MIAa5oNCW0raXpR22NJ3jKMb
zlsoIeQgzF3Y2S/lP2AZsnX1T2FJQ1LlbfuGJP/cPZt/cUmqswfCEwf7UdVOPuzG
rnM1TbnHbnw5GCIM302d9Gwu5VEsnnZtx1BAfJ61MRszH22y4YVDb2Q3Uz3JFeP3
IDxSVsdY2y0M522HGVtf9Zv54ZmSH7rO+RsycF/NO1p8kWjoU22FqSVggJO0GyX/
O6EK+rbnvBqz/L+d05r9
=97Sk
-----END PGP SIGNATURE-----

--UugvWAfsgieZRqgk--
