From: Ville Nuorvala <vnuorval@tcs.hut.fi>
Subject: Re: [PATCH] IPv6: Autoconfig link-local address on ip6-ip6 tunnel
 device
Date: Fri, 28 Nov 2003 12:34:12 +0200 (EET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0311281146560.9203@rhea.tcs.hut.fi>
References: <Pine.LNX.4.58.0311051412180.28216@rhea.tcs.hut.fi>
 <20031125.035531.94714784.yoshfuji@linux-ipv6.org>
 <Pine.LNX.4.58.0311271147250.3257@rhea.tcs.hut.fi>
 <20031127.193910.96333709.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=iso-8859-15
Content-Transfer-Encoding: quoted-printable
Cc: =?iso-8859-15?Q?YOSHIFUJI_Hideaki_=2F_=B5=C8=C6=A3=B1=D1=CC=C0?= <yoshfuji@linux-ipv6.org>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
In-Reply-To: <20031127.193910.96333709.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 27 Nov 2003, YOSHIFUJI Hideaki / [iso-2022-jp] =B5=C8=C6=A3=B1=D1=
=CC=C0 wrote:

> In article <Pine.LNX.4.58.0311271147250.3257@rhea.tcs.hut.fi> (at Thu, =
27 Nov 2003 12:31:58 +0200 (EET)), Ville Nuorvala <vnuorval@tcs.hut.fi> s=
ays:
>
> > here is a new version. I made some other minor changes to it too.
>
> looks fine.
> --yoshfuji

Hi Dave, Yoshifuji-san is now ok with this patch :) Would you apply it?

Its purpose is to enable autoconfiguration of link-local addresses on
the ip6-ip6 tunnel devices.

Thanks,
Ville

=3D=3D=3D=3D=3D net/ipv6/ip6_tunnel.c 1.12.1.2 vs 1.16 =3D=3D=3D=3D=3D
--- 1.12.1.2/net/ipv6/ip6_tunnel.c	Wed Nov  5 22:36:56 2003
+++ 1.16/net/ipv6/ip6_tunnel.c	Thu Nov  6 17:00:52 2003
@@ -821,6 +821,8 @@
 	else
 		dev->flags &=3D ~IFF_POINTOPOINT;

+	dev->iflink =3D p->link;
+
 	if (p->flags & IP6_TNL_F_CAP_XMIT) {
 		struct rt6_info *rt =3D rt6_lookup(&p->raddr, &p->laddr,
 						 p->link, 0);
@@ -829,8 +831,6 @@
 			return;

 		if (rt->rt6i_dev) {
-			dev->iflink =3D rt->rt6i_dev->ifindex;
-
 			dev->hard_header_len =3D rt->rt6i_dev->hard_header_len +
 				sizeof (struct ipv6hdr);

@@ -1040,7 +1040,6 @@
 	dev->hard_header_len =3D LL_MAX_HEADER + sizeof (struct ipv6hdr);
 	dev->mtu =3D ETH_DATA_LEN - sizeof (struct ipv6hdr);
 	dev->flags |=3D IFF_NOARP;
-	dev->iflink =3D 0;
 	dev->addr_len =3D sizeof(struct in6_addr);
 }

=3D=3D=3D=3D=3D net/ipv6/addrconf.c 1.74.1.3 vs 1.79 =3D=3D=3D=3D=3D
--- 1.74.1.3/net/ipv6/addrconf.c	Wed Nov 26 03:06:32 2003
+++ 1.79/net/ipv6/addrconf.c	Thu Nov 27 11:14:09 2003
@@ -1809,6 +1809,54 @@
 		sit_route_add(dev);
 }

+static inline int
+ipv6_inherit_linklocal(struct inet6_dev *idev, struct net_device *link_d=
ev)
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
+	    (link_dev =3D __dev_get_by_index(idev->dev->iflink))) {
+		if (!ipv6_inherit_linklocal(idev, link_dev))
+			return;
+	}
+	/* then try to inherit it from any device */
+	for (link_dev =3D dev_base; link_dev; link_dev =3D link_dev->next) {
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
+	if ((idev =3D addrconf_add_dev(dev)) =3D=3D NULL) {
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

 	if (ifp->idev->cnf.forwarding =3D=3D 0 &&
+	    ifp->idev->cnf.rtr_solicits > 0 &&
 	    (dev->flags&IFF_LOOPBACK) =3D=3D 0 &&
 	    (ipv6_addr_type(&ifp->addr) & IPV6_ADDR_LINKLOCAL)) {
 		struct in6_addr all_routers;

--
Ville Nuorvala
Research Assistant, Institute of Digital Communications,
Helsinki University of Technology
email: vnuorval@tcs.hut.fi, phone: +358 (0)9 451 5257
