From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [PATCH 02/12 -Rev2] Changes to netdevice.h
Date: Sun, 22 Jul 2007 14:35:16 +0530
Message-ID: <20070722090516.7787.79695.sendpatchset@K50wks273871wss.in.ibm.com>
References: <20070722090457.7787.4601.sendpatchset@K50wks273871wss.in.ibm.com>
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
Received: from ausmtp05.au.ibm.com ([202.81.18.154]:34153 "EHLO
	ausmtp05.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760054AbXGVJEs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Jul 2007 05:04:48 -0400
Received: from d23relay01.au.ibm.com (d23relay01.au.ibm.com [202.81.18.232])
	by ausmtp05.au.ibm.com (8.13.8/8.13.8) with ESMTP id l6M95wvu868408
	for <netdev@vger.kernel.org>; Sun, 22 Jul 2007 19:05:58 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.250.237])
	by d23relay01.au.ibm.com (8.13.8/8.13.8/NCO v8.4) with ESMTP id l6M94DDC057020
	for <netdev@vger.kernel.org>; Sun, 22 Jul 2007 19:04:13 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l6M94iGh005851
	for <netdev@vger.kernel.org>; Sun, 22 Jul 2007 19:04:47 +1000
In-Reply-To: <20070722090457.7787.4601.sendpatchset@K50wks273871wss.in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

diff -ruNp org/include/linux/netdevice.h rev2/include/linux/netdevice.h
--- org/include/linux/netdevice.h	2007-07-20 07:49:28.000000000 +0530
+++ rev2/include/linux/netdevice.h	2007-07-22 13:20:16.000000000 +0530
@@ -340,6 +340,7 @@ struct net_device
 #define NETIF_F_VLAN_CHALLENGED	1024	/* Device cannot handle VLAN packets */
 #define NETIF_F_GSO		2048	/* Enable software GSO. */
 #define NETIF_F_LLTX		4096	/* LockLess TX */
+#define NETIF_F_BATCH_ON	8192	/* Batching skbs xmit API is enabled */
 #define NETIF_F_MULTI_QUEUE	16384	/* Has multiple TX/RX queues */
 
 	/* Segmentation offload features */
@@ -452,6 +453,7 @@ struct net_device
 	struct Qdisc		*qdisc_sleeping;
 	struct list_head	qdisc_list;
 	unsigned long		tx_queue_len;	/* Max frames per queue allowed */
+	struct sk_buff_head	skb_blist;	/* List of batch skbs */
 
 	/* Partially transmitted GSO packet. */
 	struct sk_buff		*gso_skb;
@@ -472,6 +474,9 @@ struct net_device
 	void			*priv;	/* pointer to private data	*/
 	int			(*hard_start_xmit) (struct sk_buff *skb,
 						    struct net_device *dev);
+	int			(*hard_start_xmit_batch) (struct net_device
+							  *dev);
+
 	/* These may be needed for future network-power-down code. */
 	unsigned long		trans_start;	/* Time (in jiffies) of last Tx	*/
 
@@ -582,6 +587,8 @@ struct net_device
 #define	NETDEV_ALIGN		32
 #define	NETDEV_ALIGN_CONST	(NETDEV_ALIGN - 1)
 
+#define BATCHING_ON(dev)	((dev->features & NETIF_F_BATCH_ON) != 0)
+
 static inline void *netdev_priv(const struct net_device *dev)
 {
 	return dev->priv;
@@ -832,6 +839,8 @@ extern int		dev_set_mac_address(struct n
 					    struct sockaddr *);
 extern int		dev_hard_start_xmit(struct sk_buff *skb,
 					    struct net_device *dev);
+extern int		dev_add_skb_to_blist(struct sk_buff *skb,
+					     struct net_device *dev);
 
 extern void		dev_init(void);
 
@@ -1104,6 +1113,8 @@ extern void		dev_set_promiscuity(struct 
 extern void		dev_set_allmulti(struct net_device *dev, int inc);
 extern void		netdev_state_change(struct net_device *dev);
 extern void		netdev_features_change(struct net_device *dev);
+extern int		dev_change_tx_batching(struct net_device *dev,
+					       unsigned long new_batch_skb);
 /* Load a device via the kmod */
 extern void		dev_load(const char *name);
 extern void		dev_mcast_init(void);
