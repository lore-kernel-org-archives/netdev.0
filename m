From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 2/2] rxrpc: fix undefined behavior in rxrpc_mark_call_released
Date: Wed, 31 Aug 2016 14:39:02 +0200
Message-ID: <20160831123911.3467676-2-arnd@arndb.de>
References: <20160831123911.3467676-1-arnd@arndb.de>
Cc: netdev@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>,
        linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
        David Howells <dhowells@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160831123911.3467676-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

gcc -Wmaybe-initialized correctly points out a newly introduced bug
through which we can end up calling rxrpc_queue_call() for a dead
connection:

net/rxrpc/call_object.c: In function 'rxrpc_mark_call_released':
net/rxrpc/call_object.c:600:5: error: 'sched' may be used uninitialized in this function [-Werror=maybe-uninitialized]

This sets the 'sched' variable to zero to restore the previous
behavior.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Fixes: f5c17aaeb2ae ("rxrpc: Calls should only have one terminal state")
---
 net/rxrpc/call_object.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/rxrpc/call_object.c b/net/rxrpc/call_object.c
index 104ee8b1de06..2daec1eaec6f 100644
--- a/net/rxrpc/call_object.c
+++ b/net/rxrpc/call_object.c
@@ -595,6 +595,8 @@ static void rxrpc_mark_call_released(struct rxrpc_call *call)
 		sched = __rxrpc_abort_call(call, RX_CALL_DEAD, ECONNRESET);
 		if (!test_and_set_bit(RXRPC_CALL_EV_RELEASE, &call->events))
 			sched = true;
+	} else {
+		sched = 0;
 	}
 	write_unlock(&call->state_lock);
 	if (sched)
-- 
2.9.0
