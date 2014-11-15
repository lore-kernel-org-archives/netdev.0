From: Anish Bhatt <anish@chelsio.com>
Subject: [PATCH net] dcbnl : Disable software interrupts before taking dcb_lock
Date: Fri, 14 Nov 2014 16:38:31 -0800
Message-ID: <1416011911-28998-1-git-send-email-anish@chelsio.com>
Cc: davem@davemloft.net, john.fastabend@gmail.com,
	neerav.parikh@intel.com, Anish Bhatt <anish@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 99-65-72-227.uvs.sntcca.sbcglobal.net ([99.65.72.227]:51049
	"EHLO stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754781AbaKOAiz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Nov 2014 19:38:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Solves possible lockup issues that can be seen from firmware DCB agents calling
into the DCB app api.

DCB firmware event queues can be tied in with NAPI so that dcb events are
generated in softIRQ context. This can results in calls to dcb_*app()
functions which try to take the dcb_lock.

If the the event triggers while we also have the dcb_lock because lldpad or
some other agent happened to be issuing a  get/set command we could see a cpu
lockup.

This code was not originally written with firmware agents in mind, hence
grabbing dcb_lock from softIRQ context was not considered.

Signed-off-by: Anish Bhatt <anish@chelsio.com>
---
 net/dcb/dcbnl.c | 36 ++++++++++++++++++------------------
 1 file changed, 18 insertions(+), 18 deletions(-)

diff --git a/net/dcb/dcbnl.c b/net/dcb/dcbnl.c
index ca11d28..93ea801 100644
--- a/net/dcb/dcbnl.c
+++ b/net/dcb/dcbnl.c
@@ -1080,13 +1080,13 @@ static int dcbnl_ieee_fill(struct sk_buff *skb, struct net_device *netdev)
 	if (!app)
 		return -EMSGSIZE;
 
-	spin_lock(&dcb_lock);
+	spin_lock_bh(&dcb_lock);
 	list_for_each_entry(itr, &dcb_app_list, list) {
 		if (itr->ifindex == netdev->ifindex) {
 			err = nla_put(skb, DCB_ATTR_IEEE_APP, sizeof(itr->app),
 					 &itr->app);
 			if (err) {
-				spin_unlock(&dcb_lock);
+				spin_unlock_bh(&dcb_lock);
 				return -EMSGSIZE;
 			}
 		}
@@ -1097,7 +1097,7 @@ static int dcbnl_ieee_fill(struct sk_buff *skb, struct net_device *netdev)
 	else
 		dcbx = -EOPNOTSUPP;
 
-	spin_unlock(&dcb_lock);
+	spin_unlock_bh(&dcb_lock);
 	nla_nest_end(skb, app);
 
 	/* get peer info if available */
@@ -1234,7 +1234,7 @@ static int dcbnl_cee_fill(struct sk_buff *skb, struct net_device *netdev)
 	}
 
 	/* local app */
-	spin_lock(&dcb_lock);
+	spin_lock_bh(&dcb_lock);
 	app = nla_nest_start(skb, DCB_ATTR_CEE_APP_TABLE);
 	if (!app)
 		goto dcb_unlock;
@@ -1271,7 +1271,7 @@ static int dcbnl_cee_fill(struct sk_buff *skb, struct net_device *netdev)
 	else
 		dcbx = -EOPNOTSUPP;
 
-	spin_unlock(&dcb_lock);
+	spin_unlock_bh(&dcb_lock);
 
 	/* features flags */
 	if (ops->getfeatcfg) {
@@ -1326,7 +1326,7 @@ static int dcbnl_cee_fill(struct sk_buff *skb, struct net_device *netdev)
 	return 0;
 
 dcb_unlock:
-	spin_unlock(&dcb_lock);
+	spin_unlock_bh(&dcb_lock);
 nla_put_failure:
 	return err;
 }
@@ -1762,10 +1762,10 @@ u8 dcb_getapp(struct net_device *dev, struct dcb_app *app)
 	struct dcb_app_type *itr;
 	u8 prio = 0;
 
-	spin_lock(&dcb_lock);
+	spin_lock_bh(&dcb_lock);
 	if ((itr = dcb_app_lookup(app, dev->ifindex, 0)))
 		prio = itr->app.priority;
-	spin_unlock(&dcb_lock);
+	spin_unlock_bh(&dcb_lock);
 
 	return prio;
 }
@@ -1789,7 +1789,7 @@ int dcb_setapp(struct net_device *dev, struct dcb_app *new)
 	if (dev->dcbnl_ops->getdcbx)
 		event.dcbx = dev->dcbnl_ops->getdcbx(dev);
 
-	spin_lock(&dcb_lock);
+	spin_lock_bh(&dcb_lock);
 	/* Search for existing match and replace */
 	if ((itr = dcb_app_lookup(new, dev->ifindex, 0))) {
 		if (new->priority)
@@ -1804,7 +1804,7 @@ int dcb_setapp(struct net_device *dev, struct dcb_app *new)
 	if (new->priority)
 		err = dcb_app_add(new, dev->ifindex);
 out:
-	spin_unlock(&dcb_lock);
+	spin_unlock_bh(&dcb_lock);
 	if (!err)
 		call_dcbevent_notifiers(DCB_APP_EVENT, &event);
 	return err;
@@ -1823,10 +1823,10 @@ u8 dcb_ieee_getapp_mask(struct net_device *dev, struct dcb_app *app)
 	struct dcb_app_type *itr;
 	u8 prio = 0;
 
-	spin_lock(&dcb_lock);
+	spin_lock_bh(&dcb_lock);
 	if ((itr = dcb_app_lookup(app, dev->ifindex, 0)))
 		prio |= 1 << itr->app.priority;
-	spin_unlock(&dcb_lock);
+	spin_unlock_bh(&dcb_lock);
 
 	return prio;
 }
@@ -1850,7 +1850,7 @@ int dcb_ieee_setapp(struct net_device *dev, struct dcb_app *new)
 	if (dev->dcbnl_ops->getdcbx)
 		event.dcbx = dev->dcbnl_ops->getdcbx(dev);
 
-	spin_lock(&dcb_lock);
+	spin_lock_bh(&dcb_lock);
 	/* Search for existing match and abort if found */
 	if (dcb_app_lookup(new, dev->ifindex, new->priority)) {
 		err = -EEXIST;
@@ -1859,7 +1859,7 @@ int dcb_ieee_setapp(struct net_device *dev, struct dcb_app *new)
 
 	err = dcb_app_add(new, dev->ifindex);
 out:
-	spin_unlock(&dcb_lock);
+	spin_unlock_bh(&dcb_lock);
 	if (!err)
 		call_dcbevent_notifiers(DCB_APP_EVENT, &event);
 	return err;
@@ -1882,7 +1882,7 @@ int dcb_ieee_delapp(struct net_device *dev, struct dcb_app *del)
 	if (dev->dcbnl_ops->getdcbx)
 		event.dcbx = dev->dcbnl_ops->getdcbx(dev);
 
-	spin_lock(&dcb_lock);
+	spin_lock_bh(&dcb_lock);
 	/* Search for existing match and remove it. */
 	if ((itr = dcb_app_lookup(del, dev->ifindex, del->priority))) {
 		list_del(&itr->list);
@@ -1890,7 +1890,7 @@ int dcb_ieee_delapp(struct net_device *dev, struct dcb_app *del)
 		err = 0;
 	}
 
-	spin_unlock(&dcb_lock);
+	spin_unlock_bh(&dcb_lock);
 	if (!err)
 		call_dcbevent_notifiers(DCB_APP_EVENT, &event);
 	return err;
@@ -1902,12 +1902,12 @@ static void dcb_flushapp(void)
 	struct dcb_app_type *app;
 	struct dcb_app_type *tmp;
 
-	spin_lock(&dcb_lock);
+	spin_lock_bh(&dcb_lock);
 	list_for_each_entry_safe(app, tmp, &dcb_app_list, list) {
 		list_del(&app->list);
 		kfree(app);
 	}
-	spin_unlock(&dcb_lock);
+	spin_unlock_bh(&dcb_lock);
 }
 
 static int __init dcbnl_init(void)
-- 
2.1.3
