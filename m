From: Hong Zhiguo <honkiko@gmail.com>
Subject: [PATCH net] ipv6: fix bad free of addrconf_init_net
Date: Tue, 26 Mar 2013 01:52:45 +0800
Message-ID: <1364233965-17093-1-git-send-email-honkiko@gmail.com>
Cc: davem@davemloft.net, stephen@networkplumber.org,
	Hong Zhiguo <honkiko@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f49.google.com ([209.85.160.49]:36008 "EHLO
	mail-pb0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758191Ab3CYRxG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Mar 2013 13:53:06 -0400
Received: by mail-pb0-f49.google.com with SMTP id um15so553348pbc.36
        for <netdev@vger.kernel.org>; Mon, 25 Mar 2013 10:53:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hong Zhiguo <honkiko@gmail.com>
---
 net/ipv6/addrconf.c |   26 ++++++++++----------------
 1 file changed, 10 insertions(+), 16 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index fa36a67..e7d81cd 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -4852,26 +4852,20 @@ static void addrconf_sysctl_unregister(struct inet6_dev *idev)
 
 static int __net_init addrconf_init_net(struct net *net)
 {
-	int err;
+	int err = -ENOMEM;
 	struct ipv6_devconf *all, *dflt;
 
-	err = -ENOMEM;
-	all = &ipv6_devconf;
-	dflt = &ipv6_devconf_dflt;
+	all = kmemdup(&ipv6_devconf, sizeof(ipv6_devconf), GFP_KERNEL);
+	if (all == NULL)
+		goto err_alloc_all;
 
-	if (!net_eq(net, &init_net)) {
-		all = kmemdup(all, sizeof(ipv6_devconf), GFP_KERNEL);
-		if (all == NULL)
-			goto err_alloc_all;
+	dflt = kmemdup(&ipv6_devconf_dflt, sizeof(ipv6_devconf_dflt), GFP_KERNEL);
+	if (dflt == NULL)
+		goto err_alloc_dflt;
 
-		dflt = kmemdup(dflt, sizeof(ipv6_devconf_dflt), GFP_KERNEL);
-		if (dflt == NULL)
-			goto err_alloc_dflt;
-	} else {
-		/* these will be inherited by all namespaces */
-		dflt->autoconf = ipv6_defaults.autoconf;
-		dflt->disable_ipv6 = ipv6_defaults.disable_ipv6;
-	}
+	/* these will be inherited by all namespaces */
+	dflt->autoconf = ipv6_defaults.autoconf;
+	dflt->disable_ipv6 = ipv6_defaults.disable_ipv6;
 
 	net->ipv6.devconf_all = all;
 	net->ipv6.devconf_dflt = dflt;
-- 
1.7.10.4
