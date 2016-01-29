From: roy.qing.li@gmail.com
Subject: [PATCH] vxlan: fix a out of bounds access in __vxlan_find_mac
Date: Fri, 29 Jan 2016 09:43:47 +0800
Message-ID: <1454031827-23118-1-git-send-email-roy.qing.li@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:33137 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755124AbcA2Bns (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jan 2016 20:43:48 -0500
Received: from localhost (lrq.corp.ad.wrs.com [128.224.162.134])
	by mail.windriver.com (8.15.2/8.15.1) with ESMTP id u0T1hlJb025276
	for <netdev@vger.kernel.org>; Thu, 28 Jan 2016 17:43:48 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

The size of all_zeros_mac is 6 byte, but eth_hash() will access the
8 byte, and KASan reported the below bug:

[ 8596.479031] BUG: KASan: out of bounds access in __vxlan_find_mac+0x24/0x100 at addr ffffffff841514c0
[ 8596.487647] Read of size 8 by task ip/52820
[ 8596.490818] Address belongs to variable all_zeros_mac+0x0/0x40
[ 8596.496051] CPU: 0 PID: 52820 Comm: ip Tainted: G WC 4.1.15 #1
[ 8596.503520] Hardware name: HP ProLiant DL380p Gen8, BIOS P70 02/10/2014
[ 8596.509365] ffffffff841514c0 ffff88007450f0b8 ffffffff822fa5e1 0000000000000032
[ 8596.516112] ffff88007450f150 ffff88007450f138 ffffffff812dd58c ffff88007450f1d8
[ 8596.522856] ffffffff81113b80 0000000000000282 0000000000000001 ffffffff8101ee4d
[ 8596.529599] Call Trace:
[ 8596.530858] [<ffffffff822fa5e1>] dump_stack+0x4f/0x7b
[ 8596.535080] [<ffffffff812dd58c>] kasan_report_error+0x3bc/0x3f0
[ 8596.540258] [<ffffffff81113b80>] ? __lock_acquire+0x90/0x2140
[ 8596.545245] [<ffffffff8101ee4d>] ? save_stack_trace+0x2d/0x80
[ 8596.550234] [<ffffffff812dda70>] kasan_report+0x40/0x50
[ 8596.554647] [<ffffffff81b211e4>] ? __vxlan_find_mac+0x24/0x100
[ 8596.559729] [<ffffffff812dc399>] __asan_load8+0x69/0xa0
[ 8596.564141] [<ffffffff81b211e4>] __vxlan_find_mac+0x24/0x100
[ 8596.569033] [<ffffffff81b2683d>] vxlan_fdb_create+0x9d/0x570

it can be fixed by enlarging the all_zeros_mac to 8 byte, although it is
harmless; eth_hash() will be called in other place with the memory which
is larger and equal to 8 byte.

Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 drivers/net/vxlan.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 2d88c79..b733f093 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -73,7 +73,7 @@ MODULE_PARM_DESC(log_ecn_error, "Log packets received with corrupted ECN");
 static int vxlan_net_id;
 static struct rtnl_link_ops vxlan_link_ops;
 
-static const u8 all_zeros_mac[ETH_ALEN];
+static const u8 all_zeros_mac[ETH_ALEN + 2];
 
 static int vxlan_sock_add(struct vxlan_dev *vxlan);
 
-- 
2.1.4
