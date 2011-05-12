From: =?UTF-8?q?Weiping=20Pan=28=E6=BD=98=E5=8D=AB=E5=B9=B3=29?=
	<panweiping3@gmail.com>
Subject: [PATCH net-next] net:set valid name before calling ndo_init()
Date: Thu, 12 May 2011 21:39:01 +0800
Message-ID: <1305207541-13311-1-git-send-email-panweiping3@gmail.com>
Cc: Pan Weiping <panweiping3@gmail.com>,
	"David S. Miller" <davem@davemloft.net> (maintainer:NETWORKING
	[GENERAL],commit_signer:161/196=82%),
	Eric Dumazet <eric.dumazet@gmail.com> (commit_signer:55/196=28%),
	Tom Herbert <therbert@google.com> (commit_signer:15/196=8%),
	=?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl> (commit_signer:14/196=7%),
	Ben Hutchings <bhutchings@solarflare.com> (commit_signer:13/196=7%),
	netdev@vger.kernel.org (open list:NETWORKING [GENERAL]),
	linux-kernel@vger.kernel.org (open list)
To: unlisted-recipients:; (no To-header on input)
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pan Weiping <panweiping3@gmail.com>

A bug of bonding was invloved by e815d19ffe02bdfda1260949ef2b1806171,
see example 1 and 2.

In register_netdevice(), the name of net_device is not valid until
dev_get_valid_name() is called. But dev->netdev_ops->ndo_init(that is
bond_init) is called before dev_get_valid_name(),
and it uses the invalid name of net_device.

I think register_netdevice() should make sure that the name of net_device is
valid before calling ndo_init().

example 1:
modprobe bonding
ls  /proc/net/bonding/bond%d

ps -eLf
root      3398     2  3398  0    1 21:34 ?        00:00:00 [bond%d]

example 2:
modprobe bonding max_bonds=3

[  170.100292] bonding: Ethernet Channel Bonding Driver: v3.7.1 (April 27, 2011)
[  170.101090] bonding: Warning: either miimon or arp_interval and arp_ip_target module parameters must be specified, otherwise bonding will not detect link failures! see bonding.txt for details.
[  170.102469] ------------[ cut here ]------------
[  170.103150] WARNING: at /home/pwp/net-next-2.6/fs/proc/generic.c:586 proc_register+0x126/0x157()
[  170.104075] Hardware name: VirtualBox
[  170.105065] proc_dir_entry 'bonding/bond%d' already registered
[  170.105613] Modules linked in: bonding(+) sunrpc ipv6 uinput microcode ppdev parport_pc parport joydev e1000 pcspkr i2c_piix4 i2c_core [last unloaded: bonding]
[  170.108397] Pid: 3457, comm: modprobe Not tainted 2.6.39-rc2+ #14
[  170.108935] Call Trace:
[  170.109382]  [<c0438f3b>] warn_slowpath_common+0x6a/0x7f
[  170.109911]  [<c051a42a>] ? proc_register+0x126/0x157
[  170.110329]  [<c0438fc3>] warn_slowpath_fmt+0x2b/0x2f
[  170.110846]  [<c051a42a>] proc_register+0x126/0x157
[  170.111870]  [<c051a4dd>] proc_create_data+0x82/0x98
[  170.112335]  [<f94e6af6>] bond_create_proc_entry+0x3f/0x73 [bonding]
[  170.112905]  [<f94dd806>] bond_init+0x77/0xa5 [bonding]
[  170.113319]  [<c0721ac6>] register_netdevice+0x8c/0x1d3
[  170.113848]  [<f94e0e30>] bond_create+0x6c/0x90 [bonding]
[  170.114322]  [<f94f4763>] bonding_init+0x763/0x7b1 [bonding]
[  170.114879]  [<c0401240>] do_one_initcall+0x76/0x122
[  170.115317]  [<f94f4000>] ? 0xf94f3fff
[  170.115799]  [<c0463f1e>] sys_init_module+0x1286/0x140d
[  170.116879]  [<c07c6d9f>] sysenter_do_call+0x12/0x28
[  170.117404] ---[ end trace 64e4fac3ae5fff1a ]---
[  170.117924] bond%d: Warning: failed to register to debugfs
[  170.128728] ------------[ cut here ]------------
[  170.129360] WARNING: at /home/pwp/net-next-2.6/fs/proc/generic.c:586 proc_register+0x126/0x157()
[  170.130323] Hardware name: VirtualBox
[  170.130797] proc_dir_entry 'bonding/bond%d' already registered
[  170.131315] Modules linked in: bonding(+) sunrpc ipv6 uinput microcode ppdev parport_pc parport joydev e1000 pcspkr i2c_piix4 i2c_core [last unloaded: bonding]
[  170.133731] Pid: 3457, comm: modprobe Tainted: G        W   2.6.39-rc2+ #14
[  170.134308] Call Trace:
[  170.134743]  [<c0438f3b>] warn_slowpath_common+0x6a/0x7f
[  170.135305]  [<c051a42a>] ? proc_register+0x126/0x157
[  170.135820]  [<c0438fc3>] warn_slowpath_fmt+0x2b/0x2f
[  170.137168]  [<c051a42a>] proc_register+0x126/0x157
[  170.137700]  [<c051a4dd>] proc_create_data+0x82/0x98
[  170.138174]  [<f94e6af6>] bond_create_proc_entry+0x3f/0x73 [bonding]
[  170.138745]  [<f94dd806>] bond_init+0x77/0xa5 [bonding]
[  170.139278]  [<c0721ac6>] register_netdevice+0x8c/0x1d3
[  170.139828]  [<f94e0e30>] bond_create+0x6c/0x90 [bonding]
[  170.140361]  [<f94f4763>] bonding_init+0x763/0x7b1 [bonding]
[  170.140927]  [<c0401240>] do_one_initcall+0x76/0x122
[  170.141494]  [<f94f4000>] ? 0xf94f3fff
[  170.141975]  [<c0463f1e>] sys_init_module+0x1286/0x140d
[  170.142463]  [<c07c6d9f>] sysenter_do_call+0x12/0x28
[  170.142974] ---[ end trace 64e4fac3ae5fff1b ]---
[  170.144949] bond%d: Warning: failed to register to debugfs

Signed-off-by: Pan Weiping <panweiping3@gmail.com>
---
 net/core/dev.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 75898a3..f289117 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5412,6 +5412,10 @@ int register_netdevice(struct net_device *dev)
 
 	dev->iflink = -1;
 
+	ret = dev_get_valid_name(dev, dev->name);
+	if (ret < 0)
+		goto out;
+
 	/* Init, if this function is available */
 	if (dev->netdev_ops->ndo_init) {
 		ret = dev->netdev_ops->ndo_init(dev);
@@ -5422,10 +5426,6 @@ int register_netdevice(struct net_device *dev)
 		}
 	}
 
-	ret = dev_get_valid_name(dev, dev->name);
-	if (ret < 0)
-		goto err_uninit;
-
 	dev->ifindex = dev_new_index(net);
 	if (dev->iflink == -1)
 		dev->iflink = dev->ifindex;
-- 
1.7.4
