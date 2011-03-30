From: Daniel Walter <dwalter@barracuda.com>
Subject: [PATCH] ipv6: Add support for RTA_PREFSRC
Date: Wed, 30 Mar 2011 17:29:51 +0200
Message-ID: <1301498991.31789.187.camel@localhost>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-Ph+wg+tryrE8bFkiYRL4"
Cc: <linux-kernel@vger.kernel.org>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--=-Ph+wg+tryrE8bFkiYRL4
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

=EF=BB=BFFrom: Daniel Walter <dwalter@barracuda.com>

[ipv6] Add support for RTA_PREFSRC

This patch allows a user to select the preferred source address
for a specific IPv6-Route. It can be set via a netlink message
setting RTA_PREFSRC to a valid IPv6 address which must be
up on the device the route will be bound to.=20
=20
Signed-off-by: Daniel Walter <dwalter@barracuda.com>
---

patch should apply clean against linux-2.3.39 HEAD

 include/linux/ipv6_route.h |    1 +
 include/net/ip6_fib.h      |    2 +
 include/net/ip6_route.h    |    1 +
 net/ipv6/addrconf.c        |    2 +
 net/ipv6/ip6_output.c      |   12 +++++--
 net/ipv6/route.c           |   68 ++++++++++++++++++++++++++++++++++++++++=
++--
 6 files changed, 79 insertions(+), 7 deletions(-)

diff --git a/include/linux/ipv6_route.h b/include/linux/ipv6_route.h
index 1e7d8af..9845953 100644
--- a/include/linux/ipv6_route.h
+++ b/include/linux/ipv6_route.h
@@ -44,6 +44,7 @@
 struct in6_rtmsg {
 	struct in6_addr		rtmsg_dst;
 	struct in6_addr		rtmsg_src;
+	struct in6_addr		rtmsg_prefsrc;
 	struct in6_addr		rtmsg_gateway;
 	__u32			rtmsg_type;
 	__u16			rtmsg_dst_len;
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
index c850e5f..2b37c20 100644
--- a/include/net/ip6_route.h
+++ b/include/net/ip6_route.h
@@ -141,6 +141,7 @@ struct rt6_rtnl_dump_arg {
 extern int rt6_dump_route(struct rt6_info *rt, void *p_arg);
 extern void rt6_ifdown(struct net *net, struct net_device *dev);
 extern void rt6_mtu_change(struct net_device *dev, unsigned mtu);
+extern void rt6_remove_prefsrc(struct inet6_ifaddr *ifp);
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
index 1820887..e2d8463 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -930,10 +930,14 @@ static int ip6_dst_lookup_tail(struct sock *sk,
 		goto out_err_release;
=20
 	if (ipv6_addr_any(&fl6->saddr)) {
-		err =3D ipv6_dev_get_saddr(net, ip6_dst_idev(*dst)->dev,
-					 &fl6->daddr,
-					 sk ? inet6_sk(sk)->srcprefs : 0,
-					 &fl6->saddr);
+		struct rt6_info *rt =3D (struct rt6_info *) *dst;
+		if (rt->rt6i_prefsrc.plen)
+			ipv6_addr_copy(&fl6->saddr, &rt->rt6i_prefsrc.addr);
+		else
+			err =3D ipv6_dev_get_saddr(net, ip6_dst_idev(*dst)->dev,
+						 &fl6->daddr,
+						 sk ? inet6_sk(sk)->srcprefs : 0,
+						 &fl6->saddr);
 		if (err)
 			goto out_err_release;
 	}
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 843406f..b53089d 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1325,6 +1325,20 @@ int ip6_route_add(struct fib6_config *cfg)
 	if (dev =3D=3D NULL)
 		goto out;
=20
+	/* check if prefsrc is set */
+	if (!ipv6_addr_any(&cfg->fc_prefsrc)) {
+		struct in6_addr saddr_buf;
+		ipv6_addr_copy(&saddr_buf, &cfg->fc_prefsrc);
+		if (!ipv6_chk_addr(net, &saddr_buf, dev, 0)) {
+			printk(KERN_DEBUG "invalid pref_src\n");
+			err =3D -EINVAL;
+			goto out;
+		}
+		ipv6_addr_copy(&rt->rt6i_prefsrc.addr, &cfg->fc_prefsrc);
+		rt->rt6i_prefsrc.plen =3D 128;
+	} else
+		rt->rt6i_prefsrc.plen =3D 0;
+
 	if (cfg->fc_flags & (RTF_GATEWAY | RTF_NONEXTHOP)) {
 		rt->rt6i_nexthop =3D __neigh_lookup_errno(&nd_tbl, &rt->rt6i_gateway, de=
v);
 		if (IS_ERR(rt->rt6i_nexthop)) {
@@ -1893,6 +1907,7 @@ static void rtmsg_to_fib6_config(struct net *net,
 	ipv6_addr_copy(&cfg->fc_dst, &rtmsg->rtmsg_dst);
 	ipv6_addr_copy(&cfg->fc_src, &rtmsg->rtmsg_src);
 	ipv6_addr_copy(&cfg->fc_gateway, &rtmsg->rtmsg_gateway);
+	ipv6_addr_copy(&cfg->fc_prefsrc, &rtmsg->rtmsg_prefsrc);
 }
=20
 int ipv6_route_ioctl(struct net *net, unsigned int cmd, void __user *arg)
@@ -2037,6 +2052,39 @@ struct rt6_info *addrconf_dst_alloc(struct inet6_dev=
 *idev,
 	return rt;
 }
=20
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
@@ -2183,6 +2231,9 @@ static int rtm_to_fib6_config(struct sk_buff *skb, st=
ruct nlmsghdr *nlh,
 		nla_memcpy(&cfg->fc_src, tb[RTA_SRC], plen);
 	}
=20
+	if (tb[RTA_PREFSRC])
+		nla_memcpy(&cfg->fc_prefsrc, tb[RTA_PREFSRC], 16);
+
 	if (tb[RTA_OIF])
 		cfg->fc_ifindex =3D nla_get_u32(tb[RTA_OIF]);
=20
@@ -2325,11 +2376,22 @@ static int rt6_fill_node(struct net *net,
 #endif
 			NLA_PUT_U32(skb, RTA_IIF, iif);
 	} else if (dst) {
-		struct inet6_dev *idev =3D ip6_dst_idev(&rt->dst);
 		struct in6_addr saddr_buf;
-		if (ipv6_dev_get_saddr(net, idev ? idev->dev : NULL,
-				       dst, 0, &saddr_buf) =3D=3D 0)
+		if (rt->rt6i_prefsrc.plen) {
+			ipv6_addr_copy(&saddr_buf, &rt->rt6i_prefsrc.addr);
 			NLA_PUT(skb, RTA_PREFSRC, 16, &saddr_buf);
+		} else {
+			struct inet6_dev *idev =3D ip6_dst_idev(&rt->dst);
+			if (ipv6_dev_get_saddr(net, idev ? idev->dev : NULL,
+					       dst, 0, &saddr_buf) =3D=3D 0)
+				NLA_PUT(skb, RTA_PREFSRC, 16, &saddr_buf);
+		}
+	}
+
+	if (rt->rt6i_prefsrc.plen) {
+		struct in6_addr saddr_buf;
+		ipv6_addr_copy(&saddr_buf, &rt->rt6i_prefsrc.addr);
+		NLA_PUT(skb, RTA_PREFSRC, 16, &saddr_buf);
 	}
=20
 	if (rtnetlink_put_metrics(skb, dst_metrics_ptr(&rt->dst)) < 0)











From: Daniel Walter <dwalter@barracuda.com>

[ipv6] Add support for RTA_PREFSRC

This patch allows a user to select the preferred source address
for a specific IPv6-Route. It can be set via a netlink message
setting RTA_PREFSRC to a valid IPv6 address which must be
up on the device the route will be bound to.=20
=20
Signed-off-by: Daniel Walter <dwalter@barracuda.com>
---

patch should apply clean against linux-2.3.39 HEAD

 include/linux/ipv6_route.h |    1 +
 include/net/ip6_fib.h      |    2 +
 include/net/ip6_route.h    |    1 +
 net/ipv6/addrconf.c        |    2 +
 net/ipv6/ip6_output.c      |   12 +++++--
 net/ipv6/route.c           |   68 ++++++++++++++++++++++++++++++++++++++++=
++--
 6 files changed, 79 insertions(+), 7 deletions(-)

diff --git a/include/linux/ipv6_route.h b/include/linux/ipv6_route.h
index 1e7d8af..9845953 100644
--- a/include/linux/ipv6_route.h
+++ b/include/linux/ipv6_route.h
@@ -44,6 +44,7 @@
 struct in6_rtmsg {
 	struct in6_addr		rtmsg_dst;
 	struct in6_addr		rtmsg_src;
+	struct in6_addr		rtmsg_prefsrc;
 	struct in6_addr		rtmsg_gateway;
 	__u32			rtmsg_type;
 	__u16			rtmsg_dst_len;
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
index c850e5f..2b37c20 100644
--- a/include/net/ip6_route.h
+++ b/include/net/ip6_route.h
@@ -141,6 +141,7 @@ struct rt6_rtnl_dump_arg {
 extern int rt6_dump_route(struct rt6_info *rt, void *p_arg);
 extern void rt6_ifdown(struct net *net, struct net_device *dev);
 extern void rt6_mtu_change(struct net_device *dev, unsigned mtu);
+extern void rt6_remove_prefsrc(struct inet6_ifaddr *ifp);
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
index 1820887..e2d8463 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -930,10 +930,14 @@ static int ip6_dst_lookup_tail(struct sock *sk,
 		goto out_err_release;
=20
 	if (ipv6_addr_any(&fl6->saddr)) {
-		err =3D ipv6_dev_get_saddr(net, ip6_dst_idev(*dst)->dev,
-					 &fl6->daddr,
-					 sk ? inet6_sk(sk)->srcprefs : 0,
-					 &fl6->saddr);
+		struct rt6_info *rt =3D (struct rt6_info *) *dst;
+		if (rt->rt6i_prefsrc.plen)
+			ipv6_addr_copy(&fl6->saddr, &rt->rt6i_prefsrc.addr);
+		else
+			err =3D ipv6_dev_get_saddr(net, ip6_dst_idev(*dst)->dev,
+						 &fl6->daddr,
+						 sk ? inet6_sk(sk)->srcprefs : 0,
+						 &fl6->saddr);
 		if (err)
 			goto out_err_release;
 	}
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 843406f..b53089d 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1325,6 +1325,20 @@ int ip6_route_add(struct fib6_config *cfg)
 	if (dev =3D=3D NULL)
 		goto out;
=20
+	/* check if prefsrc is set */
+	if (!ipv6_addr_any(&cfg->fc_prefsrc)) {
+		struct in6_addr saddr_buf;
+		ipv6_addr_copy(&saddr_buf, &cfg->fc_prefsrc);
+		if (!ipv6_chk_addr(net, &saddr_buf, dev, 0)) {
+			printk(KERN_DEBUG "invalid pref_src\n");
+			err =3D -EINVAL;
+			goto out;
+		}
+		ipv6_addr_copy(&rt->rt6i_prefsrc.addr, &cfg->fc_prefsrc);
+		rt->rt6i_prefsrc.plen =3D 128;
+	} else
+		rt->rt6i_prefsrc.plen =3D 0;
+
 	if (cfg->fc_flags & (RTF_GATEWAY | RTF_NONEXTHOP)) {
 		rt->rt6i_nexthop =3D __neigh_lookup_errno(&nd_tbl, &rt->rt6i_gateway, de=
v);
 		if (IS_ERR(rt->rt6i_nexthop)) {
@@ -1893,6 +1907,7 @@ static void rtmsg_to_fib6_config(struct net *net,
 	ipv6_addr_copy(&cfg->fc_dst, &rtmsg->rtmsg_dst);
 	ipv6_addr_copy(&cfg->fc_src, &rtmsg->rtmsg_src);
 	ipv6_addr_copy(&cfg->fc_gateway, &rtmsg->rtmsg_gateway);
+	ipv6_addr_copy(&cfg->fc_prefsrc, &rtmsg->rtmsg_prefsrc);
 }
=20
 int ipv6_route_ioctl(struct net *net, unsigned int cmd, void __user *arg)
@@ -2037,6 +2052,39 @@ struct rt6_info *addrconf_dst_alloc(struct inet6_dev=
 *idev,
 	return rt;
 }
=20
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
@@ -2183,6 +2231,9 @@ static int rtm_to_fib6_config(struct sk_buff *skb, st=
ruct nlmsghdr *nlh,
 		nla_memcpy(&cfg->fc_src, tb[RTA_SRC], plen);
 	}
=20
+	if (tb[RTA_PREFSRC])
+		nla_memcpy(&cfg->fc_prefsrc, tb[RTA_PREFSRC], 16);
+
 	if (tb[RTA_OIF])
 		cfg->fc_ifindex =3D nla_get_u32(tb[RTA_OIF]);
=20
@@ -2325,11 +2376,22 @@ static int rt6_fill_node(struct net *net,
 #endif
 			NLA_PUT_U32(skb, RTA_IIF, iif);
 	} else if (dst) {
-		struct inet6_dev *idev =3D ip6_dst_idev(&rt->dst);
 		struct in6_addr saddr_buf;
-		if (ipv6_dev_get_saddr(net, idev ? idev->dev : NULL,
-				       dst, 0, &saddr_buf) =3D=3D 0)
+		if (rt->rt6i_prefsrc.plen) {
+			ipv6_addr_copy(&saddr_buf, &rt->rt6i_prefsrc.addr);
 			NLA_PUT(skb, RTA_PREFSRC, 16, &saddr_buf);
+		} else {
+			struct inet6_dev *idev =3D ip6_dst_idev(&rt->dst);
+			if (ipv6_dev_get_saddr(net, idev ? idev->dev : NULL,
+					       dst, 0, &saddr_buf) =3D=3D 0)
+				NLA_PUT(skb, RTA_PREFSRC, 16, &saddr_buf);
+		}
+	}
+
+	if (rt->rt6i_prefsrc.plen) {
+		struct in6_addr saddr_buf;
+		ipv6_addr_copy(&saddr_buf, &rt->rt6i_prefsrc.addr);
+		NLA_PUT(skb, RTA_PREFSRC, 16, &saddr_buf);
 	}
=20
 	if (rtnetlink_put_metrics(skb, dst_metrics_ptr(&rt->dst)) < 0)











Daniel Walter
Software Engineer

Barracuda Networks AG
Eduard-Bodem-Gasse 1
6020 Innsbruck
Austria

Phone: +43 (0) 508 100
Fax: +43 508 100 20
eMail: mailto:DWalter@barracuda.com
Web: www.barracudanetworks.com, www.phion.com







Barracuda Networks AG
Vorsitzender des Aufsichtsrates/ Chairman of the supervisory board: Dean Dr=
ako
Vorstand/ Executive Board: Dr. Wieland Alge, Mag. Guenter Klausner
Sitz der Gesellschaft/ Registered office: 6020 Innsbruck, Austria
Handelsgericht Innsbruck Firmenbuch/ Registration Number: 184392s
UID-Nr/ VAT Number: ATU47509003

Diese Nachricht und allfaellige angehaengte Dokumente sind vertraulich und =
nur fuer den/die Adressaten bestimmt. Sollten Sie nicht der beabsichtigte A=
dressat sein, ist jede Offenlegung, Weiterleitung oder sonstige Verwendung =
dieser Information nicht gestattet. In diesem Fall bitten wir, den Absender=
 zu verstaendigen und die Information zu vernichten. Fuer Uebermittlungsfeh=
ler oder sonstige Irrtuemer bei Uebermittlung besteht keine Haftung.

This message and any attached files are confidential and intended solely fo=
r the addressee(s). Any publication, transmission or other use of the infor=
mation by a person or entity other than the intended addressee is prohibite=
d. If you receive this in error please contact the sender and delete the ma=
terial. The sender does not accept liability for any errors or omissions as=
 a result of the transmission.


Barracuda Networks solutions are now available as virtual appliances. =0D
Visit www.barracudanetworks.com/vx for more information.=0D
=0D
=0D


--=-Ph+wg+tryrE8bFkiYRL4
Content-Disposition: attachment;
	filename="linux-ipv6-prefsrc-selection.patch"
Content-Type: text/x-patch; name="linux-ipv6-prefsrc-selection.patch";
	charset="UTF-8"
Content-Transfer-Encoding: 7bit

diff --git a/include/linux/ipv6_route.h b/include/linux/ipv6_route.h
index 1e7d8af..9845953 100644
--- a/include/linux/ipv6_route.h
+++ b/include/linux/ipv6_route.h
@@ -44,6 +44,7 @@
 struct in6_rtmsg {
 	struct in6_addr		rtmsg_dst;
 	struct in6_addr		rtmsg_src;
+	struct in6_addr		rtmsg_prefsrc;
 	struct in6_addr		rtmsg_gateway;
 	__u32			rtmsg_type;
 	__u16			rtmsg_dst_len;
diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
index bc3cde0..98348d5 100644
--- a/include/net/ip6_fib.h
+++ b/include/net/ip6_fib.h
@@ -42,6 +42,7 @@ struct fib6_config {
 
 	struct in6_addr	fc_dst;
 	struct in6_addr	fc_src;
+	struct in6_addr	fc_prefsrc;
 	struct in6_addr	fc_gateway;
 
 	unsigned long	fc_expires;
@@ -107,6 +108,7 @@ struct rt6_info {
 	struct rt6key			rt6i_dst ____cacheline_aligned_in_smp;
 	u32				rt6i_flags;
 	struct rt6key			rt6i_src;
+	struct rt6key			rt6i_prefsrc;
 	u32				rt6i_metric;
 	u32				rt6i_peer_genid;
 
diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
index c850e5f..2b37c20 100644
--- a/include/net/ip6_route.h
+++ b/include/net/ip6_route.h
@@ -141,6 +141,7 @@ struct rt6_rtnl_dump_arg {
 extern int rt6_dump_route(struct rt6_info *rt, void *p_arg);
 extern void rt6_ifdown(struct net *net, struct net_device *dev);
 extern void rt6_mtu_change(struct net_device *dev, unsigned mtu);
+extern void rt6_remove_prefsrc(struct inet6_ifaddr *ifp);
 
 
 /*
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 3daaf3c..26f9e14 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -825,6 +825,8 @@ static void ipv6_del_addr(struct inet6_ifaddr *ifp)
 		dst_release(&rt->dst);
 	}
 
+	/* clean up prefsrc entries */
+	rt6_remove_prefsrc(ifp);
 out:
 	in6_ifa_put(ifp);
 }
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 1820887..e2d8463 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -930,10 +930,14 @@ static int ip6_dst_lookup_tail(struct sock *sk,
 		goto out_err_release;
 
 	if (ipv6_addr_any(&fl6->saddr)) {
-		err = ipv6_dev_get_saddr(net, ip6_dst_idev(*dst)->dev,
-					 &fl6->daddr,
-					 sk ? inet6_sk(sk)->srcprefs : 0,
-					 &fl6->saddr);
+		struct rt6_info *rt = (struct rt6_info *) *dst;
+		if (rt->rt6i_prefsrc.plen)
+			ipv6_addr_copy(&fl6->saddr, &rt->rt6i_prefsrc.addr);
+		else
+			err = ipv6_dev_get_saddr(net, ip6_dst_idev(*dst)->dev,
+						 &fl6->daddr,
+						 sk ? inet6_sk(sk)->srcprefs : 0,
+						 &fl6->saddr);
 		if (err)
 			goto out_err_release;
 	}
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 843406f..b53089d 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1325,6 +1325,20 @@ int ip6_route_add(struct fib6_config *cfg)
 	if (dev == NULL)
 		goto out;
 
+	/* check if prefsrc is set */
+	if (!ipv6_addr_any(&cfg->fc_prefsrc)) {
+		struct in6_addr saddr_buf;
+		ipv6_addr_copy(&saddr_buf, &cfg->fc_prefsrc);
+		if (!ipv6_chk_addr(net, &saddr_buf, dev, 0)) {
+			printk(KERN_DEBUG "invalid pref_src\n");
+			err = -EINVAL;
+			goto out;
+		}
+		ipv6_addr_copy(&rt->rt6i_prefsrc.addr, &cfg->fc_prefsrc);
+		rt->rt6i_prefsrc.plen = 128;
+	} else
+		rt->rt6i_prefsrc.plen = 0;
+
 	if (cfg->fc_flags & (RTF_GATEWAY | RTF_NONEXTHOP)) {
 		rt->rt6i_nexthop = __neigh_lookup_errno(&nd_tbl, &rt->rt6i_gateway, dev);
 		if (IS_ERR(rt->rt6i_nexthop)) {
@@ -1893,6 +1907,7 @@ static void rtmsg_to_fib6_config(struct net *net,
 	ipv6_addr_copy(&cfg->fc_dst, &rtmsg->rtmsg_dst);
 	ipv6_addr_copy(&cfg->fc_src, &rtmsg->rtmsg_src);
 	ipv6_addr_copy(&cfg->fc_gateway, &rtmsg->rtmsg_gateway);
+	ipv6_addr_copy(&cfg->fc_prefsrc, &rtmsg->rtmsg_prefsrc);
 }
 
 int ipv6_route_ioctl(struct net *net, unsigned int cmd, void __user *arg)
@@ -2037,6 +2052,39 @@ struct rt6_info *addrconf_dst_alloc(struct inet6_dev *idev,
 	return rt;
 }
 
+/* remove deleted ip from prefsrc entries */
+struct arg_dev_net_ip {
+	struct net_device *dev;
+	struct net *net;
+	struct in6_addr *addr;
+};
+
+static int fib6_remove_prefsrc(struct rt6_info *rt, void *arg)
+{
+	struct net_device *dev = ((struct arg_dev_net_ip *)arg)->dev;
+	struct net *net = ((struct arg_dev_net_ip *)arg)->net;
+	struct in6_addr *addr = ((struct arg_dev_net_ip *)arg)->addr;
+
+	if (((void *)rt->rt6i_dev == dev || dev == NULL) &&
+	    rt != net->ipv6.ip6_null_entry &&
+	    ipv6_addr_equal(addr, &rt->rt6i_prefsrc.addr)) {
+		/* remove prefsrc entry */
+		rt->rt6i_prefsrc.plen = 0;
+	}
+	return 0;
+}
+
+void rt6_remove_prefsrc(struct inet6_ifaddr *ifp)
+{
+	struct net *net = dev_net(ifp->idev->dev);
+	struct arg_dev_net_ip adni = {
+		.dev = ifp->idev->dev,
+		.net = net,
+		.addr = &ifp->addr,
+	};
+	fib6_clean_all(net, fib6_remove_prefsrc, 0, &adni);
+}
+
 struct arg_dev_net {
 	struct net_device *dev;
 	struct net *net;
@@ -2183,6 +2231,9 @@ static int rtm_to_fib6_config(struct sk_buff *skb, struct nlmsghdr *nlh,
 		nla_memcpy(&cfg->fc_src, tb[RTA_SRC], plen);
 	}
 
+	if (tb[RTA_PREFSRC])
+		nla_memcpy(&cfg->fc_prefsrc, tb[RTA_PREFSRC], 16);
+
 	if (tb[RTA_OIF])
 		cfg->fc_ifindex = nla_get_u32(tb[RTA_OIF]);
 
@@ -2325,11 +2376,22 @@ static int rt6_fill_node(struct net *net,
 #endif
 			NLA_PUT_U32(skb, RTA_IIF, iif);
 	} else if (dst) {
-		struct inet6_dev *idev = ip6_dst_idev(&rt->dst);
 		struct in6_addr saddr_buf;
-		if (ipv6_dev_get_saddr(net, idev ? idev->dev : NULL,
-				       dst, 0, &saddr_buf) == 0)
+		if (rt->rt6i_prefsrc.plen) {
+			ipv6_addr_copy(&saddr_buf, &rt->rt6i_prefsrc.addr);
 			NLA_PUT(skb, RTA_PREFSRC, 16, &saddr_buf);
+		} else {
+			struct inet6_dev *idev = ip6_dst_idev(&rt->dst);
+			if (ipv6_dev_get_saddr(net, idev ? idev->dev : NULL,
+					       dst, 0, &saddr_buf) == 0)
+				NLA_PUT(skb, RTA_PREFSRC, 16, &saddr_buf);
+		}
+	}
+
+	if (rt->rt6i_prefsrc.plen) {
+		struct in6_addr saddr_buf;
+		ipv6_addr_copy(&saddr_buf, &rt->rt6i_prefsrc.addr);
+		NLA_PUT(skb, RTA_PREFSRC, 16, &saddr_buf);
 	}
 
 	if (rtnetlink_put_metrics(skb, dst_metrics_ptr(&rt->dst)) < 0)

--=-Ph+wg+tryrE8bFkiYRL4--
