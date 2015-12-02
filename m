From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: [PATCH v2 1/5] VSOCK: Introduce vsock_find_unbound_socket and
	vsock_bind_dgram_generic
Date: Wed,  2 Dec 2015 14:43:59 +0800
Message-ID: <1449038643-25971-2-git-send-email-stefanha@redhat.com>
References: <1449038643-25971-1-git-send-email-stefanha@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Stefan Hajnoczi <stefanha@redhat.com>,
	"Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	Matt Benjamin <mbenjamin@redhat.com>, Asias He <asias@redhat.com>,
	Christoffer Dall <christoffer.dall@linaro.org>, matt.ma@linaro.org
To: kvm@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1449038643-25971-1-git-send-email-stefanha@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

From: Asias He <asias@redhat.com>

Signed-off-by: Asias He <asias@redhat.com>
Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>
---
 include/net/af_vsock.h   |  2 ++
 net/vmw_vsock/af_vsock.c | 70 ++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 72 insertions(+)

diff --git a/include/net/af_vsock.h b/include/net/af_vsock.h
index e9eb2d6..a0c8fa2 100644
--- a/include/net/af_vsock.h
+++ b/include/net/af_vsock.h
@@ -175,8 +175,10 @@ void vsock_insert_connected(struct vsock_sock *vsk);
 void vsock_remove_bound(struct vsock_sock *vsk);
 void vsock_remove_connected(struct vsock_sock *vsk);
 struct sock *vsock_find_bound_socket(struct sockaddr_vm *addr);
+struct sock *vsock_find_unbound_socket(struct sockaddr_vm *addr);
 struct sock *vsock_find_connected_socket(struct sockaddr_vm *src,
 					 struct sockaddr_vm *dst);
 void vsock_for_each_connected_socket(void (*fn)(struct sock *sk));
+int vsock_bind_dgram_generic(struct vsock_sock *vsk, struct sockaddr_vm *addr);
 
 #endif /* __AF_VSOCK_H__ */
diff --git a/net/vmw_vsock/af_vsock.c b/net/vmw_vsock/af_vsock.c
index 7fd1220..77247a2 100644
--- a/net/vmw_vsock/af_vsock.c
+++ b/net/vmw_vsock/af_vsock.c
@@ -223,6 +223,17 @@ static struct sock *__vsock_find_bound_socket(struct sockaddr_vm *addr)
 	return NULL;
 }
 
+static struct sock *__vsock_find_unbound_socket(struct sockaddr_vm *addr)
+{
+	struct vsock_sock *vsk;
+
+	list_for_each_entry(vsk, vsock_unbound_sockets, bound_table)
+		if (addr->svm_port == vsk->local_addr.svm_port)
+			return sk_vsock(vsk);
+
+	return NULL;
+}
+
 static struct sock *__vsock_find_connected_socket(struct sockaddr_vm *src,
 						  struct sockaddr_vm *dst)
 {
@@ -298,6 +309,21 @@ struct sock *vsock_find_bound_socket(struct sockaddr_vm *addr)
 }
 EXPORT_SYMBOL_GPL(vsock_find_bound_socket);
 
+struct sock *vsock_find_unbound_socket(struct sockaddr_vm *addr)
+{
+	struct sock *sk;
+
+	spin_lock_bh(&vsock_table_lock);
+	sk = __vsock_find_unbound_socket(addr);
+	if (sk)
+		sock_hold(sk);
+
+	spin_unlock_bh(&vsock_table_lock);
+
+	return sk;
+}
+EXPORT_SYMBOL_GPL(vsock_find_unbound_socket);
+
 struct sock *vsock_find_connected_socket(struct sockaddr_vm *src,
 					 struct sockaddr_vm *dst)
 {
@@ -532,6 +558,50 @@ static int __vsock_bind_stream(struct vsock_sock *vsk,
 	return 0;
 }
 
+int vsock_bind_dgram_generic(struct vsock_sock *vsk, struct sockaddr_vm *addr)
+{
+	static u32 port = LAST_RESERVED_PORT + 1;
+	struct sockaddr_vm new_addr;
+
+	vsock_addr_init(&new_addr, addr->svm_cid, addr->svm_port);
+
+	if (addr->svm_port == VMADDR_PORT_ANY) {
+		bool found = false;
+		unsigned int i;
+
+		for (i = 0; i < MAX_PORT_RETRIES; i++) {
+			if (port <= LAST_RESERVED_PORT)
+				port = LAST_RESERVED_PORT + 1;
+
+			new_addr.svm_port = port++;
+
+			if (!__vsock_find_unbound_socket(&new_addr)) {
+				found = true;
+				break;
+			}
+		}
+
+		if (!found)
+			return -EADDRNOTAVAIL;
+	} else {
+		/* If port is in reserved range, ensure caller
+		 * has necessary privileges.
+		 */
+		if (addr->svm_port <= LAST_RESERVED_PORT &&
+		    !capable(CAP_NET_BIND_SERVICE)) {
+			return -EACCES;
+		}
+
+		if (__vsock_find_unbound_socket(&new_addr))
+			return -EADDRINUSE;
+	}
+
+	vsock_addr_init(&vsk->local_addr, new_addr.svm_cid, new_addr.svm_port);
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(vsock_bind_dgram_generic);
+
 static int __vsock_bind_dgram(struct vsock_sock *vsk,
 			      struct sockaddr_vm *addr)
 {
-- 
2.5.0
