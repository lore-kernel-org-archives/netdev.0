From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: [PATCH v3 1/5] VSOCK: export socket tables for sock_diag interface
Date: Thu,  5 Oct 2017 16:46:50 -0400
Message-ID: <20171005204654.2737-2-stefanha@redhat.com>
References: <20171005204654.2737-1-stefanha@redhat.com>
Cc: "David S . Miller" <davem@davemloft.net>,
        Jorgen Hansen <jhansen@vmware.com>,
        Dexuan Cui <decui@microsoft.com>,
        Stefan Hajnoczi <stefanha@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57254 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751381AbdJEUrM (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 5 Oct 2017 16:47:12 -0400
In-Reply-To: <20171005204654.2737-1-stefanha@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The socket table symbols need to be exported from vsock.ko so that the
vsock_diag.ko module will be able to traverse sockets.

Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>
---
 include/net/af_vsock.h   |  5 +++++
 net/vmw_vsock/af_vsock.c | 10 ++++++----
 2 files changed, 11 insertions(+), 4 deletions(-)

diff --git a/include/net/af_vsock.h b/include/net/af_vsock.h
index f9fb566e75cf..30cba806e344 100644
--- a/include/net/af_vsock.h
+++ b/include/net/af_vsock.h
@@ -27,6 +27,11 @@
 
 #define LAST_RESERVED_PORT 1023
 
+#define VSOCK_HASH_SIZE         251
+extern struct list_head vsock_bind_table[VSOCK_HASH_SIZE + 1];
+extern struct list_head vsock_connected_table[VSOCK_HASH_SIZE];
+extern spinlock_t vsock_table_lock;
+
 #define vsock_sk(__sk)    ((struct vsock_sock *)__sk)
 #define sk_vsock(__vsk)   (&(__vsk)->sk)
 
diff --git a/net/vmw_vsock/af_vsock.c b/net/vmw_vsock/af_vsock.c
index dfc8c51e4d74..9afe4da8c67d 100644
--- a/net/vmw_vsock/af_vsock.c
+++ b/net/vmw_vsock/af_vsock.c
@@ -153,7 +153,6 @@ EXPORT_SYMBOL_GPL(vm_sockets_get_local_cid);
  * vsock_bind_table[VSOCK_HASH_SIZE] is for unbound sockets.  The hash function
  * mods with VSOCK_HASH_SIZE to ensure this.
  */
-#define VSOCK_HASH_SIZE         251
 #define MAX_PORT_RETRIES        24
 
 #define VSOCK_HASH(addr)        ((addr)->svm_port % VSOCK_HASH_SIZE)
@@ -168,9 +167,12 @@ EXPORT_SYMBOL_GPL(vm_sockets_get_local_cid);
 #define vsock_connected_sockets_vsk(vsk)				\
 	vsock_connected_sockets(&(vsk)->remote_addr, &(vsk)->local_addr)
 
-static struct list_head vsock_bind_table[VSOCK_HASH_SIZE + 1];
-static struct list_head vsock_connected_table[VSOCK_HASH_SIZE];
-static DEFINE_SPINLOCK(vsock_table_lock);
+struct list_head vsock_bind_table[VSOCK_HASH_SIZE + 1];
+EXPORT_SYMBOL_GPL(vsock_bind_table);
+struct list_head vsock_connected_table[VSOCK_HASH_SIZE];
+EXPORT_SYMBOL_GPL(vsock_connected_table);
+DEFINE_SPINLOCK(vsock_table_lock);
+EXPORT_SYMBOL_GPL(vsock_table_lock);
 
 /* Autobind this socket to the local address if necessary. */
 static int vsock_auto_bind(struct vsock_sock *vsk)
-- 
2.13.6
