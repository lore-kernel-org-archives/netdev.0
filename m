From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH v4] net: Introduce realloc_netdev_mq()
Date: Thu, 3 Dec 2009 21:29:38 +0100
Message-ID: <20091203202937.GA11436@ami.dom.local>
References: <20091101132017.GA2598@ami.dom.local>
 <20091102.033533.08766686.davem@davemloft.net>
 <20091102123029.GA7790@ff.dom.local>
 <20091102.043907.236634594.davem@davemloft.net>
 <20091203143918.GA20526@ff.dom.local>
 <4B17D697.8000105@gmail.com>
 <20091203163640.GA2584@ami.dom.local>
 <20091203165449.GA2960@ami.dom.local>
 <4B17EFE3.4080301@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, mchan@broadcom.com,
	kaber@trash.net, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f227.google.com ([209.85.218.227]:54420 "EHLO
	mail-bw0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753482AbZLCUaE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 15:30:04 -0500
Received: by bwz27 with SMTP id 27so1476536bwz.21
        for <netdev@vger.kernel.org>; Thu, 03 Dec 2009 12:30:10 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <4B17EFE3.4080301@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 03, 2009 at 06:05:39PM +0100, Eric Dumazet wrote:
> Jarek Poplawski a =E9crit :
> > On Thu, Dec 03, 2009 at 05:36:40PM +0100, Jarek Poplawski wrote:
> >> On Thu, Dec 03, 2009 at 04:17:43PM +0100, Eric Dumazet wrote:
> >>> if (realloc_netdev_mq(dev, real_queues))
> >>> 	dev->real_num_tx_queues =3D real_queues;
> >>>
> >>> In this case the memory error is not fatal.
> >> Good point! We can consider doing this inside the function too?
> >=20
> > Hmm... Of course, not exactly this - I mean using min().
>=20
> Sure, allowing to reduce the count in case new allocation failed.
>=20
> And report an error if caller wanted to increase number of queues and=
 allocation failed.

Hmm... After re-thinking it looks a bit too complex to me. I think,
there is no reason to not report this error since in most cases it
shouldn't be fatal. That's why I skipped this check in the changelog
example. Unless I miss something?

Thanks,
Jarek P.
---------------> (take 4)

This patch separates allocation of TX subqueues from alloc_netdev_mq()
to realloc_netdev_mq() to allow for resizing like in this example:

some_nic_probe()
{
	...
	dev =3D alloc_etherdev_mq(sizeof(*bp), 1)
	...
	if (MSI-X_available && device_supports_MSI-X_and_multiqueue)
		realloc_netdev_mq(dev, TX_MAX_RINGS)
	register_netdev(dev)
	...
}

Alternatively, it can be done in reverse order: starting from the
highest queue_count and reallocating with a lower one.

The main difference is to hold in num_tx_queues something that is
really available, instead of max possible value for all configs, in
case of drivers allocating net_device at the beginning of the probe.

The description of alloc_netdev_mq() is fixed btw.

Reported-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
---

 include/linux/netdevice.h |    1 +
 net/core/dev.c            |   69 ++++++++++++++++++++++++++++++++-----=
-------
 2 files changed, 51 insertions(+), 19 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index daf13d3..36cbd53 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1904,6 +1904,7 @@ extern void		ether_setup(struct net_device *dev);
 extern struct net_device *alloc_netdev_mq(int sizeof_priv, const char =
*name,
 				       void (*setup)(struct net_device *),
 				       unsigned int queue_count);
+extern int realloc_netdev_mq(struct net_device *dev, unsigned int queu=
e_count);
 #define alloc_netdev(sizeof_priv, name, setup) \
 	alloc_netdev_mq(sizeof_priv, name, setup, 1)
 extern int		register_netdev(struct net_device *dev);
diff --git a/net/core/dev.c b/net/core/dev.c
index e3e18de..1f45bae 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5265,11 +5265,53 @@ static void netdev_init_one_queue(struct net_de=
vice *dev,
 	queue->dev =3D dev;
 }
=20
-static void netdev_init_queues(struct net_device *dev)
+/**
+ *	realloc_netdev_mq - (re)allocate network subqueues
+ *	@dev:		device
+ *	@queue_count:	the number of subqueues to (re)allocate
+ *
+ *	(Re)allocates and initializes subqueue structs for each queue.
+ *	It is allowed to use only until register_netdev().
+ *	On error previous structs are intact, but dev->real_num_tx_queue is
+ *	replaced if the queue_count is lower.
+ */
+int realloc_netdev_mq(struct net_device *dev, unsigned int queue_count=
)
 {
-	netdev_init_one_queue(dev, &dev->rx_queue, NULL);
+	struct netdev_queue *tx;
+
+	tx =3D kcalloc(queue_count, sizeof(struct netdev_queue), GFP_KERNEL);
+	if (!tx) {
+		printk(KERN_ERR "alloc_netdev: Unable to (re)allocate "
+		       "tx qdiscs.\n");
+		if (dev->real_num_tx_queues > queue_count)
+			dev->real_num_tx_queues =3D queue_count;
+
+		return -ENOMEM;
+	}
+
+	kfree(dev->_tx);
+
+	dev->_tx =3D tx;
+	dev->num_tx_queues =3D queue_count;
+	dev->real_num_tx_queues =3D queue_count;
+
 	netdev_for_each_tx_queue(dev, netdev_init_one_queue, NULL);
+
+	return 0;
+}
+EXPORT_SYMBOL(realloc_netdev_mq);
+
+static int netdev_init_queues(struct net_device *dev, unsigned int que=
ue_count)
+{
+	int err =3D realloc_netdev_mq(dev, queue_count);
+
+	if (err)
+		return err;
+
+	netdev_init_one_queue(dev, &dev->rx_queue, NULL);
 	spin_lock_init(&dev->tx_global_lock);
+
+	return 0;
 }
=20
 /**
@@ -5280,13 +5322,12 @@ static void netdev_init_queues(struct net_devic=
e *dev)
  *	@queue_count:	the number of subqueues to allocate
  *
  *	Allocates a struct net_device with private data area for driver use
- *	and performs basic initialization.  Also allocates subquue structs
- *	for each queue on the device at the end of the netdevice.
+ *	and performs basic initialization.  Also allocates subqueue structs
+ *	for each queue on the device.
  */
 struct net_device *alloc_netdev_mq(int sizeof_priv, const char *name,
 		void (*setup)(struct net_device *), unsigned int queue_count)
 {
-	struct netdev_queue *tx;
 	struct net_device *dev;
 	size_t alloc_size;
 	struct net_device *p;
@@ -5308,16 +5349,12 @@ struct net_device *alloc_netdev_mq(int sizeof_p=
riv, const char *name,
 		return NULL;
 	}
=20
-	tx =3D kcalloc(queue_count, sizeof(struct netdev_queue), GFP_KERNEL);
-	if (!tx) {
-		printk(KERN_ERR "alloc_netdev: Unable to allocate "
-		       "tx qdiscs.\n");
-		goto free_p;
-	}
-
 	dev =3D PTR_ALIGN(p, NETDEV_ALIGN);
 	dev->padded =3D (char *)dev - (char *)p;
=20
+	if (netdev_init_queues(dev, queue_count))
+		goto free_p;
+
 	if (dev_addr_init(dev))
 		goto free_tx;
=20
@@ -5325,14 +5362,8 @@ struct net_device *alloc_netdev_mq(int sizeof_pr=
iv, const char *name,
=20
 	dev_net_set(dev, &init_net);
=20
-	dev->_tx =3D tx;
-	dev->num_tx_queues =3D queue_count;
-	dev->real_num_tx_queues =3D queue_count;
-
 	dev->gso_max_size =3D GSO_MAX_SIZE;
=20
-	netdev_init_queues(dev);
-
 	INIT_LIST_HEAD(&dev->napi_list);
 	INIT_LIST_HEAD(&dev->unreg_list);
 	INIT_LIST_HEAD(&dev->link_watch_list);
@@ -5342,7 +5373,7 @@ struct net_device *alloc_netdev_mq(int sizeof_pri=
v, const char *name,
 	return dev;
=20
 free_tx:
-	kfree(tx);
+	kfree(dev->_tx);
=20
 free_p:
 	kfree(p);
