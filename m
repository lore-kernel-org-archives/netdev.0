From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next v2 5/8] ipv6: collapse state_lock and lock
Date: Mon, 23 Mar 2015 23:36:03 +0100
Message-ID: <6dd84cfa2d766af61045a7f3ad11fe8547bdb1f1.1427149704.git.hannes@stressinduktion.org>
References: <cover.1427149704.git.hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ek@google.com, fgont@si6networks.com, lorenzo@google.com,
	hideaki.yoshifuji@miraclelinux.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:35516 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753493AbbCWWgU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2015 18:36:20 -0400
Received: from compute1.internal (compute1.nyi.internal [10.202.2.41])
	by mailout.nyi.internal (Postfix) with ESMTP id A2D9020886
	for <netdev@vger.kernel.org>; Mon, 23 Mar 2015 18:36:17 -0400 (EDT)
In-Reply-To: <cover.1427149704.git.hannes@stressinduktion.org>
In-Reply-To: <cover.1427149704.git.hannes@stressinduktion.org>
References: <cover.1427149704.git.hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cc: Erik Kline <ek@google.com>
Cc: Fernando Gont <fgont@si6networks.com>
Cc: Lorenzo Colitti <lorenzo@google.com>
Cc: YOSHIFUJI Hideaki/=E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E <hideaki.yos=
hifuji@miraclelinux.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/net/if_inet6.h |  3 +--
 net/ipv6/addrconf.c    | 31 +++++++++++++++----------------
 2 files changed, 16 insertions(+), 18 deletions(-)

diff --git a/include/net/if_inet6.h b/include/net/if_inet6.h
index 98e5f95..d89397a 100644
--- a/include/net/if_inet6.h
+++ b/include/net/if_inet6.h
@@ -41,13 +41,12 @@ enum {
 struct inet6_ifaddr {
 	struct in6_addr		addr;
 	__u32			prefix_len;
-=09
+
 	/* In seconds, relative to tstamp. Expiry is at tstamp + HZ * lft. */
 	__u32			valid_lft;
 	__u32			prefered_lft;
 	atomic_t		refcnt;
 	spinlock_t		lock;
-	spinlock_t		state_lock;
=20
 	int			state;
=20
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index c2357b6..1cc5320 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -873,7 +873,6 @@ ipv6_add_addr(struct inet6_dev *idev, const struct =
in6_addr *addr,
 		ifa->peer_addr =3D *peer_addr;
=20
 	spin_lock_init(&ifa->lock);
-	spin_lock_init(&ifa->state_lock);
 	INIT_DELAYED_WORK(&ifa->dad_work, addrconf_dad_work);
 	INIT_HLIST_NODE(&ifa->addr_lst);
 	ifa->scope =3D scope;
@@ -1016,10 +1015,10 @@ static void ipv6_del_addr(struct inet6_ifaddr *=
ifp)
=20
 	ASSERT_RTNL();
=20
-	spin_lock_bh(&ifp->state_lock);
+	spin_lock_bh(&ifp->lock);
 	state =3D ifp->state;
 	ifp->state =3D INET6_IFADDR_STATE_DEAD;
-	spin_unlock_bh(&ifp->state_lock);
+	spin_unlock_bh(&ifp->lock);
=20
 	if (state =3D=3D INET6_IFADDR_STATE_DEAD)
 		goto out;
@@ -1699,12 +1698,12 @@ static int addrconf_dad_end(struct inet6_ifaddr=
 *ifp)
 {
 	int err =3D -ENOENT;
=20
-	spin_lock_bh(&ifp->state_lock);
+	spin_lock_bh(&ifp->lock);
 	if (ifp->state =3D=3D INET6_IFADDR_STATE_DAD) {
 		ifp->state =3D INET6_IFADDR_STATE_POSTDAD;
 		err =3D 0;
 	}
-	spin_unlock_bh(&ifp->state_lock);
+	spin_unlock_bh(&ifp->lock);
=20
 	return err;
 }
@@ -1737,10 +1736,10 @@ void addrconf_dad_failure(struct inet6_ifaddr *=
ifp)
 		}
 	}
=20
-	spin_lock_bh(&ifp->state_lock);
+	spin_lock_bh(&ifp->lock);
 	/* transition from _POSTDAD to _ERRDAD */
 	ifp->state =3D INET6_IFADDR_STATE_ERRDAD;
-	spin_unlock_bh(&ifp->state_lock);
+	spin_unlock_bh(&ifp->lock);
=20
 	addrconf_mod_dad_work(ifp, 0);
 }
@@ -2369,7 +2368,7 @@ ok:
 			u32 stored_lft;
=20
 			/* update lifetime (RFC2462 5.5.3 e) */
-			spin_lock(&ifp->lock);
+			spin_lock_bh(&ifp->lock);
 			now =3D jiffies;
 			if (ifp->valid_lft > (now - ifp->tstamp) / HZ)
 				stored_lft =3D ifp->valid_lft - (now - ifp->tstamp) / HZ;
@@ -2399,12 +2398,12 @@ ok:
 				ifp->tstamp =3D now;
 				flags =3D ifp->flags;
 				ifp->flags &=3D ~IFA_F_DEPRECATED;
-				spin_unlock(&ifp->lock);
+				spin_unlock_bh(&ifp->lock);
=20
 				if (!(flags&IFA_F_TENTATIVE))
 					ipv6_ifa_notify(0, ifp);
 			} else
-				spin_unlock(&ifp->lock);
+				spin_unlock_bh(&ifp->lock);
=20
 			manage_tempaddrs(in6_dev, ifp, valid_lft, prefered_lft,
 					 create, now);
@@ -3265,10 +3264,10 @@ restart:
=20
 		write_unlock_bh(&idev->lock);
=20
-		spin_lock_bh(&ifa->state_lock);
+		spin_lock_bh(&ifa->lock);
 		state =3D ifa->state;
 		ifa->state =3D INET6_IFADDR_STATE_DEAD;
-		spin_unlock_bh(&ifa->state_lock);
+		spin_unlock_bh(&ifa->lock);
=20
 		if (state !=3D INET6_IFADDR_STATE_DEAD) {
 			__ipv6_ifa_notify(RTM_DELADDR, ifa);
@@ -3426,12 +3425,12 @@ static void addrconf_dad_start(struct inet6_ifa=
ddr *ifp)
 {
 	bool begin_dad =3D false;
=20
-	spin_lock_bh(&ifp->state_lock);
+	spin_lock_bh(&ifp->lock);
 	if (ifp->state !=3D INET6_IFADDR_STATE_DEAD) {
 		ifp->state =3D INET6_IFADDR_STATE_PREDAD;
 		begin_dad =3D true;
 	}
-	spin_unlock_bh(&ifp->state_lock);
+	spin_unlock_bh(&ifp->lock);
=20
 	if (begin_dad)
 		addrconf_mod_dad_work(ifp, 0);
@@ -3453,7 +3452,7 @@ static void addrconf_dad_work(struct work_struct =
*w)
=20
 	rtnl_lock();
=20
-	spin_lock_bh(&ifp->state_lock);
+	spin_lock_bh(&ifp->lock);
 	if (ifp->state =3D=3D INET6_IFADDR_STATE_PREDAD) {
 		action =3D DAD_BEGIN;
 		ifp->state =3D INET6_IFADDR_STATE_DAD;
@@ -3461,7 +3460,7 @@ static void addrconf_dad_work(struct work_struct =
*w)
 		action =3D DAD_ABORT;
 		ifp->state =3D INET6_IFADDR_STATE_POSTDAD;
 	}
-	spin_unlock_bh(&ifp->state_lock);
+	spin_unlock_bh(&ifp->lock);
=20
 	if (action =3D=3D DAD_BEGIN) {
 		addrconf_dad_begin(ifp);
--=20
2.1.0
