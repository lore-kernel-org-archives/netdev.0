From: David Howells <dhowells@redhat.com>
Subject: [PATCH 06/11] rxrpc: Rename ar-local.c to local-event.c
Date: Mon, 07 Mar 2016 14:38:41 +0000
Message-ID: <20160307143841.18567.40309.stgit@warthog.procyon.org.uk>
References: <20160307143759.18567.8234.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linux-afs@lists.infradead.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160307143759.18567.8234.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rename ar-local.c to local-event.c.  What's left in the file is the local
endpoint event/packet handling code after the object management has been
separated out.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/Makefile      |    2 -
 net/rxrpc/ar-internal.h |   10 ++--
 net/rxrpc/ar-local.c    |  119 -----------------------------------------------
 net/rxrpc/local-event.c |  119 +++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 125 insertions(+), 125 deletions(-)
 delete mode 100644 net/rxrpc/ar-local.c
 create mode 100644 net/rxrpc/local-event.c

diff --git a/net/rxrpc/Makefile b/net/rxrpc/Makefile
index 166e4cb3b13c..7f41d272bf3d 100644
--- a/net/rxrpc/Makefile
+++ b/net/rxrpc/Makefile
@@ -12,13 +12,13 @@ af-rxrpc-y := \
 	ar-error.o \
 	ar-input.o \
 	ar-key.o \
-	ar-local.o \
 	ar-output.o \
 	ar-peer.o \
 	ar-recvmsg.o \
 	ar-security.o \
 	ar-skbuff.o \
 	ar-transport.o \
+	local-event.o \
 	local-object.o \
 	objcache.o
 
diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index ceb1442f745b..79c965789c2c 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -596,11 +596,6 @@ int rxrpc_queue_rcv_skb(struct rxrpc_call *, struct sk_buff *, bool, bool);
 void rxrpc_fast_process_packet(struct rxrpc_call *, struct sk_buff *);
 
 /*
- * ar-local.c
- */
-extern void rxrpc_process_local_events(struct work_struct *);
-
-/*
  * ar-key.c
  */
 extern struct key_type key_type_rxrpc;
@@ -672,6 +667,11 @@ struct rxrpc_transport *rxrpc_find_transport(struct rxrpc_local *,
 					     struct rxrpc_peer *);
 
 /*
+ * local-event.c
+ */
+extern void rxrpc_process_local_events(struct work_struct *);
+
+/*
  * local-object.c
  */
 extern struct objcache rxrpc_local_cache;
diff --git a/net/rxrpc/ar-local.c b/net/rxrpc/ar-local.c
deleted file mode 100644
index 6ab0e9bfdbe8..000000000000
--- a/net/rxrpc/ar-local.c
+++ /dev/null
@@ -1,119 +0,0 @@
-/* AF_RXRPC local endpoint management
- *
- * Copyright (C) 2007 Red Hat, Inc. All Rights Reserved.
- * Written by David Howells (dhowells@redhat.com)
- *
- * This program is free software; you can redistribute it and/or
- * modify it under the terms of the GNU General Public License
- * as published by the Free Software Foundation; either version
- * 2 of the License, or (at your option) any later version.
- */
-
-#include <linux/module.h>
-#include <linux/net.h>
-#include <linux/skbuff.h>
-#include <linux/slab.h>
-#include <linux/udp.h>
-#include <linux/ip.h>
-#include <net/sock.h>
-#include <net/af_rxrpc.h>
-#include <generated/utsrelease.h>
-#include "ar-internal.h"
-
-static const char rxrpc_version_string[65] = "linux-" UTS_RELEASE " AF_RXRPC";
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
-void rxrpc_process_local_events(struct work_struct *work)
-{
-	struct rxrpc_local *local =
-		container_of(work, struct rxrpc_local, processor);
-	struct sk_buff *skb;
-	char v;
-
-	_enter("");
-
-	rxrpc_get_local(local);
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
diff --git a/net/rxrpc/local-event.c b/net/rxrpc/local-event.c
new file mode 100644
index 000000000000..6ab0e9bfdbe8
--- /dev/null
+++ b/net/rxrpc/local-event.c
@@ -0,0 +1,119 @@
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
+	struct rxrpc_local *local =
+		container_of(work, struct rxrpc_local, processor);
+	struct sk_buff *skb;
+	char v;
+
+	_enter("");
+
+	rxrpc_get_local(local);
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
