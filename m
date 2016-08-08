From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] [net] rxrpc: fix uninitialized pointer dereference in debug code
Date: Mon,  8 Aug 2016 12:13:45 +0200
Message-ID: <20160808101357.1583011-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	David Howells <dhowells@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A newly added bugfix caused an uninitialized variable to be
used for printing debug output. This is harmless as long
as the debug setting is disabled, but otherwise leads to an
immediate crash.

gcc warns about this when -Wmaybe-uninitialized is enabled:

net/rxrpc/call_object.c: In function 'rxrpc_release_call':
net/rxrpc/call_object.c:496:163: error: 'sp' may be used uninitialized in this function [-Werror=maybe-uninitialized]

The initialization was removed but one of the users remains.
This adds back the initialization.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Fixes: 372ee16386bb ("rxrpc: Fix races between skb free, ACK generation and replying")
---
I have not tried to understand the longish bugfix patch that
caused this, so I'm not sure whether it's actually safe to
access rxrpc_skb(skb) in this function. Please check if this
is the right fix.
---
 net/rxrpc/call_object.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/rxrpc/call_object.c b/net/rxrpc/call_object.c
index c47f14fc5e88..e8c953c48cb8 100644
--- a/net/rxrpc/call_object.c
+++ b/net/rxrpc/call_object.c
@@ -493,6 +493,7 @@ void rxrpc_release_call(struct rxrpc_call *call)
 		       (skb = skb_dequeue(&call->rx_oos_queue))) {
 			spin_unlock_bh(&call->lock);
 
+			sp = rxrpc_skb(skb);
 			_debug("- zap %s %%%u #%u",
 			       rxrpc_pkts[sp->hdr.type],
 			       sp->hdr.serial, sp->hdr.seq);
-- 
2.9.0
