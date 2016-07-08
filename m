From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] ipv4: do not abuse GFP_ATOMIC in
 inet_netconf_notify_devconf()
Date: Fri, 08 Jul 2016 05:18:24 +0200
Message-ID: <1467947904.1273.56.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1467764916-4983-1-git-send-email-masashi.honma@gmail.com>
	 <1467764916-4983-6-git-send-email-masashi.honma@gmail.com>
	 <1467946591.1273.45.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: Masashi Honma <masashi.honma@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:35643 "EHLO
	mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753600AbcGHDcg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jul 2016 23:32:36 -0400
Received: by mail-wm0-f67.google.com with SMTP id k123so1034896wme.2
        for <netdev@vger.kernel.org>; Thu, 07 Jul 2016 20:31:36 -0700 (PDT)
In-Reply-To: <1467946591.1273.45.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

inet_forward_change() runs with RTNL held.
We are allowed to sleep if required.

If we use __in_dev_get_rtnl() instead of __in_dev_get_rcu(),
we no longer have to use GFP_ATOMIC allocations in
inet_netconf_notify_devconf(), meaning we are less likely to miss
notifications under memory pressure, and wont touch precious memory
reserves either and risk dropping incoming packets.

inet_netconf_get_devconf() can also use GFP_KERNEL allocation.

Fixes: edc9e748934c ("rtnl/ipv4: use netconf msg to advertise forwarding status")
Fixes: 9e5511106f99 ("rtnl/ipv4: add support of RTM_GETNETCONF")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/ipv4/devinet.c |   12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index e333bc86bd39d8baf08ea336f20f99cc51ec945f..415e117967c775f805b43cd634bdf9a55f064e2f 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1834,7 +1834,7 @@ void inet_netconf_notify_devconf(struct net *net, int type, int ifindex,
 	struct sk_buff *skb;
 	int err = -ENOBUFS;
 
-	skb = nlmsg_new(inet_netconf_msgsize_devconf(type), GFP_ATOMIC);
+	skb = nlmsg_new(inet_netconf_msgsize_devconf(type), GFP_KERNEL);
 	if (!skb)
 		goto errout;
 
@@ -1846,7 +1846,7 @@ void inet_netconf_notify_devconf(struct net *net, int type, int ifindex,
 		kfree_skb(skb);
 		goto errout;
 	}
-	rtnl_notify(skb, net, 0, RTNLGRP_IPV4_NETCONF, NULL, GFP_ATOMIC);
+	rtnl_notify(skb, net, 0, RTNLGRP_IPV4_NETCONF, NULL, GFP_KERNEL);
 	return;
 errout:
 	if (err < 0)
@@ -1903,7 +1903,7 @@ static int inet_netconf_get_devconf(struct sk_buff *in_skb,
 	}
 
 	err = -ENOBUFS;
-	skb = nlmsg_new(inet_netconf_msgsize_devconf(NETCONFA_ALL), GFP_ATOMIC);
+	skb = nlmsg_new(inet_netconf_msgsize_devconf(NETCONFA_ALL), GFP_KERNEL);
 	if (!skb)
 		goto errout;
 
@@ -2027,16 +2027,16 @@ static void inet_forward_change(struct net *net)
 
 	for_each_netdev(net, dev) {
 		struct in_device *in_dev;
+
 		if (on)
 			dev_disable_lro(dev);
-		rcu_read_lock();
-		in_dev = __in_dev_get_rcu(dev);
+
+		in_dev = __in_dev_get_rtnl(dev);
 		if (in_dev) {
 			IN_DEV_CONF_SET(in_dev, FORWARDING, on);
 			inet_netconf_notify_devconf(net, NETCONFA_FORWARDING,
 						    dev->ifindex, &in_dev->cnf);
 		}
-		rcu_read_unlock();
 	}
 }
 
