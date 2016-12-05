From: Laura Abbott <labbott@redhat.com>
Subject: Oops with CONFIG_VMAP_STCK and bond device + virtio-net
Date: Mon, 5 Dec 2016 15:53:25 -0800
Message-ID: <bd4c37d9-9724-4c2a-8f0f-45b86fb5cb7f@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: zbyszek@in.waw.pl, virtualization@lists.linux-foundation.org,
        netdev@vger.kernel.org,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: "Michael S. Tsirkin" <mst@redhat.com>,
        Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Fedora got a bug report https://bugzilla.redhat.com/show_bug.cgi?id=1401612
In qemu with two virtio-net interfaces:

$ ip l
...
5: ens14: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
    link/ether 52:54:00:e9:64:41 brd ff:ff:ff:ff:ff:ff
6: ens15: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
    link/ether 52:54:00:e9:64:42 brd ff:ff:ff:ff:ff:ff

$ sudo ip link add bond1 type bond
$ sudo ip link set ens14 master bond1
Segmentation fault

 ------------[ cut here ]------------
 kernel BUG at ./include/linux/scatterlist.h:140!
 invalid opcode: 0000 [#1] SMP
 Modules linked in: bonding ip6t_rpfilter ip6t_REJECT nf_reject_ipv6 xt_conntrack ip
  ata_generic crc32c_intel qxl drm_kms_helper virtio_pci serio_raw ttm drm pata_acpi
 CPU: 5 PID: 1983 Comm: ip Not tainted 4.9.0-0.rc6.git2.1.fc26.x86_64 #1
 Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 0.0.0 02/06/2015
 task: ffff9d50a3583240 task.stack: ffffb06e41040000
 RIP: 0010:[<ffffffffbc4896fc>]  [<ffffffffbc4896fc>] sg_init_one+0x8c/0xa0
 RSP: 0018:ffffb06e41043698  EFLAGS: 00010246
 RAX: 0000000000000000 RBX: ffffb06e41043774 RCX: 0000000000000028
 RDX: 0000131ec1043774 RSI: 0000000000000013 RDI: ffffb06ec1043774
 RBP: ffffb06e410436b0 R08: 00000000001ddbe0 R09: ffffb06e410436c8
 R10: 0000000000000001 R11: 0000000000000000 R12: 0000000000000006
 R13: ffffb06e410436c8 R14: ffff9d50b2dc1800 R15: ffff9d50b3db9600
 FS:  00007f15347e5700(0000) GS:ffff9d50bb000000(0000) knlGS:0000000000000000
 CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
 CR2: 00007ffc09bc4000 CR3: 0000000135797000 CR4: 00000000000406e0
 Stack:
  ffff9d50b229d000 0000000000000000 ffffb06e41043772 ffffb06e41043720
  ffffffffc0051123 ffff9d50a3583240 0000000087654321 0000000000000002
  0000000000000000 0000000000000000 0000000000000000 000000007b8f5301
 Call Trace:
  [<ffffffffc0051123>] virtnet_set_mac_address+0xb3/0x140 [virtio_net]
  [<ffffffffbc7ae305>] dev_set_mac_address+0x55/0xc0
  [<ffffffffc03f319e>] bond_enslave+0x34e/0x1180 [bonding]
  [<ffffffffbc7ca22f>] do_setlink+0x6cf/0xd10
  [<ffffffffbc20dd6a>] ? get_page_from_freelist+0x6ba/0xca0
  [<ffffffffbc037de9>] ? sched_clock+0x9/0x10
  [<ffffffffbc068475>] ? kvm_sched_clock_read+0x25/0x40
  [<ffffffffbc111ed6>] ? __lock_acquire+0x346/0x1290
  [<ffffffffbc4aa436>] ? nla_parse+0xa6/0x120
  [<ffffffffbc7ce9e8>] rtnl_newlink+0x5c8/0x870
  [<ffffffffbc3ecb32>] ? avc_has_perm_noaudit+0x32/0x210
  [<ffffffffbc0bbfca>] ? ns_capable_common+0x7a/0x90
  [<ffffffffbc0bbff3>] ? ns_capable+0x13/0x20
  [<ffffffffbc7ced76>] rtnetlink_rcv_msg+0xe6/0x210
  [<ffffffffbc7c951b>] ? rtnetlink_rcv+0x1b/0x40
  [<ffffffffbc7c951b>] ? rtnetlink_rcv+0x1b/0x40
  [<ffffffffbc7cec90>] ? rtnl_newlink+0x870/0x870
  [<ffffffffbc7f7394>] netlink_rcv_skb+0xa4/0xc0
  [<ffffffffbc7c952a>] rtnetlink_rcv+0x2a/0x40
  [<ffffffffbc7f6d07>] netlink_unicast+0x1f7/0x2f0
  [<ffffffffbc7f6c7f>] ? netlink_unicast+0x16f/0x2f0
  [<ffffffffbc7f7102>] netlink_sendmsg+0x302/0x3c0
  [<ffffffffbc790c28>] sock_sendmsg+0x38/0x50
  [<ffffffffbc791773>] ___sys_sendmsg+0x2e3/0x2f0
  [<ffffffffbc18830d>] ? __audit_syscall_entry+0xad/0xf0
  [<ffffffffbc068475>] ? kvm_sched_clock_read+0x25/0x40
  [<ffffffffbc037de9>] ? sched_clock+0x9/0x10
  [<ffffffffbc18830d>] ? __audit_syscall_entry+0xad/0xf0
  [<ffffffffbc18830d>] ? __audit_syscall_entry+0xad/0xf0
  [<ffffffffbc111775>] ? trace_hardirqs_on_caller+0xf5/0x1b0
  [<ffffffffbc7924b4>] __sys_sendmsg+0x54/0x90
  [<ffffffffbc792502>] SyS_sendmsg+0x12/0x20
  [<ffffffffbc003eec>] do_syscall_64+0x6c/0x1f0
  [<ffffffffbc917589>] entry_SYSCALL64_slow_path+0x25/0x25
 Code: ca 75 2c 49 8b 55 08 f6 c2 01 75 25 83 e2 03 81 e3 ff 0f 00 00 45 89 65 14 48
 RIP  [<ffffffffbc4896fc>] sg_init_one+0x8c/0xa0
  RSP <ffffb06e41043698>
 ---[ end trace 9076d2284efbf735 ]---

This looks like an issue with CONFIG_VMAP_STACK since bond_enslave uses
struct sockaddr from the stack and virtnet_set_mac_address calls
sg_init_one which triggers BUG_ON(!virt_addr_valid(buf));

I know there have been a lot of CONFIG_VMAP_STACK fixes around but I
didn't find this one reported yet.

Thanks,
Laura
