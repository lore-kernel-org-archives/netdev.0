From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 09/14] rxrpc: Fix unexposed client conn release
Date: Sun, 18 Sep 2016 00:18:47 +0100
Message-ID: <147415432697.17897.576387860851150654.stgit@warthog.procyon.org.uk>
References: <147415426459.17897.13899206413543061473.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38134 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S936026AbcIQXSy (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 17 Sep 2016 19:18:54 -0400
In-Reply-To: <147415426459.17897.13899206413543061473.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the last call on a client connection is release after the connection has
had a bunch of calls allocated but before any DATA packets are sent (so
that it's not yet marked RXRPC_CONN_EXPOSED), an assertion will happen in
rxrpc_disconnect_client_call().

	af_rxrpc: Assertion failed - 1(0x1) >= 2(0x2) is false
	------------[ cut here ]------------
	kernel BUG at ../net/rxrpc/conn_client.c:753!

This is because it's expecting the conn to have been exposed and to have 2
or more refs - but this isn't necessarily the case.

Simply remove the assertion.  This allows the conn to be moved into the
inactive state and deleted if it isn't resurrected before the final put is
called.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/conn_client.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/net/rxrpc/conn_client.c b/net/rxrpc/conn_client.c
index 5a675c43cace..226bc910e556 100644
--- a/net/rxrpc/conn_client.c
+++ b/net/rxrpc/conn_client.c
@@ -721,7 +721,6 @@ void rxrpc_disconnect_client_call(struct rxrpc_call *call)
 	}
 
 	ASSERTCMP(rcu_access_pointer(chan->call), ==, call);
-	ASSERTCMP(atomic_read(&conn->usage), >=, 2);
 
 	/* If a client call was exposed to the world, we save the result for
 	 * retransmission.
