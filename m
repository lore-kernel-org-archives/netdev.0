From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: Dont use netdev_warn()
Date: Fri, 09 Apr 2010 10:13:02 +0200
Message-ID: <1270800782.2623.49.camel@edumazet-laptop>
References: <1270797973.2623.28.camel@edumazet-laptop>
	 <1270799606.19154.71.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:38958 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756470Ab0DIINI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Apr 2010 04:13:08 -0400
Received: by bwz1 with SMTP id 1so2338678bwz.21
        for <netdev@vger.kernel.org>; Fri, 09 Apr 2010 01:13:06 -0700 (PDT)
In-Reply-To: <1270799606.19154.71.camel@Joe-Laptop.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 09 avril 2010 =C3=A0 00:53 -0700, Joe Perches a =C3=A9crit =
:
> On Fri, 2010-04-09 at 09:26 +0200, Eric Dumazet wrote:
> > Dont use netdev_warn() in dev_cap_txqueue() and get_rps_cpu() so th=
at we
> > can catch following warnings without crash.
>=20
> Crash?  Can you describe the crash a bit please.
>=20
> > bond0.2240 received packet on queue 6, but number of RX queues is 1
> > bond0.2240 received packet on queue 11, but number of RX queues is =
1
>=20
> Bond0 doesn't have a valid (netdev)->dev.parent?
>=20
> 	dev_printk(level, (netdev)->dev.parent,			\
>=20
> Maybe there should be some additional check on
> netdev->dev.parent.
>=20
>=20

CC again original CC, no need to have a private conversation about this
Joe...


Yes, bonding have a NULL dev->dev.parent, I suspect other virtual
network device also have this property.


You can see in following patch Arjan's intent, and the difference
between :

dev->name and netdev_drivername(dev, drivername, 64))


commit 6579e57b31d79d31d9b806e41ba48774e73257dc
Author: Arjan van de Ven <arjan@linux.intel.com>
Date:   Mon Jul 21 13:31:48 2008 -0700

    net: Print the module name as part of the watchdog message
   =20
    As suggested by Dave:
   =20
    This patch adds a function to get the driver name from a struct net=
_device,
    and consequently uses this in the watchdog timeout handler to print=
 as
    part of the message.
   =20
    Signed-off-by: Arjan van de Ven <arjan@linux.intel.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 812bcd8..f5ea445 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1645,6 +1645,8 @@ extern void dev_seq_stop(struct seq_file *seq, vo=
id *v);
 extern int netdev_class_create_file(struct class_attribute *class_attr=
);
 extern void netdev_class_remove_file(struct class_attribute *class_att=
r);
=20
+extern char *netdev_drivername(struct net_device *dev, char *buffer, i=
nt len);
+
 extern void linkwatch_run_queue(void);
=20
 extern int netdev_compute_features(unsigned long all, unsigned long on=
e);
diff --git a/net/core/dev.c b/net/core/dev.c
index 1698b39..ad5598d 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4686,6 +4686,26 @@ err_name:
        return -ENOMEM;
 }
=20
+char *netdev_drivername(struct net_device *dev, char *buffer, int len)
+{
+       struct device_driver *driver;
+       struct device *parent;
+
+       if (len <=3D 0 || !buffer)
+               return buffer;
+       buffer[0] =3D 0;
+
+       parent =3D dev->dev.parent;
+
+       if (!parent)
+               return buffer;
+
+       driver =3D parent->driver;
+       if (driver && driver->name)
+               strlcpy(buffer, driver->name, len);
+       return buffer;
+}
+
 static void __net_exit netdev_exit(struct net *net)
 {
        kfree(net->dev_name_head);
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index cb625b4..4ac7e3a 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -212,9 +212,9 @@ static void dev_watchdog(unsigned long arg)
                        if (some_queue_stopped &&
                            time_after(jiffies, (dev->trans_start +
                                                 dev->watchdog_timeo)))=
 {
-                               printk(KERN_INFO "NETDEV WATCHDOG: %s: =
"
-                                      "transmit timed out\n",
-                                      dev->name);
+                               char drivername[64];
+                               printk(KERN_INFO "NETDEV WATCHDOG: %s (=
%s): transmit timed out\n",
+                                      dev->name, netdev_drivername(dev=
, drivername, 64));
                                dev->tx_timeout(dev);
                                WARN_ON_ONCE(1);
                        }



