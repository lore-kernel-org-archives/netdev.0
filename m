From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next V1 1/9] IB/ipoib: Add support for clones / multiple childs on the same partition
Date: Wed, 18 Jul 2012 13:59:54 +0300
Message-ID: <1342609202-32427-2-git-send-email-ogerlitz@mellanox.com>
References: <1342609202-32427-1-git-send-email-ogerlitz@mellanox.com>
Cc: roland@kernel.org, netdev@vger.kernel.org, ali@mellanox.com,
	sean.hefty@intel.com, shlomop@mellanox.com,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Erez Shitrit <erezsh@mellanox.co.il>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog120.obsmtp.com ([207.126.144.149]:58478 "HELO
	eu1sys200aog120.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753600Ab2GRLAR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 07:00:17 -0400
In-Reply-To: <1342609202-32427-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow creating "clone" child interfaces which further partition an
IPoIB interface to sub interfaces who either use the same pkey as
their parent or use the same pkey as already created child interface.

Each child now has a child index, which together with the pkey is
used as the identifier of the created network device.

All sorts of childs are still created/deleted through sysfs, in a
similar manner to the way legacy child interfaces are.

A major use case for clone childs is for virtualization purposes, where
a per VM NIC is desired at the hypervisor level, such as the solution
provided by the newly introduced Ethernet IPoIB driver.

Signed-off-by: Erez Shitrit <erezsh@mellanox.co.il>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 Documentation/infiniband/ipoib.txt         |   23 +++++++++++++
 drivers/infiniband/ulp/ipoib/ipoib.h       |    7 +++-
 drivers/infiniband/ulp/ipoib/ipoib_main.c  |   48 +++++++++++++++++++++-------
 drivers/infiniband/ulp/ipoib/ipoib_verbs.c |    3 +-
 drivers/infiniband/ulp/ipoib/ipoib_vlan.c  |   46 ++++++++++++++++++--------
 5 files changed, 98 insertions(+), 29 deletions(-)

diff --git a/Documentation/infiniband/ipoib.txt b/Documentation/infiniband/ipoib.txt
index 64eeb55..601f78f 100644
--- a/Documentation/infiniband/ipoib.txt
+++ b/Documentation/infiniband/ipoib.txt
@@ -24,6 +24,29 @@ Partitions and P_Keys
   The P_Key for any interface is given by the "pkey" file, and the
   main interface for a subinterface is in "parent."
 
+Clones
+  Its possible to further partition an IPoIB interfaces, and create
+  "clone" child interfaces which either use the same pkey as their
+  parent, or as an already created child interface. Each child now has
+  a child index, which together with the pkey is used as the identifier
+  of the created network device.
+
+ All sorts of childs are still created/deleted through sysfs, in a
+ similar manner to the way legacy child interfaces are, for example:
+
+    echo 0x8001.1 > /sys/class/net/ib0/create_child
+
+  will create an interface named ib0.8001.1 with P_Key 0x8001 and index 1
+
+    echo .1 > /sys/class/net/ib0/create_child
+
+  will create an interface named ib0.1 with same P_Key as ib0 and index 1
+
+  remove a subinterface, use the "delete_child" file:
+
+    echo 0x8001.1 > /sys/class/net/ib0/create_child
+    echo .1  > /sys/class/net/ib0/create_child
+
 Datagram vs Connected modes
 
   The IPoIB driver supports two modes of operation: datagram and
diff --git a/drivers/infiniband/ulp/ipoib/ipoib.h b/drivers/infiniband/ulp/ipoib/ipoib.h
index 86df632..a57db27 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib.h
+++ b/drivers/infiniband/ulp/ipoib/ipoib.h
@@ -332,6 +332,7 @@ struct ipoib_dev_priv {
 	struct net_device *parent;
 	struct list_head child_intfs;
 	struct list_head list;
+	int child_index;
 
 #ifdef CONFIG_INFINIBAND_IPOIB_CM
 	struct ipoib_cm_dev_priv cm;
@@ -490,8 +491,10 @@ void ipoib_transport_dev_cleanup(struct net_device *dev);
 void ipoib_event(struct ib_event_handler *handler,
 		 struct ib_event *record);
 
-int ipoib_vlan_add(struct net_device *pdev, unsigned short pkey);
-int ipoib_vlan_delete(struct net_device *pdev, unsigned short pkey);
+int ipoib_vlan_add(struct net_device *pdev, unsigned short pkey,
+						unsigned char clone_index);
+int ipoib_vlan_delete(struct net_device *pdev, unsigned short pkey,
+						unsigned char clone_index);
 
 void ipoib_pkey_poll(struct work_struct *work);
 int ipoib_pkey_dev_delay_open(struct net_device *dev);
diff --git a/drivers/infiniband/ulp/ipoib/ipoib_main.c b/drivers/infiniband/ulp/ipoib/ipoib_main.c
index bbee4b2..d0cb5cc 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_main.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_main.c
@@ -1095,17 +1095,44 @@ int ipoib_add_umcast_attr(struct net_device *dev)
 	return device_create_file(&dev->dev, &dev_attr_umcast);
 }
 
+static int parse_child(struct device *dev, const char *buf, int *pkey,
+		       int *child_index)
+{
+	int ret;
+	struct ipoib_dev_priv *priv = netdev_priv(to_net_dev(dev));
+
+	*pkey = *child_index = -1;
+
+	/* 'pkey' or 'pkey.child_index' or '.child_index' are allowed */
+	ret = sscanf(buf, "%i.%i", pkey, child_index);
+	if (ret == 1)  /* just pkey, implicit child index is 0 */
+		*child_index = 0;
+	else  if (ret != 2) { /* pkey same as parent, specified child index */
+		*pkey = priv->pkey;
+		ret  = sscanf(buf, ".%i", child_index);
+		if (ret != 1 || *child_index == 0)
+			return -EINVAL;
+	}
+
+	if (*child_index < 0 || *child_index > 0xff)
+		return -EINVAL;
+
+	if (*pkey < 0 || *pkey > 0xffff)
+		return -EINVAL;
+
+	ipoib_dbg(priv, "parse_child inp %s out pkey %04x index %d\n",
+		buf, *pkey, *child_index);
+	return 0;
+}
+
 static ssize_t create_child(struct device *dev,
 			    struct device_attribute *attr,
 			    const char *buf, size_t count)
 {
-	int pkey;
+	int pkey, child_index;
 	int ret;
 
-	if (sscanf(buf, "%i", &pkey) != 1)
-		return -EINVAL;
-
-	if (pkey < 0 || pkey > 0xffff)
+	if (parse_child(dev, buf, &pkey, &child_index))
 		return -EINVAL;
 
 	/*
@@ -1114,7 +1141,7 @@ static ssize_t create_child(struct device *dev,
 	 */
 	pkey |= 0x8000;
 
-	ret = ipoib_vlan_add(to_net_dev(dev), pkey);
+	ret = ipoib_vlan_add(to_net_dev(dev), pkey, child_index);
 
 	return ret ? ret : count;
 }
@@ -1124,16 +1151,13 @@ static ssize_t delete_child(struct device *dev,
 			    struct device_attribute *attr,
 			    const char *buf, size_t count)
 {
-	int pkey;
+	int pkey, child_index;
 	int ret;
 
-	if (sscanf(buf, "%i", &pkey) != 1)
-		return -EINVAL;
-
-	if (pkey < 0 || pkey > 0xffff)
+	if (parse_child(dev, buf, &pkey, &child_index))
 		return -EINVAL;
 
-	ret = ipoib_vlan_delete(to_net_dev(dev), pkey);
+	ret = ipoib_vlan_delete(to_net_dev(dev), pkey, child_index);
 
 	return ret ? ret : count;
 
diff --git a/drivers/infiniband/ulp/ipoib/ipoib_verbs.c b/drivers/infiniband/ulp/ipoib/ipoib_verbs.c
index 049a997..2131772 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_verbs.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_verbs.c
@@ -167,7 +167,8 @@ int ipoib_transport_dev_init(struct net_device *dev, struct ib_device *ca)
 			size += ipoib_recvq_size * ipoib_max_conn_qp;
 	}
 
-	priv->recv_cq = ib_create_cq(priv->ca, ipoib_ib_completion, NULL, dev, size, 0);
+	priv->recv_cq = ib_create_cq(priv->ca, ipoib_ib_completion, NULL, dev, size,
+				     priv->child_index % priv->ca->num_comp_vectors);
 	if (IS_ERR(priv->recv_cq)) {
 		printk(KERN_WARNING "%s: failed to create receive CQ\n", ca->name);
 		goto out_free_mr;
diff --git a/drivers/infiniband/ulp/ipoib/ipoib_vlan.c b/drivers/infiniband/ulp/ipoib/ipoib_vlan.c
index d7e9740..2d35cb4 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_vlan.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_vlan.c
@@ -49,7 +49,8 @@ static ssize_t show_parent(struct device *d, struct device_attribute *attr,
 }
 static DEVICE_ATTR(parent, S_IRUGO, show_parent, NULL);
 
-int ipoib_vlan_add(struct net_device *pdev, unsigned short pkey)
+int ipoib_vlan_add(struct net_device *pdev, unsigned short pkey,
+		unsigned char child_index)
 {
 	struct ipoib_dev_priv *ppriv, *priv;
 	char intf_name[IFNAMSIZ];
@@ -65,25 +66,40 @@ int ipoib_vlan_add(struct net_device *pdev, unsigned short pkey)
 	mutex_lock(&ppriv->vlan_mutex);
 
 	/*
-	 * First ensure this isn't a duplicate. We check the parent device and
-	 * then all of the child interfaces to make sure the Pkey doesn't match.
+	 * First ensure this isn't a duplicate. We check all of the child
+	 * interfaces to make sure the Pkey AND the child index
+	 * don't match.
 	 */
-	if (ppriv->pkey == pkey) {
-		result = -ENOTUNIQ;
-		priv = NULL;
-		goto err;
-	}
-
 	list_for_each_entry(priv, &ppriv->child_intfs, list) {
-		if (priv->pkey == pkey) {
+		if (priv->pkey == pkey && priv->child_index == child_index) {
 			result = -ENOTUNIQ;
 			priv = NULL;
 			goto err;
 		}
 	}
 
-	snprintf(intf_name, sizeof intf_name, "%s.%04x",
-		 ppriv->dev->name, pkey);
+	/*
+	 * for the case of non-legacy and same pkey childs we wanted to use
+	 * a notation of ibN.pkey:index and ibN:index but this is problematic
+	 * with tools like ifconfig who treat devices with ":" in their names
+	 * as aliases which are restriced, e.t w.r.t counters, etc
+	 */
+	if (ppriv->pkey != pkey && child_index == 0) /* legacy child */
+		snprintf(intf_name, sizeof intf_name, "%s.%04x",
+			 ppriv->dev->name, pkey);
+	else if (ppriv->pkey != pkey && child_index != 0) /* non-legacy child */
+		snprintf(intf_name, sizeof intf_name, "%s.%04x.%d",
+			 ppriv->dev->name, pkey, child_index);
+	else if (ppriv->pkey == pkey && child_index != 0) /* same pkey child */
+		snprintf(intf_name, sizeof intf_name, "%s.%d",
+			 ppriv->dev->name, child_index);
+	else  {
+		ipoib_warn(ppriv, "wrong pkey/child_index pairing %04x %d\n",
+			   pkey, child_index);
+		result = -EINVAL;
+		goto err;
+	}
+
 	priv = ipoib_intf_alloc(intf_name);
 	if (!priv) {
 		result = -ENOMEM;
@@ -101,6 +117,7 @@ int ipoib_vlan_add(struct net_device *pdev, unsigned short pkey)
 		goto err;
 
 	priv->pkey = pkey;
+	priv->child_index = child_index;
 
 	memcpy(priv->dev->dev_addr, ppriv->dev->dev_addr, INFINIBAND_ALEN);
 	priv->dev->broadcast[8] = pkey >> 8;
@@ -157,7 +174,8 @@ err:
 	return result;
 }
 
-int ipoib_vlan_delete(struct net_device *pdev, unsigned short pkey)
+int ipoib_vlan_delete(struct net_device *pdev, unsigned short pkey,
+		unsigned char child_index)
 {
 	struct ipoib_dev_priv *ppriv, *priv, *tpriv;
 	struct net_device *dev = NULL;
@@ -171,7 +189,7 @@ int ipoib_vlan_delete(struct net_device *pdev, unsigned short pkey)
 		return restart_syscall();
 	mutex_lock(&ppriv->vlan_mutex);
 	list_for_each_entry_safe(priv, tpriv, &ppriv->child_intfs, list) {
-		if (priv->pkey == pkey) {
+		if (priv->pkey == pkey && priv->child_index == child_index) {
 			unregister_netdevice(priv->dev);
 			ipoib_dev_cleanup(priv->dev);
 			list_del(&priv->list);
-- 
1.7.1
