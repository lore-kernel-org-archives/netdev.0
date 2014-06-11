From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 2/5] net: sctp: refactor active path selection
Date: Wed, 11 Jun 2014 16:34:54 +0200
Message-ID: <1402497297-27100-3-git-send-email-dborkman@redhat.com>
References: <1402497297-27100-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:3905 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752187AbaFKOfF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jun 2014 10:35:05 -0400
In-Reply-To: <1402497297-27100-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch just refactors and moves the code for the active
path selection into its own helper function outside of
sctp_assoc_control_transport() which is already big enough.
No functional changes here.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 net/sctp/associola.c | 120 ++++++++++++++++++++++++++-------------------------
 1 file changed, 61 insertions(+), 59 deletions(-)

diff --git a/net/sctp/associola.c b/net/sctp/associola.c
index 39579c3..9f1cc6f 100644
--- a/net/sctp/associola.c
+++ b/net/sctp/associola.c
@@ -55,6 +55,7 @@
 #include <net/sctp/sm.h>
 
 /* Forward declarations for internal functions. */
+static void sctp_select_active_and_retran_path(struct sctp_association *asoc);
 static void sctp_assoc_bh_rcv(struct work_struct *work);
 static void sctp_assoc_free_asconf_acks(struct sctp_association *asoc);
 static void sctp_assoc_free_asconf_queue(struct sctp_association *asoc);
@@ -774,9 +775,6 @@ void sctp_assoc_control_transport(struct sctp_association *asoc,
 				  sctp_transport_cmd_t command,
 				  sctp_sn_error_t error)
 {
-	struct sctp_transport *t = NULL;
-	struct sctp_transport *first;
-	struct sctp_transport *second;
 	struct sctp_ulpevent *event;
 	struct sockaddr_storage addr;
 	int spc_state = 0;
@@ -829,13 +827,14 @@ void sctp_assoc_control_transport(struct sctp_association *asoc,
 		return;
 	}
 
-	/* Generate and send a SCTP_PEER_ADDR_CHANGE notification to the
-	 * user.
+	/* Generate and send a SCTP_PEER_ADDR_CHANGE notification
+	 * to the user.
 	 */
 	if (ulp_notify) {
 		memset(&addr, 0, sizeof(struct sockaddr_storage));
 		memcpy(&addr, &transport->ipaddr,
 		       transport->af_specific->sockaddr_len);
+
 		event = sctp_ulpevent_make_peer_addr_change(asoc, &addr,
 					0, spc_state, error, GFP_ATOMIC);
 		if (event)
@@ -843,60 +842,7 @@ void sctp_assoc_control_transport(struct sctp_association *asoc,
 	}
 
 	/* Select new active and retran paths. */
-
-	/* Look for the two most recently used active transports.
-	 *
-	 * This code produces the wrong ordering whenever jiffies
-	 * rolls over, but we still get usable transports, so we don't
-	 * worry about it.
-	 */
-	first = NULL; second = NULL;
-
-	list_for_each_entry(t, &asoc->peer.transport_addr_list,
-			transports) {
-
-		if ((t->state == SCTP_INACTIVE) ||
-		    (t->state == SCTP_UNCONFIRMED) ||
-		    (t->state == SCTP_PF))
-			continue;
-		if (!first || t->last_time_heard > first->last_time_heard) {
-			second = first;
-			first = t;
-		} else if (!second ||
-			   t->last_time_heard > second->last_time_heard)
-			second = t;
-	}
-
-	/* RFC 2960 6.4 Multi-Homed SCTP Endpoints
-	 *
-	 * By default, an endpoint should always transmit to the
-	 * primary path, unless the SCTP user explicitly specifies the
-	 * destination transport address (and possibly source
-	 * transport address) to use.
-	 *
-	 * [If the primary is active but not most recent, bump the most
-	 * recently used transport.]
-	 */
-	if (((asoc->peer.primary_path->state == SCTP_ACTIVE) ||
-	     (asoc->peer.primary_path->state == SCTP_UNKNOWN)) &&
-	    first != asoc->peer.primary_path) {
-		second = first;
-		first = asoc->peer.primary_path;
-	}
-
-	if (!second)
-		second = first;
-	/* If we failed to find a usable transport, just camp on the
-	 * primary, even if it is inactive.
-	 */
-	if (!first) {
-		first = asoc->peer.primary_path;
-		second = asoc->peer.primary_path;
-	}
-
-	/* Set the active and retran transports.  */
-	asoc->peer.active_path = first;
-	asoc->peer.retran_path = second;
+	sctp_select_active_and_retran_path(asoc);
 }
 
 /* Hold a reference to an association. */
@@ -1325,6 +1271,62 @@ void sctp_assoc_update_retran_path(struct sctp_association *asoc)
 		 __func__, asoc, &asoc->peer.retran_path->ipaddr.sa);
 }
 
+static void sctp_select_active_and_retran_path(struct sctp_association *asoc)
+{
+	struct sctp_transport *trans, *trans_pri = NULL, *trans_sec = NULL;
+
+	/* Look for the two most recently used active transports. */
+	list_for_each_entry(trans, &asoc->peer.transport_addr_list,
+			    transports) {
+		if (trans->state == SCTP_INACTIVE ||
+		    trans->state == SCTP_UNCONFIRMED ||
+		    trans->state == SCTP_PF)
+			continue;
+		if (trans_pri == NULL ||
+		    trans->last_time_heard > trans_pri->last_time_heard) {
+			trans_sec = trans_pri;
+			trans_pri = trans;
+		} else if (trans_sec == NULL ||
+			   trans->last_time_heard > trans_sec->last_time_heard) {
+			trans_sec = trans;
+		}
+	}
+
+	/* RFC 2960 6.4 Multi-Homed SCTP Endpoints
+	 *
+	 * By default, an endpoint should always transmit to the primary
+	 * path, unless the SCTP user explicitly specifies the
+	 * destination transport address (and possibly source transport
+	 * address) to use. [If the primary is active but not most recent,
+	 * bump the most recently used transport.]
+	 */
+	if ((asoc->peer.primary_path->state == SCTP_ACTIVE ||
+	     asoc->peer.primary_path->state == SCTP_UNKNOWN) &&
+	     asoc->peer.primary_path != trans_pri) {
+		trans_sec = trans_pri;
+		trans_pri = asoc->peer.primary_path;
+	}
+
+	/* We did not find anything useful for a possible retransmission
+	 * path; either primary path that we found is the the same as
+	 * the current one, or we didn't generally find an active one.
+	 */
+	if (trans_sec == NULL)
+		trans_sec = trans_pri;
+
+	/* If we failed to find a usable transport, just camp on the
+	 * primary, even if they are inactive.
+	 */
+	if (trans_pri == NULL) {
+		trans_pri = asoc->peer.primary_path;
+		trans_sec = asoc->peer.primary_path;
+	}
+
+	/* Set the active and retran transports. */
+	asoc->peer.active_path = trans_pri;
+	asoc->peer.retran_path = trans_sec;
+}
+
 struct sctp_transport *
 sctp_assoc_choose_alter_transport(struct sctp_association *asoc,
 				  struct sctp_transport *last_sent_to)
-- 
1.7.11.7
