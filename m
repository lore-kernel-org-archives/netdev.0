From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: PATCH: [SKBUFF] introduce tr_hdr(skb)
Date: Sun, 03 Oct 2004 00:27:31 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <415F71A3.4000701@conectiva.com.br>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050708030604090602070200"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050708030604090602070200
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi David,

	Please consider pulling from:

bk://kernel.bkbits.net/acme/sk_buff-2.6

	Now there are three outstanding changesets in this tree.

Regards,

- Arnaldo

--------------050708030604090602070200
Content-Type: text/plain;
 name="tr_hdr.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="tr_hdr.patch"

===================================================================


ChangeSet@1.2033, 2004-10-03 00:23:07-03:00, acme@conectiva.com.br
  [SKBUFF] introduce tr_hdr(skb)
  
  The token ring code in the kernel is bitrotting (no surprise :) ),
  it uses skb->data all around... I have an assortment of token ring
  cards but no MAU, can anybody send me one, please? I promise to
  make ssh work over LLC over Token Ring networks! Duh... :o)
  
  Signed-off-by: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
  Signed-off-by: David S. Miller <davem@redhat.com>


 include/linux/if_tr.h |    9 +++++++++
 include/net/llc_pdu.h |    4 ++--
 net/llc/llc_output.c  |    4 ++--
 3 files changed, 13 insertions(+), 4 deletions(-)


diff -Nru a/include/linux/if_tr.h b/include/linux/if_tr.h
--- a/include/linux/if_tr.h	2004-10-03 00:24:29 -03:00
+++ b/include/linux/if_tr.h	2004-10-03 00:24:29 -03:00
@@ -48,6 +48,15 @@
 	__u16 rseg[8];			/* routing registers */
 };
 
+#ifdef __KERNEL__
+#include <linux/skbuff.h>
+
+static inline struct trh_hdr *tr_hdr(const struct sk_buff *skb)
+{
+	return (struct trh_hdr *)skb->mac.raw;
+}
+#endif
+
 /* This is an Token-Ring LLC structure */
 struct trllc {
 	__u8  dsap;			/* destination SAP */
diff -Nru a/include/net/llc_pdu.h b/include/net/llc_pdu.h
--- a/include/net/llc_pdu.h	2004-10-03 00:24:29 -03:00
+++ b/include/net/llc_pdu.h	2004-10-03 00:24:29 -03:00
@@ -255,7 +255,7 @@
 	if (skb->protocol == ntohs(ETH_P_802_2))
 		memcpy(sa, eth_hdr(skb)->h_source, ETH_ALEN);
 	else if (skb->protocol == ntohs(ETH_P_TR_802_2))
-		memcpy(sa, ((struct trh_hdr *)skb->mac.raw)->saddr, ETH_ALEN);
+		memcpy(sa, tr_hdr(skb)->saddr, ETH_ALEN);
 }
 
 /**
@@ -270,7 +270,7 @@
 	if (skb->protocol == ntohs(ETH_P_802_2))
 		memcpy(da, eth_hdr(skb)->h_dest, ETH_ALEN);
 	else if (skb->protocol == ntohs(ETH_P_TR_802_2))
-		memcpy(da, ((struct trh_hdr *)skb->mac.raw)->daddr, ETH_ALEN);
+		memcpy(da, tr_hdr(skb)->daddr, ETH_ALEN);
 }
 
 /**
diff -Nru a/net/llc/llc_output.c b/net/llc/llc_output.c
--- a/net/llc/llc_output.c	2004-10-03 00:24:29 -03:00
+++ b/net/llc/llc_output.c	2004-10-03 00:24:29 -03:00
@@ -40,7 +40,8 @@
 		struct net_device *dev = skb->dev;
 		struct trh_hdr *trh;
 		
-		trh = (struct trh_hdr *)skb_push(skb, sizeof(*trh));
+		skb->mac.raw = skb_push(skb, sizeof(*trh));
+		trh = tr_hdr(skb);
 		trh->ac = AC;
 		trh->fc = LLC_FRAME;
 		if (sa)
@@ -51,7 +52,6 @@
 			memcpy(trh->daddr, da, dev->addr_len);
 			tr_source_route(skb, trh, dev);
 		}
-		skb->mac.raw = skb->data;
 		break;
 	}
 #endif


--------------050708030604090602070200--
