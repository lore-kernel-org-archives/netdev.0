From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: [PATCH 6/6] Revert "VSOCK: Introduce vsock_find_unbound_socket and vsock_bind_dgram_generic"
Date: Tue,  8 Dec 2015 19:57:36 +0800
Message-ID: <1449575856-28507-7-git-send-email-stefanha@redhat.com>
References: <1449575856-28507-1-git-send-email-stefanha@redhat.com>
Cc: Matt Benjamin <mbenjamin@redhat.com>,
	"David S. Miller" <davem@davemloft.net>, kvm@vger.kernel.org,
	Christoffer Dall <christoffer.dall@linaro.org>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	virtualization@lists.linux-foundation.org, matt.ma@linaro.org,
	Stefan Hajnoczi <stefanha@redhat.com>
To: netdev@vger.kernel.org
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <1449575856-28507-1-git-send-email-stefanha@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This reverts commit 357ab2234d57f6c74386f64ded42dff8e3c0500b.

Keep virtio-vsock out-of-tree until the device specification is
finalized.

Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>
---
 include/net/af_vsock.h   |  2 --
 net/vmw_vsock/af_vsock.c | 70 ------------------------------------------------
 2 files changed, 72 deletions(-)

diff --git a/include/net/af_vsock.h b/include/net/af_vsock.h
index a0c8fa2..e9eb2d6 100644
--- a/include/net/af_vsock.h
+++ b/include/net/af_vsock.h
@@ -175,10 +175,8 @@ void vsock_insert_connected(struct vsock_sock *vsk);
 void vsock_remove_bound(struct vsock_sock *vsk);
 void vsock_remove_connected(struct vsock_sock *vsk);
 struct sock *vsock_find_bound_socket(struct sockaddr_vm *addr);
-struct sock *vsock_find_unbound_socket(struct sockaddr_vm *addr);
 struct sock *vsock_find_connected_socket(struct sockaddr_vm *src,
 					 struct sockaddr_vm *dst);
 void vsock_for_each_connected_socket(void (*fn)(struct sock *sk));
-int vsock_bind_dgram_generic(struct vsock_sock *vsk, struct sockaddr_vm *addr);
 
 #endif /* __AF_VSOCK_H__ */
diff --git a/net/vmw_vsock/af_vsock.c b/net/vmw_vsock/af_vsock.c
index 77247a2..7fd1220 100644
--- a/net/vmw_vsock/af_vsock.c
+++ b/net/vmw_vsock/af_vsock.c
@@ -223,17 +223,6 @@ static struct sock *__vsock_find_bound_socket(struct sockaddr_vm *addr)
 	return NULL;
 }
 
-static struct sock *__vsock_find_unbound_socket(struct sockaddr_vm *addr)
-{
-	struct vsock_sock *vsk;
-
-	list_for_each_entry(vsk, vsock_unbound_sockets, bound_table)
-		if (addr->svm_port == vsk->local_addr.svm_port)
-			return sk_vsock(vsk);
-
-	return NULL;
-}
-
 static struct sock *__vsock_find_connected_socket(struct sockaddr_vm *src,
 						  struct sockaddr_vm *dst)
 {
@@ -309,21 +298,6 @@ struct sock *vsock_find_bound_socket(struct sockaddr_vm *addr)
 }
 EXPORT_SYMBOL_GPL(vsock_find_bound_socket);
 
-struct sock *vsock_find_unbound_socket(struct sockaddr_vm *addr)
-{
-	struct sock *sk;
-
-	spin_lock_bh(&vsock_table_lock);
-	sk = __vsock_find_unbound_socket(addr);
-	if (sk)
-		sock_hold(sk);
-
-	spin_unlock_bh(&vsock_table_lock);
-
-	return sk;
-}
-EXPORT_SYMBOL_GPL(vsock_find_unbound_socket);
-
 struct sock *vsock_find_connected_socket(struct sockaddr_vm *src,
 					 struct sockaddr_vm *dst)
 {
@@ -558,50 +532,6 @@ static int __vsock_bind_stream(struct vsock_sock *vsk,
 	return 0;
 }
 
-int vsock_bind_dgram_generic(struct vsock_sock *vsk, struct sockaddr_vm *addr)
-{
-	static u32 port = LAST_RESERVED_PORT + 1;
-	struct sockaddr_vm new_addr;
-
-	vsock_addr_init(&new_addr, addr->svm_cid, addr->svm_port);
-
-	if (addr->svm_port == VMADDR_PORT_ANY) {
-		bool found = false;
-		unsigned int i;
-
-		for (i = 0; i < MAX_PORT_RETRIES; i++) {
-			if (port <= LAST_RESERVED_PORT)
-				port = LAST_RESERVED_PORT + 1;
-
-			new_addr.svm_port = port++;
-
-			if (!__vsock_find_unbound_socket(&new_addr)) {
-				found = true;
-				break;
-			}
-		}
-
-		if (!found)
-			return -EADDRNOTAVAIL;
-	} else {
-		/* If port is in reserved range, ensure caller
-		 * has necessary privileges.
-		 */
-		if (addr->svm_port <= LAST_RESERVED_PORT &&
-		    !capable(CAP_NET_BIND_SERVICE)) {
-			return -EACCES;
-		}
-
-		if (__vsock_find_unbound_socket(&new_addr))
-			return -EADDRINUSE;
-	}
-
-	vsock_addr_init(&vsk->local_addr, new_addr.svm_cid, new_addr.svm_port);
-
-	return 0;
-}
-EXPORT_SYMBOL_GPL(vsock_bind_dgram_generic);
-
 static int __vsock_bind_dgram(struct vsock_sock *vsk,
 			      struct sockaddr_vm *addr)
 {
-- 
2.5.0

