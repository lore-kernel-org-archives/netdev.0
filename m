From: Andrey Konovalov <andreyknvl@google.com>
Subject: usb/irda: global-out-of-bounds in irda_qos_bits_to_value
Date: Mon, 9 Oct 2017 19:50:48 +0200
Message-ID: <CAAeHK+x8HnczPeM9+SLiBFqw==HZHmdpHMUBXXPCaFY4ZeejnA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Samuel Ortiz <samuel@sortiz.org>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        "David S. Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>, devel@driverdev.osuosl.org,
        LKML <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi!

I've got the following report while fuzzing the kernel with syzkaller.

On commit 8a5776a5f49812d29fe4b2d0a2d71675c3facf3f (4.14-rc4).

It seems that qos->baud_rate.bits value is taken from USB descriptor
and then used as a array index without any checks.

==================================================================
BUG: KASAN: global-out-of-bounds in irda_qos_bits_to_value+0x55a/0x5a0
Read of size 4 at addr ffffffff881f655c by task syz-executor/5582

CPU: 1 PID: 5582 Comm: syz-executor Not tainted
4.14.0-rc4-43423-g7263a3720c3f #392
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
Call Trace:
 __dump_stack lib/dump_stack.c:16
 dump_stack+0x292/0x395 lib/dump_stack.c:52
 print_address_description+0x1d9/0x280 mm/kasan/report.c:252
 kasan_report_error mm/kasan/report.c:351
 kasan_report+0x23d/0x350 mm/kasan/report.c:409
 __asan_report_load4_noabort+0x19/0x20 mm/kasan/report.c:429
 irda_qos_bits_to_value+0x55a/0x5a0 drivers/staging/irda/net/qos.c:751
 irda_usb_init_qos drivers/staging/irda/drivers/irda-usb.c:1389
 irda_usb_open drivers/staging/irda/drivers/irda-usb.c:1411
 irda_usb_probe+0x14ea/0x2ca0 drivers/staging/irda/drivers/irda-usb.c:1736
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
 usb_new_device+0x7b8/0x1020 drivers/usb/core/hub.c:2538
 hub_port_connect drivers/usb/core/hub.c:4984
 hub_port_connect_change drivers/usb/core/hub.c:5090
 port_event drivers/usb/core/hub.c:5196
 hub_event_impl+0x1971/0x3760 drivers/usb/core/hub.c:5310
 gfs_hub_events_handle+0x881/0xae0 drivers/usb/core/hub.c:1853
 hub_ioctl+0x53d/0x680 drivers/usb/core/hub.c:1903
 proc_ioctl+0x435/0x680 drivers/usb/core/devio.c:2175
 proc_ioctl_default drivers/usb/core/devio.c:2198
 usbdev_do_ioctl+0xee9/0x3790 drivers/usb/core/devio.c:2512
 usbdev_ioctl+0x2a/0x40 drivers/usb/core/devio.c:2556
 vfs_ioctl fs/ioctl.c:45
 do_vfs_ioctl+0x1c4/0x15c0 fs/ioctl.c:685
 SYSC_ioctl fs/ioctl.c:700
 SyS_ioctl+0x94/0xc0 fs/ioctl.c:691
 entry_SYSCALL_64_fastpath+0x23/0xc2 arch/x86/entry/entry_64.S:202

RIP: 0033:0x447707
RSP: 002b:00007ffd24fe61a8 EFLAGS: 00000202 ORIG_RAX: 0000000000000010
RAX: ffffffffffffffda RBX: 00000000ffffffff RCX: 0000000000447707
RDX: 00007ffd24fe61c0 RSI: 00000000c0105512 RDI: 0000000000000015
RBP: 0000000000000005 R08: 000000000265c940 R09: 000000000265c940
R10: 00000000004a8e59 R11: 0000000000000202 R12: 0000000000000015
R13: 0000000000000000 R14: 00007ffd24fe6078 R15: 00007ffd24fe60e8

The buggy address belongs to the variable:
 baud_rates+0x3c/0x60

Memory state around the buggy address:
 ffffffff881f6400: 00 00 00 00 00 00 00 fa fa fa fa fa 00 00 00 00
 ffffffff881f6480: fa fa fa fa 00 00 fa fa fa fa fa fa 00 00 00 fa
>ffffffff881f6500: fa fa fa fa 00 00 00 00 00 fa fa fa fa fa fa fa
                                                    ^
 ffffffff881f6580: 00 00 00 00 fa fa fa fa 04 fa fa fa fa fa fa fa
 ffffffff881f6600: 04 fa fa fa fa fa fa fa 04 fa fa fa fa fa fa fa
==================================================================
