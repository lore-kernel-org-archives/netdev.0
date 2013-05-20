From: =?UTF-8?q?Timo=20Ter=C3=A4s?= <timo.teras@iki.fi>
Subject: [PATCH net-next] arp: flush arp cache on IFF_NOARP change
Date: Mon, 20 May 2013 16:29:01 +0300
Message-ID: <1369056541-4523-1-git-send-email-timo.teras@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Timo=20Ter=C3=A4s?= <timo.teras@iki.fi>,
	Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f54.google.com ([74.125.83.54]:48525 "EHLO
	mail-ee0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756478Ab3ETN1h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 May 2013 09:27:37 -0400
Received: by mail-ee0-f54.google.com with SMTP id e50so4094462eek.13
        for <netdev@vger.kernel.org>; Mon, 20 May 2013 06:27:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IFF_NOARP affects what kind of neighbor entries are created
(nud NOARP or nud INCOMPLETE). If the flag changes, flush the arp
cache to refresh all entries.

Signed-off-by: Timo Ter=C3=A4s <timo.teras@iki.fi>
Cc: Patrick McHardy <kaber@trash.net>
---
Original patch sent some years ago and the review is at:
 http://patchwork.ozlabs.org/patch/46806/

This is updated per Patrick's suggestion to use priv_flags as the
place to notify that NOARP flag changed.

 include/uapi/linux/if.h | 1 +
 net/core/dev.c          | 5 +++++
 net/ipv4/arp.c          | 4 ++++
 3 files changed, 10 insertions(+)

diff --git a/include/uapi/linux/if.h b/include/uapi/linux/if.h
index 1ec407b..ace4aec 100644
--- a/include/uapi/linux/if.h
+++ b/include/uapi/linux/if.h
@@ -83,6 +83,7 @@
 #define IFF_SUPP_NOFCS	0x80000		/* device supports sending custom FCS =
*/
 #define IFF_LIVE_ADDR_CHANGE 0x100000	/* device supports hardware addr=
ess
 					 * change when it's running */
+#define IFF_NOARP_CHANGED 0x200000	/* IFF_NOARP changed state recently=
 */
=20
=20
 #define IF_GET_IFACE	0x0001		/* for querying only */
diff --git a/net/core/dev.c b/net/core/dev.c
index 18e9730..7135fe1 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4691,6 +4691,11 @@ void __dev_notify_flags(struct net_device *dev, =
unsigned int old_flags)
 {
 	unsigned int changes =3D dev->flags ^ old_flags;
=20
+	if (changes & IFF_NOARP)
+		dev->priv_flags |=3D IFF_NOARP_CHANGED;
+	else
+		dev->priv_flags &=3D ~IFF_NOARP_CHANGED;
+
 	if (changes & IFF_UP) {
 		if (dev->flags & IFF_UP)
 			call_netdevice_notifiers(NETDEV_UP, dev);
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index 247ec19..375b2f2 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -1241,6 +1241,10 @@ static int arp_netdev_event(struct notifier_bloc=
k *this, unsigned long event,
 		neigh_changeaddr(&arp_tbl, dev);
 		rt_cache_flush(dev_net(dev));
 		break;
+	case NETDEV_CHANGE:
+		if (dev->priv_flags & IFF_NOARP_CHANGED)
+			neigh_changeaddr(&arp_tbl, dev);
+		break;
 	default:
 		break;
 	}
--=20
1.8.2.3
