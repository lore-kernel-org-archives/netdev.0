From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 7/8] rxrpc: Separate local endpoint event handling
 out into its own file
Date: Wed, 15 Jun 2016 17:42:27 +0100
Message-ID: <146600894754.18270.15931874216377336842.stgit@warthog.procyon.org.uk>
References: <146600889842.18270.2306896489831492957.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, netdev@vger.kernel.org,
	linux-afs@lists.infradead.org, linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <146600889842.18270.2306896489831492957.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Separate local endpoint event handling out into its own file preparatory to
overhauling the object management aspect (which remains in the original
file).

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/Makefile       |    1 
 net/rxrpc/ar-internal.h  |    5 ++
 net/rxrpc/local_event.c  |  120 ++++++++++++++++++++++++++++++++++++++++++++++
 net/rxrpc/local_object.c |  105 +---------------------------------------
 4 files changed, 129 insertions(+), 102 deletions(-)
 create mode 100644 net/rxrpc/local_event.c

diff --git a/net/rxrpc/Makefile b/net/rxrpc/Makefile
index a6f6f21d8a59..b005027f80cf 100644
--- a/net/rxrpc/Makefile
+++ b/net/rxrpc/Makefile
@@ -12,6 +12,7 @@ af-rxrpc-y := \
 	input.o \
 	insecure.o \
 	key.o \
+	local_event.o \
 	local_object.o \
 	misc.o \
 	output.o \
diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index a63bb7518fb5..fa50b09eaa63 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -573,6 +573,11 @@ int rxrpc_get_server_data_key(struct rxrpc_connection *, const void *, time_t,
 			      u32);
 
 /*
+ * local_event.c
+ */
+extern void rxrpc_process_local_events(struct work_struct *);
+
+/*
  * local_object.c
  */
 extern rwlock_t rxrpc_local_lock;
diff --git a/net/rxrpc/local_event.c b/net/rxrpc/local_event.c
new file mode 100644
index 000000000000..194db2e6d548
--- /dev/null
+++ b/net/rxrpc/local_event.c
@@ -0,0 +1,120 @@
+/* AF_RXRPC local endpoint management
+ *
+ * Copyright (C) 2007 Red Hat, Inc. All Rights Reserved.
+ * Written by David Howells (dhowells@redhat.com)
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version
+ * 2 of the License, or (at your option) any later version.
+ */
+
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
+#include <linux/module.h>
+#include <linux/net.h>
+#include <linux/skbuff.h>
+#include <linux/slab.h>
+#include <linux/udp.h>
+#include <linux/ip.h>
+#include <net/sock.h>
+#include <net/af_rxrpc.h>
+#include <generated/utsrelease.h>
+#include "ar-internal.h"
+
+static const char rxrpc_version_string[65] = "linux-" UTS_RELEASE " AF_RXRPC";
+
+/*
+ * Reply to a version request
+ */
+static void rxrpc_send_version_request(struct rxrpc_local *local,
+				       struct rxrpc_host_header *hdr,
+				       struct sk_buff *skb)
+{
+	struct rxrpc_wire_header whdr;
+	struct rxrpc_skb_priv *sp = rxrpc_skb(skb);
+	struct sockaddr_in sin;
+	struct msghdr msg;
+	struct kvec iov[2];
+	size_t len;
+	int ret;
+
+	_enter("");
+
+	sin.sin_family = AF_INET;
+	sin.sin_port = udp_hdr(skb)->source;
+	sin.sin_addr.s_addr = ip_hdr(skb)->saddr;
+
+	msg.msg_name	= &sin;
+	msg.msg_namelen	= sizeof(sin);
+	msg.msg_control	= NULL;
+	msg.msg_controllen = 0;
+	msg.msg_flags	= 0;
+
+	whdr.epoch	= htonl(sp->hdr.epoch);
+	whdr.cid	= htonl(sp->hdr.cid);
+	whdr.callNumber	= htonl(sp->hdr.callNumber);
+	whdr.seq	= 0;
+	whdr.serial	= 0;
+	whdr.type	= RXRPC_PACKET_TYPE_VERSION;
+	whdr.flags	= RXRPC_LAST_PACKET | (~hdr->flags & RXRPC_CLIENT_INITIATED);
+	whdr.userStatus	= 0;
+	whdr.securityIndex = 0;
+	whdr._rsvd	= 0;
+	whdr.serviceId	= htons(sp->hdr.serviceId);
+
+	iov[0].iov_base	= &whdr;
+	iov[0].iov_len	= sizeof(whdr);
+	iov[1].iov_base	= (char *)rxrpc_version_string;
+	iov[1].iov_len	= sizeof(rxrpc_version_string);
+
+	len = iov[0].iov_len + iov[1].iov_len;
+
+	_proto("Tx VERSION (reply)");
+
+	ret = kernel_sendmsg(local->socket, &msg, iov, 2, len);
+	if (ret < 0)
+		_debug("sendmsg failed: %d", ret);
+
+	_leave("");
+}
+
+/*
+ * Process event packets targetted at a local endpoint.
+ */
+void rxrpc_process_local_events(struct work_struct *work)
+{
+	struct rxrpc_local *local = container_of(work, struct rxrpc_local, event_processor);
+	struct sk_buff *skb;
+	char v;
+
+	_enter("");
+
+	atomic_inc(&local->usage);
+
+	while ((skb = skb_dequeue(&local->event_queue))) {
+		struct rxrpc_skb_priv *sp = rxrpc_skb(skb);
+
+		_debug("{%d},{%u}", local->debug_id, sp->hdr.type);
+
+		switch (sp->hdr.type) {
+		case RXRPC_PACKET_TYPE_VERSION:
+			if (skb_copy_bits(skb, 0, &v, 1) < 0)
+				return;
+			_proto("Rx VERSION { %02x }", v);
+			if (v == 0)
+				rxrpc_send_version_request(local, &sp->hdr, skb);
+			break;
+
+		default:
+			/* Just ignore anything we don't understand */
+			break;
+		}
+
+		rxrpc_put_local(local);
+		rxrpc_free_skb(skb);
+	}
+
+	rxrpc_put_local(local);
+	_leave("");
+}
diff --git a/net/rxrpc/local_object.c b/net/rxrpc/local_object.c
index 28f9efb3118f..c1b8d745bf5e 100644
--- a/net/rxrpc/local_object.c
+++ b/net/rxrpc/local_object.c
@@ -1,12 +1,12 @@
-/* AF_RXRPC local endpoint management
+/* Local endpoint object management
  *
  * Copyright (C) 2007 Red Hat, Inc. All Rights Reserved.
  * Written by David Howells (dhowells@redhat.com)
  *
  * This program is free software; you can redistribute it and/or
- * modify it under the terms of the GNU General Public License
+ * modify it under the terms of the GNU General Public Licence
  * as published by the Free Software Foundation; either version
- * 2 of the License, or (at your option) any later version.
+ * 2 of the Licence, or (at your option) any later version.
  */
 
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
@@ -19,18 +19,14 @@
 #include <linux/ip.h>
 #include <net/sock.h>
 #include <net/af_rxrpc.h>
-#include <generated/utsrelease.h>
 #include "ar-internal.h"
 
-static const char rxrpc_version_string[65] = "linux-" UTS_RELEASE " AF_RXRPC";
-
 static LIST_HEAD(rxrpc_locals);
 DEFINE_RWLOCK(rxrpc_local_lock);
 static DECLARE_RWSEM(rxrpc_local_sem);
 static DECLARE_WAIT_QUEUE_HEAD(rxrpc_local_wq);
 
 static void rxrpc_destroy_local(struct work_struct *work);
-static void rxrpc_process_local_events(struct work_struct *work);
 
 /*
  * allocate a new local
@@ -320,98 +316,3 @@ void __exit rxrpc_destroy_all_locals(void)
 
 	_leave("");
 }
-
-/*
- * Reply to a version request
- */
-static void rxrpc_send_version_request(struct rxrpc_local *local,
-				       struct rxrpc_host_header *hdr,
-				       struct sk_buff *skb)
-{
-	struct rxrpc_wire_header whdr;
-	struct rxrpc_skb_priv *sp = rxrpc_skb(skb);
-	struct sockaddr_in sin;
-	struct msghdr msg;
-	struct kvec iov[2];
-	size_t len;
-	int ret;
-
-	_enter("");
-
-	sin.sin_family = AF_INET;
-	sin.sin_port = udp_hdr(skb)->source;
-	sin.sin_addr.s_addr = ip_hdr(skb)->saddr;
-
-	msg.msg_name	= &sin;
-	msg.msg_namelen	= sizeof(sin);
-	msg.msg_control	= NULL;
-	msg.msg_controllen = 0;
-	msg.msg_flags	= 0;
-
-	whdr.epoch	= htonl(sp->hdr.epoch);
-	whdr.cid	= htonl(sp->hdr.cid);
-	whdr.callNumber	= htonl(sp->hdr.callNumber);
-	whdr.seq	= 0;
-	whdr.serial	= 0;
-	whdr.type	= RXRPC_PACKET_TYPE_VERSION;
-	whdr.flags	= RXRPC_LAST_PACKET | (~hdr->flags & RXRPC_CLIENT_INITIATED);
-	whdr.userStatus	= 0;
-	whdr.securityIndex = 0;
-	whdr._rsvd	= 0;
-	whdr.serviceId	= htons(sp->hdr.serviceId);
-
-	iov[0].iov_base	= &whdr;
-	iov[0].iov_len	= sizeof(whdr);
-	iov[1].iov_base	= (char *)rxrpc_version_string;
-	iov[1].iov_len	= sizeof(rxrpc_version_string);
-
-	len = iov[0].iov_len + iov[1].iov_len;
-
-	_proto("Tx VERSION (reply)");
-
-	ret = kernel_sendmsg(local->socket, &msg, iov, 2, len);
-	if (ret < 0)
-		_debug("sendmsg failed: %d", ret);
-
-	_leave("");
-}
-
-/*
- * Process event packets targetted at a local endpoint.
- */
-static void rxrpc_process_local_events(struct work_struct *work)
-{
-	struct rxrpc_local *local = container_of(work, struct rxrpc_local, event_processor);
-	struct sk_buff *skb;
-	char v;
-
-	_enter("");
-
-	atomic_inc(&local->usage);
-
-	while ((skb = skb_dequeue(&local->event_queue))) {
-		struct rxrpc_skb_priv *sp = rxrpc_skb(skb);
-
-		_debug("{%d},{%u}", local->debug_id, sp->hdr.type);
-
-		switch (sp->hdr.type) {
-		case RXRPC_PACKET_TYPE_VERSION:
-			if (skb_copy_bits(skb, 0, &v, 1) < 0)
-				return;
-			_proto("Rx VERSION { %02x }", v);
-			if (v == 0)
-				rxrpc_send_version_request(local, &sp->hdr, skb);
-			break;
-
-		default:
-			/* Just ignore anything we don't understand */
-			break;
-		}
-
-		rxrpc_put_local(local);
-		rxrpc_free_skb(skb);
-	}
-
-	rxrpc_put_local(local);
-	_leave("");
-}
