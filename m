From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net] bridge: fix netconsole setup over bridge
Date: Thu,  6 Feb 2014 15:00:52 -0800
Message-ID: <1391727652-12520-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <cwang@twopensource.com>,
	Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:58601 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751297AbaBFXBH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Feb 2014 18:01:07 -0500
Received: by mail-pa0-f46.google.com with SMTP id rd3so2323377pab.19
        for <netdev@vger.kernel.org>; Thu, 06 Feb 2014 15:01:06 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <cwang@twopensource.com>

Commit 93d8bf9fb8f3 ("bridge: cleanup netpoll code") introduced
a check in br_netpoll_enable(), but this check is incorrect for
br_netpoll_setup(). This patch moves the code after the check
into __br_netpoll_enable() and calls it in br_netpoll_setup().
For br_add_if(), the check is still needed.

Fixes: 93d8bf9fb8f3 ("bridge: cleanup netpoll code")
Cc: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Cc: Stephen Hemminger <stephen@networkplumber.org>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <cwang@twopensource.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

---
diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index e4401a5..d9a9b0f 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -226,6 +226,33 @@ static void br_netpoll_cleanup(struct net_device *dev)
 		br_netpoll_disable(p);
 }
 
+static int __br_netpoll_enable(struct net_bridge_port *p, gfp_t gfp)
+{
+	struct netpoll *np;
+	int err;
+
+	np = kzalloc(sizeof(*p->np), gfp);
+	if (!np)
+		return -ENOMEM;
+
+	err = __netpoll_setup(np, p->dev, gfp);
+	if (err) {
+		kfree(np);
+		return err;
+	}
+
+	p->np = np;
+	return err;
+}
+
+int br_netpoll_enable(struct net_bridge_port *p, gfp_t gfp)
+{
+	if (!p->br->dev->npinfo)
+		return 0;
+
+	return __br_netpoll_enable(p, gfp);
+}
+
 static int br_netpoll_setup(struct net_device *dev, struct netpoll_info *ni,
 			    gfp_t gfp)
 {
@@ -236,7 +263,7 @@ static int br_netpoll_setup(struct net_device *dev, struct netpoll_info *ni,
 	list_for_each_entry(p, &br->port_list, list) {
 		if (!p->dev)
 			continue;
-		err = br_netpoll_enable(p, gfp);
+		err = __br_netpoll_enable(p, gfp);
 		if (err)
 			goto fail;
 	}
@@ -249,28 +276,6 @@ fail:
 	goto out;
 }
 
-int br_netpoll_enable(struct net_bridge_port *p, gfp_t gfp)
-{
-	struct netpoll *np;
-	int err;
-
-	if (!p->br->dev->npinfo)
-		return 0;
-
-	np = kzalloc(sizeof(*p->np), gfp);
-	if (!np)
-		return -ENOMEM;
-
-	err = __netpoll_setup(np, p->dev, gfp);
-	if (err) {
-		kfree(np);
-		return err;
-	}
-
-	p->np = np;
-	return err;
-}
-
 void br_netpoll_disable(struct net_bridge_port *p)
 {
 	struct netpoll *np = p->np;
