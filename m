From: Jiri Pirko <jpirko@redhat.com>
Subject: [PATCH net-next-2.6] net: disallow to use net_assign_generic
 externally
Date: Fri, 23 Apr 2010 13:40:47 +0200
Message-ID: <20100423114046.GC2853@psychotron.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, ebiederm@xmission.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:24654 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757221Ab0DWLku (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Apr 2010 07:40:50 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now there's no need to use this fuction directly because it's handled by
register_pernet_device. So to make this simple and easy to understand,
make this static to do not tempt potentional users.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>

diff --git a/include/net/netns/generic.h b/include/net/netns/generic.h
index ff4982a..81a31c0 100644
--- a/include/net/netns/generic.h
+++ b/include/net/netns/generic.h
@@ -14,11 +14,8 @@
  * The rules are simple:
  * 1. set pernet_operations->id.  After register_pernet_device you
  *    will have the id of your private pointer.
- * 2. Either set pernet_operations->size (to have the code allocate and
- *    free a private structure pointed to from struct net ) or 
- *    call net_assign_generic() to put the private data on the struct
- *    net (most preferably this should be done in the ->init callback
- *    of the ops registered);
+ * 2. set pernet_operations->size to have the code allocate and free
+ *    a private structure pointed to from struct net.
  * 3. do not change this pointer while the net is alive;
  * 4. do not try to have any private reference on the net_generic object.
  *
@@ -46,6 +43,4 @@ static inline void *net_generic(struct net *net, int id)
 
 	return ptr;
 }
-
-extern int net_assign_generic(struct net *net, int id, void *data);
 #endif
diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index bd8c471..777477c 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -27,6 +27,51 @@ EXPORT_SYMBOL(init_net);
 
 #define INITIAL_NET_GEN_PTRS	13 /* +1 for len +2 for rcu_head */
 
+static void net_generic_release(struct rcu_head *rcu)
+{
+	struct net_generic *ng;
+
+	ng = container_of(rcu, struct net_generic, rcu);
+	kfree(ng);
+}
+
+static int net_assign_generic(struct net *net, int id, void *data)
+{
+	struct net_generic *ng, *old_ng;
+
+	BUG_ON(!mutex_is_locked(&net_mutex));
+	BUG_ON(id == 0);
+
+	ng = old_ng = net->gen;
+	if (old_ng->len >= id)
+		goto assign;
+
+	ng = kzalloc(sizeof(struct net_generic) +
+			id * sizeof(void *), GFP_KERNEL);
+	if (ng == NULL)
+		return -ENOMEM;
+
+	/*
+	 * Some synchronisation notes:
+	 *
+	 * The net_generic explores the net->gen array inside rcu
+	 * read section. Besides once set the net->gen->ptr[x]
+	 * pointer never changes (see rules in netns/generic.h).
+	 *
+	 * That said, we simply duplicate this array and schedule
+	 * the old copy for kfree after a grace period.
+	 */
+
+	ng->len = id;
+	memcpy(&ng->ptr, &old_ng->ptr, old_ng->len * sizeof(void*));
+
+	rcu_assign_pointer(net->gen, ng);
+	call_rcu(&old_ng->rcu, net_generic_release);
+assign:
+	ng->ptr[id - 1] = data;
+	return 0;
+}
+
 static int ops_init(const struct pernet_operations *ops, struct net *net)
 {
 	int err;
@@ -526,49 +571,3 @@ void unregister_pernet_device(struct pernet_operations *ops)
 	mutex_unlock(&net_mutex);
 }
 EXPORT_SYMBOL_GPL(unregister_pernet_device);
-
-static void net_generic_release(struct rcu_head *rcu)
-{
-	struct net_generic *ng;
-
-	ng = container_of(rcu, struct net_generic, rcu);
-	kfree(ng);
-}
-
-int net_assign_generic(struct net *net, int id, void *data)
-{
-	struct net_generic *ng, *old_ng;
-
-	BUG_ON(!mutex_is_locked(&net_mutex));
-	BUG_ON(id == 0);
-
-	ng = old_ng = net->gen;
-	if (old_ng->len >= id)
-		goto assign;
-
-	ng = kzalloc(sizeof(struct net_generic) +
-			id * sizeof(void *), GFP_KERNEL);
-	if (ng == NULL)
-		return -ENOMEM;
-
-	/*
-	 * Some synchronisation notes:
-	 *
-	 * The net_generic explores the net->gen array inside rcu
-	 * read section. Besides once set the net->gen->ptr[x]
-	 * pointer never changes (see rules in netns/generic.h).
-	 *
-	 * That said, we simply duplicate this array and schedule
-	 * the old copy for kfree after a grace period.
-	 */
-
-	ng->len = id;
-	memcpy(&ng->ptr, &old_ng->ptr, old_ng->len * sizeof(void*));
-
-	rcu_assign_pointer(net->gen, ng);
-	call_rcu(&old_ng->rcu, net_generic_release);
-assign:
-	ng->ptr[id - 1] = data;
-	return 0;
-}
-EXPORT_SYMBOL_GPL(net_assign_generic);
