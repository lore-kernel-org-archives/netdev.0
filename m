From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH v2 net] xen: netback: read hotplug script once at start of day.
Date: Mon, 1 Jun 2015 11:30:24 +0100
Message-ID: <1433154624-28123-1-git-send-email-ian.campbell@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <wei.liu2@citrix.com>, <david.vrabel@citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>
To: <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:25128 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751319AbbFAKoy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2015 06:44:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When we come to tear things down in netback_remove() and generate the
uevent it is possible that the xenstore directory has already been
removed (details below).

In such cases netback_uevent() won't be able to read the hotplug
script and will write a xenstore error node.

A recent change to the hypervisor exposed this race such that we now
sometimes lose it (where apparently we didn't ever before).

Instead read the hotplug script configuration during setup and use it
for the lifetime of the backend device.

The apparently more obvious fix of moving the transition to
state=Closed in netback_remove() to after the uevent does not work
because it is possible that we are already in state=Closed (in
reaction to the guest having disconnected as it shutdown). Being
already in Closed means the toolstack is at liberty to start tearing
down the xenstore directories. In principal it might be possible to
arrange to unregister the device sooner (e.g on transition to Closing)
such that xenstore would still be there but this state machine is
fragile and prone to anger...

A modern Xen system only relies on the hotplug uevent for driver
domains, when the backend is in the same domain as the toolstack it
will run the necessary setup/teardown directly in the correct sequence
wrt xenstore changes.

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
---
v2: Move script to backend_info and read/free it in
netback_{probe,remove}.

DaveM, could this go to all stable trees please.
---
 drivers/net/xen-netback/xenbus.c |   33 +++++++++++++++++++--------------
 1 file changed, 19 insertions(+), 14 deletions(-)

diff --git a/drivers/net/xen-netback/xenbus.c b/drivers/net/xen-netback/xenbus.c
index 3d8dbf5..6380b28 100644
--- a/drivers/net/xen-netback/xenbus.c
+++ b/drivers/net/xen-netback/xenbus.c
@@ -34,6 +34,8 @@ struct backend_info {
 	enum xenbus_state frontend_state;
 	struct xenbus_watch hotplug_status_watch;
 	u8 have_hotplug_status_watch:1;
+
+	const char *hotplug_script;
 };
 
 static int connect_rings(struct backend_info *be, struct xenvif_queue *queue);
@@ -238,6 +240,7 @@ static int netback_remove(struct xenbus_device *dev)
 		xenvif_free(be->vif);
 		be->vif = NULL;
 	}
+	kfree(be->hotplug_script);
 	kfree(be);
 	dev_set_drvdata(&dev->dev, NULL);
 	return 0;
@@ -255,6 +258,7 @@ static int netback_probe(struct xenbus_device *dev,
 	struct xenbus_transaction xbt;
 	int err;
 	int sg;
+	const char *script;
 	struct backend_info *be = kzalloc(sizeof(struct backend_info),
 					  GFP_KERNEL);
 	if (!be) {
@@ -347,6 +351,15 @@ static int netback_probe(struct xenbus_device *dev,
 	if (err)
 		pr_debug("Error writing multi-queue-max-queues\n");
 
+	script = xenbus_read(XBT_NIL, dev->nodename, "script", NULL);
+	if (IS_ERR(script)) {
+		err = PTR_ERR(script);
+		xenbus_dev_fatal(dev, err, "reading script");
+		goto fail;
+	}
+
+	be->hotplug_script = script;
+
 	err = xenbus_switch_state(dev, XenbusStateInitWait);
 	if (err)
 		goto fail;
@@ -379,22 +392,14 @@ static int netback_uevent(struct xenbus_device *xdev,
 			  struct kobj_uevent_env *env)
 {
 	struct backend_info *be = dev_get_drvdata(&xdev->dev);
-	char *val;
 
-	val = xenbus_read(XBT_NIL, xdev->nodename, "script", NULL);
-	if (IS_ERR(val)) {
-		int err = PTR_ERR(val);
-		xenbus_dev_fatal(xdev, err, "reading script");
-		return err;
-	} else {
-		if (add_uevent_var(env, "script=%s", val)) {
-			kfree(val);
-			return -ENOMEM;
-		}
-		kfree(val);
-	}
+	if (!be)
+		return 0;
+
+	if (add_uevent_var(env, "script=%s", be->hotplug_script))
+		return -ENOMEM;
 
-	if (!be || !be->vif)
+	if (!be->vif)
 		return 0;
 
 	return add_uevent_var(env, "vif=%s", be->vif->dev->name);
-- 
1.7.10.4
