From: =?UTF-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
Subject: [PATCH 6/6] Phonet: fix flawed "SYN/ACK" logic
Date: Fri, 25 Feb 2011 11:15:01 +0200
Message-ID: <1298625301-13909-6-git-send-email-remi.denis-courmont@nokia.com>
References: <201102251113.41620.remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([147.243.128.24]:30709 "EHLO mgw-da01.nokia.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932382Ab1BYJOa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Feb 2011 04:14:30 -0500
Received: from leon.remlab.com (helruo-dhcp021243.ntc.nokia.com [172.21.21.243])
	by mgw-da01.nokia.com (Switch-3.4.3/Switch-3.4.3) with ESMTP id p1P9EHG5005431
	for <netdev@vger.kernel.org>; Fri, 25 Feb 2011 11:14:28 +0200
In-Reply-To: <201102251113.41620.remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 * Do not fail if the peer supports more or less than 3 algorithms.
 * Ignore unknown congestion control algorithms instead of failing.
 * Simplify congestion algorithm negotiation (largest is best).
 * Do not use a static buffer.
 * Fix off-by-two read overflow.
 * Avoid extra memory copy (in addition to skb_copy_bits()).

The previous code really made no sense.

Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 include/net/phonet/pep.h |    1 +
 net/phonet/pep.c         |  125 +++++++++++++++++---------------------=
-------
 2 files changed, 48 insertions(+), 78 deletions(-)

diff --git a/include/net/phonet/pep.h b/include/net/phonet/pep.h
index 37f23dc..38eed1b 100644
--- a/include/net/phonet/pep.h
+++ b/include/net/phonet/pep.h
@@ -154,6 +154,7 @@ enum {
 	PN_LEGACY_FLOW_CONTROL,
 	PN_ONE_CREDIT_FLOW_CONTROL,
 	PN_MULTI_CREDIT_FLOW_CONTROL,
+	PN_MAX_FLOW_CONTROL,
 };
=20
 #define pn_flow_safe(fc) ((fc) >> 1)
diff --git a/net/phonet/pep.c b/net/phonet/pep.c
index 0ecab59..b8c31fc 100644
--- a/net/phonet/pep.c
+++ b/net/phonet/pep.c
@@ -108,70 +108,6 @@ static int pep_reply(struct sock *sk, struct sk_bu=
ff *oskb,
 #define PAD 0x00
=20
 #ifdef CONFIG_PHONET_PIPECTRLR
-static u8 pipe_negotiate_fc(u8 *host_fc, u8 *remote_fc, int len)
-{
-	int i, j;
-	u8 base_fc, final_fc;
-
-	for (i =3D 0; i < len; i++) {
-		base_fc =3D host_fc[i];
-		for (j =3D 0; j < len; j++) {
-			if (remote_fc[j] =3D=3D base_fc) {
-				final_fc =3D base_fc;
-				goto done;
-			}
-		}
-	}
-	return -EINVAL;
-
-done:
-	return final_fc;
-
-}
-
-static int pipe_get_flow_info(struct sock *sk, struct sk_buff *skb,
-		u8 *pref_rx_fc, u8 *req_tx_fc)
-{
-	struct pnpipehdr *hdr;
-	u8 n_sb;
-
-	if (!pskb_may_pull(skb, sizeof(*hdr) + 4))
-		return -EINVAL;
-
-	hdr =3D pnp_hdr(skb);
-	n_sb =3D hdr->data[4];
-
-	__skb_pull(skb, sizeof(*hdr) + 4);
-	while (n_sb > 0) {
-		u8 type, buf[3], len =3D sizeof(buf);
-		u8 *data =3D pep_get_sb(skb, &type, &len, buf);
-
-		if (data =3D=3D NULL)
-			return -EINVAL;
-
-		switch (type) {
-		case PN_PIPE_SB_REQUIRED_FC_TX:
-			if (len < 3 || (data[2] | data[3] | data[4]) > 3)
-				break;
-			req_tx_fc[0] =3D data[2];
-			req_tx_fc[1] =3D data[3];
-			req_tx_fc[2] =3D data[4];
-			break;
-
-		case PN_PIPE_SB_PREFERRED_FC_RX:
-			if (len < 3 || (data[2] | data[3] | data[4]) > 3)
-				break;
-			pref_rx_fc[0] =3D data[2];
-			pref_rx_fc[1] =3D data[3];
-			pref_rx_fc[2] =3D data[4];
-			break;
-
-		}
-		n_sb--;
-	}
-	return 0;
-}
-
 static int pipe_handler_send_req(struct sock *sk, u8 msg_id, gfp_t pri=
ority)
 {
 	int len;
@@ -661,28 +597,61 @@ static void pipe_destruct(struct sock *sk)
 }
=20
 #ifdef CONFIG_PHONET_PIPECTRLR
+static u8 pipe_negotiate_fc(const u8 *fcs, unsigned n)
+{
+	unsigned i;
+	u8 final_fc =3D PN_NO_FLOW_CONTROL;
+
+	for (i =3D 0; i < n; i++) {
+		u8 fc =3D fcs[i];
+
+		if (fc > final_fc && fc < PN_MAX_FLOW_CONTROL)
+			final_fc =3D fc;
+	}
+	return final_fc;
+}
+
 static int pep_connresp_rcv(struct sock *sk, struct sk_buff *skb)
 {
 	struct pep_sock *pn =3D pep_sk(sk);
-	u8 host_pref_rx_fc[3] =3D {3, 2, 1}, host_req_tx_fc[3] =3D {3, 2, 1};
-	u8 remote_pref_rx_fc[3], remote_req_tx_fc[3];
-	u8 negotiated_rx_fc, negotiated_tx_fc;
-
-	pipe_get_flow_info(sk, skb, remote_pref_rx_fc,
-			remote_req_tx_fc);
-	negotiated_tx_fc =3D pipe_negotiate_fc(remote_req_tx_fc,
-			host_pref_rx_fc,
-			sizeof(host_pref_rx_fc));
-	negotiated_rx_fc =3D pipe_negotiate_fc(host_req_tx_fc,
-			remote_pref_rx_fc,
-			sizeof(host_pref_rx_fc));
+	struct pnpipehdr *hdr;
+	u8 n_sb;
+
+	if (!pskb_pull(skb, sizeof(*hdr) + 4))
+		return -EINVAL;
+
+	hdr =3D pnp_hdr(skb);
+
+	/* Parse sub-blocks */
+	n_sb =3D hdr->data[4];
+	while (n_sb > 0) {
+		u8 type, buf[6], len =3D sizeof(buf);
+		const u8 *data =3D pep_get_sb(skb, &type, &len, buf);
+
+		if (data =3D=3D NULL)
+			return -EINVAL;
+
+		switch (type) {
+		case PN_PIPE_SB_REQUIRED_FC_TX:
+			if (len < 2 || len < data[0])
+				break;
+			pn->tx_fc =3D pipe_negotiate_fc(data + 2, len - 2);
+			break;
+
+		case PN_PIPE_SB_PREFERRED_FC_RX:
+			if (len < 2 || len < data[0])
+				break;
+			pn->rx_fc =3D pipe_negotiate_fc(data + 2, len - 2);
+			break;
+
+		}
+		n_sb--;
+	}
=20
 	sk->sk_state =3D TCP_SYN_RECV;
 	sk->sk_backlog_rcv =3D pipe_do_rcv;
 	sk->sk_destruct =3D pipe_destruct;
 	pn->rx_credits =3D 0;
-	pn->rx_fc =3D negotiated_rx_fc;
-	pn->tx_fc =3D negotiated_tx_fc;
 	sk->sk_state_change(sk);
=20
 	return pipe_handler_send_created_ind(sk, PNS_PIPE_CREATED_IND);
--=20
1.7.1

