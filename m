From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [patch 4/9][NETNS][IPV6] addrconf - Pass the proper network namespace parameters to addrconf
Date: Wed, 05 Mar 2008 18:56:53 +0100
Message-ID: <20080305180159.378000248@mai.toulouse-stg.fr.ibm.com>
References: <20080305175649.348451657@mai.toulouse-stg.fr.ibm.com>
Cc: netdev@vger.kernel.org, benjamin.thery@bull.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.de.ibm.com ([195.212.29.150]:10916 "EHLO
	mtagate1.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753114AbYCESCE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2008 13:02:04 -0500
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate1.de.ibm.com (8.13.8/8.13.8) with ESMTP id m25I23Tu114414
	for <netdev@vger.kernel.org>; Wed, 5 Mar 2008 18:02:03 GMT
Received: from d12av03.megacenter.de.ibm.com (d12av03.megacenter.de.ibm.com [9.149.165.213])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m25I23jo2015276
	for <netdev@vger.kernel.org>; Wed, 5 Mar 2008 19:02:03 +0100
Received: from d12av03.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av03.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m25I22u2019096
	for <netdev@vger.kernel.org>; Wed, 5 Mar 2008 18:02:03 GMT
Content-Disposition: inline; filename=addrconf-per-network-namespace.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch propagates the network namespace pointer to the address
configuration routines which need it, which means adding a new parameter
to these functions, and make them use it instead of using the initial 
network namespace.

Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>
---
 include/net/addrconf.h |    9 ++++--
 net/ipv6/addrconf.c    |   66 +++++++++++++++++++++++++++++++++++--------------
 net/ipv6/af_inet6.c    |    6 ++--
 3 files changed, 57 insertions(+), 24 deletions(-)

Index: net-2.6.26/include/net/addrconf.h
===================================================================
--- net-2.6.26.orig/include/net/addrconf.h
+++ net-2.6.26/include/net/addrconf.h
@@ -55,9 +55,12 @@ struct prefix_info {
 extern int			addrconf_init(void);
 extern void			addrconf_cleanup(void);
 
-extern int			addrconf_add_ifaddr(void __user *arg);
-extern int			addrconf_del_ifaddr(void __user *arg);
-extern int			addrconf_set_dstaddr(void __user *arg);
+extern int			addrconf_add_ifaddr(struct net *net,
+						    void __user *arg);
+extern int			addrconf_del_ifaddr(struct net *net,
+						    void __user *arg);
+extern int			addrconf_set_dstaddr(struct net *net,
+						     void __user *arg);
 
 extern int			ipv6_chk_addr(struct net *net,
 					      struct in6_addr *addr,
Index: net-2.6.26/net/ipv6/addrconf.c
===================================================================
--- net-2.6.26.orig/net/ipv6/addrconf.c
+++ net-2.6.26/net/ipv6/addrconf.c
@@ -1866,7 +1866,7 @@ ok:
  *	Special case for SIT interfaces where we create a new "virtual"
  *	device.
  */
-int addrconf_set_dstaddr(void __user *arg)
+int addrconf_set_dstaddr(struct net *net, void __user *arg)
 {
 	struct in6_ifreq ireq;
 	struct net_device *dev;
@@ -1878,7 +1878,7 @@ int addrconf_set_dstaddr(void __user *ar
 	if (copy_from_user(&ireq, arg, sizeof(struct in6_ifreq)))
 		goto err_exit;
 
-	dev = __dev_get_by_index(&init_net, ireq.ifr6_ifindex);
+	dev = __dev_get_by_index(net, ireq.ifr6_ifindex);
 
 	err = -ENODEV;
 	if (dev == NULL)
@@ -1909,7 +1909,8 @@ int addrconf_set_dstaddr(void __user *ar
 
 		if (err == 0) {
 			err = -ENOBUFS;
-			if ((dev = __dev_get_by_name(&init_net, p.name)) == NULL)
+			dev = __dev_get_by_name(net, p.name);
+			if (!dev)
 				goto err_exit;
 			err = dev_open(dev);
 		}
@@ -1924,8 +1925,9 @@ err_exit:
 /*
  *	Manual configuration of address on an interface
  */
-static int inet6_addr_add(int ifindex, struct in6_addr *pfx, int plen,
-			  __u8 ifa_flags, __u32 prefered_lft, __u32 valid_lft)
+static int inet6_addr_add(struct net *net, int ifindex, struct in6_addr *pfx,
+			  int plen, __u8 ifa_flags, __u32 prefered_lft,
+			  __u32 valid_lft)
 {
 	struct inet6_ifaddr *ifp;
 	struct inet6_dev *idev;
@@ -1939,7 +1941,8 @@ static int inet6_addr_add(int ifindex, s
 	if (!valid_lft || prefered_lft > valid_lft)
 		return -EINVAL;
 
-	if ((dev = __dev_get_by_index(&init_net, ifindex)) == NULL)
+	dev = __dev_get_by_index(net, ifindex);
+	if (!dev)
 		return -ENODEV;
 
 	if ((idev = addrconf_add_dev(dev)) == NULL)
@@ -1984,13 +1987,15 @@ static int inet6_addr_add(int ifindex, s
 	return PTR_ERR(ifp);
 }
 
-static int inet6_addr_del(int ifindex, struct in6_addr *pfx, int plen)
+static int inet6_addr_del(struct net *net, int ifindex, struct in6_addr *pfx,
+			  int plen)
 {
 	struct inet6_ifaddr *ifp;
 	struct inet6_dev *idev;
 	struct net_device *dev;
 
-	if ((dev = __dev_get_by_index(&init_net, ifindex)) == NULL)
+	dev = __dev_get_by_index(net, ifindex);
+	if (!dev)
 		return -ENODEV;
 
 	if ((idev = __in6_dev_get(dev)) == NULL)
@@ -2018,7 +2023,7 @@ static int inet6_addr_del(int ifindex, s
 }
 
 
-int addrconf_add_ifaddr(void __user *arg)
+int addrconf_add_ifaddr(struct net *net, void __user *arg)
 {
 	struct in6_ifreq ireq;
 	int err;
@@ -2030,13 +2035,14 @@ int addrconf_add_ifaddr(void __user *arg
 		return -EFAULT;
 
 	rtnl_lock();
-	err = inet6_addr_add(ireq.ifr6_ifindex, &ireq.ifr6_addr, ireq.ifr6_prefixlen,
-			     IFA_F_PERMANENT, INFINITY_LIFE_TIME, INFINITY_LIFE_TIME);
+	err = inet6_addr_add(net, ireq.ifr6_ifindex, &ireq.ifr6_addr,
+			     ireq.ifr6_prefixlen, IFA_F_PERMANENT,
+			     INFINITY_LIFE_TIME, INFINITY_LIFE_TIME);
 	rtnl_unlock();
 	return err;
 }
 
-int addrconf_del_ifaddr(void __user *arg)
+int addrconf_del_ifaddr(struct net *net, void __user *arg)
 {
 	struct in6_ifreq ireq;
 	int err;
@@ -2048,7 +2054,8 @@ int addrconf_del_ifaddr(void __user *arg
 		return -EFAULT;
 
 	rtnl_lock();
-	err = inet6_addr_del(ireq.ifr6_ifindex, &ireq.ifr6_addr, ireq.ifr6_prefixlen);
+	err = inet6_addr_del(net, ireq.ifr6_ifindex, &ireq.ifr6_addr,
+			     ireq.ifr6_prefixlen);
 	rtnl_unlock();
 	return err;
 }
@@ -3061,7 +3068,7 @@ inet6_rtm_deladdr(struct sk_buff *skb, s
 	if (pfx == NULL)
 		return -EINVAL;
 
-	return inet6_addr_del(ifm->ifa_index, pfx, ifm->ifa_prefixlen);
+	return inet6_addr_del(net, ifm->ifa_index, pfx, ifm->ifa_prefixlen);
 }
 
 static int inet6_addr_modify(struct inet6_ifaddr *ifp, u8 ifa_flags,
@@ -3137,7 +3144,7 @@ inet6_rtm_newaddr(struct sk_buff *skb, s
 		valid_lft = INFINITY_LIFE_TIME;
 	}
 
-	dev =  __dev_get_by_index(&init_net, ifm->ifa_index);
+	dev =  __dev_get_by_index(net, ifm->ifa_index);
 	if (dev == NULL)
 		return -ENODEV;
 
@@ -3150,8 +3157,9 @@ inet6_rtm_newaddr(struct sk_buff *skb, s
 		 * It would be best to check for !NLM_F_CREATE here but
 		 * userspace alreay relies on not having to provide this.
 		 */
-		return inet6_addr_add(ifm->ifa_index, pfx, ifm->ifa_prefixlen,
-				      ifa_flags, preferred_lft, valid_lft);
+		return inet6_addr_add(net, ifm->ifa_index, pfx,
+				      ifm->ifa_prefixlen, ifa_flags,
+				      preferred_lft, valid_lft);
 	}
 
 	if (nlh->nlmsg_flags & NLM_F_EXCL ||
@@ -4260,6 +4268,22 @@ int unregister_inet6addr_notifier(struct
 
 EXPORT_SYMBOL(unregister_inet6addr_notifier);
 
+
+static int addrconf_net_init(struct net *net)
+{
+	return 0;
+}
+
+static void addrconf_net_exit(struct net *net)
+{
+	;
+}
+
+static struct pernet_operations addrconf_net_ops = {
+	.init = addrconf_net_init,
+	.exit = addrconf_net_exit,
+};
+
 /*
  *	Init / cleanup code
  */
@@ -4301,6 +4325,10 @@ int __init addrconf_init(void)
 	if (err)
 		goto errlo;
 
+	err = register_pernet_device(&addrconf_net_ops);
+	if (err)
+		return err;
+
 	register_netdevice_notifier(&ipv6_dev_notf);
 
 	addrconf_verify(0);
@@ -4334,6 +4362,7 @@ void addrconf_cleanup(void)
 	int i;
 
 	unregister_netdevice_notifier(&ipv6_dev_notf);
+	unregister_pernet_device(&addrconf_net_ops);
 
 	unregister_pernet_subsys(&addrconf_ops);
 
@@ -4370,6 +4399,7 @@ void addrconf_cleanup(void)
 	write_unlock_bh(&addrconf_hash_lock);
 
 	del_timer(&addr_chk_timer);
-
 	rtnl_unlock();
+
+	unregister_pernet_subsys(&addrconf_net_ops);
 }
Index: net-2.6.26/net/ipv6/af_inet6.c
===================================================================
--- net-2.6.26.orig/net/ipv6/af_inet6.c
+++ net-2.6.26/net/ipv6/af_inet6.c
@@ -454,11 +454,11 @@ int inet6_ioctl(struct socket *sock, uns
 		return(ipv6_route_ioctl(net, cmd, (void __user *)arg));
 
 	case SIOCSIFADDR:
-		return addrconf_add_ifaddr((void __user *) arg);
+		return addrconf_add_ifaddr(net, (void __user *) arg);
 	case SIOCDIFADDR:
-		return addrconf_del_ifaddr((void __user *) arg);
+		return addrconf_del_ifaddr(net, (void __user *) arg);
 	case SIOCSIFDSTADDR:
-		return addrconf_set_dstaddr((void __user *) arg);
+		return addrconf_set_dstaddr(net, (void __user *) arg);
 	default:
 		if (!sk->sk_prot->ioctl)
 			return -ENOIOCTLCMD;

-- 
