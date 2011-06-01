From: =?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
Subject: [PATCH] caif: Fix race when conditionally taking rtnl lock
Date: Wed,  1 Jun 2011 12:55:37 +0200
Message-ID: <1306925737-1782-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sf1.isp.kq.no ([213.172.193.37]:42320 "EHLO pmx.vmail.no"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1161071Ab1FAKzr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Jun 2011 06:55:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Take the RTNL lock unconditionally when calling dev_close.
Taking the lock conditionally may cause race conditions.

Signed-off-by: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>
---
 net/caif/chnl_net.c |    9 +++------
 1 files changed, 3 insertions(+), 6 deletions(-)

diff --git a/net/caif/chnl_net.c b/net/caif/chnl_net.c
index 649ebac..adbb424 100644
--- a/net/caif/chnl_net.c
+++ b/net/caif/chnl_net.c
@@ -139,17 +139,14 @@ static void close_work(struct work_struct *work)
 	struct chnl_net *dev =3D NULL;
 	struct list_head *list_node;
 	struct list_head *_tmp;
-	/* May be called with or without RTNL lock held */
-	int islocked =3D rtnl_is_locked();
-	if (!islocked)
-		rtnl_lock();
+
+	rtnl_lock();
 	list_for_each_safe(list_node, _tmp, &chnl_net_list) {
 		dev =3D list_entry(list_node, struct chnl_net, list_field);
 		if (dev->state =3D=3D CAIF_SHUTDOWN)
 			dev_close(dev->netdev);
 	}
-	if (!islocked)
-		rtnl_unlock();
+	rtnl_unlock();
 }
 static DECLARE_WORK(close_worker, close_work);
=20
--=20
1.7.0.4

