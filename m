From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] pktgen: Dont leak kernel memory
Date: Wed, 21 Oct 2009 07:01:58 +0200
Message-ID: <4ADE95C6.40103@gmail.com>
References: <4ADE8C85.6020809@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:57846 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751501AbZJUFB4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2009 01:01:56 -0400
In-Reply-To: <4ADE8C85.6020809@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet a =E9crit :
> While playing with pktgen, I realized IP ID was not filled and a rand=
om value
> was taken, possibly leaking 2 bytes of kernel memory.
>=20
> We can use an increasing ID, this can help diagnostics anyway.
>=20
>=20

Here is a more complete version of the patch, since we leak lot of kern=
el
memory :(

[PATCH] pktgen: Dont leak kernel memory

While playing with pktgen, I realized IP ID was not filled and a random=
 value
was taken, possibly leaking 2 bytes of kernel memory.
=20
We can use an increasing ID, this can help diagnostics anyway.

Also clear packet payload, instead of leaking kernel memory.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 1da0e03..5ce017b 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -335,6 +335,7 @@ struct pktgen_dev {
 	__u32 cur_src_mac_offset;
 	__be32 cur_saddr;
 	__be32 cur_daddr;
+	__u16 ip_id;
 	__u16 cur_udp_dst;
 	__u16 cur_udp_src;
 	__u16 cur_queue_map;
@@ -2630,6 +2631,8 @@ static struct sk_buff *fill_packet_ipv4(struct ne=
t_device *odev,
 	iph->protocol =3D IPPROTO_UDP;	/* UDP */
 	iph->saddr =3D pkt_dev->cur_saddr;
 	iph->daddr =3D pkt_dev->cur_daddr;
+	iph->id =3D htons(pkt_dev->ip_id);
+	pkt_dev->ip_id++;
 	iph->frag_off =3D 0;
 	iplen =3D 20 + 8 + datalen;
 	iph->tot_len =3D htons(iplen);
@@ -2641,24 +2644,26 @@ static struct sk_buff *fill_packet_ipv4(struct =
net_device *odev,
 	skb->dev =3D odev;
 	skb->pkt_type =3D PACKET_HOST;
=20
-	if (pkt_dev->nfrags <=3D 0)
+	if (pkt_dev->nfrags <=3D 0) {
 		pgh =3D (struct pktgen_hdr *)skb_put(skb, datalen);
-	else {
+		memset(pgh + 1, 0, datalen - sizeof(struct pktgen_hdr));
+	} else {
 		int frags =3D pkt_dev->nfrags;
-		int i;
+		int i, len;
=20
 		pgh =3D (struct pktgen_hdr *)(((char *)(udph)) + 8);
=20
 		if (frags > MAX_SKB_FRAGS)
 			frags =3D MAX_SKB_FRAGS;
 		if (datalen > frags * PAGE_SIZE) {
-			skb_put(skb, datalen - frags * PAGE_SIZE);
+			len =3D datalen - frags * PAGE_SIZE;
+			memset(skb_put(skb, len), 0, len);
 			datalen =3D frags * PAGE_SIZE;
 		}
=20
 		i =3D 0;
 		while (datalen > 0) {
-			struct page *page =3D alloc_pages(GFP_KERNEL, 0);
+			struct page *page =3D alloc_pages(GFP_KERNEL | __GFP_ZERO, 0);
 			skb_shinfo(skb)->frags[i].page =3D page;
 			skb_shinfo(skb)->frags[i].page_offset =3D 0;
 			skb_shinfo(skb)->frags[i].size =3D

