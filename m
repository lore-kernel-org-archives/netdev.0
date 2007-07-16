From: Steffen Maier <smaier@users.sourceforge.net>
Subject: kernel module to list sockets with their multicast group joins and
 respective processes
Date: Mon, 16 Jul 2007 20:48:17 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0707162029430.952@nettc.informatik.uni-stuttgart.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Steffen Maier <smaier@users.sourceforge.net>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw.informatik.uni-stuttgart.de ([129.69.211.41]:51020 "EHLO
	mx1.informatik.uni-stuttgart.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751094AbXGPTOs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jul 2007 15:14:48 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

below in the text you find a small kernel module as a proof of concept, 
that allows a listing of all current multicast group joins for (UDP/IPv4) 
sockets (NOTE: sockets, neither IP-level nor netdevice-level) along with 
the corresponding process(es) and filedescriptors.

Why did I do this?

Recently two different people asked me about Linux' behavior with respect 
to UDP/IPv4 multicast sockets. The first question was, why two different 
sockets that join different groups receive messages from the respective 
other group (if they are only bound to the wildcard address). Obviously 
this is handled differently in Linux for IPv4, where the socket matching 
for incoming message is done solely on the 4-tuple of addresses and ports, 
and IPv6, where the explicit socket joins are taken into account [1,2]. 
The second question was, if there is a possibility to get a list of all 
processes and the multicast groups they joined. Apparently the usual 
approach involving "netstat -g" (aka /proc/net/igmp[6]) only reports 
aggregates on the level of the host or IP respectively. 
/proc/net/dev_mcast is similar just one level below for the MAC group 
addresses on data link layer. Funny is the fact, that the IGMP code does 
track all group joins for each socket separately. Since I could not find 
any existing method to read that useful information (in user space), I 
wrote the module.

[1] http://www.uwsg.iu.edu/hypermail/linux/net/0211.1/0003.html
[2] http://www.ussg.iu.edu/hypermail/linux/kernel/0110.2/1511.html

Maybe this is useful for somebody, so I share it here.

Regards,
Steffen.

-- sockjoin.c --:

/* sockjoin: Prints UDP/IPv4 sockets and their joined multicast groups.
  *
  * This is more information than the usual "netstat -g" aka
  * /proc/net/igmp (on network layer) and /proc/net/dev_mcast (on data
  * link layer) can provide. Specifically, such data lacks the
  * information which sockets issued explicit group joins, since IP
  * just keeps track of the aggregated union of all group joins of the
  * host. Thankfully the kernel tracks more information internally with
  * a list of current group joins for each socket. This Linux kernel
  * module fits the pieces together and prints it nicely formatted
  * (including the processes accessing multicast sockets) on module load in
  * the kernel log. Future versions should enhance user friendlyness by
  * introduction of a procfs interface.
  *
  * Linux kernel module for Linux version 2.6.
  *
  * (c) 2007 Steffen Maier <smaier@users.sourceforge.net>
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
  * the Free Software Foundation; either version 2 of the License, or
  * (at your option) any later version.
  *
  * This program is distributed in the hope that it will be useful,
  * but WITHOUT ANY WARRANTY; without even the implied warranty of
  * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  * GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
  * along with this program; if not, write to the Free Software
  * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
  */

#include <linux/kernel.h> /* printk, KERN_*, NIPQUAD */
#include <linux/module.h> /* MODULE_AUTHOR, MODULE_LICENSE,
                              MODULE_DESCRIPTION */
#include <linux/init.h> /* __init, __exit, module_init(x), module_exit(x) */
#include <linux/stddef.h> /* NULL */
#include <net/udp.h> /* udp_hash, udp_hash_lock, UDP_HTABLE_SIZE */
#include <linux/byteorder/generic.h> /* ntohs */
#include <net/sock.h> /* struct sock */
#include <linux/socket.h> /* PF_INET */
#include <linux/igmp.h> /* struct ip_mc_socklist */
#include <linux/in.h> /* struct ip_mreqn */
#include <linux/ip.h> /* struct inet_sock, inet_sk */
#include <linux/file.h> /* fcheck_files */
#include <linux/fs.h> /* struct file */
#include <linux/spinlock.h> /* read_lock, read_unlock */
#include <linux/sched.h> /* struct task_struct, tasklist_lock, task_lock,
                             task_unlock, for_each_process */
#include <linux/netdevice.h> /* struct net_device, dev_get_by_index */
#include <linux/version.h> /* LINUX_VERSION_CODE, KERNEL_VERSION */

#if (LINUX_VERSION_CODE < KERNEL_VERSION(2,6,0))
# error SockJoin is not designed to work with kernel version earlier than 2.6.0
#endif

/* prototypes (forward declarations) */
/*  internal helper functions */
static inline void search_pids(struct sock *sk, struct ip_mc_socklist *jl);
static void iterate_main(void);
/*  module support */
static int __init sockjoin_init(void);
static void __exit sockjoin_exit(void);

/* beginning of debugging stuff ... */

/* supplement to NIPQUAD */
#define NIPFMT "%u.%u.%u.%u"

#define SOCKJOIN_DEBUG KERN_DEBUG
#if 1  /* don't or do print file name in debug statements */
# define SJDBGFMT "%s:%d:%c: "
# define SJDBGARG __PRETTY_FUNCTION__,__LINE__,(in_interrupt()?'I':'-')
#else
# define SJDBGFMT __FILE__":%d:"__PRETTY_FUNCTION__":%c: "
# define SJDBGARG __LINE__,(in_interrupt()?'I':'-')
#endif

#ifdef SJDEBUG
/* Caution: The preceding space in " ,##arg" is important to not
    affect previous arguments when arg is not present! */
# define DBG(fmt,arg...) \
         printk(SOCKJOIN_DEBUG SJDBGFMT fmt, SJDBGARG ,##arg)
# define SDBG(fmt,arg...) \
         printk(SOCKJOIN_DEBUG SJDBGFMT ">> " fmt, SJDBGARG ,##arg)
# define EDBG(fmt,arg...) \
         printk(SOCKJOIN_DEBUG SJDBGFMT "<< " fmt, SJDBGARG ,##arg)
# define DBGEXP(exp) exp
# define INF(fmt,arg...) \
         printk(KERN_INFO SJDBGFMT fmt, SJDBGARG ,##arg)
# define WARN(fmt,arg...) \
         printk(KERN_WARNING SJDBGFMT fmt, SJDBGARG ,##arg)
# define ERR(fmt,arg...) \
         printk(KERN_ERR SJDBGFMT fmt, SJDBGARG ,##arg)
/* convenience macros to split output and continue one of the above
    without getting implicit info like file name or line number. */
# define DBG_(fmt,arg...) printk(fmt ,##arg)
# define SDBG_(fmt,arg...) printk(fmt ,##arg)
# define EDBG_(fmt,arg...) printk(fmt ,##arg)
#else /* SJDEBUG */
# define DBG(fmt,arg...) do { } while (0)
# define SDBG(fmt,arg...) do { } while (0)
# define EDBG(fmt,arg...) do { } while (0)
# define DBGEXP(exp) /* nothing */
# define INF(fmt,arg...) printk(KERN_INFO "sockjoin: " fmt ,##arg)
# define WARN(fmt,arg...) printk(KERN_WARNING "sockjoin: " fmt ,##arg)
# define ERR(fmt,arg...) printk(KERN_ERR "sockjoin: " fmt ,##arg)
# define DBG_(fmt,arg...) do { } while (0)
# define SDBG_(fmt,arg...) do { } while (0)
# define EDBG_(fmt,arg...) do { } while (0)
#endif /* SJDEBUG */
#define INF_(fmt,arg...) printk(fmt ,##arg)
#define WARN_(fmt,arg...) printk(fmt ,##arg)
#define ERR_(fmt,arg...) printk(fmt ,##arg)

/* prepend an underscore to deactivate certain debug macros */
#define _DBG(fmt,arg...) do { } while (0)
#define _SDBG(fmt,arg...) do { } while (0)
#define _EDBG(fmt,arg...) do { } while (0)
#define _DBGEXP(exp) /* nothing */

/* ... end of debugging stuff */

#define SOCKJOIN_BANNER "SockJoin ("__DATE__" "__TIME__") for Linux Kernel 2.6: Prints UDP/IPv4 multicast sockets with their currently joined groups (an association IMHO not possible with netstat or current procfs entries).\n"

/**
  * search_pids: Print group join for each process referencing given socket.
  * @sk: Socket whose information such as IP/port 4-tuple should be used.
  * @jl: Group join entry of socket @sk to be used for information printing.
  */
static inline void search_pids(struct sock *sk, struct ip_mc_socklist *jl)
{
         struct task_struct *p;
         struct file *sockfil;
         struct inet_sock *si;
         struct ip_mreqn *m;

         if ((sk == NULL) || (sk->sk_socket == NULL) || (jl == NULL)) return;
         sockfil = sk->sk_socket->file;
         si = inet_sk(sk);
         m = &(jl->multi);

         /* iterate list of all processes */
         read_lock(&tasklist_lock);
         for_each_process(p) {
                 int i;

                 task_lock(p);
                 /* skip processes with no opened files */
                 if (p->files == NULL) {
                         task_unlock(p);
                         continue;
                 }
                 /* iterate all open files of the process */
                 read_lock(&p->files->file_lock);
                 for (i = 0; i < p->files->max_fds; i++) {
                         struct file *filp = fcheck_files(p->files, i);
                         struct net_device *dev;

                         if ((filp == NULL) || (filp != sockfil))
                                 continue;
                         dev = dev_get_by_index(m->imr_ifindex);
                         INF(NIPFMT":%hu<-"NIPFMT":%hu "
                             "%i:%s,"NIPFMT"<-"NIPFMT" "
                             "%d %d:%s %d\n",
                             NIPQUAD(si->rcv_saddr), htons(si->sport),
                             NIPQUAD(si->daddr), htons(si->dport),
                             m->imr_ifindex,
                             (dev != NULL) ? dev->name : "dev?",
                             NIPQUAD(m->imr_address.s_addr),
                             NIPQUAD(m->imr_multiaddr.s_addr),
                             i, p->pid, p->comm, sock_i_uid(sk));
                         dev_put(dev);
                 }
                 read_unlock(&p->files->file_lock);
                 task_unlock(p);
         }
         read_unlock(&tasklist_lock);
}

/**
  * iterate_main: Iterate group joins for each UDP/IPv4 socket.
  */
static void iterate_main(void)
{
         int i;

         /* first print line format */
         INF("locIP:locPort<-remIP:remPort devID:devName,locGrp<-remGrp FD PID:procname UID\n");
         /* iterate all hash bins */
         read_lock(&udp_hash_lock);
 	for (i = 0; i < UDP_HTABLE_SIZE; i++) {
 		struct sock *sk;
                 struct hlist_node *node;

                 /* iterate external collision list of current hash bin */
                 sk_for_each(sk, node, udp_hash + i) {
                         struct inet_sock *si = inet_sk(sk);
                         struct ip_mc_socklist *l;

                         /* only process UDP/IPv4 sockets with group joins */
                         rtnl_lock();
 			if ((sk->sk_family != PF_INET) ||
                             (si->mc_list == NULL)) {
                                 rtnl_unlock();
                                 continue;
                         }
                         /* iterate the group joins of the socket */
                         for (l = si->mc_list; l != NULL; l = l->next) {
                                 search_pids(sk, l);
                         }
                         rtnl_unlock();
 		}
 	}
 	read_unlock(&udp_hash_lock);
}

/**
  * sockjoin_init: Module init function.
  */
static int __init sockjoin_init(void)
{
 	int ret = 0;
 	SDBG("()\n");
 	INF(SOCKJOIN_BANNER);
         iterate_main();
 	EDBG("%i\n", ret);
 	return ret;
}

/**
  * sockjoin_exit: Module exit function.
  */
static void __exit sockjoin_exit(void)
{
 	SDBG("()\n");
 	INF("Sockjoin removed.\n");
 	EDBG("\n");
}

MODULE_AUTHOR("Steffen Maier <smaier@users.sourceforge.net>");
MODULE_LICENSE("GPL");
MODULE_DESCRIPTION(SOCKJOIN_BANNER);
module_init(sockjoin_init);
module_exit(sockjoin_exit);

-- Kbuild --:

obj-m    := sockjoin.o sockjoin.debug.o

CFLAGS_sockjoin.debug.o := -DSJDEBUG

$(obj)/sockjoin.debug.c: $(src)/sockjoin.c
 	ln -s $^ $@

clean-files := $(obj)/sockjoin.debug.c

-- Makefile --:

ifneq ($(KERNELRELEASE),)
include Kbuild
else
# Makefile for SockJoin

KDIR    := /lib/modules/$(shell uname -r)/build
PWD    := $(shell pwd)

default:
 	$(MAKE) -C $(KDIR) M=$(PWD) modules

.PHONY: clean

clean:
 	$(MAKE) -C $(KDIR) M=$(PWD) clean

endif
