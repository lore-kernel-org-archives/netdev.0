From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next] rxrpc: Make service connection lookup always check
 for retry
Date: Mon, 04 Sep 2017 15:28:28 +0100
Message-ID: <150453530801.20359.17059994007095255872.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40424 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753566AbdIDO23 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 4 Sep 2017 10:28:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When an RxRPC service packet comes in, the target connection is looked up
by an rb-tree search under RCU and a read-locked seqlock; the seqlock retry
check is, however, currently skipped if we got a match, but probably
shouldn't be in case the connection we found gets replaced whilst we're
doing a search.

Make the lookup procedure always go through need_seqretry(), even if the
lookup was successful.  This makes sure we always pick up on a write-lock
event.

On the other hand, since we don't take a ref on the object, but rely on RCU
to prevent its destruction after dropping the seqlock, I'm not sure this is
necessary.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/conn_service.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/rxrpc/conn_service.c b/net/rxrpc/conn_service.c
index e60fcd2a4a02..f6fcdb3130a1 100644
--- a/net/rxrpc/conn_service.c
+++ b/net/rxrpc/conn_service.c
@@ -50,12 +50,11 @@ struct rxrpc_connection *rxrpc_find_service_conn_rcu(struct rxrpc_peer *peer,
 			else if (conn->proto.index_key > k.index_key)
 				p = rcu_dereference_raw(p->rb_right);
 			else
-				goto done;
+				break;
 			conn = NULL;
 		}
 	} while (need_seqretry(&peer->service_conn_lock, seq));
 
-done:
 	done_seqretry(&peer->service_conn_lock, seq);
 	_leave(" = %d", conn ? conn->debug_id : -1);
 	return conn;
