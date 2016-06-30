From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 03/19] rxrpc: Provide more refcount helper functions
Date: Thu, 30 Jun 2016 15:11:03 +0100
Message-ID: <146729586380.26306.5735072010592120761.stgit@warthog.procyon.org.uk>
References: <146729584148.26306.13038965408565743258.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, netdev@vger.kernel.org,
	linux-afs@lists.infradead.org, linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49844 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751994AbcF3OMv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Jun 2016 10:12:51 -0400
In-Reply-To: <146729584148.26306.13038965408565743258.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Provide refcount helper functions for connections so that the code doesn't
touch conn->usage directly.

Also provide queueing helper functions so that the queueing of local and
connection objects can be fixed later.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/ar-internal.h |   12 +++++++++++-
 net/rxrpc/conn_event.c  |    2 +-
 net/rxrpc/input.c       |    2 +-
 3 files changed, 13 insertions(+), 3 deletions(-)

diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index 796368d1fb25..45aef3ef7609 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -35,7 +35,6 @@ struct rxrpc_crypt {
 	queue_delayed_work(rxrpc_workqueue, (WS), (D))
 
 #define rxrpc_queue_call(CALL)	rxrpc_queue_work(&(CALL)->processor)
-#define rxrpc_queue_conn(CONN)	rxrpc_queue_work(&(CONN)->processor)
 
 struct rxrpc_connection;
 
@@ -566,6 +565,12 @@ static inline void rxrpc_get_connection(struct rxrpc_connection *conn)
 	atomic_inc(&conn->usage);
 }
 
+
+static inline void rxrpc_queue_conn(struct rxrpc_connection *conn)
+{
+	rxrpc_queue_work(&conn->processor);
+}
+
 /*
  * input.c
  */
@@ -618,6 +623,11 @@ static inline void rxrpc_put_local(struct rxrpc_local *local)
 		__rxrpc_put_local(local);
 }
 
+static inline void rxrpc_queue_local(struct rxrpc_local *local)
+{
+	rxrpc_queue_work(&local->processor);
+}
+
 /*
  * misc.c
  */
diff --git a/net/rxrpc/conn_event.c b/net/rxrpc/conn_event.c
index 6a3c96707831..d7e183c6b5df 100644
--- a/net/rxrpc/conn_event.c
+++ b/net/rxrpc/conn_event.c
@@ -318,7 +318,7 @@ void rxrpc_reject_packet(struct rxrpc_local *local, struct sk_buff *skb)
 	CHECK_SLAB_OKAY(&local->usage);
 
 	skb_queue_tail(&local->reject_queue, skb);
-	rxrpc_queue_work(&local->processor);
+	rxrpc_queue_local(local);
 }
 
 /*
diff --git a/net/rxrpc/input.c b/net/rxrpc/input.c
index f4bd57b77b93..8a68cc387a8c 100644
--- a/net/rxrpc/input.c
+++ b/net/rxrpc/input.c
@@ -595,7 +595,7 @@ static void rxrpc_post_packet_to_local(struct rxrpc_local *local,
 	_enter("%p,%p", local, skb);
 
 	skb_queue_tail(&local->event_queue, skb);
-	rxrpc_queue_work(&local->processor);
+	rxrpc_queue_local(local);
 }
 
 /*
