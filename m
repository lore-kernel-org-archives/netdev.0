From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] vlan: multiqueue vlan devices
Date: Wed, 02 Sep 2009 21:12:03 +0200
Message-ID: <4A9EC383.4070304@gmail.com>
References: <20090902081429.GB4878@ff.dom.local>	<4A9E2CC7.1010103@gmail.com>	<20090902.013002.181288977.davem@davemloft.net>	<4A9E6551.4030209@gmail.com>	<4A9E699B.7080400@gmail.com>	<20090902092351.11649796@nehalam>	<4A9E9D8A.50406@trash.net>	<4A9EA250.2010209@gmail.com>	<4A9EA8C6.2000501@gmail.com>	<4A9EBB68.2080903@hp.com>	<4A9EBF9C.2030904@gmail.com> <20090902120107.15146e4e@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Brian Haley <brian.haley@hp.com>,
	David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>, jarkao2@gmail.com,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:54058 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753327AbZIBTMI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2009 15:12:08 -0400
In-Reply-To: <20090902120107.15146e4e@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger a =C3=A9crit :
> On Wed, 02 Sep 2009 20:55:24 +0200
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> +static int vlan_get_tx_queues(struct net *net,=20
>> +			      struct nlattr *tb[],
>> +			      int *num_tx_queues,
>> +			      int *real_num_tx_queues)
>=20
>=20
> Nitpick again.  use unsigned unless you have some reason
> to allow -1.

No problem :)

Thanks Stephen

[PATCH net-next-2.6] vlan: multiqueue vlan device

vlan devices are currently not multi-queue capable.

We can do that with a new rtnl_link_ops method,
get_tx_queues(), called from rtnl_create_link()

This new method gets num_tx_queues/real_num_tx_queues
from real device.

register_vlan_device() is also handled.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/net/rtnetlink.h  |    3 +++
 net/8021q/vlan.c         |    5 +++--
 net/8021q/vlan_netlink.c |   20 ++++++++++++++++++++
 net/core/rtnetlink.c     |   10 +++++++++-
 4 files changed, 35 insertions(+), 3 deletions(-)

diff --git a/include/net/rtnetlink.h b/include/net/rtnetlink.h
index 3c1895e..b630196 100644
--- a/include/net/rtnetlink.h
+++ b/include/net/rtnetlink.h
@@ -70,6 +70,9 @@ struct rtnl_link_ops {
 	size_t			(*get_xstats_size)(const struct net_device *dev);
 	int			(*fill_xstats)(struct sk_buff *skb,
 					       const struct net_device *dev);
+	int			(*get_tx_queues)(struct net *net, struct nlattr *tb[],
+						 unsigned int *tx_queues,
+						 unsigned int *real_tx_queues);
 };
=20
 extern int	__rtnl_link_register(struct rtnl_link_ops *ops);
diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index e814794..8836575 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -330,12 +330,13 @@ static int register_vlan_device(struct net_device=
 *real_dev, u16 vlan_id)
 		snprintf(name, IFNAMSIZ, "vlan%.4i", vlan_id);
 	}
=20
-	new_dev =3D alloc_netdev(sizeof(struct vlan_dev_info), name,
-			       vlan_setup);
+	new_dev =3D alloc_netdev_mq(sizeof(struct vlan_dev_info), name,
+				  vlan_setup, real_dev->num_tx_queues);
=20
 	if (new_dev =3D=3D NULL)
 		return -ENOBUFS;
=20
+	new_dev->real_num_tx_queues =3D real_dev->real_num_tx_queues;
 	dev_net_set(new_dev, net);
 	/* need 4 bytes for extra VLAN header info,
 	 * hope the underlying device can handle it.
diff --git a/net/8021q/vlan_netlink.c b/net/8021q/vlan_netlink.c
index e9c91dc..cd5c2ae 100644
--- a/net/8021q/vlan_netlink.c
+++ b/net/8021q/vlan_netlink.c
@@ -100,6 +100,25 @@ static int vlan_changelink(struct net_device *dev,
 	return 0;
 }
=20
+static int vlan_get_tx_queues(struct net *net,=20
+			      struct nlattr *tb[],
+			      unsigned int *num_tx_queues,
+			      unsigned int *real_num_tx_queues)
+{
+	struct net_device *real_dev;
+
+	if (!tb[IFLA_LINK])
+		return -EINVAL;
+
+	real_dev =3D __dev_get_by_index(net, nla_get_u32(tb[IFLA_LINK]));
+	if (!real_dev)
+		return -ENODEV;
+
+	*num_tx_queues      =3D real_dev->num_tx_queues;
+	*real_num_tx_queues =3D real_dev->real_num_tx_queues;
+	return 0;
+}
+
 static int vlan_newlink(struct net_device *dev,
 			struct nlattr *tb[], struct nlattr *data[])
 {
@@ -216,6 +235,7 @@ struct rtnl_link_ops vlan_link_ops __read_mostly =3D=
 {
 	.maxtype	=3D IFLA_VLAN_MAX,
 	.policy		=3D vlan_policy,
 	.priv_size	=3D sizeof(struct vlan_dev_info),
+	.get_tx_queues  =3D vlan_get_tx_queues,
 	.setup		=3D vlan_setup,
 	.validate	=3D vlan_validate,
 	.newlink	=3D vlan_newlink,
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index b44775f..bbcba2a 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -974,12 +974,20 @@ struct net_device *rtnl_create_link(struct net *n=
et, char *ifname,
 {
 	int err;
 	struct net_device *dev;
+	unsigned int num_queues =3D 1;
+	unsigned int real_num_queues =3D 1;
=20
+	if (ops->get_tx_queues) {
+		err =3D ops->get_tx_queues(net, tb, &num_queues, &real_num_queues);
+		if (err)
+			goto err;
+	}
 	err =3D -ENOMEM;
-	dev =3D alloc_netdev(ops->priv_size, ifname, ops->setup);
+	dev =3D alloc_netdev_mq(ops->priv_size, ifname, ops->setup, num_queue=
s);
 	if (!dev)
 		goto err;
=20
+	dev->real_num_tx_queues =3D real_num_queues;
 	if (strchr(dev->name, '%')) {
 		err =3D dev_alloc_name(dev, dev->name);
 		if (err < 0)
