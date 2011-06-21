From: John Fastabend <john.r.fastabend@intel.com>
Subject: [net-next PATCH v2 5/7] dcb: Add dcb_ieee_getapp_mask() for drivers
	to query APP settings
Date: Tue, 21 Jun 2011 10:34:53 -0700
Message-ID: <20110621173453.2777.26992.stgit@jf-dev1-dcblab>
References: <20110621173431.2777.39482.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shmulikr@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:21162 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757082Ab1FURlb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Jun 2011 13:41:31 -0400
In-Reply-To: <20110621173431.2777.39482.stgit@jf-dev1-dcblab>
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
index 62a2685..c14fd94 100644
--- a/include/net/dcbnl.h
+++ b/include/net/dcbnl.h
@@ -32,6 +32,7 @@ u8 dcb_setapp(struct net_device *, struct dcb_app *);
 u8 dcb_getapp(struct net_device *, struct dcb_app *);
 int dcb_ieee_setapp(struct net_device *, struct dcb_app *);
 int dcb_ieee_delapp(struct net_device *, struct dcb_app *);
+u8 dcb_ieee_getapp_mask(struct net_device *, struct dcb_app *);
 
 int dcbnl_notify(struct net_device *dev, int event, int cmd, u32 seq, u32 pid);
 
diff --git a/net/dcb/dcbnl.c b/net/dcb/dcbnl.c
index 196084f..b7d0be0 100644
--- a/net/dcb/dcbnl.c
+++ b/net/dcb/dcbnl.c
@@ -1929,6 +1929,32 @@ out:
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

