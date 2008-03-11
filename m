From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH] cxgb3: enhance t3_l2t_update to catch netevents in which
	arp entries have their probe timer expire
Date: Tue, 11 Mar 2008 13:34:47 -0400
Message-ID: <20080311173447.GB13374@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nhorman@tuxdriver.com
To: divy@chelsio.com, agospoda@redhat.com, davem@davemloft.net,
	netdev@vger.kernel.org, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:2116 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752962AbYCKRgS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Mar 2008 13:36:18 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Recently commit 4eb61e0231be536d8116457b67b3e447bbd510dc went in to handle arp
completion events in the cxgb driver.  This was done to catch arp events for
which the corresponding entry was marked stale.  This was done to prevent RDMA
connection failures.  However the preceding patch misses a case.  While checking
for NUD_STALE states allows the processing of arp entries that were completed
due to arp requests rather than arp replies, it fails to catch arp entries that
have had their probe timer expire (NUD_PROBE).  It seems the same failure can
occur in that case.  By changing the check from NUD_CONNECTED|NUD_STALE to
NUD_VALID, we can catch the previous set of events and add exprired/revalidated
arp entries to the set of handled cases as well.

Regards
Neil

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>


l2t.c |    2 +-
1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/cxgb3/l2t.c b/drivers/net/cxgb3/l2t.c
index 865faee..3faf3d6 100644
--- a/drivers/net/cxgb3/l2t.c
+++ b/drivers/net/cxgb3/l2t.c
@@ -404,7 +404,7 @@ found:
 			if (neigh->nud_state & NUD_FAILED) {
 				arpq = e->arpq_head;
 				e->arpq_head = e->arpq_tail = NULL;
-			} else if (neigh->nud_state & (NUD_CONNECTED|NUD_STALE))
+			} else if (neigh->nud_state & NUD_VALID)
 				setup_l2e_send_pending(dev, NULL, e);
 		} else {
 			e->state = neigh_is_connected(neigh) ?
-- 
/****************************************************
 * Neil Horman <nhorman@tuxdriver.com>
 * Software Engineer, Red Hat
 ****************************************************/
