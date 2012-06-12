From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] bonding: remove packet cloning in recv_probe()
Date: Tue, 12 Jun 2012 07:23:07 +0200
Message-ID: <1339478587.22704.16.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>, Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Jiri Bohac <jbohac@suse.cz>,
	Nicolas de =?ISO-8859-1?Q?Peslo=FCan?=
	<nicolas.2p.debian@free.fr>,
	Maciej =?UTF-8?Q?=C5=BBenczykowski?= <maze@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:41425 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752348Ab2FLFXN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jun 2012 01:23:13 -0400
Received: by eaak11 with SMTP id k11so2030607eaa.19
        for <netdev@vger.kernel.org>; Mon, 11 Jun 2012 22:23:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <edumazet@google.com>

Cloning all packets in input path have a significant cost.

Use skb_header_pointer()/skb_copy_bits() instead of pskb_may_pull() so
that recv_probe handlers (bond_3ad_lacpdu_recv / bond_arp_rcv /
rlb_arp_recv ) dont touch input skb.

bond_handle_frame() can avoid the skb_clone()/dev_kfree_skb()

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Jay Vosburgh <fubar@us.ibm.com>
Cc: Andy Gospodarek <andy@greyhouse.net>
Cc: Jiri Bohac <jbohac@suse.cz>
Cc: Nicolas de Peslo=C3=BCan <nicolas.2p.debian@free.fr>
Cc: Maciej =C5=BBenczykowski <maze@google.com>
---
 drivers/net/bonding/bond_3ad.c  |   11 +++++---
 drivers/net/bonding/bond_3ad.h  |    4 +--
 drivers/net/bonding/bond_alb.c  |   20 ++++------------
 drivers/net/bonding/bond_main.c |   37 ++++++++++++++++--------------
 drivers/net/bonding/bonding.h   |    4 +--
 5 files changed, 36 insertions(+), 40 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_=
3ad.c
index 3463b46..3031e04 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -2460,18 +2460,21 @@ out:
 	return NETDEV_TX_OK;
 }
=20
-int bond_3ad_lacpdu_recv(struct sk_buff *skb, struct bonding *bond,
-			  struct slave *slave)
+int bond_3ad_lacpdu_recv(const struct sk_buff *skb, struct bonding *bo=
nd,
+			 struct slave *slave)
 {
 	int ret =3D RX_HANDLER_ANOTHER;
+	struct lacpdu *lacpdu, _lacpdu;
+
 	if (skb->protocol !=3D PKT_TYPE_LACPDU)
 		return ret;
=20
-	if (!pskb_may_pull(skb, sizeof(struct lacpdu)))
+	lacpdu =3D skb_header_pointer(skb, 0, sizeof(_lacpdu), &_lacpdu);
+	if (!lacpdu)
 		return ret;
=20
 	read_lock(&bond->lock);
-	ret =3D bond_3ad_rx_indication((struct lacpdu *) skb->data, slave, sk=
b->len);
+	ret =3D bond_3ad_rx_indication(lacpdu, slave, skb->len);
 	read_unlock(&bond->lock);
 	return ret;
 }
diff --git a/drivers/net/bonding/bond_3ad.h b/drivers/net/bonding/bond_=
3ad.h
index 5ee7e3c..0cfaa4a 100644
--- a/drivers/net/bonding/bond_3ad.h
+++ b/drivers/net/bonding/bond_3ad.h
@@ -274,8 +274,8 @@ void bond_3ad_adapter_duplex_changed(struct slave *=
slave);
 void bond_3ad_handle_link_change(struct slave *slave, char link);
 int  bond_3ad_get_active_agg_info(struct bonding *bond, struct ad_info=
 *ad_info);
 int bond_3ad_xmit_xor(struct sk_buff *skb, struct net_device *dev);
-int bond_3ad_lacpdu_recv(struct sk_buff *skb, struct bonding *bond,
-			  struct slave *slave);
+int bond_3ad_lacpdu_recv(const struct sk_buff *skb, struct bonding *bo=
nd,
+			 struct slave *slave);
 int bond_3ad_set_carrier(struct bonding *bond);
 void bond_3ad_update_lacp_rate(struct bonding *bond);
 #endif //__BOND_3AD_H__
diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_=
alb.c
index 0f59c15..ef3791a 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -342,27 +342,17 @@ static void rlb_update_entry_from_arp(struct bond=
ing *bond, struct arp_pkt *arp)
 	_unlock_rx_hashtbl_bh(bond);
 }
=20
-static int rlb_arp_recv(struct sk_buff *skb, struct bonding *bond,
-			 struct slave *slave)
+static int rlb_arp_recv(const struct sk_buff *skb, struct bonding *bon=
d,
+			struct slave *slave)
 {
-	struct arp_pkt *arp;
+	struct arp_pkt *arp, _arp;
=20
 	if (skb->protocol !=3D cpu_to_be16(ETH_P_ARP))
 		goto out;
=20
-	arp =3D (struct arp_pkt *) skb->data;
-	if (!arp) {
-		pr_debug("Packet has no ARP data\n");
+	arp =3D skb_header_pointer(skb, 0, sizeof(_arp), &_arp);
+	if (!arp)
 		goto out;
-	}
-
-	if (!pskb_may_pull(skb, arp_hdr_len(bond->dev)))
-		goto out;
-
-	if (skb->len < sizeof(struct arp_pkt)) {
-		pr_debug("Packet is too small to be an ARP\n");
-		goto out;
-	}
=20
 	if (arp->op_code =3D=3D htons(ARPOP_REPLY)) {
 		/* update rx hash table for this ARP */
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond=
_main.c
index 2ee8cf9..9e2301e 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1444,8 +1444,8 @@ static rx_handler_result_t bond_handle_frame(stru=
ct sk_buff **pskb)
 	struct sk_buff *skb =3D *pskb;
 	struct slave *slave;
 	struct bonding *bond;
-	int (*recv_probe)(struct sk_buff *, struct bonding *,
-				struct slave *);
+	int (*recv_probe)(const struct sk_buff *, struct bonding *,
+			  struct slave *);
 	int ret =3D RX_HANDLER_ANOTHER;
=20
 	skb =3D skb_share_check(skb, GFP_ATOMIC);
@@ -1462,15 +1462,10 @@ static rx_handler_result_t bond_handle_frame(st=
ruct sk_buff **pskb)
=20
 	recv_probe =3D ACCESS_ONCE(bond->recv_probe);
 	if (recv_probe) {
-		struct sk_buff *nskb =3D skb_clone(skb, GFP_ATOMIC);
-
-		if (likely(nskb)) {
-			ret =3D recv_probe(nskb, bond, slave);
-			dev_kfree_skb(nskb);
-			if (ret =3D=3D RX_HANDLER_CONSUMED) {
-				consume_skb(skb);
-				return ret;
-			}
+		ret =3D recv_probe(skb, bond, slave);
+		if (ret =3D=3D RX_HANDLER_CONSUMED) {
+			consume_skb(skb);
+			return ret;
 		}
 	}
=20
@@ -2737,25 +2732,31 @@ static void bond_validate_arp(struct bonding *b=
ond, struct slave *slave, __be32
 	}
 }
=20
-static int bond_arp_rcv(struct sk_buff *skb, struct bonding *bond,
-			 struct slave *slave)
+static int bond_arp_rcv(const struct sk_buff *skb, struct bonding *bon=
d,
+			struct slave *slave)
 {
-	struct arphdr *arp;
+	struct arphdr *arp =3D (struct arphdr *)skb->data;
 	unsigned char *arp_ptr;
 	__be32 sip, tip;
+	int alen;
=20
 	if (skb->protocol !=3D __cpu_to_be16(ETH_P_ARP))
 		return RX_HANDLER_ANOTHER;
=20
 	read_lock(&bond->lock);
+	alen =3D arp_hdr_len(bond->dev);
=20
 	pr_debug("bond_arp_rcv: bond %s skb->dev %s\n",
 		 bond->dev->name, skb->dev->name);
=20
-	if (!pskb_may_pull(skb, arp_hdr_len(bond->dev)))
-		goto out_unlock;
+	if (alen > skb_headlen(skb)) {
+		arp =3D kmalloc(alen, GFP_ATOMIC);
+		if (!arp)
+			goto out_unlock;
+		if (skb_copy_bits(skb, 0, arp, alen) < 0)
+			goto out_unlock;
+	}
=20
-	arp =3D arp_hdr(skb);
 	if (arp->ar_hln !=3D bond->dev->addr_len ||
 	    skb->pkt_type =3D=3D PACKET_OTHERHOST ||
 	    skb->pkt_type =3D=3D PACKET_LOOPBACK ||
@@ -2790,6 +2791,8 @@ static int bond_arp_rcv(struct sk_buff *skb, stru=
ct bonding *bond,
=20
 out_unlock:
 	read_unlock(&bond->lock);
+	if (arp !=3D (struct arphdr *)skb->data)
+		kfree(arp);
 	return RX_HANDLER_ANOTHER;
 }
=20
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bondin=
g.h
index 4581aa5..f8af2fc 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -218,8 +218,8 @@ struct bonding {
 	struct   slave *primary_slave;
 	bool     force_primary;
 	s32      slave_cnt; /* never change this value outside the attach/det=
ach wrappers */
-	int     (*recv_probe)(struct sk_buff *, struct bonding *,
-			       struct slave *);
+	int     (*recv_probe)(const struct sk_buff *, struct bonding *,
+			      struct slave *);
 	rwlock_t lock;
 	rwlock_t curr_slave_lock;
 	u8	 send_peer_notif;
