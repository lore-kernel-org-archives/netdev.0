From: Andrey Konovalov <andreyknvl@google.com>
Subject: Re: [RFT] lan78xx: FIX use-after-free in lan78xx_write_reg
Date: Wed, 27 Sep 2017 14:12:17 +0200
Message-ID: <CAAeHK+y5nfeMYC8wAsU5ajrhKdU9i4CNYh8UAD8g6S=HFtgAmw@mail.gmail.com>
References: <d7710b468c6c1b9cf3b3fe2fc986118a2cd2639a.1506510873.git.arvind.yadav.cs@gmail.com>
 <CAAeHK+y1pc98H4xcVC79yBdfAD3212VxUYzjvFGx9bumwvH_KQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "David S. Miller" <davem@davemloft.net>,
        Woojung Huh <woojung.huh@microchip.com>,
        Microchip Linux Driver Support <UNGLinuxDriver@microchip.com>,
        netdev <netdev@vger.kernel.org>,
        Kostya Serebryany <kcc@google.com>,
        Dmitry Vyukov <dvyukov@google.com>, Nisar.Sayed@microchip.com,
        USB list <linux-usb@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        syzkaller <syzkaller@googlegroups.com>
To: Arvind Yadav <arvind.yadav.cs@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAAeHK+y1pc98H4xcVC79yBdfAD3212VxUYzjvFGx9bumwvH_KQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 27, 2017 at 2:06 PM, Andrey Konovalov <andreyknvl@google.com> wrote:
> On Wed, Sep 27, 2017 at 1:18 PM, Arvind Yadav <arvind.yadav.cs@gmail.com> wrote:
>> We are not releasing 'buf' memory on failure or disconnect a device.
>>
>> Adding 'u8 *buf' as part of 'lan78xx_net' structure to make proper
>> handle for 'buf'.
>> Now releasing 'buf' memory on failure. It's allocate first in
>> lan78xx_probe() and it should be freed last in lan78xx_disconnect().
>>
>> Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
>
> Hi Arvind,
>
> I've tried your patch and still see a crash.
>
> Thanks!
>
> lan78xx 1-1:90.0 (unnamed net_device) (uninitialized): can't register MDIO bus
> lan78xx: probe of 1-1:90.0 failed with error -5
> usb 1-1: USB disconnect, device number 2
> ==================================================================
> BUG: KASAN: use-after-free in lan78xx_write_reg.isra.21+0x1a8/0x1b0
> Read of size 8 at addr ffff880063dfac40 by task kworker/1:1/1152

It seems that the bug is caused by the fact that the
lan78xx_deferred_multicast_write() work is not shut down on
lan78xx_probe() failure.

>
> CPU: 1 PID: 1152 Comm: kworker/1:1 Not tainted
> 4.14.0-rc2-42660-g24b7bd59eec0-dirty #274
> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
> Workqueue: events lan78xx_deferred_multicast_write
> Call Trace:
>  __dump_stack lib/dump_stack.c:16
>  dump_stack+0x292/0x395 lib/dump_stack.c:52
>  print_address_description+0x78/0x280 mm/kasan/report.c:252
>  kasan_report_error mm/kasan/report.c:351
>  kasan_report+0x23d/0x350 mm/kasan/report.c:409
>  __asan_report_load8_noabort+0x19/0x20 mm/kasan/report.c:430
>  lan78xx_write_reg.isra.21+0x1a8/0x1b0 drivers/net/usb/lan78xx.c:459
>  lan78xx_deferred_multicast_write+0x10d/0x1a0 drivers/net/usb/lan78xx.c:1043
>  process_one_work+0xc7f/0x1db0 kernel/workqueue.c:2119
>  worker_thread+0x221/0x1850 kernel/workqueue.c:2253
>  kthread+0x3a1/0x470 kernel/kthread.c:231
>  ret_from_fork+0x2a/0x40 arch/x86/entry/entry_64.S:431
>
> Allocated by task 1848:
>  save_stack_trace+0x1b/0x20 arch/x86/kernel/stacktrace.c:59
>  save_stack+0x43/0xd0 mm/kasan/kasan.c:447
>  set_track mm/kasan/kasan.c:459
>  kasan_kmalloc+0xad/0xe0 mm/kasan/kasan.c:551
>  __kmalloc_node+0x192/0x480 mm/slub.c:3827
>  kmalloc_node ./include/linux/slab.h:535
>  kvmalloc_node+0x69/0xd0 mm/util.c:397
>  kvmalloc ./include/linux/mm.h:529
>  kvzalloc ./include/linux/mm.h:537
>  alloc_netdev_mqs+0x173/0xea0 net/core/dev.c:8023
>  alloc_etherdev_mqs+0x38/0x40 net/ethernet/eth.c:391
>  lan78xx_probe+0x13a/0x3020 drivers/net/usb/lan78xx.c:3545
>  usb_probe_interface+0x35d/0x8e0 drivers/usb/core/driver.c:361
>  really_probe drivers/base/dd.c:413
>  driver_probe_device+0x610/0xa00 drivers/base/dd.c:557
>  __device_attach_driver+0x230/0x290 drivers/base/dd.c:653
>  bus_for_each_drv+0x161/0x210 drivers/base/bus.c:463
>  __device_attach+0x26e/0x3d0 drivers/base/dd.c:710
>  device_initial_probe+0x1f/0x30 drivers/base/dd.c:757
>  bus_probe_device+0x1eb/0x290 drivers/base/bus.c:523
>  device_add+0xd0b/0x1660 drivers/base/core.c:1835
>  usb_set_configuration+0x104e/0x1870 drivers/usb/core/message.c:1932
>  generic_probe+0x73/0xe0 drivers/usb/core/generic.c:174
>  usb_probe_device+0xaf/0xe0 drivers/usb/core/driver.c:266
>  really_probe drivers/base/dd.c:413
>  driver_probe_device+0x610/0xa00 drivers/base/dd.c:557
>  __device_attach_driver+0x230/0x290 drivers/base/dd.c:653
>  bus_for_each_drv+0x161/0x210 drivers/base/bus.c:463
>  __device_attach+0x26e/0x3d0 drivers/base/dd.c:710
>  device_initial_probe+0x1f/0x30 drivers/base/dd.c:757
>  bus_probe_device+0x1eb/0x290 drivers/base/bus.c:523
>  device_add+0xd0b/0x1660 drivers/base/core.c:1835
>  usb_new_device+0x7b8/0x1020 drivers/usb/core/hub.c:2457
>  hub_port_connect drivers/usb/core/hub.c:4903
>  hub_port_connect_change drivers/usb/core/hub.c:5009
>  port_event drivers/usb/core/hub.c:5115
>  hub_event+0x194d/0x3740 drivers/usb/core/hub.c:5195
>  process_one_work+0xc7f/0x1db0 kernel/workqueue.c:2119
>  worker_thread+0x221/0x1850 kernel/workqueue.c:2253
>  kthread+0x3a1/0x470 kernel/kthread.c:231
>  ret_from_fork+0x2a/0x40 arch/x86/entry/entry_64.S:431
>
> Freed by task 1848:
>  save_stack_trace+0x1b/0x20 arch/x86/kernel/stacktrace.c:59
>  save_stack+0x43/0xd0 mm/kasan/kasan.c:447
>  set_track mm/kasan/kasan.c:459
>  kasan_slab_free+0x72/0xc0 mm/kasan/kasan.c:524
>  slab_free_hook mm/slub.c:1390
>  slab_free_freelist_hook mm/slub.c:1412
>  slab_free mm/slub.c:2988
>  kfree+0xf6/0x2f0 mm/slub.c:3919
>  kvfree+0x3b/0x60 mm/util.c:416
>  netdev_freemem net/core/dev.c:7975
>  free_netdev+0x304/0x3c0 net/core/dev.c:8137
>  lan78xx_probe+0x21a4/0x3020 drivers/net/usb/lan78xx.c:3649
>  usb_probe_interface+0x35d/0x8e0 drivers/usb/core/driver.c:361
>  really_probe drivers/base/dd.c:413
>  driver_probe_device+0x610/0xa00 drivers/base/dd.c:557
>  __device_attach_driver+0x230/0x290 drivers/base/dd.c:653
>  bus_for_each_drv+0x161/0x210 drivers/base/bus.c:463
>  __device_attach+0x26e/0x3d0 drivers/base/dd.c:710
>  device_initial_probe+0x1f/0x30 drivers/base/dd.c:757
>  bus_probe_device+0x1eb/0x290 drivers/base/bus.c:523
>  device_add+0xd0b/0x1660 drivers/base/core.c:1835
>  usb_set_configuration+0x104e/0x1870 drivers/usb/core/message.c:1932
>  generic_probe+0x73/0xe0 drivers/usb/core/generic.c:174
>  usb_probe_device+0xaf/0xe0 drivers/usb/core/driver.c:266
>  really_probe drivers/base/dd.c:413
>  driver_probe_device+0x610/0xa00 drivers/base/dd.c:557
>  __device_attach_driver+0x230/0x290 drivers/base/dd.c:653
>  bus_for_each_drv+0x161/0x210 drivers/base/bus.c:463
>  __device_attach+0x26e/0x3d0 drivers/base/dd.c:710
>  device_initial_probe+0x1f/0x30 drivers/base/dd.c:757
>  bus_probe_device+0x1eb/0x290 drivers/base/bus.c:523
>  device_add+0xd0b/0x1660 drivers/base/core.c:1835
>  usb_new_device+0x7b8/0x1020 drivers/usb/core/hub.c:2457
>  hub_port_connect drivers/usb/core/hub.c:4903
>  hub_port_connect_change drivers/usb/core/hub.c:5009
>  port_event drivers/usb/core/hub.c:5115
>  hub_event+0x194d/0x3740 drivers/usb/core/hub.c:5195
>  process_one_work+0xc7f/0x1db0 kernel/workqueue.c:2119
>  worker_thread+0x221/0x1850 kernel/workqueue.c:2253
>  kthread+0x3a1/0x470 kernel/kthread.c:231
>  ret_from_fork+0x2a/0x40 arch/x86/entry/entry_64.S:431
>
> The buggy address belongs to the object at ffff880063dfa100
>  which belongs to the cache kmalloc-8192 of size 8192
> The buggy address is located 2880 bytes inside of
>  8192-byte region [ffff880063dfa100, ffff880063dfc100)
> The buggy address belongs to the page:
> page:ffffea00018f7e00 count:1 mapcount:0 mapping:          (null)
> index:0x0 compound_mapcount: 0
> flags: 0x100000000008100(slab|head)
> raw: 0100000000008100 0000000000000000 0000000000000000 0000000100030003
> raw: ffffea0001afd800 0000000300000003 ffff88006c402a80 0000000000000000
> page dumped because: kasan: bad access detected
>
> Memory state around the buggy address:
>  ffff880063dfab00: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
>  ffff880063dfab80: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
>>ffff880063dfac00: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
>                                            ^
>  ffff880063dfac80: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
>  ffff880063dfad00: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
> ==================================================================
>
>> ---
>>  drivers/net/usb/lan78xx.c | 14 +++++++++-----
>>  1 file changed, 9 insertions(+), 5 deletions(-)
>>
>> diff --git a/drivers/net/usb/lan78xx.c b/drivers/net/usb/lan78xx.c
>> index b99a7fb..e653982 100644
>> --- a/drivers/net/usb/lan78xx.c
>> +++ b/drivers/net/usb/lan78xx.c
>> @@ -402,6 +402,7 @@ struct lan78xx_net {
>>         struct statstage        stats;
>>
>>         struct irq_domain_data  domain_data;
>> +       u8 *buf;
>>  };
>>
>>  /* define external phy id */
>> @@ -3470,6 +3471,9 @@ static void lan78xx_disconnect(struct usb_interface *intf)
>>
>>         usb_scuttle_anchored_urbs(&dev->deferred);
>>
>> +       kfree(dev->buf);
>> +       dev->buf = NULL;
>> +
>>         lan78xx_unbind(dev, intf);
>>
>>         usb_kill_urb(dev->urb_intr);
>> @@ -3520,7 +3524,6 @@ static int lan78xx_probe(struct usb_interface *intf,
>>         int ret;
>>         unsigned maxp;
>>         unsigned period;
>> -       u8 *buf = NULL;
>>
>>         udev = interface_to_usbdev(intf);
>>         udev = usb_get_dev(udev);
>> @@ -3588,16 +3591,15 @@ static int lan78xx_probe(struct usb_interface *intf,
>>         period = dev->ep_intr->desc.bInterval;
>>
>>         maxp = usb_maxpacket(dev->udev, dev->pipe_intr, 0);
>> -       buf = kmalloc(maxp, GFP_KERNEL);
>> -       if (buf) {
>> +       dev->buf = kmalloc(maxp, GFP_KERNEL);
>> +       if (dev->buf) {
>>                 dev->urb_intr = usb_alloc_urb(0, GFP_KERNEL);
>>                 if (!dev->urb_intr) {
>>                         ret = -ENOMEM;
>> -                       kfree(buf);
>>                         goto out3;
>>                 } else {
>>                         usb_fill_int_urb(dev->urb_intr, dev->udev,
>> -                                        dev->pipe_intr, buf, maxp,
>> +                                        dev->pipe_intr, dev->buf, maxp,
>>                                          intr_complete, dev, period);
>>                 }
>>         }
>> @@ -3626,6 +3628,8 @@ static int lan78xx_probe(struct usb_interface *intf,
>>         return 0;
>>
>>  out3:
>> +       kfree(dev->buf);
>> +       dev->buf = NULL;
>>         lan78xx_unbind(dev, intf);
>>  out2:
>>         free_netdev(netdev);
>> --
>> 1.9.1
>>
