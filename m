From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH 2.6.11-rc3 1/5]: net/core: move set MAC into separate function
Date: Fri, 11 Feb 2005 01:15:50 -0800
Message-ID: <200502110915.j1B9Fo2v003646@death.nxdomain.ibm.com>
Cc: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


	This moves the SIOCSIFHWADDR code from dev_ifsioc() into a
separate new function, dev_set_mac_address().  This provides a single
entry point for all callers performing MAC address changes.

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>


Index: linux-2611-rc3/net/core/dev.c
===================================================================
RCS file: /sda7/CVS/linux-2611-rc3/linux-2611-rc3/net/core/dev.c,v
retrieving revision 1.1.1.1
retrieving revision 1.2
diff -u -u -r1.1.1.1 -r1.2
--- linux-2611-rc3/net/core/dev.c	11 Feb 2005 04:50:49 -0000	1.1.1.1
+++ linux-2611-rc3/net/core/dev.c	11 Feb 2005 05:54:32 -0000	1.2
@@ -2299,6 +2299,21 @@
 	return err;
 }
 
+int dev_set_mac_address(struct net_device *dev, struct sockaddr *sa)
+{
+	int err;
+
+	if (!dev->set_mac_address)
+		return -EOPNOTSUPP;
+	if (sa->sa_family != dev->type)
+		return -EINVAL;
+	if (!netif_device_present(dev))
+		return -ENODEV;
+	err = dev->set_mac_address(dev, sa);
+	if (!err)
+		notifier_call_chain(&netdev_chain, NETDEV_CHANGEADDR, dev);
+	return err;
+}
 
 /*
  *	Perform the SIOCxIFxxx calls.
@@ -2345,17 +2360,7 @@
 			return 0;
 
 		case SIOCSIFHWADDR:
-			if (!dev->set_mac_address)
-				return -EOPNOTSUPP;
-			if (ifr->ifr_hwaddr.sa_family != dev->type)
-				return -EINVAL;
-			if (!netif_device_present(dev))
-				return -ENODEV;
-			err = dev->set_mac_address(dev, &ifr->ifr_hwaddr);
-			if (!err)
-				notifier_call_chain(&netdev_chain,
-						    NETDEV_CHANGEADDR, dev);
-			return err;
+			return dev_set_mac_address(dev, &ifr->ifr_hwaddr);
 
 		case SIOCSIFHWBROADCAST:
 			if (ifr->ifr_hwaddr.sa_family != dev->type)
@@ -3322,6 +3327,7 @@
 EXPORT_SYMBOL(dev_set_promiscuity);
 EXPORT_SYMBOL(dev_change_flags);
 EXPORT_SYMBOL(dev_set_mtu);
+EXPORT_SYMBOL(dev_set_mac_address);
 EXPORT_SYMBOL(free_netdev);
 EXPORT_SYMBOL(netdev_boot_setup_check);
 EXPORT_SYMBOL(netdev_set_master);
Index: linux-2611-rc3/include/linux/netdevice.h
===================================================================
RCS file: /sda7/CVS/linux-2611-rc3/linux-2611-rc3/include/linux/netdevice.h,v
retrieving revision 1.1.1.1
retrieving revision 1.2
diff -u -u -r1.1.1.1 -r1.2
--- linux-2611-rc3/include/linux/netdevice.h	11 Feb 2005 04:51:23 -0000	1.1.1.1
+++ linux-2611-rc3/include/linux/netdevice.h	11 Feb 2005 05:54:25 -0000	1.2
@@ -678,6 +678,8 @@
 extern int		dev_change_flags(struct net_device *, unsigned);
 extern int		dev_change_name(struct net_device *, char *);
 extern int		dev_set_mtu(struct net_device *, int);
+extern int		dev_set_mac_address(struct net_device *,
+					    struct sockaddr *);
 extern void		dev_queue_xmit_nit(struct sk_buff *skb, struct net_device *dev);
 
 extern void		dev_init(void);
