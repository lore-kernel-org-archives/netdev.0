From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH 13/13] SCTP: Always flush the queue when uncorcking.
Date: Wed,  7 Nov 2007 12:46:31 -0500
Message-ID: <1194457591442-git-send-email-vladislav.yasevich@hp.com>
References: <11944575911538-git-send-email-vladislav.yasevich@hp.com>
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel13.hp.com ([156.153.255.238]:39651 "EHLO palrel13.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755044AbXKGSFR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Nov 2007 13:05:17 -0500
In-Reply-To: <11944575911538-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When the code calls uncork, trigger a queue flush, even
if the queue was not corked.  Most callers that explicitly
cork the queue will have additional checks to see if they
corked it.  Callers who do not cork the queue expect packets
to flow when they call uncork.

The scenario that showcased this bug happened when we were not
able to bundle DATA with outgoing COOKIE-ECHO.  As a result
the data just sat in the outqueue and did not get transmitted.
The application expected a response, but nothing happened.

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 net/sctp/outqueue.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/sctp/outqueue.c b/net/sctp/outqueue.c
index 99a3db5..fa76f23 100644
--- a/net/sctp/outqueue.c
+++ b/net/sctp/outqueue.c
@@ -662,10 +662,9 @@ static int sctp_outq_flush_rtx(struct sctp_outq *q, struct sctp_packet *pkt,
 int sctp_outq_uncork(struct sctp_outq *q)
 {
 	int error = 0;
-	if (q->cork) {
+	if (q->cork)
 		q->cork = 0;
-		error = sctp_outq_flush(q, 0);
-	}
+	error = sctp_outq_flush(q, 0);
 	return error;
 }
 
-- 
1.5.2.4

