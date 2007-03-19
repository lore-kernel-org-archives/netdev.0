From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [PATCH 2/3][SCTP]: Reset some transport and association variables
	on restart
Date: Mon, 19 Mar 2007 11:38:05 -0700
Message-ID: <1174329486.3187.12.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:56183 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030567AbXCSSiM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Mar 2007 14:38:12 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l2JIc8Dv032438
	for <netdev@vger.kernel.org>; Mon, 19 Mar 2007 14:38:08 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l2JIc8E5179948
	for <netdev@vger.kernel.org>; Mon, 19 Mar 2007 14:38:08 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l2JIc7kL032414
	for <netdev@vger.kernel.org>; Mon, 19 Mar 2007 14:38:08 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[SCTP]: Reset some transport and association variables on restart

If the association has been restarted, we need to reset the
transport congestion variables as well as accumulated error
counts and CACC variables.  If we do not, the association
will use the wrong values and may terminate prematurely.

This was found with a scenario where the peer restarted
the association when lksctp was in the last HB timeout for
its association.  The restart happened, but the error counts
have not been reset and when the timeout occurred, a newly
restarted association was terminated due to excessive
retransmits.

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

---
 include/net/sctp/structs.h |    1 +
 net/sctp/associola.c       |    9 +++++++++
 net/sctp/transport.c       |   32 ++++++++++++++++++++++++++++++++
 3 files changed, 42 insertions(+), 0 deletions(-)

diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 31a8e88..f431acf 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -1002,6 +1002,7 @@ void sctp_transport_update_rto(struct sc
 void sctp_transport_raise_cwnd(struct sctp_transport *, __u32, __u32);
 void sctp_transport_lower_cwnd(struct sctp_transport *, sctp_lower_cwnd_t);
 unsigned long sctp_transport_timeout(struct sctp_transport *);
+void sctp_transport_reset(struct sctp_transport *);
 
 
 /* This is the structure we use to queue packets as they come into
diff --git a/net/sctp/associola.c b/net/sctp/associola.c
index 2505cd3..78d2ddb 100644
--- a/net/sctp/associola.c
+++ b/net/sctp/associola.c
@@ -1046,6 +1046,9 @@ void sctp_assoc_update(struct sctp_assoc
 		trans = list_entry(pos, struct sctp_transport, transports);
 		if (!sctp_assoc_lookup_paddr(new, &trans->ipaddr))
 			sctp_assoc_del_peer(asoc, &trans->ipaddr);
+
+		if (asoc->state >= SCTP_STATE_ESTABLISHED)
+			sctp_transport_reset(trans);
 	}
 
 	/* If the case is A (association restart), use
@@ -1069,6 +1072,12 @@ void sctp_assoc_update(struct sctp_assoc
 		 */
 		sctp_ulpq_flush(&asoc->ulpq);
 
+		/* reset the overall association error count so
+		 * that the restarted association doesn't get torn
+		 * down on the next retransmission timer.
+		 */
+		asoc->overall_error_count = 0;
+
 	} else {
 		/* Add any peer addresses from the new association. */
 		list_for_each(pos, &new->peer.transport_addr_list) {
diff --git a/net/sctp/transport.c b/net/sctp/transport.c
index a596f53..c4699f5 100644
--- a/net/sctp/transport.c
+++ b/net/sctp/transport.c
@@ -526,3 +526,35 @@ unsigned long sctp_transport_timeout(str
 	timeout += jiffies;
 	return timeout;
 }
+
+/* Reset transport variables to their initial values */
+void sctp_transport_reset(struct sctp_transport *t)
+{
+	struct sctp_association *asoc = t->asoc;
+
+	/* RFC 2960 (bis), Section 5.2.4
+	 * All the congestion control parameters (e.g., cwnd, ssthresh)
+	 * related to this peer MUST be reset to their initial values
+	 * (see Section 6.2.1)
+	 */
+	t->cwnd = min(4*asoc->pathmtu, max_t(__u32, 2*asoc->pathmtu, 4380));
+	t->ssthresh = SCTP_DEFAULT_MAXWINDOW;
+	t->rto = asoc->rto_initial;
+	t->rtt = 0;
+	t->srtt = 0;
+	t->rttvar = 0;
+
+	/* Reset these additional varibles so that we have a clean
+	 * slate.
+	 */
+	t->partial_bytes_acked = 0;
+	t->flight_size = 0;
+	t->error_count = 0;
+	t->rto_pending = 0;
+
+	/* Initialize the state information for SFR-CACC */
+	t->cacc.changeover_active = 0;
+	t->cacc.cycling_changeover = 0;
+	t->cacc.next_tsn_at_change = 0;
+	t->cacc.cacc_saw_newack = 0;
+}


