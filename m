From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net v2] net: sctp: sctp_transport_destroy{,_rcu}: fix potential pointer corruption
Date: Fri,  9 Aug 2013 15:27:22 +0200
Message-ID: <1376054842-376-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:23329 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966041Ab3HIN1Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Aug 2013 09:27:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Probably this one is quite unlikely to be triggered, but it's more safe
to hold a pointer to asoc (instead of dereferencing), free the packet
chunks first, and access asoc though the pointer after we have called
sctp_transport_destroy_rcu() where the transport is being kfree()'d.
Introduced by commit 8c98653f ("sctp: sctp_close: fix release of bindings
for deferred call_rcu's"). I also did the 8c98653f regression test and
it's fine that way.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 v1->v2: do sctp_packet_free before call_rcu

 net/sctp/transport.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/net/sctp/transport.c b/net/sctp/transport.c
index bdbbc3f..c691455 100644
--- a/net/sctp/transport.c
+++ b/net/sctp/transport.c
@@ -176,17 +176,19 @@ static void sctp_transport_destroy_rcu(struct rcu_head *head)
  */
 static void sctp_transport_destroy(struct sctp_transport *transport)
 {
+	struct sctp_association *asoc = transport->asoc;
+
 	if (unlikely(!transport->dead)) {
 		WARN(1, "Attempt to destroy undead transport %p!\n", transport);
 		return;
 	}
 
-	call_rcu(&transport->rcu, sctp_transport_destroy_rcu);
-
 	sctp_packet_free(&transport->packet);
 
-	if (transport->asoc)
-		sctp_association_put(transport->asoc);
+	call_rcu(&transport->rcu, sctp_transport_destroy_rcu);
+
+	if (asoc != NULL)
+		sctp_association_put(asoc);
 }
 
 /* Start T3_rtx timer if it is not already running and update the heartbeat
-- 
1.7.11.7
