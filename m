From: Ville Nuorvala <vnuorval@tcs.hut.fi>
Subject: [PATCH][RESEND] IPv6: Autoconfig link-local address on ip6-ip6 tunnel
 device
Date: Wed, 7 Jan 2004 11:22:57 +0200 (EET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0401071034440.27524@rhea.tcs.hut.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: yoshfuji@linux-ipv6.org, pekkas@netcore.fi, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Dave,

This patch, made against cset 1.1492, adds a link-local address to a
ip6-ip6 tunnel interface when it is brougth up.

It also changes the router solicitation behavior slightly by checking that
rtr_solicits is > 0, before sending a router solicitation after a
successful DAD probe on the link-local address.

2.6.0 has been released, so would you apply this patch now? :)

Thanks,
Ville

diff -Nru a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
--- a/net/ipv6/addrconf.c	Wed Jan  7 11:07:42 2004
+++ b/net/ipv6/addrconf.c	Wed Jan  7 11:07:42 2004
@@ -1809,6 +1809,54 @@
 		sit_route_add(dev);
 }

+static inline int
+ipv6_inherit_linklocal(struct inet6_dev *idev, struct net_device *link_dev)
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
+		if (!ipv6_inherit_linklocal(idev, link_dev))
+			return;
+	}
+	/* then try to inherit it from any device */
+	for (link_dev = dev_base; link_dev; link_dev = link_dev->next) {
+		if (!ipv6_inherit_linklocal(idev, link_dev))
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

 int addrconf_notify(struct notifier_block *this, unsigned long event,
 		    void * data)
@@ -1822,7 +1870,9 @@
 		case ARPHRD_SIT:
 			addrconf_sit_config(dev);
 			break;
-
+		case ARPHRD_TUNNEL6:
+			addrconf_ip6_tnl_config(dev);
+			break;
 		case ARPHRD_LOOPBACK:
 			init_loopback(dev);
 			break;
@@ -2121,6 +2171,7 @@
 	 */

 	if (ifp->idev->cnf.forwarding == 0 &&
+	    ifp->idev->cnf.rtr_solicits > 0 &&
 	    (dev->flags&IFF_LOOPBACK) == 0 &&
 	    (ipv6_addr_type(&ifp->addr) & IPV6_ADDR_LINKLOCAL)) {
 		struct in6_addr all_routers;
diff -Nru a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
--- a/net/ipv6/ip6_tunnel.c	Wed Jan  7 11:07:42 2004
+++ b/net/ipv6/ip6_tunnel.c	Wed Jan  7 11:07:42 2004
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
