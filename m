From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: [PATCH] remove magic number for netdev alignment
Date: Thu, 4 Mar 2004 14:15:53 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040304141553.0080a1ba.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik <jgarzik@pobox.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,
Please apply to 2.6.current.

--
~Randy


// Linux 2.6.3
// remove magic number of '31' for net_device and private alignment;

diffstat:=
 drivers/net/net_init.c    |   13 ++++++++-----
 include/linux/netdevice.h |    7 ++++++-
 2 files changed, 14 insertions(+), 6 deletions(-)


diff -Naurp ./drivers/net/net_init.c~netpriv ./drivers/net/net_init.c
--- ./drivers/net/net_init.c~netpriv	2004-02-17 19:57:14.000000000 -0800
+++ ./drivers/net/net_init.c	2004-03-04 14:15:17.000000000 -0800
@@ -79,8 +79,9 @@ struct net_device *alloc_netdev(int size
 
 	/* ensure 32-byte alignment of both the device and private area */
 
-	alloc_size = (sizeof(struct net_device) + 31) & ~31;
-	alloc_size += sizeof_priv + 31;
+	alloc_size = (sizeof(struct net_device) + NETDEV_ALIGN_CONST)
+			& ~NETDEV_ALIGN_CONST;
+	alloc_size += sizeof_priv + NETDEV_ALIGN_CONST;
 
 	p = kmalloc (alloc_size, GFP_KERNEL);
 	if (!p) {
@@ -90,7 +91,8 @@ struct net_device *alloc_netdev(int size
 
 	memset(p, 0, alloc_size);
 
-	dev = (struct net_device *)(((long)p + 31) & ~31);
+	dev = (struct net_device *)(((long)p + NETDEV_ALIGN_CONST)
+				& ~NETDEV_ALIGN_CONST);
 	dev->padded = (char *)dev - (char *)p;
 
 	if (sizeof_priv)
@@ -109,7 +111,7 @@ static struct net_device *init_alloc_dev
 	int alloc_size;
 
 	/* ensure 32-byte alignment of the private area */
-	alloc_size = sizeof (*dev) + sizeof_priv + 31;
+	alloc_size = sizeof (*dev) + sizeof_priv + NETDEV_ALIGN_CONST;
 
 	dev = (struct net_device *) kmalloc (alloc_size, GFP_KERNEL);
 	if (dev == NULL)
@@ -121,7 +123,8 @@ static struct net_device *init_alloc_dev
 	memset(dev, 0, alloc_size);
 
 	if (sizeof_priv)
-		dev->priv = (void *) (((long)(dev + 1) + 31) & ~31);
+		dev->priv = (void *) (((long)(dev + 1) + NETDEV_ALIGN_CONST)
+				& ~NETDEV_ALIGN_CONST);
 
 	return dev;
 }
diff -Naurp ./include/linux/netdevice.h~netpriv ./include/linux/netdevice.h
--- ./include/linux/netdevice.h~netpriv	2004-02-17 19:59:32.000000000 -0800
+++ ./include/linux/netdevice.h	2004-03-04 14:13:42.000000000 -0800
@@ -478,9 +478,14 @@ struct net_device
 	int padded;
 };
 
+#define	NETDEV_ALIGN		32
+#define	NETDEV_ALIGN_CONST	(NETDEV_ALIGN - 1)
+
 static inline void *netdev_priv(struct net_device *dev)
 {
-	return (char *)dev + ((sizeof(struct net_device) + 31) & ~31);
+	return (char *)dev + ((sizeof(struct net_device)
+					+ NETDEV_ALIGN_CONST)
+				& ~NETDEV_ALIGN_CONST);
 }
 
 #define SET_MODULE_OWNER(dev) do { } while (0)
