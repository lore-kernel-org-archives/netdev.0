From: Wang Yufen <wangyufen@huawei.com>
Subject: [PATCH] tg3: Avoid NULL pointer dereference in tg3_get_nstats()
Date: Thu, 5 Jan 2017 22:13:21 +0800
Message-ID: <1483625601-10552-1-git-send-email-wangyufen@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Yufen Wang <wangyufen@huawei.com>
To: <siva.kallam@broadcom.com>, <prashant@broadcom.com>,
        <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:59183 "EHLO
        szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1032580AbdAEOOF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Jan 2017 09:14:05 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yufen Wang <wangyufen@huawei.com>

A possible NULL pointer dereference in tg3_get_stats64 while doing
tg3_free_consistent.

The following trace is seen when the error is triggered:
[360729.331080] BUG: unable to handle kernel NULL pointer dereference at 0000000000000130
[360729.339357] IP: [<ffffffffa02855a6>] tg3_get_nstats+0x276/0x370 [tg3]
[360729.346072] PGD 0
[360729.348356] Thread overran stack, or stack corrupted
[360729.353573] Oops: 0000 [#1] SMP

[360729.386221] task: ffff880c22dd5c00 ti: ffff881037cb4000 task.ti: ffff881037cb4000
[360729.386227] RIP: 0010:[<ffffffffa02855a6>] tg3_get_nstats+0x276/0x370 [tg3]
[360729.386228] RSP: 0018:ffff881037cb7c98  EFLAGS: 00010206
[360729.386229] RAX: 0000000000000000 RBX: ffff880c1e32e000 RCX: 0000000000005719
[360729.386230] RDX: 0000000000000000 RSI: ffff881037cb7d90 RDI: ffff880852ea08c0
[360729.386230] RBP: ffff881037cb7cc8 R08: ffffffffa02a4ca0 R09: 0000000000000248
[360729.386231] R10: 0000000000000000 R11: ffff881037cb7bbe R12: ffff880852ea08c0
[360729.386232] R13: ffff881037cb7d90 R14: 0000000000000000 R15: ffff8806b7213e80
[360729.386233] FS:  00007fd00c3da740(0000) GS:ffff88085ff00000(0000) knlGS:0000000000000000
[360729.386234] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[360729.386235] CR2: 0000000000000130 CR3: 0000000109df4000 CR4: 00000000001427e0
[360729.386235] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[360729.386236] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[360729.386236] Stack:
[360729.386238]  ffff8806b7213e80 00000000132dc9ae ffff880852ea0000 ffff881037cb7d90
[360729.386240]  ffff880852ea08c4 ffff880852ea08c0 ffff881037cb7cf8 ffffffffa02856e1
[360729.386241]  ffff881037cb7d90 ffff880852ea0000 ffff880852ea0000 ffff881037cb7f48
[360729.386242] Call Trace:
[360729.386247]  [<ffffffffa02856e1>] tg3_get_stats64+0x41/0x80 [tg3]
[360729.386249]  [<ffffffff8153292e>] dev_get_stats+0x6e/0x200
[360729.386251]  [<ffffffff81551927>] dev_seq_printf_stats+0x37/0x120
[360729.386254]  [<ffffffff81551a24>] dev_seq_show+0x14/0x30
[360729.386256]  [<ffffffff8120cb48>] seq_read+0x238/0x3a0
[360729.386258]  [<ffffffff81254fcd>] proc_reg_read+0x3d/0x80
[360729.386260]  [<ffffffff811e8b0c>] vfs_read+0x9c/0x170
[360729.386262]  [<ffffffff811e965f>] SyS_read+0x7f/0xe0
[360729.386264]  [<ffffffff81652289>] system_call_fastpath+0x16/0x1b

This patch avoids the NULL pointer dereference by using !tg3_flag(tp, INIT_COMPLETE)
instate of !tp->hw_stats.

Signed-off-by: Yufen Wang <wangyufen@huawei.com>
---
 drivers/net/ethernet/broadcom/tg3.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 185e9e0..012f18d 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -14148,7 +14148,7 @@ static struct rtnl_link_stats64 *tg3_get_stats64(struct net_device *dev,
 	struct tg3 *tp = netdev_priv(dev);
 
 	spin_lock_bh(&tp->lock);
-	if (!tp->hw_stats) {
+	if (!tg3_flag(tp, INIT_COMPLETE)) {
 		*stats = tp->net_stats_prev;
 		spin_unlock_bh(&tp->lock);
 		return stats;
-- 
2.7.0
