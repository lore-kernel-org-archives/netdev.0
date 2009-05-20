From: Tom Goff <thomas.goff@boeing.com>
Subject: Re: PIM-SM namespace changes
Date: Tue, 19 May 2009 17:43:44 -0700
Message-ID: <20090520004344.GA10143@boeing.com>
References: <20090518.222429.135907168.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stl-smtpout-01.boeing.com ([130.76.96.56]:62896 "EHLO
	stl-smtpout-01.boeing.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754887AbZETBCX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2009 21:02:23 -0400
Content-Disposition: inline
In-Reply-To: <20090518.222429.135907168.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Some bugs to fix before I can apply these Tom.
...
> Also we need to seriously discuss how now we unconditionally
> register the PIM protocols.  Before we had a policy of only
> doing so conditionally, and that's a change that needs to
> be carefully considered and discussed.

Thanks for the feedback, I think the patch below includes proper error
handling.

For protocol registration I see three basic approaches for using PIM
with namespaces:

  - unconditionally add PIM when multicast routing is initialized
    (maybe only ifdef CONFIG_NET_NS, otherwise preserve the current
    behavior)

  - keep a count of the number of namespaces that have enabled PIM and
    add/delete PIM when transitioning from/to zero

  - make all or some protocol registration per network namespace

There are obviously tradeoffs and I would appreciate any
comments/suggestions on alternatives that allow namespace use of
dynamically enabled protocols.

  Tom


PIM-SM namespace changes

IPv4:
  - make PIM register vifs netns local
  - set the netns when a PIM register vif is created
  - make PIM available in all network namespaces (if CONFIG_IP_PIMSM_V2)
    by adding the protocol handler when multicast routing is initialized

IPv6:
  - make PIM register vifs netns local
  - make PIM available in all network namespaces (if CONFIG_IPV6_PIMSM_V2)
    by adding the protocol handler when multicast routing is initialized

Signed-off-by: Tom Goff <thomas.goff@boeing.com>
---
 net/ipv4/ipmr.c  |   29 +++++++++++++++++------------
 net/ipv6/ip6mr.c |   20 ++++++++++++--------
 2 files changed, 29 insertions(+), 20 deletions(-)

diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 13e9dd3..0f34e25 100644
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
 
@@ -2041,8 +2035,19 @@ int __init ip_mr_init(void)
 	err = register_netdevice_notifier(&ip_mr_notifier);
 	if (err)
 		goto reg_notif_fail;
+#ifdef CONFIG_IP_PIMSM_V2
+	if (inet_add_protocol(&pim_protocol, IPPROTO_PIM) < 0) {
+		printk(KERN_ERR "ip_mr_init: can't add PIM protocol\n");
+		err = -EAGAIN;
+		goto add_proto_fail;
+	}
+#endif
 	return 0;
 
+#ifdef CONFIG_IP_PIMSM_V2
+add_proto_fail:
+	unregister_netdevice_notifier(&ip_mr_notifier);
+#endif
 reg_notif_fail:
 	del_timer(&ipmr_expire_timer);
 	unregister_pernet_subsys(&ipmr_net_ops);
diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index 228be55..6055c58 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -442,6 +442,7 @@ static void reg_vif_setup(struct net_device *dev)
 	dev->flags		= IFF_NOARP;
 	dev->netdev_ops		= &reg_vif_netdev_ops;
 	dev->destructor		= free_netdev;
+	dev->features		|= NETIF_F_NETNS_LOCAL;
 }
 
 static struct net_device *ip6mr_reg_vif(struct net *net)
@@ -1078,7 +1079,18 @@ int __init ip6_mr_init(void)
 	err = register_netdevice_notifier(&ip6_mr_notifier);
 	if (err)
 		goto reg_notif_fail;
+#ifdef CONFIG_IPV6_PIMSM_V2
+	if (inet6_add_protocol(&pim6_protocol, IPPROTO_PIM) < 0) {
+		printk(KERN_ERR "ip6_mr_init: can't add PIM protocol\n");
+		err = -EAGAIN;
+		goto add_proto_fail;
+	}
+#endif
 	return 0;
+#ifdef CONFIG_IPV6_PIMSM_V2
+add_proto_fail:
+	unregister_netdevice_notifier(&ip6_mr_notifier);
+#endif
 reg_notif_fail:
 	del_timer(&ipmr_expire_timer);
 	unregister_pernet_subsys(&ip6mr_net_ops);
@@ -1364,14 +1376,6 @@ int ip6_mroute_setsockopt(struct sock *sk, int optname, char __user *optval, int
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

