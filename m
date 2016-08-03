From: David Howells <dhowells@redhat.com>
Subject: [PATCH net] rxrpc: Fix races between skb free,
 ACK generation and replying
Date: Wed, 03 Aug 2016 14:11:40 +0100
Message-ID: <147022990074.29436.7549763949462405093.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48634 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753253AbcHCNME (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Aug 2016 09:12:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Inside the kafs filesystem it is possible to occasionally have a call
processed and terminated before we've had a chance to check whether we need
to clean up the rx queue for that call because afs_send_simple_reply() ends
the call when it is done, but this is done in a workqueue item that might
happen to run to completion before afs_deliver_to_call() completes.

Further, it is possible for rxrpc_kernel_send_data() to be called to send a
reply before the last request-phase data skb is released.  The rxrpc skb
destructor is where the ACK processing is done and the call state is
advanced upon release of the last skb.  ACK generation is also deferred to
a work item because it's possible that the skb destructor is not called in
a context where kernel_sendmsg() can be invoked.

To this end, the following changes are made:

 (1) kernel_rxrpc_data_consumed() is added.  This should be called whenever
     an skb is emptied so as to crank the ACK and call states.  This does
     not release the skb, however.  kernel_rxrpc_free_skb() must now be
     called to achieve that.  These together replace
     rxrpc_kernel_data_delivered().

 (2) kernel_rxrpc_data_consumed() is wrapped by afs_data_consumed().

     This makes afs_deliver_to_call() easier to work as the skb can simply
     be discarded unconditionally here without trying to work out what the
     return value of the ->deliver() function means.

     The ->deliver() functions can, via afs_data_complete(),
     afs_transfer_reply() and afs_extract_data() mark that an skb has been
     consumed (thereby cranking the state) without the need to
     conditionally free the skb to make sure the state is correct on an
     incoming call for when the call processor tries to send the reply.

 (3) rxrpc_recvmsg() now has to call kernel_rxrpc_data_consumed() when it
     has finished with a packet and MSG_PEEK isn't set.

 (4) rxrpc_packet_destructor() no longer calls rxrpc_hard_ACK_data().

     Because of this, we no longer need to clear the destructor and put the
     call before we free the skb in cases where we don't want the ACK/call
     state to be cranked.

 (5) The ->deliver() call-type callbacks are made to return -EAGAIN rather
     than 0 if they expect more data (afs_extract_data() returns -EAGAIN to
     the delivery function already), and the caller is now responsible for
     producing an abort if that was the last packet.

 (6) There are many bits of unmarshalling code where:

 		ret = afs_extract_data(call, skb, last, ...);
		switch (ret) {
		case 0:		break;
		case -EAGAIN:	return 0;
		default:	return ret;
		}

     is to be found.  As -EAGAIN can now be passed back to the caller, we
     now just return if ret < 0:

 		ret = afs_extract_data(call, skb, last, ...);
		if (ret < 0)
			return ret;

 (7) Checks for trailing data and empty final data packets has been
     consolidated as afs_data_complete().  So:

		if (skb->len > 0)
			return -EBADMSG;
		if (!last)
			return 0;

     becomes:

		ret = afs_data_complete(call, skb, last);
		if (ret < 0)
			return ret;

 (8) afs_transfer_reply() now checks the amount of data it has against the
     amount of data desired and the amount of data in the skb and returns
     an error to induce an abort if we don't get exactly what we want.


Without these changes, the following oops can occasionally be observed,
particularly if some printks are inserted into the delivery path:

general protection fault: 0000 [#1] SMP
Modules linked in: kafs(E) af_rxrpc(E) [last unloaded: af_rxrpc]
CPU: 0 PID: 1305 Comm: kworker/u8:3 Tainted: G            E   4.7.0-fsdevel+ #1303
Hardware name: ASUS All Series/H97-PLUS, BIOS 2306 10/09/2014
Workqueue: kafsd afs_async_workfn [kafs]
task: ffff88040be041c0 ti: ffff88040c070000 task.ti: ffff88040c070000
RIP: 0010:[<ffffffff8108fd3c>]  [<ffffffff8108fd3c>] __lock_acquire+0xcf/0x15a1
RSP: 0018:ffff88040c073bc0  EFLAGS: 00010002
RAX: 6b6b6b6b6b6b6b6b RBX: 0000000000000000 RCX: ffff88040d29a710
RDX: 0000000000000000 RSI: 0000000000000000 RDI: ffff88040d29a710
RBP: ffff88040c073c70 R08: 0000000000000001 R09: 0000000000000001
R10: 0000000000000001 R11: 0000000000000000 R12: 0000000000000000
R13: 0000000000000000 R14: ffff88040be041c0 R15: ffffffff814c928f
FS:  0000000000000000(0000) GS:ffff88041fa00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00007fa4595f4750 CR3: 0000000001c14000 CR4: 00000000001406f0
Stack:
 0000000000000006 000000000be04930 0000000000000000 ffff880400000000
 ffff880400000000 ffffffff8108f847 ffff88040be041c0 ffffffff81050446
 ffff8803fc08a920 ffff8803fc08a958 ffff88040be041c0 ffff88040c073c38
Call Trace:
 [<ffffffff8108f847>] ? mark_held_locks+0x5e/0x74
 [<ffffffff81050446>] ? __local_bh_enable_ip+0x9b/0xa1
 [<ffffffff8108f9ca>] ? trace_hardirqs_on_caller+0x16d/0x189
 [<ffffffff810915f4>] lock_acquire+0x122/0x1b6
 [<ffffffff810915f4>] ? lock_acquire+0x122/0x1b6
 [<ffffffff814c928f>] ? skb_dequeue+0x18/0x61
 [<ffffffff81609dbf>] _raw_spin_lock_irqsave+0x35/0x49
 [<ffffffff814c928f>] ? skb_dequeue+0x18/0x61
 [<ffffffff814c928f>] skb_dequeue+0x18/0x61
 [<ffffffffa009aa92>] afs_deliver_to_call+0x344/0x39d [kafs]
 [<ffffffffa009ab37>] afs_process_async_call+0x4c/0xd5 [kafs]
 [<ffffffffa0099e9c>] afs_async_workfn+0xe/0x10 [kafs]
 [<ffffffff81063a3a>] process_one_work+0x29d/0x57c
 [<ffffffff81064ac2>] worker_thread+0x24a/0x385
 [<ffffffff81064878>] ? rescuer_thread+0x2d0/0x2d0
 [<ffffffff810696f5>] kthread+0xf3/0xfb
 [<ffffffff8160a6ff>] ret_from_fork+0x1f/0x40
 [<ffffffff81069602>] ? kthread_create_on_node+0x1cf/0x1cf

Signed-off-by: David Howells <dhowells@redhat.com>
---

 Documentation/networking/rxrpc.txt |   21 ++-
 fs/afs/cmservice.c                 |   78 ++++++-------
 fs/afs/fsclient.c                  |  221 ++++++++++++------------------------
 fs/afs/internal.h                  |   14 ++
 fs/afs/rxrpc.c                     |   73 +++++++-----
 fs/afs/vlclient.c                  |   11 +-
 include/net/af_rxrpc.h             |    2 
 net/rxrpc/ar-internal.h            |    1 
 net/rxrpc/call_accept.c            |    1 
 net/rxrpc/call_event.c             |    3 
 net/rxrpc/call_object.c            |    8 -
 net/rxrpc/input.c                  |   12 --
 net/rxrpc/recvmsg.c                |   25 ----
 net/rxrpc/skbuff.c                 |   41 ++++++-
 14 files changed, 225 insertions(+), 286 deletions(-)

diff --git a/Documentation/networking/rxrpc.txt b/Documentation/networking/rxrpc.txt
index 16a924c486bf..70c926ae212d 100644
--- a/Documentation/networking/rxrpc.txt
+++ b/Documentation/networking/rxrpc.txt
@@ -790,13 +790,12 @@ The kernel interface functions are as follows:
      Data messages can have their contents extracted with the usual bunch of
      socket buffer manipulation functions.  A data message can be determined to
      be the last one in a sequence with rxrpc_kernel_is_data_last().  When a
-     data message has been used up, rxrpc_kernel_data_delivered() should be
-     called on it..
+     data message has been used up, rxrpc_kernel_data_consumed() should be
+     called on it.
 
-     Non-data messages should be handled to rxrpc_kernel_free_skb() to dispose
-     of.  It is possible to get extra refs on all types of message for later
-     freeing, but this may pin the state of a call until the message is finally
-     freed.
+     Messages should be handled to rxrpc_kernel_free_skb() to dispose of.  It
+     is possible to get extra refs on all types of message for later freeing,
+     but this may pin the state of a call until the message is finally freed.
 
  (*) Accept an incoming call.
 
@@ -821,12 +820,14 @@ The kernel interface functions are as follows:
      Other errors may be returned if the call had been aborted (-ECONNABORTED)
      or had timed out (-ETIME).
 
- (*) Record the delivery of a data message and free it.
+ (*) Record the delivery of a data message.
 
-	void rxrpc_kernel_data_delivered(struct sk_buff *skb);
+	void rxrpc_kernel_data_consumed(struct rxrpc_call *call,
+					struct sk_buff *skb);
 
-     This is used to record a data message as having been delivered and to
-     update the ACK state for the call.  The socket buffer will be freed.
+     This is used to record a data message as having been consumed and to
+     update the ACK state for the call.  The message must still be passed to
+     rxrpc_kernel_free_skb() for disposal by the caller.
 
  (*) Free a message.
 
diff --git a/fs/afs/cmservice.c b/fs/afs/cmservice.c
index 4b0eff6da674..85737e96ab8b 100644
--- a/fs/afs/cmservice.c
+++ b/fs/afs/cmservice.c
@@ -189,11 +189,8 @@ static int afs_deliver_cb_callback(struct afs_call *call, struct sk_buff *skb,
 	case 1:
 		_debug("extract FID count");
 		ret = afs_extract_data(call, skb, last, &call->tmp, 4);
-		switch (ret) {
-		case 0:		break;
-		case -EAGAIN:	return 0;
-		default:	return ret;
-		}
+		if (ret < 0)
+			return ret;
 
 		call->count = ntohl(call->tmp);
 		_debug("FID count: %u", call->count);
@@ -210,11 +207,8 @@ static int afs_deliver_cb_callback(struct afs_call *call, struct sk_buff *skb,
 		_debug("extract FID array");
 		ret = afs_extract_data(call, skb, last, call->buffer,
 				       call->count * 3 * 4);
-		switch (ret) {
-		case 0:		break;
-		case -EAGAIN:	return 0;
-		default:	return ret;
-		}
+		if (ret < 0)
+			return ret;
 
 		_debug("unmarshall FID array");
 		call->request = kcalloc(call->count,
@@ -239,11 +233,8 @@ static int afs_deliver_cb_callback(struct afs_call *call, struct sk_buff *skb,
 	case 3:
 		_debug("extract CB count");
 		ret = afs_extract_data(call, skb, last, &call->tmp, 4);
-		switch (ret) {
-		case 0:		break;
-		case -EAGAIN:	return 0;
-		default:	return ret;
-		}
+		if (ret < 0)
+			return ret;
 
 		tmp = ntohl(call->tmp);
 		_debug("CB count: %u", tmp);
@@ -258,11 +249,8 @@ static int afs_deliver_cb_callback(struct afs_call *call, struct sk_buff *skb,
 		_debug("extract CB array");
 		ret = afs_extract_data(call, skb, last, call->request,
 				       call->count * 3 * 4);
-		switch (ret) {
-		case 0:		break;
-		case -EAGAIN:	return 0;
-		default:	return ret;
-		}
+		if (ret < 0)
+			return ret;
 
 		_debug("unmarshall CB array");
 		cb = call->request;
@@ -278,9 +266,9 @@ static int afs_deliver_cb_callback(struct afs_call *call, struct sk_buff *skb,
 		call->unmarshall++;
 
 	case 5:
-		_debug("trailer");
-		if (skb->len != 0)
-			return -EBADMSG;
+		ret = afs_data_complete(call, skb, last);
+		if (ret < 0)
+			return ret;
 
 		/* Record that the message was unmarshalled successfully so
 		 * that the call destructor can know do the callback breaking
@@ -294,8 +282,6 @@ static int afs_deliver_cb_callback(struct afs_call *call, struct sk_buff *skb,
 		break;
 	}
 
-	if (!last)
-		return 0;
 
 	call->state = AFS_CALL_REPLYING;
 
@@ -335,13 +321,13 @@ static int afs_deliver_cb_init_call_back_state(struct afs_call *call,
 {
 	struct afs_server *server;
 	struct in_addr addr;
+	int ret;
 
 	_enter(",{%u},%d", skb->len, last);
 
-	if (skb->len > 0)
-		return -EBADMSG;
-	if (!last)
-		return 0;
+	ret = afs_data_complete(call, skb, last);
+	if (ret < 0)
+		return ret;
 
 	/* no unmarshalling required */
 	call->state = AFS_CALL_REPLYING;
@@ -371,8 +357,10 @@ static int afs_deliver_cb_init_call_back_state3(struct afs_call *call,
 
 	_enter(",{%u},%d", skb->len, last);
 
+	/* There are some arguments that we ignore */
+	afs_data_consumed(call, skb);
 	if (!last)
-		return 0;
+		return -EAGAIN;
 
 	/* no unmarshalling required */
 	call->state = AFS_CALL_REPLYING;
@@ -408,12 +396,13 @@ static void SRXAFSCB_Probe(struct work_struct *work)
 static int afs_deliver_cb_probe(struct afs_call *call, struct sk_buff *skb,
 				bool last)
 {
+	int ret;
+
 	_enter(",{%u},%d", skb->len, last);
 
-	if (skb->len > 0)
-		return -EBADMSG;
-	if (!last)
-		return 0;
+	ret = afs_data_complete(call, skb, last);
+	if (ret < 0)
+		return ret;
 
 	/* no unmarshalling required */
 	call->state = AFS_CALL_REPLYING;
@@ -460,10 +449,9 @@ static int afs_deliver_cb_probe_uuid(struct afs_call *call, struct sk_buff *skb,
 
 	_enter("{%u},{%u},%d", call->unmarshall, skb->len, last);
 
-	if (skb->len > 0)
-		return -EBADMSG;
-	if (!last)
-		return 0;
+	ret = afs_data_complete(call, skb, last);
+	if (ret < 0)
+		return ret;
 
 	switch (call->unmarshall) {
 	case 0:
@@ -509,8 +497,9 @@ static int afs_deliver_cb_probe_uuid(struct afs_call *call, struct sk_buff *skb,
 		break;
 	}
 
-	if (!last)
-		return 0;
+	ret = afs_data_complete(call, skb, last);
+	if (ret < 0)
+		return ret;
 
 	call->state = AFS_CALL_REPLYING;
 
@@ -588,12 +577,13 @@ static void SRXAFSCB_TellMeAboutYourself(struct work_struct *work)
 static int afs_deliver_cb_tell_me_about_yourself(struct afs_call *call,
 						 struct sk_buff *skb, bool last)
 {
+	int ret;
+
 	_enter(",{%u},%d", skb->len, last);
 
-	if (skb->len > 0)
-		return -EBADMSG;
-	if (!last)
-		return 0;
+	ret = afs_data_complete(call, skb, last);
+	if (ret < 0)
+		return ret;
 
 	/* no unmarshalling required */
 	call->state = AFS_CALL_REPLYING;
diff --git a/fs/afs/fsclient.c b/fs/afs/fsclient.c
index c2e930ec2888..9312b92e54be 100644
--- a/fs/afs/fsclient.c
+++ b/fs/afs/fsclient.c
@@ -240,15 +240,13 @@ static int afs_deliver_fs_fetch_status(struct afs_call *call,
 {
 	struct afs_vnode *vnode = call->reply;
 	const __be32 *bp;
+	int ret;
 
 	_enter(",,%u", last);
 
-	afs_transfer_reply(call, skb);
-	if (!last)
-		return 0;
-
-	if (call->reply_size != call->reply_max)
-		return -EBADMSG;
+	ret = afs_transfer_reply(call, skb, last);
+	if (ret < 0)
+		return ret;
 
 	/* unmarshall the reply once we've received all of it */
 	bp = call->buffer;
@@ -335,11 +333,8 @@ static int afs_deliver_fs_fetch_data(struct afs_call *call,
 	case 1:
 		_debug("extract data length (MSW)");
 		ret = afs_extract_data(call, skb, last, &call->tmp, 4);
-		switch (ret) {
-		case 0:		break;
-		case -EAGAIN:	return 0;
-		default:	return ret;
-		}
+		if (ret < 0)
+			return ret;
 
 		call->count = ntohl(call->tmp);
 		_debug("DATA length MSW: %u", call->count);
@@ -353,11 +348,8 @@ static int afs_deliver_fs_fetch_data(struct afs_call *call,
 	case 2:
 		_debug("extract data length");
 		ret = afs_extract_data(call, skb, last, &call->tmp, 4);
-		switch (ret) {
-		case 0:		break;
-		case -EAGAIN:	return 0;
-		default:	return ret;
-		}
+		if (ret < 0)
+			return ret;
 
 		call->count = ntohl(call->tmp);
 		_debug("DATA length: %u", call->count);
@@ -375,11 +367,8 @@ static int afs_deliver_fs_fetch_data(struct afs_call *call,
 			ret = afs_extract_data(call, skb, last, buffer,
 					       call->count);
 			kunmap_atomic(buffer);
-			switch (ret) {
-			case 0:		break;
-			case -EAGAIN:	return 0;
-			default:	return ret;
-			}
+			if (ret < 0)
+				return ret;
 		}
 
 		call->offset = 0;
@@ -389,11 +378,8 @@ static int afs_deliver_fs_fetch_data(struct afs_call *call,
 	case 4:
 		ret = afs_extract_data(call, skb, last, call->buffer,
 				       (21 + 3 + 6) * 4);
-		switch (ret) {
-		case 0:		break;
-		case -EAGAIN:	return 0;
-		default:	return ret;
-		}
+		if (ret < 0)
+			return ret;
 
 		bp = call->buffer;
 		xdr_decode_AFSFetchStatus(&bp, &vnode->status, vnode, NULL);
@@ -405,15 +391,12 @@ static int afs_deliver_fs_fetch_data(struct afs_call *call,
 		call->unmarshall++;
 
 	case 5:
-		_debug("trailer");
-		if (skb->len != 0)
-			return -EBADMSG;
+		ret = afs_data_complete(call, skb, last);
+		if (ret < 0)
+			return ret;
 		break;
 	}
 
-	if (!last)
-		return 0;
-
 	if (call->count < PAGE_SIZE) {
 		_debug("clear");
 		page = call->reply3;
@@ -537,9 +520,8 @@ static int afs_deliver_fs_give_up_callbacks(struct afs_call *call,
 {
 	_enter(",{%u},%d", skb->len, last);
 
-	if (skb->len > 0)
-		return -EBADMSG; /* shouldn't be any reply data */
-	return 0;
+	/* shouldn't be any reply data */
+	return afs_data_complete(call, skb, last);
 }
 
 /*
@@ -622,15 +604,13 @@ static int afs_deliver_fs_create_vnode(struct afs_call *call,
 {
 	struct afs_vnode *vnode = call->reply;
 	const __be32 *bp;
+	int ret;
 
 	_enter("{%u},{%u},%d", call->unmarshall, skb->len, last);
 
-	afs_transfer_reply(call, skb);
-	if (!last)
-		return 0;
-
-	if (call->reply_size != call->reply_max)
-		return -EBADMSG;
+	ret = afs_transfer_reply(call, skb, last);
+	if (ret < 0)
+		return ret;
 
 	/* unmarshall the reply once we've received all of it */
 	bp = call->buffer;
@@ -721,15 +701,13 @@ static int afs_deliver_fs_remove(struct afs_call *call,
 {
 	struct afs_vnode *vnode = call->reply;
 	const __be32 *bp;
+	int ret;
 
 	_enter("{%u},{%u},%d", call->unmarshall, skb->len, last);
 
-	afs_transfer_reply(call, skb);
-	if (!last)
-		return 0;
-
-	if (call->reply_size != call->reply_max)
-		return -EBADMSG;
+	ret = afs_transfer_reply(call, skb, last);
+	if (ret < 0)
+		return ret;
 
 	/* unmarshall the reply once we've received all of it */
 	bp = call->buffer;
@@ -804,15 +782,13 @@ static int afs_deliver_fs_link(struct afs_call *call,
 {
 	struct afs_vnode *dvnode = call->reply, *vnode = call->reply2;
 	const __be32 *bp;
+	int ret;
 
 	_enter("{%u},{%u},%d", call->unmarshall, skb->len, last);
 
-	afs_transfer_reply(call, skb);
-	if (!last)
-		return 0;
-
-	if (call->reply_size != call->reply_max)
-		return -EBADMSG;
+	ret = afs_transfer_reply(call, skb, last);
+	if (ret < 0)
+		return ret;
 
 	/* unmarshall the reply once we've received all of it */
 	bp = call->buffer;
@@ -892,15 +868,13 @@ static int afs_deliver_fs_symlink(struct afs_call *call,
 {
 	struct afs_vnode *vnode = call->reply;
 	const __be32 *bp;
+	int ret;
 
 	_enter("{%u},{%u},%d", call->unmarshall, skb->len, last);
 
-	afs_transfer_reply(call, skb);
-	if (!last)
-		return 0;
-
-	if (call->reply_size != call->reply_max)
-		return -EBADMSG;
+	ret = afs_transfer_reply(call, skb, last);
+	if (ret < 0)
+		return ret;
 
 	/* unmarshall the reply once we've received all of it */
 	bp = call->buffer;
@@ -999,15 +973,13 @@ static int afs_deliver_fs_rename(struct afs_call *call,
 {
 	struct afs_vnode *orig_dvnode = call->reply, *new_dvnode = call->reply2;
 	const __be32 *bp;
+	int ret;
 
 	_enter("{%u},{%u},%d", call->unmarshall, skb->len, last);
 
-	afs_transfer_reply(call, skb);
-	if (!last)
-		return 0;
-
-	if (call->reply_size != call->reply_max)
-		return -EBADMSG;
+	ret = afs_transfer_reply(call, skb, last);
+	if (ret < 0)
+		return ret;
 
 	/* unmarshall the reply once we've received all of it */
 	bp = call->buffer;
@@ -1105,20 +1077,13 @@ static int afs_deliver_fs_store_data(struct afs_call *call,
 {
 	struct afs_vnode *vnode = call->reply;
 	const __be32 *bp;
+	int ret;
 
 	_enter(",,%u", last);
 
-	afs_transfer_reply(call, skb);
-	if (!last) {
-		_leave(" = 0 [more]");
-		return 0;
-	}
-
-	if (call->reply_size != call->reply_max) {
-		_leave(" = -EBADMSG [%u != %u]",
-		       call->reply_size, call->reply_max);
-		return -EBADMSG;
-	}
+	ret = afs_transfer_reply(call, skb, last);
+	if (ret < 0)
+		return ret;
 
 	/* unmarshall the reply once we've received all of it */
 	bp = call->buffer;
@@ -1292,20 +1257,13 @@ static int afs_deliver_fs_store_status(struct afs_call *call,
 	afs_dataversion_t *store_version;
 	struct afs_vnode *vnode = call->reply;
 	const __be32 *bp;
+	int ret;
 
 	_enter(",,%u", last);
 
-	afs_transfer_reply(call, skb);
-	if (!last) {
-		_leave(" = 0 [more]");
-		return 0;
-	}
-
-	if (call->reply_size != call->reply_max) {
-		_leave(" = -EBADMSG [%u != %u]",
-		       call->reply_size, call->reply_max);
-		return -EBADMSG;
-	}
+	ret = afs_transfer_reply(call, skb, last);
+	if (ret < 0)
+		return ret;
 
 	/* unmarshall the reply once we've received all of it */
 	store_version = NULL;
@@ -1504,11 +1462,8 @@ static int afs_deliver_fs_get_volume_status(struct afs_call *call,
 		_debug("extract status");
 		ret = afs_extract_data(call, skb, last, call->buffer,
 				       12 * 4);
-		switch (ret) {
-		case 0:		break;
-		case -EAGAIN:	return 0;
-		default:	return ret;
-		}
+		if (ret < 0)
+			return ret;
 
 		bp = call->buffer;
 		xdr_decode_AFSFetchVolumeStatus(&bp, call->reply2);
@@ -1518,11 +1473,8 @@ static int afs_deliver_fs_get_volume_status(struct afs_call *call,
 		/* extract the volume name length */
 	case 2:
 		ret = afs_extract_data(call, skb, last, &call->tmp, 4);
-		switch (ret) {
-		case 0:		break;
-		case -EAGAIN:	return 0;
-		default:	return ret;
-		}
+		if (ret < 0)
+			return ret;
 
 		call->count = ntohl(call->tmp);
 		_debug("volname length: %u", call->count);
@@ -1537,11 +1489,8 @@ static int afs_deliver_fs_get_volume_status(struct afs_call *call,
 		if (call->count > 0) {
 			ret = afs_extract_data(call, skb, last, call->reply3,
 					       call->count);
-			switch (ret) {
-			case 0:		break;
-			case -EAGAIN:	return 0;
-			default:	return ret;
-			}
+			if (ret < 0)
+				return ret;
 		}
 
 		p = call->reply3;
@@ -1561,11 +1510,8 @@ static int afs_deliver_fs_get_volume_status(struct afs_call *call,
 	case 4:
 		ret = afs_extract_data(call, skb, last, call->buffer,
 				       call->count);
-		switch (ret) {
-		case 0:		break;
-		case -EAGAIN:	return 0;
-		default:	return ret;
-		}
+		if (ret < 0)
+			return ret;
 
 		call->offset = 0;
 		call->unmarshall++;
@@ -1574,11 +1520,8 @@ static int afs_deliver_fs_get_volume_status(struct afs_call *call,
 		/* extract the offline message length */
 	case 5:
 		ret = afs_extract_data(call, skb, last, &call->tmp, 4);
-		switch (ret) {
-		case 0:		break;
-		case -EAGAIN:	return 0;
-		default:	return ret;
-		}
+		if (ret < 0)
+			return ret;
 
 		call->count = ntohl(call->tmp);
 		_debug("offline msg length: %u", call->count);
@@ -1593,11 +1536,8 @@ static int afs_deliver_fs_get_volume_status(struct afs_call *call,
 		if (call->count > 0) {
 			ret = afs_extract_data(call, skb, last, call->reply3,
 					       call->count);
-			switch (ret) {
-			case 0:		break;
-			case -EAGAIN:	return 0;
-			default:	return ret;
-			}
+			if (ret < 0)
+				return ret;
 		}
 
 		p = call->reply3;
@@ -1617,11 +1557,8 @@ static int afs_deliver_fs_get_volume_status(struct afs_call *call,
 	case 7:
 		ret = afs_extract_data(call, skb, last, call->buffer,
 				       call->count);
-		switch (ret) {
-		case 0:		break;
-		case -EAGAIN:	return 0;
-		default:	return ret;
-		}
+		if (ret < 0)
+			return ret;
 
 		call->offset = 0;
 		call->unmarshall++;
@@ -1630,11 +1567,8 @@ static int afs_deliver_fs_get_volume_status(struct afs_call *call,
 		/* extract the message of the day length */
 	case 8:
 		ret = afs_extract_data(call, skb, last, &call->tmp, 4);
-		switch (ret) {
-		case 0:		break;
-		case -EAGAIN:	return 0;
-		default:	return ret;
-		}
+		if (ret < 0)
+			return ret;
 
 		call->count = ntohl(call->tmp);
 		_debug("motd length: %u", call->count);
@@ -1649,11 +1583,8 @@ static int afs_deliver_fs_get_volume_status(struct afs_call *call,
 		if (call->count > 0) {
 			ret = afs_extract_data(call, skb, last, call->reply3,
 					       call->count);
-			switch (ret) {
-			case 0:		break;
-			case -EAGAIN:	return 0;
-			default:	return ret;
-			}
+			if (ret < 0)
+				return ret;
 		}
 
 		p = call->reply3;
@@ -1673,26 +1604,20 @@ static int afs_deliver_fs_get_volume_status(struct afs_call *call,
 	case 10:
 		ret = afs_extract_data(call, skb, last, call->buffer,
 				       call->count);
-		switch (ret) {
-		case 0:		break;
-		case -EAGAIN:	return 0;
-		default:	return ret;
-		}
+		if (ret < 0)
+			return ret;
 
 		call->offset = 0;
 		call->unmarshall++;
 	no_motd_padding:
 
 	case 11:
-		_debug("trailer %d", skb->len);
-		if (skb->len != 0)
-			return -EBADMSG;
+		ret = afs_data_complete(call, skb, last);
+		if (ret < 0)
+			return ret;
 		break;
 	}
 
-	if (!last)
-		return 0;
-
 	_leave(" = 0 [done]");
 	return 0;
 }
@@ -1764,15 +1689,13 @@ static int afs_deliver_fs_xxxx_lock(struct afs_call *call,
 				    struct sk_buff *skb, bool last)
 {
 	const __be32 *bp;
+	int ret;
 
 	_enter("{%u},{%u},%d", call->unmarshall, skb->len, last);
 
-	afs_transfer_reply(call, skb);
-	if (!last)
-		return 0;
-
-	if (call->reply_size != call->reply_max)
-		return -EBADMSG;
+	ret = afs_transfer_reply(call, skb, last);
+	if (ret < 0)
+		return ret;
 
 	/* unmarshall the reply once we've received all of it */
 	bp = call->buffer;
diff --git a/fs/afs/internal.h b/fs/afs/internal.h
index 71d5982312f3..df976b2a7f40 100644
--- a/fs/afs/internal.h
+++ b/fs/afs/internal.h
@@ -609,17 +609,29 @@ extern void afs_proc_cell_remove(struct afs_cell *);
  */
 extern int afs_open_socket(void);
 extern void afs_close_socket(void);
+extern void afs_data_consumed(struct afs_call *, struct sk_buff *);
 extern int afs_make_call(struct in_addr *, struct afs_call *, gfp_t,
 			 const struct afs_wait_mode *);
 extern struct afs_call *afs_alloc_flat_call(const struct afs_call_type *,
 					    size_t, size_t);
 extern void afs_flat_call_destructor(struct afs_call *);
-extern void afs_transfer_reply(struct afs_call *, struct sk_buff *);
+extern int afs_transfer_reply(struct afs_call *, struct sk_buff *, bool);
 extern void afs_send_empty_reply(struct afs_call *);
 extern void afs_send_simple_reply(struct afs_call *, const void *, size_t);
 extern int afs_extract_data(struct afs_call *, struct sk_buff *, bool, void *,
 			    size_t);
 
+static inline int afs_data_complete(struct afs_call *call, struct sk_buff *skb,
+				    bool last)
+{
+	if (skb->len > 0)
+		return -EBADMSG;
+	afs_data_consumed(call, skb);
+	if (!last)
+		return -EAGAIN;
+	return 0;
+}
+
 /*
  * security.c
  */
diff --git a/fs/afs/rxrpc.c b/fs/afs/rxrpc.c
index 4832de84d52c..14d04c848465 100644
--- a/fs/afs/rxrpc.c
+++ b/fs/afs/rxrpc.c
@@ -150,10 +150,9 @@ void afs_close_socket(void)
 }
 
 /*
- * note that the data in a socket buffer is now delivered and that the buffer
- * should be freed
+ * Note that the data in a socket buffer is now consumed.
  */
-static void afs_data_delivered(struct sk_buff *skb)
+void afs_data_consumed(struct afs_call *call, struct sk_buff *skb)
 {
 	if (!skb) {
 		_debug("DLVR NULL [%d]", atomic_read(&afs_outstanding_skbs));
@@ -161,9 +160,7 @@ static void afs_data_delivered(struct sk_buff *skb)
 	} else {
 		_debug("DLVR %p{%u} [%d]",
 		       skb, skb->mark, atomic_read(&afs_outstanding_skbs));
-		if (atomic_dec_return(&afs_outstanding_skbs) == -1)
-			BUG();
-		rxrpc_kernel_data_delivered(skb);
+		rxrpc_kernel_data_consumed(call->rxcall, skb);
 	}
 }
 
@@ -489,9 +486,15 @@ static void afs_deliver_to_call(struct afs_call *call)
 			last = rxrpc_kernel_is_data_last(skb);
 			ret = call->type->deliver(call, skb, last);
 			switch (ret) {
+			case -EAGAIN:
+				if (last) {
+					_debug("short data");
+					goto unmarshal_error;
+				}
+				break;
 			case 0:
-				if (last &&
-				    call->state == AFS_CALL_AWAIT_REPLY)
+				ASSERT(last);
+				if (call->state == AFS_CALL_AWAIT_REPLY)
 					call->state = AFS_CALL_COMPLETE;
 				break;
 			case -ENOTCONN:
@@ -501,6 +504,7 @@ static void afs_deliver_to_call(struct afs_call *call)
 				abort_code = RX_INVALID_OPERATION;
 				goto do_abort;
 			default:
+			unmarshal_error:
 				abort_code = RXGEN_CC_UNMARSHAL;
 				if (call->state != AFS_CALL_AWAIT_REPLY)
 					abort_code = RXGEN_SS_UNMARSHAL;
@@ -511,9 +515,7 @@ static void afs_deliver_to_call(struct afs_call *call)
 				call->state = AFS_CALL_ERROR;
 				break;
 			}
-			afs_data_delivered(skb);
-			skb = NULL;
-			continue;
+			break;
 		case RXRPC_SKB_MARK_FINAL_ACK:
 			_debug("Rcv ACK");
 			call->state = AFS_CALL_COMPLETE;
@@ -685,15 +687,35 @@ static void afs_process_async_call(struct afs_call *call)
 }
 
 /*
- * empty a socket buffer into a flat reply buffer
+ * Empty a socket buffer into a flat reply buffer.
  */
-void afs_transfer_reply(struct afs_call *call, struct sk_buff *skb)
+int afs_transfer_reply(struct afs_call *call, struct sk_buff *skb, bool last)
 {
 	size_t len = skb->len;
 
-	if (skb_copy_bits(skb, 0, call->buffer + call->reply_size, len) < 0)
-		BUG();
-	call->reply_size += len;
+	if (len > call->reply_max - call->reply_size) {
+		_leave(" = -EBADMSG [%zu > %u]",
+		       len, call->reply_max - call->reply_size);
+		return -EBADMSG;
+	}
+
+	if (len > 0) {
+		if (skb_copy_bits(skb, 0, call->buffer + call->reply_size,
+				  len) < 0)
+			BUG();
+		call->reply_size += len;
+	}
+
+	afs_data_consumed(call, skb);
+	if (!last)
+		return -EAGAIN;
+
+	if (call->reply_size != call->reply_max) {
+		_leave(" = -EBADMSG [%u != %u]",
+		       call->reply_size, call->reply_max);
+		return -EBADMSG;
+	}
+	return 0;
 }
 
 /*
@@ -745,7 +767,8 @@ static void afs_collect_incoming_call(struct work_struct *work)
 }
 
 /*
- * grab the operation ID from an incoming cache manager call
+ * Grab the operation ID from an incoming cache manager call.  The socket
+ * buffer is discarded on error or if we don't yet have sufficient data.
  */
 static int afs_deliver_cm_op_id(struct afs_call *call, struct sk_buff *skb,
 				bool last)
@@ -766,12 +789,9 @@ static int afs_deliver_cm_op_id(struct afs_call *call, struct sk_buff *skb,
 	call->offset += len;
 
 	if (call->offset < 4) {
-		if (last) {
-			_leave(" = -EBADMSG [op ID short]");
-			return -EBADMSG;
-		}
-		_leave(" = 0 [incomplete]");
-		return 0;
+		afs_data_consumed(call, skb);
+		_leave(" = -EAGAIN");
+		return -EAGAIN;
 	}
 
 	call->state = AFS_CALL_AWAIT_REQUEST;
@@ -855,7 +875,7 @@ void afs_send_simple_reply(struct afs_call *call, const void *buf, size_t len)
 }
 
 /*
- * extract a piece of data from the received data socket buffers
+ * Extract a piece of data from the received data socket buffers.
  */
 int afs_extract_data(struct afs_call *call, struct sk_buff *skb,
 		     bool last, void *buf, size_t count)
@@ -873,10 +893,7 @@ int afs_extract_data(struct afs_call *call, struct sk_buff *skb,
 	call->offset += len;
 
 	if (call->offset < count) {
-		if (last) {
-			_leave(" = -EBADMSG [%d < %zu]", call->offset, count);
-			return -EBADMSG;
-		}
+		afs_data_consumed(call, skb);
 		_leave(" = -EAGAIN");
 		return -EAGAIN;
 	}
diff --git a/fs/afs/vlclient.c b/fs/afs/vlclient.c
index 340afd0cd182..f94d1abdc3eb 100644
--- a/fs/afs/vlclient.c
+++ b/fs/afs/vlclient.c
@@ -64,16 +64,13 @@ static int afs_deliver_vl_get_entry_by_xxx(struct afs_call *call,
 	struct afs_cache_vlocation *entry;
 	__be32 *bp;
 	u32 tmp;
-	int loop;
+	int loop, ret;
 
 	_enter(",,%u", last);
 
-	afs_transfer_reply(call, skb);
-	if (!last)
-		return 0;
-
-	if (call->reply_size != call->reply_max)
-		return -EBADMSG;
+	ret = afs_transfer_reply(call, skb, last);
+	if (ret < 0)
+		return ret;
 
 	/* unmarshall the reply once we've received all of it */
 	entry = call->reply;
diff --git a/include/net/af_rxrpc.h b/include/net/af_rxrpc.h
index ac1bc3c49fbd..7b0f88699b25 100644
--- a/include/net/af_rxrpc.h
+++ b/include/net/af_rxrpc.h
@@ -40,12 +40,12 @@ struct rxrpc_call *rxrpc_kernel_begin_call(struct socket *,
 					   unsigned long,
 					   gfp_t);
 int rxrpc_kernel_send_data(struct rxrpc_call *, struct msghdr *, size_t);
+void rxrpc_kernel_data_consumed(struct rxrpc_call *, struct sk_buff *);
 void rxrpc_kernel_abort_call(struct rxrpc_call *, u32);
 void rxrpc_kernel_end_call(struct rxrpc_call *);
 bool rxrpc_kernel_is_data_last(struct sk_buff *);
 u32 rxrpc_kernel_get_abort_code(struct sk_buff *);
 int rxrpc_kernel_get_error_number(struct sk_buff *);
-void rxrpc_kernel_data_delivered(struct sk_buff *);
 void rxrpc_kernel_free_skb(struct sk_buff *);
 struct rxrpc_call *rxrpc_kernel_accept_call(struct socket *, unsigned long);
 int rxrpc_kernel_reject_call(struct socket *);
diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index 1bb9e7ac9e14..ff83fb1ddd47 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -425,6 +425,7 @@ struct rxrpc_call {
 	spinlock_t		lock;
 	rwlock_t		state_lock;	/* lock for state transition */
 	atomic_t		usage;
+	atomic_t		skb_count;	/* Outstanding packets on this call */
 	atomic_t		sequence;	/* Tx data packet sequence counter */
 	u32			local_abort;	/* local abort code */
 	u32			remote_abort;	/* remote abort code */
diff --git a/net/rxrpc/call_accept.c b/net/rxrpc/call_accept.c
index 0b2832141bd0..9bae21e66d65 100644
--- a/net/rxrpc/call_accept.c
+++ b/net/rxrpc/call_accept.c
@@ -130,6 +130,7 @@ static int rxrpc_accept_incoming_call(struct rxrpc_local *local,
 			call->state = RXRPC_CALL_SERVER_ACCEPTING;
 			list_add_tail(&call->accept_link, &rx->acceptq);
 			rxrpc_get_call(call);
+			atomic_inc(&call->skb_count);
 			nsp = rxrpc_skb(notification);
 			nsp->call = call;
 
diff --git a/net/rxrpc/call_event.c b/net/rxrpc/call_event.c
index fc32aa5764a2..f5e99163a09e 100644
--- a/net/rxrpc/call_event.c
+++ b/net/rxrpc/call_event.c
@@ -460,6 +460,7 @@ static void rxrpc_insert_oos_packet(struct rxrpc_call *call,
 	ASSERTCMP(sp->call, ==, NULL);
 	sp->call = call;
 	rxrpc_get_call(call);
+	atomic_inc(&call->skb_count);
 
 	/* insert into the buffer in sequence order */
 	spin_lock_bh(&call->lock);
@@ -734,6 +735,7 @@ all_acked:
 		skb->mark = RXRPC_SKB_MARK_FINAL_ACK;
 		sp->call = call;
 		rxrpc_get_call(call);
+		atomic_inc(&call->skb_count);
 		spin_lock_bh(&call->lock);
 		if (rxrpc_queue_rcv_skb(call, skb, true, true) < 0)
 			BUG();
@@ -793,6 +795,7 @@ static int rxrpc_post_message(struct rxrpc_call *call, u32 mark, u32 error,
 		sp->error = error;
 		sp->call = call;
 		rxrpc_get_call(call);
+		atomic_inc(&call->skb_count);
 
 		spin_lock_bh(&call->lock);
 		ret = rxrpc_queue_rcv_skb(call, skb, true, fatal);
diff --git a/net/rxrpc/call_object.c b/net/rxrpc/call_object.c
index 91287c9d01bb..c47f14fc5e88 100644
--- a/net/rxrpc/call_object.c
+++ b/net/rxrpc/call_object.c
@@ -491,13 +491,6 @@ void rxrpc_release_call(struct rxrpc_call *call)
 		spin_lock_bh(&call->lock);
 		while ((skb = skb_dequeue(&call->rx_queue)) ||
 		       (skb = skb_dequeue(&call->rx_oos_queue))) {
-			sp = rxrpc_skb(skb);
-			if (sp->call) {
-				ASSERTCMP(sp->call, ==, call);
-				rxrpc_put_call(call);
-				sp->call = NULL;
-			}
-			skb->destructor = NULL;
 			spin_unlock_bh(&call->lock);
 
 			_debug("- zap %s %%%u #%u",
@@ -605,6 +598,7 @@ void __rxrpc_put_call(struct rxrpc_call *call)
 
 	if (atomic_dec_and_test(&call->usage)) {
 		_debug("call %d dead", call->debug_id);
+		WARN_ON(atomic_read(&call->skb_count) != 0);
 		ASSERTCMP(call->state, ==, RXRPC_CALL_DEAD);
 		rxrpc_queue_work(&call->destroyer);
 	}
diff --git a/net/rxrpc/input.c b/net/rxrpc/input.c
index 991a20d25093..9e0f58edcd01 100644
--- a/net/rxrpc/input.c
+++ b/net/rxrpc/input.c
@@ -55,9 +55,6 @@ int rxrpc_queue_rcv_skb(struct rxrpc_call *call, struct sk_buff *skb,
 	if (test_bit(RXRPC_CALL_TERMINAL_MSG, &call->flags)) {
 		_debug("already terminated");
 		ASSERTCMP(call->state, >=, RXRPC_CALL_COMPLETE);
-		skb->destructor = NULL;
-		sp->call = NULL;
-		rxrpc_put_call(call);
 		rxrpc_free_skb(skb);
 		return 0;
 	}
@@ -111,13 +108,7 @@ int rxrpc_queue_rcv_skb(struct rxrpc_call *call, struct sk_buff *skb,
 	ret = 0;
 
 out:
-	/* release the socket buffer */
-	if (skb) {
-		skb->destructor = NULL;
-		sp->call = NULL;
-		rxrpc_put_call(call);
-		rxrpc_free_skb(skb);
-	}
+	rxrpc_free_skb(skb);
 
 	_leave(" = %d", ret);
 	return ret;
@@ -200,6 +191,7 @@ static int rxrpc_fast_process_data(struct rxrpc_call *call,
 
 	sp->call = call;
 	rxrpc_get_call(call);
+	atomic_inc(&call->skb_count);
 	terminal = ((sp->hdr.flags & RXRPC_LAST_PACKET) &&
 		    !(sp->hdr.flags & RXRPC_CLIENT_INITIATED));
 	ret = rxrpc_queue_rcv_skb(call, skb, false, terminal);
diff --git a/net/rxrpc/recvmsg.c b/net/rxrpc/recvmsg.c
index a3fa2ed85d63..9ed66d533002 100644
--- a/net/rxrpc/recvmsg.c
+++ b/net/rxrpc/recvmsg.c
@@ -203,6 +203,9 @@ int rxrpc_recvmsg(struct socket *sock, struct msghdr *msg, size_t len,
 		}
 
 		/* we transferred the whole data packet */
+		if (!(flags & MSG_PEEK))
+			rxrpc_kernel_data_consumed(call, skb);
+
 		if (sp->hdr.flags & RXRPC_LAST_PACKET) {
 			_debug("last");
 			if (rxrpc_conn_is_client(call->conn)) {
@@ -360,28 +363,6 @@ wait_error:
 }
 
 /**
- * rxrpc_kernel_data_delivered - Record delivery of data message
- * @skb: Message holding data
- *
- * Record the delivery of a data message.  This permits RxRPC to keep its
- * tracking correct.  The socket buffer will be deleted.
- */
-void rxrpc_kernel_data_delivered(struct sk_buff *skb)
-{
-	struct rxrpc_skb_priv *sp = rxrpc_skb(skb);
-	struct rxrpc_call *call = sp->call;
-
-	ASSERTCMP(sp->hdr.seq, >=, call->rx_data_recv);
-	ASSERTCMP(sp->hdr.seq, <=, call->rx_data_recv + 1);
-	call->rx_data_recv = sp->hdr.seq;
-
-	ASSERTCMP(sp->hdr.seq, >, call->rx_data_eaten);
-	rxrpc_free_skb(skb);
-}
-
-EXPORT_SYMBOL(rxrpc_kernel_data_delivered);
-
-/**
  * rxrpc_kernel_is_data_last - Determine if data message is last one
  * @skb: Message holding data
  *
diff --git a/net/rxrpc/skbuff.c b/net/rxrpc/skbuff.c
index eee0cfd9ac8c..06c51d4b622d 100644
--- a/net/rxrpc/skbuff.c
+++ b/net/rxrpc/skbuff.c
@@ -98,11 +98,39 @@ static void rxrpc_hard_ACK_data(struct rxrpc_call *call,
 	spin_unlock_bh(&call->lock);
 }
 
+/**
+ * rxrpc_kernel_data_consumed - Record consumption of data message
+ * @call: The call to which the message pertains.
+ * @skb: Message holding data
+ *
+ * Record the consumption of a data message and generate an ACK if appropriate.
+ * The call state is shifted if this was the final packet.  The caller must be
+ * in process context with no spinlocks held.
+ *
+ * TODO: Actually generate the ACK here rather than punting this to the
+ * workqueue.
+ */
+void rxrpc_kernel_data_consumed(struct rxrpc_call *call, struct sk_buff *skb)
+{
+	struct rxrpc_skb_priv *sp = rxrpc_skb(skb);
+
+	_enter("%d,%p{%u}", call->debug_id, skb, sp->hdr.seq);
+
+	ASSERTCMP(sp->call, ==, call);
+	ASSERTCMP(sp->hdr.type, ==, RXRPC_PACKET_TYPE_DATA);
+
+	/* TODO: Fix the sequence number tracking */
+	ASSERTCMP(sp->hdr.seq, >=, call->rx_data_recv);
+	ASSERTCMP(sp->hdr.seq, <=, call->rx_data_recv + 1);
+	ASSERTCMP(sp->hdr.seq, >, call->rx_data_eaten);
+
+	call->rx_data_recv = sp->hdr.seq;
+	rxrpc_hard_ACK_data(call, sp);
+}
+EXPORT_SYMBOL(rxrpc_kernel_data_consumed);
+
 /*
- * destroy a packet that has an RxRPC control buffer
- * - advance the hard-ACK state of the parent call (done here in case something
- *   in the kernel bypasses recvmsg() and steals the packet directly off of the
- *   socket receive queue)
+ * Destroy a packet that has an RxRPC control buffer
  */
 void rxrpc_packet_destructor(struct sk_buff *skb)
 {
@@ -112,9 +140,8 @@ void rxrpc_packet_destructor(struct sk_buff *skb)
 	_enter("%p{%p}", skb, call);
 
 	if (call) {
-		/* send the final ACK on a client call */
-		if (sp->hdr.type == RXRPC_PACKET_TYPE_DATA)
-			rxrpc_hard_ACK_data(call, sp);
+		if (atomic_dec_return(&call->skb_count) < 0)
+			BUG();
 		rxrpc_put_call(call);
 		sp->call = NULL;
 	}
