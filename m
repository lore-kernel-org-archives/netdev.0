From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 4/9] rxrpc: Randomise epoch and starting client
 conn ID values
Date: Sun, 04 Sep 2016 22:02:51 +0100
Message-ID: <147302297165.28597.8317497494192917329.stgit@warthog.procyon.org.uk>
References: <147302294435.28597.15007422228950187972.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <147302294435.28597.15007422228950187972.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Create a random epoch value rather than a time-based one on startup and set
the top bit to indicate that this is the case.

Also create a random starting client connection ID value.  This will be
incremented from here as new client connections are created.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 include/rxrpc/packet.h |    1 +
 net/rxrpc/af_rxrpc.c   |    9 ++++++++-
 2 files changed, 9 insertions(+), 1 deletion(-)

diff --git a/include/rxrpc/packet.h b/include/rxrpc/packet.h
index b2017440b765..3c6128e1fdbe 100644
--- a/include/rxrpc/packet.h
+++ b/include/rxrpc/packet.h
@@ -24,6 +24,7 @@ typedef __be32	rxrpc_serial_net_t; /* on-the-wire Rx message serial number */
  */
 struct rxrpc_wire_header {
 	__be32		epoch;		/* client boot timestamp */
+#define RXRPC_RANDOM_EPOCH	0x80000000	/* Random if set, date-based if not */
 
 	__be32		cid;		/* connection and channel ID */
 #define RXRPC_MAXCALLS		4			/* max active calls per conn */
diff --git a/net/rxrpc/af_rxrpc.c b/net/rxrpc/af_rxrpc.c
index 32d544995dda..b66a9e6f8d04 100644
--- a/net/rxrpc/af_rxrpc.c
+++ b/net/rxrpc/af_rxrpc.c
@@ -16,6 +16,7 @@
 #include <linux/net.h>
 #include <linux/slab.h>
 #include <linux/skbuff.h>
+#include <linux/random.h>
 #include <linux/poll.h>
 #include <linux/proc_fs.h>
 #include <linux/key-type.h>
@@ -700,7 +701,13 @@ static int __init af_rxrpc_init(void)
 
 	BUILD_BUG_ON(sizeof(struct rxrpc_skb_priv) > FIELD_SIZEOF(struct sk_buff, cb));
 
-	rxrpc_epoch = get_seconds();
+	get_random_bytes(&rxrpc_epoch, sizeof(rxrpc_epoch));
+	rxrpc_epoch |= RXRPC_RANDOM_EPOCH;
+	get_random_bytes(&rxrpc_client_conn_ids.cur,
+			 sizeof(rxrpc_client_conn_ids.cur));
+	rxrpc_client_conn_ids.cur &= 0x3fffffff;
+	if (rxrpc_client_conn_ids.cur == 0)
+		rxrpc_client_conn_ids.cur = 1;
 
 	ret = -ENOMEM;
 	rxrpc_call_jar = kmem_cache_create(
