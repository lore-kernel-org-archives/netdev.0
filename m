From: vyasevich@gmail.com
Subject: [PATCH] sctp: Error in calculation of RTTvar
Date: Wed, 28 Nov 2012 10:18:29 -0500
Message-ID: <1354115909-24172-1-git-send-email-vyasevich@gmail.com>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50408 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932184Ab2K1PSi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Nov 2012 10:18:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Schoch Christian <e0326715@student.tuwien.ac.at>

The calculation of RTTVAR involves the subtraction of two unsigned
numbers which
may causes rollover and results in very high values of RTTVAR when RTT > SRTT.
With this patch it is possible to set RTOmin = 1 to get the minimum of RTO at
4 times the clock granularity.

Change Notes:

v2)
        *Replaced abs() by abs64() and long by __s64, changed patch
description.

Signed-off-by: Christian Schoch <e0326715@student.tuwien.ac.at>
CC: Vlad Yasevich <vyasevich@gmail.com>
CC: Sridhar Samudrala <sri@us.ibm.com>
CC: Neil Horman <nhorman@tuxdriver.com>
CC: linux-sctp@vger.kernel.org
Acked-by: Vlad Yasevich <vyasevich@gmail.com>
Acked-by: Neil Horman <nhorman@tuxdriver.com>
---
 net/sctp/transport.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sctp/transport.c b/net/sctp/transport.c
index 953c21e..206cf52 100644
--- a/net/sctp/transport.c
+++ b/net/sctp/transport.c
@@ -331,7 +331,7 @@ void sctp_transport_update_rto(struct sctp_transport *tp, __u32 rtt)
 		 * 1/8, rto_alpha would be expressed as 3.
 		 */
 		tp->rttvar = tp->rttvar - (tp->rttvar >> net->sctp.rto_beta)
-			+ ((abs(tp->srtt - rtt)) >> net->sctp.rto_beta);
+			+ (((__u32)abs64((__s64)tp->srtt - (__s64)rtt)) >> net->sctp.rto_beta);
 		tp->srtt = tp->srtt - (tp->srtt >> net->sctp.rto_alpha)
 			+ (rtt >> net->sctp.rto_alpha);
 	} else {
-- 
1.7.7.6
