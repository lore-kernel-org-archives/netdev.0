From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v3 07/10] net: Relocate dev_to_net_device() into core
Date: Sat, 14 Jan 2017 13:47:10 -0800
Message-ID: <20170114214713.28109-8-f.fainelli@gmail.com>
References: <20170114214713.28109-1-f.fainelli@gmail.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        Jason Cooper <jason@lakedaemon.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        Gregory Clement <gregory.clement@free-electrons.com>,
        Russell King <linux@armlinux.org.uk>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        "David S. Miller" <davem@davemloft.net>,
        linux-arm-kernel@lists.infradead.org (moderated list:ARM
        SUB-ARCHITECTURES), linux-kernel@vger.kernel.org (open list),
        gregkh@linuxfoundation.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170114214713.28109-1-f.fainelli@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

dev_to_net_device() is moved from net/dsa/dsa.c to net/core/dev.c since
it going to be used by net/dsa/dsa2.c and the namespace of the function
justifies making it available to other users potentially.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 include/linux/netdevice.h |  2 ++
 net/core/dev.c            | 19 +++++++++++++++++++
 net/dsa/dsa.c             | 18 ------------------
 3 files changed, 21 insertions(+), 18 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 97ae0ac513ee..6d021c37b774 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -4390,4 +4390,6 @@ do {								\
 #define PTYPE_HASH_SIZE	(16)
 #define PTYPE_HASH_MASK	(PTYPE_HASH_SIZE - 1)
 
+struct net_device *dev_to_net_device(struct device *dev);
+
 #endif	/* _LINUX_NETDEVICE_H */
diff --git a/net/core/dev.c b/net/core/dev.c
index ad5959e56116..7547e2ccc06b 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -8128,6 +8128,25 @@ const char *netdev_drivername(const struct net_device *dev)
 	return empty;
 }
 
+struct net_device *dev_to_net_device(struct device *dev)
+{
+	struct device *d;
+
+	d = device_find_class(dev, "net");
+	if (d) {
+		struct net_device *nd;
+
+		nd = to_net_dev(d);
+		dev_hold(nd);
+		put_device(d);
+
+		return nd;
+	}
+
+	return NULL;
+}
+EXPORT_SYMBOL_GPL(dev_to_net_device);
+
 static void __netdev_printk(const char *level, const struct net_device *dev,
 			    struct va_format *vaf)
 {
diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 77fa4c4f5828..6c264f92fec5 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -473,24 +473,6 @@ struct mii_bus *dsa_host_dev_to_mii_bus(struct device *dev)
 }
 EXPORT_SYMBOL_GPL(dsa_host_dev_to_mii_bus);
 
-static struct net_device *dev_to_net_device(struct device *dev)
-{
-	struct device *d;
-
-	d = device_find_class(dev, "net");
-	if (d != NULL) {
-		struct net_device *nd;
-
-		nd = to_net_dev(d);
-		dev_hold(nd);
-		put_device(d);
-
-		return nd;
-	}
-
-	return NULL;
-}
-
 #ifdef CONFIG_OF
 static int dsa_of_setup_routing_table(struct dsa_platform_data *pd,
 					struct dsa_chip_data *cd,
-- 
2.9.3
