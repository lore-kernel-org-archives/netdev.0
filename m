From: Kumar A Sanghvi <kumar.sanghvi@stericsson.com>
Subject: [PATCH v2 1/2] Phonet: Implement Pipe Controller to support Nokia Slim Modems
Date: Mon, 27 Sep 2010 10:37:59 +0530
Message-ID: <1285564079-23066-1-git-send-email-kumar.sanghvi@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <STEricsson_nomadik_linux@list.st.com>,
	<sudeep.divakaran@stericsson.com>,
	<gulshan.karmani@stericsson.com>,
	Kumar Sanghvi <kumar.sanghvi@stericsson.com>,
	Linus Walleij <linus.walleij@stericsson.com>
To: <remi.denis-courmont@nokia.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog114.obsmtp.com ([207.126.144.137]:34167 "EHLO
	eu1sys200aog114.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750841Ab0I0FIa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Sep 2010 01:08:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kumar Sanghvi <kumar.sanghvi@stericsson.com>

Phonet stack assumes the presence of Pipe Controller, either in Modem or
on Application Processing Engine user-space for the Pipe data.
Nokia Slim Modems like WG2.5 used in ST-Ericsson U8500 platform do not
implement Pipe controller in them.
This patch adds Pipe Controller implemenation to Phonet stack to support
Pipe data over Phonet stack for Nokia Slim Modems.

Signed-off-by: Kumar Sanghvi <kumar.sanghvi@stericsson.com>
Acked-by: Linus Walleij <linus.walleij@stericsson.com>
---
Changes:

 -v2: Correction for header retrieving after pskb_may_pull

 include/linux/phonet.h   |    5 +
 include/net/phonet/pep.h |   21 +++
 net/phonet/Kconfig       |   11 ++
 net/phonet/pep.c         |  448 +++++++++++++++++++++++++++++++++++++++++++++-
 4 files changed, 479 insertions(+), 6 deletions(-)

diff --git a/include/linux/phonet.h b/include/linux/phonet.h
index 85e14a8..96f5625 100644
--- a/include/linux/phonet.h
+++ b/include/linux/phonet.h
@@ -36,6 +36,11 @@
 /* Socket options for SOL_PNPIPE level */
 #define PNPIPE_ENCAP		1
 #define PNPIPE_IFINDEX		2
+#define PNPIPE_CREATE           3
+#define PNPIPE_ENABLE           4
+#define PNPIPE_DISABLE          5
+#define PNPIPE_DESTROY          6
+#define PNPIPE_INQ              7
 
 #define PNADDR_ANY		0
 #define PNADDR_BROADCAST	0xFC
diff --git a/include/net/phonet/pep.h b/include/net/phonet/pep.h
index 37f23dc..def6cfa 100644
--- a/include/net/phonet/pep.h
+++ b/include/net/phonet/pep.h
@@ -45,6 +45,10 @@ struct pep_sock {
 	u8			tx_fc;	/* TX flow control */
 	u8			init_enable;	/* auto-enable at creation */
 	u8			aligned;
+#ifdef CONFIG_PHONET_PIPECTRLR
+	u16                     remote_pep;
+	u8                      pipe_state;
+#endif
 };
 
 static inline struct pep_sock *pep_sk(struct sock *sk)
@@ -165,4 +169,21 @@ enum {
 	PEP_IND_READY,
 };
 
+#ifdef CONFIG_PHONET_PIPECTRLR
+#define PNS_PEP_CONNECT_UTID           0x02
+#define PNS_PIPE_CREATED_IND_UTID      0x04
+#define PNS_PIPE_ENABLE_UTID           0x0A
+#define PNS_PIPE_ENABLED_IND_UTID      0x0C
+#define PNS_PIPE_DISABLE_UTID          0x0F
+#define PNS_PIPE_DISABLED_IND_UTID     0x11
+#define PNS_PEP_DISCONNECT_UTID        0x06
+
+/* Used for tracking state of a pipe */
+enum {
+	PIPE_IDLE,
+	PIPE_DISABLED,
+	PIPE_ENABLED,
+};
+#endif /* CONFIG_PHONET_PIPECTRLR */
+
 #endif
diff --git a/net/phonet/Kconfig b/net/phonet/Kconfig
index 6ec7d55..901956a 100644
--- a/net/phonet/Kconfig
+++ b/net/phonet/Kconfig
@@ -14,3 +14,14 @@ config PHONET
 
 	  To compile this driver as a module, choose M here: the module
 	  will be called phonet. If unsure, say N.
+
+config PHONET_PIPECTRLR
+	bool "Phonet Pipe Controller"
+	depends on PHONET
+	default N
+	help
+	  The Pipe Controller implementation in Phonet stack to support Pipe
+	  data with Nokia Slim modems like WG2.5 used on ST-Ericsson U8500
+	  platform.
+
+	  If unsure, say N.
diff --git a/net/phonet/pep.c b/net/phonet/pep.c
index d0e7eb2..7bf23cf 100644
--- a/net/phonet/pep.c
+++ b/net/phonet/pep.c
@@ -88,6 +88,15 @@ static int pep_reply(struct sock *sk, struct sk_buff *oskb,
 	const struct pnpipehdr *oph = pnp_hdr(oskb);
 	struct pnpipehdr *ph;
 	struct sk_buff *skb;
+#ifdef CONFIG_PHONET_PIPECTRLR
+	const struct phonethdr *hdr = pn_hdr(oskb);
+	struct sockaddr_pn spn = {
+		.spn_family = AF_PHONET,
+		.spn_resource = 0xD9,
+		.spn_dev = hdr->pn_sdev,
+		.spn_obj = hdr->pn_sobj,
+	};
+#endif
 
 	skb = alloc_skb(MAX_PNPIPE_HEADER + len, priority);
 	if (!skb)
@@ -105,10 +114,271 @@ static int pep_reply(struct sock *sk, struct sk_buff *oskb,
 	ph->pipe_handle = oph->pipe_handle;
 	ph->error_code = code;
 
+#ifdef CONFIG_PHONET_PIPECTRLR
+	return pn_skb_send(sk, skb, &spn);
+#else
 	return pn_skb_send(sk, skb, &pipe_srv);
+#endif
 }
 
 #define PAD 0x00
+
+#ifdef CONFIG_PHONET_PIPECTRLR
+static u8 pipe_negotiate_fc(u8 *host_fc, u8 *remote_fc, int len)
+{
+	int i, j;
+	u8 base_fc, final_fc;
+
+	for (i = 0; i < len; i++) {
+		base_fc = host_fc[i];
+		for (j = 0; j < len; j++) {
+			if (remote_fc[j] == base_fc) {
+				final_fc = base_fc;
+				goto done;
+			}
+		}
+	}
+	return -EINVAL;
+
+done:
+	return final_fc;
+
+}
+
+static int pipe_get_flow_info(struct sock *sk, struct sk_buff *skb,
+		u8 *pref_rx_fc, u8 *req_tx_fc)
+{
+	struct pnpipehdr *hdr;
+	u8 n_sb;
+
+	if (!pskb_may_pull(skb, sizeof(*hdr) + 4))
+		return -EINVAL;
+
+	hdr = pnp_hdr(skb);
+	n_sb = hdr->data[4];
+
+	__skb_pull(skb, sizeof(*hdr) + 4);
+	while (n_sb > 0) {
+		u8 type, buf[3], len = sizeof(buf);
+		u8 *data = pep_get_sb(skb, &type, &len, buf);
+
+		if (data == NULL)
+			return -EINVAL;
+
+		switch (type) {
+		case PN_PIPE_SB_REQUIRED_FC_TX:
+			if (len < 3 || (data[2] | data[3] | data[4]) > 3)
+				break;
+			req_tx_fc[0] = data[2];
+			req_tx_fc[1] = data[3];
+			req_tx_fc[2] = data[4];
+			break;
+
+		case PN_PIPE_SB_PREFERRED_FC_RX:
+			if (len < 3 || (data[2] | data[3] | data[4]) > 3)
+				break;
+			pref_rx_fc[0] = data[2];
+			pref_rx_fc[1] = data[3];
+			pref_rx_fc[2] = data[4];
+			break;
+
+		}
+		n_sb--;
+	}
+	return 0;
+}
+
+static int pipe_handler_send_req(struct sock *sk, u16 dobj, u8 utid,
+		u8 msg_id, u8 p_handle, gfp_t priority)
+{
+	int len;
+	struct pnpipehdr *ph;
+	struct sk_buff *skb;
+	struct sockaddr_pn spn = {
+		.spn_family = AF_PHONET,
+		.spn_resource = 0xD9,
+		.spn_dev = pn_dev(dobj),
+		.spn_obj = pn_obj(dobj),
+	};
+
+	static const u8 data[4] = {
+		PAD, PAD, PAD, PAD,
+	};
+
+	switch (msg_id) {
+	case PNS_PEP_CONNECT_REQ:
+		len = sizeof(data);
+		break;
+
+	case PNS_PEP_DISCONNECT_REQ:
+	case PNS_PEP_ENABLE_REQ:
+	case PNS_PEP_DISABLE_REQ:
+		len = 0;
+		break;
+
+	default:
+		return -EINVAL;
+	}
+
+	skb = alloc_skb(MAX_PNPIPE_HEADER + len, priority);
+	if (!skb)
+		return -ENOMEM;
+	skb_set_owner_w(skb, sk);
+
+	skb_reserve(skb, MAX_PNPIPE_HEADER);
+	if (len) {
+		__skb_put(skb, len);
+		skb_copy_to_linear_data(skb, data, len);
+	}
+	__skb_push(skb, sizeof(*ph));
+	skb_reset_transport_header(skb);
+	ph = pnp_hdr(skb);
+	ph->utid = utid;
+	ph->message_id = msg_id;
+	ph->pipe_handle = p_handle;
+	ph->error_code = PN_PIPE_NO_ERROR;
+
+	return pn_skb_send(sk, skb, &spn);
+}
+
+static int pipe_handler_send_created_ind(struct sock *sk, u16 dobj,
+		u8 utid, u8 p_handle, u8 msg_id, u8 tx_fc, u8 rx_fc)
+{
+	int err_code;
+	struct pnpipehdr *ph;
+	struct sk_buff *skb;
+	struct sockaddr_pn spn = {
+		.spn_family = AF_PHONET,
+		.spn_resource = 0xD9,
+		.spn_dev = pn_dev(dobj),
+		.spn_obj = pn_obj(dobj),
+	};
+
+	static u8 data[4] = {
+		0x03, 0x04,
+	};
+	data[2] = tx_fc;
+	data[3] = rx_fc;
+
+	/*
+	 * actually, below is number of sub-blocks and not error code.
+	 * Pipe_created_ind message format does not have any
+	 * error code field. However, the Phonet stack will always send
+	 * an error code as part of pnpipehdr. So, use that err_code to
+	 * specify the number of sub-blocks.
+	 */
+	err_code = 0x01;
+
+	skb = alloc_skb(MAX_PNPIPE_HEADER + sizeof(data), GFP_ATOMIC);
+	if (!skb)
+		return -ENOMEM;
+	skb_set_owner_w(skb, sk);
+
+	skb_reserve(skb, MAX_PNPIPE_HEADER);
+	__skb_put(skb, sizeof(data));
+	skb_copy_to_linear_data(skb, data, sizeof(data));
+	__skb_push(skb, sizeof(*ph));
+	skb_reset_transport_header(skb);
+	ph = pnp_hdr(skb);
+	ph->utid = utid;
+	ph->message_id = msg_id;
+	ph->pipe_handle = p_handle;
+	ph->error_code = err_code;
+
+	return pn_skb_send(sk, skb, &spn);
+}
+
+static int pipe_handler_send_ind(struct sock *sk, u16 dobj, u8 utid,
+		u8 p_handle, u8 msg_id)
+{
+	int err_code;
+	struct pnpipehdr *ph;
+	struct sk_buff *skb;
+	struct sockaddr_pn spn = {
+		.spn_family = AF_PHONET,
+		.spn_resource = 0xD9,
+		.spn_dev = pn_dev(dobj),
+		.spn_obj = pn_obj(dobj),
+	};
+
+	/*
+	 * actually, below is a filler.
+	 * Pipe_enabled/disabled_ind message format does not have any
+	 * error code field. However, the Phonet stack will always send
+	 * an error code as part of pnpipehdr. So, use that err_code to
+	 * specify the filler value.
+	 */
+	err_code = 0x0;
+
+	skb = alloc_skb(MAX_PNPIPE_HEADER, GFP_ATOMIC);
+	if (!skb)
+		return -ENOMEM;
+	skb_set_owner_w(skb, sk);
+
+	skb_reserve(skb, MAX_PNPIPE_HEADER);
+	__skb_push(skb, sizeof(*ph));
+	skb_reset_transport_header(skb);
+	ph = pnp_hdr(skb);
+	ph->utid = utid;
+	ph->message_id = msg_id;
+	ph->pipe_handle = p_handle;
+	ph->error_code = err_code;
+
+	return pn_skb_send(sk, skb, &spn);
+}
+
+static int pipe_handler_enable_pipe(struct sock *sk, int cmd)
+{
+	int ret;
+	struct pep_sock *pn = pep_sk(sk);
+
+	switch (cmd) {
+	case PNPIPE_ENABLE:
+		ret = pipe_handler_send_req(sk, pn->pn_sk.sobject,
+				PNS_PIPE_ENABLE_UTID, PNS_PEP_ENABLE_REQ,
+				pn->pipe_handle, GFP_ATOMIC);
+		break;
+
+	case PNPIPE_DISABLE:
+		ret = pipe_handler_send_req(sk, pn->pn_sk.sobject,
+				PNS_PIPE_DISABLE_UTID, PNS_PEP_DISABLE_REQ,
+				pn->pipe_handle, GFP_ATOMIC);
+		break;
+
+	default:
+		ret = -EINVAL;
+	}
+
+	return ret;
+}
+
+static int pipe_handler_create_pipe(struct sock *sk, int pipe_handle, int cmd)
+{
+	int ret;
+	struct pep_sock *pn = pep_sk(sk);
+
+	switch (cmd) {
+	case PNPIPE_CREATE:
+		ret = pipe_handler_send_req(sk, pn->pn_sk.sobject,
+				PNS_PEP_CONNECT_UTID, PNS_PEP_CONNECT_REQ,
+				pipe_handle, GFP_ATOMIC);
+		break;
+
+	case PNPIPE_DESTROY:
+		ret = pipe_handler_send_req(sk, pn->remote_pep,
+				PNS_PEP_DISCONNECT_UTID,
+				PNS_PEP_DISCONNECT_REQ,
+				pn->pipe_handle, GFP_ATOMIC);
+		break;
+
+	default:
+		ret = -EINVAL;
+	}
+
+	return ret;
+}
+#endif
+
 static int pep_accept_conn(struct sock *sk, struct sk_buff *skb)
 {
 	static const u8 data[20] = {
@@ -173,6 +443,14 @@ static int pipe_snd_status(struct sock *sk, u8 type, u8 status, gfp_t priority)
 	struct pep_sock *pn = pep_sk(sk);
 	struct pnpipehdr *ph;
 	struct sk_buff *skb;
+#ifdef CONFIG_PHONET_PIPECTRLR
+	struct sockaddr_pn spn = {
+		.spn_family = AF_PHONET,
+		.spn_resource = 0xD9,
+		.spn_dev = pn_dev(pn->remote_pep),
+		.spn_obj = pn_obj(pn->remote_pep),
+	};
+#endif
 
 	skb = alloc_skb(MAX_PNPIPE_HEADER + 4, priority);
 	if (!skb)
@@ -192,7 +470,11 @@ static int pipe_snd_status(struct sock *sk, u8 type, u8 status, gfp_t priority)
 	ph->data[3] = PAD;
 	ph->data[4] = status;
 
+#ifdef CONFIG_PHONET_PIPECTRLR
+	return pn_skb_send(sk, skb, &spn);
+#else
 	return pn_skb_send(sk, skb, &pipe_srv);
+#endif
 }
 
 /* Send our RX flow control information to the sender.
@@ -308,6 +590,12 @@ static int pipe_do_rcv(struct sock *sk, struct sk_buff *skb)
 	struct pnpipehdr *hdr = pnp_hdr(skb);
 	struct sk_buff_head *queue;
 	int err = 0;
+#ifdef CONFIG_PHONET_PIPECTRLR
+	struct phonethdr *ph = pn_hdr(skb);
+	static u8 host_pref_rx_fc[3], host_req_tx_fc[3];
+	u8 remote_pref_rx_fc[3], remote_req_tx_fc[3];
+	u8 negotiated_rx_fc, negotiated_tx_fc;
+#endif
 
 	BUG_ON(sk->sk_state == TCP_CLOSE_WAIT);
 
@@ -316,6 +604,40 @@ static int pipe_do_rcv(struct sock *sk, struct sk_buff *skb)
 		pep_reject_conn(sk, skb, PN_PIPE_ERR_PEP_IN_USE);
 		break;
 
+#ifdef CONFIG_PHONET_PIPECTRLR
+	case PNS_PEP_CONNECT_RESP:
+		if ((ph->pn_sdev == pn_dev(pn->remote_pep)) &&
+				(ph->pn_sobj == pn_obj(pn->remote_pep))) {
+			pipe_get_flow_info(sk, skb, remote_pref_rx_fc,
+					remote_req_tx_fc);
+
+			 negotiated_tx_fc = pipe_negotiate_fc(remote_req_tx_fc,
+					 host_pref_rx_fc,
+					 sizeof(host_pref_rx_fc));
+			 negotiated_rx_fc = pipe_negotiate_fc(host_req_tx_fc,
+					 remote_pref_rx_fc,
+					 sizeof(host_pref_rx_fc));
+
+			pn->pipe_state = PIPE_DISABLED;
+			pipe_handler_send_created_ind(sk, pn->remote_pep,
+					PNS_PIPE_CREATED_IND_UTID,
+					pn->pipe_handle, PNS_PIPE_CREATED_IND,
+					negotiated_tx_fc, negotiated_rx_fc);
+			pipe_handler_send_created_ind(sk, pn->pn_sk.sobject,
+					PNS_PIPE_CREATED_IND_UTID,
+					pn->pipe_handle, PNS_PIPE_CREATED_IND,
+					negotiated_tx_fc, negotiated_rx_fc);
+		} else {
+			pipe_handler_send_req(sk, pn->remote_pep,
+					PNS_PEP_CONNECT_UTID,
+					PNS_PEP_CONNECT_REQ, pn->pipe_handle,
+					GFP_ATOMIC);
+			pipe_get_flow_info(sk, skb, host_pref_rx_fc,
+					host_req_tx_fc);
+		}
+		break;
+#endif
+
 	case PNS_PEP_DISCONNECT_REQ:
 		pep_reply(sk, skb, PN_PIPE_NO_ERROR, NULL, 0, GFP_ATOMIC);
 		sk->sk_state = TCP_CLOSE_WAIT;
@@ -323,11 +645,41 @@ static int pipe_do_rcv(struct sock *sk, struct sk_buff *skb)
 			sk->sk_state_change(sk);
 		break;
 
+#ifdef CONFIG_PHONET_PIPECTRLR
+	case PNS_PEP_DISCONNECT_RESP:
+		pn->pipe_state = PIPE_IDLE;
+		pipe_handler_send_req(sk, pn->pn_sk.sobject,
+				PNS_PEP_DISCONNECT_UTID,
+				PNS_PEP_DISCONNECT_REQ, pn->pipe_handle,
+				GFP_KERNEL);
+		break;
+#endif
+
 	case PNS_PEP_ENABLE_REQ:
 		/* Wait for PNS_PIPE_(ENABLED|REDIRECTED)_IND */
 		pep_reply(sk, skb, PN_PIPE_NO_ERROR, NULL, 0, GFP_ATOMIC);
 		break;
 
+#ifdef CONFIG_PHONET_PIPECTRLR
+	case PNS_PEP_ENABLE_RESP:
+		if ((ph->pn_sdev == pn_dev(pn->remote_pep)) &&
+				(ph->pn_sobj == pn_obj(pn->remote_pep))) {
+			pn->pipe_state = PIPE_ENABLED;
+			pipe_handler_send_ind(sk, pn->remote_pep,
+					PNS_PIPE_ENABLED_IND_UTID,
+					pn->pipe_handle, PNS_PIPE_ENABLED_IND);
+			pipe_handler_send_ind(sk, pn->pn_sk.sobject,
+					PNS_PIPE_ENABLED_IND_UTID,
+					pn->pipe_handle, PNS_PIPE_ENABLED_IND);
+		} else
+			pipe_handler_send_req(sk, pn->remote_pep,
+					PNS_PIPE_ENABLE_UTID,
+					PNS_PEP_ENABLE_REQ, pn->pipe_handle,
+					GFP_KERNEL);
+
+		break;
+#endif
+
 	case PNS_PEP_RESET_REQ:
 		switch (hdr->state_after_reset) {
 		case PN_PIPE_DISABLE:
@@ -346,6 +698,27 @@ static int pipe_do_rcv(struct sock *sk, struct sk_buff *skb)
 		pep_reply(sk, skb, PN_PIPE_NO_ERROR, NULL, 0, GFP_ATOMIC);
 		break;
 
+#ifdef CONFIG_PHONET_PIPECTRLR
+	case PNS_PEP_DISABLE_RESP:
+		if ((ph->pn_sdev == pn_dev(pn->remote_pep)) &&
+				(ph->pn_sobj == pn_obj(pn->remote_pep))) {
+			pn->pipe_state = PIPE_DISABLED;
+			pipe_handler_send_ind(sk, pn->remote_pep,
+					PNS_PIPE_DISABLED_IND_UTID,
+					pn->pipe_handle,
+					PNS_PIPE_DISABLED_IND);
+			pipe_handler_send_ind(sk, pn->pn_sk.sobject,
+					PNS_PIPE_DISABLED_IND_UTID,
+					pn->pipe_handle,
+					PNS_PIPE_DISABLED_IND);
+		} else
+			pipe_handler_send_req(sk, pn->remote_pep,
+					PNS_PIPE_DISABLE_UTID,
+					PNS_PEP_DISABLE_REQ, pn->pipe_handle,
+					GFP_KERNEL);
+		break;
+#endif
+
 	case PNS_PEP_CTRL_REQ:
 		if (skb_queue_len(&pn->ctrlreq_queue) >= PNPIPE_CTRLREQ_MAX) {
 			atomic_inc(&sk->sk_drops);
@@ -519,6 +892,9 @@ static int pep_connreq_rcv(struct sock *sk, struct sk_buff *skb)
 	newpn->rx_fc = newpn->tx_fc = PN_LEGACY_FLOW_CONTROL;
 	newpn->init_enable = enabled;
 	newpn->aligned = aligned;
+#ifdef CONFIG_PHONET_PIPECTRLR
+	newpn->remote_pep = pn->remote_pep;
+#endif
 
 	BUG_ON(!skb_queue_empty(&newsk->sk_receive_queue));
 	skb_queue_head(&newsk->sk_receive_queue, skb);
@@ -781,6 +1157,10 @@ static int pep_setsockopt(struct sock *sk, int level, int optname,
 {
 	struct pep_sock *pn = pep_sk(sk);
 	int val = 0, err = 0;
+#ifdef CONFIG_PHONET_PIPECTRLR
+	int remote_pep;
+	int pipe_handle;
+#endif
 
 	if (level != SOL_PNPIPE)
 		return -ENOPROTOOPT;
@@ -791,6 +1171,48 @@ static int pep_setsockopt(struct sock *sk, int level, int optname,
 
 	lock_sock(sk);
 	switch (optname) {
+#ifdef CONFIG_PHONET_PIPECTRLR
+	case PNPIPE_CREATE:
+		if (val) {
+			if (pn->pipe_state > PIPE_IDLE) {
+				err = -EFAULT;
+				break;
+			}
+			remote_pep = val & 0xFFFF;
+			pipe_handle =  (val >> 16) & 0xFF;
+			pn->remote_pep = remote_pep;
+			err = pipe_handler_create_pipe(sk, pipe_handle,
+					PNPIPE_CREATE);
+			break;
+		}
+
+	case PNPIPE_ENABLE:
+		if (pn->pipe_state != PIPE_DISABLED) {
+			err = -EFAULT;
+			break;
+		}
+		err = pipe_handler_enable_pipe(sk, PNPIPE_ENABLE);
+		break;
+
+	case PNPIPE_DISABLE:
+		if (pn->pipe_state != PIPE_ENABLED) {
+			err = -EFAULT;
+			break;
+		}
+
+		err = pipe_handler_enable_pipe(sk, PNPIPE_DISABLE);
+		break;
+
+	case PNPIPE_DESTROY:
+		if (pn->pipe_state < PIPE_DISABLED) {
+			err = -EFAULT;
+			break;
+		}
+
+		err = pipe_handler_create_pipe(sk, 0x0, PNPIPE_DESTROY);
+		break;
+#endif
+
 	case PNPIPE_ENCAP:
 		if (val && val != PNPIPE_ENCAP_IP) {
 			err = -EINVAL;
@@ -840,6 +1262,13 @@ static int pep_getsockopt(struct sock *sk, int level, int optname,
 	case PNPIPE_ENCAP:
 		val = pn->ifindex ? PNPIPE_ENCAP_IP : PNPIPE_ENCAP_NONE;
 		break;
+
+#ifdef CONFIG_PHONET_PIPECTRLR
+	case PNPIPE_INQ:
+		val = pn->pipe_state;
+		break;
+#endif
+
 	case PNPIPE_IFINDEX:
 		val = pn->ifindex;
 		break;
@@ -859,7 +1288,14 @@ static int pipe_skb_send(struct sock *sk, struct sk_buff *skb)
 {
 	struct pep_sock *pn = pep_sk(sk);
 	struct pnpipehdr *ph;
-	int err;
+#ifdef CONFIG_PHONET_PIPECTRLR
+	struct sockaddr_pn spn = {
+		.spn_family = AF_PHONET,
+		.spn_resource = 0xD9,
+		.spn_dev = pn_dev(pn->remote_pep),
+		.spn_obj = pn_obj(pn->remote_pep),
+	};
+#endif
 
 	if (pn_flow_safe(pn->tx_fc) &&
 	    !atomic_add_unless(&pn->tx_credits, -1, 0)) {
@@ -877,11 +1313,11 @@ static int pipe_skb_send(struct sock *sk, struct sk_buff *skb)
 	} else
 		ph->message_id = PNS_PIPE_DATA;
 	ph->pipe_handle = pn->pipe_handle;
-
-	err = pn_skb_send(sk, skb, &pipe_srv);
-	if (err && pn_flow_safe(pn->tx_fc))
-		atomic_inc(&pn->tx_credits);
-	return err;
+#ifdef CONFIG_PHONET_PIPECTRLR
+	return pn_skb_send(sk, skb, &spn);
+#else
+	return pn_skb_send(sk, skb, &pipe_srv);
+#endif
 }
 
 static int pep_sendmsg(struct kiocb *iocb, struct sock *sk,
-- 
1.7.2.dirty

