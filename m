From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Subject: [PATCH v5 net-next 1/5] net: add napi_id and hash
Date: Mon, 27 May 2013 10:44:01 +0300
Message-ID: <20130527074401.29882.98135.stgit@ladj378.jer.intel.com>
References: <20130527074351.29882.51106.stgit@ladj378.jer.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Willem de Bruijn <willemb@google.com>, Or Gerlitz <or.gerlitz@gmail.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	HPA <hpa@zytor.com>, linux-kernel@vger.kernel.org,
	Alex Rosenbaum <alexr@mellanox.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Eliezer Tamir <eliezer@tamir.org.il>, Andi Kleen <andi@firstfloor.org>,
	Eilon Greenstien <eilong@broadcom.com>
To: Dave Miller <davem@davemloft.net>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20130527074351.29882.51106.stgit@ladj378.jer.intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Adds a napi_id and a hashing mechanism to lookup a napi by id.
This will be used by subsequent patches to implement low latency
Ethernet device polling.
Based on a code sample by Eric Dumazet.

Signed-off-by: Eliezer Tamir <eliezer.tamir@linux.intel.com>
---

 include/linux/netdevice.h |   29 +++++++++++++++++++++++++++++
 net/core/dev.c            |   44 ++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 73 insertions(+), 0 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index ea7b6bc..d1ec8b1 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -324,12 +324,15 @@ struct napi_struct {
 	struct sk_buff		*gro_list;
 	struct sk_buff		*skb;
 	struct list_head	dev_list;
+	struct hlist_node	napi_hash_node;
+	int			napi_id;
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
+ *	napi_hash_add - add a NAPI to global hashtable
+ *	@napi: napi context
+ *
+ * generate a new napi_id and store a @napi under it in napi_hash
+ */
+extern void napi_hash_add(struct napi_struct *napi);
+
+/**
+ *	napi_hash_del - remove a NAPI from blobal table
+ *	@napi: napi context
+ *
+ * Warning: caller must observe rcu grace period
+ * before freeing memory containing @NAPI
+ */
+extern void napi_hash_del(struct napi_struct *napi);
+
+/**
+ *	napi_by_is - lookup a NAPI by napi_id
+ *	@napi_id: hashed napi_id
+ *
+ * lookup napi_id in napi_hash table
+ * must be called under rcu_read_lock()
+ */
+extern struct napi_struct *napi_by_id(int napi_id);
+
+/**
  *	napi_disable - prevent NAPI from scheduling
  *	@n: napi context
  *
diff --git a/net/core/dev.c b/net/core/dev.c
index 50c02de..283ab14 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -129,6 +129,7 @@
 #include <linux/inetdevice.h>
 #include <linux/cpu_rmap.h>
 #include <linux/static_key.h>
+#include <linux/hashtable.h>
 
 #include "net-sysfs.h"
 
@@ -166,6 +167,10 @@ static struct list_head offload_base __read_mostly;
 DEFINE_RWLOCK(dev_base_lock);
 EXPORT_SYMBOL(dev_base_lock);
 
+atomic_t napi_gen_id;
+
+DEFINE_HASHTABLE(napi_hash, 8);
+
 seqcount_t devnet_rename_seq;
 
 static inline void dev_base_seq_inc(struct net *net)
@@ -4113,6 +4118,45 @@ void napi_complete(struct napi_struct *n)
 }
 EXPORT_SYMBOL(napi_complete);
 
+void napi_hash_add(struct napi_struct *napi)
+{
+	if (!test_and_set_bit(NAPI_STATE_HASHED, &napi->state)) {
+
+		/* 0 is not a valid id */
+		napi->napi_id = 0;
+		while (!napi->napi_id)
+			napi->napi_id = atomic_inc_return(&napi_gen_id);
+
+		hlist_add_head_rcu(&napi->napi_hash_node,
+			&napi_hash[napi->napi_id % HASH_SIZE(napi_hash)]);
+	}
+}
+EXPORT_SYMBOL_GPL(napi_hash_add);
+
+/* Warning : caller is responsible to make sure rcu grace period
+ * is respected before freeing memory containing @napi
+ */
+void napi_hash_del(struct napi_struct *napi)
+{
+	if (test_and_clear_bit(NAPI_STATE_HASHED, &napi->state))
+		hlist_del_rcu(&napi->napi_hash_node);
+}
+EXPORT_SYMBOL_GPL(napi_hash_del);
+
+/* must be called under rcu_read_lock(), as we dont take a reference */
+struct napi_struct *napi_by_id(int napi_id)
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
 void netif_napi_add(struct net_device *dev, struct napi_struct *napi,
 		    int (*poll)(struct napi_struct *, int), int weight)
 {


------------------------------------------------------------------------------
Try New Relic Now & We'll Send You this Cool Shirt
New Relic is the only SaaS-based application performance monitoring service 
that delivers powerful full stack analytics. Optimize and monitor your
browser, app, & servers with just a few lines of code. Try New Relic
and get this awesome Nerd Life shirt! http://p.sf.net/sfu/newrelic_d2d_may
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
