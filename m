From: Michael Ellerman <michael@ellerman.id.au>
Subject: [PATCH 4/12] iseries_veth: Remove a FIXME WRT deletion of the ack_timer
Date: Thu, 30 Jun 2005 20:20:39 +1000
Message-ID: <1120126839.355585.362623134076.qpatch__42473.2059277177$1120126797$gmane$org@concordia>
References: <200506302016.55125.michael@ellerman.id.au>
Return-path: <netdev-bounce@oss.sgi.com>
To: linuxppc64-dev@ozlabs.org, netdev@oss.sgi.com,
        linux-kernel@vger.kernel.org
In-Reply-To: <200506302016.55125.michael@ellerman.id.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The iseries_veth driver has a timer which we use to send acks. When the
connection is reset or stopped we need to delete the timer.

Currently we only call del_timer() when resetting a connection, which means
the timer might run again while the connection is being re-setup. As it turns
out that's ok, because the flags the timer consults have been reset.

It's cleaner though to call del_timer_sync() once we've dropped the lock,
although the timer may still run between us dropping the lock and calling
del_timer_sync(), but as above that's ok.


---

 drivers/net/iseries_veth.c |   21 +++++++++++++--------
 1 files changed, 13 insertions(+), 8 deletions(-)

Index: veth-dev/drivers/net/iseries_veth.c
===================================================================
--- veth-dev.orig/drivers/net/iseries_veth.c
+++ veth-dev/drivers/net/iseries_veth.c
@@ -450,13 +450,15 @@ static void veth_statemachine(void *p)
 	if (cnx->state & VETH_STATE_RESET) {
 		int i;
 
-		del_timer(&cnx->ack_timer);
-
 		if (cnx->state & VETH_STATE_OPEN)
 			HvCallEvent_closeLpEventPath(cnx->remote_lp,
 						     HvLpEvent_Type_VirtualLan);
 
-		/* reset ack data */
+		/*
+		 * Reset ack data. This prevents the ack_timer actually
+		 * doing anything, even if it runs one more time when
+		 * we drop the lock below.
+		 */
 		memset(&cnx->pending_acks, 0xff, sizeof (cnx->pending_acks));
 		cnx->num_pending_acks = 0;
 
@@ -469,9 +471,16 @@ static void veth_statemachine(void *p)
 		if (cnx->msgs)
 			for (i = 0; i < VETH_NUMBUFFERS; ++i)
 				veth_recycle_msg(cnx, cnx->msgs + i);
+
+		/* Drop the lock so we can do stuff that might sleep or
+		 * take other locks. */
 		spin_unlock_irq(&cnx->lock);
+
+		del_timer_sync(&cnx->ack_timer);
 		veth_flush_pending(cnx);
+
 		spin_lock_irq(&cnx->lock);
+
 		if (cnx->state & VETH_STATE_RESET)
 			goto restart;
 	}
@@ -658,12 +667,8 @@ static void veth_stop_connection(u8 rlp)
 	veth_kick_statemachine(cnx);
 	spin_unlock_irq(&cnx->lock);
 
+	/* Wait for the state machine to run. */
 	flush_scheduled_work();
-
-	/* FIXME: not sure if this is necessary - will already have
-	 * been deleted by the state machine, just want to make sure
-	 * its not running any more */
-	del_timer_sync(&cnx->ack_timer);
 }
 
 static void veth_destroy_connection(u8 rlp)
