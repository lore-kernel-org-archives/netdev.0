From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH net-next v4] af_mpls: fix undefined reference to ip6_route_output
Date: Mon, 27 Jul 2015 23:40:24 -0700
Message-ID: <1438065624-38229-1-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:33143 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751238AbbG1Gk3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2015 02:40:29 -0400
Received: by padck2 with SMTP id ck2so64741714pad.0
        for <netdev@vger.kernel.org>; Mon, 27 Jul 2015 23:40:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

Undefined reference to ip6_route_output and ip_route_output
was reported with CONFIG_INET=n and CONFIG_IPV6=n.

This patch adds new CONFIG_MPLS_NEXTHOP_DEVLOOKUP
to lookup nexthop device if user has not specified it
in RTA_OIF attribute. Make CONFIG_MPLS_NEXTHOP_DEVLOOKUP
depend on INET and (IPV6 || IPV6=n) because it
uses ip6_route_output and ip_route_output.

Reported-by: kbuild test robot <fengguang.wu@intel.com>
Reported-by: Thomas Graf <tgraf@suug.ch>
Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---

v1 - v2: use IS_BUILTIN

v2 - v3: Use new Kconfig option that depends on (IPV6 || IPV6=n) as
	 suggested by Dave. Also uses IS_ERR as suggested by Thomas.

v3 - v4: Include missed case of (MPLS_ROUTING=y && IPV6=m) reported by
         Dave.

 net/mpls/Kconfig   |    8 ++++++++
 net/mpls/af_mpls.c |   19 ++++++++++++++++++-
 2 files changed, 26 insertions(+), 1 deletion(-)

diff --git a/net/mpls/Kconfig b/net/mpls/Kconfig
index 5c467ef..134764e 100644
--- a/net/mpls/Kconfig
+++ b/net/mpls/Kconfig
@@ -33,4 +33,12 @@ config MPLS_IPTUNNEL
 	---help---
 	 mpls ip tunnel support.
 
+config MPLS_NEXTHOP_DEVLOOKUP
+	bool "MPLS: nexthop oif dev lookup"
+	depends on MPLS_ROUTING && INET && \
+		((IPV6 && !(MPLS_ROUTING=y && IPV6=m)) || IPV6=n)
+	---help---
+	 This enables mpls route nexthop dev lookup when oif is not
+	 specified by user
+
 endif # MPLS
diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
index 49f1b0e..3e0c0212d 100644
--- a/net/mpls/af_mpls.c
+++ b/net/mpls/af_mpls.c
@@ -331,6 +331,7 @@ static unsigned find_free_label(struct net *net)
 	return LABEL_NOT_SPECIFIED;
 }
 
+#if IS_ENABLED(CONFIG_MPLS_NEXTHOP_DEVLOOKUP)
 static struct net_device *inet_fib_lookup_dev(struct net *net, void *addr)
 {
 	struct net_device *dev = NULL;
@@ -350,7 +351,14 @@ static struct net_device *inet_fib_lookup_dev(struct net *net, void *addr)
 errout:
 	return dev;
 }
+#else
+static struct net_device *inet_fib_lookup_dev(struct net *net, void *addr)
+{
+	return ERR_PTR(-EAFNOSUPPORT);
+}
+#endif
 
+#if IS_ENABLED(CONFIG_MPLS_NEXTHOP_DEVLOOKUP) && IS_ENABLED(CONFIG_IPV6)
 static struct net_device *inet6_fib_lookup_dev(struct net *net, void *addr)
 {
 	struct net_device *dev = NULL;
@@ -371,6 +379,12 @@ errout:
 
 	return dev;
 }
+#else
+static struct net_device *inet6_fib_lookup_dev(struct net *net, void *addr)
+{
+	return ERR_PTR(-EAFNOSUPPORT);
+}
+#endif
 
 static struct net_device *find_outdev(struct net *net,
 				      struct mpls_route_config *cfg)
@@ -427,8 +441,11 @@ static int mpls_route_add(struct mpls_route_config *cfg)
 
 	err = -ENODEV;
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
