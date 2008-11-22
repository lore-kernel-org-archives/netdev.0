From: David Miller <davem@davemloft.net>
Subject: [PATCH]: inet_diag: Missed conversion after changing inet ehash
 lockl to spinlocks.
Date: Fri, 21 Nov 2008 16:40:13 -0800 (PST)
Message-ID: <20081121.164013.199583439.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39597
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753855AbYKVAkO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2008 19:40:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Tsk tsk... :) I just commited the following to net-next-2.6

inet_diag: Missed conversion after changing inet ehash lockl to spinlocks.

They are no longer a rwlocks.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/inet_diag.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index 1cb154e..998a78f 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -778,7 +778,7 @@ skip_listen_ht:
 
 	for (i = s_i; i < hashinfo->ehash_size; i++) {
 		struct inet_ehash_bucket *head = &hashinfo->ehash[i];
-		rwlock_t *lock = inet_ehash_lockp(hashinfo, i);
+		spinlock_t *lock = inet_ehash_lockp(hashinfo, i);
 		struct sock *sk;
 		struct hlist_nulls_node *node;
 
@@ -791,7 +791,7 @@ skip_listen_ht:
 		if (i > s_i)
 			s_num = 0;
 
-		read_lock_bh(lock);
+		spin_lock_bh(lock);
 		sk_nulls_for_each(sk, node, &head->chain) {
 			struct inet_sock *inet = inet_sk(sk);
 
@@ -806,7 +806,7 @@ skip_listen_ht:
 			    r->id.idiag_dport)
 				goto next_normal;
 			if (inet_csk_diag_dump(sk, skb, cb) < 0) {
-				read_unlock_bh(lock);
+				spin_unlock_bh(lock);
 				goto done;
 			}
 next_normal:
@@ -828,14 +828,14 @@ next_normal:
 				    r->id.idiag_dport)
 					goto next_dying;
 				if (inet_twsk_diag_dump(tw, skb, cb) < 0) {
-					read_unlock_bh(lock);
+					spin_unlock_bh(lock);
 					goto done;
 				}
 next_dying:
 				++num;
 			}
 		}
-		read_unlock_bh(lock);
+		spin_unlock_bh(lock);
 	}
 
 done:
-- 
1.5.6.5

