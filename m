From: gfree.wind@vip.163.com
Subject: [PATCH net] ppp: Fix a scheduling-while-atomic bug in del_chan
Date: Mon, 31 Jul 2017 18:07:38 +0800
Message-ID: <1501495658-119725-1-git-send-email-gfree.wind@vip.163.com>
Cc: Gao Feng <gfree.wind@vip.163.com>
To: xeb@mail.ru, davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from m181-177.vip.163.com ([123.58.177.181]:38758 "EHLO
        m181-177.vip.163.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751046AbdGaKHy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2017 06:07:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao Feng <gfree.wind@vip.163.com>

The PPTP set the pptp_sock_destruct as the sock's sk_destruct, it would
trigger this bug when __sk_free is invoked in atomic context, because of
the call path pptp_sock_destruct->del_chan->synchronize_rcu.

Now move the synchronize_rcu to pptp_release from del_chan. This is the
only one case which would free the sock and need the synchronize_rcu.

The following is the panic I met with kernel 3.3.8, but this issue should
exist in current kernel too according to the codes.

BUG: scheduling while atomic
__schedule_bug+0x5e/0x64
__schedule+0x55/0x580
? ppp_unregister_channel+0x1cd5/0x1de0 [ppp_generic]
? dev_hard_start_xmit+0x423/0x530
? sch_direct_xmit+0x73/0x170
__cond_resched+0x16/0x30
_cond_resched+0x22/0x30
wait_for_common+0x18/0x110
? call_rcu_bh+0x10/0x10
wait_for_completion+0x12/0x20
wait_rcu_gp+0x34/0x40
? wait_rcu_gp+0x40/0x40
synchronize_sched+0x1e/0x20
0xf8417298
0xf8417484
? sock_queue_rcv_skb+0x109/0x130
__sk_free+0x16/0x110
? udp_queue_rcv_skb+0x1f2/0x290
sk_free+0x16/0x20
__udp4_lib_rcv+0x3b8/0x650

Signed-off-by: Gao Feng <gfree.wind@vip.163.com>
---
 drivers/net/ppp/pptp.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ppp/pptp.c b/drivers/net/ppp/pptp.c
index eac499c..6dde9a0 100644
--- a/drivers/net/ppp/pptp.c
+++ b/drivers/net/ppp/pptp.c
@@ -131,7 +131,6 @@ static void del_chan(struct pppox_sock *sock)
 	clear_bit(sock->proto.pptp.src_addr.call_id, callid_bitmap);
 	RCU_INIT_POINTER(callid_sock[sock->proto.pptp.src_addr.call_id], NULL);
 	spin_unlock(&chan_lock);
-	synchronize_rcu();
 }
 
 static int pptp_xmit(struct ppp_channel *chan, struct sk_buff *skb)
@@ -520,6 +519,7 @@ static int pptp_release(struct socket *sock)
 
 	po = pppox_sk(sk);
 	del_chan(po);
+	synchronize_rcu();
 
 	pppox_unbind_sock(sk);
 	sk->sk_state = PPPOX_DEAD;
-- 
1.9.1
