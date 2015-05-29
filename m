From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH net] xen: netback: read hotplug script once at start of day.
Date: Fri, 29 May 2015 17:24:53 +0100
Message-ID: <1432916693-21121-1-git-send-email-ian.campbell@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <wei.liu2@citrix.com>, <david.vrabel@citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>
To: <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:63199 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030196AbbE2Qar (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2015 12:30:47 -0400
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
for the lifetime of the vif device.

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
DaveM, could this go to all stable trees please.
---
 drivers/net/xen-netback/common.h |    2 ++
 drivers/net/xen-netback/xenbus.c |   29 ++++++++++++++++-------------
 2 files changed, 18 insertions(+), 13 deletions(-)

diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback/common.h
index 8a495b3..01b54e9 100644
--- a/drivers/net/xen-netback/common.h
+++ b/drivers/net/xen-netback/common.h
@@ -248,6 +248,8 @@ struct xenvif {
 
 	/* Miscellaneous private stuff. */
 	struct net_device *dev;
+
+	const char *hotplug_script;
 };
 
 struct xenvif_rx_cb {
diff --git a/drivers/net/xen-netback/xenbus.c b/drivers/net/xen-netback/xenbus.c
index 3d8dbf5..698b4ad 100644
--- a/drivers/net/xen-netback/xenbus.c
+++ b/drivers/net/xen-netback/xenbus.c
@@ -235,6 +235,7 @@ static int netback_remove(struct xenbus_device *dev)
 		kobject_uevent(&dev->dev.kobj, KOBJ_OFFLINE);
 		xen_unregister_watchers(be->vif);
 		xenbus_rm(XBT_NIL, dev->nodename, "hotplug-status");
+		kfree(be->vif->hotplug_script);
 		xenvif_free(be->vif);
 		be->vif = NULL;
 	}
@@ -379,24 +380,14 @@ static int netback_uevent(struct xenbus_device *xdev,
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
 
 	if (!be || !be->vif)
 		return 0;
 
+	if (add_uevent_var(env, "script=%s", be->vif->hotplug_script))
+		return -ENOMEM;
+
 	return add_uevent_var(env, "vif=%s", be->vif->dev->name);
 }
 
@@ -407,6 +398,7 @@ static int backend_create_xenvif(struct backend_info *be)
 	long handle;
 	struct xenbus_device *dev = be->dev;
 	struct xenvif *vif;
+	const char *script;
 
 	if (be->vif != NULL)
 		return 0;
@@ -417,12 +409,23 @@ static int backend_create_xenvif(struct backend_info *be)
 		return (err < 0) ? err : -EINVAL;
 	}
 
+	script = xenbus_read(XBT_NIL, dev->nodename, "script", NULL);
+	if (IS_ERR(script)) {
+		int err = PTR_ERR(script);
+		xenbus_dev_fatal(dev, err, "reading script");
+		return err;
+	}
+
 	vif = xenvif_alloc(&dev->dev, dev->otherend_id, handle);
 	if (IS_ERR(vif)) {
 		err = PTR_ERR(vif);
 		xenbus_dev_fatal(dev, err, "creating interface");
+		kfree(script);
 		return err;
 	}
+
+	vif->hotplug_script = script;
+
 	be->vif = vif;
 
 	kobject_uevent(&dev->dev.kobj, KOBJ_ONLINE);
-- 
1.7.10.4
