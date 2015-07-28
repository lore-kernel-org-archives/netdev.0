From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH net-next v5 2/2] af_mpls: fix undefined reference to ip6_route_output
Date: Tue, 28 Jul 2015 15:27:41 -0700
Message-ID: <1438122461-8350-3-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, tgraf@suug.ch, hannes@stressinduktion.org,
	rshearma@brocade.com, stephen@networkplumber.org,
	kuznet@ms2.inr.ac.ru, jon.maloy@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:34187 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750927AbbG1W1t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2015 18:27:49 -0400
Received: by pdbbh15 with SMTP id bh15so77607151pdb.1
        for <netdev@vger.kernel.org>; Tue, 28 Jul 2015 15:27:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

Undefined reference to ip6_route_output and ip_route_output
was reported with CONFIG_INET=n and CONFIG_IPV6=n.

This patch uses ipv6_stub_impl.ipv6_dst_lookup instead of
ip6_route_output. And wraps affected code under
IS_ENABLED(CONFIG_INET) and IS_ENABLED(CONFIG_IPV6).

Reported-by: kbuild test robot <fengguang.wu@intel.com>
Reported-by: Thomas Graf <tgraf@suug.ch>
Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 net/mpls/af_mpls.c |   39 +++++++++++++++++++++++++++++++--------
 1 file changed, 31 insertions(+), 8 deletions(-)

diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
index 49f1b0e..1c82888 100644
--- a/net/mpls/af_mpls.c
+++ b/net/mpls/af_mpls.c
@@ -15,7 +15,10 @@
 #include <net/ip_fib.h>
 #include <net/netevent.h>
 #include <net/netns/generic.h>
-#include <net/ip6_route.h>
+#if IS_ENABLED(CONFIG_IPV6)
+#include <net/ipv6.h>
+#include <net/addrconf.h>
+#endif
 #include "internal.h"
 
 #define LABEL_NOT_SPECIFIED (1<<20)
@@ -331,6 +334,7 @@ static unsigned find_free_label(struct net *net)
 	return LABEL_NOT_SPECIFIED;
 }
 
+#if IS_ENABLED(CONFIG_INET)
 static struct net_device *inet_fib_lookup_dev(struct net *net, void *addr)
 {
 	struct net_device *dev = NULL;
@@ -347,30 +351,47 @@ static struct net_device *inet_fib_lookup_dev(struct net *net, void *addr)
 
 	ip_rt_put(rt);
 
-errout:
 	return dev;
+errout:
+	return ERR_PTR(-ENODEV);
 }
+#else
+static struct net_device *inet_fib_lookup_dev(struct net *net, void *addr)
+{
+	return ERR_PTR(-EAFNOSUPPORT);
+}
+#endif
 
+#if IS_ENABLED(CONFIG_IPV6)
 static struct net_device *inet6_fib_lookup_dev(struct net *net, void *addr)
 {
 	struct net_device *dev = NULL;
 	struct dst_entry *dst;
 	struct flowi6 fl6;
 
+	if (!ipv6_stub)
+		return ERR_PTR(-EAFNOSUPPORT);
+
 	memset(&fl6, 0, sizeof(fl6));
 	memcpy(&fl6.daddr, addr, sizeof(struct in6_addr));
-	dst = ip6_route_output(net, NULL, &fl6);
-	if (dst->error)
+	if (ipv6_stub->ipv6_dst_lookup(net, NULL, &dst, &fl6))
 		goto errout;
 
 	dev = dst->dev;
 	dev_hold(dev);
-
-errout:
 	dst_release(dst);
 
 	return dev;
+
+errout:
+	return ERR_PTR(-ENODEV);
 }
+#else
+static struct net_device *inet6_fib_lookup_dev(struct net *net, void *addr)
+{
+	return ERR_PTR(-EAFNOSUPPORT);
+}
+#endif
 
 static struct net_device *find_outdev(struct net *net,
 				      struct mpls_route_config *cfg)
@@ -425,10 +446,12 @@ static int mpls_route_add(struct mpls_route_config *cfg)
 	if (cfg->rc_output_labels > MAX_NEW_LABELS)
 		goto errout;
 
-	err = -ENODEV;
 	dev = find_outdev(net, cfg);
-	if (!dev)
+	if (IS_ERR(dev)) {
+		err = PTR_ERR(dev);
+		dev = NULL;
 		goto errout;
+	}
 
 	/* Ensure this is a supported device */
 	err = -EINVAL;
-- 
1.7.10.4
