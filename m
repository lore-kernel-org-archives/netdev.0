From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net 1/1] tipc: correct settings of broadcast link state
Date: Thu, 19 Nov 2015 14:12:50 -0500
Message-ID: <1447960370-8306-1-git-send-email-jon.maloy@ericsson.com>
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	parthasarathy.xx.bhuvaragan@ericsson.com,
	richard.alpe@ericsson.com, ying.xue@windriver.com,
	maloy@donjonn.com, tipc-discussion@lists.sourceforge.net,
	Jon Maloy <jon.maloy@ericsson.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp104.biz.mail.bf1.yahoo.com ([98.139.221.63]:26381 "EHLO
	smtp104.biz.mail.bf1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759036AbbKSTMz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2015 14:12:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since commit 5266698661401afc5e ("tipc: let broadcast packet
reception use new link receive function") the broadcast send
link state was meant to always be set to LINK_ESTABLISHED, since
we don't need this link to follow the regular link FSM rules. It
was also the intention that this state anyway shouldn't impact
the run-time working state of the link, since the latter in
reality is controlled by the number of registered peers.

We have now discovered that this assumption is not quite correct.
If the broadcast link is reset because of too many retransmissions,
its state will inadvertently go to LINK_RESETTING, and never go
back to LINK_ESTABLISHED, because the LINK_FAILURE event was not
anticipated. This will work well once, but if it happens a second
time, the reset on a link in LINK_RESETTING has has no effect, and
neither the broadcast link nor the unicast links will go down as
they should.

Furthermore, it is confusing that the management tool shows that
this link is in UP state when that obviously isn't the case.

We now ensure that this state strictly follows the true working
state of the link. The state is set to LINK_ESTABLISHED when
the number of peers is non-zero, and to LINK_RESET otherwise.

Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/link.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index 9efbdbd..91aea07 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -191,6 +191,7 @@ void tipc_link_add_bc_peer(struct tipc_link *snd_l,
 
 	snd_l->ackers++;
 	rcv_l->acked = snd_l->snd_nxt - 1;
+	snd_l->state = LINK_ESTABLISHED;
 	tipc_link_build_bc_init_msg(uc_l, xmitq);
 }
 
@@ -206,6 +207,7 @@ void tipc_link_remove_bc_peer(struct tipc_link *snd_l,
 	rcv_l->state = LINK_RESET;
 	if (!snd_l->ackers) {
 		tipc_link_reset(snd_l);
+		snd_l->state = LINK_RESET;
 		__skb_queue_purge(xmitq);
 	}
 }
-- 
1.9.1
