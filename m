From: Andrew Collins <acollins@cradlepoint.com>
Subject: Kernel panic due to netdev all_adj_list refcnt handling
Date: Tue, 26 Jan 2016 13:12:10 -0700
Message-ID: <56A7D31A.1080906@cradlepoint.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <vfalico@redhat.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from phaseu-1.complex1.sms.eurus.ops.us.digitar.com ([107.6.68.62]:51792
	"EHLO phaseu-1.complex1.sms.eurus.ops.us.digitar.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751091AbcAZUUs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Jan 2016 15:20:48 -0500
Received: from apps-2.eurus.ops.us.digitar.com (phaseu-2.complex1.sms.eurus.ops.us.digitar.com [107.6.68.63])
	by phaseu-1.complex1.sms.eurus.ops.us.digitar.com (Postfix) with SMTP id 91E16CF46
	for <netdev@vger.kernel.org>; Tue, 26 Jan 2016 20:12:18 +0000 (UTC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm running into a relatively easily reproducible kernel panic related to the all_adj_list handling for netdevs
in recent kernels.

The following sequence of commands will reproduce the issue:

ip link add link eth0 name eth0.100 type vlan id 100
ip link add link eth0 name eth0.200 type vlan id 200
ip link add name testbr type bridge
ip link set eth0.100 master testbr
ip link set eth0.200 master testbr
ip link add link testbr mac0 type macvlan
ip link delete dev testbr

This creates an upper/lower tree of (excuse the poor ASCII art):

             /---eth0.100-eth0
mac0-testbr-
             \---eth0.200-eth0

When testbr is deleted, the all_adj_lists are walked, and eth0 is deleted twice from the mac0 list.
Unfortunately, during setup in __netdev_upper_dev_link, only one reference to eth0 is added,
so this results in the following panic trace:

[68235.234564] tried to remove device eth0 from mac0
[68235.234585] ------------[ cut here ]------------
[68235.234599] kernel BUG at net/core/dev.c:5237!
[68235.234608] invalid opcode: 0000 [#1] SMP
[68235.234619] Modules linked in: macvlan bridge 8021q garp mrp stp llc nfsv3 nfs_acl rpcsec_gss_krb5 auth_rpcgss nfsv4 dns_resolver nfs lockd grace sunrpc fscache ebtable_filter ebtables ip6table_filter ip6_tables ccm fuse vmw_vsock_vmci_transport vsock vmw_vmci ftdi_sio snd_hda_codec_realtek snd_hda_codec_hdmi snd_hda_codec_generic intel_rapl arc4 iosf_mbi x86_pkg_temp_thermal snd_hda_intel coretemp iwldvm snd_hda_codec kvm_intel mac80211 kvm snd_hda_core snd_hwdep iTCO_wdt snd_seq iTCO_vendor_support ppdev iwlwifi snd_seq_device crct10dif_pclmul snd_pcm joydev cfg80211 crc32_pclmul crc32c_intel snd_timer snd mei_me i2c_i801 rfkill soundcore lpc_ich mei parport_pc shpchp parport soc_button_array binfmt_misc i915 i2c_algo_bit drm_kms_helper drm e1000e r8169 mii ptp pps_core video fjes
[68235.234841] CPU: 2 PID: 14808 Comm: ip Not tainted 4.3.3-301.fc23.x86_64 #1
[68235.234856] Hardware name: Shuttle Inc. SZ87R/FZ87, BIOS 1.02 07/29/2013
[68235.234870] task: ffff8803cce50000 ti: ffff8801c7db8000 task.ti: ffff8801c7db8000
[68235.234885] RIP: 0010:[<ffffffff816678b1>]  [<ffffffff816678b1>] __netdev_adjacent_dev_remove+0x51/0x170
[68235.234908] RSP: 0018:ffff8801c7dbb8b8  EFLAGS: 00010286
[68235.234919] RAX: 0000000000000027 RBX: ffff8800369400b8 RCX: 0000000000000006
[68235.234934] RDX: 0000000000000000 RSI: 0000000000000246 RDI: ffff88043fa8dff0
[68235.234948] RBP: ffff8801c7dbb8d8 R08: 000000000000000a R09: 0000000000000434
[68235.234963] R10: ffff88032fe49528 R11: 0000000000000434 R12: ffff88009621e000
[68235.234977] R13: ffff880036940000 R14: ffff8803bcf7f0e0 R15: ffff8802b9b8fc40
[68235.234991] FS:  00007f3057634700(0000) GS:ffff88043fa80000(0000) knlGS:0000000000000000
[68235.235007] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[68235.235020] CR2: 000055efaad421f8 CR3: 000000009d8d9000 CR4: 00000000001406e0
[68235.235034] Stack:
[68235.235039]  ffff8803bcf7f0b0 ffff88009621e000 ffff880036940000 ffff8803ad48c000
[68235.235056]  ffff8801c7dbb8f8 ffffffff816679ee ffff8803ad48c0d0 ffff880399b93100
[68235.235073]  ffff8801c7dbb958 ffffffff81667af9 ffff8803bcf7f000 ffffffffa0731af6
[68235.235090] Call Trace:
[68235.235098]  [<ffffffff816679ee>] __netdev_adjacent_dev_unlink+0x1e/0x40
[68235.235112]  [<ffffffff81667af9>] netdev_upper_dev_unlink+0x99/0x170
[68235.235128]  [<ffffffffa0731af6>] ? br_fdb_delete_by_port+0xa6/0xd0 [bridge]
[68235.235144]  [<ffffffffa0733950>] del_nbp+0xc0/0x130 [bridge]
[68235.235157]  [<ffffffffa0733a02>] br_dev_delete+0x42/0xb0 [bridge]
[68235.235172]  [<ffffffff8167aeb3>] rtnl_delete_link+0x43/0x70
[68235.235184]  [<ffffffff8167befb>] rtnl_dellink+0xcb/0x1d0
[68235.235196]  [<ffffffff8167c146>] rtnetlink_rcv_msg+0xe6/0x230
[68235.235210]  [<ffffffff8132d762>] ? sock_has_perm+0x72/0x90
[68235.235222]  [<ffffffff8167c060>] ? rtnetlink_rcv+0x30/0x30
[68235.235235]  [<ffffffff816a18c4>] netlink_rcv_skb+0xa4/0xc0
[68235.235247]  [<ffffffff8167c058>] rtnetlink_rcv+0x28/0x30
[68235.235260]  [<ffffffff816a1087>] netlink_unicast+0x127/0x1a0
[68235.235272]  [<ffffffff816a15a2>] netlink_sendmsg+0x4a2/0x5f0
[68235.235285]  [<ffffffff8164f8f8>] sock_sendmsg+0x38/0x50
[68235.235297]  [<ffffffff81650289>] ___sys_sendmsg+0x289/0x2a0
[68235.235310]  [<ffffffff811b694c>] ? lru_cache_add+0x1c/0x50
[68235.235323]  [<ffffffff811d9323>] ? handle_mm_fault+0xc83/0x1840
[68235.235336]  [<ffffffff8123a6cd>] ? __dentry_kill+0x13d/0x1b0
[68235.235349]  [<ffffffff8123a8ff>] ? dput+0x1bf/0x1f0
[68235.235359]  [<ffffffff81650d21>] __sys_sendmsg+0x51/0x90
[68235.235371]  [<ffffffff81650d72>] SyS_sendmsg+0x12/0x20
[68235.235382]  [<ffffffff817815ee>] entry_SYSCALL_64_fastpath+0x12/0x71

I have a rather naive patch which simply calls __netdev_adjacent_dev_link ref_nr times
to keep the refcnts synced, but it seems hacky and is likely incomplete.

The basic idea is as below (excluding cleanup handling):

diff --git a/net/core/dev.c b/net/core/dev.c
index cc9e365..37d0574 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5633,7 +5633,7 @@ static int __netdev_upper_dev_link(struct net_device *dev,
  {
         struct netdev_notifier_changeupper_info changeupper_info;
         struct netdev_adjacent *i, *j, *to_i, *to_j;
-       int ret = 0;
+       int ret = 0, refs;

         ASSERT_RTNL();

@@ -5685,18 +5685,22 @@ static int __netdev_upper_dev_link(struct net_device *dev,
         list_for_each_entry(i, &upper_dev->all_adj_list.upper, list) {
                 pr_debug("linking %s's upper device %s with %s\n",
                          upper_dev->name, i->dev->name, dev->name);
-               ret = __netdev_adjacent_dev_link(dev, i->dev);
-               if (ret)
-                       goto rollback_upper_mesh;
+               for (refs = 0; refs < i->ref_nr; refs++) {
+                       ret = __netdev_adjacent_dev_link(dev, i->dev);
+                       if (ret)
+                               goto rollback_upper_mesh;
+               }
         }

         /* add upper_dev to every dev's lower device */
         list_for_each_entry(i, &dev->all_adj_list.lower, list) {
                 pr_debug("linking %s's lower device %s with %s\n", dev->name,
                          i->dev->name, upper_dev->name);
-               ret = __netdev_adjacent_dev_link(i->dev, upper_dev);
-               if (ret)
-                       goto rollback_lower_mesh;
+               for (refs = 0; refs < i->ref_nr; refs++) {
+                       ret = __netdev_adjacent_dev_link(i->dev, upper_dev);
+                       if (ret)
+                               goto rollback_lower_mesh;
+               }
         }

Has anyone else encountered this before?  Any ideas on a cleaner solution?

Thanks,
Andrew Collins
