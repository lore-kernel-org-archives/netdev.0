From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 1/6] switchdev: Execute bridge ndos only for bridge ports
Date: Tue, 18 Oct 2016 18:50:23 +0200
Message-ID: <1476809423-14624-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
        roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
        linville@tuxdriver.com, andy@greyhouse.net, f.fainelli@gmail.com,
        dsa@cumulusnetworks.com, jhs@mojatatu.com,
        vivien.didelot@savoirfairelinux.com, andrew@lunn.ch,
        ivecera@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:36656 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753537AbcJRQu0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2016 12:50:26 -0400
Received: by mail-wm0-f67.google.com with SMTP id o81so308301wma.3
        for <netdev@vger.kernel.org>; Tue, 18 Oct 2016 09:50:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

We recently got the following warning after setting up a vlan device on
top of an offloaded bridge and executing 'bridge link':

WARNING: CPU: 0 PID: 18566 at drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c:81 mlxsw_sp_port_orig_get.part.9+0x55/0x70 [mlxsw_spectrum]
[...]
 CPU: 0 PID: 18566 Comm: bridge Not tainted 4.8.0-rc7 #1
 Hardware name: Mellanox Technologies Ltd. Mellanox switch/Mellanox switch, BIOS 4.6.5 05/21/2015
  0000000000000286 00000000e64ab94f ffff880406e6f8f0 ffffffff8135eaa3
  0000000000000000 0000000000000000 ffff880406e6f930 ffffffff8108c43b
  0000005106e6f988 ffff8803df398840 ffff880403c60108 ffff880406e6f990
 Call Trace:
  [<ffffffff8135eaa3>] dump_stack+0x63/0x90
  [<ffffffff8108c43b>] __warn+0xcb/0xf0
  [<ffffffff8108c56d>] warn_slowpath_null+0x1d/0x20
  [<ffffffffa01420d5>] mlxsw_sp_port_orig_get.part.9+0x55/0x70 [mlxsw_spectrum]
  [<ffffffffa0142195>] mlxsw_sp_port_attr_get+0xa5/0xb0 [mlxsw_spectrum]
  [<ffffffff816f151f>] switchdev_port_attr_get+0x4f/0x140
  [<ffffffff816f15d0>] switchdev_port_attr_get+0x100/0x140
  [<ffffffff816f15d0>] switchdev_port_attr_get+0x100/0x140
  [<ffffffff816f1d6b>] switchdev_port_bridge_getlink+0x5b/0xc0
  [<ffffffff816f2680>] ? switchdev_port_fdb_dump+0x90/0x90
  [<ffffffff815f5427>] rtnl_bridge_getlink+0xe7/0x190
  [<ffffffff8161a1b2>] netlink_dump+0x122/0x290
  [<ffffffff8161b0df>] __netlink_dump_start+0x15f/0x190
  [<ffffffff815f5340>] ? rtnl_bridge_dellink+0x230/0x230
  [<ffffffff815fab46>] rtnetlink_rcv_msg+0x1a6/0x220
  [<ffffffff81208118>] ? __kmalloc_node_track_caller+0x208/0x2c0
  [<ffffffff815f5340>] ? rtnl_bridge_dellink+0x230/0x230
  [<ffffffff815fa9a0>] ? rtnl_newlink+0x890/0x890
  [<ffffffff8161cf54>] netlink_rcv_skb+0xa4/0xc0
  [<ffffffff815f56f8>] rtnetlink_rcv+0x28/0x30
  [<ffffffff8161c92c>] netlink_unicast+0x18c/0x240
  [<ffffffff8161ccdb>] netlink_sendmsg+0x2fb/0x3a0
  [<ffffffff815c5a48>] sock_sendmsg+0x38/0x50
  [<ffffffff815c6031>] SYSC_sendto+0x101/0x190
  [<ffffffff815c7111>] ? __sys_recvmsg+0x51/0x90
  [<ffffffff815c6b6e>] SyS_sendto+0xe/0x10
  [<ffffffff817017f2>] entry_SYSCALL_64_fastpath+0x1a/0xa4

The problem is that the 8021q module propagates the call to
ndo_bridge_getlink() via switchdev ops, but the switch driver doesn't
recognize the netdev, as it's not offloaded.

While we can ignore calls being made to non-bridge ports inside the
driver, a better fix would be to push this check up to the switchdev
layer.

Note that these ndos can be called for non-bridged netdev, but this only
happens in certain PF drivers which don't call the corresponding
switchdev functions anyway.

Fixes: 99f44bb3527b ("mlxsw: spectrum: Enable L3 interfaces on top of bridge devices")
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Reported-by: Tamir Winetroub <tamirw@mellanox.com>
Tested-by: Tamir Winetroub <tamirw@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
Please queue-up to stable as well. Thanks.
---
 net/switchdev/switchdev.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index 02beb35..3b95fe9 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -771,6 +771,9 @@ int switchdev_port_bridge_getlink(struct sk_buff *skb, u32 pid, u32 seq,
 	u32 mask = BR_LEARNING | BR_LEARNING_SYNC | BR_FLOOD;
 	int err;
 
+	if (!netif_is_bridge_port(dev))
+		return -EOPNOTSUPP;
+
 	err = switchdev_port_attr_get(dev, &attr);
 	if (err && err != -EOPNOTSUPP)
 		return err;
@@ -926,6 +929,9 @@ int switchdev_port_bridge_setlink(struct net_device *dev,
 	struct nlattr *afspec;
 	int err = 0;
 
+	if (!netif_is_bridge_port(dev))
+		return -EOPNOTSUPP;
+
 	protinfo = nlmsg_find_attr(nlh, sizeof(struct ifinfomsg),
 				   IFLA_PROTINFO);
 	if (protinfo) {
@@ -959,6 +965,9 @@ int switchdev_port_bridge_dellink(struct net_device *dev,
 {
 	struct nlattr *afspec;
 
+	if (!netif_is_bridge_port(dev))
+		return -EOPNOTSUPP;
+
 	afspec = nlmsg_find_attr(nlh, sizeof(struct ifinfomsg),
 				 IFLA_AF_SPEC);
 	if (afspec)
-- 
2.5.5
