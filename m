From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [PATCH 2/6] [DCCP]: Bug in initial acknowledgment number assignment
Date: Mon, 28 Jan 2008 10:16:12 +0000
Message-ID: <1201515376-8280-3-git-send-email-gerrit@erg.abdn.ac.uk>
References: dccp_ccid3_dccp_probe__bug_fixes
 <1201515376-8280-1-git-send-email-gerrit@erg.abdn.ac.uk>
 <1201515376-8280-2-git-send-email-gerrit@erg.abdn.ac.uk>
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org,
	Gerrit Renker <gerrit@erg.abdn.ac.uk>
To: acme@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:60470 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752571AbYA1KRM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Jan 2008 05:17:12 -0500
In-Reply-To: <1201515376-8280-2-git-send-email-gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Step 8.5 in RFC 4340 says for the newly cloned socket

           Initialize S.GAR := S.ISS,

but what in fact the code (minisocks.c) does is

           Initialize S.GAR := S.ISR,

which is wrong (typo?) -- fixed by the patch.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/minisocks.c |    7 +++----
 1 files changed, 3 insertions(+), 4 deletions(-)

--- a/net/dccp/minisocks.c
+++ b/net/dccp/minisocks.c
@@ -122,13 +122,12 @@ struct sock *dccp_create_openreq_child(struct sock *sk,
 		 *    Initialize S.GAR := S.ISS
 		 *    Set S.ISR, S.GSR, S.SWL, S.SWH from packet or Init Cookies
 		 */
+		newdp->dccps_gar = newdp->dccps_iss = dreq->dreq_iss;
+		dccp_update_gss(newsk, dreq->dreq_iss);
 
-		newdp->dccps_gar = newdp->dccps_isr = dreq->dreq_isr;
+		newdp->dccps_isr = dreq->dreq_isr;
 		dccp_update_gsr(newsk, dreq->dreq_isr);
 
-		newdp->dccps_iss = dreq->dreq_iss;
-		dccp_update_gss(newsk, dreq->dreq_iss);
-
 		/*
 		 * SWL and AWL are initially adjusted so that they are not less than
 		 * the initial Sequence Numbers received and sent, respectively:
