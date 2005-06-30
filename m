From: Michael Ellerman <michael@ellerman.id.au>
Subject: [PATCH 7/12] iseries_veth: Remove redundant message stack lock
Date: Thu, 30 Jun 2005 20:20:39 +1000
Message-ID: <1120126839.569702.406803544780.qpatch__48074.6975438253$1120126809$gmane$org@concordia>
References: <200506302016.55125.michael@ellerman.id.au>
Return-path: <netdev-bounce@oss.sgi.com>
To: linuxppc64-dev@ozlabs.org, netdev@oss.sgi.com,
        linux-kernel@vger.kernel.org
In-Reply-To: <200506302016.55125.michael@ellerman.id.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The iseries_veth driver keeps a stack of messages for each connection
and a lock to protect the stack. However there is also a per-connection lock
which makes the message stack redundant.

Remove the message stack lock and document the fact that callers of the
stack-manipulation functions must hold the connection's lock.


---

 drivers/net/iseries_veth.c |   12 +++---------
 1 files changed, 3 insertions(+), 9 deletions(-)

Index: veth-dev/drivers/net/iseries_veth.c
===================================================================
--- veth-dev.orig/drivers/net/iseries_veth.c
+++ veth-dev/drivers/net/iseries_veth.c
@@ -143,7 +143,6 @@ struct veth_lpar_connection {
 	struct VethCapData remote_caps;
 	u32 ack_timeout;
 
-	spinlock_t msg_stack_lock;
 	struct veth_msg *msg_stack_head;
 };
 
@@ -190,27 +189,23 @@ static void veth_timed_ack(unsigned long
 #define veth_debug(fmt, args...) do {} while (0)
 #endif
 
+/* You must hold the connection's lock when you call this function. */
 static inline void veth_stack_push(struct veth_lpar_connection *cnx,
 				   struct veth_msg *msg)
 {
-	unsigned long flags;
-
-	spin_lock_irqsave(&cnx->msg_stack_lock, flags);
 	msg->next = cnx->msg_stack_head;
 	cnx->msg_stack_head = msg;
-	spin_unlock_irqrestore(&cnx->msg_stack_lock, flags);
 }
 
+/* You must hold the connection's lock when you call this function. */
 static inline struct veth_msg *veth_stack_pop(struct veth_lpar_connection *cnx)
 {
-	unsigned long flags;
 	struct veth_msg *msg;
 
-	spin_lock_irqsave(&cnx->msg_stack_lock, flags);
 	msg = cnx->msg_stack_head;
 	if (msg)
 		cnx->msg_stack_head = cnx->msg_stack_head->next;
-	spin_unlock_irqrestore(&cnx->msg_stack_lock, flags);
+
 	return msg;
 }
 
@@ -643,7 +638,6 @@ static int veth_init_connection(u8 rlp)
 
 	cnx->msgs = msgs;
 	memset(msgs, 0, VETH_NUMBUFFERS * sizeof(struct veth_msg));
-	spin_lock_init(&cnx->msg_stack_lock);
 
 	for (i = 0; i < VETH_NUMBUFFERS; i++) {
 		msgs[i].token = i;
