From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 1/1 net-next] net/atm/signaling.c: remove WAIT_FOR_DEMON code
Date: Tue,  3 Mar 2015 19:38:46 +0100
Message-ID: <1425407926-15917-1-git-send-email-fabf@skynet.be>
Cc: davem@davemloft.net, chas@cmf.nrl.navy.mil,
	Fabian Frederick <fabf@skynet.be>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

WAIT_FOR_DEMON code is directly undefined at the beginning
of signaling.c since initial git version and thus never compiled.
This also removes buggy current->state direct access.

Suggested-by: Chas Williams <chas@cmf.nrl.navy.mil>
Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 net/atm/signaling.c |   24 ------------------------
 1 file changed, 24 deletions(-)

diff --git a/net/atm/signaling.c b/net/atm/signaling.c
index 523bce7..4fd6af4 100644
--- a/net/atm/signaling.c
+++ b/net/atm/signaling.c
@@ -19,36 +19,15 @@
 #include "resources.h"
 #include "signaling.h"
 
-#undef WAIT_FOR_DEMON		/* #define this if system calls on SVC sockets
-				   should block until the demon runs.
-				   Danger: may cause nasty hangs if the demon
-				   crashes. */
-
 struct atm_vcc *sigd = NULL;
-#ifdef WAIT_FOR_DEMON
-static DECLARE_WAIT_QUEUE_HEAD(sigd_sleep);
-#endif
 
 static void sigd_put_skb(struct sk_buff *skb)
 {
-#ifdef WAIT_FOR_DEMON
-	DECLARE_WAITQUEUE(wait, current);
-
-	add_wait_queue(&sigd_sleep, &wait);
-	while (!sigd) {
-		set_current_state(TASK_UNINTERRUPTIBLE);
-		pr_debug("atmsvc: waiting for signaling daemon...\n");
-		schedule();
-	}
-	current->state = TASK_RUNNING;
-	remove_wait_queue(&sigd_sleep, &wait);
-#else
 	if (!sigd) {
 		pr_debug("atmsvc: no signaling daemon\n");
 		kfree_skb(skb);
 		return;
 	}
-#endif
 	atm_force_charge(sigd, skb->truesize);
 	skb_queue_tail(&sk_atm(sigd)->sk_receive_queue, skb);
 	sk_atm(sigd)->sk_data_ready(sk_atm(sigd));
@@ -261,8 +240,5 @@ int sigd_attach(struct atm_vcc *vcc)
 	vcc_insert_socket(sk_atm(vcc));
 	set_bit(ATM_VF_META, &vcc->flags);
 	set_bit(ATM_VF_READY, &vcc->flags);
-#ifdef WAIT_FOR_DEMON
-	wake_up(&sigd_sleep);
-#endif
 	return 0;
 }
-- 
1.7.9.5
