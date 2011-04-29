From: tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Subject: [PATCH] usbnet: runtime pm: fix out of memory
Date: Fri, 29 Apr 2011 16:37:09 +0800
Message-ID: <1304066229-30875-1-git-send-email-tom.leiming@gmail.com>
Cc: Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

This patch makes use of the EVENT_DEV_OPEN flag introduced recently to
fix one out of memory issue, which can be reproduced on omap3/4 based
pandaboard/beagle XM easily with steps below:

	- enable runtime pm
	echo auto > /sys/devices/platform/usbhs-omap.0/ehci-omap.0/usb1/1-1/1-1.1/power/control

	- ifconfig eth0 up

	- then out of memroy happened, see [1] for kernel message.

Follows my analysis:
	- 'ifconfig eth0 up' brings eth0 out of suspend, and usbnet_resume
	is called to schedule dev->bh, then rx urbs are submited to prepare for
	recieving data;

	- some usbnet devices will produce garbage rx packets flood if
	info->reset is not called in usbnet_open.

	- so there is no enough chances for usbnet_bh to handle and release
	recieved skb buffers since many rx interrupts consumes cpu, so out of memory
	for atomic allocation in rx_submit happened.

This patch fixes the issue by simply not allowing schedule of usbnet_bh until device
is opened.

[1], dmesg
[  234.712005] smsc95xx 1-1.1:1.0: rpm_resume flags 0x4
[  234.712066] usb 1-1.1: rpm_resume flags 0x0
[  234.712066] usb 1-1: rpm_resume flags 0x0
[  234.712097] usb usb1: rpm_resume flags 0x0
[  234.712127] usb usb1: usb auto-resume
[  234.712158] ehci-omap ehci-omap.0: resume root hub
[  234.754028] hub 1-0:1.0: hub_resume
[  234.754821] hub 1-0:1.0: port 1: status 0507 change 0000
[  234.756011] hub 1-0:1.0: state 7 ports 3 chg 0000 evt 0000
[  234.756042] hub 1-0:1.0: rpm_resume flags 0x4
[  234.756072] usb usb1: rpm_resume flags 0x0
[  234.756164] usb usb1: rpm_resume returns 1
[  234.756195] hub 1-0:1.0: rpm_resume returns 0
[  234.756195] hub 1-0:1.0: rpm_suspend flags 0x4
[  234.756225] hub 1-0:1.0: rpm_suspend returns 0
[  234.756256] usb usb1: rpm_resume returns 0
[  234.757141] usb 1-1: usb auto-resume
[  234.793151] ehci-omap ehci-omap.0: GetStatus port:1 status 001005 0  ACK POWER sig=se0 PE CONNECT
[  234.816558] usb 1-1: finish resume
[  234.817871] hub 1-1:1.0: hub_resume
[  234.818420] hub 1-1:1.0: port 1: status 0507 change 0000
[  234.820495] ehci-omap ehci-omap.0: reused qh eec50220 schedule
[  234.820495] usb 1-1: link qh256-0001/eec50220 start 1 [1/0 us]
[  234.820587] usb 1-1: rpm_resume returns 0
[  234.820800] hub 1-1:1.0: state 7 ports 5 chg 0000 evt 0000
[  234.820800] hub 1-1:1.0: rpm_resume flags 0x4
[  234.820831] hub 1-1:1.0: rpm_resume returns 0
[  234.820861] hub 1-1:1.0: rpm_suspend flags 0x4
[  234.820861] hub 1-1:1.0: rpm_suspend returns 0
[  234.821777] usb 1-1.1: usb auto-resume
[  234.868591] hub 1-1:1.0: state 7 ports 5 chg 0000 evt 0002
[  234.868591] hub 1-1:1.0: rpm_resume flags 0x4
[  234.868621] hub 1-1:1.0: rpm_resume returns 0
[  234.868652] hub 1-1:1.0: rpm_suspend flags 0x4
[  234.868652] hub 1-1:1.0: rpm_suspend returns 0
[  234.879486] usb 1-1.1: finish resume
[  234.880279] usb 1-1.1: rpm_resume returns 0
[  234.880310] smsc95xx 1-1.1:1.0: rpm_resume returns 0
[  238.880187] ksoftirqd/0: page allocation failure. order:0, mode:0x20
[  238.880218] Backtrace:
[  238.880249] [<c01b9800>] (dump_backtrace+0x0/0xf8) from [<c065e1dc>] (dump_stack+0x18/0x1c)
[  238.880249]  r6:00000000 r5:00000000 r4:00000020 r3:00000002
[  238.880310] [<c065e1c4>] (dump_stack+0x0/0x1c) from [<c026ece4>] (__alloc_pages_nodemask+0x620/0x724)
[  238.880340] [<c026e6c4>] (__alloc_pages_nodemask+0x0/0x724) from [<c02986d4>] (kmem_getpages.clone.34+0x34/0xc8)
[  238.880371] [<c02986a0>] (kmem_getpages.clone.34+0x0/0xc8) from [<c02988f8>] (cache_grow.clone.42+0x84/0x154)
[  238.880371]  r6:ef871aa4 r5:ef871a80 r4:ef81fd40 r3:00000020
[  238.880401] [<c0298874>] (cache_grow.clone.42+0x0/0x154) from [<c0298b64>] (cache_alloc_refill+0x19c/0x1f0)
[  238.880432] [<c02989c8>] (cache_alloc_refill+0x0/0x1f0) from [<c0299804>] (kmem_cache_alloc+0x90/0x190)
[  238.880462] [<c0299774>] (kmem_cache_alloc+0x0/0x190) from [<c052e260>] (__alloc_skb+0x34/0xe8)
[  238.880493] [<c052e22c>] (__alloc_skb+0x0/0xe8) from [<bf0509f4>] (rx_submit+0x2c/0x1d4 [usbnet])
[  238.880523] [<bf0509c8>] (rx_submit+0x0/0x1d4 [usbnet]) from [<bf050d38>] (rx_complete+0x19c/0x1b0 [usbnet])
[  238.880737] [<bf050b9c>] (rx_complete+0x0/0x1b0 [usbnet]) from [<bf006fd0>] (usb_hcd_giveback_urb+0xa8/0xf4 [usbcore])
[  238.880737]  r8:eeeced34 r7:eeecec00 r6:eeecec00 r5:00000000 r4:eec2dd20
[  238.880767] r3:bf050b9c
[  238.880859] [<bf006f28>] (usb_hcd_giveback_urb+0x0/0xf4 [usbcore]) from [<bf03c8f8>] (ehci_urb_done+0xb0/0xbc [ehci_hcd])
[  238.880859]  r6:00000000 r5:eec2dd20 r4:eeeced44 r3:eec2dd34
[  238.880920] [<bf03c848>] (ehci_urb_done+0x0/0xbc [ehci_hcd]) from [<bf040204>] (qh_completions+0x308/0x3bc [ehci_hcd])
[  238.880920]  r7:00000000 r6:eeda21a0 r5:ffdfe3c0 r4:eeda21ac
[  238.880981] [<bf03fefc>] (qh_completions+0x0/0x3bc [ehci_hcd]) from [<bf040ef8>] (scan_async+0xb0/0x16c [ehci_hcd])
[  238.881011] [<bf040e48>] (scan_async+0x0/0x16c [ehci_hcd]) from [<bf040fec>] (ehci_work+0x38/0x90 [ehci_hcd])
[  238.881042] [<bf040fb4>] (ehci_work+0x0/0x90 [ehci_hcd]) from [<bf042940>] (ehci_irq+0x300/0x34c [ehci_hcd])
[  238.881072]  r4:eeeced34 r3:00000001
[  238.881134] [<bf042640>] (ehci_irq+0x0/0x34c [ehci_hcd]) from [<bf006828>] (usb_hcd_irq+0x40/0xac [usbcore])
[  238.881195] [<bf0067e8>] (usb_hcd_irq+0x0/0xac [usbcore]) from [<c0239764>] (handle_irq_event_percpu+0xb8/0x240)
[  238.881225]  r6:eec504e0 r5:0000006d r4:eec504e0 r3:bf0067e8
[  238.881256] [<c02396ac>] (handle_irq_event_percpu+0x0/0x240) from [<c0239930>] (handle_irq_event+0x44/0x64)
[  238.881256] [<c02398ec>] (handle_irq_event+0x0/0x64) from [<c023bbd0>] (handle_level_irq+0xe0/0x114)
[  238.881286]  r6:0000006d r5:c080c14c r4:c080c100 r3:00020000
[  238.881317] [<c023baf0>] (handle_level_irq+0x0/0x114) from [<c01ab090>] (asm_do_IRQ+0x90/0xd0)
[  238.881317]  r5:00000000 r4:0000006d
[  238.881347] [<c01ab000>] (asm_do_IRQ+0x0/0xd0) from [<c06624d0>] (__irq_svc+0x50/0x134)
[  238.881378] Exception stack(0xef837e20 to 0xef837e68)
[  238.881378] 7e20: 00000001 00185610 016cc000 c00490c0 eb380000 ef800540 00000020 00004ae0
[  238.881408] 7e40: 00000020 bf0509f4 60000013 ef837e9c ef837e40 ef837e68 c0226f0c c0298ca0
[  238.881408] 7e60: 20000013 ffffffff
[  238.881408]  r5:fa240100 r4:ffffffff
[  238.881439] [<c0298bb8>] (__kmalloc_track_caller+0x0/0x1d0) from [<c052e284>] (__alloc_skb+0x58/0xe8)
[  238.881469] [<c052e22c>] (__alloc_skb+0x0/0xe8) from [<bf0509f4>] (rx_submit+0x2c/0x1d4 [usbnet])
[  238.881500] [<bf0509c8>] (rx_submit+0x0/0x1d4 [usbnet]) from [<bf0513d8>] (usbnet_bh+0x1b4/0x250 [usbnet])
[  238.881530] [<bf051224>] (usbnet_bh+0x0/0x250 [usbnet]) from [<c01f912c>] (tasklet_action+0xb0/0x1f8)
[  238.881530]  r6:00000000 r5:ef9757f0 r4:ef9757ec r3:bf051224
[  238.881561] [<c01f907c>] (tasklet_action+0x0/0x1f8) from [<c01f97ac>] (__do_softirq+0x140/0x290)
[  238.881561]  r8:00000006 r7:00000101 r6:00000000 r5:c0806098 r4:00000001
[  238.881591] r3:c01f907c
[  238.881622] [<c01f966c>] (__do_softirq+0x0/0x290) from [<c01f99cc>] (run_ksoftirqd+0xd0/0x1f4)
[  238.881622] [<c01f98fc>] (run_ksoftirqd+0x0/0x1f4) from [<c02113b0>] (kthread+0x90/0x98)
[  238.881652]  r7:00000013 r6:c01f98fc r5:00000000 r4:ef831efc
[  238.881683] [<c0211320>] (kthread+0x0/0x98) from [<c01f62f4>] (do_exit+0x0/0x374)
[  238.881713]  r6:c01f62f4 r5:c0211320 r4:ef831efc
[  238.881713] Mem-info:
[  238.881744] Normal per-cpu:
[  238.881744] CPU    0: hi:  186, btch:  31 usd:  38
[  238.881744] CPU    1: hi:  186, btch:  31 usd: 169
[  238.881774] HighMem per-cpu:
[  238.881774] CPU    0: hi:   90, btch:  15 usd:  66
[  238.881774] CPU    1: hi:   90, btch:  15 usd:  86
[  238.881805] active_anon:544 inactive_anon:71 isolated_anon:0
[  238.881805]  active_file:926 inactive_file:2538 isolated_file:0
[  238.881805]  unevictable:0 dirty:10 writeback:0 unstable:0
[  238.881805]  free:57782 slab_reclaimable:864 slab_unreclaimable:186898
[  238.881805]  mapped:632 shmem:144 pagetables:50 bounce:0
[  238.881835] Normal free:1328kB min:3532kB low:4412kB high:5296kB active_anon:0kB inactive_anon:0kB active_file:880kB inactive_file:848kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:780288kB mlocked:0kB dirty:36kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:3456kB slab_unreclaimable:747592kB kernel_stack:392kB pagetables:200kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[  238.881866] lowmem_reserve[]: 0 1904 1904
[  238.881896] HighMem free:229800kB min:236kB low:508kB high:784kB active_anon:2176kB inactive_anon:284kB active_file:2824kB inactive_file:9304kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:243712kB mlocked:0kB dirty:4kB writeback:0kB mapped:2528kB shmem:576kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[  238.881927] lowmem_reserve[]: 0 0 0
[  238.881958] Normal: 0*4kB 4*8kB 6*16kB 0*32kB 1*64kB 1*128kB 0*256kB 2*512kB 0*1024kB 0*2048kB 0*4096kB = 1344kB
[  238.882019] HighMem: 6*4kB 2*8kB 4*16kB 4*32kB 1*64kB 1*128kB 0*256kB 2*512kB 3*1024kB 0*2048kB 55*4096kB = 229800kB
[  238.882080] 3610 total pagecache pages
[  238.882080] 0 pages in swap cache
[  238.882080] Swap cache stats: add 0, delete 0, find 0/0
[  238.882110] Free swap  = 0kB
[  238.882110] Total swap = 0kB
[  238.933776] 262144 pages of RAM
[  238.933776] 58240 free pages
[  238.933776] 10503 reserved pages
[  238.933776] 187773 slab pages
[  238.933807] 2475 pages shared
[  238.933807] 0 pages swap cached

Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Signed-off-by: Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 drivers/net/usb/usbnet.c |   10 +++++++---
 1 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 009bba3..9ab439d 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -645,6 +645,7 @@ int usbnet_stop (struct net_device *net)
 	struct driver_info	*info = dev->driver_info;
 	int			retval;
 
+	clear_bit(EVENT_DEV_OPEN, &dev->flags);
 	netif_stop_queue (net);
 
 	netif_info(dev, ifdown, dev->net,
@@ -1524,9 +1525,12 @@ int usbnet_resume (struct usb_interface *intf)
 		smp_mb();
 		clear_bit(EVENT_DEV_ASLEEP, &dev->flags);
 		spin_unlock_irq(&dev->txq.lock);
-		if (!(dev->txq.qlen >= TX_QLEN(dev)))
-			netif_start_queue(dev->net);
-		tasklet_schedule (&dev->bh);
+
+		if (test_bit(EVENT_DEV_OPEN, &dev->flags)) {
+			if (!(dev->txq.qlen >= TX_QLEN(dev)))
+				netif_start_queue(dev->net);
+			tasklet_schedule (&dev->bh);
+		}
 	}
 	return 0;
 }
-- 
1.7.4.1

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
