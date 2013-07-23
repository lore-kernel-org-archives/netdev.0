From: Chris Metcalf <cmetcalf@tilera.com>
Subject: [PATCH 11/13] tile: support TSO for IPv6 in tilegx network driver
Date: Tue, 23 Jul 2013 16:05:48 -0400
Message-ID: <b56efb6f1ce83a975fd2b9857fd9e154c8a7d6c0.1374609949.git.cmetcalf@tilera.com>
References: <cover.1374609948.git.cmetcalf@tilera.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1374609948.git.cmetcalf@tilera.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Chris Metcalf <cmetcalf@tilera.com>
---
 drivers/net/ethernet/tile/tilegx.c | 44 +++++++++++++++++++++++++-------------
 1 file changed, 29 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/tile/tilegx.c b/drivers/net/ethernet/tile/tilegx.c
index 18eb7b9..04fe597 100644
--- a/drivers/net/ethernet/tile/tilegx.c
+++ b/drivers/net/ethernet/tile/tilegx.c
@@ -36,6 +36,7 @@
 #include <linux/io.h>
 #include <linux/ctype.h>
 #include <linux/ip.h>
+#include <linux/ipv6.h>
 #include <linux/tcp.h>
 
 #include <asm/checksum.h>
@@ -1563,20 +1564,20 @@ static int tso_count_edescs(struct sk_buff *skb)
 	return num_edescs;
 }
 
-/* Prepare modified copies of the skbuff headers.
- * FIXME: add support for IPv6.
- */
+/* Prepare modified copies of the skbuff headers. */
 static void tso_headers_prepare(struct sk_buff *skb, unsigned char *headers,
 				s64 slot)
 {
 	struct skb_shared_info *sh = skb_shinfo(skb);
 	struct iphdr *ih;
+	struct ipv6hdr *ih6;
 	struct tcphdr *th;
 	unsigned int sh_len = skb_transport_offset(skb) + tcp_hdrlen(skb);
 	unsigned int data_len = skb->len - sh_len;
 	unsigned char *data = skb->data;
 	unsigned int ih_off, th_off, p_len;
 	unsigned int isum_seed, tsum_seed, id, seq;
+	int is_ipv6;
 	long f_id = -1;    /* id of the current fragment */
 	long f_size = skb_headlen(skb) - sh_len;  /* current fragment size */
 	long f_used = 0;  /* bytes used from the current fragment */
@@ -1584,18 +1585,24 @@ static void tso_headers_prepare(struct sk_buff *skb, unsigned char *headers,
 	int segment;
 
 	/* Locate original headers and compute various lengths. */
-	ih = ip_hdr(skb);
+	is_ipv6 = skb_is_gso_v6(skb);
+	if (is_ipv6) {
+		ih6 = ipv6_hdr(skb);
+		ih_off = skb_network_offset(skb);
+	} else {
+		ih = ip_hdr(skb);
+		ih_off = skb_network_offset(skb);
+		isum_seed = ((0xFFFF - ih->check) +
+			     (0xFFFF - ih->tot_len) +
+			     (0xFFFF - ih->id));
+		id = ntohs(ih->id);
+	}
+
 	th = tcp_hdr(skb);
-	ih_off = skb_network_offset(skb);
 	th_off = skb_transport_offset(skb);
 	p_len = sh->gso_size;
 
-	/* Set up seed values for IP and TCP csum and initialize id and seq. */
-	isum_seed = ((0xFFFF - ih->check) +
-		     (0xFFFF - ih->tot_len) +
-		     (0xFFFF - ih->id));
 	tsum_seed = th->check + (0xFFFF ^ htons(skb->len));
-	id = ntohs(ih->id);
 	seq = ntohl(th->seq);
 
 	/* Prepare all the headers. */
@@ -1609,11 +1616,17 @@ static void tso_headers_prepare(struct sk_buff *skb, unsigned char *headers,
 		memcpy(buf, data, sh_len);
 
 		/* Update copied ip header. */
-		ih = (struct iphdr *)(buf + ih_off);
-		ih->tot_len = htons(sh_len + p_len - ih_off);
-		ih->id = htons(id);
-		ih->check = csum_long(isum_seed + ih->tot_len +
-				      ih->id) ^ 0xffff;
+		if (is_ipv6) {
+			ih6 = (struct ipv6hdr *)(buf + ih_off);
+			ih6->payload_len = htons(sh_len + p_len - ih_off -
+						 sizeof(*ih6));
+		} else {
+			ih = (struct iphdr *)(buf + ih_off);
+			ih->tot_len = htons(sh_len + p_len - ih_off);
+			ih->id = htons(id);
+			ih->check = csum_long(isum_seed + ih->tot_len +
+					      ih->id) ^ 0xffff;
+		}
 
 		/* Update copied tcp header. */
 		th = (struct tcphdr *)(buf + th_off);
@@ -2010,6 +2023,7 @@ static void tile_net_setup(struct net_device *dev)
 	dev->features |= NETIF_F_HW_CSUM;
 	dev->features |= NETIF_F_SG;
 	dev->features |= NETIF_F_TSO;
+	dev->features |= NETIF_F_TSO6;
 	dev->features |= NETIF_F_GRO;
 	dev->mtu = 1500;
 }
-- 
1.8.3.1
