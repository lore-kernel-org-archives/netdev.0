From: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?= <remi@remlab.net>
Subject: [PATCH 3/5] Phonet: routing table Netlink interface
Date: Wed, 14 Oct 2009 13:48:29 +0300
Message-ID: <1255517311-19527-3-git-send-email-remi@remlab.net>
References: <06dcdf33b2a0132b2a05c3220735a81e@chewa.net>
 <1255517311-19527-1-git-send-email-remi@remlab.net>
 <1255517311-19527-2-git-send-email-remi@remlab.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:36523 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932876AbZJNKtI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Oct 2009 06:49:08 -0400
In-Reply-To: <1255517311-19527-2-git-send-email-remi@remlab.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>

Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 include/net/phonet/pn_dev.h |    1 +
 net/phonet/pn_dev.c         |   31 ++++++++++
 net/phonet/pn_netlink.c     |  130 +++++++++++++++++++++++++++++++++++=
++++++++
 3 files changed, 162 insertions(+), 0 deletions(-)

diff --git a/include/net/phonet/pn_dev.h b/include/net/phonet/pn_dev.h
index 87b5d81..afa7def 100644
--- a/include/net/phonet/pn_dev.h
+++ b/include/net/phonet/pn_dev.h
@@ -49,6 +49,7 @@ void phonet_address_notify(int event, struct net_devi=
ce *dev, u8 addr);
=20
 int phonet_route_add(struct net_device *dev, u8 daddr);
 int phonet_route_del(struct net_device *dev, u8 daddr);
+void rtm_phonet_notify(int event, struct net_device *dev, u8 dst);
 struct net_device *phonet_route_get(struct net *net, u8 daddr);
 struct net_device *phonet_route_output(struct net *net, u8 daddr);
=20
diff --git a/net/phonet/pn_dev.c b/net/phonet/pn_dev.c
index 71fffa5..6d64fda 100644
--- a/net/phonet/pn_dev.c
+++ b/net/phonet/pn_dev.c
@@ -240,6 +240,27 @@ static int phonet_device_autoconf(struct net_devic=
e *dev)
 	return 0;
 }
=20
+static void phonet_route_autodel(struct net_device *dev)
+{
+	struct phonet_net *pnn =3D net_generic(dev_net(dev), phonet_net_id);
+	unsigned i;
+	DECLARE_BITMAP(deleted, 64);
+
+	/* Remove left-over Phonet routes */
+	bitmap_zero(deleted, 64);
+	spin_lock_bh(&pnn->routes.lock);
+	for (i =3D 0; i < 64; i++)
+		if (dev =3D=3D pnn->routes.table[i]) {
+			set_bit(i, deleted);
+			pnn->routes.table[i] =3D NULL;
+			dev_put(dev);
+		}
+	spin_unlock_bh(&pnn->routes.lock);
+	for (i =3D find_first_bit(deleted, 64); i < 64;
+			i =3D find_next_bit(deleted, 64, i + 1))
+		rtm_phonet_notify(RTM_DELROUTE, dev, i);
+}
+
 /* notify Phonet of device events */
 static int phonet_device_notify(struct notifier_block *me, unsigned lo=
ng what,
 				void *arg)
@@ -253,6 +274,7 @@ static int phonet_device_notify(struct notifier_blo=
ck *me, unsigned long what,
 		break;
 	case NETDEV_UNREGISTER:
 		phonet_device_destroy(dev);
+		phonet_route_autodel(dev);
 		break;
 	}
 	return 0;
@@ -287,10 +309,19 @@ static void phonet_exit_net(struct net *net)
 {
 	struct phonet_net *pnn =3D net_generic(net, phonet_net_id);
 	struct net_device *dev;
+	unsigned i;
=20
 	rtnl_lock();
 	for_each_netdev(net, dev)
 		phonet_device_destroy(dev);
+
+	for (i =3D 0; i < 64; i++) {
+		dev =3D pnn->routes.table[i];
+		if (dev) {
+			rtm_phonet_notify(RTM_DELROUTE, dev, i);
+			dev_put(dev);
+		}
+	}
 	rtnl_unlock();
=20
 	proc_net_remove(net, "phonet");
diff --git a/net/phonet/pn_netlink.c b/net/phonet/pn_netlink.c
index d21fd35..d8f5d3f 100644
--- a/net/phonet/pn_netlink.c
+++ b/net/phonet/pn_netlink.c
@@ -29,6 +29,8 @@
 #include <net/sock.h>
 #include <net/phonet/pn_dev.h>
=20
+/* Device address handling */
+
 static int fill_addr(struct sk_buff *skb, struct net_device *dev, u8 a=
ddr,
 		     u32 pid, u32 seq, int event);
=20
@@ -160,6 +162,131 @@ out:
 	return skb->len;
 }
=20
+/* Routes handling */
+
+static int fill_route(struct sk_buff *skb, struct net_device *dev, u8 =
dst,
+			u32 pid, u32 seq, int event)
+{
+	struct rtmsg *rtm;
+	struct nlmsghdr *nlh;
+
+	nlh =3D nlmsg_put(skb, pid, seq, event, sizeof(*rtm), 0);
+	if (nlh =3D=3D NULL)
+		return -EMSGSIZE;
+
+	rtm =3D nlmsg_data(nlh);
+	rtm->rtm_family =3D AF_PHONET;
+	rtm->rtm_dst_len =3D 6;
+	rtm->rtm_src_len =3D 0;
+	rtm->rtm_tos =3D 0;
+	rtm->rtm_table =3D RT_TABLE_MAIN;
+	rtm->rtm_protocol =3D RTPROT_STATIC;
+	rtm->rtm_scope =3D RT_SCOPE_UNIVERSE;
+	rtm->rtm_type =3D RTN_UNICAST;
+	rtm->rtm_flags =3D 0;
+	NLA_PUT_U8(skb, RTA_DST, dst);
+	NLA_PUT_U32(skb, RTA_OIF, dev->ifindex);
+	return nlmsg_end(skb, nlh);
+
+nla_put_failure:
+	nlmsg_cancel(skb, nlh);
+	return -EMSGSIZE;
+}
+
+void rtm_phonet_notify(int event, struct net_device *dev, u8 dst)
+{
+	struct sk_buff *skb;
+	int err =3D -ENOBUFS;
+
+	skb =3D nlmsg_new(NLMSG_ALIGN(sizeof(struct ifaddrmsg)) +
+			nla_total_size(1) + nla_total_size(4), GFP_KERNEL);
+	if (skb =3D=3D NULL)
+		goto errout;
+	err =3D fill_route(skb, dev, dst, 0, 0, event);
+	if (err < 0) {
+		WARN_ON(err =3D=3D -EMSGSIZE);
+		kfree_skb(skb);
+		goto errout;
+	}
+	rtnl_notify(skb, dev_net(dev), 0,
+			  RTNLGRP_PHONET_ROUTE, NULL, GFP_KERNEL);
+	return;
+errout:
+	if (err < 0)
+		rtnl_set_sk_err(dev_net(dev), RTNLGRP_PHONET_ROUTE, err);
+}
+
+static const struct nla_policy rtm_phonet_policy[RTA_MAX+1] =3D {
+	[RTA_DST] =3D { .type =3D NLA_U8 },
+	[RTA_OIF] =3D { .type =3D NLA_U32 },
+};
+
+static int route_doit(struct sk_buff *skb, struct nlmsghdr *nlh, void =
*attr)
+{
+	struct net *net =3D sock_net(skb->sk);
+	struct nlattr *tb[RTA_MAX+1];
+	struct net_device *dev;
+	struct rtmsg *rtm;
+	int err;
+	u8 dst;
+
+	if (!capable(CAP_SYS_ADMIN))
+		return -EPERM;
+
+	ASSERT_RTNL();
+
+	err =3D nlmsg_parse(nlh, sizeof(*rtm), tb, RTA_MAX, rtm_phonet_policy=
);
+	if (err < 0)
+		return err;
+
+	rtm =3D nlmsg_data(nlh);
+	if (rtm->rtm_table !=3D RT_TABLE_MAIN || rtm->rtm_type !=3D RTN_UNICA=
ST)
+		return -EINVAL;
+	if (tb[RTA_DST] =3D=3D NULL || tb[RTA_OIF] =3D=3D NULL)
+		return -EINVAL;
+	dst =3D nla_get_u8(tb[RTA_DST]);
+	if (dst & 3) /* Phonet addresses only have 6 high-order bits */
+		return -EINVAL;
+
+	dev =3D __dev_get_by_index(net, nla_get_u32(tb[RTA_OIF]));
+	if (dev =3D=3D NULL)
+		return -ENODEV;
+
+	if (nlh->nlmsg_type =3D=3D RTM_NEWROUTE)
+		err =3D phonet_route_add(dev, dst);
+	else
+		err =3D phonet_route_del(dev, dst);
+	if (!err)
+		rtm_phonet_notify(nlh->nlmsg_type, dev, dst);
+	return err;
+}
+
+static int route_dumpit(struct sk_buff *skb, struct netlink_callback *=
cb)
+{
+	struct net *net =3D sock_net(skb->sk);
+	u8 addr, addr_idx =3D 0, addr_start_idx =3D cb->args[0];
+
+	for (addr =3D 0; addr < 64; addr++) {
+		struct net_device *dev;
+
+		dev =3D phonet_route_get(net, addr << 2);
+		if (!dev)
+			continue;
+
+		if (addr_idx++ < addr_start_idx)
+			continue;
+		if (fill_route(skb, dev, addr << 2, NETLINK_CB(cb->skb).pid,
+				cb->nlh->nlmsg_seq, RTM_NEWROUTE))
+			goto out;
+	}
+
+out:
+	cb->args[0] =3D addr_idx;
+	cb->args[1] =3D 0;
+
+	return skb->len;
+}
+
 int __init phonet_netlink_register(void)
 {
 	int err =3D __rtnl_register(PF_PHONET, RTM_NEWADDR, addr_doit, NULL);
@@ -169,5 +296,8 @@ int __init phonet_netlink_register(void)
 	/* Further __rtnl_register() cannot fail */
 	__rtnl_register(PF_PHONET, RTM_DELADDR, addr_doit, NULL);
 	__rtnl_register(PF_PHONET, RTM_GETADDR, NULL, getaddr_dumpit);
+	__rtnl_register(PF_PHONET, RTM_NEWROUTE, route_doit, NULL);
+	__rtnl_register(PF_PHONET, RTM_DELROUTE, route_doit, NULL);
+	__rtnl_register(PF_PHONET, RTM_GETROUTE, NULL, route_dumpit);
 	return 0;
 }
--=20
1.6.0.4

