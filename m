From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: [PATCH 1/2] [SKBUFF] use eth_hdr(skb), skb->mac.raw cases
Date: Wed, 06 Oct 2004 15:39:22 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <41643BDA.8000204@conectiva.com.br>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090802080008060505060306"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------090802080008060505060306
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi David,

	More two changesets, first one in this message, placed in

bk://kernel.bkbits.net/acme/sk_buff-2.6

Regards,

- Arnaldo

--------------090802080008060505060306
Content-Type: text/plain;
 name="eth_hdr2.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="eth_hdr2.patch"

===================================================================


ChangeSet@1.2055, 2004-10-06 14:12:55-03:00, acme@conectiva.com.br
  [SKBUFF] use eth_hdr(skb), skb->mac.raw cases
  
  Signed-off-by: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
  Signed-off-by: David S. Miller <davem@redhat.com>


 drivers/ieee1394/eth1394.c      |    2 +-
 drivers/ieee1394/eth1394.h      |    7 +++++++
 drivers/net/hamradio/bpqether.c |    2 +-
 include/net/llc_pdu.h           |    6 +++---
 net/llc/llc_input.c             |    2 +-
 net/llc/llc_output.c            |    2 +-
 6 files changed, 14 insertions(+), 7 deletions(-)


diff -Nru a/drivers/ieee1394/eth1394.c b/drivers/ieee1394/eth1394.c
--- a/drivers/ieee1394/eth1394.c	2004-10-06 15:34:25 -03:00
+++ b/drivers/ieee1394/eth1394.c	2004-10-06 15:34:25 -03:00
@@ -850,7 +850,7 @@
 
 	skb->mac.raw = skb->data;
 	skb_pull (skb, ETH1394_HLEN);
-	eth = (struct eth1394hdr*)skb->mac.raw;
+	eth = eth1394_hdr(skb);
 
 	if (*eth->h_dest & 1) {
 		if (memcmp(eth->h_dest, dev->broadcast, dev->addr_len)==0)
diff -Nru a/drivers/ieee1394/eth1394.h b/drivers/ieee1394/eth1394.h
--- a/drivers/ieee1394/eth1394.h	2004-10-06 15:34:25 -03:00
+++ b/drivers/ieee1394/eth1394.h	2004-10-06 15:34:25 -03:00
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
--- a/drivers/net/hamradio/bpqether.c	2004-10-06 15:34:25 -03:00
+++ b/drivers/net/hamradio/bpqether.c	2004-10-06 15:34:25 -03:00
@@ -193,7 +193,7 @@
 
 	bpq = (struct bpqdev *)dev->priv;
 
-	eth = (struct ethhdr *)skb->mac.raw;
+	eth = eth_hdr(skb);
 
 	if (!(bpq->acpt_addr[0] & 0x01) &&
 	    memcmp(eth->h_source, bpq->acpt_addr, ETH_ALEN))
diff -Nru a/include/net/llc_pdu.h b/include/net/llc_pdu.h
--- a/include/net/llc_pdu.h	2004-10-06 15:34:25 -03:00
+++ b/include/net/llc_pdu.h	2004-10-06 15:34:25 -03:00
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
diff -Nru a/net/llc/llc_input.c b/net/llc/llc_input.c
--- a/net/llc/llc_input.c	2004-10-06 15:34:25 -03:00
+++ b/net/llc/llc_input.c	2004-10-06 15:34:25 -03:00
@@ -111,7 +111,7 @@
 	skb->h.raw += llc_len;
 	skb_pull(skb, llc_len);
 	if (skb->protocol == htons(ETH_P_802_2)) {
-		u16 pdulen = ((struct ethhdr *)skb->mac.raw)->h_proto,
+		u16 pdulen = eth_hdr(skb)->h_proto,
 		    data_size = ntohs(pdulen) - llc_len;
 
 		skb_trim(skb, data_size);
diff -Nru a/net/llc/llc_output.c b/net/llc/llc_output.c
--- a/net/llc/llc_output.c	2004-10-06 15:34:25 -03:00
+++ b/net/llc/llc_output.c	2004-10-06 15:34:25 -03:00
@@ -61,7 +61,7 @@
 		struct ethhdr *eth;
 
 		skb->mac.raw = skb_push(skb, sizeof(*eth));
-		eth = (struct ethhdr *)skb->mac.raw;
+		eth = eth_hdr(skb);
 		eth->h_proto = htons(len);
 		memcpy(eth->h_dest, da, ETH_ALEN);
 		memcpy(eth->h_source, sa, ETH_ALEN);


--------------090802080008060505060306--
