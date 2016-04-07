From: David Howells <dhowells@redhat.com>
Subject: [PATCH 3/9] rxrpc: Move some miscellaneous bits out into their own
 file
Date: Thu, 07 Apr 2016 17:23:16 +0100
Message-ID: <20160407162316.21283.29456.stgit@warthog.procyon.org.uk>
References: <20160407162256.21283.47849.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linux-afs@lists.infradead.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160407162256.21283.47849.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Move some miscellaneous bits out into their own file to make it easier to
split the call handling.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 include/net/af_rxrpc.h  |    1 +
 net/rxrpc/Makefile      |    3 +-
 net/rxrpc/ar-ack.c      |   68 ------------------------------------
 net/rxrpc/ar-input.c    |    6 ---
 net/rxrpc/ar-internal.h |   24 ++++++++-----
 net/rxrpc/misc.c        |   89 +++++++++++++++++++++++++++++++++++++++++++++++
 6 files changed, 107 insertions(+), 84 deletions(-)
 create mode 100644 net/rxrpc/misc.c

diff --git a/include/net/af_rxrpc.h b/include/net/af_rxrpc.h
index e797d45a5ae6..4fd3e4a2cadd 100644
--- a/include/net/af_rxrpc.h
+++ b/include/net/af_rxrpc.h
@@ -12,6 +12,7 @@
 #ifndef _NET_RXRPC_H
 #define _NET_RXRPC_H
 
+#include <linux/skbuff.h>
 #include <linux/rxrpc.h>
 
 struct rxrpc_call;
diff --git a/net/rxrpc/Makefile b/net/rxrpc/Makefile
index ec126f91276b..5b98c1640d6d 100644
--- a/net/rxrpc/Makefile
+++ b/net/rxrpc/Makefile
@@ -18,7 +18,8 @@ af-rxrpc-y := \
 	ar-recvmsg.o \
 	ar-security.o \
 	ar-skbuff.o \
-	ar-transport.o
+	ar-transport.o \
+	misc.o
 
 af-rxrpc-$(CONFIG_PROC_FS) += ar-proc.o
 af-rxrpc-$(CONFIG_SYSCTL) += sysctl.o
diff --git a/net/rxrpc/ar-ack.c b/net/rxrpc/ar-ack.c
index 01a017a05f14..54bf43ba9aa8 100644
--- a/net/rxrpc/ar-ack.c
+++ b/net/rxrpc/ar-ack.c
@@ -20,74 +20,6 @@
 #include "ar-internal.h"
 
 /*
- * How long to wait before scheduling ACK generation after seeing a
- * packet with RXRPC_REQUEST_ACK set (in jiffies).
- */
-unsigned int rxrpc_requested_ack_delay = 1;
-
-/*
- * How long to wait before scheduling an ACK with subtype DELAY (in jiffies).
- *
- * We use this when we've received new data packets.  If those packets aren't
- * all consumed within this time we will send a DELAY ACK if an ACK was not
- * requested to let the sender know it doesn't need to resend.
- */
-unsigned int rxrpc_soft_ack_delay = 1 * HZ;
-
-/*
- * How long to wait before scheduling an ACK with subtype IDLE (in jiffies).
- *
- * We use this when we've consumed some previously soft-ACK'd packets when
- * further packets aren't immediately received to decide when to send an IDLE
- * ACK let the other end know that it can free up its Tx buffer space.
- */
-unsigned int rxrpc_idle_ack_delay = 0.5 * HZ;
-
-/*
- * Receive window size in packets.  This indicates the maximum number of
- * unconsumed received packets we're willing to retain in memory.  Once this
- * limit is hit, we should generate an EXCEEDS_WINDOW ACK and discard further
- * packets.
- */
-unsigned int rxrpc_rx_window_size = 32;
-
-/*
- * Maximum Rx MTU size.  This indicates to the sender the size of jumbo packet
- * made by gluing normal packets together that we're willing to handle.
- */
-unsigned int rxrpc_rx_mtu = 5692;
-
-/*
- * The maximum number of fragments in a received jumbo packet that we tell the
- * sender that we're willing to handle.
- */
-unsigned int rxrpc_rx_jumbo_max = 4;
-
-static const char *rxrpc_acks(u8 reason)
-{
-	static const char *const str[] = {
-		"---", "REQ", "DUP", "OOS", "WIN", "MEM", "PNG", "PNR", "DLY",
-		"IDL", "-?-"
-	};
-
-	if (reason >= ARRAY_SIZE(str))
-		reason = ARRAY_SIZE(str) - 1;
-	return str[reason];
-}
-
-static const s8 rxrpc_ack_priority[] = {
-	[0]				= 0,
-	[RXRPC_ACK_DELAY]		= 1,
-	[RXRPC_ACK_REQUESTED]		= 2,
-	[RXRPC_ACK_IDLE]		= 3,
-	[RXRPC_ACK_PING_RESPONSE]	= 4,
-	[RXRPC_ACK_DUPLICATE]		= 5,
-	[RXRPC_ACK_OUT_OF_SEQUENCE]	= 6,
-	[RXRPC_ACK_EXCEEDS_WINDOW]	= 7,
-	[RXRPC_ACK_NOSPACE]		= 8,
-};
-
-/*
  * propose an ACK be sent
  */
 void __rxrpc_propose_ACK(struct rxrpc_call *call, u8 ack_reason,
diff --git a/net/rxrpc/ar-input.c b/net/rxrpc/ar-input.c
index 63ed75c40e29..f9d97fcb21ff 100644
--- a/net/rxrpc/ar-input.c
+++ b/net/rxrpc/ar-input.c
@@ -25,12 +25,6 @@
 #include <net/net_namespace.h>
 #include "ar-internal.h"
 
-const char *rxrpc_pkts[] = {
-	"?00",
-	"DATA", "ACK", "BUSY", "ABORT", "ACKALL", "CHALL", "RESP", "DEBUG",
-	"?09", "?10", "?11", "?12", "VERSION", "?14", "?15"
-};
-
 /*
  * queue a packet for recvmsg to pass to userspace
  * - the caller must hold a lock on call->lock
diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index cd6cdbe87125..24126d954f38 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -478,13 +478,6 @@ int rxrpc_reject_call(struct rxrpc_sock *);
 /*
  * ar-ack.c
  */
-extern unsigned int rxrpc_requested_ack_delay;
-extern unsigned int rxrpc_soft_ack_delay;
-extern unsigned int rxrpc_idle_ack_delay;
-extern unsigned int rxrpc_rx_window_size;
-extern unsigned int rxrpc_rx_mtu;
-extern unsigned int rxrpc_rx_jumbo_max;
-
 void __rxrpc_propose_ACK(struct rxrpc_call *, u8, u32, bool);
 void rxrpc_propose_ACK(struct rxrpc_call *, u8, u32, bool);
 void rxrpc_process_call(struct work_struct *);
@@ -550,8 +543,6 @@ void rxrpc_UDP_error_handler(struct work_struct *);
 /*
  * ar-input.c
  */
-extern const char *rxrpc_pkts[];
-
 void rxrpc_data_ready(struct sock *);
 int rxrpc_queue_rcv_skb(struct rxrpc_call *, struct sk_buff *, bool, bool);
 void rxrpc_fast_process_packet(struct rxrpc_call *, struct sk_buff *);
@@ -637,6 +628,21 @@ struct rxrpc_transport *rxrpc_find_transport(struct rxrpc_local *,
 					     struct rxrpc_peer *);
 
 /*
+ * misc.c
+ */
+extern unsigned int rxrpc_requested_ack_delay;
+extern unsigned int rxrpc_soft_ack_delay;
+extern unsigned int rxrpc_idle_ack_delay;
+extern unsigned int rxrpc_rx_window_size;
+extern unsigned int rxrpc_rx_mtu;
+extern unsigned int rxrpc_rx_jumbo_max;
+
+extern const char *rxrpc_pkts[];
+extern const s8 rxrpc_ack_priority[];
+
+extern const char *rxrpc_acks(u8 reason);
+
+/*
  * sysctl.c
  */
 #ifdef CONFIG_SYSCTL
diff --git a/net/rxrpc/misc.c b/net/rxrpc/misc.c
new file mode 100644
index 000000000000..8ebeec3384e1
--- /dev/null
+++ b/net/rxrpc/misc.c
@@ -0,0 +1,89 @@
+/* Miscellaneous bits
+ *
+ * Copyright (C) 2016 Red Hat, Inc. All Rights Reserved.
+ * Written by David Howells (dhowells@redhat.com)
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public Licence
+ * as published by the Free Software Foundation; either version
+ * 2 of the Licence, or (at your option) any later version.
+ */
+
+#include <linux/kernel.h>
+#include <net/sock.h>
+#include <net/af_rxrpc.h>
+#include "ar-internal.h"
+
+/*
+ * How long to wait before scheduling ACK generation after seeing a
+ * packet with RXRPC_REQUEST_ACK set (in jiffies).
+ */
+unsigned int rxrpc_requested_ack_delay = 1;
+
+/*
+ * How long to wait before scheduling an ACK with subtype DELAY (in jiffies).
+ *
+ * We use this when we've received new data packets.  If those packets aren't
+ * all consumed within this time we will send a DELAY ACK if an ACK was not
+ * requested to let the sender know it doesn't need to resend.
+ */
+unsigned int rxrpc_soft_ack_delay = 1 * HZ;
+
+/*
+ * How long to wait before scheduling an ACK with subtype IDLE (in jiffies).
+ *
+ * We use this when we've consumed some previously soft-ACK'd packets when
+ * further packets aren't immediately received to decide when to send an IDLE
+ * ACK let the other end know that it can free up its Tx buffer space.
+ */
+unsigned int rxrpc_idle_ack_delay = 0.5 * HZ;
+
+/*
+ * Receive window size in packets.  This indicates the maximum number of
+ * unconsumed received packets we're willing to retain in memory.  Once this
+ * limit is hit, we should generate an EXCEEDS_WINDOW ACK and discard further
+ * packets.
+ */
+unsigned int rxrpc_rx_window_size = 32;
+
+/*
+ * Maximum Rx MTU size.  This indicates to the sender the size of jumbo packet
+ * made by gluing normal packets together that we're willing to handle.
+ */
+unsigned int rxrpc_rx_mtu = 5692;
+
+/*
+ * The maximum number of fragments in a received jumbo packet that we tell the
+ * sender that we're willing to handle.
+ */
+unsigned int rxrpc_rx_jumbo_max = 4;
+
+const char *rxrpc_pkts[] = {
+	"?00",
+	"DATA", "ACK", "BUSY", "ABORT", "ACKALL", "CHALL", "RESP", "DEBUG",
+	"?09", "?10", "?11", "?12", "VERSION", "?14", "?15"
+};
+
+const s8 rxrpc_ack_priority[] = {
+	[0]				= 0,
+	[RXRPC_ACK_DELAY]		= 1,
+	[RXRPC_ACK_REQUESTED]		= 2,
+	[RXRPC_ACK_IDLE]		= 3,
+	[RXRPC_ACK_PING_RESPONSE]	= 4,
+	[RXRPC_ACK_DUPLICATE]		= 5,
+	[RXRPC_ACK_OUT_OF_SEQUENCE]	= 6,
+	[RXRPC_ACK_EXCEEDS_WINDOW]	= 7,
+	[RXRPC_ACK_NOSPACE]		= 8,
+};
+
+const char *rxrpc_acks(u8 reason)
+{
+	static const char *const str[] = {
+		"---", "REQ", "DUP", "OOS", "WIN", "MEM", "PNG", "PNR", "DLY",
+		"IDL", "-?-"
+	};
+
+	if (reason >= ARRAY_SIZE(str))
+		reason = ARRAY_SIZE(str) - 1;
+	return str[reason];
+}
