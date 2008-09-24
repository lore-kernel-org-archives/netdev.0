From: Remi Denis-Courmont <remi.denis-courmont@nokia.com>
Subject: [PATCH 1/3] Phonet: Netlink factorization and cleanup
Date: Wed, 24 Sep 2008 19:11:38 +0300
Message-ID: <1222272700-28232-1-git-send-email-remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.233]:17736 "EHLO
	mgw-mx06.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751899AbYIXQL6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Sep 2008 12:11:58 -0400
Received: from esebh107.NOE.Nokia.com (esebh107.ntc.nokia.com [172.21.143.143])
	by mgw-mx06.nokia.com (Switch-3.2.6/Switch-3.2.6) with ESMTP id m8OGBtEa025585
	for <netdev@vger.kernel.org>; Wed, 24 Sep 2008 19:11:56 +0300
In-Reply-To: <>
References: <>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>

Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 net/phonet/pn_netlink.c |   91 ++++++++++++++++++---------------------=
--------
 1 files changed, 35 insertions(+), 56 deletions(-)

diff --git a/net/phonet/pn_netlink.c b/net/phonet/pn_netlink.c
index b1ea19a..b1770d6 100644
--- a/net/phonet/pn_netlink.c
+++ b/net/phonet/pn_netlink.c
@@ -54,11 +54,16 @@ errout:
 		rtnl_set_sk_err(dev_net(dev), RTNLGRP_PHONET_IFADDR, err);
 }
=20
-static int newaddr_doit(struct sk_buff *skb, struct nlmsghdr *nlm, voi=
d *attr)
+static const struct nla_policy ifa_phonet_policy[IFA_MAX+1] =3D {
+	[IFA_LOCAL] =3D { .type =3D NLA_U8 },
+};
+
+static int addr_doit(struct sk_buff *skb, struct nlmsghdr *nlh, void *=
attr)
 {
-	struct rtattr **rta =3D attr;
-	struct ifaddrmsg *ifm =3D NLMSG_DATA(nlm);
+	struct net *net =3D sock_net(skb->sk);
+	struct nlattr *tb[IFA_MAX+1];
 	struct net_device *dev;
+	struct ifaddrmsg *ifm;
 	int err;
 	u8 pnaddr;
=20
@@ -67,52 +72,28 @@ static int newaddr_doit(struct sk_buff *skb, struct=
 nlmsghdr *nlm, void *attr)
=20
 	ASSERT_RTNL();
=20
-	if (rta[IFA_LOCAL - 1] =3D=3D NULL)
-		return -EINVAL;
-
-	dev =3D __dev_get_by_index(&init_net, ifm->ifa_index);
-	if (dev =3D=3D NULL)
-		return -ENODEV;
+	err =3D nlmsg_parse(nlh, sizeof(*ifm), tb, IFA_MAX, ifa_phonet_policy=
);
+	if (err < 0)
+		return err;
=20
-	if (ifm->ifa_prefixlen > 0)
+	ifm =3D nlmsg_data(nlh);
+	if (tb[IFA_LOCAL] =3D=3D NULL)
 		return -EINVAL;
-
-	memcpy(&pnaddr, RTA_DATA(rta[IFA_LOCAL - 1]), 1);
-
-	err =3D phonet_address_add(dev, pnaddr);
-	if (!err)
-		rtmsg_notify(RTM_NEWADDR, dev, pnaddr);
-	return err;
-}
-
-static int deladdr_doit(struct sk_buff *skb, struct nlmsghdr *nlm, voi=
d *attr)
-{
-	struct rtattr **rta =3D attr;
-	struct ifaddrmsg *ifm =3D NLMSG_DATA(nlm);
-	struct net_device *dev;
-	int err;
-	u8 pnaddr;
-
-	if (!capable(CAP_SYS_ADMIN))
-		return -EPERM;
-
-	ASSERT_RTNL();
-
-	if (rta[IFA_LOCAL - 1] =3D=3D NULL)
+	pnaddr =3D nla_get_u8(tb[IFA_LOCAL]);
+	if (pnaddr & 3)
+		/* Phonet addresses only have 6 high-order bits */
 		return -EINVAL;
=20
-	dev =3D __dev_get_by_index(&init_net, ifm->ifa_index);
+	dev =3D __dev_get_by_index(net, ifm->ifa_index);
 	if (dev =3D=3D NULL)
 		return -ENODEV;
=20
-	if (ifm->ifa_prefixlen > 0)
-		return -EADDRNOTAVAIL;
-
-	memcpy(&pnaddr, RTA_DATA(rta[IFA_LOCAL - 1]), 1);
-
-	err =3D phonet_address_del(dev, pnaddr);
+	if (nlh->nlmsg_type =3D=3D RTM_NEWADDR)
+		err =3D phonet_address_add(dev, pnaddr);
+	else
+		err =3D phonet_address_del(dev, pnaddr);
 	if (!err)
-		rtmsg_notify(RTM_DELADDR, dev, pnaddr);
+		rtmsg_notify(nlh->nlmsg_type, dev, pnaddr);
 	return err;
 }
=20
@@ -121,25 +102,23 @@ static int fill_addr(struct sk_buff *skb, struct =
net_device *dev, u8 addr,
 {
 	struct ifaddrmsg *ifm;
 	struct nlmsghdr *nlh;
-	unsigned int orig_len =3D skb->len;
=20
-	nlh =3D NLMSG_PUT(skb, pid, seq, event, sizeof(struct ifaddrmsg));
-	ifm =3D NLMSG_DATA(nlh);
+	nlh =3D nlmsg_put(skb, pid, seq, event, sizeof(*ifm), 0);
+	if (nlh =3D=3D NULL)
+		return -EMSGSIZE;
+
+	ifm =3D nlmsg_data(nlh);
 	ifm->ifa_family =3D AF_PHONET;
 	ifm->ifa_prefixlen =3D 0;
 	ifm->ifa_flags =3D IFA_F_PERMANENT;
-	ifm->ifa_scope =3D RT_SCOPE_HOST;
+	ifm->ifa_scope =3D RT_SCOPE_LINK;
 	ifm->ifa_index =3D dev->ifindex;
-	RTA_PUT(skb, IFA_LOCAL, 1, &addr);
-	nlh->nlmsg_len =3D skb->len - orig_len;
-
-	return 0;
-
-nlmsg_failure:
-rtattr_failure:
-	skb_trim(skb, orig_len);
+	NLA_PUT_U8(skb, IFA_LOCAL, addr);
+	return nlmsg_end(skb, nlh);
=20
-	return -1;
+nla_put_failure:
+	nlmsg_cancel(skb, nlh);
+	return -EMSGSIZE;
 }
=20
 static int getaddr_dumpit(struct sk_buff *skb, struct netlink_callback=
 *cb)
@@ -180,7 +159,7 @@ out:
=20
 void __init phonet_netlink_register(void)
 {
-	rtnl_register(PF_PHONET, RTM_NEWADDR, newaddr_doit, NULL);
-	rtnl_register(PF_PHONET, RTM_DELADDR, deladdr_doit, NULL);
+	rtnl_register(PF_PHONET, RTM_NEWADDR, addr_doit, NULL);
+	rtnl_register(PF_PHONET, RTM_DELADDR, addr_doit, NULL);
 	rtnl_register(PF_PHONET, RTM_GETADDR, NULL, getaddr_dumpit);
 }
--=20
1.5.4.3

