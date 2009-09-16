From: Ursula Braun <ursula.braun@de.ibm.com>
Subject: [patch 7/7] [PATCH] af_iucv: fix race when queueing skbs on the backlog queue
Date: Wed, 16 Sep 2009 16:37:28 +0200
Message-ID: <20090916144304.939683000@linux.vnet.ibm.com>
References: <20090916143721.863799000@linux.vnet.ibm.com>
Cc: schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
	Hendrik Brueckner <brueckner@linux.vnet.ibm.com>,
	Ursula Braun <ursula.braun@de.ibm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.de.ibm.com ([195.212.17.165]:57149 "EHLO
	mtagate5.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752371AbZIPOnD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Sep 2009 10:43:03 -0400
Content-Disposition: inline; filename=607-af_iucv-backlog-queue.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hendrik Brueckner <brueckner@linux.vnet.ibm.com>

iucv_sock_recvmsg() and iucv_process_message()/iucv_fragment_skb race
for dequeuing an skb from the backlog queue.

If iucv_sock_recvmsg() dequeues first, iucv_process_message() calls
sock_queue_rcv_skb() with an skb that is NULL.

This results in the following kernel panic:

<1>Unable to handle kernel pointer dereference at virtual kernel address (null)
<4>Oops: 0004 [#1] PREEMPT SMP DEBUG_PAGEALLOC
<4>Modules linked in: af_iucv sunrpc qeth_l3 dm_multipath dm_mod vmur qeth ccwgroup
<4>CPU: 0 Not tainted 2.6.30 #4
<4>Process client-iucv (pid: 4787, task: 0000000034e75940, ksp: 00000000353e3710)
<4>Krnl PSW : 0704000180000000 000000000043ebca (sock_queue_rcv_skb+0x7a/0x138)
<4>           R:0 T:1 IO:1 EX:1 Key:0 M:1 W:0 P:0 AS:0 CC:0 PM:0 EA:3
<4>Krnl GPRS: 0052900000000000 000003e0016e0fe8 0000000000000000 0000000000000000
<4>           000000000043eba8 0000000000000002 0000000000000001 00000000341aa7f0
<4>           0000000000000000 0000000000007800 0000000000000000 0000000000000000
<4>           00000000341aa7f0 0000000000594650 000000000043eba8 000000003fc2fb28
<4>Krnl Code: 000000000043ebbe: a7840006            brc     8,43ebca
<4>           000000000043ebc2: 5930c23c            c       %r3,572(%r12)
<4>           000000000043ebc6: a724004c            brc     2,43ec5e
<4>          >000000000043ebca: e3c0b0100024        stg     %r12,16(%r11)
<4>           000000000043ebd0: a7190000            lghi    %r1,0
<4>           000000000043ebd4: e310b0200024        stg     %r1,32(%r11)
<4>           000000000043ebda: c010ffffdce9        larl    %r1,43a5ac
<4>           000000000043ebe0: e310b0800024        stg     %r1,128(%r11)
<4>Call Trace:
<4>([<000000000043eba8>] sock_queue_rcv_skb+0x58/0x138)
<4> [<000003e0016bcf2a>] iucv_process_message+0x112/0x3cc [af_iucv]
<4> [<000003e0016bd3d4>] iucv_callback_rx+0x1f0/0x274 [af_iucv]
<4> [<000000000053a21a>] iucv_message_pending+0xa2/0x120
<4> [<000000000053b5a6>] iucv_tasklet_fn+0x176/0x1b8
<4> [<000000000014fa82>] tasklet_action+0xfe/0x1f4
<4> [<0000000000150a56>] __do_softirq+0x116/0x284
<4> [<0000000000111058>] do_softirq+0xe4/0xe8
<4> [<00000000001504ba>] irq_exit+0xba/0xd8
<4> [<000000000010e0b2>] do_extint+0x146/0x190
<4> [<00000000001184b6>] ext_no_vtime+0x1e/0x22
<4> [<00000000001fbf4e>] kfree+0x202/0x28c
<4>([<00000000001fbf44>] kfree+0x1f8/0x28c)
<4> [<000000000044205a>] __kfree_skb+0x32/0x124
<4> [<000003e0016bd8b2>] iucv_sock_recvmsg+0x236/0x41c [af_iucv]
<4> [<0000000000437042>] sock_aio_read+0x136/0x160
<4> [<0000000000205e50>] do_sync_read+0xe4/0x13c
<4> [<0000000000206dce>] vfs_read+0x152/0x15c
<4> [<0000000000206ed0>] SyS_read+0x54/0xac
<4> [<0000000000117c8e>] sysc_noemu+0x10/0x16
<4> [<00000042ff8def3c>] 0x42ff8def3c

Signed-off-by: Hendrik Brueckner <brueckner@linux.vnet.ibm.com>
Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
---

 net/iucv/af_iucv.c |   16 ++++++++++++++--
 1 file changed, 14 insertions(+), 2 deletions(-)

Index: linux-2.6-uschi/net/iucv/af_iucv.c
===================================================================
--- linux-2.6-uschi.orig/net/iucv/af_iucv.c
+++ linux-2.6-uschi/net/iucv/af_iucv.c
@@ -1036,6 +1036,10 @@ out:
 	return err;
 }
 
+/* iucv_fragment_skb() - Fragment a single IUCV message into multiple skb's
+ *
+ * Locking: must be called with message_q.lock held
+ */
 static int iucv_fragment_skb(struct sock *sk, struct sk_buff *skb, int len)
 {
 	int dataleft, size, copied = 0;
@@ -1070,6 +1074,10 @@ static int iucv_fragment_skb(struct sock
 	return 0;
 }
 
+/* iucv_process_message() - Receive a single outstanding IUCV message
+ *
+ * Locking: must be called with message_q.lock held
+ */
 static void iucv_process_message(struct sock *sk, struct sk_buff *skb,
 				 struct iucv_path *path,
 				 struct iucv_message *msg)
@@ -1120,6 +1128,10 @@ static void iucv_process_message(struct 
 		skb_queue_head(&iucv_sk(sk)->backlog_skb_q, skb);
 }
 
+/* iucv_process_message_q() - Process outstanding IUCV messages
+ *
+ * Locking: must be called with message_q.lock held
+ */
 static void iucv_process_message_q(struct sock *sk)
 {
 	struct iucv_sock *iucv = iucv_sk(sk);
@@ -1210,6 +1222,7 @@ static int iucv_sock_recvmsg(struct kioc
 		kfree_skb(skb);
 
 		/* Queue backlog skbs */
+		spin_lock_bh(&iucv->message_q.lock);
 		rskb = skb_dequeue(&iucv->backlog_skb_q);
 		while (rskb) {
 			if (sock_queue_rcv_skb(sk, rskb)) {
@@ -1221,11 +1234,10 @@ static int iucv_sock_recvmsg(struct kioc
 			}
 		}
 		if (skb_queue_empty(&iucv->backlog_skb_q)) {
-			spin_lock_bh(&iucv->message_q.lock);
 			if (!list_empty(&iucv->message_q.list))
 				iucv_process_message_q(sk);
-			spin_unlock_bh(&iucv->message_q.lock);
 		}
+		spin_unlock_bh(&iucv->message_q.lock);
 	}
 
 done:

