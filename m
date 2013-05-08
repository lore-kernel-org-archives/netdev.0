From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [BUG REPORT] ipv6: possible unsafe locking scenario
Date: Wed, 8 May 2013 07:05:38 +0000 (UTC)
Message-ID: <kmctg2$2k2$1@ger.gmane.org>
References: <5189D836.3060903@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:60585 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752484Ab3EHHGE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 May 2013 03:06:04 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1UZyRt-0001Ng-Mv
	for netdev@vger.kernel.org; Wed, 08 May 2013 09:06:01 +0200
Received: from 220.165.38.92 ([220.165.38.92])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 08 May 2013 09:06:01 +0200
Received: from xiyou.wangcong by 220.165.38.92 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 08 May 2013 09:06:01 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 08 May 2013 at 04:44 GMT, dingtianhong <dingtianhong@huawei.com=
> wrote:
> hi =EF=BC=81
> I make the kernel config with CONFIG_PROVE_LOCKING CONFIG_IOSCHED_CFQ=
 CONFIG_PREEMPT_RT_FULL on,
> and do several test case, it works well, but i notice that the log me=
ssage has some Call Trace for rwlock,
> it happens only once, maybe the lock use is not safe in ipv6 and need=
 to improve.
>
>         CPU0                    CPU1
>         ----                    ----
>    lock(&mc->mca_lock);
>                                 lock(&ndev->lock);
>                                 lock(&mc->mca_lock);
>    lock(&ndev->lock);
>

Can you try the following patch?

Thanks.

-------------------->

diff --git a/include/net/addrconf.h b/include/net/addrconf.h
index 84a6440..dbc6db7 100644
--- a/include/net/addrconf.h
+++ b/include/net/addrconf.h
@@ -86,6 +86,9 @@ extern int			ipv6_dev_get_saddr(struct net *net,
 					       const struct in6_addr *daddr,
 					       unsigned int srcprefs,
 					       struct in6_addr *saddr);
+extern int			__ipv6_get_lladdr(struct inet6_dev *idev,
+						  struct in6_addr *addr,
+						  unsigned char banned_flags);
 extern int			ipv6_get_lladdr(struct net_device *dev,
 						struct in6_addr *addr,
 						unsigned char banned_flags);
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index d1ab6ab..a937092 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -1448,6 +1448,23 @@ try_nextdev:
 }
 EXPORT_SYMBOL(ipv6_dev_get_saddr);
=20
+int __ipv6_get_lladdr(struct inet6_dev *idev, struct in6_addr *addr,
+		      unsigned char banned_flags)
+{
+	int err =3D -EADDRNOTAVAIL;
+	struct inet6_ifaddr *ifp;
+
+	list_for_each_entry(ifp, &idev->addr_list, if_list) {
+		if (ifp->scope =3D=3D IFA_LINK &&
+		    !(ifp->flags & banned_flags)) {
+			*addr =3D ifp->addr;
+			err =3D 0;
+			break;
+		}
+	}
+	return err;
+}
+
 int ipv6_get_lladdr(struct net_device *dev, struct in6_addr *addr,
 		    unsigned char banned_flags)
 {
@@ -1457,17 +1474,8 @@ int ipv6_get_lladdr(struct net_device *dev, stru=
ct in6_addr *addr,
 	rcu_read_lock();
 	idev =3D __in6_dev_get(dev);
 	if (idev) {
-		struct inet6_ifaddr *ifp;
-
 		read_lock_bh(&idev->lock);
-		list_for_each_entry(ifp, &idev->addr_list, if_list) {
-			if (ifp->scope =3D=3D IFA_LINK &&
-			    !(ifp->flags & banned_flags)) {
-				*addr =3D ifp->addr;
-				err =3D 0;
-				break;
-			}
-		}
+		err =3D __ipv6_get_lladdr(idev, addr, banned_flags);
 		read_unlock_bh(&idev->lock);
 	}
 	rcu_read_unlock();
diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index bfa6cc3..c3998c2 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -1343,8 +1343,9 @@ static void ip6_mc_hdr(struct sock *sk, struct sk=
_buff *skb,
 	hdr->daddr =3D *daddr;
 }
=20
-static struct sk_buff *mld_newpack(struct net_device *dev, int size)
+static struct sk_buff *mld_newpack(struct inet6_dev *idev, int size)
 {
+	struct net_device *dev =3D idev->dev;
 	struct net *net =3D dev_net(dev);
 	struct sock *sk =3D net->ipv6.igmp_sk;
 	struct sk_buff *skb;
@@ -1369,7 +1370,7 @@ static struct sk_buff *mld_newpack(struct net_dev=
ice *dev, int size)
=20
 	skb_reserve(skb, hlen);
=20
-	if (ipv6_get_lladdr(dev, &addr_buf, IFA_F_TENTATIVE)) {
+	if (__ipv6_get_lladdr(idev, &addr_buf, IFA_F_TENTATIVE)) {
 		/* <draft-ietf-magma-mld-source-05.txt>:
 		 * use unspecified address as the source address
 		 * when a valid link-local address is not available.
@@ -1465,7 +1466,7 @@ static struct sk_buff *add_grhead(struct sk_buff =
*skb, struct ifmcaddr6 *pmc,
 	struct mld2_grec *pgr;
=20
 	if (!skb)
-		skb =3D mld_newpack(dev, dev->mtu);
+		skb =3D mld_newpack(pmc->idev, dev->mtu);
 	if (!skb)
 		return NULL;
 	pgr =3D (struct mld2_grec *)skb_put(skb, sizeof(struct mld2_grec));
@@ -1485,7 +1486,8 @@ static struct sk_buff *add_grhead(struct sk_buff =
*skb, struct ifmcaddr6 *pmc,
 static struct sk_buff *add_grec(struct sk_buff *skb, struct ifmcaddr6 =
*pmc,
 	int type, int gdeleted, int sdeleted)
 {
-	struct net_device *dev =3D pmc->idev->dev;
+	struct inet6_dev *idev =3D pmc->idev;
+	struct net_device *dev =3D idev->dev;
 	struct mld2_report *pmr;
 	struct mld2_grec *pgr =3D NULL;
 	struct ip6_sf_list *psf, *psf_next, *psf_prev, **psf_list;
@@ -1514,7 +1516,7 @@ static struct sk_buff *add_grec(struct sk_buff *s=
kb, struct ifmcaddr6 *pmc,
 		    AVAILABLE(skb) < grec_size(pmc, type, gdeleted, sdeleted)) {
 			if (skb)
 				mld_sendpack(skb);
-			skb =3D mld_newpack(dev, dev->mtu);
+			skb =3D mld_newpack(idev, dev->mtu);
 		}
 	}
 	first =3D 1;
@@ -1541,7 +1543,7 @@ static struct sk_buff *add_grec(struct sk_buff *s=
kb, struct ifmcaddr6 *pmc,
 				pgr->grec_nsrcs =3D htons(scount);
 			if (skb)
 				mld_sendpack(skb);
-			skb =3D mld_newpack(dev, dev->mtu);
+			skb =3D mld_newpack(idev, dev->mtu);
 			first =3D 1;
 			scount =3D 0;
 		}
@@ -1596,8 +1598,8 @@ static void mld_send_report(struct inet6_dev *ide=
v, struct ifmcaddr6 *pmc)
 	struct sk_buff *skb =3D NULL;
 	int type;
=20
+	read_lock_bh(&idev->lock);
 	if (!pmc) {
-		read_lock_bh(&idev->lock);
 		for (pmc=3Didev->mc_list; pmc; pmc=3Dpmc->next) {
 			if (pmc->mca_flags & MAF_NOREPORT)
 				continue;
@@ -1609,7 +1611,6 @@ static void mld_send_report(struct inet6_dev *ide=
v, struct ifmcaddr6 *pmc)
 			skb =3D add_grec(skb, pmc, type, 0, 0);
 			spin_unlock_bh(&pmc->mca_lock);
 		}
-		read_unlock_bh(&idev->lock);
 	} else {
 		spin_lock_bh(&pmc->mca_lock);
 		if (pmc->mca_sfcount[MCAST_EXCLUDE])
@@ -1619,6 +1620,7 @@ static void mld_send_report(struct inet6_dev *ide=
v, struct ifmcaddr6 *pmc)
 		skb =3D add_grec(skb, pmc, type, 0, 0);
 		spin_unlock_bh(&pmc->mca_lock);
 	}
+	read_unlock_bh(&idev->lock);
 	if (skb)
 		mld_sendpack(skb);
 }
