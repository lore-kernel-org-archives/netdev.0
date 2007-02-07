From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [Lksctp-developers] Fw: Intermittent SCTP multihoming breakage
Date: Wed, 07 Feb 2007 15:45:23 -0500
Message-ID: <45CA3A63.8000306@hp.com>
References: <E096369D937D3A4DB271B382850C5C5F48E60D@pysmail.eicon.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080605090903070400050701"
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net,
	Sridhar Samudrala <sri@us.ibm.com>
To: Steve Hill <steve.hill@dialogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel6.hp.com ([156.153.255.205]:35091 "EHLO atlrel6.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161222AbXBGUvf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Feb 2007 15:51:35 -0500
In-Reply-To: <E096369D937D3A4DB271B382850C5C5F48E60D@pysmail.eicon.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------080605090903070400050701
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Hi Steve

I think I've tracked this down.  Can you apply the attached patch on top
of the one I posted before and re-run your test.

With both patches, I was able flip-flop the downed interface multiple times
and in all cases path failover completed and data flow resumed.

Here is the modified script I was running:

#!/bin/sh

net1="$1"
net2="$2"

flush() {
    iptables -F
    echo "Flush"
    exit
}

trap flush EXIT

while true; do
    # clear table
    iptables -F
    echo "flushed"
    sleep 5

    # block net1
    iptables -A INPUT -i "$net1" -p sctp -j DROP
    echo "set net1"
    sleep 5

    # clear table
    iptables -F
    echo "flushed"
    sleep 5

    # block net2
    iptables -A INPUT -i "$net2" -p sctp -j DROP
    echo "set net2"
    sleep 5
done

I was able to run this script for 10 minutes sustaining the message flow.

-vlad

--------------080605090903070400050701
Content-Type: text/x-patch;
 name*0="0001-SCTP-Strike-the-transport-before-updating-rto.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename*0="0001-SCTP-Strike-the-transport-before-updating-rto.patch"

>From 72d6856f7e45a17e0910e0eacd1a01d44fafd1c0 Mon Sep 17 00:00:00 2001
From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Wed, 7 Feb 2007 14:58:25 -0500
Subject: [PATCH] [SCTP] Strike the transport before updating rto

Once we reach a poing where we exceed the max.path.retrans
strike the trasport before updating the rto.  This will force
transport switch at the right time, instead of 1 retransmit too
late.

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 net/sctp/sm_statefuns.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index fbbc9e6..801f9d6 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -4605,12 +4605,12 @@ sctp_disposition_t sctp_sf_do_6_3_3_rtx(const struct sctp_endpoint *ep,
 	 * sent as soon as cwnd allows (normally when a SACK arrives).
 	 */
 
-	/* NB: Rules E4 and F1 are implicit in R1.  */
-	sctp_add_cmd_sf(commands, SCTP_CMD_RETRAN, SCTP_TRANSPORT(transport));
-
 	/* Do some failure management (Section 8.2). */
 	sctp_add_cmd_sf(commands, SCTP_CMD_STRIKE, SCTP_TRANSPORT(transport));
 
+	/* NB: Rules E4 and F1 are implicit in R1.  */
+	sctp_add_cmd_sf(commands, SCTP_CMD_RETRAN, SCTP_TRANSPORT(transport));
+
 	return SCTP_DISPOSITION_CONSUME;
 }
 
-- 
1.5.0.rc3.g6506


--------------080605090903070400050701--
