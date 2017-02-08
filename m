From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCHv6 net-next 4/6] sctp: implement sender-side procedures for SSN/TSN Reset Request Parameter
Date: Thu,  9 Feb 2017 01:18:18 +0800
Message-ID: <7095f88e0d93a7189df08fec56b3db89deb0397c.1486573728.git.lucien.xin@gmail.com>
References: <cover.1486573727.git.lucien.xin@gmail.com>
 <5f2d5aa54716217f68f724e4165289bd964b8755.1486573728.git.lucien.xin@gmail.com>
 <3d1180fcc5c72dea7d6cb7c7fafae4c4a7782cb3.1486573728.git.lucien.xin@gmail.com>
 <376d8794b81d7c5efe02b588ca381b88ed5f05ad.1486573728.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        Vlad Yasevich <vyasevich@gmail.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:32830 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752939AbdBHR1R (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 12:27:17 -0500
In-Reply-To: <376d8794b81d7c5efe02b588ca381b88ed5f05ad.1486573728.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1486573727.git.lucien.xin@gmail.com>
References: <cover.1486573727.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to implement Sender-Side Procedures for the SSN/TSN
Reset Request Parameter descibed in rfc6525 section 5.1.4.

It is also to add sockopt SCTP_RESET_ASSOC in rfc6525 section 6.3.3
for users.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/net/sctp/sctp.h   |  1 +
 include/uapi/linux/sctp.h |  1 +
 net/sctp/socket.c         | 29 +++++++++++++++++++++++++++++
 net/sctp/stream.c         | 40 ++++++++++++++++++++++++++++++++++++++++
 4 files changed, 71 insertions(+)

diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
index 480b65a..b60ca14 100644
--- a/include/net/sctp/sctp.h
+++ b/include/net/sctp/sctp.h
@@ -198,6 +198,7 @@ int sctp_offload_init(void);
  */
 int sctp_send_reset_streams(struct sctp_association *asoc,
 			    struct sctp_reset_streams *params);
+int sctp_send_reset_assoc(struct sctp_association *asoc);
 
 /*
  * Module global variables
diff --git a/include/uapi/linux/sctp.h b/include/uapi/linux/sctp.h
index 03c27ce..c0bd8c3 100644
--- a/include/uapi/linux/sctp.h
+++ b/include/uapi/linux/sctp.h
@@ -117,6 +117,7 @@ typedef __s32 sctp_assoc_t;
 #define SCTP_PR_ASSOC_STATUS	115
 #define SCTP_ENABLE_STREAM_RESET	118
 #define SCTP_RESET_STREAMS	119
+#define SCTP_RESET_ASSOC	120
 
 /* PR-SCTP policies */
 #define SCTP_PR_SCTP_NONE	0x0000
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index a8b4252f..45a7c41 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -3818,6 +3818,32 @@ static int sctp_setsockopt_reset_streams(struct sock *sk,
 	return retval;
 }
 
+static int sctp_setsockopt_reset_assoc(struct sock *sk,
+				       char __user *optval,
+				       unsigned int optlen)
+{
+	struct sctp_association *asoc;
+	sctp_assoc_t associd;
+	int retval = -EINVAL;
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
+	retval = sctp_send_reset_assoc(asoc);
+
+out:
+	return retval;
+}
+
 /* API 6.2 setsockopt(), getsockopt()
  *
  * Applications use setsockopt() and getsockopt() to set or retrieve
@@ -3990,6 +4016,9 @@ static int sctp_setsockopt(struct sock *sk, int level, int optname,
 	case SCTP_RESET_STREAMS:
 		retval = sctp_setsockopt_reset_streams(sk, optval, optlen);
 		break;
+	case SCTP_RESET_ASSOC:
+		retval = sctp_setsockopt_reset_assoc(sk, optval, optlen);
+		break;
 	default:
 		retval = -ENOPROTOOPT;
 		break;
diff --git a/net/sctp/stream.c b/net/sctp/stream.c
index 6a686e3..53e49fc 100644
--- a/net/sctp/stream.c
+++ b/net/sctp/stream.c
@@ -177,3 +177,43 @@ int sctp_send_reset_streams(struct sctp_association *asoc,
 out:
 	return retval;
 }
+
+int sctp_send_reset_assoc(struct sctp_association *asoc)
+{
+	struct sctp_chunk *chunk = NULL;
+	int retval;
+	__u16 i;
+
+	if (!asoc->peer.reconf_capable ||
+	    !(asoc->strreset_enable & SCTP_ENABLE_RESET_ASSOC_REQ))
+		return -ENOPROTOOPT;
+
+	if (asoc->strreset_outstanding)
+		return -EINPROGRESS;
+
+	chunk = sctp_make_strreset_tsnreq(asoc);
+	if (!chunk)
+		return -ENOMEM;
+
+	/* Block further xmit of data until this request is completed */
+	for (i = 0; i < asoc->stream->outcnt; i++)
+		asoc->stream->out[i].state = SCTP_STREAM_CLOSED;
+
+	asoc->strreset_chunk = chunk;
+	sctp_chunk_hold(asoc->strreset_chunk);
+
+	retval = sctp_send_reconf(asoc, chunk);
+	if (retval) {
+		sctp_chunk_put(asoc->strreset_chunk);
+		asoc->strreset_chunk = NULL;
+
+		for (i = 0; i < asoc->stream->outcnt; i++)
+			asoc->stream->out[i].state = SCTP_STREAM_OPEN;
+
+		return retval;
+	}
+
+	asoc->strreset_outstanding = 1;
+
+	return 0;
+}
-- 
2.1.0
