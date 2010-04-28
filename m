From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH 2/5] sctp: fix potential reference of a freed pointer
Date: Wed, 28 Apr 2010 14:47:19 -0400
Message-ID: <1272480442-32673-3-git-send-email-vladislav.yasevich@hp.com>
References: <1272480442-32673-1-git-send-email-vladislav.yasevich@hp.com>
Cc: davem@davemloft.net, linux-sctp@vger.kernel.org,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g6t0185.atlanta.hp.com ([15.193.32.62]:15851 "EHLO
	g6t0185.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756333Ab0D1Sr0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Apr 2010 14:47:26 -0400
In-Reply-To: <1272480442-32673-1-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When sctp attempts to update an assocition, it removes any
addresses that were not in the updated INITs.  However, the loop
may attempt to refrence a transport with address after removing it.

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 net/sctp/associola.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/sctp/associola.c b/net/sctp/associola.c
index df5abbf..99c93ee 100644
--- a/net/sctp/associola.c
+++ b/net/sctp/associola.c
@@ -1194,8 +1194,10 @@ void sctp_assoc_update(struct sctp_association *asoc,
 	/* Remove any peer addresses not present in the new association. */
 	list_for_each_safe(pos, temp, &asoc->peer.transport_addr_list) {
 		trans = list_entry(pos, struct sctp_transport, transports);
-		if (!sctp_assoc_lookup_paddr(new, &trans->ipaddr))
-			sctp_assoc_del_peer(asoc, &trans->ipaddr);
+		if (!sctp_assoc_lookup_paddr(new, &trans->ipaddr)) {
+			sctp_assoc_rm_peer(asoc, trans);
+			continue;
+		}
 
 		if (asoc->state >= SCTP_STATE_ESTABLISHED)
 			sctp_transport_reset(trans);
-- 
1.6.0.4

