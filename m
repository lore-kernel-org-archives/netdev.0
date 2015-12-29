From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCHv2 net] sctp: sctp should release assoc when sctp_make_abort_user return NULL in sctp_close
Date: Tue, 29 Dec 2015 17:49:25 +0800
Message-ID: <038f05a2f35f3be88976ee1b59578bd5e5112112.1451382565.git.lucien.xin@gmail.com>
Cc: marcelo.leitner@gmail.com, vyasevic@redhat.com,
	daniel@iogearbox.net, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:36737 "EHLO
	mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752024AbbL2Jtb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Dec 2015 04:49:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In sctp_close, sctp_make_abort_user may return NULL because of memory
allocation failure. If this happens, it will bypass any state change
and never free the assoc. The assoc has no chance to be freed and it
will be kept in memory with the state it had even after the socket is
closed by sctp_close().

So if sctp_make_abort_user fails to allocate memory, we should abort
the asoc via sctp_primitive_ABORT as well. Just like the annotation in
sctp_sf_cookie_wait_prm_abort and sctp_sf_do_9_1_prm_abort said,
"Even if we can't send the ABORT due to low memory delete the TCB.
This is a departure from our typical NOMEM handling".

But then the chunk is NULL (low memory) and the SCTP_CMD_REPLY cmd would
dereference the chunk pointer, and system crash. So we should add
SCTP_CMD_REPLY cmd only when the chunk is not NULL, just like other
places where it adds SCTP_CMD_REPLY cmd.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
Acked-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
---
 net/sctp/sm_statefuns.c | 6 ++++--
 net/sctp/socket.c       | 3 +--
 2 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index cd34a4a..22c2bf3 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -4829,7 +4829,8 @@ sctp_disposition_t sctp_sf_do_9_1_prm_abort(
 
 	retval = SCTP_DISPOSITION_CONSUME;
 
-	sctp_add_cmd_sf(commands, SCTP_CMD_REPLY, SCTP_CHUNK(abort));
+	if (abort)
+		sctp_add_cmd_sf(commands, SCTP_CMD_REPLY, SCTP_CHUNK(abort));
 
 	/* Even if we can't send the ABORT due to low memory delete the
 	 * TCB.  This is a departure from our typical NOMEM handling.
@@ -4966,7 +4967,8 @@ sctp_disposition_t sctp_sf_cookie_wait_prm_abort(
 			SCTP_TO(SCTP_EVENT_TIMEOUT_T1_INIT));
 	retval = SCTP_DISPOSITION_CONSUME;
 
-	sctp_add_cmd_sf(commands, SCTP_CMD_REPLY, SCTP_CHUNK(abort));
+	if (abort)
+		sctp_add_cmd_sf(commands, SCTP_CMD_REPLY, SCTP_CHUNK(abort));
 
 	sctp_add_cmd_sf(commands, SCTP_CMD_NEW_STATE,
 			SCTP_STATE(SCTP_STATE_CLOSED));
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 9b6cc6d..6b2f901 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -1513,8 +1513,7 @@ static void sctp_close(struct sock *sk, long timeout)
 			struct sctp_chunk *chunk;
 
 			chunk = sctp_make_abort_user(asoc, NULL, 0);
-			if (chunk)
-				sctp_primitive_ABORT(net, asoc, chunk);
+			sctp_primitive_ABORT(net, asoc, chunk);
 		} else
 			sctp_primitive_SHUTDOWN(net, asoc, NULL);
 	}
-- 
2.1.0
