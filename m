From: Andrew Morton <akpm@digeo.com>
Subject: e100: "Freeing alive device f7dd8000, eth%d"
Date: Thu, 3 Apr 2003 02:45:17 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030403024517.534a0760.akpm@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Feldman, Scott" <scott.feldman@intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hi Scott.

This message comes out all the time when e100 is being brought up.

What's happening is that e100_found1() is starting up and calling
netif_carrier_off() when the netdevice's refcount is zero.  The link state
change callback is queued and takes the refcount to 1.  Then the callback is
run while the refcount is still 1.  So it calls netdev_finish_unregister(),
which gets all upset because the netdevice has not actually shut down.

Here's a call trace:

#0  linkwatch_fire_event (dev=0xcfddb000) at include/asm/bitops.h:133
#1  0xc0295cb2 in e100_update_link_state (bdp=0xcfddb1c0) at include/linux/netdevice.h:663
#2  0xc029559a in e100_find_speed_duplex (bdp=0xcfddb1c0) at drivers/net/e100/e100_phy.c:495
#3  0xc0295ac6 in e100_auto_neg (bdp=0xcfddb1c0, force_restart=0) at drivers/net/e100/e100_phy.c:864
#4  0xc0295b14 in e100_phy_set_speed_duplex (bdp=0xcfddb1c0, force_restart=0 '\0')
    at drivers/net/e100/e100_phy.c:875
#5  0xc042dc7c in e100_phy_init (bdp=0xcfddb1c0) at drivers/net/e100/e100_phy.c:931
#6  0xc042d21d in e100_hw_init (bdp=0xcfddb1c0) at drivers/net/e100/e100_main.c:1389
#7  0xc042d09c in e100_init (bdp=0xcfddb1c0) at drivers/net/e100/e100_main.c:1287
#8  0xc042cb39 in e100_found1 (pcid=0xcfe5e000, ent=0xc04630c4) at drivers/net/e100/e100_main.c:643
#9  0xc0260973 in pci_device_probe (dev=0xcfe5e04c) at drivers/pci/pci-driver.c:53
#10 0xc02815f4 in bus_match (dev=0xcfe5e04c, drv=0xc03cf188) at drivers/base/bus.c:266
#11 0xc02816d6 in driver_attach (drv=0xc03cf188) at drivers/base/bus.c:331
#12 0xc0281972 in bus_add_driver (drv=0xc03cf188) at drivers/base/bus.c:447
#13 0xc0281d43 in driver_register (drv=0xc03cf188) at drivers/base/driver.c:87
#14 0xc0260a74 in pci_register_driver (drv=0xc03cf160) at drivers/pci/pci-driver.c:127
#15 0xc042cd36 in e100_init_module () at include/linux/pci.h:775
#16 0xc0418851 in do_initcalls () at init/main.c:490
#17 0xc04188c4 in do_basic_setup () at init/main.c:530
#18 0xc01050d2 in init (unused=0x0) at init/main.c:568

I'm not sure what the right fix is here - perhaps the driver just shouldn't
be playing with link state at all in the probe handler, and this should
actually happen in the open() routine.


Also, it seems a bit bogus that anything at all happened when you did
netif_carrier_off() in the probe() handler:

static inline void netif_carrier_off(struct net_device *dev)
{
	if (!test_and_set_bit(__LINK_STATE_NOCARRIER, &dev->state))
		linkwatch_fire_event(dev);
}

It seems to me more logical that drivers should come up in state "no
carrier".  But I guess it would break naive drivers if we made that change.
