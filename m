From: "=?iso-8859-1?q?R=E9mi?= Denis-Courmont"
	<remi.denis-courmont@Nokia.com>
Subject: Re: [PATCH 05/11] Phonet: Netlink interface
Date: Wed, 24 Sep 2008 14:30:45 +0300
Message-ID: <200809241430.45344.remi.denis-courmont@nokia.com>
References: <200809221845.54736.remi.denis-courmont@nokia.com> <1222098445-26175-5-git-send-email-remi.denis-courmont@nokia.com> <20080923121002.GQ20815@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: "ext Thomas Graf" <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.233]:41964 "EHLO
	mgw-mx06.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750988AbYIXLbB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Sep 2008 07:31:01 -0400
In-Reply-To: <20080923121002.GQ20815@postel.suug.ch>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Tuesday 23 September 2008 15:10:02, you wrote:
> Please do not use the old attribute buffer anymore. It's use is racy
> ever since we started dropping the rtnl semaphore in order to load
> modules. It would be safe in this particular case but it shouldn't be
> used for new code.
>
> Take a look at rtnl_setlink() for an example on how to use the interf=
ace
> correctly. (...)

Ok, thanks. Would this work?

diff --git a/net/phonet/pn_netlink.c b/net/phonet/pn_netlink.c
index b1ea19a..136622b 100644
--- a/net/phonet/pn_netlink.c
+++ b/net/phonet/pn_netlink.c
@@ -54,11 +54,17 @@ errout:
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
attr,
+			int op)
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
@@ -67,53 +73,39 @@ static int newaddr_doit(struct sk_buff *skb, struct=
 nlmsghdr *nlm, void *attr)
=20
 	ASSERT_RTNL();
=20
-	if (rta[IFA_LOCAL - 1] =3D=3D NULL)
+	err =3D nlmsg_parse(nlh, sizeof(*ifm), tb, IFA_MAX, ifa_phonet_policy=
);
+	if (err < 0)
+		return err;
+
+	ifm =3D nlmsg_data(nlh);
+	if (tb[IFA_LOCAL] =3D=3D NULL)
+		return -EINVAL;
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
-		return -EINVAL;
-
-	memcpy(&pnaddr, RTA_DATA(rta[IFA_LOCAL - 1]), 1);
-
-	err =3D phonet_address_add(dev, pnaddr);
+	if (op =3D=3D RTM_NEWADDR)
+		err =3D phonet_address_add(dev, pnaddr);
+	else
+		err =3D phonet_address_del(dev, pnaddr);
 	if (!err)
-		rtmsg_notify(RTM_NEWADDR, dev, pnaddr);
+		rtmsg_notify(op, dev, pnaddr);
 	return err;
 }
=20
-static int deladdr_doit(struct sk_buff *skb, struct nlmsghdr *nlm, voi=
d *attr)
+static int newaddr_doit(struct sk_buff *skb, struct nlmsghdr *nlm, voi=
d *attr)
 {
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
-		return -EINVAL;
-
-	dev =3D __dev_get_by_index(&init_net, ifm->ifa_index);
-	if (dev =3D=3D NULL)
-		return -ENODEV;
-
-	if (ifm->ifa_prefixlen > 0)
-		return -EADDRNOTAVAIL;
-
-	memcpy(&pnaddr, RTA_DATA(rta[IFA_LOCAL - 1]), 1);
+	return addr_doit(skb, nlm, attr, RTM_NEWADDR);
+}
=20
-	err =3D phonet_address_del(dev, pnaddr);
-	if (!err)
-		rtmsg_notify(RTM_DELADDR, dev, pnaddr);
-	return err;
+static int deladdr_doit(struct sk_buff *skb, struct nlmsghdr *nlm, voi=
d *attr)
+{
+	return addr_doit(skb, nlm, attr, RTM_DELADDR);
 }
=20
 static int fill_addr(struct sk_buff *skb, struct net_device *dev, u8 a=
ddr,
@@ -121,25 +113,23 @@ static int fill_addr(struct sk_buff *skb, struct =
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
_

--=20
R=E9mi Denis-Courmont
Maemo Software, Nokia Devices R&D

