From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH net-next] ipv6: addrconf: use stable address generator for ARPHRD_NONE
Date: Wed, 16 Dec 2015 16:44:38 +0100
Message-ID: <1450280678-4730-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	=?UTF-8?q?=E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E?=
	<hideaki.yoshifuji@miraclelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:37897 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934012AbbLPPpA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Dec 2015 10:45:00 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a new address generator mode, using the stable address generator
with an automatically generated secret. This is intended as a default
address generator mode for device types with no EUI64 implementation.
The new generator is used for ARPHRD_NONE interfaces initially, adding
default IPv6 autoconf support to e.g. tun interfaces.

If the addrgenmode is set to 'random', either by default or manually,
and no stable secret is available, then a random secret is used as
input for the stable-privacy address generator.  The secret can be
read and modified like manually configured secrets, using the proc
interface.  Modifying the secret will change the addrgen mode to
'stable-privacy' to indicate that it operates on a known secret.

Existing behaviour of the 'stable-privacy' mode is kept unchanged. If
a known secret is available when the device is created, then the mode
will default to 'stable-privacy' as before.  The mode can be manually
set to 'random' but it will behave exactly like 'stable-privacy' in
this case. The secret will not change.

Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
Cc: =E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E <hideaki.yoshifuji@miraclelinu=
x.com>
Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
Changes since RFC:
 - use IN6_ADDR_GEN_MODE_RANDOM as requested
 - set the device type specific default in addrconf_dev_config() instea=
d
   of ipv6_add_dev() to catch device type changes

I guess an explanation is needed for the last change: My primary
use case for this is the raw-ip support recently added to the qmi_wwan
driver. This driver creates an ARPHRD_ETHER device which can be morphed
into an ARPHRD_NONE device. So at device creation time everything is
fine and EUI64 is supported. But when the link is set up, the device
type is change and EUI64 does not work. So I needed to override the
default for ARPHRD_NONE at link up time.

An alternative would be to keep the ipv6_add_dev() code and add device
type change notifier code. That seemed messier to me. Besides, we
already do type based address configuration decisions in
addrconf_dev_config(), deciding whether autoconfiguration is available
or not.


Bj=C3=B8rn

 include/uapi/linux/if_link.h |  1 +
 net/ipv6/addrconf.c          | 45 ++++++++++++++++++++++++++++++++++++=
++------
 2 files changed, 40 insertions(+), 6 deletions(-)

diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.=
h
index 2be1dd5a103f..a30b78090594 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -218,6 +218,7 @@ enum in6_addr_gen_mode {
 	IN6_ADDR_GEN_MODE_EUI64,
 	IN6_ADDR_GEN_MODE_NONE,
 	IN6_ADDR_GEN_MODE_STABLE_PRIVACY,
+	IN6_ADDR_GEN_MODE_RANDOM,
 };
=20
 /* Bridge section */
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 7082fb79d876..9bb1458badbf 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -2313,6 +2313,12 @@ static void manage_tempaddrs(struct inet6_dev *i=
dev,
 	}
 }
=20
+static bool is_addr_mode_generate_stable(struct inet6_dev *idev)
+{
+	return idev->addr_gen_mode =3D=3D IN6_ADDR_GEN_MODE_STABLE_PRIVACY ||
+	       idev->addr_gen_mode =3D=3D IN6_ADDR_GEN_MODE_RANDOM;
+}
+
 void addrconf_prefix_rcv(struct net_device *dev, u8 *opt, int len, boo=
l sllao)
 {
 	struct prefix_info *pinfo;
@@ -2426,8 +2432,7 @@ void addrconf_prefix_rcv(struct net_device *dev, =
u8 *opt, int len, bool sllao)
 				       in6_dev->token.s6_addr + 8, 8);
 				read_unlock_bh(&in6_dev->lock);
 				tokenized =3D true;
-			} else if (in6_dev->addr_gen_mode =3D=3D
-				   IN6_ADDR_GEN_MODE_STABLE_PRIVACY &&
+			} else if (is_addr_mode_generate_stable(in6_dev) &&
 				   !ipv6_generate_stable_address(&addr, 0,
 								 in6_dev)) {
 				addr_flags |=3D IFA_F_STABLE_PRIVACY;
@@ -3027,6 +3032,17 @@ retry:
 	return 0;
 }
=20
+static void ipv6_gen_mode_random_init(struct inet6_dev *idev)
+{
+	struct ipv6_stable_secret *s =3D &idev->cnf.stable_secret;
+
+	if (s->initialized)
+		return;
+	s =3D &idev->cnf.stable_secret;
+	get_random_bytes(&s->secret, sizeof(s->secret));
+	s->initialized =3D true;
+}
+
 static void addrconf_addr_gen(struct inet6_dev *idev, bool prefix_rout=
e)
 {
 	struct in6_addr addr;
@@ -3037,13 +3053,18 @@ static void addrconf_addr_gen(struct inet6_dev =
*idev, bool prefix_route)
=20
 	ipv6_addr_set(&addr, htonl(0xFE800000), 0, 0, 0);
=20
-	if (idev->addr_gen_mode =3D=3D IN6_ADDR_GEN_MODE_STABLE_PRIVACY) {
+	switch (idev->addr_gen_mode) {
+	case IN6_ADDR_GEN_MODE_RANDOM:
+		ipv6_gen_mode_random_init(idev);
+		/* fallthrough */
+	case IN6_ADDR_GEN_MODE_STABLE_PRIVACY:
 		if (!ipv6_generate_stable_address(&addr, 0, idev))
 			addrconf_add_linklocal(idev, &addr,
 					       IFA_F_STABLE_PRIVACY);
 		else if (prefix_route)
 			addrconf_prefix_route(&addr, 64, idev->dev, 0, 0);
-	} else if (idev->addr_gen_mode =3D=3D IN6_ADDR_GEN_MODE_EUI64) {
+		break;
+	case IN6_ADDR_GEN_MODE_EUI64:
 		/* addrconf_add_linklocal also adds a prefix_route and we
 		 * only need to care about prefix routes if ipv6_generate_eui64
 		 * couldn't generate one.
@@ -3052,6 +3073,11 @@ static void addrconf_addr_gen(struct inet6_dev *=
idev, bool prefix_route)
 			addrconf_add_linklocal(idev, &addr, 0);
 		else if (prefix_route)
 			addrconf_prefix_route(&addr, 64, idev->dev, 0, 0);
+		break;
+	case IN6_ADDR_GEN_MODE_NONE:
+	default:
+		/* will not add any link local address */
+		break;
 	}
 }
=20
@@ -3067,7 +3093,8 @@ static void addrconf_dev_config(struct net_device=
 *dev)
 	    (dev->type !=3D ARPHRD_INFINIBAND) &&
 	    (dev->type !=3D ARPHRD_IEEE1394) &&
 	    (dev->type !=3D ARPHRD_TUNNEL6) &&
-	    (dev->type !=3D ARPHRD_6LOWPAN)) {
+	    (dev->type !=3D ARPHRD_6LOWPAN) &&
+	    (dev->type !=3D ARPHRD_NONE)) {
 		/* Alas, we support only Ethernet autoconfiguration. */
 		return;
 	}
@@ -3076,6 +3103,11 @@ static void addrconf_dev_config(struct net_devic=
e *dev)
 	if (IS_ERR(idev))
 		return;
=20
+	/* this device type has no EUI support */
+	if (dev->type =3D=3D ARPHRD_NONE &&
+	    idev->addr_gen_mode =3D=3D IN6_ADDR_GEN_MODE_EUI64)
+		idev->addr_gen_mode =3D IN6_ADDR_GEN_MODE_RANDOM;
+
 	addrconf_addr_gen(idev, false);
 }
=20
@@ -4920,7 +4952,8 @@ static int inet6_set_link_af(struct net_device *d=
ev, const struct nlattr *nla)
=20
 		if (mode !=3D IN6_ADDR_GEN_MODE_EUI64 &&
 		    mode !=3D IN6_ADDR_GEN_MODE_NONE &&
-		    mode !=3D IN6_ADDR_GEN_MODE_STABLE_PRIVACY)
+		    mode !=3D IN6_ADDR_GEN_MODE_STABLE_PRIVACY &&
+		    mode !=3D IN6_ADDR_GEN_MODE_RANDOM)
 			return -EINVAL;
=20
 		if (mode =3D=3D IN6_ADDR_GEN_MODE_STABLE_PRIVACY &&
--=20
2.1.4
