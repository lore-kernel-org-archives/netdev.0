From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH 14/14] Fix memory leak in discard case of sctp_sf_abort_violation()
Date: Mon, 12 Nov 2007 11:38:29 -0500
Message-ID: <11948855193018-git-send-email-vladislav.yasevich@hp.com>
References: <11948855091808-git-send-email-vladislav.yasevich@hp.com>
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net,
	Jesper Juhl <jesper.juhl@gmail.com>,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel12.hp.com ([156.153.255.237]:56258 "EHLO palrel12.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754534AbXKLQil (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Nov 2007 11:38:41 -0500
In-Reply-To: <11948855091808-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jesper Juhl <jesper.juhl@gmail.com>

In net/sctp/sm_statefuns.c::sctp_sf_abort_violation() we may leak
the storage allocated for 'abort' by returning from the function
without using or freeing it. This happens in case
"sctp_auth_recv_cid(SCTP_CID_ABORT, asoc)" is true and we jump to
the 'discard' label.
Spotted by the Coverity checker.

The simple fix is to simply move the creation of the "abort chunk"
to after the possible jump to the 'discard' label. This way we don't
even have to allocate the memory at all in the problem case.

Signed-off-by: Jesper Juhl <jesper.juhl@gmail.com>
Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 net/sctp/sm_statefuns.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index a66075a..5ebbe80 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -4064,11 +4064,6 @@ static sctp_disposition_t sctp_sf_abort_violation(
 	struct sctp_chunk *chunk =  arg;
 	struct sctp_chunk *abort = NULL;
 
-	/* Make the abort chunk. */
-	abort = sctp_make_abort_violation(asoc, chunk, payload, paylen);
-	if (!abort)
-		goto nomem;
-
 	/* SCTP-AUTH, Section 6.3:
 	 *    It should be noted that if the receiver wants to tear
 	 *    down an association in an authenticated way only, the
@@ -4083,6 +4078,11 @@ static sctp_disposition_t sctp_sf_abort_violation(
 	if (sctp_auth_recv_cid(SCTP_CID_ABORT, asoc))
 		goto discard;
 
+	/* Make the abort chunk. */
+	abort = sctp_make_abort_violation(asoc, chunk, payload, paylen);
+	if (!abort)
+		goto nomem;
+
 	if (asoc) {
 		sctp_add_cmd_sf(commands, SCTP_CMD_REPLY, SCTP_CHUNK(abort));
 		SCTP_INC_STATS(SCTP_MIB_OUTCTRLCHUNKS);
-- 
1.5.2.4

