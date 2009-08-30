From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 27/47] Bluetooth: Allow setting of L2CAP ERTM via socket option
Date: Sun, 30 Aug 2009 01:50:41 -0700
Message-ID: <c6b03cf986eab00e20d0dbc852b233bb83472138.1251621661.git.marcel@holtmann.org>
References: <cover.1251621661.git.marcel@holtmann.org>
 <fd0b3ff707dc1f7837079044bd4eca7ed505f70d.1251621661.git.marcel@holtmann.org>
 <981b1414d78a7a42cab48b97d4de54a62d61db88.1251621661.git.marcel@holtmann.org>
 <290ba200815fdecb4d40dc942499c4ea6d0c4624.1251621661.git.marcel@holtmann.org>
 <364f63519d94442ed373ac7da79033c8282df46a.1251621661.git.marcel@holtmann.org>
 <9eba32b86d17ef87131fa0bce43c614904ab5781.1251621661.git.marcel@holtmann.org>
 <edad63886993d18ab800c49f6587a93432ef8b35.1251621661.git.marcel@holtmann.org>
 <132ff4e5fa8dfb71a7d99902f88043113947e972.1251621661.git.marcel@holtmann.org>
 <789221ecc870117b77e354d488d5d29f15410de8.1251621661.git.marcel@holtmann.org>
 <fb784f0508d5aa39a23e72879a8dfb517c6f6e7f.1251621661.git.marcel@holtmann.org>
 <196be0cd018068d545e1d764094c7b07aaf0bcfe.1251621661.git.marcel@holtmann.org>
 <e7a25f9839fd392ec2c96e7e2b3734501d761a24.1251621661.git.marcel@holtmann.org>
 <08b0b0ce8c609b0e2284b134f0614e211374a038.1251621661.git.marcel@holtmann.org>
 <944fe798c6a48336e82bbc0d4e280587325a4d95.1251621661.git.marcel@holtmann.org>
 <542399037d0cb2b2e96dfb8ced35b07dfb1c3706.1251621661.git.marcel@holtmann.org>
 <4271e08d8b799171af18d7864908ec444282efe5.1251621661.git.marcel@holtmann.org>
 <dcf47f3bc798888f9ea40b9f626d669dc62086bf.1251621661.git.marcel@holtmann.org>
 <9666fb356da78a5ec28403197d72e8cd6aa16424.1251621661.git.marcel@holtmann.org>
 <60dee5ccd789ee8a380eee802b6cb24c52123428.1251621661.git.marcel@holtmann.org>
 <91d697302b291205171840bfe84c1563e171acb2.1251621661.git.marcel@holtmann.org>
 <e0721f99ba33d13a88746732be2d74ca805abf55.1251621661.git.marcel@holtmann.org>
 <9374253ffe609f2d70dd5ae280182cb6f08fef08.1251621661.git.marcel@holtmann.org>
 <3318b2362bf0528be77123c480249663557dfbfc.1251621661.git.marcel@holtmann.org>
 <5959809ded86e267c1a95fb44738a224c30d3434.1251621661.git.marcel@holtmann.org>
 <a6a67efd7088702fdbbb780c5a3f8e1a74e77b63.1251621661.git.marcel@holtmann.org>
 <52d18347dfb61519aa0f58fe1759edd3ad8c4e36.1251621661.git.marcel@holtmann.org>
 <44dd46de325c4d47abfd1361e5d84a548edb8e42.1251621661.git.marcel@holtmann.org>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:53310 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753167AbZH3IwX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Aug 2009 04:52:23 -0400
In-Reply-To: <44dd46de325c4d47abfd1361e5d84a548edb8e42.1251621661.git.marcel@holtmann.org>
In-Reply-To: <cover.1251621661.git.marcel@holtmann.org>
References: <cover.1251621661.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To enable Enhanced Retransmission mode it needs to be set via a socket
option. A different mode can be set on a socket, but on listen() and
connect() the mode is checked and ERTM is only allowed if it is enabled
via the module parameter.

Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 include/net/bluetooth/l2cap.h |    8 +++++---
 net/bluetooth/l2cap.c         |   37 +++++++++++++++++++++++++++++++++----
 2 files changed, 38 insertions(+), 7 deletions(-)

diff --git a/include/net/bluetooth/l2cap.h b/include/net/bluetooth/l2cap.h
index e919fca..06b072f 100644
--- a/include/net/bluetooth/l2cap.h
+++ b/include/net/bluetooth/l2cap.h
@@ -190,7 +190,7 @@ struct l2cap_conf_rfc {
 #define L2CAP_MODE_RETRANS	0x01
 #define L2CAP_MODE_FLOWCTL	0x02
 #define L2CAP_MODE_ERTM		0x03
-#define L2CAP_MODE_STREAM	0x04
+#define L2CAP_MODE_STREAMING	0x04
 
 struct l2cap_disconn_req {
 	__le16     dcid;
@@ -271,9 +271,11 @@ struct l2cap_pinfo {
 	__u16		imtu;
 	__u16		omtu;
 	__u16		flush_to;
-	__u8            sec_level;
+	__u8		mode;
+	__u8		fcs;
+	__u8		sec_level;
 	__u8		role_switch;
-	__u8            force_reliable;
+	__u8		force_reliable;
 
 	__u8		conf_req[64];
 	__u8		conf_len;
diff --git a/net/bluetooth/l2cap.c b/net/bluetooth/l2cap.c
index 810a3c1..8a59e57 100644
--- a/net/bluetooth/l2cap.c
+++ b/net/bluetooth/l2cap.c
@@ -717,12 +717,16 @@ static void l2cap_sock_init(struct sock *sk, struct sock *parent)
 
 		pi->imtu = l2cap_pi(parent)->imtu;
 		pi->omtu = l2cap_pi(parent)->omtu;
+		pi->mode = l2cap_pi(parent)->mode;
+		pi->fcs  = l2cap_pi(parent)->fcs;
 		pi->sec_level = l2cap_pi(parent)->sec_level;
 		pi->role_switch = l2cap_pi(parent)->role_switch;
 		pi->force_reliable = l2cap_pi(parent)->force_reliable;
 	} else {
 		pi->imtu = L2CAP_DEFAULT_MTU;
 		pi->omtu = 0;
+		pi->mode = L2CAP_MODE_BASIC;
+		pi->fcs  = L2CAP_FCS_CRC16;
 		pi->sec_level = BT_SECURITY_LOW;
 		pi->role_switch = 0;
 		pi->force_reliable = 0;
@@ -958,6 +962,18 @@ static int l2cap_sock_connect(struct socket *sock, struct sockaddr *addr, int al
 		goto done;
 	}
 
+	switch (l2cap_pi(sk)->mode) {
+	case L2CAP_MODE_BASIC:
+		break;
+	case L2CAP_MODE_ERTM:
+		if (enable_ertm)
+			break;
+		/* fall through */
+	default:
+		err = -ENOTSUPP;
+		goto done;
+	}
+
 	switch (sk->sk_state) {
 	case BT_CONNECT:
 	case BT_CONNECT2:
@@ -1009,6 +1025,18 @@ static int l2cap_sock_listen(struct socket *sock, int backlog)
 		goto done;
 	}
 
+	switch (l2cap_pi(sk)->mode) {
+	case L2CAP_MODE_BASIC:
+		break;
+	case L2CAP_MODE_ERTM:
+		if (enable_ertm)
+			break;
+		/* fall through */
+	default:
+		err = -ENOTSUPP;
+		goto done;
+	}
+
 	if (!l2cap_pi(sk)->psm) {
 		bdaddr_t *src = &bt_sk(sk)->src;
 		u16 psm;
@@ -1259,7 +1287,7 @@ static int l2cap_sock_setsockopt_old(struct socket *sock, int optname, char __us
 		opts.imtu     = l2cap_pi(sk)->imtu;
 		opts.omtu     = l2cap_pi(sk)->omtu;
 		opts.flush_to = l2cap_pi(sk)->flush_to;
-		opts.mode     = L2CAP_MODE_BASIC;
+		opts.mode     = l2cap_pi(sk)->mode;
 
 		len = min_t(unsigned int, sizeof(opts), optlen);
 		if (copy_from_user((char *) &opts, optval, len)) {
@@ -1267,8 +1295,9 @@ static int l2cap_sock_setsockopt_old(struct socket *sock, int optname, char __us
 			break;
 		}
 
-		l2cap_pi(sk)->imtu  = opts.imtu;
-		l2cap_pi(sk)->omtu  = opts.omtu;
+		l2cap_pi(sk)->imtu = opts.imtu;
+		l2cap_pi(sk)->omtu = opts.omtu;
+		l2cap_pi(sk)->mode = opts.mode;
 		break;
 
 	case L2CAP_LM:
@@ -1381,7 +1410,7 @@ static int l2cap_sock_getsockopt_old(struct socket *sock, int optname, char __us
 		opts.imtu     = l2cap_pi(sk)->imtu;
 		opts.omtu     = l2cap_pi(sk)->omtu;
 		opts.flush_to = l2cap_pi(sk)->flush_to;
-		opts.mode     = L2CAP_MODE_BASIC;
+		opts.mode     = l2cap_pi(sk)->mode;
 
 		len = min_t(unsigned int, len, sizeof(opts));
 		if (copy_to_user(optval, (char *) &opts, len))
-- 
1.6.2.5

