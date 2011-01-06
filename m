From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] net: ppp: use {get,put}_unaligned_be{16,32}
Date: Thu,  6 Jan 2011 17:37:35 +0800
Message-ID: <1294306655-22033-1-git-send-email-xiaosuo@gmail.com>
Cc: Paul Mackerras <paulus@samba.org>, linux-ppp@vger.kernel.org,
	netdev@vger.kernel.org, Changli Gao <xiaosuo@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-ppp-owner@vger.kernel.org>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
---
 drivers/net/ppp_async.c   |   10 +++++-----
 drivers/net/ppp_deflate.c |    9 ++++-----
 drivers/net/ppp_generic.c |    9 ++++-----
 drivers/net/ppp_mppe.c    |    7 +++----
 drivers/net/ppp_synctty.c |    3 ++-
 5 files changed, 18 insertions(+), 20 deletions(-)
diff --git a/drivers/net/ppp_async.c b/drivers/net/ppp_async.c
index 78d70a6..cbe1e13 100644
--- a/drivers/net/ppp_async.c
+++ b/drivers/net/ppp_async.c
@@ -32,6 +32,7 @@
 #include <linux/init.h>
 #include <linux/jiffies.h>
 #include <linux/slab.h>
+#include <linux/unaligned/be_struct.h>
 #include <asm/uaccess.h>
 #include <asm/string.h>
 
@@ -542,7 +543,7 @@ ppp_async_encode(struct asyncppp *ap)
 	data = ap->tpkt->data;
 	count = ap->tpkt->len;
 	fcs = ap->tfcs;
-	proto = (data[0] << 8) + data[1];
+	proto = get_unaligned_be16(data);
 
 	/*
 	 * LCP packets with code values between 1 (configure-reqest)
@@ -963,7 +964,7 @@ static void async_lcp_peek(struct asyncppp *ap, unsigned char *data,
 	code = data[0];
 	if (code != CONFACK && code != CONFREQ)
 		return;
-	dlen = (data[2] << 8) + data[3];
+	dlen = get_unaligned_be16(data + 2);
 	if (len < dlen)
 		return;		/* packet got truncated or length is bogus */
 
@@ -997,15 +998,14 @@ static void async_lcp_peek(struct asyncppp *ap, unsigned char *data,
 	while (dlen >= 2 && dlen >= data[1] && data[1] >= 2) {
 		switch (data[0]) {
 		case LCP_MRU:
-			val = (data[2] << 8) + data[3];
+			val = get_unaligned_be16(data + 2);
 			if (inbound)
 				ap->mru = val;
 			else
 				ap->chan.mtu = val;
 			break;
 		case LCP_ASYNCMAP:
-			val = (data[2] << 24) + (data[3] << 16)
-				+ (data[4] << 8) + data[5];
+			val = get_unaligned_be32(data + 2);
 			if (inbound)
 				ap->raccm = val;
 			else
diff --git a/drivers/net/ppp_deflate.c b/drivers/net/ppp_deflate.c
index 695bc83..df3ce78 100644
--- a/drivers/net/ppp_deflate.c
+++ b/drivers/net/ppp_deflate.c
@@ -41,6 +41,7 @@
 #include <linux/ppp-comp.h>
 
 #include <linux/zlib.h>
+#include <linux/unaligned/be_struct.h>
 
 /*
  * State for a Deflate (de)compressor.
@@ -232,11 +233,9 @@ static int z_compress(void *arg, unsigned char *rptr, unsigned char *obuf,
 	 */
 	wptr[0] = PPP_ADDRESS(rptr);
 	wptr[1] = PPP_CONTROL(rptr);
-	wptr[2] = PPP_COMP >> 8;
-	wptr[3] = PPP_COMP;
+	put_unaligned_be16(PPP_COMP, wptr + 2);
 	wptr += PPP_HDRLEN;
-	wptr[0] = state->seqno >> 8;
-	wptr[1] = state->seqno;
+	put_unaligned_be16(state->seqno, wptr);
 	wptr += DEFLATE_OVHD;
 	olen = PPP_HDRLEN + DEFLATE_OVHD;
 	state->strm.next_out = wptr;
@@ -451,7 +450,7 @@ static int z_decompress(void *arg, unsigned char *ibuf, int isize,
 	}
 
 	/* Check the sequence number. */
-	seq = (ibuf[PPP_HDRLEN] << 8) + ibuf[PPP_HDRLEN+1];
+	seq = get_unaligned_be16(ibuf + PPP_HDRLEN);
 	if (seq != (state->seqno & 0xffff)) {
 		if (state->debug)
 			printk(KERN_DEBUG "z_decompress%d: bad seq # %d, expected %d\n",
diff --git a/drivers/net/ppp_generic.c b/drivers/net/ppp_generic.c
index 6456484..0a81f0b 100644
--- a/drivers/net/ppp_generic.c
+++ b/drivers/net/ppp_generic.c
@@ -46,6 +46,7 @@
 #include <linux/device.h>
 #include <linux/mutex.h>
 #include <linux/slab.h>
+#include <linux/unaligned/be_struct.h>
 #include <net/slhc_vj.h>
 #include <asm/atomic.h>
 
@@ -210,7 +211,7 @@ struct ppp_net {
 };
 
 /* Get the PPP protocol number from a skb */
-#define PPP_PROTO(skb)	(((skb)->data[0] << 8) + (skb)->data[1])
+#define PPP_PROTO(skb)	get_unaligned_be16((skb)->data)
 
 /* We limit the length of ppp->file.rq to this (arbitrary) value */
 #define PPP_MAX_RQLEN	32
@@ -964,8 +965,7 @@ ppp_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	pp = skb_push(skb, 2);
 	proto = npindex_to_proto[npi];
-	pp[0] = proto >> 8;
-	pp[1] = proto;
+	put_unaligned_be16(proto, pp);
 
 	netif_stop_queue(dev);
 	skb_queue_tail(&ppp->file.xq, skb);
@@ -1473,8 +1473,7 @@ static int ppp_mp_explode(struct ppp *ppp, struct sk_buff *skb)
 		q = skb_put(frag, flen + hdrlen);
 
 		/* make the MP header */
-		q[0] = PPP_MP >> 8;
-		q[1] = PPP_MP;
+		put_unaligned_be16(PPP_MP, q);
 		if (ppp->flags & SC_MP_XSHORTSEQ) {
 			q[2] = bits + ((ppp->nxseq >> 8) & 0xf);
 			q[3] = ppp->nxseq;
diff --git a/drivers/net/ppp_mppe.c b/drivers/net/ppp_mppe.c
index 6d1a1b8..44dab65 100644
--- a/drivers/net/ppp_mppe.c
+++ b/drivers/net/ppp_mppe.c
@@ -55,6 +55,7 @@
 #include <linux/ppp_defs.h>
 #include <linux/ppp-comp.h>
 #include <linux/scatterlist.h>
+#include <linux/unaligned/be_struct.h>
 
 #include "ppp_mppe.h"
 
@@ -395,16 +396,14 @@ mppe_compress(void *arg, unsigned char *ibuf, unsigned char *obuf,
 	 */
 	obuf[0] = PPP_ADDRESS(ibuf);
 	obuf[1] = PPP_CONTROL(ibuf);
-	obuf[2] = PPP_COMP >> 8;	/* isize + MPPE_OVHD + 1 */
-	obuf[3] = PPP_COMP;	/* isize + MPPE_OVHD + 2 */
+	put_unaligned_be16(PPP_COMP, obuf + 2);
 	obuf += PPP_HDRLEN;
 
 	state->ccount = (state->ccount + 1) % MPPE_CCOUNT_SPACE;
 	if (state->debug >= 7)
 		printk(KERN_DEBUG "mppe_compress[%d]: ccount %d\n", state->unit,
 		       state->ccount);
-	obuf[0] = state->ccount >> 8;
-	obuf[1] = state->ccount & 0xff;
+	put_unaligned_be16(state->ccount, obuf);
 
 	if (!state->stateful ||	/* stateless mode     */
 	    ((state->ccount & 0xff) == 0xff) ||	/* "flag" packet      */
diff --git a/drivers/net/ppp_synctty.c b/drivers/net/ppp_synctty.c
index 4c95ec3..fe86826 100644
--- a/drivers/net/ppp_synctty.c
+++ b/drivers/net/ppp_synctty.c
@@ -45,6 +45,7 @@
 #include <linux/completion.h>
 #include <linux/init.h>
 #include <linux/slab.h>
+#include <linux/unaligned/be_struct.h>
 #include <asm/uaccess.h>
 
 #define PPP_VERSION	"2.4.2"
@@ -563,7 +564,7 @@ ppp_sync_txmunge(struct syncppp *ap, struct sk_buff *skb)
 	int islcp;
 
 	data  = skb->data;
-	proto = (data[0] << 8) + data[1];
+	proto = get_unaligned_be16(data);
 
 	/* LCP packets with codes between 1 (configure-request)
 	 * and 7 (code-reject) must be sent as though no options
