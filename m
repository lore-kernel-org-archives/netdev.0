From: N N Ashok <nalkunda@egr.msu.edu>
Subject: Kernel locking up in module
Date: Mon, 14 Jul 2003 17:46:30 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200307141746.30761.nalkunda@egr.msu.edu>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="------------Boundary-00=_I5B1Z16K2MEMVO8EMDU8"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--------------Boundary-00=_I5B1Z16K2MEMVO8EMDU8
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

Hi All,
    I am creating a module to measure the outgoing bandwidth usage on the=
=20
interfaces. It uses the get_stats() of the device to get the current stat=
s=20
and then computes the bandwidth usage. The algorithm for the usage=20
calculation are borrowed from iproute2 package (tc/tc_estimator.c).
  The problem is that the kernel keeps locking up. I am using rwlock_t lo=
cks=20
to lock the data. In the code, I traverse the list of bwuage structures a=
nd=20
as a debug message am printing whether the traversal ended in the variabl=
e=20
becoming null (which it should if everything went right), but the variabl=
e is=20
non-null every other time I insert the module.=20
=09printk(KERN_INFO "bwestimator: dev: %s. bwusage: %s.\n", dev ? "non-nu=
ll" :=20
"null", bwusage ? "non-null" : "null");

  I think this has got to do with some locking issues. As this is my firs=
t go=20
at the kernel locking, I might have used the wrong kind of locks. I have=20
attached the module source, header and the log messages as I inserted the=
=20
module a couple of times. I request you all to please help me as I am tot=
ally=20
lost here.

Thanks,
Ashok
--------------Boundary-00=_I5B1Z16K2MEMVO8EMDU8
Content-Type: text/x-csrc;
  charset="us-ascii";
  name="bwestimator.c"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="bwestimator.c"

#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/netdevice.h>
#include <net/pkt_sched.h>
#include <linux/sched.h>
#include <linux/timer.h>
#include <net/bwestimator.h>

#if CONFIG_MODVERSIONS==1
#define MODVERSIONS
#include <linux/modsetver.h>
#endif

/** Timer */
struct timer_list estimator_timer;

/** Moving average weight */
unsigned interval, time_const;
int ewma_log;
int idx;

/** Function to check bandwidth usage */
void check_bandwidth(unsigned long ptr);

/**
 * init_module: Module init function
 */
int init_module()
{
	struct net_device *dev;
	struct bwusage *current_bwusage;
	/**
	 * Temporarily used to stop the timer after a specific number of times
	 */
	unsigned long value;

	EXPORT_NO_SYMBOLS;

	/**
	 * Borrowed from iproute2 package (tc/tc_estimator.c)
	 * Following values were obtained by running the estimator for 1 sec
	 * interval and 8 sec time constant of iproute2 package.
	 */
	interval = 1000000;	/* 1 sec */
	time_const = 8000000;	/* 8 sec */
	idx = 2;
	ewma_log = 3;

	/** Could this be true due to previous errors */
	if(bwusage_head != NULL) {
		printk(KERN_INFO "bwestimator: bwusage_head is not NULL\n");
		return -1;
	}

	bwusage_head = NULL;
	current_bwusage = NULL;
	/** Lock the dev_base */
	read_lock(&dev_base_lock);
	/** Lock the bwusage_head */
	write_lock(&bwusage_head_lock);
	for(dev = dev_base; dev != NULL; dev = dev -> next) {
		struct bwusage *bwusage = kmalloc(sizeof(bwusage), GFP_KERNEL);

		if(bwusage == NULL) {
			/** Free allocated memory */
			for(bwusage = bwusage_head; bwusage;) {
				struct bwusage *u = bwusage -> next;
				kfree(bwusage);
				bwusage = u;
			}
			
			/** Unlock the bwusage_head */
			write_unlock(&bwusage_head_lock);
			/** Unlock the dev_base */
			read_unlock(&dev_base_lock);
			/** Return error */
			return -ENOBUFS;
		}

		bwusage -> next = NULL;

		dev_hold(dev);
		bwusage -> name = dev -> name;
		__dev_put(dev);

		bwusage -> rx_bps = 0;
		bwusage -> rx_avbps = 0;
		bwusage -> rx_pps = 0;
		bwusage -> rx_avpps = 0;
		bwusage -> rx_bytes = 0;
		bwusage -> rx_packets = 0;

		bwusage -> tx_bps = 0;
		bwusage -> tx_avbps = 0;
		bwusage -> tx_pps = 0;
		bwusage -> tx_avpps = 0;
		bwusage -> tx_bytes = 0;
		bwusage -> tx_packets = 0;

		if(bwusage_head == NULL) {
			bwusage_head = bwusage;
		} else {
			current_bwusage -> next = bwusage;
		}
		current_bwusage = bwusage;

		printk(KERN_INFO "bwestimator: Adding %s device (%s), rx_bytes, %lu, rx_packets, %lu, rx_bps, %lu, rx_avbps, %lu, rx_pps, %lu, rx_avpps, %lu\n", dev->name, bwusage -> name, bwusage -> rx_bytes, bwusage -> rx_packets, bwusage -> rx_bps, bwusage -> rx_avbps, bwusage -> rx_pps, bwusage -> rx_avpps);

	}

	/** Initialize and setup the timer */
	init_timer(&estimator_timer);
	estimator_timer.function = check_bandwidth;
	value = 0;
	estimator_timer.data = (unsigned long) &value;
	estimator_timer.expires = jiffies + HZ; /* One second */
	add_timer(&estimator_timer);

	/** Unlock the bwusage_head */
	write_unlock(&bwusage_head_lock);
	/** Unlock the dev_base */
	read_unlock(&dev_base_lock);

	printk("<1>bwestimator: Starting bandwidth usage estimation\n");
	return 0;
}

/**
 * cleanup_module: Module cleanup function
 */
void cleanup_module()
{
	struct bwusage *current_bwusage;
	unsigned long flags;

	/** Lock the bwusage_head */
	write_lock(&bwusage_head_lock);
	/** Delete the timer */
	del_timer(&estimator_timer);
	/** Free allocated memory */
	for(current_bwusage = bwusage_head; current_bwusage;) {
		struct bwusage *u = current_bwusage -> next;
		printk(KERN_INFO "bwestimator: Deleting %s device\n", 
			current_bwusage -> name ? current_bwusage -> name : "null");
		kfree(current_bwusage);
		current_bwusage = u;
	}
	bwusage_head = NULL;
	/** Unlock the bwusage_head */
	write_unlock(&bwusage_head_lock);
	
	printk("<1>bwestimator: Stopping bandwidth usage estimation\n");
}

/**
 * check_bandwidth(): Checks the bandwidth usage on interfaces
 */
void check_bandwidth(unsigned long ptr)
{
	struct net_device *dev;
	struct bwusage *bwusage;
	unsigned long *data = (unsigned long *) ptr;
	unsigned long nbytes, old_nbytes;
	unsigned long npackets, old_npackets;
	unsigned long rate;
	/** Count to print the debug message */
	static unsigned count = 0;
	unsigned long flags;

	/** Read lock the dev_base */
	read_lock(&dev_base_lock);
	/** Read lock the bwusage_head */
	write_lock(&bwusage_head_lock);

	if(count >= 5) {
		/** Unlock the bwusage_head */
		write_unlock(&bwusage_head_lock);
		/** Unlock the dev_base */
		read_unlock(&dev_base_lock);
		return;
	}

	for(dev = dev_base, bwusage = bwusage_head; dev != NULL && bwusage != NULL; dev = dev -> next, bwusage = bwusage -> next) {
		struct net_device_stats *stats;
		dev_hold(dev);

		stats = (dev -> get_stats ? dev -> get_stats(dev) : (struct net_device_stats *)NULL);
		if(stats) {
#if 0
			nbytes = stats -> tx_bytes;
			npackets = stats -> tx_packets;

			/** Tx_bps */
			rate = (nbytes - bwusage -> tx_bytes) << (7 - idx);
			bwusage -> tx_bytes = nbytes;
			bwusage -> tx_avbps += ((long)rate - (long)bwusage ->tx_avbps) >> ewma_log;
			bwusage -> tx_bps = (bwusage -> tx_avbps + 0xF) >> 5;

			/** Tx_pps */
			rate = (u32) ((npackets - bwusage -> tx_packets) << (12 - idx));
			bwusage -> tx_packets = npackets;
			bwusage -> tx_avpps = (u32) (bwusage -> tx_avpps + (((long)rate - (long)bwusage ->tx_avpps) >> ewma_log));
			bwusage -> tx_pps = (u32) ((bwusage -> tx_avpps + 0x1FF) >> 10);

			/** Rx_bps */
			nbytes = stats -> rx_bytes;
			npackets = stats -> rx_packets;
			old_nbytes = bwusage -> rx_bytes;
			old_npackets = bwusage -> rx_packets;

			rate = (nbytes - bwusage -> rx_bytes) << (7 - idx);
			bwusage -> rx_bytes = nbytes;
			bwusage -> rx_avbps += ((long)rate - (long)bwusage ->rx_avbps) >> ewma_log;
			bwusage -> rx_bps = (bwusage -> rx_avbps + 0xF) >> 5;

			printk(KERN_INFO "bwestimator: device, %s, nbytes, %lu, npackets, %lu, old_nbytes, %lu, old_npackets, %lu, rate, %lu, rx_avbps, %lu, rx_bps, %lu, idx, %d, ewma_log, %d\n", dev -> name, nbytes, npackets, old_nbytes, old_npackets, rate, bwusage -> rx_avbps, bwusage -> rx_bps, idx, ewma_log);

			/** Rx_pps */
			rate = (u32) ((npackets - bwusage -> rx_packets) << (12 - idx));
			bwusage -> rx_packets = npackets;
			bwusage -> rx_avpps = (u32) (bwusage -> rx_avpps + (((long)rate - (long)bwusage ->rx_avpps) >> ewma_log));
			bwusage -> rx_pps = (u32) ((bwusage -> rx_avpps + 0x1FF) >> 10);

			/*
			printk(KERN_INFO "bwestimator: Device, %6s, nbytes, %llu, npackets, %lu, rxbps, %lu, rxpps, %lu, txbps, %lu, txpps, %lu\n",
				bwusage->name,
				nbytes,
				npackets,
				bwusage->rx_bps,
				bwusage->rx_pps,
				bwusage->tx_bps,
				bwusage->tx_pps
				);
			*/
#endif
		} else {
			printk(KERN_INFO "bwestimator: Device: %6s. No statistics available.\n", dev->name);
		}
		__dev_put(dev);
	}
	mod_timer(&estimator_timer, jiffies + HZ);
	printk(KERN_INFO "bwestimator: dev: %s. bwusage: %s.\n", dev ? "non-null" : "null", bwusage ? "non-null" : "null");

	count++;
	/** Unlock the bwusage_head */
	write_unlock(&bwusage_head_lock);
	/** Unlock the dev_base */
	read_unlock(&dev_base_lock);

	return;
}
MODULE_LICENSE("GPL");


--------------Boundary-00=_I5B1Z16K2MEMVO8EMDU8
Content-Type: text/x-chdr;
  charset="us-ascii";
  name="bwestimator.h"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="bwestimator.h"

#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/netdevice.h>
#include <net/pkt_sched.h>
#include <linux/sched.h>
#include <linux/timer.h>

/** Timer */
//extern struct timer_list estimator_timer;


/** We assume that the list of devices in dev_base does not change and
 * hence once the list of usage is built for each device, we assume that
 * there is a one-to-one correspondence in the list of devices and the 
 * list of usage structures.
 */
/** Usage structure list */
struct bwusage {
	struct bwusage *next;
	char *name;

	unsigned long rx_bps;
	unsigned long rx_avbps;
	unsigned long rx_pps;
	unsigned long rx_avpps;
	unsigned long rx_bytes;
	unsigned long rx_total_bytes;
	unsigned long rx_packets;
	unsigned long rx_total_packets;

	unsigned long tx_bps;
	unsigned long tx_avbps;
	unsigned long tx_pps;
	unsigned long tx_avpps;
	unsigned long tx_bytes;
	unsigned long tx_total_bytes;
	unsigned long tx_packets;
	unsigned long tx_total_packets;
};
extern struct bwusage *bwusage_head;

/** bwusage_head lock */
extern rwlock_t bwusage_head_lock;


--------------Boundary-00=_I5B1Z16K2MEMVO8EMDU8
Content-Type: text/x-log;
  charset="us-ascii";
  name="messages.log"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="messages.log"

Jul 14 16:23:55 elans-pc kernel: bwestimator: Adding lo device (lo), rx_bytes, 0, rx_packets, 0, rx_bps, 0, rx_avbps, 0, rx_pps, 0, rx_avpps, 0
Jul 14 16:23:55 elans-pc kernel: bwestimator: Adding eth0 device (eth0), rx_bytes, 0, rx_packets, 0, rx_bps, 0, rx_avbps, 0, rx_pps, 0, rx_avpps, 0
Jul 14 16:23:55 elans-pc kernel: bwestimator: Adding eth1 device (eth1), rx_bytes, 0, rx_packets, 0, rx_bps, 0, rx_avbps, 0, rx_pps, 0, rx_avpps, 0
Jul 14 16:23:55 elans-pc kernel: bwestimator: Adding eth2 device (eth2), rx_bytes, 0, rx_packets, 0, rx_bps, 0, rx_avbps, 0, rx_pps, 0, rx_avpps, 0
Jul 14 16:23:55 elans-pc kernel: bwestimator: Adding eth3 device (eth3), rx_bytes, 0, rx_packets, 0, rx_bps, 0, rx_avbps, 0, rx_pps, 0, rx_avpps, 0
Jul 14 16:23:55 elans-pc kernel: bwestimator: Adding eth4 device (eth4), rx_bytes, 0, rx_packets, 0, rx_bps, 0, rx_avbps, 0, rx_pps, 0, rx_avpps, 0
Jul 14 16:23:55 elans-pc kernel: bwestimator: Adding eth5 device (eth5), rx_bytes, 0, rx_packets, 0, rx_bps, 0, rx_avbps, 0, rx_pps, 0, rx_avpps, 0
Jul 14 16:23:55 elans-pc kernel: bwestimator: Starting bandwidth usage estimation
Jul 14 16:23:56 elans-pc kernel: bwestimator: dev: null. bwusage: null.
Jul 14 16:24:00 elans-pc last message repeated 4 times
Jul 14 16:24:01 elans-pc kernel: bwestimator: Deleting lo device
Jul 14 16:24:01 elans-pc kernel: bwestimator: Deleting eth0 device
Jul 14 16:24:01 elans-pc kernel: bwestimator: Deleting eth1 device
Jul 14 16:24:01 elans-pc kernel: bwestimator: Deleting eth2 device
Jul 14 16:24:01 elans-pc kernel: bwestimator: Deleting eth3 device
Jul 14 16:24:01 elans-pc kernel: bwestimator: Deleting eth4 device
Jul 14 16:24:01 elans-pc kernel: bwestimator: Deleting eth5 device
Jul 14 16:24:01 elans-pc kernel: bwestimator: Stopping bandwidth usage estimation
Jul 14 16:24:05 elans-pc kernel: bwestimator: Adding lo device (lo), rx_bytes, 0, rx_packets, 0, rx_bps, 0, rx_avbps, 0, rx_pps, 0, rx_avpps, 0
Jul 14 16:24:05 elans-pc kernel: bwestimator: Adding eth0 device (eth0), rx_bytes, 0, rx_packets, 3433504032, rx_bps, 0, rx_avbps, 0, rx_pps, 0, rx_avpps, 0
Jul 14 16:24:05 elans-pc kernel: bwestimator: Adding eth1 device (eth1), rx_bytes, 0, rx_packets, 3433504000, rx_bps, 0, rx_avbps, 0, rx_pps, 0, rx_avpps, 0
Jul 14 16:24:05 elans-pc kernel: bwestimator: Adding eth2 device (eth2), rx_bytes, 0, rx_packets, 3433503968, rx_bps, 0, rx_avbps, 0, rx_pps, 0, rx_avpps, 0
Jul 14 16:24:05 elans-pc kernel: bwestimator: Adding eth3 device (eth3), rx_bytes, 0, rx_packets, 3433503936, rx_bps, 0, rx_avbps, 0, rx_pps, 0, rx_avpps, 0
Jul 14 16:24:05 elans-pc kernel: bwestimator: Adding eth4 device (eth4), rx_bytes, 0, rx_packets, 3433503904, rx_bps, 0, rx_avbps, 0, rx_pps, 0, rx_avpps, 0
Jul 14 16:24:05 elans-pc kernel: bwestimator: Adding eth5 device (eth5), rx_bytes, 0, rx_packets, 3433503872, rx_bps, 0, rx_avbps, 0, rx_pps, 0, rx_avpps, 0
Jul 14 16:24:05 elans-pc kernel: bwestimator: Starting bandwidth usage estimation
Jul 14 16:24:06 elans-pc kernel: bwestimator: dev: non-null. bwusage: null.
Jul 14 16:24:10 elans-pc last message repeated 4 times
Jul 14 16:24:19 elans-pc kernel: bwestimator: Deleting lo device
Jul 14 16:24:19 elans-pc kernel: bwestimator: Stopping bandwidth usage estimation
Jul 14 16:24:22 elans-pc kernel: bwestimator: Adding lo device (lo), rx_bytes, 0, rx_packets, 0, rx_bps, 0, rx_avbps, 0, rx_pps, 0, rx_avpps, 0
Jul 14 16:24:22 elans-pc kernel: bwestimator: Adding eth0 device (eth0), rx_bytes, 0, rx_packets, 0, rx_bps, 0, rx_avbps, 0, rx_pps, 0, rx_avpps, 0
Jul 14 16:24:22 elans-pc kernel: bwestimator: Adding eth1 device (eth1), rx_bytes, 0, rx_packets, 0, rx_bps, 0, rx_avbps, 0, rx_pps, 0, rx_avpps, 0
Jul 14 16:24:22 elans-pc kernel: bwestimator: Adding eth2 device (eth2), rx_bytes, 0, rx_packets, 0, rx_bps, 0, rx_avbps, 0, rx_pps, 0, rx_avpps, 0
Jul 14 16:24:22 elans-pc kernel: bwestimator: Adding eth3 device (eth3), rx_bytes, 0, rx_packets, 0, rx_bps, 0, rx_avbps, 0, rx_pps, 0, rx_avpps, 0
Jul 14 16:24:22 elans-pc kernel: bwestimator: Adding eth4 device (eth4), rx_bytes, 0, rx_packets, 0, rx_bps, 0, rx_avbps, 0, rx_pps, 0, rx_avpps, 0
Jul 14 16:24:22 elans-pc kernel: bwestimator: Adding eth5 device (eth5), rx_bytes, 0, rx_packets, 0, rx_bps, 0, rx_avbps, 0, rx_pps, 0, rx_avpps, 0
Jul 14 16:24:22 elans-pc kernel: bwestimator: Starting bandwidth usage estimation
Jul 14 16:24:23 elans-pc kernel: bwestimator: dev: null. bwusage: null.
Jul 14 16:24:27 elans-pc last message repeated 4 times
Jul 14 16:24:30 elans-pc kernel: bwestimator: Deleting lo device
Jul 14 16:24:30 elans-pc kernel: bwestimator: Deleting eth0 device
Jul 14 16:24:30 elans-pc kernel: bwestimator: Deleting eth1 device
Jul 14 16:24:30 elans-pc kernel: bwestimator: Deleting eth2 device
Jul 14 16:24:30 elans-pc kernel: bwestimator: Deleting eth3 device
Jul 14 16:24:30 elans-pc kernel: bwestimator: Deleting eth4 device
Jul 14 16:24:30 elans-pc kernel: bwestimator: Deleting eth5 device
Jul 14 16:24:30 elans-pc kernel: bwestimator: Stopping bandwidth usage estimation
Jul 14 16:24:35 elans-pc kernel: bwestimator: Adding lo device (lo), rx_bytes, 0, rx_packets, 0, rx_bps, 0, rx_avbps, 0, rx_pps, 0, rx_avpps, 0
Jul 14 16:24:35 elans-pc kernel: bwestimator: Adding eth0 device (eth0), rx_bytes, 0, rx_packets, 3433504224, rx_bps, 0, rx_avbps, 0, rx_pps, 0, rx_avpps, 0
Jul 14 16:24:35 elans-pc kernel: bwestimator: Adding eth1 device (eth1), rx_bytes, 0, rx_packets, 3433504192, rx_bps, 0, rx_avbps, 0, rx_pps, 0, rx_avpps, 0
Jul 14 16:24:35 elans-pc kernel: bwestimator: Adding eth2 device (eth2), rx_bytes, 0, rx_packets, 3433504160, rx_bps, 0, rx_avbps, 0, rx_pps, 0, rx_avpps, 0
Jul 14 16:24:35 elans-pc kernel: bwestimator: Adding eth3 device (eth3), rx_bytes, 0, rx_packets, 3433504128, rx_bps, 0, rx_avbps, 0, rx_pps, 0, rx_avpps, 0
Jul 14 16:24:35 elans-pc kernel: bwestimator: Adding eth4 device (eth4), rx_bytes, 0, rx_packets, 3433504096, rx_bps, 0, rx_avbps, 0, rx_pps, 0, rx_avpps, 0
Jul 14 16:24:35 elans-pc kernel: bwestimator: Adding eth5 device (eth5), rx_bytes, 0, rx_packets, 3433504064, rx_bps, 0, rx_avbps, 0, rx_pps, 0, rx_avpps, 0
Jul 14 16:24:35 elans-pc kernel: bwestimator: Starting bandwidth usage estimation
Jul 14 16:24:36 elans-pc kernel: bwestimator: dev: non-null. bwusage: null.
Jul 14 16:24:40 elans-pc last message repeated 4 times
Jul 14 16:24:40 elans-pc kernel: bwestimator: Deleting lo device
Jul 14 16:24:40 elans-pc kernel: bwestimator: Stopping bandwidth usage estimation

--------------Boundary-00=_I5B1Z16K2MEMVO8EMDU8--
