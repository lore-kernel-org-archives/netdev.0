From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH 1/4] NET : defines an infrastructure to keep 'inuse' changes
 in an efficent SMP/NUMA way.
Date: Mon, 05 Nov 2007 18:56:56 +0100
Message-ID: <472F5968.5030607@cosmosbay.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020406060208030507090202"
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2f.orange.fr ([80.12.242.152]:59581 "EHLO smtp2f.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754696AbXKER47 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Nov 2007 12:56:59 -0500
Received: from me-wanadoo.net (localhost [127.0.0.1])
	by mwinf2f26.orange.fr (SMTP Server) with ESMTP id 6796E700009B
	for <netdev@vger.kernel.org>; Mon,  5 Nov 2007 18:56:58 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------020406060208030507090202
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

"struct proto" currently uses an array stats[NR_CPUS] to track change on 
'inuse' sockets per protocol.

If NR_CPUS is big, this means we use a big memory area for this.
Moreover, all this memory area is located on a single node on NUMA 
machines, increasing memory pressure on the boot node.

In this patch, I tried to :

- Keep a fast !CONFIG_SMP implementation
- Keep a fast CONFIG_SMP implementation for often used protocols 
(tcp,udp,raw,...)
- Introduce a NUMA efficient implementation

Some helper macros are defined in include/net/sock.h
These macros take into account CONFIG_SMP

If a "struct proto" is declared without using DEFINE_PROTO_INUSE / 
REF_PROTO_INUSE
macros, it will automatically use a default implementation, using a 
dynamically allocated percpu zone.
This default implementation will be NUMA efficient, but might use 32/64 
bytes per possible cpu
because of current alloc_percpu() implementation.
However it still should be better than previous implementation based on 
stats[NR_CPUS] field.

When a "struct proto" is changed to use the new macros, we use a single 
static "int" percpu variable,
lowering the memory and cpu costs, still preserving NUMA efficiency.


Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

 include/net/sock.h |   63 ++++++++++++++++++++++++++++++++++++++-----
 net/core/sock.c    |   48 ++++++++++++++++++++++++++++++++
 net/ipv4/proc.c    |   19 ++----------
 net/ipv6/proc.c    |   19 ++----------
 4 files changed, 112 insertions(+), 37 deletions(-)



--------------020406060208030507090202
Content-Type: text/plain;
 name="prot_inuse_infra.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="prot_inuse_infra.patch"

diff --git a/include/net/sock.h b/include/net/sock.h
index 20de3fa..5504fb9 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -560,6 +560,14 @@ struct proto {
 	void			(*unhash)(struct sock *sk);
 	int			(*get_port)(struct sock *sk, unsigned short snum);
 
+#ifdef CONFIG_SMP
+	/* Keeping track of sockets in use */
+	void			(*inuse_add)(struct proto *prot, int inc);
+	int			(*inuse_getval)(const struct proto *prot);
+	int			*inuse_ptr;
+#else
+	int			inuse;
+#endif
 	/* Memory pressure */
 	void			(*enter_memory_pressure)(void);
 	atomic_t		*memory_allocated;	/* Current allocated memory. */
@@ -592,12 +600,38 @@ struct proto {
 #ifdef SOCK_REFCNT_DEBUG
 	atomic_t		socks;
 #endif
-	struct {
-		int inuse;
-		u8  __pad[SMP_CACHE_BYTES - sizeof(int)];
-	} stats[NR_CPUS];
 };
 
+/*
+ * Special macros to let protos use a fast version of inuse{get|add}
+ * using a static percpu variable per proto instead of an allocated one,
+ * saving one dereference.
+ * This might be changed if/when dynamic percpu vars become fast.
+ */
+#ifdef CONFIG_SMP
+# define DEFINE_PROTO_INUSE(NAME)			\
+static DEFINE_PER_CPU(int, NAME##_inuse);		\
+static void NAME##_inuse_add(struct proto *prot, int inc)	\
+{							\
+	__get_cpu_var(NAME##_inuse) += inc;		\
+}							\
+							\
+static int NAME##_inuse_getval(const struct proto *prot)\
+{							\
+	int res = 0, cpu;				\
+							\
+	for_each_possible_cpu(cpu)			\
+		res += per_cpu(NAME##_inuse, cpu);	\
+	return res;					\
+}
+# define REF_PROTO_INUSE(NAME)				\
+	.inuse_add = NAME##_inuse_add,			\
+	.inuse_getval = NAME##_inuse_getval,
+#else
+# define DEFINE_PROTO_INUSE(NAME)
+# define REF_PROTO_INUSE(NAME)
+#endif
+
 extern int proto_register(struct proto *prot, int alloc_slab);
 extern void proto_unregister(struct proto *prot);
 
@@ -629,12 +663,29 @@ static inline void sk_refcnt_debug_release(const struct sock *sk)
 /* Called with local bh disabled */
 static __inline__ void sock_prot_inc_use(struct proto *prot)
 {
-	prot->stats[smp_processor_id()].inuse++;
+#ifdef CONFIG_SMP
+	prot->inuse_add(prot, 1);
+#else
+	prot->inuse++;
+#endif
 }
 
 static __inline__ void sock_prot_dec_use(struct proto *prot)
 {
-	prot->stats[smp_processor_id()].inuse--;
+#ifdef CONFIG_SMP
+	prot->inuse_add(prot, -1);
+#else
+	prot->inuse--;
+#endif
+}
+
+static __inline__ int sock_prot_inuse(struct proto *proto)
+{
+#ifdef CONFIG_SMP
+	return proto->inuse_getval(proto);
+#else
+	return proto->inuse;
+#endif
 }
 
 /* With per-bucket locks this operation is not-atomic, so that
diff --git a/net/core/sock.c b/net/core/sock.c
index 12ad206..e077f26 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1801,12 +1801,41 @@ EXPORT_SYMBOL(sk_common_release);
 static DEFINE_RWLOCK(proto_list_lock);
 static LIST_HEAD(proto_list);
 
+#ifdef CONFIG_SMP
+/*
+ * Define default functions to keep track of inuse sockets per protocol
+ * Note that often used protocols use dedicated functions to get a speed increase.
+ * (see DEFINE_PROTO_INUSE/REF_PROTO_INUSE)
+ */
+static void inuse_add(struct proto *prot, int inc)
+{
+	per_cpu_ptr(prot->inuse_ptr, smp_processor_id())[0] += inc;
+}
+
+static int inuse_get(const struct proto *prot)
+{
+	int res = 0, cpu;
+	for_each_possible_cpu(cpu)
+		res += per_cpu_ptr(prot->inuse_ptr, cpu)[0];
+	return res;
+}
+#endif
+
 int proto_register(struct proto *prot, int alloc_slab)
 {
 	char *request_sock_slab_name = NULL;
 	char *timewait_sock_slab_name;
 	int rc = -ENOBUFS;
 
+#ifdef CONFIG_SMP
+	if (!prot->inuse_getval || !prot->inuse_add) {
+		prot->inuse_ptr = alloc_percpu(int);
+		if (prot->inuse_ptr == NULL)
+			goto out;
+		prot->inuse_getval = inuse_get;
+		prot->inuse_add = inuse_add;
+	}
+#endif
 	if (alloc_slab) {
 		prot->slab = kmem_cache_create(prot->name, prot->obj_size, 0,
 					       SLAB_HWCACHE_ALIGN, NULL);
@@ -1814,7 +1843,7 @@ int proto_register(struct proto *prot, int alloc_slab)
 		if (prot->slab == NULL) {
 			printk(KERN_CRIT "%s: Can't create sock SLAB cache!\n",
 			       prot->name);
-			goto out;
+			goto out_free_inuse;
 		}
 
 		if (prot->rsk_prot != NULL) {
@@ -1873,6 +1902,15 @@ out_free_request_sock_slab_name:
 out_free_sock_slab:
 	kmem_cache_destroy(prot->slab);
 	prot->slab = NULL;
+out_free_inuse:
+#ifdef CONFIG_SMP
+	if (prot->inuse_ptr != NULL) {
+		free_percpu(prot->inuse_ptr);
+		prot->inuse_ptr = NULL;
+		prot->inuse_getval = NULL;
+		prot->inuse_add = NULL;
+	}
+#endif
 	goto out;
 }
 
@@ -1884,6 +1922,14 @@ void proto_unregister(struct proto *prot)
 	list_del(&prot->node);
 	write_unlock(&proto_list_lock);
 
+#ifdef CONFIG_SMP
+	if (prot->inuse_ptr != NULL) {
+		free_percpu(prot->inuse_ptr);
+		prot->inuse_ptr = NULL;
+		prot->inuse_getval = NULL;
+		prot->inuse_add = NULL;
+	}
+#endif
 	if (prot->slab != NULL) {
 		kmem_cache_destroy(prot->slab);
 		prot->slab = NULL;
diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
index ffdccc0..ce34b28 100644
--- a/net/ipv4/proc.c
+++ b/net/ipv4/proc.c
@@ -46,17 +46,6 @@
 #include <net/sock.h>
 #include <net/raw.h>
 
-static int fold_prot_inuse(struct proto *proto)
-{
-	int res = 0;
-	int cpu;
-
-	for_each_possible_cpu(cpu)
-		res += proto->stats[cpu].inuse;
-
-	return res;
-}
-
 /*
  *	Report socket allocation statistics [mea@utu.fi]
  */
@@ -64,12 +53,12 @@ static int sockstat_seq_show(struct seq_file *seq, void *v)
 {
 	socket_seq_show(seq);
 	seq_printf(seq, "TCP: inuse %d orphan %d tw %d alloc %d mem %d\n",
-		   fold_prot_inuse(&tcp_prot), atomic_read(&tcp_orphan_count),
+		   sock_prot_inuse(&tcp_prot), atomic_read(&tcp_orphan_count),
 		   tcp_death_row.tw_count, atomic_read(&tcp_sockets_allocated),
 		   atomic_read(&tcp_memory_allocated));
-	seq_printf(seq, "UDP: inuse %d\n", fold_prot_inuse(&udp_prot));
-	seq_printf(seq, "UDPLITE: inuse %d\n", fold_prot_inuse(&udplite_prot));
-	seq_printf(seq, "RAW: inuse %d\n", fold_prot_inuse(&raw_prot));
+	seq_printf(seq, "UDP: inuse %d\n", sock_prot_inuse(&udp_prot));
+	seq_printf(seq, "UDPLITE: inuse %d\n", sock_prot_inuse(&udplite_prot));
+	seq_printf(seq, "RAW: inuse %d\n", sock_prot_inuse(&raw_prot));
 	seq_printf(seq,  "FRAG: inuse %d memory %d\n",
 			ip_frag_nqueues(), ip_frag_mem());
 	return 0;
diff --git a/net/ipv6/proc.c b/net/ipv6/proc.c
index be526ad..8631ed7 100644
--- a/net/ipv6/proc.c
+++ b/net/ipv6/proc.c
@@ -32,27 +32,16 @@
 
 static struct proc_dir_entry *proc_net_devsnmp6;
 
-static int fold_prot_inuse(struct proto *proto)
-{
-	int res = 0;
-	int cpu;
-
-	for_each_possible_cpu(cpu)
-		res += proto->stats[cpu].inuse;
-
-	return res;
-}
-
 static int sockstat6_seq_show(struct seq_file *seq, void *v)
 {
 	seq_printf(seq, "TCP6: inuse %d\n",
-		       fold_prot_inuse(&tcpv6_prot));
+		       sock_prot_inuse(&tcpv6_prot));
 	seq_printf(seq, "UDP6: inuse %d\n",
-		       fold_prot_inuse(&udpv6_prot));
+		       sock_prot_inuse(&udpv6_prot));
 	seq_printf(seq, "UDPLITE6: inuse %d\n",
-			fold_prot_inuse(&udplitev6_prot));
+			sock_prot_inuse(&udplitev6_prot));
 	seq_printf(seq, "RAW6: inuse %d\n",
-		       fold_prot_inuse(&rawv6_prot));
+		       sock_prot_inuse(&rawv6_prot));
 	seq_printf(seq, "FRAG6: inuse %d memory %d\n",
 		       ip6_frag_nqueues(), ip6_frag_mem());
 	return 0;

--------------020406060208030507090202--


