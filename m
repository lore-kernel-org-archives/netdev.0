From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH] net/core: use netdev name in warning if no parent
Date: Mon, 16 Nov 2015 19:16:40 +0100
Message-ID: <1447697800-6959-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:33041 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751300AbbKPSQq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Nov 2015 13:16:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A recent flaw in the netdev feature setting resulted in warnings
like this one from VLAN interfaces:

 WARNING: CPU: 1 PID: 4975 at net/core/dev.c:2419 skb_warn_bad_offload+=
0xbc/0xcb()
 : caps=3D(0x00000000001b5820, 0x00000000001b5829) len=3D2782 data_len=3D=
0 gso_size=3D1348 gso_type=3D16 ip_summed=3D3

The ":" is supposed to be preceded by a driver name, but in this
case it is an empty string since the device has no parent.

There are many types of network devices without a parent. The
anonymous warnings for these devices can be hard to debug.  Log
the network device name instead in these cases to assist further
debugging.

This is mostly similar to how __netdev_printk() handles orphan
devices.

Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
 net/core/dev.c | 13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index ab9b8d0d115e..4dbf7ae6f8b5 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2403,17 +2403,20 @@ static void skb_warn_bad_offload(const struct s=
k_buff *skb)
 {
 	static const netdev_features_t null_features =3D 0;
 	struct net_device *dev =3D skb->dev;
-	const char *driver =3D "";
+	const char *name =3D "";
=20
 	if (!net_ratelimit())
 		return;
=20
-	if (dev && dev->dev.parent)
-		driver =3D dev_driver_string(dev->dev.parent);
-
+	if (dev) {
+		if (dev->dev.parent)
+			name =3D dev_driver_string(dev->dev.parent);
+		else
+			name =3D netdev_name(dev);
+	}
 	WARN(1, "%s: caps=3D(%pNF, %pNF) len=3D%d data_len=3D%d gso_size=3D%d=
 "
 	     "gso_type=3D%d ip_summed=3D%d\n",
-	     driver, dev ? &dev->features : &null_features,
+	     name, dev ? &dev->features : &null_features,
 	     skb->sk ? &skb->sk->sk_route_caps : &null_features,
 	     skb->len, skb->data_len, skb_shinfo(skb)->gso_size,
 	     skb_shinfo(skb)->gso_type, skb->ip_summed);
--=20
2.1.4
