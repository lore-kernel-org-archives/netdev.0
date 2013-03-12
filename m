From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH] sctp: optimize searching the active path for tsns
Date: Tue, 12 Mar 2013 13:29:42 -0400
Message-ID: <1363109382-753-1-git-send-email-nhorman@tuxdriver.com>
References: <513F5120.7090209@gmail.com>
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Xufeng Zhang <xufengzhang.main@gmail.com>, vyasevich@gmail.com,
	davem@davemloft.net, netdev@vger.kernel.org
To: linux-sctp@vger.kernel-org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:33703 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754960Ab3CLRaJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Mar 2013 13:30:09 -0400
In-Reply-To: <513F5120.7090209@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SCTP currently attempts to optimize the search for tsns on a transport by first
checking the active_path, then searching alternate transports.  This operation
however is a bit convoluted, as we explicitly search the active path, then serch
all other transports, skipping the active path, when its detected.  Lets
optimize this by preforming a move to front on the transport_addr_list every
time the active_path is changed.  The active_path changes occur in relatively
non-critical paths, and doing so allows us to just search the
transport_addr_list in order, avoiding an extra conditional check in the
relatively hot tsn lookup path.  This also happens to fix a bug where we break
out of the for loop early in the tsn lookup.

CC: Xufeng Zhang <xufengzhang.main@gmail.com>
CC: vyasevich@gmail.com
CC: davem@davemloft.net
CC: netdev@vger.kernel.org
---
 net/sctp/associola.c | 31 ++++++++++++-------------------
 1 file changed, 12 insertions(+), 19 deletions(-)

diff --git a/net/sctp/associola.c b/net/sctp/associola.c
index 43cd0dd..7af96b3 100644
--- a/net/sctp/associola.c
+++ b/net/sctp/associola.c
@@ -513,8 +513,11 @@ void sctp_assoc_set_primary(struct sctp_association *asoc,
 	 * user wants to use this new path.
 	 */
 	if ((transport->state == SCTP_ACTIVE) ||
-	    (transport->state == SCTP_UNKNOWN))
+	    (transport->state == SCTP_UNKNOWN)) {
+		list_del_rcu(&transport->transports);
+		list_add_rcu(&transport->transports, &asoc->peer.transport_addr_list);
 		asoc->peer.active_path = transport;
+	}
 
 	/*
 	 * SFR-CACC algorithm:
@@ -964,6 +967,10 @@ void sctp_assoc_control_transport(struct sctp_association *asoc,
 	}
 
 	/* Set the active and retran transports.  */
+	if (asoc->peer.active_path != first) {
+		list_del_rcu(first);
+		list_add_rcu(first, &asoc->peer.transport_addr_list);
+	}
 	asoc->peer.active_path = first;
 	asoc->peer.retran_path = second;
 }
@@ -1040,7 +1047,6 @@ struct sctp_chunk *sctp_get_ecne_prepend(struct sctp_association *asoc)
 struct sctp_transport *sctp_assoc_lookup_tsn(struct sctp_association *asoc,
 					     __u32 tsn)
 {
-	struct sctp_transport *active;
 	struct sctp_transport *match;
 	struct sctp_transport *transport;
 	struct sctp_chunk *chunk;
@@ -1057,29 +1063,16 @@ struct sctp_transport *sctp_assoc_lookup_tsn(struct sctp_association *asoc,
 	 * The general strategy is to search each transport's transmitted
 	 * list.   Return which transport this TSN lives on.
 	 *
-	 * Let's be hopeful and check the active_path first.
-	 * Another optimization would be to know if there is only one
-	 * outbound path and not have to look for the TSN at all.
+	 * Note, that sctp_assoc_set_primary does a move to front operation
+	 * on the active_path transport, so this code implicitly checks
+	 * the active_path first, as we most commonly expect to find our TSN
+	 * there.
 	 *
 	 */
 
-	active = asoc->peer.active_path;
-
-	list_for_each_entry(chunk, &active->transmitted,
-			transmitted_list) {
-
-		if (key == chunk->subh.data_hdr->tsn) {
-			match = active;
-			goto out;
-		}
-	}
-
-	/* If not found, go search all the other transports. */
 	list_for_each_entry(transport, &asoc->peer.transport_addr_list,
 			transports) {
 
-		if (transport == active)
-			break;
 		list_for_each_entry(chunk, &transport->transmitted,
 				transmitted_list) {
 			if (key == chunk->subh.data_hdr->tsn) {
-- 
1.7.11.7
