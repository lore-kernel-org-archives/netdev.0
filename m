From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [PATCH 1/3][SCTP]: Clean up stale data during association restart
Date: Mon, 19 Mar 2007 11:38:02 -0700
Message-ID: <1174329483.3187.11.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:44503 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030506AbXCSSjY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Mar 2007 14:39:24 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l2JIdNoF006599
	for <netdev@vger.kernel.org>; Mon, 19 Mar 2007 14:39:23 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l2JIc63g179170
	for <netdev@vger.kernel.org>; Mon, 19 Mar 2007 14:38:06 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l2JIc6hx011179
	for <netdev@vger.kernel.org>; Mon, 19 Mar 2007 14:38:06 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dave,

Please consider the following 3 SCTP bug fix patches for
inclusion in 2.6.21.

Thanks
Sridhar

[SCTP]: Clean up stale data during association restart

During association restart we may have stale data sitting
on the ULP queue waiting for ordering or reassembly.  This
data may cause severe problems if not cleaned up.  In particular
stale data pending ordering may cause problems with receive
window exhaustion if our peer has decided to restart the
association.

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

---
 include/net/sctp/ulpqueue.h |    1 +
 net/sctp/associola.c        |    6 ++++++
 net/sctp/ulpqueue.c         |    2 +-
 3 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/include/net/sctp/ulpqueue.h b/include/net/sctp/ulpqueue.h
index a43c878..ab26ab3 100644
--- a/include/net/sctp/ulpqueue.h
+++ b/include/net/sctp/ulpqueue.h
@@ -59,6 +59,7 @@ struct sctp_ulpq {
 /* Prototypes. */
 struct sctp_ulpq *sctp_ulpq_init(struct sctp_ulpq *,
 				 struct sctp_association *);
+void sctp_ulpq_flush(struct sctp_ulpq *ulpq);
 void sctp_ulpq_free(struct sctp_ulpq *);
 
 /* Add a new DATA chunk for processing. */
diff --git a/net/sctp/associola.c b/net/sctp/associola.c
index fa82b73..2505cd3 100644
--- a/net/sctp/associola.c
+++ b/net/sctp/associola.c
@@ -1063,6 +1063,12 @@ void sctp_assoc_update(struct sctp_assoc
 		 */
 		sctp_ssnmap_clear(asoc->ssnmap);
 
+		/* Flush the ULP reassembly and ordered queue.
+		 * Any data there will now be stale and will
+		 * cause problems.
+		 */
+		sctp_ulpq_flush(&asoc->ulpq);
+
 	} else {
 		/* Add any peer addresses from the new association. */
 		list_for_each(pos, &new->peer.transport_addr_list) {
diff --git a/net/sctp/ulpqueue.c b/net/sctp/ulpqueue.c
index f4759a9..bfb197e 100644
--- a/net/sctp/ulpqueue.c
+++ b/net/sctp/ulpqueue.c
@@ -73,7 +73,7 @@ struct sctp_ulpq *sctp_ulpq_init(struct 
 
 
 /* Flush the reassembly and ordering queues.  */
-static void sctp_ulpq_flush(struct sctp_ulpq *ulpq)
+void sctp_ulpq_flush(struct sctp_ulpq *ulpq)
 {
 	struct sk_buff *skb;
 	struct sctp_ulpevent *event;


