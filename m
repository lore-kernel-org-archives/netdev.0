From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: [RFC/PATCH] ICMPv6 MIB stats per-interface
Date: Mon, 14 Apr 2003 08:03:47 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030414080347.0af818f7.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: linux-net@vger.kernel.org
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

I'm looking for feedback on this patch....
and (feedback) on future IPv6 MIB stats patches if anyone cares to
go that far.


This patch modifies the ICMPv6 MIB statistics to be collected per
network-interface instead of globally, as required by RFC 2466
(ICMPv6 MIB Group).

[This patch is to 2.5.67-plain.]


1.  Icmp6 MIB counters are no longer per-cpu since they are per-interface.
Do they need to be per-interface * per-cpu ?

2.  This patch modifies the contents of /proc/net/snmp6 for the Icmp6*
fields.  I began the patch by prefixing each Icmp6 field with
<interface_dev_name>, e.g.:

eth0:Icmp6InMsgs                        1520
eth0:Icmp6InErrors                      0
eth0:Icmp6OutMsgs                       40
lo:Icmp6InMsgs                          1520
lo:Icmp6InErrors                        0
lo:Icmp6OutMsgs                         40
dummy0:Icmp6InMsgs                      1520
dummy0:Icmp6InErrors                    0
dummy0:Icmp6OutMsgs                     40

but I had some feedback that the following format was more preferable:

interface:eth0
Icmp6InMsgs                             1520
Icmp6InErrors                           0
Icmp6OutMsgs                            40
interface:lo
Icmp6InMsgs                             25
Icmp6InErrors                           0
Icmp6OutMsgs                            15
interface:dummy0
Icmp6InMsgs                             15
Icmp6InErrors                           0
Icmp6OutMsgs                            10

However, if it isn't possible to modify the proc file contents at all,
how about adding new files to /proc/net/* ?  Is that OK?


I have a commitment from someone to modify the Net-SNMP package to
support a /proc/net/snmp6 format when it is agreed upon, and I will
modify the netstat program in the net-tools package.


Comments?

--
~Randy   ["in English any noun can be verbed."  bah!]



diff -Naurp -X /home/rddunlap/doc/dontdiff-osdl linux-2567-pv/include/linux/netdevice.h linux-2567-icmpv6/include/linux/netdevice.h
--- linux-2567-pv/include/linux/netdevice.h	Mon Apr  7 10:32:51 2003
+++ linux-2567-icmpv6/include/linux/netdevice.h	Wed Apr  9 14:03:34 2003
@@ -335,6 +335,7 @@ struct net_device
 	void                    *dn_ptr;        /* DECnet specific data */
 	void                    *ip6_ptr;       /* IPv6 specific data */
 	void			*ec_ptr;	/* Econet specific data	*/
+	struct icmpv6_mib	*icmpv6_stats[2];
 
 	struct list_head	poll_list;	/* Link to poll list	*/
 	int			quota;
diff -Naurp -X /home/rddunlap/doc/dontdiff-osdl linux-2567-pv/include/net/icmp.h linux-2567-icmpv6/include/net/icmp.h
--- linux-2567-pv/include/net/icmp.h	Mon Apr  7 10:32:26 2003
+++ linux-2567-icmpv6/include/net/icmp.h	Thu Apr 10 16:48:00 2003
@@ -20,6 +20,7 @@
 
 #include <linux/icmp.h>
 #include <linux/skbuff.h>
+#include <asm/hardirq.h>
 
 #include <net/sock.h>
 #include <net/protocol.h>
diff -Naurp -X /home/rddunlap/doc/dontdiff-osdl linux-2567-pv/include/net/ipv6.h linux-2567-icmpv6/include/net/ipv6.h
--- linux-2567-pv/include/net/ipv6.h	Mon Apr  7 10:32:25 2003
+++ linux-2567-icmpv6/include/net/ipv6.h	Sun Apr 13 20:50:53 2003
@@ -110,14 +110,31 @@ DECLARE_SNMP_STAT(struct ipv6_mib, ipv6_
 #define IP6_INC_STATS(field)		SNMP_INC_STATS(ipv6_statistics, field)
 #define IP6_INC_STATS_BH(field)		SNMP_INC_STATS_BH(ipv6_statistics, field)
 #define IP6_INC_STATS_USER(field) 	SNMP_INC_STATS_USER(ipv6_statistics, field)
-DECLARE_SNMP_STAT(struct icmpv6_mib, icmpv6_statistics);
-#define ICMP6_INC_STATS(field)		SNMP_INC_STATS(icmpv6_statistics, field)
-#define ICMP6_INC_STATS_BH(field)	SNMP_INC_STATS_BH(icmpv6_statistics, field)
-#define ICMP6_INC_STATS_USER(field) 	SNMP_INC_STATS_USER(icmpv6_statistics, field)
-#define ICMP6_STATS_PTR_BH(field) 					\
-	(&								\
-	 ((per_cpu_ptr(icmpv6_statistics[0], smp_processor_id()))->	\
-	  field))
+
+/////DECLARE_SNMP_STAT(struct icmpv6_mib, icmpv6_statistics);
+#if 0
+#define ICMP6_INC_STATS(dev, field)	\
+	SNMP_INC_IFSTATS(dev, icmpv6_stats, field)
+#define ICMP6_INC_STATS_BH(dev, field)	\
+	SNMP_INC_IFSTATS_BH(dev, icmpv6_stats, field)
+#define ICMP6_INC_STATS_USER(dev, field)	\
+	SNMP_INC_IFSTATS_USER(dev, icmpv6_stats, field)
+#endif
+#define ICMP6_INC_STATS(dev, field)	do { \
+	SNMP_INC_IFSTATS(dev, icmpv6_stats, field); \
+} while (0)
+#define ICMP6_INC_STATS_BH(dev, field)	do { \
+	SNMP_INC_IFSTATS_BH(dev, icmpv6_stats, field); \
+} while (0)
+#define ICMP6_INC_STATS_USER(dev, field)  do { \
+	SNMP_INC_IFSTATS_USER(dev, icmpv6_stats, field); \
+} while (0)
+#define ICMP6_INC_STATS_OFFSET_BH(dev, base, offset) do {	\
+	struct icmpv6_mib *__mib = dev->icmpv6_stats[0];	\
+	unsigned long *field = (unsigned long *)&(__mib->base) + offset; \
+	*field = *field + 1;						\
+} while (0)
+
 DECLARE_SNMP_STAT(struct udp_mib, udp_stats_in6);
 #define UDP6_INC_STATS(field)		SNMP_INC_STATS(udp_stats_in6, field)
 #define UDP6_INC_STATS_BH(field)	SNMP_INC_STATS_BH(udp_stats_in6, field)
diff -Naurp -X /home/rddunlap/doc/dontdiff-osdl linux-2567-pv/include/net/snmp.h linux-2567-icmpv6/include/net/snmp.h
--- linux-2567-pv/include/net/snmp.h	Mon Apr  7 10:31:05 2003
+++ linux-2567-icmpv6/include/net/snmp.h	Thu Apr 10 16:48:45 2003
@@ -22,6 +22,7 @@
 #define _SNMP_H
 
 #include <linux/cache.h>
+#include <asm/hardirq.h>
  
 /*
  *	We use all unsigned longs. Linux will soon be so reliable that even these
@@ -314,5 +315,18 @@ struct linux_mib 
 	(per_cpu_ptr(mib[0], smp_processor_id())->field += addend)
 #define SNMP_ADD_STATS_USER(mib, field, addend) 	\
 	(per_cpu_ptr(mib[1], smp_processor_id())->field += addend)
+
+#define SNMP_INC_IFSTATS_BH(dev, mib, field) 	\
+	(dev->mib[0]->field++)
+#define SNMP_INC_IFSTATS_USER(dev, mib, field) \
+	(dev->mib[1]->field++)
+#define SNMP_INC_IFSTATS(dev, mib, field) 	\
+	(dev->mib[!in_softirq()]->field++)
+#define SNMP_DEC_IFSTATS(dev, mib, field) 	\
+	(dev->mib[!in_softirq()]->field--)
+#define SNMP_ADD_IFSTATS_BH(dev, mib, field, addend) 	\
+	(dev->mib[0]->field += addend)
+#define SNMP_ADD_IFSTATS_USER(dev, mib, field, addend) 	\
+	(dev->mib[1]->field += addend)
  	
 #endif
diff -Naurp -X /home/rddunlap/doc/dontdiff-osdl linux-2567-pv/include/net/sock.h linux-2567-icmpv6/include/net/sock.h
--- linux-2567-pv/include/net/sock.h	Mon Apr  7 10:32:16 2003
+++ linux-2567-icmpv6/include/net/sock.h	Thu Apr 10 16:47:18 2003
@@ -51,6 +51,7 @@
 #include <linux/filter.h>
 
 #include <asm/atomic.h>
+#include <asm/hardirq.h>
 #include <net/dst.h>
 
 /*
diff -Naurp -X /home/rddunlap/doc/dontdiff-osdl linux-2567-pv/net/core/dev.c linux-2567-icmpv6/net/core/dev.c
--- linux-2567-pv/net/core/dev.c	Mon Apr  7 10:31:20 2003
+++ linux-2567-icmpv6/net/core/dev.c	Sun Apr 13 20:48:09 2003
@@ -2519,6 +2519,20 @@ int dev_new_index(void)
 	}
 }
 
+#ifdef CONFIG_IPV6
+static int alloc_icmpv6_stats(struct net_device *dev)
+{
+	dev->icmpv6_stats[0] = kmalloc(2 * sizeof(struct icmpv6_mib), GFP_KERNEL);
+	if (!dev->icmpv6_stats[0])
+		return -ENOMEM;
+	memset(dev->icmpv6_stats[0], 0, 2 * sizeof(struct icmpv6_mib));
+	dev->icmpv6_stats[1] = (void *)dev->icmpv6_stats[0] + sizeof(struct icmpv6_mib);
+	return 0;
+}
+#else
+#define alloc_icmpv6_stats(dev)		0
+#endif
+
 static int dev_boot_phase = 1;
 
 /**
@@ -2559,12 +2573,17 @@ int register_netdevice(struct net_device
 		goto out;
 #endif /* CONFIG_NET_DIVERT */
 
+	if (alloc_icmpv6_stats(dev)) {
+		ret = -ENOMEM;
+		goto out_err;
+	}
+
 	dev->iflink = -1;
 
 	/* Init, if this function is available */
 	ret = -EIO;
 	if (dev->init && dev->init(dev))
-		goto out_err;
+		goto out_err_mib;
 
 	dev->ifindex = dev_new_index();
 	if (dev->iflink == -1)
@@ -2574,12 +2593,12 @@ int register_netdevice(struct net_device
 	ret = -EEXIST;
 	for (dp = &dev_base; (d = *dp) != NULL; dp = &d->next) {
 		if (d == dev || !strcmp(d->name, dev->name))
-			goto out_err;
+			goto out_err_mib;
 	}
 	snprintf(dev->kobj.name,KOBJ_NAME_LEN,dev->name);
 	kobj_set_kset_s(dev,net_subsys);
 	if ((ret = kobject_register(&dev->kobj)))
-		goto out_err;
+		goto out_err_mib;
 	
 	/*
 	 *	nil rebuild_header routine,
@@ -2612,6 +2631,8 @@ int register_netdevice(struct net_device
 
 out:
 	return ret;
+out_err_mib:
+	kfree(dev->icmpv6_stats[0]);
 out_err:
 #ifdef CONFIG_NET_DIVERT
 	free_divert_blk(dev);
@@ -2725,6 +2746,7 @@ int unregister_netdevice(struct net_devi
 #ifdef CONFIG_NET_DIVERT
 	free_divert_blk(dev);
 #endif
+	kfree(dev->icmpv6_stats[0]);
 
 	if (dev->destructor != NULL) {
 #ifdef NET_REFCNT_DEBUG
@@ -2830,6 +2852,9 @@ static int __init net_dev_init(void)
 	BUG_ON(!dev_boot_phase);
 
 	if (dev_proc_init())
+		goto out;
+
+	if (alloc_icmpv6_stats(&loopback_dev))
 		goto out;
 
 	subsystem_register(&net_subsys);
diff -Naurp -X /home/rddunlap/doc/dontdiff-osdl linux-2567-pv/net/ipv6/af_inet6.c linux-2567-icmpv6/net/ipv6/af_inet6.c
--- linux-2567-pv/net/ipv6/af_inet6.c	Mon Apr  7 10:31:45 2003
+++ linux-2567-icmpv6/net/ipv6/af_inet6.c	Wed Apr  9 14:03:34 2003
@@ -641,15 +641,6 @@ static int __init init_ipv6_mibs(void)
 	if (!ipv6_statistics[1])
 		goto err_ip_mib1;
 	
-	icmpv6_statistics[0] = kmalloc_percpu(sizeof (struct icmpv6_mib),
-						GFP_KERNEL);
-	if (!icmpv6_statistics[0])
-		goto err_icmp_mib0;
-	icmpv6_statistics[1] = kmalloc_percpu(sizeof (struct icmpv6_mib),
-						GFP_KERNEL);
-	if (!icmpv6_statistics[1])
-		goto err_icmp_mib1;
-	
 	udp_stats_in6[0] = kmalloc_percpu(sizeof (struct udp_mib),
 						GFP_KERNEL);
 	if (!udp_stats_in6[0])
@@ -666,10 +657,6 @@ static int __init init_ipv6_mibs(void)
 				sizeof (struct ipv6_mib));
 		memset(per_cpu_ptr(ipv6_statistics[1], i), 0,
 				sizeof (struct ipv6_mib));
-		memset(per_cpu_ptr(icmpv6_statistics[0], i), 0,
-				sizeof (struct icmpv6_mib));
-		memset(per_cpu_ptr(icmpv6_statistics[1], i), 0,
-				sizeof (struct icmpv6_mib));
 		memset(per_cpu_ptr(udp_stats_in6[0], i), 0,
 				sizeof (struct udp_mib));
 		memset(per_cpu_ptr(udp_stats_in6[1], i), 0,
@@ -681,10 +668,6 @@ static int __init init_ipv6_mibs(void)
 err_udp_mib1:
 	kfree_percpu(udp_stats_in6[0]);
 err_udp_mib0:
-	kfree_percpu(icmpv6_statistics[1]);
-err_icmp_mib1:
-	kfree_percpu(icmpv6_statistics[0]);
-err_icmp_mib0:
 	kfree_percpu(ipv6_statistics[1]);
 err_ip_mib1:
 	kfree_percpu(ipv6_statistics[0]);
@@ -697,8 +680,6 @@ static void cleanup_ipv6_mibs(void)
 {
 	kfree_percpu(ipv6_statistics[0]);
 	kfree_percpu(ipv6_statistics[1]);
-	kfree_percpu(icmpv6_statistics[0]);
-	kfree_percpu(icmpv6_statistics[1]);
 	kfree_percpu(udp_stats_in6[0]);
 	kfree_percpu(udp_stats_in6[1]);
 }
diff -Naurp -X /home/rddunlap/doc/dontdiff-osdl linux-2567-pv/net/ipv6/icmp.c linux-2567-icmpv6/net/ipv6/icmp.c
--- linux-2567-pv/net/ipv6/icmp.c	Mon Apr  7 10:30:59 2003
+++ linux-2567-icmpv6/net/ipv6/icmp.c	Sun Apr 13 20:51:34 2003
@@ -64,7 +64,7 @@
 #include <asm/uaccess.h>
 #include <asm/system.h>
 
-DEFINE_SNMP_STAT(struct icmpv6_mib, icmpv6_statistics);
+/////DEFINE_SNMP_STAT(struct icmpv6_mib, icmpv6_statistics);
 
 /*
  *	ICMP socket(s) for flow control.
@@ -353,8 +353,8 @@ void icmpv6_send(struct sk_buff *skb, in
 	ip6_build_xmit(sk, icmpv6_getfrag, &msg, &fl, len, NULL, -1,
 		       MSG_DONTWAIT);
 	if (type >= ICMPV6_DEST_UNREACH && type <= ICMPV6_PARAMPROB)
-		ICMP6_STATS_PTR_BH(Icmp6OutDestUnreachs) [type-ICMPV6_DEST_UNREACH]++;
-	ICMP6_INC_STATS_BH(Icmp6OutMsgs);
+		ICMP6_INC_STATS_OFFSET_BH(dev, Icmp6OutDestUnreachs, type - ICMPV6_DEST_UNREACH);
+	ICMP6_INC_STATS_BH(dev, Icmp6OutMsgs);
 out:
 	icmpv6_xmit_unlock();
 }
@@ -397,8 +397,8 @@ static void icmpv6_echo_reply(struct sk_
 
 	ip6_build_xmit(sk, icmpv6_getfrag, &msg, &fl, msg.len, NULL, -1,
 		       MSG_DONTWAIT);
-	ICMP6_INC_STATS_BH(Icmp6OutEchoReplies);
-	ICMP6_INC_STATS_BH(Icmp6OutMsgs);
+	ICMP6_INC_STATS_BH(skb->dev, Icmp6OutEchoReplies);
+	ICMP6_INC_STATS_BH(skb->dev, Icmp6OutMsgs);
 
 	icmpv6_xmit_unlock();
 }
@@ -468,7 +468,7 @@ static int icmpv6_rcv(struct sk_buff **p
 	struct icmp6hdr *hdr;
 	int type;
 
-	ICMP6_INC_STATS_BH(Icmp6InMsgs);
+	ICMP6_INC_STATS_BH(dev, Icmp6InMsgs);
 
 	saddr = &skb->nh.ipv6h->saddr;
 	daddr = &skb->nh.ipv6h->daddr;
@@ -516,9 +516,9 @@ static int icmpv6_rcv(struct sk_buff **p
 	type = hdr->icmp6_type;
 
 	if (type >= ICMPV6_DEST_UNREACH && type <= ICMPV6_PARAMPROB)
-		ICMP6_STATS_PTR_BH(Icmp6InDestUnreachs)[type-ICMPV6_DEST_UNREACH]++;
+		ICMP6_INC_STATS_OFFSET_BH(dev, Icmp6InDestUnreachs, type - ICMPV6_DEST_UNREACH);
 	else if (type >= ICMPV6_ECHO_REQUEST && type <= NDISC_REDIRECT)
-		ICMP6_STATS_PTR_BH(Icmp6InEchos)[type-ICMPV6_ECHO_REQUEST]++;
+		ICMP6_INC_STATS_OFFSET_BH(dev, Icmp6InEchos, type - ICMPV6_ECHO_REQUEST);
 
 	switch (type) {
 	case ICMPV6_ECHO_REQUEST:
@@ -596,7 +596,7 @@ static int icmpv6_rcv(struct sk_buff **p
 	return 0;
 
 discard_it:
-	ICMP6_INC_STATS_BH(Icmp6InErrors);
+	ICMP6_INC_STATS_BH(dev, Icmp6InErrors);
 	kfree_skb(skb);
 	return 0;
 }
diff -Naurp -X /home/rddunlap/doc/dontdiff-osdl linux-2567-pv/net/ipv6/ipv6_syms.c linux-2567-icmpv6/net/ipv6/ipv6_syms.c
--- linux-2567-pv/net/ipv6/ipv6_syms.c	Mon Apr  7 10:32:16 2003
+++ linux-2567-icmpv6/net/ipv6/ipv6_syms.c	Wed Apr  9 14:39:32 2003
@@ -9,7 +9,6 @@
 
 EXPORT_SYMBOL(ipv6_addr_type);
 EXPORT_SYMBOL(icmpv6_send);
-EXPORT_SYMBOL(icmpv6_statistics);
 EXPORT_SYMBOL(icmpv6_err_convert);
 EXPORT_SYMBOL(ndisc_mc_map);
 EXPORT_SYMBOL(register_inet6addr_notifier);
diff -Naurp -X /home/rddunlap/doc/dontdiff-osdl linux-2567-pv/net/ipv6/mcast.c linux-2567-icmpv6/net/ipv6/mcast.c
--- linux-2567-pv/net/ipv6/mcast.c	Mon Apr  7 10:32:28 2003
+++ linux-2567-icmpv6/net/ipv6/mcast.c	Wed Apr  9 14:03:34 2003
@@ -569,10 +569,10 @@ static void igmp6_send(struct in6_addr *
 
 	dev_queue_xmit(skb);
 	if (type == ICMPV6_MGM_REDUCTION)
-		ICMP6_INC_STATS(Icmp6OutGroupMembReductions);
+		ICMP6_INC_STATS(dev, Icmp6OutGroupMembReductions);
 	else
-		ICMP6_INC_STATS(Icmp6OutGroupMembResponses);
-	ICMP6_INC_STATS(Icmp6OutMsgs);
+		ICMP6_INC_STATS(dev, Icmp6OutGroupMembResponses);
+	ICMP6_INC_STATS(dev, Icmp6OutMsgs);
 	return;
 
 out:
diff -Naurp -X /home/rddunlap/doc/dontdiff-osdl linux-2567-pv/net/ipv6/ndisc.c linux-2567-icmpv6/net/ipv6/ndisc.c
--- linux-2567-pv/net/ipv6/ndisc.c	Mon Apr  7 10:31:48 2003
+++ linux-2567-icmpv6/net/ipv6/ndisc.c	Wed Apr  9 14:03:34 2003
@@ -499,8 +499,8 @@ static void ndisc_send_na(struct net_dev
 	skb->dst = dst;
 	dst_output(skb);
 
-	ICMP6_INC_STATS(Icmp6OutNeighborAdvertisements);
-	ICMP6_INC_STATS(Icmp6OutMsgs);
+	ICMP6_INC_STATS(dev, Icmp6OutNeighborAdvertisements);
+	ICMP6_INC_STATS(dev, Icmp6OutMsgs);
 }        
 
 void ndisc_send_ns(struct net_device *dev, struct neighbour *neigh,
@@ -578,8 +578,8 @@ void ndisc_send_ns(struct net_device *de
 	skb->dst = dst;
 	dst_output(skb);
 
-	ICMP6_INC_STATS(Icmp6OutNeighborSolicits);
-	ICMP6_INC_STATS(Icmp6OutMsgs);
+	ICMP6_INC_STATS(dev, Icmp6OutNeighborSolicits);
+	ICMP6_INC_STATS(dev, Icmp6OutMsgs);
 }
 
 void ndisc_send_rs(struct net_device *dev, struct in6_addr *saddr,
@@ -646,8 +646,8 @@ void ndisc_send_rs(struct net_device *de
 	skb->dst = dst;
 	dst_output(skb);
 
-	ICMP6_INC_STATS(Icmp6OutRouterSolicits);
-	ICMP6_INC_STATS(Icmp6OutMsgs);
+	ICMP6_INC_STATS(dev, Icmp6OutRouterSolicits);
+	ICMP6_INC_STATS(dev, Icmp6OutMsgs);
 }
 		   
 
@@ -1381,8 +1381,8 @@ void ndisc_send_redirect(struct sk_buff 
 	skb->dst = dst;
 	dst_output(skb);
 
-	ICMP6_INC_STATS(Icmp6OutRedirects);
-	ICMP6_INC_STATS(Icmp6OutMsgs);
+	ICMP6_INC_STATS(dev, Icmp6OutRedirects);
+	ICMP6_INC_STATS(dev, Icmp6OutMsgs);
 }
 
 static void pndisc_redo(struct sk_buff *skb)
diff -Naurp -X /home/rddunlap/doc/dontdiff-osdl linux-2567-pv/net/ipv6/proc.c linux-2567-icmpv6/net/ipv6/proc.c
--- linux-2567-pv/net/ipv6/proc.c	Mon Apr  7 10:31:05 2003
+++ linux-2567-icmpv6/net/ipv6/proc.c	Wed Apr  9 14:37:48 2003
@@ -19,6 +19,7 @@
 #include <linux/sched.h>
 #include <linux/socket.h>
 #include <linux/net.h>
+#include <linux/netdevice.h>
 #include <linux/ipv6.h>
 #include <linux/proc_fs.h>
 #include <linux/seq_file.h>
@@ -53,12 +54,14 @@ static int sockstat6_seq_show(struct seq
 }
 
 
-static struct snmp6_item
+struct snmp6_item
 {
 	char *name;
 	void **mib;
 	int   offset;
-} snmp6_list[] = {
+};
+
+static struct snmp6_item snmp6_ipv6_list[] = {
 /* ipv6 mib according to draft-ietf-ipngwg-ipv6-mib-04 */
 #define SNMP6_GEN(x) { #x , (void **)ipv6_statistics, offsetof(struct ipv6_mib, x) }
 	SNMP6_GEN(Ip6InReceives),
@@ -84,6 +87,8 @@ static struct snmp6_item
 	SNMP6_GEN(Ip6InMcastPkts),
 	SNMP6_GEN(Ip6OutMcastPkts),
 #undef SNMP6_GEN
+};
+
 /* icmpv6 mib according to draft-ietf-ipngwg-ipv6-icmp-mib-02
 
    Exceptions:  {In|Out}AdminProhibs are removed, because I see
@@ -94,7 +99,8 @@ static struct snmp6_item
 		OutRouterAdvertisements too.
 		OutGroupMembQueries too.
  */
-#define SNMP6_GEN(x) { #x , (void **)icmpv6_statistics, offsetof(struct icmpv6_mib, x) }
+static struct snmp6_item snmp6_icmp6_list[] = {
+#define SNMP6_GEN(x) { #x , NULL, offsetof(struct icmpv6_mib, x) }
 	SNMP6_GEN(Icmp6InMsgs),
 	SNMP6_GEN(Icmp6InErrors),
 	SNMP6_GEN(Icmp6InDestUnreachs),
@@ -124,6 +130,9 @@ static struct snmp6_item
 	SNMP6_GEN(Icmp6OutGroupMembResponses),
 	SNMP6_GEN(Icmp6OutGroupMembReductions),
 #undef SNMP6_GEN
+};
+
+static struct snmp6_item snmp6_udp6_list[] = {
 #define SNMP6_GEN(x) { "Udp6" #x , (void **)udp_stats_in6, offsetof(struct udp_mib, Udp##x) }
 	SNMP6_GEN(InDatagrams),
 	SNMP6_GEN(NoPorts),
@@ -151,13 +160,46 @@ fold_field(void *mib[], int offt)
         return res;
 }
 
+static inline unsigned long
+fold_field_per_if(void *mib[], int offt)
+{
+	return *((unsigned long *) (((void *)mib[0]) + offt))
+		+ *((unsigned long *) (((void *)mib[1]) + offt));
+}
+
 static int snmp6_seq_show(struct seq_file *seq, void *v)
 {
 	int i;
+	struct net_device *dev;
 
-	for (i=0; i<sizeof(snmp6_list)/sizeof(snmp6_list[0]); i++)
-		seq_printf(seq, "%-32s\t%lu\n", snmp6_list[i].name,
-			       fold_field(snmp6_list[i].mib, snmp6_list[i].offset));
+	for (i=0; i<sizeof(snmp6_ipv6_list)/sizeof(snmp6_ipv6_list[0]); i++)
+		seq_printf(seq, "%-32s\t%lu\n",
+				snmp6_ipv6_list[i].name,
+				fold_field(snmp6_ipv6_list[i].mib, snmp6_ipv6_list[i].offset));
+
+	/* print ICMPv6 stats per network interface */
+	read_lock(&dev_base_lock);
+	for (dev = dev_base; dev; dev = dev->next) {
+	    seq_printf(seq, "interface:%s\n", dev ? dev->name : "dev=nil");
+
+	    for (i=0; i<sizeof(snmp6_icmp6_list)/sizeof(snmp6_icmp6_list[0]); i++) {
+		if (!dev->icmpv6_stats[0] || !dev->icmpv6_stats[1]) {
+			seq_printf(seq, "bad stats ptrs: %p, %p\n",
+					dev->icmpv6_stats[0], dev->icmpv6_stats[1]);
+			break;
+		}
+		else
+			seq_printf(seq, "%-32s\t%lu\n",
+				snmp6_icmp6_list[i].name,
+				fold_field_per_if((void *)dev->icmpv6_stats, snmp6_icmp6_list[i].offset));
+	    }
+	}
+	read_unlock(&dev_base_lock);
+
+	for (i=0; i<sizeof(snmp6_udp6_list)/sizeof(snmp6_udp6_list[0]); i++)
+		seq_printf(seq, "%-32s\t%lu\n",
+				snmp6_udp6_list[i].name,
+				fold_field(snmp6_udp6_list[i].mib, snmp6_udp6_list[i].offset));
 
 	return 0;
 }
diff -Naurp -X /home/rddunlap/doc/dontdiff-osdl linux-2567-pv/net/ipv6/tcp_ipv6.c linux-2567-icmpv6/net/ipv6/tcp_ipv6.c
--- linux-2567-pv/net/ipv6/tcp_ipv6.c	Mon Apr  7 10:31:45 2003
+++ linux-2567-icmpv6/net/ipv6/tcp_ipv6.c	Wed Apr  9 14:03:34 2003
@@ -751,7 +751,7 @@ static void tcp_v6_err(struct sk_buff *s
 	sk = tcp_v6_lookup(&hdr->daddr, th->dest, &hdr->saddr, th->source, skb->dev->ifindex);
 
 	if (sk == NULL) {
-		ICMP6_INC_STATS_BH(Icmp6InErrors);
+		ICMP6_INC_STATS_BH(skb->dev, Icmp6InErrors);
 		return;
 	}
 
