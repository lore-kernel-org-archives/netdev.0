From: Sitsofe Wheeler <sitsofe@gmail.com>
Subject: [hyperv] BUG at drivers/hv/channel.c:462 while changing MTU
Date: Tue, 19 Aug 2014 13:36:56 +0100
Message-ID: <20140819123655.GC12160@sucs.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 Jason Wang <jasowang@redhat.com>, linux-kernel@vger.kernel.org,
 "David S. Miller" <davem@davemloft.net>, Daniel Borkmann <dborkman@redhat.com>,
 netdev@vger.kernel.org, devel@linuxdriverproject.org,
 Haiyang Zhang <haiyangz@microsoft.com>
To: "K. Y. Srinivasan" <kys@microsoft.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
Content-Disposition: inline
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

Now we get to the issue I've been meaning to report: changing the MTU of
a Hyper-V network interface while traffic is flowing through it triggers
a BUG. I've seen this happen on a variety of kernels but the trace below
is from 3.17.0-rc1.

Steps to reproduce:
(Guests were customised Fedora 20 cloud images)
1.On Hyper-V VM 1 run
iperf -s 
2. On Hyper-V VM 2 run
iperf -c <Hyper-V VM 1 host address> -t 200
3. On Hyper-V VM 2 run
ip link set dev eth0 mtu 9000

Expected results:
MTU of eth0 to be changed, packets to keep flowing or stop, interface to
be at alive enough to be reconfigured.

Actual results:
Error messages on the console, eth0 winds up dead.

Here's the console output:

[   77.445546] audit: type=1404 audit(1408448793.921:2): selinux=0 auid=4294967295 ses=4294967295
[   79.940527] EXT4-fs (sda1): re-mounted. Opts: (null)
[   79.972849] systemd-udevd[362]: starting version 208
[   80.922339] md: bind<sdc>
[   80.963397] md: personality for level -1 is not loaded!
[   81.171186] EXT4-fs (sdb1): mounted filesystem with ordered data mode. Opts: (null)
[   81.425767] systemd-journald[368]: Received request to flush runtime journal from PID 1
[   82.418749] hv_utils: KVP: user-mode registering done.
[   87.731881] hv_netvsc vmbus_0_15: net device safe to remove
[   87.781930] hv_netvsc: hv_netvsc channel opened successfully
[   88.171244] hv_netvsc vmbus_0_15: Send section size: 6144, Section count:2560
[   88.220903] hv_netvsc vmbus_0_15: Device MAC 00:15:5d:6f:02:a5 link state up
[  148.301487] hv_netvsc vmbus_0_14 eth0: got rndis message but rndis device uninitialized...dropping this message!
[  148.327751] hv_netvsc vmbus_0_14 eth0: got rndis message but no rndis device - dropping this message!
[  148.347568] hv_netvsc vmbus_0_14 eth0: got rndis message but no rndis device - dropping this message!
[  148.369785] hv_netvsc vmbus_0_14 eth0: got rndis message but no rndis device - dropping this message!
[  148.389599] hv_netvsc vmbus_0_14 eth0: got rndis message but no rndis device - dropping this message!
[  148.409822] hv_netvsc vmbus_0_14 eth0: got rndis message but no rndis device - dropping this message!
[  148.432335] hv_netvsc vmbus_0_14 eth0: got rndis message but no rndis device - dropping this message!
[  148.452600] hv_netvsc vmbus_0_14 eth0: got rndis message but no rndis device - dropping this message!
[  148.474691] hv_netvsc vmbus_0_14 eth0: got rndis message but no rndis device - dropping this message!
[  148.497285] hv_netvsc vmbus_0_14 eth0: got rndis message but no rndis device - dropping this message!
[  148.523044] hv_netvsc vmbus_0_14 eth0: got rndis message but no rndis device - dropping this message!
[  148.545864] hv_netvsc vmbus_0_14 eth0: got rndis message but no rndis device - dropping this message!
[  148.573655] hv_netvsc vmbus_0_14 eth0: got rndis message but no rndis device - dropping this message!
[  148.615174] hv_netvsc vmbus_0_14 eth0: got rndis message but no rndis device - dropping this message!
[  148.646164] hv_netvsc vmbus_0_14 eth0: got rndis message but no rndis device - dropping this message!
[  148.676229] hv_netvsc vmbus_0_14 eth0: got rndis message but no rndis device - dropping this message!
[  148.712116] hv_netvsc vmbus_0_14 eth0: got rndis message but no rndis device - dropping this message!
[  148.752890] hv_netvsc vmbus_0_14 eth0: got rndis message but no rndis device - dropping this message!
[  148.801304] hv_netvsc vmbus_0_14 eth0: got rndis message but no rndis device - dropping this message!
[  148.852974] hv_netvsc vmbus_0_14 eth0: got rndis message but no rndis device - dropping this message!
[  148.914414] hv_netvsc vmbus_0_14 eth0: got rndis message but no rndis device - dropping this message!
[  148.983242] hv_netvsc vmbus_0_14 eth0: got rndis message but no rndis device - dropping this message!
[  149.057919] hv_netvsc vmbus_0_14 eth0: got rndis message but no rndis device - dropping this message!
[  149.126764] hv_netvsc vmbus_0_14 eth0: got rndis message but no rndis device - dropping this message!
[  149.195238] hv_netvsc vmbus_0_14 eth0: got rndis message but no rndis device - dropping this message!
[  149.263909] hv_netvsc vmbus_0_14 eth0: got rndis message but no rndis device - dropping this message!
[  149.332479] hv_netvsc vmbus_0_14 eth0: got rndis message but no rndis device - dropping this message!
[  149.416638] hv_netvsc vmbus_0_14 eth0: got rndis message but no rndis device - dropping this message!
[  149.479057] hv_netvsc vmbus_0_14 eth0: got rndis message but no rndis device - dropping this message!
[  149.547632] hv_netvsc vmbus_0_14 eth0: got rndis message but no rndis device - dropping this message!
[  153.342214] ------------[ cut here ]------------
[  153.343159] kernel BUG at drivers/hv/channel.c:462!
[  153.343159] invalid opcode: 0000 [#1] SMP 
[  153.343159] CPU: 3 PID: 902 Comm: ip Not tainted 3.17.0-rc1.x86_64 #124
[  153.343159] Hardware name: Microsoft Corporation Virtual Machine/Virtual Machine, BIOS 090006  05/23/2012
[  153.343159] task: ffff8800ef2b8000 ti: ffff8800ef094000 task.ti: ffff8800ef094000
[  153.343159] RIP: 0010:[<ffffffff815a8d29>]  [<ffffffff815a8d29>] vmbus_teardown_gpadl+0xd9/0x130
[  153.343159] RSP: 0018:ffff8800ef0976e8  EFLAGS: 00010246
[  153.343159] RAX: 0000000000000000 RBX: ffff8800ef04bcf0 RCX: 0000000000000006
[  153.343159] RDX: 0000000000000006 RSI: ffff8800ef2b8740 RDI: ffff8800ef2b8000
[  153.343159] RBP: ffff8800ef097708 R08: 0000000000000000 R09: 0000000000000000
[  153.343159] R10: 0000000000000001 R11: 0000000000000001 R12: 0000000000000286
[  153.343159] R13: ffff8801fbb89fb0 R14: ffff8800ef04bd10 R15: ffff8800f1078000
[  153.343159] FS:  00007fd3f8495740(0000) GS:ffff880207c60000(0000) knlGS:0000000000000000
[  153.343159] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  153.343159] CR2: 00007f458a2ad000 CR3: 00000000ed33d000 CR4: 00000000000406e0
[  153.343159] Stack:
[  153.343159]  ffff8800f1078000 0000000000000000 ffff8801f9399160 ffff8800ef4a4000
[  153.343159]  ffff8800ef097730 ffffffff814e77b6 ffff8801fbb8d9c8 ffff8800f1078000
[  153.343159]  ffff8800f1078010 ffff8800ef097750 ffffffff814e7f3e ffff8800f1078000
[  153.343159] Call Trace:
[  153.343159]  [<ffffffff814e77b6>] netvsc_destroy_buf+0xb6/0x210
[  153.343159]  [<ffffffff814e7f3e>] netvsc_device_remove+0x1e/0xa0
[  153.343159]  [<ffffffff814e9b88>] rndis_filter_device_remove+0x128/0x140
[  153.343159]  [<ffffffff810b13d0>] ? __wake_up_common+0x90/0x90
[  153.343159]  [<ffffffff814e6310>] netvsc_change_mtu+0x130/0x1f0
[  154.450966]  [<ffffffff8108fbb6>] ? raw_notifier_call_chain+0x16/0x20
[  154.450966]  [<ffffffff815d0e00>] dev_set_mtu+0x80/0x130
[  154.450966]  [<ffffffff815e12f5>] do_setlink+0x1b5/0xa60
[  154.450966]  [<ffffffff815e23ad>] rtnl_newlink+0x49d/0x760
[  154.450966]  [<ffffffff815e202f>] ? rtnl_newlink+0x11f/0x760
[  154.450966]  [<ffffffff816a3977>] ? retint_restore_args+0x13/0x13
[  154.450966]  [<ffffffff810cf1e2>] ? rcu_irq_exit+0x92/0xb0
[  154.450966]  [<ffffffff816a3977>] ? retint_restore_args+0x13/0x13
[  154.450966]  [<ffffffff815de8c1>] rtnetlink_rcv_msg+0x221/0x260
[  154.450966]  [<ffffffff810b980d>] ? trace_hardirqs_on+0xd/0x10
[  154.450966]  [<ffffffff815de67b>] ? rtnetlink_rcv+0x1b/0x40
[  154.450966]  [<ffffffff815de6a0>] ? rtnetlink_rcv+0x40/0x40
[  154.450966]  [<ffffffff815fc4b5>] netlink_rcv_skb+0x65/0xb0
[  154.450966]  [<ffffffff815de68a>] rtnetlink_rcv+0x2a/0x40
[  154.450966]  [<ffffffff815fa5ec>] netlink_unicast+0xcc/0x1a0
[  154.450966]  [<ffffffff815fb3ee>] netlink_sendmsg+0x6de/0x750
[  154.450966]  [<ffffffff815b3dd8>] sock_sendmsg+0x88/0xb0
[  154.450966]  [<ffffffff81184e9a>] ? might_fault+0x5a/0xb0
[  154.450966]  [<ffffffff81184ee3>] ? might_fault+0xa3/0xb0
[  154.450966]  [<ffffffff81184e9a>] ? might_fault+0x5a/0xb0
[  154.450966]  [<ffffffff815c26cd>] ? verify_iovec+0x7d/0xf0
[  154.450966]  [<ffffffff815b41e6>] ___sys_sendmsg+0x296/0x2b0
[  154.450966]  [<ffffffff8118356d>] ? handle_mm_fault+0x69d/0x12a0
[  154.450966]  [<ffffffff810403e3>] ? __do_page_fault+0x1c3/0x4f0
[  154.450966]  [<ffffffff810b6a5f>] ? up_read+0x1f/0x40
[  154.450966]  [<ffffffff8104064c>] ? __do_page_fault+0x42c/0x4f0
[  154.450966]  [<ffffffff811e1f15>] ? mntput_no_expire+0x65/0x170
[  154.450966]  [<ffffffff811e1eb5>] ? mntput_no_expire+0x5/0x170
[  154.450966]  [<ffffffff811e27c5>] ? mntput+0x35/0x40
[  154.450966]  [<ffffffff811c3022>] ? __fput+0x1b2/0x1d0
[  154.450966]  [<ffffffff815b5172>] __sys_sendmsg+0x42/0x70
[  154.450966]  [<ffffffff815b51ae>] SyS_sendmsg+0xe/0x10
[  154.450966]  [<ffffffff816a2d29>] system_call_fastpath+0x16/0x1b
[  154.450966] Code: bb 88 00 00 00 be 10 00 00 00 e8 13 f2 ff ff 85 c0 74 07 0f 0b 0f 1f 44 00 00 be 88 13 00 00 4c 89 f7 e8 bb 4d 0f 00 85 c0 75 07 <0f> 0b 0f 1f 44 00 00 48 c7 c7 40 27 ce 81 e8 a4 91 0f 00 48 89 
[  154.450966] RIP  [<ffffffff815a8d29>] vmbus_teardown_gpadl+0xd9/0x130
[  154.450966]  RSP <ffff8800ef0976e8>
[  154.465935] ---[ end trace 9e424a814eb71263 ]---

-- 
Sitsofe | http://sucs.org/~sits/
