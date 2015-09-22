From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 10/10] switchdev: reduce transaction phase enum down to a boolean
Date: Tue, 22 Sep 2015 17:47:51 +0200
Message-ID: <1442936871-6147-1-git-send-email-jiri@resnulli.us>
References: <1442930031-4732-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	sfeldma@gmail.com, f.fainelli@gmail.com, linux@roeck-us.net,
	vivien.didelot@savoirfairelinux.com, rami.rosen@intel.com,
	roopa@cumulusnetworks.com, pjonnala@broadcom.com, andrew@lunn.ch,
	gospo@cumulusnetworks.com, Jiri Pirko <jiri@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f171.google.com ([209.85.212.171]:33506 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758446AbbIVPry (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2015 11:47:54 -0400
Received: by wiclk2 with SMTP id lk2so199840523wic.0
        for <netdev@vger.kernel.org>; Tue, 22 Sep 2015 08:47:53 -0700 (PDT)
In-Reply-To: <1442930031-4732-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Now, since we have only 2 values for transaction phase, just use bool.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/net/switchdev.h   | 11 +++--------
 net/switchdev/switchdev.c |  8 ++++----
 2 files changed, 7 insertions(+), 12 deletions(-)

diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index 9cf372f..1820787 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -17,11 +17,6 @@
 
 #define SWITCHDEV_F_NO_RECURSE		BIT(0)
 
-enum switchdev_trans_ph {
-	SWITCHDEV_TRANS_PREPARE,
-	SWITCHDEV_TRANS_COMMIT,
-};
-
 struct switchdev_trans_item {
 	struct list_head list;
 	void *data;
@@ -30,17 +25,17 @@ struct switchdev_trans_item {
 
 struct switchdev_trans {
 	struct list_head item_list;
-	enum switchdev_trans_ph ph;
+	bool ph_prepare;
 };
 
 static inline bool switchdev_trans_ph_prepare(struct switchdev_trans *trans)
 {
-	return trans && trans->ph == SWITCHDEV_TRANS_PREPARE;
+	return trans && trans->ph_prepare;
 }
 
 static inline bool switchdev_trans_ph_commit(struct switchdev_trans *trans)
 {
-	return trans && trans->ph == SWITCHDEV_TRANS_COMMIT;
+	return trans && !trans->ph_prepare;
 }
 
 enum switchdev_attr_id {
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index 4eab17d..89c2bc9 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -214,7 +214,7 @@ int switchdev_port_attr_set(struct net_device *dev, struct switchdev_attr *attr)
 	 * but should not commit the attr.
 	 */
 
-	trans.ph = SWITCHDEV_TRANS_PREPARE;
+	trans.ph_prepare = true;
 	err = __switchdev_port_attr_set(dev, attr, &trans);
 	if (err) {
 		/* Prepare phase failed: abort the transaction.  Any
@@ -233,7 +233,7 @@ int switchdev_port_attr_set(struct net_device *dev, struct switchdev_attr *attr)
 	 * because the driver said everythings was OK in phase I.
 	 */
 
-	trans.ph = SWITCHDEV_TRANS_COMMIT;
+	trans.ph_prepare = false;
 	err = __switchdev_port_attr_set(dev, attr, &trans);
 	WARN(err, "%s: Commit of attribute (id=%d) failed.\n",
 	     dev->name, attr->id);
@@ -297,7 +297,7 @@ int switchdev_port_obj_add(struct net_device *dev, struct switchdev_obj *obj)
 	 * but should not commit the obj.
 	 */
 
-	trans.ph = SWITCHDEV_TRANS_PREPARE;
+	trans.ph_prepare = true;
 	err = __switchdev_port_obj_add(dev, obj, &trans);
 	if (err) {
 		/* Prepare phase failed: abort the transaction.  Any
@@ -316,7 +316,7 @@ int switchdev_port_obj_add(struct net_device *dev, struct switchdev_obj *obj)
 	 * because the driver said everythings was OK in phase I.
 	 */
 
-	trans.ph = SWITCHDEV_TRANS_COMMIT;
+	trans.ph_prepare = false;
 	err = __switchdev_port_obj_add(dev, obj, &trans);
 	WARN(err, "%s: Commit of object (id=%d) failed.\n", dev->name, obj->id);
 	switchdev_trans_items_destroy(&trans);
-- 
1.9.3
