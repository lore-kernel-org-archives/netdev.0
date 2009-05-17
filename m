From: Tom Goff <thomas.goff@boeing.com>
Subject: [PATCH] Network namespace support for PIM-SM (IPv4)
Date: Sat, 16 May 2009 17:41:38 -0700
Message-ID: <20090517004138.GA10175@boeing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from slb-smtpout-01.boeing.com ([130.76.64.48]:40933 "EHLO
	slb-smtpout-01.boeing.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755829AbZEQBAR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 May 2009 21:00:17 -0400
Received: from blv-av-01.boeing.com (blv-av-01.boeing.com [130.247.48.231])
	by slb-smtpout-01.ns.cs.boeing.com (8.14.0/8.14.0/8.14.0/SMTPOUT) with ESMTP id n4H0feQ4024509
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Sat, 16 May 2009 17:41:40 -0700 (PDT)
Received: from blv-av-01.boeing.com (localhost [127.0.0.1])
	by blv-av-01.boeing.com (8.14.0/8.14.0/DOWNSTREAM_RELAY) with ESMTP id n4H0fdlN006708
	for <netdev@vger.kernel.org>; Sat, 16 May 2009 17:41:39 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Here are some minor changes to enable using IPv4 PIM-SM with network
namespaces:

  - make PIM register vifs netns local
  - set the netns when a PIM register vif is created
  - make PIM available in all network namespaces (if CONFIG_IP_PIMSM_V2)
    by adding the protocol handler when multicast routing is initialized

Signed-off-by: Tom Goff <thomas.goff@boeing.com>
---
 net/ipv4/ipmr.c |   24 ++++++++++++------------
 1 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 13e9dd3..bb8b103 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -226,9 +226,10 @@ static void reg_vif_setup(struct net_device *dev)
 	dev->flags		= IFF_NOARP;
 	dev->netdev_ops		= &reg_vif_netdev_ops,
 	dev->destructor		= free_netdev;
+	dev->features		|= NETIF_F_NETNS_LOCAL;
 }

-static struct net_device *ipmr_reg_vif(void)
+static struct net_device *ipmr_reg_vif(struct net *net)
 {
 	struct net_device *dev;
 	struct in_device *in_dev;
@@ -238,6 +239,8 @@ static struct net_device *ipmr_reg_vif(void)
 	if (dev == NULL)
 		return NULL;

+	dev_net_set(dev, net);
+
 	if (register_netdevice(dev)) {
 		free_netdev(dev);
 		return NULL;
@@ -448,7 +451,7 @@ static int vif_add(struct net *net, struct vifctl *vifc, int mrtsock)
 		 */
 		if (net->ipv4.mroute_reg_vif_num >= 0)
 			return -EADDRINUSE;
-		dev = ipmr_reg_vif();
+		dev = ipmr_reg_vif(net);
 		if (!dev)
 			return -ENOBUFS;
 		err = dev_set_allmulti(dev, 1);
@@ -1031,16 +1034,6 @@ int ip_mroute_setsockopt(struct sock *sk, int optname, char __user *optval, int
 		if (v != net->ipv4.mroute_do_pim) {
 			net->ipv4.mroute_do_pim = v;
 			net->ipv4.mroute_do_assert = v;
-#ifdef CONFIG_IP_PIMSM_V2
-			if (net->ipv4.mroute_do_pim)
-				ret = inet_add_protocol(&pim_protocol,
-							IPPROTO_PIM);
-			else
-				ret = inet_del_protocol(&pim_protocol,
-							IPPROTO_PIM);
-			if (ret < 0)
-				ret = -EAGAIN;
-#endif
 		}
 		rtnl_unlock();
 		return ret;
@@ -1955,6 +1948,7 @@ static const struct file_operations ipmr_mfc_fops = {
 #ifdef CONFIG_IP_PIMSM_V2
 static struct net_protocol pim_protocol = {
 	.handler	=	pim_rcv,
+	.netns_ok	=	1,
 };
 #endif

@@ -2039,6 +2033,12 @@ int __init ip_mr_init(void)

 	setup_timer(&ipmr_expire_timer, ipmr_expire_process, 0);
 	err = register_netdevice_notifier(&ip_mr_notifier);
+#ifdef CONFIG_IP_PIMSM_V2
+	if (inet_add_protocol(&pim_protocol, IPPROTO_PIM) < 0) {
+		printk(KERN_ERR "ip_mr_init: can't add PIM protocol\n");
+		err = -EAGAIN;
+	}
+#endif
 	if (err)
 		goto reg_notif_fail;
 	return 0;
-- 
1.6.0.6

