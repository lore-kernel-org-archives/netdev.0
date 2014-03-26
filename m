From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net v3] vlan: Fix lockdep warning when vlan dev handle notification
Date: Wed, 26 Mar 2014 11:11:53 +0800
Message-ID: <53324579.8080602@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Ben Hutchings <ben@decadent.org.uk>,
	John Fastabend <john.r.fastabend@intel.com>,
	Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	"Florian Fainelli" <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:10107 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753727AbaCZDNv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 23:13:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When I open the LOCKDEP config and run these steps:

modprobe 8021q
vconfig add eth2 20
vconfig add eth2.20 30
ifconfig eth2 xx.xx.xx.xx

then the Call Trace happened:

[32524.386288] =============================================
[32524.386293] [ INFO: possible recursive locking detected ]
[32524.386298] 3.14.0-rc2-0.7-default+ #35 Tainted: G           O
[32524.386302] ---------------------------------------------
[32524.386306] ifconfig/3103 is trying to acquire lock:
[32524.386310]  (&vlan_netdev_addr_lock_key/1){+.....}, at: [<ffffffff814275f4>] dev_mc_sync+0x64/0xb0
[32524.386326]
[32524.386326] but task is already holding lock:
[32524.386330]  (&vlan_netdev_addr_lock_key/1){+.....}, at: [<ffffffff8141af83>] dev_set_rx_mode+0x23/0x40
[32524.386341]
[32524.386341] other info that might help us debug this:
[32524.386345]  Possible unsafe locking scenario:
[32524.386345]
[32524.386350]        CPU0
[32524.386352]        ----
[32524.386354]   lock(&vlan_netdev_addr_lock_key/1);
[32524.386359]   lock(&vlan_netdev_addr_lock_key/1);
[32524.386364]
[32524.386364]  *** DEADLOCK ***
[32524.386364]
[32524.386368]  May be due to missing lock nesting notation
[32524.386368]
[32524.386373] 2 locks held by ifconfig/3103:
[32524.386376]  #0:  (rtnl_mutex){+.+.+.}, at: [<ffffffff81431d42>] rtnl_lock+0x12/0x20
[32524.386387]  #1:  (&vlan_netdev_addr_lock_key/1){+.....}, at: [<ffffffff8141af83>] dev_set_rx_mode+0x23/0x40
[32524.386398]
[32524.386398] stack backtrace:
[32524.386403] CPU: 1 PID: 3103 Comm: ifconfig Tainted: G           O 3.14.0-rc2-0.7-default+ #35
[32524.386409] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2007
[32524.386414]  ffffffff81ffae40 ffff8800d9625ae8 ffffffff814f68a2 ffff8800d9625bc8
[32524.386421]  ffffffff810a35fb ffff8800d8a8d9d0 00000000d9625b28 ffff8800d8a8e5d0
[32524.386428]  000003cc00000000 0000000000000002 ffff8800d8a8e5f8 0000000000000000
[32524.386435] Call Trace:
[32524.386441]  [<ffffffff814f68a2>] dump_stack+0x6a/0x78
[32524.386448]  [<ffffffff810a35fb>] __lock_acquire+0x7ab/0x1940
[32524.386454]  [<ffffffff810a323a>] ? __lock_acquire+0x3ea/0x1940
[32524.386459]  [<ffffffff810a4874>] lock_acquire+0xe4/0x110
[32524.386464]  [<ffffffff814275f4>] ? dev_mc_sync+0x64/0xb0
[32524.386471]  [<ffffffff814fc07a>] _raw_spin_lock_nested+0x2a/0x40
[32524.386476]  [<ffffffff814275f4>] ? dev_mc_sync+0x64/0xb0
[32524.386481]  [<ffffffff814275f4>] dev_mc_sync+0x64/0xb0
[32524.386489]  [<ffffffffa0500cab>] vlan_dev_set_rx_mode+0x2b/0x50 [8021q]
[32524.386495]  [<ffffffff8141addf>] __dev_set_rx_mode+0x5f/0xb0
[32524.386500]  [<ffffffff8141af8b>] dev_set_rx_mode+0x2b/0x40
[32524.386506]  [<ffffffff8141b3cf>] __dev_open+0xef/0x150
[32524.386511]  [<ffffffff8141b177>] __dev_change_flags+0xa7/0x190
[32524.386516]  [<ffffffff8141b292>] dev_change_flags+0x32/0x80
[32524.386524]  [<ffffffff8149ca56>] devinet_ioctl+0x7d6/0x830
[32524.386532]  [<ffffffff81437b0b>] ? dev_ioctl+0x34b/0x660
[32524.386540]  [<ffffffff814a05b0>] inet_ioctl+0x80/0xa0
[32524.386550]  [<ffffffff8140199d>] sock_do_ioctl+0x2d/0x60
[32524.386558]  [<ffffffff81401a52>] sock_ioctl+0x82/0x2a0
[32524.386568]  [<ffffffff811a7123>] do_vfs_ioctl+0x93/0x590
[32524.386578]  [<ffffffff811b2705>] ? rcu_read_lock_held+0x45/0x50
[32524.386586]  [<ffffffff811b39e5>] ? __fget_light+0x105/0x110
[32524.386594]  [<ffffffff811a76b1>] SyS_ioctl+0x91/0xb0
[32524.386604]  [<ffffffff815057e2>] system_call_fastpath+0x16/0x1b

========================================================================

The reason is that all of the addr_lock_key for vlan dev have the same class,
so if we change the status for vlan dev, the vlan dev and its real dev will
hold the same class of addr_lock_key together, so the warning happened.

we should distinguish the lock depth for vlan dev and its real dev.

v1->v2: Convert the vlan_netdev_addr_lock_key to an array of eight elements, which
	could support to add 8 vlan id on a same vlan dev, I think it is enough for current
	scene, because a netdev's name is limited to IFNAMSIZ which could not hold 8 vlan id,
	and the vlan dev would not meet the same class key with its real dev.

	The new function vlan_dev_get_lockdep_subkey() will return the subkey and make the vlan
	dev could get a suitable class key.

v2->v3: According David's suggestion, I use the subclass to distinguish the lock key for vlan dev
	and its real dev, but it make no sense, because the difference for subclass in the
	lock_class_key doesn't mean that the difference class for lock_key, so I use lock_depth
	to distinguish the different depth for every vlan dev, the same depth of the vlan dev
	could have the same lock_class_key, I import the MAX_LOCK_DEPTH from the include/linux/sched.h,
	I think it is enough here, the lockdep should never exceed that value.

Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 net/8021q/vlan_dev.c | 27 +++++++++++++++++++++++++--
 1 file changed, 25 insertions(+), 2 deletions(-)

diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 4f3e907..6295bf2 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -505,7 +505,7 @@ static void vlan_dev_set_rx_mode(struct net_device *vlan_dev)
  * separate class since they always nest.
  */
 static struct lock_class_key vlan_netdev_xmit_lock_key;
-static struct lock_class_key vlan_netdev_addr_lock_key;
+static struct lock_class_key vlan_netdev_addr_lock_key[MAX_LOCK_DEPTH];
 
 static void vlan_dev_set_lockdep_one(struct net_device *dev,
 				     struct netdev_queue *txq,
@@ -516,10 +516,33 @@ static void vlan_dev_set_lockdep_one(struct net_device *dev,
 				       *(int *)_subclass);
 }
 
+static int vlan_calculate_lockdep_depth(struct net_device *dev)
+{
+	int lockdep_depth = 0;
+	struct net_device *real_dev;
+
+	real_dev = vlan_dev_priv(dev)->real_dev;
+
+	while(is_vlan_dev(real_dev)) {
+		lockdep_depth ++;
+		real_dev = vlan_dev_priv(real_dev)->real_dev;
+	}
+
+	return lockdep_depth;
+}
+
 static void vlan_dev_set_lockdep_class(struct net_device *dev, int subclass)
 {
+	int lock_depth = 0;
+
+	lock_depth = vlan_calculate_lockdep_depth(dev);
+
+	/* Ran out of static storage for vlan_netdev_addr_lock_key */
+	if (DEBUG_LOCKS_WARN_ON(lock_depth >= MAX_LOCK_DEPTH))
+		return;
+
 	lockdep_set_class_and_subclass(&dev->addr_list_lock,
-				       &vlan_netdev_addr_lock_key,
+				       &vlan_netdev_addr_lock_key[lock_depth],
 				       subclass);
 	netdev_for_each_tx_queue(dev, vlan_dev_set_lockdep_one, &subclass);
 }
-- 
1.8.0
