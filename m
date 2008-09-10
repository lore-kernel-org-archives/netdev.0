From: Johannes Berg <johannes@sipsolutions.net>
Subject: ipv6 neighbour code keeps interfaces held
Date: Wed, 10 Sep 2008 23:18:59 +0200
Message-ID: <1221081539.3804.33.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:49341 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753137AbYIJVek (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Sep 2008 17:34:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Every once a while when the stars align right, I'll run into this
message:

[22350.676116] unregister_netdevice: waiting for wlan0 to become free. Usage count = 3

when rmmod'ing b43 and mac80211.

In trying to debug it, I have created the patch you can find at the end
of this email. I'm not sure it's generally useful, but I now found it
useful to pinpoint what's going on and to confirm that mac80211 isn't at
fault :)

The patch will WARN_ON() when a netdev reference is released via
dev_put() after the message above has already appeared at least once.
For me, I got this dump out of it:

[22369.076490] Badness at include/linux/netdevice.h:1255
[22369.076493] NIP: c0301aac LR: c0306b6c CTR: c0306b28
[22369.076497] REGS: efff5e40 TRAP: 0700   Tainted: G        W  (2.6.27-rc5-wl-00855-gebb8706-dirty)
[22369.076500] MSR: 00029032 <EE,ME,IR,DR>  CR: 28428442  XER: 20000000
[22369.076509] TASK = ed1da3a0[17998] 'cc1' THREAD: ee68a000
[22369.076512] GPR00: 00000001 efff5ef0 ed1da3a0 efb9a000 bbbbbbbb 00000004 ef8f54bc ef8f54e4 
[22369.076522] GPR08: 0000005a edb174b0 ffffffff edb172a0 28428442 10756ca4 c064ee04 eefb5494 
[22369.076532] GPR16: 00000000 1074f028 105ebb0c 00200200 00000000 c0870ff8 c0870df8 c0870bf8 
[22369.076542] GPR24: efff4000 c08709f8 c064461c efff5f78 00000000 00000000 ef8f5400 efb9a000 
[22369.076559] NIP [c0301aac] in6_dev_finish_destroy+0x50/0xb0
[22369.076565] LR [c0306b6c] ip6_dst_destroy+0x44/0x54
[22369.076567] Call Trace:
[22369.076571] [efff5ef0] [c028f984] neigh_destroy+0x16c/0x1b8 (unreliable)
[22369.076577] [efff5f00] [c0306b6c] ip6_dst_destroy+0x44/0x54
[22369.076582] [efff5f10] [c028c304] dst_destroy+0x78/0x154
[22369.076586] [efff5f30] [c030a270] icmp6_dst_gc+0xa4/0xd4
[22369.076591] [efff5f50] [c030b084] fib6_run_gc+0x50/0x110
[22369.076596] [efff5f70] [c003b040] run_timer_softirq+0x170/0x22c
[22369.076602] [efff5fc0] [c0035e7c] __do_softirq+0x8c/0xfc
[22369.076607] [efff5ff0] [c00120c4] call_do_softirq+0x14/0x24
[22369.076612] [ee68bd00] [c0007000] do_softirq+0x78/0x88
[22369.076616] [ee68bd20] [c0035ae4] irq_exit+0x60/0x80
[22369.076621] [ee68bd30] [c000fde0] timer_interrupt+0x11c/0x16c
[22369.076626] [ee68bd50] [c0012e78] ret_from_except+0x0/0x14
[22369.076632] --- Exception: 901 at __flush_dcache_icache+0x24/0x40
[22369.076634]     LR = update_mmu_cache+0x124/0x128
[22369.076644] [ee68be10] [ed6a0000] 0xed6a0000 (unreliable)
[22369.076649] [ee68be30] [c0085378] handle_mm_fault+0x774/0xb10
[22369.076653] [ee68be90] [c0332ba4] do_page_fault+0x3a8/0x540
[22369.076658] [ee68bf40] [c0012bfc] handle_page_fault+0xc/0x80
[22369.076663] --- Exception: 301 at 0x10383868
[22369.076665]     LR = 0x10383858
[22369.076667] Instruction dump:
[22369.076670] 7c0a4910 0f000000 81230008 3149ffff 7c0a4910 0f000000 392b0210 7c004828 
[22369.076680] 3000ffff 7c00492d 40a2fff4 880b0430 <0f000000> 812300a0 2f890000 419e0040 


Having never looked at the code I'll spare you any speculation, but I
don't see why I should be getting this once a while, no less on an
interface that's not even seeing traffic.

johannes
---
 include/linux/netdevice.h |    7 +++++++
 net/Kconfig               |    6 ++++++
 net/core/dev.c            |    3 +++
 3 files changed, 16 insertions(+)

--- everything.orig/include/linux/netdevice.h	2008-09-10 11:06:31.000000000 +0200
+++ everything/include/linux/netdevice.h	2008-09-10 11:10:55.000000000 +0200
@@ -749,6 +749,10 @@ struct net_device
 	/* for setting kernel sock attribute on TCP connection setup */
 #define GSO_MAX_SIZE		65536
 	unsigned int		gso_max_size;
+
+#ifdef CONFIG_NET_HOLD_DBG
+	bool			held_warning;
+#endif
 };
 #define to_net_dev(d) container_of(d, struct net_device, dev)
 
@@ -1247,6 +1251,9 @@ extern void netdev_run_todo(void);
 static inline void dev_put(struct net_device *dev)
 {
 	atomic_dec(&dev->refcnt);
+#ifdef CONFIG_NET_HOLD_DBG
+	WARN_ON(dev->held_warning);
+#endif
 }
 
 /**
--- everything.orig/net/core/dev.c	2008-09-10 11:06:42.000000000 +0200
+++ everything/net/core/dev.c	2008-09-10 11:11:31.000000000 +0200
@@ -4117,6 +4117,9 @@ static void netdev_wait_allrefs(struct n
 			       "count = %d\n",
 			       dev->name, atomic_read(&dev->refcnt));
 			warning_time = jiffies;
+#ifdef CONFIG_NET_HOLD_DBG
+			dev->held_warning = true;
+#endif
 		}
 	}
 }
--- everything.orig/net/Kconfig	2008-09-10 11:11:36.000000000 +0200
+++ everything/net/Kconfig	2008-09-10 11:13:29.000000000 +0200
@@ -24,6 +24,12 @@ if NET
 
 menu "Networking options"
 
+config NET_HOLD_DBG
+	bool "Network device refcount debugging"
+	default n
+	help
+	  Enable this option to have the kernel WARN too late dev_put().
+
 config NET_NS
 	bool "Network namespace support"
 	default n


