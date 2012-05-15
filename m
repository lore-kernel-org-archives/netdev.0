From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless 2012-05-15
Date: Tue, 15 May 2012 16:51:58 -0400
Message-ID: <20120515205157.GF24572@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="nFreZHaLTZJo0R7j"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--nFreZHaLTZJo0R7j
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

commit 60374631487a6dbf6b888729022f0e8d76eec8fb

Dave,

Here are three more fixes that some of my developers are desperate to
see included in 3.4...

Johan Hedberg went to some length justifyng the inclusion of these two
Bluetooth fixes:

"The device_connected fix should be quite self-explanatory, but it's
actually a wider issue than just for keyboards. All profiles that do
incoming connection authorization (e.g. headsets) will break without it
with specific hardware. The reason it wasn't caught earlier is that it
only occurs with specific Bluetooth adapters.

As for the security level patch, this fixes L2CAP socket based security
level elevation during a connection. The HID profile needs this (for
keyboards) and it is the only way to achieve the security level
elevation when using the management interface to talk to the kernel
(hence the management enabling patch being the one that exposes this"

The rtlwifi fix addresses a regression related to firmware loading,
as described in kernel.org bug 43187.  It basically just moves a hunk
of code to a more appropriate place.

Please let me know if there are problems!  I know you will! :-)

Thanks,

John

---

The following changes since commit 3ab77bf271e6a41512e366dfa5110edb981ed1d3:

  pch_gbe: fix transmit races (2012-05-15 13:41:43 -0400)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git for-d=
avem

Gustavo Padovan (1):
      Bluetooth: notify userspace of security level change

Johan Hedberg (1):
      Bluetooth: mgmt: Fix device_connected sending order

John W. Linville (1):
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless i=
nto for-davem

Larry Finger (1):
      rtlwifi: fix for race condition when firmware is cached

 drivers/net/wireless/rtlwifi/pci.c |   16 ++++++++--------
 drivers/net/wireless/rtlwifi/usb.c |   10 +++++-----
 include/net/bluetooth/bluetooth.h  |    1 +
 net/bluetooth/af_bluetooth.c       |    2 +-
 net/bluetooth/hci_core.c           |    8 ++++++++
 net/bluetooth/hci_event.c          |   11 +++++++++--
 net/bluetooth/l2cap_core.c         |    5 +++++
 net/bluetooth/l2cap_sock.c         |   12 ++++++++----
 8 files changed, 45 insertions(+), 20 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/pci.c b/drivers/net/wireless/rtlw=
ifi/pci.c
index cc15fdb..67f9430 100644
--- a/drivers/net/wireless/rtlwifi/pci.c
+++ b/drivers/net/wireless/rtlwifi/pci.c
@@ -1851,14 +1851,6 @@ int __devinit rtl_pci_probe(struct pci_dev *pdev,
 	/*like read eeprom and so on */
 	rtlpriv->cfg->ops->read_eeprom_info(hw);
=20
-	if (rtlpriv->cfg->ops->init_sw_vars(hw)) {
-		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, "Can't init_sw_vars\n");
-		err =3D -ENODEV;
-		goto fail3;
-	}
-
-	rtlpriv->cfg->ops->init_sw_leds(hw);
-
 	/*aspm */
 	rtl_pci_init_aspm(hw);
=20
@@ -1877,6 +1869,14 @@ int __devinit rtl_pci_probe(struct pci_dev *pdev,
 		goto fail3;
 	}
=20
+	if (rtlpriv->cfg->ops->init_sw_vars(hw)) {
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, "Can't init_sw_vars\n");
+		err =3D -ENODEV;
+		goto fail3;
+	}
+
+	rtlpriv->cfg->ops->init_sw_leds(hw);
+
 	err =3D sysfs_create_group(&pdev->dev.kobj, &rtl_attribute_group);
 	if (err) {
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
diff --git a/drivers/net/wireless/rtlwifi/usb.c b/drivers/net/wireless/rtlw=
ifi/usb.c
index d04dbda..a6049d7 100644
--- a/drivers/net/wireless/rtlwifi/usb.c
+++ b/drivers/net/wireless/rtlwifi/usb.c
@@ -971,11 +971,6 @@ int __devinit rtl_usb_probe(struct usb_interface *intf,
 	rtlpriv->cfg->ops->read_chip_version(hw);
 	/*like read eeprom and so on */
 	rtlpriv->cfg->ops->read_eeprom_info(hw);
-	if (rtlpriv->cfg->ops->init_sw_vars(hw)) {
-		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, "Can't init_sw_vars\n");
-		goto error_out;
-	}
-	rtlpriv->cfg->ops->init_sw_leds(hw);
 	err =3D _rtl_usb_init(hw);
 	if (err)
 		goto error_out;
@@ -987,6 +982,11 @@ int __devinit rtl_usb_probe(struct usb_interface *intf,
 			 "Can't allocate sw for mac80211\n");
 		goto error_out;
 	}
+	if (rtlpriv->cfg->ops->init_sw_vars(hw)) {
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, "Can't init_sw_vars\n");
+		goto error_out;
+	}
+	rtlpriv->cfg->ops->init_sw_leds(hw);
=20
 	return 0;
 error_out:
diff --git a/include/net/bluetooth/bluetooth.h b/include/net/bluetooth/blue=
tooth.h
index 262ebd1..a65910b 100644
--- a/include/net/bluetooth/bluetooth.h
+++ b/include/net/bluetooth/bluetooth.h
@@ -191,6 +191,7 @@ struct bt_sock {
 	struct list_head accept_q;
 	struct sock *parent;
 	u32 defer_setup;
+	bool suspended;
 };
=20
 struct bt_sock_list {
diff --git a/net/bluetooth/af_bluetooth.c b/net/bluetooth/af_bluetooth.c
index 72eb187..6fb68a9 100644
--- a/net/bluetooth/af_bluetooth.c
+++ b/net/bluetooth/af_bluetooth.c
@@ -450,7 +450,7 @@ unsigned int bt_sock_poll(struct file *file, struct soc=
ket *sock, poll_table *wa
 			sk->sk_state =3D=3D BT_CONFIG)
 		return mask;
=20
-	if (sock_writeable(sk))
+	if (!bt_sk(sk)->suspended && sock_writeable(sk))
 		mask |=3D POLLOUT | POLLWRNORM | POLLWRBAND;
 	else
 		set_bit(SOCK_ASYNC_NOSPACE, &sk->sk_socket->flags);
diff --git a/net/bluetooth/hci_core.c b/net/bluetooth/hci_core.c
index edfd61a..d6dc44c 100644
--- a/net/bluetooth/hci_core.c
+++ b/net/bluetooth/hci_core.c
@@ -2784,6 +2784,14 @@ static inline void hci_acldata_packet(struct hci_dev=
 *hdev, struct sk_buff *skb)
 	if (conn) {
 		hci_conn_enter_active_mode(conn, BT_POWER_FORCE_ACTIVE_OFF);
=20
+		hci_dev_lock(hdev);
+		if (test_bit(HCI_MGMT, &hdev->dev_flags) &&
+		    !test_and_set_bit(HCI_CONN_MGMT_CONNECTED, &conn->flags))
+			mgmt_device_connected(hdev, &conn->dst, conn->type,
+					      conn->dst_type, 0, NULL, 0,
+					      conn->dev_class);
+		hci_dev_unlock(hdev);
+
 		/* Send to upper protocol */
 		l2cap_recv_acldata(conn, skb, flags);
 		return;
diff --git a/net/bluetooth/hci_event.c b/net/bluetooth/hci_event.c
index 6c06525..1266f78 100644
--- a/net/bluetooth/hci_event.c
+++ b/net/bluetooth/hci_event.c
@@ -2039,6 +2039,12 @@ static inline void hci_encrypt_change_evt(struct hci=
_dev *hdev, struct sk_buff *
=20
 		clear_bit(HCI_CONN_ENCRYPT_PEND, &conn->flags);
=20
+		if (ev->status && conn->state =3D=3D BT_CONNECTED) {
+			hci_acl_disconn(conn, 0x13);
+			hci_conn_put(conn);
+			goto unlock;
+		}
+
 		if (conn->state =3D=3D BT_CONFIG) {
 			if (!ev->status)
 				conn->state =3D BT_CONNECTED;
@@ -2049,6 +2055,7 @@ static inline void hci_encrypt_change_evt(struct hci_=
dev *hdev, struct sk_buff *
 			hci_encrypt_cfm(conn, ev->status, ev->encrypt);
 	}
=20
+unlock:
 	hci_dev_unlock(hdev);
 }
=20
@@ -2102,7 +2109,7 @@ static inline void hci_remote_features_evt(struct hci=
_dev *hdev, struct sk_buff
 		goto unlock;
 	}
=20
-	if (!ev->status) {
+	if (!ev->status && !test_bit(HCI_CONN_MGMT_CONNECTED, &conn->flags)) {
 		struct hci_cp_remote_name_req cp;
 		memset(&cp, 0, sizeof(cp));
 		bacpy(&cp.bdaddr, &conn->dst);
@@ -2871,7 +2878,7 @@ static inline void hci_remote_ext_features_evt(struct=
 hci_dev *hdev, struct sk_b
 	if (conn->state !=3D BT_CONFIG)
 		goto unlock;
=20
-	if (!ev->status) {
+	if (!ev->status && !test_bit(HCI_CONN_MGMT_CONNECTED, &conn->flags)) {
 		struct hci_cp_remote_name_req cp;
 		memset(&cp, 0, sizeof(cp));
 		bacpy(&cp.bdaddr, &conn->dst);
diff --git a/net/bluetooth/l2cap_core.c b/net/bluetooth/l2cap_core.c
index 94552b3..6f9c25b 100644
--- a/net/bluetooth/l2cap_core.c
+++ b/net/bluetooth/l2cap_core.c
@@ -4589,6 +4589,11 @@ int l2cap_security_cfm(struct hci_conn *hcon, u8 sta=
tus, u8 encrypt)
=20
 		if (!status && (chan->state =3D=3D BT_CONNECTED ||
 						chan->state =3D=3D BT_CONFIG)) {
+			struct sock *sk =3D chan->sk;
+
+			bt_sk(sk)->suspended =3D false;
+			sk->sk_state_change(sk);
+
 			l2cap_check_encryption(chan, encrypt);
 			l2cap_chan_unlock(chan);
 			continue;
diff --git a/net/bluetooth/l2cap_sock.c b/net/bluetooth/l2cap_sock.c
index 29122ed..04e7c17 100644
--- a/net/bluetooth/l2cap_sock.c
+++ b/net/bluetooth/l2cap_sock.c
@@ -592,10 +592,14 @@ static int l2cap_sock_setsockopt(struct socket *sock,=
 int level, int optname, ch
 			sk->sk_state =3D BT_CONFIG;
 			chan->state =3D BT_CONFIG;
=20
-		/* or for ACL link, under defer_setup time */
-		} else if (sk->sk_state =3D=3D BT_CONNECT2 &&
-					bt_sk(sk)->defer_setup) {
-			err =3D l2cap_chan_check_security(chan);
+		/* or for ACL link */
+		} else if ((sk->sk_state =3D=3D BT_CONNECT2 &&
+			   bt_sk(sk)->defer_setup) ||
+			   sk->sk_state =3D=3D BT_CONNECTED) {
+			if (!l2cap_chan_check_security(chan))
+				bt_sk(sk)->suspended =3D true;
+			else
+				sk->sk_state_change(sk);
 		} else {
 			err =3D -EINVAL;
 		}
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--nFreZHaLTZJo0R7j
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBAgAGBQJPssHtAAoJEJctW/TcYTgGw10QAJoRzonTPdfOvzY9VdQpSd0y
BNds3uBlOEPgEdnQlyOjklDNl65m0YfdcuuMJMcufJXBQ3g3dVPuRmfhmq6b1Px9
HK44+Lp3HJddbgBTOnIASJZEMDMhivM5bLHuPUgIG7tRfj/VuGt6Cf0tqK9FMMrP
zgPXsTVCZhTOFndzEHjjYnmSi8CEJcmIKov9Bj/HjuPh8lqM+w24GhvgObezMCbN
F27onUB7pxqt9xFypvvnPSRvFEy9gifdMVuWnoulRz9IjfnGqLsibMkaM4QgTTjG
bfpRDplMDeJYk32ebnR194xHMnvNAlUa/7ybDPmECoAHi5+s01YLbFn/vv6nmbMq
+zVcWDKQ/JLqxr5Dp3yqE7XuTOQtRbIWeaM1w5m8klhx0qrsJ7mOvi7F7cngsdzj
K0jInBD0i7Kda/tP8U22PLkvsD/23UmnIFKNhf5r4V0FRfM12w9IXNW9M9kb+tFy
9SkzwFxqFR1zb5xPGQIDCWKGXVaEBBRKgYHJg+uhrC03qSEFp381b6IrNcNr/H8s
xjEWgdX2Lzn5VJxoSb1h8uZy7n3tJZtOAwLEz2JD29cjBfO7fPUjHt5pvR+xHhHA
TFXhdFVSo4SCuPlCmR4po7z7Yn1yWoFppbvBalOZKE2D+xlCDuNr6H5Xz8jKzsMQ
G0F2/51G4XtUq/FcBydD
=0Prz
-----END PGP SIGNATURE-----

--nFreZHaLTZJo0R7j--
