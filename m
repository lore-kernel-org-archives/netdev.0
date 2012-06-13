From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 7/8] dcbnl: Move dcb app allocation into dcb_app_add()
Date: Wed, 13 Jun 2012 14:55:00 +0200
Message-ID: <d1899882a06c0271002efdc64b44a4ee45f71057.1339591572.git.tgraf@suug.ch>
References: <cover.1339591572.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, lucy.liu@intel.com,
	john.r.fastabend@intel.com, alexander.h.duyck@intel.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34521 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753482Ab2FMMzP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jun 2012 08:55:15 -0400
In-Reply-To: <cover.1339591572.git.tgraf@suug.ch>
In-Reply-To: <cover.1339591572.git.tgraf@suug.ch>
References: <cover.1339591572.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 net/dcb/dcbnl.c |   47 ++++++++++++++++++++++-------------------------
 1 files changed, 22 insertions(+), 25 deletions(-)

diff --git a/net/dcb/dcbnl.c b/net/dcb/dcbnl.c
index 6817f14..6e1c324 100644
--- a/net/dcb/dcbnl.c
+++ b/net/dcb/dcbnl.c
@@ -1732,6 +1732,21 @@ static struct dcb_app_type *dcb_app_lookup(const struct dcb_app *app,
 	return NULL;
 }
 
+static int dcb_app_add(const struct dcb_app *app, int ifindex)
+{
+	struct dcb_app_type *entry;
+
+	entry = kmalloc(sizeof(*entry), GFP_ATOMIC);
+	if (!entry)
+		return -ENOMEM;
+
+	memcpy(&entry->app, app, sizeof(*app));
+	entry->ifindex = ifindex;
+	list_add(&entry->list, &dcb_app_list);
+
+	return 0;
+}
+
 /**
  * dcb_getapp - retrieve the DCBX application user priority
  *
@@ -1764,6 +1779,7 @@ int dcb_setapp(struct net_device *dev, struct dcb_app *new)
 {
 	struct dcb_app_type *itr;
 	struct dcb_app_type event;
+	int err = 0;
 
 	event.ifindex = dev->ifindex;
 	memcpy(&event.app, new, sizeof(event.app));
@@ -1782,22 +1798,13 @@ int dcb_setapp(struct net_device *dev, struct dcb_app *new)
 		goto out;
 	}
 	/* App type does not exist add new application type */
-	if (new->priority) {
-		struct dcb_app_type *entry;
-		entry = kmalloc(sizeof(struct dcb_app_type), GFP_ATOMIC);
-		if (!entry) {
-			spin_unlock(&dcb_lock);
-			return -ENOMEM;
-		}
-
-		memcpy(&entry->app, new, sizeof(*new));
-		entry->ifindex = dev->ifindex;
-		list_add(&entry->list, &dcb_app_list);
-	}
+	if (new->priority)
+		err = dcb_app_add(new, dev->ifindex);
 out:
 	spin_unlock(&dcb_lock);
-	call_dcbevent_notifiers(DCB_APP_EVENT, &event);
-	return 0;
+	if (!err)
+		call_dcbevent_notifiers(DCB_APP_EVENT, &event);
+	return err;
 }
 EXPORT_SYMBOL(dcb_setapp);
 
@@ -1831,7 +1838,6 @@ EXPORT_SYMBOL(dcb_ieee_getapp_mask);
  */
 int dcb_ieee_setapp(struct net_device *dev, struct dcb_app *new)
 {
-	struct dcb_app_type *entry;
 	struct dcb_app_type event;
 	int err = 0;
 
@@ -1847,16 +1853,7 @@ int dcb_ieee_setapp(struct net_device *dev, struct dcb_app *new)
 		goto out;
 	}
 
-	/* App entry does not exist add new entry */
-	entry = kmalloc(sizeof(struct dcb_app_type), GFP_ATOMIC);
-	if (!entry) {
-		err = -ENOMEM;
-		goto out;
-	}
-
-	memcpy(&entry->app, new, sizeof(*new));
-	entry->ifindex = dev->ifindex;
-	list_add(&entry->list, &dcb_app_list);
+	err = dcb_app_add(new, dev->ifindex);
 out:
 	spin_unlock(&dcb_lock);
 	if (!err)
-- 
1.7.7.6
