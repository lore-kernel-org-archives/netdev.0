From: Michael Ellerman <michael@ellerman.id.au>
Subject: [PATCH 5/18] iseries_veth: Remove redundant message stack lock
Date: Thu,  1 Sep 2005 11:29:05 +1000 (EST)
Message-ID: <20050901012905.C9D3668205@ozlabs.org>
References: <1125538127.859382.875909607846.qpush@concordia>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linuxppc64-dev@ozlabs.org
Return-path: <linuxppc64-dev-bounces@ozlabs.org>
To: <jgarzik@pobox.com>
In-Reply-To: <1125538127.859382.875909607846.qpush@concordia>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc64-dev>,
	<mailto:linuxppc64-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc64-dev>
List-Post: <mailto:linuxppc64-dev@ozlabs.org>
List-Help: <mailto:linuxppc64-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc64-dev>,
	<mailto:linuxppc64-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc64-dev-bounces@ozlabs.org
Errors-To: linuxppc64-dev-bounces@ozlabs.org
List-Id: netdev.vger.kernel.org

The iseries_veth driver keeps a stack of messages for each connection
and a lock to protect the stack. However there is also a per-connection lock
which makes the message stack lock redundant.

Remove the message stack lock and document the fact that callers of the
stack-manipulation functions must hold the connection's lock.

Signed-off-by: Michael Ellerman <michael@ellerman.id.au>
---

 drivers/net/iseries_veth.c |   12 +++---------
 1 files changed, 3 insertions(+), 9 deletions(-)

Index: veth-dev2/drivers/net/iseries_veth.c
===================================================================
--- veth-dev2.orig/drivers/net/iseries_veth.c
+++ veth-dev2/drivers/net/iseries_veth.c
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
 
@@ -645,7 +640,6 @@ static int veth_init_connection(u8 rlp)
 
 	cnx->msgs = msgs;
 	memset(msgs, 0, VETH_NUMBUFFERS * sizeof(struct veth_msg));
-	spin_lock_init(&cnx->msg_stack_lock);
 
 	for (i = 0; i < VETH_NUMBUFFERS; i++) {
 		msgs[i].token = i;
