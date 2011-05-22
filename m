From: cedric arbogast <arbogast.cedric@gmail.com>
Subject: Patchs for pg3.c and Linux 2.6.x kernel
Date: Sun, 22 May 2011 17:24:27 +0200
Message-ID: <4DD92AAB.8060202@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:42079 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750774Ab1EVPA5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 May 2011 11:00:57 -0400
Received: by wya21 with SMTP id 21so3675528wya.19
        for <netdev@vger.kernel.org>; Sun, 22 May 2011 08:00:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Hello,

This is my first contact and mail with this mailing list, to summarize i'm a coder maintening a personnal home server using several GNU tools since the late 90's.

I build IPUTILS-s20101006 in a chroot jail (gcc 4.5.2/libc 2.13/binutils 2.21/make 3.82) with an athlon architecture on ext3 FS. I see the packet's injection module in the Module directory and try a "make modules" which indeed fails. I put an eye on the pg3.c and it seems it has not been ported to
the 2.6.x modules architecture (i'm not a kernel hacker, so it's just my humble opinion).

I make some trivial adaptations to make the code meets the 2.6 module's API requirements. The patched code compile successfully on the platform described above, but i can't now test it's proper functioning, if anyone could give a try (please consider it could (will ?) be harmful for the test
platform as i am not familiar with kernel modules hacking...) :



- --- Makefile.orig       2010-10-06 13:59:20.000000000 +0200
+++ Makefile    2011-05-22 16:56:09.000000000 +0200
@@ -39,17 +39,8 @@
        $(CC) $(CFLAGS) -DRDISC_SERVER -o rdisc_srv.o rdisc.c


- -check-kernel:
- -ifeq ($(KERNEL_INCLUDE),)
- -       @echo "Please, set correct KERNEL_INCLUDE"; false
- -else
- -       @set -e; \
- -       if [ ! -r $(KERNEL_INCLUDE)/linux/autoconf.h ]; then \
- -               echo "Please, set correct KERNEL_INCLUDE"; false; fi
- -endif
- -
- -modules: check-kernel
- -       $(MAKE) KERNEL_INCLUDE=$(KERNEL_INCLUDE) -C Modules
+modules:
+       $(MAKE) -C Modules

 man:
        $(MAKE) -C doc man



- --- Modules/Makefile.orig    2010-10-06 13:59:20.000000000 +0200
+++ Modules/Makefile    2011-05-22 14:47:48.000000000 +0200
@@ -1,12 +1,10 @@
- -KERNEL_INCLUDE=/usr/src/linux/include
+ifneq ($(KERNELRELEASE),)
+    obj-m      := pg3.o

+else
+KDIR   := /lib/modules/$(shell uname -r)/build
+PWD    := $(shell pwd)

- -CC=gcc
- -CCOPT=-O2 -Wstrict-prototypes -Wall -Werror -fno-strict-aliasing -fno-common
- -CFLAGS=-DMODULE -D__KERNEL__ -I$(KERNEL_INCLUDE) $(CCOPT)
- -
- -
- -all: pg3.o
- -
- -clean:
- -       @rm -f *.o
+default:
+       $(MAKE) -C $(KDIR) SUBDIRS=$(PWD) modules
+endif





- --- Modules/pg3.c.orig	2010-10-06 13:59:20.000000000 +0200
+++ Modules/pg3.c	2011-05-22 16:27:57.000000000 +0200
@@ -89,7 +89,7 @@
 #include <linux/ptrace.h>
 #include <linux/errno.h>
 #include <linux/ioport.h>
- -#include <linux/malloc.h>
+#include <linux/slab.h>
 #include <linux/interrupt.h>
 #include <linux/pci.h>
 #include <linux/delay.h>
@@ -110,6 +110,7 @@
 #include <linux/proc_fs.h>
 #include <linux/if_arp.h>
 #include <net/checksum.h>
+#include <linux/version.h>

 static char version[] __initdata =
   "pg3.c: v1.0 010812: Packet Generator for packet performance testing.\n";
@@ -150,7 +151,7 @@
 	u32 saddr;

 	rtnl_lock();
- -	odev = __dev_get_by_name(pg_outdev);
+	odev = __dev_get_by_name(&init_net, pg_outdev);
 	if (!odev) {
 		sprintf(pg_result, "No such netdevice: \"%s\"", pg_outdev);
 		goto out_unlock;
@@ -176,7 +177,8 @@
 		if (in_dev->ifa_list)
 			saddr = in_dev->ifa_list->ifa_address;
 	}
- -	atomic_inc(&odev->refcnt);
+	//atomic_inc(&odev->refcnt);
+	dev_hold(odev);
 	rtnl_unlock();

 	*saddrp = saddr;
@@ -282,7 +284,8 @@
 	iph->check = 0;
 	iph->check = ip_fast_csum((void *)iph, iph->ihl);
 	skb->protocol = __constant_htons(ETH_P_IP);
- -	skb->mac.raw = ((u8*)iph) - 14;
+	//skb->mac.raw = ((u8*)iph) - 14;
+	skb_set_mac_header(skb, -14);
 	skb->dev = odev;
 	skb->pkt_type = PACKET_HOST;

@@ -363,10 +366,11 @@
 	do_gettimeofday(&start);

 	for(;;) {
- -		spin_lock_bh(&odev->xmit_lock);
+		//spin_lock_bh(&odev->xmit_lock);
+		netif_tx_lock_bh(odev);
 		atomic_inc(&skb->users);
 		if (!netif_queue_stopped(odev)) {
- -			if (odev->hard_start_xmit(skb, odev)) {
+			if (odev->netdev_ops->ndo_start_xmit(skb, odev)) {
 				kfree_skb(skb);
 				if (net_ratelimit())
 					printk(KERN_INFO "Hard xmit error\n");
@@ -375,7 +379,8 @@
 		} else {
 			kfree_skb(skb);
 		}
- -		spin_unlock_bh(&odev->xmit_lock);
+		//spin_unlock_bh(&odev->xmit_lock);
+		netif_tx_unlock_bh(odev);

 		if (pg_ipg)
 			nanospin(pg_ipg);
@@ -402,7 +407,7 @@
 			break;
 		}

- -		if (netif_queue_stopped(odev) || current->need_resched) {
+		if (netif_queue_stopped(odev) || test_thread_flag(TIF_NEED_RESCHED) /*current->need_resched*/) {
 			u32 idle_start, idle;

 			idle_start = get_cycles();
@@ -411,10 +416,10 @@
 					goto out_intr;
 				if (!netif_running(odev))
 					goto out_intr;
- -				if (current->need_resched)
+				if (test_thread_flag(TIF_NEED_RESCHED) /*current->need_resched*/)
 					schedule();
- -				else
- -					do_softirq();
+				//else
+				//	do_softirq();
 			} while (netif_queue_stopped(odev));
 			idle = get_cycles() - idle_start;
 			idle_acc_lo += idle;
@@ -540,7 +545,7 @@
 		case '\t':
 		case ' ':
 			goto done_str;
- -		default:
+		default:;
 		}
 done_str:
 	return i;
@@ -669,12 +674,12 @@
 	}

 	if (!strcmp(name, "inject") || !strcmp(name, "start") ) {
- -		MOD_INC_USE_COUNT;
+		//MOD_INC_USE_COUNT;
 		pg_busy = 1;
 		strcpy(pg_result, "Starting");
 		pg_inject();
 		pg_busy = 0;
- -		MOD_DEC_USE_COUNT;
+		//MOD_DEC_USE_COUNT;
 		return count;
 	}

@@ -723,9 +728,12 @@
 #if LINUX_VERSION_CODE > 0x20118
 MODULE_AUTHOR("Robert Olsson <robert.olsson@its.uu.se");
 MODULE_DESCRIPTION("Packet Generator tool");
- -MODULE_PARM(pg_count, "i");
- -MODULE_PARM(pg_ipg, "i");
- -MODULE_PARM(pg_cpu_speed, "i");
+module_param(pg_count, int, S_IRUGO);
+module_param(pg_ipg, int, S_IRUGO);
+module_param(pg_cpu_speed, int, S_IRUGO);
+//MODULE_PARM(pg_count, "i");
+//MODULE_PARM(pg_ipg, "i");
+//MODULE_PARM(pg_cpu_speed, "i");
 #endif

 /*




Regards, Cedric.
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.17 (MingW32)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk3ZKqsACgkQUPHT03kXaaar2wCfcxesPlBK/5e/Dy9tfX+csq5M
qIIAn2acDqBbFyKZdVHJEKHLkGxoPKxf
=JShy
-----END PGP SIGNATURE-----
