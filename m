From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-2.6.26 2/5][SOCK]: Introduce a percpu inuse counting array.
Date: Fri, 28 Mar 2008 12:03:08 +0300
Message-ID: <47ECB44C.5080807@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:40273 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754708AbYC1JDL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Mar 2008 05:03:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

And redirect sock_prot_inuse_add|_get to use one.

As far as the dereferences are concerned. Before the patch we made
1 dereference to proto->inuse.add call, the call itself and then
made a __get_cpu_var() on a static variable. After the patch we make
a direct call, then one dereference to proto->inuse_idx and then
the same __get_cpu_var() on a still static variable. So this patch
doesn't seem to produce performance penalty on SMP.

Besides, add a sanity check into inuse_idx generator.

This is net per-net yet, but I will deliberately make this case
separated from NET_NS=n, since it'll cost us one-or-two more 
dereferences to get the struct net and the inuse counter.


Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 include/net/sock.h |   13 +++++--------
 net/core/sock.c    |   34 ++++++++++++++++++++++++++++++++++
 2 files changed, 39 insertions(+), 8 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index abc6341..ebf9552 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -639,18 +639,15 @@ static inline void sk_refcnt_debug_release(const struct sock *sk)
 # define DEFINE_PROTO_INUSE(NAME) DEFINE_PCOUNTER(NAME)
 # define REF_PROTO_INUSE(NAME) PCOUNTER_MEMBER_INITIALIZER(NAME, .inuse)
 /* Called with local bh disabled */
-static inline void sock_prot_inuse_add(struct proto *prot, int inc)
-{
-	pcounter_add(&prot->inuse, inc);
-}
+extern void sock_prot_inuse_add(struct proto *prot, int inc);
+
 static inline int sock_prot_inuse_init(struct proto *proto)
 {
 	return pcounter_alloc(&proto->inuse);
 }
-static inline int sock_prot_inuse_get(struct proto *proto)
-{
-	return pcounter_getval(&proto->inuse);
-}
+
+extern int sock_prot_inuse_get(struct proto *proto);
+
 static inline void sock_prot_inuse_free(struct proto *proto)
 {
 	pcounter_free(&proto->inuse);
diff --git a/net/core/sock.c b/net/core/sock.c
index a7faf30..2b6f8f1 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1940,11 +1940,45 @@ EXPORT_SYMBOL(sk_common_release);
 static DEFINE_RWLOCK(proto_list_lock);
 static LIST_HEAD(proto_list);
 
+#ifdef CONFIG_PROC_FS
+#define PROTO_INUSE_NR	64	/* should be enough for the first time */
+
+struct prot_inuse {
+	int val[PROTO_INUSE_NR];
+};
+
+static DEFINE_PER_CPU(struct prot_inuse, prot_inuse);
+
+void sock_prot_inuse_add(struct proto *prot, int val)
+{
+	__get_cpu_var(prot_inuse).val[prot->inuse_idx] += val;
+}
+EXPORT_SYMBOL_GPL(sock_prot_inuse_add);
+
+int sock_prot_inuse_get(struct proto *prot)
+{
+	int cpu, idx = prot->inuse_idx;
+	int res = 0;
+
+	for_each_possible_cpu(cpu)
+		res += per_cpu(prot_inuse, cpu).val[idx];
+
+	return res >= 0 ? res : 0;
+}
+EXPORT_SYMBOL_GPL(sock_prot_inuse_get);
+#endif
+
 static void assign_proto_idx(struct proto *prot)
 {
 #ifdef CONFIG_PROC_FS
 	static unsigned int idx = 0;
 
+	if (unlikely(idx == PROTO_INUSE_NR - 1)) {
+		printk(KERN_ERR "PROTO_INUSE_NR exhausted\n");
+		prot->inuse_idx = idx;
+		return;
+	}
+
 	prot->inuse_idx = idx++;
 #endif
 }
-- 
1.5.3.4

