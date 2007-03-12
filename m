From: Michal Ostrowski <mostrows@earthlink.net>
Subject: Re: [PATCH 4/4] PPPoE: race between interface going down and
	release()
Date: Sun, 11 Mar 2007 21:36:56 -0500
Message-ID: <1173667016.24373.36.camel@kdsk1.austin.ibm.com>
References: <20070311044143.GD17712@florz.florz.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Florian Zumbiehl <florz@florz.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from igw2.watson.ibm.com ([129.34.20.6]:52478 "EHLO
	igw2.watson.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932654AbXCLChJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Mar 2007 22:37:09 -0400
In-Reply-To: <20070311044143.GD17712@florz.florz.dyndns.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Attached below is my take on how to address this problem.  
This addresses any concerns you may have had about checking po->pppoe_dev==NULL,
because accesses to this field are now synchronized with pppoe_hash_lock.

Once we can settle on a fix for this, I'll deal with the SID==0 issue 
(trying to do that now would just cause patch conflicts).

-- 
Michal Ostrowski <mostrows@earthlink.net>



[PATCH] PPPOE Fix device tear-down notification.

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
 drivers/net/pppoe.c |   93 +++++++++++++++++++++++++++-----------------------
 1 files changed, 50 insertions(+), 43 deletions(-)

diff --git a/drivers/net/pppoe.c b/drivers/net/pppoe.c
index e097688..0961bf9 100644
--- a/drivers/net/pppoe.c
+++ b/drivers/net/pppoe.c
@@ -241,56 +241,53 @@ static inline struct pppox_sock *delete_item(unsigned long sid, char *addr, int
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
-
-				/* We hold a reference to SK, now drop the
-				 * hash table lock so that we may attempt
-				 * to lock the socket (which can sleep).
-				 */
-				read_unlock_bh(&pppoe_hash_lock);
-
-				lock_sock(sk);
-
-				if(po->pppoe_dev==dev){
-					dev_put(dev);
-					po->pppoe_dev = NULL;
-					if (sk->sk_state &
-					    (PPPOX_CONNECTED | PPPOX_BOUND)) {
-						pppox_unbind_sock(sk);
-						sk->sk_state = PPPOX_ZOMBIE;
-						sk->sk_state_change(sk);
-					}
-				}
-
-				release_sock(sk);
-
-				sock_put(sk);
-
-				read_lock_bh(&pppoe_hash_lock);
-
-				/* Now restart from the beginning of this
-				 * hash chain.  We always NULL out pppoe_dev
-				 * so we are guaranteed to make forward
-				 * progress.
-				 */
-				po = item_hash_table[hash];
+			struct sock *sk = sk_pppox(po);
+			if (po->pppoe_dev != dev) {
+				po = po->next;
 				continue;
 			}
-			po = po->next;
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
+
+			sock_hold(sk);
+
+			write_unlock_bh(&pppoe_hash_lock);
+			lock_sock(sk);
+
+			if (sk->sk_state & (PPPOX_CONNECTED | PPPOX_BOUND)) {
+				pppox_unbind_sock(sk);
+				sk->sk_state = PPPOX_ZOMBIE;
+				sk->sk_state_change(sk);
+			}
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
@@ -517,15 +514,25 @@ static int pppoe_release(struct socket *sock)
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
-- 
1.5.0.g78e90


