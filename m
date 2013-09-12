From: Jun Chen <jun.d.chen@intel.com>
Subject: [PATCH] Inet-hashtable: Change the range of sk->hash lock to avoid
 the race condition.
Date: Thu, 12 Sep 2013 12:32:29 -0400
Message-ID: <1379003549.12328.6.camel@chenjun-workstation>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jun Chen <jun.d.chen@intel.com>
To: edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:11650 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754588Ab3ILIdQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Sep 2013 04:33:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


When try to add node to list in __inet_hash_nolisten function, first get the
list and then to lock for using, but in extremeness case, others can del this
node before locking it, then the node should be null.So this patch try to lock
firstly and then get the list for using to avoid this race condition.

Signed-off-by: Chen Jun <jun.d.chen@intel.com>
---
 net/ipv4/inet_hashtables.c |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index 7bd8983..76e846e 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -407,12 +407,15 @@ int __inet_hash_nolisten(struct sock *sk, struct inet_timewait_sock *tw)
 	WARN_ON(!sk_unhashed(sk));
 
 	sk->sk_hash = inet_sk_ehashfn(sk);
-	head = inet_ehash_bucket(hashinfo, sk->sk_hash);
-	list = &head->chain;
 	lock = inet_ehash_lockp(hashinfo, sk->sk_hash);
 
 	spin_lock(lock);
-	__sk_nulls_add_node_rcu(sk, list);
+	if (sk_hashed(sk)) {
+		head = inet_ehash_bucket(hashinfo, sk->sk_hash);
+		list = &head->chain;
+		__sk_nulls_add_node_rcu(sk, list);
+	}
+
 	if (tw) {
 		WARN_ON(sk->sk_hash != tw->tw_hash);
 		twrefcnt = inet_twsk_unhash(tw);
-- 
1.7.4.1
