From: David Howells <dhowells@redhat.com>
Subject: [PATCH net 1/6] rxrpc: fix uninitialized pointer dereference in
 debug code
Date: Tue, 09 Aug 2016 17:33:19 +0100
Message-ID: <147076039919.13232.12482209450582110412.stgit@warthog.procyon.org.uk>
References: <147076039224.13232.8512451280294417362.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <147076039224.13232.8512451280294417362.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>

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
Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/call_object.c |    1 +
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
