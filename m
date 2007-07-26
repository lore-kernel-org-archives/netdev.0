From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 4/6] [NET]: Allow netdev REGISTER/CHANGENAME events to fail
Date: Thu, 26 Jul 2007 17:09:36 +0800
Message-ID: <E1IDzLk-0000AI-00@gondolin.me.apana.org.au>
References: <20070726090725.GA510@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1317 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756970AbXGZJJi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jul 2007 05:09:38 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[NET]: Allow netdev REGISTER/CHANGENAME events to fail

This patch adds code to allow errors to be passed up from event
handlers of NETDEV_REGISTER and NETDEV_CHANGENAME.  It also adds
the notifier_from_errno/notifier_to_errnor helpers to pass the
errno value up to the notifier caller.

If an error is detected when a device is registered, it causes
that operation to fail.  A NETDEV_UNREGISTER will be sent to
all event handlers.

Similarly if NETDEV_CHANGENAME fails the original name is restored
and a new NETDEV_CHANGENAME event is sent.

As such all event handlers must be idempotent with respect to
these events.

When an event handler is registered NETDEV_REGISTER events are
sent for all devices currently registered.  Should any of them
fail, we will send NETDEV_GOING_DOWN/NETDEV_DOWN/NETDEV_UNREGISTER
events to that handler for the devices which have already been
registered with it.  The handler registration itself will fail.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 include/linux/notifier.h |   13 +++++++++
 net/core/dev.c           |   62 +++++++++++++++++++++++++++++++++++++++--------
 2 files changed, 65 insertions(+), 10 deletions(-)

diff --git a/include/linux/notifier.h b/include/linux/notifier.h
index be3f2bb..fad7ff1 100644
--- a/include/linux/notifier.h
+++ b/include/linux/notifier.h
@@ -157,6 +157,19 @@ extern int __srcu_notifier_call_chain(struct srcu_notifier_head *nh,
  */
 #define NOTIFY_STOP		(NOTIFY_OK|NOTIFY_STOP_MASK)
 
+/* Encapsulate (negative) errno value (in particular, NOTIFY_BAD <=> EPERM). */
+static inline int notifier_from_errno(int err)
+{
+	return NOTIFY_STOP_MASK | (NOTIFY_OK - err);
+}
+
+/* Restore (negative) errno value from notify return value. */
+static inline int notifier_to_errno(int ret)
+{
+	ret &= ~NOTIFY_STOP_MASK;
+	return ret > NOTIFY_OK ? NOTIFY_OK - ret : 0;
+}
+
 /*
  *	Declared notifiers so far. I can imagine quite a few more chains
  *	over time (eg laptop power reset chains, reboot chain (to clean 
diff --git a/net/core/dev.c b/net/core/dev.c
index 0a35c15..d94b178 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -817,7 +817,9 @@ int dev_alloc_name(struct net_device *dev, const char *name)
  */
 int dev_change_name(struct net_device *dev, char *newname)
 {
+	char oldname[IFNAMSIZ];
 	int err = 0;
+	int ret;
 
 	ASSERT_RTNL();
 
@@ -827,6 +829,8 @@ int dev_change_name(struct net_device *dev, char *newname)
 	if (!dev_valid_name(newname))
 		return -EINVAL;
 
+	memcpy(oldname, dev->name, IFNAMSIZ);
+
 	if (strchr(newname, '%')) {
 		err = dev_alloc_name(dev, newname);
 		if (err < 0)
@@ -838,6 +842,7 @@ int dev_change_name(struct net_device *dev, char *newname)
 	else
 		strlcpy(dev->name, newname, IFNAMSIZ);
 
+rollback:
 	device_rename(&dev->dev, dev->name);
 
 	write_lock_bh(&dev_base_lock);
@@ -845,7 +850,20 @@ int dev_change_name(struct net_device *dev, char *newname)
 	hlist_add_head(&dev->name_hlist, dev_name_hash(dev->name));
 	write_unlock_bh(&dev_base_lock);
 
-	raw_notifier_call_chain(&netdev_chain, NETDEV_CHANGENAME, dev);
+	ret = raw_notifier_call_chain(&netdev_chain, NETDEV_CHANGENAME, dev);
+	ret = notifier_to_errno(ret);
+
+	if (ret) {
+		if (err) {
+			printk(KERN_ERR
+			       "%s: name change rollback failed: %d.\n",
+			       dev->name, ret);
+		} else {
+			err = ret;
+			memcpy(dev->name, oldname, IFNAMSIZ);
+			goto rollback;
+		}
+	}
 
 	return err;
 }
@@ -1058,20 +1076,43 @@ int dev_close(struct net_device *dev)
 int register_netdevice_notifier(struct notifier_block *nb)
 {
 	struct net_device *dev;
+	struct net_device *last;
 	int err;
 
 	rtnl_lock();
 	err = raw_notifier_chain_register(&netdev_chain, nb);
-	if (!err) {
-		for_each_netdev(dev) {
-			nb->notifier_call(nb, NETDEV_REGISTER, dev);
+	if (err)
+		goto unlock;
 
-			if (dev->flags & IFF_UP)
-				nb->notifier_call(nb, NETDEV_UP, dev);
-		}
+	for_each_netdev(dev) {
+		err = nb->notifier_call(nb, NETDEV_REGISTER, dev);
+		err = notifier_to_errno(err);
+		if (err)
+			goto rollback;
+
+		if (!(dev->flags & IFF_UP))
+			continue;
+
+		nb->notifier_call(nb, NETDEV_UP, dev);
 	}
+
+unlock:
 	rtnl_unlock();
 	return err;
+
+rollback:
+	last = dev;
+	for_each_netdev(dev) {
+		if (dev == last)
+			break;
+
+		if (dev->flags & IFF_UP) {
+			nb->notifier_call(nb, NETDEV_GOING_DOWN, dev);
+			nb->notifier_call(nb, NETDEV_DOWN, dev);
+		}
+		nb->notifier_call(nb, NETDEV_UNREGISTER, dev);
+	}
+	goto unlock;
 }
 
 /**
@@ -3430,9 +3471,10 @@ int register_netdevice(struct net_device *dev)
 	write_unlock_bh(&dev_base_lock);
 
 	/* Notify protocols, that a new device appeared. */
-	raw_notifier_call_chain(&netdev_chain, NETDEV_REGISTER, dev);
-
-	ret = 0;
+	ret = raw_notifier_call_chain(&netdev_chain, NETDEV_REGISTER, dev);
+	ret = notifier_to_errno(ret);
+	if (ret)
+		unregister_netdevice(dev);
 
 out:
 	return ret;
