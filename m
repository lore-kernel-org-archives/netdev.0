From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 1/5] rxrpc: Remove RXRPC_CALL_PROC_BUSY
Date: Tue, 23 Aug 2016 16:26:25 +0100
Message-ID: <147196598546.28271.9352618198978938524.stgit@warthog.procyon.org.uk>
References: <147196597852.28271.4071308846084923450.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54872 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752410AbcHWPeA (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 23 Aug 2016 11:34:00 -0400
In-Reply-To: <147196597852.28271.4071308846084923450.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove RXRPC_CALL_PROC_BUSY as work queue items are now 100% non-reentrant.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/ar-internal.h |    1 -
 net/rxrpc/call_event.c  |    6 ------
 2 files changed, 7 deletions(-)

diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index ff83fb1ddd47..3a2f4c214811 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -341,7 +341,6 @@ enum rxrpc_call_flag {
 	RXRPC_CALL_RCVD_LAST,		/* all packets received */
 	RXRPC_CALL_RUN_RTIMER,		/* Tx resend timer started */
 	RXRPC_CALL_TX_SOFT_ACK,		/* sent some soft ACKs */
-	RXRPC_CALL_PROC_BUSY,		/* the processor is busy */
 	RXRPC_CALL_INIT_ACCEPT,		/* acceptance was initiated */
 	RXRPC_CALL_HAS_USERID,		/* has a user ID attached */
 	RXRPC_CALL_EXPECT_OOS,		/* expect out of sequence packets */
diff --git a/net/rxrpc/call_event.c b/net/rxrpc/call_event.c
index e60cf65c2232..eaa8035dcb71 100644
--- a/net/rxrpc/call_event.c
+++ b/net/rxrpc/call_event.c
@@ -832,11 +832,6 @@ void rxrpc_process_call(struct work_struct *work)
 	       call->debug_id, rxrpc_call_states[call->state], call->events,
 	       (jiffies - call->creation_jif) / (HZ / 10));
 
-	if (test_and_set_bit(RXRPC_CALL_PROC_BUSY, &call->flags)) {
-		_debug("XXXXXXXXXXXXX RUNNING ON MULTIPLE CPUS XXXXXXXXXXXXX");
-		return;
-	}
-
 	if (!call->conn)
 		goto skip_msg_init;
 
@@ -1281,7 +1276,6 @@ maybe_reschedule:
 	}
 
 error:
-	clear_bit(RXRPC_CALL_PROC_BUSY, &call->flags);
 	kfree(acks);
 
 	/* because we don't want two CPUs both processing the work item for one
