From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 2/2][BRIDGE]: Consolidate error paths in br_add_bridge().
Date: Sun, 04 May 2008 10:49:21 +0400
Message-ID: <481D5C71.9000005@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:56566 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752068AbYEDGwA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 4 May 2008 02:52:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This actually had to be merged with the patch #1, but I decided
not to mix two changes in one patch.

There are already two calls to free_netdev() in there, so merge
them into one.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 net/bridge/br_if.c |   16 ++++++++--------
 1 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index bff0f5b..c2397f5 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -273,17 +273,13 @@ int br_add_bridge(const char *name)
 	rtnl_lock();
 	if (strchr(dev->name, '%')) {
 		ret = dev_alloc_name(dev, dev->name);
-		if (ret < 0) {
-			free_netdev(dev);
-			goto out;
-		}
+		if (ret < 0)
+			goto out_free;
 	}
 
 	ret = register_netdevice(dev);
-	if (ret) {
-		free_netdev(dev);
-		goto out;
-	}
+	if (ret)
+		goto out_free;
 
 	ret = br_sysfs_addbr(dev);
 	if (ret)
@@ -291,6 +287,10 @@ int br_add_bridge(const char *name)
  out:
 	rtnl_unlock();
 	return ret;
+
+out_free:
+	free_netdev(dev);
+	goto out;
 }
 
 int br_del_bridge(const char *name)
-- 
1.5.3.4

