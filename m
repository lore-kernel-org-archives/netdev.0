From: David Howells <dhowells@redhat.com>
Subject: [PATCH 4/8] af_rxrpc: Add sysctls for configuring RxRPC parameters
 [ver #2]
Date: Thu, 06 Mar 2014 12:46:43 +0000
Message-ID: <20140306124643.16645.93293.stgit@warthog.procyon.org.uk>
References: <20140306124614.16645.50744.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, tim@electronghost.co.uk,
	linux-afs@lists.infradead.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140306124614.16645.50744.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add sysctls for configuring RxRPC protocol handling, specifically controls on
delays before ack generation, the delay before resending a packet, the maximum
lifetime of a call and the expiration times of calls, connections and
transports that haven't been recently used.

More info added in Documentation/networking/rxrpc.txt.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 Documentation/networking/rxrpc.txt |   62 ++++++++++++++++++++
 net/rxrpc/Makefile                 |    5 +-
 net/rxrpc/af_rxrpc.c               |    9 +++
 net/rxrpc/ar-ack.c                 |   35 +++++++++--
 net/rxrpc/ar-call.c                |   18 ++++--
 net/rxrpc/ar-connection.c          |   10 ++-
 net/rxrpc/ar-input.c               |    2 -
 net/rxrpc/ar-internal.h            |   24 +++++++-
 net/rxrpc/ar-output.c              |    7 ++
 net/rxrpc/ar-skbuff.c              |    5 ++
 net/rxrpc/ar-transport.c           |   10 ++-
 net/rxrpc/sysctl.c                 |  113 ++++++++++++++++++++++++++++++++++++
 12 files changed, 273 insertions(+), 27 deletions(-)
 create mode 100644 net/rxrpc/sysctl.c

diff --git a/Documentation/networking/rxrpc.txt b/Documentation/networking/rxrpc.txt
index b89bc82eed46..aa08d2625f05 100644
--- a/Documentation/networking/rxrpc.txt
+++ b/Documentation/networking/rxrpc.txt
@@ -27,6 +27,8 @@ Contents of this document:
 
  (*) AF_RXRPC kernel interface.
 
+ (*) Configurable parameters.
+
 
 ========
 OVERVIEW
@@ -864,3 +866,63 @@ The kernel interface functions are as follows:
 
      This is used to allocate a null RxRPC key that can be used to indicate
      anonymous security for a particular domain.
+
+
+=======================
+CONFIGURABLE PARAMETERS
+=======================
+
+The RxRPC protocol driver has a number of configurable parameters that can be
+adjusted through sysctls in /proc/net/rxrpc/:
+
+ (*) req_ack_delay
+
+     The amount of time in milliseconds after receiving a packet with the
+     request-ack flag set before we honour the flag and actually send the
+     requested ack.
+
+     Usually the other side won't stop sending packets until the advertised
+     reception window is full (to a maximum of 255 packets), so delaying the
+     ACK permits several packets to be ACK'd in one go.
+
+ (*) soft_ack_delay
+
+     The amount of time in milliseconds after receiving a new packet before we
+     generate a soft-ACK to tell the sender that it doesn't need to resend.
+
+ (*) idle_ack_delay
+
+     The amount of time in milliseconds after all the packets currently in the
+     received queue have been consumed before we generate a hard-ACK to tell
+     the sender it can free its buffers, assuming no other reason occurs that
+     we would send an ACK.
+
+ (*) resend_timeout
+
+     The amount of time in milliseconds after transmitting a packet before we
+     transmit it again, assuming no ACK is received from the receiver telling
+     us they got it.
+
+ (*) max_call_lifetime
+
+     The maximum amount of time in seconds that a call may be in progress
+     before we preemptively kill it.
+
+ (*) dead_call_expiry
+
+     The amount of time in seconds before we remove a dead call from the call
+     list.  Dead calls are kept around for a little while for the purpose of
+     repeating ACK and ABORT packets.
+
+ (*) connection_expiry
+
+     The amount of time in seconds after a connection was last used before we
+     remove it from the connection list.  Whilst a connection is in existence,
+     it serves as a placeholder for negotiated security; when it is deleted,
+     the security must be renegotiated.
+
+ (*) transport_expiry
+
+     The amount of time in seconds after a transport was last used before we
+     remove it from the transport list.  Whilst a transport is in existence, it
+     serves to anchor the peer data and keeps the connection ID counter.
diff --git a/net/rxrpc/Makefile b/net/rxrpc/Makefile
index d1c3429b69ed..ec126f91276b 100644
--- a/net/rxrpc/Makefile
+++ b/net/rxrpc/Makefile
@@ -20,9 +20,8 @@ af-rxrpc-y := \
 	ar-skbuff.o \
 	ar-transport.o
 
-ifeq ($(CONFIG_PROC_FS),y)
-af-rxrpc-y += ar-proc.o
-endif
+af-rxrpc-$(CONFIG_PROC_FS) += ar-proc.o
+af-rxrpc-$(CONFIG_SYSCTL) += sysctl.o
 
 obj-$(CONFIG_AF_RXRPC) += af-rxrpc.o
 
diff --git a/net/rxrpc/af_rxrpc.c b/net/rxrpc/af_rxrpc.c
index e61aa6001c65..7b1670489638 100644
--- a/net/rxrpc/af_rxrpc.c
+++ b/net/rxrpc/af_rxrpc.c
@@ -838,6 +838,12 @@ static int __init af_rxrpc_init(void)
 		goto error_key_type_s;
 	}
 
+	ret = rxrpc_sysctl_init();
+	if (ret < 0) {
+		printk(KERN_CRIT "RxRPC: Cannot register sysctls\n");
+		goto error_sysctls;
+	}
+
 #ifdef CONFIG_PROC_FS
 	proc_create("rxrpc_calls", 0, init_net.proc_net, &rxrpc_call_seq_fops);
 	proc_create("rxrpc_conns", 0, init_net.proc_net,
@@ -845,6 +851,8 @@ static int __init af_rxrpc_init(void)
 #endif
 	return 0;
 
+error_sysctls:
+	unregister_key_type(&key_type_rxrpc_s);
 error_key_type_s:
 	unregister_key_type(&key_type_rxrpc);
 error_key_type:
@@ -865,6 +873,7 @@ error_call_jar:
 static void __exit af_rxrpc_exit(void)
 {
 	_enter("");
+	rxrpc_sysctl_exit();
 	unregister_key_type(&key_type_rxrpc_s);
 	unregister_key_type(&key_type_rxrpc);
 	sock_unregister(PF_RXRPC);
diff --git a/net/rxrpc/ar-ack.c b/net/rxrpc/ar-ack.c
index cd97a0ce48d8..732b82f540c5 100644
--- a/net/rxrpc/ar-ack.c
+++ b/net/rxrpc/ar-ack.c
@@ -19,7 +19,29 @@
 #include <net/af_rxrpc.h>
 #include "ar-internal.h"
 
-static unsigned int rxrpc_ack_defer = 1;
+/*
+ * How long to wait before scheduling ACK generation after seeing a
+ * packet with RXRPC_REQUEST_ACK set (in jiffies).
+ */
+unsigned rxrpc_requested_ack_delay = 1;
+
+/*
+ * How long to wait before scheduling an ACK with subtype DELAY (in jiffies).
+ *
+ * We use this when we've received new data packets.  If those packets aren't
+ * all consumed within this time we will send a DELAY ACK if an ACK was not
+ * requested to let the sender know it doesn't need to resend.
+ */
+unsigned rxrpc_soft_ack_delay = 1 * HZ;
+
+/*
+ * How long to wait before scheduling an ACK with subtype IDLE (in jiffies).
+ *
+ * We use this when we've consumed some previously soft-ACK'd packets when
+ * further packets aren't immediately received to decide when to send an IDLE
+ * ACK let the other end know that it can free up its Tx buffer space.
+ */
+unsigned rxrpc_idle_ack_delay = 1;
 
 static const char *rxrpc_acks(u8 reason)
 {
@@ -82,24 +104,23 @@ void __rxrpc_propose_ACK(struct rxrpc_call *call, u8 ack_reason,
 	switch (ack_reason) {
 	case RXRPC_ACK_DELAY:
 		_debug("run delay timer");
-		call->ack_timer.expires = jiffies + rxrpc_ack_timeout * HZ;
-		add_timer(&call->ack_timer);
-		return;
+		expiry = rxrpc_soft_ack_delay;
+		goto run_timer;
 
 	case RXRPC_ACK_IDLE:
 		if (!immediate) {
 			_debug("run defer timer");
-			expiry = 1;
+			expiry = rxrpc_idle_ack_delay;
 			goto run_timer;
 		}
 		goto cancel_timer;
 
 	case RXRPC_ACK_REQUESTED:
-		if (!rxrpc_ack_defer)
+		expiry = rxrpc_requested_ack_delay;
+		if (!expiry)
 			goto cancel_timer;
 		if (!immediate || serial == cpu_to_be32(1)) {
 			_debug("run defer timer");
-			expiry = rxrpc_ack_defer;
 			goto run_timer;
 		}
 
diff --git a/net/rxrpc/ar-call.c b/net/rxrpc/ar-call.c
index a3bbb360a3f9..1e0903a2a0db 100644
--- a/net/rxrpc/ar-call.c
+++ b/net/rxrpc/ar-call.c
@@ -16,6 +16,16 @@
 #include <net/af_rxrpc.h>
 #include "ar-internal.h"
 
+/*
+ * Maximum lifetime of a call (in jiffies).
+ */
+unsigned rxrpc_max_call_lifetime = 60 * HZ;
+
+/*
+ * Time till dead call expires after last use (in jiffies).
+ */
+unsigned rxrpc_dead_call_expiry = 2 * HZ;
+
 const char *const rxrpc_call_states[] = {
 	[RXRPC_CALL_CLIENT_SEND_REQUEST]	= "ClSndReq",
 	[RXRPC_CALL_CLIENT_AWAIT_REPLY]		= "ClAwtRpl",
@@ -38,8 +48,6 @@ const char *const rxrpc_call_states[] = {
 struct kmem_cache *rxrpc_call_jar;
 LIST_HEAD(rxrpc_calls);
 DEFINE_RWLOCK(rxrpc_call_lock);
-static unsigned int rxrpc_call_max_lifetime = 60;
-static unsigned int rxrpc_dead_call_timeout = 2;
 
 static void rxrpc_destroy_call(struct work_struct *work);
 static void rxrpc_call_life_expired(unsigned long _call);
@@ -132,7 +140,7 @@ static struct rxrpc_call *rxrpc_alloc_client_call(
 	list_add(&call->error_link, &call->conn->trans->peer->error_targets);
 	spin_unlock(&call->conn->trans->peer->lock);
 
-	call->lifetimer.expires = jiffies + rxrpc_call_max_lifetime * HZ;
+	call->lifetimer.expires = jiffies + rxrpc_max_call_lifetime;
 	add_timer(&call->lifetimer);
 
 	_leave(" = %p", call);
@@ -349,7 +357,7 @@ struct rxrpc_call *rxrpc_incoming_call(struct rxrpc_sock *rx,
 
 	_net("CALL incoming %d on CONN %d", call->debug_id, call->conn->debug_id);
 
-	call->lifetimer.expires = jiffies + rxrpc_call_max_lifetime * HZ;
+	call->lifetimer.expires = jiffies + rxrpc_max_call_lifetime;
 	add_timer(&call->lifetimer);
 	_leave(" = %p {%d} [new]", call, call->debug_id);
 	return call;
@@ -533,7 +541,7 @@ void rxrpc_release_call(struct rxrpc_call *call)
 	del_timer_sync(&call->resend_timer);
 	del_timer_sync(&call->ack_timer);
 	del_timer_sync(&call->lifetimer);
-	call->deadspan.expires = jiffies + rxrpc_dead_call_timeout * HZ;
+	call->deadspan.expires = jiffies + rxrpc_dead_call_expiry;
 	add_timer(&call->deadspan);
 
 	_leave("");
diff --git a/net/rxrpc/ar-connection.c b/net/rxrpc/ar-connection.c
index 7bf5b5b9e8b9..6631f4f1e39b 100644
--- a/net/rxrpc/ar-connection.c
+++ b/net/rxrpc/ar-connection.c
@@ -18,11 +18,15 @@
 #include <net/af_rxrpc.h>
 #include "ar-internal.h"
 
+/*
+ * Time till a connection expires after last use (in seconds).
+ */
+unsigned rxrpc_connection_expiry = 10 * 60;
+
 static void rxrpc_connection_reaper(struct work_struct *work);
 
 LIST_HEAD(rxrpc_connections);
 DEFINE_RWLOCK(rxrpc_connection_lock);
-static unsigned long rxrpc_connection_timeout = 10 * 60;
 static DECLARE_DELAYED_WORK(rxrpc_connection_reap, rxrpc_connection_reaper);
 
 /*
@@ -862,7 +866,7 @@ static void rxrpc_connection_reaper(struct work_struct *work)
 
 		spin_lock(&conn->trans->client_lock);
 		write_lock(&conn->trans->conn_lock);
-		reap_time = conn->put_time + rxrpc_connection_timeout;
+		reap_time = conn->put_time + rxrpc_connection_expiry;
 
 		if (atomic_read(&conn->usage) > 0) {
 			;
@@ -916,7 +920,7 @@ void __exit rxrpc_destroy_all_connections(void)
 {
 	_enter("");
 
-	rxrpc_connection_timeout = 0;
+	rxrpc_connection_expiry = 0;
 	cancel_delayed_work(&rxrpc_connection_reap);
 	rxrpc_queue_delayed_work(&rxrpc_connection_reap, 0);
 
diff --git a/net/rxrpc/ar-input.c b/net/rxrpc/ar-input.c
index eb7e16276cc1..540c03d338c9 100644
--- a/net/rxrpc/ar-input.c
+++ b/net/rxrpc/ar-input.c
@@ -25,8 +25,6 @@
 #include <net/net_namespace.h>
 #include "ar-internal.h"
 
-unsigned long rxrpc_ack_timeout = 1;
-
 const char *rxrpc_pkts[] = {
 	"?00",
 	"DATA", "ACK", "BUSY", "ABORT", "ACKALL", "CHALL", "RESP", "DEBUG",
diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index 5f43675ee1df..036e1dd84223 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -433,6 +433,10 @@ int rxrpc_reject_call(struct rxrpc_sock *);
 /*
  * ar-ack.c
  */
+extern unsigned rxrpc_requested_ack_delay;
+extern unsigned rxrpc_soft_ack_delay;
+extern unsigned rxrpc_idle_ack_delay;
+
 void __rxrpc_propose_ACK(struct rxrpc_call *, u8, __be32, bool);
 void rxrpc_propose_ACK(struct rxrpc_call *, u8, __be32, bool);
 void rxrpc_process_call(struct work_struct *);
@@ -440,6 +444,8 @@ void rxrpc_process_call(struct work_struct *);
 /*
  * ar-call.c
  */
+extern unsigned rxrpc_max_call_lifetime;
+extern unsigned rxrpc_dead_call_expiry;
 extern struct kmem_cache *rxrpc_call_jar;
 extern struct list_head rxrpc_calls;
 extern rwlock_t rxrpc_call_lock;
@@ -460,6 +466,7 @@ void __exit rxrpc_destroy_all_calls(void);
 /*
  * ar-connection.c
  */
+extern unsigned rxrpc_connection_expiry;
 extern struct list_head rxrpc_connections;
 extern rwlock_t rxrpc_connection_lock;
 
@@ -493,7 +500,6 @@ void rxrpc_UDP_error_handler(struct work_struct *);
 /*
  * ar-input.c
  */
-extern unsigned long rxrpc_ack_timeout;
 extern const char *rxrpc_pkts[];
 
 void rxrpc_data_ready(struct sock *, int);
@@ -504,6 +510,7 @@ void rxrpc_fast_process_packet(struct rxrpc_call *, struct sk_buff *);
  * ar-local.c
  */
 extern rwlock_t rxrpc_local_lock;
+
 struct rxrpc_local *rxrpc_lookup_local(struct sockaddr_rxrpc *);
 void rxrpc_put_local(struct rxrpc_local *);
 void __exit rxrpc_destroy_all_locals(void);
@@ -522,7 +529,7 @@ int rxrpc_get_server_data_key(struct rxrpc_connection *, const void *, time_t,
 /*
  * ar-output.c
  */
-extern int rxrpc_resend_timeout;
+extern unsigned rxrpc_resend_timeout;
 
 int rxrpc_send_packet(struct rxrpc_transport *, struct sk_buff *);
 int rxrpc_client_sendmsg(struct kiocb *, struct rxrpc_sock *,
@@ -572,6 +579,8 @@ void rxrpc_packet_destructor(struct sk_buff *);
 /*
  * ar-transport.c
  */
+extern unsigned rxrpc_transport_expiry;
+
 struct rxrpc_transport *rxrpc_get_transport(struct rxrpc_local *,
 					    struct rxrpc_peer *, gfp_t);
 void rxrpc_put_transport(struct rxrpc_transport *);
@@ -580,6 +589,17 @@ struct rxrpc_transport *rxrpc_find_transport(struct rxrpc_local *,
 					     struct rxrpc_peer *);
 
 /*
+ * sysctl.c
+ */
+#ifdef CONFIG_SYSCTL
+extern int __init rxrpc_sysctl_init(void);
+extern void rxrpc_sysctl_exit(void);
+#else
+static inline int __init rxrpc_sysctl_init(void) { return 0; }
+static inline void rxrpc_sysctl_exit(void) {}
+#endif
+
+/*
  * debug tracing
  */
 extern unsigned int rxrpc_debug;
diff --git a/net/rxrpc/ar-output.c b/net/rxrpc/ar-output.c
index d0e8f1c1898a..4814d882bcb4 100644
--- a/net/rxrpc/ar-output.c
+++ b/net/rxrpc/ar-output.c
@@ -18,7 +18,10 @@
 #include <net/af_rxrpc.h>
 #include "ar-internal.h"
 
-int rxrpc_resend_timeout = 4;
+/*
+ * Time till packet resend (in jiffies).
+ */
+unsigned rxrpc_resend_timeout = 4 * HZ;
 
 static int rxrpc_send_data(struct kiocb *iocb,
 			   struct rxrpc_sock *rx,
@@ -487,7 +490,7 @@ static void rxrpc_queue_packet(struct rxrpc_call *call, struct sk_buff *skb,
 	       ntohl(sp->hdr.serial), ntohl(sp->hdr.seq));
 
 	sp->need_resend = false;
-	sp->resend_at = jiffies + rxrpc_resend_timeout * HZ;
+	sp->resend_at = jiffies + rxrpc_resend_timeout;
 	if (!test_and_set_bit(RXRPC_CALL_RUN_RTIMER, &call->flags)) {
 		_debug("run timer");
 		call->resend_timer.expires = sp->resend_at;
diff --git a/net/rxrpc/ar-skbuff.c b/net/rxrpc/ar-skbuff.c
index de755e04d29c..af9f4fd2a365 100644
--- a/net/rxrpc/ar-skbuff.c
+++ b/net/rxrpc/ar-skbuff.c
@@ -83,6 +83,11 @@ static void rxrpc_hard_ACK_data(struct rxrpc_call *call,
 		rxrpc_request_final_ACK(call);
 	} else if (atomic_dec_and_test(&call->ackr_not_idle) &&
 		   test_and_clear_bit(RXRPC_CALL_TX_SOFT_ACK, &call->flags)) {
+		/* We previously soft-ACK'd some received packets that have now
+		 * been consumed, so send a hard-ACK if no more packets are
+		 * immediately forthcoming to allow the transmitter to free up
+		 * its Tx bufferage.
+		 */
 		_debug("send Rx idle ACK");
 		__rxrpc_propose_ACK(call, RXRPC_ACK_IDLE, sp->hdr.serial,
 				    true);
diff --git a/net/rxrpc/ar-transport.c b/net/rxrpc/ar-transport.c
index 92df566930b9..1976dec84f29 100644
--- a/net/rxrpc/ar-transport.c
+++ b/net/rxrpc/ar-transport.c
@@ -17,11 +17,15 @@
 #include <net/af_rxrpc.h>
 #include "ar-internal.h"
 
+/*
+ * Time after last use at which transport record is cleaned up.
+ */
+unsigned rxrpc_transport_expiry = 3600 * 24;
+
 static void rxrpc_transport_reaper(struct work_struct *work);
 
 static LIST_HEAD(rxrpc_transports);
 static DEFINE_RWLOCK(rxrpc_transport_lock);
-static unsigned long rxrpc_transport_timeout = 3600 * 24;
 static DECLARE_DELAYED_WORK(rxrpc_transport_reap, rxrpc_transport_reaper);
 
 /*
@@ -235,7 +239,7 @@ static void rxrpc_transport_reaper(struct work_struct *work)
 		if (likely(atomic_read(&trans->usage) > 0))
 			continue;
 
-		reap_time = trans->put_time + rxrpc_transport_timeout;
+		reap_time = trans->put_time + rxrpc_transport_expiry;
 		if (reap_time <= now)
 			list_move_tail(&trans->link, &graveyard);
 		else if (reap_time < earliest)
@@ -271,7 +275,7 @@ void __exit rxrpc_destroy_all_transports(void)
 {
 	_enter("");
 
-	rxrpc_transport_timeout = 0;
+	rxrpc_transport_expiry = 0;
 	cancel_delayed_work(&rxrpc_transport_reap);
 	rxrpc_queue_delayed_work(&rxrpc_transport_reap, 0);
 
diff --git a/net/rxrpc/sysctl.c b/net/rxrpc/sysctl.c
new file mode 100644
index 000000000000..cdc85e72af5d
--- /dev/null
+++ b/net/rxrpc/sysctl.c
@@ -0,0 +1,113 @@
+/* sysctls for configuring RxRPC operating parameters
+ *
+ * Copyright (C) 2014 Red Hat, Inc. All Rights Reserved.
+ * Written by David Howells (dhowells@redhat.com)
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public Licence
+ * as published by the Free Software Foundation; either version
+ * 2 of the Licence, or (at your option) any later version.
+ */
+
+#include <linux/sysctl.h>
+#include <net/sock.h>
+#include <net/af_rxrpc.h>
+#include "ar-internal.h"
+
+static struct ctl_table_header *rxrpc_sysctl_reg_table;
+static const unsigned zero = 0;
+static const unsigned one = 1;
+
+/*
+ * RxRPC operating parameters.
+ *
+ * See Documentation/networking/rxrpc.txt and the variable definitions for more
+ * information on the individual parameters.
+ */
+static struct ctl_table rxrpc_sysctl_table[] = {
+	/* Values measured in milliseconds */
+	{
+		.procname	= "req_ack_delay",
+		.data		= &rxrpc_requested_ack_delay,
+		.maxlen		= sizeof(unsigned),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_ms_jiffies,
+		.extra1		= (void *)&zero,
+	},
+	{
+		.procname	= "soft_ack_delay",
+		.data		= &rxrpc_soft_ack_delay,
+		.maxlen		= sizeof(unsigned),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_ms_jiffies,
+		.extra1		= (void *)&one,
+	},
+	{
+		.procname	= "idle_ack_delay",
+		.data		= &rxrpc_idle_ack_delay,
+		.maxlen		= sizeof(unsigned),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_ms_jiffies,
+		.extra1		= (void *)&one,
+	},
+	{
+		.procname	= "resend_timeout",
+		.data		= &rxrpc_resend_timeout,
+		.maxlen		= sizeof(unsigned),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_ms_jiffies,
+		.extra1		= (void *)&one,
+	},
+
+	/* Values measured in seconds but used in jiffies */
+	{
+		.procname	= "max_call_lifetime",
+		.data		= &rxrpc_max_call_lifetime,
+		.maxlen		= sizeof(unsigned),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_jiffies,
+		.extra1		= (void *)&one,
+	},
+	{
+		.procname	= "dead_call_expiry",
+		.data		= &rxrpc_dead_call_expiry,
+		.maxlen		= sizeof(unsigned),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_jiffies,
+		.extra1		= (void *)&one,
+	},
+
+	/* Values measured in seconds */
+	{
+		.procname	= "connection_expiry",
+		.data		= &rxrpc_connection_expiry,
+		.maxlen		= sizeof(unsigned),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= (void *)&one,
+	},
+	{
+		.procname	= "transport_expiry",
+		.data		= &rxrpc_transport_expiry,
+		.maxlen		= sizeof(unsigned),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= (void *)&one,
+	},
+	{ }
+};
+
+int __init rxrpc_sysctl_init(void)
+{
+	rxrpc_sysctl_reg_table = register_net_sysctl(&init_net, "net/rxrpc",
+						     rxrpc_sysctl_table);
+	if (!rxrpc_sysctl_reg_table)
+		return -ENOMEM;
+	return 0;
+}
+
+void rxrpc_sysctl_exit(void)
+{
+	if (rxrpc_sysctl_reg_table)
+		unregister_net_sysctl_table(rxrpc_sysctl_reg_table);
+}
