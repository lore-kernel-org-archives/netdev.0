From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net v2] bridge: flush br's address entry in fdb
 when remove the bridge dev
Date: Wed, 20 Nov 2013 09:58:02 +0800
Message-ID: <528C172A.3090004@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Stephen Hemminger <stephen@networkplumber.org>, "David S. Miller"
	<davem@davemloft.net>, <bridge@lists.linux-foundation.org>, Netdev
	<netdev@vger.kernel.org>, Toshiaki Makita <toshiaki.makita1@gmail.com>,
	Vlad Yasevich <vyasevich@gmail.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

>From 241ddeaad73c7ed9e376a4b0926e79bdc3df9f58 Mon Sep 17 00:00:00 2001
From: Ding Tianhong <dingtianhong@huawei.com>
Date: Sat, 7 Dec 2013 22:12:05 +0800
Subject: [PATCH] bridge: flush br's address entry in fdb when remove the
 bridge dev

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

--------------------------- cut here -------------------------------

The reason is that when the bridge dev's address is changed, the
br_fdb_change_mac_address() will add new address in fdb, but when
the bridge was removed, the address entry in the fdb did not free,
the bridge_fdb_cache still has objects when destroy the cache, Fix
this by flushing the bridge address entry when removing the bridge.

v2: according to the Toshiaki Makita and Vlad's suggestion, I only
    delete the vlan0 entry, it still have a leak here if the vlan id
    is other number, so I need to call fdb_delete_by_port(br, NULL, 1)
    to flush all entries whose dst is NULL for the bridge.

Suggested-by: Toshiaki Makita <toshiaki.makita1@gmail.com>
Suggested-by: Vlad Yasevich <vyasevich@gmail.com>
Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 net/bridge/br_if.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index 6e6194f..4bf02ad 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -172,6 +172,8 @@ void br_dev_delete(struct net_device *dev, struct list_head *head)
 		del_nbp(p);
 	}
 
+	br_fdb_delete_by_port(br, NULL, 1);
+
 	br_vlan_flush(br);
 	del_timer_sync(&br->gc_timer);
 
-- 
1.8.0
