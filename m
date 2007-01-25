From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH RFC 25/31] net: Make wireless netlink event generation handle multiple network namespaces
Date: Thu, 25 Jan 2007 12:00:27 -0700
Message-ID: <11697516381204-git-send-email-ebiederm@xmission.com>
References: <m13b5zym0n.fsf@ebiederm.dsl.xmission.com>
Cc: <containers@lists.osdl.org>, <openib-general@openib.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:35818 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030308AbXAYTBl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jan 2007 14:01:41 -0500
In-Reply-To: <m13b5zym0n.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric W. Biederman <ebiederm@xmission.com> - unquoted

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 net/core/wireless.c |   15 ++++++++++-----
 1 files changed, 10 insertions(+), 5 deletions(-)

diff --git a/net/core/wireless.c b/net/core/wireless.c
index 9036359..d534617 100644
--- a/net/core/wireless.c
+++ b/net/core/wireless.c
@@ -1934,8 +1934,13 @@ static void wireless_nlevent_process(unsigned long data)
 {
 	struct sk_buff *skb;
 
-	while ((skb = skb_dequeue(&wireless_nlevent_queue)))
-		rtnl_notify(skb, init_net(), 0, RTNLGRP_LINK, NULL, GFP_ATOMIC);
+	while ((skb = skb_dequeue(&wireless_nlevent_queue))) {
+		struct net_device *dev = skb->dev;
+		net_t net = dev->nd_net;
+		skb->dev = NULL;
+		rtnl_notify(skb, net, 0, RTNLGRP_LINK, NULL, GFP_ATOMIC);
+		dev_put(dev);
+	}
 }
 
 static DECLARE_TASKLET(wireless_nlevent_tasklet, wireless_nlevent_process, 0);
@@ -1992,9 +1997,6 @@ static inline void rtmsg_iwinfo(struct net_device *	dev,
 	struct sk_buff *skb;
 	int size = NLMSG_GOODSIZE;
 
-	if (!net_eq(dev->nd_net, init_net()))
-		return;
-
 	skb = alloc_skb(size, GFP_ATOMIC);
 	if (!skb)
 		return;
@@ -2004,6 +2006,9 @@ static inline void rtmsg_iwinfo(struct net_device *	dev,
 		kfree_skb(skb);
 		return;
 	}
+	/* Remember the device until we are in process context */
+	dev_hold(dev);
+	skb->dev = dev;
 	NETLINK_CB(skb).dst_group = RTNLGRP_LINK;
 	skb_queue_tail(&wireless_nlevent_queue, skb);
 	tasklet_schedule(&wireless_nlevent_tasklet);
-- 
1.4.4.1.g278f

