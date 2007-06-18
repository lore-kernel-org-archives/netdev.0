From: Patrick McHardy <kaber@trash.net>
Subject: sky bugs in 2.6.22-rc5
Date: Mon, 18 Jun 2007 21:49:49 +0200
Message-ID: <4676E1DD.1060007@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:41212 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763103AbXFRTtw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jun 2007 15:49:52 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

sky2 breaks reproducably in 2.6.22-rc5 when setting the interface
down and up again. Packets are not received on the other side,
after a short time tcpdump (on the sky2 side) shows
use-after-free patterns:

IP6 (hlim 255, next-header: ICMPv6 (58), length: 16)
fe80::215:f2ff:fe24:91f8 > ff02::2: [icmp6
 sum ok] ICMP6, router solicitation, length 16
          source link-address option (1), length 8 (1): 00:15:f2:24:91:f8
arp who-has 192.168.0.1 tell 192.168.0.100
5a:5a:5a:5a:5a:5a > 5a:5a:5a:5a:5a:5a, ethertype Unknown (0x5a5a),
length 219:
        0x0000:  5a5a 5a5a 5a5a 5a5a 5a5a 5a5a 5a5a 5a5a  ZZZZZZZZZZZZZZZZ
        0x0010:  5a5a 5a5a 5a5a 5a5a 5a5a 5a5a 5a5a 5a5a  ZZZZZZZZZZZZZZZZ
        0x0020:  5a5a 5a5a 5a5a 5a5a 5a5a 5a5a 5a5a 5a5a  ZZZZZZZZZZZZZZZZ
        0x0030:  5a5a 5a5a 5a5a 5a5a 5a5a 5a5a 5a5a 5a5a  ZZZZZZZZZZZZZZZZ
        0x0040:  5a5a 5a5a 5a5a 5a5a 5a5a 5a5a 5a5a 5a5a  ZZZZZZZZZZZZZZZZ
        0x0050:  5a5a                                     ZZ



Additionally I get this oops when using netconsole and setting
the device down and up again:

sky2 eth0: disabling interface

sky2 eth0: enabling interface
Unable to handle kernel NULL pointer dereference at 0000000000000be4 RIP:
 [<ffffffff81162c6c>] sky2_xmit_frame+0x2c5/0x478
PGD 1338e4067 PUD 133945067 PMD 0
Oops: 0002 [1] PREEMPT SMP
CPU 1
Modules linked in: nfsd exportfs ppdev lp nfs lockd nfs_acl sunrpc
deflate zlib_deflate zlib_inflate twofish twofish_common camellia
serpent blowfish des cbc ecb blkcipher aes xcbc sha256 crypto_null
af_key rfcomm l2cap fuse nfnetlink_queue nfnetlink_log
nf_conntrack_netlink nf_nat nf_conntrack_ipv6 nf_conntrack_ipv4
nf_conntrack nfnetlink ip6_tables ip_tables x_tables hangcheck_timer
cpufreq_ondemand powernow_k8 freq_table video backlight thermal
processor fan ide_generic ide_disk ide_cd cdrom generic usbhid hid
hci_usb bluetooth snd_mpu401 snd_via82xx snd_mpu401_uart snd_seq_dummy
snd_seq_oss snd_via82xx_modem snd_ac97_codec ac97_bus snd_pcm_oss
snd_mixer_oss snd_seq_midi snd_seq_midi_event snd_seq snd_pcm evdev
snd_timer snd_rawmidi snd_seq_device via82cxxx psmouse serio_raw
parport_pc parport pcspkr snd soundcore snd_page_alloc i2c_viapro
ehci_hcd ide_core uhci_hcd
Pid: 5015, comm: ifconfig Not tainted 2.6.22-rc5 #2
RIP: 0010:[<ffffffff81162c6c>]  [<ffffffff81162c6c>]
sky2_xmit_frame+0x2c5/0x478
RSP: 0018:ffff81013ecd1a08  EFLAGS: 00010082
RAX: 00000000ffffffc1 RBX: ffff81013f6ca8c0 RCX: 0000000000000be0
RDX: 000000000000017c RSI: 0000000000000000 RDI: ffff81013f79e578
RBP: ffff81013ecd1a48 R08: 0000000000000000 R09: 000000013d25805a
R10: 0000000057afde91 R11: 0000000000000004 R12: ffff81013d4d3078
R13: 0000000000000048 R14: 0000000000000000 R15: 0000000000000048
FS:  00002b708f7bb6f0(0000) GS:ffff81013fc7a4c8(0000) knlGS:00000000f7e566c0
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 0000000000000be4 CR3: 000000013393b000 CR4: 00000000000006e0
Process ifconfig (pid: 5015, threadinfo ffff81013ecd0000, task
ffff810133c9a0c0)
Stack:  ffff81013f6ca000 ffff81013f6ca000 ffff81013fc994d0 0000000000000082
 ffff81013f6ca000 0000000000000000 ffff81013ec30b90 ffff81013d4d3078
 ffff81013ecd1aa8 ffffffff811baae2 000000000000002c 000000140000004a
Call Trace:
 [<ffffffff811baae2>] netpoll_send_skb+0xd9/0x15a
 [<ffffffff811bb999>] netpoll_send_udp+0x26c/0x27b
 [<ffffffff81164249>] write_msg+0x4c/0x7b
 [<ffffffff8102a92c>] __call_console_drivers+0x62/0x73
 [<ffffffff8102a9ac>] _call_console_drivers+0x6f/0x73
 [<ffffffff8102ab30>] release_console_sem+0x14c/0x1f7
 [<ffffffff8102b097>] vprintk+0x28e/0x306
 [<ffffffff8102b176>] printk+0x67/0x69
 [<ffffffff811b269c>] dev_mc_upload+0x19/0x43
 [<ffffffff8115fd08>] sky2_up+0x90/0x6d0
 [<ffffffff811b06bf>] dev_open+0x37/0x78
 [<ffffffff811ae59a>] dev_change_flags+0x5d/0x120
 [<ffffffff811f39e7>] devinet_ioctl+0x24a/0x5be
 [<ffffffff811f446a>] inet_ioctl+0x82/0xa0
 [<ffffffff811a3fdf>] sock_ioctl+0x1c8/0x1ea
 [<ffffffff81084cd0>] do_ioctl+0x2c/0xba
 [<ffffffff81084faf>] vfs_ioctl+0x251/0x26e
 [<ffffffff8108500e>] sys_ioctl+0x42/0x68
 [<ffffffff81009d9e>] system_call+0x7e/0x83


Code: 66 44 89 79 04 44 89 09 88 41 07 44 88 71 06 48 89 c8 48 2b


The reason for the second problem seems to be that sky2 enables
the queue too early and netconsole sends packets before
initialization is complete when sky2_up() prints a message.


