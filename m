From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: [PATCH] xen-netfront: avoid crashing on resume after a failure in talk_to_netback()
Date: Thu,  4 May 2017 14:23:04 +0200
Message-ID: <20170504122304.11735-1-vkuznets@redhat.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Boris Ostrovsky <boris.ostrovsky@oracle.com>,
        Juergen Gross <jgross@suse.com>
To: xen-devel@lists.xenproject.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34690 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750710AbdEDMXH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 4 May 2017 08:23:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Unavoidable crashes in netfront_resume() and netback_changed() after a
previous fail in talk_to_netback() (e.g. when we fail to read MAC from
xenstore) were discovered. The failure path in talk_to_netback() does
unregister/free for netdev but we don't reset drvdata and we try accessing
it again after resume.

Reset drvdata in netback_changed() the same way we reset it in
netfront_probe() and check for NULL in both netfront_resume() and
netback_changed() to properly handle the situation.

Signed-off-by: Vitaly Kuznetsov <vkuznets@redhat.com>
---
I apologize for sending this during the merge window, I'm not sure if this
needs to go through xen or netdev tree. I think the fix is simple enough
and it would make sense to squeeze it in 4.12 if possible. Thanks.
---
 drivers/net/xen-netfront.c | 11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index 6ffc482..92f746c 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -1426,6 +1426,9 @@ static int netfront_resume(struct xenbus_device *dev)
 {
 	struct netfront_info *info = dev_get_drvdata(&dev->dev);
 
+	if (!info)
+		return 0;
+
 	dev_dbg(&dev->dev, "%s\n", dev->nodename);
 
 	xennet_disconnect_backend(info);
@@ -1936,6 +1939,7 @@ static int talk_to_netback(struct xenbus_device *dev,
  out:
 	unregister_netdev(info->netdev);
 	xennet_free_netdev(info->netdev);
+	dev_set_drvdata(&dev->dev, NULL);
 	return err;
 }
 
@@ -1997,7 +2001,12 @@ static void netback_changed(struct xenbus_device *dev,
 			    enum xenbus_state backend_state)
 {
 	struct netfront_info *np = dev_get_drvdata(&dev->dev);
-	struct net_device *netdev = np->netdev;
+	struct net_device *netdev;
+
+	if (!np)
+		return;
+
+	netdev = np->netdev;
 
 	dev_dbg(&dev->dev, "%s\n", xenbus_strstate(backend_state));
 
-- 
2.9.3
