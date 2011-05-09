From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] net: use batched device unregister in veth
 and macvlan
Date: Mon, 09 May 2011 11:17:57 +0200
Message-ID: <1304932677.3342.17.camel@edumazet-laptop>
References: <1304793749.3207.26.camel@edumazet-laptop>
	 <1304838742.3207.45.camel@edumazet-laptop>
	 <F57561A93EFF5E88729A8D53@nimrod.local>
	 <7B76F9D75FD26D716624004B@nimrod.local>
	 <20110508125028.GK2641@linux.vnet.ibm.com>
	 <B2891EFD056565BBD4DBCE16@nimrod.local>
	 <20110508134425.GL2641@linux.vnet.ibm.com>
	 <C449131127D58077CB25C9D8@Ximines.local>
	 <20110508144749.GR2641@linux.vnet.ibm.com>
	 <AB9DE9E04289CF29CA79CC67@Ximines.local>
	 <20110508154854.GT2641@linux.vnet.ibm.com>
	 <1304888447.3207.66.camel@edumazet-laptop>
	 <1304916275.3207.79.camel@edumazet-laptop>
	 <BANLkTim2e1Gm_jqfY89is-FfRYTu2=G02w@mail.gmail.com>
	 <1304929236.3342.8.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alex Bligh <alex@alex.org.uk>, netdev@vger.kernel.org,
	Jesse Gross <jesse@nicira.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Ben Greear <greearb@candelatech.com>
To: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirqus@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:53512 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750704Ab1EIJSA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2011 05:18:00 -0400
Received: by ewy4 with SMTP id 4so1476628ewy.19
        for <netdev@vger.kernel.org>; Mon, 09 May 2011 02:17:59 -0700 (PDT)
In-Reply-To: <1304929236.3342.8.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

veth devices dont use the batched device unregisters yet.

Since veth are a pair of devices, it makes sense to use a batch of two
unregisters, this roughly divides dismantle time by two.

=46ix this by changing dellink() callers to always provide a non NULL
head. (Idea from Micha=C5=82 Miros=C5=82aw)

This patch also handles macvlan case : We now dismantle all macvlans on
top of a lower dev at once.

Reported-by: Alex Bligh <alex@alex.org.uk>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Micha=C5=82 Miros=C5=82aw <mirqus@gmail.com>
Cc: Jesse Gross <jesse@nicira.com>
Cc: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
Cc: Ben Greear <greearb@candelatech.com>
---
v3: Micha=C5=82 Miros=C5=82aw dellink idea

 drivers/net/macvlan.c |    5 ++++-
 net/core/rtnetlink.c  |    5 ++++-
 2 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 3ad5425..d7c0bc62 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -785,6 +785,7 @@ static int macvlan_device_event(struct notifier_blo=
ck *unused,
 	struct net_device *dev =3D ptr;
 	struct macvlan_dev *vlan, *next;
 	struct macvlan_port *port;
+	LIST_HEAD(list_kill);
=20
 	if (!macvlan_port_exists(dev))
 		return NOTIFY_DONE;
@@ -810,7 +811,9 @@ static int macvlan_device_event(struct notifier_blo=
ck *unused,
 			break;
=20
 		list_for_each_entry_safe(vlan, next, &port->vlans, list)
-			vlan->dev->rtnl_link_ops->dellink(vlan->dev, NULL);
+			vlan->dev->rtnl_link_ops->dellink(vlan->dev, &list_kill);
+		unregister_netdevice_many(&list_kill);
+		list_del(&list_kill);
 		break;
 	case NETDEV_PRE_TYPE_CHANGE:
 		/* Forbid underlaying device to change its type. */
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 5a160f4..d2ba259 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1501,6 +1501,7 @@ static int rtnl_dellink(struct sk_buff *skb, stru=
ct nlmsghdr *nlh, void *arg)
 	char ifname[IFNAMSIZ];
 	struct nlattr *tb[IFLA_MAX+1];
 	int err;
+	LIST_HEAD(list_kill);
=20
 	err =3D nlmsg_parse(nlh, sizeof(*ifm), tb, IFLA_MAX, ifla_policy);
 	if (err < 0)
@@ -1524,7 +1525,9 @@ static int rtnl_dellink(struct sk_buff *skb, stru=
ct nlmsghdr *nlh, void *arg)
 	if (!ops)
 		return -EOPNOTSUPP;
=20
-	ops->dellink(dev, NULL);
+	ops->dellink(dev, &list_kill);
+	unregister_netdevice_many(&list_kill);
+	list_del(&list_kill);
 	return 0;
 }
=20


