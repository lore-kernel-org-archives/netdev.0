From: Asias He <asias@redhat.com>
Subject: [RFC 1/5] VSOCK: Introduce vsock_find_unbound_socket and
	vsock_bind_dgram_generic
Date: Thu, 27 Jun 2013 16:00:00 +0800
Message-ID: <1372320004-20502-2-git-send-email-asias@redhat.com>
References: <1372320004-20502-1-git-send-email-asias@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Andy King <acking@vmware.com>, "Michael S. Tsirkin" <mst@redhat.com>,
	Reilly Grant <grantr@vmware.com>, Pekka Enberg <penberg@kernel.org>,
	Sasha Levin <sasha.levin@oracle.com>,
	"David S. Miller" <davem@davemloft.net>, Dmitry Torokhov <dtor@vmware.com>
To: netdev@vger.kernel.org, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1372320004-20502-1-git-send-email-asias@redhat.com>
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

Signed-off-by: Asias He <asias@redhat.com>
---
 net/vmw_vsock/af_vsock.c | 70 ++++++++++++++++++++++++++++++++++++++++++++++++
 net/vmw_vsock/af_vsock.h |  2 ++
 2 files changed, 72 insertions(+)

diff --git a/net/vmw_vsock/af_vsock.c b/net/vmw_vsock/af_vsock.c
index 593071d..bc76ddb 100644
--- a/net/vmw_vsock/af_vsock.c
+++ b/net/vmw_vsock/af_vsock.c
@@ -225,6 +225,17 @@ static struct sock *__vsock_find_bound_socket(struct sockaddr_vm *addr)
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
@@ -300,6 +311,21 @@ struct sock *vsock_find_bound_socket(struct sockaddr_vm *addr)
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
@@ -534,6 +560,50 @@ static int __vsock_bind_stream(struct vsock_sock *vsk,
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
diff --git a/net/vmw_vsock/af_vsock.h b/net/vmw_vsock/af_vsock.h
index 7d64d36..88f559a 100644
--- a/net/vmw_vsock/af_vsock.h
+++ b/net/vmw_vsock/af_vsock.h
@@ -168,8 +168,10 @@ void vsock_insert_connected(struct vsock_sock *vsk);
 void vsock_remove_bound(struct vsock_sock *vsk);
 void vsock_remove_connected(struct vsock_sock *vsk);
 struct sock *vsock_find_bound_socket(struct sockaddr_vm *addr);
+struct sock *vsock_find_unbound_socket(struct sockaddr_vm *addr);
 struct sock *vsock_find_connected_socket(struct sockaddr_vm *src,
 					 struct sockaddr_vm *dst);
 void vsock_for_each_connected_socket(void (*fn)(struct sock *sk));
+int vsock_bind_dgram_generic(struct vsock_sock *vsk, struct sockaddr_vm *addr);
 
 #endif /* __AF_VSOCK_H__ */
-- 
1.8.1.4
