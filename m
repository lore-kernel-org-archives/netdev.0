From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-2.6.26 1/5][SOCK]: Enumerate struct proto-s to facilitate
 percpu inuse accounting (v2).
Date: Fri, 28 Mar 2008 15:29:43 +0300
Message-ID: <47ECE4B7.40806@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:56345 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752122AbYC1M37 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Mar 2008 08:29:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The inuse counters are going to become a per-cpu array.
Introduce an index for this array on the struct proto.

To handle the case of proto register-unregister-register
loop the bitmap is used. All its bits manipulations are
protected with proto_list_lock and a sanity check for the
bitmap being exhausted is also added.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 include/net/sock.h |    1 +
 net/core/sock.c    |   34 ++++++++++++++++++++++++++++++++++
 2 files changed, 35 insertions(+), 0 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 1c9d059..abc6341 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -562,6 +562,7 @@ struct proto {
 
 	/* Keeping track of sockets in use */
 #ifdef CONFIG_PROC_FS
+	unsigned int		inuse_idx;
 	struct pcounter		inuse;
 #endif
 
diff --git a/net/core/sock.c b/net/core/sock.c
index 3ee9506..7d2c8ad 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1940,6 +1940,38 @@ EXPORT_SYMBOL(sk_common_release);
 static DEFINE_RWLOCK(proto_list_lock);
 static LIST_HEAD(proto_list);
 
+#ifdef CONFIG_PROC_FS
+#define PROTO_INUSE_NR	64	/* should be enough for the first time */
+
+static DECLARE_BITMAP(proto_inuse_idx, PROTO_INUSE_NR);
+
+static void assign_proto_idx(struct proto *prot)
+{
+	prot->inuse_idx = find_first_zero_bit(proto_inuse_idx, PROTO_INUSE_NR);
+
+	if (unlikely(prot->inuse_idx == PROTO_INUSE_NR - 1)) {
+		printk(KERN_ERR "PROTO_INUSE_NR exhausted\n");
+		return;
+	}
+
+	set_bit(prot->inuse_idx, proto_inuse_idx);
+}
+
+static void release_proto_idx(struct proto *prot)
+{
+	if (prot->inuse_idx != PROTO_INUSE_NR - 1)
+		clear_bit(prot->inuse_idx, proto_inuse_idx);
+}
+#else
+static inline void assign_proto_idx(struct proto *prot)
+{
+}
+
+static inline void release_proto_idx(struct proto *prot)
+{
+}
+#endif
+
 int proto_register(struct proto *prot, int alloc_slab)
 {
 	char *request_sock_slab_name = NULL;
@@ -2000,6 +2032,7 @@ int proto_register(struct proto *prot, int alloc_slab)
 
 	write_lock(&proto_list_lock);
 	list_add(&prot->node, &proto_list);
+	assign_proto_idx(prot);
 	write_unlock(&proto_list_lock);
 	return 0;
 
@@ -2026,6 +2059,7 @@ EXPORT_SYMBOL(proto_register);
 void proto_unregister(struct proto *prot)
 {
 	write_lock(&proto_list_lock);
+	release_proto_idx(prot);
 	list_del(&prot->node);
 	write_unlock(&proto_list_lock);
 
