From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] macvlan: add a salt to mc_hash()
Date: Thu, 07 Feb 2013 18:41:02 -0800
Message-ID: <1360291262.28557.89.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Maciej =?UTF-8?Q?=C5=BBenczykowski?= <maze@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f42.google.com ([209.85.219.42]:45368 "EHLO
	mail-oa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759207Ab3BHClG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Feb 2013 21:41:06 -0500
Received: by mail-oa0-f42.google.com with SMTP id i18so3612451oag.1
        for <netdev@vger.kernel.org>; Thu, 07 Feb 2013 18:41:04 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <edumazet@google.com>

Some multicast addresses are common to all macvlans,
so if a multicast message has a hash value collision, we
have to deliver a copy to all macvlans, adding significant
latency and possible packet drops if netdev_max_backlog
limit is hit.

Having a per macvlan hash function permits to reduce the
impact of hash collisions.

Suggested-by: Maciej =C5=BBenczykowski <maze@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
Should be applied after=20
  "macvlan: broadcast addr should be part of mc_filter"

 drivers/net/macvlan.c |   17 +++++++++++++----
 1 file changed, 13 insertions(+), 4 deletions(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index ce7c926..e4b8078 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -127,10 +127,18 @@ static int macvlan_broadcast_one(struct sk_buff *=
skb,
 	return vlan->receive(skb);
 }
=20
-static unsigned int mc_hash(const unsigned char *addr)
+static u32 macvlan_hash_mix(const struct macvlan_dev *vlan)
+{
+	return (u32)(((unsigned long)vlan) >> L1_CACHE_SHIFT);
+}
+
+
+static unsigned int mc_hash(const struct macvlan_dev *vlan,
+			    const unsigned char *addr)
 {
 	u32 val =3D __get_unaligned_cpu32(addr + 2);
=20
+	val ^=3D macvlan_hash_mix(vlan);
 	return hash_32(val, MACVLAN_MC_FILTER_BITS);
 }
=20
@@ -145,7 +153,7 @@ static void macvlan_broadcast(struct sk_buff *skb,
 	struct sk_buff *nskb;
 	unsigned int i;
 	int err;
-	unsigned int hash =3D mc_hash(eth->h_dest);
+	unsigned int hash;
=20
 	if (skb->protocol =3D=3D htons(ETH_P_PAUSE))
 		return;
@@ -155,6 +163,7 @@ static void macvlan_broadcast(struct sk_buff *skb,
 			if (vlan->dev =3D=3D src || !(vlan->mode & mode))
 				continue;
=20
+			hash =3D mc_hash(vlan, eth->h_dest);
 			if (!test_bit(hash, vlan->mc_filter))
 				continue;
 			nskb =3D skb_clone(skb, GFP_ATOMIC);
@@ -424,10 +433,10 @@ static void macvlan_set_mac_lists(struct net_devi=
ce *dev)
=20
 		bitmap_zero(filter, MACVLAN_MC_FILTER_SZ);
 		netdev_for_each_mc_addr(ha, dev) {
-			__set_bit(mc_hash(ha->addr), filter);
+			__set_bit(mc_hash(vlan, ha->addr), filter);
 		}
=20
-		__set_bit(mc_hash(dev->broadcast), filter);
+		__set_bit(mc_hash(vlan, dev->broadcast), filter);
=20
 		bitmap_copy(vlan->mc_filter, filter, MACVLAN_MC_FILTER_SZ);
 	}
