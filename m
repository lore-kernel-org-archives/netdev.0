From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: extend net_device allocation to vmalloc()
Date: Wed, 30 Oct 2013 08:01:18 -0700
Message-ID: <1383145278.4857.46.camel@edumazet-glaptop.roam.corp.google.com>
References: <20131029152628.GA3065@citrix.com>
	 <1383061430.5464.41.camel@edumazet-glaptop.roam.corp.google.com>
	 <20131029184647.GA3261@citrix.com>
	 <1383089055.4176.1.camel@edumazet-glaptop.roam.corp.google.com>
	 <1383089532.4857.1.camel@edumazet-glaptop.roam.corp.google.com>
	 <20131030103958.GB3261@citrix.com>
	 <1383141242.4857.36.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, wei.liu2@citrix.com,
	ian.campbell@citrix.com, xen-devel@lists.xen.org,
	andrew.bennieston@citrix.com, david.vrabel@citrix.com,
	malcolm.crossley@citrix.com
To: Joby Poriyath <joby.poriyath@citrix.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:60443 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752517Ab3J3PBW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Oct 2013 11:01:22 -0400
Received: by mail-pa0-f47.google.com with SMTP id lf10so1051018pab.20
        for <netdev@vger.kernel.org>; Wed, 30 Oct 2013 08:01:21 -0700 (PDT)
In-Reply-To: <1383141242.4857.36.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Joby Poriyath provided a xen-netback patch to reduce the size of
xenvif structure as some netdev allocation could fail under
memory pressure/fragmentation.

This patch is handling the problem at the core level, allowing
any netdev structures to use vmalloc() if kmalloc() failed.

As vmalloc() adds overhead on a critical network path, add __GFP_REPEAT
to kzalloc() flags to do this fallback only when really needed.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Joby Poriyath <joby.poriyath@citrix.com>
---
 Documentation/networking/netdevices.txt |    7 ++++---
 include/linux/netdevice.h               |    1 +
 net/core/dev.c                          |   22 +++++++++++++++++-----
 net/core/net-sysfs.c                    |    2 +-
 4 files changed, 23 insertions(+), 9 deletions(-)

diff --git a/Documentation/networking/netdevices.txt b/Documentation/networking/netdevices.txt
index c7ecc70..df7cd19 100644
--- a/Documentation/networking/netdevices.txt
+++ b/Documentation/networking/netdevices.txt
@@ -10,9 +10,10 @@ network devices.
 struct net_device allocation rules
 ==================================
 Network device structures need to persist even after module is unloaded and
-must be allocated with kmalloc.  If device has registered successfully,
-it will be freed on last use by free_netdev.  This is required to handle the
-pathologic case cleanly (example: rmmod mydriver </sys/class/net/myeth/mtu )
+must be allocated with kmalloc() or vmalloc(). If device has registered
+successfully, it will be freed on last use by free_netdev.
+This is required to handle the pathologic case cleanly
+(example: rmmod mydriver </sys/class/net/myeth/mtu )
 
 There are routines in net_init.c to handle the common cases of
 alloc_etherdev, alloc_netdev.  These reserve extra space for driver
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index cb1d918..e6353ca 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1800,6 +1800,7 @@ static inline void unregister_netdevice(struct net_device *dev)
 
 int netdev_refcnt_read(const struct net_device *dev);
 void free_netdev(struct net_device *dev);
+void netdev_freemem(struct net_device *dev);
 void synchronize_net(void);
 int init_dummy_netdev(struct net_device *dev);
 
diff --git a/net/core/dev.c b/net/core/dev.c
index 0054c8c..0e61365 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -6196,6 +6196,16 @@ void netdev_set_default_ethtool_ops(struct net_device *dev,
 }
 EXPORT_SYMBOL_GPL(netdev_set_default_ethtool_ops);
 
+void netdev_freemem(struct net_device *dev)
+{
+	char *addr = (char *)dev - dev->padded;
+
+	if (is_vmalloc_addr(addr))
+		vfree(addr);
+	else
+		kfree(addr);
+}
+
 /**
  *	alloc_netdev_mqs - allocate network device
  *	@sizeof_priv:	size of private data to allocate space for
@@ -6239,7 +6249,9 @@ struct net_device *alloc_netdev_mqs(int sizeof_priv, const char *name,
 	/* ensure 32-byte alignment of whole construct */
 	alloc_size += NETDEV_ALIGN - 1;
 
-	p = kzalloc(alloc_size, GFP_KERNEL);
+	p = kzalloc(alloc_size, GFP_KERNEL | __GFP_NOWARN | __GFP_REPEAT);
+	if (!p)
+		p = vzalloc(alloc_size);
 	if (!p)
 		return NULL;
 
@@ -6248,7 +6260,7 @@ struct net_device *alloc_netdev_mqs(int sizeof_priv, const char *name,
 
 	dev->pcpu_refcnt = alloc_percpu(int);
 	if (!dev->pcpu_refcnt)
-		goto free_p;
+		goto free_dev;
 
 	if (dev_addr_init(dev))
 		goto free_pcpu;
@@ -6301,8 +6313,8 @@ free_pcpu:
 	kfree(dev->_rx);
 #endif
 
-free_p:
-	kfree(p);
+free_dev:
+	netdev_freemem(dev);
 	return NULL;
 }
 EXPORT_SYMBOL(alloc_netdev_mqs);
@@ -6339,7 +6351,7 @@ void free_netdev(struct net_device *dev)
 
 	/*  Compatibility with error handling in drivers */
 	if (dev->reg_state == NETREG_UNINITIALIZED) {
-		kfree((char *)dev - dev->padded);
+		netdev_freemem(dev);
 		return;
 	}
 
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index d954b56..d03f2c9 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -1263,7 +1263,7 @@ static void netdev_release(struct device *d)
 	BUG_ON(dev->reg_state != NETREG_RELEASED);
 
 	kfree(dev->ifalias);
-	kfree((char *)dev - dev->padded);
+	netdev_freemem(dev);
 }
 
 static const void *net_namespace(struct device *d)
