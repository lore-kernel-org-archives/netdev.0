From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v3 01/28] net: Check CHANGEUPPER notifier return value
Date: Thu,  3 Dec 2015 12:12:03 +0100
Message-ID: <1449141150-8172-2-git-send-email-jiri@resnulli.us>
References: <1449141150-8172-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com, j.vosburgh@gmail.com,
	vfalico@gmail.com, gospo@cumulusnetworks.com,
	dsa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	pjonnala@broadcom.com, f.fainelli@gmail.com, sfeldma@gmail.com,
	john.fastabend@gmail.com, roopa@cumulusnetworks.com, andrew@lunn.ch
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:37246 "EHLO
	mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759809AbbLCLMj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2015 06:12:39 -0500
Received: by wmww144 with SMTP id w144so17295546wmw.0
        for <netdev@vger.kernel.org>; Thu, 03 Dec 2015 03:12:38 -0800 (PST)
In-Reply-To: <1449141150-8172-1-git-send-email-jiri@resnulli.us>
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
v2->v3:
- convert notify return value to errno and check it instead of
  the notify return value - spotted by JohnF
v1->v2:
-new patch
---
 net/core/dev.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 5df6cbc..939cd1b 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5490,8 +5490,12 @@ static int __netdev_upper_dev_link(struct net_device *dev,
 			goto rollback_lower_mesh;
 	}
 
-	call_netdevice_notifiers_info(NETDEV_CHANGEUPPER, dev,
-				      &changeupper_info.info);
+	ret = call_netdevice_notifiers_info(NETDEV_CHANGEUPPER, dev,
+					    &changeupper_info.info);
+	ret = notifier_to_errno(ret);
+	if (ret)
+		goto rollback_lower_mesh;
+
 	return 0;
 
 rollback_lower_mesh:
-- 
1.9.3
