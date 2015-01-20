From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next 1/6] rtnl: fix error path when adding an iface with a link net
Date: Tue, 20 Jan 2015 15:15:42 +0100
Message-ID: <1421763347-4354-2-git-send-email-nicolas.dichtel@6wind.com>
References: <1421763347-4354-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:53801 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751980AbbATOP5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2015 09:15:57 -0500
In-Reply-To: <1421763347-4354-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If an error occurs when the netdevice is moved to the link netns, a full cleanup
must be done.

Fixes: 317f4810e45e ("rtnl: allow to create device with IFLA_LINK_NETNSID set")
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/core/rtnetlink.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index a12eecc0f976..07447d1665e6 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -2172,8 +2172,11 @@ replay:
 			goto out;
 		}
 
-		if (link_net)
+		if (link_net) {
 			err = dev_change_net_namespace(dev, dest_net, ifname);
+			if (err < 0)
+				unregister_netdevice(dev);
+		}
 out:
 		if (link_net)
 			put_net(link_net);
-- 
2.2.2
