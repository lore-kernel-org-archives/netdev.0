From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 25/64] Bluetooth: Read RFC conf option on a successful Conf RSP
Date: Mon, 10 May 2010 11:37:15 +0200
Message-ID: <7b1c0049be3aabc18831ada339dbcf41ba8c81fd.1273484097.git.marcel@holtmann.org>
References: <cover.1273484094.git.marcel@holtmann.org>
 <fe1aff710756ac73c455d214845c74e304d0e966.1273484095.git.marcel@holtmann.org>
 <acce90d6a957812081b83ac4d1133e93a43569c6.1273484095.git.marcel@holtmann.org>
 <4f7ac1814ef6f0773e57ffd159a1dd57a3c80521.1273484095.git.marcel@holtmann.org>
 <0d861d8b8edd139a9b291cb262d08dec8dc3922d.1273484095.git.marcel@holtmann.org>
 <b9dbdbc1f4404cba2e64939c30c87d59c9796e4e.1273484095.git.marcel@holtmann.org>
 <c69163e9ed5048407cc84f439cbfecc53f6f7131.1273484095.git.marcel@holtmann.org>
 <faaebd192ec9c3febcab98149d1309199a5b886c.1273484095.git.marcel@holtmann.org>
 <7dffe4210233a2860c3f41477c40b3252edf2b7d.1273484095.git.marcel@holtmann.org>
 <d1daa091e8612f3aab14d28b5836375fafe155e1.1273484096.git.marcel@holtmann.org>
 <e8235c6bdd1c7ffbaa7eb8dcdbb46c51f1e5d72e.1273484096.git.marcel@holtmann.org>
 <d5392c8f1e9faef089bb7cb66c3314da8bddd1fe.1273484096.git.marcel@holtmann.org>
 <1d8f5d16913d74e428950ee02fe9ff7e6391c120.1273484096.git.marcel@holtmann.org>
 <277ffbe362823d18a17792fbd8e507010e666299.1273484096.git.marcel@holtmann.org>
 <36f2fd585f43199f006a3b5ff84e95815102cd31.1273484096.git.marcel@holtmann.org>
 <9e917af13d59182f95bbb5483dc0c4254dfb7944.1273484096.git.marcel@holtmann.org>
 <f0946ccfc7da403a46b7ff7cb2e3deffac108742.1273484096.git.marcel@holtmann.org>
 <73edaa9933219e25d6733b78d1e2c881025705e2.1273484096.git.marcel@holtmann.org>
 <e072745f4adb01b909bd08a0cfc8f79348f4d2c6.1273484096.git.marcel@holtmann.org>
 <99b0d4b7b09edeacf4542bced5c01239375b51a9.1273484096.git.marcel@holtmann.org>
 <6e3a59819fac19006fe4255b87928e5a12c54532.1273484096.git.marcel@holtmann.org>
 <8abb52ee00c4b3f857269eb6b7145991bab869bf.1273484096.git.marcel@holtmann.org>
 <05fbd89dd4153341717b33d9e8ae8bd29db6c1c8.1273484096.git.marcel@holtmann.org>
 <c1b4f43be01c2a363be021485dd18cca33cfab8a.1273484097.git.marcel@holtmann.org>
 <2fb862e215e53630066c677e06d7551fa38bf235.1273484097.git.marcel@holtmann.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:53441 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755819Ab0EJJiy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 May 2010 05:38:54 -0400
In-Reply-To: <2fb862e215e53630066c677e06d7551fa38bf235.1273484097.git.marcel@holtmann.org>
In-Reply-To: <cover.1273484094.git.marcel@holtmann.org>
References: <cover.1273484094.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Gustavo F. Padovan <padovan@profusion.mobi>

On Enhanced Retransmission Mode and Streaming Mode a entity can send, o=
n
a successful Conf RSP, new values for the RFC fields. For example, the
entity can send txWindow and MPS values less than the value received on
a Conf REQ.

Signed-off-by: Gustavo F. Padovan <padovan@profusion.mobi>
Reviewed-by: Jo=C3=A3o Paulo Rechi Vita <jprvita@profusion.mobi>
Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 net/bluetooth/l2cap.c |   39 ++++++++++++++++++++++++++++++++++++++-
 1 files changed, 38 insertions(+), 1 deletions(-)

diff --git a/net/bluetooth/l2cap.c b/net/bluetooth/l2cap.c
index f604405..c50c057 100644
--- a/net/bluetooth/l2cap.c
+++ b/net/bluetooth/l2cap.c
@@ -2602,6 +2602,42 @@ static int l2cap_build_conf_rsp(struct sock *sk,=
 void *data, u16 result, u16 fla
 	return ptr - data;
 }
=20
+static void l2cap_conf_rfc_get(struct sock *sk, void *rsp, int len)
+{
+	struct l2cap_pinfo *pi =3D l2cap_pi(sk);
+	int type, olen;
+	unsigned long val;
+	struct l2cap_conf_rfc rfc;
+
+	BT_DBG("sk %p, rsp %p, len %d", sk, rsp, len);
+
+	if ((pi->mode !=3D L2CAP_MODE_ERTM) && (pi->mode !=3D L2CAP_MODE_STRE=
AMING))
+		return;
+
+	while (len >=3D L2CAP_CONF_OPT_SIZE) {
+		len -=3D l2cap_get_conf_opt(&rsp, &type, &olen, &val);
+
+		switch (type) {
+		case L2CAP_CONF_RFC:
+			if (olen =3D=3D sizeof(rfc))
+				memcpy(&rfc, (void *)val, olen);
+			goto done;
+		}
+	}
+
+done:
+	switch (rfc.mode) {
+	case L2CAP_MODE_ERTM:
+		pi->remote_tx_win   =3D rfc.txwin_size;
+		pi->retrans_timeout =3D rfc.retrans_timeout;
+		pi->monitor_timeout =3D rfc.monitor_timeout;
+		pi->mps    =3D le16_to_cpu(rfc.max_pdu_size);
+		break;
+	case L2CAP_MODE_STREAMING:
+		pi->mps    =3D le16_to_cpu(rfc.max_pdu_size);
+	}
+}
+
 static inline int l2cap_command_rej(struct l2cap_conn *conn, struct l2=
cap_cmd_hdr *cmd, u8 *data)
 {
 	struct l2cap_cmd_rej *rej =3D (struct l2cap_cmd_rej *) data;
@@ -2881,6 +2917,7 @@ static inline int l2cap_config_rsp(struct l2cap_c=
onn *conn, struct l2cap_cmd_hdr
 	struct l2cap_conf_rsp *rsp =3D (struct l2cap_conf_rsp *)data;
 	u16 scid, flags, result;
 	struct sock *sk;
+	int len =3D cmd->len - sizeof(*rsp);
=20
 	scid   =3D __le16_to_cpu(rsp->scid);
 	flags  =3D __le16_to_cpu(rsp->flags);
@@ -2895,11 +2932,11 @@ static inline int l2cap_config_rsp(struct l2cap=
_conn *conn, struct l2cap_cmd_hdr
=20
 	switch (result) {
 	case L2CAP_CONF_SUCCESS:
+		l2cap_conf_rfc_get(sk, rsp->data, len);
 		break;
=20
 	case L2CAP_CONF_UNACCEPT:
 		if (l2cap_pi(sk)->num_conf_rsp <=3D L2CAP_CONF_MAX_CONF_RSP) {
-			int len =3D cmd->len - sizeof(*rsp);
 			char req[64];
=20
 			if (len > sizeof(req) - sizeof(struct l2cap_conf_req)) {
--=20
1.6.6.1

