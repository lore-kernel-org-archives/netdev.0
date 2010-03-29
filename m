From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: linux-next: build failure after merge of the final tree (net
 tree related)
Date: Mon, 29 Mar 2010 08:59:30 +0200
Message-ID: <1269845970.2164.4.camel@edumazet-laptop>
References: <20100329174300.512d83a8.sfr@canb.auug.org.au>
	 <1269845561.2164.1.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Tom Herbert <therbert@google.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <1269845561.2164.1.camel@edumazet-laptop>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Stephen Rothwell <sfr@canb.auug.org.au>

Le lundi 29 mars 2010 =C3=A0 08:52 +0200, Eric Dumazet a =C3=A9crit :
> Le lundi 29 mars 2010 =C3=A0 17:43 +1100, Stephen Rothwell a =C3=A9cr=
it :
> > Hi Dave,
> >=20
> > After merging the final tree, today's linux-next build (powerpc
> > ppc44x_defconfig) failed like this:
> >=20
> > net/core/net-sysfs.c:476: warning: 'struct netdev_rx_queue' declare=
d inside parameter list
> > net/core/net-sysfs.c:476: warning: its scope is only this definitio=
n or declaration, which is probably not what you want
> > net/core/net-sysfs.c:478: warning: 'struct netdev_rx_queue' declare=
d inside parameter list
> > net/core/net-sysfs.c: In function 'rx_queue_attr_show':
> > net/core/net-sysfs.c:489: error: dereferencing pointer to incomplet=
e type
> > net/core/net-sysfs.c:489: warning: type defaults to 'int' in declar=
ation of '__mptr'
> > net/core/net-sysfs.c:489: warning: initialization from incompatible=
 pointer type
> > net/core/net-sysfs.c:489: error: invalid use of undefined type 'str=
uct netdev_rx_queue'
> > net/core/net-sysfs.c:494: warning: passing argument 1 of 'attribute=
->show' from incompatible pointer type
> > net/core/net-sysfs.c:494: note: expected 'struct netdev_rx_queue *'=
 but argument is of type 'struct netdev_rx_queue *'
> >=20
> > (and many more)
> >=20
> > Caused by commit 0a9627f2649a02bea165cfd529d7bcb625c2fcad ("rps: Re=
ceive
> > Packet Steering") from the net tree.  struct netdev_rx_queue is pro=
tected by
> > CONFIG_RPS in netdevice.h, but uses are not so protected in net-sys=
fs.c.
> >=20
> > I applied the following patch for today:
> >=20
> > From: Stephen Rothwell <sfr@canb.auug.org.au>
> > Date: Mon, 29 Mar 2010 17:27:55 +1100
> > Subject: [PATCH] rps: fix net-sysfs build for !CONFIG_RPS
> >=20
> > Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>

Oops, a cleaner patch would be :

[PATCH] rps: fix net-sysfs build for !CONFIG_RPS

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index f6b6bfe..2144a7f 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -466,6 +466,7 @@ static struct attribute_group wireless_group =3D {
 };
 #endif
=20
+#ifdef CONFIG_RPS
 /*
  * RX queue sysfs structures and functions.
  */
@@ -675,7 +676,7 @@ static void rx_queue_remove_kobjects(struct net_dev=
ice *net)
 		kobject_put(&net->_rx[i].kobj);
 	kset_unregister(net->queues_kset);
 }
-
+#endif /* CONFIG_RPS */
 #endif /* CONFIG_SYSFS */
=20
 #ifdef CONFIG_HOTPLUG
@@ -739,7 +740,7 @@ void netdev_unregister_kobject(struct net_device * =
net)
 	if (!net_eq(dev_net(net), &init_net))
 		return;
=20
-#ifdef CONFIG_SYSFS
+#ifdef CONFIG_RPS
 	rx_queue_remove_kobjects(net);
 #endif
=20
@@ -782,7 +783,7 @@ int netdev_register_kobject(struct net_device *net)
 	if (error)
 		return error;
=20
-#ifdef CONFIG_SYSFS
+#ifdef CONFIG_RPS
 	error =3D rx_queue_register_kobjects(net);
 	if (error) {
 		device_del(dev);
