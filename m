From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: Tree for December 12 (netdev ops)
Date: Mon, 15 Dec 2008 15:07:02 -0800 (PST)
Message-ID: <20081215.150702.187335926.davem@davemloft.net>
References: <20081212185654.0af8b4a1.sfr@canb.auug.org.au>
	<494498ED.7080903@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	shemminger@vyatta.com, alan@lxorguk.ukuu.org.uk
To: randy.dunlap@oracle.com
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <494498ED.7080903@oracle.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <randy.dunlap@oracle.com>
Date: Sat, 13 Dec 2008 21:26:05 -0800

> If hplan is built-in, this build error can happen:
> 
> build-r7084.out:8390p.c:(.text+0xfd9aa): undefined reference to `ei_start_xmit'
> build-r7084.out:8390p.c:(.text+0xfd9b6): undefined reference to `ei_get_stats'
> build-r7084.out:8390p.c:(.text+0xfd9c6): undefined reference to `ei_set_multicast_list'
> 
> since hplan uses 8390p.c, which uses lib8390.c, but the latter always uses:
> 
> #ifdef CONFIG_COMPAT_NET_DEV_OPS
> 	dev->hard_start_xmit = ei_start_xmit;
> 	dev->get_stats	= ei_get_stats;
> 	dev->set_multicast_list = ei_set_multicast_list;
> 	dev->tx_timeout = __ei_tx_timeout;
> #endif
> 
> However, those ei_* functions should be eip_* in this case.
> How to do that??

Thanks for your report Randy, I'll try to fix this.

These assignments need to be pushed into the 8390.c and
8390p.c code.

The fix will look something like the following.  I'll
do some sanity builds and commit this to net-next-2.6

diff --git a/drivers/net/8390.c b/drivers/net/8390.c
index 029ad08..fbe609a 100644
--- a/drivers/net/8390.c
+++ b/drivers/net/8390.c
@@ -72,7 +72,16 @@ EXPORT_SYMBOL(ei_netdev_ops);
 
 struct net_device *__alloc_ei_netdev(int size)
 {
-	return ____alloc_ei_netdev(size);
+	struct net_device *dev = ____alloc_ei_netdev(size);
+#ifdef CONFIG_COMPAT_NET_DEV_OPS
+	if (dev) {
+		dev->hard_start_xmit = ei_start_xmit;
+		dev->get_stats	= ei_get_stats;
+		dev->set_multicast_list = ei_set_multicast_list;
+		dev->tx_timeout = ei_tx_timeout;
+	}
+#endif
+	return dev;
 }
 EXPORT_SYMBOL(__alloc_ei_netdev);
 
diff --git a/drivers/net/8390p.c b/drivers/net/8390p.c
index 9c916d4..ee70b35 100644
--- a/drivers/net/8390p.c
+++ b/drivers/net/8390p.c
@@ -77,7 +77,16 @@ EXPORT_SYMBOL(eip_netdev_ops);
 
 struct net_device *__alloc_eip_netdev(int size)
 {
-	return ____alloc_ei_netdev(size);
+	struct net_device *dev = ____alloc_ei_netdev(size);
+#ifdef CONFIG_COMPAT_NET_DEV_OPS
+	if (dev) {
+		dev->hard_start_xmit = eip_start_xmit;
+		dev->get_stats	= eip_get_stats;
+		dev->set_multicast_list = eip_set_multicast_list;
+		dev->tx_timeout = eip_tx_timeout;
+	}
+#endif
+	return dev;
 }
 EXPORT_SYMBOL(__alloc_eip_netdev);
 
diff --git a/drivers/net/lib8390.c b/drivers/net/lib8390.c
index 1d36ca4..789b6cb 100644
--- a/drivers/net/lib8390.c
+++ b/drivers/net/lib8390.c
@@ -1010,12 +1010,6 @@ static void ethdev_setup(struct net_device *dev)
 	if (ei_debug > 1)
 		printk(version);
 
-#ifdef CONFIG_COMPAT_NET_DEV_OPS
-	dev->hard_start_xmit = ei_start_xmit;
-	dev->get_stats	= ei_get_stats;
-	dev->set_multicast_list = ei_set_multicast_list;
-	dev->tx_timeout = __ei_tx_timeout;
-#endif
 	ether_setup(dev);
 
 	spin_lock_init(&ei_local->page_lock);
