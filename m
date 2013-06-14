From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next v3 2/4] net: sctp: sctp_sf_do_prm_asoc: do SCTP_CMD_INIT_CHOOSE_TRANSPORT first
Date: Fri, 14 Jun 2013 18:24:05 +0200
Message-ID: <1371227047-16852-3-git-send-email-dborkman@redhat.com>
References: <1371227047-16852-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38895 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753023Ab3FNQYM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Jun 2013 12:24:12 -0400
In-Reply-To: <1371227047-16852-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While this currently cannot trigger any NULL pointer dereference in
sctp_seq_dump_local_addrs(), better change the order of commands to
prevent a future bug to happen. Although we first add SCTP_CMD_NEW_ASOC
and then set the SCTP_CMD_INIT_CHOOSE_TRANSPORT, it is okay for now,
since this primitive is only called by sctp_connect() or sctp_sendmsg()
with sctp_assoc_add_peer() set first. However, lets do this precaution
and first set the transport and then add it to the association hashlist
to prevent in future something to possibly triggering this.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 net/sctp/sm_statefuns.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index de1a013..b3d1868 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -4632,16 +4632,16 @@ sctp_disposition_t sctp_sf_do_prm_asoc(struct net *net,
 	if (!repl)
 		goto nomem;
 
+	/* Choose transport for INIT. */
+	sctp_add_cmd_sf(commands, SCTP_CMD_INIT_CHOOSE_TRANSPORT,
+			SCTP_CHUNK(repl));
+
 	/* Cast away the const modifier, as we want to just
 	 * rerun it through as a sideffect.
 	 */
 	my_asoc = (struct sctp_association *)asoc;
 	sctp_add_cmd_sf(commands, SCTP_CMD_NEW_ASOC, SCTP_ASOC(my_asoc));
 
-	/* Choose transport for INIT. */
-	sctp_add_cmd_sf(commands, SCTP_CMD_INIT_CHOOSE_TRANSPORT,
-			SCTP_CHUNK(repl));
-
 	/* After sending the INIT, "A" starts the T1-init timer and
 	 * enters the COOKIE-WAIT state.
 	 */
-- 
1.7.11.7
