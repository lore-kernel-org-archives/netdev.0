From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v2] bonding: allow TSO being set on bonding master
Date: Thu, 16 May 2013 10:34:53 -0700
Message-ID: <1368725693.3301.59.camel@edumazet-glaptop>
References: <1368654065.4519.53.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>, Jay Vosburgh <fubar@us.ibm.com>,
	Maciej =?UTF-8?Q?=C5=BBenczykowski?= <maze@google.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Tom Herbert <therbert@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: David Miller <davem@davemloft.net>,
	=?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirqus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:60186 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753225Ab3EPRe5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 May 2013 13:34:57 -0400
Received: by mail-pd0-f179.google.com with SMTP id q10so2538397pdj.38
        for <netdev@vger.kernel.org>; Thu, 16 May 2013 10:34:56 -0700 (PDT)
In-Reply-To: <1368654065.4519.53.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <edumazet@google.com>

In some situations, we need to disable TSO on bonding slaves.

bonding device automatically unset TSO in bond_fix_features(), and
performance is not good because :

1) We consume more cpu cycles.

2) GSO segmentation has some bugs leading to out of order TCP packets
if this segmentation is done before virtual device. This particular
problem will be addressed in a separate patch.

This patch allows TSO being set/unset on the bonding master,
so that GSO segmentation is done after bonding layer.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Micha=C5=82 Miros=C5=82aw <mirqus@gmail.com>
Cc: Jay Vosburgh <fubar@us.ibm.com>
Cc: Andy Gospodarek <andy@greyhouse.net>
Cc: Maciej =C5=BBenczykowski <maze@google.com>
Cc: Tom Herbert <therbert@google.com>
Cc: Neal Cardwell <ncardwell@google.com>
Cc: Yuchung Cheng <ycheng@google.com>
---
v2: add a documented helper so that team/bridge can use it

 drivers/net/bonding/bond_main.c |    1 +
 include/linux/netdevice.h       |   11 +++++++++++
 2 files changed, 12 insertions(+)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond=
_main.c
index d0aade0..449ad9b 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1362,6 +1362,7 @@ static netdev_features_t bond_fix_features(struct=
 net_device *dev,
 						     slave->dev->features,
 						     mask);
 	}
+	features =3D netdev_add_tso_features(features, mask);
=20
 out:
 	read_unlock(&bond->lock);
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index a94a5a0..095945c 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2733,6 +2733,17 @@ static inline netdev_features_t netdev_get_wante=
d_features(
 }
 netdev_features_t netdev_increment_features(netdev_features_t all,
 	netdev_features_t one, netdev_features_t mask);
+
+/* Allow TSO being used on stacked device :
+ * Performing the GSO segmentation before last device
+ * is a performance improvement.
+ */
+static inline netdev_features_t netdev_add_tso_features(netdev_feature=
s_t features,
+	netdev_features_t mask)
+{
+	return netdev_increment_features(features, NETIF_F_ALL_TSO, mask);
+}
+
 int __netdev_update_features(struct net_device *dev);
 void netdev_update_features(struct net_device *dev);
 void netdev_change_features(struct net_device *dev);
