From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH 2/5] net: Allow to create links with given ifindex
Date: Mon, 06 Aug 2012 14:31:18 +0400
Message-ID: <501F9CF6.4020409@parallels.com>
References: <501F9CAF.3030605@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:26391 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752983Ab2HFKbX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Aug 2012 06:31:23 -0400
In-Reply-To: <501F9CAF.3030605@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently the RTM_NEWLINK results in -EOPNOTSUPP if the ifinfomsg->ifi_index
is not zero. I propose to allow requesting ifindices on link creation. This
is required by the checkpoint-restore to correctly restore a net namespace
(i.e. -- a container).

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

---
 net/core/dev.c       |    7 ++++++-
 net/core/rtnetlink.c |   12 +++++++-----
 2 files changed, 13 insertions(+), 6 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index f91abf8..3ca300d 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5579,7 +5579,12 @@ int register_netdevice(struct net_device *dev)
 		}
 	}
 
-	dev->ifindex = dev_new_index(net);
+	ret = -EBUSY;
+	if (!dev->ifindex)
+		dev->ifindex = dev_new_index(net);
+	else if (__dev_get_by_index(net, dev->ifindex))
+		goto err_uninit;
+
 	if (dev->iflink == -1)
 		dev->iflink = dev->ifindex;
 
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 2c5a0a0..1aa1456 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1812,8 +1812,6 @@ replay:
 			return -ENODEV;
 		}
 
-		if (ifm->ifi_index)
-			return -EOPNOTSUPP;
 		if (tb[IFLA_MAP] || tb[IFLA_MASTER] || tb[IFLA_PROTINFO])
 			return -EOPNOTSUPP;
 
@@ -1839,10 +1837,14 @@ replay:
 			return PTR_ERR(dest_net);
 
 		dev = rtnl_create_link(net, dest_net, ifname, ops, tb);
-
-		if (IS_ERR(dev))
+		if (IS_ERR(dev)) {
 			err = PTR_ERR(dev);
-		else if (ops->newlink)
+			goto out;
+		}
+
+		dev->ifindex = ifm->ifi_index;
+
+		if (ops->newlink)
 			err = ops->newlink(net, dev, tb, data);
 		else
 			err = register_netdevice(dev);
-- 
1.7.6.5
