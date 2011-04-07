From: Daniel Walter <dwalter@barracuda.com>
Subject: Re: ipv6: Add support for RTA_PREFSRC
Date: Thu, 7 Apr 2011 11:23:57 +0200
Message-ID: <1302168237.31789.245.camel@localhost>
References: <20110401.204613.246536923.davem@davemloft.net>
	 <1301903804.31789.234.camel@localhost>
	 <20110406.183716.226766155.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bn-scl-osf02.barracuda.com ([64.235.144.26]:25176 "EHLO
	bn-scl-osf02.barracuda.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751646Ab1DGJe0 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Apr 2011 05:34:26 -0400
In-Reply-To: <20110406.183716.226766155.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-04-06 at 18:37 -0700, David Miller wrote:
> From: Daniel Walter <dwalter@barracuda.com>
> Date: Mon, 4 Apr 2011 09:56:44 +0200
>=20
> > =EF=BB=BFOn Fri, 2011-04-01 at 20:46 -0700, David Miller wrote:
> >> You can't change the layout of "struct in6_rtmsg", as that structu=
re
> >> is explicitly exported to user space and changing it will break ev=
ery
> >> application out there.
> >=20
> > Hi,
> >=20
> > I've kicked support for setting the preferred source via ioctl,
> > to keep "struct in6_rtmsg" untouched.
> > This reduces the RTA_PREFSRC support to netlink only, unless
> > we break the struct.
> >=20
> > Do you see any other way around this problem?
>=20
> This is fine, adding new feature support to deprecated things like
> the ioctl routing calls is undesirable anyways.
>=20
> Since you do the prefsrc extraction in at least two places, make a
> helper function that does the whole "if prefsrc.plen use prefsrc, els=
e
> use ipv6_dev_get_saddr()"
>=20
> This would be akin to ipv4's FIB_RES_PREFSRC
Hi,

I've moved the extraction into a helper function as suggested and did
some cleanup.

---

diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
index bc3cde0..98348d5 100644
--- a/include/net/ip6_fib.h
+++ b/include/net/ip6_fib.h
@@ -42,6 +42,7 @@ struct fib6_config {
=20
 	struct in6_addr	fc_dst;
 	struct in6_addr	fc_src;
+	struct in6_addr	fc_prefsrc;
 	struct in6_addr	fc_gateway;
=20
 	unsigned long	fc_expires;
@@ -107,6 +108,7 @@ struct rt6_info {
 	struct rt6key			rt6i_dst ____cacheline_aligned_in_smp;
 	u32				rt6i_flags;
 	struct rt6key			rt6i_src;
+	struct rt6key			rt6i_prefsrc;
 	u32				rt6i_metric;
 	u32				rt6i_peer_genid;
=20
diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
index c850e5f..86b1cb4 100644
--- a/include/net/ip6_route.h
+++ b/include/net/ip6_route.h
@@ -84,6 +84,12 @@ extern int			ip6_route_add(struct fib6_config *cfg);
 extern int			ip6_ins_rt(struct rt6_info *);
 extern int			ip6_del_rt(struct rt6_info *);
=20
+extern int			ip6_route_get_saddr(struct net *net,
+						    struct rt6_info *rt,
+						    struct in6_addr *daddr,
+						    unsigned int prefs,
+						    struct in6_addr *saddr);
+
 extern struct rt6_info		*rt6_lookup(struct net *net,
 					    const struct in6_addr *daddr,
 					    const struct in6_addr *saddr,
@@ -141,6 +147,7 @@ struct rt6_rtnl_dump_arg {
 extern int rt6_dump_route(struct rt6_info *rt, void *p_arg);
 extern void rt6_ifdown(struct net *net, struct net_device *dev);
 extern void rt6_mtu_change(struct net_device *dev, unsigned mtu);
+extern void rt6_remove_prefsrc(struct inet6_ifaddr *ifp);
=20
=20
 /*
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 3daaf3c..26f9e14 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -825,6 +825,8 @@ static void ipv6_del_addr(struct inet6_ifaddr *ifp)
 		dst_release(&rt->dst);
 	}
=20
+	/* clean up prefsrc entries */
+	rt6_remove_prefsrc(ifp);
 out:
 	in6_ifa_put(ifp);
 }
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 1820887..0ce081b 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -930,10 +930,10 @@ static int ip6_dst_lookup_tail(struct sock *sk,
 		goto out_err_release;
=20
 	if (ipv6_addr_any(&fl6->saddr)) {
-		err =3D ipv6_dev_get_saddr(net, ip6_dst_idev(*dst)->dev,
-					 &fl6->daddr,
-					 sk ? inet6_sk(sk)->srcprefs : 0,
-					 &fl6->saddr);
+		struct rt6_info *rt =3D (struct rt6_info *) *dst;
+		err =3D ip6_route_get_saddr(net, rt, dst,=20
+					  sk ? inet6_sk(sk)->srcprefs : 0,
+					  &fl6->saddr);
 		if (err)
 			goto out_err_release;
 	}
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 843406f..2688b2e 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1325,6 +1325,16 @@ int ip6_route_add(struct fib6_config *cfg)
 	if (dev =3D=3D NULL)
 		goto out;
=20
+	if (!ipv6_addr_any(&cfg->fc_prefsrc)) {
+		if (!ipv6_chk_addr(net, &cfg->fc_prefsrc, dev, 0)) {
+			err =3D -EINVAL;
+			goto out;
+		}
+		ipv6_addr_copy(&rt->rt6i_prefsrc.addr, &cfg->fc_prefsrc);
+		rt->rt6i_prefsrc.plen =3D 128;
+	} else
+		rt->rt6i_prefsrc.plen =3D 0;
+
 	if (cfg->fc_flags & (RTF_GATEWAY | RTF_NONEXTHOP)) {
 		rt->rt6i_nexthop =3D __neigh_lookup_errno(&nd_tbl, &rt->rt6i_gateway=
, dev);
 		if (IS_ERR(rt->rt6i_nexthop)) {
@@ -2037,6 +2047,55 @@ struct rt6_info *addrconf_dst_alloc(struct inet6=
_dev *idev,
 	return rt;
 }
=20
+int ip6_route_get_saddr(struct net *net,
+			struct rt6_info *rt,
+			struct in6_addr *daddr,
+			unsigned int prefs,
+			struct in6_addr *saddr)
+{
+	struct inet6_dev *idev =3D ip6_dst_idev(&rt->dst);
+	int err =3D 0;
+	if (rt->rt6i_prefsrc.plen)
+		ipv6_addr_copy(saddr, &rt->rt6i_prefsrc.addr);
+	else
+		err =3D ipv6_dev_get_saddr(net, idev ? idev->dev : NULL,
+					 daddr, prefs, saddr);
+	return err;
+}
+
+/* remove deleted ip from prefsrc entries */
+struct arg_dev_net_ip {
+	struct net_device *dev;
+	struct net *net;
+	struct in6_addr *addr;
+};
+
+static int fib6_remove_prefsrc(struct rt6_info *rt, void *arg)
+{
+	struct net_device *dev =3D ((struct arg_dev_net_ip *)arg)->dev;
+	struct net *net =3D ((struct arg_dev_net_ip *)arg)->net;
+	struct in6_addr *addr =3D ((struct arg_dev_net_ip *)arg)->addr;
+
+	if (((void *)rt->rt6i_dev =3D=3D dev || dev =3D=3D NULL) &&
+	    rt !=3D net->ipv6.ip6_null_entry &&
+	    ipv6_addr_equal(addr, &rt->rt6i_prefsrc.addr)) {
+		/* remove prefsrc entry */
+		rt->rt6i_prefsrc.plen =3D 0;
+	}
+	return 0;
+}
+
+void rt6_remove_prefsrc(struct inet6_ifaddr *ifp)
+{
+	struct net *net =3D dev_net(ifp->idev->dev);
+	struct arg_dev_net_ip adni =3D {
+		.dev =3D ifp->idev->dev,
+		.net =3D net,
+		.addr =3D &ifp->addr,
+	};
+	fib6_clean_all(net, fib6_remove_prefsrc, 0, &adni);
+}
+
 struct arg_dev_net {
 	struct net_device *dev;
 	struct net *net;
@@ -2183,6 +2242,9 @@ static int rtm_to_fib6_config(struct sk_buff *skb=
, struct nlmsghdr *nlh,
 		nla_memcpy(&cfg->fc_src, tb[RTA_SRC], plen);
 	}
=20
+	if (tb[RTA_PREFSRC])
+		nla_memcpy(&cfg->fc_prefsrc, tb[RTA_PREFSRC], 16);
+
 	if (tb[RTA_OIF])
 		cfg->fc_ifindex =3D nla_get_u32(tb[RTA_OIF]);
=20
@@ -2325,13 +2387,17 @@ static int rt6_fill_node(struct net *net,
 #endif
 			NLA_PUT_U32(skb, RTA_IIF, iif);
 	} else if (dst) {
-		struct inet6_dev *idev =3D ip6_dst_idev(&rt->dst);
 		struct in6_addr saddr_buf;
-		if (ipv6_dev_get_saddr(net, idev ? idev->dev : NULL,
-				       dst, 0, &saddr_buf) =3D=3D 0)
+		if (ip6_route_get_saddr(net, rt, dst, 0, &saddr_buf) =3D=3D 0)
 			NLA_PUT(skb, RTA_PREFSRC, 16, &saddr_buf);
 	}
=20
+	if (rt->rt6i_prefsrc.plen) {
+		struct in6_addr saddr_buf;
+		ipv6_addr_copy(&saddr_buf, &rt->rt6i_prefsrc.addr);
+		NLA_PUT(skb, RTA_PREFSRC, 16, &saddr_buf);
+	}
+
 	if (rtnetlink_put_metrics(skb, dst_metrics_ptr(&rt->dst)) < 0)
 		goto nla_put_failure;
=20




Barracuda Networks solutions are now available as virtual appliances. =0D
Visit www.barracudanetworks.com/vx for more information.=0D
=0D
=0D

