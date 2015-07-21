From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH net-next] mpls: make RTA_OIF optional
Date: Tue, 21 Jul 2015 09:16:24 -0700
Message-ID: <1437495384-15023-1-git-send-email-roopa@cumulusnetworks.com>
Cc: davem@davemloft.net, rshearma@brocade.com, netdev@vger.kernel.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:33609 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754360AbbGUQQ3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jul 2015 12:16:29 -0400
Received: by pdbnt7 with SMTP id nt7so52106713pdb.0
        for <netdev@vger.kernel.org>; Tue, 21 Jul 2015 09:16:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

If user did not specify an oif, try and get it from the via address.
If failed to get device, return with -ENODEV.

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 net/mpls/af_mpls.c |   67 +++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 66 insertions(+), 1 deletion(-)

diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
index 1f93a59..4cd3789 100644
--- a/net/mpls/af_mpls.c
+++ b/net/mpls/af_mpls.c
@@ -15,6 +15,7 @@
 #include <net/ip_fib.h>
 #include <net/netevent.h>
 #include <net/netns/generic.h>
+#include <net/ip6_route.h>
 #include "internal.h"
 
 #define LABEL_NOT_SPECIFIED (1<<20)
@@ -327,6 +328,70 @@ static unsigned find_free_label(struct net *net)
 	return LABEL_NOT_SPECIFIED;
 }
 
+static struct net_device *inet_fib_lookup_dev(struct net *net, void *addr)
+{
+	struct net_device *dev = NULL;
+	struct rtable *rt;
+	struct in_addr daddr;
+
+	memcpy(&daddr, addr, sizeof(struct in_addr));
+	rt = ip_route_output(net, daddr.s_addr, 0, 0, 0);
+	if (IS_ERR(rt))
+		goto errout;
+
+	dev = rt->dst.dev;
+	dev_hold(dev);
+
+	ip_rt_put(rt);
+
+errout:
+	return dev;
+}
+
+static struct net_device *inet6_fib_lookup_dev(struct net *net, void *addr)
+{
+	struct net_device *dev = NULL;
+	struct dst_entry *dst;
+	struct flowi6 fl6;
+
+	memset(&fl6, 0, sizeof(fl6));
+	memcpy(&fl6.daddr, addr, sizeof(struct in6_addr));
+	dst = ip6_route_output(net, NULL, &fl6);
+	if (dst->error)
+		goto errout;
+
+	dev = dst->dev;
+	dev_hold(dev);
+
+errout:
+	dst_release(dst);
+
+	return dev;
+}
+
+static struct net_device *find_outdev(struct net *net,
+				      struct mpls_route_config *cfg)
+{
+	struct net_device *dev = NULL;
+
+	if (!cfg->rc_ifindex) {
+		switch (cfg->rc_via_table) {
+		case NEIGH_ARP_TABLE:
+			dev = inet_fib_lookup_dev(net, cfg->rc_via);
+			break;
+		case NEIGH_ND_TABLE:
+			dev = inet6_fib_lookup_dev(net, cfg->rc_via);
+			break;
+		case NEIGH_LINK_TABLE:
+			break;
+		}
+	} else {
+		dev = dev_get_by_index(net, cfg->rc_ifindex);
+	}
+
+	return dev;
+}
+
 static int mpls_route_add(struct mpls_route_config *cfg)
 {
 	struct mpls_route __rcu **platform_label;
@@ -358,7 +423,7 @@ static int mpls_route_add(struct mpls_route_config *cfg)
 		goto errout;
 
 	err = -ENODEV;
-	dev = dev_get_by_index(net, cfg->rc_ifindex);
+	dev = find_outdev(net, cfg);
 	if (!dev)
 		goto errout;
 
-- 
1.7.10.4
