From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (2/5) IPV6 notifier replay changes
Date: Tue, 13 Jan 2004 10:58:56 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040113105856.3e366b9c.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Change IPV6 to handle the new case where netdev events are replayed on registration:
	* change code ordering so address configuration is ready before registration
	  (this was actually a bug in existing code)
	* take out code that capture's existing devices, this is now done in the replay
	* make notifier code local to addrconf.c so it can be have smaller scope

diff -Nru a/include/net/addrconf.h b/include/net/addrconf.h
--- a/include/net/addrconf.h	Thu Dec 18 15:42:20 2003
+++ b/include/net/addrconf.h	Thu Dec 18 15:42:20 2003
@@ -50,10 +50,6 @@
 extern void			addrconf_init(void);
 extern void			addrconf_cleanup(void);
 
-extern int		        addrconf_notify(struct notifier_block *this, 
-						unsigned long event, 
-						void * data);
-
 extern int			addrconf_add_ifaddr(void *arg);
 extern int			addrconf_del_ifaddr(void *arg);
 extern int			addrconf_set_dstaddr(void *arg);
diff -Nru a/include/net/ipv6.h b/include/net/ipv6.h
--- a/include/net/ipv6.h	Thu Dec 18 15:42:20 2003
+++ b/include/net/ipv6.h	Thu Dec 18 15:42:20 2003
@@ -408,11 +408,7 @@
 
 extern void			ipv6_packet_init(void);
 
-extern void			ipv6_netdev_notif_init(void);
-
 extern void			ipv6_packet_cleanup(void);
-
-extern void			ipv6_netdev_notif_cleanup(void);
 
 extern int 			ipv6_recv_error(struct sock *sk, struct msghdr *msg, int len);
 extern void			ipv6_icmp_error(struct sock *sk, struct sk_buff *skb, int err, u16 port,
diff -Nru a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
--- a/net/ipv6/addrconf.c	Thu Dec 18 15:42:20 2003
+++ b/net/ipv6/addrconf.c	Thu Dec 18 15:42:20 2003
@@ -1810,8 +1810,8 @@
 }
 
 
-int addrconf_notify(struct notifier_block *this, unsigned long event, 
-		    void * data)
+static int addrconf_notify(struct notifier_block *this, unsigned long event, 
+			   void * data)
 {
 	struct net_device *dev = (struct net_device *) data;
 	struct inet6_dev *idev = __in6_dev_get(dev);
@@ -1881,6 +1881,14 @@
 	return NOTIFY_OK;
 }
 
+/*
+ *	addrconf module should be notified of a device going up
+ */
+static struct notifier_block ipv6_dev_notf = {
+	.notifier_call = addrconf_notify,
+	.priority = 0
+};
+
 static int addrconf_ifdown(struct net_device *dev, int how)
 {
 	struct inet6_dev *idev;
@@ -3126,9 +3134,7 @@
 
 void __init addrconf_init(void)
 {
-#ifdef MODULE
-	struct net_device *dev;
-#endif
+	register_netdevice_notifier(&ipv6_dev_notf);
 
 #ifdef CONFIG_IPV6_PRIVACY
 	md5_tfm = crypto_alloc_tfm("md5", 0);
@@ -3137,30 +3143,6 @@
 			"failed to load transform for md5\n");
 #endif
 
-#ifdef MODULE
-	/* This takes sense only during module load. */
-	rtnl_lock();
-	for (dev = dev_base; dev; dev = dev->next) {
-		if (!(dev->flags&IFF_UP))
-			continue;
-
-		switch (dev->type) {
-		case ARPHRD_LOOPBACK:	
-			init_loopback(dev);
-			break;
-		case ARPHRD_ETHER:
-		case ARPHRD_FDDI:
-		case ARPHRD_IEEE802_TR:	
-		case ARPHRD_ARCNET:
-			addrconf_dev_config(dev);
-			break;
-		default:;
-			/* Ignore all other */
-		}
-	}
-	rtnl_unlock();
-#endif
-
 	addrconf_verify(0);
 	rtnetlink_links[PF_INET6] = inet6_rtnetlink_table;
 #ifdef CONFIG_SYSCTL
@@ -3178,6 +3160,8 @@
  	struct inet6_ifaddr *ifa;
 	int i;
 
+	unregister_netdevice_notifier(&ipv6_dev_notf);
+
 	rtnetlink_links[PF_INET6] = NULL;
 #ifdef CONFIG_SYSCTL
 	addrconf_sysctl_unregister(&ipv6_devconf_dflt);
@@ -3231,3 +3215,4 @@
 #endif
 }
 #endif	/* MODULE */
+
diff -Nru a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
--- a/net/ipv6/af_inet6.c	Thu Dec 18 15:42:20 2003
+++ b/net/ipv6/af_inet6.c	Thu Dec 18 15:42:20 2003
@@ -802,7 +802,6 @@
 	if (if6_proc_init())
 		goto proc_if6_fail;
 #endif
-	ipv6_netdev_notif_init();
 	ipv6_packet_init();
 	ip6_route_init();
 	ip6_flowlabel_init();
@@ -869,7 +868,6 @@
 #endif
 	/* Cleanup code parts. */
 	sit_cleanup();
-	ipv6_netdev_notif_cleanup();
 	ip6_flowlabel_cleanup();
 	addrconf_cleanup();
 	ip6_route_cleanup();
diff -Nru a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
--- a/net/ipv6/ipv6_sockglue.c	Thu Dec 18 15:42:20 2003
+++ b/net/ipv6/ipv6_sockglue.c	Thu Dec 18 15:42:20 2003
@@ -62,14 +62,6 @@
 	.func = ipv6_rcv,
 };
 
-/*
- *	addrconf module should be notified of a device going up
- */
-static struct notifier_block ipv6_dev_notf = {
-	.notifier_call = addrconf_notify,
-	.priority = 0
-};
-
 struct ip6_ra_chain *ip6_ra_chain;
 rwlock_t ip6_ra_lock = RW_LOCK_UNLOCKED;
 
@@ -707,19 +699,9 @@
 	dev_add_pack(&ipv6_packet_type);
 }
 
-void __init ipv6_netdev_notif_init(void)
-{
-	register_netdevice_notifier(&ipv6_dev_notf);
-}
-
 #ifdef MODULE
 void ipv6_packet_cleanup(void)
 {
 	dev_remove_pack(&ipv6_packet_type);
-}
-
-void ipv6_netdev_notif_cleanup(void)
-{
-	unregister_netdevice_notifier(&ipv6_dev_notf);
 }
 #endif
