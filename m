From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: [SKBUFF] use eth_hdr(skb), skb->mac.raw cases
Date: Sat, 02 Oct 2004 16:50:24 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <415F0680.7040200@conectiva.com.br>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040208030207070501080502"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040208030207070501080502
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi David,

	Please consider pulling from:

bk://kernel.bkbits.net/acme/sk_buff-2.6

	Now there are 3 outstanding changesets in this tree.

Regards,

- Arnaldo

--------------040208030207070501080502
Content-Type: text/plain;
 name="eth_hdr2.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="eth_hdr2.patch"

===================================================================


ChangeSet@1.2032, 2004-10-02 16:44:12-03:00, acme@amd64.kerneljanitors.org
  [SKBUFF] use eth_hdr(skb), skb->mac.raw cases
  
  Signed-off-by: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
  Signed-off-by: David S. Miller <davem@redhat.com>


 drivers/ieee1394/eth1394.c        |    2 +-
 drivers/ieee1394/eth1394.h        |    7 +++++++
 drivers/net/hamradio/bpqether.c   |    2 +-
 drivers/net/wireless/orinoco.c    |    2 +-
 drivers/net/wireless/wavelan.c    |    5 ++---
 drivers/net/wireless/wavelan_cs.c |    4 ++--
 include/net/llc_pdu.h             |    6 +++---
 net/bluetooth/bnep/core.c         |    6 +++---
 net/llc/llc_input.c               |    2 +-
 net/llc/llc_output.c              |    2 +-
 10 files changed, 22 insertions(+), 16 deletions(-)


diff -Nru a/drivers/ieee1394/eth1394.c b/drivers/ieee1394/eth1394.c
--- a/drivers/ieee1394/eth1394.c	2004-10-02 16:44:56 -03:00
+++ b/drivers/ieee1394/eth1394.c	2004-10-02 16:44:56 -03:00
@@ -850,7 +850,7 @@
 
 	skb->mac.raw = skb->data;
 	skb_pull (skb, ETH1394_HLEN);
-	eth = (struct eth1394hdr*)skb->mac.raw;
+	eth = eth1394_hdr(skb);
 
 	if (*eth->h_dest & 1) {
 		if (memcmp(eth->h_dest, dev->broadcast, dev->addr_len)==0)
diff -Nru a/drivers/ieee1394/eth1394.h b/drivers/ieee1394/eth1394.h
--- a/drivers/ieee1394/eth1394.h	2004-10-02 16:44:56 -03:00
+++ b/drivers/ieee1394/eth1394.h	2004-10-02 16:44:56 -03:00
@@ -81,7 +81,14 @@
 	unsigned short	h_proto;		/* packet type ID field	*/
 }  __attribute__((packed));
 
+#ifdef __KERNEL__
+#include <linux/skbuff.h>
 
+static inline struct eth1394hdr *eth1394_hdr(const struct sk_buff *skb)
+{
+	return (struct eth1394hdr *)skb->mac.raw;
+}
+#endif
 
 typedef enum {ETH1394_GASP, ETH1394_WRREQ} eth1394_tx_type;
 
diff -Nru a/drivers/net/hamradio/bpqether.c b/drivers/net/hamradio/bpqether.c
--- a/drivers/net/hamradio/bpqether.c	2004-10-02 16:44:56 -03:00
+++ b/drivers/net/hamradio/bpqether.c	2004-10-02 16:44:56 -03:00
@@ -193,7 +193,7 @@
 
 	bpq = (struct bpqdev *)dev->priv;
 
-	eth = (struct ethhdr *)skb->mac.raw;
+	eth = eth_hdr(skb);
 
 	if (!(bpq->acpt_addr[0] & 0x01) &&
 	    memcmp(eth->h_source, bpq->acpt_addr, ETH_ALEN))
diff -Nru a/drivers/net/wireless/orinoco.c b/drivers/net/wireless/orinoco.c
--- a/drivers/net/wireless/orinoco.c	2004-10-02 16:44:56 -03:00
+++ b/drivers/net/wireless/orinoco.c	2004-10-02 16:44:56 -03:00
@@ -1009,7 +1009,7 @@
 	/* Note : gcc will optimise the whole section away if
 	 * WIRELESS_SPY is not defined... - Jean II */
 	if (SPY_NUMBER(priv)) {
-		orinoco_spy_gather(dev, skb->mac.raw + ETH_ALEN,
+		orinoco_spy_gather(dev, eth_hdr(skb)->h_source,
 				   desc->signal, desc->silence);
 	}
 }
diff -Nru a/drivers/net/wireless/wavelan.c b/drivers/net/wireless/wavelan.c
--- a/drivers/net/wireless/wavelan.c	2004-10-02 16:44:56 -03:00
+++ b/drivers/net/wireless/wavelan.c	2004-10-02 16:44:56 -03:00
@@ -2521,7 +2521,7 @@
 	skb->protocol = eth_type_trans(skb, dev);
 
 #ifdef DEBUG_RX_INFO
-	wv_packet_info(skb->mac.raw, sksize, dev->name, "wv_packet_read");
+	wv_packet_info(eth_hdr(skb)->h_dest, sksize, dev->name, "wv_packet_read");
 #endif				/* DEBUG_RX_INFO */
 
 	/* Statistics-gathering and associated stuff.
@@ -2557,8 +2557,7 @@
 
 		/* Spying stuff */
 #ifdef IW_WIRELESS_SPY
-		wl_spy_gather(dev, skb->mac.raw + WAVELAN_ADDR_SIZE,
-			      stats);
+		wl_spy_gather(dev, eth_hdr(skb)->h_source, stats);
 #endif /* IW_WIRELESS_SPY */
 #ifdef HISTOGRAM
 		wl_his_gather(dev, stats);
diff -Nru a/drivers/net/wireless/wavelan_cs.c b/drivers/net/wireless/wavelan_cs.c
--- a/drivers/net/wireless/wavelan_cs.c	2004-10-02 16:44:56 -03:00
+++ b/drivers/net/wireless/wavelan_cs.c	2004-10-02 16:44:56 -03:00
@@ -2943,7 +2943,7 @@
   skb->protocol = eth_type_trans(skb, dev);
 
 #ifdef DEBUG_RX_INFO
-  wv_packet_info(skb->mac.raw, sksize, dev->name, "wv_packet_read");
+  wv_packet_info(eth_hdr(skb)->h_dest, sksize, dev->name, "wv_packet_read");
 #endif	/* DEBUG_RX_INFO */
      
   /* Statistics gathering & stuff associated.
@@ -2977,7 +2977,7 @@
 #endif	/* WAVELAN_ROAMING */
 	  
 #ifdef WIRELESS_SPY
-      wl_spy_gather(dev, skb->mac.raw + WAVELAN_ADDR_SIZE, stats);
+      wl_spy_gather(dev, eth_hdr(skb)->h_source, stats);
 #endif	/* WIRELESS_SPY */
 #ifdef HISTOGRAM
       wl_his_gather(dev, stats);
diff -Nru a/include/net/llc_pdu.h b/include/net/llc_pdu.h
--- a/include/net/llc_pdu.h	2004-10-02 16:44:56 -03:00
+++ b/include/net/llc_pdu.h	2004-10-02 16:44:56 -03:00
@@ -253,7 +253,7 @@
 static inline void llc_pdu_decode_sa(struct sk_buff *skb, u8 *sa)
 {
 	if (skb->protocol == ntohs(ETH_P_802_2))
-		memcpy(sa, ((struct ethhdr *)skb->mac.raw)->h_source, ETH_ALEN);
+		memcpy(sa, eth_hdr(skb)->h_source, ETH_ALEN);
 	else if (skb->protocol == ntohs(ETH_P_TR_802_2))
 		memcpy(sa, ((struct trh_hdr *)skb->mac.raw)->saddr, ETH_ALEN);
 }
@@ -268,7 +268,7 @@
 static inline void llc_pdu_decode_da(struct sk_buff *skb, u8 *da)
 {
 	if (skb->protocol == ntohs(ETH_P_802_2))
-		memcpy(da, ((struct ethhdr *)skb->mac.raw)->h_dest, ETH_ALEN);
+		memcpy(da, eth_hdr(skb)->h_dest, ETH_ALEN);
 	else if (skb->protocol == ntohs(ETH_P_TR_802_2))
 		memcpy(da, ((struct trh_hdr *)skb->mac.raw)->daddr, ETH_ALEN);
 }
@@ -347,7 +347,7 @@
 		struct llc_pdu_un *ev_pdu = llc_pdu_un_hdr(ev_skb);
 		int dsize;
 
-		dsize = ntohs(((struct ethhdr *)ev_skb->mac.raw)->h_proto) - 3;
+		dsize = ntohs(eth_hdr(ev_skb)->h_proto) - 3;
 		memcpy(((u8 *)pdu) + 3, ((u8 *)ev_pdu) + 3, dsize);
 		skb_put(skb, dsize);
 	}
diff -Nru a/net/bluetooth/bnep/core.c b/net/bluetooth/bnep/core.c
--- a/net/bluetooth/bnep/core.c	2004-10-02 16:44:56 -03:00
+++ b/net/bluetooth/bnep/core.c	2004-10-02 16:44:56 -03:00
@@ -364,17 +364,17 @@
 	
 	case BNEP_COMPRESSED_SRC_ONLY:
 		memcpy(__skb_put(nskb, ETH_ALEN), s->eh.h_dest, ETH_ALEN);
-		memcpy(__skb_put(nskb, ETH_ALEN), skb->mac.raw, ETH_ALEN);
+		memcpy(__skb_put(nskb, ETH_ALEN), eth_hdr(skb), ETH_ALEN);
 		put_unaligned(s->eh.h_proto, (u16 *) __skb_put(nskb, 2));
 		break;
 
 	case BNEP_COMPRESSED_DST_ONLY:
-		memcpy(__skb_put(nskb, ETH_ALEN), skb->mac.raw, ETH_ALEN);
+		memcpy(__skb_put(nskb, ETH_ALEN), eth_hdr(skb), ETH_ALEN);
 		memcpy(__skb_put(nskb, ETH_ALEN + 2), s->eh.h_source, ETH_ALEN + 2);
 		break;
 
 	case BNEP_GENERAL:
-		memcpy(__skb_put(nskb, ETH_ALEN * 2), skb->mac.raw, ETH_ALEN * 2);
+		memcpy(__skb_put(nskb, ETH_ALEN * 2), eth_hdr(skb), ETH_ALEN * 2);
 		put_unaligned(s->eh.h_proto, (u16 *) __skb_put(nskb, 2));
 		break;
 	}
diff -Nru a/net/llc/llc_input.c b/net/llc/llc_input.c
--- a/net/llc/llc_input.c	2004-10-02 16:44:56 -03:00
+++ b/net/llc/llc_input.c	2004-10-02 16:44:56 -03:00
@@ -111,7 +111,7 @@
 	skb->h.raw += llc_len;
 	skb_pull(skb, llc_len);
 	if (skb->protocol == htons(ETH_P_802_2)) {
-		u16 pdulen = ((struct ethhdr *)skb->mac.raw)->h_proto,
+		u16 pdulen = eth_hdr(skb)->h_proto,
 		    data_size = ntohs(pdulen) - llc_len;
 
 		skb_trim(skb, data_size);
diff -Nru a/net/llc/llc_output.c b/net/llc/llc_output.c
--- a/net/llc/llc_output.c	2004-10-02 16:44:56 -03:00
+++ b/net/llc/llc_output.c	2004-10-02 16:44:56 -03:00
@@ -61,7 +61,7 @@
 		struct ethhdr *eth;
 
 		skb->mac.raw = skb_push(skb, sizeof(*eth));
-		eth = (struct ethhdr *)skb->mac.raw;
+		eth = eth_hdr(skb);
 		eth->h_proto = htons(len);
 		memcpy(eth->h_dest, da, ETH_ALEN);
 		memcpy(eth->h_source, sa, ETH_ALEN);


--------------040208030207070501080502--
