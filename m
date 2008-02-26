From: =?ISO-8859-1?Q?St=E9phane_BERTHELOT?= <sberthelot@emisfr.com>
Subject: via-velocity netpoll enable (patch proposal)
Date: Wed, 27 Feb 2008 00:08:44 +0100
Message-ID: <47C49BFC.5040102@emisfr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smith.emisfr.net ([88.191.19.17]:33829 "EHLO smith.emisfr.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751681AbYBZXhi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Feb 2008 18:37:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello all,

I tried to use netconsole on via-velocity hardware to get some dmesg=20
remotely.
Surprisingly the current driver does not seem to have netpoll function =
code.

I had a look at how it is done in 8139cp and tg3 and borrowed some line=
s=20
to make a patch for via-velocity.
Though I tested it for some time, I didn't put the hardware at stress=20
especially with high number of netpoll packets.
I am no expert of the via-velocity hardware so I don't know if disablin=
g=20
interrupts is necessary, but it works for me this way and netconsole is=
=20
happy and didn't crash yet...


--- via-velocity.c.orig    2008-02-26 23:47:42.000000000 +0100
+++ via-velocity.c    2008-02-23 10:58:58.000000000 +0100
@@ -378,6 +379,9 @@
 static int velocity_change_mtu(struct net_device *dev, int mtu);
 static int velocity_xmit(struct sk_buff *skb, struct net_device *dev);
 static int velocity_intr(int irq, void *dev_instance);
+#ifdef CONFIG_NET_POLL_CONTROLLER
+static void velocity_poll_controller(struct net_device *dev);
+#endif
 static void velocity_set_multi(struct net_device *dev);
 static struct net_device_stats *velocity_get_stats(struct net_device *=
dev);
 static int velocity_ioctl(struct net_device *dev, struct ifreq *rq, in=
t=20
cmd);
@@ -955,6 +959,9 @@
     dev->set_multicast_list =3D velocity_set_multi;
     dev->do_ioctl =3D velocity_ioctl;
     dev->ethtool_ops =3D &velocity_ethtool_ops;
+#ifdef CONFIG_NET_POLL_CONTROLLER
+        dev->poll_controller =3D velocity_poll_controller;
+#endif
     dev->change_mtu =3D velocity_change_mtu;
=20
     dev->vlan_rx_add_vid =3D velocity_vlan_rx_add_vid;
@@ -2252,6 +2264,18 @@
=20
 }
=20
+#ifdef CONFIG_NET_POLL_CONTROLLER
+/*
+ * Polling receive - used by netconsole and other diagnostic tools
+ * to allow network i/o with interrupts disabled.
+ */
+static void velocity_poll_controller(struct net_device *dev)
+{
+  disable_irq(dev->irq);
+  velocity_intr(dev->irq, dev);
+  enable_irq(dev->irq);
+}
+#endif
=20
 /**
  *    velocity_set_multi    -    filter list change callback

--=20
St=E9phane BERTHELOT
EmisFR
- R=E9seau : S=E9curit=E9 et Serveurs , D=E9veloppements m=E9tier et sp=
=E9cifiques -
10 rue Mazagran, 54000 NANCY, France
http://www.emisfr.com
Tel/Fax. 03 83 32 25 75

