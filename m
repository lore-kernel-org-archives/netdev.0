From: Abhishek <guptaa80@ymail.com>
Subject: Problem with passing =?utf-8?b?cHR5cGVfYmFzZQ==?= list as a function argument
Date: Mon, 19 Jul 2010 05:01:59 +0000 (UTC)
Message-ID: <loom.20100719T063120-919@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:39001 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751832Ab0GSFFF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Jul 2010 01:05:05 -0400
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1OaiXH-0000Jm-2p
	for netdev@vger.kernel.org; Mon, 19 Jul 2010 07:05:03 +0200
Received: from ABTS-KK-Static-ILP-034.159.181.122.airtel.in ([ABTS-KK-Static-ILP-034.159.181.122.airtel.in])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 19 Jul 2010 07:05:03 +0200
Received: from guptaa80 by ABTS-KK-Static-ILP-034.159.181.122.airtel.in with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 19 Jul 2010 07:05:03 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all

I want to pass ptype_base list as an argument to a function defined in dev.c. 
The problem that I am facing once this is done is a kernel crash after execution 
of the kernel with the patch. Please let me know why there is crash? What is 
going wrong over here? Do we require any other lock apart from rcu_read_lock() 
which is already part of dev.c?

The relevant details are as follows:

Kernel version: 2.6.27-17.46
Defined Function name and definition:
 
struct sk_buff * foo(struct sk_buff*, struct list_head *)
{
         struct packet_type *ptype, *pt_prev;
         struct net_device *orig_dev;
         struct net_device *null_or_orig;
         int ret = NET_RX_DROP;
         __be16 type;

       pt_prev = NULL;
       null_or_orig = NULL;
       orig_dev = skb->dev;
       type = skb->protocol;

        list_for_each_entry_rcu(ptype, head, list) {
                 if (ptype->type == type && (ptype->dev == null_or_orig ||
                      ptype->dev == skb->dev || ptype->dev == orig_dev ||
                      ptype->dev == null_or_bond)) {
                         if (pt_prev)
                                 ret = deliver_skb(skb, pt_prev, orig_dev);
                         pt_prev = ptype;
                 }
         }
 
         if (pt_prev) {
                 ret = pt_prev->func(skb, skb->dev, pt_prev, orig_dev);
         } else {
                 kfree_skb(skb);
                 /* Jamal, now you will not able to escape explaining
                  * me how you were going to use this. :-)
                  */
                 ret = NET_RX_DROP;
         }
    if (ret)
      return skb;
 return NULL;
}

net/core/dev.c Patch:

 75 #include <asm/uaccess.h>
 76 #include <asm/system.h>
 77 #include <linux/bitops.h>
 78 #include <linux/capability.h>
 79 #include <linux/cpu.h>
 80 #include <linux/types.h>
 81 #include <linux/kernel.h>
 82 #include <linux/hash.h>
 83 #include <linux/slab.h>
 84 #include <linux/sched.h>
 85 #include <linux/mutex.h>
 86 #include <linux/string.h>
 87 #include <linux/mm.h>
 88 #include <linux/socket.h>
 89 #include <linux/sockios.h>
 90 #include <linux/errno.h>
 91 #include <linux/interrupt.h>
 92 #include <linux/if_ether.h>
 93 #include <linux/netdevice.h>
 94 #include <linux/etherdevice.h>
 95 #include <linux/ethtool.h>
 96 #include <linux/notifier.h>
 97 #include <linux/skbuff.h>
 98 #include <net/net_namespace.h>
 99 #include <net/sock.h>
100 #include <linux/rtnetlink.h>
101 #include <linux/proc_fs.h>
102 #include <linux/seq_file.h>
103 #include <linux/stat.h>
104 #include <linux/if_bridge.h>
105 #include <linux/if_macvlan.h>
106 #include <net/dst.h>
107 #include <net/pkt_sched.h>
108 #include <net/checksum.h>
109 #include <net/xfrm.h>
110 #include <linux/highmem.h>
111 #include <linux/init.h>
112 #include <linux/kmod.h>
113 #include <linux/module.h>
114 #include <linux/netpoll.h>
115 #include <linux/rcupdate.h>
116 #include <linux/delay.h>
117 #include <net/wext.h>
118 #include <net/iw_handler.h>
119 #include <asm/current.h>
120 #include <linux/audit.h>
121 #include <linux/dmaengine.h>
122 #include <linux/err.h>
123 #include <linux/ctype.h>
124 #include <linux/if_arp.h>
125 #include <linux/if_vlan.h>
126 #include <linux/ip.h>
127 #include <net/ip.h>
128 #include <linux/ipv6.h>
129 #include <linux/in.h>
130 #include <linux/jhash.h>
131 #include <linux/random.h>
132 #include <trace/events/napi.h>
133 
134 #include "net-sysfs.h"
135 
136 /* Instead of increasing this, you should create a hash table. */
137 #define MAX_GRO_SKBS 8
138 
139 /* This should be increased if a protocol with a bigger head is added. */
140 #define GRO_MAX_HEAD (MAX_HEADER + 128)
141 
142 /*
143  *      The list of packet types we will receive (as opposed to discard)
144  *      and the routines to invoke.
145  *
146  *      Why 16. Because with 16 the only overlap we get on a hash of the
147  *      low nibble of the protocol value is RARP/SNAP/X.25.
148  *
149  *      NOTE:  That is no longer true with the addition of VLAN tags.  Not
150  *             sure which should go first, but I bet it won't make much
151  *             difference if we are running VLANs.  The good news is that
152  *             this protocol won't be in the list unless compiled in, so
153  *             the average user (w/out VLANs) will not be adversely 
affected.
154  *             --BLG
155  *
156  *              0800    IP
157  *              8100    802.1Q VLAN
158  *              0001    802.3
159  *              0002    AX.25
160  *              0004    802.2
161  *              8035    RARP
162  *              0005    SNAP
163  *              0805    X.25
164  *              0806    ARP
165  *              8137    IPX
166  *              0009    Localtalk
167  *              86DD    IPv6
168  */
169 
170 #define PTYPE_HASH_SIZE (16)
171 #define PTYPE_HASH_MASK (PTYPE_HASH_SIZE - 1)
172 
173 static DEFINE_SPINLOCK(ptype_lock);
174 static struct list_head ptype_base[PTYPE_HASH_SIZE] __read_mostly;
175 static struct list_head ptype_all __read_mostly;        /* Taps */
 
+ struct sk_buff* foo(struct sk_buff*, struct list_head *);

             .
             .
             .
             .

int netif_receive_skb(struct sk_buff *skb)
2487 {
2488         struct packet_type *ptype, *pt_prev;
2489         struct net_device *orig_dev;
2490         struct net_device *master;
2491         struct net_device *null_or_orig;
2492         struct net_device *null_or_bond;
2493         int ret = NET_RX_DROP;
2494         __be16 type;
2495 
2496         if (!skb->tstamp.tv64)
2497                 net_timestamp(skb);
2498 
2499         if (vlan_tx_tag_present(skb) && vlan_hwaccel_do_receive(skb))
2500                 return NET_RX_SUCCESS;
2501 
2502         /* if we've gotten here through NAPI, check netpoll */
2503         if (netpoll_receive_skb(skb))
2504                 return NET_RX_DROP;
2505 
2506         if (!skb->skb_iif)
2507                 skb->skb_iif = skb->dev->ifindex;
2508 
2509         null_or_orig = NULL;
2510         orig_dev = skb->dev;
2511         master = ACCESS_ONCE(orig_dev->master);
2512         if (master) {
2513                 if (skb_bond_should_drop(skb, master))
2514                         null_or_orig = orig_dev; /* deliver only exact 
match */
2515                 else
2516                         skb->dev = master;
2517         }
2518 
2519         __get_cpu_var(netdev_rx_stat).total++;
2520 
2521         skb_reset_network_header(skb);
2522         skb_reset_transport_header(skb);
2523         skb->mac_len = skb->network_header - skb->mac_header;
2524 
2525         pt_prev = NULL;
2526 
2527         rcu_read_lock();
2528 
2529 #ifdef CONFIG_NET_CLS_ACT
2530         if (skb->tc_verd & TC_NCLS) {
2531                 skb->tc_verd = CLR_TC_NCLS(skb->tc_verd);
2532                 goto ncls;
2533         }
2534 #endif
2535 
2536         list_for_each_entry_rcu(ptype, &ptype_all, list) {
2537                 if (ptype->dev == null_or_orig || ptype->dev == skb->dev ||
2538                     ptype->dev == orig_dev) {
2539                         if (pt_prev)
2540                                 ret = deliver_skb(skb, pt_prev, orig_dev);
2541                         pt_prev = ptype;
2542                 }
2543         }
2544 
2545 #ifdef CONFIG_NET_CLS_ACT
2546         skb = handle_ing(skb, &pt_prev, &ret, orig_dev);
2547         if (!skb)
2548                 goto out;
2549 ncls:
2550 #endif

+ skb = foo(skb, &ptype_base[ntohs(skb-<protocol) & PTYPE_HASK_MASK]);
 
2552         skb = handle_bridge(skb, &pt_prev, &ret, orig_dev);
2553         if (!skb)
2554                 goto out;
2555         skb = handle_macvlan(skb, &pt_prev, &ret, orig_dev);
2556         if (!skb)
2557                 goto out;
2558 
2559         /*
2560          * Make sure frames received on VLAN interfaces stacked on
2561          * bonding interfaces still make their way to any base bonding
2562          * device that may have registered for a specific ptype.  The
2563          * handler may have to adjust skb->dev and orig_dev.
2564          */
2565         null_or_bond = NULL;
2566         if ((skb->dev->priv_flags & IFF_802_1Q_VLAN) &&
2567             (vlan_dev_real_dev(skb->dev)->priv_flags & IFF_BONDING)) {
2568                 null_or_bond = vlan_dev_real_dev(skb->dev);
2569         }
2570 
2571         type = skb->protocol;
2572         list_for_each_entry_rcu(ptype,
2573                         &ptype_base[ntohs(type) & PTYPE_HASH_MASK], list) {
2574                 if (ptype->type == type && (ptype->dev == null_or_orig ||
2575                      ptype->dev == skb->dev || ptype->dev == orig_dev ||
2576                      ptype->dev == null_or_bond)) {
2577                         if (pt_prev)
2578                                 ret = deliver_skb(skb, pt_prev, orig_dev);
2579                         pt_prev = ptype;
2580                 }
2581         }
2582 
2583         if (pt_prev) {
2584                 ret = pt_prev->func(skb, skb->dev, pt_prev, orig_dev);
2585         } else {
2586                 kfree_skb(skb);
2587                 /* Jamal, now you will not able to escape explaining
2588                  * me how you were going to use this. :-)
2589                  */
2590                 ret = NET_RX_DROP;
2591         }
2592 
2593 out:
2594         rcu_read_unlock();
2595         return ret;
2596 }
2597 EXPORT_SYMBOL(netif_receive_skb);

