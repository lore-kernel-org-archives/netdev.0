From: Ben Greear <greearb@candelatech.com>
Subject: Re: RFC:  Redirect-Device
Date: Thu, 31 Mar 2005 13:45:38 -0800
Message-ID: <424C6F82.7030609@candelatech.com>
References: <424C6089.1080507@candelatech.com> <20050331130512.7e4b8bc0@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050008060104060607060606"
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20050331130512.7e4b8bc0@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050008060104060607060606
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Stephen Hemminger wrote:
> You need to cleanup the style.  
> 	Lots of dead commented out code.

Ok, think I got rid of most of the dead code and commented code.  I left
in the commented printks in case I need to do more debugging.

> 	Encapsulating locking in macros is ugly and makes maintenance a nuisance.

Changed to just support spin locks and got rid of the macros.

>        CamelCaps

No idea what you mean here.  Do you want JavaStyleCapitalization?

>         Use prdebug instead of DEBUG

Just changed the DEBUG to printk and commented them out.

> 	RCU instead of rwlock's or just use spinlock

Used spin-lock.  The rwlock code was never tested or enabled anyway.

> 	Adding new /proc interfaces is frowned on

I want to keep this.  I want quick script access to configure the devices so I don't
have to maintain a rddconfig c program that uses ioctls.

> 	Adding new ioctl's are very frowned on

Bummer.  I want these as well, makes programatic reading of the information
much easier than trying to parse some proc file.  I will look into what it
takes to make them compat with 64-bit as DaveM suggested.

> 	global namespace issues with toupper et a..

Purged it, it was dead code.

Please see if the attached code looks better to you.

Thanks!
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com


--------------050008060104060607060606
Content-Type: text/plain;
 name="redirdev.c"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="redirdev.c"

/* -*- linux-c -*-
#######################################################################
#
# (C) Copyright 2005
# Ben Greear <greearb@candelatech.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 2 of
# the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston,
# MA 02111-1307 USA
#######################################################################
# Notes:
# 
# This file implements the Redirect-net-device module.  A pair of
# redir devices linked to each other act like two ethernet interfaces
# connected with a cross-over cable.
#
# This provides an IOCTL interface which allows you to
# It uses an IOCTL interface which allows you to
#
# 1. create redirect device
# 2. delete redirect device
# 
#######################################################################
*/

#include <linux/config.h>
#include <linux/init.h>
#include <linux/module.h>
#include <linux/sched.h>
#include <linux/kernel.h> 
#include <linux/fs.h>	  
#include <linux/errno.h>  
#include <linux/delay.h>  
#include <linux/slab.h>
#include <linux/mm.h>
#include <linux/ioport.h>
#include <linux/interrupt.h>
#include <linux/poll.h>
#include <linux/types.h>
#include <linux/string.h>
#include <linux/if_redirdev.h>
#include <linux/if_arp.h>
#include <linux/etherdevice.h>
#include <net/arp.h>
#include <linux/rtnetlink.h>
#include <linux/notifier.h>

#include <asm/io.h>
#include <asm/irq.h>
#include <asm/uaccess.h>
#include <asm/semaphore.h>
#include <net/dst.h>

#ifdef CONFIG_PROC_FS
#include <linux/proc_fs.h>
#define RDD_PROC_DIR "redirdev"
#define RDD_PROC_CFG "config"
static struct proc_dir_entry *rdd_proc_dir;
static struct proc_dir_entry *rdd_proc_cfg;
#endif

#include "redirdev.h"

/* Defined in socket.c */
void redirdev_ioctl_set(int (*hook)(void*));
static int redirdev_device_event(struct notifier_block *unused,
				 unsigned long event, void *ptr);

static struct notifier_block redirdev_notifier_block = {
	.notifier_call = redirdev_device_event,
};

/*********************************************************/
/*			defines				 */
/*********************************************************/

/*  Must hold this lock to make any changes to the Redirect-Device structures.
 */
static spinlock_t rdd_cfg_lock = SPIN_LOCK_UNLOCKED;


/*********************************************************/
/*		       file scope variables		 */
/*********************************************************/

static struct redirdev* rdds = NULL;

static atomic_t rdd_dev_counter;

static int debug_lvl = 0;


/*********************************************************/
/*		   forward declarations			 */
/*********************************************************/

#ifdef RDD_CONFIG_PROC_FS
static int read_rdd_glbl(char *page, char **start, off_t off,
			 int count, int *eof, void *data);
static int write_rdd_glbl(struct file *file, const char *buffer,
			  unsigned long count, void *data);
#endif



/*********************************************************/
/*		   function definitions			 */
/*********************************************************/


#define iswhitespace(x)\
	((x) == ' ' || (x) == '\n' || (x) == '\r' || (x) == '\r' )

#define skip_whitespace(x) 	{ while (iswhitespace(*x)) (x)++; }

static int copy_next_word(char *dst, char *src, int len) {
	char *p;
	for (p=src; p < src + len ; p++) {
		if ( iswhitespace(*p))
			break;
		*dst++ = *p;
	}
	return p - src;
}

/*  Grab the RDD lock before calling this method. */
struct redirdev* rdd_find_dev_by_name(const char* ifname) {
	struct redirdev* d;
	//printk("finding port for underlying ifname: %s\n", ifname);
	for (d = rdds; d; d = d->next) {
		//printk("Testing port: %p name: %s\n", port, port->dev->name);
		if (strcmp(d->dev->name, ifname) == 0) {
			break;
		}
	}
	//printk("done finding port: %p\n", port);
	return d;
}

/*  Grab the RDD lock before calling this method. */
struct redirdev* rdd_find_dev_by_txdev_name(const char* ifname) {
	struct redirdev* d;
	for (d = rdds; d; d = d->next) {
		if (d->tx_dev) {
			if (strcmp(d->tx_dev->name, ifname) == 0) {
				break;
			}
		}
	}
	return d;
}	 


static struct net_device_stats *redirdev_get_stats(struct net_device *dev)
{
	struct redirdev* rdd = dev->priv;

	return &rdd->statistics;
}

/** Bump our tx counters and then act as if this was received from
 * the network on the tx_dev device.  Since we don't do any CSUM
 * activity in this driver, make sure SKB as marked as not checksummed
 * yet.
 */
static int redirdev_xmit(struct sk_buff *iskb, struct net_device *dev) {
	struct redirdev* rdd = dev->priv;
	struct net_device_stats* txs;
	
	if (unlikely(!rdd->tx_dev)) {
		printk("ERROR:  tx_dev null in redirdev_xmit.\n");
		kfree_skb(iskb);
		rdd->statistics.tx_errors++;
		return 0;
	}

	//printk("%s: dev: %s tx_dev: %s\n",
	//       __PRETTY_FUNCTION__, dev->name, rdd->tx_dev->name);

	if (netif_running(rdd->tx_dev)) {

		/* We need to free the old skb so that the socket
		 * account works correctly.  We'll make a copy and
		 * then forward that to the other device.
		 */

		struct sk_buff* skb = skb_clone(iskb, GFP_ATOMIC);

		kfree_skb(iskb); //Let the sending socket reclaim it's memory
		
		if (!skb) {
			rdd->statistics.tx_dropped++;
		}
		else {
			int rv;
			struct ethhdr *eth;
			skb->dev = rdd->tx_dev;

			/* We didn't calculate the csum, so mark as such. */
			skb->ip_summed = CHECKSUM_UNNECESSARY;//NONE;
	
			rdd->statistics.tx_packets++;
			rdd->statistics.tx_bytes += skb->len;

			txs = rdd->tx_dev->get_stats(rdd->tx_dev);
			txs->rx_packets++;
			txs->rx_bytes += skb->len;

			/* Call this on the receiving net device.  This assumes
			 * that all devices are ethernet or ethernet-like.  Valid
			 * for now.  TODO:  Generalize tx_dev ??
			 */
			skb->pkt_type = PACKET_HOST; //Reset this to default.

			skb->protocol = eth_type_trans(skb, skb->dev);

			eth = eth_hdr(skb);
			
			if (skb->dst) {
				dst_release(skb->dst);
				skb->dst = NULL;
			}
			
			//printk("skb->protocol: %x  pkt_type: %u\n",
			//       (unsigned int)(skb->protocol),
			//       (unsigned int)(skb->pkt_type));
			rv = netif_rx(skb);
			if (rv != NET_RX_SUCCESS) {
				// TODO:  Remove
				//printk("netif_rx rv: %i\n", (int)(rv));
			}
			rdd->tx_dev->last_rx = jiffies;
			rdd->dev->trans_start = jiffies;
		}
	}
	else {
		/* Chunk the packet and log some errors */
		rdd->statistics.tx_errors++;
		kfree_skb(iskb);
	}
	return 0;
}/* redir xmit */

static int redirdev_open(struct net_device *dev) {
	struct redirdev* rdd = dev->priv;
	if (!rdd->tx_dev) {
		rdd->tx_dev = dev_get_by_name(rdd->tx_dev_name);
	}
	if (!rdd->tx_dev) {
		printk("redir: Could not start device %s because tx_dev: %s is not found.\n",
		       dev->name, rdd->tx_dev_name);
		return -ENODEV;
	}
	else {
		printk("redirdev:  Starting device: %s\n", dev->name);
		netif_start_queue(dev);
		return 0;
	}
}

//static void redirdev_set_multicast_list(struct net_device *dev) {
	/* TODO ??? */
//}

static int redirdev_stop(struct net_device *dev) {
	struct redirdev* rdd = dev->priv;
	printk("redirdev:  stopping device: %s\n", dev->name);
	netif_stop_queue(dev);
	if (rdd->tx_dev) {
		struct net_device* tmp = rdd->tx_dev;
		rdd->tx_dev = NULL;
		printk("  releasing reference to dev: %s\n", tmp->name);
		dev_put(tmp);
	}
	printk("   done stopping %s\n", dev->name);
	return 0;
}


void redirdev_dev_destructor(struct net_device *dev) {
	atomic_dec(&rdd_dev_counter);
	if (dev->priv) {
		//printk("dst: %s", dev->name);
		kfree(dev->priv);
		dev->priv = NULL;
	}
	else {
		//printk("dst2: %s", dev->name);
	}
}

int redirdev_change_mtu(struct net_device *dev, int new_mtu) {
	dev->mtu = new_mtu;
	return 0;
}

static int redirdev_create(const char* newifname,
			   const char* txdevname) {
	struct redirdev *rdd = NULL;
	struct net_device* td = NULL;
	struct net_device* nnd = NULL;
	struct net_device* txd = NULL;
	unsigned long flags;
	int rv;

	if ((strlen(txdevname) == 0) ||
	    (strlen(newifname) == 0)) {
		printk("redirdev: ERROR:  Must specify ifname and txifname"
		       " when creating redirect devices!\n");
		rv = -ENODEV;
		goto out;
	}	   

	printk("redirdev: creating interface: -:%s:- with tx_dev: -:%s:-\n",
	       newifname, txdevname);
	

	//printk("malloc ");
	if ((rdd = kmalloc(sizeof(*rdd), GFP_KERNEL)) == NULL) {
		//printk("redirdev: kmalloc failure\n");
		rv = -ENOMEM;
		goto outfree;
	}
	memset(rdd, 0, sizeof(*rdd));

	//printk("4 ");
	if ((nnd = kmalloc(sizeof(struct net_device), GFP_KERNEL)) == NULL) {
		//printk("redirdev: kmalloc net_device failure\n");
		rv = -ENOMEM;
		goto outfree;
	}
	memset(nnd, 0, sizeof(struct net_device));	

	if ((td = dev_get_by_name(newifname)) != NULL) {
		//printk("redirdev: device by that name already exists\n");
		rv = -EEXIST;
		goto outfree;
	}

	/* If it's not here yet, no problem, will associate later */
	txd = dev_get_by_name(txdevname);
	strncpy(rdd->tx_dev_name, txdevname, IFNAMSIZ);

	//printk("4 ");
	rdd->dev = nnd;
	
	//printk("5 ");
	strncpy(rdd->dev->name, newifname, IFNAMSIZ-1);
	rdd->dev->name[IFNAMSIZ-1] = 0; //Ensure null termination.
	ether_setup(rdd->dev);
	
	dev_hold(rdd->dev); /* RDD code holds reference */
	
	rdd->dev->priv = rdd;
	rdd->tx_dev = txd;
	
	//printk("6 ");
	rdd->dev->get_stats = redirdev_get_stats;
	rdd->dev->hard_start_xmit = redirdev_xmit;
	rdd->dev->change_mtu = redirdev_change_mtu;
	rdd->dev->open = redirdev_open;
	rdd->dev->stop = redirdev_stop;
	rdd->dev->destructor = redirdev_dev_destructor;

	// Defaults are fine for these
	//rdd->dev->rebuild_header = redirdev_dev_rebuild_header;
	//rdd->dev->set_multicast_list = redirdev_set_multicast_list;
	//rdd->dev->hard_header = redirdev_hard_header;	

	rdd->dev->dev_addr[0] = 0;
	rdd->dev->dev_addr[1] = net_random();
	rdd->dev->dev_addr[2] = net_random();
	rdd->dev->dev_addr[3] = net_random();
	rdd->dev->dev_addr[4] = net_random();
	rdd->dev->dev_addr[5] = net_random();

	/* No qdisc for us */
	rdd->dev->qdisc = NULL;
	rdd->dev->tx_queue_len = 0;
	
	//printk("redirdev: created redirect-device %p\n", vlan);

	/* link to list */
	//printk("8 ");
	spin_lock_irqsave(&rdd_cfg_lock, flags);
	rdd->next = rdds;
	rdds = rdd;
	spin_unlock_irqrestore(&rdd_cfg_lock, flags);

	//printk("End of redirdev_create, registering rdd->dev: %p (%s)\n",
	//       rdd->dev, rdd->dev->name);
	
	register_netdev(rdd->dev);

	//printk("End of mac_vlan create2\n");

	atomic_inc(&rdd_dev_counter);
	//printk("9\n");
	rv = 0;
	goto out;

	/* Error case, clean up vlan memory */
 outfree:
	if (rdd) {
		kfree(rdd);
	}
	if (nnd) {
		kfree(nnd);
	}
	if (td) {
		dev_put(td);
	}
	if (txd) {
		dev_put(txd);
	}
 out:
	return rv;
} /* redirdev_create */

static int redirdev_device_event(struct notifier_block *unused,
				 unsigned long event, void *ptr) {
	struct net_device* dev = ptr;
	struct redirdev* rdd;
	unsigned long flags;
	
	spin_lock_irqsave(&rdd_cfg_lock, flags);
	rdd = rdd_find_dev_by_txdev_name(dev->name);
	spin_unlock_irqrestore(&rdd_cfg_lock, flags);

	if (!rdd) {
		//printk("redirdev: Ignoring event: %lu for device: %s\n",
		//       event, dev->name);
		goto out;
	}


	/* It is OK that we do not hold the group lock right now,
	 * as we run under the RTNL lock.
	 */

	switch (event) {
	case NETDEV_CHANGE:
	case NETDEV_UP:
	case NETDEV_DOWN:
		//printk("redirdev: Ignoring change/up/down for device: %s\n",
		//       dev->name);
		/* Ignore for now */
		break;

	case NETDEV_UNREGISTER:
		/* Stop the redir-dev too */
		printk("Device: %s is going away, closing redir-device: %s too.\n",
		       dev->name, rdd->dev->name);
		dev_close(rdd->dev);
		break;

	};

out:
	return NOTIFY_DONE;
}

/* Has locking internally */
int redirdev_cleanup(const char* ifname, int force) {
	struct redirdev* d; //walker
	struct redirdev* prev = NULL;
	unsigned long flags;
	int rv;
	
	//printk(__FUNCTION__"(%p)\n",vlan);
	//printk("rdd_cln: %s", ifname);

	spin_lock_irqsave(&rdd_cfg_lock, flags);
	for (d = rdds; d; d = d->next) {
		if (strcmp(d->dev->name, ifname) == 0) {			
			if ((d->dev->flags & IFF_UP) && (!force)) {
				rv = -EBUSY;
				goto unlockout;
			}

			// Un-link from the list.
			if (prev) {
				prev->next = d->next;
				d->next = NULL;
			}
			else {
				// This means we're first in line
				rdds = d->next;
				d->next = NULL;
			}

			break;
		}
		prev = d;
	}

	spin_unlock_irqrestore(&rdd_cfg_lock, flags);

	if (d) {
		if (d->dev->flags & IFF_UP) {
			BUG_ON(!force);

			rtnl_lock();
			dev_close(d->dev);
			rtnl_unlock();
		}

		if (d->tx_dev) {
			dev_put(d->tx_dev);
		}
		
		dev_put(d->dev);
		unregister_netdev(d->dev);
		rv = 0;
	}
	else {
		rv = -ENODEV;
	}
	goto out;

 unlockout:
	spin_unlock_irqrestore(&rdd_cfg_lock, flags);

 out:
	return rv;	
} /* redirdev cleanup */


static int redirdev_ioctl_deviceless_stub(void* arg) {
	int err = 0;
	struct redirdev_ioctl req;
	unsigned long flags;
	
	if (!capable(CAP_NET_ADMIN))
		return -EPERM;

	if (copy_from_user(&req, arg, sizeof(req)))
		return -EFAULT;

	switch (req.cmd) {
	case REDIRDEV_ADD: {
		/* 
		 * create a new redirect device
		 */
		req.txifname[IFNAMSIZ-1] = '\0';
		req.ifname[IFNAMSIZ-1] = '\0';
		printk("Creating redir via ioctl, ifname: %s  txifname: %s\n",
		       req.ifname, req.txifname);

		/* Has internal locking. */
		err = redirdev_create(req.ifname, req.txifname);
		break;
	}
	case REDIRDEV_DEL: {
		/*
		 * destroy a redirect device
		 */
		req.ifname[IFNAMSIZ-1] = '\0';

		/* Has internal locking */
		err = redirdev_cleanup(req.ifname, 0);
		break;
	}

	case REDIRDEV_IS_REDIRDEV: {
		/* 
		 * Give user-space a chance of determining if we are a redirect-device
		 * or not.
		 *  (If the IOCTL fails, we are not, otherwise we are.)
		 */
		struct redirdev* rdd;
		req.ifname[IFNAMSIZ-1] = '\0';
	    
		spin_lock_irqsave(&rdd_cfg_lock, flags);
		/* find the port in question */
		rdd = rdd_find_dev_by_name(req.ifname);
		spin_unlock_irqrestore(&rdd_cfg_lock, flags);

		if (!rdd) {
			/* printk("device: %s is NOT a REDIR device\n", ifname); */
			err = -ENODEV;
		}
		else {
			/* printk("device: %s IS a MAC-VLAN\n", ifname); */
			err = 0;
		}
		break;
	}
	case REDIRDEV_GET_BY_IDX: {
		/* 
		 * get the nth redirdev name
		 */
		struct redirdev *rdd;
		int n = req.ifidx;

		spin_lock_irqsave(&rdd_cfg_lock, flags);
		/* find the port in question */
		for (rdd = rdds; rdd && n; rdd = rdd->next, n--);
		if (!rdd) {
			err = -ENODEV;
			spin_unlock_irqrestore(&rdd_cfg_lock, flags);
		}
		else {
			memcpy(req.ifname, rdd->dev->name, IFNAMSIZ);
			memcpy(req.txifname, rdd->tx_dev_name, IFNAMSIZ);
			if (rdd->tx_dev) {
				req.flags |= RDD_ASSOCIATED;
			}
			else {
				req.flags &= ~RDD_ASSOCIATED;
			}
			spin_unlock_irqrestore(&rdd_cfg_lock, flags);
					
			if (copy_to_user(arg, &req, sizeof(req))) {
				err = -EFAULT;
			}
		}
		break;
	}
	case REDIRDEV_GET_BY_NAME: {
		/* 
		 * get info on the specified redirect device
		 */
		struct redirdev *rdd;
		req.ifname[IFNAMSIZ-1] = '\0';
	    
		spin_lock_irqsave(&rdd_cfg_lock, flags);
		/* find the port in question */
		rdd = rdd_find_dev_by_name(req.ifname);

		if (!rdd) {
			err = -ENODEV;
			spin_unlock_irqrestore(&rdd_cfg_lock, flags);
		}
		else {
			memcpy(req.ifname, rdd->dev->name, IFNAMSIZ);
			memcpy(req.txifname, rdd->tx_dev_name, IFNAMSIZ);
			if (rdd->tx_dev) {
				req.flags |= RDD_ASSOCIATED;
			}
			else {
				req.flags &= ~RDD_ASSOCIATED;
			}
			spin_unlock_irqrestore(&rdd_cfg_lock, flags);
					
			if (copy_to_user(arg, &req, sizeof(req))) {
				err = -EFAULT;
			}
		}
		break;
	}
	default:
		printk("ERROR:  Un-supported redirdev ioctl command: %u\n",
		       (unsigned int)(req.cmd));
		send_sig(SIGSEGV, current, 1); // TODO:  Remove
		err = -EOPNOTSUPP;
		break;
	}//switch

	/* printk("Returning err: %i\n", err); */
	return err;
}/* ioctl handler */


#ifdef RDD_CONFIG_PROC_FS

static int read_rdd_glbl(char *page, char **start, off_t off,
			 int count, int *eof, void *data) {
	int	ret = -1;
	char	*p = page;
	int mx_len = (4096 - (p - page));
	
	if (! *eof ) {
		struct redirdev* rdd;
		int cnt;
		unsigned long flags;
		
                /* Global counts here... */
		p += sprintf(p, "Redirect-Device module:\n");

		p += sprintf(p, " redirect-devices: %i\n",
			     atomic_read(&rdd_dev_counter));

		spin_lock_irqsave(&rdd_cfg_lock, flags);
		rdd = rdds;
		while (rdd) {
			if (rdd->tx_dev) {
				p += sprintf(p, " %s  tx-dev: %s\n",
					     rdd->dev->name, rdd->tx_dev->name);
			}
			else {
				p += sprintf(p, " %s  tx-dev: [%s]\n",
					     rdd->dev->name, rdd->tx_dev_name);
			}

			/* catch overflow */
			cnt = p - page;
			if (cnt > (mx_len - 60)) {
				if (mx_len - cnt >= 20) {
					p += sprintf(p, "OUT_OF_SPACE!\n");
				}
				break;
			}

			rdd = rdd->next;
		}

		ret = p - page;
		spin_unlock_irqrestore(&rdd_cfg_lock, flags);
	}
	return ret;
} /* read_rdd_glbl */

static int write_rdd_glbl(struct file *file, const char *buffer,
			  unsigned long count, void *data) {
	char		*p;
	const char	*end;
	int		ret=count;
	int		len;
	char		dev_name[2][IFNAMSIZ];
        char* tmps = NULL;
        char ss[50];
	end = buffer + count;

	snprintf(ss, 50, "redir proc cmd: %%.%lus", count);

	printk(ss, buffer);
	
	for (p= (char *) buffer; p< end ; ) {
		if (iswhitespace(*p)) {
			p++;
			continue;
		}

		memset(dev_name[0], 0 ,IFNAMSIZ);
		memset(dev_name[1], 0 ,IFNAMSIZ);

		len = strlen("add_rdd ");
		if (strncmp(p, "add_rdd ", len)==0)
		{
			p += len;

			if ( (p + IFNAMSIZ) <= end)
				p += copy_next_word(dev_name[0], p, IFNAMSIZ);
			else
				p += copy_next_word(dev_name[0], p, end-p );

			skip_whitespace(p);

			if ( (p + IFNAMSIZ) <= end)
				p += copy_next_word(dev_name[1], p, IFNAMSIZ);
			else
				p += copy_next_word(dev_name[1], p, end-p );

			skip_whitespace(p);

                        /* This can fail, but not sure how to return failure
                         * to user-space here.
			 * NOTE:  Does it's own internal locking.
                         */
                        redirdev_create(dev_name[0], dev_name[1]);
                        goto forend;
		}
                
		len = strlen("remove_rdd ");
		if (strncmp(p,"remove_rdd ", len)==0) {
			p += len;

			if ( (p + IFNAMSIZ) <= end)
				p += copy_next_word(dev_name[0], p, IFNAMSIZ);
			else
				p += copy_next_word(dev_name[0], p, end-p );

                        skip_whitespace(p);

                        redirdev_cleanup(dev_name[0], 0);
                        goto forend;
		}

                len = strlen("debug_lvl ");
		if (strncmp(p,"debug_lvl ",len)==0)
		{
			p += len;

			if ( (p + IFNAMSIZ) <= end)
				p += copy_next_word(dev_name[0], p, IFNAMSIZ);
			else
				p += copy_next_word(dev_name[0], p, end-p );

                        skip_whitespace(p);

                        debug_lvl = simple_strtoul(dev_name[0], &tmps, 10);
                        goto forend;
		}

                printk("ERROR:  Unsupported command\n");

        forend:
		p++;
	}

	return ret;
} /* write_rdd_glbl */

#endif


static int __init redirdev_init(void) {
	int err;
	printk(KERN_INFO "Redirect-Network-Device: 1.0 <greearb@candelatech.com>\n");

	rdds = NULL;

	redirdev_ioctl_set(redirdev_ioctl_deviceless_stub);

#ifdef RDD_CONFIG_PROC_FS

        rdd_proc_dir = proc_mkdir(RDD_PROC_DIR, proc_net);
        if (rdd_proc_dir) {
		rdd_proc_cfg = create_proc_read_entry(RDD_PROC_CFG, S_IRUGO, rdd_proc_dir,
						      read_rdd_glbl, NULL);
		if (rdd_proc_cfg) {
			rdd_proc_cfg->write_proc = write_rdd_glbl;
			rdd_proc_cfg->owner = THIS_MODULE;
		}
	}
#endif

	/* Register us to receive netdevice events */
	err = register_netdevice_notifier(&redirdev_notifier_block);
	if (err < 0) {
		printk("ERROR:  redirdev: Failed to register netdevice notifier callback!\n");
	}	

	return 0;
}

static void redirdev_module_cleanup(void) {
	char nm[IFNAMSIZ+1];
	unsigned long flags;
	
	redirdev_ioctl_set(NULL);

	spin_lock_irqsave(&rdd_cfg_lock, flags);
	/* destroy all redirect devices */
	while (rdds) {
		strncpy(nm, rdds->dev->name, IFNAMSIZ);
		spin_unlock_irqrestore(&rdd_cfg_lock, flags);
		if (redirdev_cleanup(nm, 1) < 0) {
			printk("redirdev: ERROR:  Failed redir_cleanup in redir_module_cleanup\n");
			
		}
		spin_lock_irqsave(&rdd_cfg_lock, flags);
	}
	spin_unlock_irqrestore(&rdd_cfg_lock, flags);

	/* Un-register us from receiving netdevice events */
	unregister_netdevice_notifier(&redirdev_notifier_block);
	
#ifdef RDD_CONFIG_PROC_FS
	if (rdd_proc_cfg) {
		remove_proc_entry(RDD_PROC_CFG, rdd_proc_dir);
		rdd_proc_cfg = NULL;
	}
	if (rdd_proc_dir) {
		remove_proc_entry(RDD_PROC_DIR, proc_net);
		rdd_proc_dir = NULL;
	}
#endif

}/* redirdev_cleanup */


module_init(redirdev_init);
module_exit(redirdev_module_cleanup);
MODULE_LICENSE("GPL");

--------------050008060104060607060606
Content-Type: text/plain;
 name="redirdev.h"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="redirdev.h"

/* -*- linux-c -*-

# (C) Copyright 2005
# Ben Greear <greearb@candelatech.com>
# Released under the GPL version 2
*/

#ifndef REDIRDEV_KERNEL_H_FILE__
#define REDIRDEV_KERNEL_H_FILE__


/* Proc file related */
#define RDD_MX_ARG_LEN 80

#ifdef CONFIG_PROC_FS

/* To use or not to use the PROC-FS */
#define RDD_CONFIG_PROC_FS

#endif


/*********************************************************/
/*		       types				 */
/*********************************************************/
struct redirdev {
	/* Can be NULL if not yet associated */
	struct net_device* tx_dev; /* Call rx on this device when a packet
				    * is _transmitted_ on this redirect
				    * device.
				    */
	struct net_device* dev; /* the device struct this belongs too */
	struct redirdev *next;
	char tx_dev_name[IFNAMSIZ];
	struct net_device_stats	statistics;
};

#endif


--------------050008060104060607060606--
