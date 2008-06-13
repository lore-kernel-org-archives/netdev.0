From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH 2/2 v2] sctp: Correclty set changeover_active for SFR-CACC
Date: Fri, 13 Jun 2008 09:58:51 -0400
Message-ID: <1213365531-10049-1-git-send-email-vladislav.yasevich@hp.com>
Cc: lksctp-developers@lists.sourceforge.net,
	linux-sctp@vger.kernel.org,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0015.houston.hp.com ([15.201.24.18]:22680 "EHLO
	g4t0015.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756013AbYFMN6x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jun 2008 09:58:53 -0400
In-Reply-To: 1213364949-9997-3-git-send-email-vladislav.yasevich@hp.com>
References: 1213364949-9997-3-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Not sure why the spacing got garbled in this patch, but here it
again and looking much better.

--

Right now, any time we set a primary transport we set
the changeover_active flag.  As a result, we invoke SFR-CACC
even when there has been no changeover events.

Only set changeover_active, when there is a true changeover
event, i.e. we had a primary path and we are changing to
another transport.

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 net/sctp/associola.c |   13 +++++++++++--
 1 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/net/sctp/associola.c b/net/sctp/associola.c
index 5326348..39f92c0 100644
--- a/net/sctp/associola.c
+++ b/net/sctp/associola.c
@@ -474,6 +474,15 @@ static void sctp_association_destroy(struct sctp_association *asoc)
 void sctp_assoc_set_primary(struct sctp_association *asoc,
 			    struct sctp_transport *transport)
 {
+	int changeover = 0;
+
+	/* it's a changeover only if we already have a primary path
+	 * that we are changing
+	 */
+	if (asoc->peer.primary_path != NULL &&
+	    asoc->peer.primary_path != transport)
+		changeover = 1 ;
+
 	asoc->peer.primary_path = transport;
 
 	/* Set a default msg_name for events. */
@@ -499,12 +508,12 @@ void sctp_assoc_set_primary(struct sctp_association *asoc,
 	 * double switch to the same destination address.
 	 */
 	if (transport->cacc.changeover_active)
-		transport->cacc.cycling_changeover = 1;
+		transport->cacc.cycling_changeover = changeover;
 
 	/* 2) The sender MUST set CHANGEOVER_ACTIVE to indicate that
 	 * a changeover has occurred.
 	 */
-	transport->cacc.changeover_active = 1;
+	transport->cacc.changeover_active = changeover;
 
 	/* 3) The sender MUST store the next TSN to be sent in
 	 * next_tsn_at_change.
-- 
1.5.3.5

