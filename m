From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: [PATCH] Bluetooth: Pre-initialize variables in read_local_oob_ext_data_complete()
Date: Thu, 16 Apr 2015 21:24:25 +0200
Message-ID: <1429212265-26750-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Geert Uytterhoeven <geert@linux-m68k.org>
To: Marcel Holtmann <marcel@holtmann.org>,
	Gustavo Padovan <gustavo@padovan.org>,
	Johan Hedberg <johan.hedberg@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from baptiste.telenet-ops.be ([195.130.132.51]:41864 "EHLO
	baptiste.telenet-ops.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751501AbbDPTYU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2015 15:24:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

net/bluetooth/mgmt.c: In function =E2=80=98read_local_oob_ext_data_comp=
lete=E2=80=99:
net/bluetooth/mgmt.c:6474: warning: =E2=80=98r256=E2=80=99 may be used =
uninitialized in this function
net/bluetooth/mgmt.c:6474: warning: =E2=80=98h256=E2=80=99 may be used =
uninitialized in this function
net/bluetooth/mgmt.c:6474: warning: =E2=80=98r192=E2=80=99 may be used =
uninitialized in this function
net/bluetooth/mgmt.c:6474: warning: =E2=80=98h192=E2=80=99 may be used =
uninitialized in this function

While these are false positives, the code can be shortened by
pre-initializing the hash table pointers and eir_len. This has the side
effect of killing the compiler warnings.

Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
---
 net/bluetooth/mgmt.c | 16 ++--------------
 1 file changed, 2 insertions(+), 14 deletions(-)

diff --git a/net/bluetooth/mgmt.c b/net/bluetooth/mgmt.c
index 7fd87e7135b52753..f8e13b6d58279463 100644
--- a/net/bluetooth/mgmt.c
+++ b/net/bluetooth/mgmt.c
@@ -6471,9 +6471,9 @@ static void read_local_oob_ext_data_complete(stru=
ct hci_dev *hdev, u8 status,
 {
 	const struct mgmt_cp_read_local_oob_ext_data *mgmt_cp;
 	struct mgmt_rp_read_local_oob_ext_data *mgmt_rp;
-	u8 *h192, *r192, *h256, *r256;
+	u8 *h192 =3D NULL, *r192 =3D NULL, *h256 =3D NULL, *r256 =3D NULL;
 	struct mgmt_pending_cmd *cmd;
-	u16 eir_len;
+	u16 eir_len =3D 0;
 	int err;
=20
 	BT_DBG("%s status %u", hdev->name, status);
@@ -6486,18 +6486,11 @@ static void read_local_oob_ext_data_complete(st=
ruct hci_dev *hdev, u8 status,
=20
 	if (status) {
 		status =3D mgmt_status(status);
-		eir_len =3D 0;
-
-		h192 =3D NULL;
-		r192 =3D NULL;
-		h256 =3D NULL;
-		r256 =3D NULL;
 	} else if (opcode =3D=3D HCI_OP_READ_LOCAL_OOB_DATA) {
 		struct hci_rp_read_local_oob_data *rp;
=20
 		if (skb->len !=3D sizeof(*rp)) {
 			status =3D MGMT_STATUS_FAILED;
-			eir_len =3D 0;
 		} else {
 			status =3D MGMT_STATUS_SUCCESS;
 			rp =3D (void *)skb->data;
@@ -6505,23 +6498,18 @@ static void read_local_oob_ext_data_complete(st=
ruct hci_dev *hdev, u8 status,
 			eir_len =3D 5 + 18 + 18;
 			h192 =3D rp->hash;
 			r192 =3D rp->rand;
-			h256 =3D NULL;
-			r256 =3D NULL;
 		}
 	} else {
 		struct hci_rp_read_local_oob_ext_data *rp;
=20
 		if (skb->len !=3D sizeof(*rp)) {
 			status =3D MGMT_STATUS_FAILED;
-			eir_len =3D 0;
 		} else {
 			status =3D MGMT_STATUS_SUCCESS;
 			rp =3D (void *)skb->data;
=20
 			if (hci_dev_test_flag(hdev, HCI_SC_ONLY)) {
 				eir_len =3D 5 + 18 + 18;
-				h192 =3D NULL;
-				r192 =3D NULL;
 			} else {
 				eir_len =3D 5 + 18 + 18 + 18 + 18;
 				h192 =3D rp->hash192;
--=20
1.9.1
