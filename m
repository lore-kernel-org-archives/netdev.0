From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCHv4 net-next 1/5] sctp: streams should be closed when stream reset request is sent successfully.
Date: Sat, 21 Jan 2017 02:00:35 +0800
Message-ID: <162aa3d0e82a2224ea08f2adc8bf4c0eb99b5cac.1484934853.git.lucien.xin@gmail.com>
References: <cover.1484934853.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        Vlad Yasevich <vyasevich@gmail.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:33902 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751800AbdATSAz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2017 13:00:55 -0500
In-Reply-To: <cover.1484934853.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1484934853.git.lucien.xin@gmail.com>
References: <cover.1484934853.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now when sending stream reset request, it closes the streams to
block further xmit of data until this request is completed, then
calls sctp_send_reconf to send the chunk.

But if sctp_send_reconf returns err, which means the request chunk
would not be queued and sent, so the asoc will get stuck, streams
are closed and no packet was even queued.

This patch is to fix it by closing streams only when request is sent
successfully, it is also to fix a return value.

Fixes: 7f9d68ac944e ("sctp: implement sender-side procedures for SSN Reset Request Parameter")
Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/sctp/stream.c | 22 +++++++++++++---------
 1 file changed, 13 insertions(+), 9 deletions(-)

diff --git a/net/sctp/stream.c b/net/sctp/stream.c
index 13d5e07..53c67d6 100644
--- a/net/sctp/stream.c
+++ b/net/sctp/stream.c
@@ -136,8 +136,20 @@ int sctp_send_reset_streams(struct sctp_association *asoc,
 				goto out;
 
 	chunk = sctp_make_strreset_req(asoc, str_nums, str_list, out, in);
-	if (!chunk)
+	if (!chunk) {
+		retval = -ENOMEM;
 		goto out;
+	}
+
+	asoc->strreset_chunk = chunk;
+	sctp_chunk_hold(asoc->strreset_chunk);
+
+	retval = sctp_send_reconf(asoc, chunk);
+	if (retval) {
+		sctp_chunk_put(asoc->strreset_chunk);
+		asoc->strreset_chunk = NULL;
+		goto out;
+	}
 
 	if (out) {
 		if (str_nums)
@@ -150,14 +162,6 @@ int sctp_send_reset_streams(struct sctp_association *asoc,
 	}
 
 	asoc->strreset_outstanding = out + in;
-	asoc->strreset_chunk = chunk;
-	sctp_chunk_hold(asoc->strreset_chunk);
-
-	retval = sctp_send_reconf(asoc, chunk);
-	if (retval) {
-		sctp_chunk_put(asoc->strreset_chunk);
-		asoc->strreset_chunk = NULL;
-	}
 
 out:
 	return retval;
-- 
2.1.0
