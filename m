From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next 15/27] sctp: add rfc6525 section 5.1.4 and 6.3.3
Date: Sun,  1 Jan 2017 19:20:32 +0800
Message-ID: <ef7d01cf1d5826e694a08303ee0b36c00201c666.1483269426.git.lucien.xin@gmail.com>
References: <cover.1483269426.git.lucien.xin@gmail.com>
 <684ad8ddd79f23844883dede4c34360ce744dfc3.1483269426.git.lucien.xin@gmail.com>
 <c752879a5af358c08da949b391416452f1322c43.1483269426.git.lucien.xin@gmail.com>
 <be8a2770ddc2381266050c9f168add9802b90a49.1483269426.git.lucien.xin@gmail.com>
 <fc046afdda34c9b262ce57400c4256b14fd1a0fb.1483269426.git.lucien.xin@gmail.com>
 <d4f1b2a4fa19457e9867b0a1f84764a7a509459a.1483269426.git.lucien.xin@gmail.com>
 <31abc54d31ef0714322f137bff43458014d7c276.1483269426.git.lucien.xin@gmail.com>
 <58860816816d6d51b062235fd54dae6540a4797a.1483269426.git.lucien.xin@gmail.com>
 <229608faf7af54c0bf908694ca8349205bbf6eab.1483269426.git.lucien.xin@gmail.com>
 <c4f16844620cd3a2aa76596df9eaadf1505fc8e6.1483269426.git.lucien.xin@gmail.com>
 <1d0b270084289945c4b42ae36d0556648a3f9b64.1483269426.git.lucien.xin@gmail.com>
 <1e4560205cff3c10868d5614b62a3db14e87ccf0.1483269426.git.lucien.xin@gmail.com>
 <91b9171cc57c0f322d103dfbbcce1b9706800805.1483269426.git.lucien.xin@gmail.com>
 <d5fb0969ea5d055dea5bdc257569530b6d2fc7c2.1483269426.git.lucien.xin@gmail.com>
 <6a74f5a3ac408f20816a8c79edd6b9922ed3b573.1483269426.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:34771 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932079AbdAALWx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 1 Jan 2017 06:22:53 -0500
In-Reply-To: <6a74f5a3ac408f20816a8c79edd6b9922ed3b573.1483269426.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1483269426.git.lucien.xin@gmail.com>
References: <cover.1483269426.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to implement Sender-Side Procedures for the SSN/TSN
Reset Request Parameter descibed in section 5.1.4.

It is also to add sockopt SCTP_RESET_ASSOC in section 6.3.3 for
users.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/uapi/linux/sctp.h |  1 +
 net/sctp/socket.c         | 57 +++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 58 insertions(+)

diff --git a/include/uapi/linux/sctp.h b/include/uapi/linux/sctp.h
index 1f4518b..c1c77c8 100644
--- a/include/uapi/linux/sctp.h
+++ b/include/uapi/linux/sctp.h
@@ -118,6 +118,7 @@ typedef __s32 sctp_assoc_t;
 #define SCTP_RECONFIG_SUPPORTED	117
 #define SCTP_ENABLE_STREAM_RESET	118
 #define SCTP_RESET_STREAMS	119
+#define SCTP_RESET_ASSOC	120
 
 /* PR-SCTP policies */
 #define SCTP_PR_SCTP_NONE	0x0000
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index e62872c..bcefc55 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -3914,6 +3914,60 @@ static int sctp_setsockopt_reset_streams(struct sock *sk,
 	return retval;
 }
 
+static int sctp_setsockopt_reset_assoc(struct sock *sk,
+				       char __user *optval,
+				       unsigned int optlen)
+{
+	struct sctp_association *asoc;
+	struct sctp_chunk *chunk = NULL;
+	sctp_assoc_t associd;
+	int retval = -EINVAL;
+	__u16 i;
+
+	if (optlen != sizeof(associd))
+		goto out;
+
+	if (copy_from_user(&associd, optval, optlen)) {
+		retval = -EFAULT;
+		goto out;
+	}
+
+	asoc = sctp_id2assoc(sk, associd);
+	if (!asoc)
+		goto out;
+
+	if (!asoc->peer.reconf_capable ||
+	    !(asoc->strreset_enable & SCTP_ENABLE_RESET_ASSOC_REQ)) {
+		retval = -ENOPROTOOPT;
+		goto out;
+	}
+
+	if (asoc->strreset_outstanding) {
+		retval = -EINPROGRESS;
+		goto out;
+	}
+
+	chunk = sctp_make_strreset_tsnreq(asoc);
+	if (!chunk)
+		goto out;
+
+	for (i = 0; i < asoc->streamoutcnt; i++)
+		asoc->streamout[i].state = SCTP_STREAM_CLOSED;
+
+	asoc->strreset_outstanding = 1;
+	asoc->strreset_chunk = chunk;
+	sctp_chunk_hold(asoc->strreset_chunk);
+
+	retval = sctp_send_reconf(asoc, chunk);
+	if (retval) {
+		sctp_chunk_put(asoc->strreset_chunk);
+		asoc->strreset_chunk = NULL;
+	}
+
+out:
+	return retval;
+}
+
 /* API 6.2 setsockopt(), getsockopt()
  *
  * Applications use setsockopt() and getsockopt() to set or retrieve
@@ -4089,6 +4143,9 @@ static int sctp_setsockopt(struct sock *sk, int level, int optname,
 	case SCTP_RESET_STREAMS:
 		retval = sctp_setsockopt_reset_streams(sk, optval, optlen);
 		break;
+	case SCTP_RESET_ASSOC:
+		retval = sctp_setsockopt_reset_assoc(sk, optval, optlen);
+		break;
 	default:
 		retval = -ENOPROTOOPT;
 		break;
-- 
2.1.0
