From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH 2/2] sctp: Fix oops when INIT-ACK indicates that peer doesn't support AUTH
Date: Thu, 18 Sep 2008 17:31:04 -0400
Message-ID: <1221773464-28845-2-git-send-email-vladislav.yasevich@hp.com>
References: <1221773464-28845-1-git-send-email-vladislav.yasevich@hp.com>
Cc: linux-sctp@vger.kernel.org,
	lksctp-developers@lists.sourceforge.net, netdev@vger.kernel.org,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0026.austin.hp.com ([15.216.28.33]:14434 "EHLO
	g1t0026.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754741AbYIRVbK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Sep 2008 17:31:10 -0400
In-Reply-To: <1221773464-28845-1-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If INIT-ACK is received with SupportedExtensions parameter which
indicates that the peer does not support AUTH, the packet will be
silently ignore, and sctp_process_init() do cleanup all of the
transports in the association.
When T1-Init timer is expires, OOPS happen while we try to choose
a different init transport.

The solution is to only clean up the non-active transports, i.e
the ones that the peer added.  However, that introduces a problem
with sctp_connectx(), because we don't mark the proper state for
the transports provided by the user.  So, we'll simply mark
user-provided transports as ACTIVE.  That will allow INIT
retransmissions to work properly in the sctp_connectx() context
and prevent the crash.

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 net/sctp/associola.c     |    9 +++++----
 net/sctp/sm_make_chunk.c |    6 ++----
 2 files changed, 7 insertions(+), 8 deletions(-)

diff --git a/net/sctp/associola.c b/net/sctp/associola.c
index 8472b8b..abd51ce 100644
--- a/net/sctp/associola.c
+++ b/net/sctp/associola.c
@@ -599,11 +599,12 @@ struct sctp_transport *sctp_assoc_add_peer(struct sctp_association *asoc,
 	/* Check to see if this is a duplicate. */
 	peer = sctp_assoc_lookup_paddr(asoc, addr);
 	if (peer) {
+		/* An UNKNOWN state is only set on transports added by
+		 * user in sctp_connectx() call.  Such transports should be
+		 * considered CONFIRMED per RFC 4960, Section 5.4.
+		 */
 		if (peer->state == SCTP_UNKNOWN) {
-			if (peer_state == SCTP_ACTIVE)
-				peer->state = SCTP_ACTIVE;
-			if (peer_state == SCTP_UNCONFIRMED)
-				peer->state = SCTP_UNCONFIRMED;
+			peer->state = SCTP_ACTIVE;
 		}
 		return peer;
 	}
diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index fe94f42..b599cbb 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -2321,12 +2321,10 @@ clean_up:
 	/* Release the transport structures. */
 	list_for_each_safe(pos, temp, &asoc->peer.transport_addr_list) {
 		transport = list_entry(pos, struct sctp_transport, transports);
-		list_del_init(pos);
-		sctp_transport_free(transport);
+		if (transport->state != SCTP_ACTIVE)
+			sctp_assoc_rm_peer(asoc, transport);
 	}
 
-	asoc->peer.transport_count = 0;
-
 nomem:
 	return 0;
 }
-- 
1.5.3.5

