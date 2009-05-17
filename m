From: Tom Goff <thomas.goff@boeing.com>
Subject: [PATCH] Network namespace support for PIM-SM (IPv6)
Date: Sat, 16 May 2009 17:43:21 -0700
Message-ID: <20090517004321.GB10175@boeing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from blv-smtpout-01.boeing.com ([130.76.32.69]:52775 "EHLO
	blv-smtpout-01.boeing.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755429AbZEQA76 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 May 2009 20:59:58 -0400
Received: from blv-av-01.boeing.com (blv-av-01.boeing.com [130.247.48.231])
	by blv-smtpout-01.ns.cs.boeing.com (8.14.0/8.14.0/8.14.0/SMTPOUT) with ESMTP id n4H0hMv8014825
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Sat, 16 May 2009 17:43:23 -0700 (PDT)
Received: from blv-av-01.boeing.com (localhost [127.0.0.1])
	by blv-av-01.boeing.com (8.14.0/8.14.0/DOWNSTREAM_RELAY) with ESMTP id n4H0hMXk007686
	for <netdev@vger.kernel.org>; Sat, 16 May 2009 17:43:22 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Here are some minor changes to enable using IPv6 PIM-SM with network
namespaces:

  - make PIM register vifs netns local
  - make PIM available in all network namespaces (if CONFIG_IPV6_PIMSM_V2)
    by adding the protocol handler when multicast routing is initialized

Signed-off-by: Tom Goff <thomas.goff@boeing.com>
---
 net/ipv6/ip6mr.c |   15 +++++++--------
 1 files changed, 7 insertions(+), 8 deletions(-)

diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index 228be55..148d1af 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -442,6 +442,7 @@ static void reg_vif_setup(struct net_device *dev)
 	dev->flags		= IFF_NOARP;
 	dev->netdev_ops		= &reg_vif_netdev_ops;
 	dev->destructor		= free_netdev;
+	dev->features		|= NETIF_F_NETNS_LOCAL;
 }

 static struct net_device *ip6mr_reg_vif(struct net *net)
@@ -1076,6 +1077,12 @@ int __init ip6_mr_init(void)

 	setup_timer(&ipmr_expire_timer, ipmr_expire_process, 0);
 	err = register_netdevice_notifier(&ip6_mr_notifier);
+#ifdef CONFIG_IPV6_PIMSM_V2
+	if (inet6_add_protocol(&pim6_protocol, IPPROTO_PIM) < 0) {
+		printk(KERN_ERR "ip6_mr_init: can't add PIM protocol\n");
+		err = -EAGAIN;
+	}
+#endif
 	if (err)
 		goto reg_notif_fail;
 	return 0;
@@ -1364,14 +1371,6 @@ int ip6_mroute_setsockopt(struct sock *sk, int optname, char __user *optval, int
 		if (v != net->ipv6.mroute_do_pim) {
 			net->ipv6.mroute_do_pim = v;
 			net->ipv6.mroute_do_assert = v;
-			if (net->ipv6.mroute_do_pim)
-				ret = inet6_add_protocol(&pim6_protocol,
-							 IPPROTO_PIM);
-			else
-				ret = inet6_del_protocol(&pim6_protocol,
-							 IPPROTO_PIM);
-			if (ret < 0)
-				ret = -EAGAIN;
 		}
 		rtnl_unlock();
 		return ret;
-- 
1.6.0.6

