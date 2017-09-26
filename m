From: Andrey Konovalov <andreyknvl@google.com>
Subject: usb/net/lan78xx: use-after-free in lan78xx_write_reg
Date: Tue, 26 Sep 2017 14:04:19 +0200
Message-ID: <CAAeHK+wfnGkTpiRiLusfR22XRF-bjSXnqFGwo2avjt33mSh2mg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Woojung Huh <woojung.huh@microchip.com>,
        Microchip Linux Driver Support <UNGLinuxDriver@microchip.com>,
        netdev <netdev@vger.kernel.org>,
        USB list <linux-usb@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f49.google.com ([209.85.218.49]:52568 "EHLO
        mail-oi0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S968489AbdIZMEV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 26 Sep 2017 08:04:21 -0400
Received: by mail-oi0-f49.google.com with SMTP id p126so11478445oih.9
        for <netdev@vger.kernel.org>; Tue, 26 Sep 2017 05:04:21 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

I've got the following report while fuzzing the kernel with syzkaller.

On commit e19b205be43d11bff638cad4487008c48d21c103 (4.14-rc2).

==================================================================
BUG: KASAN: use-after-free in lan78xx_write_reg.isra.21+0x1a8/0x1b0
Read of size 8 at addr ffff8800683e2c40 by task kworker/0:3/2551

CPU: 0 PID: 2551 Comm: kworker/0:3 Not tainted
4.14.0-rc2-42613-g1488251d1a98 #256
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
Workqueue: events lan78xx_deferred_multicast_write
Call Trace:
 __dump_stack lib/dump_stack.c:16
 dump_stack+0x292/0x395 lib/dump_stack.c:52
 print_address_description+0x78/0x280 mm/kasan/report.c:252
 kasan_report_error mm/kasan/report.c:351
 kasan_report+0x23d/0x350 mm/kasan/report.c:409
 __asan_report_load8_noabort+0x19/0x20 mm/kasan/report.c:430
 lan78xx_write_reg.isra.21+0x1a8/0x1b0 drivers/net/usb/lan78xx.c:458
 lan78xx_deferred_multicast_write+0x10d/0x1a0 drivers/net/usb/lan78xx.c:1042
 process_one_work+0xc7f/0x1db0 kernel/workqueue.c:2119
 worker_thread+0x221/0x1850 kernel/workqueue.c:2253
 kthread+0x3a1/0x470 kernel/kthread.c:231
 ret_from_fork+0x2a/0x40 arch/x86/entry/entry_64.S:431

Allocated by task 24:
 save_stack_trace+0x1b/0x20 arch/x86/kernel/stacktrace.c:59
 save_stack+0x43/0xd0 mm/kasan/kasan.c:447
 set_track mm/kasan/kasan.c:459
 kasan_kmalloc+0xad/0xe0 mm/kasan/kasan.c:551
 __kmalloc_node+0x192/0x480 mm/slub.c:3827
 kmalloc_node ./include/linux/slab.h:535
 kvmalloc_node+0x69/0xd0 mm/util.c:397
 kvmalloc ./include/linux/mm.h:529
 kvzalloc ./include/linux/mm.h:537
 alloc_netdev_mqs+0x173/0xea0 net/core/dev.c:8023
 alloc_etherdev_mqs+0x38/0x40 net/ethernet/eth.c:391
 lan78xx_probe+0x13a/0x2f10 drivers/net/usb/lan78xx.c:3542
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

Freed by task 24:
 save_stack_trace+0x1b/0x20 arch/x86/kernel/stacktrace.c:59
 save_stack+0x43/0xd0 mm/kasan/kasan.c:447
 set_track mm/kasan/kasan.c:459
 kasan_slab_free+0x72/0xc0 mm/kasan/kasan.c:524
 slab_free_hook mm/slub.c:1390
 slab_free_freelist_hook mm/slub.c:1412
 slab_free mm/slub.c:2988
 kfree+0xf6/0x2f0 mm/slub.c:3919
 kvfree+0x3b/0x60 mm/util.c:416
 netdev_freemem net/core/dev.c:7975
 free_netdev+0x304/0x3c0 net/core/dev.c:8137
 lan78xx_probe+0x20cc/0x2f10 drivers/net/usb/lan78xx.c:3645
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

The buggy address belongs to the object at ffff8800683e2100
 which belongs to the cache kmalloc-8192 of size 8192
The buggy address is located 2880 bytes inside of
 8192-byte region [ffff8800683e2100, ffff8800683e4100)
The buggy address belongs to the page:
page:ffffea0001a0f800 count:1 mapcount:0 mapping:          (null)
index:0x0 compound_mapcount: 0
flags: 0x100000000008100(slab|head)
raw: 0100000000008100 0000000000000000 0000000000000000 0000000100030003
raw: ffffea00018fe800 0000000200000002 ffff88006c402a80 0000000000000000
page dumped because: kasan: bad access detected

Memory state around the buggy address:
 ffff8800683e2b00: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
 ffff8800683e2b80: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
>ffff8800683e2c00: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
                                           ^
 ffff8800683e2c80: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
 ffff8800683e2d00: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
==================================================================
