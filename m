From: Chris Metcalf <cmetcalf@tilera.com>
Subject: [PATCH v3 10/13] tile: support TSO for IPv6 in tilegx network driver
Date: Thu, 1 Aug 2013 11:36:42 -0400
Message-ID: <65924ecd1f57d8ada0966b60d99fcb518efb0db3.1375385120.git.cmetcalf@tilera.com>
References: <20130801.113100.2059303096028571906.davem@davemloft.net>
	<cover.1375385119.git.cmetcalf@tilera.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1375385119.git.cmetcalf@tilera.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Chris Metcalf <cmetcalf@tilera.com>
---
 drivers/net/ethernet/tile/tilegx.c | 44 +++++++++++++++++++++++++-------------
 1 file changed, 29 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/tile/tilegx.c b/drivers/net/ethernet/tile/tilegx.c
index b80a91f..6d94d58 100644
--- a/drivers/net/ethernet/tile/tilegx.c
+++ b/drivers/net/ethernet/tile/tilegx.c
@@ -36,6 +36,7 @@
 #include <linux/io.h>
 #include <linux/ctype.h>
 #include <linux/ip.h>
+#include <linux/ipv6.h>
 #include <linux/tcp.h>
 
 #include <asm/checksum.h>
@@ -1512,20 +1513,20 @@ static int tso_count_edescs(struct sk_buff *skb)
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
@@ -1533,18 +1534,24 @@ static void tso_headers_prepare(struct sk_buff *skb, unsigned char *headers,
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
@@ -1558,11 +1565,17 @@ static void tso_headers_prepare(struct sk_buff *skb, unsigned char *headers,
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
@@ -1954,6 +1967,7 @@ static void tile_net_setup(struct net_device *dev)
 	features |= NETIF_F_HW_CSUM;
 	features |= NETIF_F_SG;
 	features |= NETIF_F_TSO;
+	features |= NETIF_F_TSO6;
 
 	dev->hw_features   |= features;
 	dev->vlan_features |= features;
-- 
1.8.3.1
