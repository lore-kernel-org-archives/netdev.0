From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: [PATCH 1/2] net: add alloc_netdev_mqs_id
Date: Tue,  7 Jun 2011 04:39:45 +0300
Message-ID: <1307410786-19110-2-git-send-email-lucian.grijincu@gmail.com>
References: <1307410786-19110-1-git-send-email-lucian.grijincu@gmail.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:51773 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755997Ab1FGBkD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2011 21:40:03 -0400
Received: by mail-wy0-f174.google.com with SMTP id 21so3213782wya.19
        for <netdev@vger.kernel.org>; Mon, 06 Jun 2011 18:40:03 -0700 (PDT)
In-Reply-To: <1307410786-19110-1-git-send-email-lucian.grijincu@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The complexity of alloc_netdev_mqs depends on the type of the device name:
- O(nr-net-devices) - for a device name with '%d' in it
- O(1)              - for given device name without any format.

The difference comes from the path chosen in __dev_alloc_name: if '%d'
is found in the name (e.g. 'dummy%d') it will:
- match all the devices in the that network namespace with the device
  name format extracting all used values for '%d' (e.g. 'dummy0',
  'dummy1', dummy3' => {0, 1 ,3} are used)
- create a device with the smallest unused value (e.g. 'dummy2').

Obviously the O(N) part comes the for_each_netdev loop. One could keep
around a precomputed table of values that are in use for each pattern
that is of interest (patterns for with there will be large numbers of
devices created) and make sure to mark slots as unused when
unregistering the device. The table would have no use after
registering a device and would need to be netns-specific.

Things get more complicated when taking into consideration device
renames and registration of devices that do not use patterns in names
(e.g. an explicit registration of a device with the 'dummy3' name).

This patch adds a new method of creating device names that aims to sit
in the middle: accept device names patterns with '%d' and the last
value used for '%d'. If the next slot is not taken, alloc_netdev_mqs_id
will be an O(1) operation. If that name is taken it falls back on
the O(N) algorithm.

Signed-off-by: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
---
 include/linux/netdevice.h |    7 +++++
 net/core/dev.c            |   63 +++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 70 insertions(+), 0 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index ca333e7..612c1f3 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2452,9 +2452,16 @@ extern void		ether_setup(struct net_device *dev);
 extern struct net_device *alloc_netdev_mqs(int sizeof_priv, const char *name,
 				       void (*setup)(struct net_device *),
 				       unsigned int txqs, unsigned int rxqs);
+extern struct net_device *alloc_netdev_mqs_id(int sizeof_priv, const char *name,
+		void (*setup)(struct net_device *),
+		unsigned int txqs, unsigned int rxqs, int *p_last_id);
+
 #define alloc_netdev(sizeof_priv, name, setup) \
 	alloc_netdev_mqs(sizeof_priv, name, setup, 1, 1)
 
+#define alloc_netdev_id(sizeof_priv, name, setup, p_last_id)	\
+	alloc_netdev_mqs_id(sizeof_priv, name, setup, 1, 1, p_last_id)
+
 #define alloc_netdev_mq(sizeof_priv, name, setup, count) \
 	alloc_netdev_mqs(sizeof_priv, name, setup, count, count)
 
diff --git a/net/core/dev.c b/net/core/dev.c
index 9393078..0862e81 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5908,6 +5908,69 @@ free_p:
 }
 EXPORT_SYMBOL(alloc_netdev_mqs);
 
+
+/**
+ * alloc_netdev_mqs_id - allocate a network device
+ *
+ * @name      - format of the device name. E.g. 'dummy%d'
+ * @p_last_id - IN: last known value that was given to '%d'
+ *              OUT: the value used for '%d' for the newly created device
+ *
+ *	@sizeof_priv:	size of private data to allocate space for
+ *	@setup:		callback to initialize device
+ *	@txqs:		the number of TX subqueues to allocate
+ *	@rxqs:		the number of RX subqueues to allocate
+ *
+ * alloc_netdev_mqs' complexity depends on the device name:
+ *  - O(nr-net-devices) - for a device name with '%d' in it
+ *  - O(1)              - for given device name without any format.
+ *
+ * alloc_netdev_mqs_id takes an extra argument: the last value that was
+ * used to fill '%d' in the name pattern. It uses this to create name
+ * that is likely to not be used (last_id+1) and tries to register a
+ * device with that name - O(1). If that fails it drops to the O(N)
+ * algorithm by sending the device name format.
+ *
+ * alloc_netdev_mqs will always make sure to find the smallest unused
+ * value for the '%d' in the name. alloc_netdev_mqs_id does not.
+ *
+ * E.g.:
+ * - you create 8 devices by calling alloc_netdev_mqs_id ('eth0' .. 'eth7')
+ *   and you know the next free slot is 'eth8'.
+ * - someone renames 'eth2' to 'some-other-name'
+ * - the next device created by alloc_netdev_mqs_id will be 'eth8'
+ *   even though 'eth2' could have been used.
+ */
+struct net_device *alloc_netdev_mqs_id(int sizeof_priv, const char *name,
+		void (*setup)(struct net_device *),
+		unsigned int txqs, unsigned int rxqs, int *p_last_id)
+{
+	struct net_device *dev;
+	char buf[IFNAMSIZ];
+
+	int new_id = (*p_last_id) + 1;
+
+	/* first try with explicit name - O(1) */
+	snprintf(buf, IFNAMSIZ, name, new_id);
+	dev = alloc_netdev_mqs(sizeof_priv, buf, setup, txqs, rxqs);
+	if (dev)
+		goto out;
+
+	/* fallback: create a name automatically - O(N) */
+	dev = alloc_netdev_mqs(sizeof_priv, name, setup, txqs, rxqs);
+	if (!dev)
+		goto fail;
+
+	sscanf(dev->name, name, &new_id);
+
+out:
+	*p_last_id = new_id;
+fail:
+	return dev;
+}
+EXPORT_SYMBOL(alloc_netdev_mqs_id);
+
+
 /**
  *	free_netdev - free network device
  *	@dev: device
-- 
1.7.5.2.317.g391b14

