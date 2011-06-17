From: John Fastabend <john.r.fastabend@intel.com>
Subject: [PATCH 3/7] dcb: Add ieee_dcb_setapp() to be used for IEEE 802.1Qaz
	APP data
Date: Fri, 17 Jun 2011 14:16:24 -0700
Message-ID: <20110617211623.26578.88849.stgit@jf-dev1-dcblab>
References: <20110617211027.26578.11317.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shmulikr@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:23078 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757305Ab1FQVW4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Jun 2011 17:22:56 -0400
In-Reply-To: <20110617211027.26578.11317.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds a setapp routine for IEEE802.1Qaz encoded APP data types.
The IEEE 802.1Qaz spec encodes the priority bits differently and
allows for multiple APP data entries of the same selector and
protocol. Trying to force these to use the same set routines was
becoming tedious. Furthermore, userspace could probably enforce
the correct semantics, but expecting drivers to do this seems
error prone in the firmware case.

For these reasons add ieee_dcb_setapp() that understands the
IEEE 802.1Qaz encoded form.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---

 include/net/dcbnl.h |    1 +
 net/dcb/dcbnl.c     |   55 +++++++++++++++++++++++++++++++++++++++++++++++----
 2 files changed, 52 insertions(+), 4 deletions(-)

diff --git a/include/net/dcbnl.h b/include/net/dcbnl.h
index e5983c9..47a17d2 100644
--- a/include/net/dcbnl.h
+++ b/include/net/dcbnl.h
@@ -30,6 +30,7 @@ struct dcb_app_type {
 
 u8 dcb_setapp(struct net_device *, struct dcb_app *);
 u8 dcb_getapp(struct net_device *, struct dcb_app *);
+int dcb_ieee_setapp(struct net_device *, struct dcb_app *);
 
 /*
  * Ops struct for the netlink callbacks.  Used by DCB-enabled drivers through
diff --git a/net/dcb/dcbnl.c b/net/dcb/dcbnl.c
index b514579..4e77170 100644
--- a/net/dcb/dcbnl.c
+++ b/net/dcb/dcbnl.c
@@ -1398,7 +1398,7 @@ static int dcbnl_ieee_set(struct net_device *netdev, struct nlattr **tb,
 			if (ops->ieee_setapp)
 				err = ops->ieee_setapp(netdev, app_data);
 			else
-				err = dcb_setapp(netdev, app_data);
+				err = dcb_ieee_setapp(netdev, app_data);
 			if (err)
 				goto err;
 		}
@@ -1828,10 +1828,11 @@ u8 dcb_getapp(struct net_device *dev, struct dcb_app *app)
 EXPORT_SYMBOL(dcb_getapp);
 
 /**
- * ixgbe_dcbnl_setapp - add dcb application data to app list
+ * dcb_setapp - add CEE dcb application data to app list
  *
- * Priority 0 is the default priority this removes applications
- * from the app list if the priority is set to zero.
+ * Priority 0 is an invalid priority in CEE spec. This routine
+ * removes applications from the app list if the priority is
+ * set to zero.
  */
 u8 dcb_setapp(struct net_device *dev, struct dcb_app *new)
 {
@@ -1876,6 +1877,52 @@ out:
 }
 EXPORT_SYMBOL(dcb_setapp);
 
+/**
+ * dcb_ieee_setapp - add IEEE dcb application data to app list
+ *
+ * This adds Application data to the list. Multiple application
+ * entries may exists for the same selector and protocol as long
+ * as the priorities are different.
+ */
+int dcb_ieee_setapp(struct net_device *dev, struct dcb_app *new)
+{
+	struct dcb_app_type *itr, *entry;
+	struct dcb_app_type event;
+	int err = 0;
+
+	memcpy(&event.name, dev->name, sizeof(event.name));
+	memcpy(&event.app, new, sizeof(event.app));
+
+	spin_lock(&dcb_lock);
+	/* Search for existing match and abort if found */
+	list_for_each_entry(itr, &dcb_app_list, list) {
+		if (itr->app.selector == new->selector &&
+		    itr->app.protocol == new->protocol &&
+		    itr->app.priority == new->priority &&
+		    (strncmp(itr->name, dev->name, IFNAMSIZ) == 0)) {
+			err = -EEXIST;
+			goto out;
+		}
+	}
+
+	/* App entry does not exist add new entry */
+	entry = kmalloc(sizeof(struct dcb_app_type), GFP_ATOMIC);
+	if (!entry) {
+		err = -ENOMEM;
+		goto out;
+	}
+
+	memcpy(&entry->app, new, sizeof(*new));
+	strncpy(entry->name, dev->name, IFNAMSIZ);
+	list_add(&entry->list, &dcb_app_list);
+out:
+	spin_unlock(&dcb_lock);
+	if (!err)
+		call_dcbevent_notifiers(DCB_APP_EVENT, &event);
+	return err;
+}
+EXPORT_SYMBOL(dcb_ieee_setapp);
+
 static void dcb_flushapp(void)
 {
 	struct dcb_app_type *app;

