From: Chris Metcalf <cmetcalf@tilera.com>
Subject: [PATCH 2/3] tilegx net driver: handle payload data not in frags
Date: Wed, 11 Jul 2012 14:08:21 -0400
Message-ID: <201207181641.q6IGfbtu007230@lab-41.internal.tilera.com>
References: <201207181640.q6IGet7P007227@lab-41.internal.tilera.com>
Mime-Version: 1.0
Content-Type: text/plain
To: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usmamail.tilera.com ([12.216.194.151]:32161 "EHLO
	USMAMAIL.TILERA.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755101Ab2GRQlh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 12:41:37 -0400
In-Reply-To: <201207181640.q6IGet7P007227@lab-41.internal.tilera.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The original driver implementation assumed that for TSO, all the
payload data would be in the frags.  This isn't always true; change
the driver to support payload data at skb->data between
"skb_transport_offset(skb) + tcp_hdrlen(skb)" and "skb->hdr_len",
followed by the data in the frags.

Signed-off-by: Chris Metcalf <cmetcalf@tilera.com>
---
 drivers/net/ethernet/tile/tilegx.c |   36 ++++++++++++++++++------------------
 1 file changed, 18 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/tile/tilegx.c b/drivers/net/ethernet/tile/tilegx.c
index c7bde28..f78effc 100644
--- a/drivers/net/ethernet/tile/tilegx.c
+++ b/drivers/net/ethernet/tile/tilegx.c
@@ -1333,11 +1333,12 @@ static s64 tile_net_equeue_try_reserve(struct net_device *dev,
 static int tso_count_edescs(struct sk_buff *skb)
 {
 	struct skb_shared_info *sh = skb_shinfo(skb);
-	unsigned int data_len = skb->data_len;
+	unsigned int sh_len = skb_transport_offset(skb) + tcp_hdrlen(skb);
+	unsigned int data_len = skb->data_len + skb->hdr_len - sh_len;
 	unsigned int p_len = sh->gso_size;
 	long f_id = -1;    /* id of the current fragment */
-	long f_size = -1;  /* size of the current fragment */
-	long f_used = -1;  /* bytes used from the current fragment */
+	long f_size = skb->hdr_len;  /* size of the current fragment */
+	long f_used = sh_len;  /* bytes used from the current fragment */
 	long n;            /* size of the current piece of payload */
 	int num_edescs = 0;
 	int segment;
@@ -1382,13 +1383,14 @@ static void tso_headers_prepare(struct sk_buff *skb, unsigned char *headers,
 	struct skb_shared_info *sh = skb_shinfo(skb);
 	struct iphdr *ih;
 	struct tcphdr *th;
-	unsigned int data_len = skb->data_len;
+	unsigned int sh_len = skb_transport_offset(skb) + tcp_hdrlen(skb);
+	unsigned int data_len = skb->data_len + skb->hdr_len - sh_len;
 	unsigned char *data = skb->data;
-	unsigned int ih_off, th_off, sh_len, p_len;
+	unsigned int ih_off, th_off, p_len;
 	unsigned int isum_seed, tsum_seed, id, seq;
 	long f_id = -1;    /* id of the current fragment */
-	long f_size = -1;  /* size of the current fragment */
-	long f_used = -1;  /* bytes used from the current fragment */
+	long f_size = skb->hdr_len;  /* size of the current fragment */
+	long f_used = sh_len;  /* bytes used from the current fragment */
 	long n;            /* size of the current piece of payload */
 	int segment;
 
@@ -1397,14 +1399,13 @@ static void tso_headers_prepare(struct sk_buff *skb, unsigned char *headers,
 	th = tcp_hdr(skb);
 	ih_off = skb_network_offset(skb);
 	th_off = skb_transport_offset(skb);
-	sh_len = th_off + tcp_hdrlen(skb);
 	p_len = sh->gso_size;
 
 	/* Set up seed values for IP and TCP csum and initialize id and seq. */
 	isum_seed = ((0xFFFF - ih->check) +
 		     (0xFFFF - ih->tot_len) +
 		     (0xFFFF - ih->id));
-	tsum_seed = th->check + (0xFFFF ^ htons(skb->len));
+	tsum_seed = th->check + (0xFFFF ^ htons(sh_len + data_len));
 	id = ntohs(ih->id);
 	seq = ntohl(th->seq);
 
@@ -1476,21 +1477,22 @@ static void tso_egress(struct net_device *dev, gxio_mpipe_equeue_t *equeue,
 {
 	struct tile_net_priv *priv = netdev_priv(dev);
 	struct skb_shared_info *sh = skb_shinfo(skb);
-	unsigned int data_len = skb->data_len;
+	unsigned int sh_len = skb_transport_offset(skb) + tcp_hdrlen(skb);
+	unsigned int data_len = skb->data_len + skb->hdr_len - sh_len;
 	unsigned int p_len = sh->gso_size;
 	gxio_mpipe_edesc_t edesc_head = { { 0 } };
 	gxio_mpipe_edesc_t edesc_body = { { 0 } };
 	long f_id = -1;    /* id of the current fragment */
-	long f_size = -1;  /* size of the current fragment */
-	long f_used = -1;  /* bytes used from the current fragment */
+	long f_size = skb->hdr_len;  /* size of the current fragment */
+	long f_used = sh_len;  /* bytes used from the current fragment */
+	void *f_data = skb->data;
 	long n;            /* size of the current piece of payload */
 	unsigned long tx_packets = 0, tx_bytes = 0;
-	unsigned int csum_start, sh_len;
+	unsigned int csum_start;
 	int segment;
 
 	/* Prepare to egress the headers: set up header edesc. */
 	csum_start = skb_checksum_start_offset(skb);
-	sh_len = skb_transport_offset(skb) + tcp_hdrlen(skb);
 	edesc_head.csum = 1;
 	edesc_head.csum_start = csum_start;
 	edesc_head.csum_dest = csum_start + skb->csum_offset;
@@ -1502,7 +1504,6 @@ static void tso_egress(struct net_device *dev, gxio_mpipe_equeue_t *equeue,
 
 	/* Egress all the edescs. */
 	for (segment = 0; segment < sh->gso_segs; segment++) {
-		void *va;
 		unsigned char *buf;
 		unsigned int p_used = 0;
 
@@ -1521,10 +1522,9 @@ static void tso_egress(struct net_device *dev, gxio_mpipe_equeue_t *equeue,
 				f_id++;
 				f_size = sh->frags[f_id].size;
 				f_used = 0;
+				f_data = tile_net_frag_buf(&sh->frags[f_id]);
 			}
 
-			va = tile_net_frag_buf(&sh->frags[f_id]) + f_used;
-
 			/* Use bytes from the current fragment. */
 			n = p_len - p_used;
 			if (n > f_size - f_used)
@@ -1533,7 +1533,7 @@ static void tso_egress(struct net_device *dev, gxio_mpipe_equeue_t *equeue,
 			p_used += n;
 
 			/* Egress a piece of the payload. */
-			edesc_body.va = va_to_tile_io_addr(va);
+			edesc_body.va = va_to_tile_io_addr(f_data) + f_used;
 			edesc_body.xfer_size = n;
 			edesc_body.bound = !(p_used < p_len);
 			gxio_mpipe_equeue_put_at(equeue, edesc_body, slot);
-- 
1.7.10.3
