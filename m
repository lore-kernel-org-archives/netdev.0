From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-2.6.26 1/5][SOCK]: Enumerate struct proto-s to facilitate
 percpu inuse accounting.
Date: Fri, 28 Mar 2008 11:59:14 +0300
Message-ID: <47ECB362.5050104@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:36920 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752447AbYC1I7S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Mar 2008 04:59:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This add the inuse_idx to struct proto and generates one in proto_register.
The ++ in generator is protected with write-locked proto_list_lock.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 include/net/sock.h |    1 +
 net/core/sock.c    |   10 ++++++++++
 2 files changed, 11 insertions(+), 0 deletions(-)

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
index 3ee9506..a7faf30 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1940,6 +1940,15 @@ EXPORT_SYMBOL(sk_common_release);
 static DEFINE_RWLOCK(proto_list_lock);
 static LIST_HEAD(proto_list);
 
+static void assign_proto_idx(struct proto *prot)
+{
+#ifdef CONFIG_PROC_FS
+	static unsigned int idx = 0;
+
+	prot->inuse_idx = idx++;
+#endif
+}
+
 int proto_register(struct proto *prot, int alloc_slab)
 {
 	char *request_sock_slab_name = NULL;
@@ -2000,6 +2009,7 @@ int proto_register(struct proto *prot, int alloc_slab)
 
 	write_lock(&proto_list_lock);
 	list_add(&prot->node, &proto_list);
+	assign_proto_idx(prot);
 	write_unlock(&proto_list_lock);
 	return 0;
 
-- 
1.5.3.4

