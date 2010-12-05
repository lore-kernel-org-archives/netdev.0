From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net: RCU conversion of dev_getbyhwaddr() and arp_ioctl()
Date: Sun, 05 Dec 2010 12:23:53 +0100
Message-ID: <1291548233.2806.212.camel@edumazet-laptop>
References: <1290996593-32416-1-git-send-email-maximlevitsky@gmail.com>
	 <1290996593-32416-4-git-send-email-maximlevitsky@gmail.com>
	 <1291504514.1874.92.camel@maxim-laptop>
	 <1291537161.2806.109.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux1394-devel <linux1394-devel@lists.sourceforge.net>,
	Stefan Richter <stefanr@s5r6.in-berlin.de>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Patrick McHardy <kaber@trash.net>
To: Maxim Levitsky <maximlevitsky@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:44678 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754532Ab0LELYE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Dec 2010 06:24:04 -0500
Received: by wyb28 with SMTP id 28so11051793wyb.19
        for <netdev@vger.kernel.org>; Sun, 05 Dec 2010 03:24:02 -0800 (PST)
In-Reply-To: <1291537161.2806.109.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 05 d=C3=A9cembre 2010 =C3=A0 09:19 +0100, Eric Dumazet a =C3=
=A9crit :

> Hmm..
>=20
> If somebody can explain why RTNL is held in arp_ioctl() (and therefor=
e
> in arp_req_delete()), we might first remove RTNL use in arp_ioctl() s=
o
> that your patch can be applied.
>=20
> Right now it is not good, because RTNL wont be necessarly held when y=
ou
> are going to call arp_invalidate() ?

While doing this analysis, I found a refcount bug in llc, I'll send a
patch for net-2.6

Meanwhile, here is the patch for net-next-2.6

Your patch then can be applied after mine.

Thanks

[PATCH] net: RCU conversion of dev_getbyhwaddr() and arp_ioctl()

dev_getbyhwaddr() was called under RTNL.

Rename it to dev_getbyhwaddr_rcu() and change all its caller to now use
RCU locking instead of RTNL.

Change arp_ioctl() to use RCU instead of RTNL locking.

Note: this fix a dev refcount bug in llc

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/linux/netdevice.h      |    3 ++-
 net/core/dev.c                 |   17 +++++++----------
 net/ieee802154/af_ieee802154.c |    6 +++---
 net/ipv4/arp.c                 |   17 +++++++++--------
 net/llc/af_llc.c               |   11 ++++++-----
 5 files changed, 27 insertions(+), 27 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index a9ac5dc..d31bc3c 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1360,7 +1360,8 @@ static inline struct net_device *first_net_device=
(struct net *net)
=20
 extern int 			netdev_boot_setup_check(struct net_device *dev);
 extern unsigned long		netdev_boot_base(const char *prefix, int unit);
-extern struct net_device    *dev_getbyhwaddr(struct net *net, unsigned=
 short type, char *hwaddr);
+extern struct net_device *dev_getbyhwaddr_rcu(struct net *net, unsigne=
d short type,
+					      const char *hwaddr);
 extern struct net_device *dev_getfirstbyhwtype(struct net *net, unsign=
ed short type);
 extern struct net_device *__dev_getfirstbyhwtype(struct net *net, unsi=
gned short type);
 extern void		dev_add_pack(struct packet_type *pt);
diff --git a/net/core/dev.c b/net/core/dev.c
index cd24374..8630142 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -743,34 +743,31 @@ struct net_device *dev_get_by_index(struct net *n=
et, int ifindex)
 EXPORT_SYMBOL(dev_get_by_index);
=20
 /**
- *	dev_getbyhwaddr - find a device by its hardware address
+ *	dev_getbyhwaddr_rcu - find a device by its hardware address
  *	@net: the applicable net namespace
  *	@type: media type of device
  *	@ha: hardware address
  *
  *	Search for an interface by MAC address. Returns NULL if the device
- *	is not found or a pointer to the device. The caller must hold the
- *	rtnl semaphore. The returned device has not had its ref count incre=
ased
+ *	is not found or a pointer to the device. The caller must hold RCU
+ *	The returned device has not had its ref count increased
  *	and the caller must therefore be careful about locking
  *
- *	BUGS:
- *	If the API was consistent this would be __dev_get_by_hwaddr
  */
=20
-struct net_device *dev_getbyhwaddr(struct net *net, unsigned short typ=
e, char *ha)
+struct net_device *dev_getbyhwaddr_rcu(struct net *net, unsigned short=
 type,
+				       const char *ha)
 {
 	struct net_device *dev;
=20
-	ASSERT_RTNL();
-
-	for_each_netdev(net, dev)
+	for_each_netdev_rcu(net, dev)
 		if (dev->type =3D=3D type &&
 		    !memcmp(dev->dev_addr, ha, dev->addr_len))
 			return dev;
=20
 	return NULL;
 }
-EXPORT_SYMBOL(dev_getbyhwaddr);
+EXPORT_SYMBOL(dev_getbyhwaddr_rcu);
=20
 struct net_device *__dev_getfirstbyhwtype(struct net *net, unsigned sh=
ort type)
 {
diff --git a/net/ieee802154/af_ieee802154.c b/net/ieee802154/af_ieee802=
154.c
index 93c91b6..6df6ecf 100644
--- a/net/ieee802154/af_ieee802154.c
+++ b/net/ieee802154/af_ieee802154.c
@@ -52,11 +52,11 @@ struct net_device *ieee802154_get_dev(struct net *n=
et,
=20
 	switch (addr->addr_type) {
 	case IEEE802154_ADDR_LONG:
-		rtnl_lock();
-		dev =3D dev_getbyhwaddr(net, ARPHRD_IEEE802154, addr->hwaddr);
+		rcu_read_lock();
+		dev =3D dev_getbyhwaddr_rcu(net, ARPHRD_IEEE802154, addr->hwaddr);
 		if (dev)
 			dev_hold(dev);
-		rtnl_unlock();
+		rcu_read_unlock();
 		break;
 	case IEEE802154_ADDR_SHORT:
 		if (addr->pan_id =3D=3D 0xffff ||
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index 7833f17..ec0966f 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -1017,13 +1017,14 @@ static int arp_req_set_proxy(struct net *net, s=
truct net_device *dev, int on)
 		IPV4_DEVCONF_ALL(net, PROXY_ARP) =3D on;
 		return 0;
 	}
-	if (__in_dev_get_rtnl(dev)) {
-		IN_DEV_CONF_SET(__in_dev_get_rtnl(dev), PROXY_ARP, on);
+	if (__in_dev_get_rcu(dev)) {
+		IN_DEV_CONF_SET(__in_dev_get_rcu(dev), PROXY_ARP, on);
 		return 0;
 	}
 	return -ENXIO;
 }
=20
+/* must be called with rcu_read_lock() */
 static int arp_req_set_public(struct net *net, struct arpreq *r,
 		struct net_device *dev)
 {
@@ -1033,7 +1034,7 @@ static int arp_req_set_public(struct net *net, st=
ruct arpreq *r,
 	if (mask && mask !=3D htonl(0xFFFFFFFF))
 		return -EINVAL;
 	if (!dev && (r->arp_flags & ATF_COM)) {
-		dev =3D dev_getbyhwaddr(net, r->arp_ha.sa_family,
+		dev =3D dev_getbyhwaddr_rcu(net, r->arp_ha.sa_family,
 				      r->arp_ha.sa_data);
 		if (!dev)
 			return -ENODEV;
@@ -1225,10 +1226,10 @@ int arp_ioctl(struct net *net, unsigned int cmd=
, void __user *arg)
 	if (!(r.arp_flags & ATF_NETMASK))
 		((struct sockaddr_in *)&r.arp_netmask)->sin_addr.s_addr =3D
 							   htonl(0xFFFFFFFFUL);
-	rtnl_lock();
+	rcu_read_lock();
 	if (r.arp_dev[0]) {
 		err =3D -ENODEV;
-		dev =3D __dev_get_by_name(net, r.arp_dev);
+		dev =3D dev_get_by_name_rcu(net, r.arp_dev);
 		if (dev =3D=3D NULL)
 			goto out;
=20
@@ -1252,12 +1253,12 @@ int arp_ioctl(struct net *net, unsigned int cmd=
, void __user *arg)
 		break;
 	case SIOCGARP:
 		err =3D arp_req_get(&r, dev);
-		if (!err && copy_to_user(arg, &r, sizeof(r)))
-			err =3D -EFAULT;
 		break;
 	}
 out:
-	rtnl_unlock();
+	rcu_read_unlock();
+	if (cmd =3D=3D SIOCGARP && !err && copy_to_user(arg, &r, sizeof(r)))
+		err =3D -EFAULT;
 	return err;
 }
=20
diff --git a/net/llc/af_llc.c b/net/llc/af_llc.c
index 5826129..dfd3a64 100644
--- a/net/llc/af_llc.c
+++ b/net/llc/af_llc.c
@@ -316,9 +316,9 @@ static int llc_ui_bind(struct socket *sock, struct =
sockaddr *uaddr, int addrlen)
 	if (unlikely(addr->sllc_family !=3D AF_LLC))
 		goto out;
 	rc =3D -ENODEV;
-	rtnl_lock();
+	rcu_read_lock();
 	if (sk->sk_bound_dev_if) {
-		llc->dev =3D dev_get_by_index(&init_net, sk->sk_bound_dev_if);
+		llc->dev =3D dev_get_by_index_rcu(&init_net, sk->sk_bound_dev_if);
 		if (llc->dev) {
 			if (!addr->sllc_arphrd)
 				addr->sllc_arphrd =3D llc->dev->type;
@@ -329,14 +329,15 @@ static int llc_ui_bind(struct socket *sock, struc=
t sockaddr *uaddr, int addrlen)
 			    !llc_mac_match(addr->sllc_mac,
 					   llc->dev->dev_addr)) {
 				rc =3D -EINVAL;
-				dev_put(llc->dev);
 				llc->dev =3D NULL;
 			}
 		}
 	} else
-		llc->dev =3D dev_getbyhwaddr(&init_net, addr->sllc_arphrd,
+		llc->dev =3D dev_getbyhwaddr_rcu(&init_net, addr->sllc_arphrd,
 					   addr->sllc_mac);
-	rtnl_unlock();
+	if (llc->dev)
+		dev_hold(llc->dev);
+	rcu_read_unlock();
 	if (!llc->dev)
 		goto out;
 	if (!addr->sllc_sap) {


