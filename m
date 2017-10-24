From: Andrey Konovalov <andreyknvl-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: usb/net/asix: kernel hang in asix_phy_reset
Date: Tue, 24 Oct 2017 16:59:34 +0200
Message-ID: <CAAeHK+x3ZvRpn3dxk6KmeJoWqLOAu26YmEpczC2LGZxB7u-U4g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Dmitry Vyukov <dvyukov-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
        Kostya Serebryany <kcc-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
        syzkaller <syzkaller-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, allan <allan-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org>,
        Peter Chen <peter.chen-3arQi8VN3Tc@public.gmane.org>,
        Greg Ungerer <gerg-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org>,
        Colin Ian King <colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
        Philippe Reynes <tremyfr-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Dean Jenkins <Dean_Jenkins-nmGgyN9QBj3QT0dZR+AlfA@public.gmane.org>,
        USB list <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi!

While fuzzing the kernel with syzkaller I've been getting kernel hangs
within the asix driver.

On commit 6cff0a118f23b98c604a3604ea9de11338e24fbe (4.14-rc6+).

As far as I can tell the issue is that asix_phy_reset() doesn't
enforce proper timeout.

asix_phy_reset() calls asix_mdio_read() in a loop 5000 times with 100
us delay, which gives 500 ms of sleeping time, but it doesn't account
for the time while asix_mdio_read() executes. asix_mdio_read() in
turns contains another loop for 30 iterations with a sleep for 1 ms
(and does a bunch of stuff besides that). As a result asix_mdio_read()
takes ~80 ms in my setup. This results in at least 5000 * 80 ms = 400
seconds of delay in addition to those insignificant 500 ms.

Hang stack trace:

[<ffffffff8297c34e>] usb_start_wait_urb+0xfe/0x220 drivers/usb/core/message.c:61
[<     inline     >] usb_internal_control_msg drivers/usb/core/message.c:100
[<ffffffff8297c735>] usb_control_msg+0x2c5/0x3a0 drivers/usb/core/message.c:151
[<ffffffff8290efad>] __usbnet_read_cmd+0xcd/0x180 drivers/net/usb/usbnet.c:1986
[<ffffffff8290f0df>] usbnet_read_cmd+0x7f/0xe0 drivers/net/usb/usbnet.c:2044
[<ffffffff82900465>] asix_read_cmd+0x75/0xe0 drivers/net/usb/asix_common.c:37
[<ffffffff8290252b>] asix_mdio_read+0xbb/0x150 drivers/net/usb/asix_common.c:471
[<ffffffff828fe64a>] asix_phy_reset.isra.9+0xfa/0x1d0
drivers/net/usb/asix_devices.c:227
[<ffffffff828ff6c7>] ax88172_bind+0x397/0x4e0 drivers/net/usb/asix_devices.c:284
[<ffffffff829134b6>] usbnet_probe+0xb06/0x2600 drivers/net/usb/usbnet.c:1726
[<ffffffff82989f58>] usb_probe_interface+0x358/0x880
drivers/usb/core/driver.c:361
[<     inline     >] really_probe drivers/base/dd.c:413
[<ffffffff824bd780>] driver_probe_device+0x490/0x800 drivers/base/dd.c:557
[<ffffffff824bdedb>] __device_attach_driver+0x22b/0x290 drivers/base/dd.c:653
[<ffffffff824b7e4a>] bus_for_each_drv+0xfa/0x170 drivers/base/bus.c:463
[<ffffffff824bd10b>] __device_attach+0x1ab/0x290 drivers/base/dd.c:710
[<ffffffff824bdfda>] device_initial_probe+0x1a/0x20 drivers/base/dd.c:757
[<ffffffff824bb086>] bus_probe_device+0x1e6/0x290 drivers/base/bus.c:523
[<ffffffff824b53ff>] device_add+0xb2f/0x1340 drivers/base/core.c:1835
[<ffffffff829836ad>] usb_set_configuration+0xe9d/0x1660
drivers/usb/core/message.c:1932
[<ffffffff829a314e>] generic_probe+0x6e/0xe0 drivers/usb/core/generic.c:174
[<ffffffff82989bca>] usb_probe_device+0xaa/0xe0 drivers/usb/core/driver.c:266
[<     inline     >] really_probe drivers/base/dd.c:413
[<ffffffff824bd780>] driver_probe_device+0x490/0x800 drivers/base/dd.c:557
[<ffffffff824bdedb>] __device_attach_driver+0x22b/0x290 drivers/base/dd.c:653
[<ffffffff824b7e4a>] bus_for_each_drv+0xfa/0x170 drivers/base/bus.c:463
[<ffffffff824bd10b>] __device_attach+0x1ab/0x290 drivers/base/dd.c:710
[<ffffffff824bdfda>] device_initial_probe+0x1a/0x20 drivers/base/dd.c:757
[<ffffffff824bb086>] bus_probe_device+0x1e6/0x290 drivers/base/bus.c:523
[<ffffffff824b53ff>] device_add+0xb2f/0x1340 drivers/base/core.c:1835
[<ffffffff82966d53>] usb_new_device+0x7b3/0xff0 drivers/usb/core/hub.c:2457
[<     inline     >] hub_port_connect drivers/usb/core/hub.c:4906
[<     inline     >] hub_port_connect_change drivers/usb/core/hub.c:5012
[<     inline     >] port_event drivers/usb/core/hub.c:5118
[<ffffffff8296a69a>] hub_event+0x133a/0x2d90 drivers/usb/core/hub.c:5198
[<ffffffff8115d7ab>] process_one_work+0x78b/0x1540 kernel/workqueue.c:2113
[<ffffffff8115e647>] worker_thread+0xe7/0xff0 kernel/workqueue.c:2247
[<ffffffff8116d63c>] kthread+0x33c/0x410 kernel/kthread.c:231
[<ffffffff838d45da>] ret_from_fork+0x2a/0x40 arch/x86/entry/entry_64.S:431
[<ffffffffffffffff>] 0xffffffffffffffff

Messages printed to kernel log:

[  244.451821] asix 1-1:0.0 (unnamed net_device) (uninitialized):
Failed to enable software MII access
[  244.470152] asix 1-1:0.0 (unnamed net_device) (uninitialized):
Failed to read reg index 0x0000: -71
[  244.490199] asix 1-1:0.0 (unnamed net_device) (uninitialized):
Failed to read reg index 0x0000: -71
[  244.510193] asix 1-1:0.0 (unnamed net_device) (uninitialized):
Failed to write reg index 0x0000: -71
[  244.511992] asix 1-1:0.0 (unnamed net_device) (uninitialized):
Failed to enable hardware MII access
[  244.530191] asix 1-1:0.0 (unnamed net_device) (uninitialized):
Failed to write reg index 0x0000: -71
[  244.532024] asix 1-1:0.0 (unnamed net_device) (uninitialized):
Failed to enable software MII access
[  244.550197] asix 1-1:0.0 (unnamed net_device) (uninitialized):
Failed to read reg index 0x0000: -71
[  244.570198] asix 1-1:0.0 (unnamed net_device) (uninitialized):
Failed to read reg index 0x0000: -71
[  244.590194] asix 1-1:0.0 (unnamed net_device) (uninitialized):
Failed to write reg index 0x0000: -71
[  244.591960] asix 1-1:0.0 (unnamed net_device) (uninitialized):
Failed to enable hardware MII access
[  244.610193] asix 1-1:0.0 (unnamed net_device) (uninitialized):
Failed to write reg index 0x0000: -71
[  244.611978] asix 1-1:0.0 (unnamed net_device) (uninitialized):
Failed to enable software MII access
[  244.630224] asix 1-1:0.0 (unnamed net_device) (uninitialized):
Failed to read reg index 0x0000: -71
[  244.650197] asix 1-1:0.0 (unnamed net_device) (uninitialized):
Failed to read reg index 0x0000: -71
[  244.670193] asix 1-1:0.0 (unnamed net_device) (uninitialized):
Failed to write reg index 0x0000: -71
[  244.671991] asix 1-1:0.0 (unnamed net_device) (uninitialized):
Failed to enable hardware MII access
[  244.690170] asix 1-1:0.0 (unnamed net_device) (uninitialized):
Failed to write reg index 0x0000: -71
[  244.691907] asix 1-1:0.0 (unnamed net_device) (uninitialized):
Failed to enable software MII access
[  244.710201] asix 1-1:0.0 (unnamed net_device) (uninitialized):
Failed to read reg index 0x0000: -71
[  244.730205] asix 1-1:0.0 (unnamed net_device) (uninitialized):
Failed to read reg index 0x0000: -71
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
