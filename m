From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: pktgen and spin_lock_bh in xmit path
Date: Tue, 20 Oct 2009 20:54:40 +0200
Message-ID: <4ADE0770.8060708@gmail.com>
References: <4ADD309B.1040505@candelatech.com> <4ADD32FA.6030409@gmail.com> <4ADD41F5.5080707@candelatech.com> <4ADDF560.1020509@candelatech.com> <4ADDF6E5.4070509@gmail.com> <4ADDF948.1050208@candelatech.com> <4ADE0306.6060101@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Greear <greearb@candelatech.com>,
	NetDev <netdev@vger.kernel.org>, robert@herjulf.net,
	"David S. Miller" <davem@davemloft.net>
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:41336 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751823AbZJTSyl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Oct 2009 14:54:41 -0400
In-Reply-To: <4ADE0306.6060101@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet a =E9crit :

> David, we are changing skb->mapping while transmitting it...
>=20
> So yes, it can break pktgen if its skbs are cloned.
>=20
> Maybe pktgen should call skb_record_rx_queue() instead of skb_set_que=
ue_mapping()
>=20
> Or maybe we should avoid this +/- 1 thing we do in skb_record_rx_queu=
e(), since
> we use same skb field for recording rx_queue or tx_queue :(
>=20

A possible fix would be :

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 86acdba..bbe4b2d 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -2554,7 +2554,6 @@ static struct sk_buff *fill_packet_ipv4(struct ne=
t_device *odev,
 	__be16 *vlan_encapsulated_proto =3D NULL;  /* packet type ID field (o=
r len) for VLAN tag */
 	__be16 *svlan_tci =3D NULL;                /* Encapsulates priority a=
nd SVLAN ID */
 	__be16 *svlan_encapsulated_proto =3D NULL; /* packet type ID field (o=
r len) for SVLAN tag */
-	u16 queue_map;
=20
 	if (pkt_dev->nr_labels)
 		protocol =3D htons(ETH_P_MPLS_UC);
@@ -2565,7 +2564,6 @@ static struct sk_buff *fill_packet_ipv4(struct ne=
t_device *odev,
 	/* Update any of the values, used when we're incrementing various
 	 * fields.
 	 */
-	queue_map =3D pkt_dev->cur_queue_map;
 	mod_cur_headers(pkt_dev);
=20
 	datalen =3D (odev->hard_header_len + 16) & ~0xf;
@@ -2605,7 +2603,6 @@ static struct sk_buff *fill_packet_ipv4(struct ne=
t_device *odev,
 	skb->network_header =3D skb->tail;
 	skb->transport_header =3D skb->network_header + sizeof(struct iphdr);
 	skb_put(skb, sizeof(struct iphdr) + sizeof(struct udphdr));
-	skb_set_queue_mapping(skb, queue_map);
 	iph =3D ip_hdr(skb);
 	udph =3D udp_hdr(skb);
=20
@@ -2896,7 +2893,6 @@ static struct sk_buff *fill_packet_ipv6(struct ne=
t_device *odev,
 	__be16 *vlan_encapsulated_proto =3D NULL;  /* packet type ID field (o=
r len) for VLAN tag */
 	__be16 *svlan_tci =3D NULL;                /* Encapsulates priority a=
nd SVLAN ID */
 	__be16 *svlan_encapsulated_proto =3D NULL; /* packet type ID field (o=
r len) for SVLAN tag */
-	u16 queue_map;
=20
 	if (pkt_dev->nr_labels)
 		protocol =3D htons(ETH_P_MPLS_UC);
@@ -2907,7 +2903,6 @@ static struct sk_buff *fill_packet_ipv6(struct ne=
t_device *odev,
 	/* Update any of the values, used when we're incrementing various
 	 * fields.
 	 */
-	queue_map =3D pkt_dev->cur_queue_map;
 	mod_cur_headers(pkt_dev);
=20
 	skb =3D __netdev_alloc_skb(odev,
@@ -2946,7 +2941,6 @@ static struct sk_buff *fill_packet_ipv6(struct ne=
t_device *odev,
 	skb->network_header =3D skb->tail;
 	skb->transport_header =3D skb->network_header + sizeof(struct ipv6hdr=
);
 	skb_put(skb, sizeof(struct ipv6hdr) + sizeof(struct udphdr));
-	skb_set_queue_mapping(skb, queue_map);
 	iph =3D ipv6_hdr(skb);
 	udph =3D udp_hdr(skb);
=20
@@ -3437,7 +3431,13 @@ static void pktgen_xmit(struct pktgen_dev *pkt_d=
ev)
 	if (pkt_dev->delay && pkt_dev->last_ok)
 		spin(pkt_dev, pkt_dev->next_tx);
=20
-	queue_map =3D skb_get_queue_mapping(pkt_dev->skb);
+	queue_map =3D pkt_dev->cur_queue_map;
+	/*
+	 * tells skb_tx_hash() to use this tx queue.
+	 * We should reset skb->mapping before each xmit() because
+	 * xmit() might change it.
+	 */
+	skb_record_rx_queue(pkt_dev->skb, queue_map);
 	txq =3D netdev_get_tx_queue(odev, queue_map);
=20
 	__netif_tx_lock_bh(txq);



