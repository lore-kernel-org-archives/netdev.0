From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] bonding: allow TSO being set on bonding master
Date: Wed, 15 May 2013 14:41:05 -0700
Message-ID: <1368654065.4519.53.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>, Jay Vosburgh <fubar@us.ibm.com>,
	Maciej =?UTF-8?Q?=C5=BBenczykowski?= <maze@google.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Tom Herbert <therbert@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f43.google.com ([209.85.160.43]:38660 "EHLO
	mail-pb0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751358Ab3EOVlI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 May 2013 17:41:08 -0400
Received: by mail-pb0-f43.google.com with SMTP id ma3so28458pbc.16
        for <netdev@vger.kernel.org>; Wed, 15 May 2013 14:41:07 -0700 (PDT)
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
Cc: Jay Vosburgh <fubar@us.ibm.com>
Cc: Andy Gospodarek <andy@greyhouse.net>
Cc: Maciej =C5=BBenczykowski <maze@google.com>
Cc: Tom Herbert <therbert@google.com>
Cc: Neal Cardwell <ncardwell@google.com>
Cc: Yuchung Cheng <ycheng@google.com>
---
 drivers/net/bonding/bond_main.c |    5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond=
_main.c
index d0aade0..b429bb8 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1362,6 +1362,11 @@ static netdev_features_t bond_fix_features(struc=
t net_device *dev,
 						     slave->dev->features,
 						     mask);
 	}
+	/* Allow TSO being used on bonding device :
+	 * Performing the GSO segmentation after bonding transmit
+	 * is a performance improvement.
+	 */
+	features |=3D mask & NETIF_F_ALL_TSO;
=20
 out:
 	read_unlock(&bond->lock);
