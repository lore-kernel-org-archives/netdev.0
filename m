From: John Fastabend <john.fastabend@gmail.com>
Subject: [net PATCH 1/3] net: rcu lock and preempt disable missing around
 generic xdp
Date: Fri, 08 Sep 2017 14:00:30 -0700
Message-ID: <150490443011.11590.2847947557652786219.stgit@john-XPS-13-9360>
References: <150490397545.11590.1409723973253492363.stgit@john-XPS-13-9360>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, john.fastabend@gmail.com,
        daniel@iogearbox.net, ast@fb.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:38300 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932400AbdIHVAo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 8 Sep 2017 17:00:44 -0400
Received: by mail-pg0-f66.google.com with SMTP id t3so1778507pgt.5
        for <netdev@vger.kernel.org>; Fri, 08 Sep 2017 14:00:43 -0700 (PDT)
In-Reply-To: <150490397545.11590.1409723973253492363.stgit@john-XPS-13-9360>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

do_xdp_generic must be called inside rcu critical section with preempt
disabled to ensure BPF programs are valid and per-cpu variables used
for redirect operations are consistent. This patch ensures this is true
and fixes the splat below.

The netif_receive_skb_internal() code path is now broken into two rcu
critical sections. I decided it was better to limit the preempt_enable/disable
block to just the xdp static key portion and the fallout is more
rcu_read_lock/unlock calls. Seems like the best option to me.

[  607.596901] =============================
[  607.596906] WARNING: suspicious RCU usage
[  607.596912] 4.13.0-rc4+ #570 Not tainted
[  607.596917] -----------------------------
[  607.596923] net/core/dev.c:3948 suspicious rcu_dereference_check() usage!
[  607.596927]
[  607.596927] other info that might help us debug this:
[  607.596927]
[  607.596933]
[  607.596933] rcu_scheduler_active = 2, debug_locks = 1
[  607.596938] 2 locks held by pool/14624:
[  607.596943]  #0:  (rcu_read_lock_bh){......}, at: [<ffffffff95445ffd>] ip_finish_output2+0x14d/0x890
[  607.596973]  #1:  (rcu_read_lock_bh){......}, at: [<ffffffff953c8e3a>] __dev_queue_xmit+0x14a/0xfd0
[  607.597000]
[  607.597000] stack backtrace:
[  607.597006] CPU: 5 PID: 14624 Comm: pool Not tainted 4.13.0-rc4+ #570
[  607.597011] Hardware name: Dell Inc. Precision Tower 5810/0HHV7N, BIOS A17 03/01/2017
[  607.597016] Call Trace:
[  607.597027]  dump_stack+0x67/0x92
[  607.597040]  lockdep_rcu_suspicious+0xdd/0x110
[  607.597054]  do_xdp_generic+0x313/0xa50
[  607.597068]  ? time_hardirqs_on+0x5b/0x150
[  607.597076]  ? mark_held_locks+0x6b/0xc0
[  607.597088]  ? netdev_pick_tx+0x150/0x150
[  607.597117]  netif_rx_internal+0x205/0x3f0
[  607.597127]  ? do_xdp_generic+0xa50/0xa50
[  607.597144]  ? lock_downgrade+0x2b0/0x2b0
[  607.597158]  ? __lock_is_held+0x93/0x100
[  607.597187]  netif_rx+0x119/0x190
[  607.597202]  loopback_xmit+0xfd/0x1b0
[  607.597214]  dev_hard_start_xmit+0x127/0x4e0

Fixes: d445516966dc ("net: xdp: support xdp generic on virtual devices")
Fixes: b5cdae3291f7 ("net: Generic XDP")
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
Signed-off-by: John Fastabend <john.fastabend@gmail.com>
---
 net/core/dev.c |   25 ++++++++++++++++---------
 1 file changed, 16 insertions(+), 9 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 6f845e4..fb766d9 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3981,8 +3981,13 @@ static int netif_rx_internal(struct sk_buff *skb)
 	trace_netif_rx(skb);
 
 	if (static_key_false(&generic_xdp_needed)) {
-		int ret = do_xdp_generic(rcu_dereference(skb->dev->xdp_prog),
-					 skb);
+		int ret;
+
+		preempt_disable();
+		rcu_read_lock();
+		ret = do_xdp_generic(rcu_dereference(skb->dev->xdp_prog), skb);
+		rcu_read_unlock();
+		preempt_enable();
 
 		/* Consider XDP consuming the packet a success from
 		 * the netdev point of view we do not want to count
@@ -4500,18 +4505,20 @@ static int netif_receive_skb_internal(struct sk_buff *skb)
 	if (skb_defer_rx_timestamp(skb))
 		return NET_RX_SUCCESS;
 
-	rcu_read_lock();
-
 	if (static_key_false(&generic_xdp_needed)) {
-		int ret = do_xdp_generic(rcu_dereference(skb->dev->xdp_prog),
-					 skb);
+		int ret;
 
-		if (ret != XDP_PASS) {
-			rcu_read_unlock();
+		preempt_disable();
+		rcu_read_lock();
+		ret = do_xdp_generic(rcu_dereference(skb->dev->xdp_prog), skb);
+		rcu_read_unlock();
+		preempt_enable();
+
+		if (ret != XDP_PASS)
 			return NET_RX_DROP;
-		}
 	}
 
+	rcu_read_lock();
 #ifdef CONFIG_RPS
 	if (static_key_false(&rps_needed)) {
 		struct rps_dev_flow voidflow, *rflow = &voidflow;
