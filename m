From: =?UTF-8?q?Timo=20Ter=C3=A4s?= <timo.teras@iki.fi>
Subject: [PATCH v2 net-next] arp: flush arp cache on IFF_NOARP change
Date: Tue, 21 May 2013 13:23:44 +0300
Message-ID: <1369131824-6318-1-git-send-email-timo.teras@iki.fi>
References: <20130520.134633.448574202175922639.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Timo=20Ter=C3=A4s?= <timo.teras@iki.fi>
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f48.google.com ([74.125.83.48]:38218 "EHLO
	mail-ee0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752655Ab3EUKWy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 May 2013 06:22:54 -0400
Received: by mail-ee0-f48.google.com with SMTP id b47so274890eek.7
        for <netdev@vger.kernel.org>; Tue, 21 May 2013 03:22:53 -0700 (PDT)
In-Reply-To: <20130520.134633.448574202175922639.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IFF_NOARP affects what kind of neighbor entries are created
(nud NOARP or nud INCOMPLETE). If the flag changes, flush the arp
cache to refresh all entries.

Signed-off-by: Timo Ter=C3=A4s <timo.teras@iki.fi>
---
> This patch makes no sense at all.
>=20
> The state bit in ->priv_flags is a boolean stating whether the
> notified should do something or not.
>=20
> But you're setting it to match what IFF_NOARP is.
>
> You should set it any time IFF_NOARP _changes_, and then clear
> the bit when the notifier clears the neighbour entries.

IFF_NOARP_CHANGED is set according to "changes =3D dev->flags ^ old_fla=
gs;"
which reflect the change. But I agree that the clearing out bit was
misplaced. This is especially true as it seems NETDEV_CHANGE can be
notified from another place too.

I've updated the if.h comment to state that the bit is valid only durin=
g
NETDEV_CHANGE notifier. And __dev_notify_flags is updated to always cle=
ar
the bit after notifiers are done.

 include/uapi/linux/if.h | 2 ++
 net/core/dev.c          | 6 +++++-
 net/ipv4/arp.c          | 4 ++++
 3 files changed, 11 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/if.h b/include/uapi/linux/if.h
index 1ec407b..1be8b35 100644
--- a/include/uapi/linux/if.h
+++ b/include/uapi/linux/if.h
@@ -83,6 +83,8 @@
 #define IFF_SUPP_NOFCS	0x80000		/* device supports sending custom FCS =
*/
 #define IFF_LIVE_ADDR_CHANGE 0x100000	/* device supports hardware addr=
ess
 					 * change when it's running */
+#define IFF_NOARP_CHANGED 0x200000	/* Set during NETDEV_CHANGE notifie=
r
+					 * if IFF_NOARP has changed */
=20
=20
 #define IF_GET_IFACE	0x0001		/* for querying only */
diff --git a/net/core/dev.c b/net/core/dev.c
index 18e9730..ce30761 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4699,8 +4699,12 @@ void __dev_notify_flags(struct net_device *dev, =
unsigned int old_flags)
 	}
=20
 	if (dev->flags & IFF_UP &&
-	    (changes & ~(IFF_UP | IFF_PROMISC | IFF_ALLMULTI | IFF_VOLATILE))=
)
+	    (changes & ~(IFF_UP | IFF_PROMISC | IFF_ALLMULTI | IFF_VOLATILE))=
) {
+		if (changes & IFF_NOARP)
+			dev->priv_flags |=3D IFF_NOARP_CHANGED;
 		call_netdevice_notifiers(NETDEV_CHANGE, dev);
+		dev->priv_flags &=3D ~IFF_NOARP_CHANGED;
+	}
 }
=20
 /**
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
