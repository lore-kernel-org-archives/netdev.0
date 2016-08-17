From: Loc Ho <lho-qTEPVZfXA3Y@public.gmane.org>
Subject: Re: regression in xgene-enet in 4.8-rc series, oops from xgene_enet_probe
Date: Wed, 17 Aug 2016 10:14:51 -0700
Message-ID: <CAPw-ZT=fTQYz=6sfpyUe5AXnEN6TzF1PgaLJ+QWib-yQsgWhfA@mail.gmail.com>
References: <CAAqcGHmwjZS8_NjZnXDcgw+x5YAGt+mCdwbgN++ipVqXLMuTaQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Iyappan Subramanian <isubramanian-qTEPVZfXA3Y@public.gmane.org>, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"patches-qTEPVZfXA3Y@public.gmane.org" <patches-qTEPVZfXA3Y@public.gmane.org>, linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org,
	"linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org"
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
To: Riku Voipio <riku.voipio-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAAqcGHmwjZS8_NjZnXDcgw+x5YAGt+mCdwbgN++ipVqXLMuTaQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Riku,

>> When the driver is configured as kernel module and when it gets
>> unloaded and reloaded, kernel crash was observed.  This patch
>> addresses the software cleanup by doing the following,
>>
>> - Moved register_netdev call after hardware is ready
>> - Since ndev is not ready, added set_irq_name to set irq name
>> - Since ndev is not ready, changed mdio_bus->parent to pdev->dev
>> - Replaced netif_start(stop)_queue by netif_tx_start(stop)_queues
>> - Removed napi_del call since it's called by free_netdev
>> - Added dev_close call, within remove
>> - Added shutdown callback
>> - Changed to use dmam_ APIs
>
> Bisecting points this patch, commited as
> cb0366b7c16427a25923350b69f53a5b1345a34b the cause of oops when
> booting apm mustang:
>
> [    1.670201] ------------[ cut here ]------------
> [    1.674804] WARNING: CPU: 2 PID: 1 at ../net/core/dev.c:6696
> rollback_registered_many+0x60/0x300
> [    1.683543] Modules linked in: realtek
> [    1.687291]
> [    1.688774] CPU: 2 PID: 1 Comm: swapper/0 Not tainted
> 4.8.0-rc2-00037-g3ec60b92d3ba #1
> [    1.696648] Hardware name: APM X-Gene Mustang board (DT)
> [    1.701930] task: ffff8003ee078000 task.stack: ffff8003ee054000
> [    1.707819] PC is at rollback_registered_many+0x60/0x300
> [    1.713102] LR is at rollback_registered_many+0x30/0x300
> [    1.718384] pc : [] lr : [] pstate: 20000045
> [    1.725739] sp : ffff8003ee057b00
> [    1.729034] x29: ffff8003ee057b00 x28: ffff8003eda1a000
> [    1.734338] x27: 0000000000000002 x26: ffff8003ebcba970
> [    1.739641] x25: ffff8003eda1a208 x24: ffff8003eda1a010
> [    1.744945] x23: ffff8003ee057c58 x22: ffff8003ebcba000
> [    1.750247] x21: 00000000ffffffed x20: ffff8003ee057b70
> [    1.755549] x19: ffff8003ee057b50 x18: ffff000008dfafff
> [    1.760852] x17: 0000000000000007 x16: 0000000000000001
> [    1.766154] x15: ffff000008ce2000 x14: ffffffffffffffff
> [    1.771458] x13: 0000000000000008 x12: 0000000000000030
> [    1.776760] x11: 0000000000000030 x10: 0101010101010101
> [    1.782062] x9 : 0000000000000000 x8 : ffff8003df80c700
> [    1.787365] x7 : 0000000000000000 x6 : 0000000000000001
> [    1.792668] x5 : dead000000000100 x4 : dead000000000200
> [    1.797971] x3 : ffff8003ebcba070 x2 : 0000000000000000
> [    1.803273] x1 : ffff8003ee057b00 x0 : ffff8003ebcba000
> [    1.808575]
> [    1.810057] ---[ end trace 93f1dda704e63533 ]---
> [    1.814648] Call trace:
> [    1.816207] ata2: SATA link down (SStatus 0 SControl 4300)
> [    1.822535] Exception stack(0xffff8003ee057930 to 0xffff8003ee057a60)
> [    1.828941] 7920:
> ffff8003ee057b50 0001000000000000
> [    1.836729] 7940: ffff8003ee057b00 ffff000008773c18
> ffff8003ee057980 ffff000008849a1c
> [    1.844517] 7960: 0000000000000009 ffff000008e50000
> ffff8003ee0579a0 ffff0000086eb03c
> [    1.852305] 7980: ffff000008dbcde8 ffff8003fffe1ca0
> 0000000000000040 ffff8003ee057998
> [    1.860094] 79a0: ffff8003ee0579e0 ffff0000086eb1b0
> 0000000000000004 ffff8003ee057a4c
> f8003ebcba000 ffff8003ee057b00
> [    1.875669] 79e0: 0000000000000000 ffff8003ebcba070
> dead000000000200 dead000000000100
> [    1.883457] 7a00: 0000000000000001 0000000000000000
> ffff8003df80c700 0000000000000000
> [    1.884198] ata4: SATA link down (SStatus 0 SControl 4300)
> [    1.884211] ata3: SATA link down (SStatus 0 SControl 4300)
> [    1.902153] 7a20: 0101010101010101 0000000000000030
> 0000000000000030 0000000000000008
> [    1.909941] 7a40: ffffffffffffffff ffff000008ce2000
> 0000000000000001 0000000000000007
> [    1.917730] [] rollback_registered_many+0x60/0x300
> [    1.924050] [] rollback_registered+0x28/0x40
> [    1.929852] [] unregister_netdevice_queue+0x78/0xb8
> [    1.936259] [] unregister_netdev+0x20/0x30
> [    1.941889] [] xgene_enet_probe+0x638/0xf98
> [    1.947605] [] platform_drv_probe+0x50/0xb8
> [    1.953320] [] driver_probe_device+0x204/0x2b0
> [    1.959294] [] __driver_attach+0xac/0xb0
> [    1.964751] [] bus_for_each_dev+0x60/0xa0
> [    1.970293] [] driver_attach+0x20/0x28
> [    1.975576] [] bus_add_driver+0x1d0/0x238
> [    1.981118] [] driver_register+0x60/0xf8
> [    1.986574] [] __platform_driver_register+0x40/0x48
> [    1.992982] [] xgene_enet_driver_init+0x18/0x20
> [    1.999044] [] do_one_initcall+0x38/0x128
> [    2.004588] [] kernel_init_freeable+0x1ac/0x250
> [    2.010651] [] kernel_init+0x10/0x100
> [    2.015847] [] ret_from_fork+0x10/0x40
> [    2.021152] network todo 'eth%d' but state 0
>
> Picked up from:
>
> https://storage.kernelci.org/mainline/v4.8-rc2-37-g3ec60b92d3ba/arm64-defconfig/lab-cambridge/boot-apm-mustang.html
>
> Visible on all mainline/apt-mustang boot reports. net-next seems to
> have a fix for this.

Iyappan will follow up if required. But I notice that you are using
1.13.xx boot loader. The latest official released boot loader version
is 1.15.23 (from late 2015). I would suggest and recommend that you
upgrade if possible.

-Loc
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
