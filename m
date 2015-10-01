From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next] vrf: fix a kernel warning
Date: Thu,  1 Oct 2015 15:21:08 -0700
Message-ID: <1443738068-30750-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:34701 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750988AbbJAWVT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Oct 2015 18:21:19 -0400
Received: by padhy16 with SMTP id hy16so86803756pad.1
        for <netdev@vger.kernel.org>; Thu, 01 Oct 2015 15:21:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This fixes:

 tried to remove device ip6gre0 from (null)
 ------------[ cut here ]------------
 kernel BUG at net/core/dev.c:5219!
 invalid opcode: 0000 [#1] SMP DEBUG_PAGEALLOC
 CPU: 3 PID: 161 Comm: kworker/u8:2 Not tainted 4.3.0-rc2+ #1142
 Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
 Workqueue: netns cleanup_net
 task: ffff8800d784a9c0 ti: ffff8800d74a4000 task.ti: ffff8800d74a4000
 RIP: 0010:[<ffffffff817f0797>]  [<ffffffff817f0797>] __netdev_adjacent_dev_remove+0x40/0xec
 RSP: 0018:ffff8800d74a7a98  EFLAGS: 00010282
 RAX: 000000000000002a RBX: 0000000000000000 RCX: 0000000000000000
 RDX: ffff88011adcf701 RSI: ffff88011adccbf8 RDI: ffff88011adccbf8
 RBP: ffff8800d74a7ab8 R08: 0000000000000001 R09: 0000000000000000
 R10: ffffffff81d190ff R11: 00000000ffffffff R12: ffff8800d599e7c0
 R13: 0000000000000000 R14: ffff8800d599e890 R15: ffffffff82385e00
 FS:  0000000000000000(0000) GS:ffff88011ac00000(0000) knlGS:0000000000000000
 CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
 CR2: 00007ffd6f003000 CR3: 000000000220c000 CR4: 00000000000006e0
 Stack:
  0000000000000000 ffff8800d599e7c0 0000000000000b00 ffff8800d599e8a0
  ffff8800d74a7ad8 ffffffff817f0861 0000000000000000 ffff8800d599e7c0
  ffff8800d74a7af8 ffffffff817f088f 0000000000000000 ffff8800d599e7c0
 Call Trace:
  [<ffffffff817f0861>] __netdev_adjacent_dev_unlink+0x1e/0x35
  [<ffffffff817f088f>] __netdev_adjacent_dev_unlink_neighbour+0x17/0x41
  [<ffffffff817f56e6>] netdev_upper_dev_unlink+0x6c/0x13d
  [<ffffffff81674a3d>] vrf_del_slave+0x26/0x7d
  [<ffffffff81674ac3>] vrf_device_event+0x2f/0x34
  [<ffffffff81098c40>] notifier_call_chain+0x75/0x9c
  [<ffffffff81098fa2>] raw_notifier_call_chain+0x14/0x16
  [<ffffffff817ee129>] call_netdevice_notifiers_info+0x52/0x59
  [<ffffffff817f179d>] call_netdevice_notifiers+0x13/0x15
  [<ffffffff817f6f18>] rollback_registered_many+0x14f/0x24f
  [<ffffffff817f70f2>] unregister_netdevice_many+0x19/0x64
  [<ffffffff819a2455>] ip6gre_exit_net+0x163/0x177
  [<ffffffff817eb019>] ops_exit_list+0x44/0x55
  [<ffffffff817ebcb7>] cleanup_net+0x193/0x226
  [<ffffffff81091e1c>] process_one_work+0x26c/0x4d8
  [<ffffffff81091d20>] ? process_one_work+0x170/0x4d8
  [<ffffffff81092296>] worker_thread+0x1df/0x2c2
  [<ffffffff810920b7>] ? process_scheduled_works+0x2f/0x2f
  [<ffffffff810920b7>] ? process_scheduled_works+0x2f/0x2f
  [<ffffffff81097a20>] kthread+0xd4/0xdc
  [<ffffffff810bc523>] ? trace_hardirqs_on_caller+0x17d/0x199
  [<ffffffff8109794c>] ? __kthread_parkme+0x83/0x83
  [<ffffffff81a5240f>] ret_from_fork+0x3f/0x70
  [<ffffffff8109794c>] ? __kthread_parkme+0x83/0x83

Fixes: 93a7e7e837af ("net: Remove the now unused vrf_ptr")
Cc: David Ahern <dsa@cumulusnetworks.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 drivers/net/vrf.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index 64f2ab6..4743963 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -672,7 +672,7 @@ static int vrf_device_event(struct notifier_block *unused,
 	if (event == NETDEV_UNREGISTER) {
 		struct net_device *vrf_dev;
 
-		if (netif_is_l3_master(dev))
+		if (!vrf_is_slave(dev) || netif_is_l3_master(dev))
 			goto out;
 
 		vrf_dev = netdev_master_upper_dev_get(dev);
-- 
1.8.3.1
