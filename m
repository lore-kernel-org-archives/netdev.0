From: Andrey Konovalov <andreyknvl@google.com>
Subject: usb/net/ar5523: warning in ar5523_submit_rx_cmd/usb_submit_urb
Date: Mon, 9 Oct 2017 19:49:54 +0200
Message-ID: <CAAeHK+xaHtb_CnEhZ5ncPXDERYhOu-+kvaAXpjbcBPRTT6xd9A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Pontus Fuchs <pontus.fuchs@gmail.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        linux-wireless@vger.kernel.org, netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi!

I've got the following report while fuzzing the kernel with syzkaller.

On commit 8a5776a5f49812d29fe4b2d0a2d71675c3facf3f (4.14-rc4).

It seems that the driver doesn't check the endpoint type provided in
the USB descriptor.

usb 1-1: BOGUS urb xfer, pipe 3 != type 1
------------[ cut here ]------------
WARNING: CPU: 1 PID: 2265 at drivers/usb/core/urb.c:449
usb_submit_urb+0xf8a/0x11d0
Modules linked in:
CPU: 1 PID: 2265 Comm: kworker/1:2 Not tainted
4.14.0-rc4-43418-g43a3f84d2109 #379
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
Workqueue: usb_hub_wq hub_event
task: ffff88006abc8000 task.stack: ffff880063e08000
RIP: 0010:usb_submit_urb+0xf8a/0x11d0 drivers/usb/core/urb.c:448
RSP: 0000:ffff880063e0ded0 EFLAGS: 00010286
RAX: 0000000000000029 RBX: ffff8800694cbf00 RCX: 0000000000000000
RDX: 0000000000000029 RSI: ffffffff86a76d40 RDI: ffffed000c7c1bcc
RBP: ffff880063e0dfd0 R08: 1ffff1000c7c1a72 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000000 R12: 1ffff1000c7c1be1
R13: 0000000000000001 R14: 0000000000000003 R15: ffff88006bb47e10
FS:  0000000000000000(0000) GS:ffff88006c500000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00007f43b3d37000 CR3: 00000000695d4000 CR4: 00000000000006e0
Call Trace:
 ar5523_submit_rx_cmd+0x20a/0x320 drivers/net/wireless/ath/ar5523/ar5523.c:208
 ar5523_probe+0x1683/0x3af0 drivers/net/wireless/ath/ar5523/ar5523.c:1643
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
Code: 48 8b 85 30 ff ff ff 48 8d b8 98 00 00 00 e8 6e df c7 fe 45 89
e8 44 89 f1 4c 89 fa 48 89 c6 48 c7 c7 c0 ce 04 87 e8 50 6d 16 fd <0f>
ff e9 9b f7 ff ff e8 9a f1 5f fd e9 80 f7 ff ff e8 60 c4 2d
---[ end trace 4ec8ea7915652acc ]---
