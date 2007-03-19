From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [PATCH 3/3][SCTP]: Increment error counters on user requested HBs.
Date: Mon, 19 Mar 2007 11:38:10 -0700
Message-ID: <1174329490.3187.13.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:60246 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030567AbXCSSjW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Mar 2007 14:39:22 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l2JIe98r005112
	for <netdev@vger.kernel.org>; Mon, 19 Mar 2007 14:40:09 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l2JIcC8x226196
	for <netdev@vger.kernel.org>; Mon, 19 Mar 2007 14:38:12 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l2JIcBuh016780
	for <netdev@vger.kernel.org>; Mon, 19 Mar 2007 14:38:12 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[SCTP]: Increment error counters on user requested HBs.

2960bis states (Section 8.3):

   D) Request an on-demand HEARTBEAT on a specific destination transport
      address of a given association.

   The endpoint should increment the respective error counter of the
   destination transport address each time a HEARTBEAT is sent to that
   address and not acknowledged within one RTO.

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

---
 net/sctp/sm_statefuns.c |   20 ++++++++++++++++++--
 1 files changed, 18 insertions(+), 2 deletions(-)

diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index 70c39ea..e9097cf 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -4342,8 +4342,24 @@ sctp_disposition_t sctp_sf_do_prm_reques
 					void *arg,
 					sctp_cmd_seq_t *commands)
 {
-	return sctp_sf_heartbeat(ep, asoc, type, (struct sctp_transport *)arg,
-				 commands);
+	if (SCTP_DISPOSITION_NOMEM == sctp_sf_heartbeat(ep, asoc, type,
+				      (struct sctp_transport *)arg, commands))
+		return SCTP_DISPOSITION_NOMEM;
+
+	/*
+	 * RFC 2960 (bis), section 8.3
+	 *
+	 *    D) Request an on-demand HEARTBEAT on a specific destination
+	 *    transport address of a given association.
+	 *
+	 *    The endpoint should increment the respective error  counter of
+	 *    the destination transport address each time a HEARTBEAT is sent
+	 *    to that address and not acknowledged within one RTO.
+	 *
+	 */
+	sctp_add_cmd_sf(commands, SCTP_CMD_TRANSPORT_RESET,
+			SCTP_TRANSPORT(arg));
+	return SCTP_DISPOSITION_CONSUME;
 }
 
 /*


