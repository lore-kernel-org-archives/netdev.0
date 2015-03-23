From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next 6/8] ipv6: do retries on stable privacy addresses
Date: Mon, 23 Mar 2015 18:02:00 +0100
Message-ID: <1b56da3336e8af216682125f6d4ff1c6bebd91ec.1427129103.git.hannes@stressinduktion.org>
References: <cover.1427129103.git.hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ek@google.com, fgont@si6networks.com, lorenzo@google.com,
	hideaki.yoshifuji@miraclelinux.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:54179 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753003AbbCWRCO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2015 13:02:14 -0400
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id C0CDA20551
	for <netdev@vger.kernel.org>; Mon, 23 Mar 2015 13:02:11 -0400 (EDT)
In-Reply-To: <cover.1427129103.git.hannes@stressinduktion.org>
In-Reply-To: <cover.1427129103.git.hannes@stressinduktion.org>
References: <cover.1427129103.git.hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If a DAD conflict is detected, we want to retry privacy stable address
generation up to idgen_retries (=3D 3) times with a delay of idgen_dela=
y
(=3D 1 second). Add the logic to addrconf_dad_failure.

By design, we don't clean up dad failed permanent addresses.

Cc: Erik Kline <ek@google.com>
Cc: Fernando Gont <fgont@si6networks.com>
Cc: Lorenzo Colitti <lorenzo@google.com>
Cc: YOSHIFUJI Hideaki/=E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E <hideaki.yos=
hifuji@miraclelinux.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/net/if_inet6.h |  1 +
 net/ipv6/addrconf.c    | 57 ++++++++++++++++++++++++++++++++++++++++++=
+++++---
 2 files changed, 55 insertions(+), 3 deletions(-)

diff --git a/include/net/if_inet6.h b/include/net/if_inet6.h
index d89397a..1c8b682 100644
--- a/include/net/if_inet6.h
+++ b/include/net/if_inet6.h
@@ -52,6 +52,7 @@ struct inet6_ifaddr {
=20
 	__u32			flags;
 	__u8			dad_probes;
+	__u8			stable_privacy_retry;
=20
 	__u16			scope;
=20
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 1cc5320..9b51fdb 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -1710,6 +1710,7 @@ static int addrconf_dad_end(struct inet6_ifaddr *=
ifp)
=20
 void addrconf_dad_failure(struct inet6_ifaddr *ifp)
 {
+	struct in6_addr addr;
 	struct inet6_dev *idev =3D ifp->idev;
=20
 	if (addrconf_dad_end(ifp)) {
@@ -1720,9 +1721,59 @@ void addrconf_dad_failure(struct inet6_ifaddr *i=
fp)
 	net_info_ratelimited("%s: IPv6 duplicate address %pI6c detected!\n",
 			     ifp->idev->dev->name, &ifp->addr);
=20
-	if (idev->cnf.accept_dad > 1 && !idev->cnf.disable_ipv6) {
-		struct in6_addr addr;
+	spin_lock_bh(&ifp->lock);
+
+	if (ifp->flags & IFA_F_STABLE_PRIVACY) {
+		int scope =3D ifp->scope;
+		u32 flags =3D ifp->flags;
+		struct in6_addr new_addr;
+		struct inet6_ifaddr *ifp2;
+		u32 valid_lft, preferred_lft;
+		int pfxlen =3D ifp->prefix_len;
+		const unsigned int idgen_retries =3D 3;
+		const unsigned int idgen_delay =3D 1 * HZ;
+		int retries =3D ifp->stable_privacy_retry + 1;
+
+		if (retries > idgen_retries) {
+			net_info_ratelimited("%s: privacy stable address generation failed =
because of DAD conflicts!\n",
+					     ifp->idev->dev->name);
+			goto errdad;
+		}
+
+		new_addr =3D ifp->addr;
+		if (ipv6_generate_stable_address(&new_addr, retries,
+						 idev))
+			goto errdad;
=20
+		valid_lft =3D ifp->valid_lft;
+		preferred_lft =3D ifp->prefered_lft;
+
+		spin_unlock_bh(&ifp->lock);
+
+		if (idev->cnf.max_addresses &&
+		    ipv6_count_addresses(idev) >=3D
+		    idev->cnf.max_addresses)
+			goto lock_errdad;
+
+		net_info_ratelimited("%s: generating new stable privacy address beca=
use of DAD conflict\n",
+				     ifp->idev->dev->name);
+
+		ifp2 =3D ipv6_add_addr(idev, &new_addr, NULL, pfxlen,
+				     scope, flags, valid_lft,
+				     preferred_lft);
+		if (IS_ERR(ifp2))
+			goto lock_errdad;
+
+		spin_lock_bh(&ifp2->lock);
+		ifp2->stable_privacy_retry =3D retries;
+		ifp2->state =3D INET6_IFADDR_STATE_PREDAD;
+		spin_unlock_bh(&ifp2->lock);
+
+		addrconf_mod_dad_work(ifp2, idgen_delay);
+		in6_ifa_put(ifp2);
+lock_errdad:
+		spin_lock_bh(&ifp->lock);
+	} else if (idev->cnf.accept_dad > 1 && !idev->cnf.disable_ipv6) {
 		addr.s6_addr32[0] =3D htonl(0xfe800000);
 		addr.s6_addr32[1] =3D 0;
=20
@@ -1736,7 +1787,7 @@ void addrconf_dad_failure(struct inet6_ifaddr *if=
p)
 		}
 	}
=20
-	spin_lock_bh(&ifp->lock);
+errdad:
 	/* transition from _POSTDAD to _ERRDAD */
 	ifp->state =3D INET6_IFADDR_STATE_ERRDAD;
 	spin_unlock_bh(&ifp->lock);
--=20
2.1.0
