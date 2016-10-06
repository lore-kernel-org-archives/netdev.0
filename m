From: David Howells <dhowells@redhat.com>
Subject: [PATCH net 01/13] rxrpc: Accesses of rxrpc_local::service need to
 be RCU managed
Date: Thu, 06 Oct 2016 11:04:03 +0100
Message-ID: <147574824368.30350.6920797508053651101.stgit@warthog.procyon.org.uk>
References: <147574823645.30350.16131031458272035074.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <147574823645.30350.16131031458272035074.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

struct rxrpc_local->service is marked __rcu - this means that accesses of
it need to be managed using RCU wrappers.  There are two such places in
rxrpc_release_sock() where the value is checked and cleared.  Fix this by
using the appropriate wrappers.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/af_rxrpc.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/rxrpc/af_rxrpc.c b/net/rxrpc/af_rxrpc.c
index 44c9c2b0b190..2d59c9be40e1 100644
--- a/net/rxrpc/af_rxrpc.c
+++ b/net/rxrpc/af_rxrpc.c
@@ -678,9 +678,9 @@ static int rxrpc_release_sock(struct sock *sk)
 	sk->sk_state = RXRPC_CLOSE;
 	spin_unlock_bh(&sk->sk_receive_queue.lock);
 
-	if (rx->local && rx->local->service == rx) {
+	if (rx->local && rcu_access_pointer(rx->local->service) == rx) {
 		write_lock(&rx->local->services_lock);
-		rx->local->service = NULL;
+		rcu_assign_pointer(rx->local->service, NULL);
 		write_unlock(&rx->local->services_lock);
 	}
 
