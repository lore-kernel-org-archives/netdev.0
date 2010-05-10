From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 26/64] Bluetooth: Fix configuration of the MPS value
Date: Mon, 10 May 2010 11:37:16 +0200
Message-ID: <1c7621596d11b9c3e19eb88a818758dee4901c95.1273484097.git.marcel@holtmann.org>
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
 <7b1c0049be3aabc18831ada339dbcf41ba8c81fd.1273484097.git.marcel@holtmann.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:53454 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755787Ab0EJJiz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 May 2010 05:38:55 -0400
In-Reply-To: <7b1c0049be3aabc18831ada339dbcf41ba8c81fd.1273484097.git.marcel@holtmann.org>
In-Reply-To: <cover.1273484094.git.marcel@holtmann.org>
References: <cover.1273484094.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Gustavo F. Padovan <padovan@profusion.mobi>

We were accepting values bigger than we can accept. This was leading
ERTM to drop packets because of wrong FCS checks.

Signed-off-by: Gustavo F. Padovan <padovan@profusion.mobi>
Reviewed-by: Jo=C3=A3o Paulo Rechi Vita <jprvita@profusion.mobi>
Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 include/net/bluetooth/l2cap.h |    3 ++-
 net/bluetooth/l2cap.c         |   36 ++++++++++++++++++++-------------=
---
 2 files changed, 22 insertions(+), 17 deletions(-)

diff --git a/include/net/bluetooth/l2cap.h b/include/net/bluetooth/l2ca=
p.h
index 48f10f4..0f4e423 100644
--- a/include/net/bluetooth/l2cap.h
+++ b/include/net/bluetooth/l2cap.h
@@ -343,7 +343,8 @@ struct l2cap_pinfo {
 	__u8		remote_max_tx;
 	__u16		retrans_timeout;
 	__u16		monitor_timeout;
-	__u16		max_pdu_size;
+	__u16		remote_mps;
+	__u16		mps;
=20
 	__le16		sport;
=20
diff --git a/net/bluetooth/l2cap.c b/net/bluetooth/l2cap.c
index c50c057..94be5db 100644
--- a/net/bluetooth/l2cap.c
+++ b/net/bluetooth/l2cap.c
@@ -1606,21 +1606,21 @@ static inline int l2cap_sar_segment_sdu(struct =
sock *sk, struct msghdr *msg, siz
=20
 	__skb_queue_head_init(&sar_queue);
 	control =3D L2CAP_SDU_START;
-	skb =3D l2cap_create_iframe_pdu(sk, msg, pi->max_pdu_size, control, l=
en);
+	skb =3D l2cap_create_iframe_pdu(sk, msg, pi->remote_mps, control, len=
);
 	if (IS_ERR(skb))
 		return PTR_ERR(skb);
=20
 	__skb_queue_tail(&sar_queue, skb);
-	len -=3D pi->max_pdu_size;
-	size +=3Dpi->max_pdu_size;
+	len -=3D pi->remote_mps;
+	size +=3D pi->remote_mps;
 	control =3D 0;
=20
 	while (len > 0) {
 		size_t buflen;
=20
-		if (len > pi->max_pdu_size) {
+		if (len > pi->remote_mps) {
 			control |=3D L2CAP_SDU_CONTINUE;
-			buflen =3D pi->max_pdu_size;
+			buflen =3D pi->remote_mps;
 		} else {
 			control |=3D L2CAP_SDU_END;
 			buflen =3D len;
@@ -1701,7 +1701,7 @@ static int l2cap_sock_sendmsg(struct kiocb *iocb,=
 struct socket *sock, struct ms
 	case L2CAP_MODE_ERTM:
 	case L2CAP_MODE_STREAMING:
 		/* Entire SDU fits into one PDU */
-		if (len <=3D pi->max_pdu_size) {
+		if (len <=3D pi->remote_mps) {
 			control =3D L2CAP_SDU_UNSEGMENTED;
 			skb =3D l2cap_create_iframe_pdu(sk, msg, len, control, 0);
 			if (IS_ERR(skb)) {
@@ -2330,7 +2330,7 @@ done:
 		rfc.monitor_timeout =3D 0;
 		rfc.max_pdu_size    =3D cpu_to_le16(L2CAP_DEFAULT_MAX_PDU_SIZE);
 		if (L2CAP_DEFAULT_MAX_PDU_SIZE > pi->conn->mtu - 10)
-			rfc.max_pdu_size =3D pi->conn->mtu - 10;
+			rfc.max_pdu_size =3D cpu_to_le16(pi->conn->mtu - 10);
=20
 		l2cap_add_conf_opt(&ptr, L2CAP_CONF_RFC,
 					sizeof(rfc), (unsigned long) &rfc);
@@ -2353,7 +2353,7 @@ done:
 		rfc.monitor_timeout =3D 0;
 		rfc.max_pdu_size    =3D cpu_to_le16(L2CAP_DEFAULT_MAX_PDU_SIZE);
 		if (L2CAP_DEFAULT_MAX_PDU_SIZE > pi->conn->mtu - 10)
-			rfc.max_pdu_size =3D pi->conn->mtu - 10;
+			rfc.max_pdu_size =3D cpu_to_le16(pi->conn->mtu - 10);
=20
 		l2cap_add_conf_opt(&ptr, L2CAP_CONF_RFC,
 					sizeof(rfc), (unsigned long) &rfc);
@@ -2482,7 +2482,10 @@ done:
 		case L2CAP_MODE_ERTM:
 			pi->remote_tx_win =3D rfc.txwin_size;
 			pi->remote_max_tx =3D rfc.max_transmit;
-			pi->max_pdu_size =3D rfc.max_pdu_size;
+			if (rfc.max_pdu_size > pi->conn->mtu - 10)
+				rfc.max_pdu_size =3D le16_to_cpu(pi->conn->mtu - 10);
+
+			pi->remote_mps =3D le16_to_cpu(rfc.max_pdu_size);
=20
 			rfc.retrans_timeout =3D L2CAP_DEFAULT_RETRANS_TO;
 			rfc.monitor_timeout =3D L2CAP_DEFAULT_MONITOR_TO;
@@ -2495,7 +2498,10 @@ done:
 			break;
=20
 		case L2CAP_MODE_STREAMING:
-			pi->max_pdu_size =3D rfc.max_pdu_size;
+			if (rfc.max_pdu_size > pi->conn->mtu - 10)
+				rfc.max_pdu_size =3D le16_to_cpu(pi->conn->mtu - 10);
+
+			pi->remote_mps =3D le16_to_cpu(rfc.max_pdu_size);
=20
 			pi->conf_state |=3D L2CAP_CONF_MODE_DONE;
=20
@@ -2574,11 +2580,10 @@ static int l2cap_parse_conf_rsp(struct sock *sk=
, void *rsp, int len, void *data,
 			pi->remote_tx_win   =3D rfc.txwin_size;
 			pi->retrans_timeout =3D rfc.retrans_timeout;
 			pi->monitor_timeout =3D rfc.monitor_timeout;
-			pi->max_pdu_size    =3D le16_to_cpu(rfc.max_pdu_size);
+			pi->mps    =3D le16_to_cpu(rfc.max_pdu_size);
 			break;
 		case L2CAP_MODE_STREAMING:
-			pi->max_pdu_size    =3D le16_to_cpu(rfc.max_pdu_size);
-			break;
+			pi->mps    =3D le16_to_cpu(rfc.max_pdu_size);
 		}
 	}
=20
@@ -3753,7 +3758,7 @@ static inline int l2cap_data_channel(struct l2cap=
_conn *conn, u16 cid, struct sk
 		 * Receiver will miss it and start proper recovery
 		 * procedures and ask retransmission.
 		 */
-		if (len > L2CAP_DEFAULT_MAX_PDU_SIZE)
+		if (len > pi->mps)
 			goto drop;
=20
 		if (l2cap_check_fcs(pi, skb))
@@ -3784,8 +3789,7 @@ static inline int l2cap_data_channel(struct l2cap=
_conn *conn, u16 cid, struct sk
 		if (pi->fcs =3D=3D L2CAP_FCS_CRC16)
 			len -=3D 2;
=20
-		if (len > L2CAP_DEFAULT_MAX_PDU_SIZE || len < 4
-				|| __is_sframe(control))
+		if (len > pi->mps || len < 4 || __is_sframe(control))
 			goto drop;
=20
 		if (l2cap_check_fcs(pi, skb))
--=20
1.6.6.1

