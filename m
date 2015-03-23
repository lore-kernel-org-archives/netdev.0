From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next v2 4/8] ipv6: introduce IFA_F_STABLE_PRIVACY flag
Date: Mon, 23 Mar 2015 23:36:02 +0100
Message-ID: <ae49b2d13691f685d3f9d70f9f380ef161cd19d7.1427149704.git.hannes@stressinduktion.org>
References: <cover.1427149704.git.hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ek@google.com, fgont@si6networks.com, lorenzo@google.com,
	hideaki.yoshifuji@miraclelinux.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:46562 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752214AbbCWWgT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2015 18:36:19 -0400
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
	by mailout.nyi.internal (Postfix) with ESMTP id 538D3207AC
	for <netdev@vger.kernel.org>; Mon, 23 Mar 2015 18:36:16 -0400 (EDT)
In-Reply-To: <cover.1427149704.git.hannes@stressinduktion.org>
In-Reply-To: <cover.1427149704.git.hannes@stressinduktion.org>
References: <cover.1427149704.git.hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We need to mark appropriate addresses so we can do retries in case thei=
r
DAD failed.

Cc: Erik Kline <ek@google.com>
Cc: Fernando Gont <fgont@si6networks.com>
Cc: Lorenzo Colitti <lorenzo@google.com>
Cc: YOSHIFUJI Hideaki/=E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E <hideaki.yos=
hifuji@miraclelinux.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/uapi/linux/if_addr.h |  1 +
 net/ipv6/addrconf.c          | 14 ++++++++------
 2 files changed, 9 insertions(+), 6 deletions(-)

diff --git a/include/uapi/linux/if_addr.h b/include/uapi/linux/if_addr.=
h
index 40fdfea..4318ab1 100644
--- a/include/uapi/linux/if_addr.h
+++ b/include/uapi/linux/if_addr.h
@@ -51,6 +51,7 @@ enum {
 #define IFA_F_MANAGETEMPADDR	0x100
 #define IFA_F_NOPREFIXROUTE	0x200
 #define IFA_F_MCAUTOJOIN	0x400
+#define IFA_F_STABLE_PRIVACY	0x800
=20
 struct ifa_cacheinfo {
 	__u32	ifa_prefered;
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 6813268..c2357b6 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -2199,6 +2199,7 @@ void addrconf_prefix_rcv(struct net_device *dev, =
u8 *opt, int len, bool sllao)
 	__u32 valid_lft;
 	__u32 prefered_lft;
 	int addr_type;
+	u32 addr_flags =3D 0;
 	struct inet6_dev *in6_dev;
 	struct net *net =3D dev_net(dev);
=20
@@ -2309,6 +2310,7 @@ void addrconf_prefix_rcv(struct net_device *dev, =
u8 *opt, int len, bool sllao)
 				   IN6_ADDR_GEN_MODE_STABLE_PRIVACY &&
 				   !ipv6_generate_stable_address(&addr, 0,
 								 in6_dev)) {
+				addr_flags |=3D IFA_F_STABLE_PRIVACY;
 				goto ok;
 			} else if (ipv6_generate_eui64(addr.s6_addr + 8, dev) &&
 				   ipv6_inherit_eui64(addr.s6_addr + 8, in6_dev)) {
@@ -2328,7 +2330,6 @@ ok:
=20
 		if (ifp =3D=3D NULL && valid_lft) {
 			int max_addresses =3D in6_dev->cnf.max_addresses;
-			u32 addr_flags =3D 0;
=20
 #ifdef CONFIG_IPV6_OPTIMISTIC_DAD
 			if (in6_dev->cnf.optimistic_dad &&
@@ -2807,10 +2808,11 @@ static void init_loopback(struct net_device *de=
v)
 	}
 }
=20
-static void addrconf_add_linklocal(struct inet6_dev *idev, const struc=
t in6_addr *addr)
+static void addrconf_add_linklocal(struct inet6_dev *idev,
+				   const struct in6_addr *addr, u32 flags)
 {
 	struct inet6_ifaddr *ifp;
-	u32 addr_flags =3D IFA_F_PERMANENT;
+	u32 addr_flags =3D flags | IFA_F_PERMANENT;
=20
 #ifdef CONFIG_IPV6_OPTIMISTIC_DAD
 	if (idev->cnf.optimistic_dad &&
@@ -2818,7 +2820,6 @@ static void addrconf_add_linklocal(struct inet6_d=
ev *idev, const struct in6_addr
 		addr_flags |=3D IFA_F_OPTIMISTIC;
 #endif
=20
-
 	ifp =3D ipv6_add_addr(idev, addr, NULL, 64, IFA_LINK, addr_flags,
 			    INFINITY_LIFE_TIME, INFINITY_LIFE_TIME);
 	if (!IS_ERR(ifp)) {
@@ -2916,7 +2917,8 @@ static void addrconf_addr_gen(struct inet6_dev *i=
dev, bool prefix_route)
=20
 	if (idev->addr_gen_mode =3D=3D IN6_ADDR_GEN_MODE_STABLE_PRIVACY) {
 		if (!ipv6_generate_stable_address(&addr, 0, idev))
-			addrconf_add_linklocal(idev, &addr);
+			addrconf_add_linklocal(idev, &addr,
+					       IFA_F_STABLE_PRIVACY);
 		else if (prefix_route)
 			addrconf_prefix_route(&addr, 64, idev->dev, 0, 0);
 	} else if (idev->addr_gen_mode =3D=3D IN6_ADDR_GEN_MODE_EUI64) {
@@ -2925,7 +2927,7 @@ static void addrconf_addr_gen(struct inet6_dev *i=
dev, bool prefix_route)
 		 * couldn't generate one.
 		 */
 		if (ipv6_generate_eui64(addr.s6_addr + 8, idev->dev) =3D=3D 0)
-			addrconf_add_linklocal(idev, &addr);
+			addrconf_add_linklocal(idev, &addr, 0);
 		else if (prefix_route)
 			addrconf_prefix_route(&addr, 64, idev->dev, 0, 0);
 	}
--=20
2.1.0
