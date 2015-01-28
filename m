From: roopa@cumulusnetworks.com
Subject: [PATCH] bridge: dont send notification when skb->len == 0 in rtnl_bridge_notify
Date: Tue, 27 Jan 2015 21:46:24 -0800
Message-ID: <1422423984-29743-1-git-send-email-roopa@cumulusnetworks.com>
To: netdev@vger.kernel.org, stephen@networkplumber.org,
	rami.rosen@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:46451 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750705AbbA1Fq3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jan 2015 00:46:29 -0500
Received: by mail-pa0-f44.google.com with SMTP id rd3so23312227pab.3
        for <netdev@vger.kernel.org>; Tue, 27 Jan 2015 21:46:28 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

Reported in: https://bugzilla.kernel.org/show_bug.cgi?id=92081

This patch avoids calling rtnl_notify if the device ndo_bridge_getlink
handler does not return any bytes in the skb.

Alternately, the skb->len check can be moved inside rtnl_notify.

For the bridge vlan case described in 92081, there is also a fix needed
in bridge driver to generate a proper notification. Will fix that in
subsequent patch.

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 net/core/rtnetlink.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 07447d1..e9d0f86 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -2934,7 +2934,7 @@ static int rtnl_bridge_notify(struct net_device *dev)
 	}
 
 	err = dev->netdev_ops->ndo_bridge_getlink(skb, 0, 0, dev, 0);
-	if (err < 0)
+	if (err < 0 || !skb->len)
 		goto errout;
 
 	rtnl_notify(skb, net, 0, RTNLGRP_LINK, NULL, GFP_ATOMIC);
@@ -2942,7 +2942,8 @@ static int rtnl_bridge_notify(struct net_device *dev)
 errout:
 	WARN_ON(err == -EMSGSIZE);
 	kfree_skb(skb);
-	rtnl_set_sk_err(net, RTNLGRP_LINK, err);
+	if (err)
+		rtnl_set_sk_err(net, RTNLGRP_LINK, err);
 	return err;
 }
 
-- 
1.7.10.4
