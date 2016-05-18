From: Guenter Roeck <linux@roeck-us.net>
Subject: Crashes in -next due to 'phy: add support for a reset-gpio
 specification'
Date: Tue, 17 May 2016 21:37:11 -0700
Message-ID: <573BF177.6090507@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: =?UTF-8?Q?Uwe_Kleine-K=c3=b6nig?= <u.kleine-koenig@pengutronix.de>,
	Network Development <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: "linux-next@vger.kernel.org" <linux-next@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

my xtensa qemu tests crash in -next as follows.

[ ... ]

[    9.366256] libphy: ethoc-mdio: probed
[    9.367389]  (null): could not attach to PHY
[    9.368555]  (null): failed to probe MDIO bus
[    9.371540] Unable to handle kernel paging request at virtual address 0000001c
[    9.371540]  pc = d0320926, ra = 903209d1
[    9.375358] Oops: sig: 11 [#1]
[    9.376081] PREEMPT
[    9.377080] CPU: 0 PID: 1 Comm: swapper Not tainted 4.6.0-next-20160517 #1
[    9.378397] task: d7c2c000 ti: d7c30000 task.ti: d7c30000
[    9.379394] a00: 903209d1 d7c31bd0 d7fb5810 00000001 00000000 00000000 d7f45c00 d7c31bd0
[    9.382298] a08: 00000000 00000000 00000000 00000000 00060100 d04b0c10 d7f45dfc d7c31bb0
[    9.385732] pc: d0320926, ps: 00060110, depc: 00000018, excvaddr: 0000001c
[    9.387061] lbeg: d0322e35, lend: d0322e57 lcount: 00000000, sar: 00000011
[    9.388173]
Stack: d7c31be0 00060700 d7f45c00 d7c31bd0 9021d509 d7c31c30 d7f45c00 00000000
        d0485dcc d0485dcc d7fb5810 d7c2c000 00000000 d7c31c30 d7f45c00 d025befc
        d0485dcc d7c30000 d7f45c34 d7c31bf0 9021c985 d7c31c50 d7f45c00 d7f45c34
[    9.396652] Call Trace:
[    9.397469]  [<d021d4d9>] __device_release_driver+0x7d/0x98
[    9.398869]  [<d021d509>] device_release_driver+0x15/0x20
[    9.400247]  [<d021c985>] bus_remove_device+0xc1/0xd4
[    9.401569]  [<d021a935>] device_del+0x109/0x15c
[    9.402794]  [<d025c3f9>] phy_mdio_device_remove+0xd/0x18
[    9.404124]  [<d025d264>] mdiobus_unregister+0x40/0x5c
[    9.405444]  [<d025ff44>] ethoc_probe+0x534/0x5b8
[    9.406742]  [<d021e2e0>] platform_drv_probe+0x28/0x48
[    9.408122]  [<d021d1e5>] driver_probe_device+0x101/0x234
[    9.409499]  [<d021d395>] __driver_attach+0x7d/0x98
[    9.410809]  [<d021bd80>] bus_for_each_dev+0x30/0x5c
[    9.412104]  [<d021cdf0>] driver_attach+0x14/0x18
[    9.413385]  [<d021ca61>] bus_add_driver+0xc9/0x198
[    9.414686]  [<d021d7d4>] driver_register+0x70/0xa0
[    9.416001]  [<d021e2b4>] __platform_driver_register+0x24/0x28
[    9.417463]  [<d04a1d34>] ethoc_driver_init+0x10/0x14
[    9.418824]  [<d00032c8>] do_one_initcall+0x80/0x1ac
[    9.420083]  [<d049386d>] kernel_init_freeable+0x131/0x198
[    9.421504]  [<d03236e8>] kernel_init+0xc/0xb0
[    9.422693]  [<d000482c>] ret_from_kernel_thread+0x8/0xc

Bisect points to commit da47b4572056 ("phy: add support for a reset-gpio specification").
Bisect log is attached. Reverting the patch fixes the problem.

I think there may be a number of problems, all of them exposed by the patch
but really separate.

GPIOLIB is not configured in my test case, meaning gpiod_get_optional()
returns -ENOSYS, and phy_probe() thus returns an error. Question here is if
it is really appropriate for the XXX_optional() gpiolib functions to return
an error if GPIOLIB is not configured. Either case, result is that pretty
much all phy registrations will now fail if GPIOLIB is not configured.

Also, I suspect that there may be a bug in the error handling path
of ethoc_probe(). No idea what exactly is wrong, though. Other drivers
use pretty much the same code sequence for mdio registration and associated
error handling.

Last but not least, something seems to be wrong with the use of dev_err()
with &netdev->dev if register_netdev() has not yet been called. Maybe someone
has some insight ?

Test scripts and root file system used for the test are available at
https://github.com/groeck/linux-build-test/tree/master/rootfs/xtensa.

Guenter

---
# bad: [31b8ce4d1f8150fdc29d2f8a649dc4835e7f2961] arm: Use _rcuidle suffix to allow clk_core_enable() to used from idle
# good: [2dcd0af568b0cf583645c8a317dd12e344b1c72a] Linux 4.6
git bisect start 'HEAD' 'v4.6'
# bad: [dfd08ad591ff4f6d19896f21fb6c10dc4998dae4] Merge remote-tracking branch 'net-next/master'
git bisect bad dfd08ad591ff4f6d19896f21fb6c10dc4998dae4
# good: [eeb1cd39e9e27d89375b33c3a907807fb5adba7e] Merge remote-tracking branch 'xfs/for-next'
git bisect good eeb1cd39e9e27d89375b33c3a907807fb5adba7e
# good: [b75803d52a2ce1f6cbaf7ae0ae40a369210070cf] tcp: refactor struct tcp_skb_cb
git bisect good b75803d52a2ce1f6cbaf7ae0ae40a369210070cf
# good: [c2f40435ab0963284d348993b10ac66de6329b74] Merge remote-tracking branch 'v4l-dvb/master'
git bisect good c2f40435ab0963284d348993b10ac66de6329b74
# good: [678c657e09034d6f87d254b3183873d6e4a493e4] Merge remote-tracking branch 'slave-dma/next'
git bisect good 678c657e09034d6f87d254b3183873d6e4a493e4
# good: [6a47a570321fdcd2b6fc9e6537b2a3650d0fd04b] Merge branch 'mlx5-next'
git bisect good 6a47a570321fdcd2b6fc9e6537b2a3650d0fd04b
# good: [06566e5dd4e53f57fc3daa12fb8b5252772d70de] i40e: Refactor ethtool get_settings
git bisect good 06566e5dd4e53f57fc3daa12fb8b5252772d70de
# bad: [10cbc6843446165ee250e1ee80dc19ee325f1e6d] net/sched: cls_flower: Hardware offloaded filters statistics support
git bisect bad 10cbc6843446165ee250e1ee80dc19ee325f1e6d
# bad: [da47b4572056487fd7941c26f73b3e8815ff712a] phy: add support for a reset-gpio specification
git bisect bad da47b4572056487fd7941c26f73b3e8815ff712a
# good: [5049e33b559a44e9f216d86c58c7c7fce6f5df2f] bnxt_en: Add BCM57314 device ID.
git bisect good 5049e33b559a44e9f216d86c58c7c7fce6f5df2f
# good: [d96a83def2f70ea7b26268efdd44eb9f1e400171] i40e: don't add broadcast filter for VFs
git bisect good d96a83def2f70ea7b26268efdd44eb9f1e400171
# good: [1c306f7f62a38ee5f05f0ee994dfe82d654cf47c] i40e: fix an uninitialized variable bug
git bisect good 1c306f7f62a38ee5f05f0ee994dfe82d654cf47c
# good: [bf14e9ec80dea9a16cd47bdf1d7c418add2594f0] Merge branch 'bnxt_en-next'
git bisect good bf14e9ec80dea9a16cd47bdf1d7c418add2594f0
# good: [f23e0f6507d9e5bcfc30a7f6be5d8df8fad9ec85] Merge branch '40GbE' of git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue
git bisect good f23e0f6507d9e5bcfc30a7f6be5d8df8fad9ec85
# first bad commit: [da47b4572056487fd7941c26f73b3e8815ff712a] phy: add support for a reset-gpio specification
