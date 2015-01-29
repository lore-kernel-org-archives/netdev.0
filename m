From: roopa@cumulusnetworks.com
Subject: [PATCH v2] bridge: dont send notification when skb->len == 0 in rtnl_bridge_notify
Date: Wed, 28 Jan 2015 16:23:11 -0800
Message-ID: <1422490991-4033-1-git-send-email-roopa@cumulusnetworks.com>
To: netdev@vger.kernel.org, davem@davemloft.net,
	stephen@networkplumber.org, rami.rosen@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:59092 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752620AbbA2BPw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jan 2015 20:15:52 -0500
Received: by mail-pa0-f45.google.com with SMTP id et14so32053627pad.4
        for <netdev@vger.kernel.org>; Wed, 28 Jan 2015 17:15:52 -0800 (PST)
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

v2: rebase patch on net tree

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 net/core/rtnetlink.c |    6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 9cf6fe9..446cbaf 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -2895,12 +2895,16 @@ static int rtnl_bridge_notify(struct net_device *dev, u16 flags)
 			goto errout;
 	}
 
+	if (!skb->len)
+		goto errout;
+
 	rtnl_notify(skb, net, 0, RTNLGRP_LINK, NULL, GFP_ATOMIC);
 	return 0;
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
