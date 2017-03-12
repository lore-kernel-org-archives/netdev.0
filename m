From: Chas Williams <3chas3@gmail.com>
Subject: [Patch net-next] atm: remove an unnecessary loop
Date: Sat, 11 Mar 2017 19:41:36 -0500
Message-ID: <1489279296-9316-1-git-send-email-3chas3@gmail.com>
Cc: Francois Romieu <romieu@fr.zoreil.com>,
        Chas Williams <3chas3@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f196.google.com ([209.85.216.196]:32952 "EHLO
        mail-qt0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751469AbdCLAln (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 11 Mar 2017 19:41:43 -0500
Received: by mail-qt0-f196.google.com with SMTP id r45so2580640qte.0
        for <netdev@vger.kernel.org>; Sat, 11 Mar 2017 16:41:43 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>

Andrey reported this kernel warning:

WARNING: CPU: 0 PID: 4114 at kernel/sched/core.c:7737 __might_sleep+0x149/0x1a0
do not call blocking ops when !TASK_RUNNING; state=1 set at
[<ffffffff813fcb22>] prepare_to_wait+0x182/0x530

The deeply nested alloc_skb is a problem.

Diagnosis: nesting is wrong. It makes zero sense. Fix it and the
implicit task state change problem automagically goes away.

alloc_skb() does not need to be in the "while" loop.

alloc_skb() does not need to be in the {prepare_to_wait/add_wait_queue ...
finish_wait/remove_wait_queue} block.

I claim that:
- alloc_tx() should only perform the "wait_for_decent_tx_drain" part
- alloc_skb() ought to be done directly in vcc_sendmsg
- alloc_skb() failure can be handled gracefully in vcc_sendmsg
- alloc_skb() may use a (m->msg_flags & MSG_DONTWAIT) dependent
  GFP_{KERNEL / ATOMIC} flag

Reported-by: Andrey Konovalov <andreyknvl@google.com>
Reviewed-and-Tested-by: Chas Williams <3chas3@gmail.com>
Signed-off-by: Chas Williams <3chas3@gmail.com>
---
 net/atm/common.c | 22 +++++++++++++---------
 1 file changed, 13 insertions(+), 9 deletions(-)

diff --git a/net/atm/common.c b/net/atm/common.c
index 9613381..f06422f 100644
--- a/net/atm/common.c
+++ b/net/atm/common.c
@@ -62,21 +62,16 @@ static void vcc_remove_socket(struct sock *sk)
 	write_unlock_irq(&vcc_sklist_lock);
 }
 
-static struct sk_buff *alloc_tx(struct atm_vcc *vcc, unsigned int size)
+static bool vcc_tx_ready(struct atm_vcc *vcc, unsigned int size)
 {
-	struct sk_buff *skb;
 	struct sock *sk = sk_atm(vcc);
 
 	if (sk_wmem_alloc_get(sk) && !atm_may_send(vcc, size)) {
 		pr_debug("Sorry: wmem_alloc = %d, size = %d, sndbuf = %d\n",
 			 sk_wmem_alloc_get(sk), size, sk->sk_sndbuf);
-		return NULL;
+		return false;
 	}
-	while (!(skb = alloc_skb(size, GFP_KERNEL)))
-		schedule();
-	pr_debug("%d += %d\n", sk_wmem_alloc_get(sk), skb->truesize);
-	atomic_add(skb->truesize, &sk->sk_wmem_alloc);
-	return skb;
+	return true;
 }
 
 static void vcc_sock_destruct(struct sock *sk)
@@ -606,7 +601,7 @@ int vcc_sendmsg(struct socket *sock, struct msghdr *m, size_t size)
 	eff = (size+3) & ~3; /* align to word boundary */
 	prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
 	error = 0;
-	while (!(skb = alloc_tx(vcc, eff))) {
+	while (!vcc_tx_ready(vcc, eff)) {
 		if (m->msg_flags & MSG_DONTWAIT) {
 			error = -EAGAIN;
 			break;
@@ -628,6 +623,15 @@ int vcc_sendmsg(struct socket *sock, struct msghdr *m, size_t size)
 	finish_wait(sk_sleep(sk), &wait);
 	if (error)
 		goto out;
+
+	skb = alloc_skb(eff, GFP_KERNEL);
+	if (!skb) {
+		error = -ENOMEM;
+		goto out;
+	}
+	pr_debug("%d += %d\n", sk_wmem_alloc_get(sk), skb->truesize);
+	atomic_add(skb->truesize, &sk->sk_wmem_alloc);
+
 	skb->dev = NULL; /* for paths shared with net_device interfaces */
 	ATM_SKB(skb)->atm_options = vcc->atm_options;
 	if (!copy_from_iter_full(skb_put(skb, size), size, &m->msg_iter)) {
-- 
2.7.4
