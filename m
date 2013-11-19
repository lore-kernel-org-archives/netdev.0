From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net RESEND] bridge: flush br's address entry in fdb when remove
 the bridge dev
Date: Tue, 19 Nov 2013 10:57:02 +0800
Message-ID: <528AD37E.1050105@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	<bridge@lists.linux-foundation.org>,
	Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:5405 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751343Ab3KSC7T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Nov 2013 21:59:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the following commands are executed:

brctl addbr br0
ifconfig br0 hw ether <addr>
rmmod bridge

The calltrace will occur:

[  563.312114] device eth1 left promiscuous mode
[  563.312188] br0: port 1(eth1) entered disabled state
[  563.468190] kmem_cache_destroy bridge_fdb_cache: Slab cache still has objects
[  563.468197] CPU: 6 PID: 6982 Comm: rmmod Tainted: G           O 3.12.0-0.7-default+ #9
[  563.468199] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2007
[  563.468200]  0000000000000880 ffff88010f111e98 ffffffff814d1c92 ffff88010f111eb8
[  563.468204]  ffffffff81148efd ffff88010f111eb8 0000000000000000 ffff88010f111ec8
[  563.468206]  ffffffffa062a270 ffff88010f111ed8 ffffffffa063ac76 ffff88010f111f78
[  563.468209] Call Trace:
[  563.468218]  [<ffffffff814d1c92>] dump_stack+0x6a/0x78
[  563.468234]  [<ffffffff81148efd>] kmem_cache_destroy+0xfd/0x100
[  563.468242]  [<ffffffffa062a270>] br_fdb_fini+0x10/0x20 [bridge]
[  563.468247]  [<ffffffffa063ac76>] br_deinit+0x4e/0x50 [bridge]
[  563.468254]  [<ffffffff810c7dc9>] SyS_delete_module+0x199/0x2b0
[  563.468259]  [<ffffffff814e0922>] system_call_fastpath+0x16/0x1b
[  570.377958] Bridge firewalling registered

------------------------------------------------

The reason is that when the bridge dev's address is changed, the
br_fdb_change_mac_address() will add new address in fdb, but when
the bridge was removed, the address entry in the fdb did not free,
the bridge_fdb_cache still has objects when destroy the cache, Fix
this by flushing the bridge address entry when removing the bridge.

Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 net/bridge/br_if.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index 6e6194f..98084d8 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -172,6 +172,10 @@ void br_dev_delete(struct net_device *dev, struct list_head *head)
 		del_nbp(p);
 	}
 
+	spin_lock_bh(&br->hash_lock);
+	fdb_delete_by_addr(br, br->dev->dev_addr, 0);
+	spin_unlock_bh(&br->hash_lock);
+
 	br_vlan_flush(br);
 	del_timer_sync(&br->gc_timer);
 
-- 
1.8.0
