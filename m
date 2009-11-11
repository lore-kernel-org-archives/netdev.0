From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH] sctp: Set socket source address when additing first transport
Date: Wed, 11 Nov 2009 16:54:37 -0500
Message-ID: <1257976477-31326-1-git-send-email-vladislav.yasevich@hp.com>
References: <1257879454-31661-1-git-send-email-vladislav.yasevich@hp.com>
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from g6t0187.atlanta.hp.com ([15.193.32.64]:13310 "EHLO
	g6t0187.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759393AbZKKWFl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2009 17:05:41 -0500
In-Reply-To: <1257879454-31661-1-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Recent commits
	sctp: Get rid of an extra routing lookup when adding a transport
and
	sctp: Set source addresses on the association before adding transports

changed when routes are added to the sctp transports.  As such,
we didn't set the socket source address correctly when adding the first
transport.  The first transport is always the primary/active one, so
when adding it, set the socket source address.  This was causing
regression failures in SCTP tests.

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 net/sctp/transport.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/sctp/transport.c b/net/sctp/transport.c
index c256e48..3b141bb 100644
--- a/net/sctp/transport.c
+++ b/net/sctp/transport.c
@@ -308,7 +308,8 @@ void sctp_transport_route(struct sctp_transport *transport,
 		/* Initialize sk->sk_rcv_saddr, if the transport is the
 		 * association's active path for getsockname().
 		 */
-		if (asoc && (transport == asoc->peer.active_path))
+		if (asoc && (!asoc->peer.primary_path ||
+				(transport == asoc->peer.active_path)))
 			opt->pf->af->to_sk_saddr(&transport->saddr,
 						 asoc->base.sk);
 	} else
-- 
1.6.0.4

