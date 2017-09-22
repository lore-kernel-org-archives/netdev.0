From: Andrey Konovalov <andreyknvl@google.com>
Subject: usb/wireless/rsi_91x: use-after-free write in __run_timers
Date: Fri, 22 Sep 2017 19:04:27 +0200
Message-ID: <CAAeHK+wXCaLZ8=enfsmjg-+FJsW1UhSCz8GUmSWhFxB4orLQ6w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Kalle Valo <kvalo@codeaurora.org>,
        Amitkumar Karwar <amit.karwar@redpinesignals.com>,
        Prameela Rani Garnepudi <prameela.j04cs@gmail.com>,
        Karun Eagalapati <karun256@gmail.com>,
        linux-wireless@vger.kernel.org, netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi!

I've got the following report while fuzzing the kernel with syzkaller.

On commit 6e80ecdddf4ea6f3cd84e83720f3d852e6624a68 (Sep 21).

==================================================================
BUG: KASAN: use-after-free in __run_timers+0xc0e/0xd40
Write of size 8 at addr ffff880069f701b8 by task swapper/0/0

CPU: 0 PID: 0 Comm: swapper/0 Not tainted 4.14.0-rc1-42311-g6e80ecdddf4e #234
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
Call Trace:
 <IRQ>
 __dump_stack lib/dump_stack.c:16
 dump_stack+0x292/0x395 lib/dump_stack.c:52
 print_address_description+0x78/0x280 mm/kasan/report.c:252
 kasan_report_error mm/kasan/report.c:351
 kasan_report+0x22f/0x340 mm/kasan/report.c:409
 __asan_report_store8_noabort+0x1c/0x20 mm/kasan/report.c:435
 collect_expired_timers ./include/linux/list.h:729
 __run_timers+0xc0e/0xd40 kernel/time/timer.c:1616
 run_timer_softirq+0x83/0x140 kernel/time/timer.c:1646
 __do_softirq+0x305/0xc2d kernel/softirq.c:284
 invoke_softirq kernel/softirq.c:364
 irq_exit+0x171/0x1a0 kernel/softirq.c:405
 exiting_irq ./arch/x86/include/asm/apic.h:638
 smp_apic_timer_interrupt+0x2b9/0x8d0 arch/x86/kernel/apic/apic.c:1048
 apic_timer_interrupt+0x9d/0xb0
 </IRQ>
RIP: 0010:native_safe_halt+0x6/0x10 ./arch/x86/include/asm/irqflags.h:53
RSP: 0018:ffffffff86607958 EFLAGS: 00000282 ORIG_RAX: ffffffffffffff10
RAX: dffffc0000000020 RBX: 1ffffffff0cc0f2f RCX: 0000000000000000
RDX: 0000000000000000 RSI: 0000000000000001 RDI: ffffffff8662ea64
RBP: ffffffff86607958 R08: ffffffff813d3501 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000000 R12: 1ffffffff0cc0f3b
R13: ffffffff86607a98 R14: ffffffff86fc1628 R15: 0000000000000000
 arch_safe_halt ./arch/x86/include/asm/paravirt.h:93
 default_idle+0x127/0x690 arch/x86/kernel/process.c:341
 arch_cpu_idle+0xf/0x20 arch/x86/kernel/process.c:332
 default_idle_call+0x3b/0x60 kernel/sched/idle.c:98
 cpuidle_idle_call kernel/sched/idle.c:156
 do_idle+0x35c/0x440 kernel/sched/idle.c:246
 cpu_startup_entry+0x1d/0x20 kernel/sched/idle.c:351
 rest_init+0xf3/0x100 init/main.c:435
 start_kernel+0x782/0x7b0 init/main.c:710
 x86_64_start_reservations+0x2a/0x2c arch/x86/kernel/head64.c:377
 x86_64_start_kernel+0x77/0x7a arch/x86/kernel/head64.c:358
 secondary_startup_64+0xa5/0xa5 arch/x86/kernel/head_64.S:235

Allocated by task 1845:
 save_stack_trace+0x1b/0x20 arch/x86/kernel/stacktrace.c:59
 save_stack+0x43/0xd0 mm/kasan/kasan.c:447
 set_track mm/kasan/kasan.c:459
 kasan_kmalloc+0xad/0xe0 mm/kasan/kasan.c:551
 kmem_cache_alloc_trace+0x11e/0x2d0 mm/slub.c:2772
 kmalloc ./include/linux/slab.h:493
 kzalloc ./include/linux/slab.h:666
 rsi_91x_init+0x98/0x510 drivers/net/wireless/rsi/rsi_91x_main.c:203
 rsi_probe+0xb6/0x13b0 drivers/net/wireless/rsi/rsi_91x_usb.c:665
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

Freed by task 1845:
 save_stack_trace+0x1b/0x20 arch/x86/kernel/stacktrace.c:59
 save_stack+0x43/0xd0 mm/kasan/kasan.c:447
 set_track mm/kasan/kasan.c:459
 kasan_slab_free+0x72/0xc0 mm/kasan/kasan.c:524
 slab_free_hook mm/slub.c:1390
 slab_free_freelist_hook mm/slub.c:1412
 slab_free mm/slub.c:2988
 kfree+0xf6/0x2f0 mm/slub.c:3919
 rsi_91x_deinit+0x1e8/0x250 drivers/net/wireless/rsi/rsi_91x_main.c:268
 rsi_probe+0xed1/0x13b0 drivers/net/wireless/rsi/rsi_91x_usb.c:709
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

The buggy address belongs to the object at ffff880069f70000
 which belongs to the cache kmalloc-2048 of size 2048
The buggy address is located 440 bytes inside of
 2048-byte region [ffff880069f70000, ffff880069f70800)
The buggy address belongs to the page:
page:ffffea0001a7dc00 count:1 mapcount:0 mapping:          (null)
index:0xffff880069f77700 compound_mapcount: 0
flags: 0x100000000008100(slab|head)
raw: 0100000000008100 0000000000000000 ffff880069f77700 00000001800f000c
raw: ffffea000190e000 0000000200000002 ffff88006c402d80 0000000000000000
page dumped because: kasan: bad access detected

Memory state around the buggy address:
 ffff880069f70080: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
 ffff880069f70100: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
>ffff880069f70180: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
                                        ^
 ffff880069f70200: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
 ffff880069f70280: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
==================================================================
