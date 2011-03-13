From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] ftmac100: use GFP_ATOMIC allocations where
 needed
Date: Sun, 13 Mar 2011 21:26:42 +0100
Message-ID: <1300048002.2761.53.camel@edumazet-laptop>
References: <1299744517-1896-1-git-send-email-ratbert.chuang@gmail.com>
	 <1300047388.2761.48.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Po-Yu Chuang <ratbert@faraday-tech.com>
To: Po-Yu Chuang <ratbert.chuang@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1300047388.2761.48.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le dimanche 13 mars 2011 =C3=A0 21:16 +0100, Eric Dumazet a =C3=A9crit =
:

> BTW, it seems I missed the fact that ftmac100_alloc_rx_page() used a
> GFP_KERNEL allocation, while its called from softirq context (from
> ftmac100_rx_packet())=20

Here is a patch against ftmac100

[PATCH net-next-2.6] ftmac100: use GFP_ATOMIC allocations where needed

When running in softirq context, we should use GFP_ATOMIC allocations
instead of GFP_KERNEL ones.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 drivers/net/ftmac100.c |   12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ftmac100.c b/drivers/net/ftmac100.c
index df70368..76cf77a 100644
--- a/drivers/net/ftmac100.c
+++ b/drivers/net/ftmac100.c
@@ -80,7 +80,8 @@ struct ftmac100 {
 	struct mii_if_info mii;
 };
=20
-static int ftmac100_alloc_rx_page(struct ftmac100 *priv, struct ftmac1=
00_rxdes *rxdes);
+static int ftmac100_alloc_rx_page(struct ftmac100 *priv,
+				  struct ftmac100_rxdes *rxdes, gfp_t gfp);
=20
 /*********************************************************************=
*********
  * internal functions (hardware register access)
@@ -441,7 +442,7 @@ static bool ftmac100_rx_packet(struct ftmac100 *pri=
v, int *processed)
 	skb->truesize +=3D length;
 	__pskb_pull_tail(skb, min(length, 64));
=20
-	ftmac100_alloc_rx_page(priv, rxdes);
+	ftmac100_alloc_rx_page(priv, rxdes, GFP_ATOMIC);
=20
 	ftmac100_rx_pointer_advance(priv);
=20
@@ -659,13 +660,14 @@ static int ftmac100_xmit(struct ftmac100 *priv, s=
truct sk_buff *skb,
 /*********************************************************************=
*********
  * internal functions (buffer)
  *********************************************************************=
********/
-static int ftmac100_alloc_rx_page(struct ftmac100 *priv, struct ftmac1=
00_rxdes *rxdes)
+static int ftmac100_alloc_rx_page(struct ftmac100 *priv,
+				  struct ftmac100_rxdes *rxdes, gtp_t gfp)
 {
 	struct net_device *netdev =3D priv->netdev;
 	struct page *page;
 	dma_addr_t map;
=20
-	page =3D alloc_page(GFP_KERNEL);
+	page =3D alloc_page(gfp);
 	if (!page) {
 		if (net_ratelimit())
 			netdev_err(netdev, "failed to allocate rx page\n");
@@ -736,7 +738,7 @@ static int ftmac100_alloc_buffers(struct ftmac100 *=
priv)
 	for (i =3D 0; i < RX_QUEUE_ENTRIES; i++) {
 		struct ftmac100_rxdes *rxdes =3D &priv->descs->rxdes[i];
=20
-		if (ftmac100_alloc_rx_page(priv, rxdes))
+		if (ftmac100_alloc_rx_page(priv, rxdes, GFP_KERNEL))
 			goto err;
 	}
=20
