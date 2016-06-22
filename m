From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 02/14] rxrpc: fix uninitialized variable use
Date: Wed, 22 Jun 2016 10:49:56 +0100
Message-ID: <146658899682.4550.7669757075121360870.stgit@warthog.procyon.org.uk>
References: <146658898230.4550.7226255613607733759.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, netdev@vger.kernel.org,
	linux-afs@lists.infradead.org, Arnd Bergmann <arnd@arndb.de>,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <146658898230.4550.7226255613607733759.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>

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
Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/peer_object.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/rxrpc/peer_object.c b/net/rxrpc/peer_object.c
index faf222c21698..6baad708f3b1 100644
--- a/net/rxrpc/peer_object.c
+++ b/net/rxrpc/peer_object.c
@@ -50,6 +50,9 @@ static unsigned long rxrpc_peer_hash_key(struct rxrpc_local *local,
 		size = sizeof(srx->transport.sin.sin_addr);
 		p = (u16 *)&srx->transport.sin.sin_addr;
 		break;
+	default:
+		WARN(1, "AF_RXRPC: Unsupported transport address family\n");
+		return 0;
 	}
 
 	/* Step through the peer address in 16-bit portions for speed */
