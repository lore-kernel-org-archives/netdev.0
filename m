From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 2/3] net: pass changed flags along with NETDEV_CHANGE event
Date: Tue, 28 May 2013 10:10:54 +0200
Message-ID: <1369728655-26649-3-git-send-email-jiri@resnulli.us>
References: <1369728655-26649-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, eric.dumazet@gmail.com, timo.teras@iki.fi,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, bhutchings@solarflare.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:43724 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933327Ab3E1ILG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 May 2013 04:11:06 -0400
Received: by mail-wi0-f181.google.com with SMTP id hi5so2200754wib.14
        for <netdev@vger.kernel.org>; Tue, 28 May 2013 01:11:04 -0700 (PDT)
In-Reply-To: <1369728655-26649-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use new netdevice notifier infrastructure to pass along changed flags.

Signed-off-by: Timo Ter=C3=A4s <timo.teras@iki.fi>
Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 include/linux/netdevice.h | 5 +++++
 net/core/dev.c            | 9 +++++++--
 2 files changed, 12 insertions(+), 2 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 153127b..38dae4f 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1602,6 +1602,11 @@ struct netdevice_notifier_info {
 	struct net_device *dev;
 };
=20
+struct netdevice_notifier_change_info {
+	struct netdevice_notifier_info info; /* must be first */
+	unsigned int flags_changed;
+};
+
 static inline struct net_device *
 get_netdevice_notifier_info_dev(const struct netdevice_notifier_info *=
info)
 {
diff --git a/net/core/dev.c b/net/core/dev.c
index 9a891e0..77f1653 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4778,8 +4778,13 @@ void __dev_notify_flags(struct net_device *dev, =
unsigned int old_flags)
 	}
=20
 	if (dev->flags & IFF_UP &&
-	    (changes & ~(IFF_UP | IFF_PROMISC | IFF_ALLMULTI | IFF_VOLATILE))=
)
-		call_netdevice_notifiers(NETDEV_CHANGE, dev);
+	    (changes & ~(IFF_UP | IFF_PROMISC | IFF_ALLMULTI | IFF_VOLATILE))=
) {
+		struct netdevice_notifier_change_info change_info;
+
+		change_info.flags_changed =3D changes;
+		call_netdevice_notifiers_info(NETDEV_CHANGE, dev,
+					      &change_info.info);
+	}
 }
=20
 /**
--=20
1.7.11.7
