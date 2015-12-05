From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [RFC] ipv6: use a random ifid for headerless devices
Date: Sat, 05 Dec 2015 20:02:09 +0100
Message-ID: <87d1ukk9ce.fsf@nemi.mork.no>
References: <1448884508-5235-1-git-send-email-bjorn@mork.no>
	<1448968942.3320842.454553905.2C5FBADD@webmail.messagingengine.com>
	<87vb8fjpou.fsf@nemi.mork.no>
	<1449225712.287884.457895729.21AD000E@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-=-="
Cc: <netdev@vger.kernel.org>,
	=?utf-8?B?5ZCJ6Jek6Iux5piO?= <hideaki.yoshifuji@miraclelinux.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:52059 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752631AbbLETCT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Dec 2015 14:02:19 -0500
In-Reply-To: <1449225712.287884.457895729.21AD000E@webmail.messagingengine.com>
	(Hannes Frederic Sowa's message of "Fri, 04 Dec 2015 11:41:52 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--=-=-=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Hannes Frederic Sowa <hannes@stressinduktion.org> writes:
> On Thu, Dec 3, 2015, at 20:29, Bj=C3=B8rn Mork wrote:
>
>> After looking more at addrconf, I started wondering if we couldn't abuse
>> ipv6_generate_stable_address() for this purpose?  We could add a new
>> addr_gen_mode which would trigger automatic generation of a secret if
>> stable_secret is uninitialized.  This would be good enough to ensure
>> stability until the interface is destroyed.  And it would still allow
>> the adminstrator to select IN6_ADDR_GEN_MODE_STABLE_PRIVACY by entering
>> a new secret.
>
> I am fine with your proposal but I would really like to see it only
> happen on the per-interface stable_secret instance.

Do you think something like the patch below will be OK?

Or would it be better to drop the additional mode and just generate a
random secret if the mode is IN6_ADDR_GEN_MODE_STABLE_PRIVACY and the
secrets are missing?  Or would that be changing the userspace ABI?  This
is not clear to me...

Bj=C3=B8rn


--=-=-=
Content-Type: text/x-diff; charset=utf-8
Content-Disposition: inline;
 filename=0001-ipv6-addrconf-use-stable-address-generator-for-ARPHR.patch
Content-Transfer-Encoding: quoted-printable

>From 099c0a856cc4d06d2da6eb7f1f684adff9820f65 Mon Sep 17 00:00:00 2001
From: =3D?UTF-8?q?Bj=3DC3=3DB8rn=3D20Mork?=3D <bjorn@mork.no>
Date: Fri, 4 Dec 2015 13:30:13 +0100
Subject: [PATCH] ipv6: addrconf: use stable address generator for ARPHRD_NO=
NE
MIME-Version: 1.0
Content-Type: text/plain; charset=3DUTF-8
Content-Transfer-Encoding: 8bit

Add a new address generator mode, using the stable address
generator with an automatically generated secret. Set it up
as the default address generator for ARPHRD_NONE interfaces,
which cannot use the EUI generator.

A random secret is generated on first link up event, allowing
a link local address to be added:

5: tun0: <POINTOPOINT,MULTICAST,NOARP> mtu 1500 qdisc noop state DOWN mode =
DEFAULT group default qlen 500
    link/none  promiscuity 0
    tun addrgenmode auto
cat: /proc/sys/net/ipv6/conf/tun0/stable_secret: Input/output error
b269:f3cc:e285:3de3:d9e5:ac1c:bf76:a7ca
5: tun0: <POINTOPOINT,MULTICAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc noqueue s=
tate UNKNOWN group default qlen 500
    link/none  promiscuity 0
    tun
    inet6 fe80::19d4:c711:c8d3:451d/64 scope link flags 800
       valid_lft forever preferred_lft forever

Manually configuring a secret changes the mode to
stable-privacy:

A:~# echo :: > /proc/sys/net/ipv6/conf/tun0/stable_secret
A:~# ip -d link show dev tun0
5: tun0: <POINTOPOINT,MULTICAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc noqueue s=
tate UNKNOWN mode DEFAULT group default qlen 500
    link/none  promiscuity 0
    tun addrgenmode stable-privacy

Changing the mode to auto will not change an existing secret.

Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
 include/uapi/linux/if_link.h |  1 +
 net/ipv6/addrconf.c          | 43 +++++++++++++++++++++++++++++++++++++---=
---
 2 files changed, 38 insertions(+), 6 deletions(-)

diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 5ad5737..999d765 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -218,6 +218,7 @@ enum in6_addr_gen_mode {
 	IN6_ADDR_GEN_MODE_EUI64,
 	IN6_ADDR_GEN_MODE_NONE,
 	IN6_ADDR_GEN_MODE_STABLE_PRIVACY,
+	IN6_ADDR_GEN_MODE_AUTO,
 };
=20
 /* Bridge section */
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index d84742f..1b12ff3 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -393,6 +393,9 @@ static struct inet6_dev *ipv6_add_dev(struct net_device=
 *dev)
 		ndev->cnf.rtr_solicits =3D 0;
 	}
 #endif
+	/* this device type does not support the default EUI mode */
+	if (dev->type =3D=3D ARPHRD_NONE)
+		ndev->addr_gen_mode =3D IN6_ADDR_GEN_MODE_AUTO;
=20
 	INIT_LIST_HEAD(&ndev->tempaddr_list);
 	setup_timer(&ndev->regen_timer, ipv6_regen_rndid, (unsigned long)ndev);
@@ -2314,6 +2317,12 @@ static void manage_tempaddrs(struct inet6_dev *idev,
 	}
 }
=20
+static bool is_addr_mode_generate_stable(struct inet6_dev *idev)
+{
+	return idev->addr_gen_mode =3D=3D IN6_ADDR_GEN_MODE_STABLE_PRIVACY ||
+	       idev->addr_gen_mode =3D=3D IN6_ADDR_GEN_MODE_AUTO;
+}
+
 void addrconf_prefix_rcv(struct net_device *dev, u8 *opt, int len, bool sl=
lao)
 {
 	struct prefix_info *pinfo;
@@ -2427,8 +2436,7 @@ void addrconf_prefix_rcv(struct net_device *dev, u8 *=
opt, int len, bool sllao)
 				       in6_dev->token.s6_addr + 8, 8);
 				read_unlock_bh(&in6_dev->lock);
 				tokenized =3D true;
-			} else if (in6_dev->addr_gen_mode =3D=3D
-				   IN6_ADDR_GEN_MODE_STABLE_PRIVACY &&
+			} else if (is_addr_mode_generate_stable(in6_dev) &&
 				   !ipv6_generate_stable_address(&addr, 0,
 								 in6_dev)) {
 				addr_flags |=3D IFA_F_STABLE_PRIVACY;
@@ -3028,6 +3036,17 @@ retry:
 	return 0;
 }
=20
+static void ipv6_gen_mode_auto_init(struct inet6_dev *idev)
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
 static void addrconf_addr_gen(struct inet6_dev *idev, bool prefix_route)
 {
 	struct in6_addr addr;
@@ -3038,13 +3057,18 @@ static void addrconf_addr_gen(struct inet6_dev *ide=
v, bool prefix_route)
=20
 	ipv6_addr_set(&addr, htonl(0xFE800000), 0, 0, 0);
=20
-	if (idev->addr_gen_mode =3D=3D IN6_ADDR_GEN_MODE_STABLE_PRIVACY) {
+	switch (idev->addr_gen_mode) {
+	case IN6_ADDR_GEN_MODE_AUTO:
+		ipv6_gen_mode_auto_init(idev);
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
@@ -3053,6 +3077,11 @@ static void addrconf_addr_gen(struct inet6_dev *idev=
, bool prefix_route)
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
@@ -3069,7 +3098,8 @@ static void addrconf_dev_config(struct net_device *de=
v)
 	    (dev->type !=3D ARPHRD_IEEE802154) &&
 	    (dev->type !=3D ARPHRD_IEEE1394) &&
 	    (dev->type !=3D ARPHRD_TUNNEL6) &&
-	    (dev->type !=3D ARPHRD_6LOWPAN)) {
+	    (dev->type !=3D ARPHRD_6LOWPAN) &&
+	    (dev->type !=3D ARPHRD_NONE)) {
 		/* Alas, we support only Ethernet autoconfiguration. */
 		return;
 	}
@@ -4921,7 +4951,8 @@ static int inet6_set_link_af(struct net_device *dev, =
const struct nlattr *nla)
=20
 		if (mode !=3D IN6_ADDR_GEN_MODE_EUI64 &&
 		    mode !=3D IN6_ADDR_GEN_MODE_NONE &&
-		    mode !=3D IN6_ADDR_GEN_MODE_STABLE_PRIVACY)
+		    mode !=3D IN6_ADDR_GEN_MODE_STABLE_PRIVACY &&
+		    mode !=3D IN6_ADDR_GEN_MODE_AUTO)
 			return -EINVAL;
=20
 		if (mode =3D=3D IN6_ADDR_GEN_MODE_STABLE_PRIVACY &&
--=20
2.1.4


--=-=-=--
