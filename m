From: "Arnaldo Carvalho de Melo" <acme@redhat.com>
Subject: [PATCH 2/2] [NET] proto: Use pcounters for the inuse field
Date: Wed, 7 Nov 2007 14:16:30 -0200
Message-ID: <20071107161630.GM27345@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dada1@cosmosbay.com, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:45288 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754321AbXKGQRB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Nov 2007 11:17:01 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 include/net/sock.h |   59 ++++++-------------------------------------------
 net/core/sock.c    |   61 +++++----------------------------------------------
 2 files changed, 14 insertions(+), 106 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 5504fb9..94f4819 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -47,6 +47,7 @@
 #include <linux/module.h>
 #include <linux/lockdep.h>
 #include <linux/netdevice.h>
+#include <linux/pcounter.h>
 #include <linux/skbuff.h>	/* struct sk_buff */
 #include <linux/mm.h>
 #include <linux/security.h>
@@ -560,14 +561,9 @@ struct proto {
 	void			(*unhash)(struct sock *sk);
 	int			(*get_port)(struct sock *sk, unsigned short snum);
 
-#ifdef CONFIG_SMP
 	/* Keeping track of sockets in use */
-	void			(*inuse_add)(struct proto *prot, int inc);
-	int			(*inuse_getval)(const struct proto *prot);
-	int			*inuse_ptr;
-#else
-	int			inuse;
-#endif
+	struct pcounter		inuse;
+
 	/* Memory pressure */
 	void			(*enter_memory_pressure)(void);
 	atomic_t		*memory_allocated;	/* Current allocated memory. */
@@ -602,35 +598,8 @@ struct proto {
 #endif
 };
 
-/*
- * Special macros to let protos use a fast version of inuse{get|add}
- * using a static percpu variable per proto instead of an allocated one,
- * saving one dereference.
- * This might be changed if/when dynamic percpu vars become fast.
- */
-#ifdef CONFIG_SMP
-# define DEFINE_PROTO_INUSE(NAME)			\
-static DEFINE_PER_CPU(int, NAME##_inuse);		\
-static void NAME##_inuse_add(struct proto *prot, int inc)	\
-{							\
-	__get_cpu_var(NAME##_inuse) += inc;		\
-}							\
-							\
-static int NAME##_inuse_getval(const struct proto *prot)\
-{							\
-	int res = 0, cpu;				\
-							\
-	for_each_possible_cpu(cpu)			\
-		res += per_cpu(NAME##_inuse, cpu);	\
-	return res;					\
-}
-# define REF_PROTO_INUSE(NAME)				\
-	.inuse_add = NAME##_inuse_add,			\
-	.inuse_getval = NAME##_inuse_getval,
-#else
-# define DEFINE_PROTO_INUSE(NAME)
-# define REF_PROTO_INUSE(NAME)
-#endif
+#define DEFINE_PROTO_INUSE(NAME) DEFINE_PCOUNTER(NAME)
+#define REF_PROTO_INUSE(NAME) PCOUNTER_MEMBER_INITIALIZER(NAME, .inuse)
 
 extern int proto_register(struct proto *prot, int alloc_slab);
 extern void proto_unregister(struct proto *prot);
@@ -663,29 +632,17 @@ static inline void sk_refcnt_debug_release(const struct sock *sk)
 /* Called with local bh disabled */
 static __inline__ void sock_prot_inc_use(struct proto *prot)
 {
-#ifdef CONFIG_SMP
-	prot->inuse_add(prot, 1);
-#else
-	prot->inuse++;
-#endif
+	pcounter_add(&prot->inuse, 1);
 }
 
 static __inline__ void sock_prot_dec_use(struct proto *prot)
 {
-#ifdef CONFIG_SMP
-	prot->inuse_add(prot, -1);
-#else
-	prot->inuse--;
-#endif
+	pcounter_add(&prot->inuse, -1);
 }
 
 static __inline__ int sock_prot_inuse(struct proto *proto)
 {
-#ifdef CONFIG_SMP
-	return proto->inuse_getval(proto);
-#else
-	return proto->inuse;
-#endif
+	return pcounter_getval(&proto->inuse);
 }
 
 /* With per-bucket locks this operation is not-atomic, so that
diff --git a/net/core/sock.c b/net/core/sock.c
index 8fc2f84..1f600e8 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1801,65 +1801,15 @@ EXPORT_SYMBOL(sk_common_release);
 static DEFINE_RWLOCK(proto_list_lock);
 static LIST_HEAD(proto_list);
 
-#ifdef CONFIG_SMP
-/*
- * Define default functions to keep track of inuse sockets per protocol
- * Note that often used protocols use dedicated functions to get a speed increase.
- * (see DEFINE_PROTO_INUSE/REF_PROTO_INUSE)
- */
-static void inuse_add(struct proto *prot, int inc)
-{
-	per_cpu_ptr(prot->inuse_ptr, smp_processor_id())[0] += inc;
-}
-
-static int inuse_get(const struct proto *prot)
-{
-	int res = 0, cpu;
-	for_each_possible_cpu(cpu)
-		res += per_cpu_ptr(prot->inuse_ptr, cpu)[0];
-	return res;
-}
-
-static int inuse_init(struct proto *prot)
-{
-	if (!prot->inuse_getval || !prot->inuse_add) {
-		prot->inuse_ptr = alloc_percpu(int);
-		if (prot->inuse_ptr == NULL)
-			return -ENOBUFS;
-
-		prot->inuse_getval = inuse_get;
-		prot->inuse_add = inuse_add;
-	}
-	return 0;
-}
-
-static void inuse_fini(struct proto *prot)
-{
-	if (prot->inuse_ptr != NULL) {
-		free_percpu(prot->inuse_ptr);
-		prot->inuse_ptr = NULL;
-		prot->inuse_getval = NULL;
-		prot->inuse_add = NULL;
-	}
-}
-#else
-static inline int inuse_init(struct proto *prot)
-{
-	return 0;
-}
-
-static inline void inuse_fini(struct proto *prot)
-{
-}
-#endif
-
 int proto_register(struct proto *prot, int alloc_slab)
 {
 	char *request_sock_slab_name = NULL;
 	char *timewait_sock_slab_name;
 
-	if (inuse_init(prot))
+	if (pcounter_alloc(&prot->inuse) != 0) {
+		printk(KERN_CRIT "%s: Can't alloc inuse counters!\n", prot->name);
 		goto out;
+	}
 
 	if (alloc_slab) {
 		prot->slab = kmem_cache_create(prot->name, prot->obj_size, 0,
@@ -1927,7 +1877,7 @@ out_free_sock_slab:
 	kmem_cache_destroy(prot->slab);
 	prot->slab = NULL;
 out_free_inuse:
-	inuse_fini(prot);
+	pcounter_free(&prot->inuse);
 out:
 	return -ENOBUFS;
 }
@@ -1940,7 +1890,8 @@ void proto_unregister(struct proto *prot)
 	list_del(&prot->node);
 	write_unlock(&proto_list_lock);
 
-	inuse_fini(prot);
+	pcounter_free(&prot->inuse);
+
 	if (prot->slab != NULL) {
 		kmem_cache_destroy(prot->slab);
 		prot->slab = NULL;
-- 
1.5.3.4

