From: Remi Denis-Courmont <remi.denis-courmont@nokia.com>
Subject: [PATCH 3/6] Phonet: Pipe End Point for Phonet Pipes protocol
Date: Wed,  1 Oct 2008 13:13:02 +0300
Message-ID: <1222855985-22859-3-git-send-email-remi.denis-courmont@nokia.com>
References: <200810011312.17288.remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.230]:38244 "EHLO
	mgw-mx03.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753159AbYJAKNb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2008 06:13:31 -0400
Received: from esebh107.NOE.Nokia.com (esebh107.ntc.nokia.com [172.21.143.143])
	by mgw-mx03.nokia.com (Switch-3.2.6/Switch-3.2.6) with ESMTP id m91ADG2Z022099
	for <netdev@vger.kernel.org>; Wed, 1 Oct 2008 13:13:27 +0300
In-Reply-To: <200810011312.17288.remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>

This protocol provides some connection handling and negotiated
congestion control. Nokia cellular modems use it for bulk transfers.
It provides packet boundaries (hence SOCK_SEQPACKET). Congestion
control is per packet rather per byte, so we do not re-use the
generic socket memory accounting.

Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 include/linux/phonet.h   |    4 +-
 include/net/phonet/pep.h |  110 ++++++
 net/phonet/Makefile      |    4 +-
 net/phonet/af_phonet.c   |    3 +
 net/phonet/pep.c         |  904 ++++++++++++++++++++++++++++++++++++++=
++++++++
 5 files changed, 1023 insertions(+), 2 deletions(-)
 create mode 100644 net/phonet/pep.c

diff --git a/include/linux/phonet.h b/include/linux/phonet.h
index 3a027f5..f921852 100644
--- a/include/linux/phonet.h
+++ b/include/linux/phonet.h
@@ -27,7 +27,9 @@
 #define PN_PROTO_TRANSPORT	0
 /* Phonet datagram socket */
 #define PN_PROTO_PHONET		1
-#define PHONET_NPROTO		2
+/* Phonet pipe */
+#define PN_PROTO_PIPE		2
+#define PHONET_NPROTO		3
=20
 #define PNADDR_ANY		0
 #define PNPORT_RESOURCE_ROUTING	0
diff --git a/include/net/phonet/pep.h b/include/net/phonet/pep.h
index b2f8c54..6b89d12 100644
--- a/include/net/phonet/pep.h
+++ b/include/net/phonet/pep.h
@@ -26,11 +26,21 @@
 struct pep_sock {
 	struct pn_sock		pn_sk;
=20
+	/* XXX: union-ify listening/connect stuff ? */
 	/* Listening socket stuff: */
 	struct hlist_head	ackq;
+	struct hlist_head	hlist;
=20
 	/* Connected socket stuff: */
+	struct sock		*listener;
+	u16			peer_type;	/* peer type/subtype */
+	u8			pipe_handle;
+
+	u8			rx_credits;
 	u8			tx_credits;
+	unsigned		rx_fc:2;	/* RX flow control */
+	unsigned		tx_fc:2;	/* TX flow control */
+	unsigned		init_enable:1;	/* auto-enable at creation */
 };
=20
 static inline struct pep_sock *pep_sk(struct sock *sk)
@@ -40,4 +50,104 @@ static inline struct pep_sock *pep_sk(struct sock *=
sk)
=20
 extern const struct proto_ops phonet_stream_ops;
=20
+/* Pipe protocol definitions */
+struct pnpipehdr {
+	u8			utid; /* transaction ID */
+	u8			message_id;
+	u8			pipe_handle;
+	u8			data[1];
+};
+#define state_after_connect	data[0]
+#define other_pep_type		data[1]
+#define state_after_reset	data[0]
+
+static inline struct pnpipehdr *pnp_hdr(struct sk_buff *skb)
+{
+	return (struct pnpipehdr *)skb_transport_header(skb);
+}
+
+#define MAX_PNPIPE_HEADER (MAX_PHONET_HEADER + 4)
+
+enum {
+	PNS_PIPE_DATA =3D 0x20,
+
+	PNS_PEP_CONNECT_REQ =3D 0x40,
+	PNS_PEP_CONNECT_RESP,
+	PNS_PEP_DISCONNECT_REQ,
+	PNS_PEP_DISCONNECT_RESP,
+	PNS_PEP_RESET_REQ,
+	PNS_PEP_RESET_RESP,
+	PNS_PEP_ENABLE_REQ,
+	PNS_PEP_ENABLE_RESP,
+	PNS_PEP_CTRL_REQ,
+	PNS_PEP_CTRL_RESP,
+	PNS_PEP_DISABLE_REQ =3D 0x4C,
+	PNS_PEP_DISABLE_RESP,
+
+	PNS_PEP_STATUS_IND =3D 0x60,
+	PNS_PIPE_CREATED_IND,
+	PNS_PIPE_RESET_IND =3D 0x63,
+	PNS_PIPE_ENABLED_IND,
+	PNS_PIPE_REDIRECTED_IND,
+	PNS_PIPE_DISABLED_IND =3D 0x66,
+};
+
+#define PN_PIPE_INVALID_HANDLE	0xff
+#define PN_PEP_TYPE_COMMON	0x00
+
+/* Phonet pipe status indication */
+enum {
+	PN_PEP_IND_FLOW_CONTROL,
+	PN_PEP_IND_ID_MCFC_GRANT_CREDITS,
+};
+
+/* Phonet pipe error codes */
+enum {
+	PN_PIPE_NO_ERROR,
+	PN_PIPE_ERR_INVALID_PARAM,
+	PN_PIPE_ERR_INVALID_HANDLE,
+	PN_PIPE_ERR_INVALID_CTRL_ID,
+	PN_PIPE_ERR_NOT_ALLOWED,
+	PN_PIPE_ERR_PEP_IN_USE,
+	PN_PIPE_ERR_OVERLOAD,
+	PN_PIPE_ERR_DEV_DISCONNECTED,
+	PN_PIPE_ERR_TIMEOUT,
+	PN_PIPE_ERR_ALL_PIPES_IN_USE,
+	PN_PIPE_ERR_GENERAL,
+	PN_PIPE_ERR_NOT_SUPPORTED,
+};
+
+/* Phonet pipe states */
+enum {
+	PN_PIPE_DISABLE,
+	PN_PIPE_ENABLE,
+};
+
+/* Phonet pipe sub-block types */
+enum {
+	PN_PIPE_SB_CREATE_REQ_PEP_SUB_TYPE,
+	PN_PIPE_SB_CONNECT_REQ_PEP_SUB_TYPE,
+	PN_PIPE_SB_REDIRECT_REQ_PEP_SUB_TYPE,
+	PN_PIPE_SB_NEGOTIATED_FC,
+	PN_PIPE_SB_REQUIRED_FC_TX,
+	PN_PIPE_SB_PREFERRED_FC_RX,
+};
+
+/* Phonet pipe flow control models */
+enum {
+	PN_NO_FLOW_CONTROL,
+	PN_LEGACY_FLOW_CONTROL,
+	PN_ONE_CREDIT_FLOW_CONTROL,
+	PN_MULTI_CREDIT_FLOW_CONTROL,
+};
+
+#define pn_flow_safe(fc) ((fc) >> 1)
+
+/* Phonet pipe flow control states */
+enum {
+	PEP_IND_EMPTY,
+	PEP_IND_BUSY,
+	PEP_IND_READY,
+};
+
 #endif
diff --git a/net/phonet/Makefile b/net/phonet/Makefile
index ae9c3ed..505df2a 100644
--- a/net/phonet/Makefile
+++ b/net/phonet/Makefile
@@ -1,4 +1,4 @@
-obj-$(CONFIG_PHONET) +=3D phonet.o
+obj-$(CONFIG_PHONET) +=3D phonet.o pn_pep.o
=20
 phonet-objs :=3D \
 	pn_dev.o \
@@ -7,3 +7,5 @@ phonet-objs :=3D \
 	datagram.o \
 	sysctl.o \
 	af_phonet.o
+
+pn_pep-objs :=3D pep.o
diff --git a/net/phonet/af_phonet.c b/net/phonet/af_phonet.c
index 06627d3..126dd73 100644
--- a/net/phonet/af_phonet.c
+++ b/net/phonet/af_phonet.c
@@ -58,6 +58,9 @@ static int pn_socket_create(struct net *net, struct s=
ocket *sock, int protocol)
 		case SOCK_DGRAM:
 			protocol =3D PN_PROTO_PHONET;
 			break;
+		case SOCK_SEQPACKET:
+			protocol =3D PN_PROTO_PIPE;
+			break;
 		default:
 			return -EPROTONOSUPPORT;
 		}
diff --git a/net/phonet/pep.c b/net/phonet/pep.c
new file mode 100644
index 0000000..0c1f19f
--- /dev/null
+++ b/net/phonet/pep.c
@@ -0,0 +1,904 @@
+/*
+ * File: pep.c
+ *
+ * Phonet pipe protocol end point socket
+ *
+ * Copyright (C) 2008 Nokia Corporation.
+ *
+ * Author: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * version 2 as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA
+ * 02110-1301 USA
+ */
+
+#include <linux/kernel.h>
+#include <linux/socket.h>
+#include <net/sock.h>
+#include <net/tcp_states.h>
+#include <asm/ioctls.h>
+
+#include <linux/phonet.h>
+#include <net/phonet/phonet.h>
+#include <net/phonet/pep.h>
+
+/* sk_state values:
+ * TCP_CLOSE		sock not in use yet
+ * TCP_CLOSE_WAIT	disconnected pipe
+ * TCP_LISTEN		listening pipe endpoint
+ * TCP_SYN_RECV		connected pipe in disabled state
+ * TCP_ESTABLISHED	connected pipe in enabled state
+ *
+ * pep_sock locking:
+ *  - sk_state, ackq, hlist: sock lock needed
+ *  - listener: read only
+ *  - pipe_handle: read only
+ */
+
+#define CREDITS_MAX	10
+#define CREDITS_THR	7
+
+static const struct sockaddr_pn pipe_srv =3D {
+	.spn_family =3D AF_PHONET,
+	.spn_resource =3D 0xD9, /* pipe service */
+};
+
+#define pep_sb_size(s) (((s) + 5) & ~3) /* 2-bytes head, 32-bits align=
ed */
+
+/* Get the next TLV sub-block. */
+static unsigned char *pep_get_sb(struct sk_buff *skb, u8 *ptype, u8 *p=
len,
+					void *buf)
+{
+	void *data =3D NULL;
+	struct {
+		u8 sb_type;
+		u8 sb_len;
+	} *ph, h;
+	int buflen =3D *plen;
+
+	ph =3D skb_header_pointer(skb, 0, 2, &h);
+	if (ph =3D=3D NULL || ph->sb_len < 2 || !pskb_may_pull(skb, ph->sb_le=
n))
+		return NULL;
+	ph->sb_len -=3D 2;
+	*ptype =3D ph->sb_type;
+	*plen =3D ph->sb_len;
+
+	if (buflen > ph->sb_len)
+		buflen =3D ph->sb_len;
+	data =3D skb_header_pointer(skb, 2, buflen, buf);
+	__skb_pull(skb, 2 + ph->sb_len);
+	return data;
+}
+
+static int pep_reply(struct sock *sk, struct sk_buff *oskb,
+			u8 code, const void *data, int len, gfp_t priority)
+{
+	const struct pnpipehdr *oph =3D pnp_hdr(oskb);
+	struct pnpipehdr *ph;
+	struct sk_buff *skb;
+
+	skb =3D alloc_skb(MAX_PNPIPE_HEADER + len, priority);
+	if (!skb)
+		return -ENOMEM;
+	skb_set_owner_w(skb, sk);
+
+	skb_reserve(skb, MAX_PNPIPE_HEADER);
+	__skb_put(skb, len);
+	skb_copy_to_linear_data(skb, data, len);
+	ph =3D (void *)__skb_push(skb, sizeof(*ph));
+	ph->utid =3D oph->utid;
+	ph->message_id =3D oph->message_id + 1; /* REQ -> RESP */
+	ph->pipe_handle =3D oph->pipe_handle;
+	ph->data[0] =3D code;	/* error code */
+
+	return pn_skb_send(sk, skb, &pipe_srv);
+}
+
+#define PAD 0x00
+static int pep_accept_conn(struct sock *sk, struct sk_buff *skb)
+{
+	static const u8 data[20] =3D {
+		PAD, PAD, PAD, 2 /* sub-blocks */,
+		PN_PIPE_SB_REQUIRED_FC_TX, pep_sb_size(5), 3, PAD,
+			PN_MULTI_CREDIT_FLOW_CONTROL,
+			PN_ONE_CREDIT_FLOW_CONTROL,
+			PN_LEGACY_FLOW_CONTROL,
+			PAD,
+		PN_PIPE_SB_PREFERRED_FC_RX, pep_sb_size(5), 3, PAD,
+			PN_MULTI_CREDIT_FLOW_CONTROL,
+			PN_ONE_CREDIT_FLOW_CONTROL,
+			PN_LEGACY_FLOW_CONTROL,
+			PAD,
+	};
+
+	might_sleep();
+	return pep_reply(sk, skb, PN_PIPE_NO_ERROR, data, sizeof(data),
+				GFP_KERNEL);
+}
+
+static int pep_reject_conn(struct sock *sk, struct sk_buff *skb, u8 co=
de)
+{
+	static const u8 data[4] =3D { PAD, PAD, PAD, 0 /* sub-blocks */ };
+	WARN_ON(code =3D=3D PN_PIPE_NO_ERROR);
+	return pep_reply(sk, skb, code, data, sizeof(data), GFP_ATOMIC);
+}
+
+/* Control requests are not sent by the pipe service and have a specif=
ic
+ * message format. */
+static int pep_ctrlreq_error(struct sock *sk, struct sk_buff *oskb, u8=
 code)
+{
+	const struct pnpipehdr *oph =3D pnp_hdr(oskb);
+	struct sk_buff *skb;
+	struct pnpipehdr *ph;
+	struct sockaddr_pn dst;
+
+	skb =3D alloc_skb(MAX_PNPIPE_HEADER + 4, GFP_ATOMIC);
+	if (!skb)
+		return -ENOMEM;
+	skb_set_owner_w(skb, sk);
+
+	skb_reserve(skb, MAX_PHONET_HEADER);
+	ph =3D (struct pnpipehdr *)skb_put(skb, sizeof(*ph) + 4);
+
+	ph->utid =3D oph->utid;
+	ph->message_id =3D PNS_PEP_CTRL_RESP;
+	ph->pipe_handle =3D oph->pipe_handle;
+	ph->data[0] =3D oph->data[1]; /* CTRL id */
+	ph->data[1] =3D oph->data[0]; /* PEP type */
+	ph->data[2] =3D code; /* error code, at an usual offset */
+	ph->data[3] =3D PAD;
+	ph->data[4] =3D PAD;
+
+	pn_skb_get_src_sockaddr(oskb, &dst);
+	return pn_skb_send(sk, skb, &dst);
+}
+
+static int pipe_snd_status(struct sock *sk, u8 type, u8 status, gfp_t =
priority)
+{
+	struct pep_sock *pn =3D pep_sk(sk);
+	struct pnpipehdr *ph;
+	struct sk_buff *skb;
+
+	skb =3D alloc_skb(MAX_PNPIPE_HEADER + 4, priority);
+	if (!skb)
+		return -ENOMEM;
+	skb_set_owner_w(skb, sk);
+
+	skb_reserve(skb, MAX_PNPIPE_HEADER + 4);
+	ph =3D (void *)__skb_push(skb, sizeof(*ph) + 4);
+	ph->utid =3D 0;
+	ph->message_id =3D PNS_PEP_STATUS_IND;
+	ph->pipe_handle =3D pn->pipe_handle;
+	ph->data[0] =3D PN_PEP_TYPE_COMMON;
+	ph->data[1] =3D type;
+	ph->data[2] =3D PAD;
+	ph->data[3] =3D PAD;
+	ph->data[4] =3D status;
+
+	return pn_skb_send(sk, skb, &pipe_srv);
+}
+
+/* Send our RX flow control information to the sender.
+ * Socket must be locked. */
+static void pipe_grant_credits(struct sock *sk)
+{
+	struct pep_sock *pn =3D pep_sk(sk);
+
+	BUG_ON(sk->sk_state !=3D TCP_ESTABLISHED);
+
+	switch (pn->rx_fc) {
+	case PN_LEGACY_FLOW_CONTROL: /* TODO */
+		break;
+	case PN_ONE_CREDIT_FLOW_CONTROL:
+		pipe_snd_status(sk, PN_PEP_IND_FLOW_CONTROL,
+				PEP_IND_READY, GFP_ATOMIC);
+		pn->rx_credits =3D 1;
+		break;
+	case PN_MULTI_CREDIT_FLOW_CONTROL:
+		if ((pn->rx_credits + CREDITS_THR) > CREDITS_MAX)
+			break;
+		if (pipe_snd_status(sk, PN_PEP_IND_ID_MCFC_GRANT_CREDITS,
+					CREDITS_MAX - pn->rx_credits,
+					GFP_ATOMIC) =3D=3D 0)
+			pn->rx_credits =3D CREDITS_MAX;
+		break;
+	}
+}
+
+static int pipe_rcv_status(struct sock *sk, struct sk_buff *skb)
+{
+	struct pep_sock *pn =3D pep_sk(sk);
+	struct pnpipehdr *hdr =3D pnp_hdr(skb);
+
+	if (!pskb_may_pull(skb, sizeof(*hdr) + 4))
+		return -EINVAL;
+
+	if (hdr->data[0] !=3D PN_PEP_TYPE_COMMON) {
+		if (net_ratelimit())
+			printk(KERN_DEBUG"Phonet unknown PEP type: %u\n",
+				(unsigned)hdr->data[0]);
+		return -EOPNOTSUPP;
+	}
+
+	switch (hdr->data[1]) {
+	case PN_PEP_IND_FLOW_CONTROL:
+		switch (pn->tx_fc) {
+		case PN_LEGACY_FLOW_CONTROL:
+			switch (hdr->data[4]) {
+			case PEP_IND_BUSY:
+				pn->tx_credits =3D 0;
+				break;
+			case PEP_IND_READY:
+				pn->tx_credits =3D 1;
+				break;
+			}
+			break;
+		case PN_ONE_CREDIT_FLOW_CONTROL:
+			if (hdr->data[4] =3D=3D PEP_IND_READY)
+				pn->tx_credits =3D 1;
+			break;
+		}
+		break;
+
+	case PN_PEP_IND_ID_MCFC_GRANT_CREDITS:
+		if (pn->tx_fc !=3D PN_MULTI_CREDIT_FLOW_CONTROL)
+			break;
+		if (pn->tx_credits + hdr->data[4] > 0xff)
+			pn->tx_credits =3D 0xff;
+		else
+			pn->tx_credits +=3D hdr->data[4];
+		break;
+
+	default:
+		if (net_ratelimit())
+			printk(KERN_DEBUG"Phonet unknown PEP indication: %u\n",
+				(unsigned)hdr->data[1]);
+		return -EOPNOTSUPP;
+	}
+	if (pn->tx_credits)
+		sk->sk_write_space(sk);
+	return 0;
+}
+
+static int pipe_rcv_created(struct sock *sk, struct sk_buff *skb)
+{
+	struct pep_sock *pn =3D pep_sk(sk);
+	struct pnpipehdr *hdr =3D pnp_hdr(skb);
+	u8 n_sb =3D hdr->data[0];
+
+	pn->rx_fc =3D pn->tx_fc =3D PN_LEGACY_FLOW_CONTROL;
+	__skb_pull(skb, sizeof(*hdr));
+	while (n_sb > 0) {
+		u8 type, buf[2], len =3D sizeof(buf);
+		u8 *data =3D pep_get_sb(skb, &type, &len, buf);
+
+		if (data =3D=3D NULL)
+			return -EINVAL;
+		switch (type) {
+		case PN_PIPE_SB_NEGOTIATED_FC:
+			if (len < 2 || (data[0] | data[1]) > 3)
+				break;
+			pn->tx_fc =3D data[0] & 3;
+			pn->rx_fc =3D data[1] & 3;
+			break;
+		}
+		n_sb--;
+	}
+	return 0;
+}
+
+/* Queue an skb to a connected sock.
+ * Socket lock must be held. */
+static int pipe_do_rcv(struct sock *sk, struct sk_buff *skb)
+{
+	struct pep_sock *pn =3D pep_sk(sk);
+	struct pnpipehdr *hdr =3D pnp_hdr(skb);
+	int err =3D 0;
+
+	BUG_ON(sk->sk_state =3D=3D TCP_CLOSE_WAIT);
+
+	switch (hdr->message_id) {
+	case PNS_PEP_CONNECT_REQ:
+		pep_reject_conn(sk, skb, PN_PIPE_ERR_PEP_IN_USE);
+		break;
+
+	case PNS_PEP_DISCONNECT_REQ:
+		pep_reply(sk, skb, PN_PIPE_NO_ERROR, NULL, 0, GFP_ATOMIC);
+		sk->sk_state =3D TCP_CLOSE_WAIT;
+		if (!sock_flag(sk, SOCK_DEAD))
+			sk->sk_state_change(sk);
+		break;
+
+	case PNS_PEP_ENABLE_REQ:
+		/* Wait for PNS_PIPE_(ENABLED|REDIRECTED)_IND */
+		pep_reply(sk, skb, PN_PIPE_NO_ERROR, NULL, 0, GFP_ATOMIC);
+		break;
+
+	case PNS_PEP_RESET_REQ:
+		switch (hdr->state_after_reset) {
+		case PN_PIPE_DISABLE:
+			pn->init_enable =3D 0;
+			break;
+		case PN_PIPE_ENABLE:
+			pn->init_enable =3D 1;
+			break;
+		default: /* not allowed to send an error here!? */
+			err =3D -EINVAL;
+			goto out;
+		}
+		/* fall through */
+	case PNS_PEP_DISABLE_REQ:
+		pn->tx_credits =3D 0;
+		pep_reply(sk, skb, PN_PIPE_NO_ERROR, NULL, 0, GFP_ATOMIC);
+		break;
+
+	case PNS_PEP_CTRL_REQ:
+		/* TODO */
+		pep_ctrlreq_error(sk, skb, PN_PIPE_NO_ERROR);
+		break;
+
+	case PNS_PIPE_DATA:
+		__skb_pull(skb, 3); /* Pipe data header */
+		if (!pn_flow_safe(pn->rx_fc)) {
+			err =3D sock_queue_rcv_skb(sk, skb);
+			if (!err)
+				return 0;
+			break;
+		}
+
+		if (pn->rx_credits =3D=3D 0) {
+			err =3D -ENOBUFS;
+			break;
+		}
+		pn->rx_credits--;
+		skb->dev =3D NULL;
+		skb_set_owner_r(skb, sk);
+		err =3D skb->len;
+		skb_queue_tail(&sk->sk_receive_queue, skb);
+		if (!sock_flag(sk, SOCK_DEAD))
+			sk->sk_data_ready(sk, err);
+		return 0;
+
+	case PNS_PEP_STATUS_IND:
+		pipe_rcv_status(sk, skb);
+		break;
+
+	case PNS_PIPE_REDIRECTED_IND:
+		err =3D pipe_rcv_created(sk, skb);
+		break;
+
+	case PNS_PIPE_CREATED_IND:
+		err =3D pipe_rcv_created(sk, skb);
+		if (err)
+			break;
+		/* fall through */
+	case PNS_PIPE_RESET_IND:
+		if (!pn->init_enable)
+			break;
+		/* fall through */
+	case PNS_PIPE_ENABLED_IND:
+		if (!pn_flow_safe(pn->tx_fc)) {
+			pn->tx_credits =3D 1;
+			sk->sk_write_space(sk);
+		}
+		if (sk->sk_state =3D=3D TCP_ESTABLISHED)
+			break; /* Nothing to do */
+		sk->sk_state =3D TCP_ESTABLISHED;
+		pipe_grant_credits(sk);
+		break;
+
+	case PNS_PIPE_DISABLED_IND:
+		sk->sk_state =3D TCP_SYN_RECV;
+		pn->rx_credits =3D 0;
+		break;
+
+	default:
+		if (net_ratelimit())
+			printk(KERN_DEBUG"Phonet unknown PEP message: %u\n",
+				hdr->message_id);
+		err =3D -EINVAL;
+	}
+out:
+	kfree_skb(skb);
+	return err;
+}
+
+/* Destroy connected sock. */
+static void pipe_destruct(struct sock *sk)
+{
+	skb_queue_purge(&sk->sk_receive_queue);
+}
+
+static int pep_connreq_rcv(struct sock *sk, struct sk_buff *skb)
+{
+	struct sock *newsk;
+	struct pep_sock *newpn, *pn =3D pep_sk(sk);
+	struct pnpipehdr *hdr;
+	struct sockaddr_pn dst;
+	u16 peer_type;
+	u8 pipe_handle, enabled, n_sb;
+
+	if (!pskb_pull(skb, sizeof(*hdr) + 4))
+		return -EINVAL;
+
+	hdr =3D pnp_hdr(skb);
+	pipe_handle =3D hdr->pipe_handle;
+	switch (hdr->state_after_connect) {
+	case PN_PIPE_DISABLE:
+		enabled =3D 0;
+		break;
+	case PN_PIPE_ENABLE:
+		enabled =3D 1;
+		break;
+	default:
+		pep_reject_conn(sk, skb, PN_PIPE_ERR_INVALID_PARAM);
+		return -EINVAL;
+	}
+	peer_type =3D hdr->other_pep_type << 8;
+
+	if (unlikely(sk->sk_state !=3D TCP_LISTEN) || sk_acceptq_is_full(sk))=
 {
+		pep_reject_conn(sk, skb, PN_PIPE_ERR_PEP_IN_USE);
+		return -ENOBUFS;
+	}
+
+	/* Parse sub-blocks (options) */
+	n_sb =3D hdr->data[4];
+	while (n_sb > 0) {
+		u8 type, buf[1], len =3D sizeof(buf);
+		const u8 *data =3D pep_get_sb(skb, &type, &len, buf);
+
+		if (data =3D=3D NULL)
+			return -EINVAL;
+		switch (type) {
+		case PN_PIPE_SB_CONNECT_REQ_PEP_SUB_TYPE:
+			if (len < 1)
+				return -EINVAL;
+			peer_type =3D (peer_type & 0xff00) | data[0];
+			break;
+		}
+		n_sb--;
+	}
+
+	skb =3D skb_clone(skb, GFP_ATOMIC);
+	if (!skb)
+		return -ENOMEM;
+
+	/* Create a new to-be-accepted sock */
+	newsk =3D sk_alloc(sock_net(sk), PF_PHONET, GFP_ATOMIC, sk->sk_prot);
+	if (!newsk) {
+		kfree_skb(skb);
+		return -ENOMEM;
+	}
+	sock_init_data(NULL, newsk);
+	newsk->sk_state =3D TCP_SYN_RECV;
+	newsk->sk_backlog_rcv =3D pipe_do_rcv;
+	newsk->sk_protocol =3D sk->sk_protocol;
+	newsk->sk_destruct =3D pipe_destruct;
+
+	newpn =3D pep_sk(newsk);
+	pn_skb_get_dst_sockaddr(skb, &dst);
+	newpn->pn_sk.sobject =3D pn_sockaddr_get_object(&dst);
+	newpn->pn_sk.resource =3D pn->pn_sk.resource;
+	newpn->pipe_handle =3D pipe_handle;
+	newpn->peer_type =3D peer_type;
+	newpn->rx_credits =3D newpn->tx_credits =3D 0;
+	newpn->rx_fc =3D newpn->tx_fc =3D PN_LEGACY_FLOW_CONTROL;
+	newpn->init_enable =3D enabled;
+
+	BUG_ON(!skb_queue_empty(&newsk->sk_receive_queue));
+	skb_queue_head(&newsk->sk_receive_queue, skb);
+	if (!sock_flag(sk, SOCK_DEAD))
+		sk->sk_data_ready(sk, 0);
+
+	sk_acceptq_added(sk);
+	sk_add_node(newsk, &pn->ackq);
+	return 0;
+}
+
+static struct sock *pep_find_pipe(const struct hlist_head *hlist,
+					const struct sockaddr_pn *dst,
+					u8 pipe_handle)
+{
+	struct hlist_node *node;
+	struct sock *sknode;
+	u16 dobj =3D pn_sockaddr_get_object(dst);
+
+	sk_for_each(sknode, node, hlist) {
+		struct pep_sock *pnnode =3D pep_sk(sknode);
+
+		/* Ports match, but addresses might not: */
+		if (pnnode->pn_sk.sobject !=3D dobj)
+			continue;
+		if (pnnode->pipe_handle !=3D pipe_handle)
+			continue;
+		if (sknode->sk_state =3D=3D TCP_CLOSE_WAIT)
+			continue;
+
+		sock_hold(sknode);
+		return sknode;
+	}
+	return NULL;
+}
+
+/*
+ * Deliver an skb to a listening sock.
+ * Socket lock must be held.
+ * We then queue the skb to the right connected sock (if any).
+ */
+static int pep_do_rcv(struct sock *sk, struct sk_buff *skb)
+{
+	struct pep_sock *pn =3D pep_sk(sk);
+	struct sock *sknode;
+	struct pnpipehdr *hdr =3D pnp_hdr(skb);
+	struct sockaddr_pn dst;
+	int err =3D NET_RX_SUCCESS;
+	u8 pipe_handle;
+
+	if (!pskb_may_pull(skb, sizeof(*hdr)))
+		goto drop;
+
+	hdr =3D pnp_hdr(skb);
+	pipe_handle =3D hdr->pipe_handle;
+	if (pipe_handle =3D=3D PN_PIPE_INVALID_HANDLE)
+		goto drop;
+
+	pn_skb_get_dst_sockaddr(skb, &dst);
+
+	/* Look for an existing pipe handle */
+	sknode =3D pep_find_pipe(&pn->hlist, &dst, pipe_handle);
+	if (sknode)
+		return sk_receive_skb(sknode, skb, 1);
+
+	/* Look for a pipe handle pending accept */
+	sknode =3D pep_find_pipe(&pn->ackq, &dst, pipe_handle);
+	if (sknode) {
+		sock_put(sknode);
+		if (net_ratelimit())
+			printk(KERN_WARNING"Phonet unconnected PEP ignored");
+		err =3D NET_RX_DROP;
+		goto drop;
+	}
+
+	switch (hdr->message_id) {
+	case PNS_PEP_CONNECT_REQ:
+		err =3D pep_connreq_rcv(sk, skb);
+		break;
+
+	case PNS_PEP_DISCONNECT_REQ:
+		pep_reply(sk, skb, PN_PIPE_NO_ERROR, NULL, 0, GFP_ATOMIC);
+		break;
+
+	case PNS_PEP_CTRL_REQ:
+		pep_ctrlreq_error(sk, skb, PN_PIPE_INVALID_HANDLE);
+		break;
+
+	case PNS_PEP_RESET_REQ:
+	case PNS_PEP_ENABLE_REQ:
+	case PNS_PEP_DISABLE_REQ:
+		/* invalid handle is not even allowed here! */
+	default:
+		err =3D NET_RX_DROP;
+	}
+drop:
+	kfree_skb(skb);
+	return err;
+}
+
+/* associated socket ceases to exist */
+static void pep_sock_close(struct sock *sk, long timeout)
+{
+	struct pep_sock *pn =3D pep_sk(sk);
+
+	sk_common_release(sk);
+
+	lock_sock(sk);
+	if (sk->sk_state =3D=3D TCP_LISTEN) {
+		/* Destroy the listen queue */
+		struct sock *sknode;
+		struct hlist_node *p, *n;
+
+		sk_for_each_safe(sknode, p, n, &pn->ackq)
+			sk_del_node_init(sknode);
+		sk->sk_state =3D TCP_CLOSE;
+	}
+	release_sock(sk);
+}
+
+static int pep_wait_connreq(struct sock *sk, int noblock)
+{
+	struct task_struct *tsk =3D current;
+	struct pep_sock *pn =3D pep_sk(sk);
+	long timeo =3D sock_rcvtimeo(sk, noblock);
+
+	for (;;) {
+		DEFINE_WAIT(wait);
+
+		if (sk->sk_state !=3D TCP_LISTEN)
+			return -EINVAL;
+		if (!hlist_empty(&pn->ackq))
+			break;
+		if (!timeo)
+			return -EWOULDBLOCK;
+		if (signal_pending(tsk))
+			return sock_intr_errno(timeo);
+
+		prepare_to_wait_exclusive(&sk->sk_socket->wait, &wait,
+						TASK_INTERRUPTIBLE);
+		release_sock(sk);
+		timeo =3D schedule_timeout(timeo);
+		lock_sock(sk);
+		finish_wait(&sk->sk_socket->wait, &wait);
+	}
+
+	return 0;
+}
+
+static struct sock *pep_sock_accept(struct sock *sk, int flags, int *e=
rrp)
+{
+	struct pep_sock *pn =3D pep_sk(sk);
+	struct sock *newsk =3D NULL;
+	struct sk_buff *oskb;
+	int err;
+
+	lock_sock(sk);
+	err =3D pep_wait_connreq(sk, flags & O_NONBLOCK);
+	if (err)
+		goto out;
+
+	newsk =3D __sk_head(&pn->ackq);
+
+	oskb =3D skb_dequeue(&newsk->sk_receive_queue);
+	err =3D pep_accept_conn(newsk, oskb);
+	if (err) {
+		skb_queue_head(&newsk->sk_receive_queue, oskb);
+		newsk =3D NULL;
+		goto out;
+	}
+
+	sock_hold(sk);
+	pep_sk(newsk)->listener =3D sk;
+
+	sock_hold(newsk);
+	sk_del_node_init(newsk);
+	sk_acceptq_removed(sk);
+	sk_add_node(newsk, &pn->hlist);
+	__sock_put(newsk);
+
+out:
+	release_sock(sk);
+	*errp =3D err;
+	return newsk;
+}
+
+static int pep_ioctl(struct sock *sk, int cmd, unsigned long arg)
+{
+	int answ;
+
+	switch (cmd) {
+	case SIOCINQ:
+		if (sk->sk_state =3D=3D TCP_LISTEN)
+			return -EINVAL;
+
+		lock_sock(sk);
+		if (!skb_queue_empty(&sk->sk_receive_queue))
+			answ =3D skb_peek(&sk->sk_receive_queue)->len;
+		else
+			answ =3D 0;
+		release_sock(sk);
+		return put_user(answ, (int __user *)arg);
+	}
+
+	return -ENOIOCTLCMD;
+}
+
+static int pep_init(struct sock *sk)
+{
+	struct pep_sock *pn =3D pep_sk(sk);
+
+	INIT_HLIST_HEAD(&pn->ackq);
+	INIT_HLIST_HEAD(&pn->hlist);
+	pn->pipe_handle =3D PN_PIPE_INVALID_HANDLE;
+	return 0;
+}
+
+static int pep_sendmsg(struct kiocb *iocb, struct sock *sk,
+			struct msghdr *msg, size_t len)
+{
+	struct pep_sock *pn =3D pep_sk(sk);
+	struct sk_buff *skb =3D NULL;
+	struct pnpipehdr *ph;
+	long timeo;
+	int flags =3D msg->msg_flags;
+	int err, done;
+
+	if (msg->msg_flags & MSG_OOB || !(msg->msg_flags & MSG_EOR))
+		return -EOPNOTSUPP;
+
+	lock_sock(sk);
+	timeo =3D sock_sndtimeo(sk, flags & MSG_DONTWAIT);
+	if ((1 << sk->sk_state) & (TCPF_LISTEN|TCPF_CLOSE)) {
+		err =3D -ENOTCONN;
+		goto out;
+	}
+	if (sk->sk_state !=3D TCP_ESTABLISHED) {
+		/* Wait until the pipe gets to enabled state */
+disabled:
+		err =3D sk_stream_wait_connect(sk, &timeo);
+		if (err)
+			goto out;
+
+		if (sk->sk_state =3D=3D TCP_CLOSE_WAIT) {
+			err =3D -ECONNRESET;
+			goto out;
+		}
+	}
+	BUG_ON(sk->sk_state !=3D TCP_ESTABLISHED);
+
+	/* Wait until flow control allows TX */
+	done =3D pn->tx_credits > 0;
+	while (!done) {
+		DEFINE_WAIT(wait);
+
+		if (!timeo) {
+			err =3D -EAGAIN;
+			goto out;
+		}
+		if (signal_pending(current)) {
+			err =3D sock_intr_errno(timeo);
+			goto out;
+		}
+
+		prepare_to_wait(&sk->sk_socket->wait, &wait,
+				TASK_INTERRUPTIBLE);
+		done =3D sk_wait_event(sk, &timeo, pn->tx_credits > 0);
+		finish_wait(&sk->sk_socket->wait, &wait);
+
+		if (sk->sk_state !=3D TCP_ESTABLISHED)
+			goto disabled;
+	}
+
+	if (!skb) {
+		skb =3D sock_alloc_send_skb(sk, MAX_PNPIPE_HEADER + len,
+						flags & MSG_DONTWAIT, &err);
+		if (skb =3D=3D NULL)
+			goto out;
+		skb_reserve(skb, MAX_PHONET_HEADER + 3);
+
+		if (sk->sk_state !=3D TCP_ESTABLISHED || !pn->tx_credits)
+			goto disabled; /* sock_alloc_send_skb might sleep */
+	}
+
+	err =3D memcpy_fromiovec(skb_put(skb, len), msg->msg_iov, len);
+	if (err < 0)
+		goto out;
+
+	ph =3D (struct pnpipehdr *)skb_push(skb, 3);
+	ph->utid =3D 0;
+	ph->message_id =3D PNS_PIPE_DATA;
+	ph->pipe_handle =3D pn->pipe_handle;
+	if (pn_flow_safe(pn->tx_fc)) /* credit-based flow control */
+		pn->tx_credits--;
+
+	err =3D pn_skb_send(sk, skb, &pipe_srv);
+	if (err >=3D 0)
+		err =3D len; /* success! */
+	skb =3D NULL;
+out:
+	release_sock(sk);
+	if (skb)
+		kfree_skb(skb);
+	return err;
+}
+
+static int pep_recvmsg(struct kiocb *iocb, struct sock *sk,
+			struct msghdr *msg, size_t len, int noblock,
+			int flags, int *addr_len)
+{
+	struct sk_buff *skb;
+	int err;
+
+	if (unlikely(flags & MSG_OOB))
+		return -EOPNOTSUPP;
+	if (unlikely(1 << sk->sk_state & (TCPF_LISTEN | TCPF_CLOSE)))
+		return -ENOTCONN;
+
+	skb =3D skb_recv_datagram(sk, flags, noblock, &err);
+	lock_sock(sk);
+	if (skb =3D=3D NULL) {
+		if (err =3D=3D -ENOTCONN && sk->sk_state =3D=3D TCP_CLOSE_WAIT)
+			err =3D -ECONNRESET;
+		release_sock(sk);
+		return err;
+	}
+
+	if (sk->sk_state =3D=3D TCP_ESTABLISHED)
+		pipe_grant_credits(sk);
+	release_sock(sk);
+
+	msg->msg_flags |=3D MSG_EOR;
+
+	if (skb->len > len)
+		msg->msg_flags |=3D MSG_TRUNC;
+	else
+		len =3D skb->len;
+
+	err =3D skb_copy_datagram_iovec(skb, 0, msg->msg_iov, len);
+	if (!err)
+		err =3D (flags & MSG_TRUNC) ? skb->len : len;
+
+	skb_free_datagram(sk, skb);
+	return err;
+}
+
+static void pep_sock_unhash(struct sock *sk)
+{
+	struct pep_sock *pn =3D pep_sk(sk);
+	struct sock *skparent =3D NULL;
+
+	lock_sock(sk);
+	if ((1 << sk->sk_state) & ~(TCPF_CLOSE|TCPF_LISTEN)) {
+		skparent =3D pn->listener;
+		sk_del_node_init(sk);
+		release_sock(sk);
+
+		sk =3D skparent;
+		pn =3D pep_sk(skparent);
+		lock_sock(sk);
+	}
+	/* Unhash a listening sock only when it is closed
+	 * and all of its active connected pipes are closed. */
+	if (hlist_empty(&pn->hlist))
+		pn_sock_unhash(&pn->pn_sk.sk);
+	release_sock(sk);
+
+	if (skparent)
+		sock_put(skparent);
+}
+
+static struct proto pep_proto =3D {
+	.close		=3D pep_sock_close,
+	.accept		=3D pep_sock_accept,
+	.ioctl		=3D pep_ioctl,
+	.init		=3D pep_init,
+	.sendmsg	=3D pep_sendmsg,
+	.recvmsg	=3D pep_recvmsg,
+	.backlog_rcv	=3D pep_do_rcv,
+	.hash		=3D pn_sock_hash,
+	.unhash		=3D pep_sock_unhash,
+	.get_port	=3D pn_sock_get_port,
+	.obj_size	=3D sizeof(struct pep_sock),
+	.owner		=3D THIS_MODULE,
+	.name		=3D "PNPIPE",
+};
+
+static struct phonet_protocol pep_pn_proto =3D {
+	.ops		=3D &phonet_stream_ops,
+	.prot		=3D &pep_proto,
+	.sock_type	=3D SOCK_SEQPACKET,
+};
+
+static int __init pep_register(void)
+{
+	return phonet_proto_register(PN_PROTO_PIPE, &pep_pn_proto);
+}
+
+static void __exit pep_unregister(void)
+{
+	phonet_proto_unregister(PN_PROTO_PIPE, &pep_pn_proto);
+}
+
+module_init(pep_register);
+module_exit(pep_unregister);
+MODULE_AUTHOR("Remi Denis-Courmont, Nokia");
+MODULE_DESCRIPTION("Phonet pipe protocol");
+MODULE_LICENSE("GPL");
--=20
1.5.4.3

