From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v4 07/10] net: Relocate dev_to_net_device() into
 net/core/dev.c
Date: Tue, 17 Jan 2017 15:21:49 -0800
Message-ID: <20170117232152.1661-8-f.fainelli@gmail.com>
References: <20170117232152.1661-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Andrew Lunn <andrew@lunn.ch>, Florian Fainelli <f.fainelli@gmail.com>,
 Jason Cooper <jason@lakedaemon.net>,
 Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 Russell King <linux@armlinux.org.uk>, open list <linux-kernel@vger.kernel.org>,
 Gregory Clement <gregory.clement@free-electrons.com>,
 "David S. Miller" <davem@davemloft.net>,
 "moderated list:ARM/Marvell Dove/MV78xx0/Orion SOC support"
 <linux-arm-kernel@lists.infradead.org>,
 Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20170117232152.1661-1-f.fainelli@gmail.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

dev_to_net_device() is moved from net/dsa/dsa.c to net/core/dev.c since
it going to be used by net/dsa/dsa2.c and the namespace of the function
justifies making it available to other users potentially. We also rename
it to device_to_net_device() to better illustrate what it does since it
is not just a container_of() wrapper.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 include/linux/netdevice.h |  2 ++
 net/core/dev.c            | 30 ++++++++++++++++++++++++++++++
 net/dsa/dsa.c             | 20 +-------------------
 3 files changed, 33 insertions(+), 19 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 97ae0ac513ee..f8cc9833107c 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -4390,4 +4390,6 @@ do {								\
 #define PTYPE_HASH_SIZE	(16)
 #define PTYPE_HASH_MASK	(PTYPE_HASH_SIZE - 1)
 
+struct net_device *device_to_net_device(struct device *dev);
+
 #endif	/* _LINUX_NETDEVICE_H */
diff --git a/net/core/dev.c b/net/core/dev.c
index ad5959e56116..f6897906f229 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -8128,6 +8128,36 @@ const char *netdev_drivername(const struct net_device *dev)
 	return empty;
 }
 
+/**
+ *	device_to_net_device - return the net_device from device
+ *	@dev: device reference
+ *
+ *	Returns the net_device associated with this device reference
+ *	NULL if the device is not a network device, or could not be
+ *	found.
+ *
+ *	Note: caller must call dev_put() to release the net_device
+ *	once done with it.
+ */
+struct net_device *device_to_net_device(struct device *dev)
+{
+	struct device *d;
+
+	d = device_find_in_class_name(dev, "net");
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
+EXPORT_SYMBOL_GPL(device_to_net_device);
+
 static void __netdev_printk(const char *level, const struct net_device *dev,
 			    struct va_format *vaf)
 {
diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index d9db63910887..88b56f7e3dd2 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -473,24 +473,6 @@ struct mii_bus *dsa_host_dev_to_mii_bus(struct device *dev)
 }
 EXPORT_SYMBOL_GPL(dsa_host_dev_to_mii_bus);
 
-static struct net_device *dev_to_net_device(struct device *dev)
-{
-	struct device *d;
-
-	d = device_find_in_class_name(dev, "net");
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
@@ -799,7 +781,7 @@ static int dsa_probe(struct platform_device *pdev)
 		dev = pd->of_netdev;
 		dev_hold(dev);
 	} else {
-		dev = dev_to_net_device(pd->netdev);
+		dev = device_to_net_device(pd->netdev);
 	}
 	if (dev == NULL) {
 		ret = -EPROBE_DEFER;
-- 
2.9.3
