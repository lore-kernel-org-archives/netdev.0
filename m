From: sfeldma@gmail.com
Subject: [PATCH net-next v2] switchdev: fix BUG when port driver doesn't support set attr op
Date: Thu, 11 Jun 2015 08:19:01 -0700
Message-ID: <1434035941-13665-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, bblanco@plumgrid.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:36118 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752019AbbFKPRD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2015 11:17:03 -0400
Received: by pdjm12 with SMTP id m12so5928431pdj.3
        for <netdev@vger.kernel.org>; Thu, 11 Jun 2015 08:17:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

Fix a BUG_ON() where CONFIG_NET_SWITCHDEV is set but the driver for a
bridged port does not support switchdev_port_attr_set op.  Don't BUG_ON()
if -EOPNOTSUPP is returned.

Also change BUG_ON() to netdev_err since this is a normal error path and
does not warrant the use of BUG_ON(), which is reserved for unrecoverable
errs.

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
Reported-by: Brenden Blanco <bblanco@plumgrid.com>
---
 net/switchdev/switchdev.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index e008057..ecd1b3f 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -103,7 +103,9 @@ static void switchdev_port_attr_set_work(struct work_struct *work)
 
 	rtnl_lock();
 	err = switchdev_port_attr_set(asw->dev, &asw->attr);
-	BUG_ON(err);
+	if (err && err != -EOPNOTSUPP)
+		netdev_err(asw->dev, "failed (err=%d) to set attribute (id=%d)\n",
+			   err, asw->attr.id);
 	rtnl_unlock();
 
 	dev_put(asw->dev);
-- 
1.7.10.4
