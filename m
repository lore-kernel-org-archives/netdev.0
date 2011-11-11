From: Hemant Vilas RAMDASI <hemant.ramdasi@stericsson.com>
Subject: [PATCH v3] Phonet: set the pipe handle using setsockopt
Date: Fri, 11 Nov 2011 15:58:22 +0530
Message-ID: <1321007302-7269-1-git-send-email-hemant.ramdasi@stericsson.com>
Cc: netdev@vger.kernel.org,
	Dinesh Kumar Sharma <dinesh.sharma@stericsson.com>,
	Hemant Ramdasi <hemant.ramdasi@stericsson.com>
To: remi.denis-courmont@nokia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog115.obsmtp.com ([207.126.144.139]:48712 "EHLO
	eu1sys200aog115.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750971Ab1KKK2m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Nov 2011 05:28:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dinesh Kumar Sharma <dinesh.sharma@stericsson.com>

This provides flexibility to set the pipe handle
using setsockopt and enable the same.

Signed-off-by: Hemant Ramdasi <hemant.ramdasi@stericsson.com>
Signed-off-by: Dinesh Kumar Sharma <dinesh.sharma@stericsson.com>
---
 include/linux/phonet.h |    2 +
 net/phonet/pep.c       |  111 +++++++++++++++++++++++++++++++++++++++++++----
 2 files changed, 103 insertions(+), 10 deletions(-)

diff --git a/include/linux/phonet.h b/include/linux/phonet.h
index 6fb1384..491caec 100644
--- a/include/linux/phonet.h
+++ b/include/linux/phonet.h
@@ -37,6 +37,8 @@
 #define PNPIPE_ENCAP		1
 #define PNPIPE_IFINDEX		2
 #define PNPIPE_HANDLE		3
+#define PNPIPE_ENABLE		4
+#define PNPIPE_INITSTATE	5
 
 #define PNADDR_ANY		0
 #define PNADDR_BROADCAST	0xFC
diff --git a/net/phonet/pep.c b/net/phonet/pep.c
index f17fd84..33230c5 100644
--- a/net/phonet/pep.c
+++ b/net/phonet/pep.c
@@ -167,6 +167,12 @@ static int pipe_handler_send_created_ind(struct sock *sk)
 				data, 4, GFP_ATOMIC);
 }
 
+static int pipe_handler_send_enabled_ind(struct sock *sk)
+{
+	return pep_indicate(sk, PNS_PIPE_ENABLED_IND, 0 /* sub-blocks */,
+				NULL, 0, GFP_ATOMIC);
+}
+
 static int pep_accept_conn(struct sock *sk, struct sk_buff *skb)
 {
 	static const u8 data[20] = {
@@ -533,6 +539,27 @@ static int pep_connresp_rcv(struct sock *sk, struct sk_buff *skb)
 	return pipe_handler_send_created_ind(sk);
 }
 
+static int pep_enableresp_rcv(struct sock *sk, struct sk_buff *skb)
+{
+	struct pnpipehdr *hdr = pnp_hdr(skb);
+
+	if (hdr->error_code != PN_PIPE_NO_ERROR)
+		return -ECONNREFUSED;
+
+	return pipe_handler_send_enabled_ind(sk);
+}
+
+static void pipe_start_flow_control(struct sock *sk)
+{
+	struct pep_sock *pn = pep_sk(sk);
+
+	if (!pn_flow_safe(pn->tx_fc)) {
+		atomic_set(&pn->tx_credits, 1);
+		sk->sk_write_space(sk);
+	}
+	pipe_grant_credits(sk, GFP_ATOMIC);
+}
+
 /* Queue an skb to an actively connected sock.
  * Socket lock must be held. */
 static int pipe_handler_do_rcv(struct sock *sk, struct sk_buff *skb)
@@ -578,13 +605,25 @@ static int pipe_handler_do_rcv(struct sock *sk, struct sk_buff *skb)
 			sk->sk_state = TCP_CLOSE_WAIT;
 			break;
 		}
+		if (pn->init_enable == PN_PIPE_DISABLE)
+			sk->sk_state = TCP_SYN_RECV;
+		else {
+			sk->sk_state = TCP_ESTABLISHED;
+			pipe_start_flow_control(sk);
+		}
+		break;
 
-		sk->sk_state = TCP_ESTABLISHED;
-		if (!pn_flow_safe(pn->tx_fc)) {
-			atomic_set(&pn->tx_credits, 1);
-			sk->sk_write_space(sk);
+	case PNS_PEP_ENABLE_RESP:
+		if (sk->sk_state != TCP_SYN_SENT)
+			break;
+
+		if (pep_enableresp_rcv(sk, skb)) {
+			sk->sk_state = TCP_CLOSE_WAIT;
+			break;
 		}
-		pipe_grant_credits(sk, GFP_ATOMIC);
+
+		sk->sk_state = TCP_ESTABLISHED;
+		pipe_start_flow_control(sk);
 		break;
 
 	case PNS_PEP_DISCONNECT_RESP:
@@ -863,14 +902,31 @@ static int pep_sock_connect(struct sock *sk, struct sockaddr *addr, int len)
 	int err;
 	u8 data[4] = { 0 /* sub-blocks */, PAD, PAD, PAD };
 
-	pn->pipe_handle = 1; /* anything but INVALID_HANDLE */
+	if (pn->pipe_handle == PN_PIPE_INVALID_HANDLE)
+		pn->pipe_handle = 1; /* anything but INVALID_HANDLE */
+
 	err = pipe_handler_request(sk, PNS_PEP_CONNECT_REQ,
-					PN_PIPE_ENABLE, data, 4);
-	if (err) {
-		pn->pipe_handle = PN_PIPE_INVALID_HANDLE;
+				pn->init_enable, data, 4);
+	if (err)
 		return err;
-	}
+
 	sk->sk_state = TCP_SYN_SENT;
+
+	return 0;
+}
+
+static int pep_sock_enable(struct sock *sk, struct sockaddr *addr, int len)
+{
+	int err;
+
+	err = pipe_handler_request(sk, PNS_PEP_ENABLE_REQ, PAD,
+				NULL, 0);
+
+	if (err)
+		return err;
+
+	sk->sk_state = TCP_SYN_SENT;
+
 	return 0;
 }
 
@@ -959,6 +1015,30 @@ static int pep_setsockopt(struct sock *sk, int level, int optname,
 		}
 		goto out_norel;
 
+	case PNPIPE_HANDLE:
+		if ((sk->sk_state == TCP_CLOSE) &&
+			(val >= 0) && (val < PN_PIPE_INVALID_HANDLE))
+			pn->pipe_handle = val;
+		else
+			err = -EINVAL;
+		break;
+
+	case PNPIPE_ENABLE:
+		if (sk->sk_state == TCP_SYN_SENT)
+			err = -EBUSY;
+		else if (sk->sk_state == TCP_ESTABLISHED)
+			err = -EISCONN;
+		else
+			err = pep_sock_enable(sk, NULL, 0);
+		break;
+
+	case PNPIPE_INITSTATE:
+		if ((val == 0) || (val == 1))
+			pn->init_enable = val;
+		else
+			err = -EINVAL;
+		break;
+
 	default:
 		err = -ENOPROTOOPT;
 	}
@@ -994,6 +1074,17 @@ static int pep_getsockopt(struct sock *sk, int level, int optname,
 			return -EINVAL;
 		break;
 
+	case PNPIPE_ENABLE:
+		if (sk->sk_state == TCP_ESTABLISHED)
+			val = 1;
+		else
+			val = 0;
+		break;
+
+	case PNPIPE_INITSTATE:
+		val = pn->init_enable;
+		break;
+
 	default:
 		return -ENOPROTOOPT;
 	}
-- 
1.7.4.3
