From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Subject: [PATCH v8 net-next 1/7] net: add napi_id and hash
Date: Mon, 03 Jun 2013 11:01:17 +0300
Message-ID: <20130603080117.18273.68908.stgit@ladj378.jer.intel.com>
References: <20130603080107.18273.34279.stgit@ladj378.jer.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	e1000-devel@lists.sourceforge.net,
	Willem de Bruijn <willemb@google.com>,
	Eric Dumazet <erdnetdev@gmail.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Andi Kleen <andi@firstfloor.org>, HPA <hpa@zytor.com>,
	Eilon Greenstien <eilong@broadcom.com>,
	Or Gerlitz <or.gerlitz@gmail.com>,
	Alex Rosenbaum <alexr@mellanox.com>,
	Eliezer Tamir <eliezer@tamir.org.il>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:31552 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751167Ab3FCIBY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Jun 2013 04:01:24 -0400
In-Reply-To: <20130603080107.18273.34279.stgit@ladj378.jer.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adds a napi_id and a hashing mechanism to lookup a napi by id.
This will be used by subsequent patches to implement low latency
Ethernet device polling.
Based on a code sample by Eric Dumazet.

Signed-off-by: Eliezer Tamir <eliezer.tamir@linux.intel.com>
---

 include/linux/netdevice.h |   29 ++++++++++++++++++++++
 net/core/dev.c            |   59 +++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 88 insertions(+), 0 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 8f967e3..39bbd46 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -324,12 +324,15 @@ struct napi_struct {
 	struct sk_buff		*gro_list;
 	struct sk_buff		*skb;
 	struct list_head	dev_list;
+	struct hlist_node	napi_hash_node;
+	unsigned int		napi_id;
 };
 
 enum {
 	NAPI_STATE_SCHED,	/* Poll is scheduled */
 	NAPI_STATE_DISABLE,	/* Disable pending */
 	NAPI_STATE_NPSVC,	/* Netpoll - don't dequeue from poll_list */
+	NAPI_STATE_HASHED,	/* In NAPI hash */
 };
 
 enum gro_result {
@@ -446,6 +449,32 @@ extern void __napi_complete(struct napi_struct *n);
 extern void napi_complete(struct napi_struct *n);
 
 /**
+ *	napi_by_id - lookup a NAPI by napi_id
+ *	@napi_id: hashed napi_id
+ *
+ * lookup @napi_id in napi_hash table
+ * must be called under rcu_read_lock()
+ */
+extern struct napi_struct *napi_by_id(unsigned int napi_id);
+
+/**
+ *	napi_hash_add - add a NAPI to global hashtable
+ *	@napi: napi context
+ *
+ * generate a new napi_id and store a @napi under it in napi_hash
+ */
+extern void napi_hash_add(struct napi_struct *napi);
+
+/**
+ *	napi_hash_del - remove a NAPI from global table
+ *	@napi: napi context
+ *
+ * Warning: caller must observe rcu grace period
+ * before freeing memory containing @napi
+ */
+extern void napi_hash_del(struct napi_struct *napi);
+
+/**
  *	napi_disable - prevent NAPI from scheduling
  *	@n: napi context
  *
diff --git a/net/core/dev.c b/net/core/dev.c
index d4d874a..f8388a0 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -129,6 +129,7 @@
 #include <linux/inetdevice.h>
 #include <linux/cpu_rmap.h>
 #include <linux/static_key.h>
+#include <linux/hashtable.h>
 
 #include "net-sysfs.h"
 
@@ -166,6 +167,12 @@ static struct list_head offload_base __read_mostly;
 DEFINE_RWLOCK(dev_base_lock);
 EXPORT_SYMBOL(dev_base_lock);
 
+/* protects napi_hash addition/deletion and napi_gen_id */
+static DEFINE_SPINLOCK(napi_hash_lock);
+
+static unsigned int napi_gen_id;
+static DEFINE_HASHTABLE(napi_hash, 8);
+
 seqcount_t devnet_rename_seq;
 
 static inline void dev_base_seq_inc(struct net *net)
@@ -4136,6 +4143,58 @@ void napi_complete(struct napi_struct *n)
 }
 EXPORT_SYMBOL(napi_complete);
 
+/* must be called under rcu_read_lock(), as we dont take a reference */
+struct napi_struct *napi_by_id(unsigned int napi_id)
+{
+	unsigned int hash = napi_id % HASH_SIZE(napi_hash);
+	struct napi_struct *napi;
+
+	hlist_for_each_entry_rcu(napi, &napi_hash[hash], napi_hash_node)
+		if (napi->napi_id == napi_id)
+			return napi;
+
+	return NULL;
+}
+EXPORT_SYMBOL_GPL(napi_by_id);
+
+void napi_hash_add(struct napi_struct *napi)
+{
+	if (!test_and_set_bit(NAPI_STATE_HASHED, &napi->state)) {
+
+		spin_lock(&napi_hash_lock);
+
+		/* 0 is not a valid id, we also skip an id that is taken
+		 * we expect both events to be extremely rare
+		 */
+		napi->napi_id = 0;
+		while (!napi->napi_id) {
+			napi->napi_id = ++napi_gen_id;
+			if (napi_by_id(napi->napi_id))
+				napi->napi_id = 0;
+		}
+
+		hlist_add_head_rcu(&napi->napi_hash_node,
+			&napi_hash[napi->napi_id % HASH_SIZE(napi_hash)]);
+
+		spin_unlock(&napi_hash_lock);
+	}
+}
+EXPORT_SYMBOL_GPL(napi_hash_add);
+
+/* Warning : caller is responsible to make sure rcu grace period
+ * is respected before freeing memory containing @napi
+ */
+void napi_hash_del(struct napi_struct *napi)
+{
+	spin_lock(&napi_hash_lock);
+
+	if (test_and_clear_bit(NAPI_STATE_HASHED, &napi->state))
+		hlist_del_rcu(&napi->napi_hash_node);
+
+	spin_unlock(&napi_hash_lock);
+}
+EXPORT_SYMBOL_GPL(napi_hash_del);
+
 void netif_napi_add(struct net_device *dev, struct napi_struct *napi,
 		    int (*poll)(struct napi_struct *, int), int weight)
 {
