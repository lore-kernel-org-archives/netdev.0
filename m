From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next 04/27] sctp: add rfc6525 section 3.1
Date: Sun,  1 Jan 2017 19:20:21 +0800
Message-ID: <fc046afdda34c9b262ce57400c4256b14fd1a0fb.1483269426.git.lucien.xin@gmail.com>
References: <cover.1483269426.git.lucien.xin@gmail.com>
 <684ad8ddd79f23844883dede4c34360ce744dfc3.1483269426.git.lucien.xin@gmail.com>
 <c752879a5af358c08da949b391416452f1322c43.1483269426.git.lucien.xin@gmail.com>
 <be8a2770ddc2381266050c9f168add9802b90a49.1483269426.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:33042 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755104AbdAALVY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 1 Jan 2017 06:21:24 -0500
In-Reply-To: <be8a2770ddc2381266050c9f168add9802b90a49.1483269426.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1483269426.git.lucien.xin@gmail.com>
References: <cover.1483269426.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to define the reconf chunk as the section 3.1 descibes.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/linux/sctp.h     |  6 ++++++
 net/sctp/sm_make_chunk.c | 33 +++++++++++++++++++++++++++++++++
 2 files changed, 39 insertions(+)

diff --git a/include/linux/sctp.h b/include/linux/sctp.h
index fcb4c36..cdc3b05 100644
--- a/include/linux/sctp.h
+++ b/include/linux/sctp.h
@@ -108,6 +108,7 @@ typedef enum {
 	/* Use hex, as defined in ADDIP sec. 3.1 */
 	SCTP_CID_ASCONF			= 0xC1,
 	SCTP_CID_ASCONF_ACK		= 0x80,
+	SCTP_CID_RECONF			= 0x82,
 } sctp_cid_t; /* enum */
 
 
@@ -710,4 +711,9 @@ struct sctp_infox {
 	struct sctp_association *asoc;
 };
 
+struct sctp_reconf_chunk {
+	sctp_chunkhdr_t chunk_hdr;
+	__u8 params[0];
+} __packed;
+
 #endif /* __LINUX_SCTP_H__ */
diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index 78cbd1b..258d55a 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -3534,3 +3534,36 @@ struct sctp_chunk *sctp_make_fwdtsn(const struct sctp_association *asoc,
 
 	return retval;
 }
+
+/* RE-CONFIG 3.1 (RE-CONFIG chunk)
+ *   0                   1                   2                   3
+ *   0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
+ *  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ *  | Type = 130    |  Chunk Flags  |      Chunk Length             |
+ *  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ *  \                                                               \
+ *  /                  Re-configuration Parameter                   /
+ *  \                                                               \
+ *  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ *  \                                                               \
+ *  /             Re-configuration Parameter (optional)             /
+ *  \                                                               \
+ *  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ */
+static struct sctp_chunk *sctp_make_reconf(
+				const struct sctp_association *asoc,
+				int length)
+{
+	struct sctp_reconf_chunk *reconf;
+	struct sctp_chunk *retval;
+
+	retval = sctp_make_control(asoc, SCTP_CID_RECONF, 0, length,
+				   GFP_ATOMIC);
+	if (!retval)
+		return NULL;
+
+	reconf = (struct sctp_reconf_chunk *)retval->chunk_hdr;
+	retval->param_hdr.v = reconf->params;
+
+	return retval;
+}
-- 
2.1.0
