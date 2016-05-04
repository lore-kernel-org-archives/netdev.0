From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH net] net: bridge: fix old ioctl unlocked net device walk
Date: Wed,  4 May 2016 16:18:45 +0200
Message-ID: <1462371525-26786-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, stephen@networkplumber.org,
	davem@davemloft.net,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:37883 "EHLO
	mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751289AbcEDOTA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2016 10:19:00 -0400
Received: by mail-wm0-f53.google.com with SMTP id a17so97152221wme.0
        for <netdev@vger.kernel.org>; Wed, 04 May 2016 07:18:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

get_bridge_ifindices() is used from the old "deviceless" bridge ioctl
calls which aren't called with rtnl held. The comment above says that it is
called with rtnl but that is not really the case.
Here's a sample output from a test ASSERT_RTNL() which I put in
get_bridge_ifindices and executed "brctl show":
[  957.422726] RTNL: assertion failed at net/bridge//br_ioctl.c (30)
[  957.422925] CPU: 0 PID: 1862 Comm: brctl Tainted: G        W  O
4.6.0-rc4+ #157
[  957.423009] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996),
BIOS 1.8.1-20150318_183358- 04/01/2014
[  957.423009]  0000000000000000 ffff880058adfdf0 ffffffff8138dec5
0000000000000400
[  957.423009]  ffffffff81ce8380 ffff880058adfe58 ffffffffa05ead32
0000000000000001
[  957.423009]  00007ffec1a444b0 0000000000000400 ffff880053c19130
0000000000008940
[  957.423009] Call Trace:
[  957.423009]  [<ffffffff8138dec5>] dump_stack+0x85/0xc0
[  957.423009]  [<ffffffffa05ead32>]
br_ioctl_deviceless_stub+0x212/0x2e0 [bridge]
[  957.423009]  [<ffffffff81515beb>] sock_ioctl+0x22b/0x290
[  957.423009]  [<ffffffff8126ba75>] do_vfs_ioctl+0x95/0x700
[  957.423009]  [<ffffffff8126c159>] SyS_ioctl+0x79/0x90
[  957.423009]  [<ffffffff8163a4c0>] entry_SYSCALL_64_fastpath+0x23/0xc1

Since it only reads bridge ifindices, we can use rcu to safely walk the net
device list. Also remove the wrong rtnl comment above.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
AFAICT this has been present since the beginning of git history thus no
fixes tag.

 net/bridge/br_ioctl.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/bridge/br_ioctl.c b/net/bridge/br_ioctl.c
index 263b4de4de57..60a3dbfca8a1 100644
--- a/net/bridge/br_ioctl.c
+++ b/net/bridge/br_ioctl.c
@@ -21,18 +21,19 @@
 #include <asm/uaccess.h>
 #include "br_private.h"
 
-/* called with RTNL */
 static int get_bridge_ifindices(struct net *net, int *indices, int num)
 {
 	struct net_device *dev;
 	int i = 0;
 
-	for_each_netdev(net, dev) {
+	rcu_read_lock();
+	for_each_netdev_rcu(net, dev) {
 		if (i >= num)
 			break;
 		if (dev->priv_flags & IFF_EBRIDGE)
 			indices[i++] = dev->ifindex;
 	}
+	rcu_read_unlock();
 
 	return i;
 }
-- 
2.4.11
