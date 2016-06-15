From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 3/8] rxrpc: Break MTU determination from ICMP into
 its own function
Date: Wed, 15 Jun 2016 17:41:59 +0100
Message-ID: <146600891961.18270.17418789706237015059.stgit@warthog.procyon.org.uk>
References: <146600889842.18270.2306896489831492957.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, netdev@vger.kernel.org,
	linux-afs@lists.infradead.org, linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <146600889842.18270.2306896489831492957.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Break MTU determination from ICMP out into its own function to reduce the
complexity of the error report handler.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/peer_event.c |   93 ++++++++++++++++++++++++++++--------------------
 1 file changed, 54 insertions(+), 39 deletions(-)

diff --git a/net/rxrpc/peer_event.c b/net/rxrpc/peer_event.c
index 2c2df3a5d1b9..80de84257227 100644
--- a/net/rxrpc/peer_event.c
+++ b/net/rxrpc/peer_event.c
@@ -72,6 +72,45 @@ static struct rxrpc_peer *rxrpc_lookup_peer_icmp_rcu(struct rxrpc_local *local,
 }
 
 /*
+ * Handle an MTU/fragmentation problem.
+ */
+static void rxrpc_adjust_mtu(struct rxrpc_peer *peer, struct sock_exterr_skb *serr)
+{
+	u32 mtu = serr->ee.ee_info;
+
+	_net("Rx ICMP Fragmentation Needed (%d)", mtu);
+
+	/* wind down the local interface MTU */
+	if (mtu > 0 && peer->if_mtu == 65535 && mtu < peer->if_mtu) {
+		peer->if_mtu = mtu;
+		_net("I/F MTU %u", mtu);
+	}
+
+	if (mtu == 0) {
+		/* they didn't give us a size, estimate one */
+		mtu = peer->if_mtu;
+		if (mtu > 1500) {
+			mtu >>= 1;
+			if (mtu < 1500)
+				mtu = 1500;
+		} else {
+			mtu -= 100;
+			if (mtu < peer->hdrsize)
+				mtu = peer->hdrsize + 4;
+		}
+	}
+
+	if (mtu < peer->mtu) {
+		spin_lock_bh(&peer->lock);
+		peer->mtu = mtu;
+		peer->maxdata = peer->mtu - peer->hdrsize;
+		spin_unlock_bh(&peer->lock);
+		_net("Net MTU %u (maxdata %u)",
+		     peer->mtu, peer->maxdata);
+	}
+}
+
+/*
  * handle an error received on the local endpoint
  */
 void rxrpc_error_report(struct sock *sk)
@@ -126,50 +165,26 @@ void rxrpc_error_report(struct sock *sk)
 		return;
 	}
 
-	if (serr->ee.ee_origin == SO_EE_ORIGIN_ICMP &&
-	    serr->ee.ee_type == ICMP_DEST_UNREACH &&
-	    serr->ee.ee_code == ICMP_FRAG_NEEDED
-	    ) {
-		u32 mtu = serr->ee.ee_info;
-
-		_net("Rx Received ICMP Fragmentation Needed (%d)", mtu);
-
-		/* wind down the local interface MTU */
-		if (mtu > 0 && peer->if_mtu == 65535 && mtu < peer->if_mtu) {
-			peer->if_mtu = mtu;
-			_net("I/F MTU %u", mtu);
-		}
-
-		if (mtu == 0) {
-			/* they didn't give us a size, estimate one */
-			mtu = peer->if_mtu;
-			if (mtu > 1500) {
-				mtu >>= 1;
-				if (mtu < 1500)
-					mtu = 1500;
-			} else {
-				mtu -= 100;
-				if (mtu < peer->hdrsize)
-					mtu = peer->hdrsize + 4;
-			}
-		}
-
-		if (mtu < peer->mtu) {
-			spin_lock_bh(&peer->lock);
-			peer->mtu = mtu;
-			peer->maxdata = peer->mtu - peer->hdrsize;
-			spin_unlock_bh(&peer->lock);
-			_net("Net MTU %u (maxdata %u)",
-			     peer->mtu, peer->maxdata);
-		}
+	if ((serr->ee.ee_origin == SO_EE_ORIGIN_ICMP &&
+	     serr->ee.ee_type == ICMP_DEST_UNREACH &&
+	     serr->ee.ee_code == ICMP_FRAG_NEEDED)) {
+		rxrpc_adjust_mtu(peer, serr);
+		rxrpc_free_skb(skb);
+		skb = NULL;
+		goto out;
 	}
 
+out:
 	rcu_read_unlock();
 	rxrpc_put_peer(peer);
 
-	/* pass the transport ref to error_handler to release */
-	skb_queue_tail(&trans->error_queue, skb);
-	rxrpc_queue_work(&trans->error_handler);
+	if (skb) {
+		/* pass the transport ref to error_handler to release */
+		skb_queue_tail(&trans->error_queue, skb);
+		rxrpc_queue_work(&trans->error_handler);
+	} else {
+		rxrpc_put_transport(trans);
+	}
 	_leave("");
 }
 
