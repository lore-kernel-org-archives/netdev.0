From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net] net: sctp: sctp_transport_destroy{,_rcu}: fix potential pointer corruption
Date: Fri,  9 Aug 2013 12:07:29 +0200
Message-ID: <1376042849-19732-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40194 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934248Ab3HIKHf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Aug 2013 06:07:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Probably this one is quite unlikely to be triggered, but it's more safe
to hold a pointer to asoc and packet (instead of dereferencing) and access
both though this after we have called sctp_transport_destroy_rcu() where
the transport is being kfree()'d. Introduced by commit 8c98653f ("sctp:
sctp_close: fix release of bindings for deferred call_rcu's").

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 net/sctp/transport.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/net/sctp/transport.c b/net/sctp/transport.c
index bdbbc3f..7142756 100644
--- a/net/sctp/transport.c
+++ b/net/sctp/transport.c
@@ -176,6 +176,9 @@ static void sctp_transport_destroy_rcu(struct rcu_head *head)
  */
 static void sctp_transport_destroy(struct sctp_transport *transport)
 {
+	struct sctp_association *asoc = transport->asoc;
+	struct sctp_packet *packet = &transport->packet;
+
 	if (unlikely(!transport->dead)) {
 		WARN(1, "Attempt to destroy undead transport %p!\n", transport);
 		return;
@@ -183,10 +186,10 @@ static void sctp_transport_destroy(struct sctp_transport *transport)
 
 	call_rcu(&transport->rcu, sctp_transport_destroy_rcu);
 
-	sctp_packet_free(&transport->packet);
+	sctp_packet_free(packet);
 
-	if (transport->asoc)
-		sctp_association_put(transport->asoc);
+	if (asoc != NULL)
+		sctp_association_put(asoc);
 }
 
 /* Start T3_rtx timer if it is not already running and update the heartbeat
-- 
1.7.11.7
