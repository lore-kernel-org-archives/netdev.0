From: John Fastabend <john.r.fastabend@intel.com>
Subject: [PATCH 5/7] dcb: Add dcb_ieee_getapp_mask() for drivers to query APP
	settings
Date: Fri, 17 Jun 2011 14:16:35 -0700
Message-ID: <20110617211634.26578.59372.stgit@jf-dev1-dcblab>
References: <20110617211027.26578.11317.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shmulikr@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:43341 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758014Ab1FQVXH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Jun 2011 17:23:07 -0400
In-Reply-To: <20110617211027.26578.11317.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With multiple APP entries per selector and protocol drivers
or stacks may want to pick a specific value or stripe traffic
across many priorities. Also if an APP entry in use is
deleted the stack/driver may want to choose from the existing
APP entries.

To facilitate this and avoid having duplicate code to walk
the APP ring provide a routine dcb_ieee_getapp_mask() to
return a u8 bitmask of all priorities set for the specified
selector and protocol. This routine and bitmask is a helper
for DCB kernel users.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---

 include/net/dcbnl.h |    1 +
 net/dcb/dcbnl.c     |   26 ++++++++++++++++++++++++++
 2 files changed, 27 insertions(+), 0 deletions(-)

diff --git a/include/net/dcbnl.h b/include/net/dcbnl.h
index 8c545b1..0a28788 100644
--- a/include/net/dcbnl.h
+++ b/include/net/dcbnl.h
@@ -32,6 +32,7 @@ u8 dcb_setapp(struct net_device *, struct dcb_app *);
 u8 dcb_getapp(struct net_device *, struct dcb_app *);
 int dcb_ieee_setapp(struct net_device *, struct dcb_app *);
 int dcb_ieee_delapp(struct net_device *, struct dcb_app *);
+u8 dcb_ieee_getapp_mask(struct net_device *, struct dcb_app *);
 
 /*
  * Ops struct for the netlink callbacks.  Used by DCB-enabled drivers through
diff --git a/net/dcb/dcbnl.c b/net/dcb/dcbnl.c
index 233a6fc..87010ef 100644
--- a/net/dcb/dcbnl.c
+++ b/net/dcb/dcbnl.c
@@ -1928,6 +1928,32 @@ out:
 EXPORT_SYMBOL(dcb_setapp);
 
 /**
+ * dcb_ieee_getapp_mask - retrieve the IEEE DCB application priority
+ *
+ * Helper routine which on success returns a non-zero 802.1Qaz user
+ * priority bitmap otherwise returns 0 to indicate the dcb_app was
+ * not found in APP list.
+ */
+u8 dcb_ieee_getapp_mask(struct net_device *dev, struct dcb_app *app)
+{
+	struct dcb_app_type *itr;
+	u8 prio = 0;
+
+	spin_lock(&dcb_lock);
+	list_for_each_entry(itr, &dcb_app_list, list) {
+		if (itr->app.selector == app->selector &&
+		    itr->app.protocol == app->protocol &&
+		    (strncmp(itr->name, dev->name, IFNAMSIZ) == 0)) {
+			prio |= 1 << itr->app.priority;
+		}
+	}
+	spin_unlock(&dcb_lock);
+
+	return prio;
+}
+EXPORT_SYMBOL(dcb_ieee_getapp_mask);
+
+/**
  * dcb_ieee_setapp - add IEEE dcb application data to app list
  *
  * This adds Application data to the list. Multiple application

