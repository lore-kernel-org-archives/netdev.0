From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 1/4] netlink: Move mutex_is_held under PROVE_LOCKING
Date: Thu, 13 Nov 2014 18:11:18 +0800
Message-ID: <E1XorN0-0000yw-5z@gondolin.me.apana.org.au>
References: <20141113101025.GA3728@gondor.apana.org.au>
To: netdev@vger.kernel.org, Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:56283 "EHLO
	helcar.apana.org.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932174AbaKMKLV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Nov 2014 05:11:21 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The rhashtable function mutex_is_held is only used when PROVE_LOCKING
is enabled.  This patch modifies netlink so that we can rhashtable.h
itself can later make mutex_is_held optional depending on PROVE_LOCKING.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/netlink/af_netlink.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 580b794..53b8ea7 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -114,14 +114,14 @@ static atomic_t nl_table_users = ATOMIC_INIT(0);
 DEFINE_MUTEX(nl_sk_hash_lock);
 EXPORT_SYMBOL_GPL(nl_sk_hash_lock);
 
+#ifdef CONFIG_PROVE_LOCKING
 static int lockdep_nl_sk_hash_is_held(void)
 {
-#ifdef CONFIG_LOCKDEP
 	if (debug_locks)
 		return lockdep_is_held(&nl_sk_hash_lock) || lockdep_is_held(&nl_table_lock);
-#endif
 	return 1;
 }
+#endif
 
 static ATOMIC_NOTIFIER_HEAD(netlink_chain);
 
@@ -3133,7 +3133,9 @@ static int __init netlink_proto_init(void)
 		.max_shift = 16, /* 64K */
 		.grow_decision = rht_grow_above_75,
 		.shrink_decision = rht_shrink_below_30,
+#ifdef CONFIG_PROVE_LOCKING
 		.mutex_is_held = lockdep_nl_sk_hash_is_held,
+#endif
 	};
 
 	if (err != 0)
