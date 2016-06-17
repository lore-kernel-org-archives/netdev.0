From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] rxrpc: fix uninitialized variable use
Date: Fri, 17 Jun 2016 11:55:22 +0200
Message-ID: <20160617095555.1696781-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Howells <dhowells@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hashing the peer key was introduced for AF_INET, but gcc
warns about the rxrpc_peer_hash_key function returning uninitialized
data for any other value of srx->transport.family:

net/rxrpc/peer_object.c: In function 'rxrpc_peer_hash_key':
net/rxrpc/peer_object.c:57:15: error: 'p' may be used uninitialized in this function [-Werror=maybe-uninitialized]

Assuming that nothing else can be set here, this changes the
function to just return zero in case of an unknown address
family.

Fixes: be6e6707f6ee ("rxrpc: Rework peer object handling to use hash table and RCU")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
This showed up today in linux-next, no idea if my patch is the
right solution for the problem, so please review carefully.

 net/rxrpc/peer_object.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/rxrpc/peer_object.c b/net/rxrpc/peer_object.c
index faf222c21698..5ab89295c36c 100644
--- a/net/rxrpc/peer_object.c
+++ b/net/rxrpc/peer_object.c
@@ -50,6 +50,8 @@ static unsigned long rxrpc_peer_hash_key(struct rxrpc_local *local,
 		size = sizeof(srx->transport.sin.sin_addr);
 		p = (u16 *)&srx->transport.sin.sin_addr;
 		break;
+	default:
+		return 0;
 	}
 
 	/* Step through the peer address in 16-bit portions for speed */
-- 
2.9.0
