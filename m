From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (0/9) free_netdev -- delay freeing of net_device structure
 till after last use
Date: Tue, 19 Aug 2003 12:18:00 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030819121800.009db89b.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Patrick Mochel <mochel@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The following set of patches fixes the problem caused by having a network
class device entry held open when removing a network module.  The simplest
case of this is:
	rmmod e100 </sys/class/net/eth0/statistics/tx_bytes

but the more realistic case is an monitoring application that has a sysfs entry open
when a card and module are removed on a production system.

The patch is small in size, it just hits a lot of files.


1 - free_netdev added to network core
2 - update documentation
3 - change kfree to free_netdev in drivers/net/*
4 - change kfree to free_netdev drivers/net/tokenring
5 - change kfree to free_netdev drivers/net/pcmcia
6 - change kfree to free_netdev other drivers
7 - change kfree to free_netdev in net/* pseudo-drivers
8 - change destructors to use free_netdev
9 - add free_netdev to drivers that seem to leak

The patches are against 2.6.0-test3 latest BK tree.

It should be trivial to maintain source compatiablity with 2.4
which doesn't need to change since it doesn't have sysfs,
by adding something like this to netdevice.h in 2.4

static __inline__ void free_netdev(struct net_device *dev) 
{
	kfree(dev);
}


Some drivers haven't been converted because they still statically
define the net_device structure, or encapsulate the net_device inside
another structure.  These drivers will work the same as before;  that is
they will be exposed to illegal memory references if sysfs file is
open when they are unloaded.

The drivers that still need work are:
=======================================================================

Al Viro has patches that fix the static allocation
in these drivers.

drivers/net/3c501.c
drivers/net/3c503.c
drivers/net/3c505.c
drivers/net/3c507.c
drivers/net/3c523.c
drivers/net/3c527.c
drivers/net/82596.c
drivers/net/ac3200.c
drivers/net/at1700.c
drivers/net/bagetlance.c
drivers/net/appletalk/cops.c
drivers/net/cs89x0.c
drivers/net/de620.c
drivers/net/depca.c
drivers/net/eepro.c
drivers/net/eexpress.c
drivers/net/es3210.c
drivers/net/eth16i.c
drivers/net/ethertap.c
drivers/net/fmv18x.c
drivers/net/hp.c
drivers/net/hp-plus.c
drivers/net/lance.c
drivers/net/lne390.c
drivers/net/appletalk/ltpc.c
drivers/net/ne.c
drivers/net/ne2.c
drivers/net/ne3210.c
drivers/net/ni5010.c
drivers/net/ni52.c
drivers/net/ni65.c
drivers/net/wan/sdla.c
drivers/net/seeq8005.c
drivers/net/smc-ultra32.c
drivers/net/smc-ultra.c
drivers/net/wd.c

I have patches out for test that make these dynamic:

drivers/net/appletalk/ipddp.c
net/bluetooth/bnep/core.c
net/irda/irlan/irlan_common.c

Obsolete?

drivers/net/sun3_82586.c
drivers/net/hamradio/dmascc.c
drivers/net/hamradio/mkiss.c
drivers/net/hamradio/6pack.c
drivers/net/sk_mca.c
drivers/net/smc-mca.c

======================================================================
Left to do:

Simple static to allocation conversion:
  These drivers define a static device or devices, and need
  to be converted to alloc_etherdev or alloc_netdev

drivers/net/isa-skeleton.c
drivers/net/apne.c
drivers/net/atari_bionet.c
drivers/net/atarilance.c
drivers/net/atari_pamsnet.c
drivers/net/de600.c
drivers/net/ibmlana.c
drivers/net/mac89x0.c
drivers/net/macsonic.c
drivers/net/smc9194.c
drivers/net/sun3lance.c

Convert array of devices to array of pointers:
  These drivers allocate one array of devices, and need to be
  changed to allocate an array of pointers, then allocate the devices.

drivers/net/meth.c
drivers/net/ne2k_cbus.c
drivers/media/dvb/dvb-core/dvb_net.c
drivers/net/hamradio/baycom_epp.c


Embedded 'net_device':
  These drivers embed net_device in another structure. If possible
  chain the allocations during alloc_netdev, then free the net_device
  after unregister.

drivers/char/synclink.c
drivers/char/synclinkmp.c
drivers/char/pcmcia/synclink_cs.c
drivers/isdn/i4l/isdn_net_lib.c
drivers/net/wan/sealevel.c
drivers/net/wan/hostess_sv11.c
drivers/net/wan/hdlc_generic.c
drivers/net/wireless/ray_cs.c
drivers/net/wireless/wavelan_cs.c
drivers/net/wireless/wl3501_cs.c
drivers/s390/net/qeth.c
drivers/usb/net/ax8817x.c
drivers/net/hamradio/hdlcdrv.c
drivers/net/wireless/strip.c
