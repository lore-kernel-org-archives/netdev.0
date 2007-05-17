From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [FIX][PATCH] ipv6 addrconf.c REMOVED #if patch
Date: Thu, 17 May 2007 23:10:16 +0200
Message-ID: <464CC4B8.6040401@hartkopp.net>
References: <464C886F.50703@hartkopp.net> <20070518.024940.120305926.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: =?UTF-8?B?WU9TSElGVUpJIEhpZGVha2kgLyDlkInol6Toi7HmmI4=?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.162]:18301 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754417AbXEQVKh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 May 2007 17:10:37 -0400
In-Reply-To: <20070518.024940.120305926.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E wrote:
> Please remove #if, or please provide for other
> dependencies as well (e.g., CONFIG_IPV6_TUNNEL etc.)
>
> Otherwise, I would agree.
>
>  =20
Yep - you were right. It looks better like this as ARPHRD_SIT is define=
d=20
in if_arp.h in any CONFIG_* case ...

Best regards & tnx,
Oliver


--- linux-2.6.21/net/ipv6/addrconf.c.orig    2007-05-18=20
00:54:54.000000000 +0200
+++ linux-2.6.21/net/ipv6/addrconf.c    2007-05-18 00:57:11.000000000 +=
0200
@@ -2076,15 +2076,6 @@ static void addrconf_dev_config(struct n
=20
     ASSERT_RTNL();
=20
-    if ((dev->type !=3D ARPHRD_ETHER) &&
-        (dev->type !=3D ARPHRD_FDDI) &&
-        (dev->type !=3D ARPHRD_IEEE802_TR) &&
-        (dev->type !=3D ARPHRD_ARCNET) &&
-        (dev->type !=3D ARPHRD_INFINIBAND)) {
-        /* Alas, we support only Ethernet autoconfiguration. */
-        return;
-    }
-
     idev =3D addrconf_add_dev(dev);
     if (idev =3D=3D NULL)
         return;
@@ -2172,13 +2163,33 @@ static void addrconf_ip6_tnl_config(stru
     ip6_tnl_add_linklocal(idev);
 }
=20
+static int ipv6_hwtype(struct net_device *dev)
+{
+    if ((dev->type =3D=3D ARPHRD_ETHER) ||
+        (dev->type =3D=3D ARPHRD_LOOPBACK) ||
+        (dev->type =3D=3D ARPHRD_SIT) ||
+        (dev->type =3D=3D ARPHRD_TUNNEL6) ||
+        (dev->type =3D=3D ARPHRD_FDDI) ||
+        (dev->type =3D=3D ARPHRD_IEEE802_TR) ||
+        (dev->type =3D=3D ARPHRD_ARCNET) ||
+        (dev->type =3D=3D ARPHRD_INFINIBAND))
+        return 1;
+
+    return 0;
+}
+
 static int addrconf_notify(struct notifier_block *this, unsigned long=20
event,
                void * data)
 {
     struct net_device *dev =3D (struct net_device *) data;
-    struct inet6_dev *idev =3D __in6_dev_get(dev);
+    struct inet6_dev *idev;
     int run_pending =3D 0;
=20
+    if (!ipv6_hwtype(dev))
+        return NOTIFY_OK;
+
+    idev =3D __in6_dev_get(dev);
+
     switch(event) {
     case NETDEV_REGISTER:
         if (!idev) {



