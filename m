From: Sergey Popovich <popovich_sergei@mail.ru>
Subject: [PATCH 1/3] rtnetlink: walk through all devs in netns safely on link params change
Date: Tue,  6 May 2014 18:13:15 +0300
Message-ID: <fbdc1e8c6b79ebdca8d9d81e5f53b4913c4c3e4e.1399388943.git.popovich_sergei@mail.ru>
References: <cover.1399388943.git.popovich_sergei@mail.ru>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fallback8.mail.ru ([94.100.176.136]:57343 "EHLO
	fallback8.mail.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932155AbaEFPSA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 May 2014 11:18:00 -0400
Received: from smtp10.mail.ru (smtp10.mail.ru [94.100.176.152])
	by fallback8.mail.ru (mPOP.Fallback_MX) with ESMTP id 833BB589BCE0
	for <netdev@vger.kernel.org>; Tue,  6 May 2014 19:13:55 +0400 (MSK)
Received: from [195.234.68.4] (port=41193 helo=tuxracer.skif.com.ua)
	by smtp10.mail.ru with esmtpa (envelope-from <popovich_sergei@mail.ru>)
	id 1Whh3w-0004LE-1O
	for netdev@vger.kernel.org; Tue, 06 May 2014 19:13:44 +0400
In-Reply-To: <cover.1399388943.git.popovich_sergei@mail.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changing parameters of group of network interfaces may lead to
system hang during change, caused by unsafe walking through
list of network interfaces in current network namespace.

This could be easily reproduced with following configuration:

  # ip netns add pc10
  # ip link add dev dummy128 group 128 type dummy
  # ip link set group 128 netns pc10

Fixes: e7ed828f10bd netlink: support setting devgroup parameters
Signed-off-by: Sergey Popovich <popovich_sergei@mail.ru>
---
 net/core/rtnetlink.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index d4ff417..95258e2 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1782,10 +1782,10 @@ static int rtnl_group_changelink(struct net *net, int group,
 		struct ifinfomsg *ifm,
 		struct nlattr **tb)
 {
-	struct net_device *dev;
+	struct net_device *dev, *aux;
 	int err;
 
-	for_each_netdev(net, dev) {
+	for_each_netdev_safe(net, dev, aux) {
 		if (dev->group == group) {
 			err = do_setlink(dev, ifm, tb, NULL, 0);
 			if (err < 0)
-- 
1.8.3.4
