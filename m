From: Ville Nuorvala <vnuorval@tcs.hut.fi>
Subject: [PATCH] IPv6: Autoconfig link-local address on ip6-ip6 tunnel device
Date: Wed, 5 Nov 2003 15:07:32 +0200 (EET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0311051412180.28216@rhea.tcs.hut.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello Yoshifuji-san,

this (rewritten) patch configures link-local addresses to the ip6-ip6
tunnel devices so you can run link-local protocols over them. If you are
ok with the patch, perhaps we could push it forward to Dave.

Thanks,
Ville

===== net/ipv6/addrconf.c 1.74 vs edited =====
--- 1.74/net/ipv6/addrconf.c	Tue Oct 28 13:10:47 2003
+++ edited/net/ipv6/addrconf.c	Wed Nov  5 14:50:29 2003
@@ -1818,6 +1818,58 @@
 		sit_route_add(dev);
 }

+#if defined(CONFIG_IPV6_TUNNEL) || defined(CONFIG_IPV6_TUNNEL_MODULE)
+
+static inline int
+ip6_tnl_inherit_linklocal(struct inet6_dev *idev, struct net_device *link_dev)
+{
+	struct in6_addr lladdr;
+
+	if (!ipv6_get_lladdr(link_dev, &lladdr)) {
+		addrconf_add_linklocal(idev, &lladdr);
+		return 0;
+	}
+	return -1;
+}
+
+static void ip6_tnl_add_linklocal(struct inet6_dev *idev)
+{
+	struct net_device *link_dev;
+
+	/* first try to inherit the link-local address from the link device */
+	if (idev->dev->iflink &&
+	    (link_dev = __dev_get_by_index(idev->dev->iflink))) {
+		if (!ip6_tnl_inherit_linklocal(idev, link_dev))
+			return;
+	}
+	/* then try to inherit it from any device */
+	for (link_dev = dev_base; link_dev; link_dev = link_dev->next) {
+		if (!ip6_tnl_inherit_linklocal(idev, link_dev))
+			return;
+	}
+	printk(KERN_DEBUG "init ip6-ip6: add_linklocal failed\n");
+}
+
+/*
+ * Autoconfigure tunnel with a link-local address so routing protocols,
+ * DHCPv6, MLD etc. can be run over the virtual link
+ */
+
+static void addrconf_ip6_tnl_config(struct net_device *dev)
+{
+	struct inet6_dev *idev;
+
+	ASSERT_RTNL();
+
+	if ((idev = addrconf_add_dev(dev)) == NULL) {
+		printk(KERN_DEBUG "init ip6-ip6: add_dev failed\n");
+		return;
+	}
+	ip6_tnl_add_linklocal(idev);
+	addrconf_add_mroute(dev);
+}
+#endif
+

 int addrconf_notify(struct notifier_block *this, unsigned long event,
 		    void * data)
@@ -1831,7 +1883,11 @@
 		case ARPHRD_SIT:
 			addrconf_sit_config(dev);
 			break;
-
+#if defined(CONFIG_IPV6_TUNNEL) || defined(CONFIG_IPV6_TUNNEL_MODULE)
+		case ARPHRD_TUNNEL6:
+			addrconf_ip6_tnl_config(dev);
+			break;
+#endif
 		case ARPHRD_LOOPBACK:
 			init_loopback(dev);
 			break;
===== net/ipv6/ip6_tunnel.c 1.14 vs edited =====
--- 1.14/net/ipv6/ip6_tunnel.c	Wed Nov  5 10:11:00 2003
+++ edited/net/ipv6/ip6_tunnel.c	Wed Nov  5 14:58:27 2003
@@ -821,6 +821,8 @@
 	else
 		dev->flags &= ~IFF_POINTOPOINT;

+	dev->iflink = p->link;
+
 	if (p->flags & IP6_TNL_F_CAP_XMIT) {
 		struct rt6_info *rt = rt6_lookup(&p->raddr, &p->laddr,
 						 p->link, 0);
@@ -829,8 +831,6 @@
 			return;

 		if (rt->rt6i_dev) {
-			dev->iflink = rt->rt6i_dev->ifindex;
-
 			dev->hard_header_len = rt->rt6i_dev->hard_header_len +
 				sizeof (struct ipv6hdr);

@@ -1040,7 +1040,6 @@
 	dev->hard_header_len = LL_MAX_HEADER + sizeof (struct ipv6hdr);
 	dev->mtu = ETH_DATA_LEN - sizeof (struct ipv6hdr);
 	dev->flags |= IFF_NOARP;
-	dev->iflink = 0;
 	dev->addr_len = sizeof(struct in6_addr);
 }

--
Ville Nuorvala
Research Assistant, Institute of Digital Communications,
Helsinki University of Technology
email: vnuorval@tcs.hut.fi, phone: +358 (0)9 451 5257
