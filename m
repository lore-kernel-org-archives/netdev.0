From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH 2.6.25 2/9] SCTP: Handle the wildcard ADD-IP Address parameter
Date: Mon, 17 Dec 2007 16:32:42 -0500
Message-ID: <1197927169-5106-3-git-send-email-vladislav.yasevich@hp.com>
References: <1197927169-5106-1-git-send-email-vladislav.yasevich@hp.com>
Cc: lksctp-developers@lists.sourceforge.net,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0009.atlanta.hp.com ([15.192.0.46]:34181 "EHLO
	g5t0009.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759947AbXLQVcw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Dec 2007 16:32:52 -0500
In-Reply-To: <1197927169-5106-1-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Address Parameter in the parameter list of the ASCONF chunk
may be a wildcard address.  In this case special processing
is required.  For the 'add' case, the source IP of the packet is
added.  In the 'del' case, all addresses except the source IP
of packet are removed. In the "mark primary" case, the source
address is marked as primary.

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 include/net/sctp/structs.h |    2 ++
 net/sctp/associola.c       |   17 +++++++++++++++++
 net/sctp/sm_make_chunk.c   |   40 ++++++++++++++++++++++++++++++++++++----
 3 files changed, 55 insertions(+), 4 deletions(-)

diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 002a00a..55acadc 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -1938,6 +1938,8 @@ void sctp_assoc_rwnd_increase(struct sctp_association *, unsigned);
 void sctp_assoc_rwnd_decrease(struct sctp_association *, unsigned);
 void sctp_assoc_set_primary(struct sctp_association *,
 			    struct sctp_transport *);
+void sctp_assoc_del_nonprimary_peers(struct sctp_association *,
+				    struct sctp_transport *);
 int sctp_assoc_set_bind_addr_from_ep(struct sctp_association *,
 				     gfp_t);
 int sctp_assoc_set_bind_addr_from_cookie(struct sctp_association *,
diff --git a/net/sctp/associola.c b/net/sctp/associola.c
index 33ae9b0..61bebb9 100644
--- a/net/sctp/associola.c
+++ b/net/sctp/associola.c
@@ -730,6 +730,23 @@ struct sctp_transport *sctp_assoc_lookup_paddr(
 	return NULL;
 }
 
+/* Remove all transports except a give one */
+void sctp_assoc_del_nonprimary_peers(struct sctp_association *asoc,
+				     struct sctp_transport *primary)
+{
+	struct sctp_transport	*temp;
+	struct sctp_transport	*t;
+
+	list_for_each_entry_safe(t, temp, &asoc->peer.transport_addr_list,
+				 transports) {
+		/* if the current transport is not the primary one, delete it */
+		if (t != primary)
+			sctp_assoc_rm_peer(asoc, t);
+	}
+
+	return;
+}
+
 /* Engage in transport control operations.
  * Mark the transport up or down and send a notification to the user.
  * Select and update the new active and retran paths.
diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index f487629..00598ee 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -2721,7 +2721,6 @@ static __be16 sctp_process_asconf_param(struct sctp_association *asoc,
 	struct sctp_transport *peer;
 	struct sctp_af *af;
 	union sctp_addr	addr;
-	struct list_head *pos;
 	union sctp_addr_param *addr_param;
 
 	addr_param = (union sctp_addr_param *)
@@ -2732,8 +2731,24 @@ static __be16 sctp_process_asconf_param(struct sctp_association *asoc,
 		return SCTP_ERROR_INV_PARAM;
 
 	af->from_addr_param(&addr, addr_param, htons(asoc->peer.port), 0);
+
+	/* ADDIP 4.2.1  This parameter MUST NOT contain a broadcast
+	 * or multicast address.
+	 * (note: wildcard is permitted and requires special handling so
+	 *  make sure we check for that)
+	 */
+	if (!af->is_any(&addr) && !af->addr_valid(&addr, NULL, asconf->skb))
+		return SCTP_ERROR_INV_PARAM;
+
 	switch (asconf_param->param_hdr.type) {
 	case SCTP_PARAM_ADD_IP:
+		/* Section 4.2.1:
+		 * If the address 0.0.0.0 or ::0 is provided, the source
+		 * address of the packet MUST be added.
+		 */
+		if (af->is_any(&addr))
+			memcpy(&addr, &asconf->source, sizeof(addr));
+
 		/* ADDIP 4.3 D9) If an endpoint receives an ADD IP address
 		 * request and does not have the local resources to add this
 		 * new address to the association, it MUST return an Error
@@ -2755,8 +2770,7 @@ static __be16 sctp_process_asconf_param(struct sctp_association *asoc,
 		 * MUST send an Error Cause TLV with the error cause set to the
 		 * new error code 'Request to Delete Last Remaining IP Address'.
 		 */
-		pos = asoc->peer.transport_addr_list.next;
-		if (pos->next == &asoc->peer.transport_addr_list)
+		if (asoc->peer.transport_count == 1)
 			return SCTP_ERROR_DEL_LAST_IP;
 
 		/* ADDIP 4.3 D8) If a request is received to delete an IP
@@ -2769,9 +2783,27 @@ static __be16 sctp_process_asconf_param(struct sctp_association *asoc,
 		if (sctp_cmp_addr_exact(sctp_source(asconf), &addr))
 			return SCTP_ERROR_DEL_SRC_IP;
 
-		sctp_assoc_del_peer(asoc, &addr);
+		/* Section 4.2.2
+		 * If the address 0.0.0.0 or ::0 is provided, all
+		 * addresses of the peer except	the source address of the
+		 * packet MUST be deleted.
+		 */
+		if (af->is_any(&addr)) {
+			sctp_assoc_set_primary(asoc, asconf->transport);
+			sctp_assoc_del_nonprimary_peers(asoc,
+							asconf->transport);
+		} else
+			sctp_assoc_del_peer(asoc, &addr);
 		break;
 	case SCTP_PARAM_SET_PRIMARY:
+		/* ADDIP Section 4.2.4
+		 * If the address 0.0.0.0 or ::0 is provided, the receiver
+		 * MAY mark the source address of the packet as its
+		 * primary.
+		 */
+		if (af->is_any(&addr))
+			memcpy(&addr.v4, sctp_source(asconf), sizeof(addr));
+
 		peer = sctp_assoc_lookup_paddr(asoc, &addr);
 		if (!peer)
 			return SCTP_ERROR_INV_PARAM;
-- 
1.5.3.5

