From: Andrey Konovalov <andreyknvl@google.com>
Subject: usb/net/hso: global-out-of-bounds in hso_probe
Date: Thu, 21 Sep 2017 17:39:29 +0200
Message-ID: <CAAeHK+w2fPdU3jjvPAAPNPnrg71Ce3zbrqfxQ5xOdM68-zaNFg@mail.gmail.com>
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

Is seems there's no check on the if_num value when it's used in ((u32
*)(id->driver_info))[if_num].

==================================================================
BUG: KASAN: global-out-of-bounds in hso_probe+0x1379/0x1b70
Read of size 4 at addr ffffffff85c582f8 by task kworker/1:2/1846

CPU: 1 PID: 1846 Comm: kworker/1:2 Not tainted
4.14.0-rc1-42251-gebb2c2437d80 #215
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
Workqueue: usb_hub_wq hub_event
Call Trace:
 __dump_stack lib/dump_stack.c:16
 dump_stack+0x292/0x395 lib/dump_stack.c:52
 print_address_description+0x1d9/0x280 mm/kasan/report.c:252
 kasan_report_error mm/kasan/report.c:351
 kasan_report+0x22f/0x340 mm/kasan/report.c:409
 __asan_report_load4_noabort+0x19/0x20 mm/kasan/report.c:429
 hso_probe+0x1379/0x1b70 drivers/net/usb/hso.c:2880
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

The buggy address belongs to the variable:
 driver_name+0xb8/0xee0

Memory state around the buggy address:
 ffffffff85c58180: 00 00 04 fa fa fa fa fa 00 00 fa fa fa fa fa fa
 ffffffff85c58200: 06 fa fa fa fa fa fa fa 04 fa fa fa fa fa fa fa
>ffffffff85c58280: 00 fa fa fa fa fa fa fa 06 fa fa fa fa fa fa fa
                                                                ^
 ffffffff85c58300: 00 02 fa fa fa fa fa fa 00 00 00 00 00 07 fa fa
 ffffffff85c58380: fa fa fa fa 00 07 fa fa fa fa fa fa 00 00 00 06
==================================================================
