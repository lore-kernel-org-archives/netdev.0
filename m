From: Andrey Konovalov <andreyknvl@google.com>
Subject: usb/net/asix: null-ptr-deref in asix_suspend
Date: Tue, 10 Oct 2017 15:36:02 +0200
Message-ID: <CAAeHK+y4+xSVRV6ZfXUpGRuMxYXkRey-=vVT-n+yL9jiGOX1Ng@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: "David S. Miller" <davem@davemloft.net>,
        Colin Ian King <colin.king@canonical.com>,
        Philippe Reynes <tremyfr@gmail.com>, allan <allan@asix.com.tw>,
        Dean Jenkins <Dean_Jenkins@mentor.com>,
        Greg Ungerer <gerg@linux-m68k.org>,
        Jarod Wilson <jarod@redhat.com>,
        Peter Chen <peter.chen@nxp.com>,
        USB list <linux-usb@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi!

I've got the following report while fuzzing the kernel with syzkaller.

On commit 8a5776a5f49812d29fe4b2d0a2d71675c3facf3f (4.14-rc4).

It seems that priv ends up being NULL.

usb 1-1: New USB device found, idVendor=0557, idProduct=2009
usb 1-1: New USB device strings: Mfr=204, Product=1, SerialNumber=0
usb 1-1: Product: a
usb 1-1: Manufacturer: a
gadgetfs: configuration #4
hub 1-1:4.2: bad descriptor, ignoring hub
hub: probe of 1-1:4.2 failed with error -5
asix 1-1:4.2 (unnamed net_device) (uninitialized): Failed to read reg
index 0x0000: -75
asix 1-1:4.2 eth1: register 'asix' at usb-dummy_hcd.0-1, ASIX AX8817x
USB 2.0 Ethernet, 08:d1:8e:63:00:88
asix 1-1:4.185 eth2: register 'asix' at usb-dummy_hcd.0-1, ASIX
AX8817x USB 2.0 Ethernet, 08:8f:0a:63:00:88
kasan: CONFIG_KASAN_INLINE enabled
kasan: GPF could be caused by NULL-ptr deref or user memory access
general protection fault: 0000 [#1] PREEMPT SMP KASAN
Modules linked in:
CPU: 0 PID: 24 Comm: kworker/0:1 Not tainted 4.14.0-rc4-43422-geccacdd69a8c #400
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
Workqueue: usb_hub_wq hub_event
task: ffff88006bb36300 task.stack: ffff88006bba8000
RIP: 0010:asix_suspend+0x76/0xc0 drivers/net/usb/asix_devices.c:629
RSP: 0018:ffff88006bbae718 EFLAGS: 00010202
RAX: dffffc0000000000 RBX: ffff880061ba3b80 RCX: 1ffff1000c34d644
RDX: 0000000000000001 RSI: 0000000000000402 RDI: 0000000000000008
RBP: ffff88006bbae738 R08: 1ffff1000d775cad R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000000 R12: ffff8800630a8b40
R13: 0000000000000000 R14: 0000000000000402 R15: ffff880061ba3b80
FS:  0000000000000000(0000) GS:ffff88006c600000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00007ff33cf89000 CR3: 0000000061c0a000 CR4: 00000000000006f0
Call Trace:
 usb_suspend_interface drivers/usb/core/driver.c:1209
 usb_suspend_both+0x27f/0x7e0 drivers/usb/core/driver.c:1314
 usb_runtime_suspend+0x41/0x120 drivers/usb/core/driver.c:1852
 __rpm_callback+0x339/0xb60 drivers/base/power/runtime.c:334
 rpm_callback+0x106/0x220 drivers/base/power/runtime.c:461
 rpm_suspend+0x465/0x1980 drivers/base/power/runtime.c:596
 __pm_runtime_suspend+0x11e/0x230 drivers/base/power/runtime.c:1009
 pm_runtime_put_sync_autosuspend ./include/linux/pm_runtime.h:251
 usb_new_device+0xa37/0x1020 drivers/usb/core/hub.c:2487
 hub_port_connect drivers/usb/core/hub.c:4903
 hub_port_connect_change drivers/usb/core/hub.c:5009
 port_event drivers/usb/core/hub.c:5115
 hub_event+0x194d/0x3740 drivers/usb/core/hub.c:5195
 process_one_work+0xc7f/0x1db0 kernel/workqueue.c:2119
 worker_thread+0x221/0x1850 kernel/workqueue.c:2253
 kthread+0x3a1/0x470 kernel/kthread.c:231
 ret_from_fork+0x2a/0x40 arch/x86/entry/entry_64.S:431
Code: 8d 7c 24 20 48 89 fa 48 c1 ea 03 80 3c 02 00 75 5b 48 b8 00 00
00 00 00 fc ff df 4d 8b 6c 24 20 49 8d 7d 08 48 89 fa 48 c1 ea 03 <80>
3c 02 00 75 34 4d 8b 6d 08 4d 85 ed 74 0b e8 26 2b 51 fd 4c
RIP: asix_suspend+0x76/0xc0 RSP: ffff88006bbae718
---[ end trace dfc4f5649284342c ]---
