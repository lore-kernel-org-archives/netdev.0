From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 4/4] ipv6/addrconf: common code located
Date: Sat,  7 Feb 2009 02:21:03 +0200
Message-ID: <1233966063-2419-4-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <1233966063-2419-1-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1233966063-2419-2-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1233966063-2419-3-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	"=?utf-8?q?Ilpo=20J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:35902 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752245AbZBGAVH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Feb 2009 19:21:07 -0500
In-Reply-To: <1233966063-2419-3-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

$ codiff net/ipv6/addrconf.o net/ipv6/addrconf.o.new
net/ipv6/addrconf.c:
 addrconf_notify | -267
1 function changed, 267 bytes removed

net/ipv6/addrconf.c:
 add_addr |  +86
1 function changed, 86 bytes added

net/ipv6/addrconf.o.new:
2 functions changed, 86 bytes added, 267 bytes removed, diff: -181

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---

If somebody has idea about better name for the function I'm open
to suggestions... I've some doubts that the name as is the best
possible :-).

 net/ipv6/addrconf.c |   45 ++++++++++++++++++-------------------------=
--
 1 files changed, 18 insertions(+), 27 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index f9afb45..03e2a1a 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -2224,10 +2224,24 @@ int addrconf_del_ifaddr(struct net *net, void _=
_user *arg)
 	return err;
 }
=20
+static void add_addr(struct inet6_dev *idev, const struct in6_addr *ad=
dr,
+		     int plen, int scope)
+{
+	struct inet6_ifaddr *ifp;
+
+	ifp =3D ipv6_add_addr(idev, addr, plen, scope, IFA_F_PERMANENT);
+	if (!IS_ERR(ifp)) {
+		spin_lock_bh(&ifp->lock);
+		ifp->flags &=3D ~IFA_F_TENTATIVE;
+		spin_unlock_bh(&ifp->lock);
+		ipv6_ifa_notify(RTM_NEWADDR, ifp);
+		in6_ifa_put(ifp);
+	}
+}
+
 #if defined(CONFIG_IPV6_SIT) || defined(CONFIG_IPV6_SIT_MODULE)
 static void sit_add_v4_addrs(struct inet6_dev *idev)
 {
-	struct inet6_ifaddr * ifp;
 	struct in6_addr addr;
 	struct net_device *dev;
 	struct net *net =3D dev_net(idev->dev);
@@ -2246,14 +2260,7 @@ static void sit_add_v4_addrs(struct inet6_dev *i=
dev)
 	}
=20
 	if (addr.s6_addr32[3]) {
-		ifp =3D ipv6_add_addr(idev, &addr, 128, scope, IFA_F_PERMANENT);
-		if (!IS_ERR(ifp)) {
-			spin_lock_bh(&ifp->lock);
-			ifp->flags &=3D ~IFA_F_TENTATIVE;
-			spin_unlock_bh(&ifp->lock);
-			ipv6_ifa_notify(RTM_NEWADDR, ifp);
-			in6_ifa_put(ifp);
-		}
+		add_addr(idev, &addr, 128, scope);
 		return;
 	}
=20
@@ -2281,15 +2288,7 @@ static void sit_add_v4_addrs(struct inet6_dev *i=
dev)
 				else
 					plen =3D 96;
=20
-				ifp =3D ipv6_add_addr(idev, &addr, plen, flag,
-						    IFA_F_PERMANENT);
-				if (!IS_ERR(ifp)) {
-					spin_lock_bh(&ifp->lock);
-					ifp->flags &=3D ~IFA_F_TENTATIVE;
-					spin_unlock_bh(&ifp->lock);
-					ipv6_ifa_notify(RTM_NEWADDR, ifp);
-					in6_ifa_put(ifp);
-				}
+				add_addr(idev, &addr, plen, flag);
 			}
 		}
 	}
@@ -2299,7 +2298,6 @@ static void sit_add_v4_addrs(struct inet6_dev *id=
ev)
 static void init_loopback(struct net_device *dev)
 {
 	struct inet6_dev  *idev;
-	struct inet6_ifaddr * ifp;
=20
 	/* ::1 */
=20
@@ -2310,14 +2308,7 @@ static void init_loopback(struct net_device *dev=
)
 		return;
 	}
=20
-	ifp =3D ipv6_add_addr(idev, &in6addr_loopback, 128, IFA_HOST, IFA_F_P=
ERMANENT);
-	if (!IS_ERR(ifp)) {
-		spin_lock_bh(&ifp->lock);
-		ifp->flags &=3D ~IFA_F_TENTATIVE;
-		spin_unlock_bh(&ifp->lock);
-		ipv6_ifa_notify(RTM_NEWADDR, ifp);
-		in6_ifa_put(ifp);
-	}
+	add_addr(idev, &in6addr_loopback, 128, IFA_HOST);
 }
=20
 static void addrconf_add_linklocal(struct inet6_dev *idev, struct in6_=
addr *addr)
--=20
1.5.6.5

