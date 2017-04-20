From: Mahesh Bandewar <mahesh@bandewar.net>
Subject: [PATCHv2 next] bonding: fix wq initialization for links created via netlink
Date: Thu, 20 Apr 2017 12:49:24 -0700
Message-ID: <20170420194924.20829-1-mahesh@bandewar.net>
Cc: netdev <netdev@vger.kernel.org>,
        Mahesh Bandewar <mahesh@bandewar.net>,
        Mahesh Bandewar <maheshb@google.com>
To: Jay Vosburgh <j.vosburgh@gmail.com>,
        Andy Gospodarek <andy@greyhouse.net>,
        Veaceslav Falico <vfalico@gmail.com>,
        Nikolay Aleksandrov <nikolay@redhat.com>,
        David Miller <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>, Joe Stringer <joe@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:34069 "EHLO
        mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S947219AbdDTTt3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 15:49:29 -0400
Received: by mail-oi0-f66.google.com with SMTP id y11so10905369oie.1
        for <netdev@vger.kernel.org>; Thu, 20 Apr 2017 12:49:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <maheshb@google.com>

Earlier patch 4493b81bea ("bonding: initialize work-queues during
creation of bond") moved the work-queue initialization from bond_open()
to bond_create(). However this caused the link those are created using
netlink 'create bond option' (ip link add bondX type bond); create the
new trunk without initializing work-queues. Prior to the above mentioned
change, ndo_open was in both paths and things worked correctly. The
consequence is visible in the report shared by Joe Stringer -

I've noticed that this patch breaks bonding within namespaces if
you're not careful to perform device cleanup correctly.

Here's my repro script, you can run on any net-next with this patch
and you'll start seeing some weird behaviour:

ip netns add foo
ip li add veth0 type veth peer name veth0+ netns foo
ip li add veth1 type veth peer name veth1+ netns foo
ip netns exec foo ip li add bond0 type bond
ip netns exec foo ip li set dev veth0+ master bond0
ip netns exec foo ip li set dev veth1+ master bond0
ip netns exec foo ip addr add dev bond0 192.168.0.1/24
ip netns exec foo ip li set dev bond0 up
ip li del dev veth0
ip li del dev veth1

The second to last command segfaults, last command hangs. rtnl is now
permanently locked. It's not a problem if you take bond0 down before
deleting veths, or delete bond0 before deleting veths. If you delete
either end of the veth pair as per above, either inside or outside the
namespace, it hits this problem.

Here's some kernel logs:
[ 1221.801610] bond0: Enslaving veth0+ as an active interface with an up link
[ 1224.449581] bond0: Enslaving veth1+ as an active interface with an up link
[ 1281.193863] bond0: Releasing backup interface veth0+
[ 1281.193866] bond0: the permanent HWaddr of veth0+ -
16:bf:fb:e0:b8:43 - is still in use by bond0 - set the HWaddr of
veth0+ to a different address to avoid conflicts
[ 1281.193867] ------------[ cut here ]------------
[ 1281.193873] WARNING: CPU: 0 PID: 2024 at kernel/workqueue.c:1511
__queue_delayed_work+0x13f/0x150
[ 1281.193873] Modules linked in: bonding veth openvswitch nf_nat_ipv6
nf_nat_ipv4 nf_nat autofs4 nfsd auth_rpcgss nfs_acl binfmt_misc nfs
lockd grace sunrpc fscache ppdev vmw_balloon coretemp psmouse
serio_raw vmwgfx ttm drm_kms_helper vmw_vmci netconsole parport_pc
configfs drm i2c_piix4 fb_sys_fops syscopyarea sysfillrect sysimgblt
shpchp mac_hid nf_conntrack_ipv6 nf_defrag_ipv6 nf_conntrack_ipv4
nf_defrag_ipv4 nf_conntrack libcrc32c lp parport hid_generic usbhid
hid mptspi mptscsih e1000 mptbase ahci libahci
[ 1281.193905] CPU: 0 PID: 2024 Comm: ip Tainted: G        W
4.10.0-bisect-bond-v0.14 #37
[ 1281.193906] Hardware name: VMware, Inc. VMware Virtual
Platform/440BX Desktop Reference Platform, BIOS 6.00 09/30/2014
[ 1281.193906] Call Trace:
[ 1281.193912]  dump_stack+0x63/0x89
[ 1281.193915]  __warn+0xd1/0xf0
[ 1281.193917]  warn_slowpath_null+0x1d/0x20
[ 1281.193918]  __queue_delayed_work+0x13f/0x150
[ 1281.193920]  queue_delayed_work_on+0x27/0x40
[ 1281.193929]  bond_change_active_slave+0x25b/0x670 [bonding]
[ 1281.193932]  ? synchronize_rcu_expedited+0x27/0x30
[ 1281.193935]  __bond_release_one+0x489/0x510 [bonding]
[ 1281.193939]  ? addrconf_notify+0x1b7/0xab0
[ 1281.193942]  bond_netdev_event+0x2c5/0x2e0 [bonding]
[ 1281.193944]  ? netconsole_netdev_event+0x124/0x190 [netconsole]
[ 1281.193947]  notifier_call_chain+0x49/0x70
[ 1281.193948]  raw_notifier_call_chain+0x16/0x20
[ 1281.193950]  call_netdevice_notifiers_info+0x35/0x60
[ 1281.193951]  rollback_registered_many+0x23b/0x3e0
[ 1281.193953]  unregister_netdevice_many+0x24/0xd0
[ 1281.193955]  rtnl_delete_link+0x3c/0x50
[ 1281.193956]  rtnl_dellink+0x8d/0x1b0
[ 1281.193960]  rtnetlink_rcv_msg+0x95/0x220
[ 1281.193962]  ? __kmalloc_node_track_caller+0x35/0x280
[ 1281.193964]  ? __netlink_lookup+0xf1/0x110
[ 1281.193966]  ? rtnl_newlink+0x830/0x830
[ 1281.193967]  netlink_rcv_skb+0xa7/0xc0
[ 1281.193969]  rtnetlink_rcv+0x28/0x30
[ 1281.193970]  netlink_unicast+0x15b/0x210
[ 1281.193971]  netlink_sendmsg+0x319/0x390
[ 1281.193974]  sock_sendmsg+0x38/0x50
[ 1281.193975]  ___sys_sendmsg+0x25c/0x270
[ 1281.193978]  ? mem_cgroup_commit_charge+0x76/0xf0
[ 1281.193981]  ? page_add_new_anon_rmap+0x89/0xc0
[ 1281.193984]  ? lru_cache_add_active_or_unevictable+0x35/0xb0
[ 1281.193985]  ? __handle_mm_fault+0x4e9/0x1170
[ 1281.193987]  __sys_sendmsg+0x45/0x80
[ 1281.193989]  SyS_sendmsg+0x12/0x20
[ 1281.193991]  do_syscall_64+0x6e/0x180
[ 1281.193993]  entry_SYSCALL64_slow_path+0x25/0x25
[ 1281.193995] RIP: 0033:0x7f6ec122f5a0
[ 1281.193995] RSP: 002b:00007ffe69e89c48 EFLAGS: 00000246 ORIG_RAX:
000000000000002e
[ 1281.193997] RAX: ffffffffffffffda RBX: 00007ffe69e8dd60 RCX: 00007f6ec122f5a0
[ 1281.193997] RDX: 0000000000000000 RSI: 00007ffe69e89c90 RDI: 0000000000000003
[ 1281.193998] RBP: 00007ffe69e89c90 R08: 0000000000000000 R09: 0000000000000003
[ 1281.193999] R10: 00007ffe69e89a10 R11: 0000000000000246 R12: 0000000058f14b9f
[ 1281.193999] R13: 0000000000000000 R14: 00000000006473a0 R15: 00007ffe69e8e450
[ 1281.194001] ---[ end trace 713a77486cbfbfa3 ]---

Fixes: 4493b81bea ("bonding: initialize work-queues during creation of bond")
Reported-by: Joe Stringer <joe@ovn.org>
Tested-by: Joe Stringer <joe@ovn.org>
Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
v1 -> v2 : fixed 'if' condition

 drivers/net/bonding/bond_main.c    | 2 +-
 drivers/net/bonding/bond_netlink.c | 5 +++++
 include/net/bonding.h              | 1 +
 3 files changed, 7 insertions(+), 1 deletion(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 6bd3b50faf48..e549bf6f5cac 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3243,7 +3243,7 @@ u32 bond_xmit_hash(struct bonding *bond, struct sk_buff *skb)
 
 /*-------------------------- Device entry points ----------------------------*/
 
-static void bond_work_init_all(struct bonding *bond)
+void bond_work_init_all(struct bonding *bond)
 {
 	INIT_DELAYED_WORK(&bond->mcast_work,
 			  bond_resend_igmp_join_requests_delayed);
diff --git a/drivers/net/bonding/bond_netlink.c b/drivers/net/bonding/bond_netlink.c
index b8df0f5e8c25..c502c139d3bc 100644
--- a/drivers/net/bonding/bond_netlink.c
+++ b/drivers/net/bonding/bond_netlink.c
@@ -449,6 +449,11 @@ static int bond_newlink(struct net *src_net, struct net_device *bond_dev,
 	err = register_netdevice(bond_dev);
 
 	netif_carrier_off(bond_dev);
+	if (!err) {
+		struct bonding *bond = netdev_priv(bond_dev);
+
+		bond_work_init_all(bond);
+	}
 
 	return err;
 }
diff --git a/include/net/bonding.h b/include/net/bonding.h
index 04a21e8048be..b00508d22e0a 100644
--- a/include/net/bonding.h
+++ b/include/net/bonding.h
@@ -614,6 +614,7 @@ struct bond_vlan_tag *bond_verify_device_path(struct net_device *start_dev,
 					      int level);
 int bond_update_slave_arr(struct bonding *bond, struct slave *skipslave);
 void bond_slave_arr_work_rearm(struct bonding *bond, unsigned long delay);
+void bond_work_init_all(struct bonding *bond);
 
 #ifdef CONFIG_PROC_FS
 void bond_create_proc_entry(struct bonding *bond);
-- 
2.12.2.816.g2cccc81164-goog
