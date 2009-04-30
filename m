From: Bruno =?UTF-8?B?UHLDqW1vbnQ=?= <bonbons@linux-vserver.org>
Subject: Re: [PATCH, resend] netconsole: take care of NETDEV_UNREGISTER
 event
Date: Thu, 30 Apr 2009 08:45:17 +0200
Message-ID: <20090430084517.6de15689@pluto.restena.lu>
References: <20090429223722.62da9dcd@neptune.home>
	<20090429225625.75a016ff@neptune.home>
	<20090429.144420.262432582.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [158.64.110.167] ([158.64.110.167]:39992 "EHLO
	bonbons.gotdns.org" rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1751206AbZD3Gz3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Apr 2009 02:55:29 -0400
In-Reply-To: <20090429.144420.262432582.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When netconsole is loaded and a network interface fades away (e.g. on
rmmod $interface_driver_module) the rmmod remains stuck and some locks
are taken that prevent any additional module loading/unloading as well
as interface up/down changes.
In addition kernel logs (and console) get flooded at 10s interval with

[  122.464065] unregister_netdevice: waiting for eth0 to become free. U=
sage count =3D 1
[  132.704059] unregister_netdevice: waiting for eth0 to become free. U=
sage count =3D 1

This patch lets netconsole take NETDEV_UNREGISTER event into account
and release the affected interface if it was in use.

Signed-off-by: Bruno Pr=C3=A9mont <bonbons@linux-vserver.org>
---
diff --git a/drivers/net/netconsole.c b/drivers/net/netconsole.c
index eceadf7..bf4af52 100644
--- a/drivers/net/netconsole.c
+++ b/drivers/net/netconsole.c
@@ -664,7 +664,7 @@ static int netconsole_netdev_event(struct notifier_=
block *this,
 	struct netconsole_target *nt;
 	struct net_device *dev =3D ptr;
=20
-	if (!(event =3D=3D NETDEV_CHANGENAME))
+	if (!(event =3D=3D NETDEV_CHANGENAME || event =3D=3D NETDEV_UNREGISTE=
R))
 		goto done;
=20
 	spin_lock_irqsave(&target_list_lock, flags);
@@ -675,6 +675,15 @@ static int netconsole_netdev_event(struct notifier=
_block *this,
 			case NETDEV_CHANGENAME:
 				strlcpy(nt->np.dev_name, dev->name, IFNAMSIZ);
 				break;
+			case NETDEV_UNREGISTER:
+				if (!nt->enabled)
+					break;
+				netpoll_cleanup(&nt->np);
+				nt->enabled =3D 0;
+				printk(KERN_INFO "netconsole: network logging stopped"
+					", interface %s unregistered\n",
+					dev->name);
+				break;
 			}
 		}
 		netconsole_target_put(nt);
