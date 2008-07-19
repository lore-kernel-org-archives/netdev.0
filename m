From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH 2/7] sctp: Prevent uninitialized memory access
Date: Sat, 19 Jul 2008 00:26:47 -0400
Message-ID: <1216441615995-git-send-email-vladislav.yasevich@hp.com>
References: <12164416121552-git-send-email-vladislav.yasevich@hp.com>
Cc: davem@davemloft.net, linux-sctp@vger.kernel.org,
	Florian Westphal <fw@strlen.de>,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0015.houston.hp.com ([15.201.24.18]:38487 "EHLO
	g4t0015.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752485AbYGSE2W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Jul 2008 00:28:22 -0400
In-Reply-To: <12164416121552-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

valgrind reports uninizialized memory accesses when running
sctp inside the network simulation cradle simulator:

 Conditional jump or move depends on uninitialised value(s)
    at 0x570E34A: sctp_assoc_sync_pmtu (associola.c:1324)
    by 0x57427DA: sctp_packet_transmit (output.c:403)
    by 0x5710EFF: sctp_outq_flush (outqueue.c:824)
    by 0x5710B88: sctp_outq_uncork (outqueue.c:701)
    by 0x5745262: sctp_cmd_interpreter (sm_sideeffect.c:1548)
    by 0x57444B7: sctp_side_effects (sm_sideeffect.c:976)
    by 0x5744460: sctp_do_sm (sm_sideeffect.c:945)
    by 0x572157D: sctp_primitive_ASSOCIATE (primitive.c:94)
    by 0x5725C04: __sctp_connect (socket.c:1094)
    by 0x57297DC: sctp_connect (socket.c:3297)

 Conditional jump or move depends on uninitialised value(s)
    at 0x575D3A5: mod_timer (timer.c:630)
    by 0x5752B78: sctp_cmd_hb_timers_start (sm_sideeffect.c:555)
    by 0x5754133: sctp_cmd_interpreter (sm_sideeffect.c:1448)
    by 0x5753607: sctp_side_effects (sm_sideeffect.c:976)
    by 0x57535B0: sctp_do_sm (sm_sideeffect.c:945)
    by 0x571E9AE: sctp_endpoint_bh_rcv (endpointola.c:474)
    by 0x573347F: sctp_inq_push (inqueue.c:104)
    by 0x572EF93: sctp_rcv (input.c:256)
    by 0x5689623: ip_local_deliver_finish (ip_input.c:230)
    by 0x5689759: ip_local_deliver (ip_input.c:268)
    by 0x5689CAC: ip_rcv_finish (dst.h:246)

#1 is due to "if (t->pmtu_pending)".
8a4794914f9cf2681235ec2311e189fe307c28c7 "[SCTP] Flag a pmtu change request"
suggests it should be initialized to 0.

#2 is the heartbeat timer 'expires' value, which is uninizialised, but
test by mod_timer().
T3_rtx_timer seems to be affected by the same problem, so initialize it, too.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 net/sctp/associola.c |    1 +
 net/sctp/transport.c |    3 +++
 2 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/net/sctp/associola.c b/net/sctp/associola.c
index 35b6a02..ec2a0a3 100644
--- a/net/sctp/associola.c
+++ b/net/sctp/associola.c
@@ -653,6 +653,7 @@ struct sctp_transport *sctp_assoc_add_peer(struct sctp_association *asoc,
 
 	SCTP_DEBUG_PRINTK("sctp_assoc_add_peer:association %p PMTU set to "
 			  "%d\n", asoc, asoc->pathmtu);
+	peer->pmtu_pending = 0;
 
 	asoc->frag_point = sctp_frag_point(sp, asoc->pathmtu);
 
diff --git a/net/sctp/transport.c b/net/sctp/transport.c
index 3f34f61..e745c11 100644
--- a/net/sctp/transport.c
+++ b/net/sctp/transport.c
@@ -100,6 +100,9 @@ static struct sctp_transport *sctp_transport_init(struct sctp_transport *peer,
 	INIT_LIST_HEAD(&peer->send_ready);
 	INIT_LIST_HEAD(&peer->transports);
 
+	peer->T3_rtx_timer.expires = 0;
+	peer->hb_timer.expires = 0;
+
 	setup_timer(&peer->T3_rtx_timer, sctp_generate_t3_rtx_event,
 			(unsigned long)peer);
 	setup_timer(&peer->hb_timer, sctp_generate_heartbeat_event,
-- 
1.5.2.5

