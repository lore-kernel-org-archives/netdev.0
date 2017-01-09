From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 1/4] afs: Add some tracepoints
Date: Mon, 09 Jan 2017 14:52:55 +0000
Message-ID: <148397357592.20445.2731053255520233106.stgit@warthog.procyon.org.uk>
References: <148397356909.20445.15077871371099721338.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <148397356909.20445.15077871371099721338.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add three tracepoints to the AFS filesystem:

 (1) The afs_recv_data tracepoint logs data segments that are extracted
     from the data received from the peer through afs_extract_data().

 (2) The afs_notify_call tracepoint logs notification from AF_RXRPC of data
     coming in to an asynchronous call.

 (3) The afs_cb_call tracepoint logs incoming calls that have had their
     operation ID extracted and mapped into a supported cache manager
     service call.

To make (3) work, the name strings in the afs_call_type struct objects have
to be annotated with __tracepoint_string.  This is done with the CM_NAME()
macro.

Further, the AFS call state enum needs a name so that it can be used to
declare parameter types.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/afs/cmservice.c         |   22 ++++++---
 fs/afs/internal.h          |   21 +++++---
 fs/afs/main.c              |    1 
 fs/afs/rxrpc.c             |    6 ++
 include/trace/events/afs.h |  109 ++++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 144 insertions(+), 15 deletions(-)
 create mode 100644 include/trace/events/afs.h

diff --git a/fs/afs/cmservice.c b/fs/afs/cmservice.c
index d764236072b1..a2e1e02005f6 100644
--- a/fs/afs/cmservice.c
+++ b/fs/afs/cmservice.c
@@ -25,11 +25,16 @@ static int afs_deliver_cb_probe_uuid(struct afs_call *);
 static int afs_deliver_cb_tell_me_about_yourself(struct afs_call *);
 static void afs_cm_destructor(struct afs_call *);
 
+#define CM_NAME(name) \
+	const char afs_SRXCB##name##_name[] __tracepoint_string =	\
+		"CB." #name
+
 /*
  * CB.CallBack operation type
  */
+static CM_NAME(CallBack);
 static const struct afs_call_type afs_SRXCBCallBack = {
-	.name		= "CB.CallBack",
+	.name		= afs_SRXCBCallBack_name,
 	.deliver	= afs_deliver_cb_callback,
 	.abort_to_error	= afs_abort_to_error,
 	.destructor	= afs_cm_destructor,
@@ -38,8 +43,9 @@ static const struct afs_call_type afs_SRXCBCallBack = {
 /*
  * CB.InitCallBackState operation type
  */
+static CM_NAME(InitCallBackState);
 static const struct afs_call_type afs_SRXCBInitCallBackState = {
-	.name		= "CB.InitCallBackState",
+	.name		= afs_SRXCBInitCallBackState_name,
 	.deliver	= afs_deliver_cb_init_call_back_state,
 	.abort_to_error	= afs_abort_to_error,
 	.destructor	= afs_cm_destructor,
@@ -48,8 +54,9 @@ static const struct afs_call_type afs_SRXCBInitCallBackState = {
 /*
  * CB.InitCallBackState3 operation type
  */
+static CM_NAME(InitCallBackState3);
 static const struct afs_call_type afs_SRXCBInitCallBackState3 = {
-	.name		= "CB.InitCallBackState3",
+	.name		= afs_SRXCBInitCallBackState3_name,
 	.deliver	= afs_deliver_cb_init_call_back_state3,
 	.abort_to_error	= afs_abort_to_error,
 	.destructor	= afs_cm_destructor,
@@ -58,8 +65,9 @@ static const struct afs_call_type afs_SRXCBInitCallBackState3 = {
 /*
  * CB.Probe operation type
  */
+static CM_NAME(Probe);
 static const struct afs_call_type afs_SRXCBProbe = {
-	.name		= "CB.Probe",
+	.name		= afs_SRXCBProbe_name,
 	.deliver	= afs_deliver_cb_probe,
 	.abort_to_error	= afs_abort_to_error,
 	.destructor	= afs_cm_destructor,
@@ -68,8 +76,9 @@ static const struct afs_call_type afs_SRXCBProbe = {
 /*
  * CB.ProbeUuid operation type
  */
+static CM_NAME(ProbeUuid);
 static const struct afs_call_type afs_SRXCBProbeUuid = {
-	.name		= "CB.ProbeUuid",
+	.name		= afs_SRXCBProbeUuid_name,
 	.deliver	= afs_deliver_cb_probe_uuid,
 	.abort_to_error	= afs_abort_to_error,
 	.destructor	= afs_cm_destructor,
@@ -78,8 +87,9 @@ static const struct afs_call_type afs_SRXCBProbeUuid = {
 /*
  * CB.TellMeAboutYourself operation type
  */
+static CM_NAME(TellMeAboutYourself);
 static const struct afs_call_type afs_SRXCBTellMeAboutYourself = {
-	.name		= "CB.TellMeAboutYourself",
+	.name		= afs_SRXCBTellMeAboutYourself_name,
 	.deliver	= afs_deliver_cb_tell_me_about_yourself,
 	.abort_to_error	= afs_abort_to_error,
 	.destructor	= afs_cm_destructor,
diff --git a/fs/afs/internal.h b/fs/afs/internal.h
index 6f7a9638ba1a..f71e58fcc2f2 100644
--- a/fs/afs/internal.h
+++ b/fs/afs/internal.h
@@ -68,6 +68,15 @@ struct afs_wait_mode {
 extern const struct afs_wait_mode afs_sync_call;
 extern const struct afs_wait_mode afs_async_call;
 
+enum afs_call_state {
+	AFS_CALL_REQUESTING,	/* request is being sent for outgoing call */
+	AFS_CALL_AWAIT_REPLY,	/* awaiting reply to outgoing call */
+	AFS_CALL_AWAIT_OP_ID,	/* awaiting op ID on incoming call */
+	AFS_CALL_AWAIT_REQUEST,	/* awaiting request data on incoming call */
+	AFS_CALL_REPLYING,	/* replying to incoming call */
+	AFS_CALL_AWAIT_ACK,	/* awaiting final ACK of incoming call */
+	AFS_CALL_COMPLETE,	/* Completed or failed */
+};
 /*
  * a record of an in-progress RxRPC call
  */
@@ -91,15 +100,7 @@ struct afs_call {
 	pgoff_t			first;		/* first page in mapping to deal with */
 	pgoff_t			last;		/* last page in mapping to deal with */
 	size_t			offset;		/* offset into received data store */
-	enum {					/* call state */
-		AFS_CALL_REQUESTING,	/* request is being sent for outgoing call */
-		AFS_CALL_AWAIT_REPLY,	/* awaiting reply to outgoing call */
-		AFS_CALL_AWAIT_OP_ID,	/* awaiting op ID on incoming call */
-		AFS_CALL_AWAIT_REQUEST,	/* awaiting request data on incoming call */
-		AFS_CALL_REPLYING,	/* replying to incoming call */
-		AFS_CALL_AWAIT_ACK,	/* awaiting final ACK of incoming call */
-		AFS_CALL_COMPLETE,	/* Completed or failed */
-	}			state;
+	enum afs_call_state	state;
 	int			error;		/* error code */
 	u32			abort_code;	/* Remote abort ID or 0 */
 	unsigned		request_size;	/* size of request data */
@@ -773,6 +774,8 @@ extern int afs_fsync(struct file *, loff_t, loff_t, int);
 /*
  * debug tracing
  */
+#include <trace/events/afs.h>
+
 extern unsigned afs_debug;
 
 #define dbgprintk(FMT,...) \
diff --git a/fs/afs/main.c b/fs/afs/main.c
index 0b187ef3b5b7..f8188feb03ad 100644
--- a/fs/afs/main.c
+++ b/fs/afs/main.c
@@ -15,6 +15,7 @@
 #include <linux/completion.h>
 #include <linux/sched.h>
 #include <linux/random.h>
+#define CREATE_TRACE_POINTS
 #include "internal.h"
 
 MODULE_DESCRIPTION("AFS Client File System");
diff --git a/fs/afs/rxrpc.c b/fs/afs/rxrpc.c
index 25f05a8d21b1..f26344a8c029 100644
--- a/fs/afs/rxrpc.c
+++ b/fs/afs/rxrpc.c
@@ -416,6 +416,8 @@ static void afs_deliver_to_call(struct afs_call *call)
 			ret = rxrpc_kernel_recv_data(afs_socket, call->rxcall,
 						     NULL, 0, &offset, false,
 						     &call->abort_code);
+			trace_afs_recv_data(call, 0, offset, false, ret);
+
 			if (ret == -EINPROGRESS || ret == -EAGAIN)
 				return;
 			if (ret == 1 || ret < 0) {
@@ -541,6 +543,7 @@ static void afs_wake_up_async_call(struct sock *sk, struct rxrpc_call *rxcall,
 {
 	struct afs_call *call = (struct afs_call *)call_user_ID;
 
+	trace_afs_notify_call(rxcall, call);
 	call->need_attention = true;
 	queue_work(afs_async_calls, &call->async_work);
 }
@@ -689,6 +692,8 @@ static int afs_deliver_cm_op_id(struct afs_call *call)
 	if (!afs_cm_incoming_call(call))
 		return -ENOTSUPP;
 
+	trace_afs_cb_call(call);
+
 	/* pass responsibility for the remainer of this message off to the
 	 * cache manager op */
 	return call->type->deliver(call);
@@ -780,6 +785,7 @@ int afs_extract_data(struct afs_call *call, void *buf, size_t count,
 	ret = rxrpc_kernel_recv_data(afs_socket, call->rxcall,
 				     buf, count, &call->offset,
 				     want_more, &call->abort_code);
+	trace_afs_recv_data(call, count, call->offset, want_more, ret);
 	if (ret == 0 || ret == -EAGAIN)
 		return ret;
 
diff --git a/include/trace/events/afs.h b/include/trace/events/afs.h
new file mode 100644
index 000000000000..845907b04ff4
--- /dev/null
+++ b/include/trace/events/afs.h
@@ -0,0 +1,109 @@
+/* AFS tracepoints
+ *
+ * Copyright (C) 2016 Red Hat, Inc. All Rights Reserved.
+ * Written by David Howells (dhowells@redhat.com)
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public Licence
+ * as published by the Free Software Foundation; either version
+ * 2 of the Licence, or (at your option) any later version.
+ */
+#undef TRACE_SYSTEM
+#define TRACE_SYSTEM afs
+
+#if !defined(_TRACE_AFS_H) || defined(TRACE_HEADER_MULTI_READ)
+#define _TRACE_AFS_H
+
+#include <linux/tracepoint.h>
+
+TRACE_EVENT(afs_recv_data,
+	    TP_PROTO(struct afs_call *call, unsigned count, unsigned offset,
+		     bool want_more, int ret),
+
+	    TP_ARGS(call, count, offset, want_more, ret),
+
+	    TP_STRUCT__entry(
+		    __field(struct rxrpc_call *,	rxcall		)
+		    __field(struct afs_call *,		call		)
+		    __field(enum afs_call_state,	state		)
+		    __field(unsigned int,		count		)
+		    __field(unsigned int,		offset		)
+		    __field(unsigned short,		unmarshall	)
+		    __field(bool,			want_more	)
+		    __field(int,			ret		)
+			     ),
+
+	    TP_fast_assign(
+		    __entry->rxcall	= call->rxcall;
+		    __entry->call	= call;
+		    __entry->state	= call->state;
+		    __entry->unmarshall	= call->unmarshall;
+		    __entry->count	= count;
+		    __entry->offset	= offset;
+		    __entry->want_more	= want_more;
+		    __entry->ret	= ret;
+			   ),
+
+	    TP_printk("c=%p ac=%p s=%u u=%u %u/%u wm=%u ret=%d",
+		      __entry->rxcall,
+		      __entry->call,
+		      __entry->state, __entry->unmarshall,
+		      __entry->offset, __entry->count,
+		      __entry->want_more, __entry->ret)
+	    );
+
+TRACE_EVENT(afs_notify_call,
+	    TP_PROTO(struct rxrpc_call *rxcall, struct afs_call *call),
+
+	    TP_ARGS(rxcall, call),
+
+	    TP_STRUCT__entry(
+		    __field(struct rxrpc_call *,	rxcall		)
+		    __field(struct afs_call *,		call		)
+		    __field(enum afs_call_state,	state		)
+		    __field(unsigned short,		unmarshall	)
+			     ),
+
+	    TP_fast_assign(
+		    __entry->rxcall	= rxcall;
+		    __entry->call	= call;
+		    __entry->state	= call->state;
+		    __entry->unmarshall	= call->unmarshall;
+			   ),
+
+	    TP_printk("c=%p ac=%p s=%u u=%u",
+		      __entry->rxcall,
+		      __entry->call,
+		      __entry->state, __entry->unmarshall)
+	    );
+
+TRACE_EVENT(afs_cb_call,
+	    TP_PROTO(struct afs_call *call),
+
+	    TP_ARGS(call),
+
+	    TP_STRUCT__entry(
+		    __field(struct rxrpc_call *,	rxcall		)
+		    __field(struct afs_call *,		call		)
+		    __field(const char *,		name		)
+		    __field(u32,			op		)
+			     ),
+
+	    TP_fast_assign(
+		    __entry->rxcall	= call->rxcall;
+		    __entry->call	= call;
+		    __entry->name	= call->type->name;
+		    __entry->op		= call->operation_ID;
+			   ),
+
+	    TP_printk("c=%p ac=%p %s o=%u",
+		      __entry->rxcall,
+		      __entry->call,
+		      __entry->name,
+		      __entry->op)
+	    );
+
+#endif /* _TRACE_AFS_H */
+
+/* This part must be outside protection */
+#include <trace/define_trace.h>
