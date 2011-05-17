From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] net: add rcu protection to netdev->ifalias
Date: Wed, 18 May 2011 00:18:12 +0200
Message-ID: <1305670692.6741.14.camel@edumazet-laptop>
References: <1303980967.3360.60.camel@edumazet-laptop>
	 <20110428084337.6b54603e@nehalam>
	 <20110502.152733.48516094.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@vyatta.com, kaber@trash.net, netdev@vger.kernel.org,
	remi.denis-courmont@nokia.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:48840 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756583Ab1EQWSQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2011 18:18:16 -0400
Received: by wya21 with SMTP id 21so762658wya.19
        for <netdev@vger.kernel.org>; Tue, 17 May 2011 15:18:15 -0700 (PDT)
In-Reply-To: <20110502.152733.48516094.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 02 mai 2011 =C3=A0 15:27 -0700, David Miller a =C3=A9crit :
> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Thu, 28 Apr 2011 08:43:37 -0700
>=20
> > On Thu, 28 Apr 2011 10:56:07 +0200
> > Eric Dumazet <eric.dumazet@gmail.com> wrote:
> >=20
> >> Four years ago, Patrick made a change to hold rtnl mutex during ne=
tlink
> >> dump callbacks.
> >>=20
> >> I believe it was a wrong move. This slows down concurrent dumps, m=
aking
> >> good old /proc/net/ files faster than rtnetlink in some situations=
=2E
> >>=20
> >> This occurred to me because one "ip link show dev ..." was _very_ =
slow
> >> on a workload adding/removing network devices in background.
> >>=20
> >> All dump callbacks are able to use RCU locking now, so this patch =
does
> >> roughly a revert of commits :
> >>=20
> >> 1c2d670f366 : [RTNETLINK]: Hold rtnl_mutex during netlink dump cal=
lbacks
> >> 6313c1e0992 : [RTNETLINK]: Remove unnecessary locking in dump call=
backs
> >>=20
> >> This let writers fight for rtnl mutex and readers going full speed=
=2E
> >>=20
> >> It also takes care of phonet : phonet_route_get() is now called fr=
om rcu
> >> read section. I renamed it to phonet_route_get_rcu()
> >>=20
> >> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> >> Cc: Patrick McHardy <kaber@trash.net>
> >> Cc: Remi Denis-Courmont <remi.denis-courmont@nokia.com>
> >=20
> > Acked-by: Stephen Hemminger <shemminger@vyatta.com>
>=20
> Applied, thanks everyone!

I think we probably have to make some fixes, because rtnl_fill_ifinfo()
can access fields that were previously protected with RTNL

Let's see if it's doable, before considering re-adding rtnl_lock() in
rtnl_dump_ifinfo() ?

=46irst step : dev->ifalias

Its late here, I'll continue the work tomorrow.

Thanks

[PATCH net-next-2.6] net: add rcu protection to netdev->ifalias

Avoid holding RTNL in show_ifalias() and rtnl_fill_ifinfo() to
manipulate netdev->ifalias

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/linux/netdevice.h |    7 ++++++-
 net/core/dev.c            |   28 ++++++++++++++++------------
 net/core/net-sysfs.c      |   13 +++++++------
 net/core/rtnetlink.c      |    8 ++++++--
 4 files changed, 35 insertions(+), 21 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index a134d80..09b3df4 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -980,6 +980,11 @@ struct net_device_ops {
 						    u32 features);
 };
=20
+struct ifalias {
+	struct rcu_head	rcu;
+	char		name[0];
+};
+
 /*
  *	The DEVICE structure.
  *	Actually, this whole structure is a big mistake.  It mixes I/O
@@ -1004,7 +1009,7 @@ struct net_device {
 	/* device name hash chain */
 	struct hlist_node	name_hlist;
 	/* snmp alias */
-	char 			*ifalias;
+	struct ifalias __rcu 	*ifalias;
=20
 	/*
 	 *	I/O specific fields
diff --git a/net/core/dev.c b/net/core/dev.c
index 155de20..01e3be0 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1035,6 +1035,12 @@ rollback:
 	return err;
 }
=20
+
+static void ifalias_kfree_rcu(struct rcu_head *head)
+{
+	kfree(container_of(head, struct ifalias, rcu));
+}
+
 /**
  *	dev_set_alias - change ifalias of a device
  *	@dev: device
@@ -1045,24 +1051,22 @@ rollback:
  */
 int dev_set_alias(struct net_device *dev, const char *alias, size_t le=
n)
 {
+	struct ifalias *ifalias, *new =3D NULL;
 	ASSERT_RTNL();
=20
 	if (len >=3D IFALIASZ)
 		return -EINVAL;
=20
-	if (!len) {
-		if (dev->ifalias) {
-			kfree(dev->ifalias);
-			dev->ifalias =3D NULL;
-		}
-		return 0;
+	ifalias =3D rtnl_dereference(dev->ifalias);
+	if (len) {
+		new =3D kmalloc(sizeof(*new) + len + 1, GFP_KERNEL);
+		if (!new)
+			return -ENOMEM;
+		strlcpy(new->name, alias, len + 1);
 	}
-
-	dev->ifalias =3D krealloc(dev->ifalias, len + 1, GFP_KERNEL);
-	if (!dev->ifalias)
-		return -ENOMEM;
-
-	strlcpy(dev->ifalias, alias, len+1);
+	if (ifalias)
+		call_rcu(&ifalias->rcu, ifalias_kfree_rcu);
+	rcu_assign_pointer(dev->ifalias, new);
 	return len;
 }
=20
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 1b12217..e2acf15 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -281,13 +281,14 @@ static ssize_t show_ifalias(struct device *dev,
 			    struct device_attribute *attr, char *buf)
 {
 	const struct net_device *netdev =3D to_net_dev(dev);
+	struct ifalias *ifalias;
 	ssize_t ret =3D 0;
=20
-	if (!rtnl_trylock())
-		return restart_syscall();
-	if (netdev->ifalias)
-		ret =3D sprintf(buf, "%s\n", netdev->ifalias);
-	rtnl_unlock();
+	rcu_read_lock();
+	ifalias =3D rcu_dereference(netdev->ifalias);
+	if (ifalias)
+		ret =3D sprintf(buf, "%s\n", ifalias->name);
+	rcu_read_unlock();
 	return ret;
 }
=20
@@ -1265,7 +1266,7 @@ static void netdev_release(struct device *d)
=20
 	BUG_ON(dev->reg_state !=3D NETREG_RELEASED);
=20
-	kfree(dev->ifalias);
+	kfree(rcu_dereference_protected(dev->ifalias, 1));
 	kfree((char *)dev - dev->padded);
 }
=20
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index d2ba259..c8f0a11 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -849,6 +849,7 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, st=
ruct net_device *dev,
 	const struct rtnl_link_stats64 *stats;
 	struct nlattr *attr, *af_spec;
 	struct rtnl_af_ops *af_ops;
+	struct ifalias *ifalias;
=20
 	nlh =3D nlmsg_put(skb, pid, seq, type, sizeof(*ifm), flags);
 	if (nlh =3D=3D NULL)
@@ -879,8 +880,11 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, s=
truct net_device *dev,
 	if (dev->qdisc)
 		NLA_PUT_STRING(skb, IFLA_QDISC, dev->qdisc->ops->id);
=20
-	if (dev->ifalias)
-		NLA_PUT_STRING(skb, IFLA_IFALIAS, dev->ifalias);
+	rcu_read_lock();
+	ifalias =3D rcu_dereference(dev->ifalias);
+	if (ifalias)
+		NLA_PUT_STRING(skb, IFLA_IFALIAS, ifalias->name);
+	rcu_read_unlock();
=20
 	if (1) {
 		struct rtnl_link_ifmap map =3D {


