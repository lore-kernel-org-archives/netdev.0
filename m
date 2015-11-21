From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net] vrf: fix double free and memory corruption on register_netdevice failure
Date: Sat, 21 Nov 2015 19:46:19 +0100
Message-ID: <1448131579-20525-1-git-send-email-razor@blackwall.org>
Cc: dsa@cumulusnetworks.com, shm@cumulusnetworks.com,
	davem@davemloft.net,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:35106 "EHLO
	mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751156AbbKUSrb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Nov 2015 13:47:31 -0500
Received: by wmuu63 with SMTP id u63so11688232wmu.0
        for <netdev@vger.kernel.org>; Sat, 21 Nov 2015 10:47:25 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

When vrf's ->newlink is called, if register_netdevice() fails then it
does free_netdev(), but that's also done by rtnl_newlink() so a second
free happens and memory gets corrupted, to reproduce execute the
following line a couple of times (1 - 5 usually is enough):
$ for i in `seq 1 5`; do ip link add vrf: type vrf table 1; done;
This works because we fail in register_netdevice() because of the wrong
name "vrf:".

And here's a trace of one crash:
[   28.792157] ------------[ cut here ]------------
[   28.792407] kernel BUG at fs/namei.c:246!
[   28.792608] invalid opcode: 0000 [#1] SMP
[   28.793240] Modules linked in: vrf nfsd auth_rpcgss oid_registry
nfs_acl nfs lockd grace sunrpc crct10dif_pclmul crc32_pclmul
crc32c_intel qxl drm_kms_helper ttm drm aesni_intel aes_x86_64 psmouse
glue_helper lrw evdev gf128mul i2c_piix4 ablk_helper cryptd ppdev
parport_pc parport serio_raw pcspkr virtio_balloon virtio_console
i2c_core acpi_cpufreq button 9pnet_virtio 9p 9pnet fscache ipv6 autofs4
ext4 crc16 mbcache jbd2 virtio_blk virtio_net sg sr_mod cdrom
ata_generic ehci_pci uhci_hcd ehci_hcd e1000 usbcore usb_common ata_piix
libata virtio_pci virtio_ring virtio scsi_mod floppy
[   28.796016] CPU: 0 PID: 1148 Comm: ld-linux-x86-64 Not tainted
4.4.0-rc1+ #24
[   28.796016] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996),
BIOS 1.8.1-20150318_183358- 04/01/2014
[   28.796016] task: ffff8800352561c0 ti: ffff88003592c000 task.ti:
ffff88003592c000
[   28.796016] RIP: 0010:[<ffffffff812187b3>]  [<ffffffff812187b3>]
putname+0x43/0x60
[   28.796016] RSP: 0018:ffff88003592fe88  EFLAGS: 00010246
[   28.796016] RAX: 0000000000000000 RBX: ffff8800352561c0 RCX:
0000000000000001
[   28.796016] RDX: 0000000000000000 RSI: 0000000000000000 RDI:
ffff88003784f000
[   28.796016] RBP: ffff88003592ff08 R08: 0000000000000001 R09:
0000000000000000
[   28.796016] R10: 0000000000000000 R11: 0000000000000001 R12:
0000000000000000
[   28.796016] R13: 000000000000047c R14: ffff88003784f000 R15:
ffff8800358c4a00
[   28.796016] FS:  0000000000000000(0000) GS:ffff88003fc00000(0000)
knlGS:0000000000000000
[   28.796016] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   28.796016] CR2: 00007ffd583bc2d9 CR3: 0000000035a99000 CR4:
00000000000406f0
[   28.796016] Stack:
[   28.796016]  ffffffff8121045d ffffffff812102d3 ffff8800352561c0
ffff880035a91660
[   28.796016]  ffff8800008a9880 0000000000000000 ffffffff81a49940
00ffffff81218684
[   28.796016]  ffff8800352561c0 000000000000047c 0000000000000000
ffff880035b36d80
[   28.796016] Call Trace:
[   28.796016]  [<ffffffff8121045d>] ?
do_execveat_common.isra.34+0x74d/0x930
[   28.796016]  [<ffffffff812102d3>] ?
do_execveat_common.isra.34+0x5c3/0x930
[   28.796016]  [<ffffffff8121066c>] do_execve+0x2c/0x30
[   28.796016]  [<ffffffff810939a0>]
call_usermodehelper_exec_async+0xf0/0x140
[   28.796016]  [<ffffffff810938b0>] ? umh_complete+0x40/0x40
[   28.796016]  [<ffffffff815cb1af>] ret_from_fork+0x3f/0x70
[   28.796016] Code: 48 8d 47 1c 48 89 e5 53 48 8b 37 48 89 fb 48 39 c6
74 1a 48 8b 3d 7e e9 8f 00 e8 49 fa fc ff 48 89 df e8 f1 01 fd ff 5b 5d
f3 c3 <0f> 0b 48 89 fe 48 8b 3d 61 e9 8f 00 e8 2c fa fc ff 5b 5d eb e9
[   28.796016] RIP  [<ffffffff812187b3>] putname+0x43/0x60
[   28.796016]  RSP <ffff88003592fe88>

Fixes: 193125dbd8eb ("net: Introduce VRF device driver")
Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 drivers/net/vrf.c | 11 +----------
 1 file changed, 1 insertion(+), 10 deletions(-)

diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index 92fa3e1ea65c..4f9748457f5a 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -907,7 +907,6 @@ static int vrf_newlink(struct net *src_net, struct net_device *dev,
 		       struct nlattr *tb[], struct nlattr *data[])
 {
 	struct net_vrf *vrf = netdev_priv(dev);
-	int err;
 
 	if (!data || !data[IFLA_VRF_TABLE])
 		return -EINVAL;
@@ -916,15 +915,7 @@ static int vrf_newlink(struct net *src_net, struct net_device *dev,
 
 	dev->priv_flags |= IFF_L3MDEV_MASTER;
 
-	err = register_netdevice(dev);
-	if (err < 0)
-		goto out_fail;
-
-	return 0;
-
-out_fail:
-	free_netdev(dev);
-	return err;
+	return register_netdevice(dev);
 }
 
 static size_t vrf_nl_getsize(const struct net_device *dev)
-- 
2.4.3
