From: Sasha Levin <levinsasha928@gmail.com>
Subject: [PATCH] net: caif: Don't act on notification for non-caif devices
Date: Tue, 24 Jan 2012 02:30:29 -0500
Message-ID: <1327390229-30170-1-git-send-email-levinsasha928@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Sasha Levin <levinsasha928@gmail.com>
To: sjur.brandeland@stericsson.com, davem@davemloft.net,
	davej@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:55052 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752791Ab2AXFbS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2012 00:31:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently we assume every notification happens within a network namespace
in which CAIF was already initialized. This is not true when we're copying
the namespace and the notifier is being called before the initialization
code runs.

Since the list of CAIF devices is stored in the net generic struct in each
net namespace, which is not initialized at that point, we see the following
BUG():

[  200.752016] kernel BUG at include/net/netns/generic.h:40!
[  200.752016] invalid opcode: 0000 [#1] PREEMPT SMP
[  200.752016] CPU 0
[  200.752016] Pid: 18013, comm: trinity Not tainted 3.3.0-rc1-next-20120123-sasha-dirty #134
[  200.752016] RIP: 0010:[<ffffffff825c3dd6>]  [<ffffffff825c3dd6>] get_cfcnfg+0x126/0x180
[  200.752016] RSP: 0018:ffff88000fbabb00  EFLAGS: 00010202
[  200.752016] RAX: 0000000000000001 RBX: 0000000000000016 RCX: 0000000000000000
[  200.752016] RDX: 0000000000000001 RSI: ffffffff8323c620 RDI: 0000000000000286
[  200.752016] RBP: ffff88000fbabb20 R08: 0000000000000003 R09: 0000000000000001
[  200.752016] R10: 0000000000000000 R11: 0000000000000001 R12: ffff88000502b480
[  200.752016] R13: ffffffff836b9440 R14: 0000000000000000 R15: 0000000000000010
[  200.752016] FS:  00007f6c3af86700(0000) GS:ffff880013a00000(0000) knlGS:0000000000000000
[  200.752016] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  200.752016] CR2: 00007f7a60186f60 CR3: 000000000fb3b000 CR4: 00000000000406f0
[  200.752016] DR0: ffffffff810ab5e0 DR1: 0000000000000000 DR2: 0000000000000000
[  200.752016] DR3: 0000000000000000 DR6: 00000000ffff4ff0 DR7: 0000000000000600
[  200.752016] Process trinity (pid: 18013, threadinfo ffff88000fbaa000, task ffff880005002000)
[  200.752016] Stack:
[  200.752016]  ffffffff825c3cea ffffffff821cf0b0 ffff88000504d000 00000000ffffffd2
[  200.752016]  ffff88000fbabb80 ffffffff825c41be ffff88000fbabb80 0000000000000001
[  200.752016]  0000000000000001 ffff880005002000 ffff88000fbabb80 ffff88000504d000
[  200.752016] Call Trace:
[  200.752016]  [<ffffffff825c3cea>] ? get_cfcnfg+0x3a/0x180
[  200.752016]  [<ffffffff821cf0b0>] ? lockdep_rtnl_is_held+0x10/0x20
[  200.752016]  [<ffffffff825c41be>] caif_device_notify+0x2e/0x530
[  200.752016]  [<ffffffff810d61b7>] notifier_call_chain+0x67/0x110
[  200.752016]  [<ffffffff810d67c1>] raw_notifier_call_chain+0x11/0x20
[  200.752016]  [<ffffffff821bae82>] call_netdevice_notifiers+0x32/0x60
[  200.752016]  [<ffffffff821c2b26>] register_netdevice+0x196/0x300
[  200.752016]  [<ffffffff821c2ca9>] register_netdev+0x19/0x30
[  200.752016]  [<ffffffff81c1c67a>] loopback_net_init+0x4a/0xa0
[  200.752016]  [<ffffffff821b5e62>] ops_init+0x42/0x180
[  200.752016]  [<ffffffff821b600b>] setup_net+0x6b/0x100
[  200.752016]  [<ffffffff821b6466>] copy_net_ns+0x86/0x110
[  200.752016]  [<ffffffff810d5789>] create_new_namespaces+0xd9/0x190
[  200.752016]  [<ffffffff810d5964>] copy_namespaces+0x84/0xc0
[  200.752016]  [<ffffffff810aab0f>] copy_process+0xa2f/0x14c0
[  200.752016]  [<ffffffff810d54de>] ? up_read+0x1e/0x40
[  200.752016]  [<ffffffff810ab653>] do_fork+0x73/0x340
[  200.752016]  [<ffffffff8265f5fc>] ? __mutex_unlock_slowpath+0x10c/0x200
[  200.752016]  [<ffffffff8110c7bd>] ? trace_hardirqs_on+0xd/0x10
[  200.752016]  [<ffffffff82662add>] ? retint_swapgs+0x13/0x1b
[  200.752016]  [<ffffffff810554b3>] sys_clone+0x23/0x30
[  200.752016]  [<ffffffff82663743>] stub_clone+0x13/0x20
[  200.752016]  [<ffffffff826633b9>] ? system_call_fastpath+0x16/0x1b
[  200.752016] Code: dc 82 c6 05 71 b1 32 02 01 e8 47 dc b4 fe e9 6c ff ff ff 66 90 48 c7 c7 20 c6 23 83 e8 14 9e b4 fe 85 c0 0f 85 56 ff ff ff eb c4 <0f> 0b 80 3d 45 b1 32 02 01 90 0f 84 04 ff ff ff be f2 00 00 00
[  200.752016] RIP  [<ffffffff825c3dd6>] get_cfcnfg+0x126/0x180
[  200.752016]  RSP <ffff88000fbabb00>

Instead, we'll first check if the device in the notification is a CAIF device:
 - If it is - the net generic struct in that namespace must have been already
initialized.
 - If not - just ignore it as we don't care about other devices.

Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
---
 net/caif/caif_dev.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/net/caif/caif_dev.c b/net/caif/caif_dev.c
index 673728a..75b9803 100644
--- a/net/caif/caif_dev.c
+++ b/net/caif/caif_dev.c
@@ -372,13 +372,16 @@ static int caif_device_notify(struct notifier_block *me, unsigned long what,
 	int head_room = 0;
 	struct caif_device_entry_list *caifdevs;
 
+	if (dev->type != ARPHRD_CAIF)
+		return 0;
+
 	cfg = get_cfcnfg(dev_net(dev));
 	caifdevs = caif_device_list(dev_net(dev));
 	if (!cfg || !caifdevs)
 		return 0;
 
 	caifd = caif_get(dev);
-	if (caifd == NULL && dev->type != ARPHRD_CAIF)
+	if (caifd == NULL)
 		return 0;
 
 	switch (what) {
-- 
1.7.8.3
