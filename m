From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [PATCH 2/10 REV5] [core] Add skb_blist & support for batching
Date: Fri, 14 Sep 2007 14:31:37 +0530
Message-ID: <20070914090137.17589.60322.sendpatchset@K50wks273871wss.in.ibm.com>
References: <20070914090058.17589.80352.sendpatchset@K50wks273871wss.in.ibm.com>
Cc: jagana@us.ibm.com, Robert.Olsson@data.slu.se, rick.jones2@hp.com,
	xma@us.ibm.com, gaagaan@gmail.com, kumarkr@linux.ibm.com,
	rdreier@cisco.com, peter.p.waskiewicz.jr@intel.com,
	mcarlson@broadcom.com, jeff@garzik.org,
	Krishna Kumar <krkumar2@in.ibm.com>,
	general@lists.openfabrics.org, netdev@vger.kernel.org,
	tgraf@suug.ch, randy.dunlap@oracle.com, mchan@broadcom.com,
	sri@us.ibm.com
To: johnpol@2ka.mipt.ru, herbert@gondor.apana.org.au, hadi@cyberus.ca,
	kaber@trash.net, shemminger@linux-foundation.org,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:36847 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751638AbXINI7h (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Sep 2007 04:59:37 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l8E8xbmV010479
	for <netdev@vger.kernel.org>; Fri, 14 Sep 2007 04:59:37 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8E8xauX471010
	for <netdev@vger.kernel.org>; Fri, 14 Sep 2007 04:59:36 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8E8xXmR021859
	for <netdev@vger.kernel.org>; Fri, 14 Sep 2007 04:59:36 -0400
In-Reply-To: <20070914090058.17589.80352.sendpatchset@K50wks273871wss.in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Introduce skb_blist, NETIF_F_BATCH_SKBS, use single API for
batching/no-batching, etc.

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
---
 include/linux/netdevice.h |    8 ++++++--
 net/core/dev.c            |   29 ++++++++++++++++++++++++++---
 2 files changed, 32 insertions(+), 5 deletions(-)

diff -ruNp org/include/linux/netdevice.h new/include/linux/netdevice.h
--- org/include/linux/netdevice.h	2007-09-13 09:11:09.000000000 +0530
+++ new/include/linux/netdevice.h	2007-09-14 10:26:21.000000000 +0530
@@ -439,10 +439,11 @@ struct net_device
 #define NETIF_F_NETNS_LOCAL	8192	/* Does not change network namespaces */
 #define NETIF_F_MULTI_QUEUE	16384	/* Has multiple TX/RX queues */
 #define NETIF_F_LRO		32768	/* large receive offload */
+#define NETIF_F_BATCH_SKBS	65536	/* Driver supports multiple skbs/xmit */
 
 	/* Segmentation offload features */
-#define NETIF_F_GSO_SHIFT	16
-#define NETIF_F_GSO_MASK	0xffff0000
+#define NETIF_F_GSO_SHIFT	17
+#define NETIF_F_GSO_MASK	0xfffe0000
 #define NETIF_F_TSO		(SKB_GSO_TCPV4 << NETIF_F_GSO_SHIFT)
 #define NETIF_F_UFO		(SKB_GSO_UDP << NETIF_F_GSO_SHIFT)
 #define NETIF_F_GSO_ROBUST	(SKB_GSO_DODGY << NETIF_F_GSO_SHIFT)
@@ -548,6 +549,9 @@ struct net_device
 	/* Partially transmitted GSO packet. */
 	struct sk_buff		*gso_skb;
 
+	/* List of batch skbs (optional, used if driver supports skb batching */
+	struct sk_buff_head	*skb_blist;
+
 	/* ingress path synchronizer */
 	spinlock_t		ingress_lock;
 	struct Qdisc		*qdisc_ingress;
diff -ruNp org/net/core/dev.c new/net/core/dev.c
--- org/net/core/dev.c	2007-09-14 10:24:27.000000000 +0530
+++ new/net/core/dev.c	2007-09-14 10:25:36.000000000 +0530
@@ -953,6 +953,16 @@ void netdev_state_change(struct net_devi
 	}
 }
 
+static void free_batching(struct net_device *dev)
+{
+	if (dev->skb_blist) {
+		if (!skb_queue_empty(dev->skb_blist))
+			skb_queue_purge(dev->skb_blist);
+		kfree(dev->skb_blist);
+		dev->skb_blist = NULL;
+	}
+}
+
 /**
  *	dev_load 	- load a network module
  *	@name: name of interface
@@ -1534,7 +1544,10 @@ static int dev_gso_segment(struct sk_buf
 
 int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	if (likely(!skb->next)) {
+	if (likely(skb)) {
+		if (unlikely(skb->next))
+			goto gso;
+
 		if (!list_empty(&ptype_all))
 			dev_queue_xmit_nit(skb, dev);
 
@@ -1544,10 +1557,10 @@ int dev_hard_start_xmit(struct sk_buff *
 			if (skb->next)
 				goto gso;
 		}
-
-		return dev->hard_start_xmit(skb, dev);
 	}
 
+	return dev->hard_start_xmit(skb, dev);
+
 gso:
 	do {
 		struct sk_buff *nskb = skb->next;
@@ -3566,6 +3579,13 @@ int register_netdevice(struct net_device
 		}
 	}
 
+	if (dev->features & NETIF_F_BATCH_SKBS) {
+		/* Driver supports batching skb */
+		dev->skb_blist = kmalloc(sizeof *dev->skb_blist, GFP_KERNEL);
+		if (dev->skb_blist)
+			skb_queue_head_init(dev->skb_blist);
+	}
+
 	/*
 	 *	nil rebuild_header routine,
 	 *	that should be never called and used as just bug trap.
@@ -3901,6 +3921,9 @@ void unregister_netdevice(struct net_dev
 
 	synchronize_net();
 
+	/* Deallocate batching structure */
+	free_batching(dev);
+
 	/* Shutdown queueing discipline. */
 	dev_shutdown(dev);
 
