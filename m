From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: SCTP seems to lose its socket state.
Date: Mon, 09 Jun 2014 18:44:59 -0400
Message-ID: <539638EB.9010802@gmail.com>
References: <063D6719AE5E284EB5DD2968C1650D6D1724E53D@AcuExch.aculab.com> <063D6719AE5E284EB5DD2968C1650D6D17258A67@AcuExch.aculab.com> <063D6719AE5E284EB5DD2968C1650D6D17259993@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000009030801010005040600"
To: David Laight <David.Laight@ACULAB.COM>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f48.google.com ([209.85.216.48]:38296 "EHLO
	mail-qa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932867AbaFIWpD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jun 2014 18:45:03 -0400
Received: by mail-qa0-f48.google.com with SMTP id x12so2497217qac.35
        for <netdev@vger.kernel.org>; Mon, 09 Jun 2014 15:45:02 -0700 (PDT)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D17259993@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------000009030801010005040600
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit

David

Can you try the attached patch and let me know if it solves this problem
for you.

Thanks
-vlad

--------------000009030801010005040600
Content-Type: text/x-patch;
 name="0001-sctp-Handle-association-restart-in-SHUTDOWN-PENDING-.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename*0="0001-sctp-Handle-association-restart-in-SHUTDOWN-PENDING-.pa";
 filename*1="tch"

>From 3f4f0c587c7dd131ea8d34c7c83931500aae6bbc Mon Sep 17 00:00:00 2001
From: Vlad Yasevich <vyasevic@redhat.com>
Date: Mon, 9 Jun 2014 17:38:23 -0400
Subject: [PATCH] sctp: Handle association restart in SHUTDOWN-PENDING state

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 net/sctp/sm_statefuns.c | 19 ++++++++++++++++---
 1 file changed, 16 insertions(+), 3 deletions(-)

diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index 5170a1f..7194fe85 100644
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
1.9.0


--------------000009030801010005040600--
