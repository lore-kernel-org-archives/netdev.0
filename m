From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-2.6.26 2/5][SOCK]: Introduce a percpu inuse counters array
 (v2).
Date: Fri, 28 Mar 2008 15:33:18 +0300
Message-ID: <47ECE58E.5030407@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:56999 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753476AbYC1Md2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Mar 2008 08:33:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

And redirect sock_prot_inuse_add and _get to use one.

As far as the dereferences are concerned. Before the patch we made
1 dereference to proto->inuse.add call, the call itself and then
called the __get_cpu_var() on a static variable. After the patch we 
make a direct call, then one dereference to proto->inuse_idx and 
then the same __get_cpu_var() on a still static variable. So this 
patch doesn't seem to produce performance penalty on SMP.

This is not per-net yet, but I will deliberately make NET_NS=y case
separated from NET_NS=n one, since it'll cost us one-or-two more 
dereferences to get the struct net and the inuse counter.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 include/net/sock.h |   13 +++++--------
 net/core/sock.c    |   22 ++++++++++++++++++++++
 2 files changed, 27 insertions(+), 8 deletions(-)

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
index 7d2c8ad..174c64b 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1942,8 +1942,30 @@ static LIST_HEAD(proto_list);
 
 #ifdef CONFIG_PROC_FS
 #define PROTO_INUSE_NR	64	/* should be enough for the first time */
+struct prot_inuse {
+	int val[PROTO_INUSE_NR];
+};
 
 static DECLARE_BITMAP(proto_inuse_idx, PROTO_INUSE_NR);
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
 
 static void assign_proto_idx(struct proto *prot)
 {
-- 
1.5.3.4


