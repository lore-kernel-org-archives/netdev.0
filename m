From: Ben Greear <greearb@candelatech.com>
Subject: Re: 2.6.7 tulip performance (with NAPI)
Date: Wed, 06 Oct 2004 17:56:05 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <41649425.1010102@candelatech.com>
References: <41633174.7070805@candelatech.com> <16740.17875.574967.11417@robur.slu.se> <41646587.7070401@candelatech.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020306080600040204070804"
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert Olsson <Robert.Olsson@data.slu.se>
In-Reply-To: <41646587.7070401@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------020306080600040204070804
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Ben Greear wrote:

> On a related note, I am now working on a way to use a hook in the
> netif_wake_queue callback to wake up pktgen.  This should allow me to
> have a pktgen that does not need to spin in a tight loop like it does
> now.  So far, I was able to saturate two GigE ports using about 3% of
> the CPU (as reported by top), using 1514 byte pkts.  Still tweaking
> to fix some corner cases...

I think this is mostly working now.  The patch to netdevice.h looks like this::

--- linux-2.6.7/include/linux/netdevice.h	2004-06-15 22:20:04.000000000 -0700
+++ linux-2.6.7.p4s/include/linux/netdevice.h	2004-10-06 14:31:54.000000000 -0700

@@ -466,9 +474,17 @@
  	void                    (*poll_controller)(struct net_device *dev);
  #endif

+        /* Callback for when the queue is woken, used by pktgen currently */
+	int			(*notify_queue_woken)(struct net_device *dev);
+        void* nqw_data; /* To be used by the method above as needed */
+
  	/* bridge stuff */
  	struct net_bridge_port	*br_port;

+#if defined(CONFIG_MACVLAN) || defined(CONFIG_MACVLAN_MODULE)
+	struct macvlan_port *macvlan_priv;
+#endif
+
  #ifdef CONFIG_NET_FASTROUTE
  #define NETDEV_FASTROUTE_HMASK 0xF
  	/* Semi-private data. Keep it at the end of device struct. */
@@ -619,8 +635,13 @@
  	if (netpoll_trap())
  		return;
  #endif
-	if (test_and_clear_bit(__LINK_STATE_XOFF, &dev->state))
+	if (test_and_clear_bit(__LINK_STATE_XOFF, &dev->state)) {
  		__netif_schedule(dev);
+
+                if (dev->notify_queue_woken) {
+                   dev->notify_queue_woken(dev);
+                }
+        }
  }


I'm attaching my version of pktgen since the diff is bigger than
the actual file.  With this, I can send right at 600kpps to myself (60 byte + CRC pkts),
and only use about 35% cpu as reported by top.  I also tried maxing out 6
ports and I hit what I believe is the PCI-X limit on my machine
with an aggregate throughput of about 1.3Gbps tx + 1.3Gbps rx.  CPU load is about 21%
in this case.


It may be that other programs would like to use the notify_queue_woken hook, so
if this were ever to hit the kernel proper, might want to make this a linked list
of callbacks instead of a simple pointer.

Enjoy,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com


--------------020306080600040204070804
Content-Type: text/plain;
 name="pktgen.c"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="pktgen.c"

/* -*-linux-c-*-
 *
 * Copyright 2001, 2002 by Robert Olsson <robert.olsson@its.uu.se>
 *                                 Uppsala University, Sweden
 *                 2002  Ben Greear <greearb@candelatech.com>
 *
 * A tool for loading the network with preconfigurated packets.
 * The tool is implemented as a linux module.  Parameters are output 
 * device, IPG (interpacket gap), number of packets, and whether
 * to use multiple SKBs or just the same one.
 * pktgen uses the installed interface's output routine.
 *
 * Additional hacking by:
 *
 * Jens.Laas@data.slu.se
 * Improved by ANK. 010120.
 * Improved by ANK even more. 010212.
 * MAC address typo fixed. 010417 --ro
 * Integrated.  020301 --DaveM
 * Added multiskb option 020301 --DaveM
 * Scaling of results. 020417--sigurdur@linpro.no
 * Significant re-work of the module:
 *   *  Convert to threaded model to more efficiently be able to transmit
 *       and receive on multiple interfaces at once.
 *   *  Converted many counters to __u64 to allow longer runs.
 *   *  Allow configuration of ranges, like min/max IP address, MACs,
 *       and UDP-ports, for both source and destination, and can
 *       set to use a random distribution or sequentially walk the range.
 *   *  Can now change most values after starting.
 *   *  Place 12-byte packet in UDP payload with magic number,
 *       sequence number, and timestamp.
 *   *  Add receiver code that detects dropped pkts, re-ordered pkts, and
 *       latencies (with micro-second) precision.
 *   *  Add IOCTL interface to easily get counters & configuration.
 *   --Ben Greear <greearb@candelatech.com>

 * Fix refcount off by one if first packet fails, potential null deref,
 * memleak 030710- KJP
 *
 *  * Added the IPMAC option to allow the MAC addresses to mirror IP addresses.
 *    -- (dhetheri) Dave Hetherington 03/09/29
 *  * Allow the user to change the protocol field via 'pgset "prot 0"' command
 *    -- (dhetheri) Dave Hetherington 03/10/7
 * Integrated to 2.5.x 021029 --Lucio Maciel (luciomaciel@zipmail.com.br)
 *
 *
 * Renamed multiskb to clone_skb and cleaned up sending core for two distinct 
 * skb modes. A clone_skb=0 mode for Ben "ranges" work and a clone_skb != 0 
 * as a "fastpath" with a configurable number of clones after alloc's.
 * clone_skb=0 means all packets are allocated this also means ranges time 
 * stamps etc can be used. clone_skb=100 means 1 malloc is followed by 100 
 * clones.
 *
 * Also moved to /proc/net/pktgen/ 
 * --ro
 *
 * Fix refcount off by one if first packet fails, potential null deref,
 * memleak 030710- KJP
 *
 *
 * Sept 10:  Fixed threading/locking.  Lots of bone-headed and more clever
 *    mistakes.  Also merged in DaveM's patch in the -pre6 patch.
 *
 * See Documentation/networking/pktgen.txt for how to use this.
 */

#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/sched.h>
#include <linux/types.h>
#include <linux/string.h>
#include <linux/ptrace.h>
#include <linux/errno.h>
#include <linux/ioport.h>
#include <linux/slab.h>
#include <linux/interrupt.h>
#include <linux/pci.h>
#include <linux/delay.h>
#include <linux/init.h>
#include <linux/inet.h>
#include <asm/byteorder.h>
#include <asm/bitops.h>
#include <asm/io.h>
#include <asm/dma.h>
#include <asm/uaccess.h>

#include <linux/in.h>
#include <linux/ip.h>
#include <linux/udp.h>
#include <linux/skbuff.h>
#include <linux/netdevice.h>
#include <linux/inetdevice.h>
#include <linux/rtnetlink.h>
#include <linux/proc_fs.h>
#include <linux/if_arp.h>
#include <net/checksum.h>
#include <asm/timex.h>

#include <linux/smp_lock.h> /* for lock kernel */
#include <asm/div64.h> /* do_div */

#include "pktgen.h"


#define VERSION "pktgen version 1.9.2 (nospin)"
static char version[] __initdata = 
  "pktgen.c: v1.9.2 (nospin): Packet Generator for packet performance testing.\n";

/* Used to help with determining the pkts on receive */

#define PKTGEN_MAGIC 0xbe9be955

/* #define PG_DEBUG(a) a */
#define PG_DEBUG(a) /* a */

/* cycles per micro-second */
static u32 pg_cycles_per_ns;
static u32 pg_cycles_per_us;
static u32 pg_cycles_per_ms;

/* Module parameters, defaults. */
static int pg_count_d = 0; /* run forever by default */
static int pg_ipg_d = 0;
static int pg_multiskb_d = 0;
static int pg_thread_count = 1; /* Initial threads to create */
static int debug = 0;



/* List of all running threads */
static struct pktgen_thread_info* pktgen_threads = NULL;
spinlock_t _pg_threadlist_lock = SPIN_LOCK_UNLOCKED;

/* Holds interfaces for all threads */
#define PG_INFO_HASH_MAX 32
static struct pktgen_interface_info* pg_info_hash[PG_INFO_HASH_MAX];
spinlock_t _pg_hash_lock = SPIN_LOCK_UNLOCKED;

#define PG_PROC_DIR "pktgen"
static struct proc_dir_entry *pg_proc_dir = NULL;

char module_fname[128];
struct proc_dir_entry *module_proc_ent = NULL;


static void init_pktgen_kthread(struct pktgen_thread_info *kthread, char *name);
static int pg_rem_interface_info(struct pktgen_thread_info* pg_thread,
                                 struct pktgen_interface_info* i);
static int pg_add_interface_info(struct pktgen_thread_info* pg_thread,
                                 const char* ifname);
static void exit_pktgen_kthread(struct pktgen_thread_info *kthread);
static void stop_pktgen_kthread(struct pktgen_thread_info *kthread);
static struct pktgen_thread_info* pg_find_thread(const char* name);
static int pg_add_thread_info(const char* name);
static struct pktgen_interface_info* pg_find_interface(struct pktgen_thread_info* pg_thread,
                                                       const char* ifname);
static int pktgen_device_event(struct notifier_block *, unsigned long, void *);


struct notifier_block pktgen_notifier_block = {
	notifier_call: pktgen_device_event,
};

/*  This code works around the fact that do_div cannot handle two 64-bit
    numbers, and regular 64-bit division doesn't work on x86 kernels.
    --Ben
*/

#define PG_DIV 0
#define PG_REM 1

/* This was emailed to LMKL by: Chris Caputo <ccaputo@alt.net>
 * Function copied/adapted/optimized from:
 *
 *  nemesis.sourceforge.net/browse/lib/static/intmath/ix86/intmath.c.html
 *
 * Copyright 1994, University of Cambridge Computer Laboratory
 * All Rights Reserved.
 *
 * TODO: When running on a 64-bit CPU platform, this should no longer be
 * TODO: necessary.
 */
inline static s64 divremdi3(s64 x, s64 y, int type) {
        u64 a = (x < 0) ? -x : x;
        u64 b = (y < 0) ? -y : y;
        u64 res = 0, d = 1;

        if (b > 0) {
                while (b < a) {
                        b <<= 1;
                        d <<= 1;
                }
        }
        
        do {
                if ( a >= b ) {
                        a -= b;
                        res += d;
                }
                b >>= 1;
                d >>= 1;
        }
        while (d);

        if (PG_DIV == type) {
                return (((x ^ y) & (1ll<<63)) == 0) ? res : -(s64)res;
        }
        else {
                return ((x & (1ll<<63)) == 0) ? a : -(s64)a;
        }
}/* divremdi3 */

/* End of hacks to deal with 64-bit math on x86 */



inline static void pg_lock_thread_list(const char* msg) {
        if (debug > 1) {
                printk("before pg_lock_thread_list, msg: %s\n", msg);
        }
        spin_lock(&_pg_threadlist_lock);
        if (debug > 1) {
                printk("after pg_lock_thread_list, msg: %s\n", msg);
        }
}

inline static void pg_unlock_thread_list(const char* msg) {
        if (debug > 1) {
                printk("before pg_unlock_thread_list, msg: %s\n", msg);
        }
        spin_unlock(&_pg_threadlist_lock);
        if (debug > 1) {
                printk("after pg_unlock_thread_list, msg: %s\n", msg);
        }
}

inline static void pg_lock_hash(const char* msg) {
        if (debug > 1) {
                printk("before pg_lock_hash, msg: %s\n", msg);
        }
        spin_lock(&_pg_hash_lock);
        if (debug > 1) {
                printk("before pg_lock_hash, msg: %s\n", msg);
        }
}

inline static void pg_unlock_hash(const char* msg) {
        if (debug > 1) {
                printk("before pg_unlock_hash, msg: %s\n", msg);
        }
        spin_unlock(&_pg_hash_lock);
        if (debug > 1) {
                printk("after pg_unlock_hash, msg: %s\n", msg);
        }
}

inline static void pg_lock(struct pktgen_thread_info* pg_thread, const char* msg) {
        if (debug > 1) {
                printk("before pg_lock thread, msg: %s\n", msg);
        }
        spin_lock(&(pg_thread->pg_threadlock));
        if (debug > 1) {
                printk("after pg_lock thread, msg: %s\n", msg);
        }
}

inline static void pg_unlock(struct pktgen_thread_info* pg_thread, const char* msg) {
        if (debug > 1) {
                printk("before pg_unlock thread, thread: %p  msg: %s\n",
                       pg_thread, msg);
        }
        spin_unlock(&(pg_thread->pg_threadlock));
        if (debug > 1) {
                printk("after pg_unlock thread, thread: %p  msg: %s\n",
                       pg_thread, msg);
        }
}

/** Convert to miliseconds */
static inline __u64 tv_to_ms(const struct timeval* tv) {
        __u64 ms = tv->tv_usec / 1000;
        ms += (__u64)tv->tv_sec * (__u64)1000;
        return ms;
}


/** Convert to micro-seconds */
static inline __u64 tv_to_us(const struct timeval* tv) {
        __u64 us = tv->tv_usec;
        us += (__u64)tv->tv_sec * (__u64)1000000;
        return us;
}


static inline __u64 pg_div(__u64 n, __u32 base) {
        __u64 tmp = n;
        do_div(tmp, base);
        /* printk("pg_div, n: %llu  base: %d  rv: %llu\n",
                  n, base, tmp); */
        return tmp;
}

/* Fast, not horribly accurate, since the machine started. */
static inline __u64 getRelativeCurMs(void) {
        return pg_div(get_cycles(), pg_cycles_per_ms);
}

/* Since the epoc.  More precise over long periods of time than
 * getRelativeCurMs
 */
static inline __u64 getCurMs(void) {
        struct timeval tv;
        do_gettimeofday(&tv);
        return tv_to_ms(&tv);
}

/* Since the epoc.  More precise over long periods of time than
 * getRelativeCurMs
 */
static inline __u64 getCurUs(void) {
        struct timeval tv;
        do_gettimeofday(&tv);
        return tv_to_us(&tv);
}

/* Since the machine booted. */
static inline __u64 getRelativeCurUs(void) {
        return pg_div(get_cycles(), pg_cycles_per_us);
}

/* Since the machine booted. */
static inline __u64 getRelativeCurNs(void) {
        return pg_div(get_cycles(), pg_cycles_per_ns);
}

static inline __u64 tv_diff(const struct timeval* a, const struct timeval* b) {
        return tv_to_us(a) - tv_to_us(b);
}



int pktgen_proc_ioctl(struct inode* inode, struct file* file, unsigned int cmd,
                      unsigned long arg) {
        int err = 0;
        struct pktgen_ioctl_info args;
        struct pktgen_thread_info* targ = NULL;

        /*
        if (!capable(CAP_NET_ADMIN)){
                return -EPERM;
        }
        */
        
        if (copy_from_user(&args, (void*)arg, sizeof(args))) {
                return -EFAULT;
        }

        /* Null terminate the names */
        args.thread_name[31] = 0;
        args.interface_name[31] = 0;

        /* printk("pktgen:  thread_name: %s  interface_name: %s\n",
         *        args.thread_name, args.interface_name);
         */
        
        switch (cmd) {
         case GET_PKTGEN_INTERFACE_INFO: {
                 targ = pg_find_thread(args.thread_name);
                 if (targ) {
                         struct pktgen_interface_info* info;
                         info = pg_find_interface(targ, args.interface_name);
                         if (info) {
                                 memcpy(&(args.info), info, sizeof(args.info));
                                 if (copy_to_user((void*)(arg), &args, sizeof(args))) {
                                         printk("ERROR: pktgen:  copy_to_user failed.\n");
                                         err = -EFAULT;
                                 }
                                 else {
                                         err = 0;
                                 }
                         }
                         else {
                                 /* printk("ERROR: pktgen:  Could not find interface -:%s:-\n",
                                           args.interface_name);*/
                                 err = -ENODEV;
                         }
                 }
                 else {
                         printk("ERROR: pktgen:  Could not find thread -:%s:-.\n",
                                args.thread_name);
                         err = -ENODEV;
                 }
                 break;
         }
         default:
		/* pass on to underlying device instead?? */
		printk("%s: Unknown pktgen IOCTL: %x \n", __FUNCTION__,
			cmd);
		return -EINVAL;
        }
        
        return err;
}/* pktgen_proc_ioctl */

static struct file_operations pktgen_fops = {
        ioctl:     pktgen_proc_ioctl,
};

static void remove_pg_info_from_hash(struct pktgen_interface_info* info) {
        pg_lock_hash(__FUNCTION__);
        {
                int device_idx = info->odev ? info->odev->ifindex : 0;
                int b = device_idx % PG_INFO_HASH_MAX;
                struct pktgen_interface_info* p = pg_info_hash[b];
                struct pktgen_interface_info* prev = pg_info_hash[b];

                PG_DEBUG(printk("remove_pg_info_from_hash, p: %p info: %p  device_idx: %i\n",
                                p, info, device_idx));

                if (p != NULL) {
                
                        if (p == info) {
                                pg_info_hash[b] = p->next_hash;
                                p->next_hash = NULL;
                        }
                        else {
                                while (prev->next_hash) {
                                        p = prev->next_hash;
                                        if (p == info) {
                                                prev->next_hash = p->next_hash;
                                                p->next_hash = NULL;
                                                break;
                                        }
                                        prev = p;
                                }
                        }
                }
                
                if (info->odev) {
                        info->odev->priv_flags &= ~(IFF_PKTGEN_RCV);
			info->odev->notify_queue_woken = NULL;
			info->odev->nqw_data = NULL;
                }
        }
        pg_unlock_hash(__FUNCTION__);
}/* remove_pg_info_from_hash */


int pg_notify_queue_woken(struct net_device* dev) {
	struct pktgen_interface_info* info = dev->nqw_data;
	if (info && info->pg_thread->sleeping) {
		if (getRelativeCurNs() > (info->next_tx_ns - 1000)) {
			/* See if we should wake up the thread, wake
			 * slightly early (1000 ns)
			 */
			info->pg_thread->sleeping = 0;
			wake_up_interruptible(&(info->pg_thread->queue));
		}
	}
	return 0;
}


static void add_pg_info_to_hash(struct pktgen_interface_info* info) {
        /* First remove it, just in case it's already there. */
        remove_pg_info_from_hash(info);
        
        pg_lock_hash(__FUNCTION__);
        {
                int device_idx = info->odev ? info->odev->ifindex : 0;
                int b = device_idx % PG_INFO_HASH_MAX;

                PG_DEBUG(printk("add_pg_info_from_hash, b: %i info: %p  device_idx: %i\n",
                                b, info, device_idx));

                info->next_hash = pg_info_hash[b];
                pg_info_hash[b] = info;


                if (info->odev) {
			info->odev->nqw_data = info;
			info->odev->notify_queue_woken = pg_notify_queue_woken;
                        info->odev->priv_flags |= (IFF_PKTGEN_RCV);
                }
        }
        pg_unlock_hash(__FUNCTION__);
}/* add_pg_info_to_hash */


/* Find the pktgen_interface_info for a device idx */
struct pktgen_interface_info* find_pg_info(int device_idx) {
        struct pktgen_interface_info* p = NULL;
        if (debug > 1) {
                printk("in find_pg_info...\n");
        }
        pg_lock_hash(__FUNCTION__);
        {
                int b = device_idx % PG_INFO_HASH_MAX;
                p = pg_info_hash[b];
                while (p) {
                        if (p->odev && (p->odev->ifindex == device_idx)) {
                                break;
                        }
                        p = p->next_hash;
                }
        }
        pg_unlock_hash(__FUNCTION__);
        return p;
}


/* Remove an interface from our hash, dissassociate pktgen_interface_info
 * from interface
 */
static void check_remove_device(struct pktgen_interface_info* info) {
        struct pktgen_interface_info* pi = NULL;
        if (info->odev) {
                pi = find_pg_info(info->odev->ifindex);
                if (pi != info) {
                        printk("ERROR: pi != info, pi: %p  info: %p\n", pi, info);
                }
                else {
                        /* Remove info from our hash */
                        remove_pg_info_from_hash(info);
                }

                rtnl_lock();
                info->odev->priv_flags &= ~(IFF_PKTGEN_RCV);
                atomic_dec(&(info->odev->refcnt));
                info->odev = NULL;
                rtnl_unlock();
        }
}/* check_remove_device */


static int pg_remove_interface_from_all_threads(const char* dev_name) {
        int cnt = 0;
        pg_lock_thread_list(__FUNCTION__);
        {
                struct pktgen_thread_info* tmp = pktgen_threads;
                struct pktgen_interface_info* info = NULL;
                
                while (tmp) {
                        info = pg_find_interface(tmp, dev_name);
                        if (info) {
                                printk("pktgen:  Removing interface: %s from pktgen control.\n",
                                       dev_name);
                                pg_rem_interface_info(tmp, info);
                                cnt++;
                        }
                        else {
                                /* printk("pktgen:  Could not find interface: %s in rem_from_all.\n",
				   dev_name); */
                        }
                        tmp = tmp->next;
                }
        }
        pg_unlock_thread_list(__FUNCTION__);
        return cnt;
}/* pg_rem_interface_from_all_threads */


static int pktgen_device_event(struct notifier_block *unused, unsigned long event, void *ptr) {
	struct net_device *dev = (struct net_device *)(ptr);

	/* It is OK that we do not hold the group lock right now,
	 * as we run under the RTNL lock.
	 */

	switch (event) {
	case NETDEV_CHANGEADDR:
	case NETDEV_GOING_DOWN:
	case NETDEV_DOWN:
	case NETDEV_UP:
		/* Ignore for now */
		break;
		
	case NETDEV_UNREGISTER:
                pg_remove_interface_from_all_threads(dev->name);
		break;
	};

	return NOTIFY_DONE;
}


/* Associate pktgen_interface_info with a device.
 */
static struct net_device* pg_setup_interface(struct pktgen_interface_info* info) {
	struct net_device *odev;
	int keep_it = 0;
	
        check_remove_device(info);                
        
	odev = dev_get_by_name(info->ifname);
	if (!odev) {
		printk("No such netdevice: \"%s\"\n", info->ifname);
	}
	else if (odev->type != ARPHRD_ETHER) {
		printk("Not an ethernet device: \"%s\"\n", info->ifname);
	}
	else if (!netif_running(odev)) {
		printk("Device is down: \"%s\"\n", info->ifname);
	}
	else if (odev->priv_flags & IFF_PKTGEN_RCV) {
		printk("ERROR: Device: \"%s\" is already assigned to a pktgen interface.\n",
                       info->ifname);
	}
        else {
                info->odev = odev;
                info->odev->priv_flags |= (IFF_PKTGEN_RCV);
		keep_it = 1;
        }
        
        if (info->odev) {
                add_pg_info_to_hash(info);
        }

	if ((!keep_it) && odev) {
		dev_put(odev);
	}
        
        return info->odev;
}

/* Read info from the interface and set up internal pktgen_interface_info
 * structure to have the right information to create/send packets
 */
static void pg_setup_inject(struct pktgen_interface_info* info)
{
        if (!info->odev) {
                /* Try once more, just in case it works now. */
                pg_setup_interface(info);
        }
        
        if (!info->odev) {
                printk("ERROR: info->odev == NULL in setup_inject.\n");
                sprintf(info->result, "ERROR: info->odev == NULL in setup_inject.\n");
                return;
        }
        
        /* Default to the interface's mac if not explicitly set. */
        if (!(info->flags & F_SET_SRCMAC)) {
                memcpy(&(info->hh[6]), info->odev->dev_addr, 6);
        }
        else {
                memcpy(&(info->hh[6]), info->src_mac, 6);
        }

        /* Set up Dest MAC */
        memcpy(&(info->hh[0]), info->dst_mac, 6);

        /* Set up pkt size */
        info->cur_pkt_size = info->min_pkt_size;
        
	info->saddr_min = 0;
	info->saddr_max = 0;
        if (strlen(info->src_min) == 0) {
                if (info->odev->ip_ptr) {
                        struct in_device *in_dev = info->odev->ip_ptr;

                        if (in_dev->ifa_list) {
                                info->saddr_min = in_dev->ifa_list->ifa_address;
                                info->saddr_max = info->saddr_min;
                        }
                }
	}
        else {
                info->saddr_min = in_aton(info->src_min);
                info->saddr_max = in_aton(info->src_max);
        }

        info->daddr_min = in_aton(info->dst_min);
        info->daddr_max = in_aton(info->dst_max);

        /* Initialize current values. */
        info->cur_dst_mac_offset = 0;
        info->cur_src_mac_offset = 0;
        info->cur_saddr = info->saddr_min;
        info->cur_daddr = info->daddr_min;
        info->cur_udp_dst = info->udp_dst_min;
        info->cur_udp_src = info->udp_src_min;
}

/* delay_ns is in nano-seconds */
static void pg_nanodelay(int delay_ns, struct pktgen_interface_info* info,
			 struct pktgen_thread_info* pg_thread)
{
	u64 idle_start = getRelativeCurNs();
	u64 last_time;
	u64 itmp = idle_start;
	info->nanodelays++;
	info->accum_delay_ns += delay_ns;
	while (info->accum_delay_ns > PG_MAX_ACCUM_DELAY_NS) {
		info->sleeps++;
		pg_thread->sleeping = 1;
		interruptible_sleep_on_timeout(&(pg_thread->queue), 1);
		pg_thread->sleeping = 0;
		/* will wake after one tick */
		last_time = itmp;
		itmp = getRelativeCurNs();
		info->accum_delay_ns -= (itmp - last_time);
		info->idle_acc += (itmp - last_time);

		if (!info->do_run_run) {
			break;
		}
	}/* while */
}//pg_nanodelay


/* Returns: cycles per micro-second */
static int calc_mhz(void)
{
	struct timeval start, stop;
	u64 start_s;
        u64 t1, t2;
        u32 elapsed;
        u32 clock_time = 0;
        
	do_gettimeofday(&start);
	start_s = get_cycles();
        /* Spin for 50,000,000 cycles */
	do {
		barrier();
		elapsed = (u32)(get_cycles() - start_s);
		if (elapsed == 0)
			return 0;
	} while (elapsed < 50000000);
	do_gettimeofday(&stop);

        t1 = tv_to_us(&start);
        t2 = tv_to_us(&stop);

        clock_time = (u32)(t2 - t1);
        if (clock_time == 0) {
                printk("pktgen: ERROR:  clock_time was zero..things may not work right, t1: %u  t2: %u ...\n",
                       (u32)(t1), (u32)(t2));
                return 0x7FFFFFFF;
        }
	return elapsed / clock_time;
}

/* Calibrate cycles per micro-second */
static void cycles_calibrate(void)
{
	int i;

	for (i = 0; i < 3; i++) {
		u32 res = calc_mhz();
		if (res > pg_cycles_per_us)
			pg_cycles_per_us = res;
	}

        /* Set these up too, only need to calculate these once. */
        pg_cycles_per_ns = pg_cycles_per_us / 1000;
        if (pg_cycles_per_ns == 0) {
                pg_cycles_per_ns = 1;
        }
        pg_cycles_per_ms = pg_cycles_per_us * 1000;
        
        printk("pktgen: cycles_calibrate, cycles_per_ns: %d  per_us: %d  per_ms: %d\n",
               pg_cycles_per_ns, pg_cycles_per_us, pg_cycles_per_ms);
}


/* Increment/randomize headers according to flags and current values
 * for IP src/dest, UDP src/dst port, MAC-Addr src/dst
 */
static void mod_cur_headers(struct pktgen_interface_info* info) {        
        __u32 imn;
        __u32 imx;
        
	/*  Deal with source MAC */
        if (info->src_mac_count > 1) {
                __u32 mc;
                __u32 tmp;
                if (info->flags & F_MACSRC_RND) {
                        mc = net_random() % (info->src_mac_count);
                }
                else {
                        mc = info->cur_src_mac_offset++;
                        if (info->cur_src_mac_offset > info->src_mac_count) {
                                info->cur_src_mac_offset = 0;
                        }
                }

                tmp = info->src_mac[5] + (mc & 0xFF);
                info->hh[11] = tmp;
                tmp = (info->src_mac[4] + ((mc >> 8) & 0xFF) + (tmp >> 8));
                info->hh[10] = tmp;
                tmp = (info->src_mac[3] + ((mc >> 16) & 0xFF) + (tmp >> 8));
                info->hh[9] = tmp;
                tmp = (info->src_mac[2] + ((mc >> 24) & 0xFF) + (tmp >> 8));
                info->hh[8] = tmp;
                tmp = (info->src_mac[1] + (tmp >> 8));
                info->hh[7] = tmp;        
        }

        /*  Deal with Destination MAC */
        if (info->dst_mac_count > 1) {
                __u32 mc;
                __u32 tmp;
                if (info->flags & F_MACDST_RND) {
                        mc = net_random() % (info->dst_mac_count);
                }
                else {
                        mc = info->cur_dst_mac_offset++;
                        if (info->cur_dst_mac_offset > info->dst_mac_count) {
                                info->cur_dst_mac_offset = 0;
                        }
                }

                tmp = info->dst_mac[5] + (mc & 0xFF);
                info->hh[5] = tmp;
                tmp = (info->dst_mac[4] + ((mc >> 8) & 0xFF) + (tmp >> 8));
                info->hh[4] = tmp;
                tmp = (info->dst_mac[3] + ((mc >> 16) & 0xFF) + (tmp >> 8));
                info->hh[3] = tmp;
                tmp = (info->dst_mac[2] + ((mc >> 24) & 0xFF) + (tmp >> 8));
                info->hh[2] = tmp;
                tmp = (info->dst_mac[1] + (tmp >> 8));
                info->hh[1] = tmp;        
        }

        if (info->udp_src_min < info->udp_src_max) {
                if (info->flags & F_UDPSRC_RND) {
                        info->cur_udp_src = ((net_random() % (info->udp_src_max - info->udp_src_min))
                                             + info->udp_src_min);
                }
                else {
                     info->cur_udp_src++;
                     if (info->cur_udp_src >= info->udp_src_max) {
                             info->cur_udp_src = info->udp_src_min;
                     }
                }
        }

        if (info->udp_dst_min < info->udp_dst_max) {
                if (info->flags & F_UDPDST_RND) {
                        info->cur_udp_dst = ((net_random() % (info->udp_dst_max - info->udp_dst_min))
                                             + info->udp_dst_min);
                }
                else {
                     info->cur_udp_dst++;
                     if (info->cur_udp_dst >= info->udp_dst_max) {
                             info->cur_udp_dst = info->udp_dst_min;
                     }
                }
        }

        if ((imn = ntohl(info->saddr_min)) < (imx = ntohl(info->saddr_max))) {
                __u32 t;
                if (info->flags & F_IPSRC_RND) {
                        t = ((net_random() % (imx - imn)) + imn);
                }
                else {
                     t = ntohl(info->cur_saddr);
                     t++;
                     if (t > imx) {
                             t = imn;
                     }
                }
                info->cur_saddr = htonl(t);
        }

        if ((imn = ntohl(info->daddr_min)) < (imx = ntohl(info->daddr_max))) {
                __u32 t;
                if (info->flags & F_IPDST_RND) {
                        t = ((net_random() % (imx - imn)) + imn);
                }
                else {
                     t = ntohl(info->cur_daddr);
                     t++;
                     if (t > imx) {
                             t = imn;
                     }
                }
                info->cur_daddr = htonl(t);
        }

	/* dhetheri - Make MAC address = 00:00:IP address */
        if (info->flags & F_IPMAC) {
                __u32 tmp;
		__u32 t;

                /* SRC MAC = 00:00:IP address */
                t = ntohl(info->cur_saddr);

                tmp = info->src_mac[5] + (t & 0xFF);
                info->hh[11] = tmp;
                tmp = (info->src_mac[4] + ((t >> 8) & 0xFF) + (tmp >> 8));
                info->hh[10] = tmp;
                tmp = (info->src_mac[3] + ((t >> 16) & 0xFF) + (tmp >> 8));
                info->hh[9] = tmp;
                tmp = (info->src_mac[2] + ((t >> 24) & 0xFF) + (tmp >> 8));
                info->hh[8] = tmp;
                tmp = (info->src_mac[1] + (tmp >> 8));
                info->hh[7] = tmp;

                info->cur_saddr = htonl(t);

		/* DST MAC = 00:00:IP address */
		t = ntohl(info->cur_daddr);

		tmp = info->dst_mac[5] + (t & 0xFF);
		info->hh[5] = tmp;
		tmp = (info->dst_mac[4] + ((t >> 8) & 0xFF) + (tmp >> 8));
		info->hh[4] = tmp;
		tmp = (info->dst_mac[3] + ((t >> 16) & 0xFF) + (tmp >> 8));
		info->hh[3] = tmp;
		tmp = (info->dst_mac[2] + ((t >> 24) & 0xFF) + (tmp >> 8));
		info->hh[2] = tmp;
                tmp = (info->dst_mac[1] + (tmp >> 8));
                info->hh[1] = tmp;

                info->cur_daddr = htonl(t);
	}  /* MAC = 00:00:IP address (dhetheri) */
}/* mod_cur_headers */


static struct sk_buff *fill_packet(struct net_device *odev, struct pktgen_interface_info* info)
{
	struct sk_buff *skb = NULL;
	__u8 *eth;
	struct udphdr *udph;
	int datalen, iplen;
	struct iphdr *iph;
        struct pktgen_hdr *pgh = NULL;
   
	/* dhetheri - Moved out of mod_cur_headers. */
	if (info->min_pkt_size < info->max_pkt_size) {
		__u32 t;
		if (info->flags & F_TXSIZE_RND) {
			t = ((net_random() % (info->max_pkt_size - info->min_pkt_size))
			     + info->min_pkt_size);
		}
		else {
			t = info->cur_pkt_size + 1;
			if (t > info->max_pkt_size) {
				t = info->min_pkt_size;
			}
		}
		info->cur_pkt_size = t;
	}

	skb = alloc_skb(info->cur_pkt_size + 64 + 16, GFP_ATOMIC);
	if (!skb) {
		sprintf(info->result, "No memory");
		return NULL;
	}

	skb_reserve(skb, 16);

	/*  Reserve for ethernet and IP header  */
	eth = (__u8 *) skb_push(skb, 14);
	iph = (struct iphdr *)skb_put(skb, sizeof(struct iphdr));
	udph = (struct udphdr *)skb_put(skb, sizeof(struct udphdr));

        /* Update any of the values, used when we're incrementing various
         * fields.
         */
        mod_cur_headers(info);

	memcpy(eth, info->hh, 14);
        
	datalen = info->cur_pkt_size - 14 - 20 - 8; /* Eth + IPh + UDPh */
	if (datalen < sizeof(struct pktgen_hdr)) {
		datalen = sizeof(struct pktgen_hdr);
        }
        
	udph->source = htons(info->cur_udp_src);
	udph->dest = htons(info->cur_udp_dst);
	udph->len = htons(datalen + 8); /* DATA + udphdr */
	udph->check = 0;  /* No checksum */

	iph->ihl = 5;
	iph->version = 4;
	iph->ttl = 32;
	iph->tos = 0;
	if (info->prot) {			/* dhetheri */
		iph->protocol = info->prot; /* dhetheri */
	}
	else {
		iph->protocol = IPPROTO_UDP; /* UDP */
	}
	iph->saddr = info->cur_saddr;
	iph->daddr = info->cur_daddr;
	iph->frag_off = 0;
	iplen = 20 + 8 + datalen;
	iph->tot_len = htons(iplen);
	iph->check = 0;
	iph->check = ip_fast_csum((void *) iph, iph->ihl);
	skb->protocol = __constant_htons(ETH_P_IP);
	skb->mac.raw = ((u8 *)iph) - 14;
	skb->dev = odev;
	skb->pkt_type = PACKET_HOST;

	if (info->nfrags <= 0) {
                pgh = (struct pktgen_hdr *)skb_put(skb, datalen);
	} else {
		int frags = info->nfrags;
		int i;

                pgh = (struct pktgen_hdr*)(((char*)(udph)) + 8);
                
		if (frags > MAX_SKB_FRAGS)
			frags = MAX_SKB_FRAGS;
		if (datalen > frags*PAGE_SIZE) {
			skb_put(skb, datalen-frags*PAGE_SIZE);
			datalen = frags*PAGE_SIZE;
		}

		i = 0;
		while (datalen > 0) {
			struct page *page = alloc_pages(GFP_KERNEL, 0);
			skb_shinfo(skb)->frags[i].page = page;
			skb_shinfo(skb)->frags[i].page_offset = 0;
			skb_shinfo(skb)->frags[i].size =
				(datalen < PAGE_SIZE ? datalen : PAGE_SIZE);
			datalen -= skb_shinfo(skb)->frags[i].size;
			skb->len += skb_shinfo(skb)->frags[i].size;
			skb->data_len += skb_shinfo(skb)->frags[i].size;
			i++;
			skb_shinfo(skb)->nr_frags = i;
		}

		while (i < frags) {
			int rem;

			if (i == 0)
				break;

			rem = skb_shinfo(skb)->frags[i - 1].size / 2;
			if (rem == 0)
				break;

			skb_shinfo(skb)->frags[i - 1].size -= rem;

			skb_shinfo(skb)->frags[i] = skb_shinfo(skb)->frags[i - 1];
			get_page(skb_shinfo(skb)->frags[i].page);
			skb_shinfo(skb)->frags[i].page = skb_shinfo(skb)->frags[i - 1].page;
			skb_shinfo(skb)->frags[i].page_offset += skb_shinfo(skb)->frags[i - 1].size;
			skb_shinfo(skb)->frags[i].size = rem;
			i++;
			skb_shinfo(skb)->nr_frags = i;
		}
	}

        /* Stamp the time, and sequence number, convert them to network byte order */
        if (pgh) {
                pgh->pgh_magic = __constant_htonl(PKTGEN_MAGIC);
                do_gettimeofday(&(pgh->timestamp));
                pgh->timestamp.tv_usec = htonl(pgh->timestamp.tv_usec);
                pgh->timestamp.tv_sec = htonl(pgh->timestamp.tv_sec);
                pgh->seq_num = htonl(info->seq_num);
        }
        info->seq_num++;
        
	return skb;
}


static void record_latency(struct pktgen_interface_info* info, int latency) {
        /* NOTE:  Latency can be negative */
        int div = 100;
        int diff;
        int vl;
        int i;

        info->pkts_rcvd_since_clear++;
        
        if (info->pkts_rcvd_since_clear < 100) {
                div = info->pkts_rcvd;
                if (info->pkts_rcvd_since_clear == 1) {
                        info->avg_latency = latency;
                }
        }

        if ((div + 1) == 0) {
                info->avg_latency = 0;
        }
        else {
                info->avg_latency = ((info->avg_latency * div + latency) / (div + 1));
        }

        if (latency < info->min_latency) {
                info->min_latency = latency;
        }
        if (latency > info->max_latency) {
                info->max_latency = latency;
        }

        /* Place the latency in the right 'bucket' */
        diff = (latency - info->min_latency);        
        for (i = 0; i<LAT_BUCKETS_MAX; i++) {
                vl = (1<<i);
                if (latency <= vl) {
                        info->latency_bkts[i]++;
                        break;
                }
        }
}/* record latency */


/* Returns < 0 if the skb is not a pktgen buffer. */
int pktgen_receive(struct sk_buff* skb) {
	/* int i; */ /* Debugging only */
	/* unsigned char* tmp; */

	/* dhetheri */
	//printk("pktgen receive:\n");
	//tmp=(char *)(skb->data);
	//for (i=0; i<90; i++) {
	//  printk("%02hx ", tmp[i]);
	//  if (((i+1) % 15) == 0) {
	//     printk("\n");
	//  }
	//}
	//printk("\n");
	/* dhetheri */

        /* See if we have a pktgen packet */
        if ((skb->len >= (20 + 8 + sizeof(struct pktgen_hdr))) &&
            (skb->protocol == __constant_htons(ETH_P_IP))) {
		struct pktgen_hdr* pgh;
                
                /* It's IP, and long enough, lets check the magic number.
                 * TODO:  This is a hack not always guaranteed to catch the right
                 * packets.
                 */
		
		/* printk("Length & protocol passed, skb->data: %p, raw: %p\n",
		          skb->data, skb->h.raw); */
       
                pgh = (struct pktgen_hdr*)(skb->data + 20 + 8);
		
                /*
                tmp = (char*)(skb->data);
                for (i = 0; i<90; i++) {
                        printk("%02hx ", tmp[i]);
                        if (((i + 1) % 15) == 0) {
                                printk("\n");
                        }
                }
                printk("\n");
                */
                
                if (pgh->pgh_magic == __constant_ntohl(PKTGEN_MAGIC)) {
                        struct net_device* dev = skb->dev;
                        struct pktgen_interface_info* info = find_pg_info(dev->ifindex);
                        
                        /* Got one! */
                        /* TODO:  Check UDP checksum ?? */
                        __u32 seq = ntohl(pgh->seq_num);

                        if (!info) {
                                return -1;
                        }

                        info->pkts_rcvd++;
                        info->bytes_rcvd += (skb->len + 4); /* +4 for the checksum */
                        
                        /* Check for out-of-sequence packets */
                        if (info->last_seq_rcvd == seq) {
                                info->dup_rcvd++;
                                info->dup_since_incr++;
                        }
                        else {
                                __s64 rx;
                                __s64 tx;
                                struct timeval txtv;
				if (!skb->stamp.tv_sec) {
					do_gettimeofday(&skb->stamp);
				}
                                rx = tv_to_us(&(skb->stamp));

                                txtv.tv_usec = ntohl(pgh->timestamp.tv_usec);
                                txtv.tv_sec = ntohl(pgh->timestamp.tv_sec);
                                tx = tv_to_us(&txtv);
                                record_latency(info, rx - tx);
                                
                                if ((info->last_seq_rcvd + 1) == seq) {
                                        if ((info->peer_multiskb > 1) &&
                                            (info->peer_multiskb > (info->dup_since_incr + 1))) {
                                                
                                                info->seq_gap_rcvd += (info->peer_multiskb -
                                                                       info->dup_since_incr - 1);
                                        }
                                        /* Great, in order...all is well */
                                }
                                else if (info->last_seq_rcvd < seq) {
                                        /* sequence gap, means we dropped a pkt most likely */
                                        if (info->peer_multiskb > 1) {
                                                /* We dropped more than one sequence number's worth,
                                                 * and if we're using multiskb, then this is quite
                                                 * a few.  This number still will not be exact, but
                                                 * it will be closer.
                                                 */
                                                info->seq_gap_rcvd += (((seq - info->last_seq_rcvd) *
                                                                        info->peer_multiskb) -
                                                                       info->dup_since_incr);
                                        }
                                        else {
                                                info->seq_gap_rcvd += (seq - info->last_seq_rcvd - 1);
                                        }
                                }
                                else {
                                        info->ooo_rcvd++; /* out-of-order */
                                }
                                
                                info->dup_since_incr = 0;
                        }
                        info->last_seq_rcvd = seq;
                        kfree_skb(skb);
                        if (debug > 1) {
                                printk("done with pktgen_receive, free'd pkt\n");
                        }
                        return 0;
                }
        }
        return -1; /* Let another protocol handle it, it's not for us! */
}/* pktgen_receive */

static void pg_reset_latency_counters(struct pktgen_interface_info* info) {
        int i;
        info->avg_latency = 0;
        info->min_latency = 0x7fffffff; /* largest integer */
        info->max_latency = 0x80000000; /* smallest integer */
        info->pkts_rcvd_since_clear = 0;
        for (i = 0; i<LAT_BUCKETS_MAX; i++) {
                info->latency_bkts[i] = 0;
        }
}

static void pg_clear_counters(struct pktgen_interface_info* info, int seq_too) {
        info->idle_acc = 0;
	info->sofar = 0;
        info->tx_bytes = 0;
        info->errors = 0;
        info->ooo_rcvd = 0;
        info->dup_rcvd = 0;
        info->pkts_rcvd = 0;
        info->bytes_rcvd = 0;
        info->non_pg_pkts_rcvd = 0;
        info->seq_gap_rcvd = 0; /* dropped */

	/* Clear some transient state */
	info->accum_delay_ns = 0;
	info->sleeps = 0;
	info->nanodelays = 0;
	
        /* This is a bit of a hack, but it gets the dup counters
         * in line so we don't have false alarms on dropped pkts.
         */
        if (seq_too) {
                info->dup_since_incr = info->peer_multiskb - 1;
                info->seq_num = 1;
                info->last_seq_rcvd = 0;
        }
        
        pg_reset_latency_counters(info);
}

/* Adds an interface to the thread.  The interface will be in
 * the stopped queue untill started.
 */
static int add_interface_to_thread(struct pktgen_thread_info* pg_thread,
                                   struct pktgen_interface_info* info) {
        int rv = 0;
        /* grab lock & insert into the stopped list */
        pg_lock(pg_thread, __FUNCTION__);

        if (info->pg_thread) {
                printk("pktgen: ERROR:  Already assigned to a thread.\n");
                rv = -EBUSY;
                goto out;
        }
        
        info->next = pg_thread->stopped_if_infos;
        pg_thread->stopped_if_infos = info;
        info->pg_thread = pg_thread;

 out:
        pg_unlock(pg_thread, __FUNCTION__);        
        return rv;
}

/* Set up structure for sending pkts, clear counters, add to rcv hash,
 * create initial packet, and move from the stopped to the running
 * interface_info list
 */
static int pg_start_interface(struct pktgen_thread_info* pg_thread,
                              struct pktgen_interface_info* info) {
        PG_DEBUG(printk("Entering pg_start_interface..\n"));
        pg_setup_inject(info);

	if (!info->odev) {
		return -1;
        }

        PG_DEBUG(printk("About to clean counters..\n"));
        pg_clear_counters(info, 1);

        info->do_run_run = 1; /* Cranke yeself! */

	info->skb = NULL;

	info->started_at = getCurUs();

        pg_lock(pg_thread, __FUNCTION__);
        {
                /* Remove from the stopped list */
                struct pktgen_interface_info* p = pg_thread->stopped_if_infos;
                if (p == info) {
                        pg_thread->stopped_if_infos = p->next;
                        p->next = NULL;
                }
                else {
                        while (p) {
                                if (p->next == info) {
                                        p->next = p->next->next;
                                        info->next = NULL;
                                        break;
                                }
                                p = p->next;
                        }
                }

                info->next_tx_ns = 0; /* Transmit immediately */
                
                /* Move to the front of the running list */
                info->next = pg_thread->running_if_infos;
                pg_thread->running_if_infos = info;
                pg_thread->running_if_sz++;
        }
        pg_unlock(pg_thread, __FUNCTION__);
        PG_DEBUG(printk("Leaving pg_start_interface..\n"));
        return 0;
}/* pg_start_interface */


/* set stopped-at timer, remove from running list, do counters & statistics
 * NOTE:  We do not remove from the rcv hash.
 */
static int pg_stop_interface(struct pktgen_thread_info* pg_thread,
                             struct pktgen_interface_info* info) {
        __u64 total_us;
        if (!info->do_run_run) {
                printk("pktgen interface: %s is already stopped\n", info->ifname);
                return -EINVAL;
        }
        
        info->stopped_at = getCurMs();
        info->do_run_run = 0;

        /* The main worker loop will place it onto the stopped list if needed,
         * next time this interface is asked to be re-inserted into the
         * list.
         */
        
	total_us = info->stopped_at - info->started_at;

        {
                __u64 idle = pg_div(info->idle_acc, 1000); /* convert to us */
		char *p = info->result;
                __u64 pps = divremdi3(info->sofar * 1000, pg_div(total_us, 1000), PG_DIV);
                __u64 bps = pps * 8 * (info->cur_pkt_size + 4); /* take 32bit ethernet CRC into account */
                
		p += sprintf(p, "OK: %llu(c%llu+d%llu) usec, %llu (%dbyte) %llupps %lluMb/sec (%llubps)  errors: %llu",
			     total_us, total_us - idle, idle,
			     info->sofar,
                             info->cur_pkt_size + 4, /* Add 4 to account for the ethernet checksum */
			     pps,
			     bps >> 20, bps, info->errors
			     );
	}
        return 0;
}/* pg_stop_interface */


/* Re-inserts 'last' into the pg_thread's list.  Calling code should
 * make sure that 'last' is not already in the list.
 */
static struct pktgen_interface_info* pg_resort_pginfos(struct pktgen_thread_info* pg_thread,
                                                       struct pktgen_interface_info* last,
                                                       int setup_cur_if) {
        struct pktgen_interface_info* rv = NULL;
        
        pg_lock(pg_thread, __FUNCTION__);
        {
                struct pktgen_interface_info* p = pg_thread->running_if_infos;
        
                if (last) {
                        if (!last->do_run_run) {
                                /* If this guy was stopped while 'current', then
                                 * we'll want to place him on the stopped list
                                 * here.
                                 */
                                last->next = pg_thread->stopped_if_infos;
                                pg_thread->stopped_if_infos = last;
                                pg_thread->running_if_sz--;
                        }
                        else {
                                /* re-insert */
                                if (!p) {
                                        pg_thread->running_if_infos = last;
                                        last->next = NULL;
                                }
                                else {
                                        /* Another special case, check to see if we should go at the
                                         * front of the queue.
                                         */
                                        if (p->next_tx_ns > last->next_tx_ns) {
                                                last->next = p;
                                                pg_thread->running_if_infos = last;
                                        }
                                        else {
                                                int inserted = 0;
                                                while (p->next) {
                                                        if (p->next->next_tx_ns > last->next_tx_ns) {
                                                                /* Insert into the list */
                                                                last->next = p->next;
                                                                p->next = last;
                                                                inserted = 1;
                                                                break;
                                                        }
                                                        p = p->next;
                                                }
                                                if (!inserted) {
                                                        /* place at the end */
                                                        last->next = NULL;
                                                        p->next = last;
                                                }
                                        }
                                }
                        }
                }

                /* List is re-sorted, so grab the first one to return */
                rv = pg_thread->running_if_infos;
                if (rv) {
                        /* Pop him off of the list.  We do this here because we already
                         * have the lock.  Calling code just has to be aware of this
                         * feature.
                         */
                        pg_thread->running_if_infos = rv->next;
                }
        }

        if (setup_cur_if) {
                pg_thread->cur_if = rv;
        }
        
        pg_unlock(pg_thread, __FUNCTION__);
        return rv;
}/* pg_resort_pginfos */


void pg_stop_all_ifs(struct pktgen_thread_info* pg_thread) {
        struct pktgen_interface_info* next = NULL;

        pg_lock(pg_thread, __FUNCTION__);
        if (pg_thread->cur_if) {
                /* Move it onto the stopped list */
                pg_stop_interface(pg_thread, pg_thread->cur_if);
                pg_thread->cur_if->next = pg_thread->stopped_if_infos;
                pg_thread->stopped_if_infos = pg_thread->cur_if;
                pg_thread->cur_if = NULL;
        }
        pg_unlock(pg_thread, __FUNCTION__);

        /* These have their own locking */
        next = pg_resort_pginfos(pg_thread, NULL, 0);
        while (next) {
                pg_stop_interface(pg_thread, next);
                next = pg_resort_pginfos(pg_thread, NULL, 0);
        }
}/* pg_stop_all_ifs */


void pg_rem_all_ifs(struct pktgen_thread_info* pg_thread) {
        struct pktgen_interface_info* next = NULL;
        
        /* Remove all interfaces, clean up memory */
        while ((next = pg_thread->stopped_if_infos)) {
                int rv = pg_rem_interface_info(pg_thread, next);
                if (rv >= 0) {
                        kfree(next);
                }
                else {
                        printk("ERROR: failed to rem_interface: %i\n", rv);
                }
        }
}/* pg_rem_all_ifs */


void pg_rem_from_thread_list(struct pktgen_thread_info* pg_thread) {
        /* Remove from the thread list */
        pg_lock_thread_list(__FUNCTION__);
        {
                struct pktgen_thread_info* tmp = pktgen_threads;
                if (tmp == pg_thread) {
                        pktgen_threads = tmp->next;
                }
                else {
                        while (tmp) {
                                if (tmp->next == pg_thread) {
                                        tmp->next = pg_thread->next;
                                        pg_thread->next = NULL;
                                        break;
                                }
                                tmp = tmp->next;
                        }
                }
        }
        pg_unlock_thread_list(__FUNCTION__);
}/* pg_rem_from_thread_list */


/* Main loop of the thread.  Send pkts.
 */
void pg_thread_worker(struct pktgen_thread_info* pg_thread) {
	struct net_device *odev = NULL;
        __u64 idle_start = 0;
        struct pktgen_interface_info* next = NULL;
        u32 next_ipg = 0;
        u64 now = 0; /* in nano-seconds */
        u32 tx_since_softirq = 0;
	u32 queue_stopped = 0;
        
        /* setup the thread environment */
        init_pktgen_kthread(pg_thread, "kpktgend");
        
        PG_DEBUG(printk("Starting up pktgen thread: %s\n", pg_thread->name));
        
        /* an endless loop in which we are doing our work */
        while (1) {

		if (queue_stopped > pg_thread->running_if_sz) {
                        /* All our devices are all fulled up, schedule and hope to run
                         * again soon.
                         */
			/* Take this opportunity to run the soft-irq */
			do_softirq();
			tx_since_softirq = 0;

			pg_thread->queues_stopped++;
			pg_thread->sleeping = 1;
                        interruptible_sleep_on_timeout(&(pg_thread->queue), 1);
			pg_thread->sleeping = 0;
                        queue_stopped = 0;
                }

                /* Re-sorts the list, inserting 'next' (which is really the last one
                 * we used).  It pops the top one off of the queue and returns it.
                 * Calling code must make sure to re-insert the returned value
                 */
                next = pg_resort_pginfos(pg_thread, next, 1);
                
                if (next) {

                        odev = next->odev;

                        if (next->ipg || (next->accum_delay_ns > 0)) {

                                now = getRelativeCurNs();
                                if (now < next->next_tx_ns) {
                                        next_ipg = (u32)(next->next_tx_ns - now);
                                        
                                        /* These will not actually busy-spin now.  Will run as
					 * much as 1ms fast, and will sleep in 1ms units, assuming
					 * our tick is 1ms.
					 */
					pg_nanodelay(next_ipg, next, pg_thread);
					if (!next->do_run_run) {
						/* We were stopped while sleeping */
						continue;
					}
                                }

                                /* This is max IPG, this has special meaning of
                                 * "never transmit"
                                 */
                                if (next->ipg == 0x7FFFFFFF) {
                                        next->next_tx_ns = getRelativeCurNs() + next->ipg;
                                        continue;
                                }
                        }

			if (need_resched()) {
                                idle_start = getRelativeCurNs();
				schedule();
                                next->idle_acc += getRelativeCurNs() - idle_start;
			}
                
                        if (netif_queue_stopped(odev)) {
				next->queue_stopped++;
				queue_stopped++;

				if (!netif_running(odev)) {
                                        pg_stop_interface(pg_thread, next);
                                }

				continue; /* Try the next interface */
                        }
                        
                        if (next->last_ok || !next->skb) {
                                if ((++next->fp_tmp >= next->multiskb ) || (!next->skb)) {
                                        /* build a new pkt */
                                        if (next->skb) {
                                                kfree_skb(next->skb);
                                        }
                                        next->skb = fill_packet(odev, next);
                                        if (next->skb == NULL) {
						if (net_ratelimit()) {
							printk(KERN_INFO "pktgen:  Couldn't allocate skb in fill_packet.\n");
						}
                                                schedule();
                                                next->fp_tmp--; /* back out increment, OOM */
                                                continue;
                                        }
                                        next->fp++;
                                        next->fp_tmp = 0; /* reset counter */
                                        /* Not sure what good knowing nr_frags is...
                                        next->nr_frags = skb_shinfo(skb)->nr_frags;
                                        */
                                }
                                atomic_inc(&(next->skb->users));
                        }
                
                        spin_lock_bh(&odev->xmit_lock);
                        if (!netif_queue_stopped(odev)) {
                                if (odev->hard_start_xmit(next->skb, odev)) {
                                        if (net_ratelimit()) {
                                                printk(KERN_INFO "Hard xmit error\n");
                                        }
                                        next->errors++;
                                        next->last_ok = 0;
                                        next->queue_stopped++;
					queue_stopped++;
                                }
                                else {
					queue_stopped = 0; /* reset this, we tx'd one successfully */
                                        next->last_ok = 1;
                                        next->sofar++;
                                        next->tx_bytes += (next->cur_pkt_size + 4); /* count csum */
                                }
                        }
                        else {  /* Re-try it next time */
				queue_stopped++;
                                next->queue_stopped++;
                                next->last_ok = 0;	
                        }
                        spin_unlock_bh(&odev->xmit_lock);

			next->next_tx_ns = getRelativeCurNs() + next->ipg;

                        if (++tx_since_softirq > pg_thread->max_before_softirq) {
                                do_softirq();
                                tx_since_softirq = 0;
                        }

                        /* If next->count is zero, then run forever */
                        if ((next->count != 0) && (next->sofar >= next->count)) {
                                if (atomic_read(&(next->skb->users)) != 1) {
                                        idle_start = getRelativeCurNs();
                                        while (atomic_read(&(next->skb->users)) != 1) {
                                                if (signal_pending(current)) {
                                                        break;
                                                }
                                                schedule();
                                        }
                                        next->idle_acc += getRelativeCurNs() - idle_start;
                                }
                                pg_stop_interface(pg_thread, next);
                        }/* if we're done with a particular interface. */

                }/* if could find the next interface to send on. */
                else {
                        /* fall asleep for a bit */
			pg_thread->sleeping = 1;
                        interruptible_sleep_on_timeout(&(pg_thread->queue), HZ/10);
			pg_thread->sleeping = 0;
                }
                
                /* here we are back from sleep, either due to the timeout
                   (one second), or because we caught a signal.
                */
                if (pg_thread->terminate || signal_pending(current)) {
                        /* we received a request to terminate ourself */
                        break;
                }

        }//while true

        /* here we go only in case of termination of the thread */

        PG_DEBUG(printk("pgthread: %s  stopping all Interfaces.\n", pg_thread->name));
        pg_stop_all_ifs(pg_thread);

        PG_DEBUG(printk("pgthread: %s  removing all Interfaces.\n", pg_thread->name));
        pg_rem_all_ifs(pg_thread);

        pg_rem_from_thread_list(pg_thread);
        
        /* cleanup the thread, leave */
        PG_DEBUG(printk("pgthread: %s  calling exit_pktgen_kthread.\n", pg_thread->name));
        exit_pktgen_kthread(pg_thread);
}

/* private functions */
static void kthread_launcher(void *data) {
        struct pktgen_thread_info *kthread = data;
        kernel_thread((int (*)(void *))kthread->function, (void *)kthread, 0);       
}

/* create a new kernel thread. Called by the creator. */
void start_pktgen_kthread(struct pktgen_thread_info *kthread) {

        /* initialize the semaphore:
           we start with the semaphore locked. The new kernel
           thread will setup its stuff and unlock it. This
           control flow (the one that creates the thread) blocks
           in the down operation below until the thread has reached
           the up() operation.
         */
        init_MUTEX_LOCKED(&kthread->startstop_sem);

        /* store the function to be executed in the data passed to
           the launcher */
        kthread->function = pg_thread_worker;
        
        /* create the new thread my running a task through keventd */

	INIT_WORK(&(kthread->wq), kthread_launcher, kthread);

        /* and schedule it for execution */
        schedule_work(&kthread->wq);

        /* wait till it has reached the setup_thread routine */
        down(&kthread->startstop_sem);
}

/* stop a kernel thread. Called by the removing instance */
static void stop_pktgen_kthread(struct pktgen_thread_info *kthread) {
        PG_DEBUG(printk("pgthread: %s  stop_pktgen_kthread.\n", kthread->name));

        if (kthread->thread == NULL) {
                printk("stop_kthread: killing non existing thread!\n");
                return;
        }

        /* Stop each interface */
        pg_lock(kthread, __FUNCTION__);
        {
                struct pktgen_interface_info* tmp = kthread->running_if_infos;
                while (tmp) {
                        tmp->do_run_run = 0;
                        tmp->next_tx_ns = 0;
                        tmp = tmp->next;
                }
                if (kthread->cur_if) {
                        kthread->cur_if->do_run_run = 0;
                        kthread->cur_if->next_tx_ns = 0;
                }
        }
        pg_unlock(kthread, __FUNCTION__);

        /* Wait for everything to fully stop */
        while (1) {
                pg_lock(kthread, __FUNCTION__);
                if (kthread->cur_if || kthread->running_if_infos) {
                        pg_unlock(kthread, __FUNCTION__);
                        if (need_resched()) {
                                schedule();
                        }
                        mdelay(1);
                }
                else {
                        pg_unlock(kthread, __FUNCTION__);
                        break;
                }
        }
        
        /* this function needs to be protected with the big
	   kernel lock (lock_kernel()). The lock must be
           grabbed before changing the terminate
	   flag and released after the down() call. */
        lock_kernel();
        
        /* initialize the semaphore. We lock it here, the
           leave_thread call of the thread to be terminated
           will unlock it. As soon as we see the semaphore
           unlocked, we know that the thread has exited.
	*/
        init_MUTEX_LOCKED(&kthread->startstop_sem);

        /* We need to do a memory barrier here to be sure that
           the flags are visible on all CPUs. 
        */
        mb();

        /* set flag to request thread termination */
        kthread->terminate = 1;

        /* We need to do a memory barrier here to be sure that
           the flags are visible on all CPUs. 
        */
        mb();
        kill_proc(kthread->thread->pid, SIGKILL, 1);
       
        /* block till thread terminated */
        down(&kthread->startstop_sem);
        kthread->in_use = 0;
        
        /* release the big kernel lock */
        unlock_kernel();

        /* now we are sure the thread is in zombie state. We
           notify keventd to clean the process up.
        */
        kill_proc(2, SIGCHLD, 1);

        PG_DEBUG(printk("pgthread: %s  done with stop_pktgen_kthread.\n", kthread->name));
}/* stop_pktgen_kthread */


/* initialize new created thread. Called by the new thread. */
void init_pktgen_kthread(struct pktgen_thread_info *kthread, char *name) {
        /* lock the kernel. A new kernel thread starts without
           the big kernel lock, regardless of the lock state
           of the creator (the lock level is *not* inheritated)
        */
        lock_kernel();

        /* fill in thread structure */
        kthread->thread = current;

        /* set signal mask to what we want to respond */
        siginitsetinv(&current->blocked, sigmask(SIGKILL)|sigmask(SIGINT)|sigmask(SIGTERM));

        /* initialise wait queue */
        init_waitqueue_head(&kthread->queue);

        /* initialise termination flag */
        kthread->terminate = 0;

        /* set name of this process (max 15 chars + 0 !) */
        sprintf(current->comm, name);
        
        /* let others run */
        unlock_kernel();

        /* tell the creator that we are ready and let him continue */
        up(&kthread->startstop_sem);
}/* init_pktgen_kthread */

/* cleanup of thread. Called by the exiting thread. */
static void exit_pktgen_kthread(struct pktgen_thread_info *kthread) {
        /* we are terminating */

	/* lock the kernel, the exit will unlock it */
        lock_kernel();
        kthread->thread = NULL;
        mb();

        /* Clean up proc file system */
        if (strlen(kthread->fname)) {
                remove_proc_entry(kthread->fname, NULL);
        }

        /* notify the stop_kthread() routine that we are terminating. */
	up(&kthread->startstop_sem);
	/* the kernel_thread that called clone() does a do_exit here. */

	/* there is no race here between execution of the "killer" and real termination
	   of the thread (race window between up and do_exit), since both the
	   thread and the "killer" function are running with the kernel lock held.
	   The kernel lock will be freed after the thread exited, so the code
	   is really not executed anymore as soon as the unload functions gets
	   the kernel lock back.
	   The init process may not have made the cleanup of the process here,
	   but the cleanup can be done safely with the module unloaded.
	*/
}/* exit_pktgen_kthread */


/* proc/net/pg */

static char* pg_display_latency(struct pktgen_interface_info* info, char* p, int reset_latency) {
        int i;
        p += sprintf(p, "     avg_latency: %dus  min_lat: %dus  max_lat: %dus  pkts_in_sample: %llu\n",
                     info->avg_latency, info->min_latency, info->max_latency,
                     info->pkts_rcvd_since_clear);
        p += sprintf(p, "      Buckets(us) [ ");
        for (i = 0; i<LAT_BUCKETS_MAX; i++) {
                p += sprintf(p, "%llu  ", info->latency_bkts[i]);
        }
        p += sprintf(p, "]\n");        

        if (reset_latency) {
                pg_reset_latency_counters(info);
        }
        return p;
}

static int proc_pg_if_read(char *buf , char **start, off_t offset,
                           int len, int *eof, void *data)
{
	char *p;
	int i;
        struct pktgen_interface_info* info = (struct pktgen_interface_info*)(data);
        __u64 sa;
        __u64 stopped;
        __u64 now = getCurUs();
        __u64 now_rel_ns = getRelativeCurNs();
        
	p = buf;
        p += sprintf(p, "VERSION-1\n"); /* Help with parsing compatibility */
	p += sprintf(p, "Params: count %llu  min_pkt_size: %u  max_pkt_size: %u  cur_pkt_size %u\n     frags: %d  ipg: %u  multiskb: %d  ifname: %s\n",
		     info->count, info->min_pkt_size, info->max_pkt_size, info->cur_pkt_size,
                     info->nfrags, info->ipg, info->multiskb, info->ifname);
        p += sprintf(p, "     dst_min: %s  dst_max: %s\n     src_min: %s  src_max: %s\n",
                     info->dst_min, info->dst_max, info->src_min, info->src_max);
        p += sprintf(p, "     src_mac: ");
	for (i = 0; i < 6; i++) {
		p += sprintf(p, "%02X%s", info->src_mac[i], i == 5 ? "  " : ":");
        }
        p += sprintf(p, "dst_mac: ");
	for (i = 0; i < 6; i++) {
		p += sprintf(p, "%02X%s", info->dst_mac[i], i == 5 ? "\n" : ":");
        }
        p += sprintf(p, "     udp_src_min: %d  udp_src_max: %d  udp_dst_min: %d  udp_dst_max: %d\n",
                     info->udp_src_min, info->udp_src_max, info->udp_dst_min,
                     info->udp_dst_max);
        p += sprintf(p, "     src_mac_count: %d  dst_mac_count: %d  peer_multiskb: %d\n     Flags: ",
                     info->src_mac_count, info->dst_mac_count, info->peer_multiskb);
        if (info->flags &  F_IPSRC_RND) {
                p += sprintf(p, "IPSRC_RND  ");
        }
        if (info->flags & F_IPDST_RND) {
                p += sprintf(p, "IPDST_RND  ");
        }
        if (info->flags & F_TXSIZE_RND) {
                p += sprintf(p, "TXSIZE_RND  ");
        }
        if (info->flags & F_UDPSRC_RND) {
                p += sprintf(p, "UDPSRC_RND  ");
        }
        if (info->flags & F_UDPDST_RND) {
                p += sprintf(p, "UDPDST_RND  ");
        }
        if (info->flags & F_MACSRC_RND) {
                p += sprintf(p, "MACSRC_RND  ");
        }
        if (info->flags & F_MACDST_RND) {
                p += sprintf(p, "MACDST_RND  ");
        }
	if (info->flags & F_IPMAC) {            /* dhetheri */
                p += sprintf(p, "IPMAC  ");
        }
	
        p += sprintf(p, "\n");
        
        sa = info->started_at;
        stopped = info->stopped_at;
        if (info->do_run_run) {
                stopped = now; /* not really stopped, more like last-running-at */
        }
        p += sprintf(p, "Current:\n     pkts-sofar: %llu  errors: %llu\naccum_delay: %lluns  sleeps: %u  nanodelays: %llu\n     started: %lluus  elapsed: %lluus\n     idle: %lluns  next_tx: %llu(%lli)ns\n",
                     info->sofar, info->errors,
		     info->accum_delay_ns, info->sleeps, info->nanodelays,
		     sa, (stopped - sa), info->idle_acc,
                     info->next_tx_ns, (long long)(info->next_tx_ns) - (long long)(now_rel_ns));
        p += sprintf(p, "     seq_num: %d  cur_dst_mac_offset: %d  cur_src_mac_offset: %d\n",
                     info->seq_num, info->cur_dst_mac_offset, info->cur_src_mac_offset);
        p += sprintf(p, "     cur_saddr: 0x%x  cur_daddr: 0x%x  cur_udp_dst: %d  cur_udp_src: %d\n",
                     info->cur_saddr, info->cur_daddr, info->cur_udp_dst, info->cur_udp_src);
        p += sprintf(p, "     pkts_rcvd: %llu  bytes_rcvd: %llu  last_seq_rcvd: %d  ooo_rcvd: %llu\n",
                     info->pkts_rcvd, info->bytes_rcvd, info->last_seq_rcvd, info->ooo_rcvd);
        p += sprintf(p, "     dup_rcvd: %llu  seq_gap_rcvd(dropped): %llu  non_pg_rcvd: %llu\n",
                     info->dup_rcvd, info->seq_gap_rcvd, info->non_pg_pkts_rcvd);

        p = pg_display_latency(info, p, 0);
        
	if (info->result[0])
		p += sprintf(p, "Result: %s\n", info->result);
	else
		p += sprintf(p, "Result: Idle\n");
	*eof = 1;

	return p - buf;
}


static int proc_pg_thread_read(char *buf , char **start, off_t offset,
                               int len, int *eof, void *data)
{
	char *p;
        struct pktgen_thread_info* pg_thread = (struct pktgen_thread_info*)(data);
        struct pktgen_interface_info* info = NULL;

        if (!pg_thread) {
                printk("ERROR: could not find pg_thread in proc_pg_thread_read\n");
                return -EINVAL;
        }
        
	p = buf;
        p += sprintf(p, "VERSION-1 CFG_RT\n"); /* Help with parsing compatibility */
	p += sprintf(p, "PID: %i Name: %s  max_before_softirq: %d  queues_stopped: %u\n",
                     pg_thread->thread->pid, pg_thread->name,
		     pg_thread->max_before_softirq, pg_thread->queues_stopped);

        pg_lock(pg_thread, __FUNCTION__);
        if (pg_thread->cur_if) {
                p += sprintf(p, "Current: %s\n", pg_thread->cur_if->ifname);
        }
        else {
                p += sprintf(p, "Current: NULL\n");
        }
        pg_unlock(pg_thread, __FUNCTION__);
        
        p += sprintf(p, "Running: ");
        
        pg_lock(pg_thread, __FUNCTION__);
        info = pg_thread->running_if_infos;
        while (info) {
                p += sprintf(p, "%s ", info->ifname);
                info = info->next;
        }
        p += sprintf(p, "\nStopped: ");
        info = pg_thread->stopped_if_infos;
        while (info) {
                p += sprintf(p, "%s ", info->ifname);
                info = info->next;
        }

	if (pg_thread->result[0])
		p += sprintf(p, "\nResult: %s\n", pg_thread->result);
	else
		p += sprintf(p, "\nResult: NA\n");
	*eof = 1;

        pg_unlock(pg_thread, __FUNCTION__);

	return p - buf;
}/* proc_pg_thread_read */


static int proc_pg_ctrl_read(char *buf , char **start, off_t offset,
                             int len, int *eof, void *data)
{
	char *p;
        struct pktgen_thread_info* pg_thread = NULL;
        
	p = buf;
        p += sprintf(p, "VERSION-1\n"); /* Help with parsing compatibility */
        p += sprintf(p, "Threads: ");
        
        pg_lock_thread_list(__FUNCTION__);
        pg_thread = pktgen_threads;
        while (pg_thread) {
                p += sprintf(p, "%s ", pg_thread->name);
                pg_thread = pg_thread->next;
        }
        p += sprintf(p, "\n");
        
	*eof = 1;

        pg_unlock_thread_list(__FUNCTION__);
	return p - buf;
}/* proc_pg_ctrl_read */


static int isdelim(const char c) {
	switch (c) {
	 case '\"':
	 case '\n':
	 case '\r':
	 case '\t':
	 case ' ':
	 case '=':
		return 1;
	}
	return 0;
}


static int count_trail_chars(const char *buf, unsigned int maxlen) {
	int i;

	for (i = 0; i < maxlen; i++) {
		if (!isdelim(buf[i])) {
			break;
		}
	}
	
	return i;
}


static int strncpy_token(char* dst, const char* src, int mx) {
	int i;
	for (i = 0; i<mx; i++) {
		if (isdelim(src[i])) {
			break;
		}
		else {
			dst[i] = src[i];
		}
	}
	dst[i] = 0;
	return i;
}/* strncpy_token */


static unsigned int atoui(const char *buf) {
	unsigned int i;
	int num = 0;
  
	for(i = 0; buf[i]; i++) {
		char c = buf[i];
                if ((c >= '0') && (c <= '9')) {
			num *= 10;
			num += c - '0';
		}
		else {
			break;
		}
	}
	return num;
}

static int proc_pg_if_write(struct file *file, const char *user_buffer,
                            unsigned long count, void *data)
{
	char name[16];
        struct pktgen_interface_info* info = (struct pktgen_interface_info*)(data);
	char* kbuf;
	char* p;
	char* pg_result = &(info->result[0]);
        int len;
	int value;
	
	if (count < 1) {
		sprintf(pg_result, "Wrong command format");
		return -EINVAL;
	}
  
	kbuf = kmalloc(count, GFP_KERNEL);
	if (copy_from_user(kbuf, user_buffer, count)) {
		kfree(kbuf);
		return -EFAULT;
	}

	p = kbuf;
	
	while (p < (kbuf + count)) {
		p += count_trail_chars(p, count - (p - kbuf));
  
		if (p >= (kbuf + count)) {
			break;
		}

		/* Read variable name */
		if (debug) {
			printk("pg_thread: %s,%lu\n", name, count);
		}

		len = strlen("stop");
		if (!strncmp(p, "stop", len)) {
			p += len;
			if (info->do_run_run) {
				strcpy(pg_result, "Stopping");
				pg_stop_interface(info->pg_thread, info);
			}
			else {
				strcpy(pg_result, "Already stopped...\n");
			}
			goto foundcmd;
		}

		len = strlen("min_pkt_size ");
		if (!strncmp(p, "min_pkt_size ", len)) {
			char f[32];
			p += len;

			p += count_trail_chars(p, count - (p - kbuf));

			strncpy_token(f, p, min(31, (int)(count - (p - kbuf))));
			f[31] = 0;
			
			p += strlen(f);
			value = atoui(f);
			
			if (value < 14+20+8)
				value = 14+20+8;
			if (value != info->min_pkt_size) {
				info->min_pkt_size = value;
				info->cur_pkt_size = value;
			}
			sprintf(pg_result, "OK: min_pkt_size=%u", info->min_pkt_size);
			goto foundcmd;
		}

		len = strlen("max_pkt_size ");
		if (!strncmp(p, "max_pkt_size ", len)) {
			char f[32];
			p += len;

			p += count_trail_chars(p, (int)(count - (p - kbuf)));

			strncpy_token(f, p, min(31, (int)(count - (p - kbuf))));
			f[31] = 0;
			
			p += strlen(f);
			value = atoui(f);

			if (value < 14+20+8)
				value = 14+20+8;
			if (value != info->max_pkt_size) {
				info->max_pkt_size = value;
				info->cur_pkt_size = value;
			}
			sprintf(pg_result, "OK: max_pkt_size=%u", info->max_pkt_size);
			goto foundcmd;
		}
		
		len = strlen("min_pkt_size ");
		if (!strncmp(p, "min_pkt_size ", len)) {
			char f[32];
			p += len;

			p += count_trail_chars(p, (int)(count - (p - kbuf)));

			strncpy_token(f, p, min(31, (int)(count - (p - kbuf))));
			f[31] = 0;
			
			p += strlen(f);
			debug = atoui(f);
			sprintf(pg_result, "OK: debug=%u", debug);
			goto foundcmd;
		}

		len = strlen("frags ");
		if (!strncmp(p, "frags ", len)) {
			char f[32];
			p += len;

			p += count_trail_chars(p, (int)(count - (p - kbuf)));

			strncpy_token(f, p, min(31, (int)(count - (p - kbuf))));
			f[31] = 0;
			
			p += strlen(f);
			info->nfrags = atoui(f);
			sprintf(pg_result, "OK: frags=%u", info->nfrags);
			goto foundcmd;
		}

		len = strlen("ipg ");
		if (!strncmp(p, "ipg ", len)) {
			char f[32];
			p += len;

			p += count_trail_chars(p, (int)(count - (p - kbuf)));

			strncpy_token(f, p, min(31, (int)(count - (p - kbuf))));
			f[31] = 0;
			
			p += strlen(f);
			info->ipg = atoui(f);
			if ((getRelativeCurNs() + info->ipg) > info->next_tx_ns) {
				info->next_tx_ns = getRelativeCurNs() + info->ipg;
			}
			sprintf(pg_result, "OK: ipg=%u", info->ipg);
			goto foundcmd;
		}
		
		len = strlen("udp_src_min ");
		if (!strncmp(p, "udp_src_min ", len)) {
			char f[32];
			p += len;

			p += count_trail_chars(p, (int)(count - (p - kbuf)));

			strncpy_token(f, p, min(31, (int)(count - (p - kbuf))));
			f[31] = 0;
			
			p += strlen(f);
			value = atoui(f);
			
			if (value != info->udp_src_min) {
				info->udp_src_min = value;
				info->cur_udp_src = value;
			}       
			sprintf(pg_result, "OK: udp_src_min=%u", info->udp_src_min);
			goto foundcmd;
		}

		len = strlen("udp_dst_min ");
		if (!strncmp(p, "udp_dst_min ", len)) {
			char f[32];
			p += len;

			p += count_trail_chars(p, (int)(count - (p - kbuf)));

			strncpy_token(f, p, min(31, (int)(count - (p - kbuf))));
			f[31] = 0;
			
			p += strlen(f);
			value = atoui(f);
			
			if (value != info->udp_dst_min) {
				info->udp_dst_min = value;
				info->cur_udp_dst = value;
			}
			sprintf(pg_result, "OK: udp_dst_min=%u", info->udp_dst_min);
			goto foundcmd;
		}
		
		len = strlen("udp_src_max ");
		if (!strncmp(p, "udp_src_max ", len)) {
			char f[32];
			p += len;

			p += count_trail_chars(p, (int)(count - (p - kbuf)));

			strncpy_token(f, p, min(31, (int)(count - (p - kbuf))));
			f[31] = 0;
			
			p += strlen(f);
			value = atoui(f);
			
			if (value != info->udp_src_max) {
				info->udp_src_max = value;
				info->cur_udp_src = value;
			}
			sprintf(pg_result, "OK: udp_src_max=%u", info->udp_src_max);
			goto foundcmd;
		}
		
		len = strlen("udp_dst_max ");
		if (!strncmp(p, "udp_dst_max ", len)) {
			char f[32];
			p += len;

			p += count_trail_chars(p, (int)(count - (p - kbuf)));

			strncpy_token(f, p, min(31, (int)(count - (p - kbuf))));
			f[31] = 0;
			
			p += strlen(f);
			value = atoui(f);
			
			if (value != info->udp_dst_max) {
				info->udp_dst_max = value;
				info->cur_udp_dst = value;
			}
			sprintf(pg_result, "OK: udp_dst_max=%u", info->udp_dst_max);
			goto foundcmd;
		}

		len = strlen("multiskb ");
		if (!strncmp(p, "multiskb ", len)) {
			char f[32];
			p += len;

			p += count_trail_chars(p, (int)(count - (p - kbuf)));

			strncpy_token(f, p, min(31, (int)(count - (p - kbuf))));
			f[31] = 0;
			
			p += strlen(f);
			info->multiskb = atoui(f);
			
			sprintf(pg_result, "OK: multiskb=%d", info->multiskb);
			goto foundcmd;
		}
		
		len = strlen("peer_multiskb ");
		if (!strncmp(p, "peer_multiskb ", len)) {
			char f[32];
			p += len;

			p += count_trail_chars(p, (int)(count - (p - kbuf)));

			strncpy_token(f, p, min(31, (int)(count - (p - kbuf))));
			f[31] = 0;
			
			p += strlen(f);
			info->peer_multiskb = atoui(f);
			
			sprintf(pg_result, "OK: peer_multiskb=%d",
				info->peer_multiskb);
			goto foundcmd;
		}
		
		len = strlen("count ");
		if (!strncmp(p, "count ", len)) {
			char f[32];
			p += len;

			p += count_trail_chars(p, (int)(count - (p - kbuf)));

			strncpy_token(f, p, min(31, (int)(count - (p - kbuf))));
			f[31] = 0;
			
			p += strlen(f);
			info->count = atoui(f);
			
			sprintf(pg_result, "OK: count=%llu", info->count);
			goto foundcmd;
		}
		
		len = strlen("prot ");
		if (!strncmp(p, "prot ", len)) {
			char f[32];
			p += len;

			p += count_trail_chars(p, (int)(count - (p - kbuf)));

			strncpy_token(f, p, min(31, (int)(count - (p - kbuf))));
			f[31] = 0;
			
			p += strlen(f);
			info->prot = atoui(f);
			
			sprintf(pg_result, "OK: prot=%u", info->prot);
			goto foundcmd;
		}

		len = strlen("src_mac_count ");
		if (!strncmp(p, "src_mac_count ", len)) {
			char f[32];
			p += len;

			p += count_trail_chars(p, (int)(count - (p - kbuf)));

			strncpy_token(f, p, min(31, (int)(count - (p - kbuf))));
			f[31] = 0;
			
			p += strlen(f);
			value = atoui(f);
			
			if (info->src_mac_count != value) {
				info->src_mac_count = value;
				info->cur_src_mac_offset = 0;
			}
			sprintf(pg_result, "OK: src_mac_count=%d", info->src_mac_count);
			goto foundcmd;
		}
		
		len = strlen("dst_mac_count ");
		if (!strncmp(p, "dst_mac_count ", len)) {
			char f[32];
			p += len;

			p += count_trail_chars(p, (int)(count - (p - kbuf)));

			strncpy_token(f, p, min(31, (int)(count - (p - kbuf))));
			f[31] = 0;
			
			p += strlen(f);
			value = atoui(f);
			
			if (info->dst_mac_count != value) {
				info->dst_mac_count = value;
				info->cur_dst_mac_offset = 0;
			}
			sprintf(pg_result, "OK: dst_mac_count=%d", info->dst_mac_count);
			goto foundcmd;
		}
		
		len = strlen("flag ");
		if (!strncmp(p, "flag ", len)) {
			char f[32];
			p += len;

			p += count_trail_chars(p, (int)(count - (p - kbuf)));

			strncpy_token(f, p, min(31, (int)(count - (p - kbuf))));
			f[31] = 0;
			
			p += strlen(f);

			if (strcmp(f, "IPSRC_RND") == 0) {
				info->flags |= F_IPSRC_RND;
			}
			else if (strcmp(f, "!IPSRC_RND") == 0) {
				info->flags &= ~F_IPSRC_RND;
			}
			else if (strcmp(f, "TXSIZE_RND") == 0) {
				info->flags |= F_TXSIZE_RND;
			}
			else if (strcmp(f, "!TXSIZE_RND") == 0) {
				info->flags &= ~F_TXSIZE_RND;
			}
			else if (strcmp(f, "IPDST_RND") == 0) {
				info->flags |= F_IPDST_RND;
			}
			else if (strcmp(f, "!IPDST_RND") == 0) {
				info->flags &= ~F_IPDST_RND;
			}
			else if (strcmp(f, "UDPSRC_RND") == 0) {
				info->flags |= F_UDPSRC_RND;
			}
			else if (strcmp(f, "!UDPSRC_RND") == 0) {
				info->flags &= ~F_UDPSRC_RND;
			}
			else if (strcmp(f, "UDPDST_RND") == 0) {
				info->flags |= F_UDPDST_RND;
			}
			else if (strcmp(f, "!UDPDST_RND") == 0) {
				info->flags &= ~F_UDPDST_RND;
			}
			else if (strcmp(f, "MACSRC_RND") == 0) {
				info->flags |= F_MACSRC_RND;
			}
			else if (strcmp(f, "!MACSRC_RND") == 0) {
				info->flags &= ~F_MACSRC_RND;
			}
			else if (strcmp(f, "MACDST_RND") == 0) {
				info->flags |= F_MACDST_RND;
			}
			else if (strcmp(f, "!MACDST_RND") == 0) {
				info->flags &= ~F_MACDST_RND;
			}
			else if (strcmp(f, "IPMAC") == 0) {          /* dhetheri */
				info->flags |= F_IPMAC;              /* dhetheri */
			}                                            /* dhetheri */
			else if (strcmp(f, "!IPMAC") == 0) {         /* dhetheri */
				info->flags &= ~F_IPMAC;             /* dhetheri */
			}                                            /* dhetheri */
			else {
				sprintf(pg_result, "Flag -:%s:- unknown\nAvailable flags, (prepend ! to un-set flag):\n%s",
					f,
					"IPSRC_RND, IPDST_RND, TXSIZE_RND, UDPSRC_RND, UDPDST_RND, MACSRC_RND, MACDST_RND, IPMAC\n");
			}
			sprintf(pg_result, "OK: flags=0x%x", info->flags);
			goto foundcmd;			
		}
		
		len = strlen("dst_min ");
		if (!strncmp(p, "dst_min ", 6)) {
			char f[IP_NAME_SZ];
			p += len;

			p += count_trail_chars(p, (int)(count - (p - kbuf)));

			strncpy_token(f, p, min(IP_NAME_SZ-1, (int)(count - (p - kbuf))));
			f[IP_NAME_SZ-1] = 0;
			
			p += strlen(f);
			if (strcmp(f, info->dst_min) != 0) {
				memset(info->dst_min, 0, sizeof(info->dst_min));
				strcpy(info->dst_min, f);
				info->daddr_min = in_aton(info->dst_min);
				info->cur_daddr = info->daddr_min;
			}
			if(debug)
				printk("pg: dst_min set to: %s\n", info->dst_min);
			sprintf(pg_result, "OK: dst_min=%s", info->dst_min);
			goto foundcmd;
		}
		
		len = strlen("dst_max ");
		if (!strncmp(p, "dst_max ", len)) {
			char f[IP_NAME_SZ];
			p += len;

			p += count_trail_chars(p, (int)(count - (p - kbuf)));

			strncpy_token(f, p, min(IP_NAME_SZ-1, (int)(count - (p - kbuf))));
			f[IP_NAME_SZ-1] = 0;
			
			p += strlen(f);
			if (strcmp(f, info->dst_max) != 0) {
				memset(info->dst_max, 0, sizeof(info->dst_max));
				strcpy(info->dst_max, f);
				info->daddr_max = in_aton(info->dst_max);
				info->cur_daddr = info->daddr_max;
			}
			if(debug)
				printk("pg: dst_max set to: %s\n", info->dst_max);
			sprintf(pg_result, "OK: dst_max=%s", info->dst_max);
			goto foundcmd;
		}

		len = strlen("src_min ");
		if (!strncmp(p, "src_min ", len)) {
			char f[IP_NAME_SZ];
			p += len;

			p += count_trail_chars(p, (int)(count - (p - kbuf)));

			strncpy_token(f, p, min(IP_NAME_SZ-1, (int)(count - (p - kbuf))));
			f[IP_NAME_SZ-1] = 0;
			
			p += strlen(f);
			if (strcmp(f, info->src_min) != 0) {
				memset(info->src_min, 0, sizeof(info->src_min));
				strcpy(info->src_min, f);
				info->saddr_min = in_aton(info->src_min);
				info->cur_saddr = info->saddr_min;
			}
			if(debug)
				printk("pg: src_min set to: %s\n", info->src_min);
			sprintf(pg_result, "OK: src_min=%s", info->src_min);
			goto foundcmd;
		}
		
		len = strlen("src_max ");
		if (!strncmp(p, "src_max ", len)) {
			char f[IP_NAME_SZ];
			p += len;

			p += count_trail_chars(p, (int)(count - (p - kbuf)));

			strncpy_token(f, p, min(IP_NAME_SZ-1, (int)(count - (p - kbuf))));
			f[IP_NAME_SZ-1] = 0;
			
			p += strlen(f);
			if (strcmp(f, info->src_max) != 0) {
				memset(info->src_max, 0, sizeof(info->src_max));
				strcpy(info->src_max, f);
				info->saddr_min = in_aton(info->src_max);
				info->cur_saddr = info->saddr_max;
			}
			if(debug)
				printk("pg: src_min set to: %s\n", info->src_min);
			sprintf(pg_result, "OK: src_max=%s", info->src_max);
			goto foundcmd;
		}

		len = strlen("dst_max ");
		if (!strncmp(p, "dst_mac ", len)) {
			char f[IP_NAME_SZ];
			unsigned char old_dmac[6];
			unsigned char *m = info->dst_mac;
			char* v = f;
			memcpy(old_dmac, info->dst_mac, 6);
			
			p += len;

			p += count_trail_chars(p, (int)(count - (p - kbuf)));

			strncpy_token(f, p, min(IP_NAME_SZ-1, (int)(count - (p - kbuf))));
			f[IP_NAME_SZ-1] = 0;
			
			p += strlen(f);

			for(*m = 0;*v && m < info->dst_mac + 6; v++) {
				if (*v >= '0' && *v <= '9') {
					*m *= 16;
					*m += *v - '0';
				}
				if (*v >= 'A' && *v <= 'F') {
					*m *= 16;
					*m += *v - 'A' + 10;
				}
				if (*v >= 'a' && *v <= 'f') {
					*m *= 16;
					*m += *v - 'a' + 10;
				}
				if (*v == ':') {
					m++;
					*m = 0;
				}
			}

			if (memcmp(old_dmac, info->dst_mac, 6) != 0) {
				/* Set up Dest MAC */
				memcpy(&(info->hh[0]), info->dst_mac, 6);
			}
                
			sprintf(pg_result, "OK: dstmac");
			goto foundcmd;
		}

		len = strlen("src_mac ");
		if (!strncmp(p, "src_mac ", len)) {
			char f[IP_NAME_SZ];
			char* v = f;
			unsigned char old_smac[6];
			unsigned char *m = info->src_mac;
			memcpy(old_smac, info->src_mac, 6);
			
			p += len;

			p += count_trail_chars(p, (int)(count - (p - kbuf)));

			strncpy_token(f, p, min(IP_NAME_SZ-1, (int)(count - (p - kbuf))));
			f[IP_NAME_SZ-1] = 0;
			
			p += strlen(f);

			for(*m = 0;*v && m < info->src_mac + 6; v++) {
				if (*v >= '0' && *v <= '9') {
					*m *= 16;
					*m += *v - '0';
				}
				if (*v >= 'A' && *v <= 'F') {
					*m *= 16;
					*m += *v - 'A' + 10;
				}
				if (*v >= 'a' && *v <= 'f') {
					*m *= 16;
					*m += *v - 'a' + 10;
				}
				if (*v == ':') {
					m++;
					*m = 0;
				}
			}

			if (memcmp(old_smac, info->src_mac, 6) != 0) {
				/* Default to the interface's mac if not explicitly set. */
				if ((!(info->flags & F_SET_SRCMAC)) && info->odev) {
					memcpy(&(info->hh[6]), info->odev->dev_addr, 6);
				}
				else {
					memcpy(&(info->hh[6]), info->src_mac, 6);
				}
			}
                
			sprintf(pg_result, "OK: srcmac");
			goto foundcmd;
		}
		
		len = strlen("clear_counters");
		if (!strncmp(p, "clear_counters", len)) {
			p += len;
			
			pg_clear_counters(info, 0);
			sprintf(pg_result, "OK: Clearing counters...\n");
			goto foundcmd;
		}
        
		if (!strncmp(p, "inject", 6) || !strncmp(p, "start", 5)) {

			if (strncmp(p, "start", 5) == 0) {
				p += 5;
			}
			else {
				p += 6;
			}
			
			if (info->do_run_run) {
				strcpy(info->result, "Already running...\n");
				sprintf(pg_result, "Already running...\n");
			}
			else {
				int rv;
				if ((rv = pg_start_interface(info->pg_thread, info)) >= 0) {
					strcpy(info->result, "Starting");
					sprintf(pg_result, "Starting");
				}
				else {
					sprintf(info->result, "Error starting: %i\n", rv);
					sprintf(pg_result, "Error starting: %i\n", rv);
				}
			}
			goto foundcmd;
		}

		printk("Pktgen:pg_if_write: Unknown command -:%20s:-\n", p);
		p++;
		
	foundcmd:
		if (debug & 0x1000) {
			printk("Command succeeded.\n");
		}
	}/* while */
	
	kfree(kbuf);
	return count;
}/* proc_pg_if_write */


static int proc_pg_ctrl_write(struct file *file, const char *user_buffer,
                              unsigned long count, void *data)
{
	char name[16];
        struct pktgen_thread_info* pg_thread = NULL;
	char* kbuf;
	char* p;
        int len;
	
	if (count < 1) {
		return -EINVAL;
	}

	kbuf = kmalloc(count, GFP_KERNEL);
	if (copy_from_user(kbuf, user_buffer, count)) {
		kfree(kbuf);
		return -EFAULT;
	}

	p = kbuf;
	
	while (p < (kbuf + count)) {
		p += count_trail_chars(p, (int)(count - (p - kbuf)));
  
		if (p >= (kbuf + count)) {
			break;
		}

		/* Read variable name */
		if (debug) {
			printk("pg_thread: %s,%lu\n", name, count);
		}

		len = strlen("stop ");
		if (!strncmp(p, "stop ", len)) {
			char f[32];
			p += len;

			p += count_trail_chars(p, (int)(count - (p - kbuf)));

			strncpy_token(f, p, min(31, (int)(count - (p - kbuf))));
			f[31] = 0;
			
			p += strlen(f);

			pg_thread = pg_find_thread(f);
			if (pg_thread) {
				printk("pktgen INFO: stopping thread: %s\n",
				       pg_thread->name);
				stop_pktgen_kthread(pg_thread);
			}

			goto foundcmd;
		}

		len = strlen("start ");
		if (!strncmp(p, "start ", len)) {
			char f[32];
			p += len;

			p += count_trail_chars(p, (int)(count - (p - kbuf)));

			strncpy_token(f, p, min(31, (int)(count - (p - kbuf))));
			f[31] = 0;
			
			p += strlen(f);

			pg_add_thread_info(f);
			goto foundcmd;
		}

		printk("Pktgen:pgctrl_write: Unknown command -:%20s:-\n", p);
		p++;
		
	foundcmd:
		if (debug & 0x1000) {
			printk("Command handled successfully.\n");
		}
		
	}/* while */

	kfree(kbuf);
	return count;
}/* proc_pg_ctrl_write */


static int proc_pg_thread_write(struct file *file, const char *user_buffer,
                                unsigned long count, void *data)
{
	char name[16];
        struct pktgen_thread_info* pg_thread = (struct pktgen_thread_info*)(data);
        char* pg_result = &(pg_thread->result[0]);
	char* kbuf;
	char* p;
        int len;
	
	if (count < 1) {
		sprintf(pg_result, "Wrong command format");
		return -EINVAL;
	}

	kbuf = kmalloc(count, GFP_KERNEL);
	if (copy_from_user(kbuf, user_buffer, count)) {
		kfree(kbuf);
		return -EFAULT;
	}

	p = kbuf;
	
	while (p < (kbuf + count)) {
		p += count_trail_chars(p, (int)(count - (p - kbuf)));

		if (p >= (kbuf + count)) {
			break;
		}
		
		/* Read variable name */
		if (debug) {
			printk("pg_thread: %s,%lu\n", name, count);
		}

		len = strlen("add_interface ");
		if (!strncmp(p, "add_interface ", len)) {
			char f[32];
			p += len;

			p += count_trail_chars(p, (int)(count - (p - kbuf)));

			strncpy_token(f, p, min(31, (int)(count - (p - kbuf))));
			f[31] = 0;
			
			p += strlen(f);
			
			pg_add_interface_info(pg_thread, f);
			goto foundcmd;
		}

		len = strlen("rem_interface ");
		if (!strncmp(p, "rem_interface ", len)) {
			struct pktgen_interface_info* info = NULL;
			char f[32];
			p += len;

			p += count_trail_chars(p, (int)(count - (p - kbuf)));

			strncpy_token(f, p, min(31, (int)(count - (p - kbuf))));
			f[31] = 0;
			
			p += strlen(f);
			
			info = pg_find_interface(pg_thread, f);
			if (info) {
				pg_rem_interface_info(pg_thread, info);
			}
			else {
				printk("ERROR:  Interface: %s is not found.\n", f);
			}
			goto foundcmd;
		}

		len = strlen("max_before_softirq ");
		if (!strncmp(p, "max_before_softirq", len)) {
			char f[32];
			p += len;

			p += count_trail_chars(p, (int)(count - (p - kbuf)));

			strncpy_token(f, p, min(31, (int)(count - (p - kbuf))));
			f[31] = 0;
			
			p += strlen(f);

			pg_thread->max_before_softirq = atoui(f);
			
			goto foundcmd;
		}

		printk("Pktgen:pg_thread_write: Unknown command -:%20s:-\n", p);
		p++;
		
	foundcmd:
		strcpy(pg_result, "ok");
	}

	kfree(kbuf);
	return count;
}/* proc_pg_thread_write */


int create_proc_dir(void)
{
        int     len;
        /*  does proc_dir already exists */
        len = strlen(PG_PROC_DIR);

        for (pg_proc_dir = proc_net->subdir; pg_proc_dir; pg_proc_dir=pg_proc_dir->next) {
                if ((pg_proc_dir->namelen == len) &&
                    (! memcmp(pg_proc_dir->name, PG_PROC_DIR, len))) {
                        break;
                }
        }
        
        if (!pg_proc_dir) {
                pg_proc_dir = create_proc_entry(PG_PROC_DIR, S_IFDIR, proc_net);
        }
        
        if (!pg_proc_dir) {
                return -ENODEV;
        }
        
        return 0;
}

int remove_proc_dir(void)
{
        remove_proc_entry(PG_PROC_DIR, proc_net);
        return 0;
}

static struct pktgen_interface_info* pg_find_interface(struct pktgen_thread_info* pg_thread,
                                                       const char* ifname) {
        struct pktgen_interface_info* rv = NULL;
        pg_lock(pg_thread, __FUNCTION__);

        if (pg_thread->cur_if && (strcmp(pg_thread->cur_if->ifname, ifname) == 0)) {
                rv = pg_thread->cur_if;
                goto found;
        }
        
        rv = pg_thread->running_if_infos;
        while (rv) {
                if (strcmp(rv->ifname, ifname) == 0) {
                        goto found;
                }
                rv = rv->next;
        }

        rv = pg_thread->stopped_if_infos;
        while (rv) {
                if (strcmp(rv->ifname, ifname) == 0) {
                        goto found;
                }
                rv = rv->next;
        }
 found:
        pg_unlock(pg_thread, __FUNCTION__);
        return rv;
}/* pg_find_interface */


static int pg_add_interface_info(struct pktgen_thread_info* pg_thread, const char* ifname) {
        struct pktgen_interface_info* i = pg_find_interface(pg_thread, ifname);
        if (!i) {
                i = kmalloc(sizeof(struct pktgen_interface_info), GFP_KERNEL);
                if (!i) {
                        return -ENOMEM;
                }
                memset(i, 0, sizeof(struct pktgen_interface_info));
                
                i->min_pkt_size = ETH_ZLEN;
                i->max_pkt_size = ETH_ZLEN;
                i->nfrags = 0;
                i->multiskb = pg_multiskb_d;
                i->peer_multiskb = 0;
                i->ipg = pg_ipg_d;
                i->count = pg_count_d;
                i->sofar = 0;
                i->hh[12] = 0x08; /* fill in protocol.  Rest is filled in later. */
                i->hh[13] = 0x00;
                i->udp_src_min = 9; /* sink NULL */
                i->udp_src_max = 9;
                i->udp_dst_min = 9;
                i->udp_dst_max = 9;
                i->rcv = pktgen_receive;

                strncpy(i->ifname, ifname, 31);
                sprintf(i->fname, "net/%s/%s", PG_PROC_DIR, ifname);

                if (! pg_setup_interface(i)) {
                        printk("ERROR: pg_setup_interface failed.\n");
                        kfree(i);
                        return -ENODEV;
                }

                i->proc_ent = create_proc_entry(i->fname, 0600, 0);
                if (!i->proc_ent) {
                        printk("pktgen: Error: cannot create %s procfs entry.\n", i->fname);
                        kfree(i);
                        return -EINVAL;
                }
                i->proc_ent->read_proc = proc_pg_if_read;
                i->proc_ent->write_proc = proc_pg_if_write;
                i->proc_ent->data = (void*)(i);
		i->proc_ent->owner = THIS_MODULE;

                return add_interface_to_thread(pg_thread, i);
        }
        else {
                printk("ERROR: interface already exists.\n");
                return -EBUSY;
        }
}/* pg_add_interface_info */


/* return the first !in_use thread structure */
static struct pktgen_thread_info* pg_gc_thread_list_helper(void) {
        struct pktgen_thread_info* rv = NULL;
        
        pg_lock_thread_list(__FUNCTION__);

        rv = pktgen_threads;
        while (rv) {
                if (!rv->in_use) {
                        break;
                }
                rv = rv->next;
        }
        pg_unlock_thread_list(__FUNCTION__);
        return rv;
}/* pg_find_thread */

static void pg_gc_thread_list(void) {
        struct pktgen_thread_info* t = NULL;
        struct pktgen_thread_info* w = NULL;

        while ((t = pg_gc_thread_list_helper())) {
                pg_lock_thread_list(__FUNCTION__);
                if (pktgen_threads == t) {
                        pktgen_threads = t->next;
                        kfree(t);
                }
                else {
                        w = pktgen_threads;
                        while (w) {
                                if (w->next == t) {
                                        w->next = t->next;
                                        t->next = NULL;
                                        kfree(t);
                                        break;
                                }
                                w = w->next;
                        }
                }
                pg_unlock_thread_list(__FUNCTION__);
        }
}/* pg_gc_thread_list */        


static struct pktgen_thread_info* pg_find_thread(const char* name) {
        struct pktgen_thread_info* rv = NULL;

        pg_gc_thread_list();
        
        pg_lock_thread_list(__FUNCTION__);

        rv = pktgen_threads;
        while (rv) {
                if (strcmp(rv->name, name) == 0) {
                        break;
                }
                rv = rv->next;
        }
        pg_unlock_thread_list(__FUNCTION__);
        return rv;
}/* pg_find_thread */


static int pg_add_thread_info(const char* name) {
        struct pktgen_thread_info* pg_thread = NULL;

        if (strlen(name) > 31) {
                printk("pktgen ERROR:  Thread name cannot be more than 31 characters.\n");
                return -EINVAL;
        }
        
        if (pg_find_thread(name)) {
                printk("pktgen ERROR: Thread: %s already exists\n", name);
                return -EINVAL;
        }

        pg_thread = (struct pktgen_thread_info*)(kmalloc(sizeof(struct pktgen_thread_info), GFP_KERNEL));
        if (!pg_thread) {
                printk("pktgen: ERROR: out of memory, can't create new thread.\n");
                return -ENOMEM;
        }

        memset(pg_thread, 0, sizeof(struct pktgen_thread_info));
        strcpy(pg_thread->name, name);
        spin_lock_init(&(pg_thread->pg_threadlock));
        pg_thread->in_use = 1;
        pg_thread->max_before_softirq = 10000000;
        
        sprintf(pg_thread->fname, "net/%s/%s", PG_PROC_DIR, pg_thread->name);
        pg_thread->proc_ent = create_proc_entry(pg_thread->fname, 0600, 0);
        if (!pg_thread->proc_ent) {
                printk("pktgen: Error: cannot create %s procfs entry.\n", pg_thread->fname);
                kfree(pg_thread);
                return -EINVAL;
        }
        pg_thread->proc_ent->read_proc = proc_pg_thread_read;
        pg_thread->proc_ent->write_proc = proc_pg_thread_write;
        pg_thread->proc_ent->data = (void*)(pg_thread);
	pg_thread->proc_ent->owner = THIS_MODULE;

        pg_thread->next = pktgen_threads;
        pktgen_threads = pg_thread;

        /* Start the thread running */
        start_pktgen_kthread(pg_thread);
        
        return 0;
}/* pg_add_thread_info */


/* interface_info must be stopped and on the pg_thread stopped list
 */
static int pg_rem_interface_info(struct pktgen_thread_info* pg_thread,
                                 struct pktgen_interface_info* info) {
        if (info->do_run_run) {
                printk("WARNING: trying to remove a running interface, stopping it now.\n");
                pg_stop_interface(pg_thread, info);
        }
        
        /* Diss-associate from the interface */
        check_remove_device(info);
        
        /* Clean up proc file system */
        if (strlen(info->fname)) {
                remove_proc_entry(info->fname, NULL);
        }
        
        pg_lock(pg_thread, __FUNCTION__);
        {
                /* Remove from the stopped list */
                struct pktgen_interface_info* p = pg_thread->stopped_if_infos;
                if (p == info) {
                        pg_thread->stopped_if_infos = p->next;
                        p->next = NULL;
                }
                else {
                        while (p) {
                                if (p->next == info) {
                                        p->next = p->next->next;
                                        info->next = NULL;
                                        break;
                                }
                                p = p->next;
                        }
                }
                
                info->pg_thread = NULL;
        }
        pg_unlock(pg_thread, __FUNCTION__);
        
        return 0;
}/* pg_rem_interface_info */


static int __init pg_init(void) {
        int i;
	printk(version);

        /* Initialize our global variables */
        for (i = 0; i<PG_INFO_HASH_MAX; i++) {
                pg_info_hash[i] = NULL;
        }
        module_fname[0] = 0;
        
        if (handle_pktgen_hook) {
                printk("pktgen: ERROR: pktgen is already loaded it seems..\n");
                /* Already loaded */
                return -EEXIST;
        }

	cycles_calibrate();
	if (pg_cycles_per_us == 0) {
		printk("pktgen: Error: your machine does not have working cycle counter.\n");
		return -EINVAL;
	}

	create_proc_dir();

        sprintf(module_fname, "net/%s/pgctrl", PG_PROC_DIR);
        module_proc_ent = create_proc_entry(module_fname, 0600, 0);
        if (!module_proc_ent) {
                printk("pktgen: Error: cannot create %s procfs entry.\n", module_fname);
                return -EINVAL;
        }
        module_proc_ent->read_proc = proc_pg_ctrl_read;
        module_proc_ent->write_proc = proc_pg_ctrl_write;
        module_proc_ent->proc_fops = &(pktgen_fops); /* IOCTL hook */
        module_proc_ent->data = NULL;
	module_proc_ent->owner = THIS_MODULE;

	/* Register us to receive netdevice events */
	register_netdevice_notifier(&pktgen_notifier_block);
        
        /* Register handler */
        handle_pktgen_hook = pktgen_receive;

        for (i = 0; i<pg_thread_count; i++) {
                char buf[30];
                sprintf(buf, "kpktgend_%i", i);
                pg_add_thread_info(buf);
        }
                
        
        return 0;        
}/* pg_init */


static void __exit pg_cleanup(void)
{
        /* Un-register handler */
        handle_pktgen_hook = NULL;

        /* Stop all interfaces & threads */        
        while (pktgen_threads) {
                stop_pktgen_kthread(pktgen_threads);
        }
        
        /* Un-register us from receiving netdevice events */
	unregister_netdevice_notifier(&pktgen_notifier_block);

        /* Clean up proc file system */
        remove_proc_entry(module_fname, NULL);
        
	remove_proc_dir();

}


module_init(pg_init);
module_exit(pg_cleanup);

MODULE_AUTHOR("Robert Olsson <robert.olsson@its.uu.se, Ben Greear<greearb@candelatech.com>");
MODULE_DESCRIPTION("Packet Generator tool");
MODULE_LICENSE("GPL");
MODULE_PARM(pg_count_d, "i");
MODULE_PARM(pg_ipg_d, "i");
MODULE_PARM(pg_thread_count, "i");
MODULE_PARM(pg_multiskb_d, "i");
MODULE_PARM(debug, "i");

--------------020306080600040204070804
Content-Type: text/plain;
 name="pktgen.h"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="pktgen.h"

/* -*-linux-c-*-
 * $Id: pg_patch.txt,v 1.2 2002/07/07 07:23:50 greear Exp $
 * pktgen.c: Packet Generator for performance evaluation.
 *
 * See pktgen.c for details of changes, etc.
*/


#ifndef PKTGEN_H_INCLUDE_KERNEL__
#define PKTGEN_H_INCLUDE_KERNEL__


/* The buckets are exponential in 'width' */
#define LAT_BUCKETS_MAX 32

#define IP_NAME_SZ 32

#define PG_MAX_ACCUM_DELAY_NS 1000000 /* one ms */

/* Keep information per interface */
struct pktgen_interface_info {
        char ifname[32];
        
        /* Parameters */

        /* If min != max, then we will either do a linear iteration, or
         * we will do a random selection from within the range.
         */
        __u32 flags;     

#define F_IPSRC_RND   (1<<0)  /* IP-Src Random  */
#define F_IPDST_RND   (1<<1)  /* IP-Dst Random  */
#define F_UDPSRC_RND  (1<<2)  /* UDP-Src Random */
#define F_UDPDST_RND  (1<<3)  /* UDP-Dst Random */
#define F_MACSRC_RND  (1<<4)  /* MAC-Src Random */
#define F_MACDST_RND  (1<<5)  /* MAC-Dst Random */
#define F_SET_SRCMAC  (1<<6)  /* Specify-Src-Mac 
				 (default is to use Interface's MAC Addr) */
#define F_SET_SRCIP   (1<<7)  /*  Specify-Src-IP
				  (default is to use Interface's IP Addr) */ 
#define F_TXSIZE_RND  (1<<8)  /* Transmit size is random */
#define F_IPMAC       (1<<9)  /* MAC address = 00:00:IP address (dhetheri) */

        int min_pkt_size;    /* = ETH_ZLEN; */
        int max_pkt_size;    /* = ETH_ZLEN; */
        int nfrags;
        __u32 ipg;    /* Default Interpacket gap in nsec */
        __u64 count;  /* Default No packets to send */
        __u64 sofar;  /* How many pkts we've sent so far */
        __u64 tx_bytes; /* How many bytes we've transmitted */
        __u64 errors;    /* Errors when trying to transmit, pkts will be re-sent */

        /* runtime counters relating to multiskb */
        __u64 next_tx_ns;          /* timestamp of when to tx next, in nano-seconds */
        __u64 fp;
        __u32 fp_tmp;
	int last_ok;           /* Was last skb sent? 
	                        * Or a failed transmit of some sort?  This will keep
                                * sequence numbers in order, for example.
                                */
        /* Fields relating to receiving pkts */
        __u32 last_seq_rcvd;
        __u64 ooo_rcvd;  /* out-of-order packets received */
        __u64 pkts_rcvd; /* packets received */
        __u64 dup_rcvd;  /* duplicate packets received */
        __u64 bytes_rcvd; /* total bytes received, as obtained from the skb */
        __u64 seq_gap_rcvd; /* how many gaps we received.  This coorelates to
                             * dropped pkts, except perhaps in cases where we also
                             * have re-ordered pkts.  In that case, you have to tie-break
                             * by looking at send v/s received pkt totals for the interfaces
                             * involved.
                             */
        __u64 non_pg_pkts_rcvd; /* Count how many non-pktgen skb's we are sent to check. */
        __u64 dup_since_incr; /* How many dumplicates since the last seq number increment,
                               * used to detect gaps when multiskb > 1
                               */
        int avg_latency; /* in micro-seconds */
        int min_latency;
        int max_latency;
        __u64 latency_bkts[LAT_BUCKETS_MAX];
        __u64 pkts_rcvd_since_clear; /* with regard to clearing/resetting the latency logic */
        
        __u64 started_at; /* micro-seconds */
        __u64 stopped_at; /* micro-seconds */
        __u64 idle_acc;
        __u32 seq_num;
        
        int multiskb; /* Use multiple SKBs during packet gen.  If this number
                          * is greater than 1, then that many coppies of the same
                          * packet will be sent before a new packet is allocated.
                          * For instance, if you want to send 1024 identical packets
                          * before creating a new packet, set multiskb to 1024.
                          */
        int peer_multiskb; /* Helps detect drops when multiskb > 1 on peer */
        int do_run_run;  /* if this changes to false, the test will stop */
        
        char dst_min[IP_NAME_SZ]; /* IP, ie 1.2.3.4 */
        char dst_max[IP_NAME_SZ]; /* IP, ie 1.2.3.4 */
        char src_min[IP_NAME_SZ]; /* IP, ie 1.2.3.4 */
        char src_max[IP_NAME_SZ]; /* IP, ie 1.2.3.4 */

        /* If we're doing ranges, random or incremental, then this
         * defines the min/max for those ranges.
         */
        __u32 saddr_min; /* inclusive, source IP address */
        __u32 saddr_max; /* exclusive, source IP address */
        __u32 daddr_min; /* inclusive, dest IP address */
        __u32 daddr_max; /* exclusive, dest IP address */

        __u16 udp_src_min; /* inclusive, source UDP port */
        __u16 udp_src_max; /* exclusive, source UDP port */
        __u16 udp_dst_min; /* inclusive, dest UDP port */
        __u16 udp_dst_max; /* exclusive, dest UDP port */

        __u32 src_mac_count; /* How many MACs to iterate through */
        __u32 dst_mac_count; /* How many MACs to iterate through */
        
        unsigned char dst_mac[6];
        unsigned char src_mac[6];
        
        __u32 cur_dst_mac_offset;
        __u32 cur_src_mac_offset;
        __u32 cur_saddr;
        __u32 cur_daddr;
        __u16 cur_udp_dst;
        __u16 cur_udp_src;
        __u32 cur_pkt_size;
        
        __u8 hh[14];
        /* = { 
           0x00, 0x80, 0xC8, 0x79, 0xB3, 0xCB, 
           
           We fill in SRC address later
           0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
           0x08, 0x00
           };
        */
        __u16 prot; /* pad out the hh struct to an even 16 bytes, prot can
		     * be used to specify an IP protocol too (default is 0,
		     * which implies UDP
		     */
        char result[512];
        /* proc file names */
        char fname[80];

        /* End of stuff that user-space should care about */
	long long accum_delay_ns;  /* Used to sleep small amounts on average, w/out spinning */
	__u32 sleeps;              /* How many times did it sleep on the wait queue? */
	__u32 queue_stopped;       /* How many times was our network device queue stopped? */
	__u64 nanodelays;          /* How many times has the nano-delay method been called? */
        struct sk_buff* skb; /* skb we are to transmit next, mainly used for when we
                              * are transmitting the same one multiple times
                              */
        struct pktgen_thread_info* pg_thread; /* the owner */

        struct pktgen_interface_info* next_hash; /* Used for chaining in the hash buckets */
        struct pktgen_interface_info* next; /* Used for chaining in the thread's run-queue */

        

        struct net_device* odev; /* The out-going device.  Note that the device should
                                  * have it's pg_info pointer pointing back to this
                                  * device.  This will be set when the user specifies
                                  * the out-going device name (not when the inject is
                                  * started as it used to do.)
                                  */
        
        struct proc_dir_entry *proc_ent;
        
        int (*rcv) (struct sk_buff *skb);
}; /* pktgen_interface_info */


struct pktgen_hdr {
        __u32 pgh_magic;
        __u32 seq_num;
        struct timeval timestamp;
};


/* Define some IOCTLs.  Just picking random numbers, basically. */
#define GET_PKTGEN_INTERFACE_INFO 0x7450

struct pktgen_ioctl_info {
        char thread_name[32];
        char interface_name[32];
        struct pktgen_interface_info info;
};


struct pktgen_thread_info {
        struct pktgen_interface_info* running_if_infos; /* list of running interfaces, current will
                                                         * not be in this list.
                                                         */
        struct pktgen_interface_info* stopped_if_infos; /* list of stopped interfaces. */
        struct pktgen_interface_info* cur_if;           /* Current (running) interface we are servicing in
                                                         * the main thread loop.
                                                         */

        int running_if_sz;
        struct pktgen_thread_info* next;
        char name[32];
        char fname[128]; /* name of proc file */
        struct proc_dir_entry *proc_ent;
        char result[512];
        u32 max_before_softirq; /* We'll call do_softirq to prevent starvation. */
        
        spinlock_t pg_threadlock;
        
        /* Linux task structure of thread */
        struct task_struct *thread;
        
        /* Task queue need to launch thread */
        struct work_struct wq;
        
        /* function to be started as thread */
        void (*function) (struct pktgen_thread_info *kthread);
        
        /* semaphore needed on start and creation of thread. */
        struct semaphore startstop_sem;

        /* public data */

        /* queue thread is waiting on. Gets initialized by
           init_kthread, can be used by thread itself.
        */
        wait_queue_head_t queue;
        
        /* flag to tell thread whether to die or not.
           When the thread receives a signal, it must check
           the value of terminate and call exit_kthread and terminate
           if set.
        */
        int terminate;

        int in_use; /* if 0, then we can delete or re-use this struct */

	u32 queues_stopped; /* How many times were all queues blocked */
	char sleeping; /* Are we sleeping or not */
	char pad[3];
	
        /* additional data to pass to kernel thread */
        void *arg;
};/* struct pktgen_thread_info */

/* Defined in dev.c */
extern int (*handle_pktgen_hook)(struct sk_buff *skb);

/* Returns < 0 if the skb is not a pktgen buffer. */
int pktgen_receive(struct sk_buff* skb);


#endif

--------------020306080600040204070804--
