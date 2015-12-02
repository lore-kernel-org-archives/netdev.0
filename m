From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 01/28] net: dev: Check CHANGEUPPER notifier return value
Date: Wed,  2 Dec 2015 21:07:24 +0100
Message-ID: <1449086871-19911-2-git-send-email-jiri@resnulli.us>
References: <1449086871-19911-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com, j.vosburgh@gmail.com,
	vfalico@gmail.com, gospo@cumulusnetworks.com,
	dsa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	pjonnala@broadcom.com, f.fainelli@gmail.com, sfeldma@gmail.com,
	john.fastabend@gmail.com, roopa@cumulusnetworks.com, andrew@lunn.ch
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:33825 "EHLO
	mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752681AbbLBUH4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2015 15:07:56 -0500
Received: by wmvv187 with SMTP id v187so272512452wmv.1
        for <netdev@vger.kernel.org>; Wed, 02 Dec 2015 12:07:55 -0800 (PST)
In-Reply-To: <1449086871-19911-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

switchdev drivers reflect the newly requested topology to hardware when
CHANGEUPPER is received, after software links were already formed.
However, the operation can fail and user will not be notified, as the
return value of the notifier is not checked.

Add this check and rollback software links if necessary.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
v1->v2:
-new patch
---
 net/core/dev.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 5df6cbc..df33f82 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5490,8 +5490,11 @@ static int __netdev_upper_dev_link(struct net_device *dev,
 			goto rollback_lower_mesh;
 	}
 
-	call_netdevice_notifiers_info(NETDEV_CHANGEUPPER, dev,
-				      &changeupper_info.info);
+	ret = call_netdevice_notifiers_info(NETDEV_CHANGEUPPER, dev,
+					    &changeupper_info.info);
+	if (ret)
+		goto rollback_lower_mesh;
+
 	return 0;
 
 rollback_lower_mesh:
-- 
1.9.3
