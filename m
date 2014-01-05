From: Russell King - ARM Linux <linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>
Subject: [BUG] v3.13-rc7: freescale fec_main bugs on boot
Date: Sun, 5 Jan 2014 17:04:48 +0000
Message-ID: <20140105170448.GC27432@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: Shawn Guo <shawn.guo-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	Sascha Hauer <kernel-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>,
	Philipp Zabel <p.zabel-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>,
	Fabio Estevam <fabio.estevam-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

So, I just forward-ported my Hummingboard patch set to v3.13-rc7 from
-rc6, and upon boot I'm now seeing the following BUG().  I do have:

CONFIG_PHYLIB=y
CONFIG_AT803X_PHY=y

enabled, which are for the AR8035.

The problem causing the BUG() appears to be this path:

static int
fec_enet_open(struct net_device *ndev)
{
        struct fec_enet_private *fep = netdev_priv(ndev);
        int ret;
        
        napi_enable(&fep->napi);
        
        /* I should reset the ring buffers here, but I don't yet know
         * a simple way to do that.
         */

        ret = fec_enet_alloc_buffers(ndev);
        if (ret)
                return ret;

        /* Probe and connect to PHY when open the interface */
        ret = fec_enet_mii_probe(ndev);
        if (ret) {
                fec_enet_free_buffers(ndev);
<<< errors out here, leaving napi enabled >>>
                return ret;
        }

The result is if the device is attempted to be opened again, we end up
calling napi_enable() after it's already been enabled by the previous
open.  I'm not sure whether the fix below is the right one - or what
the correct placement if napi_enable() should be.

Second thing is this which was introduced by 7a399e3a2e05 between rc6
and rc7:

+       if (flags & OF_GPIO_ACTIVE_LOW)
+               port = GPIOF_OUT_INIT_LOW;
+       else
+               port = GPIOF_OUT_INIT_HIGH;

-       gpio_set_value(phy_reset, 1);
+       gpio_set_value(phy_reset, !port);

Let's look at how GPIOF_OUT_INIT_* is defined:

#define GPIOF_DIR_OUT   (0 << 0)
#define GPIOF_OUT_INIT_LOW      (GPIOF_DIR_OUT | GPIOF_INIT_LOW)
#define GPIOF_OUT_INIT_HIGH     (GPIOF_DIR_OUT | GPIOF_INIT_HIGH)

Hence, the result of !GPIOF_OUT_INIT_LOW and !GPIOF_OUT_INIT_HIGH is
zero in both cases, resulting in the phy being kept in reset all the
time.

Now, the way this is structured, it looks like the intention is that
"flag" is zero indicating that it's active high, otherwise it's
OF_GPIO_ACTIVE_LOW to indicate active low.

However, this brings up a much bigger question concerning compatibility
with existing DT files.  The original pre-rc7 code assumed that the
PHY's reset signal was active low, so all DT files have been written
this way.  Post-rc7, we now need to set this OF_GPIO_ACTIVE_LOW flag
in every pre-rc7 DT file to achieve the same.  This is an _incompatible_
change in the DT description, and one that I object to in the strongest
terms.  Pre-rc7 DT files must continue to behave exactly the same as
they did before.

And indeed, backing out 7a399e3a2e05 fixes the problem.

fec 2188000.ethernet eth0: no PHY, assuming direct connection to switch
libphy: PHY fixed-0:00 not found
fec 2188000.ethernet eth0: could not attach to PHY
------------[ cut here ]------------
kernel BUG at include/linux/netdevice.h:502!
Internal error: Oops - BUG: 0 [#1] SMP ARM
Modules linked in: hid_cypress
CPU: 0 PID: 166 Comm: ipconfig Not tainted 3.13.0-rc7+ #395
task: db3e0900 ti: da844000 task.ti: da844000
PC is at fec_enet_open+0x4d0/0x500
LR is at __dev_open+0xa4/0xfc
pc : [<c0437b70>]    lr : [<c0546344>]    psr: 60000013
sp : da845d68  ip : da845dc8  fp : da845dc4
r10: db2b900c  r9 : db83e000  r8 : 00000000
r7 : db83e02c  r6 : 00000000  r5 : c0783a70  r4 : db83e600
r3 : 00000000  r2 : 000000f3  r1 : db83e768  r0 : db83e000
Flags: nZCv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Segment user
Control: 10c53c7d  Table: 2aa34059  DAC: 00000015
Process ipconfig (pid: 166, stack limit = 0xda844248)
Stack: (0xda845d68 to 0xda846000)
5d60:                   da845d8c da845d78 c004941c c0049294 00000000 da845d88
5d80: da845dac da845d90 c0541f70 c0049408 00000006 db83e000 c0783a70 db83e000
5da0: c0783a70 00000000 db83e02c 00000000 00001003 db2b900c da845de4 da845dc8
5dc0: c0546344 c04376ac db83e000 00001003 00001002 00000001 da845e0c da845de8
5de0: c05465cc c05462ac 00000001 beec5b88 db83e000 00000120 00001002 00000000
5e00: da845e34 da845e10 c05466d0 c0546544 00000001 beec5b88 da844000 da845e60
5e20: 00000000 00008914 da845ebc da845e38 c05a2030 c05466bc beec5b88 c05587e4
5e40: 00000001 00000000 db83e000 000005dc da845e70 db2b9000 00000014 00000000
5e60: 30687465 00000000 00000000 00000000 00001003 000005dc 00009e1d 00009e2a
5e80: 00001003 000005dc 00009e1d 00009e2a 00009e1d 00008914 beec5b88 dacf6480
5ea0: beec5b88 c0112dcc da844000 00000000 da845ecc da845ec0 c05a3a34 c05a19b8
5ec0: da845eec da845ed0 c052d3c8 c05a388c c052d364 da85c600 dacf64a0 00000004
5ee0: da845f74 da845ef0 c0112770 c052d370 00000001 00000000 dbabb208 00000001
5f00: 00000000 00000000 00000000 00000000 c0320504 dbabb200 00000014 db6d4000
5f20: 00000002 dbabb208 00000000 00000000 da845f6c da844000 c000e9a4 db3e0900
5f40: 00000001 c000eb44 da844000 00000000 da85c600 beec5b88 00008914 00000004
5f60: da844000 00000000 da845fa4 da845f78 c0112dcc c01126f8 da845f94 00000000
5f80: c0065bb4 30687465 00000000 b6faa320 00000036 c000eb44 00000000 da845fa8
5fa0: c000e980 c0112d94 30687465 00000000 00000004 00008914 beec5b88 00001003
5fc0: 30687465 00000000 b6faa320 00000036 00000000 00000004 b6faa38b 00000ffe
5fe0: 0000000e beec5b78 0180984f 01809394 20000030 00000004 00000000 00000000
Backtrace: 
[<c04376a0>] (fec_enet_open) from [<c0546344>] (__dev_open+0xa4/0xfc)
 r10:db2b900c r9:00001003 r8:00000000 r7:db83e02c r6:00000000 r5:c0783a70
 r4:db83e000
[<c05462a0>] (__dev_open) from [<c05465cc>] (__dev_change_flags+0x94/0x160)
 r7:00000001 r6:00001002 r5:00001003 r4:db83e000
[<c0546538>] (__dev_change_flags) from [<c05466d0>] (dev_change_flags+0x20/0x50)
 r8:00000000 r7:00001002 r6:00000120 r5:db83e000 r4:beec5b88 r3:00000001
[<c05466b0>] (dev_change_flags) from [<c05a2030>] (devinet_ioctl+0x684/0x72c)
 r8:00008914 r7:00000000 r6:da845e60 r5:da844000 r4:beec5b88 r3:00000001
[<c05a19ac>] (devinet_ioctl) from [<c05a3a34>] (inet_ioctl+0x1b4/0x1c8)
 r10:00000000 r9:da844000 r8:c0112dcc r7:beec5b88 r6:dacf6480 r5:beec5b88
 r4:00008914
[<c05a3880>] (inet_ioctl) from [<c052d3c8>] (sock_ioctl+0x64/0x2a0)
[<c052d364>] (sock_ioctl) from [<c0112770>] (do_vfs_ioctl+0x84/0x69c)
 r6:00000004 r5:dacf64a0 r4:da85c600 r3:c052d364
[<c01126ec>] (do_vfs_ioctl) from [<c0112dcc>] (SyS_ioctl+0x44/0x68)
 r10:00000000 r9:da844000 r8:00000004 r7:00008914 r6:beec5b88 r5:da85c600
 r4:00000000
[<c0112d88>] (SyS_ioctl) from [<c000e980>] (ret_fast_syscall+0x0/0x48)
 r8:c000eb44 r7:00000036 r6:b6faa320 r5:00000000 r4:30687465
Code: 0affffc2 e1a00009 ebfffe53 eaffffcc (e7f001f2) 
---[ end trace d124ee5e5169bf48 ]---

 drivers/net/ethernet/freescale/fec_main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 45b8b22b9987..75c9b8ae31f1 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -1775,8 +1775,6 @@ fec_enet_open(struct net_device *ndev)
 	struct fec_enet_private *fep = netdev_priv(ndev);
 	int ret;
 
-	napi_enable(&fep->napi);
-
 	/* I should reset the ring buffers here, but I don't yet know
 	 * a simple way to do that.
 	 */
@@ -1791,6 +1789,8 @@ fec_enet_open(struct net_device *ndev)
 		fec_enet_free_buffers(ndev);
 		return ret;
 	}
+
+	napi_enable(&fep->napi);
 	phy_start(fep->phy_dev);
 	netif_start_queue(ndev);
 	fep->opened = 1;

-- 
FTTC broadband for 0.8mile line: 5.8Mbps down 500kbps up.  Estimation
in database were 13.1 to 19Mbit for a good line, about 7.5+ for a bad.
Estimate before purchase was "up to 13.2Mbit".
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
