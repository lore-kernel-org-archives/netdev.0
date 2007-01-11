From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [PATCH 3/4] [SCTP]: Correctly handle unexpected INIT-ACK chunk.
Date: Thu, 11 Jan 2007 11:41:29 -0800
Message-ID: <1168544489.22592.20.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:58327 "EHLO e3.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751443AbXAKTli (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Jan 2007 14:41:38 -0500
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e3.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id l0BJfeRn024398
	for <netdev@vger.kernel.org>; Thu, 11 Jan 2007 14:41:40 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id l0BJfbdT243364
	for <netdev@vger.kernel.org>; Thu, 11 Jan 2007 14:41:37 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l0BJfbkr019883
	for <netdev@vger.kernel.org>; Thu, 11 Jan 2007 14:41:37 -0500
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[SCTP]: Correctly handle unexpected INIT-ACK chunk.

Consider the chunk as Out-of-the-Blue if we don't have
an endpoint.  Otherwise discard it as before.

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

---
 include/net/sctp/sm.h    |    1 +
 net/sctp/sm_statefuns.c  |   22 ++++++++++++++++++++++
 net/sctp/sm_statetable.c |    2 +-
 3 files changed, 24 insertions(+), 1 deletions(-)

diff --git a/include/net/sctp/sm.h b/include/net/sctp/sm.h
index 3269ed1..73cb994 100644
--- a/include/net/sctp/sm.h
+++ b/include/net/sctp/sm.h
@@ -134,6 +134,7 @@ sctp_state_fn_t sctp_sf_violation;
 sctp_state_fn_t sctp_sf_discard_chunk;
 sctp_state_fn_t sctp_sf_do_5_2_1_siminit;
 sctp_state_fn_t sctp_sf_do_5_2_2_dupinit;
+sctp_state_fn_t sctp_sf_do_5_2_3_initack;
 sctp_state_fn_t sctp_sf_do_5_2_4_dupcook;
 sctp_state_fn_t sctp_sf_unk_chunk;
 sctp_state_fn_t sctp_sf_do_8_5_1_E_sa;
diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index 2c165dc..a10c3a8 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -1534,6 +1534,28 @@ sctp_disposition_t sctp_sf_do_5_2_2_dupinit(const struct sctp_endpoint *ep,
 }


+/*
+ * Unexpected INIT-ACK handler.
+ *
+ * Section 5.2.3
+ * If an INIT ACK received by an endpoint in any state other than the
+ * COOKIE-WAIT state, the endpoint should discard the INIT ACK chunk.
+ * An unexpected INIT ACK usually indicates the processing of an old or
+ * duplicated INIT chunk.
+*/
+sctp_disposition_t sctp_sf_do_5_2_3_initack(const struct sctp_endpoint *ep,
+					    const struct sctp_association *asoc,
+					    const sctp_subtype_t type,
+					    void *arg, sctp_cmd_seq_t *commands)
+{
+	/* Per the above section, we'll discard the chunk if we have an
+	 * endpoint.  If this is an OOTB INIT-ACK, treat it as such.
+	 */
+        if (ep == sctp_sk((sctp_get_ctl_sock()))->ep)
+		return sctp_sf_ootb(ep, asoc, type, arg, commands);
+	else
+		return sctp_sf_discard_chunk(ep, asoc, type, arg, commands);
+}

 /* Unexpected COOKIE-ECHO handler for peer restart (Table 2, action 'A')
  *
diff --git a/net/sctp/sm_statetable.c b/net/sctp/sm_statetable.c
index 733dd87..5f6cc7a 100644
--- a/net/sctp/sm_statetable.c
+++ b/net/sctp/sm_statetable.c
@@ -152,7 +152,7 @@ const sctp_sm_table_entry_t *sctp_sm_lookup_event(sctp_event_t event_type,
 	/* SCTP_STATE_EMPTY */ \
 	TYPE_SCTP_FUNC(sctp_sf_ootb), \
 	/* SCTP_STATE_CLOSED */ \
-	TYPE_SCTP_FUNC(sctp_sf_discard_chunk), \
+	TYPE_SCTP_FUNC(sctp_sf_do_5_2_3_initack), \
 	/* SCTP_STATE_COOKIE_WAIT */ \
 	TYPE_SCTP_FUNC(sctp_sf_do_5_1C_ack), \
 	/* SCTP_STATE_COOKIE_ECHOED */ \
--

