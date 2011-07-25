From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [PATCH 6/7] dccp ccid-2: increment cwnd correctly
Date: Mon, 25 Jul 2011 07:36:35 -0600
Message-ID: <1311600996-6712-7-git-send-email-gerrit@erg.abdn.ac.uk>
References: <test_tree_patch_set_update_2011-07-25>
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org,
	Samuel Jero <sj323707@ohio.edu>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:38458 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751941Ab1GYNhK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Jul 2011 09:37:10 -0400
In-Reply-To: <test_tree_patch_set_update_2011-07-25>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Samuel Jero <sj323707@ohio.edu>

This patch fixes an issue where CCID-2 will not increase the congestion
window for numerous RTTs after an idle period, application-limited period,
or a loss once the algorithm is in Congestion Avoidance.

What happens is that, when CCID-2 is in Congestion Avoidance mode, it will
increase hc->tx_packets_acked by one for every packet and will increment cwnd
every cwnd packets. However, if there is now an idle period in the connection,
cwnd will be reduced, possibly below the slow start threshold. This will
cause the connection to go into Slow Start. However, in Slow Start CCID-2
performs this test to increment cwnd every second ack:

	++hc->tx_packets_acked == 2

Unfortunately, this will be incorrect, if cwnd previous to the idle period
was larger than 2 and if tx_packets_acked was close to cwnd. For example:
	cwnd=50  and  tx_packets_acked=45.

In this case, the current code, will increment tx_packets_acked until it
equals two, which will only be once tx_packets_acked (an unsigned 32-bit
integer) overflows.

My fix is simply to change that test for tx_packets_acked greater than or
equal to two in slow start.

Signed-off-by: Samuel Jero <sj323707@ohio.edu>
Acked-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid2.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -411,7 +411,7 @@ static void ccid2_new_ack(struct sock *sk, struct ccid2_seq *seqp,
 	if (hc->tx_cwnd < dp->dccps_l_seq_win &&
 	    r_seq_used < dp->dccps_r_seq_win) {
 		if (hc->tx_cwnd < hc->tx_ssthresh) {
-			if (*maxincr > 0 && ++hc->tx_packets_acked == 2) {
+			if (*maxincr > 0 && ++hc->tx_packets_acked >= 2) {
 				hc->tx_cwnd += 1;
 				*maxincr    -= 1;
 				hc->tx_packets_acked = 0;
