From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] allow setting mtu and txqlen via RTM_SETLINK and provide txqlen via RTM_GETLINK
Date: Tue, 24 Aug 2004 18:25:01 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040824162501.GI21296@postel.suug.ch>
References: <20040824094952.GF21073@postel.suug.ch> <E1BzYMJ-000208-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@redhat.com, kuznet@ms2.inr.ac.ru, hadi@cyberus.ca,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <E1BzYMJ-000208-00@gondolin.me.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Herbert Xu <E1BzYMJ-000208-00@gondolin.me.apana.org.au> 2004-08-24 20:16
> Please think about the meaning of the value.  Is anyone going to have a queue
> bigger than 2^32?
> 
> And if the answer is yes, then please use u64.

Here's a new patch with all discussed changes integrated. I don't have enough
cycles to split it all up again.

Introduces IFLA_TXQLEN and IFLA_MAP to support accessing ifmap
and txqlen via RTM_(SET|GET)LINK.  Converts IFLA_MTU, IFLA_LINK
and IFLA_MASTER from arch dependent types to fixed width types.
Adds a IFLA_MTU handler for RTM_SETLINK to support changing
the MTU via RTM_SETLINK. Adds a handler for ifi_flags to
support changing net_device flags via RTM_SETLINK and changes
RTM_GETLINK to be symmetric with RTM_SETLINK like in ioctl
handlers.

   Thomas


--- 1.19/net/core/rtnetlink.c	Thu Apr 29 01:04:48 2004
+++ 1.27/net/core/rtnetlink.c	Tue Aug 24 18:16:40 2004
@@ -166,31 +166,53 @@
 	r->ifi_family = AF_UNSPEC;
 	r->ifi_type = dev->type;
 	r->ifi_index = dev->ifindex;
-	r->ifi_flags = dev->flags;
+	r->ifi_flags = dev_get_flags(dev);
 	r->ifi_change = change;
 
-	if (!netif_running(dev) || !netif_carrier_ok(dev))
-		r->ifi_flags &= ~IFF_RUNNING;
-	else
-		r->ifi_flags |= IFF_RUNNING;
-
 	RTA_PUT(skb, IFLA_IFNAME, strlen(dev->name)+1, dev->name);
+
+	if (1) {
+		u32 txqlen = dev->tx_queue_len;
+		RTA_PUT(skb, IFLA_TXQLEN, sizeof(txqlen), &txqlen);
+	}
+
+	if (1) {
+		struct ifmap map = {
+			.mem_start   = dev->mem_start,
+			.mem_end     = dev->mem_end,
+			.base_addr   = dev->base_addr,
+			.irq         = dev->irq,
+			.dma         = dev->dma,
+			.port        = dev->if_port,
+		};
+		RTA_PUT(skb, IFLA_MAP, sizeof(map), &map);
+	}
+
 	if (dev->addr_len) {
 		RTA_PUT(skb, IFLA_ADDRESS, dev->addr_len, dev->dev_addr);
 		RTA_PUT(skb, IFLA_BROADCAST, dev->addr_len, dev->broadcast);
 	}
+
 	if (1) {
-		unsigned mtu = dev->mtu;
+		u32 mtu = dev->mtu;
 		RTA_PUT(skb, IFLA_MTU, sizeof(mtu), &mtu);
 	}
-	if (dev->ifindex != dev->iflink)
-		RTA_PUT(skb, IFLA_LINK, sizeof(int), &dev->iflink);
+
+	if (dev->ifindex != dev->iflink) {
+		u32 iflink = dev->iflink;
+		RTA_PUT(skb, IFLA_LINK, sizeof(iflink), &iflink);
+	}
+
 	if (dev->qdisc_sleeping)
 		RTA_PUT(skb, IFLA_QDISC,
 			strlen(dev->qdisc_sleeping->ops->id) + 1,
 			dev->qdisc_sleeping->ops->id);
-	if (dev->master)
-		RTA_PUT(skb, IFLA_MASTER, sizeof(int), &dev->master->ifindex);
+	
+	if (dev->master) {
+		u32 master = dev->master->ifindex;
+		RTA_PUT(skb, IFLA_MASTER, sizeof(master), &master);
+	}
+
 	if (dev->get_stats) {
 		unsigned long *stats = (unsigned long*)dev->get_stats(dev);
 		if (stats) {
@@ -246,6 +268,30 @@
 
 	err = -EINVAL;
 
+	if (ifm->ifi_flags)
+		dev_change_flags(dev, ifm->ifi_flags);
+
+	if (ida[IFLA_MAP - 1]) {
+		if (!dev->set_config) {
+			err = -EOPNOTSUPP;
+			goto out;
+		}
+
+		if (!netif_device_present(dev)) {
+			err = -ENODEV;
+			goto out;
+		}
+		
+		if (ida[IFLA_MAP - 1]->rta_len != RTA_LENGTH(sizeof(struct ifmap)))
+			goto out;
+		
+		err = dev->set_config(dev, (struct ifmap *)
+				RTA_DATA(ida[IFLA_MAP - 1]));
+
+		if (err)
+			goto out;
+	}
+
 	if (ida[IFLA_ADDRESS - 1]) {
 		if (!dev->set_mac_address) {
 			err = -EOPNOTSUPP;
@@ -268,6 +314,23 @@
 			goto out;
 		memcpy(dev->broadcast, RTA_DATA(ida[IFLA_BROADCAST - 1]),
 		       dev->addr_len);
+	}
+
+	if (ida[IFLA_MTU - 1]) {
+		if (ida[IFLA_MTU - 1]->rta_len != RTA_LENGTH(sizeof(u32)))
+			goto out;
+		err = dev_set_mtu(dev, *((u32 *) RTA_DATA(ida[IFLA_MTU - 1])));
+
+		if (err)
+			goto out;
+
+	}
+
+	if (ida[IFLA_TXQLEN - 1]) {
+		if (ida[IFLA_TXQLEN - 1]->rta_len != RTA_LENGTH(sizeof(u32)))
+			goto out;
+
+		dev->tx_queue_len = *((u32 *) RTA_DATA(ida[IFLA_TXQLEN - 1]));
 	}
 
 	err = 0;
