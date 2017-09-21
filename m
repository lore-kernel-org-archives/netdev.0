From: Andrey Konovalov <andreyknvl@google.com>
Subject: usb/net/hso: warning in hso_free_net_device
Date: Thu, 21 Sep 2017 17:39:36 +0200
Message-ID: <CAAeHK+wtxeCNkOg0C2OJRrW9-z-LDOVRf3QD1mBts64x5NdV3Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: "David S. Miller" <davem@davemloft.net>,
        Andreas Kemnade <andreas@kemnade.info>,
        Johan Hovold <johan@kernel.org>,
        Johannes Berg <johannes.berg@intel.com>,
        yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>,
        Ingo Molnar <mingo@kernel.org>,
        USB list <linux-usb@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi!

I've got the following report while fuzzing the kernel with syzkaller.

On commit ebb2c2437d8008d46796902ff390653822af6cc4 (Sep 18).

Looks like hso_create_net_device() can do goto exit before registering
network device.

hso 1-1:4.0: Can't find BULK IN endpoint
------------[ cut here ]------------
WARNING: CPU: 0 PID: 24 at net/core/dev.c:7117
rollback_registered_many+0x235/0xd90
Modules linked in:
CPU: 0 PID: 24 Comm: kworker/0:1 Not tainted 4.14.0-rc1-42251-gebb2c2437d80 #215
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
Workqueue: usb_hub_wq hub_event
task: ffff88006befe300 task.stack: ffff88006bf80000
RIP: 0010:rollback_registered_many+0x235/0xd90 net/core/dev.c:7117
RSP: 0018:ffff88006bf86058 EFLAGS: 00010297
RAX: ffff88006befe300 RBX: 0000000000000000 RCX: 1ffff1000d40644e
RDX: 0000000000000000 RSI: 0000000000000000 RDI: ffff88006a032778
RBP: ffff88006bf86210 R08: ffff88006befe300 R09: ffffffff849e79cc
R10: ffff88006bf86450 R11: 1ffff1000d7dfefb R12: ffff88006a032200
R13: ffff88006a032270 R14: ffff88006bf86258 R15: dffffc0000000000
FS:  0000000000000000(0000) GS:ffff88006c800000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00007f1c4eebb000 CR3: 0000000069b63000 CR4: 00000000000006f0
Call Trace:
 rollback_registered+0x1ac/0x3c0 net/core/dev.c:7192
 unregister_netdevice_queue+0x2f3/0x580 net/core/dev.c:8180
 unregister_netdevice ./include/linux/netdevice.h:2427
 unregister_netdev+0x21/0x30 net/core/dev.c:8221
 hso_free_net_device+0xf2/0x2e0 drivers/net/usb/hso.c:2379
 hso_create_net_device+0x3f9/0x9d0 drivers/net/usb/hso.c:2567
 hso_probe+0xaa7/0x1b70 drivers/net/usb/hso.c:2896
 usb_probe_interface+0x35d/0x8e0 drivers/usb/core/driver.c:361
 really_probe drivers/base/dd.c:413
 driver_probe_device+0x610/0xa00 drivers/base/dd.c:557
 __device_attach_driver+0x230/0x290 drivers/base/dd.c:653
 bus_for_each_drv+0x161/0x210 drivers/base/bus.c:463
 __device_attach+0x26e/0x3d0 drivers/base/dd.c:710
 device_initial_probe+0x1f/0x30 drivers/base/dd.c:757
 bus_probe_device+0x1eb/0x290 drivers/base/bus.c:523
 device_add+0xd0b/0x1660 drivers/base/core.c:1835
 usb_set_configuration+0x104e/0x1870 drivers/usb/core/message.c:1932
 generic_probe+0x73/0xe0 drivers/usb/core/generic.c:174
 usb_probe_device+0xaf/0xe0 drivers/usb/core/driver.c:266
 really_probe drivers/base/dd.c:413
 driver_probe_device+0x610/0xa00 drivers/base/dd.c:557
 __device_attach_driver+0x230/0x290 drivers/base/dd.c:653
 bus_for_each_drv+0x161/0x210 drivers/base/bus.c:463
 __device_attach+0x26e/0x3d0 drivers/base/dd.c:710
 device_initial_probe+0x1f/0x30 drivers/base/dd.c:757
 bus_probe_device+0x1eb/0x290 drivers/base/bus.c:523
 device_add+0xd0b/0x1660 drivers/base/core.c:1835
 usb_new_device+0x7b8/0x1020 drivers/usb/core/hub.c:2457
 hub_port_connect drivers/usb/core/hub.c:4903
 hub_port_connect_change drivers/usb/core/hub.c:5009
 port_event drivers/usb/core/hub.c:5115
 hub_event+0x194d/0x3740 drivers/usb/core/hub.c:5195
 process_one_work+0xc7f/0x1db0 kernel/workqueue.c:2119
 worker_thread+0x221/0x1850 kernel/workqueue.c:2253
 kthread+0x3a1/0x470 kernel/kthread.c:231
 ret_from_fork+0x2a/0x40 arch/x86/entry/entry_64.S:431
Code: 48 c1 e8 03 42 0f b6 04 38 84 c0 74 08 84 c0 0f 8e e7 09 00 00
41 0f b6 9c 24 78 05 00 00 84 db 0f 85 57 ff ff ff e8 0b 92 b0 fc <0f>
ff 4c 89 ef e8 21 15 b7 fd 84 c0 0f 84 e1 00 00 00 e8 f4 91
---[ end trace 94e5147be32b2d45 ]---
