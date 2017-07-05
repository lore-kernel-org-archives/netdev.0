From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net] ip[6]: don't register inet[6]dev when dev is down
Date: Wed,  5 Jul 2017 17:57:25 +0200
Message-ID: <20170705155725.15469-1-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, Hongjun Li <hongjun.li@6wind.com>,
        Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from host.76.145.23.62.rev.coltfrance.com ([62.23.145.76]:55593 "EHLO
        proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751687AbdGEQDx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Jul 2017 12:03:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hongjun Li <hongjun.li@6wind.com>

When the netdev event NETDEV_CHANGEMTU is triggered, the inet[6]dev may be
created even if the corresponding device is down. This may lead to a leak
in the procfs when the device is unregistered, and finally trigger a
backtrace:

[  114.724500] bond1 (unregistering): Released all slaves
[  114.756700] remove_proc_entry: removing non-empty directory 'net/dev_snmp6', leaking at least 'dummy1'
[  114.757335] ------------[ cut here ]------------
[  114.757642] WARNING: CPU: 7 PID: 82 at fs/proc/generic.c:580 remove_proc_entry+0x100/0x113
[  114.758165] Modules linked in: bonding dummy nfsv3 nfs_acl auth_rpcgss oid_registry nfsv4 nfs lockd grace sunrpc fscache i2c_piix4 pcspkr evdev tpm_tis tpm_tis_core tpm parport_pc parport serio_raw button loop ext4 crc16 jbd2 mbcache ide_cd_mod ide_gd_mod cdrom ata_generic ata_piix libata scsi_mod 8139too psmouse piix 8139cp i2c_core ide_core mii floppy
[  114.760191] CPU: 7 PID: 82 Comm: kworker/u16:1 Not tainted 4.12.0-rc7+ #62
[  114.760725] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.7.5-20140531_083030-gandalf 04/01/2014
[  114.761377] Workqueue: netns cleanup_net
[  114.761630] task: ffff88022fbec280 task.stack: ffffc900010cc000
[  114.762008] RIP: 0010:remove_proc_entry+0x100/0x113
[  114.762320] RSP: 0018:ffffc900010cfde0 EFLAGS: 00010282
[  114.762653] RAX: 000000000000005a RBX: ffff88022ee73bd8 RCX: 0000000000000000
[  114.763105] RDX: ffff88023fdd5ba8 RSI: ffff88023fdcde88 RDI: ffff88023fdcde88
[  114.763555] RBP: ffffffff8177bb11 R08: 0000000000000000 R09: 0000000000000002
[  114.764102] R10: ffffc900010cfd10 R11: ffffffff81a272ac R12: ffff880234010e78
[  114.764673] R13: 00000000ffffffff R14: ffffc900010cfe48 R15: ffffffff818a6a98
[  114.765123] FS:  0000000000000000(0000) GS:ffff88023fdc0000(0000) knlGS:0000000000000000
[  114.765655] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  114.766030] CR2: 000055cd729a00c0 CR3: 000000022f1b7000 CR4: 00000000000006e0
[  114.766496] Call Trace:
[  114.766668]  ? ipv6_proc_exit_net+0x2a/0x3e
[  114.766945]  ? ops_exit_list+0x3c/0x4b
[  114.767194]  ? cleanup_net+0x183/0x21f
[  114.767447]  ? process_one_work+0x171/0x2ab
[  114.767724]  ? worker_thread+0x194/0x242
[  114.768028]  ? cancel_delayed_work_sync+0xa/0xa
[  114.768580]  ? kthread+0x101/0x109
[  114.768813]  ? init_completion+0x1d/0x1d
[  114.769073]  ? sysfs_add_file_mode_ns+0xa4/0x145
[  114.769371]  ? __kernfs_create_file+0x25/0x9b
[  114.769651]  ? kernfs_new_node+0x2b/0x4b
[  114.769908]  ? ret_from_fork+0x25/0x30
[  114.770150] Code: 30 4c 8d 80 85 00 00 00 48 8d 8b 85 00 00 00 48 c7 c6 80 1e 62 81 48 c7 c7 3e f6 73 81 31 c0 48 81 c2 85 00 00 00 e8 cb dc f5 ff <0f> ff 48 89 df e8 37 fd ff ff 48 83 c4 10 5b 5d 41 5c c3 41 55
[  114.771343] ---[ end trace b41ba34b465c148a ]---

Here is a reproducer:
  ip netns add foo
  ip -n foo link add dummy1 type dummy
  ip -n foo link add dummy2 type dummy
  iodprobe bonding
  ip -n foo link add bond1 type bond
  ip -n foo link set dev bond1 down
  ip -n foo addr add 10.10.10.1/24 dev bond1
  ip -n foo link set dev bond1 up
  ip -n foo link set dummy1 master bond1
  ip -n foo link set dummy2 master bond1
  ip -n foo link set bond1 mtu 1540
  # Move slaves to init_net
  ip -n foo link set dummy1 netns 1
  ip -n foo link set dummy2 netns 1
  # at this stage, wrong proc entries can be seen here:
  ip netns exec foo ls /proc/sys/net/ipv4/conf/
  ip netns exec foo ls /proc/net/dev_snmp6/
  # the netns removal triggers the backtrace
  ip netns del foo

When a device changes from one netns to another, it's first unregistered,
then the netns reference is updated and the dev is registered in the new
netns. Thus, when a slave moves to another netns, it is first
unregistered. This triggers a NETDEV_UNREGISTER event which is caught by
the bonding driver. The driver calls bond_release(), which calls
dev_set_mtu() and thus triggers NETDEV_CHANGEMTU (the device is still in
the old netns).

Signed-off-by: Hongjun Li <hongjun.li@6wind.com>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/ipv4/devinet.c  | 3 ++-
 net/ipv6/addrconf.c | 3 +++
 2 files changed, 5 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index df14815a3b8c..fe94f48854d3 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1424,7 +1424,8 @@ static int inetdev_event(struct notifier_block *this, unsigned long event,
 				IN_DEV_CONF_SET(in_dev, NOXFRM, 1);
 				IN_DEV_CONF_SET(in_dev, NOPOLICY, 1);
 			}
-		} else if (event == NETDEV_CHANGEMTU) {
+		} else if (event == NETDEV_CHANGEMTU &&
+			   dev->flags & IFF_UP) {
 			/* Re-enabling IP */
 			if (inetdev_valid_mtu(dev->mtu))
 				in_dev = inetdev_init(dev);
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 1d2dbace42ff..034e74a309a0 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -3395,6 +3395,9 @@ static int addrconf_notify(struct notifier_block *this, unsigned long event,
 			break;
 		}
 
+		if (!(dev->flags & IFF_UP))
+			break;
+
 		/* allocate new idev */
 		idev = ipv6_add_dev(dev);
 		if (IS_ERR(idev))
-- 
2.13.2
