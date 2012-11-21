From: George Zhang <georgezhang@vmware.com>
Subject: [PATCH 2/6] VSOCK: vsock address implementaion.
Date: Wed, 21 Nov 2012 12:39:52 -0800
Message-ID: <20121121203942.14395.43536.stgit@promb-2n-dhcp175.eng.vmware.com>
References: <20121121203715.14395.27632.stgit@promb-2n-dhcp175.eng.vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: pv-drivers@vmware.com, gregkh@linuxfoundation.org, davem@davemloft.net
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	georgezhang@vmware.com, virtualization@lists.linux-foundation.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20121121203715.14395.27632.stgit@promb-2n-dhcp175.eng.vmware.com>
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

VSOCK linux address code implementation.

Signed-off-by: George Zhang <georgezhang@vmware.com>
Signed-off-by: Dmitry Torokhov <dtor@vmware.com>
Signed-off-by: Andy King <acking@vmware.com>

---
 net/vmw_vsock/vsock_addr.c |  246 ++++++++++++++++++++++++++++++++++++++++++++
 net/vmw_vsock/vsock_addr.h |   40 +++++++
 2 files changed, 286 insertions(+), 0 deletions(-)
 create mode 100644 net/vmw_vsock/vsock_addr.c
 create mode 100644 net/vmw_vsock/vsock_addr.h

diff --git a/net/vmw_vsock/vsock_addr.c b/net/vmw_vsock/vsock_addr.c
new file mode 100644
index 0000000..35eeb14
--- /dev/null
+++ b/net/vmw_vsock/vsock_addr.c
@@ -0,0 +1,246 @@
+/*
+ * VMware vSockets Driver
+ *
+ * Copyright (C) 2007-2012 VMware, Inc. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License as published by the Free
+ * Software Foundation version 2 and no later version.
+ *
+ * This program is distributed in the hope that it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ */
+
+/*
+ * vsockAddr.c --
+ *
+ * VSockets address implementation.
+ */
+
+#include <linux/types.h>
+#include <linux/socket.h>
+#include <linux/stddef.h>	/* for NULL */
+#include <net/sock.h>
+
+#include "vsock_common.h"
+
+/*
+ *
+ * vsock_addr_init --
+ *
+ * Initialize the given address with the given context id and port. This will
+ * clear the address, set the correct family, and add the given values.
+ *
+ * Results: None.
+ *
+ * Side effects: None.
+ */
+
+void vsock_addr_init(struct sockaddr_vm *addr, u32 cid, u32 port)
+{
+	memset(addr, 0, sizeof *addr);
+
+	addr->svm_family = AF_VSOCK;
+	addr->svm_cid = cid;
+	addr->svm_port = port;
+}
+
+/*
+ *
+ * vsock_addr_validate --
+ *
+ * Try to validate the given address.  The address must not be null and must
+ * have the correct address family.  Any reserved fields must be zero.
+ *
+ * Results: 0 on success, EFAULT if the address is null, EAFNOSUPPORT if the
+ * address is of the wrong family, and EINVAL if the reserved fields are not
+ * zero.
+ *
+ * Side effects: None.
+ */
+
+int vsock_addr_validate(const struct sockaddr_vm *addr)
+{
+	if (!addr)
+		return -EFAULT;
+
+	if (addr->svm_family != AF_VSOCK)
+		return -EAFNOSUPPORT;
+
+	if (addr->svm_zero[0] != 0)
+		return -EINVAL;
+
+	return 0;
+}
+
+/*
+ *
+ * vsock_addr_bound --
+ *
+ * Determines whether the provided address is bound.
+ *
+ * Results: TRUE if the address structure is bound, FALSE otherwise.
+ *
+ * Side effects: None.
+ */
+
+bool vsock_addr_bound(const struct sockaddr_vm *addr)
+{
+	return addr->svm_port != VMADDR_PORT_ANY;
+}
+
+/*
+ *
+ * vsock_addr_unbind --
+ *
+ * Unbind the given addresss.
+ *
+ * Results: None.
+ *
+ * Side effects: None.
+ */
+
+void vsock_addr_unbind(struct sockaddr_vm *addr)
+{
+	vsock_addr_init(addr, VMADDR_CID_ANY, VMADDR_PORT_ANY);
+}
+
+/*
+ *
+ * vsock_addr_equals_addr --
+ *
+ * Determine if the given addresses are equal.
+ *
+ * Results: TRUE if the addresses are equal, FALSE otherwise.
+ *
+ * Side effects: None.
+ */
+
+bool vsock_addr_equals_addr(const struct sockaddr_vm *addr,
+			    const struct sockaddr_vm *other)
+{
+	return addr->svm_cid == other->svm_cid &&
+		addr->svm_port == other->svm_port;
+}
+
+/*
+ *
+ * vsock_addr_equals_addr_any --
+ *
+ * Determine if the given addresses are equal. Will accept either an exact
+ * match or one where the rids match and that either the cids match or are set
+ * to VMADDR_CID_ANY.
+ *
+ * Results: TRUE if the addresses are equal, FALSE otherwise.
+ *
+ * Side effects: None.
+ */
+
+bool vsock_addr_equals_addr_any(const struct sockaddr_vm *addr,
+				const struct sockaddr_vm *other)
+{
+	return (addr->svm_cid == VMADDR_CID_ANY ||
+		other->svm_cid == VMADDR_CID_ANY ||
+		addr->svm_cid == other->svm_cid) &&
+	       addr->svm_port == other->svm_port;
+}
+
+/*
+ *
+ * vsock_addr_equals_handle_port --
+ *
+ * Determines if the given address matches the given handle and port.
+ *
+ * Results: TRUE if the address matches the handle and port, FALSE otherwise.
+ *
+ * Side effects: None.
+ */
+
+bool vsock_addr_equals_handle_port(const struct sockaddr_vm *addr,
+				   struct vmci_handle handle, u32 port)
+{
+	return addr->svm_cid == VMCI_HANDLE_TO_CONTEXT_ID(handle) &&
+		addr->svm_port == port;
+}
+
+/*
+ *
+ * vsock_addr_cast --
+ *
+ * Try to cast the given generic address to a VM address.  The given length
+ * must match that of a VM address and the address must be valid. The
+ * "out_addr" parameter contains the address if successful.
+ *
+ * Results: 0 on success, EFAULT if the length is too small.  See
+ * vsock_addr_validate() for other possible return codes.
+ *
+ * Side effects: None.
+ */
+
+int vsock_addr_cast(const struct sockaddr *addr,
+		    size_t len, struct sockaddr_vm **out_addr)
+{
+	if (len < sizeof **out_addr)
+		return -EFAULT;
+
+	*out_addr = (struct sockaddr_vm *)addr;
+	return vsock_addr_validate(*out_addr);
+}
+
+/*
+ *
+ * vsock_addr_socket_context_stream --
+ *
+ * Determines whether the provided context id represents a context that
+ * contains a stream socket endpoints.
+ *
+ * Results: TRUE if the context does have socket endpoints, FALSE otherwise.
+ *
+ * Side effects: None.
+ */
+
+bool vsock_addr_socket_context_stream(u32 cid)
+{
+	static const vmci_id non_socket_contexts[] = {
+		VMCI_HYPERVISOR_CONTEXT_ID,
+		VMCI_WELL_KNOWN_CONTEXT_ID,
+	};
+	int i;
+
+	BUILD_BUG_ON(sizeof cid != sizeof *non_socket_contexts);
+
+	for (i = 0; i < ARRAY_SIZE(non_socket_contexts); i++) {
+		if (cid == non_socket_contexts[i])
+			return false;
+
+	}
+
+	return true;
+}
+
+/*
+ *
+ * vsock_addr_socket_context_dgram --
+ *
+ * Determines whether the provided <context id, resource id> represent a
+ * protected datagram endpoint.
+ *
+ * Results: TRUE if the context does have socket endpoints, FALSE otherwise.
+ *
+ * Side effects: None.
+ */
+
+bool vsock_addr_socket_context_dgram(u32 cid, u32 rid)
+{
+	if (cid == VMCI_HYPERVISOR_CONTEXT_ID) {
+		/*
+		 * Registrations of PBRPC Servers do not modify VMX/Hypervisor
+		 * state and are allowed.
+		 */
+		return rid == VMCI_UNITY_PBRPC_REGISTER;
+	}
+
+	return true;
+}
diff --git a/net/vmw_vsock/vsock_addr.h b/net/vmw_vsock/vsock_addr.h
new file mode 100644
index 0000000..18f023d
--- /dev/null
+++ b/net/vmw_vsock/vsock_addr.h
@@ -0,0 +1,40 @@
+/*
+ * VMware vSockets Driver
+ *
+ * Copyright (C) 2007-2012 VMware, Inc. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License as published by the Free
+ * Software Foundation version 2 and no later version.
+ *
+ * This program is distributed in the hope that it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ */
+
+/*
+ * vsockAddr.h --
+ *
+ * VSockets address constants, types and functions.
+ */
+
+#ifndef _VSOCK_ADDR_H_
+#define _VSOCK_ADDR_H_
+
+void vsock_addr_init(struct sockaddr_vm *addr, u32 cid, u32 port);
+int vsock_addr_validate(const struct sockaddr_vm *addr);
+bool vsock_addr_bound(const struct sockaddr_vm *addr);
+void vsock_addr_unbind(struct sockaddr_vm *addr);
+bool vsock_addr_equals_addr(const struct sockaddr_vm *addr,
+			    const struct sockaddr_vm *other);
+bool vsock_addr_equals_addr_any(const struct sockaddr_vm *addr,
+				const struct sockaddr_vm *other);
+bool vsock_addr_equals_handle_port(const struct sockaddr_vm *addr,
+				   struct vmci_handle handle, u32 port);
+int vsock_addr_cast(const struct sockaddr *addr, size_t len,
+		    struct sockaddr_vm **out_addr);
+bool vsock_addr_socket_context_stream(u32 cid);
+bool vsock_addr_socket_context_dgram(u32 cid, u32 rid);
+
+#endif
