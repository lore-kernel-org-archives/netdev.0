From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 6/8] dcbnl: Move dcb app lookup code into dcb_app_lookup()
Date: Wed, 13 Jun 2012 14:54:59 +0200
Message-ID: <10cbfa8b2f1d52448195e84d9f3a57db924cd873.1339591572.git.tgraf@suug.ch>
References: <cover.1339591572.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, lucy.liu@intel.com,
	john.r.fastabend@intel.com, alexander.h.duyck@intel.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39964 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753229Ab2FMMzO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jun 2012 08:55:14 -0400
In-Reply-To: <cover.1339591572.git.tgraf@suug.ch>
In-Reply-To: <cover.1339591572.git.tgraf@suug.ch>
References: <cover.1339591572.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 net/dcb/dcbnl.c |   81 +++++++++++++++++++++++-------------------------------
 1 files changed, 35 insertions(+), 46 deletions(-)

diff --git a/net/dcb/dcbnl.c b/net/dcb/dcbnl.c
index 5a5bc25..6817f14 100644
--- a/net/dcb/dcbnl.c
+++ b/net/dcb/dcbnl.c
@@ -1716,6 +1716,22 @@ out:
 	return ret;
 }
 
+static struct dcb_app_type *dcb_app_lookup(const struct dcb_app *app,
+					   int ifindex, int prio)
+{
+	struct dcb_app_type *itr;
+
+	list_for_each_entry(itr, &dcb_app_list, list) {
+		if (itr->app.selector == app->selector &&
+		    itr->app.protocol == app->protocol &&
+		    itr->ifindex == ifindex &&
+		    (!prio || itr->app.priority == prio))
+			return itr;
+	}
+
+	return NULL;
+}
+
 /**
  * dcb_getapp - retrieve the DCBX application user priority
  *
@@ -1729,14 +1745,8 @@ u8 dcb_getapp(struct net_device *dev, struct dcb_app *app)
 	u8 prio = 0;
 
 	spin_lock(&dcb_lock);
-	list_for_each_entry(itr, &dcb_app_list, list) {
-		if (itr->app.selector == app->selector &&
-		    itr->app.protocol == app->protocol &&
-		    itr->ifindex == dev->ifindex) {
-			prio = itr->app.priority;
-			break;
-		}
-	}
+	if ((itr = dcb_app_lookup(app, dev->ifindex, 0)))
+		prio = itr->app.priority;
 	spin_unlock(&dcb_lock);
 
 	return prio;
@@ -1762,18 +1772,14 @@ int dcb_setapp(struct net_device *dev, struct dcb_app *new)
 
 	spin_lock(&dcb_lock);
 	/* Search for existing match and replace */
-	list_for_each_entry(itr, &dcb_app_list, list) {
-		if (itr->app.selector == new->selector &&
-		    itr->app.protocol == new->protocol &&
-		    itr->ifindex == dev->ifindex) {
-			if (new->priority)
-				itr->app.priority = new->priority;
-			else {
-				list_del(&itr->list);
-				kfree(itr);
-			}
-			goto out;
+	if ((itr = dcb_app_lookup(new, dev->ifindex, 0))) {
+		if (new->priority)
+			itr->app.priority = new->priority;
+		else {
+			list_del(&itr->list);
+			kfree(itr);
 		}
+		goto out;
 	}
 	/* App type does not exist add new application type */
 	if (new->priority) {
@@ -1808,13 +1814,8 @@ u8 dcb_ieee_getapp_mask(struct net_device *dev, struct dcb_app *app)
 	u8 prio = 0;
 
 	spin_lock(&dcb_lock);
-	list_for_each_entry(itr, &dcb_app_list, list) {
-		if (itr->app.selector == app->selector &&
-		    itr->app.protocol == app->protocol &&
-		    itr->ifindex == dev->ifindex) {
-			prio |= 1 << itr->app.priority;
-		}
-	}
+	if ((itr = dcb_app_lookup(app, dev->ifindex, 0)))
+		prio |= 1 << itr->app.priority;
 	spin_unlock(&dcb_lock);
 
 	return prio;
@@ -1830,7 +1831,7 @@ EXPORT_SYMBOL(dcb_ieee_getapp_mask);
  */
 int dcb_ieee_setapp(struct net_device *dev, struct dcb_app *new)
 {
-	struct dcb_app_type *itr, *entry;
+	struct dcb_app_type *entry;
 	struct dcb_app_type event;
 	int err = 0;
 
@@ -1841,14 +1842,9 @@ int dcb_ieee_setapp(struct net_device *dev, struct dcb_app *new)
 
 	spin_lock(&dcb_lock);
 	/* Search for existing match and abort if found */
-	list_for_each_entry(itr, &dcb_app_list, list) {
-		if (itr->app.selector == new->selector &&
-		    itr->app.protocol == new->protocol &&
-		    itr->app.priority == new->priority &&
-		    itr->ifindex == dev->ifindex) {
-			err = -EEXIST;
-			goto out;
-		}
+	if (dcb_app_lookup(new, dev->ifindex, new->priority)) {
+		err = -EEXIST;
+		goto out;
 	}
 
 	/* App entry does not exist add new entry */
@@ -1887,19 +1883,12 @@ int dcb_ieee_delapp(struct net_device *dev, struct dcb_app *del)
 
 	spin_lock(&dcb_lock);
 	/* Search for existing match and remove it. */
-	list_for_each_entry(itr, &dcb_app_list, list) {
-		if (itr->app.selector == del->selector &&
-		    itr->app.protocol == del->protocol &&
-		    itr->app.priority == del->priority &&
-		    itr->ifindex == dev->ifindex) {
-			list_del(&itr->list);
-			kfree(itr);
-			err = 0;
-			goto out;
-		}
+	if ((itr = dcb_app_lookup(del, dev->ifindex, del->priority))) {
+		list_del(&itr->list);
+		kfree(itr);
+		err = 0;
 	}
 
-out:
 	spin_unlock(&dcb_lock);
 	if (!err)
 		call_dcbevent_notifiers(DCB_APP_EVENT, &event);
-- 
1.7.7.6
