From: Guenter Roeck <linux@roeck-us.net>
Subject: Crashes in -next due to 'net: phy: Fix lack of reference count on
 PHY driver'
Date: Wed, 8 Feb 2017 21:15:12 -0800
Message-ID: <20170209051512.GA31314@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Mao Wenan <maowenan@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I see a number of my qemu tests in -next crash. Affected are tests
of nios2, xtensa, and arm64.

The arm64 crash log looks as follows.

[    0.734220] Hardware name: ZynqMP EP108 (DT)
[    0.734298] task: ffff80007cb50000 task.stack: ffff80007cb4c000
[    0.734533] PC is at phy_attach_direct+0x54/0x1b8
[    0.734592] LR is at phy_connect_direct+0x1c/0x70
[    0.734643] pc : [<ffff000008603354>] lr : [<ffff0000086035b4>] pstate: 60000045
...
[    0.740044] [<ffff000008603354>] phy_attach_direct+0x54/0x1b8
[    0.740118] [<ffff0000086035b4>] phy_connect_direct+0x1c/0x70
[    0.740191] [<ffff00000862e360>] macb_probe+0x5a8/0x978
[    0.740378] [<ffff000008555728>] platform_drv_probe+0x50/0xb8
[    0.740449] [<ffff0000085538f4>] driver_probe_device+0x224/0x2c8
[    0.740519] [<ffff000008553a44>] __driver_attach+0xac/0xb0
[    0.740587] [<ffff000008551a38>] bus_for_each_dev+0x60/0xa0
[    0.740653] [<ffff000008553200>] driver_attach+0x20/0x28
[    0.740716] [<ffff000008552e08>] bus_add_driver+0x1d0/0x238
[    0.740782] [<ffff0000085543b8>] driver_register+0x60/0xf8
[    0.740849] [<ffff000008555668>] __platform_driver_register+0x40/0x48
[    0.740924] [<ffff000008d41608>] macb_driver_init+0x18/0x20
[    0.740994] [<ffff000008083150>] do_one_initcall+0x38/0x120
[    0.741062] [<ffff000008d00cfc>] kernel_init_freeable+0x19c/0x23c
[    0.741134] [<ffff0000089077c0>] kernel_init+0x10/0x100
[    0.741199] [<ffff000008082ec0>] ret_from_fork+0x10/0x50

Detailed logs are available at http://kerneltests.org/builders, in the 'next'
column. The scripts used to run the tests are available in the architecture
subdirectories of https://github.com/groeck/linux-build-test/tree/master/rootfs.

I bisected the nios2 failure; it points to commit cafe8df8b9 ("net: phy: Fix
lack of reference count on PHY driver"). Bisect log is attached below.
Reverting this patch fixes the problem for all affected architectures
in my tests.

Guenter

---
# bad: [e3e6c5f3544c5d05c6b3b309a34f4f2c3537e993] Add linux-next specific files for 20170208
# good: [d5adbfcd5f7bcc6fa58a41c5c5ada0e5c826ce2c] Linux 4.10-rc7
git bisect start 'HEAD' 'v4.10-rc7'
# bad: [403e468309f9e2b2dbe264be1ad29b1486ed720e] Merge remote-tracking branch 'crypto/master'
git bisect bad 403e468309f9e2b2dbe264be1ad29b1486ed720e
# bad: [44448c3f07a3ae77164de4405fa97baca4f103f5] Merge remote-tracking branch 'hid/for-next'
git bisect bad 44448c3f07a3ae77164de4405fa97baca4f103f5
# bad: [dd4318312c6fc5c00ae7619f875fb73538a2c1e6] Merge remote-tracking branch 'omap/for-next'
git bisect bad dd4318312c6fc5c00ae7619f875fb73538a2c1e6
# good: [52b61c8b3eefd40f8a70131cdc0c7348f18f463c] Merge branch 'next/soc' into for-next
git bisect good 52b61c8b3eefd40f8a70131cdc0c7348f18f463c
# good: [cbd3dcf3b865b961a9c10ff16e42908832cee63f] Merge branch 'next/dt' into for-next
git bisect good cbd3dcf3b865b961a9c10ff16e42908832cee63f
# bad: [66842bac82cae0e9378eea1c54ab9751e32a929b] Merge remote-tracking branch 'arm/for-next'
git bisect bad 66842bac82cae0e9378eea1c54ab9751e32a929b
# bad: [926af6273fc683cd98cd0ce7bf0d04a02eed6742] Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net
git bisect bad 926af6273fc683cd98cd0ce7bf0d04a02eed6742
# bad: [2dcab598484185dea7ec22219c76dcdd59e3cb90] sctp: avoid BUG_ON on sctp_wait_for_sndbuf
git bisect bad 2dcab598484185dea7ec22219c76dcdd59e3cb90
# bad: [89389b4d5524350e74974cf711fe4a18206c09d3] Merge tag 'mac80211-for-davem-2017-02-06' of git://git.kernel.org/pub/scm/linux/kernel/git/jberg/mac80211
git bisect bad 89389b4d5524350e74974cf711fe4a18206c09d3
# bad: [34b2cef20f19c87999fff3da4071e66937db9644] ipv4: keep skb->dst around in presence of IP options
git bisect bad 34b2cef20f19c87999fff3da4071e66937db9644
# bad: [cafe8df8b9bc9aa3dffa827c1a6757c6cd36f657] net: phy: Fix lack of reference count on PHY driver
git bisect bad cafe8df8b9bc9aa3dffa827c1a6757c6cd36f657
# good: [770f82253dbd7e6892a88018f2f6cd395f48d214] mlx4: xdp_prog becomes inactive after ethtool '-L' or '-G'
git bisect good 770f82253dbd7e6892a88018f2f6cd395f48d214
# good: [2372bcda5e681bc85d57a3604265155e1a4c040b] Merge branch 'mlx4-queue-reinit'
git bisect good 2372bcda5e681bc85d57a3604265155e1a4c040b
# first bad commit: [cafe8df8b9bc9aa3dffa827c1a6757c6cd36f657] net: phy: Fix lack of reference count on PHY driver
