From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 3/5] rxrpc: fix last_call processing
Date: Fri, 26 Aug 2016 17:25:44 +0200
Message-ID: <20160826152546.604384-4-arnd@arndb.de>
References: <20160826152546.604384-1-arnd@arndb.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        Arnd Bergmann <arnd@arndb.de>,
        David Howells <dhowells@redhat.com>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.130]:51131 "EHLO
        mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751499AbcHZP2k (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 Aug 2016 11:28:40 -0400
In-Reply-To: <20160826152546.604384-1-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A change to the retransmission handling in rxrpc caused a use-before-init
bug in rxrpc_data_ready(), as indicated by "gcc -Wmaybe-uninitialized":

net/rxrpc/input.c: In function 'rxrpc_data_ready':
net/rxrpc/input.c:735:34: error: 'call' may be used uninitialized in this function [-Werror=maybe-uninitialized]

This moves the initialization of the local variable before the first
user, which presumably is what was intended here.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Fixes: 18bfeba50dfd ("rxrpc: Perform terminal call ACK/ABORT retransmission from conn processor")
---
Cc: David Howells <dhowells@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: netdev@vger.kernel.org

 net/rxrpc/input.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/rxrpc/input.c b/net/rxrpc/input.c
index 66cdeb56f44f..3c22e43a58fd 100644
--- a/net/rxrpc/input.c
+++ b/net/rxrpc/input.c
@@ -728,6 +728,10 @@ void rxrpc_data_ready(struct sock *sk)
 		if (sp->hdr.callNumber < chan->last_call)
 			goto discard_unlock;
 
+		call = rcu_dereference(chan->call);
+		if (!call || atomic_read(&call->usage) == 0)
+			goto cant_route_call;
+
 		if (sp->hdr.callNumber == chan->last_call) {
 			/* For the previous service call, if completed
 			 * successfully, we discard all further packets.
@@ -744,10 +748,6 @@ void rxrpc_data_ready(struct sock *sk)
 			goto out_unlock;
 		}
 
-		call = rcu_dereference(chan->call);
-		if (!call || atomic_read(&call->usage) == 0)
-			goto cant_route_call;
-
 		rxrpc_post_packet_to_call(call, skb);
 		goto out_unlock;
 	}
-- 
2.9.0
