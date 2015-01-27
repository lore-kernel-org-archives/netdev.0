From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next v2] rtnetlink: pass link_net to the newlink handler
Date: Tue, 27 Jan 2015 11:13:08 +0100
Message-ID: <1422353588-4830-1-git-send-email-nicolas.dichtel@6wind.com>
References: <54C61ED1.5040501@6wind.com>
Cc: davem@davemloft.net, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:41682 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757584AbbA0KNO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2015 05:13:14 -0500
In-Reply-To: <54C61ED1.5040501@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When IFLA_LINK_NETNSID is used, the netdevice should be built in this link netns
and moved at the end to another netns (pointed by the socket netns or
IFLA_NET_NS_[PID|FD]).

Existing user of the newlink handler will use the netns argument (src_net) to
find a link netdevice or to check some other information into the link netns.
For example, to find a netdevice, two information are required: an ifindex
(usually from IFLA_LINK) and a netns (this link netns).

Note: when using IFLA_LINK_NETNSID and IFLA_NET_NS_[PID|FD], a user may create a
netdevice that stands in netnsX and with its link part in netnsY, by sending a
rtnl message from netnsZ.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---

v2: instead of patching each subsystem, pass the right netns to
    the newlink handler

 net/core/rtnetlink.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 07447d1665e6..fedd7ab4085a 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -2148,7 +2148,7 @@ replay:
 		dev->ifindex = ifm->ifi_index;
 
 		if (ops->newlink) {
-			err = ops->newlink(net, dev, tb, data);
+			err = ops->newlink(link_net ? : net, dev, tb, data);
 			/* Drivers should call free_netdev() in ->destructor
 			 * and unregister it on failure after registration
 			 * so that device could be finally freed in rtnl_unlock.
-- 
2.2.2
