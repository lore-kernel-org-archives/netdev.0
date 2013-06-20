From: Asias He <asias@redhat.com>
Subject: [PATCH 4/4] VSOCK: Fix VSOCK_HASH and VSOCK_CONN_HASH
Date: Thu, 20 Jun 2013 17:20:33 +0800
Message-ID: <1371720033-19714-5-git-send-email-asias@redhat.com>
References: <1371720033-19714-1-git-send-email-asias@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Andy King <acking@vmware.com>,
	Dmitry Torokhov <dtor@vmware.com>,
	Reilly Grant <grantr@vmware.com>, Asias He <asias@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:2523 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756245Ab3FTJVD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Jun 2013 05:21:03 -0400
In-Reply-To: <1371720033-19714-1-git-send-email-asias@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If we mod with VSOCK_HASH_SIZE -1, we get 0, 1, .... 249.  Actually, we
have vsock_bind_table[0 ... 250] and vsock_connected_table[0 .. 250].
In this case the last entry will never be used.

We should mod with VSOCK_HASH_SIZE instead.

Signed-off-by: Asias He <asias@redhat.com>
---
 net/vmw_vsock/af_vsock.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/vmw_vsock/af_vsock.c b/net/vmw_vsock/af_vsock.c
index b0b362a..593071d 100644
--- a/net/vmw_vsock/af_vsock.c
+++ b/net/vmw_vsock/af_vsock.c
@@ -144,18 +144,18 @@ EXPORT_SYMBOL_GPL(vm_sockets_get_local_cid);
  * VSOCK_HASH_SIZE + 1 so that vsock_bind_table[0] through
  * vsock_bind_table[VSOCK_HASH_SIZE - 1] are for bound sockets and
  * vsock_bind_table[VSOCK_HASH_SIZE] is for unbound sockets.  The hash function
- * mods with VSOCK_HASH_SIZE - 1 to ensure this.
+ * mods with VSOCK_HASH_SIZE to ensure this.
  */
 #define VSOCK_HASH_SIZE         251
 #define MAX_PORT_RETRIES        24
 
-#define VSOCK_HASH(addr)        ((addr)->svm_port % (VSOCK_HASH_SIZE - 1))
+#define VSOCK_HASH(addr)        ((addr)->svm_port % VSOCK_HASH_SIZE)
 #define vsock_bound_sockets(addr) (&vsock_bind_table[VSOCK_HASH(addr)])
 #define vsock_unbound_sockets     (&vsock_bind_table[VSOCK_HASH_SIZE])
 
 /* XXX This can probably be implemented in a better way. */
 #define VSOCK_CONN_HASH(src, dst)				\
-	(((src)->svm_cid ^ (dst)->svm_port) % (VSOCK_HASH_SIZE - 1))
+	(((src)->svm_cid ^ (dst)->svm_port) % VSOCK_HASH_SIZE)
 #define vsock_connected_sockets(src, dst)		\
 	(&vsock_connected_table[VSOCK_CONN_HASH(src, dst)])
 #define vsock_connected_sockets_vsk(vsk)				\
-- 
1.8.1.4
