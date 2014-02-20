From: Matija Glavinic Pecotic <matija.glavinic-pecotic.ext@nsn.com>
Subject: [PATCH] net: sctp: Potentially-Failed state should not be reached
 from unconfirmed state
Date: Thu, 20 Feb 2014 14:13:04 +0100
Message-ID: <5305FF60.80404@nsn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from demumfd002.nsn-inter.net ([93.183.12.31]:12394 "EHLO
	demumfd002.nsn-inter.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753876AbaBTNOG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Feb 2014 08:14:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In current implementation it is possible to reach PF state from unconfirmed.
We can interpret sctp-failover-02 in a way that PF state is meant to be reached
only from active state, in the end, this is when entering PF state makes sense.
Here are few quotes from sctp-failover-02, but regardless of these, same
understanding can be reached from whole section 5:

Section 5.1, quickfailover guide:
    "The PF state is an intermediate state between Active and Failed states."

    "Each time the T3-rtx timer expires on an active or idle
    destination, the error counter of that destination address will 
    be incremented.  When the value in the error counter exceeds
    PFMR, the endpoint should mark the destination transport address as PF."

There are several concrete reasons for such interpretation. For start, rfc4960
does not take into concern quickfailover algorithm. Therefore, quickfailover
must comply to 4960. Point where this compliance can be argued is following
behavior:
When PF is entered, association overall error counter is incremented for each
missed HB. This is contradictory to rfc4960, as address, while in unconfirmed
state, is subjected to probing, and while it is probed, it should not increment
association overall error counter. This has as a consequence that we might end
up in situation in which we drop association due path failure on unconfirmed
address, in case we have wrong configuration in a way:
Association.Max.Retrans == Path.Max.Retrans.

Another reason is that entering PF from unconfirmed will cause a loss of address
confirmed event when address is once (if) confirmed. This is fine from failover
guide point of view, but it is not consistent with behavior preceding failover
implementation and recommendation from 4960:

5.4.  Path Verification
   Whenever a path is confirmed, an indication MAY be given to the upper
   layer.

Signed-off-by: Matija Glavinic Pecotic <matija.glavinic-pecotic.ext@nsn.com>

--- net-next.orig/net/sctp/sm_sideeffect.c
+++ net-next/net/sctp/sm_sideeffect.c
@@ -495,11 +495,12 @@ static void sctp_do_8_2_transport_strike
 	}
 
 	/* If the transport error count is greater than the pf_retrans
-	 * threshold, and less than pathmaxrtx, then mark this transport
-	 * as Partially Failed, ee SCTP Quick Failover Draft, secon 5.1,
-	 * point 1
+	 * threshold, and less than pathmaxrtx, and if the current state
+	 * is not SCTP_UNCONFIRMED, then mark this transport as Partially
+	 * Failed, see SCTP Quick Failover Draft, section 5.1
 	 */
 	if ((transport->state != SCTP_PF) &&
+	   (transport->state != SCTP_UNCONFIRMED) &&
 	   (asoc->pf_retrans < transport->pathmaxrxt) &&
 	   (transport->error_count > asoc->pf_retrans)) {
 
