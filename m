From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net v3] net: sctp: sctp_transport_destroy{,_rcu}: fix potential pointer corruption
Date: Fri,  9 Aug 2013 16:25:21 +0200
Message-ID: <1376058321-2461-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55906 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S967879Ab3HIOZZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Aug 2013 10:25:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Probably this one is quite unlikely to be triggered, but it's more safe
to do the call_rcu() at the end after we have dropped the reference on
the asoc and freed sctp packet chunks. The reason why is because in
sctp_transport_destroy_rcu() the transport is being kfree()'d, and if
we're unlucky enough we could run into corrupted pointers. Probably
that's more of theoretical nature, but it's safer to have this simple fix.

Introduced by commit 8c98653f ("sctp: sctp_close: fix release of bindings
for deferred call_rcu's"). I also did the 8c98653f regression test and
it's fine that way.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 net/sctp/transport.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sctp/transport.c b/net/sctp/transport.c
index bdbbc3f..8fdd160 100644
--- a/net/sctp/transport.c
+++ b/net/sctp/transport.c
@@ -181,12 +181,12 @@ static void sctp_transport_destroy(struct sctp_transport *transport)
 		return;
 	}
 
-	call_rcu(&transport->rcu, sctp_transport_destroy_rcu);
-
 	sctp_packet_free(&transport->packet);
 
 	if (transport->asoc)
 		sctp_association_put(transport->asoc);
+
+	call_rcu(&transport->rcu, sctp_transport_destroy_rcu);
 }
 
 /* Start T3_rtx timer if it is not already running and update the heartbeat
-- 
1.7.11.7
