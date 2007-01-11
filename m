From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [PATCH 4/4] [SCTP]: Fix SACK sequence during shutdown
Date: Thu, 11 Jan 2007 11:41:32 -0800
Message-ID: <1168544492.22592.21.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:54075 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751452AbXAKTlw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Jan 2007 14:41:52 -0500
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e5.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id l0BJffoA016629
	for <netdev@vger.kernel.org>; Thu, 11 Jan 2007 14:41:41 -0500
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id l0BJffc1289826
	for <netdev@vger.kernel.org>; Thu, 11 Jan 2007 14:41:41 -0500
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l0BJfeNg019849
	for <netdev@vger.kernel.org>; Thu, 11 Jan 2007 14:41:41 -0500
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[SCTP]: Fix SACK sequence during shutdown

Currently, when association enters SHUTDOWN state,the
implementation will SACK any DATA first and then transmit
the SHUTDOWN chunk.  This is against the order required by
2960bis spec.  SHUTDOWN must always be first, followed by
SACK. This change forces this order and also enables bundling.

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

---
 net/sctp/sm_sideeffect.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
index 7bbc615..8bd3097 100644
--- a/net/sctp/sm_sideeffect.c
+++ b/net/sctp/sm_sideeffect.c
@@ -217,7 +217,7 @@ static int sctp_gen_sack(struct sctp_association *asoc, int force,

 		asoc->peer.sack_needed = 0;

-		error = sctp_outq_tail(&asoc->outqueue, sack);
+		sctp_add_cmd_sf(commands, SCTP_CMD_REPLY, SCTP_CHUNK(sack));

 		/* Stop the SACK timer.  */
 		sctp_add_cmd_sf(commands, SCTP_CMD_TIMER_STOP,
--

