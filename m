From: George Zhang <georgezhang@vmware.com>
Subject: [PATCH 2/6] VSOCK: vsock address implementaion.
Date: Tue, 08 Jan 2013 15:59:43 -0800
Message-ID: <20130108235931.3719.14605.stgit@promb-2n-dhcp175.eng.vmware.com>
References: <20130108235633.3719.6085.stgit@promb-2n-dhcp175.eng.vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: pv-drivers@vmware.com, gregkh@linuxfoundation.org, davem@davemloft.net
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	georgezhang@vmware.com, virtualization@lists.linux-foundation.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20130108235633.3719.6085.stgit@promb-2n-dhcp175.eng.vmware.com>
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
Acked-by: Andy king <acking@vmware.com>
Acked-by: Dmitry Torokhov <dtor@vmware.com>
---
 net/vmw_vsock/vsock_addr.c |  116 ++++++++++++++++++++++++++++++++++++++++++++
 net/vmw_vsock/vsock_addr.h |   34 +++++++++++++
 2 files changed, 150 insertions(+), 0 deletions(-)
 create mode 100644 net/vmw_vsock/vsock_addr.c
 create mode 100644 net/vmw_vsock/vsock_addr.h

diff --git a/net/vmw_vsock/vsock_addr.c b/net/vmw_vsock/vsock_addr.c
new file mode 100644
index 0000000..9564576
--- /dev/null
+++ b/net/vmw_vsock/vsock_addr.c
@@ -0,0 +1,116 @@
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
+#include <linux/types.h>
+#include <linux/socket.h>
+#include <linux/stddef.h>
+#include <net/sock.h>
+
+#include "vsock_common.h"
+
+void vsock_addr_init(struct sockaddr_vm *addr, u32 cid, u32 port)
+{
+	memset(addr, 0, sizeof(*addr));
+	addr->svm_family = AF_VSOCK;
+	addr->svm_cid = cid;
+	addr->svm_port = port;
+}
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
+bool vsock_addr_bound(const struct sockaddr_vm *addr)
+{
+	return addr->svm_port != VMADDR_PORT_ANY;
+}
+
+void vsock_addr_unbind(struct sockaddr_vm *addr)
+{
+	vsock_addr_init(addr, VMADDR_CID_ANY, VMADDR_PORT_ANY);
+}
+
+bool vsock_addr_equals_addr(const struct sockaddr_vm *addr,
+			    const struct sockaddr_vm *other)
+{
+	return addr->svm_cid == other->svm_cid &&
+		addr->svm_port == other->svm_port;
+}
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
+bool vsock_addr_equals_handle_port(const struct sockaddr_vm *addr,
+				   struct vmci_handle handle, u32 port)
+{
+	return addr->svm_cid == handle.context && addr->svm_port == port;
+}
+
+int vsock_addr_cast(const struct sockaddr *addr,
+		    size_t len, struct sockaddr_vm **out_addr)
+{
+	if (len < sizeof(**out_addr))
+		return -EFAULT;
+
+	*out_addr = (struct sockaddr_vm *)addr;
+	return vsock_addr_validate(*out_addr);
+}
+
+bool vsock_addr_socket_context_stream(u32 cid)
+{
+	static const u32 non_socket_contexts[] = {
+		VMCI_HYPERVISOR_CONTEXT_ID,
+		VMCI_WELL_KNOWN_CONTEXT_ID,
+	};
+	int i;
+
+	BUILD_BUG_ON(sizeof(cid) != sizeof(*non_socket_contexts));
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
+bool vsock_addr_socket_context_dgram(u32 cid, u32 rid)
+{
+	if (cid == VMCI_HYPERVISOR_CONTEXT_ID) {
+		/* Registrations of PBRPC Servers do not modify VMX/Hypervisor
+		 * state and are allowed.
+		 */
+		return rid == VMCI_UNITY_PBRPC_REGISTER;
+	}
+
+	return true;
+}
diff --git a/net/vmw_vsock/vsock_addr.h b/net/vmw_vsock/vsock_addr.h
new file mode 100644
index 0000000..65c4bcf
--- /dev/null
+++ b/net/vmw_vsock/vsock_addr.h
@@ -0,0 +1,34 @@
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
