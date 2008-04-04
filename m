From: Pavel Emelyanov <xemul@openvz.org>
Subject: [RFC][PATCH 3/3] Move net_device->uninit callback on net_device_ops.
Date: Fri, 04 Apr 2008 18:14:36 +0400
Message-ID: <47F637CC.30500@openvz.org>
References: <47F63681.1030603@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:58153 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752682AbYDDNvA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Apr 2008 09:51:00 -0400
Received: from [10.30.3.76] (swsoft-msk-nat.sw.ru [195.214.232.10])
	(authenticated bits=0)
	by sacred.ru (8.13.8/8.13.8) with ESMTP id m34Doqjb011577
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Fri, 4 Apr 2008 17:50:53 +0400
In-Reply-To: <47F63681.1030603@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The void calls are even simpler.

Plus ~18 more patches and all the ops will be moved on the
net_device_ops and it will be possible to start converting
device drivers...

So, what is your opinion about all this?

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 net/core/dev.c |   15 +++++++++++----
 1 files changed, 11 insertions(+), 4 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index a01c078..3428534 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3644,8 +3644,8 @@ static void rollback_registered(struct net_device *dev)
 	 */
 	dev_addr_discard(dev);
 
-	if (dev->uninit)
-		dev->uninit(dev);
+	if (dev->nd_ops->uninit)
+		dev->nd_ops->uninit(dev);
 
 	/* Notifier chain MUST detach us from master device. */
 	BUG_TRAP(!dev->master);
@@ -3804,8 +3804,8 @@ out:
 	return ret;
 
 err_uninit:
-	if (dev->uninit)
-		dev->uninit(dev);
+	if (dev->nd_ops->uninit)
+		dev->nd_ops->uninit(dev);
 	goto out;
 }
 
@@ -3988,8 +3988,15 @@ static int nd_default_init(struct net_device *dev)
 		return 0;
 }
 
+static void nd_default_uninit(struct net_device *dev)
+{
+	if (dev->uninit)
+		dev->uninit(dev);
+}
+
 static struct net_device_ops nd_default_ops = {
 	.init			= nd_default_init,
+	.uninit			= nd_default_uninit,
 };
 
 /**
-- 
1.5.3.4

