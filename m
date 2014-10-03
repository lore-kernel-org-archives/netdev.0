From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: [PATCH] sctp: handle association restarts when the socket is closed.
Date: Fri,  3 Oct 2014 18:16:20 -0400
Message-ID: <1412374580-22286-1-git-send-email-vyasevich@gmail.com>
Cc: Vlad Yasevich <vyasevich@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f43.google.com ([209.85.216.43]:37641 "EHLO
	mail-qa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758089AbaJCWQa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Oct 2014 18:16:30 -0400
Received: by mail-qa0-f43.google.com with SMTP id s7so1469862qap.2
        for <netdev@vger.kernel.org>; Fri, 03 Oct 2014 15:16:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vyasevich@gmail.com>

Currently association restarts do not take into consideration the
state of the socket.  When a restart happens, the current assocation
simply transitions into established state.  This creates a condition
where a remote system, through a the restart procedure, may create a
local association that is no way reachable by user.  The conditions
to trigger this are as follows:
  1) Remote does not acknoledge some data causing data to remain
     outstanding.
  2) Local application calls close() on the socket.  Since data
     is still outstanding, the association is placed in SHUTDOWN_PENDING
     state.  However, the socket is closed.
  3) The remote tries to create a new association, triggering a restart
     on the local system.  The association moves from SHUTDOWN_PENDING
     to ESTABLISHED.  At this point, it is no longer reachable by
     any socket on the local system.

This patch addresses the above situation by moving the newly ESTABLISHED
association into SHUTDOWN-SENT state and bundling a SHUTDOWN after
the COOKIE-ACK chunk.  This way, the restarted associate immidiately
enters the shutdown procedure and forces the termination of the
unreachable association.

Reported-by: David Laight <David.Laight@aculab.com>
Signed-off-by: Vlad Yasevich <vyasevich@gmail.com>
---
 include/net/sctp/command.h |  2 +-
 net/sctp/sm_statefuns.c    | 19 ++++++++++++++++---
 2 files changed, 17 insertions(+), 4 deletions(-)

diff --git a/include/net/sctp/command.h b/include/net/sctp/command.h
index f22538e..2487676 100644
--- a/include/net/sctp/command.h
+++ b/include/net/sctp/command.h
@@ -115,7 +115,7 @@ typedef enum {
  * analysis of the state functions, but in reality just taken from
  * thin air in the hopes othat we don't trigger a kernel panic.
  */
-#define SCTP_MAX_NUM_COMMANDS 14
+#define SCTP_MAX_NUM_COMMANDS 20 
 
 typedef union {
 	void *zero_all;	/* Set to NULL to clear the entire union */
diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index d3f1ea4..c8f6063 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -1775,9 +1775,22 @@ static sctp_disposition_t sctp_sf_do_dupcook_a(struct net *net,
 	/* Update the content of current association. */
 	sctp_add_cmd_sf(commands, SCTP_CMD_UPDATE_ASSOC, SCTP_ASOC(new_asoc));
 	sctp_add_cmd_sf(commands, SCTP_CMD_EVENT_ULP, SCTP_ULPEVENT(ev));
-	sctp_add_cmd_sf(commands, SCTP_CMD_NEW_STATE,
-			SCTP_STATE(SCTP_STATE_ESTABLISHED));
-	sctp_add_cmd_sf(commands, SCTP_CMD_REPLY, SCTP_CHUNK(repl));
+	if (sctp_state(asoc, SHUTDOWN_PENDING) &&
+	    (sctp_sstate(asoc->base.sk, CLOSING) ||
+	     sock_flag(asoc->base.sk, SOCK_DEAD))) {
+		/* if were currently in SHUTDOWN_PENDING, but the socket
+		 * has been closed by user, don't transition to ESTABLISHED.
+		 * Instead trigger SHUTDOWN bundled with COOKIE_ACK.
+		 */
+		sctp_add_cmd_sf(commands, SCTP_CMD_REPLY, SCTP_CHUNK(repl));
+		return sctp_sf_do_9_2_start_shutdown(net, ep, asoc,
+						     SCTP_ST_CHUNK(0), NULL,
+						     commands);
+	} else {
+		sctp_add_cmd_sf(commands, SCTP_CMD_NEW_STATE,
+				SCTP_STATE(SCTP_STATE_ESTABLISHED));
+		sctp_add_cmd_sf(commands, SCTP_CMD_REPLY, SCTP_CHUNK(repl));
+	}
 	return SCTP_DISPOSITION_CONSUME;
 
 nomem_ev:
-- 
1.9.3
