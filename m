From: Renato Westphal <renatowestphal@gmail.com>
Subject: [PATCH] tcp: remove improper preemption check in tcp_xmit_probe_skb()
Date: Mon, 19 Oct 2015 18:51:34 -0200
Message-ID: <1445287894-2248-1-git-send-email-renatow@taghos.com.br>
Cc: Renato Westphal <renatow@taghos.com.br>
To: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Pavel Emelyanov <xemul@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f50.google.com ([209.85.192.50]:35845 "EHLO
	mail-qg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752291AbbJSUvx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Oct 2015 16:51:53 -0400
Received: by qgad10 with SMTP id d10so76431717qga.3
        for <netdev@vger.kernel.org>; Mon, 19 Oct 2015 13:51:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit e520af48c7e5a introduced the following bug when setting the
TCP_REPAIR sockoption:

[ 2860.657036] BUG: using __this_cpu_add() in preemptible [00000000] code: daemon/12164
[ 2860.657045] caller is __this_cpu_preempt_check+0x13/0x20
[ 2860.657049] CPU: 1 PID: 12164 Comm: daemon Not tainted 4.2.3 #1
[ 2860.657051] Hardware name: Dell Inc. PowerEdge R210 II/0JP7TR, BIOS 2.0.5 03/13/2012
[ 2860.657054]  ffffffff81c7f071 ffff880231e9fdf8 ffffffff8185d765 0000000000000002
[ 2860.657058]  0000000000000001 ffff880231e9fe28 ffffffff8146ed91 ffff880231e9fe18
[ 2860.657062]  ffffffff81cd1a5d ffff88023534f200 ffff8800b9811000 ffff880231e9fe38
[ 2860.657065] Call Trace:
[ 2860.657072]  [<ffffffff8185d765>] dump_stack+0x4f/0x7b
[ 2860.657075]  [<ffffffff8146ed91>] check_preemption_disabled+0xe1/0xf0
[ 2860.657078]  [<ffffffff8146edd3>] __this_cpu_preempt_check+0x13/0x20
[ 2860.657082]  [<ffffffff817e0bc7>] tcp_xmit_probe_skb+0xc7/0x100
[ 2860.657085]  [<ffffffff817e1e2d>] tcp_send_window_probe+0x2d/0x30
[ 2860.657089]  [<ffffffff817d1d8c>] do_tcp_setsockopt.isra.29+0x74c/0x830
[ 2860.657093]  [<ffffffff817d1e9c>] tcp_setsockopt+0x2c/0x30
[ 2860.657097]  [<ffffffff81767b74>] sock_common_setsockopt+0x14/0x20
[ 2860.657100]  [<ffffffff817669e1>] SyS_setsockopt+0x71/0xc0
[ 2860.657104]  [<ffffffff81865172>] entry_SYSCALL_64_fastpath+0x16/0x75

Since tcp_xmit_probe_skb() can be called from process context, use
NET_INC_STATS() instead of NET_INC_STATS_BH().

Signed-off-by: Renato Westphal <renatow@taghos.com.br>
---
 net/ipv4/tcp_output.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 19adedb..d4621c3 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -3416,7 +3416,7 @@ static int tcp_xmit_probe_skb(struct sock *sk, int urgent, int mib)
 	 */
 	tcp_init_nondata_skb(skb, tp->snd_una - !urgent, TCPHDR_ACK);
 	skb_mstamp_get(&skb->skb_mstamp);
-	NET_INC_STATS_BH(sock_net(sk), mib);
+	NET_INC_STATS(sock_net(sk), mib);
 	return tcp_transmit_skb(sk, skb, 0, GFP_ATOMIC);
 }
 
-- 
1.9.1
