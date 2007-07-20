From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [PATCH 02/10] Networking include file changes.
Date: Fri, 20 Jul 2007 12:02:16 +0530
Message-ID: <20070720063216.26341.80316.sendpatchset@localhost.localdomain>
References: <20070720063149.26341.84076.sendpatchset@localhost.localdomain>
Cc: johnpol@2ka.mipt.ru, Robert.Olsson@data.slu.se,
	peter.p.waskiewicz.jr@intel.com, herbert@gondor.apana.org.au,
	gaagaan@gmail.com, kumarkr@linux.ibm.com, xma@us.ibm.com,
	rick.jones2@hp.com, mcarlson@broadcom.com, netdev@vger.kernel.org,
	jagana@us.ibm.com, general@lists.openfabrics.org,
	mchan@broadcom.com, tgraf@suug.ch, jeff@garzik.org,
	hadi@cyberus.ca, kaber@trash.net,
	Krishna Kumar <krkumar2@in.ibm.com>, sri@us.ibm.com
To: davem@davemloft.net, rdreier@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausmtp04.au.ibm.com ([202.81.18.152]:60868 "EHLO
	ausmtp04.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754924AbXGTGeH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jul 2007 02:34:07 -0400
Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by ausmtp04.au.ibm.com (8.13.8/8.13.8) with ESMTP id l6K6tN63267896
	for <netdev@vger.kernel.org>; Fri, 20 Jul 2007 16:55:30 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.250.243])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.4) with ESMTP id l6K6ZWmx162830
	for <netdev@vger.kernel.org>; Fri, 20 Jul 2007 16:35:39 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l6K6VpGm015124
	for <netdev@vger.kernel.org>; Fri, 20 Jul 2007 16:31:54 +1000
In-Reply-To: <20070720063149.26341.84076.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Networking include file changes for batching.

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
---
 linux/netdevice.h |   10 ++++++++++
 net/pkt_sched.h   |    6 +++---
 2 files changed, 13 insertions(+), 3 deletions(-)

diff -ruNp org/include/linux/netdevice.h new/include/linux/netdevice.h
--- org/include/linux/netdevice.h	2007-07-20 07:49:28.000000000 +0530
+++ new/include/linux/netdevice.h	2007-07-20 08:30:55.000000000 +0530
@@ -264,6 +264,8 @@ enum netdev_state_t
 	__LINK_STATE_QDISC_RUNNING,
 };
 
+/* Minimum length of device hardware queue for batching to work */
+#define MIN_QUEUE_LEN_BATCH	16
 
 /*
  * This structure holds at boot time configured netdevice settings. They
@@ -340,6 +342,7 @@ struct net_device
 #define NETIF_F_VLAN_CHALLENGED	1024	/* Device cannot handle VLAN packets */
 #define NETIF_F_GSO		2048	/* Enable software GSO. */
 #define NETIF_F_LLTX		4096	/* LockLess TX */
+#define NETIF_F_BATCH_SKBS	8192	/* Driver supports batch skbs API */
 #define NETIF_F_MULTI_QUEUE	16384	/* Has multiple TX/RX queues */
 
 	/* Segmentation offload features */
@@ -452,6 +455,8 @@ struct net_device
 	struct Qdisc		*qdisc_sleeping;
 	struct list_head	qdisc_list;
 	unsigned long		tx_queue_len;	/* Max frames per queue allowed */
+	unsigned long		xmit_slots;	/* Device free slots */
+	struct sk_buff_head	*skb_blist;	/* List of batch skbs */
 
 	/* Partially transmitted GSO packet. */
 	struct sk_buff		*gso_skb;
@@ -472,6 +477,9 @@ struct net_device
 	void			*priv;	/* pointer to private data	*/
 	int			(*hard_start_xmit) (struct sk_buff *skb,
 						    struct net_device *dev);
+	int			(*hard_start_xmit_batch) (struct net_device
+							  *dev);
+
 	/* These may be needed for future network-power-down code. */
 	unsigned long		trans_start;	/* Time (in jiffies) of last Tx	*/
 
@@ -832,6 +840,8 @@ extern int		dev_set_mac_address(struct n
 					    struct sockaddr *);
 extern int		dev_hard_start_xmit(struct sk_buff *skb,
 					    struct net_device *dev);
+extern int		dev_add_skb_to_blist(struct sk_buff *skb,
+					     struct net_device *dev);
 
 extern void		dev_init(void);
 
diff -ruNp org/include/net/pkt_sched.h new/include/net/pkt_sched.h
--- org/include/net/pkt_sched.h	2007-07-20 07:49:28.000000000 +0530
+++ new/include/net/pkt_sched.h	2007-07-20 08:30:22.000000000 +0530
@@ -80,13 +80,13 @@ extern struct qdisc_rate_table *qdisc_ge
 		struct rtattr *tab);
 extern void qdisc_put_rtab(struct qdisc_rate_table *tab);
 
-extern void __qdisc_run(struct net_device *dev);
+extern void __qdisc_run(struct net_device *dev, struct sk_buff_head *blist);
 
-static inline void qdisc_run(struct net_device *dev)
+static inline void qdisc_run(struct net_device *dev, struct sk_buff_head *blist)
 {
 	if (!netif_queue_stopped(dev) &&
 	    !test_and_set_bit(__LINK_STATE_QDISC_RUNNING, &dev->state))
-		__qdisc_run(dev);
+		__qdisc_run(dev, blist);
 }
 
 extern int tc_classify_compat(struct sk_buff *skb, struct tcf_proto *tp,
