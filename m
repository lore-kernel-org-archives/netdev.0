From: John Fastabend <john.r.fastabend@intel.com>
Subject: [net-next-2.6 PATCH v2 2/3] dcbnl: add appliction tlv handlers
Date: Thu, 30 Dec 2010 11:26:31 -0800
Message-ID: <20101230192631.21487.30082.stgit@jf-dev1-dcblab>
References: <20101230192449.21487.9764.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org,
	lucy.liu@intel.com, shmulikr@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:4557 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755241Ab0L3TbE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Dec 2010 14:31:04 -0500
In-Reply-To: <20101230192449.21487.9764.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds application tlv handlers. Networking stacks
may use the application priority to set the skb priority of
their stack using the negoatiated dcbx priority.

This patch provides the dcb_{get|set}app() routines for the
stack to query these parameters. Notice lower layer drivers
can use the dcbnl_ops routines if additional handling is
needed. Perhaps in the firmware case for example

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
Signed-off-by: Shmulik Ravid <shmulikr@broadcom.com>
---

 include/linux/dcbnl.h |    4 +
 include/net/dcbnl.h   |    9 +++
 net/dcb/dcbnl.c       |  133 +++++++++++++++++++++++++++++++++++++++++++++----
 3 files changed, 135 insertions(+), 11 deletions(-)

diff --git a/include/linux/dcbnl.h b/include/linux/dcbnl.h
index 287b561..775bdb4 100644
--- a/include/linux/dcbnl.h
+++ b/include/linux/dcbnl.h
@@ -82,7 +82,9 @@ struct ieee_pfc {
 	__u64	indications[IEEE_8021QAZ_MAX_TCS];
 };
 
-/* This structure contains the IEEE 802.1Qaz APP managed object
+/* This structure contains the IEEE 802.1Qaz APP managed object. This
+ * object is also used for the CEE std as well. There is no difference
+ * between the objects.
  *
  * @selector: protocol identifier type
  * @protocol: protocol of type indicated
diff --git a/include/net/dcbnl.h b/include/net/dcbnl.h
index e2d841e..ab7d623 100644
--- a/include/net/dcbnl.h
+++ b/include/net/dcbnl.h
@@ -22,6 +22,15 @@
 
 #include <linux/dcbnl.h>
 
+struct dcb_app_type {
+	char		  name[IFNAMSIZ];
+	struct dcb_app	  app;
+	struct list_head  list;
+};
+
+u8 dcb_setapp(struct net_device *, struct dcb_app *);
+u8 dcb_getapp(struct net_device *, struct dcb_app *);
+
 /*
  * Ops struct for the netlink callbacks.  Used by DCB-enabled drivers through
  * the netdevice struct.
diff --git a/net/dcb/dcbnl.c b/net/dcb/dcbnl.c
index 2ff9084..cfd731f 100644
--- a/net/dcb/dcbnl.c
+++ b/net/dcb/dcbnl.c
@@ -179,6 +179,9 @@ static const struct nla_policy dcbnl_ieee_app[DCB_ATTR_IEEE_APP_MAX + 1] = {
 	[DCB_ATTR_IEEE_APP]	    = {.len = sizeof(struct dcb_app)},
 };
 
+static LIST_HEAD(dcb_app_list);
+static DEFINE_SPINLOCK(dcb_lock);
+
 /* standard netlink reply call */
 static int dcbnl_reply(u8 value, u8 event, u8 cmd, u8 attr, u32 pid,
                        u32 seq, u16 flags)
@@ -634,12 +637,12 @@ out:
 static int dcbnl_setapp(struct net_device *netdev, struct nlattr **tb,
                         u32 pid, u32 seq, u16 flags)
 {
-	int ret = -EINVAL;
+	int err, ret = -EINVAL;
 	u16 id;
 	u8 up, idtype;
 	struct nlattr *app_tb[DCB_APP_ATTR_MAX + 1];
 
-	if (!tb[DCB_ATTR_APP] || !netdev->dcbnl_ops->setapp)
+	if (!tb[DCB_ATTR_APP])
 		goto out;
 
 	ret = nla_parse_nested(app_tb, DCB_APP_ATTR_MAX, tb[DCB_ATTR_APP],
@@ -663,9 +666,18 @@ static int dcbnl_setapp(struct net_device *netdev, struct nlattr **tb,
 	id = nla_get_u16(app_tb[DCB_APP_ATTR_ID]);
 	up = nla_get_u8(app_tb[DCB_APP_ATTR_PRIORITY]);
 
-	ret = dcbnl_reply(netdev->dcbnl_ops->setapp(netdev, idtype, id, up),
-	                  RTM_SETDCB, DCB_CMD_SAPP, DCB_ATTR_APP,
-	                  pid, seq, flags);
+	if (netdev->dcbnl_ops->setapp) {
+		err = netdev->dcbnl_ops->setapp(netdev, idtype, id, up);
+	} else {
+		struct dcb_app app;
+		app.selector = idtype;
+		app.protocol = id;
+		app.priority = up;
+		err = dcb_setapp(netdev, &app);
+	}
+
+	ret = dcbnl_reply(err, RTM_SETDCB, DCB_CMD_SAPP, DCB_ATTR_APP,
+			  pid, seq, flags);
 out:
 	return ret;
 }
@@ -1164,7 +1176,7 @@ static int dcbnl_ieee_set(struct net_device *netdev, struct nlattr **tb,
 			goto err;
 	}
 
-	if (ieee[DCB_ATTR_IEEE_APP_TABLE] && ops->ieee_setapp) {
+	if (ieee[DCB_ATTR_IEEE_APP_TABLE]) {
 		struct nlattr *attr;
 		int rem;
 
@@ -1173,7 +1185,10 @@ static int dcbnl_ieee_set(struct net_device *netdev, struct nlattr **tb,
 			if (nla_type(attr) != DCB_ATTR_IEEE_APP)
 				continue;
 			app_data = nla_data(attr);
-			err = ops->ieee_setapp(netdev, app_data);
+			if (ops->ieee_setapp)
+				err = ops->ieee_setapp(netdev, app_data);
+			else
+				err = dcb_setapp(netdev, app_data);
 			if (err)
 				goto err;
 		}
@@ -1193,7 +1208,8 @@ static int dcbnl_ieee_get(struct net_device *netdev, struct nlattr **tb,
 	struct sk_buff *skb;
 	struct nlmsghdr *nlh;
 	struct dcbmsg *dcb;
-	struct nlattr *ieee;
+	struct nlattr *ieee, *app;
+	struct dcb_app_type *itr;
 	const struct dcbnl_rtnl_ops *ops = netdev->dcbnl_ops;
 	int err;
 
@@ -1230,6 +1246,19 @@ static int dcbnl_ieee_get(struct net_device *netdev, struct nlattr **tb,
 			NLA_PUT(skb, DCB_ATTR_IEEE_PFC, sizeof(pfc), &pfc);
 	}
 
+	app = nla_nest_start(skb, DCB_ATTR_IEEE_APP_TABLE);
+	if (!app)
+		goto nla_put_failure;
+
+	spin_lock(&dcb_lock);
+	list_for_each_entry(itr, &dcb_app_list, list) {
+		if (strncmp(itr->name, netdev->name, IFNAMSIZ) == 0)
+			NLA_PUT(skb, DCB_ATTR_IEEE_APP,
+				sizeof(itr->app), &itr->app);
+	}
+	spin_unlock(&dcb_lock);
+	nla_nest_end(skb, app);
+
 	nla_nest_end(skb, ieee);
 	nlmsg_end(skb, nlh);
 
@@ -1364,8 +1393,93 @@ out:
 	return ret;
 }
 
+/**
+ * dcb_getapp - retrieve the DCBX application user priority
+ *
+ * On success returns a non-zero 802.1p user priority bitmap
+ * otherwise returns 0 as the invalid user priority bitmap to
+ * indicate an error.
+ */
+u8 dcb_getapp(struct net_device *dev, struct dcb_app *app)
+{
+	struct dcb_app_type *itr;
+	u8 prio = 0;
+
+	spin_lock(&dcb_lock);
+	list_for_each_entry(itr, &dcb_app_list, list) {
+		if (itr->app.selector == app->selector &&
+		    itr->app.protocol == app->protocol &&
+		    (strncmp(itr->name, dev->name, IFNAMSIZ) == 0)) {
+			prio = itr->app.priority;
+			break;
+		}
+	}
+	spin_unlock(&dcb_lock);
+
+	return prio;
+}
+EXPORT_SYMBOL(dcb_getapp);
+
+/**
+ * ixgbe_dcbnl_setapp - add dcb application data to app list
+ *
+ * Priority 0 is the default priority this removes applications
+ * from the app list if the priority is set to zero.
+ */
+u8 dcb_setapp(struct net_device *dev, struct dcb_app *new)
+{
+	struct dcb_app_type *itr;
+
+	spin_lock(&dcb_lock);
+	/* Search for existing match and replace */
+	list_for_each_entry(itr, &dcb_app_list, list) {
+		if (itr->app.selector == new->selector &&
+		    itr->app.protocol == new->protocol &&
+		    (strncmp(itr->name, dev->name, IFNAMSIZ) == 0)) {
+			if (new->priority)
+				itr->app.priority = new->priority;
+			else {
+				list_del(&itr->list);
+				kfree(itr);
+			}
+			goto out;
+		}
+	}
+	/* App type does not exist add new application type */
+	if (new->priority) {
+		struct dcb_app_type *entry;
+		entry = kmalloc(sizeof(struct dcb_app_type), GFP_ATOMIC);
+		if (!entry) {
+			spin_unlock(&dcb_lock);
+			return -ENOMEM;
+		}
+
+		memcpy(&entry->app, new, sizeof(*new));
+		strncpy(entry->name, dev->name, IFNAMSIZ);
+		list_add(&entry->list, &dcb_app_list);
+	}
+out:
+	spin_unlock(&dcb_lock);
+	return 0;
+}
+EXPORT_SYMBOL(dcb_setapp);
+
+void dcb_flushapp(void)
+{
+	struct dcb_app_type *app;
+
+	spin_lock(&dcb_lock);
+	list_for_each_entry(app, &dcb_app_list, list) {
+		list_del(&app->list);
+		kfree(app);
+	}
+	spin_unlock(&dcb_lock);
+}
+
 static int __init dcbnl_init(void)
 {
+	INIT_LIST_HEAD(&dcb_app_list);
+
 	rtnl_register(PF_UNSPEC, RTM_GETDCB, dcb_doit, NULL);
 	rtnl_register(PF_UNSPEC, RTM_SETDCB, dcb_doit, NULL);
 
@@ -1377,7 +1491,6 @@ static void __exit dcbnl_exit(void)
 {
 	rtnl_unregister(PF_UNSPEC, RTM_GETDCB);
 	rtnl_unregister(PF_UNSPEC, RTM_SETDCB);
+	dcb_flushapp();
 }
 module_exit(dcbnl_exit);
-
-

