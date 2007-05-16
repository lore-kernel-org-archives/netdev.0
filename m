From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: [WIP] [PATCH] WAS Re: [RFC] New driver API to speed up small
	packets xmits
Date: Wed, 16 May 2007 15:12:03 -0700
Message-ID: <1179353523.10414.12.camel@w-sridhar2.beaverton.ibm.com>
References: <adahcqdpz1p.fsf@cisco.com>
	 <OFF5654BB8.74EC8DCB-ON872572DC.00752079-882572DC.00756B23@us.ibm.com>
	 <20070515.143207.80029051.davem@davemloft.net>
	 <1179267467.4080.33.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, xma@us.ibm.com,
	rdreier@cisco.com, ak@suse.de, krkumar2@in.ibm.com,
	netdev@vger.kernel.org, netdev-owner@vger.kernel.org,
	ashwin.chaugule@celunite.com,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Gagan Arneja <gagan@vmware.com>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:40150 "EHLO e3.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755359AbXEPWMJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 May 2007 18:12:09 -0400
In-Reply-To: <1179267467.4080.33.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jamal,

Here are some comments i have on your patch.
See them inline.

Thanks
Sridhar

+static int try_get_tx_pkts(struct net_device *dev, struct Qdisc *q, int count)
+{
+       struct sk_buff *skb;
+       struct sk_buff_head *skbs = &dev->blist;
+       int tdq = count;
+
+       /* 
+        * very unlikely, but who knows ..
+        * If this happens we dont try to grab more pkts
+        */
+       if (!skb_queue_empty(&dev->blist))
+               return skb_queue_len(&dev->blist);
+
+       if (dev->gso_skb) {
+               count--;
+               __skb_queue_head(skbs, dev->gso_skb);
+               dev->gso_skb = NULL;
+       }

AFAIK, gso_skb can be a list of skb's. Can we add a list
to another list using __skb_queue_head()?
Also, if gso_skb is a list of multiple skb's, i think the
count needs to be decremented by the number of segments in
gso_skb.

+
+       while (count) {
+               skb = q->dequeue(q);
+               if (!skb)
+                       break;
+               count--;
+               __skb_queue_head(skbs, skb);
+       }
+
+       return tdq - count;
+}
+
+static inline int try_tx_pkts(struct net_device *dev)
+{
+
+       return dev->hard_batch_xmit(&dev->blist, dev);
+
+}
+
+/* same comments as in qdisc_restart apply;
+ * at some point use shared code with qdisc_restart*/
+int batch_qdisc_restart(struct net_device *dev)
+{
+       struct Qdisc *q = dev->qdisc;
+       unsigned lockless = (dev->features & NETIF_F_LLTX);
+       int count = dev->xmit_win;
+       int ret = 0;
+
+       ret = try_get_tx_pkts(dev, q, count);
+
+       if (ret == 0)
+               return qdisc_qlen(q);
+
+       /* we have packets to send! */
+       if (!lockless) {
+               if (!netif_tx_trylock(dev))
+                       return tx_islocked(NULL, dev, q);
+       }
+
+       /* all clear .. */
+       spin_unlock(&dev->queue_lock);
+
+       ret = NETDEV_TX_BUSY;
+       if (!netif_queue_stopped(dev))
+               ret = try_tx_pkts(dev);

try_tx_pkts() is directly calling the device's batch xmit routine.
Don't we need to call dev_hard_start_xmit() to handle dev_queue_xmit_nit
and GSO segmentation?

+
+       if (!lockless)
+               netif_tx_unlock(dev);
+
+       spin_lock(&dev->queue_lock);
+
+       q = dev->qdisc;
+
+       /* most likely result, packet went ok */
+       if (ret == NETDEV_TX_OK)
+               return qdisc_qlen(q);
+       /* only for lockless drivers .. */
+       if (ret == NETDEV_TX_LOCKED && lockless)
+               return tx_islocked(NULL, dev, q);
+
+       if (unlikely(ret != NETDEV_TX_BUSY && net_ratelimit()))
+               printk(KERN_WARNING " BUG %s code %d qlen %d\n",
+                      dev->name, ret, q->q.qlen);
+
+       return do_dev_requeue(NULL, dev, q);
+}



