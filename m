From: Jesper Juhl <jesper.juhl@gmail.com>
Subject: [PATCH] Fix memory leak in discard case of sctp_sf_abort_violation()
Date: Sun, 11 Nov 2007 23:57:49 +0100
Message-ID: <200711112357.49577.jesper.juhl@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Vlad Yasevich <vladislav.yasevich@hp.com>,
	Sridhar Samudrala <sri@us.ibm.com>,
	Jesper Juhl <jesper.juhl@gmail.com>
To: lksctp developers <lksctp-developers@lists.sourceforge.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mu-out-0910.google.com ([209.85.134.188]:29529 "EHLO
	mu-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751074AbXKKXCY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Nov 2007 18:02:24 -0500
Received: by mu-out-0910.google.com with SMTP id i10so1246214mue
        for <netdev@vger.kernel.org>; Sun, 11 Nov 2007 15:02:22 -0800 (PST)
Content-Disposition: inline
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
---

 sm_statefuns.c |   10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index f01b408..4c5c5e7 100644
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



