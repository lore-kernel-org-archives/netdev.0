From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH linux-3.18.y] rtnl: restore notifications for deleted interfaces
Date: Thu, 16 Jul 2015 11:31:43 +0200
Message-ID: <1437039103-4288-1-git-send-email-nicolas.dichtel@6wind.com>
References: <55A77422.8010305@6wind.com>
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	kristian.evensen@gmail.com, jiri@resnulli.us, j.vosburgh@gmail.com,
	vfalico@gmail.com, gospo@cumulusnetworks.com,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: sasha.levin@oracle.com, stable@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:44210 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752840AbbGPJcG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jul 2015 05:32:06 -0400
In-Reply-To: <55A77422.8010305@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The commit 984ff7a3e060 is an upstream backport. In fact, it depends on
commit 395eea6ccf2b ("rtnetlink: delay RTM_DELLINK notification until after ndo_uninit()")
which has not been backported in 3.18.y.

Before commit 395eea6ccf2b, rollback_registered_many() uses rtmsg_ifinfo().
The call to this function is done with dev->reg_state set to
NETREG_UNREGISTERING, thus testing this reg_state in rtmsg_ifinfo() is
wrong.

This patch partially reverts commit 984ff7a3e060.

Fixes: 984ff7a3e060 ("rtnl/bond: don't send rtnl msg for unregistered iface")
Reported-by: Kristian Evensen <kristian.evensen@gmail.com>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/core/rtnetlink.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 24d3242f0e01..c522f7a00eab 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -2229,9 +2229,6 @@ void rtmsg_ifinfo(int type, struct net_device *dev, unsigned int change,
 	int err = -ENOBUFS;
 	size_t if_info_size;
 
-	if (dev->reg_state != NETREG_REGISTERED)
-		return;
-
 	skb = nlmsg_new((if_info_size = if_nlmsg_size(dev, 0)), flags);
 	if (skb == NULL)
 		goto errout;
-- 
2.4.2
