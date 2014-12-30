From: Wengang Wang <wen.gang.wang-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] bonding: move ipoib_header_ops to vmlinux
Date: Tue, 30 Dec 2014 11:04:42 +0800
Message-ID: <1419908682-17012-1-git-send-email-wen.gang.wang@oracle.com>
Cc: wen.gang.wang-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

When last slave of a bonding master is removed, the bonding then does not work.
At the time if packet_snd is called against with a master net_device, it calls
then header_ops->create which points to slave's header_ops. In case the slave
is ipoib and the module is unloaded, header_ops would point to invalid address.
Accessing it will cause problem.
This patch tries to fix this issue by moving ipoib_header_ops to vmlinux to keep
it valid even when ipoib module is unloaded.

Signed-off-by: Wengang Wang <wen.gang.wang-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
---
 drivers/infiniband/ulp/ipoib/ipoib.h      | 10 ---------
 drivers/infiniband/ulp/ipoib/ipoib_main.c | 28 +------------------------
 include/linux/ibdevice.h                  | 15 ++++++++++++++
 include/linux/if_infiniband.h             | 11 ++++++++++
 include/uapi/linux/if_infiniband.h        | 16 ++++++++++++---
 net/Makefile                              |  2 +-
 net/infiniband/Makefile                   |  5 +++++
 net/infiniband/infiniband.c               | 34 +++++++++++++++++++++++++++++++
 8 files changed, 80 insertions(+), 41 deletions(-)
 create mode 100644 include/linux/ibdevice.h
 create mode 100644 include/linux/if_infiniband.h
 create mode 100644 net/infiniband/Makefile
 create mode 100644 net/infiniband/infiniband.c

diff --git a/drivers/infiniband/ulp/ipoib/ipoib.h b/drivers/infiniband/ulp/ipoib/ipoib.h
index d7562be..7c25670 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib.h
+++ b/drivers/infiniband/ulp/ipoib/ipoib.h
@@ -121,16 +121,6 @@ enum {
 
 /* structs */
 
-struct ipoib_header {
-	__be16	proto;
-	u16	reserved;
-};
-
-struct ipoib_cb {
-	struct qdisc_skb_cb	qdisc_cb;
-	u8			hwaddr[INFINIBAND_ALEN];
-};
-
 static inline struct ipoib_cb *ipoib_skb_cb(const struct sk_buff *skb)
 {
 	BUILD_BUG_ON(sizeof(skb->cb) < sizeof(struct ipoib_cb));
diff --git a/drivers/infiniband/ulp/ipoib/ipoib_main.c b/drivers/infiniband/ulp/ipoib/ipoib_main.c
index 58b5aa3..9233085 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_main.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_main.c
@@ -34,6 +34,7 @@
 
 #include "ipoib.h"
 
+#include <linux/ibdevice.h>
 #include <linux/module.h>
 
 #include <linux/init.h>
@@ -807,29 +808,6 @@ static void ipoib_timeout(struct net_device *dev)
 	/* XXX reset QP, etc. */
 }
 
-static int ipoib_hard_header(struct sk_buff *skb,
-			     struct net_device *dev,
-			     unsigned short type,
-			     const void *daddr, const void *saddr, unsigned len)
-{
-	struct ipoib_header *header;
-	struct ipoib_cb *cb = ipoib_skb_cb(skb);
-
-	header = (struct ipoib_header *) skb_push(skb, sizeof *header);
-
-	header->proto = htons(type);
-	header->reserved = 0;
-
-	/*
-	 * we don't rely on dst_entry structure,  always stuff the
-	 * destination address into skb->cb so we can figure out where
-	 * to send the packet later.
-	 */
-	memcpy(cb->hwaddr, daddr, INFINIBAND_ALEN);
-
-	return sizeof *header;
-}
-
 static void ipoib_set_mcast_list(struct net_device *dev)
 {
 	struct ipoib_dev_priv *priv = netdev_priv(dev);
@@ -1328,10 +1306,6 @@ void ipoib_dev_cleanup(struct net_device *dev)
 	ipoib_neigh_hash_uninit(dev);
 }
 
-static const struct header_ops ipoib_header_ops = {
-	.create	= ipoib_hard_header,
-};
-
 static const struct net_device_ops ipoib_netdev_ops = {
 	.ndo_uninit		 = ipoib_uninit,
 	.ndo_open		 = ipoib_open,
diff --git a/include/linux/ibdevice.h b/include/linux/ibdevice.h
new file mode 100644
index 0000000..8418974
--- /dev/null
+++ b/include/linux/ibdevice.h
@@ -0,0 +1,15 @@
+/*
+ * ipoib	Implementation of ipoib_header_ops here.
+ *
+ * Authors:	Wengang Wang <wen.gang.wang-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
+ */
+#ifndef _LINUX_IBDEVICE_H
+#define _LINUX_IBDEVICE_H
+
+#include <linux/netdevice.h>
+
+#ifdef __KERNEL__
+extern const struct header_ops ipoib_header_ops;
+#endif /* __KERNEL__ */
+
+#endif	/* _LINUX_IBDEVICE_H */
diff --git a/include/linux/if_infiniband.h b/include/linux/if_infiniband.h
new file mode 100644
index 0000000..9f2d0cf
--- /dev/null
+++ b/include/linux/if_infiniband.h
@@ -0,0 +1,11 @@
+/*
+ * ipoib	Implementation of ipoib_header_ops here.
+ *
+ * Authors:	Wengang Wang <wen.gang.wang-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
+ */
+#ifndef _LINUX_IF_INFINIBAND_H
+#define _LINUX_IF_INFINIBAND_H
+
+#include <uapi/linux/if_infiniband.h>
+
+#endif	/* _LINUX_IF_INFINIBAND_H */
diff --git a/include/uapi/linux/if_infiniband.h b/include/uapi/linux/if_infiniband.h
index 7d958475..9190ee3 100644
--- a/include/uapi/linux/if_infiniband.h
+++ b/include/uapi/linux/if_infiniband.h
@@ -21,9 +21,19 @@
  * $Id$
  */
 
-#ifndef _LINUX_IF_INFINIBAND_H
-#define _LINUX_IF_INFINIBAND_H
+#ifndef _UAPI_LINUX_IF_INFINIBAND_H
+#define _UAPI_LINUX_IF_INFINIBAND_H
 
+#include <net/sch_generic.h>
 #define INFINIBAND_ALEN		20	/* Octets in IPoIB HW addr	*/
 
-#endif /* _LINUX_IF_INFINIBAND_H */
+struct ipoib_header {
+	__be16	proto;
+	u16	reserved;
+};
+
+struct ipoib_cb {
+	struct qdisc_skb_cb	qdisc_cb;
+	u8			hwaddr[INFINIBAND_ALEN];
+};
+#endif /* _UAPI_LINUX_IF_INFINIBAND_H */
diff --git a/net/Makefile b/net/Makefile
index 7ed1970..5d00a13 100644
--- a/net/Makefile
+++ b/net/Makefile
@@ -14,7 +14,7 @@ obj-$(CONFIG_NET)		+= $(tmp-y)
 
 # LLC has to be linked before the files in net/802/
 obj-$(CONFIG_LLC)		+= llc/
-obj-$(CONFIG_NET)		+= ethernet/ 802/ sched/ netlink/
+obj-$(CONFIG_NET)		+= ethernet/ 802/ sched/ netlink/ infiniband/
 obj-$(CONFIG_NETFILTER)		+= netfilter/
 obj-$(CONFIG_INET)		+= ipv4/
 obj-$(CONFIG_XFRM)		+= xfrm/
diff --git a/net/infiniband/Makefile b/net/infiniband/Makefile
new file mode 100644
index 0000000..c8a5be0
--- /dev/null
+++ b/net/infiniband/Makefile
@@ -0,0 +1,5 @@
+#
+# Makefile for the Linux ip over infiniband layer.
+#
+
+obj-y					+= infiniband.o
diff --git a/net/infiniband/infiniband.c b/net/infiniband/infiniband.c
new file mode 100644
index 0000000..a458ec5
--- /dev/null
+++ b/net/infiniband/infiniband.c
@@ -0,0 +1,34 @@
+/*
+ * ipoib	Implementation of ipoib_header_ops here.
+ *
+ * Authors:	Wengang Wang <wen.gang.wang-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
+ */
+
+#include <linux/if_infiniband.h>
+
+static int ipoib_hard_header(struct sk_buff *skb,
+			     struct net_device *dev,
+			     unsigned short type,
+			     const void *daddr, const void *saddr, unsigned len)
+{
+	struct ipoib_header *header;
+	struct ipoib_cb *cb = (struct ipoib_cb *)skb->cb;
+
+	header = (struct ipoib_header *)skb_push(skb, sizeof(*header));
+
+	header->proto = htons(type);
+	header->reserved = 0;
+
+	/* we don't rely on dst_entry structure,  always stuff the
+	 * destination address into skb->cb so we can figure out where
+	 * to send the packet later.
+	 */
+	memcpy(cb->hwaddr, daddr, INFINIBAND_ALEN);
+
+	return sizeof(*header);
+}
+
+const struct header_ops ipoib_header_ops = {
+	.create	= ipoib_hard_header,
+};
+EXPORT_SYMBOL(ipoib_header_ops);
-- 
1.8.3.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
