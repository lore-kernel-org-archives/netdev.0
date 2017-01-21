From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCHv5 net-next 1/5] sctp: streams should be recovered when it fails to send request.
Date: Sat, 21 Jan 2017 18:24:22 +0800
Message-ID: <9f2a54d764987dc6509e2322e3c0d93f819ebdb5.1484993773.git.lucien.xin@gmail.com>
References: <cover.1484993773.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        Vlad Yasevich <vyasevich@gmail.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:33622 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751064AbdAUKYm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 21 Jan 2017 05:24:42 -0500
In-Reply-To: <cover.1484993773.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1484993773.git.lucien.xin@gmail.com>
References: <cover.1484993773.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now when sending stream reset request, it closes the streams to
block further xmit of data until this request is completed, then
calls sctp_send_reconf to send the chunk.

But if sctp_send_reconf returns err, and it doesn't recover the
streams' states back,  which means the request chunk would not be
queued and sent, so the asoc will get stuck, streams are closed
and no packet is even queued.

This patch is to fix it by recovering the streams' states when
it fails to send the request, it is also to fix a return value.

Fixes: 7f9d68ac944e ("sctp: implement sender-side procedures for SSN Reset Request Parameter")
Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/sctp/stream.c | 19 +++++++++++++++++--
 1 file changed, 17 insertions(+), 2 deletions(-)

diff --git a/net/sctp/stream.c b/net/sctp/stream.c
index 13d5e07..6a686e3 100644
--- a/net/sctp/stream.c
+++ b/net/sctp/stream.c
@@ -136,8 +136,10 @@ int sctp_send_reset_streams(struct sctp_association *asoc,
 				goto out;
 
 	chunk = sctp_make_strreset_req(asoc, str_nums, str_list, out, in);
-	if (!chunk)
+	if (!chunk) {
+		retval = -ENOMEM;
 		goto out;
+	}
 
 	if (out) {
 		if (str_nums)
@@ -149,7 +151,6 @@ int sctp_send_reset_streams(struct sctp_association *asoc,
 				stream->out[i].state = SCTP_STREAM_CLOSED;
 	}
 
-	asoc->strreset_outstanding = out + in;
 	asoc->strreset_chunk = chunk;
 	sctp_chunk_hold(asoc->strreset_chunk);
 
@@ -157,8 +158,22 @@ int sctp_send_reset_streams(struct sctp_association *asoc,
 	if (retval) {
 		sctp_chunk_put(asoc->strreset_chunk);
 		asoc->strreset_chunk = NULL;
+		if (!out)
+			goto out;
+
+		if (str_nums)
+			for (i = 0; i < str_nums; i++)
+				stream->out[str_list[i]].state =
+						       SCTP_STREAM_OPEN;
+		else
+			for (i = 0; i < stream->outcnt; i++)
+				stream->out[i].state = SCTP_STREAM_OPEN;
+
+		goto out;
 	}
 
+	asoc->strreset_outstanding = out + in;
+
 out:
 	return retval;
 }
-- 
2.1.0
