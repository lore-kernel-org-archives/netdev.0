From: Michal Ostrowski <mostrows@earthlink.net>
Subject: [PATCH 4/4] PPPOE: Fix device tear-down notification.
Date: Tue, 13 Mar 2007 09:09:35 -0500
Message-ID: <11737949753280-git-send-email-mostrows@earthlink.net>
References: <11737949753580-git-send-email-mostrows@earthlink.net> <1173794975536-git-send-email-mostrows@earthlink.net> <11737949751582-git-send-email-mostrows@earthlink.net>
Cc: Michal Ostrowski <mostrows@earthlink.net>
To: mostrows@watson.ibm.com, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from igw2.watson.ibm.com ([129.34.20.6]:47144 "EHLO
	igw2.watson.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030333AbXCMOHZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Mar 2007 10:07:25 -0400
In-Reply-To: <11737949751582-git-send-email-mostrows@earthlink.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

pppoe_flush_dev() kicks all sockets bound to a device that is going down.
In doing so, locks must be taken in the right order consistently (sock lock,
followed by the pppoe_hash_lock).  However, the scan process is based on
us holding the sock lock.  So, when something is found in the scan we must
release the lock we're holding and grab the sock lock.

This patch fixes race conditions between this code and pppoe_release(),
both of which perform similar functions but would naturally prefer to grab
locks in opposing orders.  Both code paths are now going after these locks
in a consistent manner.

pppoe_hash_lock protects the contents of the "pppox_sock" objects that reside
inside the hash.  Thus, NULL'ing out the pppoe_dev field should be done
under the protection of this lock.

Signed-off-by: Michal Ostrowski <mostrows@earthlink.net>
---
 drivers/net/pppoe.c |   93 +++++++++++++++++++++++++++++----------------------
 1 files changed, 53 insertions(+), 40 deletions(-)

diff --git a/drivers/net/pppoe.c b/drivers/net/pppoe.c
index 4e878c9..0961bf9 100644
--- a/drivers/net/pppoe.c
+++ b/drivers/net/pppoe.c
@@ -241,54 +241,53 @@ static inline struct pppox_sock *delete_item(unsigned long sid, char *addr, int
 static void pppoe_flush_dev(struct net_device *dev)
 {
 	int hash;
-
 	BUG_ON(dev == NULL);
 
-	read_lock_bh(&pppoe_hash_lock);
+	write_lock_bh(&pppoe_hash_lock);
 	for (hash = 0; hash < PPPOE_HASH_SIZE; hash++) {
 		struct pppox_sock *po = item_hash_table[hash];
 
 		while (po != NULL) {
-			if (po->pppoe_dev == dev) {
-				struct sock *sk = sk_pppox(po);
-
-				sock_hold(sk);
-				po->pppoe_dev = NULL;
-
-				/* We hold a reference to SK, now drop the
-				 * hash table lock so that we may attempt
-				 * to lock the socket (which can sleep).
-				 */
-				read_unlock_bh(&pppoe_hash_lock);
-
-				lock_sock(sk);
-
-				if (sk->sk_state &
-				    (PPPOX_CONNECTED | PPPOX_BOUND)) {
-					pppox_unbind_sock(sk);
-					dev_put(dev);
-					sk->sk_state = PPPOX_ZOMBIE;
-					sk->sk_state_change(sk);
-				}
-
-				release_sock(sk);
+			struct sock *sk = sk_pppox(po);
+			if (po->pppoe_dev != dev) {
+				po = po->next;
+				continue;
+			}
+			po->pppoe_dev = NULL;
+			dev_put(dev);
+			
+
+			/* We always grab the socket lock, followed by the
+			 * pppoe_hash_lock, in that order.  Since we should
+			 * hold the sock lock while doing any unbinding, 
+			 * we need to release the lock we're holding.  
+			 * Hold a reference to the sock so it doesn't disappear
+			 * as we're jumping between locks.
+			 */
 
-				sock_put(sk);
+			sock_hold(sk);
 
-				read_lock_bh(&pppoe_hash_lock);
+			write_unlock_bh(&pppoe_hash_lock);
+			lock_sock(sk);
 
-				/* Now restart from the beginning of this
-				 * hash chain.  We always NULL out pppoe_dev
-				 * so we are guaranteed to make forward
-				 * progress.
-				 */
-				po = item_hash_table[hash];
-				continue;
+			if (sk->sk_state & (PPPOX_CONNECTED | PPPOX_BOUND)) {
+				pppox_unbind_sock(sk);
+				sk->sk_state = PPPOX_ZOMBIE;
+				sk->sk_state_change(sk);
 			}
-			po = po->next;
+
+			release_sock(sk);
+			sock_put(sk);
+		
+			/* Restart scan at the beginning of this hash chain.
+			 * While the lock was dropped the chain contents may
+			 * have changed.
+			 */
+			write_lock_bh(&pppoe_hash_lock);
+			po = item_hash_table[hash];
 		}
 	}
-	read_unlock_bh(&pppoe_hash_lock);
+	write_unlock_bh(&pppoe_hash_lock);
 }
 
 static int pppoe_device_event(struct notifier_block *this,
@@ -504,28 +503,42 @@ static int pppoe_release(struct socket *sock)
 	if (!sk)
 		return 0;
 
-	if (sock_flag(sk, SOCK_DEAD))
+	lock_sock(sk);
+	if (sock_flag(sk, SOCK_DEAD)){
+		release_sock(sk);
 		return -EBADF;
+	}
 
 	pppox_unbind_sock(sk);
 
 	/* Signal the death of the socket. */
 	sk->sk_state = PPPOX_DEAD;
 
+
+	/* Write lock on hash lock protects the entire "po" struct from
+	 * concurrent updates via pppoe_flush_dev. The "po" struct should
+	 * be considered part of the hash table contents, thus protected
+	 * by the hash table lock */
+	write_lock_bh(&pppoe_hash_lock);
+
 	po = pppox_sk(sk);
 	if (po->pppoe_pa.sid) {
-		delete_item(po->pppoe_pa.sid, po->pppoe_pa.remote, po->pppoe_ifindex);
+		__delete_item(po->pppoe_pa.sid, 
+			      po->pppoe_pa.remote, po->pppoe_ifindex);
 	}
 
-	if (po->pppoe_dev)
+	if (po->pppoe_dev) {
 		dev_put(po->pppoe_dev);
+		po->pppoe_dev = NULL;
+	}
 
-	po->pppoe_dev = NULL;
+	write_unlock_bh(&pppoe_hash_lock);
 
 	sock_orphan(sk);
 	sock->sk = NULL;
 
 	skb_queue_purge(&sk->sk_receive_queue);
+	release_sock(sk);
 	sock_put(sk);
 
 	return 0;
-- 
1.5.0.g78e90

