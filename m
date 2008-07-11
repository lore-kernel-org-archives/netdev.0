From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH] netns:  Delete virtual interfaces during namespace cleanup
Date: Fri, 11 Jul 2008 13:07:11 -0700
Message-ID: <m1iqvcdw28.fsf@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@vger.kernel.org>,
	Linux Containers <containers@lists.osdl.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:44209 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754917AbYGKUMD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jul 2008 16:12:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


When physical devices are inside of network namespace and that network
namespace terminates we have to keep them and moving them to the
initial network namespace is the best we can do.

For virtual devices left in a network namespace that is exiting
we have no need to preserve them and we now have the infrastructure
that allows us to delete them.  So delete virtual devices when we
exit a network namespace.  Keeping the necessary user space clean up
after a network namespace exits much more tractable.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 net/core/dev.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index ea480a4..670abad 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4492,6 +4492,12 @@ static void __net_exit default_device_exit(struct net *net)
 		if (dev->features & NETIF_F_NETNS_LOCAL)
 			continue;
 
+		/* Delete virtual devices */
+		if (dev->rtnl_link_ops && dev->rtnl_link_ops->dellink) {
+			dev->rtnl_link_ops->dellink(dev);
+			continue;
+		}
+
 		/* Push remaing network devices to init_net */
 		snprintf(fb_name, IFNAMSIZ, "dev%d", dev->ifindex);
 		err = dev_change_net_namespace(dev, &init_net, fb_name);
-- 
1.5.3.rc6.17.g1911

