From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [PATCH 04/10] net-sysfs.c changes.
Date: Fri, 20 Jul 2007 12:02:38 +0530
Message-ID: <20070720063238.26341.41474.sendpatchset@localhost.localdomain>
References: <20070720063149.26341.84076.sendpatchset@localhost.localdomain>
Cc: johnpol@2ka.mipt.ru, Robert.Olsson@data.slu.se,
	peter.p.waskiewicz.jr@intel.com, herbert@gondor.apana.org.au,
	gaagaan@gmail.com, kumarkr@linux.ibm.com, xma@us.ibm.com,
	rick.jones2@hp.com, mcarlson@broadcom.com, jagana@us.ibm.com,
	mchan@broadcom.com, general@lists.openfabrics.org,
	netdev@vger.kernel.org, tgraf@suug.ch, jeff@garzik.org,
	hadi@cyberus.ca, kaber@trash.net,
	Krishna Kumar <krkumar2@in.ibm.com>, sri@us.ibm.com
To: davem@davemloft.net, rdreier@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausmtp06.au.ibm.com ([202.81.18.155]:52915 "EHLO
	ausmtp06.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755102AbXGTGee (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jul 2007 02:34:34 -0400
Received: from sd0112e0.au.ibm.com (d23rh903.au.ibm.com [202.81.18.201])
	by ausmtp06.au.ibm.com (8.13.8/8.13.8) with ESMTP id l6K6Z1wl798774
	for <netdev@vger.kernel.org>; Fri, 20 Jul 2007 16:35:02 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.250.243])
	by sd0112e0.au.ibm.com (8.13.8/8.13.8/NCO v8.4) with ESMTP id l6K6ZuuZ212934
	for <netdev@vger.kernel.org>; Fri, 20 Jul 2007 16:36:08 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l6K6WDLu016073
	for <netdev@vger.kernel.org>; Fri, 20 Jul 2007 16:32:16 +1000
In-Reply-To: <20070720063149.26341.84076.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Support to turn on/off batching from /sys.

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
---
 net-sysfs.c |   70 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 70 insertions(+)

diff -ruNp org/net/core/net-sysfs.c new/net/core/net-sysfs.c
--- org/net/core/net-sysfs.c	2007-07-20 07:49:28.000000000 +0530
+++ new/net/core/net-sysfs.c	2007-07-20 08:34:45.000000000 +0530
@@ -230,6 +230,74 @@ static ssize_t store_weight(struct devic
 	return netdev_store(dev, attr, buf, len, change_weight);
 }
 
+static ssize_t show_tx_batch_skbs(struct device *dev,
+				  struct device_attribute *attr, char *buf)
+{
+	struct net_device *netdev = to_net_dev(dev);
+
+	return sprintf(buf, fmt_dec, netdev->skb_blist ? 1 : 0);
+}
+
+static int change_tx_batch_skbs(struct net_device *net,
+				unsigned long new_tx_batch_skbs)
+{
+	int ret = 0;
+	struct sk_buff_head *blist;
+
+	if (!(net->features & NETIF_F_BATCH_SKBS) ||
+	    (new_tx_batch_skbs && net->tx_queue_len < MIN_QUEUE_LEN_BATCH)) {
+		/*
+		 * Driver doesn't support batching SKBS, or the queue len
+		 * is insufficient. TODO: Add similar check to disable
+		 * batching in change_tx_queue_len() if queue_len becomes
+		 * smaller than MIN_QUEUE_LEN_BATCH.
+		 */
+		ret = -ENOTSUPP;
+		goto out;
+	}
+
+	/* Handle invalid argument */
+	if (new_tx_batch_skbs < 0) {
+		ret = -EINVAL;
+		goto out;
+	}
+
+	/* Check if new value is same as the current */
+	new_tx_batch_skbs = !!new_tx_batch_skbs;
+	if (!!net->skb_blist == new_tx_batch_skbs)
+		goto out;
+
+	if (new_tx_batch_skbs &&
+	    (blist = kmalloc(sizeof *blist, GFP_KERNEL)) == NULL) {
+		ret = -ENOMEM;
+		goto out;
+	}
+
+	spin_lock(&net->queue_lock);
+	if (new_tx_batch_skbs) {
+		skb_queue_head_init(blist);
+		net->skb_blist = blist;
+		net->tx_queue_len >>= 1;
+	} else {
+		if (!skb_queue_empty(net->skb_blist))
+			skb_queue_purge(net->skb_blist);
+		kfree(net->skb_blist);
+		net->skb_blist = NULL;
+		net->tx_queue_len <<= 1;
+	}
+	spin_unlock(&net->queue_lock);
+
+out:
+	return ret;
+}
+
+static ssize_t store_tx_batch_skbs(struct device *dev,
+				   struct device_attribute *attr,
+				   const char *buf, size_t len)
+{
+	return netdev_store(dev, attr, buf, len, change_tx_batch_skbs);
+}
+
 static struct device_attribute net_class_attributes[] = {
 	__ATTR(addr_len, S_IRUGO, show_addr_len, NULL),
 	__ATTR(iflink, S_IRUGO, show_iflink, NULL),
@@ -246,6 +314,8 @@ static struct device_attribute net_class
 	__ATTR(flags, S_IRUGO | S_IWUSR, show_flags, store_flags),
 	__ATTR(tx_queue_len, S_IRUGO | S_IWUSR, show_tx_queue_len,
 	       store_tx_queue_len),
+	__ATTR(tx_batch_skbs, S_IRUGO | S_IWUSR, show_tx_batch_skbs,
+	       store_tx_batch_skbs),
 	__ATTR(weight, S_IRUGO | S_IWUSR, show_weight, store_weight),
 	{}
 };
