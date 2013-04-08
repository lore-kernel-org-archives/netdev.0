From: dingtianhong <dingtianhong@huawei.com>
Subject: [PATCH] net: add checks if dev->netdev_ops is NULL in register_netdevice()
Date: Mon, 8 Apr 2013 17:43:53 +0800
Message-ID: <51629159.9040000@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Netdev <netdev@vger.kernel.org>, Li Zefan <lizefan@huawei.com>,
	Xinwei Hu <huxinwei@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:61845 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761729Ab3DHJoS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Apr 2013 05:44:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In some cases netdev->netdev_ops could be NULL in the register_netdevice(),
thus a NULL point deference happens and lead to oops:

[ 8260.836400] BUG: unable to handle kernel NULL pointer dereference at (null)
[ 8260.955306] IP: [<ffffffff81388333>] register_netdevice+0x73/0x2d0
[ 8261.054888] PGD 2f4dcd067 PUD 2f4de0067 PMD 0
[ 8261.134244] Oops: 0000 [#1] SMP
[ 8261.198938] CPU 0
[ 8262.605182] RIP: 0010:[<ffffffff81388333>]  [<ffffffff81388333>] register_netdevice+0x73/0x2d0
[ 8262.741859] RSP: 0018:ffff8802f489f9f8  EFLAGS: 00010246
[ 8262.839463] RAX: 0000000000000000 RBX: ffff8802f4e73000 RCX: ffff8802f4e73006
[ 8262.959484] RDX: 0000000000000000 RSI: 00000000daa92527 RDI: ffff8802f4e73006
[ 8263.079352] RBP: 0000000000000000 R08: 0000000000000000 R09: ffff880327d898c0
[ 8263.198987] R10: 00000000000000c1 R11: 0000000000000000 R12: ffffffff81fed080
[ 8263.318401] R13: ffffffff81fed080 R14: ffff8802f4e73000 R15: 0000000000000000
[ 8263.438014] FS:  00007f01dfa81700(0000) GS:ffff88033f200000(0000) knlGS:0000000000000000
[ 8263.569778] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 8263.673859] CR2: 0000000000000000 CR3: 000000032893f000 CR4: 00000000000006f0
[ 8263.794922] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 8263.915734] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 8264.036251] Process rmcli (pid: 14089, threadinfo ffff8802f489e000, task ffff880324708080)
[ 8264.170961] Stack:
[ 8264.231328]  ffff88032a3c0000 0000000000000003 0000000000000003 ffff88032a3c0000
[ 8264.356967]  0000000000000003 ffffffffa039dbcb 000000003ec216c0 0000000000000246
[ 8264.483081]  382e30363238205b 00205d3900000006 ff00305f63696e76 0000000000000003

We should check the point to avoid the oops.

Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 net/core/dev.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index e7d68ed..596a11e 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5159,7 +5159,7 @@ int register_netdevice(struct net_device *dev)
 		goto out;

 	/* Init, if this function is available */
-	if (dev->netdev_ops->ndo_init) {
+	if (dev->netdev_ops && dev->netdev_ops->ndo_init) {
 		ret = dev->netdev_ops->ndo_init(dev);
 		if (ret) {
 			if (ret > 0)
-- 1.8.0
