From: Beniamino Galvani <bgalvani@redhat.com>
Subject: BUG in free_netdev() on ppp link deletion
Date: Tue, 3 Oct 2017 09:44:14 +0200
Message-ID: <20171003074413.GA26158@tp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-ppp@vger.kernel.org, netdev@vger.kernel.org,
        Paul Mackerras <paulus@samba.org>,
        Guillaume Nault <g.nault@alphalink.fr>,
        David Ahern <dsahern@gmail.com>,
        Gao Feng <gfree.wind@vip.163.com>
Return-path: <linux-ppp-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I see the following BUG on 4.14-rc2 and previous versions (reproduced
with 4.11 as well):

 ------------[ cut here ]------------
 kernel BUG at net/core/dev.c:8141!
 invalid opcode: 0000 [#1] SMP
 Modules linked in: pppoe pppox ppp_generic slhc cfg80211 rfkill joydev uinput tun sunrpc snd_hda_codec_generic snd_hda_intel snd_hda_codec snd_hda_core snd_hwdep snd_seq snd_seq_device crct10dif_pclmul crc32_pclmul snd_pcm ghash_clmulni_intel snd_timer ppdev snd parport_pc pcspkr soundcore parport virtio_balloon i2c_piix4 8139too virtio_console qxl drm_kms_helper ttm drm crc32c_intel serio_raw e1000 virtio_pci 8139cp floppy virtio_ring qemu_fw_cfg mii virtio ata_generic pata_acpi
 CPU: 1 PID: 1557 Comm: pppd Not tainted 4.14.0-rc2+ #4
 Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-1.fc26 04/01/2014
 task: ffff9cd4ba5e4c80 task.stack: ffffc28a40570000
 RIP: 0010:free_netdev+0x107/0x110
 RSP: 0018:ffffc28a40573d88 EFLAGS: 00010297
 RAX: 0000000000000002 RBX: ffff9cd4bb0178c0 RCX: 000000000001e94c
 RDX: 0000000000000001 RSI: 0000000000000286 RDI: 0000000000000000
 RBP: ffffc28a40573da0 R08: 0000000000000001 R09: 000000000000019b
 R10: 000000000000059b R11: 0000000000000001 R12: ffff9cd4bb017000
 R13: ffff9cd4bb017060 R14: ffff9cd4bb01793c R15: 0000000000000000
 FS:  00007fa720aa2840(0000) GS:ffff9cd4bfc80000(0000) knlGS:0000000000000000
 CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
 CR2: 00007fffeefa3000 CR3: 0000000072b34002 CR4: 00000000001606e0
 Call Trace:
  ppp_destroy_interface+0xd8/0xe0 [ppp_generic]
  ppp_disconnect_channel+0xda/0x110 [ppp_generic]
  ppp_unregister_channel+0x5e/0x110 [ppp_generic]
  pppox_unbind_sock+0x23/0x30 [pppox]
  pppoe_connect+0x130/0x440 [pppoe]
  SYSC_connect+0x98/0x110
  ? do_fcntl+0x2c0/0x5d0
  SyS_connect+0xe/0x10
  entry_SYSCALL_64_fastpath+0x1a/0xa5
 RIP: 0033:0x7fa71f4af840
 RSP: 002b:00007ffe4ea40bf8 EFLAGS: 00000246 ORIG_RAX: 000000000000002a
 RAX: ffffffffffffffda RBX: 0000556d37ae0538 RCX: 00007fa71f4af840
 RDX: 000000000000001e RSI: 00007ffe4ea40c00 RDI: 0000000000000008
 RBP: 0000556d37b2a1b0 R08: 0000556d396e95b0 R09: 0000000000000008
 R10: 00000000aaaaaaab R11: 0000000000000246 R12: 0000556d37adc008
 R13: 0000556d37adc004 R14: 0000556d37b2a1a4 R15: 0000000000000000
 Code: 04 00 00 04 e8 cb 52 e3 ff 5b 41 5c 41 5d 5d c3 41 0f b7 84 24 32 02 00 00 4c 89 e7 48 29 c7 e8 80 8b aa ff 5b 41 5c 41 5d 5d c3 <0f> 0b 0f 1f 80 00 00 00 00 0f 1f 44 00 00 55 48 89 e5 41 57 41 
 RIP: free_netdev+0x107/0x110 RSP: ffffc28a40573d88
 ---[ end trace ed294ff0cc40eeff ]---

To reproduce this, establish a PPP connection through pppd, then bring
down and delete the ppp interface:

 # pppd nodetach lock user client plugin rp-pppoe.so ens11 noauth nodeflate password password &
 Plugin rp-pppoe.so loaded.
 RP-PPPoE plugin version 3.8p compiled against pppd 2.4.7
 PPP session is 16
 Connected to fe:54:00:5f:04:13 via interface ens11
 Using interface ppp0
 Connect: ppp0 <--> ens11
 CHAP authentication succeeded: Access granted
 CHAP authentication succeeded
 peer from calling number FE:54:00:5F:04:13 authorized
 local  IP address 3.1.1.10
 remote IP address 3.1.1.1

 # ip l set ppp0 down
 # ip l del ppp0

It does not happen every time but only when ppp_destroy_interface() is
called with dev->reg_state = UNREGISTERING, set by the concurrent
rtnl_delete_link().

Beniamino
