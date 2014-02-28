From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net] vlan: don't allow to add VLAN on VLAN device
Date: Fri, 28 Feb 2014 10:08:28 +0800
Message-ID: <530FEF9C.7070106@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I run these steps:

modprobe 8021q
vconfig add eth2 20
vconfig add eth2.20 20
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

The reason is that if add vlan on vlan dev, the vlan dev will create vlan_info,
then the notification will let the real dev to run dev_set_rx_mode() and hold
netif_addr_lock, and then the real dev will call ndo_set_rx_mode(), if the real
dev is vlan dev, the ndo_set_rx_mode() will hold netif_addr_lock again, so deadlock
happened.

Don't allow to add vlan on vlan dev to fix this problem.

Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 net/8021q/vlan.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index 16fb0f4..052d201 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -132,6 +132,11 @@ int vlan_check_real_dev(struct net_device *real_dev,
 		return -EOPNOTSUPP;
 	}
 
+	if (real_dev->priv_flags & IFF_802_1Q_VLAN) {
+		pr_info("Don't add VLAN on VLAN device %s\n", name);
+		return -EOPNOTSUPP;
+        }
+
 	if (vlan_find_dev(real_dev, protocol, vlan_id) != NULL)
 		return -EEXIST;
 
-- 
1.8.0
