From: John Fastabend <john.r.fastabend@intel.com>
Subject: [net-next PATCH 1/3] dcb: Use ifindex instead of ifname
Date: Thu, 06 Oct 2011 11:52:33 -0700
Message-ID: <20111006185233.2781.80310.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org,
	gospo@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:22867 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755185Ab1JFTBe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Oct 2011 15:01:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Rustad <mark.d.rustad@intel.com>

Use ifindex instead of ifname in the DCB app ring. This makes for a smaller
data structure and faster comparisons. It also avoids possible issues when
a net device is renamed.

Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---

 include/net/dcbnl.h |    2 +-
 net/dcb/dcbnl.c     |   24 ++++++++++++------------
 2 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/include/net/dcbnl.h b/include/net/dcbnl.h
index f5aa399..263aa3a 100644
--- a/include/net/dcbnl.h
+++ b/include/net/dcbnl.h
@@ -23,7 +23,7 @@
 #include <linux/dcbnl.h>
 
 struct dcb_app_type {
-	char		  name[IFNAMSIZ];
+	int	ifindex;
 	struct dcb_app	  app;
 	struct list_head  list;
 };
diff --git a/net/dcb/dcbnl.c b/net/dcb/dcbnl.c
index 3cb56af..e508593 100644
--- a/net/dcb/dcbnl.c
+++ b/net/dcb/dcbnl.c
@@ -1255,7 +1255,7 @@ static int dcbnl_ieee_fill(struct sk_buff *skb, struct net_device *netdev)
 
 	spin_lock(&dcb_lock);
 	list_for_each_entry(itr, &dcb_app_list, list) {
-		if (strncmp(itr->name, netdev->name, IFNAMSIZ) == 0) {
+		if (itr->ifindex == netdev->ifindex) {
 			err = nla_put(skb, DCB_ATTR_IEEE_APP, sizeof(itr->app),
 					 &itr->app);
 			if (err) {
@@ -1412,7 +1412,7 @@ static int dcbnl_cee_fill(struct sk_buff *skb, struct net_device *netdev)
 		goto dcb_unlock;
 
 	list_for_each_entry(itr, &dcb_app_list, list) {
-		if (strncmp(itr->name, netdev->name, IFNAMSIZ) == 0) {
+		if (itr->ifindex == netdev->ifindex) {
 			struct nlattr *app_nest = nla_nest_start(skb,
 								 DCB_ATTR_APP);
 			if (!app_nest)
@@ -2050,7 +2050,7 @@ u8 dcb_getapp(struct net_device *dev, struct dcb_app *app)
 	list_for_each_entry(itr, &dcb_app_list, list) {
 		if (itr->app.selector == app->selector &&
 		    itr->app.protocol == app->protocol &&
-		    (strncmp(itr->name, dev->name, IFNAMSIZ) == 0)) {
+		    itr->ifindex == dev->ifindex) {
 			prio = itr->app.priority;
 			break;
 		}
@@ -2073,7 +2073,7 @@ int dcb_setapp(struct net_device *dev, struct dcb_app *new)
 	struct dcb_app_type *itr;
 	struct dcb_app_type event;
 
-	memcpy(&event.name, dev->name, sizeof(event.name));
+	event.ifindex = dev->ifindex;
 	memcpy(&event.app, new, sizeof(event.app));
 
 	spin_lock(&dcb_lock);
@@ -2081,7 +2081,7 @@ int dcb_setapp(struct net_device *dev, struct dcb_app *new)
 	list_for_each_entry(itr, &dcb_app_list, list) {
 		if (itr->app.selector == new->selector &&
 		    itr->app.protocol == new->protocol &&
-		    (strncmp(itr->name, dev->name, IFNAMSIZ) == 0)) {
+		    itr->ifindex == dev->ifindex) {
 			if (new->priority)
 				itr->app.priority = new->priority;
 			else {
@@ -2101,7 +2101,7 @@ int dcb_setapp(struct net_device *dev, struct dcb_app *new)
 		}
 
 		memcpy(&entry->app, new, sizeof(*new));
-		strncpy(entry->name, dev->name, IFNAMSIZ);
+		entry->ifindex = dev->ifindex;
 		list_add(&entry->list, &dcb_app_list);
 	}
 out:
@@ -2127,7 +2127,7 @@ u8 dcb_ieee_getapp_mask(struct net_device *dev, struct dcb_app *app)
 	list_for_each_entry(itr, &dcb_app_list, list) {
 		if (itr->app.selector == app->selector &&
 		    itr->app.protocol == app->protocol &&
-		    (strncmp(itr->name, dev->name, IFNAMSIZ) == 0)) {
+		    itr->ifindex == dev->ifindex) {
 			prio |= 1 << itr->app.priority;
 		}
 	}
@@ -2150,7 +2150,7 @@ int dcb_ieee_setapp(struct net_device *dev, struct dcb_app *new)
 	struct dcb_app_type event;
 	int err = 0;
 
-	memcpy(&event.name, dev->name, sizeof(event.name));
+	event.ifindex = dev->ifindex;
 	memcpy(&event.app, new, sizeof(event.app));
 
 	spin_lock(&dcb_lock);
@@ -2159,7 +2159,7 @@ int dcb_ieee_setapp(struct net_device *dev, struct dcb_app *new)
 		if (itr->app.selector == new->selector &&
 		    itr->app.protocol == new->protocol &&
 		    itr->app.priority == new->priority &&
-		    (strncmp(itr->name, dev->name, IFNAMSIZ) == 0)) {
+		    itr->ifindex == dev->ifindex) {
 			err = -EEXIST;
 			goto out;
 		}
@@ -2173,7 +2173,7 @@ int dcb_ieee_setapp(struct net_device *dev, struct dcb_app *new)
 	}
 
 	memcpy(&entry->app, new, sizeof(*new));
-	strncpy(entry->name, dev->name, IFNAMSIZ);
+	entry->ifindex = dev->ifindex;
 	list_add(&entry->list, &dcb_app_list);
 out:
 	spin_unlock(&dcb_lock);
@@ -2194,7 +2194,7 @@ int dcb_ieee_delapp(struct net_device *dev, struct dcb_app *del)
 	struct dcb_app_type event;
 	int err = -ENOENT;
 
-	memcpy(&event.name, dev->name, sizeof(event.name));
+	event.ifindex = dev->ifindex;
 	memcpy(&event.app, del, sizeof(event.app));
 
 	spin_lock(&dcb_lock);
@@ -2203,7 +2203,7 @@ int dcb_ieee_delapp(struct net_device *dev, struct dcb_app *del)
 		if (itr->app.selector == del->selector &&
 		    itr->app.protocol == del->protocol &&
 		    itr->app.priority == del->priority &&
-		    (strncmp(itr->name, dev->name, IFNAMSIZ) == 0)) {
+		    itr->ifindex == dev->ifindex) {
 			list_del(&itr->list);
 			kfree(itr);
 			err = 0;
