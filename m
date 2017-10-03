From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: [PATCH 4/5] VSOCK: add sock_diag interface
Date: Tue,  3 Oct 2017 11:39:42 -0400
Message-ID: <20171003153943.23159-5-stefanha@redhat.com>
References: <20171003153943.23159-1-stefanha@redhat.com>
Cc: Jorgen Hansen <jhansen@vmware.com>,
        Dexuan Cui <decui@microsoft.com>,
        Stefan Hajnoczi <stefanha@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40176 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752583AbdJCPkQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 3 Oct 2017 11:40:16 -0400
In-Reply-To: <20171003153943.23159-1-stefanha@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the sock_diag interface for querying sockets from
userspace.  Tools like ss(8) and netstat(8) can use this interface to
list open sockets.

The userspace ABI is defined in <linux/vm_sockets_diag.h> and includes
netlink request and response structs.  The request can query sockets
based on their sk_state (e.g. listening sockets only) and the response
contains socket information fields including the local/remote addresses,
inode number, etc.

This patch does not dump VMCI pending sockets because I have only tested
the virtio transport, which does not use pending sockets.  Support can
be added later by extending vsock_diag_dump() if needed by VMCI users.

Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>
---
 MAINTAINERS                          |   2 +
 net/vmw_vsock/Makefile               |   3 +
 include/uapi/linux/vm_sockets_diag.h |  33 +++++++
 net/vmw_vsock/diag.c                 | 186 +++++++++++++++++++++++++++++++++++
 net/vmw_vsock/Kconfig                |  10 ++
 5 files changed, 234 insertions(+)
 create mode 100644 include/uapi/linux/vm_sockets_diag.h
 create mode 100644 net/vmw_vsock/diag.c

diff --git a/MAINTAINERS b/MAINTAINERS
index 1c3feffb1c1c..200dac93f34b 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -13975,6 +13975,8 @@ S:	Maintained
 F:	include/linux/virtio_vsock.h
 F:	include/uapi/linux/virtio_vsock.h
 F:	include/uapi/linux/vsockmon.h
+F:	include/uapi/linux/vm_sockets_diag.h
+F:	net/vmw_vsock/diag.c
 F:	net/vmw_vsock/af_vsock_tap.c
 F:	net/vmw_vsock/virtio_transport_common.c
 F:	net/vmw_vsock/virtio_transport.c
diff --git a/net/vmw_vsock/Makefile b/net/vmw_vsock/Makefile
index 09fc2eb29dc8..e5dbf153aff0 100644
--- a/net/vmw_vsock/Makefile
+++ b/net/vmw_vsock/Makefile
@@ -1,10 +1,13 @@
 obj-$(CONFIG_VSOCKETS) += vsock.o
+obj-$(CONFIG_VSOCKETS_DIAG) += vsock_diag.o
 obj-$(CONFIG_VMWARE_VMCI_VSOCKETS) += vmw_vsock_vmci_transport.o
 obj-$(CONFIG_VIRTIO_VSOCKETS) += vmw_vsock_virtio_transport.o
 obj-$(CONFIG_VIRTIO_VSOCKETS_COMMON) += vmw_vsock_virtio_transport_common.o
 
 vsock-y += af_vsock.o af_vsock_tap.o vsock_addr.o
 
+vsock_diag-y += diag.o
+
 vmw_vsock_vmci_transport-y += vmci_transport.o vmci_transport_notify.o \
 	vmci_transport_notify_qstate.o
 
diff --git a/include/uapi/linux/vm_sockets_diag.h b/include/uapi/linux/vm_sockets_diag.h
new file mode 100644
index 000000000000..14cd7dc5a187
--- /dev/null
+++ b/include/uapi/linux/vm_sockets_diag.h
@@ -0,0 +1,33 @@
+/* AF_VSOCK sock_diag(7) interface for querying open sockets */
+
+#ifndef _UAPI__VM_SOCKETS_DIAG_H__
+#define _UAPI__VM_SOCKETS_DIAG_H__
+
+#include <linux/types.h>
+
+/* Request */
+struct vsock_diag_req {
+	__u8	sdiag_family;	/* must be AF_VSOCK */
+	__u8	sdiag_protocol;	/* must be 0 */
+	__u16	pad;		/* must be 0 */
+	__u32	vdiag_states;	/* query bitmap (e.g. 1 << TCP_LISTEN) */
+	__u32	vdiag_ino;	/* must be 0 (reserved) */
+	__u32	vdiag_show;	/* must be 0 (reserved) */
+	__u32	vdiag_cookie[2];
+};
+
+/* Response */
+struct vsock_diag_msg {
+	__u8	vdiag_family;	/* AF_VSOCK */
+	__u8	vdiag_type;	/* SOCK_STREAM or SOCK_DGRAM */
+	__u8	vdiag_state;	/* sk_state (e.g. TCP_LISTEN) */
+	__u8	vdiag_shutdown; /* local RCV_SHUTDOWN | SEND_SHUTDOWN */
+	__u32   vdiag_src_cid;
+	__u32   vdiag_src_port;
+	__u32   vdiag_dst_cid;
+	__u32   vdiag_dst_port;
+	__u32	vdiag_ino;
+	__u32	vdiag_cookie[2];
+};
+
+#endif /* _UAPI__VM_SOCKETS_DIAG_H__ */
diff --git a/net/vmw_vsock/diag.c b/net/vmw_vsock/diag.c
new file mode 100644
index 000000000000..13266329b56a
--- /dev/null
+++ b/net/vmw_vsock/diag.c
@@ -0,0 +1,186 @@
+/*
+ * vsock sock_diag(7) module
+ *
+ * Copyright (C) 2017 Red Hat, Inc.
+ * Author: Stefan Hajnoczi <stefanha@redhat.com>
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
+#include <linux/module.h>
+#include <linux/sock_diag.h>
+#include <linux/vm_sockets_diag.h>
+#include <net/af_vsock.h>
+
+static int sk_diag_fill(struct sock *sk, struct sk_buff *skb,
+			u32 portid, u32 seq, u32 flags)
+{
+	struct nlmsghdr *nlh;
+	struct vsock_diag_msg *rep;
+	struct vsock_sock *vsk = vsock_sk(sk);
+
+	nlh = nlmsg_put(skb, portid, seq, SOCK_DIAG_BY_FAMILY, sizeof(*rep),
+			flags);
+	if (!nlh)
+		return -EMSGSIZE;
+
+	rep = nlmsg_data(nlh);
+	rep->vdiag_family = AF_VSOCK;
+
+	/* Lock order dictates that sk_lock is acquired before
+	 * vsock_table_lock, so we cannot lock here.  Simply don't take
+	 * sk_lock; sk is guaranteed to stay alive since vsock_table_lock is
+	 * held.
+	 */
+	rep->vdiag_type = sk->sk_type;
+	rep->vdiag_state = sk->sk_state;
+	rep->vdiag_shutdown = sk->sk_shutdown;
+	rep->vdiag_src_cid = vsk->local_addr.svm_cid;
+	rep->vdiag_src_port = vsk->local_addr.svm_port;
+	rep->vdiag_dst_cid = vsk->remote_addr.svm_cid;
+	rep->vdiag_dst_port = vsk->remote_addr.svm_port;
+	rep->vdiag_ino = sock_i_ino(sk);
+
+	sock_diag_save_cookie(sk, rep->vdiag_cookie);
+
+	return 0;
+}
+
+static int vsock_diag_dump(struct sk_buff *skb, struct netlink_callback *cb)
+{
+	struct vsock_diag_req *req;
+	unsigned int table;
+	unsigned int bucket;
+	unsigned int last_i;
+	unsigned int i;
+	struct vsock_sock *vsk;
+	struct net *net;
+
+	req = nlmsg_data(cb->nlh);
+	net = sock_net(skb->sk);
+
+	/* State saved between calls: */
+	table = cb->args[0];
+	bucket = cb->args[1];
+	i = last_i = cb->args[2];
+
+	/* TODO VMCI pending sockets? */
+
+	spin_lock_bh(&vsock_table_lock);
+
+	/* Bind table (locally created sockets) */
+	if (table == 0) {
+		while (bucket < ARRAY_SIZE(vsock_bind_table)) {
+			struct list_head *head = &vsock_bind_table[bucket];
+
+			i = 0;
+			list_for_each_entry(vsk, head, bound_table) {
+				struct sock *sk = sk_vsock(vsk);
+
+				if (!net_eq(sock_net(sk), net))
+					continue;
+				if (i < last_i)
+					goto next_bind;
+				if (!(req->vdiag_states & (1 << sk->sk_state)))
+					goto next_bind;
+				if (sk_diag_fill(sk, skb,
+						 NETLINK_CB(cb->skb).portid,
+						 cb->nlh->nlmsg_seq,
+						 NLM_F_MULTI) < 0)
+					goto done;
+next_bind:
+				i++;
+			}
+			last_i = 0;
+			bucket++;
+		}
+
+		table++;
+		bucket = 0;
+	}
+
+	/* Connected table (accepted connections) */
+	while (bucket < ARRAY_SIZE(vsock_connected_table)) {
+		struct list_head *head = &vsock_connected_table[bucket];
+
+		i = 0;
+		list_for_each_entry(vsk, head, connected_table) {
+			struct sock *sk = sk_vsock(vsk);
+
+			/* Skip sockets we've already seen above */
+			if (__vsock_in_bound_table(vsk))
+				continue;
+
+			if (!net_eq(sock_net(sk), net))
+				continue;
+			if (i < last_i)
+				goto next_connected;
+			if (!(req->vdiag_states & (1 << sk->sk_state)))
+				goto next_connected;
+			if (sk_diag_fill(sk, skb,
+					 NETLINK_CB(cb->skb).portid,
+					 cb->nlh->nlmsg_seq,
+					 NLM_F_MULTI) < 0)
+				goto done;
+next_connected:
+			i++;
+		}
+		last_i = 0;
+		bucket++;
+	}
+
+done:
+	spin_unlock_bh(&vsock_table_lock);
+
+	cb->args[0] = table;
+	cb->args[1] = bucket;
+	cb->args[2] = i;
+
+	return skb->len;
+}
+
+static int vsock_diag_handler_dump(struct sk_buff *skb, struct nlmsghdr *h)
+{
+	int hdrlen = sizeof(struct vsock_diag_req);
+	struct net *net = sock_net(skb->sk);
+
+	if (nlmsg_len(h) < hdrlen)
+		return -EINVAL;
+
+	if (h->nlmsg_flags & NLM_F_DUMP) {
+		struct netlink_dump_control c = {
+			.dump = vsock_diag_dump,
+		};
+		return netlink_dump_start(net->diag_nlsk, skb, h, &c);
+	}
+
+	return -EOPNOTSUPP;
+}
+
+static const struct sock_diag_handler vsock_diag_handler = {
+	.family = AF_VSOCK,
+	.dump = vsock_diag_handler_dump,
+};
+
+static int __init vsock_diag_init(void)
+{
+	return sock_diag_register(&vsock_diag_handler);
+}
+
+static void __exit vsock_diag_exit(void)
+{
+	sock_diag_unregister(&vsock_diag_handler);
+}
+
+module_init(vsock_diag_init);
+module_exit(vsock_diag_exit);
+MODULE_LICENSE("GPL");
+MODULE_ALIAS_NET_PF_PROTO_TYPE(PF_NETLINK, NETLINK_SOCK_DIAG,
+			       40 /* AF_VSOCK */);
diff --git a/net/vmw_vsock/Kconfig b/net/vmw_vsock/Kconfig
index 8831e7c42167..829cb7c8f14c 100644
--- a/net/vmw_vsock/Kconfig
+++ b/net/vmw_vsock/Kconfig
@@ -15,6 +15,16 @@ config VSOCKETS
 	  To compile this driver as a module, choose M here: the module
 	  will be called vsock. If unsure, say N.
 
+config VSOCKETS_DIAG
+	tristate "Virtual Sockets monitoring interface"
+	depends on VSOCKETS
+	default y
+	help
+	  Support for PF_VSOCK sockets monitoring interface used by the ss tool.
+	  If unsure, say Y.
+
+	  Enable this module so userspace applications can query open sockets.
+
 config VMWARE_VMCI_VSOCKETS
 	tristate "VMware VMCI transport for Virtual Sockets"
 	depends on VSOCKETS && VMWARE_VMCI
-- 
2.13.6
