From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v2 net-next 13/14] net: napi_hash_del() returns a boolean status
Date: Wed, 18 Nov 2015 06:31:02 -0800
Message-ID: <1447857063-618-14-git-send-email-edumazet@google.com>
References: <1447857063-618-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eliezer Tamir <eliezer.tamir@linux.intel.com>,
	Eli Cohen <eli@mellanox.com>,
	Eugenia Emantayev <eugenia@mellanox.com>,
	Ariel Elior <ariel.elior@qlogic.com>,
	Willem de Bruijn <willemb@google.com>,
	Rida Assaf <rida@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:36763 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933050AbbKROby (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Nov 2015 09:31:54 -0500
Received: by pacdm15 with SMTP id dm15so46634432pac.3
        for <netdev@vger.kernel.org>; Wed, 18 Nov 2015 06:31:53 -0800 (PST)
In-Reply-To: <1447857063-618-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

napi_hash_del() will soon be used from both drivers (if they want)
or core networking stack.

Callers are responsibles to ensure an RCU grace period is respected
before freeing napi structure : napi_hash_del() can signal if
this RCU grace period is needed or not.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/linux/netdevice.h |  5 +++--
 net/core/dev.c            | 10 +++++++---
 2 files changed, 10 insertions(+), 5 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 838935d1cdbb..e5c33b29471b 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -474,9 +474,10 @@ void napi_hash_add(struct napi_struct *napi);
  *	@napi: napi context
  *
  * Warning: caller must observe rcu grace period
- * before freeing memory containing @napi
+ * before freeing memory containing @napi, if
+ * this function returns true.
  */
-void napi_hash_del(struct napi_struct *napi);
+bool napi_hash_del(struct napi_struct *napi);
 
 /**
  *	napi_disable - prevent NAPI from scheduling
diff --git a/net/core/dev.c b/net/core/dev.c
index 02dfbd91a8e4..59dddac1c2e7 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4760,14 +4760,18 @@ EXPORT_SYMBOL_GPL(napi_hash_add);
 /* Warning : caller is responsible to make sure rcu grace period
  * is respected before freeing memory containing @napi
  */
-void napi_hash_del(struct napi_struct *napi)
+bool napi_hash_del(struct napi_struct *napi)
 {
+	bool rcu_sync_needed = false;
+
 	spin_lock(&napi_hash_lock);
 
-	if (test_and_clear_bit(NAPI_STATE_HASHED, &napi->state))
+	if (test_and_clear_bit(NAPI_STATE_HASHED, &napi->state)) {
+		rcu_sync_needed = true;
 		hlist_del_rcu(&napi->napi_hash_node);
-
+	}
 	spin_unlock(&napi_hash_lock);
+	return rcu_sync_needed;
 }
 EXPORT_SYMBOL_GPL(napi_hash_del);
 
-- 
2.6.0.rc2.230.g3dd15c0
