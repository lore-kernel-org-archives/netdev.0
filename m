From: Joerg Roedel <joro-lkml@zlug.org>
Subject: [PATCH 02/02] net/ipv6: seperate sit driver to extra module (addrconf.c changes)
Date: Fri, 6 Oct 2006 11:39:27 +0200
Message-ID: <20061006093927.GB12460@zlug.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="7iMSBzlTiPOCCT2k"
Return-path: <netdev-owner@vger.kernel.org>
Received: from ironport-c10.fh-zwickau.de ([141.32.72.200]:2936 "EHLO
	ironport-c10.fh-zwickau.de") by vger.kernel.org with ESMTP
	id S1751382AbWJFJj3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Oct 2006 05:39:29 -0400
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	David Miller <davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--7iMSBzlTiPOCCT2k
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

This patch contains the changes to net/ipv6/addrconf.c to remove sit
specific code if the sit driver is not selected.

Signed-off-by: Joerg Roedel <joro-lkml@zlug.org>

--7iMSBzlTiPOCCT2k
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=patch_sit_as_module_addrconf

diff -upr -X linux-2.6.18/Documentation/dontdiff linux-2.6.18-vanilla/net/ipv6/addrconf.c linux-2.6.18/net/ipv6/addrconf.c
--- linux-2.6.18-vanilla/net/ipv6/addrconf.c	2006-09-20 05:42:06.000000000 +0200
+++ linux-2.6.18/net/ipv6/addrconf.c	2006-10-06 11:04:04.000000000 +0200
@@ -389,8 +389,10 @@ static struct inet6_dev * ipv6_add_dev(s
 	ndev->regen_timer.data = (unsigned long) ndev;
 	if ((dev->flags&IFF_LOOPBACK) ||
 	    dev->type == ARPHRD_TUNNEL ||
-	    dev->type == ARPHRD_NONE ||
-	    dev->type == ARPHRD_SIT) {
+#if defined(CONFIG_IPV6_SIT) || defined(CONFIG_IPV6_SIT_MODULE)
+	    dev->type == ARPHRD_SIT ||
+#endif
+	    dev->type == ARPHRD_NONE) {
 		printk(KERN_INFO
 		       "%s: Disabled Privacy Extensions\n",
 		       dev->name);
@@ -1522,8 +1524,10 @@ addrconf_prefix_route(struct in6_addr *p
 	   This thing is done here expecting that the whole
 	   class of non-broadcast devices need not cloning.
 	 */
+#if defined(CONFIG_IPV6_SIT) || defined(CONFIG_IPV6_SIT_MODULE)
 	if (dev->type == ARPHRD_SIT && (dev->flags&IFF_POINTOPOINT))
 		rtmsg.rtmsg_flags |= RTF_NONEXTHOP;
+#endif
 
 	ip6_route_add(&rtmsg, NULL, NULL, NULL);
 }
@@ -1545,6 +1549,7 @@ static void addrconf_add_mroute(struct n
 	ip6_route_add(&rtmsg, NULL, NULL, NULL);
 }
 
+#if defined(CONFIG_IPV6_SIT) || defined(CONFIG_IPV6_SIT_MODULE)
 static void sit_route_add(struct net_device *dev)
 {
 	struct in6_rtmsg rtmsg;
@@ -1561,6 +1566,7 @@ static void sit_route_add(struct net_dev
 
 	ip6_route_add(&rtmsg, NULL, NULL, NULL);
 }
+#endif
 
 static void addrconf_add_lroute(struct net_device *dev)
 {
@@ -1831,6 +1837,7 @@ int addrconf_set_dstaddr(void __user *ar
 	if (dev == NULL)
 		goto err_exit;
 
+#if defined(CONFIG_IPV6_SIT) || defined(CONFIG_IPV6_SIT_MODULE)
 	if (dev->type == ARPHRD_SIT) {
 		struct ifreq ifr;
 		mm_segment_t	oldfs;
@@ -1860,6 +1867,7 @@ int addrconf_set_dstaddr(void __user *ar
 			err = dev_open(dev);
 		}
 	}
+#endif
 
 err_exit:
 	rtnl_unlock();
@@ -1993,6 +2001,7 @@ int addrconf_del_ifaddr(void __user *arg
 	return err;
 }
 
+#if defined(CONFIG_IPV6_SIT) || defined(CONFIG_IPV6_SIT_MODULE)
 static void sit_add_v4_addrs(struct inet6_dev *idev)
 {
 	struct inet6_ifaddr * ifp;
@@ -2061,6 +2070,7 @@ static void sit_add_v4_addrs(struct inet
 		}
         }
 }
+#endif
 
 static void init_loopback(struct net_device *dev)
 {
@@ -2124,6 +2134,7 @@ static void addrconf_dev_config(struct n
 		addrconf_add_linklocal(idev, &addr);
 }
 
+#if defined(CONFIG_IPV6_SIT) || defined(CONFIG_IPV6_SIT_MODULE)
 static void addrconf_sit_config(struct net_device *dev)
 {
 	struct inet6_dev *idev;
@@ -2149,6 +2160,7 @@ static void addrconf_sit_config(struct n
 	} else
 		sit_route_add(dev);
 }
+#endif
 
 static inline int
 ipv6_inherit_linklocal(struct inet6_dev *idev, struct net_device *link_dev)
@@ -2243,9 +2255,11 @@ static int addrconf_notify(struct notifi
 		}
 
 		switch(dev->type) {
+#if defined(CONFIG_IPV6_SIT) || defined(CONFIG_IPV6_SIT_MODULE)
 		case ARPHRD_SIT:
 			addrconf_sit_config(dev);
 			break;
+#endif
 		case ARPHRD_TUNNEL6:
 			addrconf_ip6_tnl_config(dev);
 			break;

--7iMSBzlTiPOCCT2k--
