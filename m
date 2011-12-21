From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless 2011-12-21
Date: Wed, 21 Dec 2011 13:59:14 -0500
Message-ID: <20111221185914.GD11842@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="liOOAslEiF7prFVr"
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--liOOAslEiF7prFVr
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

commit b4949b84567f3ae1227d076fc95bbd8efea06506

Dave,

A few last(?) fixes intended for 3.2...

The biggest portion are from Gustavo:

"3 fixes for 3.2! There one revert that was causing connection issues,
a RFCOMM fix to a potential kernel panic, and the last on L2CAP to
a possible access to uninitialized data due to broken remote devices."

Also, an iwlwifi fix for a problem causing firmware asserts.

Please let me know if there are problems!

John

---

The following changes since commit cd7816d14953c8af910af5bb92f488b0b277e29d:

  net: have ipconfig not wait if no dev is available (2011-12-20 14:09:15 -=
0500)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git for-d=
avem

Emmanuel Grumbach (1):
      iwlwifi: update SCD BC table for all SCD queues

Gustavo F. Padovan (1):
      Revert "Bluetooth: Revert: Fix L2CAP connection establishment"

John W. Linville (2):
      Merge branch 'master' of git://git.kernel.org/.../padovan/bluetooth
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless i=
nto for-davem

Mat Martineau (2):
      Bluetooth: Prevent uninitialized data access in L2CAP configuration
      Bluetooth: Clear RFCOMM session timer when disconnecting last channel

 drivers/net/wireless/iwlwifi/iwl-trans-pcie.c |    4 +---
 net/bluetooth/hci_conn.c                      |    2 +-
 net/bluetooth/l2cap_core.c                    |   12 +++++++++++-
 net/bluetooth/rfcomm/core.c                   |    1 +
 4 files changed, 14 insertions(+), 5 deletions(-)

diff --git a/drivers/net/wireless/iwlwifi/iwl-trans-pcie.c b/drivers/net/wi=
reless/iwlwifi/iwl-trans-pcie.c
index ce91898..5f17ab8 100644
--- a/drivers/net/wireless/iwlwifi/iwl-trans-pcie.c
+++ b/drivers/net/wireless/iwlwifi/iwl-trans-pcie.c
@@ -1197,9 +1197,7 @@ static int iwl_trans_pcie_tx(struct iwl_trans *trans,=
 struct sk_buff *skb,
 	iwl_print_hex_dump(trans, IWL_DL_TX, (u8 *)tx_cmd->hdr, hdr_len);
=20
 	/* Set up entry for this TFD in Tx byte-count array */
-	if (is_agg)
-		iwl_trans_txq_update_byte_cnt_tbl(trans, txq,
-					       le16_to_cpu(tx_cmd->len));
+	iwl_trans_txq_update_byte_cnt_tbl(trans, txq, le16_to_cpu(tx_cmd->len));
=20
 	dma_sync_single_for_device(bus(trans)->dev, txcmd_phys, firstlen,
 			DMA_BIDIRECTIONAL);
diff --git a/net/bluetooth/hci_conn.c b/net/bluetooth/hci_conn.c
index e0af723..c1c597e 100644
--- a/net/bluetooth/hci_conn.c
+++ b/net/bluetooth/hci_conn.c
@@ -673,7 +673,7 @@ int hci_conn_security(struct hci_conn *conn, __u8 sec_l=
evel, __u8 auth_type)
 		goto encrypt;
=20
 auth:
-	if (test_and_set_bit(HCI_CONN_ENCRYPT_PEND, &conn->pend))
+	if (test_bit(HCI_CONN_ENCRYPT_PEND, &conn->pend))
 		return 0;
=20
 	if (!hci_conn_auth(conn, sec_level, auth_type))
diff --git a/net/bluetooth/l2cap_core.c b/net/bluetooth/l2cap_core.c
index 5ea94a1..17b5b1c 100644
--- a/net/bluetooth/l2cap_core.c
+++ b/net/bluetooth/l2cap_core.c
@@ -2152,7 +2152,7 @@ static int l2cap_parse_conf_rsp(struct l2cap_chan *ch=
an, void *rsp, int len, voi
 	void *ptr =3D req->data;
 	int type, olen;
 	unsigned long val;
-	struct l2cap_conf_rfc rfc;
+	struct l2cap_conf_rfc rfc =3D { .mode =3D L2CAP_MODE_BASIC };
=20
 	BT_DBG("chan %p, rsp %p, len %d, req %p", chan, rsp, len, data);
=20
@@ -2271,6 +2271,16 @@ static void l2cap_conf_rfc_get(struct l2cap_chan *ch=
an, void *rsp, int len)
 		}
 	}
=20
+	/* Use sane default values in case a misbehaving remote device
+	 * did not send an RFC option.
+	 */
+	rfc.mode =3D chan->mode;
+	rfc.retrans_timeout =3D cpu_to_le16(L2CAP_DEFAULT_RETRANS_TO);
+	rfc.monitor_timeout =3D cpu_to_le16(L2CAP_DEFAULT_MONITOR_TO);
+	rfc.max_pdu_size =3D cpu_to_le16(chan->imtu);
+
+	BT_ERR("Expected RFC option was not found, using defaults");
+
 done:
 	switch (rfc.mode) {
 	case L2CAP_MODE_ERTM:
diff --git a/net/bluetooth/rfcomm/core.c b/net/bluetooth/rfcomm/core.c
index 4e32e18..2d28dfe 100644
--- a/net/bluetooth/rfcomm/core.c
+++ b/net/bluetooth/rfcomm/core.c
@@ -1146,6 +1146,7 @@ static int rfcomm_recv_ua(struct rfcomm_session *s, u=
8 dlci)
 			if (list_empty(&s->dlcs)) {
 				s->state =3D BT_DISCONN;
 				rfcomm_send_disc(s, 0);
+				rfcomm_session_clear_timer(s);
 			}
=20
 			break;
--=20
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.

--liOOAslEiF7prFVr
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBAgAGBQJO8iyBAAoJEJctW/TcYTgGczsP/10aGT5iebMXycYgtRuvKn5p
KTAMBk9+oqiK8ac6HGRjztKtZQCm5VhQbXH8W+/mbUzMR/mWFQQYe+yJctWh8QKV
wk5k4C0E7yaMzu7vuoRo5rRD2c9L20I5I3DybkrrpADQNd6Sbe8R+Wmq1VhBMKTV
7hTcEy0F0VzS9Zjg4JHNm+E2xTNjZrYSlLR1rjcizuOfPXM2VuJ9sNzyVW5Bfe8S
tTXfOl03wR24LU6U4Ll/d1iHK9w5/2mRLx1X0y+S37KKLpH2IylfbtkdvIvFQLHk
c0oxAKmbjf8j02gfGZyDJ82fUIB1AG940IDt2jDbpvTY7qk5DWz4+UJZSNfA1RJ2
QUbBE5nPcMyCopufI15EY3ciuhrPdxD/nHofhq0kkR5H4T/Lq1Mu1jFvwWZzDsN2
laUY1MHQiySDOAe6U4P3LyVfBRKXKD7gFCCPexJsasSFwiL+glX0hX54Ph3LtJIo
qDy3yC3tcxcCcjSN+Ygf+sCgrDuupkttFwkwMPpmSbiBO97TE+kLlqqa1PWOOgZQ
rIVsKSgmL6ZZxaBJS57RZNgaRJ6RaXiFoKE9LvnhZd6G1QRR58Z/4qTNl2YVJx3n
LGDgvFophETFsaajxA/8v/OuQSb0jNjFIq5ff/ZoGrd0hNw0zmEJHO2EXrOkUW+a
WQY5LooUeX57JsyWxokQ
=b5wA
-----END PGP SIGNATURE-----

--liOOAslEiF7prFVr--
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
