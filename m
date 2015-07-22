From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH net-next] af_mpls: fix undefined reference to ip6_route_output
Date: Wed, 22 Jul 2015 16:10:48 -0700
Message-ID: <1437606648-6789-1-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:33418 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751820AbbGVXKy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jul 2015 19:10:54 -0400
Received: by pdbnt7 with SMTP id nt7so74910192pdb.0
        for <netdev@vger.kernel.org>; Wed, 22 Jul 2015 16:10:53 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

seen with CONFIG_IPV6 disabled. Wrap the code around
IS_BUILTIN(CONFIG_IPV6). Also fixes undefined reference
to ip_route_output with CONFIG_INET=n

Reported-by: kbuild test robot <fengguang.wu@intel.com>
Reported-by: Thomas Graf <tgraf@suug.ch>
Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
could not think of a better way. This uses IS_BUILTIN instead
of IS_ENABLED to avoid the case where CONFIG_IPV6=m.
I am not sure if this could confuse the user.

 net/mpls/af_mpls.c |   19 ++++++++++++++++++-
 1 file changed, 18 insertions(+), 1 deletion(-)

diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
index 49f1b0e..71dbc4b 100644
--- a/net/mpls/af_mpls.c
+++ b/net/mpls/af_mpls.c
@@ -331,6 +331,7 @@ static unsigned find_free_label(struct net *net)
 	return LABEL_NOT_SPECIFIED;
 }
 
+#if IS_ENABLED(CONFIG_INET)
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
 
+#if IS_BUILTIN(CONFIG_IPV6)
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
