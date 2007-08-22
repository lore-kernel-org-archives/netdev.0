From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [PATCH 2/10 Rev4] [core] Add skb_blist & support for batching
Date: Wed, 22 Aug 2007 13:59:17 +0530
Message-ID: <20070822082917.11964.52051.sendpatchset@localhost.localdomain>
References: <20070822082839.11964.63503.sendpatchset@localhost.localdomain>
Cc: jagana@us.ibm.com, Robert.Olsson@data.slu.se, rick.jones2@hp.com,
	xma@us.ibm.com, gaagaan@gmail.com, kumarkr@linux.ibm.com,
	rdreier@cisco.com, peter.p.waskiewicz.jr@intel.com,
	mcarlson@broadcom.com, jeff@garzik.org,
	Krishna Kumar <krkumar2@in.ibm.com>,
	general@lists.openfabrics.org, netdev@vger.kernel.org,
	tgraf@suug.ch, mchan@broadcom.com, sri@us.ibm.com
To: johnpol@2ka.mipt.ru, herbert@gondor.apana.org.au, hadi@cyberus.ca,
	kaber@trash.net, shemminger@linux-foundation.org,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:49412 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750948AbXHVI1s (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Aug 2007 04:27:48 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l7M8T9AV030403
	for <netdev@vger.kernel.org>; Wed, 22 Aug 2007 04:29:09 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l7M8RlUR530198
	for <netdev@vger.kernel.org>; Wed, 22 Aug 2007 04:27:47 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l7M8RimG025063
	for <netdev@vger.kernel.org>; Wed, 22 Aug 2007 04:27:47 -0400
In-Reply-To: <20070822082839.11964.63503.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Introduce skb_blist, NETIF_F_BATCH_SKBS, use single API for
batching/no-batching, etc.

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
---
 include/linux/netdevice.h |    4 ++++
 net/core/dev.c            |   21 ++++++++++++++++++---
 2 files changed, 22 insertions(+), 3 deletions(-)

diff -ruNp org/include/linux/netdevice.h new/include/linux/netdevice.h
--- org/include/linux/netdevice.h	2007-08-20 14:26:36.000000000 +0530
+++ new/include/linux/netdevice.h	2007-08-22 08:42:10.000000000 +0530
@@ -399,6 +399,7 @@ struct net_device
 #define NETIF_F_VLAN_CHALLENGED	1024	/* Device cannot handle VLAN packets */
 #define NETIF_F_GSO		2048	/* Enable software GSO. */
 #define NETIF_F_LLTX		4096	/* LockLess TX */
+#define NETIF_F_BATCH_SKBS	8192	/* Driver supports multiple skbs/xmit */
 #define NETIF_F_MULTI_QUEUE	16384	/* Has multiple TX/RX queues */
 #define NETIF_F_LRO		32768	/* large receive offload */
 
@@ -510,6 +511,9 @@ struct net_device
 	/* Partially transmitted GSO packet. */
 	struct sk_buff		*gso_skb;
 
+	/* List of batch skbs (optional, used if driver supports skb batching */
+	struct sk_buff_head	*skb_blist;
+
 	/* ingress path synchronizer */
 	spinlock_t		ingress_lock;
 	struct Qdisc		*qdisc_ingress;
diff -ruNp org/net/core/dev.c new/net/core/dev.c
--- org/net/core/dev.c	2007-08-20 14:26:37.000000000 +0530
+++ new/net/core/dev.c	2007-08-22 10:49:22.000000000 +0530
@@ -898,6 +898,16 @@ void netdev_state_change(struct net_devi
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
@@ -1458,7 +1468,9 @@ static int dev_gso_segment(struct sk_buf
 
 int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	if (likely(!skb->next)) {
+	if (likely(skb)) {
+		if (unlikely(skb->next))
+			goto gso;
 		if (!list_empty(&ptype_all))
 			dev_queue_xmit_nit(skb, dev);
 
@@ -1468,10 +1480,10 @@ int dev_hard_start_xmit(struct sk_buff *
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
@@ -3791,6 +3803,9 @@ void unregister_netdevice(struct net_dev
 
 	synchronize_net();
 
+	/* Deallocate batching structure */
+	free_batching(dev);
+
 	/* Shutdown queueing discipline. */
 	dev_shutdown(dev);
 
