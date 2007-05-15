From: jamal <hadi@cyberus.ca>
Subject: Re: [WIP] [PATCH] WAS Re: [RFC] New driver API to speed up small
	packets xmits
Date: Tue, 15 May 2007 18:48:37 -0400
Message-ID: <1179269317.4080.40.camel@localhost>
References: <adahcqdpz1p.fsf@cisco.com>
	 <OFF5654BB8.74EC8DCB-ON872572DC.00752079-882572DC.00756B23@us.ibm.com>
	 <20070515.143207.80029051.davem@davemloft.net>
	 <1179267467.4080.33.camel@localhost>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-FucwRxjQQqWOpRu6uy9p"
Cc: xma@us.ibm.com, rdreier@cisco.com, ak@suse.de, krkumar2@in.ibm.com,
	netdev@vger.kernel.org, ashwin.chaugule@celunite.com,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Max Krasnyansky <maxk@qualcomm.com>,
	Gagan Arneja <gagan@vmware.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.233]:6115 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756258AbXEOWsm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 May 2007 18:48:42 -0400
Received: by wr-out-0506.google.com with SMTP id 76so2368878wra
        for <netdev@vger.kernel.org>; Tue, 15 May 2007 15:48:42 -0700 (PDT)
In-Reply-To: <1179267467.4080.33.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-FucwRxjQQqWOpRu6uy9p
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Tue, 2007-15-05 at 18:17 -0400, jamal wrote:

> I will post a patch for tun device in a few minutes
> that i use to test on my laptop (i need to remove some debugs) to show
> an example.

Ok, here it is. 
The way i test is to point packets at a tun device. [One way i do it
is attach an ingress qdisc on lo; attach a u32 filter to match all;
on match redirect to the tun device].
The user space program reading sleeps for about a second every 20
packets or so. This forces things to accumulate in the drivers queue.
Backpressure builds up and the throttling effect is really nice to see
working.

I will try to post the e1000 patch tonight or tommorow morning.

cheers,
jamal



--=-FucwRxjQQqWOpRu6uy9p
Content-Disposition: attachment; filename=tun-b
Content-Type: text/x-patch; name=tun-b; charset=us-ascii
Content-Transfer-Encoding: 7bit

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index a2c6caa..076f794 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -70,6 +70,7 @@
 static int debug;
 #endif
 
+#define NETDEV_LTT 4 /* the low threshold to open up the tx path */
 /* Network device part of the driver */
 
 static LIST_HEAD(tun_dev_list);
@@ -86,9 +87,53 @@ static int tun_net_open(struct net_device *dev)
 static int tun_net_close(struct net_device *dev)
 {
 	netif_stop_queue(dev);
+	//skb_queue_purge(&dev->blist);
 	return 0;
 }
 
+/* Batch Net device start xmit
+ * combine with non-batching version
+ * */
+static int tun_net_bxmit(struct sk_buff_head *skbs, struct net_device *dev)
+{
+	struct sk_buff *skb;
+	struct tun_struct *tun = netdev_priv(dev);
+	u32 qlen = skb_queue_len(&tun->readq);
+
+	/* Drop packet if interface is not attached */
+	if (!tun->attached) {
+		tun->stats.tx_dropped+=skb_queue_len(&dev->blist);
+		skb_queue_purge(&dev->blist);
+		return NETDEV_TX_OK;
+	}
+
+	while (skb_queue_len(&dev->blist)) {
+		skb = __skb_dequeue(skbs);
+		if (!skb)
+			break;
+		skb_queue_tail(&tun->readq, skb);
+	}
+
+	qlen = skb_queue_len(&tun->readq);
+	if (qlen >= dev->tx_queue_len) {
+		netif_stop_queue(dev);
+		tun->stats.tx_fifo_errors++;
+		dev->xmit_win = 1;
+	} else {
+		dev->xmit_win = dev->tx_queue_len - qlen;
+	}
+
+	/* Queue packet */
+	dev->trans_start = jiffies;
+
+	/* Notify and wake up reader process */
+	if (tun->flags & TUN_FASYNC)
+		kill_fasync(&tun->fasync, SIGIO, POLL_IN);
+	wake_up_interruptible(&tun->read_wait);
+
+	return NETDEV_TX_OK;
+}
+
 /* Net device start xmit */
 static int tun_net_xmit(struct sk_buff *skb, struct net_device *dev)
 {
@@ -207,6 +252,7 @@ static void tun_net_init(struct net_device *dev)
 		dev->tx_queue_len = TUN_READQ_SIZE;  /* We prefer our own queue length */
 		break;
 	}
+	dev->xmit_win = dev->tx_queue_len>>1; /* handwave, handwave */
 }
 
 /* Character device part */
@@ -382,7 +428,13 @@ static ssize_t tun_chr_aio_read(struct kiocb *iocb, const struct iovec *iv,
 			schedule();
 			continue;
 		}
-		netif_wake_queue(tun->dev);
+		{
+			u32 t = skb_queue_len(&tun->readq);
+			if (netif_queue_stopped(tun->dev) && t < NETDEV_LTT) {
+				tun->dev->xmit_win = tun->dev->tx_queue_len;
+				netif_wake_queue(tun->dev);
+			}
+		}
 
 		/** Decide whether to accept this packet. This code is designed to
 		 * behave identically to an Ethernet interface. Accept the packet if
@@ -429,6 +481,7 @@ static void tun_setup(struct net_device *dev)
 	struct tun_struct *tun = netdev_priv(dev);
 
 	skb_queue_head_init(&tun->readq);
+	skb_queue_head_init(&dev->blist);
 	init_waitqueue_head(&tun->read_wait);
 
 	tun->owner = -1;
@@ -436,6 +489,8 @@ static void tun_setup(struct net_device *dev)
 	SET_MODULE_OWNER(dev);
 	dev->open = tun_net_open;
 	dev->hard_start_xmit = tun_net_xmit;
+	dev->hard_prep_xmit = NULL;
+	dev->hard_batch_xmit = tun_net_bxmit;
 	dev->stop = tun_net_close;
 	dev->get_stats = tun_net_stats;
 	dev->ethtool_ops = &tun_ethtool_ops;
@@ -458,7 +513,7 @@ static struct tun_struct *tun_get_by_name(const char *name)
 static int tun_set_iff(struct file *file, struct ifreq *ifr)
 {
 	struct tun_struct *tun;
-	struct net_device *dev;
+	struct net_device *dev = NULL;
 	int err;
 
 	tun = tun_get_by_name(ifr->ifr_name);
@@ -528,12 +583,15 @@ static int tun_set_iff(struct file *file, struct ifreq *ifr)
 	}
 
 	DBG(KERN_INFO "%s: tun_set_iff\n", tun->dev->name);
+	dev->features |= NETIF_F_BTX;
 
 	if (ifr->ifr_flags & IFF_NO_PI)
 		tun->flags |= TUN_NO_PI;
 
-	if (ifr->ifr_flags & IFF_ONE_QUEUE)
+	if (ifr->ifr_flags & IFF_ONE_QUEUE) {
 		tun->flags |= TUN_ONE_QUEUE;
+		dev->features &= ~NETIF_F_BTX;
+	}
 
 	file->private_data = tun;
 	tun->attached = 1;

--=-FucwRxjQQqWOpRu6uy9p--

